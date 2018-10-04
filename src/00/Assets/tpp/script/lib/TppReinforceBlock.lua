--TUPPM Header

--not present in p1080

local this={}
local GetGameObjectId=GameObject.GetGameObjectId
local GetTypeIndex=GameObject.GetTypeIndex
local SendCommand=GameObject.SendCommand
local NULL_ID=GameObject.NULL_ID

--K all changes in this file have been with the hope of spawing 12 reinforcement soldiers. It does not work.

this.REINFORCE_TYPE_NAME={"NONE","EAST_WAV","EAST_WAV_ROCKET","WEST_WAV","WEST_WAV_CANNON","EAST_TANK","WEST_TANK","HELI"}
this.REINFORCE_TYPE=TppDefine.Enum(this.REINFORCE_TYPE_NAME)
this.REINFORCE_FPK={
	[this.REINFORCE_TYPE.NONE]="",
	[this.REINFORCE_TYPE.EAST_WAV]="/Assets/tpp/pack/soldier/reinforce/reinforce_veh_east_wav.fpk",
	[this.REINFORCE_TYPE.EAST_WAV_ROCKET]="/Assets/tpp/pack/soldier/reinforce/reinforce_veh_east_wav_roc.fpk",
	[this.REINFORCE_TYPE.WEST_WAV]={
		PF_A="/Assets/tpp/pack/soldier/reinforce/reinforce_veh_west_wav_a.fpk",
		PF_B="/Assets/tpp/pack/soldier/reinforce/reinforce_veh_west_wav_b.fpk",
		PF_C="/Assets/tpp/pack/soldier/reinforce/reinforce_veh_west_wav_c.fpk"
	},
	[this.REINFORCE_TYPE.WEST_WAV_CANNON]={
		PF_A="/Assets/tpp/pack/soldier/reinforce/reinforce_veh_west_wav_can_a.fpk",
		PF_B="/Assets/tpp/pack/soldier/reinforce/reinforce_veh_west_wav_can_b.fpk",
		PF_C="/Assets/tpp/pack/soldier/reinforce/reinforce_veh_west_wav_can_c.fpk"
	},
	[this.REINFORCE_TYPE.EAST_TANK]="/Assets/tpp/pack/soldier/reinforce/reinforce_veh_east_tnk.fpk",
	[this.REINFORCE_TYPE.WEST_TANK]={
		PF_A="/Assets/tpp/pack/soldier/reinforce/reinforce_veh_west_tnk_a.fpk",
		PF_B="/Assets/tpp/pack/soldier/reinforce/reinforce_veh_west_tnk_b.fpk",
		PF_C="/Assets/tpp/pack/soldier/reinforce/reinforce_veh_west_tnk_c.fpk"
	},
	[this.REINFORCE_TYPE.HELI]={
		AFGH={
			_DEFAULT="/Assets/tpp/pack/soldier/reinforce/reinforce_heli_afgh.fpk",
			[TppDefine.ENEMY_HELI_COLORING_TYPE.BLACK]={
				"/Assets/tpp/pack/soldier/reinforce/reinforce_heli_afgh.fpk",
				"/Assets/tpp/pack/fova/mecha/sbh/sbh_ene_blk.fpk"
			},
			[TppDefine.ENEMY_HELI_COLORING_TYPE.RED]={
				"/Assets/tpp/pack/soldier/reinforce/reinforce_heli_afgh.fpk",
				"/Assets/tpp/pack/fova/mecha/sbh/sbh_ene_red.fpk"
			}
		},
		MAFR={
			_DEFAULT="/Assets/tpp/pack/soldier/reinforce/reinforce_heli_mafr.fpk",
			[TppDefine.ENEMY_HELI_COLORING_TYPE.BLACK]={
				"/Assets/tpp/pack/soldier/reinforce/reinforce_heli_mafr.fpk",
				"/Assets/tpp/pack/fova/mecha/sbh/sbh_ene_blk.fpk"},
			[TppDefine.ENEMY_HELI_COLORING_TYPE.RED]={
				"/Assets/tpp/pack/soldier/reinforce/reinforce_heli_mafr.fpk",
				"/Assets/tpp/pack/fova/mecha/sbh/sbh_ene_red.fpk"}
		}
	}
}
this.REINFORCE_VEHICLE_NAME="reinforce_vehicle_0000"this.REINFORCE_DRIVER_SOLDIER_NAME="reinforce_soldier_driver"

