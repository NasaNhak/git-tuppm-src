---r56
--@module TUPPM module
local this={}

---Fox.StrCode32
local StrCode32=Fox.StrCode32
---GameObject.GetGameObjectId
local GetGameObjectId=GameObject.GetGameObjectId
---GameObject.GetGameObjectIdByIndex
local GetGameObjectIdByIndex=GameObject.GetGameObjectIdByIndex
---GameObject.NULL_ID
local NULL_ID=GameObject.NULL_ID
---GameObject.SendCommand
local SendCommand=GameObject.SendCommand
---GkEventTimerManager.Start
local GkEventTimerManagerStart=GkEventTimerManager.Start

--r62 Quick Save option
local isSaving=false

--r63 Reload mod settings option
local isReloadingModSettings=false

--TODO rX63 Camera fix for MGS1 cam
local timerForCameraFix = 0.1

---r56
--Returns a messages table consisting of messages that are interpreted by the game engine.
-- @return #table Custom message table for the purposes of the mod
function this.Messages()
	return Tpp.StrCode32Table{
		--	Network = { --rX65 Does not work for pause menu network connect
		--				{
		--					msg = "EndLogin",
		--					func = function()
		--						if (TppGameMode.GetUserMode()<=TppGameMode.U_1ST_PARTY_SIGN_IN) then
		--							TppServerManager.StartLogin()
		--							TUPPMLog.Log("Attempting re-login",1,TUPPMSettings._debug_ENABLE_forcePrintLogs)
		--						else
		--							TUPPMLog.Log("Loged in so continue",1,TUPPMSettings._debug_ENABLE_forcePrintLogs)
		--						end
		--					end,
		--				},
		--			},
		Marker={
			{
				msg="ChangeToEnable",
				func=this._OnMarkerChangeToEnable
			}
		},
		GameObject={
			{
				msg = "StartedMoveToLandingZone", sender = {"SupportHeli", "TppHeli2"},
				func = function()
					TUPPMLog.Log("SupportHeli StartedMoveToLandingZone",3,TUPPMSettings._debug_ENABLE_forcePrintLogs)
				end
			},
			{
				msg = "StartedPullingOut", sender = {"SupportHeli", "TppHeli2"},
				func = function ()
					TUPPMLog.Log("SupportHeli StartedPullingOut",3,TUPPMSettings._debug_ENABLE_forcePrintLogs)
					this.PlayPulloutBGMFromM2()
				end
			},
			{
				msg = "LandedAtLandingZone", sender = {"SupportHeli", "TppHeli2"},
				func = function ()
					TUPPMLog.Log("SupportHeli LandedAtLandingZone",3,TUPPMSettings._debug_ENABLE_forcePrintLogs)
				end
			},
			{
				msg = "ArrivedAtLandingZoneSkyNav", sender = {"SupportHeli", "TppHeli2"},
				func = function ()
					TUPPMLog.Log("SupportHeli ArrivedAtLandingZoneSkyNav",3,TUPPMSettings._debug_ENABLE_forcePrintLogs)
				end
			},
			{
				msg = "ArrivedAtLandingZoneWaitPoint", sender = {"SupportHeli", "TppHeli2"},
				func = function ()
					TUPPMLog.Log("SupportHeli ArrivedAtLandingZoneWaitPoint",3,TUPPMSettings._debug_ENABLE_forcePrintLogs)
				end
			},
			{
				msg = "HeliDoorClosed", sender = {"SupportHeli", "TppHeli2"},
				func = function ()
					TUPPMLog.Log("SupportHeli HeliDoorClosed",3,TUPPMSettings._debug_ENABLE_forcePrintLogs)
				end
			},
			{
				msg = "RoutePoint2", sender = {"SupportHeli", "TppHeli2"},
				func = function ()
					TUPPMLog.Log("SupportHeli RoutePoint2",3,TUPPMSettings._debug_ENABLE_forcePrintLogs)
				end
			},
			{
				msg = "PlacedIntoVehicle",
				func = function ()
					TUPPMLog.Log("NoFixedSender PlacedIntoVehicle",3,TUPPMSettings._debug_ENABLE_forcePrintLogs)
				end
			},
			{
				msg = "PlacedIntoVehicle", sender = {"SupportHeli", "TppHeli2"},
				func = function ()
					TUPPMLog.Log("SupportHeli PlacedIntoVehicle",3,TUPPMSettings._debug_ENABLE_forcePrintLogs)
				end
			},
			{
				msg = "LostControl", sender = {"SupportHeli", "TppHeli2"},
				func = function ()
					TUPPMLog.Log("SupportHeli LostControl",3,TUPPMSettings._debug_ENABLE_forcePrintLogs)
				end
			},
			{
				msg = "Damage", sender = {"SupportHeli", "TppHeli2"},
				func = function ()
					TUPPMLog.Log("SupportHeli Damage",3,TUPPMSettings._debug_ENABLE_forcePrintLogs)
				end
			},
			{
				msg = "CalledFromStandby", sender = {"SupportHeli", "TppHeli2"},
				func = function ()
					TUPPMLog.Log("SupportHeli CalledFromStandby",3,TUPPMSettings._debug_ENABLE_forcePrintLogs)
					this.SetHeliLife()
				end
			},
			{
				msg = "DescendToLandingZone", sender = {"SupportHeli", "TppHeli2"},
				func = function ()
					TUPPMLog.Log("SupportHeli DescendToLandingZone",3,TUPPMSettings._debug_ENABLE_forcePrintLogs)
				end
			},
			{msg="Damage",
				func=this._OnDamage
			},
		},
		Timer={
			{
				msg="Finish",
				sender="Timer_AlwaysAlertCPs",
				func=this.AlwaysAlertCPs
			},
			{--r62 Quick Save option
				msg="Finish",
				sender="Timer_CustomSave",
				func=function()
					isSaving=false
				end
			},
			{--r63 Reload mod settings option
				msg="Finish",
				sender="Timer_ReloadModSettings",
				func=function()
					isReloadingModSettings=false
				end
			},
		--			{---TODO rX63 Camera fix for MGS1 cam
		--				msg="Finish",
		--				sender="Timer_CorrectAim",
		--				func=this.FixCameraRot
		--			},
		},
		Player = {
		--			{--r64 Camera fix for MGS1 cam
		--				msg="OnBinocularsMode",
		--				func=function(sender,messageId,arg0,arg1,arg2,arg3,strLogText)
		--					--Do not do this if weapon is held
		--					if bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.HOLD)==PlayerPad.HOLD then return end
		--					this.FixCameraRot(sender,messageId,arg0,arg1,arg2,arg3,strLogText,"OnBinocularsMode")
		--				end,
		--			},
		--			{--r64 Camera fix for MGS1 cam
		--				msg="PlayerHoldWeapon",
		--				func=function(sender,messageId,arg0,arg1,arg2,arg3,strLogText)
		--					this.FixCameraRot(sender,messageId,arg0,arg1,arg2,arg3,strLogText,"PlayerHoldWeapon")
		--				end,
		--			},
		--			{---TODO rX63 Camera fix for MGS1 cam
		--				msg="AimedFromPlayer",
		--				func=function(sender,messageId,arg0,arg1,arg2,arg3,strLogText)
		--					--GkEventTimerManagerStart("Timer_CorrectAim", timerForCameraFix)
		--					this.FixCameraRot(sender,messageId,arg0,arg1,arg2,arg3,strLogText,"AimedFromPlayer")
		--				end,
		--			},
		--			{---TODO rX63 Camera fix for MGS1 cam
		--				msg="OnPlayerUseBoosterScope",
		--				func=function(sender,messageId,arg0,arg1,arg2,arg3,strLogText)
		--					--GkEventTimerManagerStart("Timer_CorrectAim", timerForCameraFix)
		--					this.FixCameraRot(sender,messageId,arg0,arg1,arg2,arg3,strLogText,"OnPlayerUseBoosterScope")
		--				end,
		--			},
		},

	}
