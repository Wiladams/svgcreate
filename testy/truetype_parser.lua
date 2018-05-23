--[[
// stb_truetype.h - v1.19 - public domain
// authored from 2009-2016 by Sean Barrett / RAD Game Tools
//
Origin: 
    https://github.com/nothings/stb
    https://raw.githubusercontent.com/nothings/stb/master/stb_truetype.h

The original source does everything from parsing truetype fonts to rendering
them into bitmaps.  In this application, we're only interested in the 
parsing of the files, so that we can generate SVG path information 
per glyph, so all the rendering has been removed.   

Reference
https://developer.apple.com/fonts/TrueType-Reference-Manual/
--]]



local ffi = require("ffi")
local bit = require("bit")
local band, bor, lshift, rshift = bit.band, bit.bor, bit.lshift, bit.rshift

local acos = math.acos;
local sqrt = math.sqrt;
local floor = math.floor;
local ceil = math.ceil;

--[[
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
////
////   INTEGRATION WITH YOUR CODEBASE
////
////   The following sections allow you to supply alternate definitions
////   of C library functions used by stb_truetype, e.g. if you don't
////   link with the C runtime library.
--]]

ffi.cdef[[
   // #define your own (u)stbtt_int8/16/32 before including to override this
   typedef uint8_t   stbtt_uint8;
   typedef int8_t   stbtt_int8;
   typedef uint16_t  stbtt_uint16;
   typedef int16_t  stbtt_int16;
   typedef uint32_t    stbtt_uint32;
   typedef int32_t    stbtt_int32;
]]

--[[
    For finding the right font
]]
ffi.cdef[[
    enum { // platformID
   STBTT_PLATFORM_ID_UNICODE   =0,
   STBTT_PLATFORM_ID_MAC       =1,
   STBTT_PLATFORM_ID_ISO       =2,
   STBTT_PLATFORM_ID_MICROSOFT =3
};

enum { // encodingID for STBTT_PLATFORM_ID_UNICODE
   STBTT_UNICODE_EID_UNICODE_1_0    =0,
   STBTT_UNICODE_EID_UNICODE_1_1    =1,
   STBTT_UNICODE_EID_ISO_10646      =2,
   STBTT_UNICODE_EID_UNICODE_2_0_BMP=3,
   STBTT_UNICODE_EID_UNICODE_2_0_FULL=4
};

enum { // encodingID for STBTT_PLATFORM_ID_MICROSOFT
   STBTT_MS_EID_SYMBOL        =0,
   STBTT_MS_EID_UNICODE_BMP   =1,
   STBTT_MS_EID_SHIFTJIS      =2,
   STBTT_MS_EID_PRC      =3,
   STBTT_MS_EID_BIGFIVE      =4,
   STBTT_MS_EID_JOHAB      =6,
   STBTT_MS_EID_UNICODE_FULL  =10
};

enum { // encodingID for STBTT_PLATFORM_ID_MAC; same as Script Manager codes
   STBTT_MAC_EID_ROMAN        =0,   STBTT_MAC_EID_ARABIC       =4,
   STBTT_MAC_EID_JAPANESE     =1,   STBTT_MAC_EID_HEBREW       =5,
   STBTT_MAC_EID_CHINESE_TRAD =2,   STBTT_MAC_EID_GREEK        =6,
   STBTT_MAC_EID_KOREAN       =3,   STBTT_MAC_EID_RUSSIAN      =7
};

enum { // languageID for STBTT_PLATFORM_ID_MICROSOFT; same as LCID...
       // problematic because there are e.g. 16 english LCIDs and 16 arabic LCIDs
   STBTT_MS_LANG_ENGLISH     =0x0409,   STBTT_MS_LANG_ITALIAN     =0x0410,
   STBTT_MS_LANG_CHINESE     =0x0804,   STBTT_MS_LANG_JAPANESE    =0x0411,
   STBTT_MS_LANG_DUTCH       =0x0413,   STBTT_MS_LANG_KOREAN      =0x0412,
   STBTT_MS_LANG_FRENCH      =0x040c,   STBTT_MS_LANG_RUSSIAN     =0x0419,
   STBTT_MS_LANG_GERMAN      =0x0407,   STBTT_MS_LANG_SPANISH     =0x0409,
   STBTT_MS_LANG_HEBREW      =0x040d,   STBTT_MS_LANG_SWEDISH     =0x041D
};

enum { // languageID for STBTT_PLATFORM_ID_MAC
   STBTT_MAC_LANG_ENGLISH      =0 ,   STBTT_MAC_LANG_JAPANESE     =11,
   STBTT_MAC_LANG_ARABIC       =12,   STBTT_MAC_LANG_KOREAN       =23,
   STBTT_MAC_LANG_DUTCH        =4 ,   STBTT_MAC_LANG_RUSSIAN      =32,
   STBTT_MAC_LANG_FRENCH       =1 ,   STBTT_MAC_LANG_SPANISH      =6 ,
   STBTT_MAC_LANG_GERMAN       =2 ,   STBTT_MAC_LANG_SWEDISH      =5 ,
   STBTT_MAC_LANG_HEBREW       =10,   STBTT_MAC_LANG_CHINESE_SIMPLIFIED =33,
   STBTT_MAC_LANG_ITALIAN      =3 ,   STBTT_MAC_LANG_CHINESE_TRAD =19
};
]]

-- list of valid values for 'encoding_id' for
-- TT_PLATFORM_MICROSOFT
local TT_MS_ID_SYMBOL_CS    = 0;
local TT_MS_ID_UNICODE_CS   = 1;
local TT_MS_ID_SJIS         = 2;
local TT_MS_ID_PRC          = 3;
local TT_MS_ID_BIG_5        = 4;
local TT_MS_ID_WANSUNG      = 5;
local TT_MS_ID_JOHAB        = 6;
local TT_MS_ID_UCS_4        = 10;

local STBTT_ifloor = math.floor
local STBTT_iceil = math.ceil
local STBTT_sqrt =   math.sqrt
local STBTT_pow  =   math.pow
local STBTT_fmod     = math.fmod
local STBTT_cos = math.cos
local STBTT_acos = math.acos
local STBTT_fabs= math.abs

local function STBTT_malloc(x,u)  
    return ffi.new(ct,x)
end

local function STBTT_free(x,u)
    --    ((void)(u),free(x))
end

local STBTT_assert = assert
local function STBTT_strlen(x)
    return #x
--   strlen(x)
end


local function STBTT_memcpy(a,b,c)
    --memcpy
    return nil;
end

local function STBTT_memset(a,b)
    return ffi.set(a, b)
    --define STBTT_memset       memset
end


ffi.cdef[[
// private structure
typedef struct
{
   uint8_t *data;
   size_t cursor;
   size_t size;
} stbtt__buf;
]]

--[[
//////////////////////////////////////////////////////////////////////////////
//
// FONT LOADING
//
//
--]]

--[=[
ffi.cdef[[
// The following structure is defined publically so you can declare one on
// the stack or as a global or etc, but you should treat it as opaque.
struct stbtt_fontinfo
{
   void           * userdata;
   uint8_t  * data;              // pointer to .ttf file
   int              fontstart;         // offset of start of font

   int numGlyphs;                     // number of glyphs, needed for range checking

   int loca,head,glyf,hhea,hmtx,kern,gpos; // table locations as offset from start of .ttf
   int index_map;                     // a cmap mapping for our chosen character encoding
   int indexToLocFormat;              // format needed to map from glyph index to glyph

   stbtt__buf cff;                    // cff font data
   stbtt__buf charstrings;            // the charstring index
   stbtt__buf gsubrs;                 // global charstring subroutines index
   stbtt__buf subrs;                  // private charstring subroutines index
   stbtt__buf fontdicts;              // array of font dicts
   stbtt__buf fdselect;               // map from glyph to fontdict
};
]]
--]=]

-- commands for path drawing
local STBTT_vmove   = 1;
local STBTT_vline   = 2;
local STBTT_vcurve  = 3;
local STBTT_vcubic  = 4;



ffi.cdef[[
typedef stbtt_int16   stbtt_vertex_type;
typedef struct
{
    stbtt_vertex_type x,y,cx,cy,cx1,cy1;
    unsigned char type,padding;
} stbtt_vertex;
]]


local STBTT_MAX_OVERSAMPLE  = 8

assert(STBTT_MAX_OVERSAMPLE <= 255,  "STBTT_MAX_OVERSAMPLE cannot be > 255")


--typedef int stbtt__test_oversample_pow2[(STBTT_MAX_OVERSAMPLE & (STBTT_MAX_OVERSAMPLE-1)) == 0 ? 1 : -1];

--[[
//////////////////////////////////////////////////////////////////////////
//
// stbtt__buf helpers to parse data from file
//
--]]
-- get 8 bits, and advance the cursor
local function stbtt__buf_get8(b)

   if (b.cursor >= b.size) then
      return 0;
   end
   --b.data[b.cursor++];
   local r = b.data[b.cursor];
   b.cursor = b.cursor + 1;
   return r
end

-- get 8 bits, and don't advance the cursor
local function stbtt__buf_peek8(b)
    if (b.cursor >= b.size) then
        return 0;
    end

    return b.data[b.cursor];
end

-- move to a particular position, in bytes
local function stbtt__buf_seek(b, o)
   STBTT_assert(not (o > b.size or o < 0));
   --b.cursor = (o > b.size or o < 0) ? b.size : o;
    if (o > b.size or o < 0) then 
        b.cursor = b.size
    else
        b.cursor = o;
    end

    return true;
end

local function stbtt__buf_skip(b, o)
    return stbtt__buf_seek(b, b.cursor + o);
end

