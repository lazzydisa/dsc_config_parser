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
    let mut name = String::new();
    let mut value = String::new();

    // skip comment
    'main: for c in line.chars() {
        if c == '#' || c == '\n' {
            continue 'main;
        }
        else {
            // getting variable's name
            'var: for var in line.chars() { 
                if var != ' ' && var != ':' && var != '#' {
                    name.push(var);
                } else {
                    break 'var;
                }
            }

            // getting variable's value
            let mut test1 = false;
            let mut test2 = false;
            'val: for val in line.chars() {
                if val != ':' && test1 == false {
                    continue 'val;
                }

                test1 = true;

                match val {
                    ':' => continue 'val,
                    '"' => { test2 = true; continue 'val; },
                    ' ' => if test2 == false { continue 'val; } else { value.push(val) },
                    '#' => break 'val,
                    _ => value.push(val),
                }
            }

            break 'main;
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
