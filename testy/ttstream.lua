--[[
    This file is a general memory stream interface.
    The primary objective is to satisfy the needs of the 
    truetype parser, but it can be used in general cases.

    It differs from the MemoryStream object in that it can't
    write, and it has more specific data type reading 
    convenience calls.

    More specifically, all of the numeric reading assumes the
    data in the stream is formatted in 'big-endian' order.  That
    is, the high order bytes come first.
]]
local ffi = require("ffi")
local bit = require("bit")
local bor, lshift = bit.bor, bit.lshift


--[[
    Standard 'object' construct.
    __call is implemented so we get a 'constructor'
    sort of feel:
    tt_memstream(data, size, position)
]]
local tt_memstream = {}
setmetatable(tt_memstream, {
		__call = function(self, ...)
		return self:new(...)
	end,
})

local tt_memstream_mt = {
	__index = tt_memstream;
}


function tt_memstream.init(self, data, size, position, littleendian)
    position = position or 0

    assert(size > 0);

    local obj = {
        bigend = not littleendian;
        data = ffi.cast("uint8_t *", data);
        size = size;
        cursor = 0;
    }
 
    setmetatable(obj, tt_memstream_mt)
    return obj
end

function tt_memstream.new(self, data, size, position)
    return self:init(data, size, position);
end

 -- move to a particular position, in bytes
function tt_memstream.seek(self, pos)
    assert(not (pos > self.size or pos < 0));
    --b.cursor = (o > b.size or o < 0) ? b.size : o;
     if (pos > self.size or pos < 0) then 
         self.cursor = self.size
     else
         self.cursor = pos;
     end
 
     return true;
end

-- Report the current cursor position.
-- Good for finding out the size of something
function tt_memstream.tell(self)
    return self.cursor;
end


-- move the cursor ahead by the amount
-- specified in the offset
 function tt_memstream.skip(self, offset)
     return self:seek(self.cursor + offset);
 end
 
-- get 8 bits, and don't advance the cursor
function tt_memstream.peek8(self)
    if (self.cursor >= self.size) then
        return false;
    end

    return self.data[self.cursor];
end



-- get 8 bits, and advance the cursor
function tt_memstream.get8(self)
    --print("self.cursor: ", self.cursor, self.size)
    if (self.cursor >= self.size) then
       return false;
    end

    local r = self.data[self.cursor];
    self.cursor = self.cursor + 1;
    
    return r
 end
 
  -- get as many bytes specified in n as an integer
 -- this could possibly work up to 7 byte integers
 -- converts from big endian to native format while it goes
function tt_memstream.get(self, n)
    --STBTT_assert(n >= 1 and n <= 4);
    local v = 0;
    local i = 0;

    if self.bigend then
        while  (i < n) do
            v = bor(lshift(v, 8), self:get8());
            i = i + 1;
        end 
    else
        while  (i < n) do
            v = bor(v, lshift(self:get8(), 8*i));
            i = i + 1;
        end 
    end

    return v;
end

-- BUGBUG, do error checking against end of stream
function tt_memstream.getBytes(self, n)
    local bytes = ffi.new("uint8_t[?]", n)
    ffi.copy(bytes, self.data+self.cursor, n)
    self.cursor = self.cursor + n;
    
    return bytes;
end

function tt_memstream.getString(self, n)
    if n < 1 then return false end

    local str = ffi.string(self.data+self.cursor, n)
    --print("STR: ", #str)
    self.cursor = self.cursor + n;

    return str;
end

function tt_memstream.get16(self)  
     return self:get(2)
end

function tt_memstream.get32(self)  
    return tonumber(self:get(4))
end

-- These ensure the sign is dealth with properly
function tt_memstream.getInt8(self)
    return tonumber(ffi.cast('int8_t', self:get(1)))
end

function tt_memstream.getUInt8(self)
    return tonumber(ffi.cast('uint8_t', self:get(1)))
end

function tt_memstream.getInt16(self)
    return tonumber(ffi.cast('int16_t', self:get(2)))
end

function tt_memstream.getUInt16(self)
    return tonumber(ffi.cast('uint16_t', self:get(2)))
end



function tt_memstream.getInt32(self)
    return tonumber(ffi.cast('int32_t', self:get(4)))
end

function tt_memstream.getUInt32(self)
    return tonumber(ffi.cast('uint32_t', self:get(4)))
end

function tt_memstream.getFixed(self)
    local decimal = self:getInt16();
    local fraction = self:getUInt16();

    return decimal + fraction / 65535;
end

function tt_memstream.getF2Dot14(self)
    return self:getInt16() / 16384;
end

-- get a subrange of the memory stream
-- returning a new memory stream
function tt_memstream.range(self, pos, s)
    if ((pos < 0) or (s < 0) or (pos > self.size) or (s > (self.size - o))) then 
        return nil;
    end

    return tt_memstream(self.data+pos, 0, s)
end

-- Convenient types named in the documentation
tt_memstream.getFWord = tt_memstream.getInt16;
tt_memstream.getUFWord = tt_memstream.getUInt16;
tt_memstream.getOffset16 = tt_memstream.getUInt16;
tt_memstream.getOffset32 = tt_memstream.getUInt32;

return tt_memstream