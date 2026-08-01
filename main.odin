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

import "core:fmt"
import "core:io"
import "core:os"
import "core:strings"
import "core:unicode/utf8"

main :: proc() {
	args := os.args

	// a dynamic array that contains (name, value)
	vec: [dynamic][2]string

	if s, err := string_from_file(&args[1]); err == nil {
		if lines, err := strings.split_lines(s); err == nil {
			for line in lines {
				name, value := parser(line)
				r := [2]string{name, value}
				append(&vec, r)
			}
		}
	}

	fmt.println("The result is:")
    for i in vec {
        if i[0] != "" && i[1] != "" {
            fmt.printfln("%s: %s", i[0], i[1])
        } else {
            fmt.println("-- empty line --")
        }
    }
}

// parser() gets &str from the file that sliced on lines()
parser :: proc(line: string) -> (string, string) {
	name, value: [dynamic]rune

	// getting variable's name
	for var in line {
		switch var {
		case ' ', '\t':
			continue
		case '#', ':':
			break
		case:
			append(&name, var)
		}
	}

	// getting variable's value
	test1, test2 := false, false
	for val in line {
		if val != ':' && !test1 {
			continue
		}

		test1 = true

		switch val {
		case ':':
			continue
		case '"':
			if !test2 {test2 = true; continue} else {break}
		case ' ':
			if !test2 {continue} else {append(&value, val)}
		case '#':
			if !test2 {break} else {append(&value, val)}
		case:
			append(&value, val)
		}
	}

	return utf8.runes_to_string(name[:]), utf8.runes_to_string(value[:])
}

string_from_file :: proc(file: ^string) -> (string, os.Error) {
	f, err := os.open(file^)
	if err != nil {
		return "", err
	}

	data: []u8

	if _, err = os.read(f, data); err != nil && err != io.Error.EOF {
		return "", err
	}

    return string(data), err
}
