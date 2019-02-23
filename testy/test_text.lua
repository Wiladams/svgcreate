package.path = "../?.lua;"..package.path

require("svgcreate.svgelements")()


local doc = svg {
    ['xmlns:xlink']="http://www.w3.org/1999/xlink",
    g {
        style = "font-size: 36pt",
        text {style="text-anchor:start", x=20, y =30, "Simplest Text"};
    }
}

local FileStream = require("svgcreate.filestream")
local svgstream = require("svgcreate.svgstream")
local ImageStream = svgstream(FileStream.open("test_text.svg"))

doc:write(ImageStream);