local function stbtt__buf_get(b, n)
    STBTT_assert(n >= 1 and n <= 4);
    local v = 0;
    local i = 0;
    while  (i < n) do
        v = bor(lshift(v, 8), stbtt__buf_get8(b));
        i = i + 1;
    end

    return v;
end

local function stbtt__new_buf(p, size)

   local r = ffi.new(ffi.typeof('stbtt__buf'));
   STBTT_assert(size < 0x40000000);
   r.data = p;
   r.size = size;
   r.cursor = 0;

   return r;
end


local function stbtt__buf_get16(b)  
    return stbtt__buf_get(b, 2)
end

local function stbtt__buf_get32(b)  
    return stbtt__buf_get(b, 4)
end


local function stbtt__buf_range(b, o, s)

    local r = stbtt__new_buf(nil, 0);
    if ((o < 0) or (s < 0) or (o > b.size) or (s > (b.size - o))) then 
        return r;
    end


    r.data = b.data + o;
    r.size = s;
    
    return r;
end


local function stbtt__cff_get_index(b)

    local start = b.cursor;
    local count = stbtt__buf_get16(b);
    if (count > 0) then
        local offsize = stbtt__buf_get8(b);
        STBTT_assert((offsize >= 1) and (offsize <= 4));
        stbtt__buf_skip(b, offsize * count);
        stbtt__buf_skip(b, stbtt__buf_get(b, offsize) - 1);
    end
   
    return stbtt__buf_range(b, start, b.cursor - start);
end


local function stbtt__cff_int(b)

    local b0 = stbtt__buf_get8(b);
    if (b0 >= 32 and b0 <= 246) then       
        return b0 - 139;
    elseif (b0 >= 247 and b0 <= 250) then 
        return (b0 - 247)*256 + stbtt__buf_get8(b) + 108;
    elseif (b0 >= 251 and b0 <= 254) then
        return -(b0 - 251)*256 - stbtt__buf_get8(b) - 108;
    elseif (b0 == 28) then
        return stbtt__buf_get16(b);
    elseif (b0 == 29) then
        return stbtt__buf_get32(b);
    end

    STBTT_assert(false);

    return 0;
end

local function stbtt__cff_skip_operand(b) 

   local b0 = stbtt__buf_peek8(b);
   STBTT_assert(b0 >= 28);
   local v = 0;
   if (b0 == 30) then
      stbtt__buf_skip(b, 1);
      while (b.cursor < b.size) do
         v = stbtt__buf_get8(b);
         if ((bor(v, 0xF) == 0xF) or (rshift(v, 4) == 0xF)) then
            break;
         end
        end
   else 
      stbtt__cff_int(b);
   end
end

local function stbtt__dict_get(b, key)

    stbtt__buf_seek(b, 0);
    while (b.cursor < b.size) do
        local start = b.cursor; 
        local ending=0; 
        local op=0;
        while (stbtt__buf_peek8(b) >= 28) do
         stbtt__cff_skip_operand(b);
        end
        ending = b.cursor;
        op = stbtt__buf_get8(b);
        if (op == 12)  then 
            op = bor(stbtt__buf_get8(b), 0x100); 
        end
        
        if (op == key) then
            return stbtt__buf_range(b, start, ending-start);
        end
    end
    
    return stbtt__buf_range(b, 0, 0);
end

local function stbtt__dict_get_ints(b, key, outcount, out)

    local operands = stbtt__dict_get(b, key);
    local  i=0;
    while (i < outcount and operands.cursor < operands.size) do
        out[i] = stbtt__cff_int(operands);
        i = i + 1;
    end
end

local function stbtt__cff_index_count(b)
   stbtt__buf_seek(b, 0);
   return stbtt__buf_get16(b);
end

local function stbtt__cff_index_get(b, i)
   stbtt__buf_seek(b, 0);
   local count = stbtt__buf_get16(b);
   local offsize = stbtt__buf_get8(b);
   STBTT_assert((i >= 0) and (i < count));
   STBTT_assert(offsize >= 1 and offsize <= 4);
   stbtt__buf_skip(b, i*offsize);
   local start = stbtt__buf_get(b, offsize);
   local ending = stbtt__buf_get(b, offsize);
   return stbtt__buf_range(b, 2+(count+1)*offsize+start, ending - start);
end


--[[
//////////////////////////////////////////////////////////////////////////
//
// accessors to parse data from file
//

// on platforms that don't allow misaligned reads, if we want to allow
// truetype fonts that aren't padded to alignment, define ALLOW_UNALIGNED_TRUETYPE

#define ttBYTE(p)     (* (stbtt_uint8 *) (p))
#define ttCHAR(p)     (* (stbtt_int8 *) (p))
#define ttFixed(p)    ttLONG(p)
--]]
-- BUGBUG - need to mind the signed versions
local function ttUSHORT(p) return ffi.cast('uint16_t',lshift(p[0],8) + p[1]); end
local function ttSHORT(p)  return ffi.cast('int16_t', lshift(p[0],8) + p[1]); end
local function ttULONG(p)  return ffi.cast('uint32_t', lshift(p[0],24) + lshift(p[1],16) + lshift(p[2],8) + p[3]); end
local function ttLONG(p)   return ffi.cast('int32_t',lshift(p[0],24) + lshift(p[1],16) + lshift(p[2],8) + p[3]); end


local function stbtt_tag4(p,c0,c1,c2,c3) 
    return (p[0] == c0 and p[1] == c1 and p[2] == c2 and p[3] == c3)
end

local function stbtt_tag(p,str)           
    return stbtt_tag4(p,str[0],str[1],str[2],str[3])
end

local function stbtt__isfont(font)
   -- check the version number
   if (stbtt_tag4(font, '1',0,0,0))  then return 1; end -- TrueType 1
   if (stbtt_tag(font, "typ1"))   then return true; end -- TrueType with type 1 font -- we don't support this!
   if (stbtt_tag(font, "OTTO"))   then return true; end -- OpenType with CFF
   if (stbtt_tag4(font, 0,1,0,0)) then return true; end -- OpenType 1.0
   if (stbtt_tag(font, "true"))   then return true; end -- Apple specification for TrueType fonts
   
   return false;
end




local function stbtt__find_table(data, fontstart, tag)
    local tagptr = ffi.cast('uint8_t *', tag)

    local num_tables = ttUSHORT(data+fontstart+4);
    local tabledir = fontstart + 12;
    local i = 0;
    while (i < num_tables) do
        local loc = tabledir + 16*i;
        if (stbtt_tag(data+loc+0, tagptr)) then
            return tonumber(ttULONG(data+loc+8));
        end
        i = i + 1;
    end
   
   return 0;
end


local function stbtt_GetFontOffsetForIndex_internal(font_collection, index)
    -- if it's just a font, there's only one valid index
    if (stbtt__isfont(font_collection)) then
        if index == 0 then return 0 end
        return -1;  
    end
    
    -- check if it's a TTC
    if (stbtt_tag(font_collection, "ttcf")) then
      -- version 1?
      if ((ttULONG(font_collection+4) == 0x00010000) or (ttULONG(font_collection+4) == 0x00020000)) then
         local n = ttLONG(font_collection+8);
         if (index >= n) then
            return -1;
         end
         return ttULONG(font_collection+12+index*4);
      end
    end
    
    return -1;
end

local function stbtt_GetNumberOfFonts_internal(font_collection)

   -- if it's just a font, there's only one valid font
   if (stbtt__isfont(font_collection)) then
      return 1;
   end

   -- check if it's a TTC
   if (stbtt_tag(font_collection, "ttcf")) then
      -- version 1?
      if (ttULONG(font_collection+4) == 0x00010000 or ttULONG(font_collection+4) == 0x00020000) then
         return ttLONG(font_collection+8);
      end
    end
   return 0;
end


local function stbtt__get_subrs(cff, fontdict)

   local subrsoff = ffi.new('stbtt_uint32[1]',0); 
   local private_loc = ffi.new('stbtt_uint32[2]',0,0);

   local pdict = ffi.new('stbtt__buf');
   stbtt__dict_get_ints(fontdict, 18, 2, private_loc);
   if ((private_loc[1] ==0) or (private_loc[0]==0)) then return stbtt__new_buf(nil, 0); end

   pdict = stbtt__buf_range(cff, private_loc[1], private_loc[0]);
   stbtt__dict_get_ints(pdict, 19, 1, subrsoff);
   if (subrsoff[0] == 0) then return stbtt__new_buf(nil, 0); end
   stbtt__buf_seek(cff, private_loc[1]+subrsoff[0]);
   
   return stbtt__cff_get_index(cff);
end



