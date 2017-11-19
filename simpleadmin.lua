-- Simple Admin System --
json = require "json"
configFile = "scripts\\mp\\sa\\config.json"
userFile = "scripts\\mp\\sa\\users.json"
timeout = 10 
mapList = {}
config = {}
users = {}
commands = {}
players = {}
votingmap = "empty"
votingtime = 0
needTochange = false
needTonotify = false
votedplayer = {}
consoleName = "^0[^:Pluto^0]:^7 "

-- commands
function votemap_f(sender,args)
		if isEmpty(args[2]) then
			sender:iPrintLnBold("^;Usage: !vm <mapname> ")
			return
		end

		if votingmap == "empty" then
			local tmp = args[2]:lower()
			tmp = getMapCode(tmp)

			if not isEmpty(tmp) then
				if tmp == gsc.getdvar("mapname") then
					sender:iPrintLnBold("^3Warning: The current map is ^2" .. args[2] .. " ^3already!")
					return
				end
				votingmap = tmp
				votedplayer[sender:getentitynumber()] = "yes" -- luffy's tip
				sayAll("^;" .. sender.name .. " ^3want change map to ^2" .. getMapName(args[2]))
				sayAll("Say ^4!y ^7to vote yes,say ^4!n ^7to vote no.")
			else
				sender:iPrintLnBold("^1Error: ^2" .. args[2] .. " ^1is not a vaild map!")
			end
		else
			sender:iPrintLnBold("^1Error: Someone is voting map!")
		end
end

function voteyes_f(sender,args)
	if votingmap ~= "empty" then
		if votedplayer[sender:getentitynumber()] == "no" then
			sender:iPrintLnBold("^2Changing Your vote to yes...")
		elseif votedplayer[sender:getentitynumber()] == "yes" then
			sender:iPrintLnBold("^3You already voted yes!")
			return
		end
		votedplayer[sender:getentitynumber()] = "yes"
		-- sayAll(string.format("^;Voting %s,^2Yes: %d^7,^1No: %d^7.",votingmap,voteyes,voteno))
	end
end

function voteno_f(sender,args)
	if votingmap ~= "empty" then
		if votedplayer[sender:getentitynumber()] == "yes" then
			sender:iPrintLnBold("^2Changing Your vote to no...")
		elseif votedplayer[sender:getentitynumber()] =="no" then
			sender:iPrintLnBold("^3You already voted no!")
			return
		end
		votedplayer[sender:getentitynumber()] = "no"
		-- sayAll(string.format("^;Voting %s,^2Yes: %d^7,^1No: %d^7.",votingmap,voteyes,voteno))
	end
end

function help_f(sender,args)
	local level = 0
	for i,player in pairs(users.users) do
		if player["name"] == player.name and player["guid"] == sender:getguid() then
			level = player["level"]
		end
	end

	local i = 1
	for cmd_n,cmd in pairs(commands) do
		sayTo(sender,"Commands on this server:")
		if cmd[3] <= level and cmd[3] ~= -1 then
			callbacks.afterDelay.add(750 * i,function ()
				sayTo(sender,("^2!%s^3: %s"):format(cmd_n,cmd[1]))
			end)
			i = i + 1
		end
	end
end

function suicide_f(sender,args)
	callbacks.afterDelay.add(1,function() 
		sender:suicide()
	end)
end

function writeusers_f(sender,args)
	writeUsers()
end

function iamgod_f(sender,args)
	for i,player in pairs(users.users) do
		if player["level"] == 100 then
			sender:iPrintLnBold("^1Error: YOU ARE NOT THE GOD!")
			print(("Warning: %s [Guid:%s] is trying to be a owner"):format(sender.name,sender:getguid()))
			return
		end
	end

	for i,player in pairs(users.users) do
		if player["name"] == player.name and player["guid"] == sender:getguid() then
			sender:iPrintLnBold("^2You are the god now!")
			users.users[i]["level"] = 100
			writeUsers()
		end
	end