end


---r56 Message execution table
this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())

---r56
--Init and Reload functions have to be defined in order to get sender based messages working correctly
-- @param #table missionTable Table consisting of mission specific data
function this.Init(missionTable)
	this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
end

---r56
--Init and Reload functions have to be defined in order to get sender based messages working correctly
-- @param #table missionTable Table consisting of mission specific data
function this.OnReload(missionTable)
	this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
end

---r56
--OnMessages func that is called every time the engine passes a message to the Lua script
-- @param #string sender Message sender
-- @param #number messageId Message Id StrCode32
-- @param #string arg0 Usually the game object Id
-- @param #string arg1 Argument 1
-- @param #string arg2 Argument 2
-- @param #string arg3 Argument 3
-- @param #string strLogText String text usually nil
function this.OnMessage(sender,messageId,arg0,arg1,arg2,arg3,strLogText)
	Tpp.DoMessage(this.messageExecTable,TppMission.CheckMessageOption,sender,messageId,arg0,arg1,arg2,arg3,strLogText)
end

---r56
--Keeps CP in alert based on enable arg
-- @param #string cpName Name of the CP
-- @param #boolean enable Flag to keep alert
function this.SetKeepCPAlert(cpName,enable)
	local gameId=GetGameObjectId("TppCommandPost2",cpName)
	if gameId==NULL_ID then
		return
	end
	local command={id="SetKeepAlert",enable=enable}
	GameObject.SendCommand(gameId,command)
end

---r56
--Changes phase of CP
-- @param #string cpName Name of the CP
-- @param #TppGameObject phase Phase to set for CP
function this.ChangeCPPhase(cpName,phase)
	local gameId=GetGameObjectId("TppCommandPost2",cpName)
	if gameId==NULL_ID then
		return
	end
	local command={id="SetPhase",phase=phase}
	SendCommand(gameId,command)
end

---r56
--Function to check distance of game object from player position
-- @param #stringOrNumber gameObject Game Object Name or Id
-- @param #number reqDistanceFromPlayer Required distance from the player. Defaults to 301 if nil
-- @return #boolean Returns true if game object is within the reqDistanceFromPlayer radius
function this.IsCloseToPlayerPos(gameObject, reqDistanceFromPlayer)
	local gameObjectId
	if Tpp.IsTypeString(gameObject) then
		gameObjectId = GetGameObjectId(gameObject)
	elseif Tpp.IsTypeNumber(gameObject) then
		gameObjectId = gameObject
	else
		return false
	end

	if gameObjectId==NULL_ID then
		return false
	end

	local gameObjectPosition, rotY = SendCommand( gameObjectId, {id="GetPosition"} )
	local gameObjectDistanceFromPlayer = math.sqrt(TppMath.FindDistance( TppMath.Vector3toTable(gameObjectPosition), TppPlayer.GetPosition() ))

	if reqDistanceFromPlayer==nil then
		reqDistanceFromPlayer=301 --default to 301m
	end

	if gameObjectDistanceFromPlayer<=reqDistanceFromPlayer then
		return true
	end

	return false
end

---r56
--Function calls itself via a timer to put any CPs close to the player
--in alert phase if the CP is not already in alert
function this.AlwaysAlertCPs()
	if TppMission.IsMbFreeMissions(vars.missionCode) then return end
	if not mvars.ene_soldierDefine then return end
	--r57 Slightly better handling
	local nextTimerFinish=5
	local range=math.random(100,250)

	for cpName,soldierList in pairs(mvars.ene_soldierDefine)do
		local cpId=GetGameObjectId(cpName)
		local cpPhase=SendCommand(cpId,{id="GetPhase",cpName=cpName})
		local phaseToSet=TppGameObject.PHASE_ALERT

		--3 is Alert
		--2 is Evasion
		--1 is Caution
		--0 is Sneak

		if cpPhase<3 then
			for _, soldierName in pairs(soldierList) do
				local soldierObjectId = GetGameObjectId("TppSoldier2", soldierName)
				if soldierObjectId ~= NULL_ID
					and not TppEnemy.IsEliminated(soldierObjectId)
					and this.IsCloseToPlayerPos(soldierObjectId,range)
				then
					this.ChangeCPPhase(cpName,phaseToSet)
					--TUPPMLog.Log("cpName:"..tostring(cpName).." Set to phase:"..tostring(phaseToSet),3)
					--this.SetKeepCPAlert(cpName,true)
					break
				end
			end
		end
	end
	--TUPPMLog.Log("AlwaysAlertCPs completed nextTimerFinish:"..tostring(nextTimerFinish),3)
	GkEventTimerManagerStart("Timer_AlwaysAlertCPs",nextTimerFinish)
end

