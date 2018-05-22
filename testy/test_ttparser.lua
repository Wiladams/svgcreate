package.path = "../?.lua;"..package.path;

local ffi = require("ffi")
local tt = require("truetype_parser")
local mmap = require("mmap_win32")

local function print_table_head(info)
    print("==== print_table_head ====")
    print("magicNumber: ", info.tables['head'].magicNumber)
    print("unitsPerEm: ", info.tables['head'].unitsPerEm)
    print("fontDirectionHint: ", info.tables['head'].fontDirectionHint)
    print("indexToLocFormat: ", info.tables['head'].indexToLocFormat)
    print("glyphDataFormat: ", info.tables['head'].glyphDataFormat)
end

local function printTables(info)
    print("==== TABLES ====")
    print("Tag    Order   Offset   Length")
    if info.tables then
        for k, v in pairs(info.tables) do
            print(k, v.index, v.offset, v.length)
        end
    end

    print_table_head(info)
end

local function printFontInfo(info)
    print("==== FONT INFO ====")
    print("       Num Tables: ", info.numTables)
    print(" indexToLocFormat: ", info.indexToLocFormat)
    printTables(info)
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