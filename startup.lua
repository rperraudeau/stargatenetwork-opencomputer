mon = peripheral.find("monitor")
sg = peripheral.find("stargate")

mon.setBackgroundColor(colors.black)
mon.clear()
maxEng = 50000
dialling = {}

local function alarmSet(set)
  rs.setOutput("left", set)
  return 
end
  
function drawPowerBar() -- checks power levels and writes power bar to monitor
  x,y = mon.getSize()
  engPercent = (sg.energyAvailable() / (maxEng +1)) * 100 -- returns percent
  for i = y, (y - y / 100 * engPercent), -1 do
    mon.setCursorPos(x-2,i)
    if i > y/4*3 then 
      mon.setBackgroundColor(colors.red)
	  mon.setTextColor(colors.red)
    elseif i > y/2 then
      mon.setBackgroundColor(colors.orange)
	  mon.setTextColor(colors.orange)
    elseif i > y/4 then
      mon.setBackgroundColor(colors.green)
	  mon.setTextColor(colors.green)
    else
      mon.setBackgroundColor(colors.lime)
	  mon.setTextColor(colors.lime)
    end
    mon.write("  ")
  end
  mon.setBackgroundColor(colors.black)
  mon.setCursorPos(x-9,y)
  mon.write(math.floor(sg.energyAvailable() / 1000).."k SU ")
end

function drawChevrons() --draws cheyvrons on the screen
  x,y = mon.getSize()
  chevX1 = x/3
  chevX2 = x/3*2+1
  chevY1 = y/3-2
  chevY2 = y/3*2 +2
  mon.setBackgroundColor(colors.black)
  for yc = chevY1-2, chevY2-2 do
    for xc = chevX1-2, chevX2-2 do
	  mon.setCursorPos(xc, yc)
	  mon.write(" ")
	end
  end
  mon.setBackgroundColor(colors.lightGray)
  for i = chevX1+2, chevX2-2 do
    mon.setCursorPos(i,chevY1)
	mon.write(" ")
  end
  for i = chevX1+2, chevX2-2 do
    mon.setCursorPos(i,chevY2)
	mon.write(" ")
  end
  for i = chevY1+2, chevY2-2 do
    mon.setCursorPos(chevX1,i)
	mon.write(" ")
  end
  for i = chevY1+2, chevY2-2 do
    mon.setCursorPos(chevX2, i)
	mon.write(" ")
  end
  chev1pos = {chevX1, chevY2 }
  mon.setBackgroundColor(colors.gray)
  mon.setTextColor(colors.black)
  mon.setCursorPos(math.floor(chev1pos[1]), math.floor(chev1pos[2])-1)
  mon.write(" > ")
  chev2pos = {chevX1, chevY1 + ((chevY2 - chevY1) / 2) }
  mon.setCursorPos(math.floor(chev2pos[1]-1), math.floor(chev2pos[2]))
  mon.write(" > ")
  chev3pos = {chevX1, chevY1 }
  mon.setCursorPos(math.floor(chev3pos[1]), math.floor(chev3pos[2]+1))
  mon.write(" > ")
  chev4pos = {chevX1 + ((chevX2 - chevX1) / 2), chevY1 }
  mon.setCursorPos(math.floor(chev4pos[1]-1), math.floor(chev4pos[2]))
  mon.write(" V ")
  chev5pos = {chevX2, chevY1 }
  mon.setCursorPos(math.floor(chev5pos[1]-2), math.floor(chev5pos[2])+1)
  mon.write(" < ")
  chev6pos = {chevX2, chevY1 + ((chevY2 - chevY1) / 2) }
  mon.setCursorPos(math.floor(chev6pos[1]-1), math.floor(chev6pos[2]))
  mon.write(" < ")
  chev7pos = {chevX2, chevY2 }
  mon.setCursorPos(math.floor(chev7pos[1]-2), math.floor(chev7pos[2]-1))
  mon.write(" < ")
  chev8pos = {chevX1 + ((chevX2 - chevX1) /2), chevY2 }
  mon.setCursorPos(math.floor(chev8pos[1]-1), math.floor(chev8pos[2]))
  mon.write("   ")