---r56
--Function to play the cool pullout BGM from M2
function this.PlayPulloutBGMFromM2()
	if not TppMission.IsMbFreeMissions(vars.missionCode) then return end
	if not TUPPMSettings.heli_ENABLE_heroicMusicOnLeaveMotherbase then return end
	--BGM sound files have to be added :( via fox2, seems only 1 sdf per mission allowed
	--if vars.playerVehicleGameObjectId~=GameObject.NULL_ID then return end
	TUPPMLog.Log("Going to play M2 pullout BGM",3)
	TppSound.SetSceneBGM("bgm_mtbs_departure")
	TppSound.SetSceneBGMSwitch("Set_Switch_bgm_s10030_departure")
	TppSoundDaemon.SetMute( 'HeliClosing' )
	TUPPMLog.Log("Playing M2 pullout BGM",3)
end

---r56
--Sets the heli life to a custom value defined in TUPPMSettings
function this.SetHeliLife()
	if TppMission.IsFOBMission(vars.missionCode) then return end
	if not TUPPMSettings.heli_ENABLE_customLife then return end
	if not TUPPMSettings.heli_lifePoints then return end

	local heliObjectId = GetGameObjectId("TppHeli2", "SupportHeli")
	if heliObjectId==NULL_ID then return end

	local heli_lifePoints=math.max(TUPPMSettings.heli_lifePoints, 1)
	SendCommand(heliObjectId, { id="SetLife", life=heli_lifePoints })
	TUPPMLog.Log(tostring(vars.missionCode).." Set heli life points:"..tostring(heli_lifePoints),3)
end

--rX58 Nope
function this.SuperSprint()
	local moveResult,moveErr=pcall(SendCommand, { type="TppPlayer2", index=0 }, { id="SetStandMoveSpeedLimit", speedRateLimit = 0.1 } )
	local dashResult,dashErr=pcall(SendCommand, { type="TppPlayer2", index=0 }, { id="SetDashMoveSpeedLimit", speedRateLimit = 0.1 } )
	local dashResult2,dashErr2=pcall(SendCommand, { type="TppPlayer2", index=0 }, { id="SetStandDashSpeedLimit", speedRateLimit = 0.1 } )
	TUPPMLog.Log("moveResult:"..tostring(moveResult).." moveErr:"..tostring(moveErr),3,true)
	TUPPMLog.Log("dashResult:"..tostring(dashResult).." dashErr:"..tostring(dashErr),3,true)
	TUPPMLog.Log("dashResult2:"..tostring(dashResult2).." dashErr2:"..tostring(dashErr2),3,true)
end

---r58
--Sets custom weapon magazine and suppressors
function this.SetCustomWeaponSettings()
	if not TUPPMSettings.weapons_ENABLE_useCustomWeaponsSettings then
		TUPPMLog.Log("Return cause weapons_ENABLE_useCustomWeaponsSettings is false",3)
		return
	end

	--As discovered earlier, Script.LoadLibrary will only work once

	if TppMission.IsFOBMission(vars.missionCode) then
		--Script.LoadLibrary("/Assets/tpp/level_asset/weapon/ParameterTables/parts/EquipParameters.lua")
		dofile("/Assets/tpp/level_asset/weapon/ParameterTables/parts/EquipParameters.lua")
		--> r60 New settings
		dofile("/Assets/tpp/level_asset/weapon/ParameterTables/EquipParameterTables.lua")
		dofile("/Assets/tpp/level_asset/damage/ParameterTables/DamageParameterTables.lua")
		--< r60 New settings
		TUPPMLog.Log("Reset Weapon settings for FOB",3)
		return
	end

	--Script.LoadLibrary("/Assets/tpp/script/lib/TUPPMEquipParameters.lua")
	dofile("/Assets/tpp/script/lib/TUPPMEquipParameters.lua")
	--> r60 New settings
	dofile("/Assets/tpp/script/lib/TUPPMEquipParameterTables.lua")
	dofile("/Assets/tpp/script/lib/TUPPMDamageParameterTables.lua")
	--< r60 New settings
	TUPPMLog.Log("Set Weapon settings for non FOB",3)
end

---r61
--Set custom camo value
function this.SetCustomCamoSettings()
	if not TUPPMSettings.camo_ENABLE_useCustomCamoSettings then
		TUPPMLog.Log("Return cause camo_ENABLE_useCustomCamoSettings is false",3)
		return
	end

	if TppMission.IsFOBMission(vars.missionCode) then
		dofile("/Assets/tpp/level_asset/chara/player/game_object/player2_camouf_param.lua")
		TUPPMLog.Log("Reset Camo settings for FOB",3)
		return
	end

	dofile("/Assets/tpp/script/lib/TUPPMplayer2_camouf_param.lua")
	TUPPMLog.Log("Set Camo settings for non FOB",3)
end

---r51
--Set custom soldier params
--r61 Moved here
function this.SetCustomSoldierParams()
	--r58 BUGFIX Corrected setting name
	if not TUPPMSettings.hardcore_ENABLE_useCustomSoldierParams then
		TUPPMLog.Log("Return cause hardcore_ENABLE_useCustomSoldierParams is false",3)
		return
	end

	local maxLife=math.max(TUPPMSettings.hardcore_maxLife or 2600,540)
	local maxStamina=math.max(TUPPMSettings.hardcore_maxStamina or 3e3,0)
	local maxLimbLife=math.max(TUPPMSettings.hardcore_maxLimbLife or 1500,540)
	local maxArmorLife=math.max(TUPPMSettings.hardcore_maxArmorLife or 7500,0)
	local maxHelmetLife=math.max(TUPPMSettings.hardcore_maxHelmetLife or 500,0)
	local sleepRecoverSec=math.max(TUPPMSettings.hardcore_sleepRecoverSec or 300,0)
	local faintRecoverSec=math.max(TUPPMSettings.hardcore_faintRecoverSec or 50,0) --This does not have any effect. KO time with STN weapons may be dependent on weapon damage
	local dyingSec=math.max(TUPPMSettings.hardcore_dyingSec or 60,0)

	local enemySightScale=math.max(TUPPMSettings.hardcore_enemySightScale or 1,0)
	local enemySoundScale=math.max(TUPPMSettings.hardcore_enemySoundScale or 1,0)

	local message = "Setting custom soldier params"

	if TppMission.IsFOBMission(vars.missionCode) then
		maxLife=2600
		maxStamina=3000
		maxLimbLife=1500
		maxArmorLife=7500
		maxHelmetLife=500
		sleepRecoverSec=300
		faintRecoverSec=50
		dyingSec=60
		enemySightScale=1
		enemySoundScale=1
		message="Re-"..message.." for FOBs"
	end

	TUPPMLog.Log(message,3)

	--The whole bloody table has to be loaded every time, cannot be loaded in parts sadly
	--Stupid coding by KJP
	TppSoldier2.ReloadSoldier2ParameterTables{
		sightFormParameter={
			contactSightForm={distance=2*enemySightScale,verticalAngle=160,horizontalAngle=130},
			normalSightForm={distance=60*enemySightScale,verticalAngle=60,horizontalAngle=100},
			farSightForm={distance=90*enemySightScale,verticalAngle=30,horizontalAngle=30},
			searchLightSightForm={distance=50*enemySightScale,verticalAngle=15,horizontalAngle=15},
			observeSightForm={distance=200*enemySightScale,verticalAngle=5,horizontalAngle=5},
			baseSight={
				discovery={distance=10*enemySightScale,verticalAngle=36,horizontalAngle=48},
				indis={distance=20*enemySightScale,verticalAngle=60,horizontalAngle=80},
				dim={distance=45*enemySightScale,verticalAngle=60,horizontalAngle=80},
				far={distance=70*enemySightScale,verticalAngle=12,horizontalAngle=8}
			},
			nightSight={
				discovery={distance=10*enemySightScale,verticalAngle=30,horizontalAngle=40},
				indis={distance=15*enemySightScale,verticalAngle=60,horizontalAngle=60},
				dim={distance=35*enemySightScale,verticalAngle=60,horizontalAngle=60},
				far={distance=0*enemySightScale,verticalAngle=0,horizontalAngle=0}
			},
			combatSight={
				discovery={distance=10*enemySightScale,verticalAngle=36,horizontalAngle=60},
				indis={distance=25*enemySightScale,verticalAngle=60,horizontalAngle=100},
				dim={distance=50*enemySightScale,verticalAngle=60,horizontalAngle=100},
				far={distance=70*enemySightScale,verticalAngle=30,horizontalAngle=30}
			},
			walkerGearSight={
				discovery={distance=15*enemySightScale,verticalAngle=36,horizontalAngle=60},
				indis={distance=25*enemySightScale,verticalAngle=60,horizontalAngle=100},
				dim={distance=55*enemySightScale,verticalAngle=60,horizontalAngle=100},
				far={distance=85*enemySightScale,verticalAngle=30,horizontalAngle=30}
			},
			observeSight={
				discovery={distance=10*enemySightScale,verticalAngle=36,horizontalAngle=48},
				indis={distance=70*enemySightScale,verticalAngle=12,horizontalAngle=8},
				dim={distance=45*enemySightScale,verticalAngle=5,horizontalAngle=5},
				far={distance=70*enemySightScale,verticalAngle=5,horizontalAngle=5},
				observe={distance=200*enemySightScale,verticalAngle=5,horizontalAngle=5}
			},
			snipingSight={
				discovery={distance=10*enemySightScale,verticalAngle=36,horizontalAngle=48},
				indis={distance=70*enemySightScale,verticalAngle=12,horizontalAngle=8},
				dim={distance=45*enemySightScale,verticalAngle=5,horizontalAngle=5},
				far={distance=70*enemySightScale,verticalAngle=5,horizontalAngle=5},
				observe={distance=200*enemySightScale,verticalAngle=5,horizontalAngle=5}
			},
			searchLightSight={
				discovery={distance=30*enemySightScale,verticalAngle=8,horizontalAngle=8},
				indis={distance=0*enemySightScale,verticalAngle=0,horizontalAngle=0},
				dim={distance=50*enemySightScale,verticalAngle=12,horizontalAngle=12},
				far={distance=0*enemySightScale,verticalAngle=0,horizontalAngle=0}
			},
			armoredVehicleSight={
				discovery={distance=20*enemySightScale,verticalAngle=36,horizontalAngle=60},
				indis={distance=25*enemySightScale,verticalAngle=60,horizontalAngle=100},
				dim={distance=55*enemySightScale,verticalAngle=60,horizontalAngle=100},
				far={distance=85*enemySightScale,verticalAngle=30,horizontalAngle=30},
				observe={distance=120*enemySightScale,verticalAngle=5,horizontalAngle=5}
			},
			zombieSight={
				discovery={distance=7*enemySightScale,verticalAngle=36,horizontalAngle=48},
				indis={distance=14*enemySightScale,verticalAngle=60,horizontalAngle=80},
				dim={distance=31.5*enemySightScale,verticalAngle=60,horizontalAngle=80},
				far={distance=0*enemySightScale,verticalAngle=12,horizontalAngle=8}
			},
			msfSight={
				discovery={distance=10*enemySightScale,verticalAngle=36,horizontalAngle=48},
				indis={distance=20*enemySightScale,verticalAngle=60,horizontalAngle=80},
				dim={distance=45*enemySightScale,verticalAngle=60,horizontalAngle=80},
				far={distance=70*enemySightScale,verticalAngle=12,horizontalAngle=8}
			},
			vehicleSight={
				discovery={distance=15*enemySightScale,verticalAngle=36,horizontalAngle=48},
				indis={distance=25*enemySightScale,verticalAngle=60,horizontalAngle=80},
				dim={distance=45*enemySightScale,verticalAngle=60,horizontalAngle=80},
				far={distance=70*enemySightScale,verticalAngle=12,horizontalAngle=8}
			},
			sandstormSight={distanceRate=.6,angleRate=.8},
			rainSight={distanceRate=1,angleRate=1},
			cloudySight={distanceRate=1,angleRate=1},
			foggySight={distanceRate=.5,angleRate=.6}
		},
		sightCamouflageParameter={
			discovery={enemy=530,character=530,object=530},
			indis={enemy=80,character=210,object=270},
			dim={enemy=-50,character=30,object=130},
			far={enemy=-310,character=0,object=70},
			bushDensityThresold=100},
		hearingRangeParameter={
			normal={zero=0*enemySoundScale,ss=4.5*enemySoundScale,hs=5.5*enemySoundScale,s=9*enemySoundScale,m=15*enemySoundScale,l=30*enemySoundScale,hll=60*enemySoundScale,ll=160*enemySoundScale,alert=160*enemySoundScale,special=500*enemySoundScale},
			sandstorm={zero=0*enemySoundScale,ss=0*enemySoundScale,hs=0*enemySoundScale,s=0*enemySoundScale,m=15*enemySoundScale,l=30*enemySoundScale,hll=60*enemySoundScale,ll=160*enemySoundScale,alert=160*enemySoundScale,special=500*enemySoundScale},
			rain={zero=0*enemySoundScale,ss=0*enemySoundScale,hs=0*enemySoundScale,s=4.5*enemySoundScale,m=15*enemySoundScale,l=30*enemySoundScale,hll=60*enemySoundScale,ll=160*enemySoundScale,alert=160*enemySoundScale,special=500*enemySoundScale}
		},
		lifeParameterTable={
			maxLife=maxLife,
			maxStamina=maxStamina,
			maxLimbLife=maxLimbLife,
			maxArmorLife=maxArmorLife,
			maxHelmetLife=maxHelmetLife,
			sleepRecoverSec=sleepRecoverSec,
			faintRecoverSec=faintRecoverSec,
			dyingSec=dyingSec
		},
		zombieParameterTable={highHeroicValue=1e3}
	}
end

--r62 Quick Save option
local savingButtonHoldTime=0
---r62
--Allows saving at any point
function this.SaveAtCurrentLocation()
	if TppMission.IsFOBMission(vars.missionCode) then return end

	if mvars.mis_loadRequest or mvars.mis_missionStateIsNotInGame or DemoDaemon.IsDemoPlaying() then
		--TUPPMLog.Log("mis_loadRequest or mis_missionStateIsNotInGame is true",3,true)
		isSaving=false
		return
	end

	if
		bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.RELOAD)==PlayerPad.RELOAD
		and bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.CALL)==PlayerPad.CALL
		and not isSaving
	then
		if savingButtonHoldTime==0 then
			savingButtonHoldTime=Time.GetRawElapsedTimeSinceStartUp()
		end

		if
			savingButtonHoldTime~=0
			and Time.GetRawElapsedTimeSinceStartUp() - savingButtonHoldTime >= 0.25
		then
			TUPPMLog.Log("CHEATS: Saving game.......",2,true) --ALWAYS PRINT
			isSaving=true
			TppMission.UpdateCheckPointAtCurrentPosition()
			GkEventTimerManager.Start("Timer_CustomSave",4)
			savingButtonHoldTime=0
		end
	else
		savingButtonHoldTime=0
	end
