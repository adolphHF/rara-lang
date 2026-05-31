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
        literal = ctx.expr().getText()

        if literal.startswith('"'):
            raise ValueError("Las variables de Iteracion 2 solo pueden guardar enteros")

        self._emit_eval_int_expr(literal)
        self.text_lines.append(f"    sw $t0, {self._variable_label(name)}")

    def exitPrintStmt(self, ctx):
        literal = ctx.expr().getText()

        if literal.startswith('"'):
            label = self._add_string_literal(literal)
            self._emit_print_string(label)
        else:
            self._emit_eval_int_expr(literal)
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

    def _emit_eval_int_expr(self, literal):
        if self._is_identifier(literal):
            self.text_lines.append(f"    lw $t0, {self._variable_label(literal)}")
        else:
            self.text_lines.append(f"    li $t0, {self._parse_integer_literal(literal)}")

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

    def _is_identifier(self, literal):
        return literal[0].isalpha()
