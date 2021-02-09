script_name('funcslib')
script_author('Callow')
script_moonloader(023)
script_version("0.1b")
script_description('Get the latest MoonLoader updates from http://blast.hk/moonloader/')

require "lib.sampfuncs"
require "lib.moonloader"
local globls =require "lib.game.globals"
local sampeve = require 'lib.samp.events'
local inicfg = require 'inicfg'
local key = require "vkeys"
local tweaks = require "lib.mgtweaks"
ini2 = inicfg.load(nil,"moonloader/config/bind.ini");

local thrBind = {}
local Pmobile = ""
local Prank = ""
local lin = {}

function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(100)  end

	  onSystemInitialized()
    sampRegisterChatCommand("bmenu", bmenu)
    sampRegisterChatCommand("stats", getpassport)
		while true do
    wait(0)
    if enabled then
			sl:drawWindow(850,600)
			if sampIsChatInputActive() then sampSetChatInputEnabled(false) end
		end
    if doClose then toggle(false) doClose = false end
		lin[0] = ""
	  end
end

function getpassport()
	getps = true
	sampSendChat("/mn")
end
--[[
0x99cc00 -- msg c 060
0x66cc66 -- msg advget
0x66cc00 -- c c 060
0x3399ff -- 3 line c 060
0xffcd00 -- title
0xff9999 -- 4 line
0xffcc00 -- 5-6 line
0xff7000 -- other line
--]]

function sampeve.onShowDialog(id,style,title,bt1,bt2,text)
if string.find(title,"Меню игрока") ~= nil then
	if getps then
		sampSendDialogResponse(id, 1, 0,nil)
		return false
	end
elseif string.find(title,"Статистика") ~= nil then
		if getps then
		  local m = Split(text,"(%d+)")
			Plevel = m[2]
			Pmobile = m[5]
			Prank = text:match("Работа / должность:(%A+)\nРанг:")
			Prank = Prank:sub(3,Prank:len())
			--sampFuncsLog();
			getps = false
			return false
		end
  elseif string.find(title,"Члены подразделения онлайн") ~= nil then
	  if gtFind then
		  local x,_,_ = text:find(gtName)
		  if x then
		    local text1 = string.reverse(text)
		    local x1,_,_ = text1:find("\n",text:len()-x)
        local m = Split(text:sub(text:len() - x1,x),"(%d+)")
			  gtMobile = m[3]
			else
				gtMobile = "Unknown"
      end
			gtFind = false
			x = nil
			return false
		end
	end
end

--------------------------------------------------------------------------------
------------------------------W I N D O W T O O L-------------------------------
--------------------------------------------------------------------------------

local activekey = {key.VK_CONTROL,key.VK_SHIFT,key.VK_MENU}

function onTextChanged(textbox,keyid)
	if textbox == 37 then
		sl.ebxOptions[1].text = key.id_to_name(keyid)
		for i, v in ipairs(activekey) do
			if (isKeyDown(v) and keyid ~= v) then sl.ebxOptions[1].text = key.id_to_name(v).."+"..sl.ebxOptions[1].text break end
		end
		saveLine(textbox)
		return true
	end
	return false
end

function onTextEdit(textbox,text)
	if textbox == 38 then
		sl.btnLink[sl.currentLink].name = text
		saveLine(textbox)
	end
	return false
end

function onSystemInitialized()
	if not initialized then
		init()
	end
end

function ReplaceText(text,pos1,pos2,rtext)
  local offset = rtext:len()
	local deleted = 0
  if pos1 ~= text:len() and pos2 ~= text:len() then
    if pos1 < pos2 then
      local temp = pos1
      pos1 = pos2
      pos2 = temp
    end
    text = string.format("%s%s%s",text:sub(0,pos2),rtext,text:sub(pos1+1,text:len()))
    pos2 = pos2 + offset
		deleted = pos1 - pos2 + rtext:len()
  else
    if pos2 == text:len() then
      pos2 = pos1
    end
    text = string.format("%s%s",text:sub(0,pos2),rtext)
		deleted = text:len() - pos2 + rtext:len()
    pos2 = text:len()
  end
  return text,pos2,deleted
end

function init()
	initialized = true
	mh = tweaks.mouseHandler:new()
	sl = BindMenu:new()
end

function bmenu()
  toggle(not enable)
end

function toggle(show)
	enabled = show
  sampSetCursorMode(2)
	sampToggleCursor(show)
end

function bmClose()
	enabled = false
  doClose = true
	saveLine(EditBoxActive)
	saveall()
	EditBoxActive = -1
end

function pgSvch()
end

function pageSwitch(num)
	if enabled then
	  sl.currentPageLink = num
  end
end

listNamesTG = {"$PTGID","$PTGNAME","$PTGSCORE","$IFTG","$PTGMOBILE"}

function sampeve.onSendCommand(command)
  --print("Command: ",command)
  for i=1,sl.countLink do
    if ini2["Options_"..i] ~= nil and ini2["Options_"..i].TypeBind == "command" and ini2["Options_"..i].Command == command:gsub("/","") then
      if not thrBind[i] or thrBind[i].dead then
        thrBind[i] = lua_thread.create(keyBindThread, i)
      else
        thrBind[i]:terminate()
      end
    end
  end
end