end

--r63 Reload mod settings option
local reloadModSettingsButtonHoldTime=0
---r63 Reload mod settings option
function this.ReloadModSettings()
	if TppMission.IsFOBMission(vars.missionCode) then return end

	if mvars.mis_loadRequest or mvars.mis_missionStateIsNotInGame or DemoDaemon.IsDemoPlaying() then
		--TUPPMLog.Log("mis_loadRequest or mis_missionStateIsNotInGame is true",3,true)
		isReloadingModSettings=false
		return
	end

	if
		bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.FIRE)==PlayerPad.FIRE
		and bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.CALL)==PlayerPad.CALL
		and bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.DASH)==PlayerPad.DASH
		and not isReloadingModSettings
	then
		if reloadModSettingsButtonHoldTime==0 then
			reloadModSettingsButtonHoldTime=Time.GetRawElapsedTimeSinceStartUp()
		end

		if
			reloadModSettingsButtonHoldTime~=0
			and Time.GetRawElapsedTimeSinceStartUp() - reloadModSettingsButtonHoldTime >= 1
		then
			isReloadingModSettings=true
			GkEventTimerManager.Start("Timer_ReloadModSettings",4)
			TUPPMStartup.ReloadExternalModule"TUPPMSettings"
			this.ModSettingsReloadCommonFuncs()
			reloadModSettingsButtonHoldTime=0
		end
	else
		reloadModSettingsButtonHoldTime=0
	end
