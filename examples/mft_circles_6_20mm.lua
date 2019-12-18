require("svgcreate.svgelements")()

local centerDistance = 96
local halfCenter = centerDistance/2
local holeRadius = 19/2
local clampMargin = 20

local height60 = 83.138     -- sqrt(centerDistance*centerDistance + (halfCenter*halfCenter))
--[[
local circle90Locs = {
    -- 90 degree pattern
    {cx=clampMargin+(0*centerDistance), cy=clampMargin+(0*centerDistance), r=holeRadius},
    {cx=clampMargin+(1*centerDistance), cy=clampMargin+(0*centerDistance),r=holeRadius},

    {cx=clampMargin+(0*centerDistance), cy=clampMargin+(1*centerDistance),r=holeRadius},
    {cx=clampMargin+(1*centerDistance), cy=clampMargin+(1*centerDistance),r=holeRadius},
    
    {cx=clampMargin+(0*centerDistance), cy=clampMargin+(2*centerDistance),r=holeRadius},
    {cx=clampMargin+(1*centerDistance), cy=clampMargin+(2*centerDistance),r=holeRadius},
}
--]]
local circle60Locs = {
    -- 60 degree pattern
    {cx = clampMargin+height60, cy=clampMargin+halfCenter, r=holeRadius};
    {cx = clampMargin+height60, cy=clampMargin+centerDistance+halfCenter, r=holeRadius};
}

--[[
    Algorithm to generate circle pattern based
    on 90 degree grid, specified rows and columns.
]]
local function circles90(params)
    params = params or {
        rows = 3;
        columns = 2;
        centers = 96;
        halfCenter = 96/2;
        holeRadius = 19/2;
        clampMargin = 20;
    }
    params.centers = params.centers or 96;
    params.holeRadius = params.holeRadius or 19/2;
    params.clampMargin = params.clampMargin or 20;
    params.rows = params.rows or 3;
    params.columns = params.columns or 2;

    local group = g{
        stroke='black';
        stroke_width = 0.1;
        fill = "transparent";
    }

    for row =0,params.rows-1 do
        for col =0, params.columns-1 do
            local cx = params.clampMargin+(col*params.centers)
            local cy = params.clampMargin+(row*params.centers)
            group:append(circle({cx=cx, cy=cy, r = params.holeRadius}))
        end
    end

    return group
end

local doc = svg {
    ['xmlns:xlink']="http://www.w3.org/1999/xlink",
    width="256mm", 
    height="256mm", 
    viewBox="0 0 256 256",
    transform="translate(10,10)",

    g {
        id = "layer1",

        circles90({columns=2, rows=3}),
    },
    
    -- inner paths
    path {
        id="innerrect1",
        style="stroke-width:0.1; stroke:black; fill:none",
        d=[[
            M40,40 
            l56,0 
            l0,66 
            l-56,0 
            Z]],
    },

    path {
        id="innerrect2",
        style="stroke-width:0.1; stroke:black; fill:none",
        d=[[
            M40,126 
            l56,0 
            l0,66 
            l-56,0 
            Z]],
    },

    -- overall outline
    path {
        id="outline", 
        style="stroke-width:0.1; stroke:black; fill:none",
        d=[[
            M40 20 
            l56 0   
            a20,20 0 1,1 20,20   
            l0 56   
            a20,20 0 1,1 0,40   
            l0 56   
            a20,20 0 1,1 -20,20 
            l-56,0 
            a20,20 0 1,1 -20,-20 
            l0,-56
            a20,20 0 1,1 0,-40 
            l0, -56
            a20,20 0 1,1 20,-20
            Z]],
    }
}


local FileStream = require("svgcreate.filestream")
local svgstream = require("svgcreate.svgstream")
local ImageStream = svgstream(FileStream.open("mft_circles_6_19mm.svg"))

doc:write(ImageStream);
