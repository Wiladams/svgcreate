package.path = "../?.lua;"..package.path;

--[[
    Generate a sheet of snapwords for kids
    to practice.
]]
require("svgcreate.svgelements")()

local words = require("snapwords_k")



local cols = 4;      -- number of columns
local lmargin = 0.125;
local tmargin = 0.50;
local x = lmargin;
local y = tmargin;
local cellWidth = 2.00;
local cellHeight = 1.50;
local fillColor = "#CCCCCC"
local fontSize = "0.50"


local function genWords(params)
    params = params or {
        lowRange = 1;
        highRange = 28;
    }
    params.lowRange = params.lowRange or 1;
    params.highRange = params.highRange or 28;

    local group = g{
        fill = fillColor,
        font_size = fontSize;
        style = "text-anchor:start";
    }

    local x = lmargin
    local y = tmargin

    for i=params.lowRange,params.highRange do
        --print(i, i%cols)
        x = lmargin + ((i-1)%cols)*cellWidth;
        y = tmargin + math.floor((i-1)/cols)*cellHeight;
        local achar = words[i];
        --print(i, (i-1)%cols, achar)

        local txt = {
            generic_family = "serif";
            style = "text-anchor:start";
            x = x;
            y = y;
            achar,
        }

        group:append(text (txt));
    end

    return group;
end


local function gridLines() 

    local group = g{
        fill = "none";
        stroke='black';
        stroke_width = 0.05;

        -- outer rectangle
        rect {x=0,y=0, width=8,height=10.5};
    }

    -- vertical lines
    for i=1,3 do
        group:append(line{stroke_width=0.01, x1=i*2, y1=0, x2=i*2, y2 = 10.5})

    end

    -- horizontal lines
    for i=1, 6 do
        group:append(line{stroke_width=0.01, x1 = 0.0, y1 =1.5*i, x2=8, y2=1.5*i})
    end 
                
    return group; 
end



local doc = svg {
    ['xmlns:xlink']="http://www.w3.org/1999/xlink",
    width="8in", 
    height="10.5in", 
    viewBox="0 0 8 10.5",   -- set user unnits

    -- insert the grid
    gridLines();

    -- insert the words
    genWords();
}


local FileStream = require("svgcreate.filestream")
local svgstream = require("svgcreate.svgstream")
local ImageStream = svgstream(FileStream.open("snapgrid.svg"))


doc:write(ImageStream);