end

---r63 Reload any mod feature that can be updated in real time
function this.ModSettingsReloadCommonFuncs()
	this.SetCustomCamera()
	this.SetBuddyBondPoints()
	--r66 Custom UI markers settings
	this.ChangeUIElements()
	--r67 Modify hand and tool levels
	this.ModifyHandsLevels()
	this.ModifyToolsLevels()
end

---r63 Custom camera settings
function this.SetCustomCamera()
	if
		TppMission.IsFOBMission(vars.missionCode)
		or TppMission.IsHelicopterSpace(vars.missionCode)
	then
		return
	end

	if not TUPPMSettings.camera_ENABLE_customSettings then
		--		Player.SetAroundCameraManualMode(true) --Needed to set camera mode
		--		Player.SetAroundCameraManualModeParams{
		--			offset=Vector3(-0.3,0.7,0),
		--			distance=5.1,
		--			focalLength=21,
		--			focusDistance=8.75,
		--			target=Vector3(2,10,10),
		--			targetInterpTime=0,
		--			targetIsPlayer=true,
		--			ignoreCollisionGameObjectName="Player",
		--			rotationLimitMinX=-60,
		--			rotationLimitMaxX=80,
		--			alphaDistance=.5
		--		}
		--		Player.UpdateAroundCameraManualModeParams()
		Player.SetAroundCameraManualMode(false) --This seems to be enough to fix camera
		return
	end

	local camera_settingsTable = TUPPMSettings.camera_settingsTable

	--r64 Separate setting for MGS1 cam
	--r65 Removed camera_ENABLE_mgs1StyleCam
	--	if TUPPMSettings.camera_ENABLE_mgs1StyleCam then
	--		camera_settingsTable = TUPPMSettings.camera_mgs1SettingsTable
	--	end

	--	TUPPMSettings.camera_initialRotationTable={
	--		rotX = -5, --Camera should rotate to this X pos(vertical). Can be set to vars.playerCameraRotation[0]. Range seems to be -90 to +90
	--		rotY = 170, --Camera should rotate to this Y pos(horizontal). Can be set to vars.playerCameraRotation[1]. Range seems to be -90 to +90
	--		interpTime = 0.3 --Time taken for camera to rotate around to new pos. When set to 10, you will see a cinematic pan
	--	}
	--	local camera_initialRotationTable = TUPPMSettings.camera_initialRotationTable

	local isSettingsTable = camera_settingsTable~=nil and Tpp.IsTypeTable(camera_settingsTable)


	--local isInitialRotationTable = camera_initialRotationTable~=nil and Tpp.IsTypeTable(camera_initialRotationTable)


	if isSettingsTable then
		Player.SetAroundCameraManualMode(true) --Needed to set camera mode
		Player.SetAroundCameraManualModeParams(camera_settingsTable)
		Player.UpdateAroundCameraManualModeParams() --Applies camera settings(likely :P) but did not test disabling this
		TUPPMLog.Log("Applied custom camera settings",3)
	end

	--	if isInitialRotationTable then
	--		Player.RequestToSetCameraRotation(camera_initialRotationTable)
	--	end

end

--r64 Added to read messages but used wrong implementation :P
local messagesInterpretTable={
	[StrCode32"Player"]="Player",
	[StrCode32"OnBinocularsMode"]="OnBinocularsMode",
	[StrCode32"PlayerHoldWeapon"]="PlayerHoldWeapon",
	[StrCode32"OnPlayerUseBoosterScope"]="OnPlayerUseBoosterScope",
}

---r64 Aim/Binoculars camera fix for MGS1 cam
function this.FixCameraRot(weaponId,weaponType,arg0,arg1,arg2,arg3,strLogText,playerAction)
	--r65 Added FOB check
	if TppMission.IsFOBMission(vars.missionCode) then return end
	if not (TUPPMSettings.camera_ENABLE_customSettings and TUPPMSettings.camera_ENABLE_mgs1StyleCam) then return end

	--	local weaponId=messagesInterpretTable[weaponId] or weaponId
	--	local weaponType=messagesInterpretTable[weaponType] or weaponType

	TUPPMLog.Log(
		" playerAction:"..tostring(playerAction)..
		" weaponId:"..tostring(weaponId)..
		" weaponType:"..tostring(weaponType)..
		" arg0:"..tostring(arg0)..
		" arg1:"..tostring(arg1)..
		" arg2:"..tostring(arg2)..
		" arg3:"..tostring(arg3)..
		" strLogText:"..tostring(strLogText)
		,3,true)


	--Nope only for TPS camera
	--TUPPMLog.Log("Resetting camera rots for "..tostring(playerAction),3,true)
	--	vars.playerCameraRotation[0]=0
	--	vars.playerCameraRotation[1]=0

	Player.RequestToSetCameraRotation{
		rotX = 0, --Should be zero to level off the aim
		rotY = vars.playerCameraRotation[1], --
		--		rotY = vars.playerRotY, --A bit wonky in cover
		interpTime = 0, --Time taken for camera to rotate around to new pos. When set to 10, you will see a cinematic pan
	}
