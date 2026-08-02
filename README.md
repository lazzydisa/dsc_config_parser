The parser for .dsc config files rewritten in Odin by T117m (https://github.com/T117m)

The parser accepts a string after reading a file

You may want to collect result of parsing in a dynamic array of the special Result type:
```odin
// a dynamic array that contains names, values and errors
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
```

NOTE:
    This code is for reference only!
    You need only `parser()` from main.odin