--[[
local function stbtt_FindGlyphIndex(info, unicode_codepoint)

   local data = info.data;
   local index_map = info.index_map;

   local format = ttUSHORT(data + index_map + 0);
   if (format == 0) then -- apple byte encoding
      stbtt_int32 bytes = ttUSHORT(data + index_map + 2);
      if (unicode_codepoint < bytes-6)
         return ttBYTE(data + index_map + 6 + unicode_codepoint);
      return false;
   elseif (format == 6) then
      stbtt_uint32 first = ttUSHORT(data + index_map + 6);
      stbtt_uint32 count = ttUSHORT(data + index_map + 8);
      if ((stbtt_uint32) unicode_codepoint >= first && (stbtt_uint32) unicode_codepoint < first+count)
         return ttUSHORT(data + index_map + 10 + (unicode_codepoint - first)*2);
      return 0;
   elseif (format == 2) then
      STBTT_assert(0); -- @TODO: high-byte mapping for japanese/chinese/korean
      return 0;
   elseif (format == 4) then -- standard mapping for windows fonts: binary search collection of ranges
      stbtt_uint16 segcount = ttUSHORT(data+index_map+6) >> 1;
      stbtt_uint16 searchRange = ttUSHORT(data+index_map+8) >> 1;
      stbtt_uint16 entrySelector = ttUSHORT(data+index_map+10);
      stbtt_uint16 rangeShift = ttUSHORT(data+index_map+12) >> 1;

      -- do a binary search of the segments
      stbtt_uint32 endCount = index_map + 14;
      stbtt_uint32 search = endCount;

      if (unicode_codepoint > 0xffff)
         return 0;

      -- they lie from endCount .. endCount + segCount
      -- but searchRange is the nearest power of two, so...
      if (unicode_codepoint >= ttUSHORT(data + search + rangeShift*2))
         search += rangeShift*2;

      -- now decrement to bias correctly to find smallest
      search = search - 2;
      while (entrySelector) do
         searchRange = rshift(searchRange, 1);
         local ending = ttUSHORT(data + search + searchRange*2);
         if (unicode_codepoint > ending) then
            search = search + searchRange*2
         end
         entrySelector = entrySelector - 1;
      end
      search = search + 2;

      do 
         stbtt_uint16 offset, start;
         stbtt_uint16 item = (stbtt_uint16) ((search - endCount) >> 1);

         STBTT_assert(unicode_codepoint <= ttUSHORT(data + endCount + 2*item));
         start = ttUSHORT(data + index_map + 14 + segcount*2 + 2 + 2*item);
         if (unicode_codepoint < start)
            return 0;

         offset = ttUSHORT(data + index_map + 14 + segcount*6 + 2 + 2*item);
         if (offset == 0)
            return (stbtt_uint16) (unicode_codepoint + ttSHORT(data + index_map + 14 + segcount*4 + 2 + 2*item));

         return ttUSHORT(data + offset + (unicode_codepoint-start)*2 + index_map + 14 + segcount*6 + 2 + 2*item);
      end
   elseif (format == 12 or format == 13) then
      stbtt_uint32 ngroups = ttULONG(data+index_map+12);
      local low = 0; 
      local high = (stbtt_int32)ngroups;
      
      -- Binary search the right group.
      while (low < high) do
         stbtt_int32 mid = low + ((high-low) >> 1); // rounds down, so low <= mid < high
         stbtt_uint32 start_char = ttULONG(data+index_map+16+mid*12);
         stbtt_uint32 end_char = ttULONG(data+index_map+16+mid*12+4);
         if ((stbtt_uint32) unicode_codepoint < start_char) then
            high = mid;
         elseif ((stbtt_uint32) unicode_codepoint > end_char) then
            low = mid+1;
         else
            stbtt_uint32 start_glyph = ttULONG(data+index_map+16+mid*12+8);
            if (format == 12)
               return start_glyph + unicode_codepoint-start_char;
            else -- format == 13
               return start_glyph;
            end
        end
      return false; -- not found
    end
   -- @TODO
   STBTT_assert(0);
   return 0;
end
--]]


local function stbtt_GetCodepointShape(info, unicode_codepoint, vertices)
   return stbtt_GetGlyphShape(info, stbtt_FindGlyphIndex(info, unicode_codepoint), vertices);
end

local function stbtt_setvertex(v, typ, x, y, cx, cy)
   v.type = typ;
   v.x = x;
   v.y = y;
   v.cx = cx;
   v.cy = cy;
end

--[[
local function int stbtt__GetGlyfOffset(const stbtt_fontinfo *info, int glyph_index)

   int g1,g2;

   STBTT_assert(!info.cff.size);

   if (glyph_index >= info.numGlyphs) return -1; // glyph index out of range
   if (info.indexToLocFormat >= 2)    return -1; // unknown index.glyph map format

   if (info.indexToLocFormat == 0) {
      g1 = info.glyf + ttUSHORT(info.data + info.loca + glyph_index * 2) * 2;
      g2 = info.glyf + ttUSHORT(info.data + info.loca + glyph_index * 2 + 2) * 2;
   } else {
      g1 = info.glyf + ttULONG (info.data + info.loca + glyph_index * 4);
      g2 = info.glyf + ttULONG (info.data + info.loca + glyph_index * 4 + 4);
   }

   return g1==g2 ? -1 : g1; // if length is 0, return -1
end

int stbtt_GetGlyphBox(const stbtt_fontinfo *info, int glyph_index, int *x0, int *y0, int *x1, int *y1)

    if (info.cff.size > 0) then
      local res = stbtt__GetGlyphInfoT2(info, glyph_index);
      return res;
    else
        local g = stbtt__GetGlyfOffset(info, glyph_index);
        if (g < 0) then return 0; end
        return {
            idx = glyph_index;
            x0 = ttSHORT(info.data + g + 2);
            y0 = ttSHORT(info.data + g + 4);
            x1 = ttSHORT(info.data + g + 6);
            y1 = ttSHORT(info.data + g + 8);
        }
    end

   return 1;
end

int stbtt_GetCodepointBox(const stbtt_fontinfo *info, int codepoint, int *x0, int *y0, int *x1, int *y1)
{
   return stbtt_GetGlyphBox(info, stbtt_FindGlyphIndex(info,codepoint), x0,y0,x1,y1);
}

local function stbtt_IsGlyphEmpty(info, glyph_index)

    local numberOfContours;
    local g;
    
    if (info.cff.size > 0) then
        return stbtt__GetGlyphInfoT2(info, glyph_index) ~= nil;
    end

    local g = stbtt__GetGlyfOffset(info, glyph_index);
    if (g < 0) then return true; end

    local numberOfContours = ttSHORT(info.data + g);
    
    return numberOfContours == 0;
end

local function int stbtt__close_shape(stbtt_vertex *vertices, int num_vertices, int was_off, int start_off,
    stbtt_int32 sx, stbtt_int32 sy, stbtt_int32 scx, stbtt_int32 scy, stbtt_int32 cx, stbtt_int32 cy)
{
   if (start_off) {
      if (was_off)
         stbtt_setvertex(&vertices[num_vertices++], STBTT_vcurve, (cx+scx)>>1, (cy+scy)>>1, cx,cy);
      stbtt_setvertex(&vertices[num_vertices++], STBTT_vcurve, sx,sy,scx,scy);
   } else {
      if (was_off)
         stbtt_setvertex(&vertices[num_vertices++], STBTT_vcurve,sx,sy,cx,cy);
      else
         stbtt_setvertex(&vertices[num_vertices++], STBTT_vline,sx,sy,0,0);
   }
   return num_vertices;
}

local function stbtt__GetGlyphShapeTT(info, glyph_index, stbtt_vertex **pvertices)

   stbtt_int16 numberOfContours;
   stbtt_uint8 *endPtsOfContours;
   stbtt_uint8 *data = info.data;
   stbtt_vertex *vertices=0;
   local num_vertices=0;
   int g = stbtt__GetGlyfOffset(info, glyph_index);

   *pvertices = NULL;

   if (g < 0) return 0;

   numberOfContours = ttSHORT(data + g);

    if (numberOfContours > 0) then
      local flags=0;
      local flagcount=0;
      stbtt_int32 ins, i,j=0,m,n, next_move, was_off=0, off, start_off=0;
      stbtt_int32 x,y,cx,cy,sx,sy, scx,scy;
      stbtt_uint8 *points;
      endPtsOfContours = (data + g + 10);
      ins = ttUSHORT(data + g + 10 + numberOfContours * 2);
      points = data + g + 10 + numberOfContours * 2 + 2 + ins;

      n = 1+ttUSHORT(endPtsOfContours + numberOfContours*2-2);

      m = n + 2*numberOfContours;  -- a loose bound on how many vertices we might need
      --vertices = (stbtt_vertex *) STBTT_malloc(m * sizeof(vertices[0]), info.userdata);
      local vertices = ffi.new("stbtt_vertex[?]", m, info.userdata)
      if (vertices == nil) then 
         return false;
      end

      next_move = 0;
      flagcount=0;

      -- in first pass, we load uninterpreted data into the allocated array
      -- above, shifted to the end of the array so we won't overwrite it when
      -- we create our final data starting from the front

      off = m - n; // starting offset for uninterpreted data, regardless of how m ends up being calculated

      // first load flags

      for (i=0; i < n; ++i) {
         if (flagcount == 0) {
            flags = *points++;
            if (flags & 8)
               flagcount = *points++;
         } else
            --flagcount;
         vertices[off+i].type = flags;
      }

      // now load x coordinates
      x=0;
      for (i=0; i < n; ++i) {
         flags = vertices[off+i].type;
         if (flags & 2) {
            stbtt_int16 dx = *points++;
            x += (flags & 16) ? dx : -dx; // ???
         } else {
            if (!(flags & 16)) {
               x = x + (stbtt_int16) (points[0]*256 + points[1]);
               points += 2;
            }
         }
         vertices[off+i].x = (stbtt_int16) x;
      }

      // now load y coordinates
      y=0;
      for (i=0; i < n; ++i) {
         flags = vertices[off+i].type;
         if (flags & 4) {
            stbtt_int16 dy = *points++;
            y += (flags & 32) ? dy : -dy; // ???
         } else {
            if (!(flags & 32)) {
               y = y + (stbtt_int16) (points[0]*256 + points[1]);
               points += 2;
            }
         }
         vertices[off+i].y = (stbtt_int16) y;
      }

      // now convert them to our format
      num_vertices=0;
      sx = sy = cx = cy = scx = scy = 0;
      for (i=0; i < n; ++i) {
         flags = vertices[off+i].type;
         x     = (stbtt_int16) vertices[off+i].x;
         y     = (stbtt_int16) vertices[off+i].y;

         if (next_move == i) {
            if (i != 0)
               num_vertices = stbtt__close_shape(vertices, num_vertices, was_off, start_off, sx,sy,scx,scy,cx,cy);

            // now start the new one               
            start_off = !(flags & 1);
            if (start_off) {
               // if we start off with an off-curve point, then when we need to find a point on the curve
               // where we can start, and we need to save some state for when we wraparound.
               scx = x;
               scy = y;
               if (!(vertices[off+i+1].type & 1)) {
                  // next point is also a curve point, so interpolate an on-point curve
                  sx = (x + (stbtt_int32) vertices[off+i+1].x) >> 1;
                  sy = (y + (stbtt_int32) vertices[off+i+1].y) >> 1;
               } else {
                  // otherwise just use the next point as our start point
                  sx = (stbtt_int32) vertices[off+i+1].x;
                  sy = (stbtt_int32) vertices[off+i+1].y;
                  ++i; // we're using point i+1 as the starting point, so skip it
               }
            } else {
               sx = x;
               sy = y;
            }
            stbtt_setvertex(&vertices[num_vertices++], STBTT_vmove,sx,sy,0,0);
            was_off = 0;
            next_move = 1 + ttUSHORT(endPtsOfContours+j*2);
            ++j;
         } else {
            if (!(flags & 1)) { // if it's a curve
               if (was_off) // two off-curve control points in a row means interpolate an on-curve midpoint
                  stbtt_setvertex(&vertices[num_vertices++], STBTT_vcurve, (cx+x)>>1, (cy+y)>>1, cx, cy);
               cx = x;
               cy = y;
               was_off = 1;
            } else {
               if (was_off)
                  stbtt_setvertex(&vertices[num_vertices++], STBTT_vcurve, x,y, cx, cy);
               else
                  stbtt_setvertex(&vertices[num_vertices++], STBTT_vline, x,y,0,0);
               was_off = 0;
            }
         }
      }
      num_vertices = stbtt__close_shape(vertices, num_vertices, was_off, start_off, sx,sy,scx,scy,cx,cy);
    elseif (numberOfContours == -1) then
      // Compound shapes.
      int more = 1;
      stbtt_uint8 *comp = data + g + 10;
      num_vertices = 0;
      vertices = 0;
      while (more) {
         stbtt_uint16 flags, gidx;
         int comp_num_verts = 0, i;
         stbtt_vertex *comp_verts = 0, *tmp = 0;
         float mtx[6] = {1,0,0,1,0,0}, m, n;
         
         flags = ttSHORT(comp); comp+=2;
         gidx = ttSHORT(comp); comp+=2;

         if (flags & 2) { // XY values
            if (flags & 1) { // shorts
               mtx[4] = ttSHORT(comp); comp+=2;
               mtx[5] = ttSHORT(comp); comp+=2;
            } else {
               mtx[4] = ttCHAR(comp); comp+=1;
               mtx[5] = ttCHAR(comp); comp+=1;
            }
         }
         else {
            // @TODO handle matching point
            STBTT_assert(0);
         }
         if (flags & (1<<3)) { // WE_HAVE_A_SCALE
            mtx[0] = mtx[3] = ttSHORT(comp)/16384.0f; comp+=2;
            mtx[1] = mtx[2] = 0;
         } else if (flags & (1<<6)) { // WE_HAVE_AN_X_AND_YSCALE
            mtx[0] = ttSHORT(comp)/16384.0f; comp+=2;
            mtx[1] = mtx[2] = 0;
            mtx[3] = ttSHORT(comp)/16384.0f; comp+=2;
         } else if (flags & (1<<7)) { // WE_HAVE_A_TWO_BY_TWO
            mtx[0] = ttSHORT(comp)/16384.0f; comp+=2;
            mtx[1] = ttSHORT(comp)/16384.0f; comp+=2;
            mtx[2] = ttSHORT(comp)/16384.0f; comp+=2;
            mtx[3] = ttSHORT(comp)/16384.0f; comp+=2;
         }
         
         // Find transformation scales.
         m = (float) STBTT_sqrt(mtx[0]*mtx[0] + mtx[1]*mtx[1]);
         n = (float) STBTT_sqrt(mtx[2]*mtx[2] + mtx[3]*mtx[3]);

         // Get indexed glyph.
         comp_num_verts = stbtt_GetGlyphShape(info, gidx, &comp_verts);
         if (comp_num_verts > 0) {
            // Transform vertices.
            for (i = 0; i < comp_num_verts; ++i) {
               stbtt_vertex* v = &comp_verts[i];
               stbtt_vertex_type x,y;
               x=v.x; y=v.y;
               v.x = (stbtt_vertex_type)(m * (mtx[0]*x + mtx[2]*y + mtx[4]));
               v.y = (stbtt_vertex_type)(n * (mtx[1]*x + mtx[3]*y + mtx[5]));
               x=v.cx; y=v.cy;
               v.cx = (stbtt_vertex_type)(m * (mtx[0]*x + mtx[2]*y + mtx[4]));
               v.cy = (stbtt_vertex_type)(n * (mtx[1]*x + mtx[3]*y + mtx[5]));
            }
            // Append vertices.
            tmp = (stbtt_vertex*)STBTT_malloc((num_vertices+comp_num_verts)*sizeof(stbtt_vertex), info.userdata);
            if (!tmp) {
               if (vertices) STBTT_free(vertices, info.userdata);
               if (comp_verts) STBTT_free(comp_verts, info.userdata);
               return 0;
            }
            if (num_vertices > 0) STBTT_memcpy(tmp, vertices, num_vertices*sizeof(stbtt_vertex));
            STBTT_memcpy(tmp+num_vertices, comp_verts, comp_num_verts*sizeof(stbtt_vertex));
            if (vertices) STBTT_free(vertices, info.userdata);
            vertices = tmp;
            STBTT_free(comp_verts, info.userdata);
            num_vertices += comp_num_verts;
         }
         // More components ?
         more = flags & (1<<5);
      }
    elseif (numberOfContours < 0) then
      -- @TODO other compound variations?
      STBTT_assert(0);
    else
      -- numberOfCounters == 0, do nothing
    end

   pvertices[0] = vertices;
   
   return num_vertices;
end
--]]

