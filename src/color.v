module cli

struct Color {
pub mut:
        black   string = '\x1b[30m'
        red     string = '\x1b[31m'
        green   string = '\x1b[32m'
        yellow  string = '\x1b[33m'
        blue    string = '\x1b[34m'
        magenta string = '\x1b[35m'
        cyan    string = '\x1b[36m'
        white   string = '\x1b[37m'

        bblack   string = '\x1b[90m'
        bred     string = '\x1b[91m'
        bgreen   string = '\x1b[92m'
        byellow  string = '\x1b[93m'
        bblue    string = '\x1b[94m'
        bmagenta string = '\x1b[95m'
        bcyan    string = '\x1b[96m'
        bwhite   string = '\x1b[97m'

        end string = '\x1b[0m'
}

fn (mut c Color) on() {
	c.black = '\x1b[30m'
	c.red      = '\x1b[31m'
	c.green    = '\x1b[32m'
	c.yellow   = '\x1b[33m'
	c.blue     = '\x1b[34m'
	c.magenta  = '\x1b[35m'
	c.cyan     = '\x1b[36m'
	c.white    = '\x1b[37m'

	c.bblack    = '\x1b[90m'
	c.bred      = '\x1b[91m'
	c.bgreen    = '\x1b[92m'
	c.byellow   = '\x1b[93m'
	c.bblue     = '\x1b[94m'
	c.bmagenta  = '\x1b[95m'
	c.bcyan     = '\x1b[96m'
	c.bwhite    = '\x1b[97m'
}

fn (mut c Color) off() {
	c.black = ''
	c.red      = ''
	c.green    = ''
	c.yellow   = ''
	c.blue     = ''
	c.magenta  = ''
	c.cyan     = ''
	c.white    = ''

	c.bblack    = ''
	c.bred      = ''
	c.bgreen    = ''
	c.byellow   = ''
	c.bblue     = ''
	c.bmagenta  = ''
	c.bcyan     = ''
	c.bwhite    = ''
}