local colors = require("colors")
local component = require("component")
local term = require("term")
local filesystem = require("filesystem")
local event = require("event")
local serialization = require("serialization")

-- Check Required Components --

local gpu, screen, stargate

if component.isAvailable("gpu") then
  gpu = component.getPrimary("gpu")
else
  print("Error: Missing GPU")
  os.exit()
end

if component.isAvailable("screen") then
  screen = component.getPrimary("screen")
else
  print("Error: Missing Screen")
  os.exit()
end

if component.isAvailable("stargate") then
  stargate = component.getPrimary("stargate")
else
  print("Error: Missing Stargate")
  os.exit()
end

-- Check Optional Components --

local redstone
if component.isAvailable("redstone") then
  redstone = component.getPrimary("redstone")
end

-- Configuration --

local colorBlack = 0x000000
local colorWhite = 0xFFFFFF

local colorLightGray = 0xAAAAAA
local colorGray = 0x444444

local colorRed = 0xFF0000
local colorOrange = 0xF39C12
local colorGreen = 0x00AA00
local colorBlue = 0x000088
local colorLightBlue = 0x6666AA
local colorLime  = 0x32CD32

local maxEnergy = 50000

local rootDir = "/home/stargate/"
local gatesDir = rootDir.."gates/"
local secList = rootDir.."secList"
local currentSec = rootDir.."currentSec"

-- /End configuration --

term.clear()
gpu.setBackground(colorBlack)
dialling = {}

local function alarmSet(set)
  if redstone then
    redstone.setOutput("left", set)
  end
  return
end

local function eventFilter(name, ...)
  if name == "touch" or name == "sgStargateStateChange" or name == "sgChevronEngaged" or name == "sgMessageReceived" or name == "sgDialIn" or name == "interrupted" then
    return true
  end
  return false
end

-- Checks power levels and writes power bar to monitor
function drawPowerBar() 
  x,y = gpu.getResolution()
  energyPercent = math.floor(math.floor(math.min(stargate.energyAvailable(), maxEnergy)) / maxEnergy * 100) -- math.min because sometimes stargate.energyAvailable is greatter than 50000 (bug from api ?)
  gpu.setBackground(colorBlack)
  for i = y, (y - y / 100 * energyPercent) + 1, -1 do
    term.setCursor(x-2,i)
    if i > y/4*3 then 
      gpu.setBackground(colorRed)
      gpu.setForeground(colorRed)
    elseif i > y/2 then
      gpu.setBackground(colorOrange)
      gpu.setForeground(colorOrange)
    elseif i > y/4 then
      gpu.setBackground(colorGreen)
      gpu.setForeground(colorGreen)
    else
      gpu.setBackground(colorLime)
      gpu.setForeground(colorLime)
    end
    term.write("  ")
  end
  gpu.setBackground(colorBlack)
  gpu.set(x-9,y, math.floor(stargate.energyAvailable() / 1000).."k SU ")
end