ffi.cdef[[
typedef struct
{
   int bounds;
   int started;
   float first_x, first_y;
   float x, y;
   stbtt_int32 min_x, max_x, min_y, max_y;

   stbtt_vertex *pvertices;
   int num_vertices;
} stbtt__csctx;
]]


local function STBTT__CSCTX_INIT(bounds) 
    return ffi.new('stbtt__csctx', bounds,0, 0,0, 0,0, 0,0,0,0, nil, 0)
end


local function stbtt__track_vertex(c, x, y)

   if (x > c.max_x or c.started==0) then c.max_x = x; end
   if (y > c.max_y or c.started==0) then c.max_y = y; end
   if (x < c.min_x or c.started==0) then c.min_x = x; end
   if (y < c.min_y or c.started==0) then c.min_y = y; end
   c.started = 1;

   return true
end

local function stbtt__csctx_v(c, typ, x, y, cx, cy, cx1, cy1)

   if (c.bounds ~= 0) then
      stbtt__track_vertex(c, x, y);
      if (typ == STBTT_vcubic) then
         stbtt__track_vertex(c, cx, cy);
         stbtt__track_vertex(c, cx1, cy1);
      end
   else 
      stbtt_setvertex(c.pvertices[c.num_vertices], typ, x, y, cx, cy);
      c.pvertices[c.num_vertices].cx1 = cx1;
      c.pvertices[c.num_vertices].cy1 = cy1;
   end

   c.num_vertices = c.num_vertices + 1;
end

local function stbtt__csctx_close_shape(ctx)
   if ((ctx.first_x ~= ctx.x) or (ctx.first_y ~= ctx.y)) then
      stbtt__csctx_v(ctx, STBTT_vline, ctx.first_x, ctx.first_y, 0, 0, 0, 0);
   end
end

local function stbtt__csctx_rmove_to(ctx, dx, dy)
   stbtt__csctx_close_shape(ctx);
   --ctx.first_x = ctx.x = ctx.x + dx;
   ctx.first_x = ctx.x + dx;
   ctx.x = ctx.x + dx;

   --ctx.first_y = ctx.y = ctx.y + dy;
   ctx.first_y = ctx.y + dy;
   ctx.y = ctx.y + dy;
   
   stbtt__csctx_v(ctx, STBTT_vmove, ctx.x, ctx.y, 0, 0, 0, 0);
end

local function stbtt__csctx_rline_to(ctx, dx, dy)

   ctx.x = ctx.x + dx;
   ctx.y = ctx.y + dy;
   return stbtt__csctx_v(ctx, STBTT_vline, ctx.x, ctx.y, 0, 0, 0, 0);
end

local function stbtt__csctx_rccurve_to(ctx, dx1, dy1, dx2, dy2, dx3, dy3)

   local cx1 = ctx.x + dx1;
   local cy1 = ctx.y + dy1;
   local cx2 = cx1 + dx2;
   local cy2 = cy1 + dy2;
   ctx.x = cx2 + dx3;
   ctx.y = cy2 + dy3;
   return stbtt__csctx_v(ctx, STBTT_vcubic, ctx.x, ctx.y, cx1, cy1, cx2, cy2);
end

