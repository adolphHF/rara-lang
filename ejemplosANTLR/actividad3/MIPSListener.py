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

    def exitPrintStmt(self, ctx):
        literal = ctx.expr().getText()

        if literal.startswith('"'):
            label = self._add_string_literal(literal)
            self._emit_print_string(label)
        else:
            value = self._parse_integer_literal(literal)
            self._emit_print_int(value)

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

    def _emit_print_int(self, value):
        self.text_lines.extend(
            [
                "    li $v0, 1",
                f"    li $a0, {value}",
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
