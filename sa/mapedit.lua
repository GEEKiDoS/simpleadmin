-- mapedit
ctp = {}
cfloor = {}
cwall = {}
cramp = {}
cstair = {}
celevator = {}
mapedit = {}

-- commands
function fly_f(sender,args) -- this allows you respawn in the spectator team lel
	if sender.sessionstate == "spectator" then
		sender:allowspectateteam("freelook",false)
		sender.sessionstate = "playing"
	else
		sender:allowspectateteam("freelook",true)
		sender.sessionstate = "spectator"
	end
end

function tp_f(sender,args) -- add a teleport spot
	if ctp["player"] == nil then
		ctp["player"] = sender
		ctp["tpin"] = sender.origin
		sender:iPrintLnBold(("TP Start Set:(%f %f %f)"):format(sender.origin.x,sender.origin.y,sender.origin.z))
	elseif ctp["player"] == sender then
		local item = {}
		item["tpin"] = {}
		item["tpin"]["x"] = ctp["tpin"].x
		item["tpin"]["y"] = ctp["tpin"].y
		item["tpin"]["z"] = ctp["tpin"].z

		item["tpout"] = {}
		item["tpout"]["x"] = sender.origin.x
		item["tpout"]["y"] = sender.origin.y
		item["tpout"]["z"] = sender.origin.z

		addMapedit("tp",item)

		createTP(ctp["tpin"],sender.origin)
		ctp["player"] = nil
		sender:iPrintLnBold(("TP End Set:(%f %f %f)"):format(sender.origin.x,sender.origin.y,sender.origin.z))
	end
end

function wall_f(sender,args) -- create a wall
	if cwall["player"] == nil then
		if isEmpty(args[2]) then
			cwall["type"] = 1
		else
			cwall["type"] = tonumber(args[2])
		end
		cwall["player"] = sender
		cwall["start"] = sender.origin
		sender:iPrintLnBold(("Wall Start Set:(%f %f %f)"):format(sender.origin.x,sender.origin.y,sender.origin.z))
	elseif cwall["player"] == sender then
		local item = {}
		item["startp"] = {}
		item["startp"]["x"] = cwall["start"].x
		item["startp"]["y"] = cwall["start"].y
		item["startp"]["z"] = cwall["start"].z

		item["endp"] = {}
		item["endp"]["x"] = sender.origin.x
		item["endp"]["y"] = sender.origin.y
		item["endp"]["z"] = sender.origin.z

		item["type"] = cwall["type"]

		addMapedit("wall",item)

		spawnWall(cwall["start"],sender.origin,cwall["type"])
		cwall["player"] = nil
		sender:iPrintLnBold(("Wall End Set:(%f %f %f)"):format(sender.origin.x,sender.origin.y,sender.origin.z))
	end
end

function floor_f(sender,args) -- create a floor
	if cfloor["player"] == nil then
		if isEmpty(args[2]) then
			cfloor["type"] = 1
		else
			cfloor["type"] = tonumber(args[2])
		end
		cfloor["player"] = sender
		cfloor["start"] = sender.origin
		sender:iPrintLnBold(("Floor Start Set:(%f %f %f)"):format(sender.origin.x,sender.origin.y,sender.origin.z))
	elseif cfloor["player"] == sender then
		local item = {}
		item["corner1"] = {}
		item["corner1"]["x"] = cfloor["start"].x
		item["corner1"]["y"] = cfloor["start"].y
		item["corner1"]["z"] = cfloor["start"].z

		item["corner2"] = {}
		item["corner2"]["x"] = sender.origin.x
		item["corner2"]["y"] = sender.origin.y
		item["corner2"]["z"] = sender.origin.z

		item["type"] = cfloor["type"]

		addMapedit("floor",item)

		createFloor(cfloor["start"],sender.origin,cfloor["type"])
		cfloor["player"] = nil
		sender:iPrintLnBold(("Floor End Set:(%f %f %f)"):format(sender.origin.x,sender.origin.y,sender.origin.z))
	end