end

local isPlayerAiming=false
local aimCamFixedForMGS1Style=false
---r64 Aim/Binoculars camera fix for MGS1 cam
--rX65 Not very good workings
function this.UpdateFixCameraRot()
	if TppMission.IsFOBMission(vars.missionCode) then return end
	if not (TUPPMSettings.camera_ENABLE_customSettings and TUPPMSettings.camera_ENABLE_mgs1StyleCam) then return end

	if
		(bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.HOLD)==PlayerPad.HOLD)
		or PlayerInfo.AndCheckStatus{PlayerStatus.BINOCLE}
	then
		isPlayerAiming=true
	else
		isPlayerAiming=false
		aimCamFixedForMGS1Style=false
	end


	if isPlayerAiming and not aimCamFixedForMGS1Style then
		aimCamFixedForMGS1Style=true
		TUPPMLog.Log("Fixing aim cam for camera_ENABLE_mgs1StyleCam",3)
		Player.RequestToSetCameraRotation{
			rotX = 0, --Should be zero to level off the aim
			rotY = vars.playerCameraRotation[1], --
			--		rotY = vars.playerRotY, --A bit wonky in cover
			interpTime = 0, --Time taken for camera to rotate around to new pos. When set to 10, you will see a cinematic pan
		}
	end
end

---r63 Set buddy points
function this.SetBuddyBondPoints()

	if not TUPPMSettings.buddy_ENABLE_setCustomPoints then return end

	local buddy_ddBondPoints=TUPPMSettings.buddy_ddBondPoints
	local buddy_dHorseBondPoints=TUPPMSettings.buddy_dHorseBondPoints
	local buddy_quietBondPoints=TUPPMSettings.buddy_quietBondPoints

	if buddy_ddBondPoints then
		TppBuddyService.SetFriendlyPoint(BuddyType.DOG,buddy_ddBondPoints)
	end
	if buddy_dHorseBondPoints then
		TppBuddyService.SetFriendlyPoint(BuddyType.HORSE,buddy_dHorseBondPoints)
	end
	if buddy_quietBondPoints then
		TppBuddyService.SetFriendlyPoint(BuddyFriendlyType.QUIET,buddy_quietBondPoints)
	end

end

---r63 Max MB Morale
function this.MaxMBMorale()
	if not TUPPMSettings.mtbs_ENABLE_maxStaffMorale then return end
	TppMotherBaseManagement.IncrementAllStaffMorale{morale=15}
end

--rX66 Research
function this._OnDamage(gameObjectId, attackTypeId, damageSourceId)
--	TUPPMLog.Log(
--	"gameObjectId:"..tostring(gameObjectId)..
--	" attackTypeId:"..tostring(attackTypeId)..
--	" damageSourceId:"..tostring(damageSourceId)
--	,3,true)
--	GameObject.SendCommand( gameObjectId, { id = "SetEverDown", enabled = true } ) --no detection for downed enemies during Phantom Cigar usage
end

--rX66 Research
function this._OnMarkerChangeToEnable(unusedArg1, unusedArg2, markedTargetId, markingObjectTypeStrCode32, arg5)
--Dummies do not fire this on being marked
--	TUPPMLog.Log(
--	"unusedArg1:"..tostring(unusedArg1).. --Seems to be 0 for machine guns/mortars/AA guns. For soldiers/landmines/vehicles this may be StrCode32-ed soldier name/landmines/vehicles name. As expected, animals in the same group have the same name
--	" unusedArg2:"..tostring(unusedArg2).. --Object type in StrCode32: TppSolder2, TppVehicle2, TppPlaced etc etc
--	" markedTargetId:"..tostring(markedTargetId)..
--	" markingObjectTypeStrCode32:"..tostring(markingObjectTypeStrCode32).. --Snake/D-Dog/Quiet etc etc
--	" arg5:"..tostring(arg5)
--	,3,true)
--
--	if (markingObjectTypeStrCode32~=3087473413) then return end
--
--	--D-Dog causes a hard crash with this; What happens is that he marks, marker changes, then he marks again - infinite loop lol
--	local result,error = pcall(TppMarker2System.EnableMarker,{gameObjectId=markedTargetId,viewLayer={"VIEW_MAP_ICON"}})
--	TUPPMLog.Log(
--	"result:"..tostring(result)..
--	" error:"..tostring(error)
--	,3,true)
end

---r66 UI elements changing
function this.ChangeUIElements()

	if TppMission.IsFOBMission(vars.missionCode) then return end

	if TUPPMSettings.ui_disableAnnounceLog then
		TppUiStatusManager.SetStatus("AnnounceLog","INVALID_LOG")
	else
		TppUiStatusManager.ClearStatus"AnnounceLog"
	end

	if TUPPMSettings.ui_disableHeadMarkers then
		TppUiStatusManager.SetStatus("HeadMarker","INVALID")
	else
		TppUiStatusManager.ClearStatus"HeadMarker"
	end

	if TUPPMSettings.ui_disableWorldMarkers then
		TppUiStatusManager.SetStatus("WorldMarker","INVALID")
	else
		TppUiStatusManager.ClearStatus"WorldMarker"
	end

	--SOP(X-Ray) effect only sets during loading and not while in game :/ --Also from msg="FinishOpeningDemoOnHeli" for some reason(as it is an in-game point) as evidenced by Infinite Heaven
	if
		vars.missionCode==10240 --M43 explicitly disables the effect so continue to do the same
		or TUPPMSettings.ui_disableXrayMarkers
	then
		TppSoldier2.SetDisableMarkerModelEffect{enabled=true}
		--TppSoldier2.DisableMarkerModelEffect()
	else
		TppSoldier2.SetDisableMarkerModelEffect{enabled=false}
		--TppSoldier2.DisableMarkerModelEffect()
	end
end

---r67 UI elements changing for demos only
--This function only affects markers and X-ray effect and disables them after demos
function this.ChangeUIElementsForDemos()

	if TppMission.IsFOBMission(vars.missionCode) then return end

	if TUPPMSettings.ui_disableHeadMarkers then
		TppUiStatusManager.SetStatus("HeadMarker","INVALID")
	end

	if TUPPMSettings.ui_disableWorldMarkers then
		TppUiStatusManager.SetStatus("WorldMarker","INVALID")
	end

	if
		vars.missionCode==10240 --M43 explicitly disables the effect so continue to do the same
		or TUPPMSettings.ui_disableXrayMarkers
	then
		TppSoldier2.SetDisableMarkerModelEffect{enabled=true}
	end
