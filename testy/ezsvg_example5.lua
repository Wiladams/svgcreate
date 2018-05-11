
package.path = "../?.lua;"..package.path;
require("svgcreate.svgelements")()


local dim = 1000
local step = 50


local doc = svg {
    width = dim, height = dim,

    fill= "white",
    stroke= "white",

    rect {
        x = 0, y = 0,
        width = dim, height = dim,
        stroke = "none",
        fill = "rgbcolor(40,40,40)"
    },

    stroke_linecap= "round",
}

local group = g{}



for y=0,dim,step do
    local apath = polyline {
        points = {{0,y}, {500,y/2}, {1000,1000-y}},
        --points = string.format("0,%d, 500,%d/2, 1000,1000-%d", y, y, y),
        fill = "none",
        stroke = "black",
        stroke_width = 1
    }

    group:append(apath)
end


doc:append(group)

--doc:append(EzSVG.Use(group):rotate(180, 500, 500))
--doc:append(EzSVG.Use(group):rotate(90, 500, 500))
--doc:append(EzSVG.Use(group):rotate(270, 500, 500))

doc:append(
    rect {
        fill="none", 
        stroke="black", 
        stroke_width="5",

        x = 0, 
        y = 0,
        width = dim, 
        height = dim
    }
)


local FileStream = require("svgcreate.filestream")
local svgstream = require("svgcreate.svgstream")
local ImageStream = svgstream(FileStream.open("ezsvg_example5.svg"))

doc:write(ImageStream)

