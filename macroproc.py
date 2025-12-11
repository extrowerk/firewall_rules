#!/usr/bin/env python3
import re
import sys

# -------------------------------------------------------------
# Parse macro definitions
# -------------------------------------------------------------
def parse_macros(filename):
    macros = {}
    lines = open(filename).read().splitlines()
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if line.startswith("macro ") and line.endswith(":"):
            name = line[len("macro "):-1].strip()
            i += 1
            body = []
            while i < len(lines) and lines[i].strip() != "end":
                body.append(lines[i])
                i += 1
            macros[name] = "\n".join(body)
        i += 1
    return macros

# -------------------------------------------------------------
# Substitute ${var} with value
# -------------------------------------------------------------
def substitute_vars(text, variables):
    def repl(match):
        var = match.group(1)
        if var not in variables:
            raise ValueError(f"Undefined variable: {var}")
        return variables[var]
    return re.sub(r"\$\{([A-Za-z0-9_]+)\}", repl, text)

# -------------------------------------------------------------
# Deduplicate multi-line comment blocks
# -------------------------------------------------------------
def dedupe_comment_blocks(lines):
    out = []
    seen = set()
    i = 0
    n = len(lines)
    while i < n:
        if lines[i].lstrip().startswith("#"):
            block = []
            while i < n and lines[i].lstrip().startswith("#"):
                block.append(lines[i])
                i += 1
            block_text = "\n".join(block)
            if block_text not in seen:
                seen.add(block_text)
                out.extend(block)
        else:
            out.append(lines[i])
            i += 1
    return out

# -------------------------------------------------------------
# Expand block macro:
#   NAME:
#       proto=tcp port=443 application=foo
#   end
# -------------------------------------------------------------
def expand_block_macro(body, arg_lines, variables):
    expanded = []
    for line in arg_lines:
        line = line.strip()
        if not line:
            continue
        args = {}
        for part in line.split():
            if "=" in part:
                k, v = part.split("=", 1)
                args[k] = v
        temp = body
        for k, v in args.items():
            temp = temp.replace("${" + k + "}", v)
        temp = substitute_vars(temp, variables)
        expanded.extend(temp.splitlines())
    return expanded

# -------------------------------------------------------------
# Expand macros inside input file
# -------------------------------------------------------------
def process_input(inputfile, macros):
    variables = {}
    output = []

    # matches variable assignments: name = "value";
    var_assign = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*\"([^\"]*)\";?")

    lines = open(inputfile).read().splitlines()
    i = 0
    while i < len(lines):
        raw = lines[i]
        line = raw.strip()

        # preserve comments
        if line.startswith("#"):
            output.append(raw)
            i += 1
            continue

        # variable assignments (also emit in output)
        m = var_assign.match(line)
        if m:
            variables[m.group(1)] = m.group(2)
            output.append(raw)  # keep the line in the output
            i += 1
            continue

        # block macro: NAME: ... end
        if line.endswith(":") and " " not in line[:-1]:
            name = line[:-1]
            i += 1
            arg_lines = []
            while i < len(lines) and lines[i].strip() != "end":
                arg_lines.append(lines[i])
                i += 1
            i += 1  # skip "end"
            if name in macros:
                expanded = expand_block_macro(macros[name], arg_lines, variables)
                output.extend(expanded)
            continue

        # simple macro call
        if line in macros:
            temp = substitute_vars(macros[line], variables)
            output.extend(temp.splitlines())
            i += 1
            continue

        # other lines (pass through)
        output.append(raw)
        i += 1

    # deduplicate comment blocks
    output = dedupe_comment_blocks(output)

    return "\n".join(output) + "\n"

# -------------------------------------------------------------
# Main
# -------------------------------------------------------------
def main():
    if len(sys.argv) != 3:
        print("Usage: macroproc.py macros.m inputfile")
        sys.exit(1)
    macros = parse_macros(sys.argv[1])
    result = process_input(sys.argv[2], macros)
    sys.stdout.write(result)

if __name__ == "__main__":
    main()
