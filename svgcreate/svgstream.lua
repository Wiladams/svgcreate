--svgstream.lua

local svgstream = {}
setmetatable(svgstream, {
	__call = function(self, ...)
		return self:new(...)
	end,
	})
local svgstream_mt = {
	__index = svgstream;
}

function svgstream.init(self, baseStream)
	local obj = {
		BaseStream = baseStream;
		TopElement = {};
		Elements = {};
	}
	setmetatable(obj, svgstream_mt);

	return obj;
end

function svgstream.new(self, baseStream)
	return self:init(baseStream);
end


function svgstream.reset(self)
	--strm:write('<?xml version="1.0" standalone="no"?>\n');

	return self.BaseStream:reset();
end


function svgstream.openElement(self, elName)
	self.CurrentOpenTag = elName;
	self.BaseStream:writeString("<"..elName)
end

function svgstream.closeTag(self)
	self.BaseStream:writeString(">\n")
	self.CurrentOpenTag = nil;
end


function svgstream.writeAttribute(self, name, value)
	self.BaseStream:writeString(" "..name.." = '"..value.."'");
end

function svgstream.closeElement(self, elName)
	if elName then
		self.BaseStream:writeString("</"..elName..">\n");
	else
		self.BaseStream:writeString(" />\n");
	end
end

function svgstream.write(self, str)
	self.BaseStream:writeString(str);
end

return svgstream
