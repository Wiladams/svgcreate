--[[
	these are some routines that are useful when
	doing some simple parsing activities.  They 
	are typically used when parsing small numbers.

	NOTE:  Wherever they are used could probably 
	be replaced with Lua pattern matching.
]]

local function isspace(c)
	return c == string.byte(' ') or
		c == string.byte('\t') or 
		c == string.byte('\n') or
		c == string.byte('\v') or
		c == string.byte('\f') or
		c == string.byte('\r')
end


local function isdigit(c)
	return c >= string.byte('0') and
		c <= string.byte('9')
end

local function isnum(c)
	return isdigit(c) or
		c == string.byte('+') or
		c == string.byte('-') or
		c == string.byte('e') or
		c == string.byte('E')
end

return {
	isspace = isspace;
	isdigit = isdigit;
	isnum = isnum;
}