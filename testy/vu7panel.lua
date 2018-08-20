package.path = "../?.lua;"..package.path;

require("svgcreate.svgelements")()

local doc = svg {
    ['xmlns:xlink']="http://www.w3.org/1999/xlink",
    width="460mm", 
    height="180mm", 
    viewBox="0 0 460 180",

    defs {
        g {
            id = "speaker",
            fill = "none",
            stroke = "#0000ff",
            stroke_width = "0.1",
            stroke_linejoin = "meter",

            path {
                id = "spkrpath",    
                --d="M0,0 L46,0 L46,98 L0,98 L0,0"
                --d="M10,0 L36,0 Q 36,10 46,10 L46,88 Q 36,88 35,98 L10,98 Q 10,88 0,88 L0,10 Q10,10 10,0"
                d=[[
                    M0,10 
                    A1,1 0 1,0, 10, 0,  
                    L46,0 46,98 0,98 
                    z
                ]]
            };        
        }
    };

    -- Outer rectangle to cut entire panel
    rect {
        fill="none",
        stroke = "#00ff00",
        stroke_width = "0.1",
        x = 0, y = 0,
        width = 460,
        height = 180
    },

    -- cutout for display
    rect {
        fill="none",
        stroke = "#0000ff",
        stroke_width = "0.1",
        x = 142, y = 30,
        width = 165, 
        height = 96,
    },

    -- First speaker
    use { ['xlink:href']="#speaker", transform = "translate(65, 27)", x = 0, y = 0};

    -- Second speaker
    use { ['xlink:href']="#speaker", transform = "translate(338, 27)", x = 0, y = 0};

}


local FileStream = require("svgcreate.filestream")
local svgstream = require("svgcreate.svgstream")
local ImageStream = svgstream(FileStream.open("vu7panel.svg"))

doc:write(ImageStream);
