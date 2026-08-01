/* The parser for .dsc config files */

/* Syntax of the config:
 *
 * # - comment
 * name: "value" - variable = "value"
 *
 * Example:
 *
 * ```
 *  # it's a comment
 *  msg: "hello world"
 * ```
 */

package main

import "base:runtime"
import "core:fmt"
import "core:io"
import "core:os"
import "core:strings"

ParsingError :: union {
	runtime.Allocator_Error,
	SyntaxError,
	io.Error,
}

SyntaxError :: string

Result :: struct {
	name, value: string,
	error:       ParsingError,
}

main :: proc() {
	args := os.args

	// a dynamic array that contains (name, value)
	results: [dynamic]Result

	if s, err := string_from_file(&args[1]); err == nil {
		if lines, err := strings.split_lines(s); err == nil {
			for line in lines {
				name, value, err := parser(line)
				res := Result{name, value, err}
				append(&results, res)
			}
		} else {
			fmt.println(err)
			return
		}
	} else {
		fmt.println(err)
		return
	}

	fmt.println("The result is:")
	for res in results {
		if res.error == nil {
			if res.name == "" && res.value == "" {
				continue
			} else {
				fmt.printfln("%s: %s", res.name, res.value)
			}
		} else {
			fmt.println(res.error)
		}
	}
}

parser :: proc(line: string) -> (name, value: string, error: ParsingError) {
	if is_comment(line) || len(line) == 0  {
		return "", "", nil
	}
    if !strings.contains(line, ":") {
		return "", "", SyntaxError("Column not found")
	}

	b_name, b_value: strings.Builder
	runeAdded := false
	columnIndex := 0

	name_loop: for r, i in line {
		switch r {
		case ' ', '\t':
			if !runeAdded {
				continue
			} else {
				return "", "", SyntaxError("Unexpected space or tabulation in the name field")
			}
		case '#':
			return "", "", SyntaxError("Unexpected comment in the name field")
		case '"', '\'', '`':
			return "", "", SyntaxError("Unexpected quote in the name field")
		case ':':
			columnIndex = i
			break name_loop
		case:
			_, err := strings.write_rune(&b_name, r)
			if err != nil {
				return "", "", err
			}
			runeAdded = true
		}
	}

	dq_req, sq_req := false, 0
	dq_check := false
	runeAdded = false

	value_loop: for r, i in line {
		if i < columnIndex + 1 {
			continue
		}

		if dq_check {
			break value_loop
		}

		switch r {
		case '"':
			if runeAdded && !dq_req {
				return "", "", SyntaxError("Unexpected qoute in the value field")
			}
			if !dq_req && !dq_check {
				dq_req = true
			}
			if dq_req {
				dq_req = false
				dq_check = true
			}
		case ' ':
			if dq_req {
				_, err := strings.write_rune(&b_value, r)
				if err != nil {
					return "", "", err
				}
			} else if runeAdded {
				return "", "", SyntaxError("Unexpected space in the value field")
			} else {
				continue
			}
		case '\'':
			if !dq_req {
				return "", "", SyntaxError("Unexpected quote in the value field")
			}
			if sq_req == 0 {
				sq_req += 1
			}
			if sq_req > 0 {
				sq_req -= 1
			}
			_, err := strings.write_rune(&b_value, r)
			if err != nil {
				return "", "", err
			}
		case '#':
			if dq_req && sq_req > 0 {
				_, err := strings.write_rune(&b_value, r)
				if err != nil {
					return "", "", err
				}
			} else {
				break value_loop
			}
		case '\t':
			if runeAdded || dq_req {
				return "", "", SyntaxError("Unexpected tabulation in the value field")
			} else {
				continue
			}
		case:
			_, err := strings.write_rune(&b_value, r)
			if err != nil {
				return "", "", err
			}
		}
	}

	name = strings.to_string(b_name)
	value = strings.to_string(b_value)

	if dq_req {
		return "", "", SyntaxError("Unclosed value field")
	}
	if sq_req > 0 {
		return "", "", SyntaxError("Unclosed field in value")
	}

	return name, value, nil
}

is_comment :: proc(s: string) -> bool {
	if strings.has_prefix(s, "#") {
		return true
	}

	comment_loop: for r in s {
		switch r {
		case ' ', '\t':
			continue
		case '#':
			return true
		case:
			break comment_loop
		}
	}

	return false
}

string_from_file :: proc(file: ^string) -> (string, os.Error) {
	f, err := os.open(file^)
	if err != nil {
		return "", err
	}

	defer os.close(f)

	size, serr := os.file_size(f)
	if serr != nil {
		return "", serr
	}

	data := make([]u8, size)

	if _, err = os.read(f, data); err != nil && err != io.Error.EOF {
		return "", err
	}

	return string(data), err
}