end

function ramp_f(sender,args) -- create a ramp
	if cramp["player"] == nil then
		if isEmpty(args[2]) then
			cramp["type"] = 1
		else
			cramp["type"] = tonumber(args[2])
		end
		cramp["player"] = sender
		cramp["start"] = sender.origin
		sender:iPrintLnBold(("Ramp Start Set:(%f %f %f)"):format(sender.origin.x,sender.origin.y,sender.origin.z))
	elseif cramp["player"] == sender then
		local item = {}
		item["startp"] = {}
		item["startp"]["x"] = cramp["start"].x
		item["startp"]["y"] = cramp["start"].y
		item["startp"]["z"] = cramp["start"].z

		item["endp"] = {}
		item["endp"]["x"] = sender.origin.x
		item["endp"]["y"] = sender.origin.y
		item["endp"]["z"] = sender.origin.z

		item["type"] = cramp["type"]

		addMapedit("ramp",item)

		createRamp(cramp["start"],sender.origin,cramp["type"])
		cramp["player"] = nil
		sender:iPrintLnBold(("Ramp End Set:(%f %f %f)"):format(sender.origin.x,sender.origin.y,sender.origin.z))
	end
end

function stair_f(sender,args) -- create a stair
	if cstair["player"] == nil then
		cstair["player"] = sender
		cstair["start"] = sender.origin
		sender:iPrintLnBold(("Stair Start Set:(%f %f %f)"):format(sender.origin.x,sender.origin.y,sender.origin.z))
	elseif cstair["player"] == sender then
		local item = {}
		item["startp"] = {}
		item["startp"]["x"] = cstair["start"].x
		item["startp"]["y"] = cstair["start"].y
		item["startp"]["z"] = cstair["start"].z

		item["endp"] = {}
		item["endp"]["x"] = sender.origin.x
		item["endp"]["y"] = sender.origin.y
		item["endp"]["z"] = sender.origin.z

		item["type"] = cstair["type"]

		addMapedit("stair",item)

		createStair(cstair["start"],sender.origin,cstair["type"])
		cstair["player"] = nil
		sender:iPrintLnBold(("Stair End Set:(%f %f %f)"):format(sender.origin.x,sender.origin.y,sender.origin.z))
	end
end

function elevator_f(sender,args)
	if celevator["player"] == nil then
		if isEmpty(args[4]) then
			celevator["type"] = 1
		else
			celevator["type"] = tonumber(args[2])
		end

		if isEmpty(args[2]) then
			celevator["time"] = 2
		else
			celevator["time"] = tonumber(args[3])
		end

		if isEmpty(args[3]) then
			celevator["waittime"] = 2
		else
			celevator["waittime"] = tonumber(args[3])
		end

		local point = sender.origin
		point.z = point.z - 10
		celevator["floorstartp"] = point
		sender:iPrintLnBold(("Floor of elevator start:(%f %f %f) Time:%ds Waittime:%ds"):format(sender.origin.x,sender.origin.y,sender.origin.z,celevator["time"],celevator["waittime"]))
		celevator["player"] = sender
	elseif celevator["player"] == sender then
		if celevator["startp"] ~= nil then
			createElevator(celevator["floor"],celevator["time"],celevator["startp"],sender.origin,celevator["waittime"])
			sender:iPrintLnBold(("elevator end:(%f %f %f)"):format(sender.origin.x,sender.origin.y,sender.origin.z))
			celevator["floor"] = nil
			celevator["floorstartp"] = nil
			celevator["player"] = nil
			celevator["startp"] = nil
			return
		end
		if celevator["floorstartp"] ~= nil then
			celevator["floorendp"] = sender.tag_origin
			celevator["startp"] = Vector3.new((celevator["floorstartp"].x + sender.origin.x) / 2,(celevator["floorstartp"].y + sender.origin.y) / 2,(celevator["floorstartp"].z + (sender.origin.z - 10)) / 2)
			celevator["floor"] = createFloorset(celevator["floorstartp"],sender.origin,celevator["type"])
			sender:iPrintLnBold(("Floor of elevator end:(%f %f %f)"):format(sender.origin.x,sender.origin.y,sender.origin.z))
		end
	end
