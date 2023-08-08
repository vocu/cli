module cli

import time
import math
import strconv

pub fn (c Cmd) fail(s string) {
	eprintln(c.color.red + ' × ' + c.color.end + s)
}

pub fn (c Cmd) success(s string) {
	println(c.color.green + ' ✓ ' + c.color.end + s)
}

pub fn dur_fmt(sw time.StopWatch) string {
	if sw.elapsed().milliseconds() < 1000 {
		f := 1000000.0
		println(sw.elapsed().nanoseconds())
		return '(' + strconv.f64_to_str_l(math.round_sig(sw.elapsed().nanoseconds()/f, 1)) + 'ms)'
	} else if sw.elapsed().milliseconds() < 60000 {
		return '(' + (sw.elapsed().milliseconds() / 1000).str() + 's)'
	} else {
		return '(' + ((sw.elapsed().milliseconds() / 1000)  / 60).str() + 'm' +  ((sw.elapsed().milliseconds() / 1000) % 60).str() + 's)'
	}
}