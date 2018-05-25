#!/usr/bin/env luajit 

package.path = "../?.lua;"..package.path;

require("svgcreate.svgelements")()

local doc = svg {
    ['xmlns:xlink']="http://www.w3.org/1999/xlink",
    width="8in", 
    height="8in", 
    viewBox="0 0 8 8",

    -- outer gameboard rectangle
    rect {
        fill="none",
        stroke = "#000000",
        stroke_width = "0.1",
        x = 0, y = 0,
        width = 8,
        height = 8
    },

    defs {
        -- upper left quadrant
        g {
            id = "quadrant",
            stroke = "#000000",
            stroke_width = 0.01,
            fill = "none",
  
            rect {
                x = 0.0, y = 0.0,
                width = 3,
                height = 3
            };

            -- vertical lines
            line { x1 = 3.50, y1 =0.0, x2 = 3.50, y2 = 3.0};
            line { x1 = 4.00, y1 =0.0, x2 = 4.00, y2 = 3.0};

            -- horizontal lines
            line { x1 = 3.00, y1 = 0.00, x2 = 4.50, y2 = 0.00};
            line { x1 = 3.00, y1 = 0.50, x2 = 4.50, y2 = 0.50};
            line { x1 = 3.00, y1 = 1.00, x2 = 4.50, y2 = 1.00};
            line { x1 = 3.00, y1 = 1.50, x2 = 4.50, y2 = 1.50};
            line { x1 = 3.00, y1 = 2.00, x2 = 4.50, y2 = 2.00};
            line { x1 = 3.00, y1 = 2.50, x2 = 4.50, y2 = 2.50};
            line { x1 = 3.00, y1 = 3.00, x2 = 4.50, y2 = 3.00};
        }
    };

    -- replicate the quadrant, applying rotation and translation to get each into position
    use { ['xlink:href']="#quadrant", transform = "translate(0.25, 0.25)", x = 0, y = 0};
    use { ['xlink:href']="#quadrant", transform = "rotate(90, 0.25, 3.25)  translate(-2.75, -4.25)", x = 0, y = 0};
    use { ['xlink:href']="#quadrant", transform = "rotate(180, 0.25, 3.25)  translate(-7.25, -1.25)", x = 0, y = 0};
    use { ['xlink:href']="#quadrant", transform = "rotate(-90, 0.25, 3.25)  translate(-4.25, 3.25)", x = 0, y = 0};

    -- draw a couple of lines crossing in the middle
    line {x1 = 3.25, y1 = 3.25, x2 = 4.75, y2 = 4.75, stroke = "#000000", stroke_width = 0.01};
    line {x1 = 3.25, y1 = 4.75, x2 = 4.75, y2 = 3.25, stroke = "#000000", stroke_width = 0.01};
}

local FileStream = require("svgcreate.filestream")
local svgstream = require("svgcreate.svgstream")
local ImageStream = svgstream(FileStream.open("ludoboard.svg"))

doc:write(ImageStream);