end

function savemapedit_f(sender,args) -- save the map to json file
	writeMapedit()
	sender:iPrintLnBold("Map saved!")
end
-- commands


function addMapedit(type,item)
	if mapedit.mapedit == nil then
        mapedit.mapedit = {}
	end

	if type == "tp" then
		if mapedit.mapedit.tp == nil then
			mapedit.mapedit.tp = {}
		end

		table.insert( mapedit.mapedit.tp , item)
	elseif type == "wall" then
		if mapedit.mapedit.wall == nil then
			mapedit.mapedit.wall = {}
		end

		table.insert( mapedit.mapedit.wall , item)
	elseif type == "floor" then
		if mapedit.mapedit.floor == nil then
			mapedit.mapedit.floor = {}
		end

		table.insert( mapedit.mapedit.floor , item)
	elseif type == "ramp" then
		if mapedit.mapedit.ramp == nil then
			mapedit.mapedit.ramp = {}
		end

		table.insert( mapedit.mapedit.ramp , item)
	elseif type == "stair" then
		if mapedit.mapedit.stair == nil then
			mapedit.mapedit.stair = {}
		end

		table.insert( mapedit.mapedit.stair , item)
	elseif type == "stair" then
		if mapedit.mapedit.stair == nil then
			mapedit.mapedit.stair = {}
		end

		table.insert( mapedit.mapedit.stair , item)
	end
end

function loadMapedit()
	readMapedit()
	
	if mapedit.mapedit == nil then
        return
	end

	if mapedit.mapedit.tp ~= nil then
		for i,item in pairs(mapedit.mapedit.tp) do
			local TPin = Vector3.new(item["tpin"]["x"],item["tpin"]["y"],item["tpin"]["z"])
			local TPout = Vector3.new(item["tpout"]["x"],item["tpout"]["y"],item["tpout"]["z"])
			if item["type"] ~= nil then
				createTP(TPin,TPout,item["type"])
			else
				createTP(TPin,TPout)
			end
		end
	end

	if mapedit.mapedit.wall ~= nil then
		for i,item in pairs(mapedit.mapedit.wall) do
			local startp = Vector3.new(item["startp"]["x"],item["startp"]["y"],item["startp"]["z"])
			local endp = Vector3.new(item["endp"]["x"],item["endp"]["y"],item["endp"]["z"])
			if item["type"] ~= nil then
				spawnWall(startp,endp,item["type"])
			else
				spawnWall(startp,endp)
			end
		end
	end

	if mapedit.mapedit.floor ~= nil then
		for i,item in pairs(mapedit.mapedit.floor) do
			local corner1 = Vector3.new(item["corner1"]["x"],item["corner1"]["y"],item["corner1"]["z"])
			local corner2 = Vector3.new(item["corner2"]["x"],item["corner2"]["y"],item["corner2"]["z"])
			if item["type"] ~= nil then
				createFloor(corner1,corner2,item["type"])
			else
				createFloor(corner1,corner2)
			end
		end
	end

	if mapedit.mapedit.ramp ~= nil then
		for i,item in pairs(mapedit.mapedit.ramp) do
			local startp = Vector3.new(item["startp"]["x"],item["startp"]["y"],item["startp"]["z"])
			local endp = Vector3.new(item["endp"]["x"],item["endp"]["y"],item["endp"]["z"])
			if item["type"] ~= nil then
				createRamp(startp,endp,item["type"])
			else
				createRamp(startp,endp)
			end
		end
	end

	if mapedit.mapedit.stair ~= nil then
		for i,item in pairs(mapedit.mapedit.stair) do
			local startp = Vector3.new(item["startp"]["x"],item["startp"]["y"],item["startp"]["z"])
			local endp = Vector3.new(item["endp"]["x"],item["endp"]["y"],item["endp"]["z"])
			if item["type"] ~= nil then
				createStair(startp,endp,item["type"])
			else
				createStair(startp,endp)
			end
		end
	end

	if mapedit.mapedit.stair ~= nil then
		for i,item in pairs(mapedit.mapedit.stair) do
			local startp = Vector3.new(item["startp"]["x"],item["startp"]["y"],item["startp"]["z"])
			local endp = Vector3.new(item["endp"]["x"],item["endp"]["y"],item["endp"]["z"])
			if item["type"] ~= nil then
				createStair(startp,endp,item["type"])
			else
				createStair(startp,endp)
			end
		end
	end