--  chev9pos = {chevX1 + ((chevX2 - chevX1) /2), chevY2 }
--  mon.setCursorPos(math.floor(chev8pos[1]-1), chevY1 + ((chevY2 - chevY1) / 2))
--  mon.write(" 9 ")
  mon.setBackgroundColor(colors.black)
  mon.setCursorPos(x/2 - 4, y/2 - 1)
  mon.write("           ")
  mon.setCursorPos(x/2-1, y/2+4)
  mon.write("     ")
end

function drawChev( chevInfo )
  mon.setBackgroundColor(colors.gray)
  x,y = mon.getSize()
  chevX1 = x/3
  chevX2 = x/3*2+1
  chevY1 = y/3-2
  chevY2 = y/3*2 +2
  if chevInfo[1] == 1 then
    chev1pos = {chevX1, chevY2 }
    mon.setBackgroundColor(colors.gray)
    mon.setCursorPos(math.floor(chev1pos[1]), math.floor(chev1pos[2])-1)
    mon.write(" "..chevInfo[2].." ")
  elseif chevInfo[1] == 2 then
    chev2pos = {chevX1, chevY1 + ((chevY2 - chevY1) / 2) }
    mon.setCursorPos(math.floor(chev2pos[1]-1), math.floor(chev2pos[2]))
    mon.write(" "..chevInfo[2].." ")
  elseif chevInfo[1] == 3 then
    chev3pos = {chevX1, chevY1 }
    mon.setCursorPos(math.floor(chev3pos[1]), math.floor(chev3pos[2]+1))
    mon.write(" "..chevInfo[2].." ")
  elseif chevInfo[1] == 4 then
    chev4pos = {chevX1 + ((chevX2 - chevX1) / 2), chevY1 }
    mon.setCursorPos(math.floor(chev4pos[1]-1), math.floor(chev4pos[2]))
    mon.write(" "..chevInfo[2].." ")
  elseif chevInfo[1] == 5 then
    chev5pos = {chevX2, chevY1 }
    mon.setCursorPos(math.floor(chev5pos[1]-2), math.floor(chev5pos[2])+1)
    mon.write(" "..chevInfo[2].." ")
  elseif chevInfo[1] == 6 then
    chev6pos = {chevX2, chevY1 + ((chevY2 - chevY1) / 2) }
    mon.setCursorPos(math.floor(chev6pos[1]-1), math.floor(chev6pos[2]))
    mon.write(" "..chevInfo[2].." ")
  elseif chevInfo[1] == 7 then
    chev7pos = {chevX2, chevY2 }
    mon.setCursorPos(math.floor(chev7pos[1]-2), math.floor(chev7pos[2]-1))
    mon.write(" "..chevInfo[2].." ")
  elseif chevInfo[1] == 8 then
    chev8pos = {chevX1 + ((chevX2 - chevX1) /2), chevY2 }
    mon.setCursorPos(math.floor(chev8pos[1]-1), math.floor(chev8pos[2]))
    mon.write(" "..chevInfo[2].." ")
  elseif chevInfo[1] == 9 then
    chev9pos = {chevX1 + ((chevX2 - chevX1) /2), chevY2 }
    mon.setCursorPos(math.floor(chev8pos[1]-1), chevY1 + ((chevY2 - chevY1) / 2))
    mon.write(" "..chevInfo[2].." ")
  mon.setBackgroundColor(colors.black)
end

end

function drawSgStatus(status) -- draws stargate status
  if status ~= "Idle" then
  term.setCursorPos(1,2)
  write(status) --needed for sting length because sting.len() won't work with stargateStatus()
  xc, yc = term.getCursorPos()
  term.clear()
  term.setCursorPos(1,2)
  write("> ")
  if xc%2 == 1 then
    xc = xc+1
	even = true
  else
    even = false
  end
  mon.setBackgroundColor(colors.black)
  if status == "Connected" then
    mon.setTextColor(colors.lightBlue)
  elseif status == "Dialling" then
    mon.setTextColor(colors.orange)
  else
    mon.setTextColor(colors.green)
  end
  x,y = mon.getSize()
  mon.setCursorPos((x/2+1) - 6, y/2+2)
  mon.write("            ")
  mon.setCursorPos((x/2+1) - (xc/2-1), y/2+2)
  mon.write(status)
  if even == true then
    mon.write(".")
  end
  end
