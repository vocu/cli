module cli

import time

pub fn (c Cmd) fail(s string) {
	eprintln(c.color.red + ' × ' + c.color.end + s)
}

pub fn (c Cmd) success(s string) {
	println(c.color.green + ' ✓ ' + c.color.end + s)
}

pub fn dur_fmt(sw time.StopWatch) string {
	if sw.elapsed().milliseconds() < 1000 {
		return '(' + sw.elapsed().milliseconds().str() + 'ms)'
	} else if sw.elapsed().milliseconds() < 60000 {
		return '(' + (sw.elapsed().milliseconds() / 1000).str() + 's)'
	} else {
		return '(' + ((sw.elapsed().milliseconds() / 1000)  / 60).str() + 'm' +  ((sw.elapsed().milliseconds() / 1000) % 60).str() + 's)'
	}
}