end

function readMapedit()
	local mapeditfile = ("scripts\\mp\\sa\\mapedit\\%s.json"):format(gsc.getdvar("mapname"))

	if fileExists(mapeditfile) then
		local file = io.open(mapeditfile,"r")
		local jsonstr = file:read("*a")
		mapedit = json.decode(jsonstr)
		file:close()
	end
end

function writeMapedit()
	local mapeditfile = ("scripts\\mp\\sa\\mapedit\\%s.json"):format(gsc.getdvar("mapname"))
	print(mapeditfile)

	local jsonstr = json.encode(mapedit)
	local file = io.open(mapeditfile,"w")
	file:write(jsonstr)
	file:flush()
	file:close()
end

function getAlliesFlagModel()
	local mapname = gsc.getdvar("mapname")

	if mapname == "mp_alpha" or
	mapname ==  "mp_dome" or
	mapname ==  "mp_hardhat" or
	mapname ==  "mp_interchange" or
	mapname ==  "mp_cement" or
	mapname ==  "mp_hillside_ss" or
	mapname ==  "mp_morningwood" or
	mapname ==  "mp_overwatch" or
	mapname ==  "mp_park" or
	mapname ==  "mp_qadeem" or
	mapname ==  "mp_restrepo_ss" or
	mapname ==  "mp_terminal_cls" or
	mapname ==  "mp_roughneck" or
	mapname ==  "mp_boardwalk" or
	mapname ==  "mp_moab" or
	mapname ==  "mp_nola" or
	mapname ==  "mp_radar" or
	mapname ==  "mp_crosswalk_ss" or
	mapname ==  "mp_six_ss" then
		return "prop_flag_delta"
	elseif mapname ==  "mp_exchange" then
		return "prop_flag_american05"
	elseif mapname ==  "mp_bootleg" or
	mapname ==  "mp_bravo" or
	mapname ==  "mp_mogadishu" or
	mapname ==  "mp_village" or
	mapname ==  "mp_shipbreaker" then
		return "prop_flag_pmc"
	elseif mapname ==  "mp_paris" then
		return "prop_flag_gign"
	elseif mapname ==  "mp_plaza2" or
	mapname ==  "mp_aground_ss" or
	mapname ==  "mp_courtyard_ss" or
	mapname ==  "mp_italy" or
	mapname ==  "mp_meteora" or
	mapname ==  "mp_underground" then
		return "prop_flag_sas"
	elseif mapname ==  "mp_seatown" or
	mapname ==  "mp_carbon" or
	mapname ==  "mp_lambeth" then
		return "prop_flag_seal"
	end

	return ""
end

function pow(x,p)
	local ret = x
	for i = 1,p - 1 do
		ret = ret * x
	end

	return ret
end

function distance(a,b)
	return math.sqrt( pow(a.x - b.x, 2) + pow(a.y - b.y, 2) + pow(a.z - b.z, 2))
end

