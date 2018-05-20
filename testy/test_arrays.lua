local ffi = require("ffi")

ffi.cdef[[
typedef int16_t     stbtt_int16;
typedef stbtt_int16   stbtt_vertex_type;
typedef struct
{
    stbtt_vertex_type x,y,cx,cy,cx1,cy1;
    unsigned char type,padding;
} stbtt_vertex;
]]


local function stbtt_setvertex(v, typ, x, y, cx, cy)
    v.type = typ;
    v.x = x;
    v.y = y;
    v.cx = cx;
    v.cy = cy;
 end

 local function printVertex(v)
    print("==== VERTEX ====")
    print("  type: ", v.type)
    print("     x: ", v.x)
    print("     y: ", v.y)
    print("    cx: ", v.cx)
    print("    cy: ", v.cy)
end

 local function printVertices(verts, nverts, title)
    title = title or "printVertices"

    print(title)
    local i = 0;
    while (i<nverts) do
        printVertex(verts[i])
        i = i + 1;
    end
 end

 local verts = ffi.new('stbtt_vertex[?]', 10)

 printVertices(verts, 10, "BLANK");

 -- set some vertices and do it again
stbtt_setvertex(verts[7], 1, 7, 7, 70, 70)
printVertices(verts, 10, "SET")