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
			sender:iPrintLnBold("^;Useage: !votemap <mapname> ")
			return true
		end

		if votingmap == "empty" then
			local tmp = args[2]
			tmp = getMapCode(tmp)

			if not isEmpty(tmp) then
				if tmp == gsc.getdvar("mapname") then
					sender:iPrintLnBold("^3Warning: The current map is ^2" .. args[2] .. " ^3already!")
					return true;
				end
				voteyes = 1
				votingmap = tmp
				votedplayernum = 1
				votedplayer[0] = sender.name
				sayAll("^;" .. sender.name .. " ^3want change map to ^2" .. args[2])
				sayAll("Say ^4!yes ^7to vote yes,say ^4!no ^7to vote no.")
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
			return true;
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
			return true;
		end
		voteno = voteno + 1
		votedplayer[votedplayernum] = sender.name
		votedplayernum = votedplayernum + 1
		sayAll(string.format("^;Voting %s,^2Yes: %d^7,^1No: %d^7.",votingmap,voteyes,voteno))
	end
end

function help_f(sender,args)
	local i = 1
	for cmd_n,cmd in pairs(commands) do
		sayTo(sender,"Commands on this server:")
		callbacks.afterDelay.add(750 * i,function ()
			sayTo(sender,("^2!%s^3: %s"):format(cmd_n,cmd[1]))
		end)
		i = i + 1
	end
end

function suicide_f(sender,args)
	callbacks.afterDelay.add(1,function() 
		sender:suicide()
	end)
end

-- commands end

-- The command in add command will call as cmd_f(sender,args)
function addCommand(cmd_n,cmd_h,cmd_f)
	commands[cmd_n] = { cmd_h , cmd_f }
end

function InitCmds()
	addCommand("sc","Kill your self", suicide_f )
	addCommand("vm","Vote to change map",votemap_f)
	addCommand("y","Vote yes",voteyes_f)
	addCommand("n","Vote no",voteno_f)
	addCommand("help","Print command list.",help_f)
end

function readConfig()
	if fileExists(configFile) then
		local file = io.open(configFile,"r")
		local jsonstr = file:read("*a")
		print("Config file loaded!")
		config = json.decode(jsonstr)
		timeout = config["timeOut"]
		mapList = config["mapList"]
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
	local num = 1
	for i,player in pairs(users) do
		num = num + 1
	end
	local playerinfo = {}
	playerinfo["name"] = player.name
	playerinfo["guid"] = player:getguid()
	playerinfo["admin"] = 0
	playerinfo["alias"] = ""
	users[num + 1] = playerinfo
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

 function sayTo(player,msg)
	player:tell(consoleName .. msg)
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
	for i,player in pairs(users) do
		if player["name"] == name and player["guid"] == guid and player["admin"] == 1 then
			return true
		end
	end
	return false
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
					cmd[2](args.sender,chunks)
				return true
			end
		end
		args.sender:iPrintLnBold(("^1Error: Invaild Command %s"):format(chunks[1]));
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

function sayAll(message)
	util.chatPrint(consoleName .. message)
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

function onPlayerConnected(player)
	sayAll(("^3Everyone welcome ^2%s^3 join our server!"):format(player.name))
	for i,p in pairs(users) do
		if p["name"] == player.name and p["guid"] == player:getguid() then
			return
		end
	end
	addUser(player)
end

function onLevelNotify(notify)
	print(notify)
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