--K Makes no difference, tried increasing reinforcement soldiers table. Makes no difference. Sequential numbering after 0003, 0004, 0005 etc also does not work.
this.REINFORCE_SOLDIER_NAMES={
	"reinforce_soldier_0000",
	"reinforce_soldier_0001",
	"reinforce_soldier_0002",
	"reinforce_soldier_0003"
}

this.REINFORCE_HELI_NAME="EnemyHeli"
function this.GetReinforceBlockId()
	return ScriptBlock.GetScriptBlockId(mvars.reinforce_reinforceBlockName)
end

function this.GetReinforceBlockState()
	return ScriptBlock.GetScriptBlockState(this.GetReinforceBlockId())
end

function this.IsLoaded()
	return this.GetReinforceBlockState()==ScriptBlock.SCRIPT_BLOCK_STATE_EMPTY
end

function this.IsProcessing()
	return this.GetReinforceBlockState()==ScriptBlock.SCRIPT_BLOCK_STATE_PROCESSING
end

function this.GetFpk(reinforceTypeValue,cpSubType,reinforceTypeColoring)
	local e=this.REINFORCE_FPK[reinforceTypeValue]
	if Tpp.IsTypeTable(e)then
		local r=""if TppLocation.IsAfghan()then
			r="AFGH"elseif TppLocation.IsMiddleAfrica()then
			r="MAFR"end
		local r=e[cpSubType]or e[r]
		if Tpp.IsTypeTable(r)then
			reinforceTypeColoring=reinforceTypeColoring or"_DEFAULT"if r[reinforceTypeColoring]then
				r=r[reinforceTypeColoring]
			else
				r=nil
			end
		end
		if r then
			e=r
		else
			local r=""for i,n in pairs(e)do
				if r==""then
					r=n
				end
			end
			e=r
		end
	end
	if not e then
		return""end
	return e
end

function this.SetUpReinforceBlock()
	--    TppUiCommand.AnnounceLogView("SetUpReinforceBlock") --Step 1; Freeroam Step 1
	mvars.reinforce_reinforceBlockName="reinforce_block"local n=false
	local i=this.GetReinforceBlockId()n=(i~=ScriptBlock.SCRIPT_BLOCK_ID_INVALID)
	mvars.reinforce_hasReinforceBlock=n
	if not mvars.reinforce_hasReinforceBlock then
		return
	end
	for n,r in ipairs(this.REINFORCE_SOLDIER_NAMES)do
		this._SetEnabledSoldier(r,false)
	end
	this._SetEnabledVehicle(this.REINFORCE_VEHICLE_NAME,false)
	mvars.reinforce_reinforceType=this.REINFORCE_TYPE.NONE
	mvars.reinforce_reinforceColoringType=nil
	mvars.reinforce_reinforceCpId=NULL_ID
	mvars.reinforce_activated=false
end

--K Reinforcements are called through the following series of steps:
-- 1. e._OnRequestLoadReinforce(i)
-- 2. e.LoadReinforceBlock(i,o,t)
-- 3. _OnRequestAppearReinforce(r)
-- 4. e.StartReinforce(n)
-- 5. e.ReinforceBlockOnActivate()
-- 6.e._ActivateReinforce()

--These six steps are followed only the very FIRST reinforcements are called

-- After this the following steps are used:
-- 1. e._OnRequestLoadReinforce(i)
-- 2. e.LoadReinforceBlock(i,o,t)