--[=[
local function stbtt__buf stbtt__get_subr(stbtt__buf idx, int n)

    local count = stbtt__cff_index_count(&idx);
    local bias = 107;
    
    if (count >= 33900) then
      bias = 32768;
    elseif (count >= 1240)
      bias = 1131;
    end

    n = n + bias;
    if (n < 0 or n >= count) then
      return stbtt__new_buf(NULL, 0);
    end

    return stbtt__cff_index_get(idx, n);
end

local function stbtt__buf stbtt__cid_get_glyph_subrs(const stbtt_fontinfo *info, int glyph_index)
{
   stbtt__buf fdselect = info.fdselect;
   int nranges, start, end, v, fmt, fdselector = -1, i;

   stbtt__buf_seek(&fdselect, 0);
   fmt = stbtt__buf_get8(&fdselect);
   if (fmt == 0) {
      // untested
      stbtt__buf_skip(&fdselect, glyph_index);
      fdselector = stbtt__buf_get8(&fdselect);
   } else if (fmt == 3) {
      nranges = stbtt__buf_get16(&fdselect);
      start = stbtt__buf_get16(&fdselect);
      for (i = 0; i < nranges; i++) {
         v = stbtt__buf_get8(&fdselect);
         end = stbtt__buf_get16(&fdselect);
         if (glyph_index >= start && glyph_index < end) {
            fdselector = v;
            break;
         }
         start = end;
      }
   }
   if (fdselector == -1) stbtt__new_buf(NULL, 0);
   return stbtt__get_subrs(info.cff, stbtt__cff_index_get(info.fontdicts, fdselector));
}

local function int stbtt__run_charstring(const stbtt_fontinfo *info, int glyph_index, stbtt__csctx *c)
{
   int in_header = 1, maskbits = 0, subr_stack_height = 0, sp = 0, v, i, b0;
   int has_subrs = 0, clear_stack;
   float s[48];
   stbtt__buf subr_stack[10], subrs = info.subrs, b;
   float f;

#define STBTT__CSERR(s) (0)

   // this currently ignores the initial width value, which isn't needed if we have hmtx
   b = stbtt__cff_index_get(info.charstrings, glyph_index);
   while (b.cursor < b.size) {
      i = 0;
      clear_stack = 1;
      b0 = stbtt__buf_get8(&b);
      switch (b0) {
      // @TODO implement hinting
      case 0x13: // hintmask
      case 0x14: // cntrmask
         if (in_header)
            maskbits += (sp / 2); // implicit "vstem"
         in_header = 0;
         stbtt__buf_skip(&b, (maskbits + 7) / 8);
         break;

      case 0x01: // hstem
      case 0x03: // vstem
      case 0x12: // hstemhm
      case 0x17: // vstemhm
         maskbits += (sp / 2);
         break;

      case 0x15: // rmoveto
         in_header = 0;
         if (sp < 2) return STBTT__CSERR("rmoveto stack");
         stbtt__csctx_rmove_to(c, s[sp-2], s[sp-1]);
         break;
      case 0x04: // vmoveto
         in_header = 0;
         if (sp < 1) return STBTT__CSERR("vmoveto stack");
         stbtt__csctx_rmove_to(c, 0, s[sp-1]);
         break;
      case 0x16: // hmoveto
         in_header = 0;
         if (sp < 1) return STBTT__CSERR("hmoveto stack");
         stbtt__csctx_rmove_to(c, s[sp-1], 0);
         break;

      case 0x05: // rlineto
         if (sp < 2) return STBTT__CSERR("rlineto stack");
         for (; i + 1 < sp; i += 2)
            stbtt__csctx_rline_to(c, s[i], s[i+1]);
         break;

      // hlineto/vlineto and vhcurveto/hvcurveto alternate horizontal and vertical
      // starting from a different place.

      case 0x07: // vlineto
         if (sp < 1) return STBTT__CSERR("vlineto stack");
         goto vlineto;
      case 0x06: // hlineto
         if (sp < 1) return STBTT__CSERR("hlineto stack");
         for (;;) {
            if (i >= sp) break;
            stbtt__csctx_rline_to(c, s[i], 0);
            i++;
      vlineto:
            if (i >= sp) break;
            stbtt__csctx_rline_to(c, 0, s[i]);
            i++;
         }
         break;

      case 0x1F: // hvcurveto
         if (sp < 4) return STBTT__CSERR("hvcurveto stack");
         goto hvcurveto;
      case 0x1E: // vhcurveto
         if (sp < 4) return STBTT__CSERR("vhcurveto stack");
         for (;;) {
            if (i + 3 >= sp) break;
            stbtt__csctx_rccurve_to(c, 0, s[i], s[i+1], s[i+2], s[i+3], (sp - i == 5) ? s[i + 4] : 0.0f);
            i += 4;
      hvcurveto:
            if (i + 3 >= sp) break;
            stbtt__csctx_rccurve_to(c, s[i], 0, s[i+1], s[i+2], (sp - i == 5) ? s[i+4] : 0.0f, s[i+3]);
            i += 4;
         }
         break;

      case 0x08: // rrcurveto
         if (sp < 6) return STBTT__CSERR("rcurveline stack");
         for (; i + 5 < sp; i += 6)
            stbtt__csctx_rccurve_to(c, s[i], s[i+1], s[i+2], s[i+3], s[i+4], s[i+5]);
         break;

      case 0x18: // rcurveline
         if (sp < 8) return STBTT__CSERR("rcurveline stack");
         for (; i + 5 < sp - 2; i += 6)
            stbtt__csctx_rccurve_to(c, s[i], s[i+1], s[i+2], s[i+3], s[i+4], s[i+5]);
         if (i + 1 >= sp) return STBTT__CSERR("rcurveline stack");
         stbtt__csctx_rline_to(c, s[i], s[i+1]);
         break;

      case 0x19: // rlinecurve
         if (sp < 8) return STBTT__CSERR("rlinecurve stack");
         for (; i + 1 < sp - 6; i += 2)
            stbtt__csctx_rline_to(c, s[i], s[i+1]);
         if (i + 5 >= sp) return STBTT__CSERR("rlinecurve stack");
         stbtt__csctx_rccurve_to(c, s[i], s[i+1], s[i+2], s[i+3], s[i+4], s[i+5]);
         break;

      case 0x1A: // vvcurveto
      case 0x1B: // hhcurveto
         if (sp < 4) return STBTT__CSERR("(vv|hh)curveto stack");
         f = 0.0;
         if (sp & 1) { f = s[i]; i++; }
         for (; i + 3 < sp; i += 4) {
            if (b0 == 0x1B)
               stbtt__csctx_rccurve_to(c, s[i], f, s[i+1], s[i+2], s[i+3], 0.0);
            else
               stbtt__csctx_rccurve_to(c, f, s[i], s[i+1], s[i+2], 0.0, s[i+3]);
            f = 0.0;
         }
         break;

      case 0x0A: // callsubr
         if (!has_subrs) {
            if (info.fdselect.size)
               subrs = stbtt__cid_get_glyph_subrs(info, glyph_index);
            has_subrs = 1;
         }
         // fallthrough
      case 0x1D: // callgsubr
         if (sp < 1) return STBTT__CSERR("call(g|)subr stack");
         v = (int) s[--sp];
         if (subr_stack_height >= 10) return STBTT__CSERR("recursion limit");
         subr_stack[subr_stack_height++] = b;
         b = stbtt__get_subr(b0 == 0x0A ? subrs : info.gsubrs, v);
         if (b.size == 0) return STBTT__CSERR("subr not found");
         b.cursor = 0;
         clear_stack = 0;
         break;

      case 0x0B: // return
         if (subr_stack_height <= 0) return STBTT__CSERR("return outside subr");
         b = subr_stack[--subr_stack_height];
         clear_stack = 0;
         break;

      case 0x0E: // endchar
         stbtt__csctx_close_shape(c);
         return 1;

      case 0x0C: { // two-byte escape
         float dx1, dx2, dx3, dx4, dx5, dx6, dy1, dy2, dy3, dy4, dy5, dy6;
         float dx, dy;
         int b1 = stbtt__buf_get8(&b);
         switch (b1) {
         // @TODO These "flex" implementations ignore the flex-depth and resolution,
         // and always draw beziers.
         case 0x22: // hflex
            if (sp < 7) return STBTT__CSERR("hflex stack");
            dx1 = s[0];
            dx2 = s[1];
            dy2 = s[2];
            dx3 = s[3];
            dx4 = s[4];
            dx5 = s[5];
            dx6 = s[6];
            stbtt__csctx_rccurve_to(c, dx1, 0, dx2, dy2, dx3, 0);
            stbtt__csctx_rccurve_to(c, dx4, 0, dx5, -dy2, dx6, 0);
            break;

         case 0x23: // flex
            if (sp < 13) return STBTT__CSERR("flex stack");
            dx1 = s[0];
            dy1 = s[1];
            dx2 = s[2];
            dy2 = s[3];
            dx3 = s[4];
            dy3 = s[5];
            dx4 = s[6];
            dy4 = s[7];
            dx5 = s[8];
            dy5 = s[9];
            dx6 = s[10];
            dy6 = s[11];
            //fd is s[12]
            stbtt__csctx_rccurve_to(c, dx1, dy1, dx2, dy2, dx3, dy3);
            stbtt__csctx_rccurve_to(c, dx4, dy4, dx5, dy5, dx6, dy6);
            break;

         case 0x24: // hflex1
            if (sp < 9) return STBTT__CSERR("hflex1 stack");
            dx1 = s[0];
            dy1 = s[1];
            dx2 = s[2];
            dy2 = s[3];
            dx3 = s[4];
            dx4 = s[5];
            dx5 = s[6];
            dy5 = s[7];
            dx6 = s[8];
            stbtt__csctx_rccurve_to(c, dx1, dy1, dx2, dy2, dx3, 0);
            stbtt__csctx_rccurve_to(c, dx4, 0, dx5, dy5, dx6, -(dy1+dy2+dy5));
            break;

         case 0x25: // flex1
            if (sp < 11) return STBTT__CSERR("flex1 stack");
            dx1 = s[0];
            dy1 = s[1];
            dx2 = s[2];
            dy2 = s[3];
            dx3 = s[4];
            dy3 = s[5];
            dx4 = s[6];
            dy4 = s[7];
            dx5 = s[8];
            dy5 = s[9];
            dx6 = dy6 = s[10];
            dx = dx1+dx2+dx3+dx4+dx5;
            dy = dy1+dy2+dy3+dy4+dy5;
            if (STBTT_fabs(dx) > STBTT_fabs(dy))
               dy6 = -dy;
            else
               dx6 = -dx;
            stbtt__csctx_rccurve_to(c, dx1, dy1, dx2, dy2, dx3, dy3);
            stbtt__csctx_rccurve_to(c, dx4, dy4, dx5, dy5, dx6, dy6);
            break;

         default:
            return STBTT__CSERR("unimplemented");
         }
      } break;

      default:
         if (b0 != 255 && b0 != 28 && (b0 < 32 || b0 > 254))
            return STBTT__CSERR("reserved operator");

         // push immediate
         if (b0 == 255) {
            f = (float)(stbtt_int32)stbtt__buf_get32(&b) / 0x10000;
         } else {
            stbtt__buf_skip(&b, -1);
            f = (float)(stbtt_int16)stbtt__cff_int(&b);
         }
         if (sp >= 48) return STBTT__CSERR("push stack overflow");
         s[sp++] = f;
         clear_stack = 0;
         break;
      }
      if (clear_stack) sp = 0;
   }
   return STBTT__CSERR("no endchar");

#undef STBTT__CSERR
}

local function int stbtt__GetGlyphShapeT2(const stbtt_fontinfo *info, int glyph_index, stbtt_vertex **pvertices)
{
   // runs the charstring twice, once to count and once to output (to avoid realloc)
   stbtt__csctx count_ctx = STBTT__CSCTX_INIT(1);
   stbtt__csctx output_ctx = STBTT__CSCTX_INIT(0);
   if (stbtt__run_charstring(info, glyph_index, &count_ctx)) {
      *pvertices = (stbtt_vertex*)STBTT_malloc(count_ctx.num_vertices*sizeof(stbtt_vertex), info.userdata);
      output_ctx.pvertices = *pvertices;
      if (stbtt__run_charstring(info, glyph_index, &output_ctx)) {
         STBTT_assert(output_ctx.num_vertices == count_ctx.num_vertices);
         return output_ctx.num_vertices;
      }
   }
   *pvertices = NULL;
   return 0;
}
--]=]
local function stbtt__GetGlyphInfoT2(info, glyph_index)
    local c = STBTT__CSCTX_INIT(1);
    local r = stbtt__run_charstring(info, glyph_index, c);
    if r== 0 then
        return {
            idx = 0;
            x0 = 0;
            y0=0;
            x1 = 0;
            y1 = 0;
        }
    end

    return {
        idx = c.num_vertices;
        x0 = c.min_x;
        y0=c.min_y;
        x1 = max_x;
        y1 = max_y;
    }
