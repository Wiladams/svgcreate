#!/usr/bin/env luajit 
--[[
    SVG Graphic for the game of Ludo
]]
package.path = "../?.lua;"..package.path;

require("svgcreate.svgelements")()


local function gridLines() 
    local group = g{
        stroke='pink';
        -- vertical lines
        line { x1 = 3.50, y1 =0.0, x2 = 3.50, y2 = 3.0};
        line { x1 = 4.00, y1 =0.0, x2 = 4.00, y2 = 3.0};
    }

    for i=0, 6 do
        group:append(line{x1 = 3.0, y1 =0.5*i, x2=4.5, y2=0.5*i})
    end 
                
    return group; 
end


local doc = svg {
    ['xmlns:xlink']="http://www.w3.org/1999/xlink",
    width="8in", 
    height="8in", 
    viewBox="0 0 8 8",

    -- outer gameboard rectangle
    rect {
        fill="none",
        stroke = "#00ff00",
        stroke_width = "0.1",
        x = 0, y = 0,
        width = 8,
        height = 8
    },

    defs {
        -- upper left quadrant
        g {
            id = "quadrant",
            stroke = "blue",
            stroke_width = 0.01,
            fill = "transparent",
  
            rect {
                x = 0.0, y = 0.0,
                width = 3,
                height = 3
            };

            -- outer diamond
            path {d="M0.0,1.5 L1.5,0 L3.0,1.5 L1.5,3.0 L0,1.5", fill='transparent'};

            -- inner diamond
            path {d="M0.5,1.5 L1.5,0.5 L2.5,1.5 L1.5,2.5, L0.5,1.5", fill='transparent'};


            -- squares inside diamonds
            rect {x = 1.25, y = 0.75, width = 0.5, height = 0.5};
            rect {x = 1.25, y = 1.75, width = 0.5, height = 0.5};
            rect {x = 0.75, y = 1.25, width = 0.5, height = 0.5};
            rect {x = 1.75, y = 1.25, width = 0.5, height = 0.5};


            -- horizontal lines
            gridLines();           
        }
    };

    -- replicate the quadrant, applying rotation and translation to get each into position
    use { ['xlink:href']="#quadrant", transform = "translate(0.25, 0.25)", x = 0, y = 0};
    use { ['xlink:href']="#quadrant", transform = "rotate(90, 0.25, 3.25)  translate(-2.75, -4.25)", x = 0, y = 0};
    use { ['xlink:href']="#quadrant", transform = "rotate(180, 0.25, 3.25)  translate(-7.25, -1.25)", x = 0, y = 0};
    use { ['xlink:href']="#quadrant", transform = "rotate(-90, 0.25, 3.25)  translate(-4.25, 3.25)", x = 0, y = 0};

    -- draw a couple of lines crossing in the middle
    line {x1 = 3.25, y1 = 3.25, x2 = 4.75, y2 = 4.75, stroke = "pink", stroke_width = 0.01};
    line {x1 = 3.25, y1 = 4.75, x2 = 4.75, y2 = 3.25, stroke = "pink", stroke_width = 0.01};
}

local FileStream = require("svgcreate.filestream")
local svgstream = require("svgcreate.svgstream")
local ImageStream = svgstream(FileStream.open("ludoboard.svg"))

doc:write(ImageStream);