-- This is because LoadReinforceBlock(i,o,t) simply returns based on starting conditions in the function and reinforcements are called once _OnRequestLoadReinforce(i) has completed execution by the *game ENGINE*. So, as far as I know there is no legit way to spawn more than 4 soldiers at once.

--r24 flag to mark first reinforcements and be done with it
--r27 Better auto marking code
--this.areFirstReinforcements = false
function this.LoadReinforceBlock(selectedReinforceVehicle,reinforceCpIdValue,reinforceTypeColoring)
	--    TppUiCommand.AnnounceLogView("LoadReinforceBlock") --K Step 3/Repeat Step 2; Freeroam Step 3

	--r24 Added a check here to set the flag to false but it works just fine from TppMain.AutoMarkFirstReinforcements()
	--  if this.areFirstReinforcements then
	--    --TUPPMLog.Log("Are not first reinforcements; first time you see this message, it will be wrong")
	--    this.areFirstReinforcements=false
	--  end

	--  TppMain.AutoMarkReinforcements() --TODO r24
	--  TppMain.reinforceAnnounceShowOnce=true --TODO r24
	-- Add a reinforceSoldiersCount AND check in below three conditions if using, and resetting it to 1
	if mvars.reinforce_activated then
		--TppUiCommand.AnnounceLogView("if mvars.reinforce_activated then")
		return
	end

	if mvars.reinforce_reinforceCpId~=NULL_ID and mvars.reinforce_reinforceCpId~=reinforceCpIdValue then
		--TppUiCommand.AnnounceLogView("if mvars.reinforce_reinforceCpId~=r and mvars.reinforce_reinforceCpId~=o then")
		return
	end

	if not mvars.reinforce_hasReinforceBlock then
		--TppUiCommand.AnnounceLogView("if not mvars.reinforce_hasReinforceBlock then")
		return
	end


	--K return if Heli already present
	-- Below code is used to return in case a Helicopter exists. However, commenting the same does not spawn another Heli
	-- Only one Heli spawns per reinforcement call
	--K r08 Bug fix, Sideops with Grey Super Vehicles breaking as Black Super Heli not spawned, if below code is commented
	--This controls sideop SUPER heli spawning specifically. Normal sideops Helis spawn just fine.

	--r28 Was incorrect code; fuck this, this breaks auto marking code
	--  if vars.missionCode==30010 or vars.missionCode==30020 then --K This check enables Super Vehicles for certain missions along with other changes.
	if selectedReinforceVehicle==this.REINFORCE_TYPE.HELI and GameObject.DoesGameObjectExistWithTypeName"TppEnemyHeli"then
		-- TppUiCommand.AnnounceLogView("REINFORCE_TYPE.HELI so returning")
		return
	end
	--  end

	local reinforceBlockId=this.GetReinforceBlockId()
	local cpSubType=TppEnemy.GetCpSubType(mvars.reinforce_cpId)
	local fpkFile=this.GetFpk(selectedReinforceVehicle,cpSubType,reinforceTypeColoring)

	if fpkFile==nil then
		selectedReinforceVehicle=this.REINFORCE_TYPE.NONE
		fpkFile=""
	end

	ScriptBlock.Load(reinforceBlockId,fpkFile)
	mvars.reinforce_reinforceType=selectedReinforceVehicle --K First Heli call, commenting this line stops heli spawn
	mvars.reinforce_reinforceColoringType=reinforceTypeColoring

	if selectedReinforceVehicle~=this.REINFORCE_TYPE.NONE then
		SendCommand({type="TppCommandPost2"},{id="SetReinforceEnable"})
		mvars.reinforce_reinforceCpId=reinforceCpIdValue
		local hasVehicle=this._HasVehicle()
		local hasSoldier=this._HasSoldier()
		local vehicleId,driverId
		local reinforcementIds={}

		if hasSoldier then
			for index,soldierName in ipairs(this.REINFORCE_SOLDIER_NAMES)do
				reinforcementIds[index]=GameObject.GetGameObjectId("TppSoldier2",soldierName)
			end --Iterate soldier names, but why not spawn 12? Because "SetNominateList" can only hold 4 soldiers
		end

		if hasVehicle then
			vehicleId=GameObject.GetGameObjectId("TppVehicle2",this.REINFORCE_VEHICLE_NAME)
			driverId=GameObject.GetGameObjectId("TppSoldier2",this.REINFORCE_DRIVER_SOLDIER_NAME)
		end

		--TODO r23 reinforcements did change; disable return logic above and change reinforcements for engine calls as well
		--    local deadSoldiersSociety = {}
		--    if mvars.ene_soldierDefine then
		--        for _, soldierName in pairs( mvars.ene_soldierDefine[mvars.trm_currentIntelCpName] ) do
		--          local gameObjectId = GameObject.GetGameObjectId(soldierName)
		--          if gameObjectId ~= GameObject.NULL_ID
		--            and TppEnemy.IsEliminated(gameObjectId)
		--            then
		--              TUPPMLog.Log("SolId: "..tostring(gameObjectId)..", SolName: "..tostring(soldierName))
		--              table.insert(deadSoldiersSociety,gameObjectId)
		--          end
		--        end
		--    end

		SendCommand({type="TppCommandPost2"},
			{id="SetNominateList",
				driver=driverId,
				vehicle=vehicleId,

				--                  sol01=deadSoldiersSociety[1],
				--                  sol02=deadSoldiersSociety[2],
				--                  sol03=deadSoldiersSociety[3],
				--                  sol04=deadSoldiersSociety[4],
				--                  sol05=reinforcementIds[1],
				--                  sol06=reinforcementIds[2],
				--                  sol07=reinforcementIds[3],
				--                  sol08=reinforcementIds[4]

				sol01=reinforcementIds[1],
				sol02=reinforcementIds[2],
				sol03=reinforcementIds[3],
				sol04=reinforcementIds[4]
			}
		)
		--TODO WIP
		--    TppMain.AutoMarkReinforcements()
	else
		mvars.reinforce_reinforceCpId=NULL_ID
	end