end

-- stbtt_vertex **pvertices
--[[
local function stbtt_GetGlyphShape(info, glyph_index, pvertices)

    if (info.cff.size == 0) then
      return stbtt__GetGlyphShapeTT(info, glyph_index, pvertices);
    else
      return stbtt__GetGlyphShapeT2(info, glyph_index, pvertices);
    end

    return false
end
--]]

local function stbtt_GetGlyphHMetrics(info, glyph_index)
    local advanceWidth = 0;
    local leftSideBearing = 0;

    local numOfLongHorMetrics = ttUSHORT(info.data+info.hhea + 34);
    if (glyph_index < numOfLongHorMetrics) then
      advanceWidth    = ttSHORT(info.data + info.hmtx + 4*glyph_index);
      leftSideBearing = ttSHORT(info.data + info.hmtx + 4*glyph_index + 2);
    else 
      advanceWidth    = ttSHORT(info.data + info.hmtx + 4*(numOfLongHorMetrics-1));
      leftSideBearing = ttSHORT(info.data + info.hmtx + 4*numOfLongHorMetrics + 2*(glyph_index - numOfLongHorMetrics));
    end

    return advanceWidth, leftSideBearing;
end

--[=[
local function int  stbtt__GetGlyphKernInfoAdvance(const stbtt_fontinfo *info, int glyph1, int glyph2)
{
   stbtt_uint8 *data = info.data + info.kern;
   stbtt_uint32 needle, straw;
   int l, r, m;

   // we only look at the first table. it must be 'horizontal' and format 0.
   if (!info.kern)
      return 0;
   if (ttUSHORT(data+2) < 1) // number of tables, need at least 1
      return 0;
   if (ttUSHORT(data+8) != 1) // horizontal flag must be set in format
      return 0;

   l = 0;
   r = ttUSHORT(data+10) - 1;
   needle = glyph1 << 16 | glyph2;
   while (l <= r) {
      m = (l + r) >> 1;
      straw = ttULONG(data+18+(m*6)); // note: unaligned read
      if (needle < straw)
         r = m - 1;
      else if (needle > straw)
         l = m + 1;
      else
         return ttSHORT(data+22+(m*6));
   }
   return 0;
}

local function stbtt_int32  stbtt__GetCoverageIndex(stbtt_uint8 *coverageTable, int glyph)
{
    stbtt_uint16 coverageFormat = ttUSHORT(coverageTable);
    switch(coverageFormat) {
        case 1: {
            stbtt_uint16 glyphCount = ttUSHORT(coverageTable + 2);

            // Binary search.
            stbtt_int32 l=0, r=glyphCount-1, m;
            int straw, needle=glyph;
            while (l <= r) {
                stbtt_uint8 *glyphArray = coverageTable + 4;
                stbtt_uint16 glyphID;
                m = (l + r) >> 1;
                glyphID = ttUSHORT(glyphArray + 2 * m);
                straw = glyphID;
                if (needle < straw)
                    r = m - 1;
                else if (needle > straw)
                    l = m + 1;
                else {
                     return m;
                }
            }
        } break;

        case 2: {
            stbtt_uint16 rangeCount = ttUSHORT(coverageTable + 2);
            stbtt_uint8 *rangeArray = coverageTable + 4;

            // Binary search.
            stbtt_int32 l=0, r=rangeCount-1, m;
            int strawStart, strawEnd, needle=glyph;
            while (l <= r) {
                stbtt_uint8 *rangeRecord;
                m = (l + r) >> 1;
                rangeRecord = rangeArray + 6 * m;
                strawStart = ttUSHORT(rangeRecord);
                strawEnd = ttUSHORT(rangeRecord + 2);
                if (needle < strawStart)
                    r = m - 1;
                else if (needle > strawEnd)
                    l = m + 1;
                else {
                    stbtt_uint16 startCoverageIndex = ttUSHORT(rangeRecord + 4);
                    return startCoverageIndex + glyph - strawStart;
                }
            }
        } break;

        default: {
            // There are no other cases.
            STBTT_assert(0);
        } break;
    }

    return -1;
}

local function stbtt_int32  stbtt__GetGlyphClass(stbtt_uint8 *classDefTable, int glyph)
{
    stbtt_uint16 classDefFormat = ttUSHORT(classDefTable);
    switch(classDefFormat)
    {
        case 1: {
            stbtt_uint16 startGlyphID = ttUSHORT(classDefTable + 2);
            stbtt_uint16 glyphCount = ttUSHORT(classDefTable + 4);
            stbtt_uint8 *classDef1ValueArray = classDefTable + 6;

            if (glyph >= startGlyphID && glyph < startGlyphID + glyphCount)
                return (stbtt_int32)ttUSHORT(classDef1ValueArray + 2 * (glyph - startGlyphID));

            classDefTable = classDef1ValueArray + 2 * glyphCount;
        } break;

        case 2: {
            stbtt_uint16 classRangeCount = ttUSHORT(classDefTable + 2);
            stbtt_uint8 *classRangeRecords = classDefTable + 4;

            // Binary search.
            stbtt_int32 l=0, r=classRangeCount-1, m;
            int strawStart, strawEnd, needle=glyph;
            while (l <= r) {
                stbtt_uint8 *classRangeRecord;
                m = (l + r) >> 1;
                classRangeRecord = classRangeRecords + 6 * m;
                strawStart = ttUSHORT(classRangeRecord);
                strawEnd = ttUSHORT(classRangeRecord + 2);
                if (needle < strawStart)
                    r = m - 1;
                else if (needle > strawEnd)
                    l = m + 1;
                else
                    return (stbtt_int32)ttUSHORT(classRangeRecord + 4);
            }

            classDefTable = classRangeRecords + 6 * classRangeCount;
        } break;

        default: {
            // There are no other cases.
            STBTT_assert(0);
        } break;
    }

    return -1;
}

// Define to STBTT_assert(x) if you want to break on unimplemented formats.
#define STBTT_GPOS_TODO_assert(x)

local function stbtt_int32  stbtt__GetGlyphGPOSInfoAdvance(const stbtt_fontinfo *info, int glyph1, int glyph2)
{
    stbtt_uint16 lookupListOffset;
    stbtt_uint8 *lookupList;
    stbtt_uint16 lookupCount;
    stbtt_uint8 *data;
    stbtt_int32 i;

    if (!info.gpos) return 0;

    data = info.data + info.gpos;

    if (ttUSHORT(data+0) != 1) return 0; // Major version 1
    if (ttUSHORT(data+2) != 0) return 0; // Minor version 0

    lookupListOffset = ttUSHORT(data+8);
    lookupList = data + lookupListOffset;
    lookupCount = ttUSHORT(lookupList);

    for (i=0; i<lookupCount; ++i) {
        stbtt_uint16 lookupOffset = ttUSHORT(lookupList + 2 + 2 * i);
        stbtt_uint8 *lookupTable = lookupList + lookupOffset;

        stbtt_uint16 lookupType = ttUSHORT(lookupTable);
        stbtt_uint16 subTableCount = ttUSHORT(lookupTable + 4);
        stbtt_uint8 *subTableOffsets = lookupTable + 6;
        switch(lookupType) {
            case 2: { // Pair Adjustment Positioning Subtable
                stbtt_int32 sti;
                for (sti=0; sti<subTableCount; sti++) {
                    stbtt_uint16 subtableOffset = ttUSHORT(subTableOffsets + 2 * sti);
                    stbtt_uint8 *table = lookupTable + subtableOffset;
                    stbtt_uint16 posFormat = ttUSHORT(table);
                    stbtt_uint16 coverageOffset = ttUSHORT(table + 2);
                    stbtt_int32 coverageIndex = stbtt__GetCoverageIndex(table + coverageOffset, glyph1);
                    if (coverageIndex == -1) continue;

                    switch (posFormat) {
                        case 1: {
                            stbtt_int32 l, r, m;
                            int straw, needle;
                            stbtt_uint16 valueFormat1 = ttUSHORT(table + 4);
                            stbtt_uint16 valueFormat2 = ttUSHORT(table + 6);
                            stbtt_int32 valueRecordPairSizeInBytes = 2;
                            stbtt_uint16 pairSetCount = ttUSHORT(table + 8);
                            stbtt_uint16 pairPosOffset = ttUSHORT(table + 10 + 2 * coverageIndex);
                            stbtt_uint8 *pairValueTable = table + pairPosOffset;
                            stbtt_uint16 pairValueCount = ttUSHORT(pairValueTable);
                            stbtt_uint8 *pairValueArray = pairValueTable + 2;
                            // TODO: Support more formats.
                            STBTT_GPOS_TODO_assert(valueFormat1 == 4);
                            if (valueFormat1 != 4) return 0;
                            STBTT_GPOS_TODO_assert(valueFormat2 == 0);
                            if (valueFormat2 != 0) return 0;

                            STBTT_assert(coverageIndex < pairSetCount);

                            needle=glyph2;
                            r=pairValueCount-1;
                            l=0;

                            // Binary search.
                            while (l <= r) {
                                stbtt_uint16 secondGlyph;
                                stbtt_uint8 *pairValue;
                                m = (l + r) >> 1;
                                pairValue = pairValueArray + (2 + valueRecordPairSizeInBytes) * m;
                                secondGlyph = ttUSHORT(pairValue);
                                straw = secondGlyph;
                                if (needle < straw)
                                    r = m - 1;
                                else if (needle > straw)
                                    l = m + 1;
                                else {
                                    stbtt_int16 xAdvance = ttSHORT(pairValue + 2);
                                    return xAdvance;
                                }
                            }
                        } break;

                        case 2: {
                            stbtt_uint16 valueFormat1 = ttUSHORT(table + 4);
                            stbtt_uint16 valueFormat2 = ttUSHORT(table + 6);

                            stbtt_uint16 classDef1Offset = ttUSHORT(table + 8);
                            stbtt_uint16 classDef2Offset = ttUSHORT(table + 10);
                            int glyph1class = stbtt__GetGlyphClass(table + classDef1Offset, glyph1);
                            int glyph2class = stbtt__GetGlyphClass(table + classDef2Offset, glyph2);

                            stbtt_uint16 class1Count = ttUSHORT(table + 12);
                            stbtt_uint16 class2Count = ttUSHORT(table + 14);
                            STBTT_assert(glyph1class < class1Count);
                            STBTT_assert(glyph2class < class2Count);

                            // TODO: Support more formats.
                            STBTT_GPOS_TODO_assert(valueFormat1 == 4);
                            if (valueFormat1 != 4) return 0;
                            STBTT_GPOS_TODO_assert(valueFormat2 == 0);
                            if (valueFormat2 != 0) return 0;

                            if (glyph1class >= 0 && glyph1class < class1Count && glyph2class >= 0 && glyph2class < class2Count) {
                                stbtt_uint8 *class1Records = table + 16;
                                stbtt_uint8 *class2Records = class1Records + 2 * (glyph1class * class2Count);
                                stbtt_int16 xAdvance = ttSHORT(class2Records + 2 * glyph2class);
                                return xAdvance;
                            }
                        } break;

                        default: {
                            // There are no other cases.
                            STBTT_assert(0);
                            break;
                        };
                    }
                }
                break;
            };

            default:
                // TODO: Implement other stuff.
                break;
        }
    }

    return 0;
}
--]=]
local function  stbtt_GetGlyphKernAdvance(info, g1, g2)
    local xAdvance = 0;

    if (info.gpos ~= 0) then
      xAdvance = xAdvance + stbtt__GetGlyphGPOSInfoAdvance(info, g1, g2);
    end

    if (info.kern ~= 0) then
      xAdvance = xAdvance + stbtt__GetGlyphKernInfoAdvance(info, g1, g2);
    end

    return xAdvance;