function keyBindThread(id)
  local mod = tonumber(ini2["Options_"..id].Mode)
  local repeats = tonumber(ini2["Options_"..id].Repeats)
  local reps = 1
  local loop = 0
  if mod then
    if mod == 1 then reps = -1
    elseif mod == 2 and repeats then reps = 0 + math.abs(repeats)
    end
  end
  while loop ~= reps do
    loop = loop + 1
    for i=1, getCountLines(id) do
  		local v = ini2["Lines_"..id]["s_"..i]
  		if v ~= nil then
  			local time = ini2["Lines_"..id]["p_"..i]
  			local enter = ini2["Lines_"..id]["e_"..i]
  			wait(time)
  			local result, playerID = sampGetPlayerIdByCharHandle(PLAYER_PED)
  			local nick = sampGetPlayerNickname(playerID)
  			local kid;
  			nick = nick:gsub("_"," ")
  			local tid,tname,tscore;
        local tg = false;
        for j, item in ipairs(listNamesTG) do
          if v:find(item,1,true) then tg = true break end
        end
  			if tg then
  				local valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
  				repeat
  					wait(10)
  					valid, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
  				until (valid and doesCharExist(ped)) or v:find("$TGM_1",1,true)
          if (valid and doesCharExist(ped)) then
  				  local result, id = sampGetPlayerIdByCharHandle(ped)
  				  tid = id
  				  tname = sampGetPlayerNickname(tid)
  				  if v:find("$PTGMOBILE",1,true) then
  				    gtFind = true
  					  gtName = tname
  					  sampSendChat("/find")
  					  while gtMobile == nil do  wait(10) end
  					  v = v:gsub("$PTGMOBILE",gtMobile)
  					  gtMobile = nil
  				  end
  				  tname = tname:gsub("_"," ")
  				  tscore = sampGetPlayerScore(tid)
  				  v = v:gsub("$PTGID",tid)
  				  v = v:gsub("$PTGNAME",tname)
  				  v = v:gsub("$PTGSCORE",tscore)
  				  v = v:gsub("$IFTG","")
          else
            for j, item in ipairs(listNamesTG) do
              v = v:gsub(item,"")
            end
  			  end
        end
        v = v:gsub("$TGM_1","")
  			if v:find("$KBIND_",1,true) then
  				setVirtualKeyDown(v:match("$KBIND_(%d+)"), true)
  				wait(64)
  				setVirtualKeyDown(v:match("$KBIND_(%d+)"), false)
  				v = v:gsub("$KBIND_(%d+)","")
  			end
        v = v:gsub("$PMOBILE",Pmobile)
  			v = v:gsub("$PSCORE",sampGetPlayerScore(playerID))
  			v = v:gsub("$PRANK",Prank)
  			v = v:gsub("$PID",playerID)
  			v = v:gsub("$PNAME",nick)
        v = v:gsub("$PWID",weapID)
        v = v:gsub("$PPWID",prevID)
        v = v:gsub("$PWNAME",getweaponname(weapID))
        v = v:gsub("$PPWNAME",getweaponname(prevID))
  			if enter == true then
  			  if v ~= "" then
  			    sampSendChat(v)
  		    end
  			else
  				sampSetChatInputEnabled(true)
  				sampSetChatInputText(v)
  				repeat
  				  wait(10)
  			  until not sampIsChatInputActive()
  			end
      else break
  		end
  	end
  end
end

function getweaponname(weapon)
  local names = {
  [0] = "Fist",
  [1] = "Brass Knuckles",
  [2] = "Golf Club",
  [3] = "Nightstick",
  [4] = "Knife",
  [5] = "Baseball Bat",
  [6] = "Shovel",
  [7] = "Pool Cue",
  [8] = "Katana",
  [9] = "Chainsaw",
  [10] = "Purple Dildo",
  [11] = "Dildo",
  [12] = "Vibrator",
  [13] = "Silver Vibrator",
  [14] = "Flowers",
  [15] = "Cane",
  [16] = "Grenade",
  [17] = "Tear Gas",
  [18] = "Molotov Cocktail",
  [22] = "9mm",
  [23] = "Silenced 9mm",
  [24] = "Desert Eagle",
  [25] = "Shotgun",
  [26] = "Sawnoff Shotgun",
  [27] = "Combat Shotgun",
  [28] = "Micro SMG/Uzi",
  [29] = "MP5",
  [30] = "AK-47",
  [31] = "M4",
  [32] = "Tec-9",
  [33] = "Country Rifle",
  [34] = "Sniper Rifle",
  [35] = "RPG",
  [36] = "HS Rocket",
  [37] = "Flamethrower",
  [38] = "Minigun",
  [39] = "Satchel Charge",
  [40] = "Detonator",
  [41] = "Spraycan",
  [42] = "Fire Extinguisher",
  [43] = "Camera",
  [44] = "Night Vis Goggles",
  [45] = "Thermal Goggles",
  [46] = "Parachute" }
  return names[weapon]
end

weapID = 0
prevID = 0
function sampeve.onSendPlayerSync(data)
	if weapID ~= data.weapon then
    onPlayerChangeWeapon(data.weapon,weapID)
    prevID = weapID
		weapID = data.weapon
	end
end

function Split(s,pattern)
  local n = 1
	local mas = {}
	while string.find(s,pattern,n) ~= nil do
		local n1,n2,s2 = string.find (s,pattern,n)
		n = n2 + 1
		table.insert(mas,s2)
  end
	return mas
end

function onPlayerChangeWeapon(wepid,pwepid)
	if EditBoxActive == -1 and not sampIsChatInputActive() and not sampIsDialogActive() then
		for i=1,sl.countLink do
			if ini2["Options_"..i] ~= nil and ini2["Options_"..i].TypeBind == "event" and ini2["Options_"..i].EventId == 0 then
				if sl.ebxOptions[5].text == -1 or sl.ebxOptions[6].text == -1 then
					if not thrBind[i] or thrBind[i].dead then
						thrBind[i] = lua_thread.create(keyBindThread, i)
					end
        else
					local m = Split(ini2["Options_"..i].Weapons,"(%d+)")
          for id, v in ipairs(m) do
          	if tonumber(v) == wepid then
							if not thrBind[i] or thrBind[i].dead then
								thrBind[i] = lua_thread.create(keyBindThread, i)
							end
							break
						end
          end
					local m2 = Split(ini2["Options_"..i].WeaponsPrev,"(%d+)")
					for id, v in ipairs(m2) do
						if tonumber(v) == pwepid then
							if not thrBind[i] or thrBind[i].dead then
								thrBind[i] = lua_thread.create(keyBindThread, i)
							end
							break
						end
					end
				end
			end
		end
	end
end

