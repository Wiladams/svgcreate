package.path = "../?.lua;"..package.path;

local ffi = require("ffi")
local tt = require("truetype_parser")
local mmap = require("mmap_win32")

local function printFontInfo(info)
    print("==== FONT INFO ====")
    --print("cmap: ", cmap)
    print("loca: ", info.loca);
    print("head: ", info.head);
    print("glyf: ", info.glyf);
    print("hhea: ", info.hhea);
    print("hmtx: ", info.hmtx);
    print("kern: ", info.kern);
    print("gpos: ", info.gpos);
end

-- memory map the file so we have a pointer to start with
--local ffile = mmap("c:\\windows\\fonts\\calibri.ttf")
local ffile = mmap("c:\\windows\\fonts\\trebuc.ttf")
local data = ffi.cast("uint8_t *", ffile:getPointer());

print("DATA: ", data)

-- initialize a font info so we can start parsing
--local finfo = ffi.new('struct stbtt_fontinfo')
local finfo = tt.stbtt_fontinfo {data = data}
--local res = tt.stbtt_InitFont(finfo, data, 0)

--print("InitFont: ", res)

printFontInfo(finfo)