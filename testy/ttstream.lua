--[[
    This file is a general memory stream interface.
    The primary objective is to satisfy the needs of the 
    truetype parser, but it can be used in general cases.

    It differs from the MemoryStream object in that it can't
    write, and it has more specific data type reading 
    convenience calls.
]]
local ffi = require("ffi")
local bit = require("bit")
local bor, lshift = bit.bor, bit.lshift


-- ffi.cdef[[
-- typedef struct
-- {
--    uint8_t *data;
--    size_t cursor;
--    size_t size;
-- } stbtt__buf;
-- ]]
local tt_memstream = {}
setmetatable(tt_memstream, {
		__call = function(self, ...)
		return self:new(...)
	end,
})

local tt_memstream_mt = {
	__index = tt_memstream;
}


function tt_memstream.init(self, data, size, position)
    position = position or 0

    assert(size < 0x40000000);

    local obj = {
        data = data;
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
 
function tt_memstream.tell(self)
    return self.cursor;
end



 function tt_memstream.skip(self, pos)
     return self:seek(self.cursor + pos);
 end
 
-- get 8 bits, and don't advance the cursor
function tt_memstream.peek8(self)
    if (self.cursor >= self.size) then
        return false;
    end

    return self.data[self.cursor];
end

 -- get as many bytes specifiec in n as an integer
 -- this could possibly work up to 7 byte integers
 -- converts from big endian to native format while it goes
 function tt_memstream.get(self, n)
    --STBTT_assert(n >= 1 and n <= 4);
    local v = 0;
    local i = 0;
    while  (i < n) do
        v = bor(lshift(v, 8), self:get8());
        i = i + 1;
    end

    return v;
end

-- get 8 bits, and advance the cursor
function tt_memstream.get8(self)

    if (self.cursor >= self.size) then
       return false;
    end
    --b.data[b.cursor++];
    local r = self.data[self.cursor];
    self.cursor = self.cursor + 1;
    
    return r
 end
 
 function tt_memstream.get16(self)  
     return self:get(2)
 end

function tt_memstream.getInt16(self)
    return tonumber(ffi.cast('int16_t', self:get(2)))
end

function tt_memstream.getUInt16(self)
    return tonumber(ffi.cast('uint16_t', self:get(2)))
end

 function tt_memstream.get32(self)  
     return tonumber(self:get(4))
 end

function tt_memstream.getInt32(self)
    return tonumber(ffi.cast('int32_t', self:get(4)))
end

function tt_memstream.getUInt32(self)
    return tonumber(ffi.cast('uint32_t', self:get(4)))
end
 -- get a subrange of the memory stream
 -- returning a new memory stream
 function tt_memstream.range(self, pos, s)
 
     local r = stbtt__new_buf(nil, 0);
     if ((pos < 0) or (s < 0) or (pos > self.size) or (s > (self.size - o))) then 
         return r;
     end
 
 
     r.data = self.data + pos;
     r.size = s;
     
     return r;
 end

 return tt_memstream