end

function this.UnloadReinforceBlock(n)
	--  TppUiCommand.AnnounceLogView("UnloadReinforceBlock")
	if not mvars.reinforce_hasReinforceBlock then
		return
	end
	if((n~=nil and n~=NULL_ID)and mvars.reinforce_reinforceCpId~=NULL_ID)and mvars.reinforce_reinforceCpId~=n then
		return
	end
	local n=this.GetReinforceBlockId()
	if this.GetReinforceBlockState()>ScriptBlock.SCRIPT_BLOCK_STATE_INACTIVE then
		this.ReinforceBlockOnDeactivate()
		-- e.ReinforceBlockOnActivate() --K nope, don't even bother - no reinforcements spawn at all
	end
	ScriptBlock.Load(n,"")
	mvars.reinforce_reinforceType=this.REINFORCE_TYPE.NONE
	mvars.reinforce_reinforceColoringType=nil
	mvars.reinforce_reinforceCpId=NULL_ID
end

function this.StartReinforce(n)
	--    TppUiCommand.AnnounceLogView("StartReinforce") --K Step 6

	if not mvars.reinforce_hasReinforceBlock then
		return
	end

	if mvars.reinforce_reinforceType==this.REINFORCE_TYPE.NONE then
		return
	end

	if(n~=nil and n~=NULL_ID)and mvars.reinforce_reinforceCpId~=n then
		return
	end

	--TppUiCommand.AnnounceLogView("Before Activate")
	local e=this.GetReinforceBlockId()
	--TppUiCommand.AnnounceLogView("e.GetReinforceBlockId() "..e)
	--TppUiCommand.AnnounceLogView("e.GetReinforceBlockId() "..tostring(e))
	ScriptBlock.Activate(e)
	mvars.reinforce_activated=true
	--TppUiCommand.AnnounceLogView("After Activate")
	--TUPPMLog.Log("Activated reinforcements")
	--  TppMain.AutoMarkReinforcements() --TODO r24
end

