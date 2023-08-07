module cli

import strconv

enum FlagMode {
	bool
	int
	float
	string
}

struct Flag {
	mut:
	mode FlagMode
	val  []string
	name string
	help string
	required bool
	found bool
	times int
}

pub fn (mut c Cmd) add_int(name string, help string) {
	if name.len > c.flag_len {
		c.flag_len = name.len
	}
	c.flags << Flag{.int, [], name, help, false, false, 0}
}

pub fn (mut c Cmd) add_str(name string, help string) {
	if name.len > c.flag_len {
		c.flag_len name.len
	}
	c.flags << Flag{.string, [], name, help, false, false, 0}
}

pub fn (mut c Cmd) add_bool(name string, help string) {
	if name.len > c.flag_len {
		c.flag_len name.len
	}
	c.flags << Flag{.bool, [], name, help, false, false, 0}
}

pub fn (mut c Cmd) set_def(name string, val string) {
	for mut flag in c.flags {
		if flag.name == name {
			flag.val << val
		}
	}
}

pub fn (mut c Cmd) require(name string) {
	for mut flag in c.flags {
		if flag.name == name {
			flag.required = true
		}
	}
}

/*pub fn (mut c Cmd) set(name string, val string) {
	for mut flag in c.flags {
		if flag.name == name {
			flag.val << val
			flag.found = true
			flag.times = flag.times + 1
		}
	}
}*/

pub fn (c Cmd) get_int(name string) int {
	for flag in c.flags {
		if flag.name == name {
			return strconv.atoi(flag.val[0]) or { 
				c.error('invalid type for -' + name) 
			}
		}
	}
	panic(name + " not found")
}

pub fn (c Cmd) get_ints(name string) []int {
	for flag in c.flags {
		if flag.name == name {
			mut i := []int{cap: flag.val.len}
			for val in flag.val {
				i <<  strconv.atoi(val) or { 
					c.error('invalid type for -' + name) 
				}
			}
			return i
		}
	}
	panic(name + " not found")
}
