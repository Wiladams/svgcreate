package.path = "../?.lua;"..package.path;

require("svgcreate.svgelements")()

local function speakerContour()
    return [[
        M0,10 
        l5,0
        a5,5 0 0,0 5,-5
        l0,-5 26,0 0,5
        a5,5 0 0,0 5,5  
        l5,0 0,78 -5,0
        a5,5 0 0,0 -5,5
        l0,5 -25,0 0,-5
        a5,5 0 0,0 -5,-5
        l-5,0
        z
    ]]
end

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
                d= speakerContour();
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