function sampeve.onGivePlayerWeapon(wid,ammo)
	--sampFuncsLog("Player get weapon: id "..wid..", ammo "..ammo..".")
end

--[[
ID's events:
0 :$WEAPID,$WEAPNAME,$PREVID,$PREVNAME
1 :$CARID,$CARNAME
2 :$CARID,$CARNAME
3 :$PTGID,$PTGNAME
]]
function kd(key,key2)
	if key == key2 or isKeyDown(key2) then return true end
	return false
end

function keyDown(keyid)
	if EditBoxActive == -1 and not sampIsChatInputActive() and not sampIsDialogActive() then
		for i=1,sl.countLink do
			if ini2["Options_"..i] ~= nil and ini2["Options_"..i].TypeBind == "key" then
				local k1,k2 = ini2["Options_"..i].KeyIdPrev,ini2["Options_"..i].KeyId
				if not k1 then k1 = k2 end
				--print(kd(keyid,k2),kd(keyid,k1))
				if (keyid == k1 or keyid == k2) and kd(keyid,k1) and kd(keyid,k2) then
					if not thrBind[i] or thrBind[i].dead then
						thrBind[i] = lua_thread.create(keyBindThread, i)
					else
						thrBind[i]:terminate()
					end
				end
			end
		end
	end
end

function onWindowMessage(msg, wparam, lparam)
  if msg == 0x104  then
		--if wparam == 0x12 then
      onTextChanged(EditBoxActive,wparam)
			keyDown(wparam)
		--end
  elseif msg == 0x100 then
		lock = onTextChanged(EditBoxActive,wparam)
		keyDown(wparam)
    for i, ed in ipairs(EditBox) do
      if EditBoxActive == ed.id then
        if wparam == 37 or wparam == 39 then
          ed:SendChar(wparam)
        end
      end
    end
  elseif msg == 0x102 then
    for i, ed in ipairs(EditBox) do
      if EditBoxActive == ed.id then
        ed:SendChar(wparam)
      end
    end
  end
	if msg ~= 275 then
	 --print(msg .."|"..wparam.."|"..lparam)
	end
end

function addline()
	sl.countLine = sl.countLine + 1
	saveLine(sl.countLine - 18*(sl.currentPageLine-1))
end

function addLineAL()
	if EditBoxActive ~= -1 then
		----sampFuncsLog(EditBoxActive-55+ 18*(sl.currentPageLine-1).."|"..  ini2["Lines_"..sl.currentLink][EditBoxActive-55 + 18*(sl.currentPageLine-1)])
		local id = EditBoxActive+ 18*(sl.currentPageLine-1)
		local t1,t2,t3,t4,t5,t6;
		t1,t2,t3 = ini2["Lines_"..sl.currentLink]["s_"..id],ini2["Lines_"..sl.currentLink]["e_"..id],ini2["Lines_"..sl.currentLink]["p_"..id]
		for i = id+1, getCountLines(sl.currentLink)+1 do
			t4,t5,t6 = ini2["Lines_"..sl.currentLink]["s_"..i],ini2["Lines_"..sl.currentLink]["e_"..i],ini2["Lines_"..sl.currentLink]["p_"..i]
			ini2["Lines_"..sl.currentLink]["s_"..i],ini2["Lines_"..sl.currentLink]["e_"..i],ini2["Lines_"..sl.currentLink]["p_"..i] = t1,t2,t3
			t1,t2,t3 = t4,t5,t6
		end
		ini2["Lines_"..sl.currentLink]["s_"..id],ini2["Lines_"..sl.currentLink]["e_"..id],ini2["Lines_"..sl.currentLink]["p_"..id] = "New Line",true,"1000"
		sl.countLine = sl.countLine + 1
		openLink({sl.currentLink,sl.currentPageLine})
	end
end

function onEditBoxActiveChange(previd,id)
	saveLine(previd)
end

function openLink(params)
	print(params[1])
  local st = (params[2]-1)*18
  local bm = nil
  if not params[3] then
    bm = sl
  else
    bm = params[3]
  end
	if not params[4] then saveLine(EditBoxActive) end
	if bm.currentPageLine ~= params[2]  or bm.currentLink ~= params[1] then
	  EditBoxActive = -1
  end
  if bm.currentLink ~= params[1] then
		local k1,k2 = ini2["Options_"..params[1]].KeyIdPrev,ini2["Options_"..params[1]].KeyId
		if k1 then
		  bm.ebxOptions[1].text = key.id_to_name(k1).."+"..key.id_to_name(k2)
		else
			bm.ebxOptions[1].text = key.id_to_name(k2)
		end
		print(ini2["Options_"..params[1]].Name)
		bm.ebxOptions[2].text = ini2["Options_"..params[1]].Name
		bm.ebxOptions[3].text = ini2["Options_"..params[1]].TypeBind
		bm.ebxOptions[4].text = ini2["Options_"..params[1]].EventId
		bm.ebxOptions[5].text = ini2["Options_"..params[1]].Weapons
		bm.ebxOptions[6].text = ini2["Options_"..params[1]].WeaponsPrev
    bm.ebxOptions[14].text = ini2["Options_"..params[1]].Mode
    bm.ebxOptions[15].text = ini2["Options_"..params[1]].Repeats
    bm.ebxOptions[10].text = ini2["Options_"..params[1]].Command
		for i, v in ipairs(bm.ebxOptions) do
			v.first = true
		end
	end
  for i=st+1, st+18 do
    if ini2["Lines_"..params[1]]["s_"..i] ~= nil then
      bm.EditBox[i-st].text = ini2["Lines_"..params[1]]["s_"..i]
    else
      bm.EditBox[i-st].text = "New text"
    end
		bm.cbxEnter[i-st].checked = ini2["Lines_"..params[1]]["e_"..i]
		if ini2["Lines_"..params[1]]["p_"..i] ~= nil then
			bm.ebxPause[i-st].text = ini2["Lines_"..params[1]]["p_"..i]
		else
			bm.ebxPause[i-st].text = "1000"
		end
		bm.EditBox[i-st].first = true
		bm.ebxPause[i-st].first = true
  end
  if params[1] ~= bm.currentLink then
    bm.countLine = getCountLines(params[1])
  end
  bm.currentLink = params[1]
  bm.currentPageLine = params[2]