end

---r67
--Modify tools upgrades
function this.ModifyToolsLevels()

	local function GetMaxToolLevel(toolType)
		local toolsToEquipIds={
			[TppEquip.EQP_IT_Binocle] = {14001,14003,14004,14005},
			[TppEquip.EQP_IT_IDroid] = {15001,15002,15003,15004},
		}
		local maxToolLevel = 0 --Default
		for _, toolEquipId in ipairs(toolsToEquipIds[toolType]) do
			if (TppMotherBaseManagement.IsEquipDevelopableWithDevelopID{equipDevelopID=toolEquipId}) then
				maxToolLevel=maxToolLevel+1
			end
		end
		return maxToolLevel
	end

	local toolTypesTable={
		TppEquip.EQP_IT_Binocle,
		TppEquip.EQP_IT_IDroid,
	}

	--Get and set max tool upgrade levels for all tool types the player has developed
	local maxToolTypeDeveloped={}
	for _,toolType in ipairs(toolTypesTable) do
		maxToolTypeDeveloped[toolType]=GetMaxToolLevel(toolType)
	end

	--Read tool levels from TUPPM settings
	--Also set default value of 4 and check range of 0-4
	local toolTypeSettings={
		[TppEquip.EQP_IT_Binocle] = math.min(math.max(TUPPMSettings.tool_intScope or 4,1),4),
		[TppEquip.EQP_IT_IDroid] = math.min(math.max(TUPPMSettings.tool_iDroid or 4,1),4),
	}

	--Set max tool level setting based on tool upgrades developed
	for _,toolType in ipairs(toolTypesTable) do
		toolTypeSettings[toolType] = math.min(toolTypeSettings[toolType],maxToolTypeDeveloped[toolType])
	end

	TUPPMLog.Log("maxToolTypeDeveloped:"..tostring(InfInspect.Inspect(maxToolTypeDeveloped)),3)
	TUPPMLog.Log("toolTypeSettings:"..tostring(InfInspect.Inspect(toolTypeSettings)),3)

	--Finally set the tool upgrade level for each type
	for _,toolType in ipairs(toolTypesTable) do
		Player.SetItemLevel(toolType,toolTypeSettings[toolType])
	end
end

---r67
--Modify hands upgrades
function this.ModifyHandsLevels()

	local function GetMaxHandLevel(handType)
		local handToEquipIds={
			[TppEquip.EQP_HAND_ACTIVESONAR] = {18030,18031,18032},
			[TppEquip.EQP_HAND_PHYSICAL] = {17002,17003,17004},
			[TppEquip.EQP_HAND_PRECISION] = {17011,17012,17013},
			[TppEquip.EQP_HAND_MEDICAL] = {17021,17022,17023},
		}
		local maxHandLevel = 0 --Default
		if TppMotherBaseManagement.IsEquipDeveloped{equipID=handType} then
			maxHandLevel=maxHandLevel+1
		end
		for _, handEquipId in ipairs(handToEquipIds[handType]) do
			if (TppMotherBaseManagement.IsEquipDevelopableWithDevelopID{equipDevelopID=handEquipId}) then
				maxHandLevel=maxHandLevel+1
			end
		end
		return maxHandLevel
	end

	local handTypesTable={
		TppEquip.EQP_HAND_ACTIVESONAR,
		TppEquip.EQP_HAND_PHYSICAL,
		TppEquip.EQP_HAND_PRECISION,
		TppEquip.EQP_HAND_MEDICAL,
	}

	--Get and set max hand upgrade levels for all hand types the player has developed
	local maxHandTypeDeveloped={}
	for _,handType in ipairs(handTypesTable) do
		maxHandTypeDeveloped[handType]=GetMaxHandLevel(handType)
	end

	--Read hand levels from TUPPM settings
	--Also set default value of 3 and check range of 0-3
	local handTypeSettings={
		[TppEquip.EQP_HAND_ACTIVESONAR] = math.min(math.max(TUPPMSettings.tool_bioArm_activeSonar or 3,0),3),
		[TppEquip.EQP_HAND_PHYSICAL] = math.min(math.max(TUPPMSettings.tool_bioArm_mobility or 3,0),3),
		[TppEquip.EQP_HAND_PRECISION] = math.min(math.max(TUPPMSettings.tool_bioArm_precision or 3,0),3),
		[TppEquip.EQP_HAND_MEDICAL] = math.min(math.max(TUPPMSettings.tool_bioArm_medical or 3,0),3),
	}

	--Set max hand level setting based on hand upgrades developed
	--0 is not developed
	--1 is a fake equipped (not shown as ON in dev menu) - evident by active sonar being present
	--2,3,4 correspond to upgrades 1,2,3 for hands
	for _,handType in ipairs(handTypesTable) do
		handTypeSettings[handType] = math.min(handTypeSettings[handType],maxHandTypeDeveloped[handType])
		if handTypeSettings[handType]~=0 then
			--If hand level setting is not 0 then increment by 1 to match actual value the game accepts
			--This skips the actual value of 1 (fake equipped) from being set
			handTypeSettings[handType]=handTypeSettings[handType]+1
		end
	end

	TUPPMLog.Log("maxHandTypeDeveloped:"..tostring(InfInspect.Inspect(maxHandTypeDeveloped)),3)
	TUPPMLog.Log("handTypeSettings:"..tostring(InfInspect.Inspect(handTypeSettings)),3)

	--Finally set the hand upgrade level for each type
	for _,handType in ipairs(handTypesTable) do
		Player.SetItemLevel(handType,handTypeSettings[handType])
	end
end
-----------------------------
--r63 Added the below functions for getting Update working, not sure if they are needed or not

function this.OnAllocate()end
function this.OnInitialize()end
function this.OnTerminate()end

---r63 Update func for each on screen frame
function this.Update()
	--r65 Using this as main Update func

	if not TUPPMSettings then return end

	this.ReloadModSettings()
	TppPlayer.EnableDisableDebugMode()

	--r51 Settings
	--Only assign an update function if it is switched on :)
	if TUPPMSettings.game_ENABLE_hideCredits then
		TppDemo.RemoveTelopFromDemos()
	end
	if TUPPMSettings.player_ENABLE_equipmentDropping then
		TppPlayer.DropCurrentWeaponOrItem()
	end
	if TUPPMSettings.player_ENABLE_stopRadioWhenPlayingCassette then
		TppPlayer.DisableAllRadioIfCassettePlaying()
	end
	if TUPPMSettings.time_ENABLE_customScale then
		TppPlayer.SetRealTime()
	end
	if TUPPMSettings.cheats_ENABLE then
		TppPlayer.UseCheatCodes()
	end
	--r62 Quick Save option
	if TUPPMSettings.cheats_ENABLE_quickSaveAnywhere then
		this.SaveAtCurrentLocation()
	end

	--this.SetCustomCamera() --TODO r65 Fixed update call, now try this
	--this.UpdateFixCameraRot() --rX65 Not very good workings

	--rX69 Code to show movement speed
	--this.ShowSpeed()
	
	--r70 Auto fulton soldiers
	this.AutoFultonSoldiers()
	