-- Draws cheyvrons on the screen
function drawChevrons() 
  x,y = gpu.getResolution()
  chevX1 = x/3
  chevX2 = x/3*2 + 2
  chevY1 = y/3-2
  chevY2 = y/3*2 + 2

  state, int = stargate.stargateState()
  if state == "Connected" then
    gpu.setBackground(colorBlue)
  else
    gpu.setBackground(colorBlack)
  end
  for yc = chevY1+1, chevY2 do
    for xc = chevX1+2, chevX2-1 do
      term.setCursor(xc, yc)
      term.write(" ")
    end
  end

  -- Draw Gate
  gpu.setBackground(colorLightGray)
  -- Top
  for i = chevX1+2, chevX2-2 do
    term.setCursor(i,chevY1)
    term.write(" ")
  end
  -- Bottom
  for i = chevX1+2, chevX2-2 do
    term.setCursor(i,chevY2)
    term.write(" ")
  end
  -- Left
  for i = chevY1+2, chevY2-1 do
    term.setCursor(chevX1,i)
    term.write("  ")
  end
  -- Right
  for i = chevY1+1, chevY2-1 do
    term.setCursor(chevX2-1, i)
    term.write("  ")
  end

  chev1pos = {chevX1, chevY2 }
  gpu.setBackground(colorGray)
  gpu.setForeground(colorBlack)
  term.setCursor(math.floor(chev1pos[1]), math.floor(chev1pos[2])-1)
  term.write(" > ")
  chev2pos = {chevX1, chevY1 + ((chevY2 - chevY1) / 2) }
  term.setCursor(math.floor(chev2pos[1]-1), math.floor(chev2pos[2]))
  term.write(" > ")
  chev3pos = {chevX1, chevY1 }
  term.setCursor(math.floor(chev3pos[1]), math.floor(chev3pos[2]+1))
  term.write(" > ")
  chev4pos = {chevX1 + ((chevX2 - chevX1) / 2), chevY1 }
  term.setCursor(math.floor(chev4pos[1]-1), math.floor(chev4pos[2]))
  term.write(" V ")
  chev5pos = {chevX2, chevY1 }
  term.setCursor(math.floor(chev5pos[1]-2), math.floor(chev5pos[2])+1)
  term.write(" < ")
  chev6pos = {chevX2, chevY1 + ((chevY2 - chevY1) / 2) }
  term.setCursor(math.floor(chev6pos[1]-1), math.floor(chev6pos[2]))
  term.write(" < ")
  chev7pos = {chevX2, chevY2 }
  term.setCursor(math.floor(chev7pos[1]-2), math.floor(chev7pos[2]-1))
  term.write(" < ")
  chev8pos = {chevX1 + ((chevX2 - chevX1) /2), chevY2 }
  term.setCursor(math.floor(chev8pos[1]-1), math.floor(chev8pos[2]))
  term.write("   ")
  gpu.setBackground(colorBlack)
  if state == "Connected" then
    gpu.setForeground(colorLightBlue)
  end

  drawRemoteAddress()
end

-- Draws single chevron on screen for updating
function drawChev( chevInfo )
  gpu.setBackground(colorOrange)
  x,y = gpu.getResolution()
  chevX1 = x/3
  chevX2 = x/3*2+1
  chevY1 = y/3-2
  chevY2 = y/3*2 +2
  if chevInfo[1] == 1 then
    chev1pos = {chevX1, chevY2 }
    term.setCursor(math.floor(chev1pos[1]), math.floor(chev1pos[2])-1)
    term.write(" "..chevInfo[2].." ")
  elseif chevInfo[1] == 2 then
    chev2pos = {chevX1, chevY1 + ((chevY2 - chevY1) / 2) }
    term.setCursor(math.floor(chev2pos[1]-1), math.floor(chev2pos[2]))
    term.write(" "..chevInfo[2].." ")
  elseif chevInfo[1] == 3 then
    chev3pos = {chevX1, chevY1 }
    term.setCursor(math.floor(chev3pos[1]), math.floor(chev3pos[2]+1))
    term.write(" "..chevInfo[2].." ")
  elseif chevInfo[1] == 4 then
    chev4pos = {chevX1 + ((chevX2 - chevX1) / 2), chevY1 }
    term.setCursor(math.floor(chev4pos[1]-1), math.floor(chev4pos[2]))
    term.write(" "..chevInfo[2].." ")
  elseif chevInfo[1] == 5 then
    chev5pos = {chevX2, chevY1 }
    term.setCursor(math.floor(chev5pos[1]-2), math.floor(chev5pos[2])+1)
    term.write(" "..chevInfo[2].." ")
  elseif chevInfo[1] == 6 then
    chev6pos = {chevX2, chevY1 + ((chevY2 - chevY1) / 2) }
    term.setCursor(math.floor(chev6pos[1]-1), math.floor(chev6pos[2]))
    term.write(" "..chevInfo[2].." ")
  elseif chevInfo[1] == 7 then
    chev7pos = {chevX2, chevY2 }
    term.setCursor(math.floor(chev7pos[1]-2), math.floor(chev7pos[2]-1))
    term.write(" "..chevInfo[2].." ")
  elseif chevInfo[1] == 8 then
    chev8pos = {chevX1 + ((chevX2 - chevX1) /2), chevY2 }
    term.setCursor(math.floor(chev8pos[1]-1), math.floor(chev8pos[2]))
    term.write(" "..chevInfo[2].." ")
  elseif chevInfo[1] == 9 then
    chev9pos = {chevX1 + ((chevX2 - chevX1) /2), chevY2 }
    term.setCursor(math.floor(chev8pos[1]-1), chevY1 + ((chevY2 - chevY1) / 2))
    term.write(" "..chevInfo[2].." ")
  gpu.setBackground(colorBlack)
  end