end

function getCountLines(id)
	for i = 1, 400 do
		if ini2["Lines_"..id]["s_"..i] == nil then return i-1 end
	end
end
function saveLine(id)

	if id ~= -1 and id <= 18 then
		--sampFuncsLog(sl.currentLink)
		local lnk = sl.currentLink
	  local ids = id+18*(sl.currentPageLine-1)
	  ini2["Lines_"..lnk]["s_"..ids] = sl.EditBox[id].text
		ini2["Lines_"..lnk]["p_"..ids] = sl.ebxPause[id].text
		ini2["Lines_"..lnk]["e_"..ids] = sl.cbxEnter[id].checked
	elseif id ~= -1 and id > 36 then
		--sampFuncsLog(sl.currentLink)
		local lnk = sl.currentLink
		if id == 37 then

			if string.find(sl.ebxOptions[1].text,"+") then
				local p1,p2 = string.match(sl.ebxOptions[1].text,"(%a+)+(.*)")
				--print("Keys: ",p1,p2)
				ini2["Options_"..lnk].KeyIdPrev = key.name_to_id(p1,true)
				ini2["Options_"..lnk].KeyId = key.name_to_id(p2,true)
			else
				ini2["Options_"..lnk].KeyIdPrev = false
				ini2["Options_"..lnk].KeyId = key.name_to_id(sl.ebxOptions[1].text,true)
			end
    elseif id == 38 then
      ini2["Options_"..lnk].Name = sl.ebxOptions[2].text
    elseif id == 39 then
      ini2["Options_"..lnk].TypeBind = sl.ebxOptions[3].text:lower()
    elseif id == 40 then
      ini2["Options_"..lnk].EventId = sl.ebxOptions[4].text
		elseif id == 41 then
			ini2["Options_"..lnk].Weapons = sl.ebxOptions[5].text
	  elseif id == 42 then
			ini2["Options_"..lnk].WeaponsPrev = sl.ebxOptions[6].text
    elseif id == 46 then
      ini2["Options_"..lnk].Command = sl.ebxOptions[10].text
    elseif id == 50 then
      ini2["Options_"..lnk].Mode = tonumber(sl.ebxOptions[14].text)
    elseif id == 51 then
      ini2["Options_"..lnk].Repeats = tonumber(sl.ebxOptions[15].text)
    end
	elseif id ~= -1 then
		--sampFuncsLog(sl.currentLink)
		local lnk = sl.currentLink
		local ids = id+18*(sl.currentPageLine-1)-18
		ini2["Lines_"..lnk]["s_"..ids] = sl.EditBox[id-18].text
		ini2["Lines_"..lnk]["p_"..ids] = sl.ebxPause[id-18].text
		ini2["Lines_"..lnk]["e_"..ids] = sl.cbxEnter[id-18].checked
	end
end

function saveall()
  saveLine(EditBoxActive)
  inicfg.save(ini2, "./moonloader/config/bind.ini")
end

function addLink()
	local pos = 1
	for i = 1,100 do
		if ini2["Options_"..i] == nil then
			pos = i
			break
		end
	end
	table.insert(ini2,"Options_"..pos)
	table.insert(ini2,"Lines_"..pos)
	ini2["Options_"..pos] = {
			  Name = "Name",
			  TypeBind = "key",
			  KeyId = 49,
			  EventId = -1,
			  Command = "nil"
			  }
  ini2["Lines_"..pos] = {}
	sl.btnLink[pos] = tweaks.button:new(20+pos, ini2["Options_"..pos].Name, openLink,fonted,{pos,1})
	sl.countLink = sl.countLink + 1
end

function changeCheckBox(id,checked)
	saveLine(id)
end

function delLine()
  if EditBoxActive ~= -1 then
		local id = EditBoxActive+ 18*(sl.currentPageLine-1)
		if getCountLines(sl.currentLink) ~= id then
			for i = id, getCountLines(sl.currentLink)-1 do
				ini2["Lines_"..sl.currentLink]["s_"..i],ini2["Lines_"..sl.currentLink]["e_"..i],ini2["Lines_"..sl.currentLink]["p_"..i] =ini2["Lines_"..sl.currentLink]["s_"..i+1],ini2["Lines_"..sl.currentLink]["e_"..i+1],ini2["Lines_"..sl.currentLink]["p_"..i+1]
			end
		end
		ini2["Lines_"..sl.currentLink]["s_"..getCountLines(sl.currentLink)],ini2["Lines_"..sl.currentLink]["e_"..getCountLines(sl.currentLink)],ini2["Lines_"..sl.currentLink]["p_"..getCountLines(sl.currentLink)] = nil,nil,nil
    sl.countLine = sl.countLine - 1
		openLink({sl.currentLink,sl.currentPageLine,false,true})
		if getCountLines(sl.currentLink) - 18*(sl.currentPageLine-1) < EditBoxActive+ 18*(sl.currentPageLine-1) and sl.countLine ~= 0 then EditBoxActive = EditBoxActive-1 end
    if sl.currentPageLine > 1 and EditBoxActive == 0 then sl.currentPageLine = sl.currentPageLine - 1;  EditBoxActive = 18 end
	  if sl.countLine == 0 then EditBoxActive = -1 end
  end
end

function delLink()
		if sl.countLink ~= sl.currentLink then
			for i = sl.currentLink, sl.countLink-1 do
				ini2["Lines_"..i],ini2["Options_"..i],sl.btnLink[i].name =ini2["Lines_"..i+1],ini2["Options_"..i+1],sl.btnLink[i+1].name
			end
		end
		ini2["Lines_"..sl.countLink],ini2["Options_"..sl.countLink],sl.btnLink[sl.countLink].name = nil,nil,nil
    sl.countLink = sl.countLink - 1
		if sl.countLink < sl.currentLink and sl.countLink ~= 0 then openLink({sl.currentLink-1,1,false,true}) end
    if sl.currentPageLink > 1 and sl.countLink - 15*(sl.currentPageLink-1) == 0 then sl.currentPageLink = sl.currentPageLink - 1; end