end

function drawIris(state) --draws button to control the Iris
  mon.setBackgroundColor(colors.lightGray)
  ok, result = pcall(sg.openIris)
  if ok == false then
    mon.setTextColor(colors.red)
  elseif state == true then
    sg.closeIris()
    mon.setTextColor(colors.lime)
  else
	mon.setTextColor(colors.black)
	sg.openIris()
  end
  s = "   IRIS   "
  i = 1
  for  yc = y/3-1, y/3*2 +1 do
    char = string.sub(s, i, i)
	mon.setCursorPos(6, yc)
	mon.write(" "..char.." ")
	i = i+1
  end
  if state == true then
    mon.setTextColor(colors.lime)
  else
	mon.setTextColor(colors.black)
  end
end

function drawLocalAddress() -- draws the address stargate being controlled 
  x,y = mon.getSize()
  mon.setBackgroundColor(colors.black)
  mon.setTextColor(colors.lightGray)
  mon.setCursorPos(x/2-7, 1)
  mon.write("Stargate Address:")
  mon.setCursorPos(x/2-3, 2)
  mon.write(sg.localAddress())
end

function drawDial() -- draws the button to access the dialing menu
  x,y = mon.getSize()
  state, int = sg.stargateState()
  for yc = y-3, y-1 do
    for xc = x/2-5, x/2 do
	  if state == "Idle" then
	    mon.setBackgroundColor(colors.lightGray)
	  else
	    mon.setBackgroundColor(colors.gray)
	  end
	  mon.setCursorPos(xc,yc)
	  mon.write(" ")
	end
  end
  mon.setCursorPos(x/2-4, y-2)
  mon.setTextColor(colors.black)
  mon.write("DIAL")
end

function drawTerm() -- draws the button to terminate the stargate connection to another gate
  x,y = mon.getSize()
  state, int = sg.stargateState()
  for yc = y-3, y-1 do
    for xc = x/2+2, x/2+7 do
	  if state == "Connected" or state == "Connecting" or state == "Dialling" then
	    mon.setBackgroundColor(colors.lightGray)
	  else
	    mon.setBackgroundColor(colors.gray)
	  end
	  mon.setCursorPos(xc,yc)
	  mon.write(" ")
	end
  end
  mon.setCursorPos(x/2+3, y-2)
  mon.setTextColor(colors.black)
  mon.write("TERM")
end 

function securityButton() -- draws the button to access the security menu
  x,y = mon.getSize()
  mon.setBackgroundColor(colors.lightGray)
  sOK, result = pcall(sg.openIris)
  if sOK == false then
    mon.setTextColor(colors.red)
  else
    mon.setTextColor(colors.black)
  end
  s = " DEFENCE "
  i = 1
  for  yc = y/3-1, y/3*2 +1 do
    char = string.sub(s, i, i)
	mon.setCursorPos(2, yc)
	mon.write(" "..char.." ")
	i = i+1
  end
  mon.setBackgroundColor(colors.black)
end

function drawSecurityPageTop() --draws the top of the security menu, all the addresses stored in the security table
  mon.setBackgroundColor(colors.black)
  mon.clear()
  mon.setTextColor(colors.black)
  x,y = mon.getSize()
  for yc = 1,y-3 do
    if yc%2 == 1 then
      mon.setBackgroundColor(colors.lightBlue)
	else
	  mon.setBackgroundColor(colors.lightGray)
	end
	for xc = 1,x do
	  mon.setCursorPos(xc, yc)
	  mon.write(" ")
	end
	mon.setCursorPos(x/2-4, yc)
	mon.write("Add Address")
  end
  if fs.exists("secList") then
    file = fs.open("secList","r")
	secInfo = textutils.unserialize(file.readAll())
	file.close()
	if string.len(textutils.serialize(secInfo)) > 7 then
    for k,v in pairs(secInfo) do
	  mon.setCursorPos(1,i)
	    if k%2 == 1 then
          mon.setBackgroundColor(colors.lightBlue)
	    else
	      mon.setBackgroundColor(colors.lightGray)
	    end
	    mon.setCursorPos(1, k)
		mon.write(v.name)
	    mon.setCursorPos(x/2-4, k)
	    mon.write("           ")
	    mon.setCursorPos(x/2 - string.len(v.address)/2 +1, k)
	    mon.write(v.address)
	    mon.setCursorPos(x,k)
	    mon.setBackgroundColor(colors.red)
	    mon.write("X")
	end
	end
  end 
  mon.setBackgroundColor(colors.black)
