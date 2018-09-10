--[[
    This is an SVG representation of a typical 
    deck to be built
--]]

require("svgcreate.svgelements")()

local function decking()
    local deck = g{
        id = "decking";
        stroke = "black";
        stroke_width = 0.01;
        fill = "yellow";
    }

    local plankCount = 16;
    local plankWidth = 5.5;
    local plankLength = 96;
    local plankGap = 0.15;

    for i=0,plankCount do
        deck:append(rect{x=i*(plankWidth + plankGap);y=0;width=plankWidth, height=plankLength});
    end

    return deck;
end

local doc = svg {
    ['xmlns:xlink']="http://www.w3.org/1999/xlink",
    width="96in", 
    height="96in", 
    viewBox="0 0 384 384",   -- use this to scale reasonably  to fit a screen
    --viewBox="0 0 96 96",   -- use this for real size

    -- posts
    g { id = "posts";
        stroke = "black";
        stroke_width = 0.01;
        fill = "red";

        rect {x=1.51, y =1.51, width = 3.5, height=3.5};
        rect {x=96-1.51-3.51, y =1.51, width = 3.5, height=3.5};
        rect {x=1.51, y =96-1.51-3.51, width = 3.5, height=3.5};
        rect {x=96-1.51-3.51, y =96-1.51-3.51, width = 3.5, height=3.5};
    };

    -- perimeter skirt boards
    g { id = "perimeter";
        stroke = "black",
        stroke_width = 0.1,
        fill = "transparent",
        
        rect {x=0,y=0,width=96,height=1.5};
        rect {x=0, y=1.51, width = 1.5, height = 96-1.51-1.51};
        rect {x=96-1.51, y=1.51, width = 1.5, height = 96-1.51-1.51};
        rect {x=0,y=96-1.51,width=96,height=1.5};
    };

    decking();
}


local FileStream = require("svgcreate.filestream")
local svgstream = require("svgcreate.svgstream")
local ImageStream = svgstream(FileStream.open("playdeck.svg"))

doc:write(ImageStream);