end

function openOptions(state)
	sl.openOptions = state;
	saveLine(EditBoxActive)
	EditBoxActive = -1
end

--------------------------------------------------------------------------------
--------------------------R-E-N-D-E-R--M-E-N-U----------------------------------
--------------------------------------------------------------------------------
local listTypes = {
	{"key","Key",1},{"event","Event ID",4},{"command","Command",10}
}
local listArgs = {
	{4,0,"Weapon Prev IDs",6,"Weapon IDs",5},{4,1,"CarIds",7},{4,2,"In mine msg",8,"In each msg",9},
}

BindMenu = {}
function BindMenu:new()

  local public = {}
  public.x, public.y = 0, 0
	public.currentPageLink = 1
  public.currentPageLine = 1
	public.currentLink = -1
	public.countLine = 1
  public.countLink = 1
	public.openOptions = false
	fonted = renderCreateFont("PT Mono Bold", 10,FCR_NONE)
  public.btnClose = tweaks.button:new(4, "x", bmClose ,fonted)
	public.btnAddLink = tweaks.button:new(4, "Add", addLink ,fonted)
	public.btnRemoveLink = tweaks.button:new(4, "Remove", delLink ,fonted)
	public.btnAdd = tweaks.button:new(4, "Add to end", addline ,fonted)
	public.btnAddAL = tweaks.button:new(4, "Add after line", addLineAL ,fonted)
	public.btnRemove = tweaks.button:new(4, "Remove", delLine,fonted)
	public.btnOptions = tweaks.button:new(4, "Options", openOptions ,fonted,true)
	public.btnList = tweaks.button:new(4, "List", openOptions ,fonted,false)
  public.EditBox = {}
	public.ebxOptions = {}
	for i = 1,15 do
		public.ebxOptions[i] = EditBox:new(36+i, "" ,fonted)
	end
	public.cbxEnter = {}
	public.ebxPause = {}
  for i = 1,18 do
    public.EditBox[i] = EditBox:new(i,"",fonted)
		public.ebxPause[i] = EditBox:new(18+i,"",fonted)
		public.cbxEnter[i] = CheckBox:new(i,true,changeCheckBox)
  end
  public.btnPage = {}
	public.btnLink = {}
	for i = 1, 15*8 do
    if (ini2["Options_"..i] ~= nil) then
		  public.btnLink[i] = tweaks.button:new(20+i, ini2["Options_"..i].Name, openLink,fonted,{i,1})
    else
      public.countLink = i-1
      break
    end
	end

	for i = 1, 8 do
		public.btnPage[i] = tweaks.button:new(10+i, i, pageSwitch , fonted,i)
	end
  public.btnPageLink = {}
  for i = 1, 10 do
		public.btnPageLink[i] = tweaks.button:new(10+i, i, openLink , fonted,{1,i})
	end
  public.toolTip = tweaks.toolTip:new(330)
  public.windowTitle = "BinderManager v " .. thisScript().version

  function public:drawWindowTitle(text)
    local x = self.x - (renderGetFontDrawTextLength(fonted, text) / 2) + self.w / 2
    local y = self.y - 17
    renderDrawBox(self.x, y, self.w, 20, 0xFF141414)
    renderFontDrawText(fonted, text, x, y, 0xDCDCFFFF)
  end

  function public:drawWindow(w,h)
		repeat
		until fonted
    sampToggleCursor(true)
    self.x, self.y = getScreenResolution()
		self.w, self.h = w,h
    self.x, self.y = self.x / 2 - self.w / 2, self.y / 2 - self.h / 2

    self:drawWindowTitle(self.windowTitle)
    renderDrawBoxWithBorder(self.x, self.y, self.w, self.h, 0xD0101010, 2, 0xFF141414)
    self.btnClose:draw(self.x + self.w - 15, self.y - 17, 15, 20)
		self:drawList()
		renderDrawBox(self.x + 200, self.y + 40, self.w - 205 , self.h - 50 , 0x42FFFFFF)
		if not self.openOptions then
		  self.btnOptions:draw(self.x + self.w - 105,self.y + 8,100,30,0x42FFFFFF,0x7AC5C5C5,0x7Aa9a9a9,0xFFa8cc7f)
		  self.btnList:draw(self.x + self.w - 207,self.y + 8,100,30,0x99C0BCBC,0x99C0BCBC,0x99C0BCBC,0xFFa8cc7f)
		else
			self.btnOptions:draw(self.x + self.w - 105,self.y + 8,100,30,0x99C0BCBC,0x99C0BCBC,0x99C0BCBC,0xFFa8cc7f)
			self.btnList:draw(self.x + self.w - 207,self.y + 8,100,30,0x42FFFFFF,0x7AC5C5C5,0x7Aa9a9a9,0xFFa8cc7f)
		end
		if not self.openOptions then
		  self:drawEditWindow()
    else
			self:drawOptions()
		end
  end

  function public:drawOptions()
		---------------------------------------------------------------------------------------------------------------------------------
		renderDrawBox(self.x + 205, self.y + 45, 315 , 40 , 0x42FFFFFF)
		self.ebxOptions[2]:draw(self.x + 330, self.y + 52, 185 , 26 , 0x42FFFFFF, 0xFFa8cc7f,0x7AC5C5C5)
		renderFontDrawText(fonted, "Name", self.x + 268 - (renderGetFontDrawTextLength(fonted, "Name") / 2), self.y + 57, 0xFFa8cc7f)
		---------------------------------------------------------------------------------------------------------------------------------
		---------------------------------------------------------------------------------------------------------------------------------
		renderDrawBox(self.x + 525, self.y + 45, 315 , 40 , 0x42FFFFFF)
		self.ebxOptions[3]:draw(self.x + 650, self.y + 52, 185 , 26 , 0x42FFFFFF, 0xFFa8cc7f,0x7AC5C5C5)
		renderFontDrawText(fonted, "Type Bind", self.x + 587 - (renderGetFontDrawTextLength(fonted, "Type Bind") / 2), self.y + 57, 0xFFa8cc7f)
		---------------------------------------------------------------------------------------------------------------------------------
		renderDrawBox(self.x + 525, self.y + 90, 315 , 40 , 0x42FFFFFF)
		self.ebxOptions[14]:draw(self.x + 650, self.y + 97, 185 , 26 , 0x42FFFFFF, 0xFFa8cc7f,0x7AC5C5C5)
		renderFontDrawText(fonted, "Mode", self.x + 587 - (renderGetFontDrawTextLength(fonted, "Mode") / 2), self.y + 104, 0xFFa8cc7f)
    if tonumber(self.ebxOptions[14].text) == 2 then
      renderDrawBox(self.x + 205, self.y + 180, 315 , 40 , 0x42FFFFFF)
  		self.ebxOptions[15]:draw(self.x + 330, self.y + 187, 185 , 26 , 0x42FFFFFF, 0xFFa8cc7f,0x7AC5C5C5)
  		renderFontDrawText(fonted, "Repeats", self.x + 268 - (renderGetFontDrawTextLength(fonted, "Repeats") / 2), self.y + 194, 0xFFa8cc7f)
    end
		---------------------------------------------------------------------------------------------------------------------------------
		for i, v in ipairs(listTypes) do
			if self.ebxOptions[3].text == v[1] then
				enableId = v[3]
		    renderDrawBox(self.x + 205, self.y + 90, 315 , 40 , 0x42FFFFFF)
		    self.ebxOptions[v[3]]:draw(self.x + 330, self.y + 97, 185 , 26 , 0x42FFFFFF, 0xFFa8cc7f,0x7AC5C5C5)
		    renderFontDrawText(fonted, v[2], self.x + 268 - (renderGetFontDrawTextLength(fonted, v[2]) / 2), self.y + 104, 0xFFa8cc7f)
			end
    end
		---------------------------------------------------------------------------------------------------------------------------------]]

		for i, v in ipairs(listArgs) do
			if tonumber(self.ebxOptions[v[1]].text) == v[2] and v[1] == enableId then
				renderDrawBox(self.x + 205, self.y + 135, 315 , 40 , 0x42FFFFFF)
				self.ebxOptions[v[4]]:draw(self.x + 330, self.y + 142, 185 , 26 , 0x42FFFFFF, 0xFFa8cc7f,0x7AC5C5C5)
				renderFontDrawText(fonted, v[3], self.x + 268 - (renderGetFontDrawTextLength(fonted, v[3]) / 2), self.y + 149, 0xFFa8cc7f)
				if v[5] then
				  renderDrawBox(self.x + 525, self.y + 135, 315 , 40 , 0x42FFFFFF)
				  self.ebxOptions[v[6]]:draw(self.x + 650, self.y + 142, 185 , 26 , 0x42FFFFFF, 0xFFa8cc7f,0x7AC5C5C5)
				  renderFontDrawText(fonted, v[5], self.x + 587 - (renderGetFontDrawTextLength(fonted, v[5]) / 2), self.y + 149, 0xFFa8cc7f)
			  end
			end
		end

	end

  function public:drawEditWindow()


		self.btnAdd:draw(self.x + 200,self.y + 8,130,14,0x42FFFFFF,0x7AC5C5C5,0x7Aa9a9a9,0xFFa8cc7f)
		local ccl = false
		if EditBoxActive == -1 then
      ccl = not ccl
		end
		self.btnAddAL:draw(self.x + 200,self.y + 24,130,14,0x42FFFFFF,0x7AC5C5C5,0x7Aa9a9a9,0xFFa8cc7f,ccl)
		self.btnRemove:draw(self.x + 333,self.y + 8,60,30,0x42FFFFFF,0x7AC5C5C5,0x7Aa9a9a9,0xFFa8cc7f,ccl)
		renderDrawBox(self.x + 202, self.y + 40+2, 35 , 25 , 0x42FFFFFF)
		renderDrawBox(self.x + 240, self.y + 40+2, 453 , 25 , 0x42FFFFFF)
		renderDrawBox(self.x + 696, self.y + 40+2, 50 , 25 , 0x42FFFFFF)
		renderDrawBox(self.x + 749, self.y + 40+2, 94, 25 , 0x42FFFFFF)
		renderFontDrawText(fonted, "№", self.x + 219 - (renderGetFontDrawTextLength(fonted, "№") / 2), self.y + 46, 0xFFa8cc7f)
		renderFontDrawText(fonted, "Text", self.x + 466 - (renderGetFontDrawTextLength(fonted, "Text") / 2), self.y + 46, 0xFFa8cc7f)
		renderFontDrawText(fonted, "Enter", self.x + 721 - (renderGetFontDrawTextLength(fonted, "Enter") / 2), self.y + 46, 0xFFa8cc7f)
		renderFontDrawText(fonted, "Pause(ms)", self.x + 749 + 94/2 - (renderGetFontDrawTextLength(fonted, "Pause(ms)") / 2), self.y + 46, 0xFFa8cc7f)
    local lPage = self.countLine - 18*(self.currentPageLine-1)
    if lPage > 18 then lPage = 18 end
		if self.countLine ~= 0 then
			for i = 1,lPage do
				renderDrawBox(self.x + 202, self.y + 42+27*i, 35 , 25 , 0x42FFFFFF)
				renderFontDrawText(fonted, i+18*(self.currentPageLine-1), self.x + 219 - (renderGetFontDrawTextLength(fonted, i+18*(self.currentPageLine-1)) / 2), self.y + 46+27*i, 0xFFa8cc7f)
        self.EditBox[i]:draw(self.x + 240, self.y + 42+27*i, 453 , 25 , 0x42FFFFFF, 0xFFa8cc7f,0x7AC5C5C5)
				self.cbxEnter[i]:draw(self.x + 696, self.y + 42+27*i, 50 , 25 , 0x42FFFFFF, 0x42FFFFFF)
        self.ebxPause[i]:draw(self.x + 749, self.y + 42+27*i, 94 , 25 , 0x42FFFFFF, 0xFFa8cc7f,0x7AC5C5C5)
			end
		end
    for i = 1, 10 do
      if self.countLine - 18*(i-1) <= 0 then
        closed = true
      else
        closed = false
      end
        self.btnPageLink[i].param = {public.currentLink,i}
        if i == self.currentPageLine then
          self.btnPageLink[i]:draw(self.x + 400 + 23*(i-1), self.y + 560, 20 , 20,0x92FFFFFF,0x92FFFFFF,0x92FFFFFF,0xFFa8cc7f)
        else
          self.btnPageLink[i]:draw(self.x + 400 + 23*(i-1), self.y + 560, 20 , 20,0x42FFFFFF,0x7AC5C5C5,0x7Aa9a9a9,0xFFa8cc7f,closed)
        end
    end
	end

	function public:drawList()
    local closed;
		renderDrawBox(self.x + 5, self.y + 8, 190 , 62 + (33*15), 0x30FFFFFF)
		renderFontDrawText(fonted, "Tag", self.x + 100 - (renderGetFontDrawTextLength(fonted, "Tag") / 2), self.y + 17, 0xFFc34545)
		self.btnAddLink:draw(self.x + 10, self.y + 12,65,25, 0x42FFFFFF,0x7AC5C5C5,0x7Aa9a9a9,0xFFa8cc7f)
		self.btnRemoveLink:draw(self.x + 125, self.y + 12,65,25, 0x42FFFFFF,0x7AC5C5C5,0x7Aa9a9a9,0xFFa8cc7f)
		local lPage = self.countLink - 15*(self.currentPageLink-1)
		if lPage > 15 then lPage = 15 end
		if self.countLink ~= 0 then
		  for i = 1, lPage do
				if i+15*(self.currentPageLink-1) == self.currentLink then
					self.btnLink[i+15*(self.currentPageLink-1)]:draw(self.x + 5, self.y + 42 + 33*(i-1), 190 , 30, 0x99C0BCBC,0x99C0BCBC,0x99C0BCBC,0xFFa8cc7f)
				else
			    self.btnLink[i+15*(self.currentPageLink-1)]:draw(self.x + 5, self.y + 42 + 33*(i-1), 190 , 30, 0x42FFFFFF,0x7AC5C5C5,0x7Aa9a9a9,0xFFa8cc7f)
				end
		  end
    end
		for i = 1, 8 do
      if self.countLink - 15*(i-1) <= 0 then
        closed = true
      else
        closed = false
      end
			if i == self.currentPageLink then
			  self.btnPage[i]:draw(self.x + 10 + 23*(i-1), self.y + 77 + (33*14), 20 , 20,0x92FFFFFF,0x92FFFFFF,0x92FFFFFF,0xFFa8cc7f)
		  else
			  self.btnPage[i]:draw(self.x + 10 + 23*(i-1), self.y + 77 + (33*14), 20 , 20,0x42FFFFFF,0x7AC5C5C5,0x7Aa9a9a9,0xFFa8cc7f,closed)
			end
		end
	end


	setmetatable(public, self)
  self.__index = self
  openLink({1,1,public})
  return public