function this.FinishReinforce(n)
	--  TppUiCommand.AnnounceLogView("FinishReinforce")
	if not mvars.reinforce_hasReinforceBlock then
		return
	end
	if(n~=nil and n~=NULL_ID)and mvars.reinforce_reinforceCpId~=n then
		return
	end
	local e=this.GetReinforceBlockId()ScriptBlock.Deactivate(e)
	mvars.reinforce_activated=false
	mvars.reinforce_reinforceCpId=NULL_ID
	--  TppMain.AutoMarkReinforcements() --TODO r24
end

function this.ReinforceBlockOnInitialize()
	--    TppUiCommand.AnnounceLogView("ReinforceBlockOnInitialize") --Step 4
	mvars.reinforce_lastReinforceBlockState=this.GetReinforceBlockState()
	mvars.reinforce_isEnabledVehicle=false
	mvars.reinforce_isEnabledSoldiers=false
end

--Maybe this is it? Some logic here may help
function this.ReinforceBlockOnUpdate()
	--  TppUiCommand.AnnounceLogView("ReinforceBlockOnUpdate") --Called forever during missions
	--r27 Better auto marking code
	--  if this.areFirstReinforcements then
	--    TppMain.AutoMarkFirstReinforcements() --r24 Works; flag is set false after marking; OLD Comment: Not a good approach. Only used in missions and not in free roam
	--  end
	local reinforceState=this.GetReinforceBlockState()
	if reinforceState==nil then
		return
	end
	local ScriptBlock=ScriptBlock
	local mvars=mvars
	local lastReinforceBlockState=mvars.reinforce_lastReinforceBlockState
	local inactive=ScriptBlock.SCRIPT_BLOCK_STATE_INACTIVE
	local active=ScriptBlock.SCRIPT_BLOCK_STATE_ACTIVE
	if reinforceState==inactive then
		if lastReinforceBlockState==active then
			this.ReinforceBlockOnDeactivate()
			-- e.ReinforceBlockOnActivate() --test but probably not
		end
		mvars.reinforce_lastReinforceInactiveToActive=false
	elseif reinforceState==active then
		--    TppMain.AutoMarkReinforcements() --TODO r24
		if mvars.reinforce_lastReinforceInactiveToActive then
			mvars.reinforce_lastReinforceInactiveToActive=false
			this.ReinforceBlockOnActivate()
		end
		if(not lastReinforceBlockState)or lastReinforceBlockState<=inactive then
			mvars.reinforce_lastReinforceInactiveToActive=true
		end
	end
	mvars.reinforce_lastReinforceBlockState=reinforceState
end

function this.ReinforceBlockOnActivate()
	--    TppUiCommand.AnnounceLogView("ReinforceBlockOnActivate") --K Step 7
	this._ActivateReinforce()
	--  TppMain.AutoMarkReinforcements() --TODO r24
end

function this.ReinforceBlockOnDeactivate()
	--  TppUiCommand.AnnounceLogView("ReinforceBlockOnDeactivate")
	this._DeactivateReinforce()
end

function this.ReinforceBlockOnTerminate()
--TppUiCommand.AnnounceLogView("ReinforceBlockOnTerminate")
end

function this._HasSoldier()
	--TODO REVISE r28 Do not spawn soldiers with helis in M35; causes problems I think
	--Completely removes reinforcements I think
	--  if vars.missionCode==10093 and mvars.reinforce_reinforceType==this.REINFORCE_TYPE.HELI then
	--    return false
	--  end

	--r51 Settings
	if(((mvars.reinforce_reinforceType==this.REINFORCE_TYPE.HELI and not TUPPMSettings.reinforce_ENABLE_reinforcementsWithHeli) 
	or mvars.reinforce_reinforceType==this.REINFORCE_TYPE.EAST_WAV_ROCKET)
	or mvars.reinforce_reinforceType==this.REINFORCE_TYPE.EAST_TANK)
	or mvars.reinforce_reinforceType==this.REINFORCE_TYPE.WEST_TANK then
	--r28 Let soldiers spawn with Helis; this function decides if soldiers are present *INSIDE* the vehicle or not
