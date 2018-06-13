-- simple file to take the opcode table data and turn it into something useful

-- opcodes[0x7F] = {name = ''; action = opcodes.defaultAction};

local function writeEntry(e)
    print(string.format("opcodes[%s] = {name = '%s'; action = opcodes.defaultAction};", e.code, e.name))
end

local col = 1
local entry = {}


for line in io.lines("opcodetable.lua") do
    --print(line)
    if col == 1 then
        entry.name = line;
    elseif col==2 then
        entry.code = line;
    elseif col == 3 then
        entry.pops = line;
    elseif col == 4 then
        entry.pushes = line;
        writeEntry(entry)
        entry = {}
        col = 0
    end

    col = col + 1
end
