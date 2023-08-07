module cli

import strings

struct Help {
    name string
    help string
}

[noreturn]
fn (c Cmd) show_version() {
	println(c.version)
	exit(0)
}

[noreturn]
fn (mut c Cmd) show_help() {

	c.flags.sort(a.name < b.name)
	c.cmds.sort(a.name < b.name)

	if !c.info.is_blank() {
		println(c.info)
	}

	print('Usage: ' + c.name + ' ' + c.color.bcyan + '[option]' + c.color.end)
	if c.cmds.len > 0 {
		print(c.color.byellow + ' [command]' + c.color.end)
	}
	if c.max > 0 {
		print(c.color.bmagenta + ' [argument]' + c.color.end)
	}
	println('\n\nOptions:')

	for flag in c.flags {
		println(c.color.bcyan + '  -' + flag.name + c.color.end + strings.repeat(32, c.flag_len - flag.name.len) + '   ' + flag.help.replace('\n', '\n' + strings.repeat(32, c.flag_len + 6)))
	}

	if c.cmds.len > 0 {
		println('\nCommands: ')
		for cmd in c.cmds {
			println('  ' + c.color.byellow + cmd.name + c.color.end + strings.repeat(32, c.cmd_len - cmd.name.len) + '   ' + cmd.help.replace('\n', '\n' + strings.repeat(32, c.cmd_len + 6)))
		}
	}

	exit(0)
}