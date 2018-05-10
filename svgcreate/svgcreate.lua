#!/usr/bin/env luajit

--[[
	This little command will read in a .lua file which contains nothing
	more than a svg document table, and will generate the .svg file for it.

	The input is the name of the 'document' file, without the lua extension.
	So, for example, if you have a file 'mysvg.lua', the command would be:

	$ ./svgcreate mysvg

	Which will generate the appropriate svg to stdout.  You can then
	redirect this to whatever file you actually want it to be stored
	in, or redirect to another tool.
--]]

package.path = "../?.lua;"..package.path;
require("svgcreate.svgelements")()


-- read the source file
-- pass in the name of your SVG document.lua file, without 
-- the '.lua' extension.
local filename = arg[1]
if not filename then return end

local doc = require(filename)


-- generate the svg and write to stdout
local FileStream = require("svgcreate.filestream")
local svgstream = require("svgcreate.svgstream")
local ImageStream = svgstream(FileStream.new(io.stdout))

doc:write(ImageStream)
