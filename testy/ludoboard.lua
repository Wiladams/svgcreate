#!/usr/bin/env luajit 

package.path = "../?.lua;"..package.path;

require("svgcreate.svgelements")()

local doc = svg {
    ['xmlns:xlink']="http://www.w3.org/1999/xlink",
    width="8in", 
    height="8in", 
    viewBox="0 0 8 8",


    rect {
        fill="none",
        stroke = "#000000",
        stroke_width = "0.1",
        x = 0, y = 0,
        width = 8,
        height = 8
    },

    defs {
        -- upper left
        g {
        id = "quadrant",
        stroke = "#000000",
        stroke_width = 0.01,
        fill = "none",
  
        rect {
            x = 0.25, y = 0.25,
            width = 3,
            height = 3
        };

        -- vertical lines
        line { x1 = 3.75, y1 =0.25, x2 = 3.75, y2 = 3.25};
        line { x1 = 4.25, y1 =0.25, x2 = 4.25, y2 = 3.25};

            -- horizontal lines
            line { x1 = 3.25, y1 = 0.25, x2 = 4.75, y2 = 0.25};
            line { x1 = 3.25, y1 = 0.75, x2 = 4.75, y2 = 0.75};
            line { x1 = 3.25, y1 = 1.25, x2 = 4.75, y2 = 1.25};
            line { x1 = 3.25, y1 = 1.75, x2 = 4.75, y2 = 1.75};
            line { x1 = 3.25, y1 = 2.25, x2 = 4.75, y2 = 2.25};
            line { x1 = 3.25, y1 = 2.75, x2 = 4.75, y2 = 2.75};
            line { x1 = 3.25, y1 = 3.25, x2 = 4.75, y2 = 3.25};
        }
    };

    use { ['xlink:href']="#quadrant", x = 0, y = 0};
    use { ['xlink:href']="#quadrant", transform = "rotate(90, 0.25, 3.25)  translate(-3.0, -4.5)", x = 0, y = 0};
    use { ['xlink:href']="#quadrant", transform = "rotate(180, 0.25, 3.25)  translate(-7.5, -1.5)", x = 0, y = 0};
    use { ['xlink:href']="#quadrant", transform = "rotate(-90, 0.25, 3.25)  translate(-4.5, 3.0)", x = 0, y = 0};
}

local FileStream = require("svgcreate.filestream")
local svgstream = require("svgcreate.svgstream")
local ImageStream = svgstream(FileStream.open("ludoboard.svg"))

doc:write(ImageStream);