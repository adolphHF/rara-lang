from antlr.RaraLangListener import RaraLangListener


class _CtrlFrame:
    def __init__(self, kind, ctx, frame_id):
        self.kind = kind
        self.ctx = ctx
        self.frame_id = frame_id
        self.phase = "condition"
        self.then_lines = []
        self.else_lines = []
        self.body_lines = []

        if kind == "if":
            self.then_ctx = ctx.stmt(0)
            self.else_ctx = ctx.stmt(1) if len(ctx.stmt()) > 1 else None
            self.body_ctx = None
        elif kind == "while":
            self.then_ctx = None
            self.else_ctx = None
            self.body_ctx = ctx.stmt()


class MIPSListener(RaraLangListener):
    VALID_BASES = {2, 8, 10, 16}

    def __init__(self):
        self.data_lines = ['newline: .asciiz "\\n"']
        self.text_lines = [
            ".text",
            ".globl main",
            "main:",
        ]
        self.string_count = 0
        self.variables = {}
        self.if_count = 0
        self.while_count = 0
        self.control_stack = []
        self._capture_target = None

    def enterIfStmt(self, ctx):
        self.if_count += 1
        self.control_stack.append(_CtrlFrame("if", ctx, self.if_count))

    def enterWhileStmt(self, ctx):
        self.while_count += 1
        self.control_stack.append(_CtrlFrame("while", ctx, self.while_count))

    def enterEveryRule(self, ctx):
        if not self.control_stack:
            return

        frame = self.control_stack[-1]
        if frame.kind == "if" and ctx is frame.then_ctx:
            frame.phase = "then"
        elif frame.kind == "if" and ctx is frame.else_ctx:
            frame.phase = "else"
        elif frame.kind == "while" and ctx is frame.body_ctx:
            frame.phase = "body"

    def exitAssignStmt(self, ctx):
        name = ctx.ID().getText()

        if self._expr_is_string(ctx.expr()):
            raise ValueError("Las variables de Iteracion 2 solo pueden guardar enteros")

        self._emit_eval_expr(ctx.expr())
        self._emit_line(f"    sw $t0, {self._variable_label(name)}")

    def exitPrintStmt(self, ctx):
        if self._expr_is_string(ctx.expr()):
            label = self._add_string_literal(ctx.expr().getText())
            self._emit_print_string(label)
        else:
            self._emit_eval_expr(ctx.expr())
            self._emit_print_int_from_t0()

        self._emit_print_string("newline")

    def exitIfStmt(self, ctx):
        frame = self.control_stack.pop()
        else_label = f"if_else_{frame.frame_id}"
        end_label = f"if_end_{frame.frame_id}"
        false_label = else_label if frame.else_ctx is not None else end_label

        lines = self._capture_expr_lines(ctx.expr())
        lines.append(f"    beq $t0, $zero, {false_label}")
        lines.extend(frame.then_lines)

        if frame.else_ctx is not None:
            lines.append(f"    j {end_label}")
            lines.append(f"{else_label}:")
            lines.extend(frame.else_lines)

        lines.append(f"{end_label}:")
        self._emit_lines(lines)

    def exitWhileStmt(self, ctx):
        frame = self.control_stack.pop()
        start_label = f"while_start_{frame.frame_id}"
        end_label = f"while_end_{frame.frame_id}"

        lines = [f"{start_label}:"]
        lines.extend(self._capture_expr_lines(ctx.expr()))
        lines.append(f"    beq $t0, $zero, {end_label}")
        lines.extend(frame.body_lines)
        lines.append(f"    j {start_label}")
        lines.append(f"{end_label}:")
        self._emit_lines(lines)

    def exitBlockStmt(self, ctx):
        pass

    def output(self):
        return "\n".join(
            [".data", *self.data_lines, *self.text_lines, "    li $v0, 10", "    syscall", ""]
        )

    def _add_string_literal(self, literal):
        label = f"str_{self.string_count}"
        self.string_count += 1
        value = literal[1:-1]
        self.data_lines.append(f'{label}: .asciiz "{self._escape_asciiz(value)}"')
        return label

    def _parse_integer_literal(self, literal):
        if not literal.startswith("["):
            return int(literal)

        digits, base_text = literal[1:-1].split(":", 1)
        base = int(base_text)
        if base not in self.VALID_BASES:
            raise ValueError(f"Base no soportada en literal {literal}: {base}")

        try:
            return int(digits, base)
        except ValueError as exc:
            raise ValueError(f"Digitos invalidos para base {base} en literal {literal}") from exc

    def _emit_eval_expr(self, ctx):
        ctx_type = type(ctx).__name__

        if ctx_type == "ExprContext":
            self._emit_eval_expr(ctx.compExpr())
            return

        if ctx_type == "CompExprContext":
            self._emit_eval_binary_chain(
                ctx,
                ctx.addExpr(),
                {"==": "eq", "!=": "neq", "<": "lt", ">": "gt"},
            )
            return

        if ctx_type == "AddExprContext":
            self._emit_eval_binary_chain(
                ctx,
                ctx.mulExpr(),
                {"+": "add", "-": "sub", "⊠": "double_plus", "≈": "avg"},
            )
            return

        if ctx_type == "MulExprContext":
            self._emit_eval_binary_chain(ctx, ctx.unaryExpr(), {"×": "mult", "÷": "div", "⊞": "mod"})
            return

        if ctx_type == "UnaryExprContext" and ctx.NEG():
            self._emit_eval_expr(ctx.unaryExpr())
            self._emit_line("    sub $t0, $zero, $t0")
            return

        if ctx_type == "UnaryExprContext":
            self._emit_eval_expr(ctx.atom())
            return

        if ctx_type == "AtomContext" and ctx.expr():
            self._emit_eval_expr(ctx.expr())
            return

        if ctx.INT() or ctx.BASED_NUMBER():
            self._emit_line(f"    li $t0, {self._parse_integer_literal(ctx.getText())}")
            return

        if ctx.ID():
            self._emit_line(f"    lw $t0, {self._variable_label(ctx.getText())}")
            return

        if ctx.STRING():
            raise ValueError("Los strings solo pueden usarse directamente con print")

    def _emit_eval_binary_chain(self, ctx, operands, operations):
        self._emit_eval_expr(operands[0])

        for index, operand in enumerate(operands[1:], start=1):
            operator = ctx.getChild((index * 2) - 1).getText()
            self._push_t0()
            self._emit_eval_expr(operand)
            self._pop_t1()
            self._emit_binary_op(operations[operator])

    def _emit_binary_op(self, operation):
        if operation in {"add", "sub"}:
            self._emit_line(f"    {operation} $t0, $t1, $t0")
        elif operation == "mult":
            self._emit_lines(
                [
                    "    mult $t1, $t0",
                    "    mflo $t0",
                ]
            )
        elif operation == "div":
            self._emit_lines(
                [
                    "    div $t1, $t0",
                    "    mflo $t0",
                ]
            )
        elif operation == "mod":
            self._emit_lines(
                [
                    "    div $t1, $t0",
                    "    mfhi $t0",
                ]
            )
        elif operation == "double_plus":
            self._emit_lines(
                [
                    "    sll $t1, $t1, 1",
                    "    add $t0, $t1, $t0",
                ]
            )
        elif operation == "avg":
            self._emit_lines(
                [
                    "    add $t0, $t1, $t0",
                    "    sra $t0, $t0, 1",
                ]
            )
        elif operation == "eq":
            self._emit_line("    seq $t0, $t1, $t0")
        elif operation == "neq":
            self._emit_line("    sne $t0, $t1, $t0")
        elif operation == "lt":
            self._emit_line("    slt $t0, $t1, $t0")
        elif operation == "gt":
            self._emit_line("    slt $t0, $t0, $t1")

    def _push_t0(self):
        self._emit_lines(
            [
                "    addi $sp, $sp, -4",
                "    sw $t0, 0($sp)",
            ]
        )

    def _pop_t1(self):
        self._emit_lines(
            [
                "    lw $t1, 0($sp)",
                "    addi $sp, $sp, 4",
            ]
        )

    def _emit_print_int_from_t0(self):
        self._emit_lines(
            [
                "    li $v0, 1",
                "    move $a0, $t0",
                "    syscall",
            ]
        )

    def _emit_print_string(self, label):
        self._emit_lines(
            [
                "    li $v0, 4",
                f"    la $a0, {label}",
                "    syscall",
            ]
        )

    def _escape_asciiz(self, value):
        return value.replace("\\", "\\\\").replace('"', '\\"')

    def _variable_label(self, name):
        if name not in self.variables:
            label = f"var_{name}"
            self.variables[name] = label
            self.data_lines.append(f"{label}: .word 0")

        return self.variables[name]

    def _expr_is_string(self, ctx):
        text = ctx.getText()
        return text.startswith('"') and text.endswith('"')

    def _emit_line(self, line):
        self._current_output().append(line)

    def _emit_lines(self, lines):
        self._current_output().extend(lines)

    def _current_output(self):
        if self._capture_target is not None:
            return self._capture_target

        if not self.control_stack:
            return self.text_lines

        frame = self.control_stack[-1]
        if frame.kind == "if" and frame.phase == "else":
            return frame.else_lines
        if frame.kind == "while" and frame.phase == "body":
            return frame.body_lines
        return frame.then_lines

    def _capture_expr_lines(self, ctx):
        previous_target = self._capture_target
        captured = []
        self._capture_target = captured
        self._emit_eval_expr(ctx)
        self._capture_target = previous_target
        return captured