end

-- Draws stargate status
function drawSgStatus(status) 
  if status ~= "Idle" then
    term.setCursor(1,2)
    gpu.setBackground(colorBlack)
    gpu.setForeground(colorBlack)
    term.write(status) --needed for string length because string.len() won't work with stargateStatus()
    xc, yc = term.getCursor()
    --term.clear()
    term.setCursor(1,2)
    gpu.setBackground(colorBlack)
    if status == "Connected" then
      gpu.setForeground(colorLightBlue)
    elseif status == "Dialling" then
      gpu.setForeground(colorOrange)
    else
      gpu.setForeground(colorGreen)
    end
    x,y = gpu.getResolution()
    term.setCursor((x/2+1) - 6, y/2+2)
    term.write("            ")
    term.setCursor((x/2+1) - (xc/2-1), y/2+2)
    term.write(status)
  end
end

-- Draws button to control the Iris
function drawIris(state) 
  gpu.setBackground(colorLightGray)
  ok, result = pcall(stargate.openIris)
  if ok == false then
    gpu.setForeground(colorBlack)
  elseif state == true then
    stargate.closeIris()
    gpu.setForeground(colorLime)
  else
    gpu.setForeground(colorBlack)
    stargate.openIris()
  end
  s = "   IRIS   "
  i = 1
  for  yc = y/3+5, y/3*1.5 + 5 do
    char = string.sub(s, i, i)
    term.setCursor(6, yc)
    term.write(" "..char.." ")
    i = i+1
  end
  if state == true then
    gpu.setForeground(colorLime)
  else
    gpu.setForeground(colorBlack)
  end
end

-- Draws the address stargate being controlled
function drawLocalAddress() 
  x,y = gpu.getResolution()
  gpu.setBackground(colorBlack)
  gpu.setForeground(colorLightGray)
  term.setCursor(x/2-7, 1)
  term.write("Stargate Address:")
  term.setCursor(x/2-3, 2)
  term.write(stargate.localAddress())
end

-- Draws the button to access the dialing menu
function drawDial() 
  x,y = gpu.getResolution()
  state, int = stargate.stargateState()
  for yc = y-3, y-1 do
    for xc = x/2-5, x/2 do
      if state == "Idle" then
        gpu.setBackground(colorLightGray)
      else
        gpu.setBackground(colorGray)
      end
      term.setCursor(xc,yc)
      term.write(" ")
    end
  end
  term.setCursor(x/2-4, y-2)
  gpu.setForeground(colorBlack)
  term.write("DIAL")
end

-- Draws the button to terminate the stargate connection to another gate
function drawTerm() 
  x,y = gpu.getResolution()
  state, int = stargate.stargateState()
  for yc = y-3, y-1 do
    for xc = x/2+2, x/2+7 do
      if state == "Connected" or state == "Connecting" or state == "Dialling" then
        gpu.setBackground(colorLightGray)
      else
        gpu.setBackground(colorGray)
      end
      term.setCursor(xc,yc)
      term.write(" ")
    end
  end
  term.setCursor(x/2+3, y-2)
  gpu.setForeground(colorBlack)
  term.write("TERM")
end 

-- Draws the button to access the security menu
function securityButton() 
  x,y = gpu.getResolution()
  gpu.setBackground(colorLightGray)
  sOK, result = pcall(stargate.openIris)
  if sOK == false then
    gpu.setForeground(colorBlack)
  else
    gpu.setForeground(colorBlack)
  end
  s = " DEFENCE "
  i = 1
  for  yc = y/3+5, y/3*1.5 +5 do
    char = string.sub(s, i, i)
    term.setCursor(2, yc)
    term.write(" "..char.." ")
    i = i+1
  end
  gpu.setBackground(colorBlack)
