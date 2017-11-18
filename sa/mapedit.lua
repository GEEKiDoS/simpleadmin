-- mapedit
ctp = {}
cwall = {}
mapedit = {}

-- commands
function fly_f(sender,args)
	if sender.sessionstate == "spectator" then
		sender:allowspectateteam("freelook",false)
		sender.sessionstate = "playing"
	else
		sender:allowspectateteam("freelook",true)
		sender.sessionstate = "spectator"
	end
end

function tp_f(sender,args)
	if ctp["player"] == nil then
		ctp["player"] = sender
		ctp["tpin"] = sender.origin
		sender:iPrintLnBold("TP Start Set:" .. sender.origin)
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
		sender:iPrintLnBold("TP End Set:" .. sender.origin)
	end
end

function wall_f(sender,args)
	if cwall["player"] == nil then
		cwall["player"] = sender
		print(sender.origin)
		cwall["start"] = sender.origin
		sender:iPrintLnBold("Wall Start Set:" .. sender.origin)
	elseif cwall["player"] == sender then
		spawnWall(cwall["start"],sender.origin)
		cwall["player"] = nil
		sender:iPrintLnBold("Wall End Set:" .. sender.origin)
	end
end

function savemapedit_f(sender,args)
	writeMapedit()
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
	end
end

function loadMapedit()
	readMapedit()
	
	if mapedit.mapedit == nil then
        return
	end

	for i,item in pairs(mapedit.mapedit.tp) do
		local TPin = Vector3.new(item["tpin"]["x"],item["tpin"]["y"],item["tpin"]["z"])
		local TPout = Vector3.new(item["tpout"]["x"],item["tpout"]["y"],item["tpout"]["z"])
		createTP(TPin,TPout)
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
				p:setorigin(tpOut)
			end
		end
	end)

	spawnCrate(tpOut,Vector3.new(0,0,0))
end

function spawnWall(startp,endp)
	local xydist = math.sqrt( pow(startp.x - endp.x, 2) + pow(startp.y - endp.y, 2))
	local zdist = math.abs( startp.z - endp.z ) 
	local numcrateXY = math.ceil(xydist / 55)
	local numcrateZ = math.ceil(zdist / 30)

	local v = endp - startp
	local vector2 = Vector3.new(v.x / numcrateXY,v.y / numcrateXY,v.z / numcrateZ)

	local x = vector2.x / 4
	local y = vector2.y / 4

	local angles = gsc.vectortoangles(v)
	angles = Vector3.new(0,angles.y,90)
	local entity = gsc.spawn("script_origin",Vector3.new((startp.x + endp.x) / 2, (startp.y + endp.y) / 2, (startp.z + endp.z) / 2))

	for i = 0, numcrateZ - 1 do
		local entity2 = spawnCrate((startp + Vector3.new(x, y, 10)) + (Vector3.new(0, 0, vector2.z) * i), angles)
		entity2:enablelinkto()
		entity2:linkto(entity)
		for j = 0, numcrateXY - 1 do
			entity2 = spawnCrate(((startp + (Vector3.new(vector2.x, vector2.y, 0) * j)) + Vector3.new(0, 0, 10)) + (Vector3.new(0, 0, vector2.z) * i), angles);
			entity2:enablelinkto()
			entity2:linkto(entity)
		end

		entity2 = spawnCrate((Vector3.new(endp.x, endp.x, startp.z) + Vector3.new(x * -1, y * -1, 10)) + (Vector3.new(0, 0, vector2.z) * i), angles);
		entity2:enablelinkto()
		entity2:linkto(entity)
	end

	return entity;
end

function spawnCrate(origin,angles)
	--[[
	if _airdropCollision == nil then
		local airDropCrates = gsc.getEntArray( "care_package", "targetname" );
		local oldAirDropCrates = gsc.getEntArray( "airdrop_crate", "targetname" );
		if #airDropCrates then
			_airdropCollision = gsc.EntArray( airDropCrates[1].target, "targetname" )
		else
			_airdropCollision = gsc.EntArray( oldAirDropCrates[1].target, "targetname" )
		end
	end]]

	local crate = gsc.spawn("script_model",origin)
	crate:setModel("com_plasticcase_friendly")
	crate.angles = angles
	crate:solid()
	-- crate:clonebrushmodeltoscriptmodel(_airdropCollision)

	return crate
end

loadMapedit()
print("Simple Mapedit by GEEKiDoS")