--	if((mvars.reinforce_reinforceType==this.REINFORCE_TYPE.EAST_WAV_ROCKET)or mvars.reinforce_reinforceType==this.REINFORCE_TYPE.EAST_TANK)or mvars.reinforce_reinforceType==this.REINFORCE_TYPE.WEST_TANK then
		return false --r28
			--    return true --r28
			--K default false, setting to true allows soldiers to show up along side Heli/Vehicles, provided other conditions are met
	end
	return true
end

function this._HasVehicle()
	if((((mvars.reinforce_reinforceType==this.REINFORCE_TYPE.EAST_WAV 
	or mvars.reinforce_reinforceType==this.REINFORCE_TYPE.EAST_WAV_ROCKET)
	or mvars.reinforce_reinforceType==this.REINFORCE_TYPE.WEST_WAV)
	or mvars.reinforce_reinforceType==this.REINFORCE_TYPE.WEST_WAV_CANNON)
	or mvars.reinforce_reinforceType==this.REINFORCE_TYPE.EAST_TANK)
	or mvars.reinforce_reinforceType==this.REINFORCE_TYPE.WEST_TANK then
		return true
	end
	return false --K default false, setting this to true spawn 5 soldiers and 1 driver in the same spawn point inside an invisible vehicle(because that mission did not support vehicles). With the else part of _HasHeli() set to true and mvars.reinforce_reinforceType=e.REINFORCE_TYPE.HELI there, if this is turned to true, then soldiers spawn inside invisible vehicle. However, I managed to get a Heli to spawn in Mission A Hero's Way, which is not the default behaviour. Need to investigate so maybe we can have Heli, Vehicle and Soldiers together
end

