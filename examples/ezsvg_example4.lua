#!/usr/bin/env luajit 

--[[
    USAGE:
    If you're on Linux, you can simply: 
        ./ezsvg_example4.lua

    If you're on Windows
        luajit ezsvg_example4.lua
]]

package.path = "../?.lua;"..package.path;

-- Gradient Interface needs some Work
-- Better don't use now
require("svgcreate.svgelements")()
local colors = require("svgcreate.colors")
local hsv = colors.hsv;


local doc = svg{
    width = 1000,
    height = 1000,
    stroke = "#222222"
}

--svg = EzSVG.Document(1000, 1000, "#222222")
local gradients = defs{}
doc:append(gradients);

local r = 20

for x=0,1000-r*2,r*2 do
    for y=0,1000-r*2,r*2 do
    
        --local gradient = EzSVG.LinearGradient(0, y/20, 100, x/10)
        local hue = x/4 + y/8
        local gradient = linearGradient {
            id= string.format("MyGradient%d",x+1*y+1),
            x1 = 0,
            y1 = y/20,
            x2 = 100,
            y2 = x/10,
            stop {offset=0,  stop_color = hsv(hue, 50, 50)};
            stop {offset=50, stop_color = hsv(hue, 255, 255)};
            stop {offset=100, stop_color = hsv(hue, 50, 255)};
        };
        gradients:append(gradient);

        local circ = circle {
            cx = x+r, 
            cy = y+r, 
            r = r*0.9,
            fill = string.format("url(#MyGradient%d)",x+1*y+1),
            stroke = "#777777",
            --style = {
            --}
        };  
        --local circle = Circle(x+r, y+r, r * 0.9)
        
        --circle:setStyle({
        --    fill=gradient,
        --    stroke="#777777"
        --})
        
        doc:append(circ);
    end
end

local FileStream = require("svgcreate.filestream")
local svgstream = require("svgcreate.svgstream")
local ImageStream = svgstream(FileStream.open("ezsvg_example4.svg"))

doc:write(ImageStream)
