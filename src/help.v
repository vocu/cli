module cli

import strings

struct Help {
    name string
    help string
}

[noreturn]
fn (mut c Command) show_help() {

	c.helps.sort(a.name < b.name)

	if !c.description.is_blank() {
		println(c.description)
	}
	println('Usage: ' + c.name + ' ' + c.color.bblue + '[option]' + c.color.end + c.color.bmagenta + ' [argument]\n' + c.color.end)

	if c.subs.len > 0 {
		println('Commands: ')
		for sub in c.subs {
			println('  ' + sub.name + strings.repeat(32, c.longest_sub - sub.name.len) + '   ' + sub.help.replace('\n', '\n' + strings.repeat(32, c.longest_sub + 6)))
		}
		println('')
	}

	println('Options:')

	for help in c.helps {
		println(c.color.bblue + '  -' + help.name + c.color.end + strings.repeat(32, c.longest - help.name.len) + '   ' + help.help.replace('\n', '\n' + strings.repeat(32, c.longest + 6)))
	}

	exit(0)
}