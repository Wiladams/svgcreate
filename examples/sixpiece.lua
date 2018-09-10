#!/usr/bin/env luajit 

package.path = "../?.lua;"..package.path;

require("svgcreate.svgelements")()

local doc = svg {
    ['xmlns:xlink']="http://www.w3.org/1999/xlink",
    width="100mm", 
    height="100mm", 
    viewBox="0 0 100 100",

    defs {
        -- upper left quadrant
        g {
            id = "pieces",
            stroke = "blue",
            stroke_width = 0.1,
            fill = "transparent",

            --path {id = "piece3", d="M0,0 L15,0 L15,15 L85,65 L15,15 "};        
            path {id = "piece3", d="M0,0 L15,10 L26,0"};        
        }
    };

    -- replicate the quadrant, applying rotation and translation to get each into position
    use { ['xlink:href']="#piece3", transform = "translate(0.25, 0.25)", x = 0, y = 0};

}

local FileStream = require("svgcreate.filestream")
local svgstream = require("svgcreate.svgstream")
local ImageStream = svgstream(FileStream.open("sixpiece.svg"))

doc:write(ImageStream);