end

-- Draws the top of the security menu, all the addresses stored in the security table
function drawSecurityPageTop() 
  gpu.setBackground(colorBlack)
  term.clear()
  gpu.setForeground(colorBlack)
  x,y = gpu.getResolution()
  for yc = 1,y-3 do
    if yc%2 == 1 then
      gpu.setBackground(colorLightBlue)
    else
      gpu.setBackground(colorLightGray)
    end
    for xc = 1,x do
      term.setCursor(xc, yc)
      term.write(" ")
    end
    term.setCursor(x/2-4, yc)
    term.write("Add Address")
  end
  if filesystem.exists(rootDir.."secList") then
    file = filesystem.open(rootDir.."secList","r")
    secInfo = serialization.unserialize(file:read(1024))
    file:close()
    if string.len(serialization.serialize(secInfo)) > 7 then
    for k,v in pairs(secInfo) do
      term.setCursor(1,i)
        if k%2 == 1 then
          gpu.setBackground(colorLightBlue)
        else
          gpu.setBackground(colorLightGray)
        end
        term.setCursor(1, k)
        term.write(v.name)
        term.setCursor(x/2-4, k)
        term.write("           ")
        term.setCursor(x/2 - string.len(v.address)/2 +1, k)
        term.write(v.address)
        term.setCursor(x,k)
        gpu.setBackground(colorRed)
        term.write("X")
    end
    end
  end
  gpu.setBackground(colorBlack)
end

-- Draws the buttons at the bottom of the security page
function drawSecurityPageBottom(listType) 
  for yc = y-2, y do
    for xc = 1, x do
      term.setCursor(xc, yc)
      if listType == "BLACKLIST" then
        gpu.setBackground(colorBlack)
        gpu.setForeground(colorWhite)
      elseif listType == "WHITELIST" then
        gpu.setBackground(colorWhite)
        gpu.setForeground(colorBlack)
      elseif listType == "NONE" then
        gpu.setBackground(colorGray)
        gpu.setForeground(colorWhite)
      end
      term.write(" ")
    end
  end
  term.setCursor((x/2 - tonumber(string.len(listType)/2)+1), y-1)
  term.write(listType)
  term.setCursor(x-5, y-1)
  term.write("BACK")
  gpu.setBackground(colorBlack)
end

-- Draws the home screen
function drawHome() 
  term.clear()
  gpu.setBackground(colorBlack)

  term.setCursor(1, y)
  gpu.setForeground(colorGray)
  term.write("Orginal by thatParadox - Ported by Kirastaroth")

  drawPowerBar()
  drawChevrons()
  status, int = stargate.stargateState()
  drawSgStatus(tostring(status))
  drawHistoryButton()
  if stargate.irisState()  == "Open" then
    drawIris(false)
  else
    drawIris(true)
  end
  drawLocalAddress()
  securityButton()
  drawDial()
  term.setCursorBlink(false)
  drawTerm()
end

-- Draws the Dial screen
function drawBookmarksPage()
  gpu.setBackground(colorBlack)
  term.clear()
  gpu.setForeground(colorBlack)
  x,y = gpu.getResolution()
  for yc = 1,y-3 do
    if yc%2 == 1 then
      gpu.setBackground(colorLightBlue)
    else
      gpu.setBackground(colorLightGray)
    end
    for xc = 1,x do
      term.setCursor(xc, yc)
      term.write(" ")
    end
  end
  for i= 1,y do
      if i%2 == 1 then
      gpu.setBackground(colorLightBlue)
    else
      gpu.setBackground(colorLightGray)
    end
    if filesystem.exists(gatesDir..tostring(i)) then
      file = filesystem.open(gatesDir..tostring(i),"r")
      bookmark = serialization.unserialize(file:read(1024))
      file:close()
      term.setCursor(1,i)
      for k,v in pairs(bookmark) do
        if k == "name" then
          term.write(v)
          term.setCursor(x/2, i)
          term.write(bookmark.address)
          term.setCursor(x,i)
          gpu.setBackground(colorRed)
          term.write("X")
        end
      end
    elseif i < y-2 then
      term.setCursor(1, i)
      term.write("Add Address")
    end
  end
  term.setCursor(x/2, y-1)
  gpu.setBackground(colorBlack)
  gpu.setForeground(colorWhite)
  term.write("BACK")
