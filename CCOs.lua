buttons = {}
playerCardsValue = 0
playerCardsDrawn = 0
dealerCardsValue = 0
osVersion = "1.0.4"
ip = nil
apiKey = nil
standing = false
local scene = 0

local backgroundImage = "0000333333333333330000003333,0000000333333333333300000003,0000000000003333333000003333,9993333333333333333333333333,9999999933333333333333333999,9999999999999999999999999999,9999999999999999999999999999,bbbbbb999999999999bbbb999999,bbbbbbbbbbbbbbbbbbbbbbbbbbbb,bbbbbbbbbbbbbbbbbbbbbbbbbbbb,55bbbbbbbbbbbbbbbbb555bbbbbb,d55bbbbbbbbbbbbb5555dd55555b,dd555555555555555dddddddddd5,ddddddddddddddddddddddddddd5,ddd888888dddddddddddddddddd5,dd88888888ddddddddddddddddd5,ddd88888888dddddddddddddddd5,ddddddddddddddddddddddddddd5,ddddddddddddddddddddddddddd5,ddddddddddddddddddddddddddd5,dddddddddddddddddddddddddddd,dddddddddddddddddddddddddddd"

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

local file = fs.open("baseBg", "w")
file.writeLine(backgroundImage)
file.close()

function clearButtons() 
scene = math.random(1, 1000000)
buttons = {}
end

function drawButton(x, y, width, height, text, args)
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
    buttonObject = {x, y, x+width, y+height, args, text, scene}
    table.insert(buttons, buttonObject)
end

function updating()
clearButtons() 
term.setBackgroundColor(colors.lightBlue)
term.clear()
term.setCursorPos(1, 1)
print("Appel Updating")


local url = "https://raw.githubusercontent.com/Klipsgoboom/CCOs/refs/heads/main/CCOs.lua"
local response = http.get(url)

if response then
    local content = response.readAll()
    response.close()

    local file = fs.open("CCOs.lua", "w")
    file.write(content)
    file.close()

    print("Download complete!")
    else
    print("Failed to Update.")
    end
    sleep(2)
    os.reboot()

end

function settings()
    clearButtons() 
    term.setBackgroundColor(colors.white)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.black)
    print("Settings")
    term.setCursorPos(1, 2)
    print("OS version " .. osVersion)
    drawButton(1, 4, 12, 3, "Flex", "flexS")
    drawButton(1, 8, 12, 3, "Bluetooth", "bt")
    drawButton(1, 12, 12, 3, "Update", "update")
    drawButton(24, 1, 3, 2, "X", "exit")
end

function flexS()
    clearButtons() 
    term.setBackgroundColor(colors.white)
    term.clear()
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)
    term.setCursorPos(1, 1)
    print("Flex Settings")
    term.setCursorPos(1, 3)
    print("Current Ip:")
        term.setCursorPos(1, 4)
    print(ip)
    term.setCursorPos(1, 6)
    print("Current API:")
        term.setCursorPos(1, 7)
    print(apiKey)

    term.setCursorPos(1, 9)
    print("API key")
    drawButton(1, 10, 26, 2, "", "api")
    term.setBackgroundColor(colors.white)
    term.setTextColor(colors.black)
    term.setCursorPos(1, 13)
    print("URL")
    drawButton(1, 14, 26, 2, "", "url")
    drawButton(1, 18, 26, 3, "Save", "flexSetSettings")
    drawButton(24, 1, 3, 2, "X", "exit")
end


function bluetoothMenu()
clearButtons() 
term.setBackgroundColor(colors.lightBlue)
term.clear()
term.setCursorPos(1, 1)
print("Appel Bluetooth")

term.setCursorPos(1, 2)
print("Detected Devices:")
local btDevices = {rednet.lookup("bluetooth")}

for i, btDevice in pairs(btDevices) do
drawButton(1, 3+(3*(i-1)), 12, 3, "Computer" .. btDevice, "setDevice")
end

drawButton(24, 1, 3, 2, "X", "exit")
end

function setBluetooth(btID)
    term.setBackgroundColor(colors.lightBlue)
    term.clear()
    term.setCursorPos(1, 1)
    print("Appel Bluetooth")
    local bluetooth
    if (not btID) then
        term.setCursorPos(1, 3)
        print("Type the ID of your device:")
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
        term.setCursorPos(1, 5)
        print("Connected!")
    else
        term.setCursorPos(1, 5)
        print("Cannot find device, bluetooth not set.")
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


function flexMenu()
    clearButtons() 
    term.setBackgroundColor(colors.black)
    term.setCursorBlink(false)
    term.clear()
    term.setCursorPos(1, 1)
    print("FLEX APP")

    entries = getFlexLibraryItems()
    for entryNumber, entry in ipairs(entries) do
        if ((3*entryNumber) < 20) then
            shortHandEntryName = entry.Name
            --get rid of any non alphabet characters
            shortHandEntryName = string.gsub(shortHandEntryName, "'", "")
            shortHandEntryName = shortHandEntryName:gsub("[^%w%s]", "")
            shortHandEntryName = shortHandEntryName:sub(1, 15)
            --print(shortHandEntryName)
            drawButton(1, (3*entryNumber), 20, 3, shortHandEntryName, "song," .. entry.Id)
        end
    end

