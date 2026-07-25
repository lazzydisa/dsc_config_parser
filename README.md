The parser for .dsc config files written on Rust by me

The parser accepts a slice of the String that returned by reading a file

You need to collect result of parsing to Vec<(String, String)>:
```
let mut vec: Vec<(String, String)> = Vec::new();

if let Ok(info) = string_from_file(&args[1]) {
    for line in info.lines() {
        let r = parser(line);
        vec.push(r);
    }
}
```
