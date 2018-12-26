package.path = "../?.lua;"..package.path;

require("svgcreate.svgelements")()

-- allow the user to pass in a size from command line
-- otherwise, default to a size of 100
local nargs = select('#',...)
local asize = 100
if nargs > 0 then
    asize = tonumber(select(1,...))
end

local hfactor = 0.866;  -- 1/2 * (sqrt(3))
local halfsize = asize / 2
local aheight = asize * hfactor;


local function equilateral(size)

    local group = g{
        line { x1 = 0.0, y1 =0.0, x2 = size, y2 = 0.0};
        line { x1 = size, y1 =0.0, x2 = halfsize, y2 = aheight};
        line { x1 = halfsize, y1 =aheight, x2 = 0.0, y2 = 0.0};
    }

    return group
end





local doc = svg{
    version="1.2", 
    baseProfile="tiny", 
    ['xmlns:xlink']="http://www.w3.org/1999/xlink",  
    width=string.format("%3.2fmm",asize), 
    height=string.format("%3.2fmm",aheight),
    viewBox=string.format("0 0 %d %d",math.ceil(asize),math.ceil(aheight)),

    stroke_width = 0.1,
    stroke = "black",
    fill = "none",

    equilateral(asize)
}


-- write .svg out to stream
local FileStream = require("svgcreate.filestream")
local svgstream = require("svgcreate.svgstream")

local filename = string.format("equilateral_%d.svg", asize)
local imgStream = svgstream(FileStream.open(filename))

doc:write(imgStream)