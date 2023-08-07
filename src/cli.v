module cli

pub struct Cmd {
pub mut:
	name        string
	help		string
	info 		string
	args        []string
	max         int
	min         int
	exec		fn (Cmd) = dummy
	color 		Color
mut:
	subs []Cmd
	flags []Flag
	flag_len int
	sub_len int
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
	c.add_bool("help", "show this help and exit")
	return c
}

pub fn (mut c Cmd) add_sub(sub Cmd) {
	c.subs << sub
	if sub.name.len > c.sub_len {
		c.sub_len = sub.name.len
	}
}

pub fn (mut c Cmd) parse(args []string) {
	mut sub_idx := 0
	mut sub_found := false
	mut sub_args := []string{}

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
			for mut flag in c.flags {
				if flag.name == args[i][1..] {
					if flag.mode == .bool {
						flag.val << "true"
					} else {
						if i + 1 >= args.len || args[i + 1].starts_with('-') {
							c.error('missing argument(s)')
						} else {
							flag.val << args[i + 1]
							i = i + 1
						}
					}
					flag.found = true
					flag.times = flag.times + 1
					continue outer
				}
			}

			mut flag_found := false
			mut flag_idx := 0

			// Check for nearest flag match
			for idx, flag in c.flags {
				if flag.name.starts_with(args[i][1..]) {
					if !flag_found {
						flag_idx = idx
						flag_found = true
					} else {
						c.error("ambiguity for " + args[i])
					}
				}
			} // End Check for nearest flag match

			if flag_found {
				if c.flags[flag_idx].mode == .bool {
						if c.flags[flag_idx].name == 'help' {
							c.show_help()
						}
						c.flags[flag_idx].val << "true"
				} else {
					if i + 1 >= args.len || args[i + 1].starts_with('-') {
						c.error('missing argument(s)')
					} else {
						c.flags[flag_idx].val << args[i + 1]
					}
				}
				c.flags[flag_idx].found = true
				c.flags[flag_idx].times = c.flags[flag_idx].times + 1
				i = i + 1
				continue outer
			}

			c.error("invalid option " + args[i])
		} //END Parse flags
		
		// Parse Cmds
		for idx, sub in c.subs {
			if args[i] == sub.name {
				sub_idx = idx
				sub_found = true
				sub_args = args[i..]
				break outer
			}
		}

		// Parse nearest Cmd matches
		for idx, sub in c.subs {
			if sub.name.starts_with(args[i]) {
				if sub_found {
					c.error("ambiguity for " + args[i])
				} else {
					sub_idx = idx
					sub_found = true
					sub_args = args[i..]
				}
			}
		}
		if sub_found {
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

	for mut flag in c.flags {
		if flag.required && !flag.found {
			c.error(" -" + flag.name + " is required")
		}
		if !flag.found {
			flag.def()
		}
	}

	c.exec(*c)

	if sub_found {
		c.subs[sub_idx].parse(sub_args)
	}
}