end

function setalias_f(sender,args)
	if isEmpty(args[2]) then
		sender:iPrintLnBold("^;Usage: !alias <Your New Alias> ")
		return
	end

	local alias = args[2]
	local i = 3
	while args[i] ~= nil do
		alias = alias .. " " .. args[i]
		i = i + 1
	end

	for i,player in pairs(users.users) do
		if player["name"] == player.name and player["guid"] == sender:getguid() then
			users.users[i]["alias"] = alias
			writeUsers()
		end
	end
end

function setrank_f(sender,args)
	for i,player in pairs(users.users) do
		if player["name"] == sender.name and player["guid"] == sender:getguid() and player["level"] >= 100 then
			if isEmpty(args[2]) or isEmpty(args[3])then
				sender:iPrintLnBold("^;Usage: !setrank <New Rank (0 to 100)> <Player name>")
				return
			end
			local trank = tonumber(args[2])
			print(trank)
			if trank == nil or trank > 100 or trank < 0 then
				sender:iPrintLnBold(("^1Error: %s is not a vaild rank!"):format(args[2]))
				return
			end

			local playername = args[3]
			local i = 4
			while args[i] ~= nil do
				playername = playername .. " " .. args[i]
				i = i + 1
			end

			if playername:lower() == sender.name:lower() then
				sender:iPrintLnBold("^1Error: Target player is yourself!")
				return
			end

			local tplayer = nil
			-- callbacks.afterDelay.add(0,function()
				for player in util.iterPlayers() do
					if player.name:lower() == playername:lower() then
						tplayer = player
					end
				end
			-- end)	

			if tplayer ~= nil then
				for i,player in pairs(users.users) do
					if player["name"]:lower() == playername:lower() and player["guid"] == tplayer:getguid() then
						users.users[i]["level"] = trank
						writeUsers()
						sender:iPrintLnBold(("^;Player %s's rank is set to %s!"):format(player["name"],args[2]))
						sayTo(tplayer,("^2Your rank is %s now!"):format(args[2]))
						return
					end
				end
			end

			sender:iPrintLnBold(("^1Error: Theres are no player called: %s!"):format(playername))
		else
			sender:iPrintLnBold("^1Error: You are not the owner of this server!")
		end
	end
end

function give_f(sender,args)
	if not isAdmin(sender.name,sender:getguid()) then
		sender:iPrintLnBold("^1Error: You are not the admin of this server!")
		return
	end

	if isEmpty(args[2]) then
		sender:iPrintLnBold("^;Usage: !give <weapon> [Player name]")
		return
	end

	if isEmpty(args[3]) then
		sender:giveWeapon(args[2])
		sender:switchToWeaponImmediate(args[2])
	end
end

function testhud_f(sender,args)
	callbacks.afterDelay.add(1,function() 
		local test = CreateServerFontString("objective",1.5)
		SetPoint(test, "topmiddle", "topmiddle", 0, 45, 0)
		test.fontscale = 6
		test.color = Vector3.new(1,1,1)
		test:settext("test")
		test.alpha = 1
	end)
end	
-- commands end

-- The command in add command will call as cmd_f(sender,args)
function addCommand(cmd_n,cmd_h,cmd_f,cmd_l)
	commands[cmd_n] = { cmd_h , cmd_f , cmd_l}
end

function InitCmds()
	---------- CMD_N		CMD_H							CMD_F 				CMD_L ---------
	addCommand("sc"			,"Kill your self"				, suicide_f 		,0 	)
	addCommand("vm"			,"Vote to change map"			, votemap_f			,0 	)
	addCommand("y"			,"Vote yes"						, voteyes_f			,0	)
	addCommand("n"			,"Vote no"						, voteno_f			,0	)
	addCommand("help"		,"Print command list."			, help_f			,0	)
	addCommand("alias"		,"Set your alias"				, setalias_f		,0	)
	addCommand("iamgod"		,"Be a god"						, iamgod_f			,-1	)
	addCommand("setrank"	,"Set a rank of someone."		, setrank_f			,100)
	addCommand("fly"		,"FLY!!!!!"						, fly_f				,-1	)
	addCommand("give"		,"Give weapon"					, give_f			,40 )