end

local function  stbtt_GetCodepointKernAdvance(info, ch1, ch2)

   if (info.kern == 0 and info.gpos~=0) then -- if no kerning table, don't waste time looking up both codepoint.glyphs
      return nil;
   end

   return stbtt_GetGlyphKernAdvance(info, stbtt_FindGlyphIndex(info,ch1), stbtt_FindGlyphIndex(info,ch2));
end

-- return : advance, leftSideBearing
local function stbtt_GetCodepointHMetrics(info, codepoint)
   return stbtt_GetGlyphHMetrics(info, stbtt_FindGlyphIndex(info,codepoint));
end

local function stbtt_GetFontVMetrics(info)
    -- ascent, descent, lineGap
    return ttSHORT(info.data+info.hhea + 4),
        ttSHORT(info.data+info.hhea + 6),
        ttSHORT(info.data+info.hhea + 8)
end

local function  stbtt_GetFontVMetricsOS2(info)
    local tab = stbtt__find_table(info.data, info.fontstart, "OS/2");
    if (tab == 0) then
      return false;
    end

    --return typoAscent, typeDescent, typeLineGap
   return ttSHORT(info.data+tab + 68),ttSHORT(info.data+tab + 70), ttSHORT(info.data+tab + 72)
end


local function stbtt_GetFontBoundingBox(info )
    -- int *x0, int *y0, int *x1, int *y1
    return ttSHORT(info.data + info.head + 36),
        ttSHORT(info.data + info.head + 38),
        ttSHORT(info.data + info.head + 40),
        ttSHORT(info.data + info.head + 42);
end


local function stbtt_ScaleForPixelHeight(info, height)

   local fheight = ttSHORT(info.data + info.hhea + 4) - ttSHORT(info.data + info.hhea + 6);
   return height / fheight;
end


local function stbtt_ScaleForMappingEmToPixels(info, pixels)
   local unitsPerEm = ttUSHORT(info.data + info.head + 18);
   return pixels / unitsPerEm;
end

local function stbtt_FreeShape(info, v)
   STBTT_free(v, info.userdata);
end


local function stbtt_GetFontOffsetForIndex(data, index)

   return stbtt_GetFontOffsetForIndex_internal(data, index);   
end

local function stbtt_GetNumberOfFonts(data)

   return stbtt_GetNumberOfFonts_internal(data);
end


-- The fontinfo object
local stbtt_fontinfo = {}
-- Create a default constructor
setmetatable(stbtt_fontinfo, {
	__call = function(self, ...)
		return self:new(...);
	end,
})
local stbtt_fontinfo_mt = {
    __index = stbtt_fointinfo;
}

local function hasRequiredHeaders(self)
    -- first check all required headers are in place
    if not self.tables["cmap"] and 
        self.tables["head"] and 
        self.tables["hhea"] and
        self.tables["hmtx"] then
            return false;
        end

    
end

