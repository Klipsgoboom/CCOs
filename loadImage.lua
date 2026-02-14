--[[
		NPaintPro
		By NitrogenFingers
]]--
--This is just re-assembled npaintpro code that only displays an image


function split(str, sep)
    local t = {}
    for part in str:gmatch("[^"..sep.."]+") do
        t[#t+1] = part
    end
    return t
end

local w,h = term.getSize()
local canvas = {}

local leftColour, rightColour = colours.white, nil
local canvasColour = colours.black


local function getCanvasPixel( x, y )
    if canvas[y] then
        return canvas[y][x]
    end
    return nil
end

local function getCharOf( colour )
	if type(colour) == "number" then
		local value = math.floor( math.log(colour) / math.log(2) ) + 1
		if value >= 1 and value <= 16 then
			return string.sub( "0123456789abcdef", value, value )
		end
	end
	return " "
end	

local tColourLookup = {}
for n=1,16 do
	tColourLookup[ string.byte( "0123456789abcdef",n,n ) ] = 2^(n-1)
end
local function getColourOf( char )
	return tColourLookup[char]
end
local function drawCanvasPixel( x, y )
	local pixel = getCanvasPixel( x, y )
	if pixel then
		term.setBackgroundColour( pixel or canvasColour )
		term.setCursorPos(x, y)
		term.write(" ")
	else
		term.setBackgroundColour( canvasColour )
		term.setTextColour( canvasColour )
		term.setCursorPos(x, y)
        term.write("-")
	end
end

local function drawCanvasLine( y )
	for x = 1, w-2 do
		drawCanvasPixel( x, y )
	end
end

local function drawCanvas()
	for y = 1, h-1 do
		drawCanvasLine( y )
	end
end

local function load(path)
		    if fs.exists(path) then
		    local file = fs.open(path, "r")
            local allLines = file.readAll()
			allLines = split(allLines, "|")[1]
            local lines = split(allLines, ",")

            for i=1, #lines do
			    local line = {}
			    for x=1,w do
				    line[x] = getColourOf(string.byte(lines[i],x,x) )
			    end
			    table.insert( canvas, line )
		    end

		    file.close()
	    end
end

local file = read()

load(file)
drawCanvas()