--	addCommand("testhud"	,""								, testhud_f			,0	)

	if true then -- there should be a flag to toggle is able to edit map
		addCommand("tp"			,"Add a teleport spot"							, tp_f				,0	)
		addCommand("wall"		,"Create a wall"								, wall_f			,0	)
		addCommand("floor"		,"Create a floor"								, floor_f			,0 )
		addCommand("ramp"		,"Create a ramp"								, ramp_f		,0	)
		addCommand("save"		,"Save the map to json file"					, savemapedit_f		,0	)
	end
end

function readConfig()
	if fileExists(configFile) then
		local file = io.open(configFile,"r")
		local jsonstr = file:read("*a")
		print("Config file loaded!")
		config = json.decode(jsonstr)
		timeout = config["timeOut"]
		mapList = config["mapList"]
		consoleName = config["prefix"]
		file:close()
	else
		local file = io.open(configFile,"w")
		print("Config file not exists...")
		print("Created new config file!")
		local jsonstr = "{\"timeOut\":10,\"prefix\":\"^0[^5GEEK^0]^7: \",\"mapList\":[{\"mapName\":\"lockdown\",\"mapCode\":\"mp_alpha\"},{\"mapName\":\"bootleg\",\"mapCode\":\"mp_bootleg\"},{\"mapName\":\"mission\",\"mapCode\":\"mp_bravo\"},{\"mapName\":\"lockdown\",\"mapCode\":\"mp_alpha\"},{\"mapName\":\"dome\",\"mapCode\":\"mp_dome\"},{\"mapName\":\"downturn\",\"mapCode\":\"mp_exchange\"},{\"mapName\":\"hardhat\",\"mapCode\":\"mp_hardhat\"},{\"mapName\":\"interchange\",\"mapCode\":\"mp_interchange\"},{\"mapName\":\"fallen\",\"mapCode\":\"mp_lambeth\"},{\"mapName\":\"bakaara\",\"mapCode\":\"mp_mogadishu\"},{\"mapName\":\"resistance\",\"mapCode\":\"mp_paris\"},{\"mapName\":\"arkaden\",\"mapCode\":\"mp_plaza2\"},{\"mapName\":\"outpost\",\"mapCode\":\"mp_radar\"},{\"mapName\":\"seatown\",\"mapCode\":\"mp_seatown\"},{\"mapName\":\"underground\",\"mapCode\":\"mp_underground\"},{\"mapName\":\"village\",\"mapCode\":\"mp_village\"}]}"
		file:write(jsonstr)
		file:flush()
		config = json.decode(jsonstr)
		timeout = config["timeOut"]
		mapList = config["mapList"]
		admins = config["admins"]
		consoleName = config["prefix"]
		file:close()
	end

	readUsers()
end

function writeUsers()
	local jsonstr = json.encode(users)
	local file = io.open(userFile,"w")
	file:write(jsonstr)
	file:flush()
	file:close()
end

function readUsers()
	if fileExists(userFile) then
		local file = io.open(userFile,"r")
		local jsonstr = file:read("*a")
		users = json.decode(jsonstr)
		file:close()
	end
end

function addUser(player)
	if users.users == nil then
        users.users = {}
	end
	
	local playerinfo = {}
	playerinfo["name"]		= player.name
	playerinfo["guid"]		= player:getguid()
	playerinfo["level"]		= 0
	playerinfo["alias"] 	= ""
	table.insert( users.users , playerinfo)
end
--

function fileExists(name)
	local f=io.open(name,"r")
	if f~=nil then 
		io.close(f) 
		return true 
	else 
		return false 
	end
 end

