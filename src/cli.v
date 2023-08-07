module cli

import strconv

pub struct Cmd {
pub mut:
	name        string
	help		string
	info 		string
	args        []string
	max         int
	min         int
	exec		fn (Cmd) = dummy
	color Color
mut:
	subs []Cmd
	int_flags []IntFlag
	str_flags []StrFlag
	bool_flags []BoolFlag
	helps   []Help
	longest int
	longest_sub int
}

[noreturn]
fn (c Cmd) error(s string) {
	eprintln(c.color.bred + "error: " + s + c.color.end)
	exit(1)
}

fn dummy(c Cmd) {

}


pub fn new_cmd(name string) Cmd {
	mut c := Cmd{name: name, max: 0, min: 0}
	c.new_bool(false, "help", "show help", false)
	return c
}

pub fn (mut c Cmd) add_sub(sub Cmd) {
	c.subs << sub
	if sub.name.len > c.longest_sub {
		c.longest_sub = sub.name.len
	}
}

pub fn (mut c Cmd) parse(args []string) {
	mut potential_sub_idx := 0
	mut potential_sub_found := false
	mut potential_sub_args := []string{}

	if args.contains('-nocolor')
	{
		c.color.off()
		for mut sub in c.subs {
			sub.color.off()
		}
	}
		
	outer: for i := 1; i < args.len; i += 1 {
		if args[i] == '-' {
			c.args << args[i + 1..]
			break outer
		}

		if args[i] == '-nocolor' {
			continue outer
		}
		
		if args[i] == '-help' {
			c.show_help()
		}

		// Parse Flags
		if args[i].starts_with('-') {

			// Parse int flags
			for mut int_flag in c.int_flags {
				if int_flag.name == args[i][1..] {
					if i + 1 >= args.len || args[i + 1].starts_with('-') {
						c.error('missing argument(s)')
					}
					int_flag.val = strconv.atoi(args[i + 1]) or { c.error('invalid type for ' + args[i]) }
					int_flag.found = true
					i = i + 1
					continue outer
				}
			} // End Parse int flags 
		
			// Parse str flags
			for mut str_flag in c.str_flags {
				if str_flag.name == args[i][1..] {
					if i + 1 >= args.len || args[i + 1].starts_with('-') {
						c.error('missing argument(s)')
					}
					str_flag.val = args[i + 1]
					str_flag.found = true
					i = i + 1
					continue outer
				}
			} // End Parse str flags

			// Parse bool flags
			for mut bool_flag in c.bool_flags {
				if bool_flag.name == args[i][1..] {
					bool_flag.val = true
					bool_flag.times = bool_flag.times + 1
					bool_flag.found = true
					i = i + 1
					continue outer
				}
			} // End Parse bool flags

			mut potential_match := false

			// Check int_flag matches
			mut potential_int_flag_idx := 0
			mut potential_int_flag_found := false
			for idx, int_flag in c.int_flags {
				if int_flag.name.starts_with(args[i][1..]) {
					if !potential_match {
						potential_int_flag_idx = idx
						potential_match = true
						potential_int_flag_found = true
					} else {
						c.error("ambiguity for " + args[i])
					}
				}
			} // End Check int_flag matches

			// Check str_flag matches
			mut potential_str_flag_idx := 0
			mut potential_str_flag_found := false
			for idx, str_flag in c.str_flags {
				if str_flag.name.starts_with(args[i][1..]) {
					if !potential_match {
						potential_str_flag_idx = idx
						potential_match = true
						potential_str_flag_found = true
					} else {
						c.error("ambiguity for " + args[i])
					}
				}
			} // End Check str_flag matches

			// Check bool_flag matches
			mut potential_bool_flag_idx := 0
			mut potential_bool_flag_found := false
			for idx, bool_flag in c.bool_flags {
				if bool_flag.name.starts_with(args[i][1..]) {
					if !potential_match {
						potential_bool_flag_idx = idx
						potential_match = true
						potential_bool_flag_found = true
					} else {
						c.error("ambiguity for " + args[i])
					}
				}
			} // End check bool_flag matches

			if potential_int_flag_found {
				if i + 1 >= args.len || args[i + 1].starts_with('-') {
						c.error('missing argument for -' + c.int_flags[potential_int_flag_idx].name)
					}
					c.int_flags[potential_int_flag_idx].val = strconv.atoi(args[i + 1]) or { c.error('invalid type for ' + args[i]) }
					c.int_flags[potential_int_flag_idx].found = true
					i = i + 1
					continue outer
			}

			if potential_str_flag_found {
				if i + 1 >= args.len || args[i + 1].starts_with('-') {
						c.error('missing argument for -' + c.str_flags[potential_str_flag_idx].name)
					}
					c.str_flags[potential_str_flag_idx].val = args[i + 1]
					c.str_flags[potential_str_flag_idx].found = true
					i = i + 1
					continue outer
			}

			if potential_bool_flag_found {
					if c.bool_flags[potential_bool_flag_idx].name == 'help' {
						c.show_help()
					}
					c.bool_flags[potential_bool_flag_idx].val = true
					c.bool_flags[potential_bool_flag_idx].times = c.bool_flags[potential_bool_flag_idx].times + 1
					c.bool_flags[potential_bool_flag_idx].found = true
					i = i + 1
					continue outer
			}

			/*if potential_bool_flag_found || potential_int_flag_found || potential_str_flag_found {
				c.error("ambiguity for " + args[i])
			}*/

			c.error("invalid option " + args[i])
		} //END Parse flags
		
		// Parse Cmds
		for idx, sub in c.subs {
			if args[i] == sub.name {
				potential_sub_idx = idx
				potential_sub_found = true
				potential_sub_args = args[i..]
				break outer
			}
		}

		// Parse nearest Cmd matches
		for idx, sub in c.subs {
			if sub.name.starts_with(args[i]) {
				if potential_sub_found {
					c.error("ambiguity for " + args[i])
				} else {
					potential_sub_idx = idx
					potential_sub_found = true
					potential_sub_args = args[i..]
				}
			}
		}
		if potential_sub_found {
			break outer
		}

		// Parse as Argument
		c.args << args[i]
	} // END outer

	if c.args.len > c.max {
		c.error("too many arguments")
	} else if c.args.len < c.min{
		c.error("missing argument(s)")
	}

	for int_flag in c.int_flags {
		if int_flag.required && !int_flag.found {
			c.error(" -" + int_flag.name + " is required")
		}
	}

	for str_flag in c.str_flags {
		if str_flag.required && !str_flag.found {
			c.error("-" + str_flag.name + " is required")
		}
	}

	c.exec(*c)

	if potential_sub_found {
		c.subs[potential_sub_idx].parse(potential_sub_args)
	}
}