end

-- Draws the iris of the Remote gate
function drawRemoteIris()
  gpu.setBackground(colorBlack)
  x,y = gpu.getResolution()
  term.setCursor(x/2-1, y/2+4)
  term.write("IRIS.")
end

-- Add new address inputs Screen
-- TODO: add cancel button + add "wrong value for name/address"
function inputPage(type)
  nameInput = ""
  while string.len(nameInput) < 1 do
    term.clear()
    x,y = gpu.getResolution()
    term.setCursor(x/2-8, y/2-2)
    print("Set an address name")
    term.setCursor(x/2 - 4, y/2)
    print("         ")
    term.setCursor(x/2 - 4, y/2)
    nameInput = io.read()
  end

  addressInput = ""
  while string.len(addressInput) < 7 do
    term.clear()
    term.setCursor(x/2-9, y/2-4)
    print("Enter Stargate address for '"..nameInput.."'")
    if type == "secEntry" then
      term.setCursor(x/2-10, y/2-2)
      print("DO NOT ENTER ANY HYPHONS")
    end
    gpu.setBackground(colorBlack)
    term.setCursor(x/2 - 5, y/2)
    print("           ")
    term.setCursor(x/2 - 5, y/2)
    addressInput = string.upper(io.read())
  end

  newGate = {name = nameInput, address = addressInput}
  return newGate
end

-- Draws Remote address on Main screen
function drawRemoteAddress()
  gpu.setBackground(colorBlack)
  x,y = gpu.getResolution()
  local addressString = stargate.remoteAddress()
  if status == "Connected" then
    addressString = addressString .. " : Connected"
  elseif status == "Idle" or status == "Closing" then
    addressString = "                       "
  end
  term.setCursor((x/2+1) - string.len(addressString)/2, y/4-2)
  term.write(addressString)
end

-- Draws History button on Main screen
function drawHistoryButton()
  gpu.setBackground(colorLightGray)
  gpu.setForeground(colorBlack)
  s = " HISTORY "
  i = 1
  for yc = y/3+5, y/3*1.5 + 5 do
    char = string.sub(s, i, i)
    term.setCursor(x-7, yc)
    term.write(" "..char.." ")
    i = i+1
  end
end

-- Add calls to History
function addToHistory(address)
  if filesystem.exists(rootDir.."history") then
    file = filesystem.open(rootDir.."history", "r")
    history = serialization.unserialize(file:read(1024))
    file:close()
  else
    history ={}
    print("")
    print("")
    print("no history file")
  end
  if serialization.serialize(history) == false then
    history = {}
    print("")
    print("")
    print("couldn't serialize")
  end
  test = serialization.serialize(historyTable)
  table.insert(history, 1, address)
  file = filesystem.open(rootDir.."history", "w")
  file:write(serialization.serialize(history))
  file:close()
end

-- Draws History Page
function drawHistoryPage()
  gpu.setBackground(colorBlack)
  term.clear()
  gpu.setForeground(colorBlack)
  x,y = gpu.getResolution()
  for yc = 1,y-3 do
    if yc%2 == 1 then
      gpu.setBackground(colorLightBlue)
    else
      gpu.setBackground(colorLightGray)
    end
    for xc = 1,x do
      term.setCursor(xc, yc)
      term.write(" ")
    end
  end
  if filesystem.exists(rootDir.."history") then
    file = filesystem.open(rootDir.."history","r")
    historyTable = serialization.unserialize(file:read(1024))
    file:close()
    test = serialization.serialize(historyTable)
    if string.len(test) > 7 then
      for k,v in pairs(historyTable) do
        if k%2 == 1 then
          gpu.setBackground(colorLightBlue)
        else
          gpu.setBackground(colorLightGray)
        end
        term.setCursor(1,k)
        term.write(v)
        term.setCursor(x/2+7, k)
        gpu.setBackground(colorBlue)
        term.write("SAVE")
        term.setCursor(x-8, k)
        gpu.setBackground(colorRed)
        term.write("BAN/ALLOW")
        clickLimit = k
      end
    end
    test = {}
  end 
  gpu.setBackground(colorBlack)
  for yc = y-2, y do
    for xc = 1,x do
      term.setCursor(xc, yc)
      term.write(" ")
    end
  end
  term.setCursor(x/2, y-1)
  gpu.setForeground(colorWhite)
  term.write("BACK")