function createTP(tpIn,tpOut)
    local flag = gsc.spawn("script_model",tpIn)
    flag:setModel(getAlliesFlagModel())

    local flaghud = gsc.newHudElem()
    flaghud:setshader(gsc.getdvar("g_TeamIcon_Allies"),20,20)
    flaghud.alpha = 0.6
    flaghud.x = tpIn.x
    flaghud.y = tpIn.y
    flaghud.z = tpIn.z + 100
	flaghud:setwaypoint(true)
	
	callbacks.onInterval.add(100,function ()
		for p in util.iterPlayers() do
			if math.sqrt( pow(tpIn.x - p.origin.x, 2) + pow(tpIn.y - p.origin.y, 2) + pow(tpIn.z - p.origin.z, 2)) < 50 then
				local weapon = p:getCurrentWeapon()
				p:giveWeapon("killstreak_uav_mp")
				p:switchToWeaponImmediate("killstreak_uav_mp")
				callbacks.afterDelay.add(1500,function() 
					p:takeWeapon("killstreak_uav_mp")
					p:switchToWeaponImmediate(weapon)
				end)
				p:setorigin(tpOut)
			end
		end
	end)

	spawnCrate(tpOut,Vector3.new(0,0,0),3,0)
end

function createStair(top, bottom,type)
	type = type or 1

	local distance = distance(top,bottom)
	local blocks = math.ceil(distance / 30)
	local A = Vector3.new((top.x - bottom.x) / blocks, (top.y - bottom.y) / blocks, (top.z - bottom.z) / blocks)
	local temp = gsc.vectortoangles(top - bottom)
	local BA = Vector3.new(temp.z, temp.y + 90, 0 )

	for b = 0,blocks do
		spawnCrate(bottom + (A * b), BA ,type)
	end
end

function createRamp(top, bottom,type)
	type = type or 1
	local distance = distance(top,bottom)
	local blocks = math.ceil(distance / 30)
	local A = Vector3.new((top.x - bottom.x) / blocks, (top.y - bottom.y) / blocks, (top.z - bottom.z) / blocks)
	local temp = gsc.vectortoangles(top - bottom)
	local BA = Vector3.new(temp.z, temp.y + 90, temp.x);
	for b = 0,blocks do
		spawnCrate(bottom + (A * b), BA,type)
	end
end

function moveCrateset(crates,offsets,endp,time)
	for i,crate in pairs(crates) do
		crate:moveto(endp - offsets[i],time)
	end
end

function createElevator(floor,time,startp,endp,waittime)
	local stopTimer = 0
	local dualWaittime = waittime * 2
	local dualtime = time * 2

	local offsets = {}
	for i,crate in pairs(floor) do
		offsets[i] = startp - crate.origin
	end

	callbacks.onInterval.add(1000,function()
		stopTimer = stopTimer + 1
		
		if stopTimer == waittime then
			moveCrateset(floor,offsets,endp,time)
		elseif stopTimer == time + dualWaittime then
			moveCrateset(floor,offsets,startp,time)
		elseif stopTimer == dualtime + dualWaittime then
			stopTimer = 0
		end
	end)
end

function createFloorset(corner1, corner2,type)
	type = type or 1
	local width = corner1.x - corner2.x
	if width < 0 then width = width * -1 end
	local length = corner1.y - corner2.y
	if length < 0 then length = length * -1 end

	local bwide = math.ceil(width / 60)
	local blength = math.ceil(length / 30)
	local C = corner2 - corner1;
	local A = Vector3.new(C.x / bwide, C.y / blength, 0);
	local crates = {}
	for i = 0,bwide - 1 do
		for j = 0, blength - 1 do
			local crate = spawnCrate((corner1 + (Vector3.new(A.x, 0, 0) * i)) + (Vector3.new(0, A.y, 0) * j), Vector3.new(0, 0, 0),type);
			table.insert(crates,crate)
		end
	end
	return crates
end

