module cli

import strings

struct Help {
    name string
    help string
}

[noreturn]
fn (mut c Cmd) show_help() {

	c.helps.sort(a.name < b.name)

	if !c.info.is_blank() {
		println(c.info)
	}

	print('Usage: ' + c.name + ' ' + c.color.bcyan + '[option]' + c.color.end)
	if c.subs.len > 0 {
		print(c.color.byellow + ' [command]' + c.color.end)
	}
	if c.max > 0 {
		print(c.color.bmagenta + ' [argument]' + c.color.end)
	}
	println('\n\nOptions:')

	for help in c.helps {
		println(c.color.bcyan + '  -' + help.name + c.color.end + strings.repeat(32, c.longest - help.name.len) + '   ' + help.help.replace('\n', '\n' + strings.repeat(32, c.longest + 6)))
	}

	if c.subs.len > 0 {
		println('\nCommands: ')
		for sub in c.subs {
			println('  ' + c.color.byellow + sub.name + c.color.end + strings.repeat(32, c.longest_sub - sub.name.len) + '   ' + sub.help.replace('\n', '\n' + strings.repeat(32, c.longest_sub + 6)))
		}
	}

	exit(0)
}