end
  
function drawSecurityPageBottom(listType) -- draws the buttons at the bottom of the security page
  for yc = y-2, y do
    for xc = 1, x do
      mon.setCursorPos(xc, yc)
	  if listType == "BLACKLIST" then
	    mon.setBackgroundColor(colors.black)
	    mon.setTextColor(colors.white)
      elseif listType == "WHITELIST" then
	    mon.setBackgroundColor(colors.white)
	    mon.setTextColor(colors.black)
	  elseif listType == "NONE" then
	    mon.setBackgroundColor(colors.gray)
	    mon.setTextColor(colors.white)
	  end
	  mon.write(" ")
	end
  end
  mon.setCursorPos((x/2 - tonumber(string.len(listType)/2)+1), y-1)
  mon.write(listType)
  mon.setCursorPos(x-5, y-1)
  mon.write("BACK")
  mon.setBackgroundColor(colors.black)
end  

function drawHome() -- draws the home screen
  mon.setBackgroundColor(colors.black)
  x,y = mon.getSize()
  mon.clear()
  mon.setCursorPos(1,y)
  mon.setTextColor(colors.gray)
  mon.setBackgroundColor(colors.black)
  mon.write("thatParadox")
  drawPowerBar()
  drawChevrons()
  status, int = sg.stargateState()
  drawSgStatus(tostring(status))
  drawHistoryButton()
  if sg.irisState()  == "Open" then
    drawIris(false)
  else
    drawIris(true)
  end
  drawLocalAddress()
  securityButton()
  drawDial()
  mon.setCursorBlink(false)
  drawTerm()
end

function drawBookmarksPage()
  mon.setBackgroundColor(colors.black)
  mon.clear()
  mon.setTextColor(colors.black)
  x,y = mon.getSize()
  for yc = 1,y-3 do
    if yc%2 == 1 then
      mon.setBackgroundColor(colors.lightBlue)
	else
	  mon.setBackgroundColor(colors.lightGray)
	end
	for xc = 1,x do
	  mon.setCursorPos(xc, yc)
	  mon.write(" ")
	end
  end
  for i= 1,y do
  	if i%2 == 1 then
      mon.setBackgroundColor(colors.lightBlue)
	else
	  mon.setBackgroundColor(colors.lightGray)
	end
    if fs.exists(tostring(i)) then
      file = fs.open(tostring(i),"r")
	  bookmark = textutils.unserialize(file.readAll())
	  file.close()
	  mon.setCursorPos(1,i)
	  for k,v in pairs(bookmark) do
	    if k == "name" then
	      mon.write(v)
		  mon.setCursorPos(x/2, i)
		  mon.write(bookmark.address)
	      mon.setCursorPos(x,i)
	      mon.setBackgroundColor(colors.red)
	      mon.write("X")
	    end
	  end
	elseif i < y-2 then
	  mon.setCursorPos(1, i)
	  mon.write("Add Address")
	end
  end
  mon.setCursorPos(x/2, y-1)
  mon.setBackgroundColor(colors.black)
  mon.setTextColor(colors.white)
  mon.write("BACK")
end

function drawRemoteIris()
  mon.setBackgroundColor(colors.black)
  x,y = mon.getSize()
  mon.setCursorPos(x/2-1, y/2+4)
  mon.write("IRIS.")
end