end

-- Draws History input page
function historyInputPage(address)
  cx, cy = term.getCursor()
  term.clear()
  gpu.setBackground(colorLightGray)
  term.clear()
  x,y = gpu.getResolution()
  term.setCursor(x/2-8, y/2-2)
  print("Set an address name")
  term.setCursor(x/2 - 4, y/2)
  print("         ")
  term.setCursor(x/2 - 4, y/2)
  nameInput = io.read()
  addressInput = "nil"
  newGate = {name = nameInput, address = address}
  term.clear()
  term.setCursor(1,1)
  return newGate
end

-- First time execution : init folders
if not filesystem.isDirectory(rootDir) or not filesystem.isDirectory(gatesDir) then
  local hasError = false
  if not filesystem.isDirectory(rootDir) then
    term.write("Create Main directory...")
    if filesystem.makeDirectory(rootDir) then
      gpu.setForeground(colorGreen)
      term.write("OK")
      print(" ")
    else
      gpu.setForeground(colorRed)
      term.write("ERROR: cannot create directory '"..rootDir.."' - check your file system")
      hasError = true
      print(" ")
    end
    gpu.setForeground(colorWhite)
  end
  if not filesystem.isDirectory(gatesDir) then
    term.write("Create Gates config directory...")
    if filesystem.makeDirectory(gatesDir) then
      gpu.setForeground(colorGreen)
      term.write("OK")
      print(" ")
    else
      gpu.setForeground(colorRed)
      term.write("ERROR: cannot create directory '"..gatesDir.."' - check your file system")
      hasError = true
      print(" ")
    end
    gpu.setForeground(colorWhite)
  end
  
  if hasError then
    print("Error(s) found while initializing...")
    print("Check errors, then run application again")
    os.sleep(4)
    os.exit()
  else
    print(" ")
    print("Init ends. Running application...")
    os.sleep(2)
  end
end

-- Run Application
if filesystem.exists(rootDir.."currentSec") then -- checks to see if there's list of gates stored for security reasons
  file = filesystem.open(rootDir.."currentSec", "r")
  currentSec = file:read(1024)
  file:close()
else
  currentSec = "NONE"
end
drawHome()

