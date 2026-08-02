The parser for .dsc config files rewritten in Go by T117m

The parser accepts a string after reading a file

You may want to collect result of parsing in a slice of the special Result type:
```go
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
```

NOTE:
    This code is for reference only!
    You need only `parser()` from main.go