function inputPage(type)
  mon.clear()
  term.redirect(mon)
  term.setBackgroundColor(colors.lightGray)
  term.clear()
  x,y = term.getSize()
  term.setCursorPos(x/2-8, y/2-2)
  print("Set an address name")
  term.setCursorPos(x/2 - 4, y/2)
  print("         ")
  term.setCursorPos(x/2 - 4, y/2)
  nameInput = read()
  addressInput = "nil"
  term.setBackgroundColor(colors.lightGray)
  term.clear()
  term.setCursorPos(x/2-9, y/2-4)
  print("Enter Stargate address")
  if type == "secEntry" then
    term.setCursorPos(x/2-10, y/2-2)
    print("DO NOT ENTER ANY HYPHONS")
  end
  term.setBackgroundColor(colors.black)
  term.setCursorPos(x/2 - 5, y/2)
  print("           ")
  term.setCursorPos(x/2 - 5, y/2)
  addressInput = string.upper(read())
  newGate ={name = nameInput, address = addressInput}
  term.redirect(term.native())
  return newGate
end

function drawRemoteAddress()
  mon.setBackgroundColor(colors.black)
  x,y = mon.getSize()
  mon.setCursorPos((x/2+1) - string.len(sg.remoteAddress())/2, y/2-2)
  mon.write(sg.remoteAddress())
end

function drawHistoryButton()
  mon.setBackgroundColor(colors.lightGray)
  mon.setTextColor(colors.black)
  s = " HISTORY "
  i = 1
  for  yc = y/3-1, y/3*2 +1 do
    char = string.sub(s, i, i)
	mon.setCursorPos(x-7, yc)
	mon.write(" "..char.." ")
	i = i+1
  end
end

function addToHistory(address)
  if fs.exists("history") then
    file = fs.open("history", "r")
	history = textutils.unserialize(file.readAll())
	file.close()
  else
	history ={}
	print("")
	print("")
	print("no history file")
  end
  if textutils.serialize(history) == false then
    history = {}
	print("")
	print("")
	print("couldn't serialize")
  end
  test = textutils.serialize(historyTable)
  --if string.len(test) < 7 then
    --history = {}
	--print("")
	--print("")
	--print("string.len too short")
  --end
  table.insert(history, 1, address)
  file = fs.open("history", "w")
  file.write(textutils.serialize(history))
  file.close()
end

function drawHistoryPage()
  mon.setBackgroundColor(colors.black)
  mon.clear()
  mon.setTextColor(colors.black)
  x,y = mon.getSize()
  for yc = 1,y-3 do
    if yc%2 == 1 then
      mon.setBackgroundColor(colors.lightBlue)
	else
	  mon.setBackgroundColor(colors.lightGray)
	end
	for xc = 1,x do
	  mon.setCursorPos(xc, yc)
	  mon.write(" ")
	end
  end
  if fs.exists("history") then
    file = fs.open("history","r")
	historyTable = textutils.unserialize(file.readAll())
	file.close()
	test = textutils.serialize(historyTable)
	if string.len(test) > 7 then
      for k,v in pairs(historyTable) do
	    if k%2 == 1 then
          mon.setBackgroundColor(colors.lightBlue)
	    else
	      mon.setBackgroundColor(colors.lightGray)
	    end
	    mon.setCursorPos(1,k)
		mon.write(v)
	    mon.setCursorPos(x/2+7, k)
	    mon.setBackgroundColor(colors.blue)
	    mon.write("SAVE")
	    mon.setCursorPos(x-8, k)
	    mon.setBackgroundColor(colors.red)
	    mon.write("BAN/ALLOW")
		clickLimit = k
	  end
	end
	test = {}
  end 
  mon.setBackgroundColor(colors.black)
  for yc = y-2, y do
    for xc = 1,x do
	  mon.setCursorPos(xc, yc)
	  mon.write(" ")
	end
  end
  mon.setCursorPos(x/2, y-1)
  mon.setTextColor(colors.white)
  mon.write("BACK")
end

