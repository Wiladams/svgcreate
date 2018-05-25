--[[
    Testing the truetype file parser
]]
package.path = "../?.lua;"..package.path;

local ffi = require("ffi")
local tt = require("truetype_parser")
local mmap = require("mmap_win32")



local function print_table_head(info)
    print("==== print_table_head ====")
    print(string.format("magicNumber: 0x%8X", info.tables['head'].magicNumber))
    print("macStyle: ", info.tables['head'].macStyle)
    print("unitsPerEm: ", info.tables['head'].unitsPerEm)
    print("fontDirectionHint: ", info.tables['head'].fontDirectionHint)
    print("indexToLocFormat: ", info.tables['head'].indexToLocFormat)
    print("glyphDataFormat: ", info.tables['head'].glyphDataFormat)
end

local function print_table_glyf(info)
    local glyphs = info.tables['glyf'].glyphs
    local numGlyphs = info.numGlyphs;

    --for i=0, numGlyphs-1 do
    for i, glyph in ipairs(glyphs) do
        --print(string.format("Contours: %d", glyph.numberOfContours))
        
        print(string.format("Contours: %d {%d %d %d %d}", 
            glyph.numberOfContours, glyph.xMin, glyph.yMin, glyph.xMax, glyph.yMax))
    end

end

local function print_table_loca(info)
    local offsets = info.tables['loca'].offsets

    for i=0, info.numGlyphs do
        print(i, offsets[i])
    end
end

local function print_table_name(info)
    local name = info.tables['name']
    print("==== print_table_name ====")
    print("format: ", name.format)
    print("count: ", name.count)
    print("stringoffset: ", name.stringOffset)
    for i, rec in ipairs(name.names) do
        if ((rec.platformID == 1) or (rec.platformID == 3)) and rec.platformSpecificID == 0 then
        print(string.format("%4d    %4d    %4d    %4d    %4d    %4d    %s",
            rec.platformID, rec.platformSpecificID,
            rec.languageID, rec.nameID,
            rec.length, rec.offset, rec.value))
        else
            print(string.format("%4d    %4d    %4d    %4d    %4d    %4d",
            rec.platformID, rec.platformSpecificID,
            rec.languageID, rec.nameID,
            rec.length, rec.offset))
        end
    end
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
    --print_table_name(info)
    --print_table_loca(info)
    print_table_glyf(info)
end

local function printFontInfo(info)
    print("==== FONT INFO ====")
    print("       Num Glyphs: ", info.numGlyphs)
    print("       Num Tables: ", info.numTables)
    print(" indexToLocFormat: ", info.indexToLocFormat)
    print("           ascent: ", info.ascent)
    print("          descent: ", info.descent)
    
    printTables(info)
end

-- memory map the file so we have a pointer to start with
--local ffile = mmap("c:\\windows\\fonts\\calibri.ttf")
local ffile = mmap("c:\\windows\\fonts\\trebuc.ttf")
local data = ffi.cast("uint8_t *", ffile:getPointer());

--print("DATA: ", data)

-- initialize a font info so we can start parsing
--local finfo = ffi.new('struct stbtt_fontinfo')
local finfo = tt.stbtt_fontinfo {data = data}
--local res = tt.stbtt_InitFont(finfo, data, 0)

--print("InitFont: ", res)

printFontInfo(finfo)