function getMapCode(input)
	for i,map in pairs(mapList) do
		if map["mapName"]:lower() == input:lower() or map["mapCode"]:lower() == input:lower() then 
			return map["mapCode"]
		end
	end
	return nil
end

function getMapName(input)
	for i,map in pairs(mapList) do
		if map["mapName"]:lower() == input:lower() or map["mapCode"]:lower() == input:lower() then 
			return map["mapName"]
		end
	end
	return nil
end

function isAdmin(name,guid)
	for i,player in pairs(users.users) do
		if player["name"] == name and player["guid"] == guid and player["level"] > 40 then
			return true
		end
	end
	return false
end

function getAlias(name,guid)
	for i,player in pairs(users.users) do
		if player["name"] == name and player["guid"] == guid and player["alias"] ~= "" then
			return player["alias"]
		end
	end

	return nil
end

function sayAs(name,msg)
	util.chatPrint(("%s^7: %s"):format(name,msg))
end

function sayAll(message)
	util.chatPrint(consoleName .. message)
end

function sayTo(player,msg)
	player:tell(consoleName .. msg)
 end

function onPlayerSay(args)
	local lowerMsg = args.message:lower()
	local chunks = lowerMsg:split(" ")

	if string.sub(chunks[1],1,1) == "!" then
		local cmd_n = string.sub(chunks[1],2,string.len( chunks[1] ))
		-- print(cmd_n)
		for cmd_nt,cmd in pairs(commands) do
			-- print(cmd_nt)
			if cmd_nt == cmd_n then
					cmd[2](args.sender,args.message:split(" "))
				return true
			end
		end
		args.sender:iPrintLnBold(("^1Error: Invaild Command %s"):format(chunks[1]));
		return true
	end

	local alias = getAlias(args.sender.name,args.sender:getguid())
	if alias ~= nil then
		sayAs(alias,args.message)
		return true
	end

	return false
end

function isEmpty(s)
  return s == nil or s == ''
end

-- HudElem
function CreateServerFontString(font, fontScale)
	local elem 
	elem = gsc.newHudElem()
	elem.font = font
	elem.fontscale = fontScale
	elem.x = 0
	elem.y = 0
	elem.height = 12 * tonumber(fontScale)
	return elem
end

function CreateFontString(player,font, fontScale)
	local elem 
	elem = gsc.NewClientHudElem(player)
	elem.font = font
	elem.fontscale = fontScale
	elem.x = 0
	elem.y = 0
	elem.height = 12 * tonumber(fontScale)
	return elem
end

function SetPoint(elem, point, relativePoint, xOffset, yOffset, moveTime)
	point = point:lower()
	relativePoint = relativePoint:lower()

	if (moveTime > 0) then
		elem:moveovertime(moveTime)
	end

	local AlignX = "center"
	local AlignY = "middle"
	if string.match(point,"top") then
		local AlignY = "top"
	end
	if string.match(point,"bottom") then
		local AlignY = "bottom"
	end
	if string.match(point, "left") then
		local AlignX = "left"
	end
	if string.match(point,"right") then
		local AlignX = "right"
	end
	local relativeX
	relativeX = "center_adjustable"
	local relativeY
	relativeY = "middle"
	if string.match(relativePoint, "top") then
		relativeY = "top_adjustable"
	end
	if string.match(relativePoint,"bottom") then
		relativeY = "bottom_adjustable"
	end
	if string.match(relativePoint, "left") then
		relativeX = "left_adjustable"
	end
	if string.match(relativePoint, "right") then
		relativeX = "right_adjustable"
	end

	elem.horzalign = relativeX
	elem.vertalign = relativeY

	local xFactor
	xFactor = 0
	local yFactor
	yFactor = 0
	local offsetX
	offsetX = 0
	local offsetY
	offsetY = 0

	if relativeX == "center" then
		offsetX = 320
		if relativeX == "left_adjustable" then
			xFactor = -1
		else
			xFactor = 1
		end;
	else
		offsetX = 640
		if relativeX == "left_adjustable" then
			xFactor = -1;
		else
			xFactor = 1;
		end;
	end;
	elem.x = offsetX * xFactor;

	if relativeY == "middle" then
		offsetY = 240
		if relativeY == "top_adjustable" then
			yFactor = -1
		else
			yFactor = 1
		end
	else
		offsetY = 480
		if relativeY == "top_adjustable" then
			yFactor = -1;
		else
			yFactor = 1;
		end;
	end
	elem.Y = offsetY * yFactor

	elem.X = elem.X + xOffset
	elem.Y = elem.Y + yOffset;