function createFloor(corner1, corner2,type)
	type = type or 1
	local width = corner1.x - corner2.x
	if width < 0 then width = width * -1 end
	local length = corner1.y - corner2.y
	if length < 0 then length = length * -1 end

	local bwide = math.ceil(width / 60)
	local blength = math.ceil(length / 30)
	local C = corner2 - corner1;
	local A = Vector3.new(C.x / bwide, C.y / blength, 0);
	local center = gsc.spawn("script_origin", Vector3.new((corner1.x + corner2.x) / 2, (corner1.y + corner2.y) / 2, corner1.z));
	for i = 0,bwide - 1 do
		for j = 0, blength - 1 do
			local crate = spawnCrate((corner1 + (Vector3.new(A.x, 0, 0) * i)) + (Vector3.new(0, A.y, 0) * j), Vector3.new(0, 0, 0),type);
			crate:enablelinkto()
			crate:linkto(center)
		end
	end
	return center
end

function spawnWall(startp,endp,type)
	type = type or 1
	local xydist = math.sqrt( pow(startp.x - endp.x, 2) + pow(startp.y - endp.y, 2))
	local zdist = math.abs( startp.z - endp.z ) 
	local numcrateXY = math.ceil(xydist / 60)
	local numcrateZ = math.ceil(zdist / 30)

	local v = endp - startp
	local vector2 = Vector3.new(v.x / numcrateXY,v.y / numcrateXY,v.z / numcrateZ)

	local x = vector2.x / 4
	local y = vector2.y / 4

	local angles = gsc.vectortoangles(v)
	angles = Vector3.new(0,angles.y,90)
	local entity = gsc.spawn("script_origin",Vector3.new((startp.x + endp.x) / 2, (startp.y + endp.y) / 2, (startp.z + endp.z) / 2))
	entity:setContents(1)

	for i = 0, numcrateZ - 1 do
		local entity2 = spawnCrate((startp + Vector3.new(x, y, 10)) + (Vector3.new(0, 0, vector2.z) * i), angles,type)
		entity2:enablelinkto()
		entity2:linkto(entity)
		entity2:setContents(1)
		for j = 0, numcrateXY - 1 do
			entity2 = spawnCrate(((startp + (Vector3.new(vector2.x, vector2.y, 0) * j)) + Vector3.new(0, 0, 10)) + (Vector3.new(0, 0, vector2.z) * i), angles,type);
			entity2:enablelinkto()
			entity2:linkto(entity)
			entity2:setContents(1)
		end

		entity2 = spawnCrate((Vector3.new(endp.x, endp.x, startp.z) + Vector3.new(x * -1, y * -1, 10)) + (Vector3.new(0, 0, vector2.z) * i), angles,type);
		entity2:enablelinkto()
		entity2:linkto(entity)
		entity2:setContents(1)
	end

	return entity;
end

function spawnCrate(origin,angles,type,collision)
	type = type or 1
	collision = collision or 1

	if _airdropCollision == nil then
		if gsc.getdvar("mapname") == "mp_radar" then
			_airdropCollision = gsc.getEnt( "pf3_auto1" , "targetname" )
		else
			_airdropCollision = gsc.getEnt( "pf2_auto1" , "targetname" )
		end
		-- I found it via cheat engine!
	end

	local crate = gsc.spawn("script_model",origin)
	if type == 2 then
		crate:setModel("com_plasticcase_trap_friendly")
	elseif type == 3 then
		crate:setModel("com_plasticcase_trap_bombsquad")
	elseif type == 4 then
		crate:setModel("com_plasticcase_enemy")
	elseif type == 5 then
		crate:setModel("tag_origin")
	else
		crate:setModel("com_plasticcase_friendly")
	end
	crate.angles = angles
	if collision == 1 then
		crate:solid()
		crate:clonebrushmodeltoscriptmodel(_airdropCollision)
	end

	return crate
end

callbacks.postGameInit.add(function () 
	print(gsc.getent("airdrop_crate","targetname"))
end)

loadMapedit()
print("Simple Mapedit by GEEKiDoS")