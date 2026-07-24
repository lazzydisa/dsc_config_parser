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
        println!("{}: {}", i.0, i.1);
    }
}

// parser() gets &str from the file that sliced on lines()
fn parser(line: &str) -> (String, String) {
    let mut name = String::new();
    let mut value = String::new();

    // skip comment
    'main: for c in line.chars() {
        if c == '#' {
            break 'main;
        } 
        else {
            // getting variable's name
            'var: for var in line.chars() { 
                if var != ' ' && var != ':' && var != '#' {
                    name.push(var);
                }

                if var == ':' {
                    break 'var;
                }
            }

            // getting variable's value
            let mut test = false;
            'val: for val in line.chars() {
                while val != ':' && val != '#' && test == false {
                    continue 'val;
                }

                test = true;

                if val == ' ' || val == ':' || val == '#' {
                    continue 'val;
                }

                if val == '"' {
                    continue 'val;
                } else {
                    value.push(val);
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
