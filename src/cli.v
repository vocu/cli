module cli

pub struct Cmd {
pub mut:
	name        string
	help		string
	info 		string
	args        []string
	max         int
	min         int
	version		string
	exec		fn (Cmd) = dummy
	color 		Color
mut:
	cmds []Cmd
	flags []Flag
	flag_len int
	cmd_len int
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
	c.add_bool("version", "show version and exit")
	return c
}

pub fn (mut c Cmd) add_cmd(cmd Cmd) {
	c.cmds << cmd
	if cmd.name.len > c.cmd_len {
		c.cmd_len = cmd.name.len
	}
	c.cmds.last().version = c.version
}

pub fn (mut c Cmd) parse(args []string) {
	mut cmd_idx := 0
	mut cmd_found := false
	mut cmd_args := []string{}

	if args.contains('-nocolor')
	{
		c.color.off()
		for mut cmd in c.cmds {
			cmd.color.off()
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

		if args[i] == '-version' {
			c.show_version()
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
						if c.flags[flag_idx].name == 'version' {
							c.show_version()
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
		for idx, cmd in c.cmds {
			if args[i] == cmd.name {
				cmd_idx = idx
				cmd_found = true
				cmd_args = args[i..]
				break outer
			}
		}

		// Parse nearest Cmd matches
		for idx, cmd in c.cmds {
			if cmd.name.starts_with(args[i]) {
				if cmd_found {
					c.error("ambiguity for " + args[i])
				} else {
					cmd_idx = idx
					cmd_found = true
					cmd_args = args[i..]
				}
			}
		}
		if cmd_found {
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

	if cmd_found {
		c.cmds[cmd_idx].parse(cmd_args)
	}
}