end


local keyToPadMapping={
	--This is how buttons should be mapped and checked for. String keys with PlayerPad masks
	["LIGHT_SWITCH"]=PlayerPad.LIGHT_SWITCH,
}

function this.playerPressed(pressedButton)
	if not keyToPadMapping[pressedButton] then return false end --> return if String index not present in keyToPadMapping
	return bit.band(PlayerVars.scannedButtonsDirect,keyToPadMapping[pressedButton])==keyToPadMapping[pressedButton]
end

this.localVar={
	playerPos={vars.playerPosX, vars.playerPosY, vars.playerPosZ},
	ride=false,
	oldTime=0
}

function this.ShowSpeed()

	if mvars.mis_missionStateIsNotInGame then return end --This is to ensure function runs only after title screen/in-game and playerPos data is available

	if ((Time.GetRawElapsedTimeSinceStartUp()-this.localVar.oldTime)>=1) then

		this.localVar.oldTime=Time.GetRawElapsedTimeSinceStartUp()
		local l={vars=vars}
		local m={floor=math.floor, sqrt=math.sqrt, ceil=math.ceil}


		local function playerSpeed(newPos)
			local op=this.localVar.playerPos
			local np=newPos
			local x,y,z=(np[1]-op[1]), (np[2]-op[2]), (np[3]-op[3])
			op=nil
			x=m.sqrt((x*x)+(y*y)+(z*z))
			y=nil
			x=(m.floor(x*10)*1e-1)
			local secondsInHour=60*60
			local metersInKm=1e3
			x=x*secondsInHour
			x=x/metersInKm
			secondsInHour=nil
			metersInKm=nil
			z=x%1
			if 0<z then
				if z<0.5 then
					x=(m.floor(x*10)*1e-1)
				else
					x=(m.ceil(x*10)*1e-1)
				end
			end
			TppUiCommand.AnnounceLogView("Speed is "..x.." KPH. If not here then done fucked up")
		end

		if this.playerPressed("LIGHT_SWITCH") then
			playerSpeed{l.vars.playerPosX, l.vars.playerPosY, l.vars.playerPosZ}
		end

		this.localVar.playerPos={l.vars.playerPosX, l.vars.playerPosY, l.vars.playerPosZ}
	end
end

---r70
--Joins two tables with simple value entries (not a deep join)
function this.joinTables(t1, t2)
   for k,v in ipairs(t2) do
      table.insert(t1, v)
   end 
   return t1
end

---r70
--Checks if staff id is female
function this.IsFemaleStaffId( staffId )
	local faceId = TppMotherBaseManagement.StaffIdToFaceId{ staffId=staffId }
	local faceTypeList = TppSoldierFace.CheckFemale{ face={faceId  } }
	return faceTypeList and faceTypeList[1] == 1
end

---r70
--Auto fulton soldiers added
function this.AutoFultonSoldiers()
	
	if not TUPPMSettings.fastFillStaff_ENABLE then return end
	if mvars.mis_missionStateIsNotInGame then return end

	if
		vars.missionCode == 1
		or vars.missionCode == 5
		or vars.missionCode == 60000
		or vars.missionCode == 50050
		or vars.missionCode == 30050
		or vars.missionCode == 30150
		or vars.missionCode == 30250
		or vars.missionCode == 40010
		or vars.missionCode == 40020
		or vars.missionCode == 40050
		or vars.missionCode == 40060
	then
		return
	end

	local actuallyAdded = 0
	local faceIdsTable={}

	if mvars.ene_soldierDefine then
		
		faceIdsTable = this.joinTables(TppEneFova.GetAllFaceIds(TppEneFova.maleFaceIdsUncommon), TppEneFova.GetAllFaceIds(TppEneFova.femaleFaceIds))

		if TUPPMSettings.fastFillStaff_ENABLE_maleOnly then
			faceIdsTable=TppEneFova.GetAllFaceIds(TppEneFova.maleFaceIdsUncommon)
		elseif TUPPMSettings.fastFillStaff_ENABLE_femaleOnly then
			faceIdsTable=TppEneFova.GetAllFaceIds(TppEneFova.femaleFaceIds)
		end
		
		for cpName, soldierNameList in pairs(mvars.ene_soldierDefine) do
			for _, soldierName in pairs(soldierNameList) do
				local gameObjectId = GameObject.GetGameObjectId("TppSoldier2", soldierName)
				if gameObjectId ~= GameObject.NULL_ID then
					local isFemaleStaffId = false
					local staffId = nil

					TppMain.Randomize()
					
					--This here is key to infinite adding of soldiers. Changing the face id on the game object, changes the staff id that is generated for some reason.
					--If face ids are not applied randomly, then male soldiers are only extracted once till the face ids (and hence staff ids run out). In such a case, the mission
					--needs to be restarted in order to add some more.
					--When DirectAddStaff adds a soldier it seems to be using staff id to do so, as a result randomizing the male face fovas leads to somewhat infinite adding
					--of staff
					--This is still not truely infinite as staff ids may still run out eventually and DirectAddStaff will stop adding more staff 
					local faceIndex=math.random(#faceIdsTable)
					local selectedFaceId=faceIdsTable[faceIndex]
					local changeToFaceFovaCommand={id="ChangeFova",faceId=selectedFaceId}
					GameObject.SendCommand(gameObjectId,changeToFaceFovaCommand) --Soldier faces are still male (don't think they even change during gameplay), no interrogation voice if female fova is applied, extraction leads to female :)
					
					TppMotherBaseManagement.RegenerateGameObjectStaffParameter{gameObjectId=gameObjectId}
					staffId=TppMotherBaseManagement.GetStaffIdFromGameObject{gameObjectId=gameObjectId}
					isFemaleStaffId=this.IsFemaleStaffId(staffId)
					
					local tableToDirectAddStaff={staffId=staffId,section="Wait",isNew=true,specialContract=false}
					TppMotherBaseManagement.DirectAddStaff(tableToDirectAddStaff)
					actuallyAdded=actuallyAdded+1
				end
			end
		end
	end
	
--	TUPPMLog.Log("Soldiers auto extracted: "..tostring(actuallyAdded)
--		..", femaleOnly: "..tostring(TUPPMSettings.fastFillStaff_ENABLE_femaleOnly),
--		2, true)
end

return this