-- Global Events
while true do
  local eventName, param1, param2, param3 = event.pullFiltered(eventFilter)

  -- Interupt program (CTRL+C)
  if eventName == "interrupted" then
    gpu.setBackground(colorBlack)
    term.clear()
    gpu.setForeground(colorRed)
    print("soft interrupt, closing")
    gpu.setBackground(colorWhite)
    break

  -- Click envents
  elseif eventName == "touch" then
    x,y = gpu.getResolution()

    --opens or closes the Iris
    if param2 >= 6 and param2 <= 8 and param3 >= y/3+5 and param3 <= y/3*1.5+5 then 
      if stargate.irisState() == "Closed" then
        ok, result = pcall(stargate.openIris)
        if ok then
          drawIris(false)
        end
      else
        ok, result = pcall(stargate.closeIris)
        if ok then
          drawIris(true)
        end
      end

    -- Open the defence menu
    elseif param2 >= 2 and param2 <= 4 and param3 >= y/3+5 and param3 <= y/3*1.5+5 then
      sOK, result = pcall(stargate.openIris)
      if sOK then
        while true do
          drawSecurityPageTop()
          drawSecurityPageBottom(currentSec)
          eventName, param1, param2, param3 = event.pullFiltered(eventFilter)
          if eventName == "touch" then
            if param3 >= y-2 then --checks if the user's touch is at the bottom of the screen with the buttons
              if param2 >= x-8 then -- "back" button has been pushed, returns user to home menu
                drawHome()
                break
              elseif param2 < x-6 then -- Click has changed the security type, cycles through "BLACKLIST", "WHITELIST", "NONE"
                if currentSec == "BLACKLIST" then
                  currentSec = "WHITELIST"
                elseif currentSec == "WHITELIST" then
                  currentSec = "NONE"        
                elseif currentSec == "NONE" then
                  currentSec = "BLACKLIST"
                end
                file = filesystem.open(rootDir.."currentSec", "w")
                file:write(currentSec)
                file:close()
              end
            elseif param2 > x - 3 then -- delete record
              file = filesystem.open(rootDir.."secList", "r")
              secList = serialization.unserialize(file:read(1024))
              file:close()
              table.remove(secList, param3)
              file = filesystem.open(rootDir.."secList", "w")
              file:write(serialization.serialize(secList))
              file:close()
              drawSecurityPageTop()
            elseif param3 < y - 2 then -- check if empty, if so add new entry  
              if filesystem.exists(rootDir.."secList") == false then
                secList = {}
                table.insert(secList, 1, inputPage())
                file = filesystem.open(rootDir.."secList", "w")
                file:write(serialization.serialize(secList))
                file:close()
              else
                file = filesystem.open(rootDir.."secList", "r")
                secList = serialization.unserialize(file:read(1024))
                file:close()
                table.insert(secList, 1, inputPage("secEntry"))
                file = filesystem.open(rootDir.."secList", "w")
                file:write(serialization.serialize(secList))
                file:close()
              end
              drawSecurityPageTop()
              drawSecurityPageBottom(currentSec)
            end
          else -- if an event that isn't a users touch happens the screen will return to the home screen (in case of incoming connection)
            drawHome()
            break
          end
        end
      end

    -- Open dial menu
    elseif param2 > x/2-5 and param2 <= x/2 and param3 >= y-3 and param3 <= y-1 then 
      status, int = stargate.stargateState()
      if status == "Idle" then
        while true do
          drawBookmarksPage()
          local eventName, param1, param2, param3 = event.pullFiltered(eventFilter)
          if eventName == "touch" then

            -- user clicked back
            if param3 >= y-2 then 
              drawHome()
              break

            -- user clicked delete on a bookmark
            elseif param2 > x-2 then 
              if filesystem.exists(gatesDir..tostring(math.floor(param3))) then
                filesystem.remove(gatesDir..tostring(math.floor(param3)))
                term.clear()
                print(gatesDir..tostring(math.floor(param3)).." Deleted!")
                os.sleep(1)
              else
                term.clear()
                print("Error, can't find "..gatesDir..tostring(param3))
                os.sleep(2)
              end

            -- user has clicked on a bookmark
            else
              -- Dial existing gate
              if filesystem.exists(gatesDir..tostring(math.floor(param3))) then
                file = filesystem.open(gatesDir..tostring(math.floor(param3)), "r")
                gateData = serialization.unserialize(file:read(1024)) -- GATE DATA VARIABLE!!!
                file:close()
                drawHome()
                for k,v in pairs(gateData) do
                  if k == "address" then
                    ok, result = pcall(stargate.dial, v)
                    if ok then
                      status, int = stargate.stargateState()
                      drawSgStatus(status)
                      address = v
                      addToHistory(v)
                    else
                      drawSgStatus("Error")
                    end
                  end
                  os.sleep(.5)
                end
                break

              -- Create Gate data
              else
                file = filesystem.open(gatesDir..tostring(math.floor(param3)), "w")
                values = inputPage()
                file:write(serialization.serialize(values))
                file:close()
              end
            end
          else
            drawHome()
            break
          end
        end
      end

    -- Click has opened history menu
    elseif param2 > x-7 and param2 < x-4 and param3 >= y/3+5 and param3 <= y/3*1.5+5 then 
      while true do
        drawHistoryPage()
        eventName, param1, param2, param3 = event.pullFiltered(eventFilter)
        if eventName == "touch" then

          -- user clicked back
          if param3 >= y-2 then 
            drawHome()
            break

          -- user has clicked save
          elseif param2 >= x/2+7 and param2 <= x/2+10 and param3 <= clickLimit then 
            if filesystem.exists(rootDir.."history") then
              file = filesystem.open(rootDir.."history", "r")
              history = serialization.unserialize(file:read(1024))
              file:close()
              for i = 1,y do
                if filesystem.exists(gatesDir..tostring(i)) == false then
                  file = filesystem.open(gatesDir..tostring(i), "w")
                  file:write(serialization.serialize(historyInputPage(history[param3])))
                  file:close()
                  break
                end
              end
            end

          -- user click "ban/allow"
          elseif param2 >= x-9 and param3 <= clickLimit then 
            if filesystem.exists(rootDir.."history") then
              file = filesystem.open(rootDir.."history", "r")
              history = serialization.unserialize(file:read(1024))
              file:close()
              if filesystem.exists(rootDir.."secList") == false then
                secList = {}
                table.insert(secList, 1, historyInputPage(history[param3]))
                file = filesystem.open(rootDir.."secList", "w")
                file:write(serialization.serialize(secList))
                file:close()
              else
                file = filesystem.open(rootDir.."secList", "r")
                secList = serialization.unserialize(file:read(1024))
                file:close()
                table.insert(secList, 1, historyInputPage(history[param3]))
                file = filesystem.open(rootDir.."secList", "w")
                file:write(serialization.serialize(secList))
                file:close()
              end
            end
          end
          drawHome()
          break
        end
      end

    -- user clicked TERM
    elseif param2 > x/2+2 and param2 <= x/2+7 and param3 >= y-3 and param3 <= y-1 then 
      ok, result = pcall(stargate.disconnect)
      drawChevrons()
    end

  -- Incoming Connection
  elseif eventName == "sgDialIn" then
    gpu.setForeground(colorOrange)
    drawRemoteAddress()
    alarmSet(true)
    if filesystem.exists(rootDir.."currentSec") then
      file = filesystem.open(rootDir.."currentSec", "r")
      currentSec = file:read(1024)
      file:close()
    end
    if filesystem.exists(rootDir.."secList") then
      file = filesystem.open(rootDir.."secList", "r")
      secList = serialization.unserialize(file:read(1024))
      for k,v in pairs(secList) do
        address = v.address
        if string.sub(v.address,1,7) == param2 or v.address == param2 then
          if currentSec == "BLACKLIST" then
            stargate.closeIris()
            drawIris(true)
          elseif currentSec == "WHITELIST" then
              stargate.openIris()
              drawIris(false)
          else
            stargate.openIris()
            drawIris(false)
          end
          secGate = true
        end
      end
    end
    if secGate == true and currentSec == "WHITELIST" then
      stargate.openIris()
      drawIris(false)
      gateSec = false
    end
    addToHistory(param2)

  elseif eventName == "sgMessageReceived" then
    if param2 == "Open" then
      gpu.setForeground(colorLime)
      drawRemoteIris()
    elseif param2 == "Closed" then
      gpu.setForeground(colorRed)
      drawRemoteIris()
    end 

  -- State Change
  elseif eventName == "sgStargateStateChange" or "sgChevronEngaged" then
    status, int = stargate.stargateState()
    drawDial()
    drawPowerBar()
    drawTerm()
    drawSgStatus(tostring(status))
    if status == "idle" then
      isConnected = false
    else
      isConnected = true
    end
    if eventName == "sgChevronEngaged" then
      gpu.setForeground(colorOrange)
      drawChev({param2, param3})
      if param2 == 1 then
        dialling = {}
      end
      table.insert(dialling, param2, param3)
      drawRemoteAddress()
    elseif param2 == "Idle" then
      alarmSet(false)
      drawChevrons()
    elseif param2 == "Connected" then
      alarmSet(false)
      gpu.setForeground(colorLightBlue)
      drawRemoteAddress()
      drawChevrons()
    end
  end
end

term.write("TERMINATED PROGRAM")