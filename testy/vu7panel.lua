package.path = "../?.lua;"..package.path;

require("svgcreate.svgelements")()

local function speakerContour()
    -- width = 46
    -- height = 98
    return [[
        M0,8 
        l4,0
        a4,4 0 0,0 4,-4
        l0,-4 28,0 0,4
        a4,4 0 0,0 4,4  
        l4,0 0,84 -4,0
        a4,4 0 0,0 -4,4
        l0,4 -28,0 0,-4
        a4,4 0 0,0 -4,-4
        l-4,0
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

            path {d= speakerContour();};        
        };

        -- cutout for display
        g {
            id = "display",
            fill="none",
            stroke = "#0000ff",
            stroke_width = "0.1",
            rect {
                x = 0, y = 0,
                width = 165, 
                height = 101,
            };
        };
    };
---[[
    -- Outer rectangle to cut entire panel
    rect {
        fill="none",
        stroke = "#00ff00",
        stroke_width = "0.1",
        x = 0, y = 0,
        width = 460,
        height = 180
    },
--]]



---[[
    --use { ['xlink:href']="#display", transform = "translate(65, 27)", x = 142, y = 30};
    use { ['xlink:href']="#display", x = 142, y = 30};

    -- First speaker
    use { ['xlink:href']="#speaker", transform="rotate(15, 23,50)", x = 65, y = 27};

    -- Second speaker
    use { ['xlink:href']="#speaker", x = 338, y = 27};
--]]
}


local FileStream = require("svgcreate.filestream")
local svgstream = require("svgcreate.svgstream")
local ImageStream = svgstream(FileStream.open("vu7panel.svg"))

doc:write(ImageStream);