end

EditBox = {}
EditBoxActive = -1
EditBox.last = 0
function EditBox:new(id,text,font)

  local public = {}
  public.id = id
  public.text = tostring(text)
  public.font = font
  public.time = 0
  public.currentChar = 0
  public.currentChar2 = 0
  public.offsetLeft = 0
	public.offsetRight = 0
	public.first = true
  function public:draw(x,y,w,h,color,colorText,colorActive)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
		self.fontheiht = renderGetFontDrawHeight(self.font)
		self.text = tostring(self.text)
    self.ty = self.y+self.h/2-renderGetFontDrawHeight(self.font)/2
    if self.first then self:setStartOffset() self.first = false self.currentChar = 0 self.currentChar2 = 0 end
    renderFontDrawText(self.font, string.sub(self.text,1+self.offsetLeft-self.offsetRight,self.text:len()-self.offsetRight), self.x + 5, self.ty, colorText)
    local flags,xp,yp = mh:isKeyPressed(VK_LBUTTON, self.x, self.y, self.w, self.h)
    if flags.isWnd then
      if flags.isPressedWnd then
        if EditBoxActive ~= self.id then
					onEditBoxActiveChange(EditBoxActive,self.id)
          EditBoxActive = self.id
        end
        self.currentChar = self:getChar(xp,yp)
      elseif flags.isDownWnd then
        self.currentChar2 = self:getChar(xp,yp)
      end
    end

    if EditBoxActive == self.id then
      renderDrawBox(self.x,self.y,self.w,self.h,colorActive)
      if self.time >= 25 and self.time < 50 then
        renderDrawBox(self.x+5+ renderGetFontDrawTextLength(self.font, self.text:sub(1+self.offsetLeft-self.offsetRight,self.currentChar)), self.ty, 2,self.fontheiht,0x8F0000FF)
      elseif self.time == 50 then self.time = 0 end
      self.time = self.time+1
      if self.currentChar2 ~= self.currentChar then
        if self.currentChar2 > self.currentChar then
          renderDrawBox(self.x+5+ renderGetFontDrawTextLength(self.font, self.text:sub(1+self.offsetLeft-self.offsetRight,self.currentChar)), self.ty, renderGetFontDrawTextLength(self.font, self.text:sub(self.currentChar+1,self.currentChar2)),self.fontheiht,0x8F0000FF)
        else
          renderDrawBox(self.x+5+ renderGetFontDrawTextLength(self.font, self.text:sub(1+self.offsetLeft-self.offsetRight,self.currentChar2)), self.ty, renderGetFontDrawTextLength(self.font, self.text:sub(self.currentChar2+1,self.currentChar)),self.fontheiht,0x8F0000FF)
        end
      end
    else
      renderDrawBox(self.x,self.y,self.w,self.h,color)
    end
  end

  function public:getChar(x,y)
    cx = x - (self.x+5)
		self.text = tostring(self.text)
		if self.text:len() == nil then return 0 end
    for i = 1, self.text:len() do
      if cx < (renderGetFontDrawTextLength(self.font, self.text:sub(1,i)) - renderGetFontDrawTextLength(self.font, self.text:sub(i,i))/2) then return i-1+self.offsetLeft-self.offsetRight end
    end
    return self.text:len()
  end

  function public:setStartOffset(onlyleft)
    self.offsetRight = 0
		self.offsetLeft = 0
		self.text = tostring(self.text)
		for i=1,self.text:len() do
      if (renderGetFontDrawTextLength(self.font, self.text:sub(1,i)) > self.w - 10 ) then
				self.offsetLeft = self.text:len() - i
        if not onlyleft then self.offsetRight = self.offsetLeft end
  			--sampFuncsLog(self.offsetLeft)
			  break
			end
		end
  end

  function public:SendChar(id)
		if lock then lock = not lock return false end
    local pvtext,pvcr1,pvcr2 = self.text,self.currentChar,self.currentChar2
		if id == 18 then
    elseif id == 8 then
      if self.currentChar2 == self.currentChar then
        if self.currentChar ~= 0 then
          self.text,self.currentChar = ReplaceText(self.text,self.currentChar-1,self.currentChar,"")
          self.currentChar2 = self.currentChar
					if (self.offsetLeft >= 1) then
					  self.offsetLeft = self.offsetLeft - 1
						self.offsetRight = self.offsetRight -1
				  end
				  if (self.offsetRight < 0) then self.offsetRight = 0 end
        end
      else
				local minus = 0
        self.text,self.currentChar,minus = ReplaceText(self.text,self.currentChar,self.currentChar2,"")
				self.offsetLeft = self.offsetLeft - minus
				self.offsetRight = self.offsetRight - minus
				if self.offsetLeft < 0 then self.offsetLeft = 0 end
				if self.offsetRight < 0 then self.offsetRight = 0 end
        self.currentChar2 = self.currentChar
      end
    elseif id == 37 then
			--sampFuncsLog(self.currentChar.."|"..self.offsetRight.."|"..self.offsetLeft )
			if self.currentChar ~= 0 then
				if self.currentChar == self.offsetLeft - self.offsetRight and self.offsetLeft ~= 0 then self.offsetRight = self.offsetRight + 1  end
				self.currentChar = self.currentChar - 1
				self.currentChar2 = self.currentChar
		  end
    elseif id == 39 then
			--sampFuncsLog(self.currentChar.."|"..self.offsetRight.."|"..self.offsetLeft )
      if self.currentChar ~= self.text:len() then
				if self.currentChar == self.text:len() - self.offsetRight and self.offsetRight ~= 0 then self.offsetRight = self.offsetRight - 1  end
        self.currentChar = self.currentChar + 1
        self.currentChar2 = self.currentChar
      end
    else
      if not isKeyDown(0x11) then
        local char = string.char(id)
        if self.currentChar2 == self.currentChar then
					self.text,self.currentChar = ReplaceText(self.text,self.currentChar,self.currentChar2,char)
					self.currentChar2 = self.currentChar
          if (self.x + 5+ renderGetFontDrawTextLength(self.font, string.format("%s%s",self.text,char)) > self.x + self.w - 5 ) then
            self.offsetLeft = self.offsetLeft + 1
          end
        else
					local minus = 0
          self.text,self.currentChar,minus = ReplaceText(self.text,self.currentChar,self.currentChar2,char)
					self.offsetLeft = self.offsetLeft - minus
					self.offsetRight = self.offsetRight - minus
					if self.offsetLeft < 0 then self.offsetLeft = 0 end
					if self.offsetRight < 0 then self.offsetRight = 0 end
					self.currentChar2 = self.currentChar
        end
      else
        if isKeyJustPressed(0x43) then
          if self.currentChar2 ~= self.currentChar then
            if self.currentChar > self.currentChar2 then
              local temp = self.currentChar
              self.currentChar = self.currentChar2
              self.currentChar2 = temp
            end
            setClipboardText(self.text:sub(self.currentChar,self.currentChar2+1))
          end
        elseif isKeyJustPressed(0x56) then
          copytext = getClipboardText()
          local minus;
          self.text,self.currentChar,minus = ReplaceText(self.text,self.currentChar,self.currentChar2,copytext)
					self:setStartOffset(true)
          self.currentChar2 = self.currentChar
        end
      end
    end
    if onTextEdit(self.id,self.text) then self.text,self.currentChar,self.currentChar2 =pvtext,pvcr1,pvcr2 end
  end

  setmetatable(public, self)
  self.__index = self
	table.insert(EditBox,public)
  return EditBox[#EditBox]
end

CheckBox = {}
function CheckBox:new(id,checked,funcOnCheck)
	local public = {}
	public.id = id
	public.checked = checked
	public.OnChangeCheck = funcOnCheck
	function public:draw(x,y,w,h,color,colorCheck)
    self.x = x
		self.y = y
		self.w = w
    self.h = h
		self.clr = color
		self.clrCheck = colorCheck
		local flags = mh:isKeyPressed(VK_LBUTTON, self.x, self.y, self.w, self.h)
		if flags.isWnd == true then
			if flags.isPressedWnd == true then self.checked = not self.checked if self.OnChangeCheck then self.OnChangeCheck(id,checked) end end--0xFF141414 end
		end
		renderDrawBox(self.x, self.y, self.w, self.h, self.clr)
		if self.checked then
			renderDrawBox(self.x+3, self.y+3, self.w-6, self.h-6, self.clrCheck)
		end
	end
	setmetatable(public, self)
	self.__index = self
	return public
end
