buttons = {}
sprites = {}
spritesNames = {}
playerCardsValue = 0
playerCardsDrawn = 0
dealerCardsValue = 0
osVersion = "1.0.7"
ip = nil
apiKey = nil
standing = false
local scene = 0
yOffset = 0


-- Added wallpaper app in settings
-- Added drop down lists
-- Added new sprite properties max and min y

function split(str, sep)
    local t = {}
    for part in str:gmatch("[^"..sep.."]+") do
        t[#t+1] = part
    end
    return t
end

function split(iString, separater) 
    outputTable = {}
    lastParition = 1

    for i=1, #iString do
        if (string.sub(iString, i, i) == separater) then
            table.insert(outputTable, string.sub(iString, lastParition, i-1))
            lastParition = i+1
        end
        if (i == #iString) then
            table.insert(outputTable, string.sub(iString, lastParition, i))
        end
    end
    return(outputTable)
end

function webRequestDownload(url, fileName)
local response = http.get(url)

if response then
    local content = response.readAll()
    response.close()
    local file = fs.open(fileName, "w")
    file.writeLine(content)
    file.close()
else
    return nil
end
end

--load api stuff
if (fs.exists("flex.settings")) then
    local file = fs.open("flex.settings", "r")
    data = file.readAll()
    data = split(data, ",")
    ip = data[2]
    apiKey = data[1]
    file.close()
else
    ip = "none set"
    apiKey = "none set"
end

textEntries = {}

local buttonsWork = true
local file = fs.open("startup", "w")
file.writeLine('shell.run("CCOs")')
file.close()


if (not fs.exists("flex.settings")) then
local file = fs.open("startup", "w")
file.writeLine('shell.run("CCOs")')
file.close()
end


if (not fs.exists("lockscreen.nfa")) then
webRequestDownload("https://raw.githubusercontent.com/Klipsgoboom/CCOs/refs/heads/main/artwork/drawing.nfa", "lockscreen.nfa")
webRequestDownload("https://raw.githubusercontent.com/Klipsgoboom/CCOs/refs/heads/main/artwork/abstract.nfa", "abstract.nfa")
end

function clearSprites() 
scene = math.random(1, 1000000)
yOffset = 0
sprites = {}
end

function drawObject(object)
    previousColor = term.getBackgroundColor()
        local sprite = {}
        sprite = sprites[object]
        name = sprite[1]
        x = sprite[2]
        y = sprite[3]
        width = sprite[4]
        height = sprite[5]
        typeA = sprite[6]
        rotation = sprite[7]
        src = sprite[8]
        text = sprite[9]
        args = sprite[10]
        z = sprite[11]
        static = sprite[12]
        lScene = sprite[13]
        baseX = sprite[14]
        baseY = sprite[15]

        if (typeA == "text") then
            term.setCursorPos(x, y)
            term.setTextColor(args) --just using args for color
            term.write(text)
        end
        if (typeA == "dropDown") then
            --type to identify as dropDown
            --text to have default/current value
            --args to have all possible results
            --src to store whether expanded or not
            -- draw background

            term.setBackgroundColor(colors.gray)
            term.setTextColor(colors.white)
            term.setCursorPos(x, y)
            term.write(string.rep(" ", width))
            term.setCursorPos(x, y)
            print(tostring(text))

            if (src == "false") then
            term.setCursorPos(width, y)
            print("-")
            else
                drawDropDownEntries(x,y,w,h, args)
            end

        end
        if (typeA == "button") then
            term.setBackgroundColor(colors.gray)
            term.setTextColor(colors.white)
            for i = 0, height-1 do
                term.setCursorPos(x, y+i)
                term.write(string.rep(" ", width))
            end

            local textX = x + math.floor((width - #text) / 2)
            local textY = y + math.floor(height / 2)
            term.setCursorPos(textX, textY)
            term.write(text)
        end
        if (typeA == "image") then
            drawImage(src)
        end

        term.setBackgroundColor(previousColor)
end

function drawAllObjects()
    term.clear()
    for i=1, #sprites do
        drawObject(i)
    end
end

function drawDropDownEntries(x,y,w,h,entriesTable)
    ogColor = term.getBackgroundColor()
    term.setCursorPos(width, y)
    term.setBackgroundColor(colors.gray)
    print("v")
    for i=1, #entriesTable do
            term.setBackgroundColor(colors.lightGray)
            term.setTextColor(colors.white)
            term.setCursorPos(x, y+i)
            term.write(string.rep(" ", width))
            term.setCursorPos(x, y+i)
            print(tostring(entriesTable[i]))
            term.setBackgroundColor(ogColor)
        end
end

function createSprite(name, x, y, width, height, typeA, rotation, src, text, args, z, static, minY, maxY)
    spriteObject = {name, x, y, width, height, typeA, rotation, src, text, args, z, static, scene, x, y, minY, maxY}
    table.insert(sprites, spriteObject)
    spritesNames[name] = #sprites
    drawObject(#sprites)
end

function createText(x,y,text,static,color)
    if (color == nil) then
        color = colors.white
    end
    createSprite("textbox", x, y, 0, 0, "text", 0, 0, text, color, 0, static)
end

function createImage(src)
    createSprite("image", 0, 0, 0, 0, "image", 0, src, 0, 0, 0, true)
end

function createButton(x,y,w,h,text,args,static, minY, maxY)
    createSprite("btn", x, y, w, h, "button", 0, 0, text, args, 0, static,minY,maxY)
end

function createDropDown(name, x,y,w,h,text,args,static, minY, maxY)
    createSprite(name, x, y, w, h, "dropDown", 0, "false", text, args, 0, static,minY,maxY)
end


function updating()
clearSprites() 
term.setBackgroundColor(colors.lightBlue)
term.clear()
createText(1,1, "Appel Updating", true)


local url = "https://raw.githubusercontent.com/Klipsgoboom/CCOs/refs/heads/main/CCOs.lua"
local response = http.get(url)

if response then
    local content = response.readAll()
    response.close()

    local file = fs.open("CCOs.lua", "w")
    file.write(content)
    file.close()

    createText(1,3, "Download Complete!", true, colors.white)
else
    print("Failed to Update.")
end
    sleep(2)
    os.reboot()
end

function settings()
    clearSprites() 
    term.setBackgroundColor(colors.white)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.black)
    createText(1,1, "Settings", true, colors.black)
    createText(1,2, "OS version " .. osVersion, true, colors.black)
    
    createSprite("btn", 1, 4, 12, 3, "button", 0, 0, "Flex", "flexS", 0, true)
    createSprite("btn", 1, 8, 12, 3, "button", 0, 0, "Bluetooth", "bt", 0, true)
    createSprite("btn", 1, 12, 12, 3, "button", 0, 0, "Update", "update", 0, true)
    createSprite("btn", 1, 16, 12, 3, "button", 0, 0, "Wallpaper", "wallpaper", 0, true)
    createSprite("btn", 24, 1, 3, 2, "button", 0, 0, "X", "exit", 0, true)
end

function flexS()
    clearSprites() 
    term.setBackgroundColor(colors.white)
    term.clear()
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)
    
    createText(1,1, "Flex Settings", true, colors.black)
    createText(1,3, "Current Ip:", true, colors.black)
    createText(1,4, ip, true, colors.black)
    createText(1,6, "Current API:", true, colors.black)
    createText(1,7, apiKey, true, colors.black)

    createText(1,9, "Api Key", true, colors.black)
    createButton(1,10,26,2,"","api", true)
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)
    createText(1,13, "Url", true, colors.black)

    createButton(1,14,26,2,"","url", true)
    createButton(1,18,26,3,"save","flexSetSettings", true)
    createButton(24,1,3,2,"X","exit", true)

end


function bluetoothMenu()
clearSprites() 
term.setBackgroundColor(colors.lightBlue)
term.clear()
createText(1,1, "Appel Bluetooth", true)

createText(1,2, "Detected Devices", true)
local btDevices = {rednet.lookup("bluetooth")}

for i, btDevice in pairs(btDevices) do
createButton(1,3+(3*(i-1)),12,3,"Computer" .. btDevice,"setDevice", true)
end

createButton(24,1,3,2,"X","exit", true)
end

function setBluetooth(btID)
    term.setBackgroundColor(colors.lightBlue)
    term.clear()
    createText(1,1, "Appel Bluetooth", true)
    local bluetooth
    if (not btID) then
        createText(1,3, "Type the ID of your device:", true)
        bluetooth = read()
    else
        bluetooth = btID
    end
    local btDevice = rednet.lookup("bluetooth", "Speaker" .. bluetooth)
    if btDevice then
        rednet.send(btID, "a", "connected")
        local file = fs.open("bluetooth.bt", "w")
        file.writeLine(bluetooth)
        file.close()
        createText(1,5, "Connected", true)
    else
        term.setCursorPos(1, 5)
        createText(1,5, "Cannot find device, bluetooth not set.", true)
end
sleep(2)
homeScreen()

end

local function getFlexLibraryItems()
local userId = "0635f662c1764b27b665a6b6eda6a685"
     local url = ip.."Users/"..userId.."/Items?ParentId=f6a865777104971fa1a021944a91c9eb&IncludeItemTypes=Audio&Recursive=true"
    local response = http.get(url, { ["X-Emby-Token"] = apiKey })
    if not response then
        print("Failed to fetch library items.")
        sleep(2)
        homeScreen()
    else

    local body = response.readAll()
    response.close()

    local data = textutils.unserializeJSON(body)
    return data and data.Items or nil
    end
end

function wallpaperSetter()
    clearSprites()
    term.setBackgroundColor(colors.black)
    term.setCursorBlink(false)
    term.clear()
    createText(1,1, "Wallpaper Setter", true)
    createSprite("btn", 24, 1, 3, 2, "button", 0, 0, "X", "exit", 0, true)
    newList = {"lockscreen.nfa", "abstract.nfa"}
    newListString = ""
    for i=1, #newList do
        newListString = newListString .. newList[i] .. "|"
    end
    createDropDown("wallpaperName", 1, 2,15,0, newList[1], newList, false, minY, maxY)
    createButton(1,10,15,2,"Save","lockscreenWallPaper", true)
end


function flexMenu()
    clearSprites() 
    term.setBackgroundColor(colors.black)
    term.setCursorBlink(false)
    term.clear()
    createText(1,1, "FLEX app", true)
    createSprite("btn", 24, 1, 3, 2, "button", 0, 0, "X", "exit", 0, true)

    entries = getFlexLibraryItems()
    for entryNumber, entry in ipairs(entries) do

            shortHandEntryName = entry.Name
            --get rid of any non alphabet characters
            shortHandEntryName = string.gsub(shortHandEntryName, "'", "")
            shortHandEntryName = shortHandEntryName:gsub("[^%w%s]", "")
            shortHandEntryName = shortHandEntryName:sub(1, 15)
            --print(shortHandEntryName)
            createButton(1,(3*entryNumber),20,3,shortHandEntryName,"song," .. entry.Id, false)

    end

end

function requestFlexSong()
clearSprites() 
local bluetoothId = content
term.setBackgroundColor(colors.lightBlue)
term.clear()
createText(1,1, "Flex Song Search", true)
createText(1,2, "Request song name:", true)
local searchTerm = read()

function searchItems(term)
    local items = getFlexLibraryItems()
    if not items then return end

    for _, item in ipairs(items) do
        if string.find(string.lower(item.Name), string.lower(term)) then
            print("Found:", item.Name)
            rednet.open("back")
            local message = ip .. "Items/" .. item.Id .. "/Download?api_key=" .. apiKey
            if (fs.exists("bluetooth.bt")) then
                local file = fs.open("bluetooth.bt", "r")
                local content = file.readAll() 
                local targetId = tonumber(content) 
                file.close()
                rednet.send(targetId, message, "flexSong")
                print("Requested")
            else
                print("NO PAIRED SPEAKER")
                sleep(1)
            end
            sleep(2)
            homeScreen()
        end
    end
    end
    searchItems(searchTerm)
end



function processButtonClicks(args, name, i)
    if (args == "unlock") then
        homeScreen()
    end
    if (args == "exit") then
    playerCardsValue = 0
    playerCardsDrawn = 0

    clearSprites()
    homeScreen()
    end
    if (args== "settings") then
        settings()
    end
    if (args== "wallpaper") then
        wallpaperSetter()
    end
    if (args == "setDevice") then
        id = string.sub(name, 9, #name)
        setBluetooth(tonumber(id))
    end
    if (args == "casino") then
        casino()
    end
    if (args == "update") then
        updating()
    end
    if (args == "lockscreenWallPaper") then
        local file = fs.open("lockscreen.setting", "w")
        file.writeLine(sprites[spritesNames["wallpaperName"]][9])
        file.close()
        lockScreen()
    end
    if (args == "flexS") then
        flexS()
    end
    if (args == "appStore") then
        playAnim()
    end
    if (args == "flexSetSettings") then

        local file = fs.open("flex.settings", "w")
        file.writeLine(textEntries["api"] .. "," .. textEntries["url"])
        file.close()
        ip = textEntries["url"]
        apiKey = textEntries["api"]
        sleep(0.1)
        homeScreen()
    end
    if (args == "bt") then
        bluetoothMenu()
    end
    if (#split(args, ",") > 1 and split(args, ",")[1] == "song") then
            if (fs.exists("bluetooth.bt")) then
                local file = fs.open("bluetooth.bt", "r")
                local targetId = file.readAll() 
                file.close()
                local message = ip .. "Items/" .. split(args, ",")[2] .. "/Download?api_key=" .. apiKey
                rednet.send(tonumber(targetId), message, "flexSong")
                homeScreen()
            else 
                term.clear()
                term.setCursorPos(1,1)
                print("NO PAIRED SPEAKER")
                sleep(1)
                homeScreen()
            end
    end
    if (args == "casinoStand") then
        if (playerCardsValue <= 21 and playerCardsDrawn <= 5) then
                standing = true
                createText(1,9, "Dealer cards: " .. dealerCardsValue, true)
            --figure out who won BJ
            if (dealerCardsValue > playerCardsValue and dealerCardsValue <= 21) then
                term.setCursorPos(1, 10)
                createText(1,10, "You lost", true)
            elseif (dealerCardsValue == playerCardsValue) then
                createText(1,10, "You tied", true)
            else
                createText(1,10, "You won", true)
            end
            sleep(1.5)
            casino()


        end
    end
    if (args== "flexRequest") then
        flexMenu()
    end
    if (name == "") then
        --text entry box
        preserveOriginalBgColor = term.getBackgroundColor()
        term.setTextColor(colors.white)
        term.setBackgroundColor(colors.gray)
        term.setCursorPos(sprites[i][2], sprites[i][3] + (sprites[i][5])/2)
        local value = read()
        textEntries[args] = value
        term.setBackgroundColor(preserveOriginalBgColor)

    end
    if (args == "casinoHit") then
        if (playerCardsDrawn < 5 and playerCardsValue < 21 and standing == false) then
            playerCardsValue = playerCardsValue + math.random(1,11)
            playerCardsDrawn = playerCardsDrawn + 1 
            casinoLoadCards()
            if (playerCardsValue > 21) then
                createText(1,9, "Dealer cards: " .. dealerCardsValue, true)
                createText(1,10, "You busted", true)
                sleep(1.5)
            casino()
            end
        end
    end

end

function homeScreen()
    buttonsWork = false
    peripheral.find("modem", rednet.open)
    clearSprites() 
    term.setBackgroundColor(colors.blue)
    term.setCursorBlink(false)
    term.clear()
    createText(1,1, "Appel Home", true)
    sleep(0.1)
    buttonsWork = true
    createSprite("btn", 1, 3, 12, 3, "button", 0, 0, "Settings", "settings", 0, true)
    createSprite("btn", 15, 3, 12, 3, "button", 0, 0, "Casino", "casino", 0, true)
    createSprite("btn", 1, 7, 12, 3, "button", 0, 0, "Flex", "flexRequest", 0, true)
    --createSprite("btn", 15, 7, 12, 3, "button", 0, 0, "App store", "appStore", 0, true)

end

function lockScreen()
    clearSprites() 
    term.setBackgroundColor(colors.blue)
    term.setCursorBlink(false)
    term.clear()
    local content

    if fs.exists("lockscreen.setting") then
    local file = fs.open("lockscreen.setting", "r")
    content = file.readAll()
    file.close()
    else
        content = "lockscreen.nfa"
    end

    createImage(content)
    createText(1,1, "Appel Os " .. osVersion, true)
    createSprite("btn", 8, 7, 12, 3, "button", 0, 0, "Unlock", "unlock", 0, true)
end

function casinoLoadCards()
    term.setBackgroundColor(colors.red)
    createText(1,3, "You have drawn", true)
    createText(16,3, playerCardsDrawn, true)
    createText(17,3, " cards", true)
    term.setBackgroundColor(colors.red)
    createText(1,5, "You have", true)
    createText(10,5, playerCardsValue, true)
    createText(12,5, " Value", true)
end

function casino()
    standing = false
    clearSprites() 
    playerCardsValue = math.random(1, 10)
    term.setBackgroundColor(colors.red)
    term.setCursorBlink(false)
    term.clear()
    createText(1,1, "Appel Casino", true)
    createSprite("btn", 24, 1, 3, 2, "button", 0, 0, "X", "exit", 0, true)

    createSprite("btn", 1, 18, 12, 3, "button", 0, 0, "Hit", "casinoHit", 0, true)
    createSprite("btn", 15, 18, 12, 3, "button", 0, 0, "Stand", "casinoStand", 0, true)
    dealerCardsValue = 0
    
    for dealerCardsPulled=0, 5 do
        dealerCardsValue = dealerCardsValue + math.random(1, 10)
        if (dealerCardsValue >= 16) then
        break
        end
        dealerCardsPulled = dealerCardsPulled + 1
    end

    playerCardsDrawn = 2
    playerCardsValue = math.random(1,20)

    term.setBackgroundColor(colors.red)
    createText(1,3, "Dealing...", true)
    sleep(0.750)
    casinoLoadCards()
end

function checkWhatButtonWasClicked(event, button, xC, yC, sceneWhenClicked)
    if (buttonsWork) then
        for i, sprite in ipairs(sprites) do
        name = sprite[1]
        x = sprite[2]
        y = sprite[3]
        width = sprite[4]
        height = sprite[5]
        typeA = sprite[6]
        rotation = sprite[7]
        src = sprite[8]
        text = sprite[9]
        args = sprite[10]
        z = sprite[11]
        static = sprite[12]
        lScene = sprite[13]
        baseX = sprite[14]
        baseY = sprite[15]
            if (sprites[i] ~= nil and scene and sceneWhenClicked == scene and typeA == "button") then
                if xC >= x and xC <= x+width and yC >= y and yC <= y+height then
                        processButtonClicks(args, text, i, scene)
                end
            end
            if (sprites[i] ~= nil and scene and sceneWhenClicked == scene and typeA == "dropDown") then
                --if opening or closing dropdown menu
                if xC >= x and xC <= x+width and yC >= y and yC <= y+height then
                        if (src == "false") then
                        sprite[8] = "true"
                        drawDropDownEntries(x,y,w,h, args)
                        else
                        sprite[8] = "false"
                        drawAllObjects()
                        end
                        break
                end
                --if an option is picked
                if (src == "true") then
                    for i = 1, #args do
                        if (y+i==yC and xC >= x and xC <= width) then
                            sprite[9] = args[i]
                            sprite[8] = "false"
                            drawAllObjects()
                            break
                        end
                    end
                end
            end
        end
        event = nil
        button = nil
        x = nil
        y = nil
    end
end

function drawImage(fileName, frame)
    --[[
		NPaintPro
		By NitrogenFingers
    ]]--
    --This is just re-assembled npaintpro code that only displays an image

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
	    for x = 1, w do
		    drawCanvasPixel( x, y )
	    end
    end
    local function drawCanvas()
	    for y = 1, h do
		    drawCanvasLine( y )
	    end
    end
    function load(path)
        if (not frame) then
            frame = 1
        end
	    if fs.exists(path) then
		    local file = fs.open(path, "r")
            local allFrames = file.readAll()
            allFrames = split(allFrames, "|")
            local allLines = split(allFrames[frame], ",")
            local lines = allLines
            
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

    load(fileName)
    drawCanvas()
end

function playAnim()
    for i=1, 7 do
    drawImage("animation.nfa", i)
    sleep(0.2)
    end
end

lockScreen()


function transformNonStaticObjects(offset)
    for i, sprite in ipairs(sprites) do
        absoluteY = sprites[i][15]
        static = sprite[12]
        minY = sprite[16]
        maxY = sprite[17]
        if (static ~= true and (maxY ~= nil and minY ~= nil and absoluteY + yOffset < maxY and absoluteY + yOffset > minY)) then
            sprites[i][3] = absoluteY + yOffset
        elseif (static ~=true and (maxY == nil and minY == nil)) then
            sprites[i][3] = absoluteY + yOffset
        end
    end
end

while true do
    local event, p1, p2, p3 = os.pullEvent()
    if (event == "mouse_scroll") then
        local direction = p1
        if direction == 1 then
            yOffset = yOffset - 2
            transformNonStaticObjects(-2)
        elseif direction == -1 then
            yOffset = yOffset + 2
            transformNonStaticObjects(2)
        end
        drawAllObjects()
    end
    if (event == "mouse_up") then
        local button = p1
        local x = p2
        local y = p3
        checkWhatButtonWasClicked(event, button, x, y, scene)
    end
end