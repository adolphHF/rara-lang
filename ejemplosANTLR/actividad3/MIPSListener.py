from antlr.RaraLangListener import RaraLangListener


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

    def exitAssignStmt(self, ctx):
        name = ctx.ID().getText()

        if self._expr_is_string(ctx.expr()):
            raise ValueError("Las variables de Iteracion 2 solo pueden guardar enteros")

        self._emit_eval_expr(ctx.expr())
        self.text_lines.append(f"    sw $t0, {self._variable_label(name)}")

    def exitPrintStmt(self, ctx):
        if self._expr_is_string(ctx.expr()):
            label = self._add_string_literal(ctx.expr().getText())
            self._emit_print_string(label)
        else:
            self._emit_eval_expr(ctx.expr())
            self._emit_print_int_from_t0()

        self._emit_print_string("newline")

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
        if hasattr(ctx, "addExpr"):
            self._emit_eval_expr(ctx.addExpr())
            return

        if hasattr(ctx, "mulExpr"):
            self._emit_eval_binary_chain(ctx, ctx.mulExpr(), {"+": "add", "-": "sub"})
            return

        if hasattr(ctx, "atom"):
            self._emit_eval_binary_chain(ctx, ctx.atom(), {"×": "mult", "÷": "div"})
            return

        if ctx.INT() or ctx.BASED_NUMBER():
            self.text_lines.append(f"    li $t0, {self._parse_integer_literal(ctx.getText())}")
            return

        if ctx.ID():
            self.text_lines.append(f"    lw $t0, {self._variable_label(ctx.getText())}")
            return

        if ctx.STRING():
            raise ValueError("Los strings solo pueden usarse directamente con print")

        self._emit_eval_expr(ctx.expr())

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
            self.text_lines.append(f"    {operation} $t0, $t1, $t0")
        elif operation == "mult":
            self.text_lines.extend(
                [
                    "    mult $t1, $t0",
                    "    mflo $t0",
                ]
            )
        elif operation == "div":
            self.text_lines.extend(
                [
                    "    div $t1, $t0",
                    "    mflo $t0",
                ]
            )

    def _push_t0(self):
        self.text_lines.extend(
            [
                "    addi $sp, $sp, -4",
                "    sw $t0, 0($sp)",
            ]
        )

    def _pop_t1(self):
        self.text_lines.extend(
            [
                "    lw $t1, 0($sp)",
                "    addi $sp, $sp, 4",
            ]
        )

    def _emit_print_int_from_t0(self):
        self.text_lines.extend(
            [
                "    li $v0, 1",
                "    move $a0, $t0",
                "    syscall",
            ]
        )

    def _emit_print_string(self, label):
        self.text_lines.extend(
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