function historyInputPage(address)
  cx, cy = term.getCursorPos()
  mon.clear()
  term.redirect(mon)
  term.setBackgroundColor(colors.lightGray)
  term.clear()
  x,y = term.getSize()
  term.setCursorPos(x/2-8, y/2-2)
  print("Set an address name")
  term.setCursorPos(x/2 - 4, y/2)
  print("         ")
  term.setCursorPos(x/2 - 4, y/2)
  nameInput = read()
  addressInput = "nil"
  newGate ={name = nameInput, address = address}
  term.redirect(term.native())
  term.clear()
  term.setCursorPos(1,1)
  return newGate
end


if fs.exists("currentSec") then -- checks to see if there's list of gates stored for security reasons
  file = fs.open("currentSec", "r")
  currentSec = file.readAll()
  file.close()
else
  currentSec = "NONE"
end
mon.setTextScale(1)
drawHome()
while true do
  event, param1, param2, param3 = os.pullEvent()
  if event == "monitor_touch" then
    x,y = mon.getSize()
    if param2 >= 6 and param2 <= 8 and param3 >= y/3-2 and param3 <= y/3*2+1 then --opens or closes the Iris
	  if sg.irisState() == "Closed" then
	    ok, result = pcall(sg.openIris)
	    if ok then
		  drawIris(false)
		end
      else
	    ok, result = pcall(sg.closeIris)
		  if ok then
	        drawIris(true)
		  end
      end
	elseif param2 >= 2 and param2 <= 4 and param3 >= y/3-2 and param3 <= y/3*2+1 then -- click has opened the security menu
	  sOK, result = pcall(sg.openIris)
      if sOK then
	  while true do
	    drawSecurityPageTop()
	    drawSecurityPageBottom(currentSec)
	    event, param1, param2, param3 = os.pullEvent()
	    if event == "monitor_touch" then
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
			  file = fs.open("currentSec", "w")
			  file.write(currentSec)
			  file.close()
		    end
		  elseif param2 > x - 3 then -- delete record
              file = fs.open("secList", "r")
			  secList = textutils.unserialize(file.readAll())
			  file.close()
			  table.remove(secList, param3)
			  file = fs.open("secList", "w")
			  file.write(textutils.serialize(secList))
			  file.close()
			  drawSecurityPageTop()
		  elseif param3 < y - 2 then -- check if empty, if so add new entry	  
            if fs.exists("secList") == false then
			  secList = {}
			  table.insert(secList, 1, inputPage())
			  file = fs.open("secList", "w")
			  file.write(textutils.serialize(secList))
			  file.close()
			else
              file = fs.open("secList", "r")
			  secList = textutils.unserialize(file.readAll())
			  file.close()
			  table.insert(secList, 1, inputPage("secEntry"))
			  file = fs.open("secList", "w")
			  file.write(textutils.serialize(secList))
			  file.close()
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
	elseif param2 > x/2-5 and param2 <= x/2 and param3 >= y-3 and param3 <= y-1 then -- Click has opened dial menu
	  status, int = sg.stargateState()
	  if status == "Idle" then
	  while true do
	    drawBookmarksPage()
		event, param1, param2, param3 = os.pullEvent()
		if event == "monitor_touch" then
		  if param3 >= y-2 then -- user clicked back
		    drawHome()
			break
	      elseif param2 > x-2 then -- user clicked delete on a bookmark
		    if fs.exists(tostring(param3)) then
			  fs.delete(tostring(param3))
			end
		  else -- user has clicked on a bookmark
		    if fs.exists(tostring(param3)) then
			  file = fs.open(tostring(param3), "r")
			  gateData = textutils.unserialize(file.readAll()) -- GATE DATA VARIABLE!!!
			  file.close()
			  drawHome()
			  for k,v in pairs(gateData) do
			    if k == "address" then
                  ok, result = pcall(sg.dial, v)
                  if ok then
				    status, int = sg.stargateState()
                    drawSgStatus(status)
					address = v
					addToHistory(v)
                  else
                    drawSgStatus("Error")
		          end
				end
				sleep(.5)
			  end
			  break
			else
			  x,y = mon.getSize()
			  for i = 1,y do
			    if fs.exists(tostring(i)) == false then
                  file = fs.open(tostring(i), "w")
				  file.write(textutils.serialize(inputPage()))
				  file.close()
				  break
				end
			  end
			end
          end
		else
	      drawHome()
	      break
	    end
	  end
	  end
	elseif param2 > x-7 and param2 < x-4 and param3 >= y/3-2 and param3 <= y/3*2+1 then -- Click has opened history menu
	  while true do
	    drawHistoryPage()
		event, param1, param2, param3 = os.pullEvent()
		if event == "monitor_touch" then
		  if param3 >= y-2 then -- user clicked back
		    drawHome()
			break --might break everything
          elseif param2 >= x/2+7 and param2 <= x/2+10 and param3 <= clickLimit then -- user has clicked save.
			if fs.exists("history") then
              file = fs.open("history", "r")
		      history = textutils.unserialize(file.readAll())
			  file.close()
			  for i = 1,y do
				if fs.exists(tostring(i)) == false then
				  file = fs.open(tostring(i), "w")
			      file.write(textutils.serialize(historyInputPage(history[param3])))
			      file.close()
				  break
				end
			  end
			end
		  elseif param2 >= x-9 and param3 <= clickLimit then -- user click "ban/allow"
		    if fs.exists("history") then
              file = fs.open("history", "r")
		      history = textutils.unserialize(file.readAll())
			  file.close()
			  if fs.exists("secList") == false then
			    secList = {}
			    table.insert(secList, 1, historyInputPage(history[param3]))
			    file = fs.open("secList", "w")
			    file.write(textutils.serialize(secList))
			    file.close()
			  else
                file = fs.open("secList", "r")
			    secList = textutils.unserialize(file.readAll())
			    file.close()
			    table.insert(secList, 1, historyInputPage(history[param3]))
			    file = fs.open("secList", "w")
			    file.write(textutils.serialize(secList))
			    file.close()
			  end
			end
		  end
		  drawHome()
	      break  
	    end		
	  end
	elseif param2 > x/2+2 and param2 <= x/2+7 and param3 >= y-3 and param3 <= y-1 then -- user clicked TERM
	  ok, result = pcall(sg.disconnect)
	  drawChevrons()
	end
  elseif event == "sgDialIn" then
	mon.setTextColor(colors.orange)
	drawRemoteAddress()
	alarmSet(true)
	if fs.exists("currentSec") then
      file = fs.open("currentSec", "r")
	  currentSec = file.readAll()
	  file.close()
	end
	if fs.exists("secList") then
	  file = fs.open("secList", "r")
	  secList = textutils.unserialize(file.readAll())
	  for k,v in pairs(secList) do
	    address = v.address
	    if string.sub(v.address,1,7) == param2 or v.address == param2 then
	      if currentSec == "BLACKLIST" then
		    sg.closeIris()
		    drawIris(true)
		  elseif currentSec == "WHITELIST" then
		      sg.openIris()
			  drawIris(false)
		  else
		    sg.openIris()
			drawIris(false)
		  end
		  secGate = true
	    end
	  end
	end
    if secGate == true and currentSec == "WHITELIST" then
	  sg.openIris()
	  drawIris(false)
	  gateSec = false
	end
	addToHistory(param2)
  elseif event == "sgMessageReceived" then
	if param2 == "Open" then
	  mon.setTextColor(colors.lime)
	  drawRemoteIris()
	elseif param2 == "Closed" then
	  mon.setTextColor(colors.red)
	  drawRemoteIris()
	end	  
  elseif event == "sgStargateStateChange" or "sgChevronEngaged" then
    drawDial()
    drawPowerBar()
    drawTerm()
	status, int = sg.stargateState()
    drawSgStatus(tostring(status))
	if status == "idle" then
	  isConnected = false
	else
	  isConnected = true
	end
	if event == "sgChevronEngaged" then
	  mon.setTextColor(colors.orange)
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
	  mon.setTextColor(colors.lightBlue)
      drawRemoteAddress()
	  for k,v in pairs(dialling) do
	    drawChev({k,v})
	  end
	  sg.sendMessage(sg.irisState())
	end
  end
end