function this._HasHeli()
	if mvars.reinforce_reinforceType==this.REINFORCE_TYPE.HELI then
		return true --true
	end
	return false --r28
		--  --r28 Fixed variable incorrectly being set in Free roam and below missions
		--  if vars.missionCode~=30010 and vars.missionCode~=30020 and vars.missionCode~=30050 and vars.missionCode~=10093 and vars.missionCode~=10036 then
		--    mvars.reinforce_reinforceType=this.REINFORCE_TYPE.HELI
		--    --K setting this here allows for reinforcement soldiers to spawn alongside *Vehicles* for some reason(without spawing a Heli in ouposts where a Heli won't spawn), very strange, discovered completely by accident
		--    return true --K default false
		--  elseif vars.missionCode==10093 or vars.missionCode==10036 then
		--    return false --TODO test heli in these missions; I can see reinforce spawning without armor
		--  else
		--    mvars.reinforce_reinforceType=this.REINFORCE_TYPE.NONE --r28 For Free roam
		--    return false
		--  end
end

function this._GetHeliRoute(e)
	return"reinforce_heli_route_0000"end

function this._SetEnabledSoldier(soldierName,enabled)
	local soldierId=GameObject.GetGameObjectId(soldierName)
	if soldierId==NULL_ID then
		return
	end
	--  TppMain.AutoMarkReinforcements(soldierId)
	SendCommand(soldierId,{id="SetEnabled",enabled=enabled})
	--TppMarker.Enable(soldierId,0,"moving","map_and_world_only_icon",0,true,false) --nope, works but soldiers are not yet present on the map
	--TUPPMLog.Log("Auto marked soldiers: "..tostring(soldierId)) --WIP
end

function this._SetEnabledVehicle(vehicleName,enabled)
	local vehicleId=GameObject.GetGameObjectId(vehicleName)
	if vehicleId==NULL_ID then
		return
	end
	if enabled then
		local vehicleSubType
		if mvars.reinforce_reinforceType==this.REINFORCE_TYPE.EAST_WAV_ROCKET then
			vehicleSubType=Vehicle.subType.EASTERN_WHEELED_ARMORED_VEHICLE_ROCKET_ARTILLERY
		elseif mvars.reinforce_reinforceType==this.REINFORCE_TYPE.WEST_WAV then
			vehicleSubType=Vehicle.subType.WESTERN_WHEELED_ARMORED_VEHICLE_TURRET_MACHINE_GUN
		elseif mvars.reinforce_reinforceType==this.REINFORCE_TYPE.WEST_WAV_CANNON then
			vehicleSubType=Vehicle.subType.WESTERN_WHEELED_ARMORED_VEHICLE_TURRET_CANNON
		end
		local cpSubType=TppEnemy.GetCpSubType(mvars.reinforce_cpId)
		local vehiclePaint=Vehicle.paintType.NONE
		if(cpSubType=="PF_A"or cpSubType=="PF_B")or cpSubType=="PF_C"then
			vehiclePaint=Vehicle.paintType.FOVA_0
		end
		local class=nil
		if mvars.reinforce_reinforceColoringType then
			class=mvars.reinforce_reinforceColoringType
		end
		local command={id="Respawn",name=vehicleName,type=9,subType=vehicleSubType,paintType=vehiclePaint,class=class}
		SendCommand(vehicleId,command)
	else
		SendCommand(vehicleId,{id="Despawn",name=vehicleName,type=9})
	end
end

function this._ActivateReinforce()
	--    TppUiCommand.AnnounceLogView("_ActivateReinforce") --K Step 8
	local hasVehicle=this._HasVehicle()
	local hasSoldier=this._HasSoldier()
	local hasHeli=this._HasHeli()

	local vehicleObject,solDriver,sol1,sol2,sol3,sol4,itwo,ithree,ctwo,cthree,ttwo,tthree,otwo,othree
	local reinforcements={}

	if hasSoldier then
		mvars.reinforce_isEnabledSoldiers=true

		for n,soldierName in ipairs(this.REINFORCE_SOLDIER_NAMES)do
			this._SetEnabledSoldier(soldierName,true)
		end

		sol1=GameObject.GetGameObjectId("TppSoldier2",this.REINFORCE_SOLDIER_NAMES[1])
		sol2=GameObject.GetGameObjectId("TppSoldier2",this.REINFORCE_SOLDIER_NAMES[2])
		sol3=GameObject.GetGameObjectId("TppSoldier2",this.REINFORCE_SOLDIER_NAMES[3])
		sol4=GameObject.GetGameObjectId("TppSoldier2",this.REINFORCE_SOLDIER_NAMES[4])

		table.insert(reinforcements,sol1)
		table.insert(reinforcements,sol2)
		table.insert(reinforcements,sol3)
		table.insert(reinforcements,sol4)

	end

	if hasVehicle then
		mvars.reinforce_isEnabledVehicle=true
		this._SetEnabledVehicle(this.REINFORCE_VEHICLE_NAME,true)
		this._SetEnabledSoldier(this.REINFORCE_DRIVER_SOLDIER_NAME,true)
		vehicleObject=GameObject.GetGameObjectId("TppVehicle2",this.REINFORCE_VEHICLE_NAME)
		solDriver=GameObject.GetGameObjectId("TppSoldier2",this.REINFORCE_DRIVER_SOLDIER_NAME)
		table.insert(reinforcements,solDriver)
		--    TppMain.AutoMarkReinforcements(solDriver)
	end

	if hasHeli then
		local heliId=GameObject.GetGameObjectId(this.REINFORCE_HELI_NAME)
		local heliRoute=this._GetHeliRoute(mvars.reinforce_cpId)
		local cpId=mvars.ene_cpList[mvars.reinforce_reinforceCpId]
		--    TUPPMLog.Log("mvars.reinforce_cpId: "..tostring(mvars.reinforce_cpId)) --WIP
		--    TUPPMLog.Log("cpId: "..tostring(cpId))
		SendCommand(heliId,{id="RequestReinforce",toCp=cpId})
		SendCommand(heliId,{id="SetCommandPost",cp=cpId})

		if mvars.reinforce_reinforceColoringType then
			TppHelicopter.SetEnemyColoring(mvars.reinforce_reinforceColoringType)
		end
	end

	TppRevenge.ApplyPowerSettingsForReinforce(reinforcements)
	--  TppMain.AutoMarkReinforcements(solDriver)
	--  TppMain.AutoMarkReinforcements(sol1)
	--  TppMain.AutoMarkReinforcements(sol2)
	--  TppMain.AutoMarkReinforcements(sol3)
	--  TppMain.AutoMarkReinforcements(sol4)

	GameObject.SendCommand({type="TppCommandPost2"},{id="SetReinforcePrepared"})
	--r27 Better auto marking code
	--  this.areFirstReinforcements=true --r24 Set the flag to true here, reinforcements are spawned after this
	--  TppMain.AutoMarkReinforcements() --TODO r24
end

function this._DeactivateReinforce()
	--  TppUiCommand.AnnounceLogView("_DeactivateReinforce")
	if mvars.reinforce_isEnabledSoldiers then
		mvars.reinforce_isEnabledSoldiers=false
		for n,r in ipairs(this.REINFORCE_SOLDIER_NAMES)do
			this._SetEnabledSoldier(r,false)
		end
	end
	if mvars.reinforce_isEnabledVehicle then
		mvars.reinforce_isEnabledVehicle=false
		this._SetEnabledVehicle(this.REINFORCE_VEHICLE_NAME,false)
		this._SetEnabledSoldier(this.REINFORCE_DRIVER_SOLDIER_NAME,false)
	end

	GameObject.SendCommand({type="TppCommandPost2"},{id="SetNominateList"})
end

function this.Messages()
	--TppUiCommand.AnnounceLogView("Messages")
	return Tpp.StrCode32Table{
		GameObject={
			{msg="RequestLoadReinforce",
				func=this._OnRequestLoadReinforce},
			{msg="RequestAppearReinforce",
				func=this._OnRequestAppearReinforce},
			{msg="CancelReinforce",
				func=this._OnCancelReinforce}}
	}
end

function this.Init(r)
	--TppUiCommand.AnnounceLogView("Init")
	this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
end

function this.OnReload(r)
	--TppUiCommand.AnnounceLogView("OnReload")
	this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
end

function this.OnMessage(r,n,a,o,t,c,i)
	Tpp.DoMessage(this.messageExecTable,TppMission.CheckMessageOption,r,n,a,o,t,c,i)
end

--K get reinforce type
function this._OnRequestLoadReinforce(i)
	--    TppUiCommand.AnnounceLogView("_OnRequestLoadReinforce") --K Step 2/Repeat Step 1; Freeroam Step 2
	local selectedReinforceVehicle=TppRevenge.SelectReinforceType()
	local r

	if TppRevenge.IsUsingBlackSuperReinforce()then
		if selectedReinforceVehicle==this.REINFORCE_TYPE.HELI then
			--r44 Red Strongest Heli type
			r=TppDefine.ENEMY_HELI_COLORING_TYPE.BLACK
			--r51 Settings
			if TUPPMSettings.reinforce_ENABLE_redReinforceHeli then
				r=TppDefine.ENEMY_HELI_COLORING_TYPE.RED
			end
		else
			--r44 Oxide Red does not work on reinforce armored vehicles
			--r=Vehicle.class.OXIDE_RED
			r=Vehicle.class.DARK_GRAY
		end
	end

	this.LoadReinforceBlock(selectedReinforceVehicle,i,r)

end

function this._OnRequestAppearReinforce(r)
	--    TppUiCommand.AnnounceLogView("_OnRequestAppearReinforce") --K Step 5
	this.StartReinforce(r)
	--  TppMain.AutoMarkReinforcements() --TODO r24
end

function this._OnCancelReinforce(r)
	--  TppUiCommand.AnnounceLogView("_OnCancelReinforce")
	if mvars.reinforce_activated then
		return
	end
	this.FinishReinforce(r)
end
return this
