package main

import (
	"fmt"
	"os"
	"strings"
)

type Result struct {
	name, value string
}

func main() {
	var (
		args    = os.Args
		results []Result
	)

	if s, err := string_from_file(args[1]); err == nil {
		for line := range strings.SplitSeq(s, "\n") {
			name, value := parser(line)
			res := Result{name, value}
			results = append(results, res)
		}
	} else {
		fmt.Println(err)
		return
	}

	for _, res := range results {
		if res.name != "" && res.value != "" {
			fmt.Printf("%s: %s\n", res.name, res.value)
		} else {
			fmt.Println("-- empty line --")
		}
	}
}

func parser(line string) (name, value string) {
	var b_name, b_val strings.Builder

name_loop:
	for _, r := range line {
		switch r {
		case ' ', '\t':
			continue name_loop
		case '#', ':':
			break name_loop
		default:
			b_name.WriteRune(r)
		}
	}

	test1, test2, test3 := false, false, false

value_loop:
	for _, r := range line {
		if r != ':' && !test1 {
			continue value_loop
		}

		test1 = true

		switch r {
		case ':':
			continue value_loop
		case '"':
			if !test2 {
				test2 = true
				continue
			} else {
				break value_loop
			}
		case ' ':
			if !test2 && !test3 {
				continue value_loop
			} else if test2 {
				test3 = true
				b_val.WriteRune(r)
			} else {
				break value_loop
			}
		case '#':
			if !test2 {
				break value_loop
			} else {
				b_val.WriteRune(r)
			}
		default:
			test3 = true
			b_val.WriteRune(r)
		}
	}

	return b_name.String(), b_val.String()
}

func string_from_file(path string) (string, error) {
	file, err := os.Open(path)
	if err != nil {
		return "", err
	}

	defer func() {
		if err := file.Close(); err != nil {
			panic(err)
		}
	}()

	fileInfo, err := file.Stat()
	if err != nil {
		return "", err
	}

	data := make([]byte, fileInfo.Size())
	if _, err = file.Read(data); err != nil {
		return "", err
	}

	return string(data), nil
}
