package.path = "../?.lua;"..package.path;

require("svgcreate.svgelements")()

--[[
    This is a nameplate to be screwed onto the typical
    door at Microsoft.  It is roughly 7.0inx2.0in

    The text and image can be easily changed out for
    whatever you want, or omitted completely.
]]
local doc = svg {
    ['xmlns:xlink']="http://www.w3.org/1999/xlink",
    width="178mm", 
    height="64mm", 
    viewBox="0 0 178 64",

    -- The outline to be cut out
    rect {
        --fill="url(#MyGradient)",
        fill="none",
        stroke="black",
        x=0, y=0, width="178", height="64",
    },

    image {
        id = "faceimage",
        x = "20",
        y = "4",
        width = "25.93",    -- 196 pixel wide (51.85mm)
        height = "38.63",   -- 292 pixels high (77.25mm)

        viewBox = "0 0 48 96",
        
        --["xlink:href"] = "images/charicature_small.jpg",
        --["xlink:href"] = "images/charicature_small_slate.jpg",
        ["xlink:href"] = "images/charicature_small_bw.jpg",
    };


    -- Title
    text {
        x = 89,
        y = 60,
        fill = "#CCCCCC",
        stroke = "black",
        stroke_width = 0.1,
        font_family = "Arial Rounded MT Bold",
        font_size = "14",
        style = "text-anchor: middle",

        -- The actual text
        "OCTO Ambassador"
    };

    -- Room Number
    text {
        x = 89,
        y = 14,
        fill = "#CCCCCC",
        stroke = "black",
        stroke_width = 0.1,
        font_family = "Arial Rounded MT Bold",
        font_size = "12",
        style = "text-anchor: middle",

        -- The actual text
        "4158"
    };

    -- Mounting Holes
    circle {
        fill = "none",
        stroke = "black",
        stroke_width = 0.1,
        cx = "16",
        cy = "40",
        r = "2"
    };

    circle {
        fill = "none",
        stroke = "black",
        stroke_width = 0.1,
        cx = "162",
        cy = "40",
        r = "2",
    };
}

local FileStream = require("svgcreate.filestream")
local svgstream = require("svgcreate.svgstream")
local ImageStream = svgstream(FileStream.open("test_nameplate.svg"))

doc:write(ImageStream);
