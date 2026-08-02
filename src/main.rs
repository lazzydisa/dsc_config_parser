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

fn main() {
    let args: Vec<String> = std::env::args().collect();

    // a vector that contains (name, value)
    let mut vec: Vec<(String, String)> = Vec::new();

    if let Ok(info) = string_from_file(&args[1]) {
        for line in info.lines() {
            let r = parser(line);
            vec.push(r);
        }
    }

    println!("The result is:");
    for i in vec {
        if i != ("".to_string(), "".to_string()) {
            println!("{}: {}", i.0, i.1);
        } else {
            println!("-- empty line --");
        }
    }
}

// parser() gets &str from the file that sliced on lines()
fn parser(line: &str) -> (String, String) {
    let (mut name, mut value) = (String::new(), String::new());

    // getting variable's name
    for var in line.chars() {
        match var {
            '"' | '\'' => continue, // don't use that characters in names please
            ' ' | '\t' => continue,
            '#' | ':'  => break,
            _ => name.push(var)
        }
    }

    // getting variable's value
    let (mut test1, mut test2, mut c_test) = (false, false, 'x');
    for val in line.chars() {
        if val != ':' && test1 == false { continue; }

        test1 = true;

        match val {
            ':'  => continue,
            '"'  => if c_test != '\'' {
                if test2 == false {
                    test2 = true;
                    c_test = '"';
                    continue;
                } else {
                    break;
                }
            } else { value.push(val); },
            '\'' => if c_test != '"' {
                if test2 == false { 
                    test2 = true;
                    c_test = '\'';
                    continue;
                } else {
                    break;
                }
            } else { value.push(val); },
            ' '  => if test2 == false { continue; } else { value.push(val); },
            '#'  => if test2 == false { break; } else { value.push(val); },
            _    => value.push(val),
        }
    }

    (name, value)
}

fn string_from_file(file: &str) -> Result<String, String> {
    match std::fs::read_to_string(file) {
        Ok(s) => Ok(s),
        Err(_) => Err(String::from("Error: can't read the file")),
    }
}
