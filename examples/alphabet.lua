package.path = "../?.lua;"..package.path;

-- Show alphabet in a grid for kids 
-- to practice
require("svgcreate.svgelements")()

local alphas = {
    [0] = "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G",
    "H",
    "I",
    "J",
    "K",
    "L",
    "M",
    "N",
    "O",
    "P",
    "Q",
    "R",
    "S",
    "T",
    "U",
    "V",
    "W",
    "X",
    "Y",
    "Z"
}

local function lettering()
    local group = g{
        fill = "#CCCCCC",
        stroke = "black",
    }

    local lmargin = 0.125;
    local tmargin = 0.125;
    local x = lmargin;
    local y = tmargin;
    local cellWidth = 2.00;
    local cellHeight = 1.50;

    for i=0,25 do
        --print(i, i%4)
        x = lmargin + (i%4)*cellWidth;
        y = tmargin + math.floor(i/4)*cellHeight;
        local achar = alphas[i];
        print(i, i%4, achar)

        group:append(text {
            style = "text-anchor:start";
            x = x;
            y = y;
            font_size = 0.25,
--            font_family = "Arial",
--            fill = "#CCCCCC",
--            stroke = "black",
            achar
        });
    end

    return group;
end


local function gridLines() 

    local group = g{
        fill = "none";
        stroke='blue';
        stroke_width = 0.05;

        -- outer rectangle
        rect {x=0,y=0, width=8,height=10.5};

        -- vertical lines
        line { x1 = 2.00, y1 =0.0, x2 = 2.00, y2 = 10.50};
        line { x1 = 4.00, y1 =0.0, x2 = 4.00, y2 = 10.50};
        line { x1 = 6.00, y1 =0.0, x2 = 6.00, y2 = 10.50};
    }

    -- horizontal lines
    for i=0, 6 do
        group:append(line{x1 = 0.0, y1 =1.5*i, x2=8, y2=1.5*i})
    end 
                
    return group; 
end



local doc = svg {
    ['xmlns:xlink']="http://www.w3.org/1999/xlink",
    width="8in", 
    height="10.5in", 
    viewBox="0 0 8 10.5",

    -- Draw the grid
    gridLines();

    lettering();
}


local FileStream = require("svgcreate.filestream")
local svgstream = require("svgcreate.svgstream")
local ImageStream = svgstream(FileStream.open("alphagrid.svg"))


doc:write(ImageStream);
