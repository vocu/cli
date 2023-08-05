module cli

struct IntFlag {
mut:
	val  int
	name string
	required bool
	found bool
}

pub fn (mut c Command) new_int(default_val int, name string, help string, required bool) {
	c.int_flags << IntFlag{default_val, name, required, false}
	c.helps << Help{name, help}
	if name.len > c.longest {
		c.longest = name.len
	}
}

pub fn (c Command) get_int(name string) int {
	for int_flag in c.int_flags {
		if int_flag.name == name {
			return int_flag.val
		}
	}
	panic(name + " not found")
}

struct StrFlag {
mut:
	val  string
	name string
	required bool
	found bool
}

pub fn (mut c Command) new_str(default_val string, name string, help string, required bool) {
	c.str_flags << StrFlag{default_val, name, required, false}
	c.helps << Help{name, help}
	if name.len > c.longest {
		c.longest = name.len
	}
}

pub fn (c Command) get_str(name string) string {
	for str_flag in c.str_flags {
		if str_flag.name == name {
			return str_flag.val
		}
	}
	panic(name + " not found")
}

struct BoolFlag {
mut:
	val  bool
	times int
	name string
	required bool
	found bool
}

pub fn (mut c Command) new_bool(default_val bool, name string, help string, required bool) {
	c.bool_flags << BoolFlag{default_val, 0, name, required, false}
	c.helps << Help{name, help}
	if name.len > c.longest {
		c.longest = name.len
	}
}

pub fn (c Command) get_bool(name string) bool {
	for bool_flag in c.bool_flags {
		if bool_flag.name == name {
			return bool_flag.val
		}
	}
	panic(name + " not found")
}

pub fn (c Command) get_bools(name string) int {
	for bool_flag in c.bool_flags {
		if bool_flag.name == name {
			return bool_flag.times
		}
	}
	panic(name + " not found")
}