end

function requestFlexSong()
clearButtons() 
local bluetoothId = content
term.setBackgroundColor(colors.lightBlue)
term.clear()
term.setCursorPos(1, 1)
print("Flex Song Search")
term.setCursorPos(1, 2)
print("Request song name:")
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

    clearButtons()
    homeScreen()
    end
    if (args== "settings") then
        settings()
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
    if (args == "flexS") then
        flexS()
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
                print("Requested")
            else 
                print("NO PAIRED SPEAKER")
                sleep(1)
            end
    end
    if (args == "casinoStand") then
        if (playerCardsValue <= 21 and playerCardsDrawn <= 5) then
                standing = true
                term.setCursorPos(1, 9)
                print("Dealer cards: " .. dealerCardsValue)
            --figure out who won BJ
            if (dealerCardsValue > playerCardsValue and dealerCardsValue <= 21) then
                
                term.setCursorPos(1, 10)
                print("You lost")
            elseif (dealerCardsValue == playerCardsValue) then
                term.setCursorPos(1, 10)
                print("You tied")
            else
                term.setCursorPos(1, 10)
                print("You won")
            end


        end
    end
    if (args== "flexRequest") then
        flexMenu()
    end
    if (name == "") then
        --text entry box
        term.setCursorPos(buttons[i][1], (buttons[i][4] + buttons[i][2])/2)
        local value = read()
        textEntries[args] = value

    end
    if (args == "casinoHit") then
        if (playerCardsDrawn < 5 and playerCardsValue < 21 and standing == false) then
            playerCardsValue = playerCardsValue + math.random(1,11)
            playerCardsDrawn = playerCardsDrawn + 1 
            casinoLoadCards()
            if (playerCardsValue > 21) then
                term.setCursorPos(1, 9)
                print("Dealer cards: " .. dealerCardsValue)
                term.setCursorPos(1, 10)
                print("You busted")
            end
        end
    end

end

function homeScreen()
    buttonsWork = false
    peripheral.find("modem", rednet.open)
    clearButtons() 
    term.setBackgroundColor(colors.blue)
    term.setCursorBlink(false)
    term.clear()
    term.setCursorPos(1, 1)
    print("Appel HOME")
    sleep(0.1)
    buttonsWork = true
    drawButton(1, 3, 12, 3, "Settings", "settings")
    drawButton(15, 3, 12, 3, "Casino", "casino")
    drawButton(1, 7, 12, 3, "Flex", "flexRequest")
    drawButton(15, 7, 12, 3, "App store", "appStore")
end

function lockScreen()
    clearButtons() 
    term.setBackgroundColor(colors.blue)
    term.setCursorBlink(false)
    term.clear()
    drawImage("baseBg")
    term.setCursorPos(1, 1)
    print("Appel Os ".. osVersion)
    drawButton(8, 7, 12, 3, "Unlock", "unlock")
end

function casinoLoadCards()
    term.setCursorPos(1, 3)
    term.setBackgroundColor(colors.red)
    print("You have drawn ")
    term.setCursorPos(16, 3)
    print(playerCardsDrawn)
    term.setCursorPos(17, 3)
    print(" Cards")
    term.setCursorPos(1, 5)
    term.setBackgroundColor(colors.red)
    print("You have ")
    term.setCursorPos(10, 5)
    print(playerCardsValue)
    term.setCursorPos(12, 5)
    print(" Value")
end

function casino()
    standing = false
    clearButtons() 
    playerCardsValue = math.random(1, 10)
    term.setBackgroundColor(colors.red)
    term.setCursorBlink(false)
    term.clear()
    term.setCursorPos(1, 1)
    print("Appel Casino")
    drawButton(24, 1, 3, 2, "X", "exit")
    drawButton(1, 18, 12, 3, "Hit", "casinoHit")
    drawButton(15, 18, 12, 3, "Stand", "casinoStand")
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

    term.setCursorPos(1, 3)
    term.setBackgroundColor(colors.red)
    print("Dealing...")
    sleep(0.750)
    casinoLoadCards()
end

function checkWhatButtonWasClicked(event, button, x, y, sceneWhenClicked)
    if (buttonsWork) then
            for i=1, #buttons do

                if (buttons[i] ~= nil and buttons[i][7] and sceneWhenClicked == buttons[i][7]) then
                    if x >= buttons[i][1] and x <= buttons[i][3] and y >= buttons[i][2] and y <= buttons[i][4] then
                            processButtonClicks(buttons[i][5], buttons[i][6], i, scene)
                    end
                end
            end
        event = nil
        button = nil
        x = nil
        y = nil
    end
end

function drawImage(fileName)
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
    local function load(path)
	    if fs.exists(path) then
		    local file = fs.open(path, "r")
            --[[
		    local sLine = file.readLine()
		    while sLine do
			    local line = {}
			    for x=1,w do
				    line[x] = getColourOf( string.byte(sLine,x,x) )
			    end
			    table.insert( canvas, line )
			    sLine = file.readLine()
		    end
            --]]

            local allLines = file.readAll()
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

    load(fileName)
    drawCanvas()
end

lockScreen()
while true do
        local event, button, x, y = os.pullEvent("mouse_up")
        checkWhatButtonWasClicked(event, button, x, y, scene)
end