local function stbtt_InitFont_internal(self)
   --self.cff = stbtt__new_buf(nil, 0);
   --info.loca = stbtt__find_table(data, fontstart, "loca"); -- required
   --info.head = stbtt__find_table(data, fontstart, "head"); -- required
   --info.glyf = stbtt__find_table(data, fontstart, "glyf"); -- required
   --info.hhea = stbtt__find_table(data, fontstart, "hhea"); -- required
   --info.hmtx = stbtt__find_table(data, fontstart, "hmtx"); -- required
  -- info.kern = stbtt__find_table(data, fontstart, "kern"); -- not required
   --info.gpos = stbtt__find_table(data, fontstart, "GPOS"); -- not required

    if (self.tables["glyf"]) then
      -- required for truetype
      if (not self.tables["loca"]) then 
        return false;
      end
    else
      -- initialization for CFF / Type2 fonts (OTF)
      local b = ffi.new('stbtt__buf');
      local topdict = ffi.new('stbtt__buf');
      local topdictidx = ffi.new('stbtt__buf');
      local cstype = 2;
      local charstrings = 0;
      local fdarrayoff = 0; 
      local fdselectoff = 0;
      local cff=0;

      --cff = stbtt__find_table(data, fontstart, "CFF ");
      local cff = self.tables["CFF "]
      if (not cff) then 
        return false;
      end

      self.fontdicts = stbtt__new_buf(nil, 0);
      self.fdselect = stbtt__new_buf(nil, 0);
  
      -- @TODO this should use size from table (not 512MB)
      self.cff = stbtt__new_buf(self.data+cff, 512*1024*1024);
      b = self.cff;

      -- read the header
      stbtt__buf_skip(b, 2);
      stbtt__buf_seek(b, stbtt__buf_get8(b)); -- hdrsize

      -- @TODO the name INDEX could list multiple fonts,
      -- but we just use the first one.
      stbtt__cff_get_index(b);  -- name INDEX
      topdictidx = stbtt__cff_get_index(b);
      topdict = stbtt__cff_index_get(topdictidx, 0);
      stbtt__cff_get_index(b);  -- string INDEX
      self.gsubrs = stbtt__cff_get_index(b);
  --[[
      stbtt__dict_get_ints(topdict, 17, 1, &charstrings);
      stbtt__dict_get_ints(topdict, 0x100 | 6, 1, &cstype);
      stbtt__dict_get_ints(topdict, 0x100 | 36, 1, &fdarrayoff);
      stbtt__dict_get_ints(topdict, 0x100 | 37, 1, &fdselectoff);
      info.subrs = stbtt__get_subrs(b, topdict);

      // we only support Type 2 charstrings
      if (cstype != 2) return 0;
      if (charstrings == 0) return 0;

      if (fdarrayoff) {
         // looks like a CID font
         if (!fdselectoff) return 0;
         stbtt__buf_seek(b, fdarrayoff);
         info.fontdicts = stbtt__cff_get_index(b);
         info.fdselect = stbtt__buf_range(b, fdselectoff, b.size-fdselectoff);
      }
--]]
      stbtt__buf_seek(b, charstrings);
      self.charstrings = stbtt__cff_get_index(b);
    end

   --local maxp = self.tables["maxp"];
   local cmap = self.tables['cmap'];



    self.index_map = 0;
    local i = 0;
    while (i < self.numTables) do
        local encoding_record = cmap.offset + 4 + 8 * i;
        -- find an encoding we understand:
        local enc = ttUSHORT(self.data+encoding_record);
        if enc == ffi.C.STBTT_PLATFORM_ID_MICROSOFT then
            local msfteid = ttUSHORT(self.data+encoding_record+2)
            if msfteid == TT_MS_ID_UNICODE_CS or
                msfteid == TT_MS_ID_UNICODE_FULL then
                    -- MS/Unicode
                self.index_map = cmap.offset + ttULONG(self.data+encoding_record+4);
            end

        elseif enc == ffi.C.STBTT_PLATFORM_ID_UNICODE then
                -- Mac/iOS has these
                -- all the encodingIDs are unicode, so we don't bother to check it
                self.index_map = cmap.offset + ttULONG(self.data+encoding_record+4);
        end

        i = i + 1;
    end

    if (self.index_map == 0) then
        return false;
    end

    --self.indexToLocFormat = tonumber(ttUSHORT(self.data+self.tables['head'].offset + 50));

    return true;
end


function stbtt_fontinfo.new(self, params)
	local obj = params or {}

    obj.data = obj.data or nil;
    obj.userdata = obj.userdata or nil;
    obj.fontstart = obj.fontstart or 0;
    obj.numGlyphs = obj.numGlyphs or 0;
    obj.index_map = obj.index_map or 0;
    obj.indexToLocFormat = obj.indexToLocFormat or 0;

    -- offsets from start of file to a few tables
    if obj.data ~= nil then
        obj.tables = stbtt_fontinfo.readTableDirectory(obj);
    end

    -- check to make sure the font has the required headers
    --if not hasRequiredHeaders(obj) then return nil end
    
    -- After reading table directory, set some values
    local maxp = obj.tables["maxp"];
    --local cmap = obj.tables['cmap'];
    local head = obj.tables['head'];

    if head then
        obj.indexToLocFormat = head.indexToLocFormat;
    end

    if (maxp) then
        obj.numGlyphs = maxp.numGlyphs;
     else
        obj.numGlyphs = 0;
     end



    stbtt_InitFont_internal(obj)

--[[
    stbtt__buf cff;                    // cff font data
    stbtt__buf charstrings;            // the charstring index
    stbtt__buf gsubrs;                 // global charstring subroutines index
    stbtt__buf subrs;                  // private charstring subroutines index
    stbtt__buf fontdicts;              // array of font dicts
    stbtt__buf fdselect;               // map from glyph to fontdict
--]] 

    setmetatable(obj, stbtt_fontinfo_mt);
    return obj;
end


-- function used to calculate a table's checksum
-- This is useful to confirm the integrity of the
-- table data
local function CalcTableChecksum(tbl, numberOfBytesInTable)
    local sum = ffi.cast('uint32_t',0);
    local tblptr = ffi.cast('uint32_t *', tbl)
    local nLongs = (numberOfBytesInTable + 3) / 4;
    while (nLongs > 0) do
        sum = sum + table[0];
        tableptr = tblptr + 1;
        nLongs = nLongs - 1;
    end

    return sum;
end

--[[
    readTableDirectory(data, fontstart)

    Get the offset and length information
    for all of the tables that are in a font

    The offset subtable is the first thing in the font.
    We'll fill in all the attributes, including the
    offsets table.
]]
function stbtt_fontinfo.readTableDirectory(self)
    self.scalerType = ttULONG(self.data+self.fontstart+0)
    self.numTables = tonumber(ttUSHORT(self.data+self.fontstart+4));
    self.searchRange = ttUSHORT(self.data+self.fontstart+6);
    self.entrySelector = ttUSHORT(self.data+self.fontstart+8);
    self.rangeShift = ttUSHORT(self.data+self.fontstart+10);
    
    if self.numTables < 1 then return nil end

    -- The table directory starts 12 bytes from the
    -- font offset.
    
    local tabledir = self.fontstart + 12;
    local res = {}
    local i = 0;
    while (i < self.numTables) do
        local loc = tabledir + 16*i;
        local name = ffi.string(self.data+loc+0, 4);
        res[name] = {
            name = name, 
            index = i;
            offset = tonumber(ttULONG(self.data+loc+8)),
            length = tonumber(ttULONG(self.data+loc+12))
        }
        res[name].data = self.data + res[name].offset;

        i = i + 1;
    end

    -- Read in the required tables
    stbtt_fontinfo.readTable_maxp(res['maxp'])
    stbtt_fontinfo.readTable_head(res['head'])
    --stbtt_fontinfo.readTable_cmap(res['cmap'])
    stbtt_fontinfo.readTable_name(res['name'])

    return res;
end

-- Read the contents of the 'maxp' table
function stbtt_fontinfo.readTable_maxp(self)
    if not self then return false end

    self.version = ttULONG(self.data+0);
    self.numGlyphs = tonumber(ttUSHORT(self.data+4));
    self.maxPoints = ttUSHORT(self.data+6);
    self.maxContours = ttUSHORT(self.data+8);
    self.maxComponentPoints = ttUSHORT(self.data+10);
    self.maxComponentContours = ttUSHORT(self.data+12);
    self.maxZones = ttUSHORT(self.data+14);
    self.maxTwilightPoints = ttUSHORT(self.data+16);
    self.maxStorage = ttUSHORT(self.data+18);
    self.maxFunctionDefs = ttUSHORT(self.data+20);
    self.maxInstructionDefs = ttUSHORT(self.data+22);
    self.maxStackElements = ttUSHORT(self.data+24);
    self.maxSizeOfInstructions = ttUSHORT(self.data+26);
    self.maxComponentElements = ttUSHORT(self.data+28);
    self.maxComponentDepth = ttUSHORT(self.data+30);

    return self;
end

function stbtt_fontinfo.readTable_head(self)
    if not self then return false end

    self.version = ttULONG(self.data+0);
    self.fontRevision = ttULONG(self.data+4);
    self.checksumAdjustment = tonumber(ttULONG(self.data+8));
    self.magicNumber = tonumber(ttULONG(self.data+12));
    self.flags = ttUSHORT(self.data+16);
    self.unitsPerEm = tonumber(ttUSHORT(self.data+18));
    --self.created = ttULONGLONG(self.data+20);
    --self.modified = ttULONGLONG(self.data+28);
    self.xMin = ttSHORT(self.data+36);
    self.yMin = ttSHORT(self.data+38);
    self.xMax = ttSHORT(self.data+40);
    self.yMax = ttSHORT(self.data+42);
    self.macStyle = tonumber(ttUSHORT(self.data+44));
    self.lowestRecPPEM = ttUSHORT(self.data+46);
    self.fontDirectionHint = tonumber(ttSHORT(self.data+48));
    self.indexToLocFormat = tonumber(ttSHORT(self.data+50));
    self.glyhpDataFormat = tonumber(ttSHORT(self.data+52));

    return self;
end

function stbtt_fontinfo.readTable_name(tbl)

    tbl.format = tonumber(ttUSHORT(tbl.data+0));
    tbl.count = tonumber(ttUSHORT(tbl.data+2));
    tbl.stringOffset = tonumber(ttUSHORT(tbl.data+4));
    tbl.names = {}

    print("==== readTable_name: ", tbl, tbl.name, tbl.count)
    
    -- for the number of name record entries...
    local i=0
    while (i < tbl.count ) do
        local base = tbl.data+6 + 12*(i);
        local rec = {
            platformID = tonumber(ttUSHORT(base + 0)),
            platformSpecificID = tonumber(ttUSHORT(base+2)),
            languageID = tonumber(ttUSHORT(base+4)),
            nameID = tonumber(ttUSHORT(base+6)),
            length = tonumber(ttUSHORT(base+8)),
            offset = tonumber(ttUSHORT(base+10))
            
        }
        rec.value = ffi.string(tbl.data+tbl.stringOffset+rec.offset, rec.length)

        table.insert(tbl.names, rec)
        
        i = i + 1;
    end

    return tbl
end

local exports = {
    stbtt_fontinfo = stbtt_fontinfo;
}

return exports