end

function ChangeFontScaleOverTime(elem, time, endScale)
	elem:changefontscaleovertime(time)
	elem.fontscale = endScale
end
-- HudElem End --

function checkVote()
	if votingmap ~= "empty" then

		votingtime = votingtime + 2

		if needTonotify then
			needTonotify = false
			needTochange = true
			sayAll("Changing map to ^2" .. getMapName(votingmap) .. "^7...")
		end

		if needTochange then
			local temp = votingmap
			util.executeCommand("map " .. temp)
		end
		if votingtime >= timeout then -- timeout
			local voteyes = 0
			local voteno = 0

			for i,ticket in pairs(votedplayer) do
				if ticket == "yes" then 
					voteyes = voteyes + 1
				else
					voteno = voteno + 1
				end
			end

			if voteyes > voteno then
				needTonotify = true
			else
				votingmap = "empty"
				votingtime = 0
			end
		end
	end
end

-- TODO:HUD
function onPlayerConnected(p)
	callbacks.afterDelay.add(1,function() 
		p:setclientdvar("ui_mapname","^1test")
	end)
	for i,player in pairs(users.users) do
		if player["name"] == p.name and player["guid"] == p:getguid() then
			if player["level"] > 40 then
				sayAll(("^3Welcome back,admin! ^2%s"):format(p.name))
			elseif player["level"] < 0 then
				util.executeCommand(string.format("kickclient %i \"%s\"", p:getentitynumber(), "^1You are banned from our server!"))  
			else
				sayAll(("^3Welcome back! ^2%s"):format(p.name))
			end
			return
		end
	end
	sayAll(("^3Everyone welcome ^2%s^3 join our server!"):format(p.name))
	addUser(player)
end

function onLevelNotify(notify)
	print(notify)
	if notify == "connected" then
		callbacks.afterDelay.add(1,function() 
			-- two shit fors
			for p in util.iterPlayers() do
				local isNewplayer = true
				for guid,player in pairs(players) do
					if p.name == player[1] and p:getguid() == guid then
						isNewplayer = false
					end
				end 
				if isNewplayer then
					players[p:getguid()] = { p.name }
					onPlayerConnected(p)
				end
			end
		end)
	elseif notify == "game_ended" then
		writeUsers()
	end
end

-- if player leaves the server then remove him form player list
function checkPlayers()
	for guid,player in pairs(players) do
		local leaved = true
		for p in util.iterPlayers() do
			if p.name == player[1] and p:getguid() == guid then
				leaved = false
			end
		end

		if leaved then -- player is not on this server,remove him then
			players[guid] = nil
		end
	end 
end

-- Callbacks
callbacks.playerSay.add(onPlayerSay)
callbacks.onInterval.add(2000, checkVote)
callbacks.onInterval.add(5000, checkPlayers)
callbacks.levelNotify.add(onLevelNotify)

callbacks.postGameInit.add(function () 
	util.executeCommand("unloadscript simpleadmin;loadscript simpleadmin") -- reload script when loaded a new map
end)

readConfig()
votingmap = "empty"
votingtime = 0
needTochange = false
votedplayer = {}

-- load mapedit
require "scripts.mp.sa.mapedit"

InitCmds()
print("Simple Admin system by GEEKiDoS")