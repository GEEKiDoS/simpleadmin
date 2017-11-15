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
voteyes = 0
voteno = 0
needTochange = false
needTonotify = false
votedplayer = {}
votedplayernum = 0
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
				voteyes = 1
				votingmap = tmp
				votedplayernum = 1
				votedplayer[0] = sender.name
				sayAll("^;" .. sender.name .. " ^3want change map to ^2" .. args[2])
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
		if isPlayerVoted(sender.name) then
			sender:iPrintLnBold("^1Error: You already voted!")
			return
		end
		voteyes = voteyes + 1
		votedplayer[votedplayernum] = sender.name
		votedplayernum = votedplayernum + 1
		sayAll(string.format("^;Voting %s,^2Yes: %d^7,^1No: %d^7.",votingmap,voteyes,voteno))
	end
end

function voteno_f(sender,args)
	if votingmap ~= "empty" then
		if isPlayerVoted(sender.name) then
			sender:iPrintLnBold("^1Error: You already voted!")
			return
		end
		voteno = voteno + 1
		votedplayer[votedplayernum] = sender.name
		votedplayernum = votedplayernum + 1
		sayAll(string.format("^;Voting %s,^2Yes: %d^7,^1No: %d^7.",votingmap,voteyes,voteno))
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

	for i,player in pairs(users.users) do
		if player["name"] == player.name and player["guid"] == sender:getguid() then
			users.users[i]["alias"] = args[2]
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
-- 	addCommand("wu"			,""								, writeusers_f	)
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

-- users(not working now)

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
		if map["mapName"] == input or map["mapCode"] == input then 
			return map["mapCode"]
		end
	end
	return nil
end

function isAdmin(name,guid)
	if users.users == nil then
		return false
	end

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
-- TODO:alias

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

	-- args.sender:iPrintLnBold(string.format("^;%s",lowerMsg))
	--[[
	if string.sub(chunks[1], 1, 1) == "!" then
		if chunks[1] == "!votemap" then
			if isEmpty(chunks[2]) then
				args.sender:iPrintLnBold("^;Useage: !votemap <mapname> ")
				return true
			end

			if votingmap == "empty" then
				local tmp = chunks[2]
				tmp = getMapCode(tmp)

				if not isEmpty(tmp) then
					if tmp == gsc.getdvar("mapname") then
						args.sender:iPrintLnBold("^3Warning: The current map is ^2" .. chunks[2] .. "^3already!")
						return true;
					end
					voteyes = 1
					votingmap = tmp
					votedplayernum = 1
					votedplayer[0] = args.sender.name
					sayAll("^;" .. args.sender.name .. " ^3want change map to ^2" .. chunks[2])
					sayAll("Say ^4!yes ^7to vote yes,say ^4!no ^7to vote no.")
				else
					args.sender:iPrintLnBold("^1Error: ^2" .. chunks[2] .. " ^1is not a vaild map!")
				end
			else
				args.sender:iPrintLnBold("^1Error: Someone is voting map!")
			end
		elseif chunks[1] == "!yes" then
			if votingmap ~= "empty" then
				if isPlayerVoted(args.sender.name) then
					args.sender:iPrintLnBold("^1Error: You already voted!")
					return true;
				end
				voteyes = voteyes + 1
				votedplayer[votedplayernum] = args.sender.name
				votedplayernum = votedplayernum + 1
				sayAll(string.format("^;Voting %s,^2Yes: %d" .. "^7,^1No: %d^7.",votingmap,voteyes,voteno))
			end
		elseif chunks[1] == "!no" then
			if votingmap ~= "empty" then
				if isPlayerVoted(args.sender.name) then
					args.sender:iPrintLnBold("^1Error: You already voted!")
					return true;
				end
				voteno = voteno + 1
				votedplayer[votedplayernum] = args.sender.name
				votedplayernum = votedplayernum + 1
				sayAll(string.format("^;Voting %s,^2Yes: %d" .. "^7,^1No: %d^7.",votingmap,voteyes,voteno))
			end
		elseif chunks[1] == "!map" then
			if isAdmin(args.sender.name,args.sender:getguid()) then
				if isEmpty(chunks[2]) then
					args.sender:iPrintLnBold("^;Useage: !map <mapname>")
					return true
				end
				local tmp = chunks[2]
				tmp = getMapCode(tmp)

				if not isEmpty(tmp) then
					votingmap = tmp
					needTonotify = true
				else
					args.sender:iPrintLnBold("^1Error: ^2" .. chunks[2] .. " ^1is not a vaild map!")
				end
			else
				args.sender:iPrintLnBold("^1Error: You are not admin!")
				print("Player: " .. args.sender.name .." is trying to change map.GUID:" .. args.sender:getguid())
			end
		end
		return true
	end
	return false
	]]--
end

function isEmpty(s)
  return s == nil or s == ''
end

function checkVote()
	if votingmap ~= "empty" then

		votingtime = votingtime + 1

		if needTonotify then
			needTonotify = false
			needTochange = true
			sayAll("Changing map to ^2" .. votingmap .. "^7...")
		end

		if needTochange then
			local temp = votingmap
			util.executeCommand("map " .. temp)
		end
		if votingtime == timeout then -- timeout
			if voteyes > voteno then
				needTonotify = true
			else
				votingmap = "empty"
				votingtime = 0
			end
		end
	end
end

function isPlayerVoted(player)
	for i= 0, 15 do
   		if votedplayer[i] == player then
		   return true
		end 
	end

	return false
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
	-- print(notify)
	if notify == "connected" then
		callbacks.afterDelay.add(1,function() 
			-- two shit fors
			for p in util.iterPlayers() do
				local isNewplayer = true;
				for guid,player in pairs(players) do
					if p.name == player[1] and p:getguid() == guid then
						isNewplayer = false;
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

-- Callbacks
callbacks.playerSay.add(onPlayerSay)
callbacks.onInterval.add(1000, checkVote)
callbacks.levelNotify.add(onLevelNotify)
callbacks.postGameInit.add(function () 
	readConfig()
	votingmap = "empty"
	votingtime = 0
	needTochange = false
	votedplayer = {}
	InitCmds()
	print("Simple Admin system by GEEKiDoS")
end)

readConfig()
InitCmds()
print("Simple Admin system by GEEKiDoS")