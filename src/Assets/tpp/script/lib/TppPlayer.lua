local this={}
local IsTypeFunc=Tpp.IsTypeFunc
local IsTypeTable=Tpp.IsTypeTable
local IsTypeString=Tpp.IsTypeString
local StrCode32=Fox.StrCode32
local GkEventTimerManagerStart=GkEventTimerManager.Start
local GkEventTimerManagerStop=GkEventTimerManager.Stop
local GetTypeIndex=GameObject.GetTypeIndex
local GetGameObjectId=GameObject.GetGameObjectId
local GetTypeIndexWithTypeName=GameObject.GetTypeIndexWithTypeName
local GAME_OBJECT_TYPE_SOLDIER2=TppGameObject.GAME_OBJECT_TYPE_SOLDIER2
local GAME_OBJECT_TYPE_HOSTAGE2=TppGameObject.GAME_OBJECT_TYPE_HOSTAGE2
local NULL_ID=GameObject.NULL_ID
local SendCommand=GameObject.SendCommand

this.MISSION_CLEAR_CAMERA_FADE_DELAY_TIME=3
this.MISSION_CLEAR_CAMERA_DELAY_TIME=0
this.PLAYER_FALL_DEAD_DELAY_TIME=.2
this.DisableAbilityList={
	Stand="DIS_ACT_STAND",
	Squat="DIS_ACT_SQUAT",
	Crawl="DIS_ACT_CRAWL",
	Dash="DIS_ACT_DASH"
}
this.ControlModeList={
	LockPadMode="All",
	LockMBTerminalOpenCloseMode="MB_Disable",
	MBTerminalOnlyMode="MB_OnlyMode"
}
this.CageRandomTableG1={
	{1,20},
	{0,80}
}
this.CageRandomTableG2={
	{2,15},
	{1,20},
	{0,65}
}
this.CageRandomTableG3={
	{4,5},
	{3,10},
	{2,15},
	{1,20},
	{0,50}
}
this.RareLevelList={
	"N",
	"NR",
	"R",
	"SR",
	"SSR"
}

function this.RegisterCallbacks(e)
	if IsTypeFunc(e.OnFultonIconDying)then
		mvars.ply_OnFultonIconDying=e.OnFultonIconDying
	end
end
function this.SetStartStatus(e)
	if(e>TppDefine.INITIAL_PLAYER_STATE.MIN)and(e<TppDefine.INITIAL_PLAYER_STATE.MAX)then
		gvars.ply_initialPlayerState=e
	end
end
function this.SetStartStatusRideOnHelicopter()
	this.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.RIDEON_HELICOPTER)
	this.ResetInitialPosition()
	this.ResetMissionStartPosition()
end
function this.ResetDisableAction()
	vars.playerDisableActionFlag=PlayerDisableAction.NONE
end
function this.GetPosition()
	return{vars.playerPosX,vars.playerPosY,vars.playerPosZ}
end
function this.GetRotation()
	return vars.playerRotY
end
function this.Warp(e)
	if not IsTypeTable(e)then
		return
	end
	local n=e.pos
	if not IsTypeTable(n)or(#n~=3)then
		return
	end
	local t=foxmath.NormalizeRadian(foxmath.DegreeToRadian(e.rotY or 0))
	local a
	if e.fobRespawn==true then
		a={type="TppPlayer2",index=PlayerInfo.GetLocalPlayerIndex()}
	else
		a={type="TppPlayer2",index=0}
	end
	local e={id="WarpAndWaitBlock",pos=n,rotY=t}
	GameObject.SendCommand(a,e)
end
function this.SetForceFultonPercent(a,e)
	if not Tpp.IsTypeNumber(a)then
		return
	end
	if not Tpp.IsTypeNumber(e)then
		return
	end
	if(a<0)or(a>=NULL_ID)then
		return
	end
	if(e<0)or(e>100)then
		return
	end
	mvars.ply_forceFultonPercent=mvars.ply_forceFultonPercent or{}
	mvars.ply_forceFultonPercent[a]=e
end

function this.ForceChangePlayerToSnake(resetOutfit)
	--r51 Settings
	--K do nothing now. Player model stays the same
	if not TUPPMSettings.player_ENABLE_ddSoldiersInCutscenes then
		vars.playerType=PlayerType.SNAKE
		if resetOutfit then
			vars.playerPartsType=PlayerPartsType.NORMAL
			vars.playerCamoType=PlayerCamoType.OLIVEDRAB
			vars.playerFaceEquipId=0
		else
			vars.playerPartsType=vars.sortiePrepPlayerSnakePartsType
			vars.playerCamoType=vars.sortiePrepPlayerSnakeCamoType
			vars.playerFaceEquipId=vars.sortiePrepPlayerSnakeFaceEquipId
		end
		Player.SetItemLevel(TppEquip.EQP_SUIT,vars.sortiePrepPlayerSnakeSuitLevel)
	end
end

function this.CheckRotationSetting(a)
	if not IsTypeTable(a)then
		return
	end
	local e=mvars
	e.ply_checkDirectionList={}
	e.ply_checkRotationResult={}
	local function n(a,t,e)
		if e>=-180 and e<180 then
			a[t]=e
		end
	end
	for a,t in pairs(a)do
		if IsTypeFunc(t.func)then
			e.ply_checkDirectionList[a]={}
			e.ply_checkDirectionList[a].func=t.func
			local o=t.directionX or 0
			local i=t.directionY or 0
			local r=t.directionRangeX or 0
			local t=t.directionRangeY or 0
			n(e.ply_checkDirectionList[a],"directionX",o)n(e.ply_checkDirectionList[a],"directionY",i)n(e.ply_checkDirectionList[a],"directionRangeX",r)n(e.ply_checkDirectionList[a],"directionRangeY",t)
		else
			return
		end
	end
end
function this.CheckRotation()
	local a=mvars
	if a.ply_checkDirectionList==nil then
		return
	end
	for t,n in pairs(a.ply_checkDirectionList)do
		local e=this._CheckRotation(n.directionX,n.directionRangeX,n.directionY,n.directionRangeY,t)
		if e~=a.ply_checkRotationResult[t]then
			a.ply_checkRotationResult[t]=e
			a.ply_checkDirectionList[t].func(e)
		end
	end
end
function this.IsDeliveryWarping()
	if mvars.ply_deliveryWarpState then
		return true
	else
		return false
	end
end
function this.GetStationUniqueId(e)
	if not IsTypeString(e)then
		return
	end
	local e="col_stat_"..e
	return TppCollection.GetUniqueIdByLocatorName(e)
end
function this.SetMissionStartPositionToCurrentPosition()
	gvars.ply_useMissionStartPos=true
	gvars.ply_missionStartPos[0]=vars.playerPosX
	gvars.ply_missionStartPos[1]=vars.playerPosY+.5
	gvars.ply_missionStartPos[2]=vars.playerPosZ
	gvars.ply_missionStartRot=vars.playerRotY
	gvars.mis_orderBoxName=0
	this.SetInitialPositionFromMissionStartPosition()
end
function this.SetNoOrderBoxMissionStartPosition(e,a)
	gvars.ply_useMissionStartPosForNoOrderBox=true
	gvars.ply_missionStartPosForNoOrderBox[0]=e[1]
	gvars.ply_missionStartPosForNoOrderBox[1]=e[2]
	gvars.ply_missionStartPosForNoOrderBox[2]=e[3]
	gvars.ply_missionStartRotForNoOrderBox=a
end
function this.SetNoOrderBoxMissionStartPositionToCurrentPosition()
	gvars.ply_useMissionStartPosForNoOrderBox=true
	gvars.ply_missionStartPosForNoOrderBox[0]=vars.playerPosX
	gvars.ply_missionStartPosForNoOrderBox[1]=vars.playerPosY+.5
	gvars.ply_missionStartPosForNoOrderBox[2]=vars.playerPosZ
	gvars.ply_missionStartRotForNoOrderBox=vars.playerRotY
end
function this.SetMissionStartPosition(e,a)
	gvars.ply_useMissionStartPos=true
	gvars.ply_missionStartPos[0]=e[1]
	gvars.ply_missionStartPos[1]=e[2]
	gvars.ply_missionStartPos[2]=e[3]
	gvars.ply_missionStartRot=a
end
function this.ResetMissionStartPosition()
	gvars.ply_useMissionStartPos=false
	gvars.ply_missionStartPos[0]=0
	gvars.ply_missionStartPos[1]=0
	gvars.ply_missionStartPos[2]=0
	gvars.ply_missionStartRot=0
end
function this.ResetNoOrderBoxMissionStartPosition()
	gvars.ply_useMissionStartPosForNoOrderBox=false
	gvars.ply_missionStartPosForNoOrderBox[0]=0
	gvars.ply_missionStartPosForNoOrderBox[1]=0
	gvars.ply_missionStartPosForNoOrderBox[2]=0
	gvars.ply_missionStartRotForNoOrderBox=0
end
function this.SetMissionStartPositionFromNoOrderBoxPosition()
	if gvars.ply_useMissionStartPosForNoOrderBox then
		gvars.ply_useMissionStartPos=true
		gvars.ply_missionStartPos[0]=gvars.ply_missionStartPosForNoOrderBox[0]
		gvars.ply_missionStartPos[1]=gvars.ply_missionStartPosForNoOrderBox[1]
		gvars.ply_missionStartPos[2]=gvars.ply_missionStartPosForNoOrderBox[2]
		gvars.ply_missionStartRot=gvars.ply_missionStartRotForNoOrderBox
		this.ResetNoOrderBoxMissionStartPosition()
	end
end
function this.DEBUG_CheckNearMissionStartPositionToRealizePosition()
	if gvars.ply_useMissionStartPos then
		local e
		if TppLocation.IsMotherBase()then
			e=1e3*1e3
		else
			e=64*64
		end
		local a=gvars.ply_missionStartPos[0]-vars.playerPosX
		local t=gvars.ply_missionStartPos[2]-vars.playerPosZ
		local a=(a*a)+(t*t)
		if(a>e)then
			return true
		else
			return false
		end
	else
		return false
	end
end
function this.SetInitialPositionToCurrentPosition()
	vars.initialPlayerFlag=PlayerFlag.USE_VARS_FOR_INITIAL_POS
	vars.initialPlayerPosX=vars.playerPosX
	vars.initialPlayerPosY=vars.playerPosY+.5
	vars.initialPlayerPosZ=vars.playerPosZ
	vars.initialPlayerRotY=vars.playerRotY
end
function this.SetInitialPosition(e,a)
	vars.initialPlayerFlag=PlayerFlag.USE_VARS_FOR_INITIAL_POS
	vars.initialPlayerPosX=e[1]
	vars.initialPlayerPosY=e[2]
	vars.initialPlayerPosZ=e[3]
	vars.initialPlayerRotY=a
end
function this.SetInitialPositionFromMissionStartPosition()
	if gvars.ply_useMissionStartPos then
		vars.initialPlayerFlag=PlayerFlag.USE_VARS_FOR_INITIAL_POS
		vars.initialPlayerPosX=gvars.ply_missionStartPos[0]
		vars.initialPlayerPosY=gvars.ply_missionStartPos[1]
		vars.initialPlayerPosZ=gvars.ply_missionStartPos[2]
		vars.initialPlayerRotY=gvars.ply_missionStartRot
		vars.playerCameraRotation[0]=0
		vars.playerCameraRotation[1]=gvars.ply_missionStartRot
	end
end
function this.ResetInitialPosition()
	vars.initialPlayerFlag=0
	vars.initialPlayerPosX=0
	vars.initialPlayerPosY=0
	vars.initialPlayerPosZ=0
	vars.initialPlayerRotY=0
end
function this.FailSafeInitialPositionForFreePlay()
	if not((vars.missionCode==30010)or(vars.missionCode==30020))then
		return
	end
	if vars.initialPlayerFlag~=PlayerFlag.USE_VARS_FOR_INITIAL_POS then
		return
	end
	if(((vars.initialPlayerPosX>3500)or(vars.initialPlayerPosX<-3500))or(vars.initialPlayerPosZ>3500))or(vars.initialPlayerPosZ<-3500)then
		local e={[30010]={1448.61,337.787,1466.4},[30020]={-510.73,5.09,1183.02}}
		local e=e[vars.missionCode]
		vars.initialPlayerPosX,vars.initialPlayerPosY,vars.initialPlayerPosZ=e[1],e[2],e[3]
	end
end
function this.RegisterTemporaryPlayerType(e)
	if not IsTypeTable(e)then
		return
	end
	--K very important variable. Decides whether to load Snake in certain missions and Subsitence mission equipment as well.
	mvars.ply_isExistTempPlayerType=true
	local a=e.camoType
	local n=e.partsType
	local t=e.playerType
	local r=e.handEquip
	local e=e.faceEquipId
	if n then
		mvars.ply_tempPartsType=n
	end
	if a then
		mvars.ply_tempCamoType=a
	end
	if t then
		mvars.ply_tempPlayerType=t
	end
	if r then
		mvars.ply_tempPlayerHandEquip=r
	end
	if e then
		mvars.ply_tempPlayerFaceEquipId=e
	end
end
function this.SaveCurrentPlayerType()
	if not gvars.ply_isUsingTempPlayerType then
		gvars.ply_lastPlayerPartsTypeUsingTemp=vars.playerPartsType
		gvars.ply_lastPlayerCamoTypeUsingTemp=vars.playerCamoType
		gvars.ply_lastPlayerHandTypeUsingTemp=vars.handEquip
		gvars.ply_lastPlayerTypeUsingTemp=vars.playerType
		gvars.ply_lastPlayerFaceIdUsingTemp=vars.playerFaceId
		gvars.ply_lastPlayerFaceEquipIdUsingTemp=vars.playerFaceEquipId
	end
	gvars.ply_isUsingTempPlayerType=true
end

function this.ApplyTemporaryPlayerType()
	if mvars.ply_tempPartsType
	then
		vars.playerPartsType=mvars.ply_tempPartsType
	end

	if mvars.ply_tempCamoType
	then
		vars.playerCamoType=mvars.ply_tempCamoType
	end

	if mvars.ply_tempPlayerType
	then
		vars.playerType=mvars.ply_tempPlayerType
	end

	if mvars.ply_tempPlayerHandEquip
	then
		vars.handEquip=mvars.ply_tempPlayerHandEquip
	end

	if mvars.ply_tempPlayerFaceEquipId
	then
		vars.playerFaceEquipId=mvars.ply_tempPlayerFaceEquipId
	end
end

function this.RestoreTemporaryPlayerType()
	if gvars.ply_isUsingTempPlayerType then
		--K Do nothing here
		-- Messing here will likely break player model type loading
		-- I experienced a reset to Snake soemtimes but with missing body camo, just a floating head and chest!
		-- This is immediately evident after exiting Custom Avatar editing screen of all places!
		-- Not sure how to go about messing here
		vars.playerPartsType=gvars.ply_lastPlayerPartsTypeUsingTemp
		vars.playerCamoType=gvars.ply_lastPlayerCamoTypeUsingTemp
		vars.playerType=gvars.ply_lastPlayerTypeUsingTemp
		vars.playerFaceId=gvars.ply_lastPlayerFaceIdUsingTemp
		vars.playerFaceEquipId=gvars.ply_lastPlayerFaceEquipIdUsingTemp
		vars.handEquip=gvars.ply_lastPlayerHandTypeUsingTemp
		gvars.ply_lastPlayerPartsTypeUsingTemp=PlayerPartsType.NORMAL_SCARF
		gvars.ply_lastPlayerCamoTypeUsingTemp=PlayerCamoType.OLIVEDRAB
		gvars.ply_lastPlayerTypeUsingTemp=PlayerType.SNAKE
		gvars.ply_lastPlayerFaceIdUsingTemp=0
		gvars.ply_lastPlayerFaceEquipIdUsingTemp=0
		gvars.ply_isUsingTempPlayerType=false --K Keep this false to avoid resetting to Snake
		gvars.ply_lastPlayerHandTypeUsingTemp=TppEquip.EQP_HAND_NORMAL
	end
end

function this.SetWeapons(a)
	--TUPPMLog.Log("inside *SetWeapons*")
	this._SetWeapons(a,"weapons")
end

function this.SetInitWeapons(a)
	if gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_RECUE_MILLER then
		this.SaveWeaponsToUsingTemp(a)
	end

	--  --rX50 M2, M43 do not reset initial player weapons and items - use any weapons during these missions
	-- Lol M2 won't let you use hip and back weapons, M43 has no collision for stun weapons
	--	if
	--		( TppStory.IsMissionCleard( 10020 ) )
	----		and not (vars.missionCode==10010 or vars.missionCode==10280)
	--		and not TppMission.IsSubsistenceMission()
	--	then
	--		return
	--	end

	this._SetWeapons(a,"initWeapons")
end

function this._SetWeapons(weaponsTable,weaponsString)
	--TUPPMLog.Log("inside _SetWeapons")
	if not IsTypeTable(weaponsTable)then
		return
	end
	local supportItemCount=TppDefine.WEAPONSLOT.SUPPORT_0-1
	local weapon,name,magazineType,ammo,underBarrelAmmo
	for s,l in pairs(weaponsTable)do
		--    TUPPMLog.Log("s="..tostring(s))
		--    TUPPMLog.Log("l="..tostring(l))
		weapon,supportItemCount,name,magazineType,ammo,underBarrelAmmo=this.GetWeaponSlotInfoFromWeaponSet(l,supportItemCount)
		local localType=TppEquip[name]
		if localType==nil then
		else
			local p,c,l,s,d,T=TppEquip.GetAmmoInfo(localType)
			if weapon then
				vars[weaponsString][weapon]=localType
				local e,t
				if magazineType then
					e=magazineType*c
				elseif ammo then
					e=ammo
				else
					e=l
				end
				gvars.initAmmoStockIds[weapon]=p
				gvars.initAmmoStockCounts[weapon]=e
				gvars.initAmmoInWeapons[weapon]=c
				if(s~=TppEquip.BL_None)then
					if underBarrelAmmo then
						t=underBarrelAmmo
					else
						t=T
					end
					gvars.initAmmoStockIds[weapon+TppDefine.WEAPONSLOT.MAX]=s
					gvars.initAmmoStockCounts[weapon+TppDefine.WEAPONSLOT.MAX]=t
					gvars.initAmmoSubInWeapons[weapon]=d
				end
				if weaponsString=="initWeapons"then
					vars.isInitialWeapon[weapon]=1
				end
			elseif supportItemCount>=TppDefine.WEAPONSLOT.SUPPORT_0 and supportItemCount<=TppDefine.WEAPONSLOT.SUPPORT_7 then
				local e=supportItemCount-TppDefine.WEAPONSLOT.SUPPORT_0
				vars.initSupportWeapons[e]=localType
				gvars.initAmmoStockIds[supportItemCount]=p
				local e
				if ammo then
					e=ammo
				else
					e=l
				end
				gvars.initAmmoStockCounts[supportItemCount]=e
			end
		end
	end
end

function this.GetWeaponSlotInfoFromWeaponSet(e,supportItemCount)
	--TUPPMLog.Log("inside GetWeaponSlotInfoFromWeaponSet")
	local weapon,name,magazineType,ammo,underBarrelAmmo
	if e.primaryHip then
		weapon=TppDefine.WEAPONSLOT.PRIMARY_HIP
		name=e.primaryHip
		magazineType=e.magazine
		ammo=e.ammo
		underBarrelAmmo=e.underBarrelAmmo
		--TUPPMLog.Log("primaryHip="..tostring(weapon))
		--TUPPMLog.Log("type="..tostring(name))
	elseif e.primaryBack then
		weapon=TppDefine.WEAPONSLOT.PRIMARY_BACK
		name=e.primaryBack
		magazineType=e.magazine
		ammo=e.ammo
		--TUPPMLog.Log("primaryBack="..tostring(weapon))
		--TUPPMLog.Log("type="..tostring(name))
	elseif e.secondary then
		weapon=TppDefine.WEAPONSLOT.SECONDARY
		name=e.secondary
		magazineType=e.magazine
		ammo=e.ammo
		--TUPPMLog.Log("secondary="..tostring(weapon))
		--TUPPMLog.Log("type="..tostring(name))
	elseif e.support then
		supportItemCount=supportItemCount+1
		name=e.support
		ammo=e.ammo
		--TUPPMLog.Log("support="..tostring(weapon))
		--TUPPMLog.Log("type="..tostring(name))
	end
	return weapon,supportItemCount,name,magazineType,ammo,underBarrelAmmo
end

function this.SaveWeaponsToUsingTemp(n)
	--TUPPMLog.Log("inside SaveWeaponsToUsingTemp")
	if gvars.ply_isUsingTempWeapons then
		return
	end
	if not IsTypeTable(n)then
		return
	end
	for e=0,11 do
		gvars.ply_lastWeaponsUsingTemp[e]=TppEquip.EQP_None
	end
	local t
	local a=TppDefine.WEAPONSLOT.SUPPORT_0-1
	for r,n in pairs(n)do
		t,a=this.GetWeaponSlotInfoFromWeaponSet(n,a)
		if t then
			gvars.ply_lastWeaponsUsingTemp[t]=vars.initWeapons[t]
		elseif a>=TppDefine.WEAPONSLOT.SUPPORT_0 and a<=TppDefine.WEAPONSLOT.SUPPORT_7 then
			local e=a-TppDefine.WEAPONSLOT.SUPPORT_0
			gvars.ply_lastWeaponsUsingTemp[a]=vars.initSupportWeapons[e]
		end
	end
	gvars.ply_isUsingTempWeapons=true
end

function this.RestoreWeaponsFromUsingTemp()
	if not gvars.ply_isUsingTempWeapons then
		return
	end
	for a=0,11 do
		if gvars.ply_lastWeaponsUsingTemp[a]~=TppEquip.EQP_None then
			if a>=TppDefine.WEAPONSLOT.SUPPORT_0 and a<=TppDefine.WEAPONSLOT.SUPPORT_7 then
				local e=a-TppDefine.WEAPONSLOT.SUPPORT_0
				vars.initSupportWeapons[e]=gvars.ply_lastWeaponsUsingTemp[a]
			else
				vars.initWeapons[a]=gvars.ply_lastWeaponsUsingTemp[a]
			end
			local i,l,r,o,n,t=TppEquip.GetAmmoInfo(gvars.ply_lastWeaponsUsingTemp[a])this.SupplyAmmoByBulletId(i,r)
			gvars.initAmmoInWeapons[a]=l
			this.SupplyAmmoByBulletId(o,t)
			gvars.initAmmoSubInWeapons[a]=n
		end
	end
	for e=0,11 do
		gvars.ply_lastWeaponsUsingTemp[e]=TppEquip.EQP_None
	end
	gvars.ply_isUsingTempWeapons=false
	return true
end

function this.SetItems(a)
	if not IsTypeTable(a)then
		return
	end
	for t,a in ipairs(a)do
		if TppEquip[a]==nil then
			return
		end
	end
	this._SetItems(a,"items")
end

function this.SetInitItems(a)
	if not IsTypeTable(a)then
		return
	end
	for a,e in ipairs(a)do
		if TppEquip[e]==nil then
			return
		end
	end
	if gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_RECUE_MILLER then
		this.SaveItemsToUsingTemp(a)
	end

	--  --rX50 M2, M43 do not reset initial player weapons and items - use any weapons during these missions
	-- Lol M2 won't let you use hip and back weapons, M43 has no collision for stun weapons
	--	if
	--		( TppStory.IsMissionCleard( 10020 ) )
	----		and not (vars.missionCode==10010 or vars.missionCode==10280)
	--		and not TppMission.IsSubsistenceMission()
	--	then
	--		return
	--	end

	this._SetItems(a,"initItems")
end

function this._SetItems(a,e)
	vars[e][0]=TppEquip.EQP_None
	for t,a in pairs(a)do
		vars[e][t]=TppEquip[a]
	end
end

function this.SaveItemsToUsingTemp(a)
	if gvars.ply_isUsingTempItems then
		return
	end
	for e=0,7 do
		gvars.ply_lastItemsUsingTemp[e]=TppEquip.EQP_None
	end
	for e,a in pairs(a)do
		if e<8 then
			gvars.ply_lastItemsUsingTemp[e]=vars.initItems[e]
		end
	end
	gvars.ply_isUsingTempItems=true
end

function this.RestoreItemsFromUsingTemp()
	if not gvars.ply_isUsingTempItems then
		return
	end
	for e=1,7 do
		if gvars.ply_lastItemsUsingTemp[e]~=TppEquip.EQP_None then
			vars.initItems[e]=gvars.ply_lastItemsUsingTemp[e]
		end
	end
	for e=0,7 do
		gvars.ply_lastItemsUsingTemp[e]=TppEquip.EQP_None
	end
	gvars.ply_isUsingTempItems=false
end

function this.InitItemStockCount()
	if TppScriptVars.PLAYER_AMMO_STOCK_TYPE_COUNT==nil then
		return
	end
	for e=AmmoStockIndex.ITEM,AmmoStockIndex.ITEM_END-1 do
		vars.ammoStockIds[e]=0
		vars.ammoStockCounts[e]=0
	end
end

function this.GetBulletNum(a)
	for e=0,TppScriptVars.PLAYER_AMMO_STOCK_TYPE_COUNT-1 do
		if(a~=nil and a==vars.ammoStockIds[e])then
			return vars.ammoStockCounts[e]
		end
	end
	return 0
end

function this.SavePlayerCurrentWeapons()
	if not vars.initWeapons then
		return
	end

	vars.initWeapons[TppDefine.WEAPONSLOT.PRIMARY_HIP]=vars.weapons[TppDefine.WEAPONSLOT.PRIMARY_HIP]
	if TppDefine.HONEY_BEE_EQUIP_ID~=vars.weapons[TppDefine.WEAPONSLOT.PRIMARY_BACK]then
		vars.initWeapons[TppDefine.WEAPONSLOT.PRIMARY_BACK]=vars.weapons[TppDefine.WEAPONSLOT.PRIMARY_BACK]
	else
		vars.initWeapons[TppDefine.WEAPONSLOT.PRIMARY_BACK]=TppEquip.EPQ_None
	end
	vars.initWeapons[TppDefine.WEAPONSLOT.SECONDARY]=vars.weapons[TppDefine.WEAPONSLOT.SECONDARY]
	vars.initHandEquip=vars.handEquip
	for a=0,7 do
		vars.initSupportWeapons[a]=vars.supportWeapons[a]
	end
	this.SaveChimeraWeaponParameter()
end

function this.RestorePlayerWeaponsOnMissionStart()
	if not vars.initWeapons then
		return
	end
	vars.weapons[TppDefine.WEAPONSLOT.PRIMARY_HIP]=vars.initWeapons[TppDefine.WEAPONSLOT.PRIMARY_HIP]
	vars.weapons[TppDefine.WEAPONSLOT.PRIMARY_BACK]=vars.initWeapons[TppDefine.WEAPONSLOT.PRIMARY_BACK]
	vars.weapons[TppDefine.WEAPONSLOT.SECONDARY]=vars.initWeapons[TppDefine.WEAPONSLOT.SECONDARY]
	vars.handEquip=vars.initHandEquip
	for e=0,7 do
		vars.supportWeapons[e]=vars.initSupportWeapons[e]
	end

end

function this.SaveChimeraWeaponParameter()
	if not vars.initCustomizedWeapon then
		return
	end
	for e=0,2 do
		vars.initCustomizedWeapon[e]=vars.customizedWeapon[e]
	end
	for e=0,32 do
		vars.initChimeraParts[e]=vars.chimeraParts[e]
	end
end

function this.RestoreChimeraWeaponParameter()
	if not vars.initCustomizedWeapon then
		return
	end
	for e=0,2 do
		vars.customizedWeapon[e]=vars.initCustomizedWeapon[e]
	end
	for e=0,32 do
		vars.chimeraParts[e]=vars.initChimeraParts[e]
	end
end

function this.SavePlayerCurrentItems()
	for e=0,7 do
		vars.initItems[e]=vars.items[e]
	end
end

function this.RestorePlayerItemsOnMissionStart()
	for e=0,7 do
		vars.items[e]=vars.initItems[e]
	end
end

function this.ForceSetAllInitialWeapon()
	vars.isInitialWeapon[TppDefine.WEAPONSLOT.PRIMARY_HIP]=1
	vars.isInitialWeapon[TppDefine.WEAPONSLOT.PRIMARY_BACK]=1
	vars.isInitialWeapon[TppDefine.WEAPONSLOT.SECONDARY]=1
end

function this.SupplyAllAmmoFullOnMissionFinalize()
	local a={TppDefine.WEAPONSLOT.PRIMARY_HIP,TppDefine.WEAPONSLOT.PRIMARY_BACK,TppDefine.WEAPONSLOT.SECONDARY}
	for t,a in ipairs(a)do
		this.SupplyWeaponAmmoFull(a)
	end
	for a=0,3 do
		local a=vars.initSupportWeapons[a]
		if a~=TppEquip.EQP_None then
			this.SupplySupportWeaponAmmoFull(a)
		end
	end
end

function this.SupplyWeaponAmmoFull(a)
	local t=vars.initWeapons[a]
	if t==TppEquip.EQP_None then
		return
	end
	local n,r,i,o,l,t=TppEquip.GetAmmoInfo(t)this.SupplyAmmoByBulletId(n,i)
	gvars.initAmmoInWeapons[a]=r
	this.SupplyAmmoByBulletId(o,t)
	gvars.initAmmoSubInWeapons[a]=l
end
function this.SupplySupportWeaponAmmoFull(a)
	local t,n,a,n,n,n=TppEquip.GetAmmoInfo(a)this.SupplyAmmoByBulletId(t,a)
end
function this.SupplyAmmoByBulletId(t,n)
	if t==TppEquip.BL_None then
		return
	end
	local e
	for a=0,TppScriptVars.PLAYER_AMMO_STOCK_TYPE_COUNT-1 do
		if gvars.initAmmoStockIds[a]==t then
			e=a
			break
		end
	end
	if not e then
		for a=0,TppScriptVars.PLAYER_AMMO_STOCK_TYPE_COUNT-1 do
			if gvars.initAmmoStockIds[a]==TppEquip.BL_None then
				gvars.initAmmoStockIds[a]=t
				e=a
				break
			end
		end
	end
	if not e then
		return
	end
	gvars.initAmmoStockCounts[e]=n
end
function this.SavePlayerCurrentAmmoCount()
	for e=0,TppScriptVars.PLAYER_AMMO_STOCK_TYPE_COUNT-1 do
		gvars.initAmmoStockIds[e]=vars.ammoStockIds[e]
		gvars.initAmmoStockCounts[e]=vars.ammoStockCounts[e]
	end
	local e={TppDefine.WEAPONSLOT.PRIMARY_HIP,TppDefine.WEAPONSLOT.PRIMARY_BACK,TppDefine.WEAPONSLOT.SECONDARY}
	for a,e in ipairs(e)do
		gvars.initAmmoInWeapons[e]=vars.ammoInWeapons[e]
		gvars.initAmmoSubInWeapons[e]=vars.ammoSubInWeapons[e]
	end
end
function this.SetMissionStartAmmoCount()
	for e=0,TppScriptVars.PLAYER_AMMO_STOCK_TYPE_COUNT-1 do
		vars.ammoStockIds[e]=gvars.initAmmoStockIds[e]
		vars.ammoStockCounts[e]=gvars.initAmmoStockCounts[e]
	end
	local e={
		TppDefine.WEAPONSLOT.PRIMARY_HIP,
		TppDefine.WEAPONSLOT.PRIMARY_BACK,
		TppDefine.WEAPONSLOT.SECONDARY
	}
	for a,e in ipairs(e)do
		vars.ammoInWeapons[e]=gvars.initAmmoInWeapons[e]
		vars.ammoSubInWeapons[e]=gvars.initAmmoSubInWeapons[e]
	end
end

function this.SetEquipMissionBlockGroupSize()
	local e=mvars.ply_equipMissionBlockGroupSize
	if e>0 then
		TppEquip.CreateEquipMissionBlockGroup{size=e}
	end
end
function this.SetMaxPickableLocatorCount()
	if mvars.ply_maxPickableLocatorCount>0 then
		TppPickable.OnAllocate{locators=mvars.ply_maxPickableLocatorCount,svarsName="ply_pickableLocatorDisabled"}
	end
end
function this.SetMaxPlacedLocatorCount()
	if mvars.ply_maxPlacedLocatorCount>0 then
		TppPlaced.OnAllocate{locators=mvars.ply_maxPlacedLocatorCount,svarsName="ply_placedLocatorDisabled"}
	end
end
function this.IsDecoy(e)
	local a=TppEquip.GetSupportWeaponTypeId(e)
	local e={[TppEquip.SWP_TYPE_Decoy]=true,[TppEquip.SWP_TYPE_ActiveDecoy]=true,[TppEquip.SWP_TYPE_ShockDecoy]=true}
	if e[a]then
		return true
	else
		return false
	end
end
function this.IsMine(e)
	local e=TppEquip.GetSupportWeaponTypeId(e)
	local a={[TppEquip.SWP_TYPE_DMine]=true,[TppEquip.SWP_TYPE_SleepingGusMine]=true,[TppEquip.SWP_TYPE_AntitankMine]=true,[TppEquip.SWP_TYPE_ElectromagneticNetMine]=true}
	if a[e]then
		return true
	else
		return false
	end
end
function this.AddTrapSettingForIntel(t)
	local n=t.trapName
	local s=t.direction or 0
	local p=t.directionRange or 60
	local e=t.intelName
	local m=t.autoIcon
	local r=t.gotFlagName
	local o=t.markerTrapName
	local i=t.markerObjectiveName
	local c=t.identifierName
	local t=t.locatorName
	if not IsTypeString(n)then
		return
	end
	mvars.ply_intelTrapInfo=mvars.ply_intelTrapInfo or{}
	if e then
		mvars.ply_intelTrapInfo[e]={trapName=n}
	else
		return
	end
	mvars.ply_intelNameReverse=mvars.ply_intelNameReverse or{}
	mvars.ply_intelNameReverse[StrCode32(e)]=e
	mvars.ply_intelFlagInfo=mvars.ply_intelFlagInfo or{}
	if r then
		mvars.ply_intelFlagInfo[e]=r
		mvars.ply_intelFlagInfo[StrCode32(e)]=r
		mvars.ply_intelTrapInfo[e].gotFlagName=r
	end
	mvars.ply_intelMarkerObjectiveName=mvars.ply_intelMarkerObjectiveName or{}
	if i then
		mvars.ply_intelMarkerObjectiveName[e]=i
		mvars.ply_intelMarkerObjectiveName[StrCode32(e)]=i
		mvars.ply_intelTrapInfo[e].markerObjectiveName=i
	end
	mvars.ply_intelMarkerTrapList=mvars.ply_intelMarkerTrapList or{}
	mvars.ply_intelMarkerTrapInfo=mvars.ply_intelMarkerTrapInfo or{}
	if o then
		table.insert(mvars.ply_intelMarkerTrapList,o)
		mvars.ply_intelMarkerTrapInfo[StrCode32(o)]=e
		mvars.ply_intelTrapInfo[e].markerTrapName=o
	end
	mvars.ply_intelTrapList=mvars.ply_intelTrapList or{}
	if m then
		table.insert(mvars.ply_intelTrapList,n)
		mvars.ply_intelTrapInfo[StrCode32(n)]=e
		mvars.ply_intelTrapInfo[e].autoIcon=true
	end
	if c and t then
		local a,e=Tpp.GetLocator(c,t)
		if a and e then
			s=e
		end
	end
	mvars.ply_intelTrapInfo[e].direction=s
	mvars.ply_intelTrapInfo[e].directionRange=p
	Player.AddTrapDetailCondition{trapName=n,condition=PlayerTrap.FINE,action=(PlayerTrap.NORMAL+PlayerTrap.BEHIND),stance=(PlayerTrap.STAND+PlayerTrap.SQUAT),direction=s,directionRange=p}
end
function this.ShowIconForIntel(e,n)
	if not IsTypeString(e)then
		return
	end
	local t
	if mvars.ply_intelTrapInfo and mvars.ply_intelTrapInfo[e]then
		t=mvars.ply_intelTrapInfo[e].trapName
	end
	local a=mvars.ply_intelFlagInfo[e]
	if a then
		if svars[a]~=nil then
			n=svars[a]
		end
	end
	if not n then
		if Tpp.IsNotAlert()then
			Player.RequestToShowIcon{type=ActionIcon.ACTION,icon=ActionIcon.INTEL,message=Fox.StrCode32"GetIntel",messageInDisplay=Fox.StrCode32"IntelIconInDisplay",messageArg=e}
		elseif t then
			Player.RequestToShowIcon{type=ActionIcon.ACTION,icon=ActionIcon.INTEL_NG,message=Fox.StrCode32"NGIntel",messageInDisplay=Fox.StrCode32"IntelIconInDisplay",messageArg=e}
			if not TppRadio.IsPlayed(TppRadio.COMMON_RADIO_LIST[TppDefine.COMMON_RADIO.CANNOT_GET_INTEL_ON_ALERT])then
				TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.CANNOT_GET_INTEL_ON_ALERT)
			end
		end
	end
end
function this.GotIntel(a)
	local e=mvars.ply_intelFlagInfo[a]
	if not e then
		return
	end
	if svars[e]~=nil then
		svars[e]=true
	end
	local e=mvars.ply_intelMarkerObjectiveName[a]
	if e then
		local a=TppMission.GetParentObjectiveName(e)
		local e={}
		for a,t in pairs(a)do
			table.insert(e,a)
		end
		TppMission.UpdateObjective{objectives=e}
	end
end
function this.HideIconForIntel()Player.RequestToHideIcon{type=ActionIcon.ACTION,icon=ActionIcon.INTEL}Player.RequestToHideIcon{type=ActionIcon.ACTION,icon=ActionIcon.INTEL_NG}
end
function this.AddTrapSettingForQuest(e)
	local t=e.trapName
	local n=e.direction or 0
	local r=e.directionRange or 180
	local e=e.questName
	if not IsTypeString(t)then
		return
	end
	mvars.ply_questStartTrapInfo=mvars.ply_questStartTrapInfo or{}
	if e then
		mvars.ply_questStartTrapInfo[e]={trapName=t}
	else
		return
	end
	mvars.ply_questNameReverse=mvars.ply_questNameReverse or{}
	mvars.ply_questNameReverse[StrCode32(e)]=e
	mvars.ply_questStartFlagInfo=mvars.ply_questStartFlagInfo or{}
	mvars.ply_questStartFlagInfo[e]=false
	mvars.ply_questTrapList=mvars.ply_questTrapList or{}table.insert(mvars.ply_questTrapList,t)
	mvars.ply_questStartTrapInfo[StrCode32(t)]=e
	Player.AddTrapDetailCondition{trapName=t,condition=PlayerTrap.FINE,action=PlayerTrap.NORMAL,stance=(PlayerTrap.STAND+PlayerTrap.SQUAT),direction=n,directionRange=r}
end
function this.ShowIconForQuest(e,a)
	if not IsTypeString(e)then
		return
	end
	local t
	if mvars.ply_questStartTrapInfo and mvars.ply_questStartTrapInfo[e]then
		t=mvars.ply_questStartTrapInfo[e].trapName
	end
	if mvars.ply_questStartFlagInfo[e]~=nil then
		a=mvars.ply_questStartFlagInfo[e]
	end
	if not a then
		Player.RequestToShowIcon{type=ActionIcon.ACTION,icon=ActionIcon.TRAINING,message=Fox.StrCode32"QuestStarted",messageInDisplay=Fox.StrCode32"QuestIconInDisplay",messageArg=e}
	end
end
function this.QuestStarted(a)
	local a=mvars.ply_questNameReverse[a]
	if mvars.ply_questStartFlagInfo[a]~=nil then
		mvars.ply_questStartFlagInfo[a]=true
	end
	this.HideIconForQuest()
end
function this.HideIconForQuest()Player.RequestToHideIcon{type=ActionIcon.ACTION,icon=ActionIcon.TRAINING}
end
function this.ResetIconForQuest(e)
	mvars.ply_questStartFlagInfo.ShootingPractice=false
end
function this.AppearHorseOnMissionStart(a,e)
	local e,a=Tpp.GetLocator(a,e)
	if e then
		vars.buddyType=BuddyType.HORSE
		vars.initialBuddyPos[0]=e[1]
		vars.initialBuddyPos[1]=e[2]
		vars.initialBuddyPos[2]=e[3]
	end
end
function this.StartGameOverCamera(t,a,e)
	if mvars.ply_gameOverCameraGameObjectId~=nil then
		return
	end
	mvars.ply_gameOverCameraGameObjectId=t
	mvars.ply_gameOverCameraStartTimerName=a
	mvars.ply_gameOverCameraAnnounceLog=e
	TppUiStatusManager.SetStatus("AnnounceLog","INVALID_LOG")
	TppSound.PostJingleOnGameOver()
	TppSoundDaemon.PostEvent"sfx_s_force_camera_out"vars.playerDisableActionFlag=PlayerDisableAction.SUBJECTIVE_CAMERA
	GkEventTimerManagerStart("Timer_StartGameOverCamera",.25)
end
function this._StartGameOverCamera(e,e)
	TppUiStatusManager.ClearStatus"AnnounceLog"FadeFunction.SetFadeColor(64,0,0,255)
	TppUI.FadeOut(TppUI.FADE_SPEED.FADE_HIGHSPEED,mvars.ply_gameOverCameraStartTimerName,nil,{exceptGameStatus={AnnounceLog=false}})Player.RequestToSetCameraFocalLengthAndDistance{focalLength=16,interpTime=TppUI.FADE_SPEED.FADE_HIGHSPEED}
end
function this.PrepareStartGameOverCamera()FadeFunction.ResetFadeColor()
	local e={}
	for a,t in pairs(TppDefine.GAME_STATUS_TYPE_ALL)do
		e[a]=false
	end
	for a,t in pairs(TppDefine.UI_STATUS_TYPE_ALL)do
		e[a]=false
	end
	e.S_DISABLE_NPC=nil
	e.AnnounceLog=nil
	TppUI.FadeIn(TppUI.FADE_SPEED.FADE_HIGHESTSPEED,nil,nil,{exceptGameStatus=e})Player.RequestToStopCameraAnimation{}
	if mvars.ply_gameOverCameraAnnounceLog then
		TppUiStatusManager.ClearStatus"AnnounceLog"TppUI.ShowAnnounceLog(mvars.ply_gameOverCameraAnnounceLog)
	end
end
function this.FOBStartGameOverCamera(a,e,t)
	if mvars.ply_gameOverCameraGameObjectId~=nil then
		return
	end
	mvars.ply_gameOverCameraGameObjectId=a
	mvars.ply_gameOverCameraStartTimerName=e
	mvars.ply_gameOverCameraAnnounceLog=t
	TppUiStatusManager.SetStatus("AnnounceLog","INVALID_LOG")
	vars.playerDisableActionFlag=PlayerDisableAction.SUBJECTIVE_CAMERA
	GkEventTimerManagerStart("Timer_StartGameOverCamera",.25)
end
function this.SetTargetDeadCamera(r)
	local o
	local a
	local l
	if IsTypeTable(r)then
		o=r.gameObjectName or""a=r.gameObjectId
		l=r.announceLog or"target_extract_failed"end
	a=a or GetGameObjectId(o)
	if a==NULL_ID then
		return
	end
	this.StartGameOverCamera(a,"EndFadeOut_StartTargetDeadCamera",l)
end
function this._SetTargetDeadCamera()
	this.PrepareStartGameOverCamera()
	Player.RequestToPlayCameraNonAnimation{characterId=mvars.ply_gameOverCameraGameObjectId,isFollowPos=false,isFollowRot=true,followTime=7,followDelayTime=.1,candidateRots={{10,0},{10,45},{10,90},{10,135},{10,180},{10,225},{10,270}},skeletonNames={"SKL_004_HEAD","SKL_011_LUARM","SKL_021_RUARM","SKL_032_LFOOT","SKL_042_RFOOT"},skeletonCenterOffsets={Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0)},skeletonBoundings={Vector3(0,.45,0),Vector3(0,0,0),Vector3(0,0,0),Vector3(0,-.3,0),Vector3(0,-.3,0)},offsetPos=Vector3(.3,.2,-4.6),focalLength=21,aperture=1.875,timeToSleep=10,fitOnCamera=true,timeToStartToFitCamera=.001,fitCameraInterpTime=.24,diffFocalLengthToReFitCamera=16}
end
function this.SetTargetHeliCamera(r)
	local o
	local a
	local l
	if IsTypeTable(r)then
		o=r.gameObjectName or""a=r.gameObjectId
		l=r.announceLog or"target_eliminate_failed"end
	a=a or GetGameObjectId(o)
	if a==NULL_ID then
		return
	end
	this.StartGameOverCamera(a,"EndFadeOut_StartTargetHeliCamera",l)
end
function this._SetTargetHeliCamera()this.PrepareStartGameOverCamera()Player.RequestToPlayCameraNonAnimation{characterId=mvars.ply_gameOverCameraGameObjectId,isFollowPos=false,isFollowRot=true,followTime=7,followDelayTime=.1,candidateRots={{10,0}},skeletonNames={"SKL_011_RLWDOOR"},skeletonCenterOffsets={Vector3(0,0,0)},skeletonBoundings={Vector3(0,.45,0)},offsetPos=Vector3(.3,.2,-4.6),focalLength=21,aperture=1.875,timeToSleep=10,fitOnCamera=true,timeToStartToFitCamera=.01,fitCameraInterpTime=.24,diffFocalLengthToReFitCamera=999999}
end
function this.SetTargetTruckCamera(r)
	local l
	local a
	local o
	if IsTypeTable(r)then
		l=r.gameObjectName or""a=r.gameObjectId
		o=r.announceLog or"target_extract_failed"end
	a=a or GetGameObjectId(l)
	if a==NULL_ID then
		return
	end
	this.StartGameOverCamera(a,"EndFadeOut_StartTargetTruckCamera",o)
end
function this._SetTargetTruckCamera(a)this.PrepareStartGameOverCamera()Player.RequestToPlayCameraNonAnimation{characterId=mvars.ply_gameOverCameraGameObjectId,isFollowPos=false,isFollowRot=true,followTime=7,followDelayTime=.1,candidateRots={{10,0},{10,45},{10,90},{10,135},{10,180},{10,225},{10,270}},skeletonNames={"SKL_005_WIPERC"},skeletonCenterOffsets={Vector3(0,-.75,-2)},skeletonBoundings={Vector3(1.5,2,4)},offsetPos=Vector3(2.5,3,7.5),focalLength=21,aperture=1.875,timeToSleep=10,fitOnCamera=true,timeToStartToFitCamera=.01,fitCameraInterpTime=.24,diffFocalLengthToReFitCamera=999999}
end
function this.SetPlayerKilledChildCamera()
	if mvars.mis_childGameObjectIdKilledPlayer then
		local a=nil
		if not TppEnemy.IsRescueTarget(mvars.mis_childGameObjectIdKilledPlayer)then
			a="boy_died"end
		this.SetTargetDeadCamera{gameObjectId=mvars.mis_childGameObjectIdKilledPlayer,announceLog=a}
	end
end
function this.SetPressStartCamera()
	local e=GetGameObjectId"Player"if e==NULL_ID then
		return
	end
	Player.RequestToStopCameraAnimation{}Player.RequestToPlayCameraNonAnimation{characterId=e,isFollowPos=true,isFollowRot=true,followTime=0,followDelayTime=0,candidateRots={{0,185}},skeletonNames={"SKL_004_HEAD"},skeletonCenterOffsets={Vector3(-.5,-.15,0)},skeletonBoundings={Vector3(.5,.45,.1)},offsetPos=Vector3(-.8,0,-1.4),focalLength=21,aperture=1.875,timeToSleep=0,fitOnCamera=false,timeToStartToFitCamera=0,fitCameraInterpTime=0,diffFocalLengthToReFitCamera=0}
end
function this.SetTitleCamera()
	local e=GetGameObjectId"Player"if e==NULL_ID then
		return
	end
	Player.RequestToStopCameraAnimation{}Player.RequestToPlayCameraNonAnimation{characterId=e,isFollowPos=true,isFollowRot=true,followTime=0,followDelayTime=0,candidateRots={{0,185}},skeletonNames={"SKL_004_HEAD"},skeletonCenterOffsets={Vector3(-.5,-.15,.1)},skeletonBoundings={Vector3(.5,.45,.9)},offsetPos=Vector3(-.8,0,-1.8),focalLength=21,aperture=1.875,timeToSleep=0,fitOnCamera=false,timeToStartToFitCamera=0,fitCameraInterpTime=0,diffFocalLengthToReFitCamera=0}
end
function this.SetSearchTarget(t,o,s,r,a,i,l,e)
	if(t==nil or o==nil)then
		return
	end
	local o=GetTypeIndexWithTypeName(o)
	if o==NULL_ID then
		return
	end
	if l==nil then
		l=true
	end
	if a==nil then
		a=Vector3(0,.25,0)
	end
	if e==nil then
		e=.03
	end
	local e={name=s,targetGameObjectTypeIndex=o,targetGameObjectName=t,offset=a,centerRange=.3,lookingTime=1,distance=200,doWideCheck=true,wideCheckRadius=.15,wideCheckRange=e,doDirectionCheck=false,directionCheckRange=100,doCollisionCheck=true}
	if(r~=nil)then
		e.skeletonName=r
	end
	if(i~=nil)then
		e.targetFox2Name=i
	end
	Player.AddSearchTarget(e)
end
function this.IsSneakPlayerInFOB(e)
	if e==0 then
		return true
	else
		return false
	end
end
function this.PlayMissionClearCamera()
	local e=this.SetPlayerStatusForMissionEndCamera()
	if not e then
		return
	end
	GkEventTimerManagerStart("Timer_StartPlayMissionClearCameraStep1",.25)
end
function this.SetPlayerStatusForMissionEndCamera()Player.SetPadMask{settingName="MissionClearCamera",except=true}
	vars.playerDisableActionFlag=PlayerDisableAction.SUBJECTIVE_CAMERA
	return true
end
function this.ResetMissionEndCamera()Player.ResetPadMask{settingName="MissionClearCamera"}Player.RequestToStopCameraAnimation{}
end
function this.PlayCommonMissionEndCamera(o,s,i,l,t,n)
	local a
	local e=vars.playerVehicleGameObjectId
	if Tpp.IsHorse(e)then
		GameObject.SendCommand(e,{id="HorseForceStop"})a=o(e,t,n)
	elseif Tpp.IsVehicle(e)then
		local r=GameObject.SendCommand(e,{id="GetVehicleType"})
		GameObject.SendCommand(e,{id="ForceStop",enabled=true})
		local r=s[r]
		if r then
			a=r(e,t,n)
		end
	elseif(Tpp.IsPlayerWalkerGear(e)or Tpp.IsEnemyWalkerGear(e))then
		GameObject.SendCommand(e,{id="ForceStop",enabled=true})a=i(e,t,n)
	elseif Tpp.IsHelicopter(e)then
	else
		a=l(t,n)
	end
	if a then
		local e="Timer_StartPlayMissionClearCameraStep"..tostring(t+1)GkEventTimerManagerStart(e,a)
	end
end
function this._PlayMissionClearCamera(a,t)
	if a==1 then
		TppMusicManager.PostJingleEvent("SingleShot","Play_bgm_common_jingle_clear")
	end
	this.PlayCommonMissionEndCamera(this.PlayMissionClearCameraOnRideHorse,this.VEHICLE_MISSION_CLEAR_CAMERA,this.PlayMissionClearCameraOnWalkerGear,this.PlayMissionClearCameraOnFoot,a,t)
end
function this.RequestMissionClearMotion()
	--TODO rX47 find more
	Player.RequestToPlayDirectMotion{"missionClearMotion",{"/Assets/tpp/motion/SI_game/fani/bodies/snap/snapnon/snapnon_f_idl7.gani",false,"","","",false}}
end
function this.PlayMissionClearCameraOnFoot(p,c)
	if PlayerInfo.AndCheckStatus{PlayerStatus.NORMAL_ACTION}then
		if PlayerInfo.OrCheckStatus{PlayerStatus.STAND,PlayerStatus.SQUAT}then
			if PlayerInfo.AndCheckStatus{PlayerStatus.CARRY}then
				mvars.ply_requestedMissionClearCameraCarryOff=true
				GameObject.SendCommand({type="TppPlayer2",index=PlayerInfo.GetLocalPlayerIndex()},{id="RequestCarryOff"})
			else
				this.RequestMissionClearMotion()
			end
		end
	end
	local t={"SKL_004_HEAD","SKL_002_CHEST"}
	local a={Vector3(0,0,.05),Vector3(.15,0,0)}
	local n={Vector3(.1,.125,.1),Vector3(.15,.1,.05)}
	local e=Vector3(0,0,-4.5)
	local r=.3
	local l
	local o=false
	local i=20
	local s=false
	if p==1 then
		t={"SKL_004_HEAD","SKL_002_CHEST"}a={Vector3(0,0,.05),Vector3(.15,0,0)}n={Vector3(.1,.125,.1),Vector3(.15,.1,.05)}e=Vector3(0,0,-1.5)r=.3
		l=1
		o=true
	elseif c then
		t={"SKL_004_HEAD"}a={Vector3(0,0,.05)}n={Vector3(.1,.125,.1)}e=Vector3(0,-.5,-3.5)r=3
		i=4
	else
		t={"SKL_004_HEAD","SKL_031_LLEG","SKL_041_RLEG"}a={Vector3(0,0,.05),Vector3(.15,0,0),Vector3(-.15,0,0)}n={Vector3(.1,.125,.1),Vector3(.15,.1,.05),Vector3(.15,.1,.05)}e=Vector3(0,0,-3.2)r=3
		s=true
	end
	Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",0),isFollowPos=true,isFollowRot=true,followTime=4,followDelayTime=.1,candidateRots={{1,168},{1,-164}},skeletonNames=t,skeletonCenterOffsets=a,skeletonBoundings=n,offsetPos=e,focalLength=28,aperture=1.875,timeToSleep=i,interpTimeAtStart=r,fitOnCamera=false,timeToStartToFitCamera=1,fitCameraInterpTime=.3,diffFocalLengthToReFitCamera=16,callSeOfCameraInterp=o,useLastSelectedIndex=s}
	return l
end
function this.PlayMissionClearCameraOnRideHorse(e,p,c)
	local e={"SKL_004_HEAD","SKL_002_CHEST"}
	local a={Vector3(0,0,.05),Vector3(.15,0,0)}
	local t={Vector3(.1,.125,.1),Vector3(.15,.1,.05)}
	local n=Vector3(0,0,-3.2)
	local r=.2
	local l
	local s=false
	local o=20
	local i=false
	if c then
		o=4
	end
	if p==1 then
		e={"SKL_004_HEAD","SKL_002_CHEST"}a={Vector3(0,-.125,.05),Vector3(.15,-.125,0)}t={Vector3(.1,.125,.1),Vector3(.15,.1,.05)}n=Vector3(0,0,-3.2)r=.2
		l=1
		s=true
	else
		e={"SKL_004_HEAD","SKL_031_LLEG","SKL_041_RLEG"}a={Vector3(0,-.125,.05),Vector3(.15,-.125,0),Vector3(-.15,-.125,0)}t={Vector3(.1,.125,.1),Vector3(.15,.1,.05),Vector3(.15,.1,.05)}n=Vector3(0,0,-4.5)r=3
		i=true
	end
	Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",0),isFollowPos=true,isFollowRot=true,followTime=4,followDelayTime=.1,candidateRots={{0,160},{0,-160}},skeletonNames=e,skeletonCenterOffsets={Vector3(0,-.125,.05),Vector3(.15,-.125,0),Vector3(-.15,-.125,0)},skeletonBoundings={Vector3(.1,.125,.1),Vector3(.15,.1,.05),Vector3(.15,.1,.05)},skeletonCenterOffsets=a,skeletonBoundings=t,offsetPos=n,focalLength=28,aperture=1.875,timeToSleep=o,interpTimeAtStart=r,fitOnCamera=false,timeToStartToFitCamera=1,fitCameraInterpTime=.3,diffFocalLengthToReFitCamera=16,callSeOfCameraInterp=s,useLastSelectedIndex=i}
	return l
end
function this.PlayMissionClearCameraOnRideLightVehicle(e,s,l)
	local a=Vector3(-.35,.6,.7)
	local e=Vector3(0,0,-2.25)
	local t=.2
	local n
	local r=false
	local o=20
	local i=false
	if l then
		o=4
	end
	if s==1 then
		a=Vector3(-.35,.6,.7)e=Vector3(0,0,-2.25)t=.2
		n=.5
		r=true
	else
		a=Vector3(-.35,.4,.7)e=Vector3(0,0,-4)t=.75
		i=true
	end
	Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",0),isFollowPos=true,isFollowRot=true,followTime=5,followDelayTime=0,candidateRots={{3,160},{3,-160}},offsetTarget=a,offsetPos=e,focalLength=28,aperture=1.875,timeToSleep=o,interpTimeAtStart=t,fitOnCamera=false,timeToStartToFitCamera=1,fitCameraInterpTime=.3,diffFocalLengthToReFitCamera=16,callSeOfCameraInterp=r,useLastSelectedIndex=i}
	return n
end
function this.PlayMissionClearCameraOnRideTruck(e,s,l)
	local t=Vector3(-.35,1.3,1)
	local e=Vector3(0,0,-2)
	local a=.2
	local r
	local n=false
	local o=20
	local i=false
	if l then
		o=4
	end
	if s==1 then
		t=Vector3(-.35,1.3,1)e=Vector3(0,0,-3)a=.2
		r=.5
		n=true
	else
		t=Vector3(-.35,1,1)e=Vector3(0,0,-6)a=.75
		i=true
	end
	Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",0),isFollowPos=true,isFollowRot=true,followTime=5,followDelayTime=0,candidateRots={{3,160},{3,-160}},offsetTarget=t,offsetPos=e,focalLength=28,aperture=1.875,timeToSleep=o,interpTimeAtStart=a,fitOnCamera=false,timeToStartToFitCamera=1,fitCameraInterpTime=.3,diffFocalLengthToReFitCamera=16,callSeOfCameraInterp=n,useLastSelectedIndex=i}
	return r
end
function this.PlayMissionClearCameraOnRideCommonArmoredVehicle(e,s,a,l)
	local e=Vector3(.05,-.5,-2.2)
	if a==1 then
		e=Vector3(.05,-.5,-2.2)
	else
		e=Vector3(-.05,-1,0)
	end
	local a=Vector3(0,0,-7.5)
	local t=.2
	local i
	local n=false
	local r=20
	local o=false
	if l then
		r=4
	end
	if s==1 then
		a=Vector3(0,0,-7.5)t=.2
		i=.5
		n=true
	else
		a=Vector3(0,0,-13.25)t=.75
		o=true
	end
	Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",0),isFollowPos=true,isFollowRot=true,followTime=5,followDelayTime=0,candidateRots={{8,165},{8,-165}},offsetTarget=e,offsetPos=a,focalLength=28,aperture=1.875,timeToSleep=r,interpTimeAtStart=t,fitOnCamera=false,timeToStartToFitCamera=1,fitCameraInterpTime=.3,diffFocalLengthToReFitCamera=16,callSeOfCameraInterp=n,useLastSelectedIndex=o}
	return i
end
function this.PlayMissionClearCameraOnRideEasternArmoredVehicle(t,r,n)
	local a
	a=this.PlayMissionClearCameraOnRideCommonArmoredVehicle(t,r,1,n)
	return a
end
function this.PlayMissionClearCameraOnRideWesternArmoredVehicle(t,n)
	local a
	a=this.PlayMissionClearCameraOnRideCommonArmoredVehicle(t,n,2,isQuest)
	return a
end
function this.PlayMissionClearCameraOnRideTank(e,l,i)
	local e=Vector3(0,0,-6.5)
	local a=.2
	local o
	local n=false
	local r=20
	local t=false
	if i then
		r=4
	end
	if l==1 then
		e=Vector3(0,0,-6.5)a=.2
		o=.5
		n=true
	else
		e=Vector3(0,0,-9)a=.75
		t=true
	end
	Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",0),isFollowPos=true,isFollowRot=true,followTime=5,followDelayTime=0,candidateRots={{9,165},{9,-165}},offsetTarget=Vector3(0,-.85,3.25),offsetPos=e,focalLength=28,aperture=1.875,timeToSleep=r,interpTimeAtStart=a,fitOnCamera=false,timeToStartToFitCamera=1,fitCameraInterpTime=.3,diffFocalLengthToReFitCamera=16,callSeOfCameraInterp=n,useLastSelectedIndex=t}
	return o
end
function this.PlayMissionClearCameraOnWalkerGear(a,p,s)
	local a=Vector3(0,.55,.35)
	local t=Vector3(0,0,-3.65)
	local n=.2
	local l
	local o=false
	local r=20
	local i=false
	if s then
		r=4
	end
	if p==1 then
		a=Vector3(0,.55,.35)t=Vector3(0,0,-3.65)n=.2
		l=1
		o=true
	else
		a=Vector3(0,.4,.35)t=Vector3(0,0,-4.95)n=3
		i=true
	end
	Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",0),isFollowPos=true,isFollowRot=true,followTime=3,followDelayTime=.1,candidateRots={{7,165},{7,-165}},offsetTarget=a,offsetPos=t,focalLength=28,aperture=1.875,timeToSleep=r,interpTimeAtStart=n,fitOnCamera=false,timeToStartToFitCamera=1,fitCameraInterpTime=.3,diffFocalLengthToReFitCamera=16,callSeOfCameraInterp=o,useLastSelectedIndex=i}
	return l
end
this.VEHICLE_MISSION_CLEAR_CAMERA={
	[Vehicle.type.EASTERN_LIGHT_VEHICLE]=this.PlayMissionClearCameraOnRideLightVehicle,
	[Vehicle.type.EASTERN_TRACKED_TANK]=this.PlayMissionClearCameraOnRideTank,
	[Vehicle.type.EASTERN_TRUCK]=this.PlayMissionClearCameraOnRideTruck,
	[Vehicle.type.EASTERN_WHEELED_ARMORED_VEHICLE]=this.PlayMissionClearCameraOnRideEasternArmoredVehicle,
	[Vehicle.type.WESTERN_LIGHT_VEHICLE]=this.PlayMissionClearCameraOnRideLightVehicle,
	[Vehicle.type.WESTERN_TRACKED_TANK]=this.PlayMissionClearCameraOnRideTank,
	[Vehicle.type.WESTERN_TRUCK]=this.PlayMissionClearCameraOnRideTruck,
	[Vehicle.type.WESTERN_WHEELED_ARMORED_VEHICLE]=this.PlayMissionClearCameraOnRideWesternArmoredVehicle
}
function this.FOBPlayMissionClearCamera()
	local e=this.SetPlayerStatusForMissionEndCamera()
	if not e then
		return
	end
	GkEventTimerManagerStart("Timer_FOBStartPlayMissionClearCameraStep1",.25)
end
function this._FOBPlayMissionClearCamera(a)this.FOBPlayCommonMissionEndCamera(this.FOBPlayMissionClearCameraOnFoot,a)
end
function this.FOBPlayCommonMissionEndCamera(t,a)
	local e
	e=t(a)
	if e then
		local a="Timer_FOBStartPlayMissionClearCameraStep"..tostring(a+1)GkEventTimerManagerStart(a,e)
	end
end
function this.FOBRequestMissionClearMotion()Player.RequestToPlayDirectMotion{"missionClearMotionFob",{"/Assets/tpp/motion/SI_game/fani/bodies/snap/snapnon/snapnon_s_win_idl.gani",false,"","","",false}}
end
function this.FOBPlayMissionClearCameraOnFoot(l)
	Player.SetCurrentSlot{slotType=PlayerSlotType.ITEM,subIndex=0}
	if PlayerInfo.OrCheckStatus{PlayerStatus.STAND,PlayerStatus.SQUAT,PlayerStatus.CRAWL}then
		if PlayerInfo.AndCheckStatus{PlayerStatus.CARRY}then
			mvars.ply_requestedMissionClearCameraCarryOff=true
			GameObject.SendCommand({type="TppPlayer2",index=PlayerInfo.GetLocalPlayerIndex()},{id="RequestCarryOff"})
		elseif PlayerInfo.OrCheckStatus{PlayerStatus.SQUAT,PlayerStatus.CRAWL}then
			Player.RequestToSetTargetStance(PlayerStance.STAND)GkEventTimerManagerStart("Timer_FOBWaitStandStance",1)
		else
			this.FOBRequestMissionClearMotion()
		end
	end
	local r={"SKL_004_HEAD","SKL_002_CHEST"}
	local n={Vector3(0,.1,0),Vector3(0,-.05,0)}
	local a={Vector3(.1,.125,.1),Vector3(.15,.1,.05)}
	local t=Vector3(0,0,-4.5)
	local e=.3
	local o
	local i=false
	if l==1 then
		r={"SKL_004_HEAD","SKL_002_CHEST"}n={Vector3(0,.25,0),Vector3(0,-.05,0)}a={Vector3(.1,.125,.1),Vector3(.1,.125,.1)}t=Vector3(0,0,-1)e=.3
		o=1
		i=true
	else
		r={"SKL_004_HEAD","SKL_002_CHEST"}n={Vector3(0,.15,0),Vector3(0,-.05,0)}a={Vector3(.1,.125,.1),Vector3(.1,.125,.1)}t=Vector3(0,0,-1.5)e=3
	end
	Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",0),isFollowPos=true,isFollowRot=true,followTime=4,followDelayTime=.1,candidateRots={{-10,170},{-10,-170}},skeletonNames=r,skeletonCenterOffsets=n,skeletonBoundings=a,offsetPos=t,focalLength=28,aperture=1.875,timeToSleep=20,interpTimeAtStart=e,fitOnCamera=false,timeToStartToFitCamera=1,fitCameraInterpTime=.3,diffFocalLengthToReFitCamera=16,callSeOfCameraInterp=i}
	return o
end
function this.PlayMissionAbortCamera()
	local e=this.SetPlayerStatusForMissionEndCamera()
	if not e then
		return
	end
	GkEventTimerManagerStart("Timer_StartPlayMissionAbortCamera",.25)
end
function this._PlayMissionAbortCamera()
	TppMusicManager.PostJingleEvent("SingleShot","Play_bgm_common_jingle_failed")this.PlayCommonMissionEndCamera(this.PlayMissionAbortCameraOnRideHorse,this.VEHICLE_MISSION_ABORT_CAMERA,this.PlayMissionAbortCameraOnWalkerGear,this.PlayMissionAbortCameraOnFoot)
end
function this.PlayMissionAbortCameraOnFoot()Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",0),isFollowPos=true,isFollowRot=true,followTime=4,followDelayTime=.1,candidateRots={{6,10},{6,-10}},skeletonNames={"SKL_004_HEAD","SKL_031_LLEG","SKL_041_RLEG"},skeletonCenterOffsets={Vector3(0,.2,0),Vector3(-.15,0,0),Vector3(-.15,0,0)},skeletonBoundings={Vector3(.1,.125,.1),Vector3(.15,.1,.05),Vector3(.15,.1,.05)},offsetPos=Vector3(0,0,-3),focalLength=28,aperture=1.875,timeToSleep=20,interpTimeAtStart=.5,fitOnCamera=false,timeToStartToFitCamera=1,fitCameraInterpTime=.3,diffFocalLengthToReFitCamera=16}
end
function this.PlayMissionAbortCameraOnRideHorse(e)Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",0),isFollowPos=true,isFollowRot=true,followTime=4,followDelayTime=.1,candidateRots={{6,20},{6,-20}},skeletonNames={"SKL_004_HEAD","SKL_031_LLEG","SKL_041_RLEG"},skeletonCenterOffsets={Vector3(0,.2,0),Vector3(-.15,0,0),Vector3(-.15,0,0)},skeletonBoundings={Vector3(.1,.125,.1),Vector3(.15,.1,.05),Vector3(.15,.1,.05)},offsetPos=Vector3(0,0,-3),focalLength=28,aperture=1.875,timeToSleep=20,interpTimeAtStart=.5,fitOnCamera=false,timeToStartToFitCamera=1,fitCameraInterpTime=.3,diffFocalLengthToReFitCamera=16}
end
function this.PlayMissionAbortCameraOnRideLightVehicle(e)Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",0),isFollowPos=true,isFollowRot=true,followTime=3,followDelayTime=.1,candidateRots={{10,30},{10,-30}},offsetTarget=Vector3(-.35,.3,0),offsetPos=Vector3(0,0,-4),focalLength=28,aperture=1.875,timeToSleep=20,interpTimeAtStart=.5,fitOnCamera=false,timeToStartToFitCamera=1,fitCameraInterpTime=.3,diffFocalLengthToReFitCamera=16}
end
function this.PlayMissionAbortCameraOnRideTruck(e)Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",0),isFollowPos=true,isFollowRot=true,followTime=3,followDelayTime=.1,candidateRots={{8,75},{8,-55}},offsetTarget=Vector3(-.35,1,1),offsetPos=Vector3(0,0,-5),focalLength=35,aperture=1.875,timeToSleep=20,interpTimeAtStart=.5,fitOnCamera=false,timeToStartToFitCamera=1,fitCameraInterpTime=.3,diffFocalLengthToReFitCamera=16}
end
function this.PlayMissionAbortCameraOnRideCommonArmoredVehicle(e,a)
	local e=Vector3(.05,-.5,-2.2)
	if a==1 then
		e=Vector3(.05,-.5,-2.2)
	else
		e=Vector3(-.65,-1,0)
	end
	Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",0),isFollowPos=true,isFollowRot=true,followTime=3,followDelayTime=.1,candidateRots={{8,30},{8,-30}},offsetTarget=e,offsetPos=Vector3(0,0,-9),focalLength=35,aperture=1.875,timeToSleep=20,interpTimeAtStart=.5,fitOnCamera=false,timeToStartToFitCamera=1,fitCameraInterpTime=.3,diffFocalLengthToReFitCamera=16}
end
function this.PlayMissionAbortCameraOnRideEasternArmoredVehicle(a)this.PlayMissionAbortCameraOnRideCommonArmoredVehicle(a,1)
end
function this.PlayMissionAbortCameraOnRideWesternArmoredVehicle(a)this.PlayMissionAbortCameraOnRideCommonArmoredVehicle(a,2)
end
function this.PlayMissionAbortCameraOnRideTank(e)
	local e=Vector3(0,-.5,0)Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",0),isFollowPos=true,isFollowRot=true,followTime=3,followDelayTime=.1,candidateRots={{8,25},{8,-25}},offsetTarget=e,offsetPos=Vector3(0,0,-10),focalLength=35,aperture=1.875,timeToSleep=20,interpTimeAtStart=.5,fitOnCamera=false,timeToStartToFitCamera=1,fitCameraInterpTime=.3,diffFocalLengthToReFitCamera=16}
end
function this.PlayMissionAbortCameraOnWalkerGear(a)Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",0),isFollowPos=true,isFollowRot=true,followTime=3,followDelayTime=.1,candidateRots={{7,15},{7,-15}},offsetTarget=Vector3(0,.8,0),offsetPos=Vector3(0,.5,-3.5),focalLength=35,aperture=1.875,timeToSleep=20,interpTimeAtStart=.5,fitOnCamera=false,timeToStartToFitCamera=1,fitCameraInterpTime=.3,diffFocalLengthToReFitCamera=16}
end
this.VEHICLE_MISSION_ABORT_CAMERA={[Vehicle.type.EASTERN_LIGHT_VEHICLE]=this.PlayMissionAbortCameraOnRideLightVehicle,[Vehicle.type.EASTERN_TRACKED_TANK]=this.PlayMissionAbortCameraOnRideTank,[Vehicle.type.EASTERN_TRUCK]=this.PlayMissionAbortCameraOnRideTruck,[Vehicle.type.EASTERN_WHEELED_ARMORED_VEHICLE]=this.PlayMissionAbortCameraOnRideEasternArmoredVehicle,[Vehicle.type.WESTERN_LIGHT_VEHICLE]=this.PlayMissionAbortCameraOnRideLightVehicle,[Vehicle.type.WESTERN_TRACKED_TANK]=this.PlayMissionAbortCameraOnRideTank,[Vehicle.type.WESTERN_TRUCK]=this.PlayMissionAbortCameraOnRideTruck,[Vehicle.type.WESTERN_WHEELED_ARMORED_VEHICLE]=this.PlayMissionAbortCameraOnRideWesternArmoredVehicle}
function this.PlayFallDeadCamera(a)
	mvars.ply_fallDeadCameraTimeToSleep=20
	if a and Tpp.IsTypeNumber(a.timeToSleep)then
		mvars.ply_fallDeadCameraTimeToSleep=a.timeToSleep
	end
	mvars.ply_fallDeadCameraTargetPlayerIndex=PlayerInfo.GetLocalPlayerIndex()HighSpeedCamera.RequestEvent{continueTime=.03,worldTimeRate=.1,localPlayerTimeRate=.1}this.PlayCommonMissionEndCamera(this.PlayFallDeadCameraOnRideHorse,this.VEHICLE_FALL_DEAD_CAMERA,this.PlayFallDeadCameraOnWalkerGear,this.PlayFallDeadCameraOnFoot)
end
function this.SetLimitFallDeadCameraOffsetPosY(e)
	mvars.ply_fallDeadCameraPosYLimit=e
end
function this.ResetLimitFallDeadCameraOffsetPosY()
	mvars.ply_fallDeadCameraPosYLimit=nil
end
function this.GetFallDeadCameraOffsetPosY()
	local a=vars.playerPosY
	local e=.5
	if mvars.ply_fallDeadCameraPosYLimit then
		local t=a+e
		if t<mvars.ply_fallDeadCameraPosYLimit then
			e=mvars.ply_fallDeadCameraPosYLimit-a
		end
	end
	return e
end
function this.PlayFallDeadCameraOnFoot()
	local e=this.GetFallDeadCameraOffsetPosY()Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",mvars.ply_fallDeadCameraTargetPlayerIndex),isFollowPos=false,isFollowRot=true,followTime=.8,followDelayTime=0,candidateRots={{-60,-25},{-60,25},{-60,-115},{-60,115},{5,-25},{5,25},{5,-115},{5,115}},offsetTarget=Vector3(0,0,0),offsetPos=Vector3(-2.5,(e+1),-2.5),focalLength=21,aperture=1.875,timeToSleep=mvars.ply_fallDeadCameraTimeToSleep,interpTimeAtStart=0,fitOnCamera=false}
end
function this.PlayFallDeadCameraOnRideHorse(a)
	local e=this.GetFallDeadCameraOffsetPosY()Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",mvars.ply_fallDeadCameraTargetPlayerIndex),isFollowPos=false,isFollowRot=true,followTime=.8,followDelayTime=0,candidateRots={{-60,-25},{-60,25},{-60,-115},{-60,115},{5,-25},{5,25},{5,-115},{5,115}},offsetTarget=Vector3(0,0,0),offsetPos=Vector3(-2.5,(e+1),-2.5),focalLength=21,aperture=1.875,timeToSleep=mvars.ply_fallDeadCameraTimeToSleep,interpTimeAtStart=0,fitOnCamera=false}
end
function this.PlayFallDeadCameraOnRideLightVehicle(a)
	local e=this.GetFallDeadCameraOffsetPosY()Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",mvars.ply_fallDeadCameraTargetPlayerIndex),isFollowPos=false,isFollowRot=true,followTime=.8,followDelayTime=0,candidateRots={{-60,-25},{-60,25},{-60,-115},{-60,115},{5,-25},{5,25},{5,-115},{5,115}},offsetTarget=Vector3(0,0,0),offsetPos=Vector3(-4,(e+1),-8),focalLength=21,aperture=1.875,timeToSleep=mvars.ply_fallDeadCameraTimeToSleep,interpTimeAtStart=0,fitOnCamera=false}
end
function this.PlayFallDeadCameraOnRideTruck(a)
	local e=this.GetFallDeadCameraOffsetPosY()Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",mvars.ply_fallDeadCameraTargetPlayerIndex),isFollowPos=false,isFollowRot=true,followTime=.8,followDelayTime=0,candidateRots={{-60,-25},{-60,25},{-60,-115},{-60,115},{5,-25},{5,25},{5,-115},{5,115}},offsetTarget=Vector3(0,0,0),offsetPos=Vector3(-4,(e+1),-8),focalLength=21,aperture=1.875,timeToSleep=mvars.ply_fallDeadCameraTimeToSleep,interpTimeAtStart=0,fitOnCamera=false}
end
function this.PlayFallDeadCameraOnRideArmoredVehicle(a)
	local e=this.GetFallDeadCameraOffsetPosY()Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",mvars.ply_fallDeadCameraTargetPlayerIndex),isFollowPos=false,isFollowRot=true,followTime=.8,followDelayTime=0,candidateRots={{-60,-25},{-60,25},{-60,-115},{-60,115},{5,-25},{5,25},{5,-115},{5,115}},offsetTarget=Vector3(0,0,0),offsetPos=Vector3(-4,(e+1),-8),focalLength=21,aperture=1.875,timeToSleep=mvars.ply_fallDeadCameraTimeToSleep,interpTimeAtStart=0,fitOnCamera=false}
end
function this.PlayFallDeadCameraOnRideTank(a)
	local e=this.GetFallDeadCameraOffsetPosY()Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",mvars.ply_fallDeadCameraTargetPlayerIndex),isFollowPos=false,isFollowRot=true,followTime=.8,followDelayTime=0,candidateRots={{-60,-25},{-60,25},{-60,-115},{-60,115},{5,-25},{5,25},{5,-115},{5,115}},offsetTarget=Vector3(0,0,0),offsetPos=Vector3(-4,(e+1),-8),focalLength=21,aperture=1.875,timeToSleep=mvars.ply_fallDeadCameraTimeToSleep,interpTimeAtStart=0,fitOnCamera=false}
end
function this.PlayFallDeadCameraOnWalkerGear(a)
	local a=this.GetFallDeadCameraOffsetPosY()Player.RequestToPlayCameraNonAnimation{characterId=GameObject.GetGameObjectIdByIndex("TppPlayer2",mvars.ply_fallDeadCameraTargetPlayerIndex),isFollowPos=false,isFollowRot=true,followTime=.8,followDelayTime=0,candidateRots={{-60,-25},{-60,25},{-60,-115},{-60,115},{5,-25},{5,25},{5,-115},{5,115}},offsetTarget=Vector3(0,0,0),offsetPos=Vector3(-4,(a+1),-8),focalLength=21,aperture=1.875,timeToSleep=mvars.ply_fallDeadCameraTimeToSleep,interpTimeAtStart=0,fitOnCamera=false}
end
this.VEHICLE_FALL_DEAD_CAMERA={
	[Vehicle.type.EASTERN_LIGHT_VEHICLE]=this.PlayFallDeadCameraOnRideLightVehicle,
	[Vehicle.type.EASTERN_TRACKED_TANK]=this.PlayFallDeadCameraOnRideTank,
	[Vehicle.type.EASTERN_TRUCK]=this.PlayFallDeadCameraOnRideTruck,
	[Vehicle.type.EASTERN_WHEELED_ARMORED_VEHICLE]=this.PlayFallDeadCameraOnRideArmoredVehicle,
	[Vehicle.type.WESTERN_LIGHT_VEHICLE]=this.PlayFallDeadCameraOnRideLightVehicle,
	[Vehicle.type.WESTERN_TRACKED_TANK]=this.PlayFallDeadCameraOnRideTank,
	[Vehicle.type.WESTERN_TRUCK]=this.PlayFallDeadCameraOnRideTruck,
	[Vehicle.type.WESTERN_WHEELED_ARMORED_VEHICLE]=this.PlayFallDeadCameraOnRideArmoredVehicle
}

--r37 CHEAT MODE
local activateButtonHoldTime=0
local warpButtonHoldTime=0
--rX44 Demo theater mode - playback all MB demos
local demoTheaterButtonsHoldTime=0
local cheatModeActive=false
--r51 Settings
local godModeEnabled=false
local godModeDisabled=true
local isWarping=false

function this.UseCheatCodes()
	if mvars.mis_missionStateIsNotInGame then
		cheatModeActive=false
		isWarping=false
		godModeEnabled=false
		godModeDisabled=true
		return
	end

	--rX44 Demo theater mode - playback all MB demos
	--this.DemoTheater()

	if
		vars.missionCode == 50050 or TppMission.IsFOBMission(vars.missionCode) or
		vars.missionCode == 40010
		or vars.missionCode == 40020
		or vars.missionCode == 40050
		or vars.missionCode == 40060
		or vars.missionCode == 1
		or vars.missionCode == 5
		or vars.missionCode == 6000
	then
		cheatModeActive=false
		isWarping=false
		godModeEnabled=false
		godModeDisabled=true
		return
	end

	--r51 Settings
	if TUPPMSettings.cheats_ENABLE_cheatsAlwaysOn then
		cheatModeActive=TUPPMSettings.cheats_ENABLE_cheatsAlwaysOn
	end
	this.ChangeCheatsStatus()
	this.HandleGodMode()

	if not cheatModeActive then return end

	--r40 Invincible on takng damage
	this.SetFOBInvincible()
	this.SuperWarp()

	--  svars.chickCapEnabled = true
	--  vars.playerRetryFlag=PlayerRetryFlag.RETRY_WITH_CHICK_CAP

	--  TppMission.SetFOBMissionFlag()
	--  TppGameStatus.Set("Mission","S_IS_ONLINE") --Cannot pick up dead bodies :) as on FOBs

	--  TppGameStatus.Set("TppMain.lua","S_DISABLE_PLAYER_DAMAGE") --Real God Mode :)
	--  TppGameStatus.Set("TppMain.lua","S_DISABLE_NPC_NOTICE") --Don't notice anything, not even dead guards

	--  Tpp.SetGameStatus{target="all",enable=true,scriptName="TppMain.lua"}
	--  TppUiStatusManager.ClearStatus( "PauseMenu" )
	--	TppUiStatusManager.ClearStatus( "EquipHud" )
	--	TppUiStatusManager.ClearStatus( "EquipPanel" )

	--rX46 Max out Stamina and keep it constant, since MAX stamina can't be increased any other way AFAIK
	--Nope doesn't work, stun grenades still knock out, probably a message trigger or some such
	--may help with getting shot but only FOBs have stun weapons so not much use
	--  vars.playerStamina=65535

	--TODO rX46 Top up female staff --IMP! if enabling remember to move the func in TppMain so its not removed while building
	--  this.AddFreeFemaleStaff()
end

--r40 Invincible on takng damage
this.currentHealthAmount=0
function this.SetFOBInvincible()
	--r60 Disable God mode effects
	if TUPPMSettings.cheats_DISABLE_godMode then return end

	if vars.playerLife<this.currentHealthAmount then
		if Player.StartFOBInvincible ~= nil then
			Player.StartFOBInvincible(PlayerInfo.GetLocalPlayerIndex())
			--      TUPPMLog.Log("Took some damage, now feel the wrath of Big Boss' phantom u sonsa bitches")
			--      Player.StartFOBInvincible(0)
			--      Player.StartFOBInvincible(1)
		end
		this.currentHealthAmount=vars.playerLife
	else
		this.currentHealthAmount=vars.playerLife
	end
end

function this.ChangeCheatsStatus()
	if
		bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.HOLD)==PlayerPad.HOLD
		and bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.CALL)==PlayerPad.CALL
		and bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.EVADE)==PlayerPad.EVADE
	then
		if activateButtonHoldTime==0 then
			activateButtonHoldTime=Time.GetRawElapsedTimeSinceStartUp()
		end

		if
			activateButtonHoldTime~=0
			and Time.GetRawElapsedTimeSinceStartUp() - activateButtonHoldTime >= 2
		then
			if not cheatModeActive then
				TUPPMLog.Log("CHEATS: Cheat Mode activated",2,true) --ALWAYS PRINT
				cheatModeActive=true
			else
				TUPPMLog.Log("CHEATS: Cheat Mode deactivated",2,true) --ALWAYS PRINT
				cheatModeActive=false
			end
			activateButtonHoldTime=0
		end
	else
		activateButtonHoldTime=0
	end
end

--r51 Settings - Allows for always on cheats
function this.HandleGodMode()
	--r60 Disable God mode effects
	if TUPPMSettings.cheats_DISABLE_godMode then return end
	this.EnableGodMode()
	this.DisableGodMode()
end

function this.EnableGodMode()
	if not cheatModeActive then return end
	if godModeEnabled then return end

	godModeEnabled=true
	godModeDisabled=false

	--  if mvars.mis_missionStateIsNotInGame then
	--    return
	--  end

	--  TUPPMLog.Log("NORMAL playerLife: "..tostring(vars.playerLife)
	--    ..", playerLifeMax: "..tostring(vars.playerLifeMax))
	--    ..", playerStamina: "..tostring(vars.playerStamina))

	Player.ResetLifeMaxValue()
	if vars.playerType==PlayerType.AVATAR or vars.playerType==PlayerType.SNAKE then
		--Snake gains a SCALED(max 1.300017439072241, should be less without upgrades I think) health bonus (maybe not due to upgrades)
		--Scaling reduces by damage taken
		--The scale is what decreases as Snake takes damage
		Player.ChangeLifeMaxValue(50410)
		Player.ChangeLifeMaxValue(50410.86221640929) --max possible - with above scaling this becomes 65535
	else
		--All other soldiers
		--TODO check if DD Staff have their max health reduced because of damage

		--SCALES vs Actual multiplier:
		-- x1.1(6600) = 1.100001022834118
		-- x1.2(7201) = 1.200019149450464
		-- x1.3(7801) = 1.300017439072241
		-- x0.02 = 0.0199956905254415 (For Downscale, not accurate)

		--Noticed downscales for "Tough Guys":
		--1.28000191155223
		--1.260006221026789
		--1.240010530501347
		--1.220014839975905
		--1.200019149450464 (Last)

		--Scaling is 1.1 for ALL NORMAL soldiers (and scaling does exist)
		--Scaling is 1.3 for "Tough Guys" (it's actually the same as Snake's)

		--In free roam/missions, ALL NORMAL soldiers gain 1.1 first
		--  but "Tough Guys"(and Snake) then gain 1.3 on base 6000. Fucking KJP
		--I feel that "Tough Guys"(and Snake) actually
		-- gain 1.188679245283019 on the first upscale applied to 6000 but not 100% sure about this
		--1.188679245283019(using smaller values) or 1.18867430196871(using larger values)

		--Time based scaling downscale (with flies, time=stinky) will only drop
		--  by MAX x0.1 in 5 steps of x0.02 each
		-- So ALL NORMAL soldiers downscale to 1.0
		-- "Tough Guys"(and Snake) downscale to 1.2
		--Time based downscale applies to all areas

		--Last(5th) Time based downscale activates flies effect
		--Time based downscaling DOES NOT happen on MB/ACC/FOBs even
		-- when using the cigar/time scale cheats

		--The game seems to maintain it's own downscale timer.
		-- The timer increases with time spent in missions/free roam
		-- The timer definitely increases when using the cigar
		-- The timer does not increase on MB/ACC/FOBs at all, even with cigar usage
		-- Flies appear when this timer hits 5 in-game days
		--CONTRARY to what the game/Kojima will have you believe
		-- this downscale timer does not reset on taking a break between missions
		-- and returning to the ACC, nor does it reset on visiting MB
		--The timer only resets on showering! Or when a cutscene/mission resets it

		--24 Hours = 1 downscale so:
		--Grade 3 Phantom Cigar(36 in-game hours) - 2/3rd usage = 1 downscale
		--Grade 2 Phantom Cigar(24 in-game hours) - 1 usage = 1 downscale
		--Grade 1 Phantom Cigar(12 in-game hours) - 2 usages = 1 downscale

		--Player.GetSmallFlyLevel()>=1 , can be >=5

		--Serious injury downscales:
		--Injury downscales seem random but do occur in steps
		--Downscales on 1.3:
		--  0.0384566081271632
		--  0.0700047538336147
		--  0.0769132162543264
		--  0.1153698243814896
		--  0.1539546212024099
		--  0.1922830406358159
		--  0.2308678374567363
		--Serious injuries will reduce the TOTAL scaling to 1.0
		-- Health pool will go down to 6000 for normal soldiers as well as
		-- "Tough Guys"(and Snake)
		--On top of this, time based downscaling will still occur and stack!
		-- 5 downscales of 0.02 each will still be applied on 6000
		-- 5881, 5760, 5640, 5520, 5400 (min health pool a player can have)
		--Serious injuries activate blood pack on ACC - clue to visit MB and
		-- shower if playing only FOBs

		--Downscaling due to SERIOUS INJURIES resets when changing locations however

		--"Tough Guys"(and Snake) on MB/ACC/FOBs gain 1.2 scale for some reason (irrespective
		-- of whether time based downscales are applied or not) while NORMAL soldiers do not gain a
		--  boost at all (scale remains 1.0)
		--I think the shower adds to the scale itself so on MB
		--  "Tough Guys"(and Snake) get 1.2 max so it can become 1.3 after shower
		--  while NORMAL soldiers get 1.0 so it can become 1.1 after shower
		--Fucking KJP

		--AND THE MOST REDICULOUS THING! - Once Time based scaling occurs for one soldier,
		--  it remains applied for *ALL* soldiers, meaning changing to any other character
		--  does not reset it and one does need to visit the shower on MB! Fucking KJP!!!
		--This also means that one character can have 3 Time based downscales and
		--  another character can have 2 Time based downscales to activate flies effect

		--EVEN MORE REDICULOUS! FOBs do NOT have any downscaling applied at all!
		-- Max health on FOBs will always be 1.1(6600) for normal soldiers
		-- and 1.2(7201) for "Tough Guys"(and Snake)

		--    Player.ChangeLifeMaxValue(50405.07627227277) --max possible
		Player.ChangeLifeMaxValue(50410.86221640929) --max possible with Snake's scaling
	end
	--  vars.playerStamina=65535 --Stamina does not stay put
	--  vars.playerStaminaMax=65535 --Stamina does not stay put
	--  TUPPMLog.Log("playerStaminaMax: "..tostring(vars.playerStaminaMax))

	--r39 Infinite ammo
	Player.SetInfiniteAmmoFromScript(true)
	--r39 Infinite fultons
	Player.SetFultonCountInfinity(true)

	--  TUPPMLog.Log("SUPER playerLife: "..tostring(vars.playerLife)
	--    ..", playerLifeMax: "..tostring(vars.playerLifeMax))
	--    ..", playerStamina: "..tostring(vars.playerStamina))
	TUPPMLog.Log("CHEATS: SUPER Health set to: "..tostring(vars.playerLifeMax),2,true) --ALWAYS PRINT
	--r46 Remove damage and damage collision
	TppGameStatus.Set("TppMain.lua","S_DISABLE_PLAYER_DAMAGE") --Umm yeah, all damage types disabled/collision disabled
end

function this.DisableGodMode()
	if cheatModeActive then return end
	if godModeDisabled then return end

	godModeEnabled=false
	godModeDisabled=true

	--  if mvars.mis_missionStateIsNotInGame then
	--    return
	--  end

	--  TUPPMLog.Log("SUPER playerLife: "..tostring(vars.playerLife)
	--    ..", playerLifeMax: "..tostring(vars.playerLifeMax))
	--    ..", playerStamina: "..tostring(vars.playerStamina))

	Player.ResetLifeMaxValue()
	--  vars.playerStamina=1000

	--r51 Settings
	this.SetCustomPlayerHealth()

	--r39 Infinite ammo
	Player.SetInfiniteAmmoFromScript(false)
	--r39 Infinite fultons
	Player.SetFultonCountInfinity(false)

	--  TUPPMLog.Log("NORMAL playerLife: "..tostring(vars.playerLife)
	--    ..", playerLifeMax: "..tostring(vars.playerLifeMax))
	--    ..", playerStamina: "..tostring(vars.playerStamina))
	TUPPMLog.Log("CHEATS: Normal Health reset to: "..tostring(vars.playerLifeMax),2,true) --ALWAYS PRINT
	--r46 Enable damage and damage collision
	TppGameStatus.Reset("TppMain.lua","S_DISABLE_PLAYER_DAMAGE")
end

function this.SuperWarp()
	--  if bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.DASH)==PlayerPad.DASH then
	--r42 no more squatting to teleport
	--  if PlayerInfo.AndCheckStatus{PlayerStatus.SQUAT} then
	if
		bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.ACTION)==PlayerPad.ACTION
		and bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.CALL)==PlayerPad.CALL
		and not isWarping
	then
		if warpButtonHoldTime==0 then
			warpButtonHoldTime=Time.GetRawElapsedTimeSinceStartUp()
		end

		if
			warpButtonHoldTime~=0
			and Time.GetRawElapsedTimeSinceStartUp() - warpButtonHoldTime >= 0.25
			and vars.userMarkerSaveCount~=0
		then
			--        TppSoundDaemon.PostEvent( 'sfx_s_force_camera_out' )
			--        TppSoundDaemon.PostEvent( 'env_wormhole_in' )
			--        TppSoundDaemon.PostEvent( 'env_wormhole_out' )
			TUPPMLog.Log("CHEATS: Super Space-Time Warping Activated!",2,true) --ALWAYS PRINT
			isWarping=true
			--r42 Added HSC distortion effect
			--r46 Removed shitty effect - caused headaches
			--        TppPlayer2CallbackScript._SetHighSpeedCamera(2.35,1) --params: time effect lasts, world speed
			--r51 Settings
			if TUPPMSettings.cheats_ENABLE_wormholeWarping then
				--r47 Only for NOT-DEBUG mode - Wormhole effect drops carry object and not cool as a result
				GameObject.SendCommand( { type="TppPlayer2", index=PlayerInfo.GetLocalPlayerIndex() }, { id="CreateWormhole", isEnter = true } ) --Disappear into Wormhole, enough to trigger IntoWormhole
			else
				--r47 REINTEGRATED
				GkEventTimerManager.Start("PlayerWarpingTimer",1)
				this.WarpToUserMarker()
			end
			--        TppSoundDaemon.PostEvent( 'sfx_s_force_camera_out' )
			--        TppSoundDaemon.PostEvent( 'env_wormhole_in' )
			--        TppSoundDaemon.PostEvent( 'env_wormhole_out' )
			warpButtonHoldTime=0
		end
	else
		warpButtonHoldTime=0
	end

	--  end
end

--r47 tex figured this shit out
function this.GetLastAddedUserMarkerIndex()
	if vars.userMarkerSaveCount==0 then
		return
	end

	--tex find 'last added' in repect to how userMarker works described in above notes
	--there may be a better way to do this, but I b bad math
	--grab all the markerFlags
	local addMarkerFlags={}
	for index=0,vars.userMarkerSaveCount-1 do
		local addFlag=vars.userMarkerAddFlag[index]
		addMarkerFlags[#addMarkerFlags+1]={addFlag=addFlag,index=index}
	end

	--sort
	local SortFunc=function(a,b)
		if a.addFlag<b.addFlag then
			return true
		end
		return false
	end
	table.sort(addMarkerFlags,SortFunc)


	--figure this shit out
	local highestMarkerIndex=nil

	local flagMax=26--tex maps to alphabet so Z=26

	local startFlag=addMarkerFlags[1].addFlag
	local endFlag=addMarkerFlags[#addMarkerFlags].addFlag

	if vars.userMarkerSaveCount==1 then
		return addMarkerFlags[1].index
	elseif endFlag==flagMax and startFlag==1 then--tex a marker hit the end and markers have wrapped
		local previousFlag=startFlag
		for n,info in ipairs(addMarkerFlags)do
			if info.addFlag~=previousFlag and info.addFlag-1~=previousFlag then --tex GOTCHA(not actually) this method would fail if number of markers was max, think of a snake earing it's tail (snake? snake? snaaake!), but imagine trying to use 26 markers lol
				highestMarkerIndex=addMarkerFlags[n-1].index
				break
			else
				previousFlag=info.addFlag
			end
		end
	else
		highestMarkerIndex=addMarkerFlags[#addMarkerFlags].index
	end

	return highestMarkerIndex
end

function this.WarpToUserMarker(index)
	if vars.userMarkerSaveCount==0 then
		return
	end
	--  TUPPMLog.Log("vars.userMarkerSaveCount: "..tostring(vars.userMarkerSaveCount))
	index=0
	--r47 warp to last marker first
	index=this.GetLastAddedUserMarkerIndex()
	--TODO rX46 Attempt to warp to last marker first
	--  index=#vars.userMarkerGameObjId --rX47 returns 0 cause indexed table starting with 0
	local markerPos=Vector3(0,0,0)
	local rotY=0
	local gameId=vars.userMarkerGameObjId[index]

	--r51 Settings
	local cheats_wormholeWarpOutHeight = math.max(TUPPMSettings.cheats_wormholeWarpOutHeight or 3,0)


	--  TUPPMLog.Log("gameId: "..tostring(gameId))

	if gameId==GameObject.NULL_ID then
		markerPos=Vector3(vars.userMarkerPosX[index],vars.userMarkerPosY[index]+cheats_wormholeWarpOutHeight,vars.userMarkerPosZ[index])
	else
		markerPos, rotY=GameObject.SendCommand(gameId,{id="GetPosition"})
		if markerPos==nil then
			--TODO rotY does not work?
			--      markerPos=Vector3(vars.userMarkerPosX[index],vars.userMarkerPosY[index]+cheats_wormholeWarpOutHeight,rotY)
			markerPos=Vector3(vars.userMarkerPosX[index],vars.userMarkerPosY[index]+cheats_wormholeWarpOutHeight,vars.userMarkerPosZ[index])
		else
			--CONTINUE :: do nothing if markerPos is not nil

			--      TUPPMLog.Log("markerPos[1]: "..tostring(markerPos[1]))
			--      TUPPMLog.Log("markerPos[2]: "..tostring(markerPos[2]))
			--      TUPPMLog.Log("markerPos[3]: "..tostring(markerPos[3]))
			--If a soldier/vehicle/walker gear marker then drop on it
			--      markerPos[2]=markerPos[2]+3

			--TODO figure out how to increment the vector Y position until then use this
			markerPos=Vector3(vars.userMarkerPosX[index],vars.userMarkerPosY[index]+cheats_wormholeWarpOutHeight,vars.userMarkerPosZ[index])
		end
	end

	--  markerPos=Vector3(vars.userMarkerPosX[index],vars.userMarkerPosY[index]+1,vars.userMarkerPosZ[index])
	--  TppEffectUtility.CreateWormHoleEffect(markerPos:GetX(),markerPos:GetY(),markerPos:GetZ()) --Not sure what this does, thought it created wormhole effect after exit

	--  TUPPMLog.Log("markerPos: "..tostring(markerPos))

	--  TUPPMLog.Log("warped to marker "..index..":".. markerPos:GetX()..",".. markerPos:GetY().. ","..markerPos:GetZ())

	--rX47 this would be true for some reason when carrying before the warp - weird
	--	if not PlayerInfo.AndCheckStatus{PlayerStatus.CARRY} then
	--		this.currentSoldierCarried=nil
	--	end

	TppPlayer.Warp{pos={markerPos:GetX(),markerPos:GetY(),markerPos:GetZ()},rotY=vars.playerCameraRotation[1]}
	--  Player.SetWarpToPositionToWormholeFilter(markerPos)

	--rX44 TODO trying to warp carried target
	--  if this.currentSoldierCarried~=nil then
	--    local command={id="Warp",pos=markerPos,rotY=rotY}
	--    GameObject.SendCommand(this.currentSoldierCarried,command)
	--    TUPPMLog.Log("Warping this.currentSoldierCarried: "..tostring(this.currentSoldierCarried))
	--  end
end
--r47 Warp carryied object - not really used
function this.WarpToUserMarkerCarry()
	--	TUPPMLog.Log("WarpToUserMarkerCarry this.currentSoldierCarried: "..tostring(this.currentSoldierCarried),3,true,true)
	if this.currentSoldierCarried~=nil then
		local command=""
		if Tpp.IsHostage(this.currentSoldierCarried) then
			command={id="Warp", degRotationY=vars.playerRotY, position=Vector3(vars.playerPosX,vars.playerPosY+3,vars.playerPosZ)} --works for hostages :)
			--	    command={id="Warp", position=Vector3(vars.playerPosX,vars.playerPosY+3,vars.playerPosZ)} --works for hostages :)
			--	    TUPPMLog.Log("IsHostage",3,true,true)
		else
			command={id="SetPosition", position=Vector3(vars.playerPosX,vars.playerPosY+3,vars.playerPosZ), rotY=vars.playerRotY} --nope for soldiers and hostages
			--    	command={id="Warp", position=Vector3(vars.playerPosX,vars.playerPosY+3,vars.playerPosZ), rotY=vars.playerRotY} --nope for soldiers and hostages
			--			local command={id="Warp", degRotationY=vars.playerRotY, position=Vector3(vars.playerPosX,vars.playerPosY+3,vars.playerPosZ)} --nope for soldiers
			--    	TUPPMLog.Log("NOT IsHostage",3,true,true)
		end
		GameObject.SendCommand(this.currentSoldierCarried,command)
		--    TUPPMLog.Log("Warping this.currentSoldierCarried: "..tostring(this.currentSoldierCarried),3,true,true)
	end
	this.currentSoldierCarried=nil
end

--rX44 Demo theater mode - playback all MB demos
local currentFlashback=0
function this.DemoTheater()

	if vars.missionCode~=30050 then
		return
	end

	if
		bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.RELOAD)==PlayerPad.RELOAD
		and bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.CALL)==PlayerPad.CALL
		and bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.EVADE)==PlayerPad.EVADE
	then
		if demoTheaterButtonsHoldTime==0 then
			demoTheaterButtonsHoldTime=Time.GetRawElapsedTimeSinceStartUp()
		end
		if
			demoTheaterButtonsHoldTime~=0
			and Time.GetRawElapsedTimeSinceStartUp() - demoTheaterButtonsHoldTime >= 2
		then
			--      for i, demoName in pairs(TppDefine.MB_FREEPLAY_DEMO_PRIORITY_LIST) do
			--        TUPPMLog.Log("FLASHBACK: [ "..tostring(demoName).." ]")
			--        TppMbFreeDemo.PlayMtbsEventDemo{demoName=demoName}
			--      end

			currentFlashback=currentFlashback+1
			local demoName=TppDefine.MB_FREEPLAY_DEMO_PRIORITY_LIST[currentFlashback]

			if TppDemo.IsPlayedMBEventDemo(demoName) then
				TUPPMLog.Log("FLASHBACK: [ "..tostring(demoName).." ]")
				TppMbFreeDemo.PlayMtbsEventDemo{demoName=demoName} --breaks when called from ACC or in game
			end

			demoTheaterButtonsHoldTime=0
			if currentFlashback==#TppDefine.MB_FREEPLAY_DEMO_PRIORITY_LIST then
				currentFlashback=0
			end

		end
	else
		demoTheaterButtonsHoldTime=0
	end

end

--r46 Top up female staff
local addFreeFemaleStaffButtonsHoldTime=0
function this.AddFreeFemaleStaff()

	if
		bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.CALL)==PlayerPad.CALL
		and bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.ZOOM_CHANGE)==PlayerPad.ZOOM_CHANGE
	then
		if addFreeFemaleStaffButtonsHoldTime==0 then
			addFreeFemaleStaffButtonsHoldTime=Time.GetRawElapsedTimeSinceStartUp()
		end

		if
			addFreeFemaleStaffButtonsHoldTime~=0
			and Time.GetRawElapsedTimeSinceStartUp() - addFreeFemaleStaffButtonsHoldTime >= 1
		then
			TppMain.AddLotsOfSoldiers()
			addFreeFemaleStaffButtonsHoldTime=0

		end
	else
		addFreeFemaleStaffButtonsHoldTime=0
	end

end

--r44 Enable/disable debug logs
local debugLogsButtonsHoldTime=0
function this.EnableDisableDebugMode()
	--r46 Enable/disable anywhere

	if
		bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.RELOAD)==PlayerPad.RELOAD
		and bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.DASH)==PlayerPad.DASH
	then
		if debugLogsButtonsHoldTime==0 then
			debugLogsButtonsHoldTime=Time.GetRawElapsedTimeSinceStartUp()
		end

		if
			debugLogsButtonsHoldTime~=0
			and Time.GetRawElapsedTimeSinceStartUp() - debugLogsButtonsHoldTime >= 2
		then

			if TUPPMSettings._debug_ENABLE then
				TUPPMLog.Log("Disabling DEBUG logs",3,true) --ALWAYS PRINT
				TUPPMSettings._debug_ENABLE=not TUPPMSettings._debug_ENABLE
			else
				TUPPMSettings._debug_ENABLE=not TUPPMSettings._debug_ENABLE
				TUPPMLog.InitLogging() --r64 Logical fix
				TUPPMLog.Log("Enabling DEBUG logs",3,true) --ALWAYS PRINT
				--r65 More debug info
				TUPPMLog.Log("Current TUPPMLog:"..tostring(InfInspect.Inspect(TUPPMLog)),1,TUPPMSettings._debug_ENABLE_forcePrintLogs)
				TUPPMLog.Log("Current TUPPMSettings:"..tostring(InfInspect.Inspect(TUPPMSettings)),1,TUPPMSettings._debug_ENABLE_forcePrintLogs)
			end

			debugLogsButtonsHoldTime=0

		end
	else
		debugLogsButtonsHoldTime=0
	end

end

--r51 One single collated function to do common stuff - should have used all along
function this.MissionStartCommonFunctions()
	--TppMain.InspectEverything()
	--TppMain.AddLotsOfSoldiers() --can be called here as well, or triggered with a button combo

	--TppBuddy2BlockController.CallBuddy(vars.buddyType,Vector3(vars.playerPosX,vars.playerPosY,vars.playerPosZ),vars.playerRotY) --rX45 nope
	--this.EnableWormholePortalMine() --rX46 Nope

	--rX45 Alternate heli removal with CallToLZ command
	--this.RemoveFirstFakeHeli2() --comment out RemoveFirstFakeHeliTimer call below

	--TppMain.ForceOpenHeliDoors() --TODO WIP

	--local file = InfInspect.Inspect(f30050_enemy.salutationEnemyList)
	--InfInspect.DebugPrint(file)

	--rX45 table to hold all LZ takeoff routes and print them when going to MB on foot
	--table.sort(this.LZRouteTakeOffRoutes)
	--local file = InfInspect.Inspect(this.LZRouteTakeOffRoutes)
	--InfInspect.DebugPrint(file)
	--this.LZRouteTakeOffRoutes={}

	--rX45 Firing here moves soldiers to route
	--TppMain.SetSoldiersToSaluteForMBFakeHeliDrop()


	--vars.playerInjuryCount=1 --rX7 does not work here
	--Player.HeliUseBloodPack()
	--TppMain.InspectEverything()

	if TppMission.IsFOBMission(vars.missionCode)then return end

	TppMain.MBMoraleBoost()

	if not TppMission.IsHelicopterSpace(vars.missionCode) then

		--		TppMain.ForceChangeWildWeather() --Will mess up weather at checkpoints like SKULLS fog

		this.ForceActivateQuietsCellRadio() --r45 Quiet's cell radio now starts correctly with on foot deployment to Med platform
		this.FultonHandler()
		GkEventTimerManager.Start("PlayerWarpingTimer",0.01) --r47 safety measure since demos disable all timers
		--r51 Settings
		if TUPPMSettings.game_ENABLE_autoMarking then
			GkEventTimerManager.Start("AutoMarkingTimer",0.01)
		end
		GkEventTimerManager.Start("RemoveFirstFakeHeliTimer",5)

		--r51 Settings
		this.SetCustomPlayerHealth()
		--TUPPM.SetCustomSoldierParams() --Not ALL params are reflected, needs to be load time

		--r56 Always trigger alert
		if TUPPMSettings.phase_ENABLE_alwaysAlertCPs then
			TUPPM.AlwaysAlertCPs()
		end

		--rX58 No go
		--TUPPM.SuperSprint()

		--r63 Set custom camera properties
		TUPPM.SetCustomCamera()

		--r66 Custom UI markers settings
		TUPPM.ChangeUIElements()
	end

end

--rX45 table to hold all LZ takeoff routes and print them when going to MB on foot
this.LZRouteTakeOffRoutes={}
--rX44 Inspect log max string length
function this.Messages()
	local strCode32MessageTable=Tpp.StrCode32Table{
		--rX45 Animal block - get names as each animal block is made active
		Block=
		{
		--      {
		--        msg="StageBlockCurrentSmallBlockIndexUpdated",
		--        func=function(xPos,yPos,clusterIndex)
		--          TUPPMLog.Log("StageBlockCurrentSmallBlockIndexUpdated xPos:"..tostring(xPos)..", yPos:"..tostring(yPos)..", clusterIndex:"..tostring(clusterIndex))
		--
		--          if mvars.loc_locationAnimalSettingTable==nil then return end
		--          local loc_locationAnimalSettingTable=mvars.loc_locationAnimalSettingTable
		--          local animalAreaSetting=loc_locationAnimalSettingTable.animalAreaSetting
		--          local MAX_AREA_NUM=loc_locationAnimalSettingTable.MAX_AREA_NUM
		--          if not MAX_AREA_NUM then
		--            return
		--          end
		--          --TUPPMLog.Log("MAX_AREA_NUM: "..tostring(MAX_AREA_NUM))
		--
		--          local animalBlockKeyName,animalBlockAreaName=TppAnimalBlock._GetAnimalBlockAreaName(animalAreaSetting,MAX_AREA_NUM,"activeArea",xPos,yPos)
		--          if animalBlockKeyName==nil and animalBlockAreaName==nil then return end
		--          TUPPMLog.Log("animalBlockKeyName:"..tostring(animalBlockKeyName)..", animalBlockAreaName:"..tostring(animalBlockAreaName))
		--
		--
		----          this.PrintAnimalAreaDetails(animalBlockAreaName)
		--
		--        end},
		--      {msg="OnChangeLargeBlockState",
		--      func=function(blockNameStr32,blockStatus)
		--          TUPPMLog.Log("OnChangeLargeBlockState blockNameStr32:"..blockNameStr32..", blockStatus:"..blockStatus)
		--      end},
		--      {msg="OnChangeSmallBlockState",
		--      func=function(blockNameStr32,blockStatus)
		----          TUPPMLog.Log("OnChangeLargeBlockState blockNameStr32:"..blockNameStr32..", blockStatus:"..blockStatus)
		--        end},
		},
		--r38 Bug fix - auto marking and fulton handler work on timers so those need to be fired again after demos
		Demo={
			--r51 Settings --Weather related, Play alone should be enough
			{msg="Play",
				func=function()
					--TppDemo.RemoveTelopFromDemos() --rX54 Does not work
					TppMain.ForceChangeWildWeather()
				end,
			},
			--			{msg="PlayInit",
			--				func=function()
			--					TppMain.ForceChangeWildWeather()
			--				end,
			--			},
			{msg="Finish",
				func=function()
					this.MissionStartCommonFunctions()
					--r51 Settings
					TppMain.ForceChangeWildWeather()
				end,
			}
		},
		Player={
			--rX46 OnEquipItem fires when an item is used
			--    	{msg="OnEquipItem",
			--    		func=function(a,b,c,d,e,f,g,h)
			--    			TUPPMLog.Log(
			--          "OnEquipItem"
			--          .." a: "..tostring(a)
			--          .." b: "..tostring(b)
			--          .." c: "..tostring(c)
			--          .." d: "..tostring(d)
			--          .." e: "..tostring(e)
			--          .." f: "..tostring(f)
			--          .." g: "..tostring(g)
			--          .." h: "..tostring(h)
			--          ,3)
			--    		end
			--    		},

			--    	--rX46 Best way to approach fulton handler
			--			{
			--				msg = "OnPickUpSupplyCbox",
			--				func = function ()
			--					--Opening Cbox - can be destroyed too right :)
			----					TUPPMLog.Log("OnPickUpSupplyCbox",3)
			--				end
			--			},
			--r46 Best way to approach fulton handler
			{
				msg = "OnComeOutSupplyCbox",
				func = function ()
					--Coming out of Cbox
					--					TUPPMLog.Log("OnComeOutSupplyCbox",3)
					this.FultonHandler()
				end
			},
			{
				msg = "OnPickUpSupplyCbox",
				func = function ()
					--r67 Modify hand and tool levels
					TUPPM.ModifyHandsLevels()
					TUPPM.ModifyToolsLevels()
				end
			},
			--r48 Only for NOT-DEBUG mode - Wormhole effect drops carry object and not cool as a result
			--r37 Warp after the wormhole anim plays out
			{msg = "IntoWormhole",
				func = function ()
					if not cheatModeActive then return end
					--FOBs use this message as well. Do not run on FOBs
					if TppMission.IsFOBMission(vars.missionCode)then return end
					--          TppSoundDaemon.PostEvent( 'sfx_s_force_camera_out' )
					this.WarpToUserMarker()
					GameObject.SendCommand( { type="TppPlayer2", index=PlayerInfo.GetLocalPlayerIndex() }, { id="CreateWormhole", isEnter = false } ) --wormhole out effect - creates wormhole
				end
			},
			--r37 Disable wormhole after the anim plays out
			{msg = "OutFromWormhole",
				func = function ()
					if not cheatModeActive then return end
					--FOBs use this message as well. Do not run on FOBs
					if TppMission.IsFOBMission(vars.missionCode)then return end
					isWarping=false
					--  GameObject.SendCommand( { type="TppPlayer2", index=PlayerInfo.GetLocalPlayerIndex() }, { id="SetWormhole", enable= false } ) --? Not sure if this does anything, No such command seen, tested it somewhere else due to desperation
					GameObject.SendCommand( { type="TppPlayer2", index=PlayerInfo.GetLocalPlayerIndex() }, { id="SetWormhole", disp = false } ) --close wormhole effect
					--          GameObject.SendCommand( { type="TppPlayer2", index=PlayerInfo.GetLocalPlayerIndex() }, { id="SetWormholeIcon", enable=false } ) --Thought it changes icon to disabled but no
					--r47 Warp carryied object
					this.WarpToUserMarkerCarry()
				end
			},
			{msg="CalcFultonPercent",
				func=function(r,n,t,a,o)
					this.MakeFultonRecoverSucceedRatio(r,n,t,a,o,false)
				end
			},
			{msg="CalcDogFultonPercent",
				func=function(r,n,o,a,t)
					this.MakeFultonRecoverSucceedRatio(r,n,o,a,t,true)
				end
			},
			{msg="RideHelicopter",
				func=this.SetHelicopterInsideAction},
			{msg="PlayerFulton",
				func=this.OnPlayerFulton
			},
			{msg="OnPickUpCollection",
				func=this.OnPickUpCollection
			},
			{msg="OnPickUpPlaced",
				func=this.OnPickUpPlaced
			},
			{msg="OnPickUpWeapon",
				func=this.OnPickUpWeapon
			},
			{msg="WarpEnd",
				func=this.OnEndWarpByCboxDelivery
			},
			{msg="LandingFromHeli",
				func=function()
					--rX62 Alternate short heli ride
					--this.RemoveFirstFakeHeli()
					--vars.playerDisableActionFlag = PlayerDisableAction.NONE
					this.UpdateCheckPointOnMissionStartDrop()

					-->rX45 My monitor code to get acutal LZ rotations
					--					if TppMain.LZPositions[gvars.heli_missionStartRoute] then
					--            TUPPMLog.Log(
					--            "LandingFromHeli dropRt: "..tostring(TppMain.LZPositions[gvars.heli_missionStartRoute].dropRt)
					--            .." setRot:"..tostring(TppMain.LZPositions[gvars.heli_missionStartRoute].rotY)
					--            )
					--        	end
					--        	TUPPMLog.Log("vars.playerRotY:"..tostring(vars.playerRotY).." vars.playerRotYRad:"..tostring(TppMath.DegreeToRadian(vars.playerRotY)))
					--<
				end
			},
			{msg="EndCarryAction",
				func=function()
					--TODO rX44 trying to warp carried target
					--          TUPPMLog.Log("EndCarryAction this.currentSoldierCarried: "..tostring(this.currentSoldierCarried))
					--          this.currentSoldierCarried=nil
					if mvars.ply_requestedMissionClearCameraCarryOff then
						if PlayerInfo.AndCheckStatus{PlayerStatus.STAND}then
							this.RequestMissionClearMotion()
						end
					end
				end,
				option={isExecMissionClear=true}},
			{msg="IntelIconInDisplay",
				func=this.OnIntelIconDisplayContinue},
			{msg="QuestIconInDisplay",
				func=this.OnQuestIconDisplayContinue},
			{msg="PlayerShowerEnd",
				func=function()
					TppUI.ShowAnnounceLog"refresh"end}
		},
		GameObject={
			--    --rX46 Heli call monitoring
			--    { msg = "StartedMoveToLandingZone", sender = "SupportHeli",
			--    	func = function()
			--    		--Only for calls to LZ
			--    		TUPPMLog.Log("StartedMoveToLandingZone",3)
			--    	end
			--    },
			--rX44 trying to warp carried target
			{msg = "Carried",
				func =  function(gameObjectId)
					this.currentSoldierCarried=gameObjectId
					--            TUPPMLog.Log("Carried msg this.currentSoldierCarried: "..tostring(this.currentSoldierCarried),3,true,true)
				end
			},
			{msg="RideHeli",
				func=this.QuietRideHeli},
			--r38 Increase total marking count for these Bosses now
			{msg = "QuietEraseMarker", sender = {"BossQuietGameObjectLocator","wmu_lab_0000","wmu_lab_0001","wmu_lab_0002","wmu_lab_0003"},
				func = function (gameObjectId)
					--            table.remove(TppMain.totalMarkingCountKeeper, gameObjectId) --lol
					if TppMain.totalMarkingCountKeeper[gameObjectId] then
						TppMain.totalMarkingCountKeeper[gameObjectId]=nil
					end
					--            TUPPMLog.Log("Removed marker so total can increment for: "..tostring(gameObjectId))
				end
			},
		--TODO --rX55 Nope - music has to be loaded
		--			{
		--				msg = "StartedPullingOut",
		--
		--				func = function ()
		--					if not TppMission.IsMbFreeMissions(vars.missionCode) then return end
		--					TppSound.SetSceneBGM("bgm_mtbs_departure")
		--					TppSound.SetSceneBGMSwitch("Set_Switch_bgm_s10030_departure")
		--					TppSoundDaemon.SetMute( 'HeliClosing' )
		--				end
		--			},
		--rX45 Monitor pullout routes --rX45 table to hold all LZ takeoff routes and print them when going to MB on foot
		--      {
		--        msg = "StartedPullingOut",
		--        sender = "SupportHeli",
		--        func = function (heliId, routeId1, routeId2)
		----          TUPPMLog.Log("StartedPullingOut heliId: "..tostring(heliId)
		----          .." routeId1: "..tostring(routeId1)
		----          .." routeId2: "..tostring(routeId2)
		----          )
		--          local heliRoute=GameObject.SendCommand({type="TppHeli2",index=0},{id="GetUsingRoute"})
		--
		--          if TppMain.LZPositions[gvars.heli_missionStartRoute] then
		----            TUPPMLog.Log("LZ dropRt: "..tostring(TppMain.LZPositions[gvars.heli_missionStartRoute].dropRt)
		----            .." takeOffRt: "..tostring(TppMain.LZPositions[gvars.heli_missionStartRoute].takeOffRt)
		----            )
		--            this.LZRouteTakeOffRoutes[TppMain.LZPositions[gvars.heli_missionStartRoute].dropRt]=heliRoute
		--            TUPPMLog.Log("StartedPullingOut dropRt: "..tostring(TppMain.LZPositions[gvars.heli_missionStartRoute].dropRt).." currentHeliRoute: "..tostring(heliRoute),3)
		--          end
		----          if TppMain.LZPositions[gvars.heli_missionStartRoute] then
		----            TUPPMLog.Log("MB dropRt: "..tostring(TppMain.LZPositions[gvars.heli_missionStartRoute].dropRt)
		----            .." takeOffRt: "..tostring(TppMain.LZPositions[gvars.heli_missionStartRoute].takeOffRt)
		----            )
		----          end
		--        end
		--      },
		--        --rX6
		--        { msg = "ArrivedAtLandingZoneSkyNav",
		--          sender = "SupportHeli",
		--               func = function(gameObjectId, lzName)
		--                 TUPPMLog.Log("ArrivedAtLandingZoneSkyNav")
		--               end},
		--        --rX6
		--        { msg = "ArrivedAtLandingZoneWaitPoint",
		--          sender = "SupportHeli",
		--               func = function(gameObjectId, lzName)
		--                 TUPPMLog.Log("ArrivedAtLandingZoneWaitPoint")
		--               end},
		--        { msg = "MessageRoutePoint",
		--          sender = "SupportHeli",
		--               func = function(gameObjectId, lzName)
		--                 TUPPMLog.Log("MessageRoutePoint")
		--               end},
		--        --rX6 Does trigger on heli call to LZ
		--        { msg = "StartedMoveToLandingZone",
		--          sender = "SupportHeli",
		--               func=function( gameObjectId, lzName )
		--                 TUPPMLog.Log("StartedMoveToLandingZone")
		--                 GameObject.SendCommand(gameObjectId, { id="SetLife", life=10000 })
		--               end},
		--        --rX6 Does trigger on heli call to LZ
		--        { msg = "RoutePoint",
		--          sender = "SupportHeli",
		--               func=function( gameObjectId, lzName )
		--                 TUPPMLog.Log("RoutePoint")
		--               end},
		--        --rX6 Does trigger on heli call to LZ
		--        { msg = "RoutePoint2",
		--          sender = "SupportHeli",
		--               func=function( gameObjectId, lzName )
		--                 TUPPMLog.Log("RoutePoint2")
		--               end},
		},
		--r37 Using timers now instead of update for auto marking, fulton handler and heli remover
		--Should have used from beginning - does not seem to improve performace(not 100% certain, game did run better) but still
		UI={
			{msg="EndFadeIn",
				sender="FadeInOnGameStart",
				func=function()
					--fires on: most mission starts, on-foot free and story missions, not mb on-foot, but does mb heli start --EDIT: fires on Zoo and MBQF as well, just not on MB
					this.MissionStartCommonFunctions()
				end},
			{msg="EndFadeIn",
				sender="OnEndGameStartFadeIn",
				func=function()
					--fires on: on-foot mother base, both initial and continue
					this.MissionStartCommonFunctions()
				end},
			{msg="EndFadeIn",
				sender="FadeInOnStartMissionGame",
				func=function()
					--fires on: returning to heli from mission
					this.MissionStartCommonFunctions()
				end},
			{msg="EndFadeOut",
				sender="OnSelectCboxDelivery",
				func=this.WarpByCboxDelivery},
			{msg="EndFadeIn",
				sender="OnEndWarpByCboxDelivery",
				func=this.OnEndFadeInWarpByCboxDelivery},
			{msg="EndFadeOut",
				sender="EndFadeOut_StartTargetDeadCamera",
				func=this._SetTargetDeadCamera,
				option={isExecGameOver=true}},
			{msg="EndFadeOut",
				sender="EndFadeOut_StartTargetHeliCamera",
				func=this._SetTargetHeliCamera,
				option={isExecGameOver=true}},
			{msg="EndFadeOut",
				sender="EndFadeOut_StartTargetTruckCamera",
				func=this._SetTargetTruckCamera,
				option={isExecGameOver=true}}
		},
		Terminal={
			{msg="MbDvcActSelectCboxDelivery",
				func=this.OnSelectCboxDelivery}
		},
		Timer={
			--rX44 Timer based inspect
			{msg="Finish",
				sender="InspectStuffTimer",
				func=function()
					--          TUPPMLog.Log("Finished InspectStuffTimer")
					local message = ""
					local remaining=""
					if this.isMoreMessagePresent==nil or not this.isMoreMessagePresent then
						message = TppMain.InspectThings()
						--            TUPPMLog.Log("not or nil isMoreMessagePresent")
					else
						message = this.availableMessage
						--            TUPPMLog.Log("got availableMessage")
					end

					if string.len(message)>this.MAX_ANNOUNCE_STRING then
						local printMessage=string.sub(message,0,this.MAX_ANNOUNCE_STRING)
						TppUiCommand.AnnounceLogView(printMessage)
						message=string.sub(message,this.MAX_ANNOUNCE_STRING+1)
						this.isMoreMessagePresent = true
						this.availableMessage = message
						GkEventTimerManager.Start("InspectStuffTimer",0.5)
						--            TUPPMLog.Log("reduced message length")
					else
						TppUiCommand.AnnounceLogView(message)
						this.isMoreMessagePresent = false
						this.availableMessage = nil
						--            TUPPMLog.Log("last part of message")
					end
				end},
			--r37
			{msg="Finish",
				sender="AutoMarkingTimer",
				func=function()
					TppMain.AutomarkAllSoldeirsInRange()
					GkEventTimerManager.Start("AutoMarkingTimer",4)
					--          TUPPMLog.Log("AutoMarkingTimer completed")
				end},
			--r37
			{msg="Finish",
				sender="RemoveFirstFakeHeliTimer",
				func=function()
					this.RemoveFirstFakeHeli()
					--          TUPPMLog.Log("RemoveFirstFakeHeliTimer completed")
				end},
			--      --rX45 Alternate heli removal with CallToLZ command
			--      {msg="Finish",
			--        sender="RemoveFirstFakeHeliTimer2",
			--        func=function()
			--          this.PullOutFakeHeli()
			--          --          TUPPMLog.Log("RemoveFirstFakeHeliTimer completed")
			--        end},
			--rX45 Alternate method with distance based heli removal
			--      {msg="Finish",
			--        sender="RemoveFirstFakeMBHeliTimer",
			--        func=function()
			--          this.FindDistanceFromFakeHeliForMb()
			--          --          TUPPMLog.Log("RemoveFirstFakeHeliTimer completed")
			--        end},
			--r37
			{msg="Finish",
				sender="FultonHandlerTimer",
				func=function()
					this.FultonHandler()
					--r46 No need to keep firing timer as found SupplyCbox message
					--          GkEventTimerManager.Start("FultonHandlerTimer",2)
					--          TUPPMLog.Log("FultonHandlerTimer completed")
				end},
			--r37 OBSOLETE; CHEAT MODE Warp timer so warping cannot be repeated frequently
			--r47 REINTEGRATED
			{msg="Finish",
				sender="PlayerWarpingTimer",
				func=function()
					isWarping=false
					--          TppSoundDaemon.PostEvent( 'sfx_s_force_camera_out' )
					--r47 Turns out simple warping allows carry of object
					--          this.WarpToUserMarker()
					--          GameObject.SendCommand( { type="TppPlayer2", index=PlayerInfo.GetLocalPlayerIndex() }, { id="CreateWormhole", isEnter = false } )
					--          TUPPMLog.Log("PlayerWarpingTimer completed")
				end},
			{msg="Finish",
				sender="Timer_StartPlayMissionClearCameraStep1",
				func=function()this._PlayMissionClearCamera(1)
				end,
				option={isExecMissionClear=true}},
			{msg="Finish",
				sender="Timer_StartPlayMissionClearCameraStep2",
				func=function()this._PlayMissionClearCamera(2)
				end,
				option={isExecMissionClear=true}},
			{msg="Finish",
				sender="Timer_FOBStartPlayMissionClearCameraStep1",
				func=function()this._FOBPlayMissionClearCamera(1)
				end,
				option={isExecMissionClear=true}},
			{msg="Finish",
				sender="Timer_FOBStartPlayMissionClearCameraStep2",
				func=function()this._FOBPlayMissionClearCamera(2)
				end,
				option={isExecMissionClear=true}},
			{msg="Finish",
				sender="Timer_StartPlayMissionAbortCamera",
				func=this._PlayMissionAbortCamera,
				option={isExecGameOver=true}},
			{msg="Finish",
				sender="Timer_DeliveryWarpSoundCannotCancel",
				func=this.OnDeliveryWarpSoundCannotCancel},
			{msg="Finish",
				sender="Timer_StartGameOverCamera",
				func=this._StartGameOverCamera,
				option={isExecGameOver=true}},
			{msg="Finish",
				sender="Timer_FOBWaitStandStance",
				func=function()this.FOBRequestMissionClearMotion()
				end,
				option={isExecMissionClear=true}}
		},
		Trap={
			{msg="Enter",
				sender="trap_TppSandWind0000",
				func=function()
					TppEffectUtility.SetSandWindEnable(true)
				end,
				option={isExecMissionPrepare=true}},
			{msg="Exit",
				sender="trap_TppSandWind0000",
				func=function()
					TppEffectUtility.SetSandWindEnable(false)
				end,
				option={isExecMissionPrepare=true}},
			{msg="Enter",
				sender="fallDeath_camera",
				func=function()
					this.SetLimitFallDeadCameraOffsetPosY(-18)
				end,
				option={isExecMissionPrepare=true}},
			{msg="Exit",
				sender="fallDeath_camera",
				func=this.ResetLimitFallDeadCameraOffsetPosY,
				option={isExecMissionPrepare=true}}
		}
	}
	if IsTypeTable(mvars.ply_intelMarkerTrapList)and next(mvars.ply_intelMarkerTrapList)then
		strCode32MessageTable[StrCode32"Trap"]=strCode32MessageTable[StrCode32"Trap"]or{}
		table.insert(strCode32MessageTable[StrCode32"Trap"],Tpp.StrCode32Table{msg="Enter",sender=mvars.ply_intelMarkerTrapList,func=this.OnEnterIntelMarkerTrap,option={isExecMissionPrepare=true}})
	end
	if IsTypeTable(mvars.ply_intelTrapList)and next(mvars.ply_intelTrapList)then
		strCode32MessageTable[StrCode32"Trap"]=strCode32MessageTable[StrCode32"Trap"]or{}
		table.insert(strCode32MessageTable[StrCode32"Trap"],Tpp.StrCode32Table{msg="Enter",sender=mvars.ply_intelTrapList,func=this.OnEnterIntelTrap})
		table.insert(strCode32MessageTable[StrCode32"Trap"],Tpp.StrCode32Table{msg="Exit",sender=mvars.ply_intelTrapList,func=this.OnExitIntelTrap})
	end
	return strCode32MessageTable
end
function this.DeclareSVars()
	return{{name="ply_pickableLocatorDisabled",arraySize=mvars.ply_maxPickableLocatorCount,type=TppScriptVars.TYPE_BOOL,value=false,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="ply_placedLocatorDisabled",arraySize=mvars.ply_maxPlacedLocatorCount,type=TppScriptVars.TYPE_BOOL,value=false,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="ply_isUsedPlayerInitialAction",type=TppScriptVars.TYPE_BOOL,value=false,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},nil}
end
function this.OnAllocate(e)
	if(e and e.sequence)and e.sequence.EQUIP_MISSION_BLOCK_GROUP_SIZE then
		mvars.ply_equipMissionBlockGroupSize=e.sequence.EQUIP_MISSION_BLOCK_GROUP_SIZE
	else
		mvars.ply_equipMissionBlockGroupSize=TppDefine.DEFAULT_EQUIP_MISSION_BLOCK_GROUP_SIZE
	end
	if(e and e.sequence)and e.sequence.MAX_PICKABLE_LOCATOR_COUNT then
		mvars.ply_maxPickableLocatorCount=e.sequence.MAX_PICKABLE_LOCATOR_COUNT
	else
		mvars.ply_maxPickableLocatorCount=TppDefine.PICKABLE_MAX
	end
	if(e and e.sequence)and e.sequence.MAX_PLACED_LOCATOR_COUNT then
		mvars.ply_maxPlacedLocatorCount=e.sequence.MAX_PLACED_LOCATOR_COUNT
	else
		mvars.ply_maxPlacedLocatorCount=TppDefine.PLACED_MAX
	end
end
function this.SetInitialPlayerState(a)
	local t
	if(a.sequence and a.sequence.missionStartPosition)and a.sequence.missionStartPosition.helicopterRouteList then
		if not Tpp.IsTypeFunc(a.sequence.missionStartPosition.IsUseRoute)or a.sequence.missionStartPosition.IsUseRoute()then
			t=a.sequence.missionStartPosition.helicopterRouteList
		end
	end
	if t==nil then
		if gvars.ply_initialPlayerState==TppDefine.INITIAL_PLAYER_STATE.RIDEON_HELICOPTER then
		end
		this.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
	end
end
function this.MissionStartPlayerTypeSetting()
	if not mvars.ply_isExistTempPlayerType then
		this.RestoreTemporaryPlayerType()
	end

	if TppStory.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_ESCAPE_THE_HOSPITAL then
		--K Use Avatar from the start
		vars.playerType=PlayerType.SNAKE --r46 Switching back to Snake --orig
		--r51 Settings
		if TUPPMSettings.player_ENABLE_avatarInM1WhenPlayingNewGame then
			vars.playerType=PlayerType.AVATAR --r46 Switching back to Snake
		end
		vars.playerPartsType=PlayerPartsType.NORMAL_SCARF
		vars.playerCamoType=PlayerCamoType.TIGERSTRIPE
		vars.playerHandType=PlayerHandType.NORMAL
	end

	--r51 Settings
	if
		TUPPMSettings.player_ENABLE_ddSoldiersForM2andM43 and
		(vars.missionCode==10030 -- Mission 2 Diamond Dogs - use Avatar/DD soldiers
		or vars.missionCode==10240) --r14 removing restriction For Mission 43 - 10240 - default DD soldiers to Avatar in the below if condition at e.ApplyTemporaryPlayerType()
	then
		return
	end

	if mvars.ply_isExistTempPlayerType then
		this.SaveCurrentPlayerType()
		this.ApplyTemporaryPlayerType()
	end

	if(vars.missionCode~=10010)and(vars.missionCode~=10280)then
		if vars.playerCamoType==PlayerCamoType.HOSPITAL then
			vars.playerCamoType=PlayerCamoType.OLIVEDRAB
		end
		if vars.playerPartsType==PlayerPartsType.HOSPITAL then
			vars.playerPartsType=PlayerPartsType.NORMAL
		end
	end
end
function this.Init(a)
	this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
	if gvars.ini_isTitleMode then
		vars.isInitialWeapon[TppDefine.WEAPONSLOT.PRIMARY_HIP]=1
		vars.isInitialWeapon[TppDefine.WEAPONSLOT.PRIMARY_BACK]=1
		vars.isInitialWeapon[TppDefine.WEAPONSLOT.SECONDARY]=1
	end
	if a.sequence and a.sequence.ALLWAYS_100_PERCENT_FULTON then
		mvars.ply_allways_100percent_fulton=true
	end
	if TppMission.IsMissionStart()then
		local e
		if a.sequence and a.sequence.INITIAL_HAND_EQUIP then
			e=a.sequence.INITIAL_HAND_EQUIP
		end
		if e then
		end
		local e
		if a.sequence and a.sequence.INITIAL_CAMERA_ROTATION then
			e=a.sequence.INITIAL_CAMERA_ROTATION
		end
		if e then
			vars.playerCameraRotation[0]=e[1]
			vars.playerCameraRotation[1]=e[2]
		end
	end
	if gvars.s10240_isPlayedFuneralDemo then
		Player.SetUseBlackDiamondEmblem(true)
	else
		Player.SetUseBlackDiamondEmblem(false)
	end
	local e=0
	if TppMission.IsHelicopterSpace(vars.missionCode)then
		vars.currentItemIndex=e
		vars.initialPlayerAction=PlayerInitialAction.HELI_SPACE
		return
	end
	if TppMission.IsMissionStart()then
		if((vars.missionCode==30010)or(vars.missionCode==30020))and(Player.IsVarsCurrentItemCBox())then
		else
			vars.currentItemIndex=e
		end
	end
	if(gvars.ply_initialPlayerState==TppDefine.INITIAL_PLAYER_STATE.RIDEON_HELICOPTER)and(svars.ply_isUsedPlayerInitialAction==false)then
		local e=GetGameObjectId("TppHeli2","SupportHeli")
		if e~=NULL_ID then
			vars.initialPlayerAction=PlayerInitialAction.FROM_HELI_SPACE
			vars.initialPlayerPairGameObjectId=e
		end
	else
		if TppMission.IsMissionStart()then
			local e
			if a.sequence and a.sequence.MISSION_START_INITIAL_ACTION then
				e=a.sequence.MISSION_START_INITIAL_ACTION
			end
			if e then
				vars.initialPlayerAction=e
			end
		end
	end
	mvars.ply_locationStationTable={}
	mvars.ply_stationLocatorList={}
	local e=TppLocation.GetLocationName()
	if e=="afgh"or e=="mafr"then
		local a=TppDefine.STATION_LIST[e]
		if a and TppCollection.GetUniqueIdByLocatorName then
			for a,e in ipairs(a)do
				local a="col_labl_"..e
				local e="col_stat_"..e
				local t=TppCollection.GetUniqueIdByLocatorName(a)
				mvars.ply_locationStationTable[t]=e
				if TppCollection.RepopCountOperation("GetAt",a)>0 then
					TppCollection.SetValidStation(e)
				end
			end
		end
		local e=TppDefine.STATION_LIST[e]
		if e then
			for a,e in ipairs(e)do
				local e="col_labl_"..e
				table.insert(mvars.ply_stationLocatorList,e)
			end
		end
	end
	TppEffectUtility.SetSandWindEnable(false)
end

function this.SetSelfSubsistenceOnHardMission()
	if TppMission.IsSubsistenceMission()then
		this.SetInitWeapons(TppDefine.CYPR_PLAYER_INITIAL_WEAPON_TABLE)
		this.SetInitItems(TppDefine.CYPR_PLAYER_INITIAL_ITEM_TABLE)
		this.RegisterTemporaryPlayerType{
			partsType=PlayerPartsType.NORMAL,
			camoType=PlayerCamoType.OLIVEDRAB,
			handEquip=TppEquip.EQP_HAND_NORMAL,
			faceEquipId=0
		}
	end
end

function this.OnReload()this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
end
function this.OnMessage(sender,messageId,arg0,arg1,arg2,arg3,strLogText)
	Tpp.DoMessage(this.messageExecTable,TppMission.CheckMessageOption,sender,messageId,arg0,arg1,arg2,arg3,strLogText)

	--rX45 Debugging
	--  if sender~=typeStrCode32("Player") then
	--		return
	--	end

	----Player requests SupplyBoxDrop
	--|22.51.44	| Message sender:3087473413 messageId:2307345963 arg0:0 arg1:nil arg2:nil arg3:nil strLogText:
	--Player requests SupplyBoxDrop
	--|22.51.44	| Message sender:3087473413 messageId:2307345963 arg0:0 arg1:nil arg2:nil arg3:nil strLogText:
	--
	----Player drive icon - one of these --25600 is player vehicle ID, whatever the vehicle may be, D-Horse and D-Walker have diff Ids obviously
	--|23.00.30	| Message sender:3087473413 messageId:639544647 arg0:0 arg1:nil arg2:nil arg3:nil strLogText:
	--|22.58.56	| Message sender:3087473413 messageId:152902167 arg0:0 arg1:25600 arg2:0 arg3:0 strLogText:


	--  if
	--    sender~=typeStrCode32("GameObject")
	----    or messageId==typeStrCode32("GameObject")
	----    or arg0==typeStrCode32("GameObject")
	----    or arg1==typeStrCode32("GameObject")
	----    or arg2==typeStrCode32("GameObject")
	----    or arg3==typeStrCode32("GameObject")
	----    or strLogText==typeStrCode32("GameObject")
	--  then
	--    return
	--  end

	--  if
	--    arg0~=GameObject.GetGameObjectId("TppHeli2", "SupportHeli")
	--    and sender~=GameObject.GetGameObjectId("TppHeli2", "SupportHeli")
	--    and sender~=typeStrCode32("Heli")
	--  then
	--    return
	--  end
	--
	--  TUPPMLog.Log("Message sender:"..tostring(sender)
	--  .." messageId:"..tostring(messageId)
	--  .." arg0:"..tostring(arg0)
	--  .." arg1:"..tostring(arg1)
	--  .." arg2:"..tostring(arg2)
	--  .." arg3:"..tostring(arg3)
	--  .." strLogText:"..tostring(strLogText)
	--  ,3)

	--  TUPPMLog.Log("gvars.heli_missionStartRoute: "..tostring(gvars.heli_missionStartRoute))
	--  TUPPMLog.Log("mvars.mis_helicopterMissionStartPosition: "..tostring(mvars.mis_helicopterMissionStartPosition))
	--  local LZDetails = TppMain.LZPositions[arg1]
	--  local mbLZDetails = TppMain.LZPositions[arg1]
	--  if LZDetails~=nil and mbLZDetails~=nil then return end
	--  TUPPMLog.Log("LZDetails dropRt: "..tostring(LZDetails.dropRt).." takeOffRt: "..tostring(LZDetails.takeOffRt))
	--  TUPPMLog.Log("mbLZDetails takeOffRt: "..tostring(mbLZDetails.takeOffRt))
end
function this.Update()
	this.UpdateDeliveryWarp()

	--r51 Using separate update functions

	--r46 Drop weapons/items :)
	--	this.DropCurrentWeaponOrItem()

	--r47 Disable radio calls if cassette tape playing
	--	this.DisableAllRadioIfCassettePlaying()

	--r37 CHEAT MODE
	--	this.UseCheatCodes()

	--r44 Enable/disable debug logs
	--r46 Moved here
	--	this.EnableDisableDebugMode()

	--rX45 Alternate method with distance based heli removal
	--  this.FindDistanceFromFakeHeliForMb()

	--  TppMain.AutomarkAllSoldeirsInRange() --r27 New and improves range based auto marking
	--  this.FultonHandler() --r30 Better fulton handler, had been meaning to do this for a while now

	--r35 Remove the first fake heli
	--   this.RemoveFirstFakeHeli()
end
local c={[TppDefine.WEATHER.SUNNY]=0,[TppDefine.WEATHER.CLOUDY]=-10,[TppDefine.WEATHER.RAINY]=-30,[TppDefine.WEATHER.FOGGY]=-50,[TppDefine.WEATHER.SANDSTORM]=-70}

function this.MakeFultonRecoverSucceedRatio(t,a,i,l,r,o)
	local s={
		[TppMotherBaseManagementConst.SECTION_FUNC_RANK_S]=60,
		[TppMotherBaseManagementConst.SECTION_FUNC_RANK_A]=50,
		[TppMotherBaseManagementConst.SECTION_FUNC_RANK_B]=40,
		[TppMotherBaseManagementConst.SECTION_FUNC_RANK_C]=30,
		[TppMotherBaseManagementConst.SECTION_FUNC_RANK_D]=20,
		[TppMotherBaseManagementConst.SECTION_FUNC_RANK_E]=10,
		[TppMotherBaseManagementConst.SECTION_FUNC_RANK_F]=0,
		[TppMotherBaseManagementConst.SECTION_FUNC_RANK_NONE]=0
	}
	local t=a
	local finalPercentage=0
	local p=100
	local n=0
	n=TppTerminal.DoFuncByFultonTypeSwitch(t,i,l,r,nil,nil,nil,this.GetSoldierFultonSucceedRatio,this.GetVolginFultonSucceedRatio,this.GetDefaultSucceedRatio,this.GetDefaultSucceedRatio,this.GetDefaultSucceedRatio,this.GetDefaultSucceedRatio,this.GetDefaultSucceedRatio,this.GetDefaultSucceedRatio,this.GetDefaultSucceedRatio,this.GetDefaultSucceedRatio,this.GetDefaultSucceedRatio)
	if n==nil then
		n=100
	end
	local e=TppMotherBaseManagement.GetSectionFuncRank{sectionFuncId=TppMotherBaseManagementConst.SECTION_FUNC_ID_SUPPORT_FULTON}
	local r=s[e]or 0
	local e=c[vars.weather]or 0
	e=e+r
	if e>0 then
		e=0
	end
	finalPercentage=(p+n)+e
	if mvars.ply_allways_100percent_fulton then
		finalPercentage=100
	end
	if TppEnemy.IsRescueTarget(t)then
		finalPercentage=100
	end
	local e
	if mvars.ply_forceFultonPercent then
		e=mvars.ply_forceFultonPercent[t]
	end
	if e then
		finalPercentage=e
	end
	--finalPercentage=finalPercentage/2 --rX2
	if o then
		Player.SetDogFultonIconPercentage{percentage=finalPercentage,targetId=t}
	else
		Player.SetFultonIconPercentage{percentage=finalPercentage,targetId=t}
	end
end

function this.GetSoldierFultonSucceedRatio(t)
	local e=0
	local n=0
	local a=SendCommand(t,{id="GetLifeStatus"})
	local r=GameObject.SendCommand(t,{id="GetStateFlag"})
	if(bit.band(r,StateFlag.DYING_LIFE)~=0)then
		e=-70
	elseif(a==TppGameObject.NPC_LIFE_STATE_SLEEP)or(a==TppGameObject.NPC_LIFE_STATE_FAINT)then
		e=0
		if mvars.ply_OnFultonIconDying then
			mvars.ply_OnFultonIconDying()
		end
	elseif(a==TppGameObject.NPC_LIFE_STATE_DEAD)then
		return
	end
	local a={
		[TppMotherBaseManagementConst.SECTION_FUNC_RANK_S]=60,
		[TppMotherBaseManagementConst.SECTION_FUNC_RANK_A]=50,
		[TppMotherBaseManagementConst.SECTION_FUNC_RANK_B]=40,
		[TppMotherBaseManagementConst.SECTION_FUNC_RANK_C]=30,
		[TppMotherBaseManagementConst.SECTION_FUNC_RANK_D]=20,
		[TppMotherBaseManagementConst.SECTION_FUNC_RANK_E]=10,
		[TppMotherBaseManagementConst.SECTION_FUNC_RANK_F]=0,
		[TppMotherBaseManagementConst.SECTION_FUNC_RANK_NONE]=0
	}
	local r=TppMotherBaseManagement.GetSectionFuncRank{sectionFuncId=TppMotherBaseManagementConst.SECTION_FUNC_ID_MEDICAL_STAFF_EMERGENCY}
	local a=a[r]or 0
	e=e+a
	if e>0 then
		e=0
	end
	local a=SendCommand(t,{id="GetStatus"})
	if a==EnemyState.STAND_HOLDUP then
		n=-10
	end
	return(e+n)
end

function this.GetDefaultSucceedRatio(e)
	return 0
end
function this.GetVolginFultonSucceedRatio(e)
	return 100
end
function this.SetHelicopterInsideAction()Player.SetHeliToInsideParam{canClearMission=svars.mis_canMissionClear}
end
function this.OnPlayerFulton(e,r)
	if e~=PlayerInfo.GetLocalPlayerIndex()then
		return
	end
	local n=300 --rx2
	local a=1e4
	local e=1e4
	local t=5e3
	local a={[TppGameObject.GAME_OBJECT_TYPE_WALKERGEAR2]=a,[TppGameObject.GAME_OBJECT_TYPE_COMMON_WALKERGEAR2]=a,[TppGameObject.GAME_OBJECT_TYPE_BATTLEGEAR]=a,[TppGameObject.GAME_OBJECT_TYPE_VEHICLE]=e,[TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER]=e,[TppGameObject.GAME_OBJECT_TYPE_GATLINGGUN]=e,[TppGameObject.GAME_OBJECT_TYPE_MORTAR]=t,[TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN]=t}
	local e
	local t=GameObject.GetTypeIndex(r)e=a[t]or n
	TppTerminal.UpdateGMP{gmp=-e,gmpCostType=TppDefine.GMP_COST_TYPE.FULTON}svars.supportGmpCost=svars.supportGmpCost+e
end
function this.QuietRideHeli(e)
	if e==GameObject.GetGameObjectIdByIndex("TppBuddyQuiet2",0)then
		Player.RequestToPlayCameraNonAnimation{characterId=e,isFollowPos=false,isFollowRot=false,followTime=1,followDelayTime=.1,candidateRots={{-4,45},{-4,-45},{-8,0}},offsetPos=Vector3(0,-.2,-2.5),offsetTarget=Vector3(0,2,0),focalLength=21,aperture=1.875,timeToSleep=2,enableOverride=true}
	end
end
function this.SetRetryFlag()
	vars.playerRetryFlag=PlayerRetryFlag.RETRY
end
function this.SetRetryFlagWithChickCap()
	vars.playerRetryFlag=PlayerRetryFlag.RETRY_WITH_CHICK_CAP
end
function this.UnsetRetryFlag()
	vars.playerRetryFlag=0
end
function this.ResetStealthAssistCount()
	vars.stealthAssistLeftCount=0
end
function this.OnPickUpCollection(r,t,a,i)
	local r=255
	TppCollection.RepopCountOperation("SetAt",t,r)
	TppTerminal.AddPickedUpResourceToTempBuffer(a,i)
	local r={[TppCollection.TYPE_POSTER_SOL_AFGN]="key_poster_3500",[TppCollection.TYPE_POSTER_SOL_MAFR]="key_poster_3501",[TppCollection.TYPE_POSTER_GRAVURE_V]="key_poster_3502",[TppCollection.TYPE_POSTER_GRAVURE_H]="key_poster_3503",[TppCollection.TYPE_POSTER_MOE_V]="key_poster_3504",[TppCollection.TYPE_POSTER_MOE_H]="key_poster_3505"}
	local r=r[a]
	if r~=nil then
		TppUI.ShowAnnounceLog("getPoster",r,TppTerminal.GMP_POSTER)
	end
	local r
	if TppTerminal.RESOURCE_INFORMATION_TABLE[a]and TppTerminal.RESOURCE_INFORMATION_TABLE[a].count then
		r=TppTerminal.RESOURCE_INFORMATION_TABLE[a].count
	end
	if TppCollection.IsHerbByType(a)then
		local e=GameObject.GetGameObjectIdByIndex("TppBuddyDog2",0)
		if e~=NULL_ID then
			SendCommand(e,{id="GetPlant",uniqueId=t})
		end
	end
	if TppCollection.IsMaterialByType(a)then
		TppUI.ShowAnnounceLog("find_processed_res",i,r)
	end
	if a==TppCollection.TYPE_DIAMOND_SMALL then
		TppUI.ShowAnnounceLog("find_diamond",TppDefine.SMALL_DIAMOND_GMP)
	end
	if a==TppCollection.TYPE_DIAMOND_LARGE then
		TppUI.ShowAnnounceLog("find_diamond",TppDefine.LARGE_DIAMOND_GMP)
	end
	local a=mvars.ply_locationStationTable[t]
	if a then
		TppUI.ShowAnnounceLog"get_invoice"TppUI.ShowAnnounceLog"add_delivery_point"TppCollection.SetValidStation(a)this.CheckAllStationPickedUp()
	end
	TppTerminal.PickUpBluePrint(t)
	TppTerminal.PickUpEmblem(t)
end
function this.CheckAllStationPickedUp()
	local a=true
	for t,e in ipairs(mvars.ply_stationLocatorList)do
		local e=TppCollection.RepopCountOperation("GetAt",e)
		if e then
			if e<1 then
				a=false
				break
			end
		end
	end
	if a then
		TppTerminal.AcquireKeyItem{dataBaseId=TppMotherBaseManagementConst.DESIGN_3011,isShowAnnounceLog=true}
		if TppLocation.IsAfghan()then
			gvars.ply_isAllGotStation_Afgh=true
		elseif TppLocation.IsMiddleAfrica()then
			gvars.ply_isAllGotStation_Mafr=true
		end
		if gvars.ply_isAllGotStation_Afgh and gvars.ply_isAllGotStation_Mafr then
			TppTerminal.AcquireKeyItem{dataBaseId=TppMotherBaseManagementConst.DESIGN_3012,isShowAnnounceLog=true}
		end
	end
end
function this.OnPickUpPlaced(e,e,a)
	local e=GameObject.GetGameObjectIdByIndex("TppBuddyDog2",0)
	if e~=NULL_ID then
		SendCommand(e,{id="GetPlacedItem",index=a})
	end
end
function this.OnPickUpWeapon(t,e,a)
	if e==TppEquip.EQP_IT_Cassette then
		TppCassette.AcquireOnPickUp(a)
	end
end
function this.RestoreSupplyCbox()
	if this.IsExistSupplyCboxSystem()then
		local e={type="TppSupplyCboxSystem"}SendCommand(e,{id="RestoreRequest"})
	end
end
function this.StoreSupplyCbox()
	if this.IsExistSupplyCboxSystem()then
		local e={type="TppSupplyCboxSystem"}SendCommand(e,{id="StoreRequest"})
	end
end
function this.IsExistSupplyCboxSystem()
	if GameObject.GetGameObjectIdByIndex("TppSupplyCboxSystem",0)~=NULL_ID then
		return true
	else
		return false
	end
end
function this.RestoreSupportAttack()
	if this.IsExistSupportAttackSystem()then
		local e={type="TppSupportAttackSystem"}SendCommand(e,{id="RestoreRequest"})
	end
end
function this.StoreSupportAttack()
	if this.IsExistSupportAttackSystem()then
		local e={type="TppSupportAttackSystem"}SendCommand(e,{id="StoreRequest"})
	end
end
function this.IsExistSupportAttackSystem()
	if GameObject.GetGameObjectIdByIndex("TppSupportAttackSystem",0)~=NULL_ID then
		return true
	else
		return false
	end
end
function this.StorePlayerDecoyInfos()
	if this.IsExistDecoySystem()then
		local e={type="TppDecoySystem"}SendCommand(e,{id="StorePlayerDecoyInfos"})
	end
end
function this.IsExistDecoySystem()
	if GameObject.GetGameObjectIdByIndex("TppDecoySystem",0)~=NULL_ID then
		return true
	else
		return false
	end
end
local a=7.5
local t=3.5
this.DELIVERY_WARP_STATE=Tpp.Enum{"START_FADE_OUT","START_WARP","END_WARP","START_FADE_IN"}
function this.OnSelectCboxDelivery(a)Player.SetPadMask{settingName="CboxDelivery",except=true}
	mvars.ply_deliveryWarpState=this.DELIVERY_WARP_STATE.START_FADE_OUT
	mvars.ply_selectedCboxDeliveryUniqueId=a
	mvars.ply_playingDeliveryWarpSoundHandle=TppSoundDaemon.PostEventAndGetHandle("Play_truck_transfer","Loading")
	TppUI.FadeOut(TppUI.FADE_SPEED.FADE_HIGHESTSPEED,"OnSelectCboxDelivery",nil,{setMute=true})
end
function this.WarpByCboxDelivery()
	if not mvars.ply_selectedCboxDeliveryUniqueId then
		return
	end
	TppGameStatus.Set("TppPlayer.WarpByCboxDelivery","S_IS_BLACK_LOADING")
	if TppMission.GetMissionID()==30010 or TppMission.GetMissionID()==30020 then
		TppQuest.DeactivateCurrentQuestBlock()
		TppQuest.ClearBlockStateRequest()
	end
	mvars.ply_deliveryWarpState=this.DELIVERY_WARP_STATE.START_WARP
	GkEventTimerManagerStart("Timer_DeliveryWarpSoundCannotCancel",a)
	local a={type="TppPlayer2",index=0}
	local e={id="WarpToStation",stationId=mvars.ply_selectedCboxDeliveryUniqueId}
	GameObject.SendCommand(a,e)
end
function this.OnEndWarpByCboxDelivery()
	if mvars.ply_deliveryWarpState==this.DELIVERY_WARP_STATE.START_WARP then
		mvars.ply_deliveryWarpState=this.DELIVERY_WARP_STATE.END_WARP
	end
end
function this.OnDeliveryWarpSoundCannotCancel()
	mvars.ply_deliveryWarpSoundCannotCancel=true
end
function this.UpdateDeliveryWarp()
	if not mvars.ply_deliveryWarpState then
		return
	end
	if(mvars.ply_deliveryWarpState==this.DELIVERY_WARP_STATE.START_WARP)then
		TppUI.ShowAccessIconContinue()
	end
	if(mvars.ply_deliveryWarpState~=this.DELIVERY_WARP_STATE.END_WARP)then
		return
	end
	if not TppMission.CheckMissionState()then
		mvars.ply_playingDeliveryWarpSoundHandle=nil
		mvars.ply_selectedCboxDeliveryUniqueId=nil
		mvars.ply_deliveryWarpState=nil
		mvars.ply_deliveryWarpSoundCannotCancel=nil
		TppSoundDaemon.PostEventAndGetHandle("Stop_truck_transfer","Loading")GkEventTimerManagerStop"Timer_DeliveryWarpSoundCannotCancel"return
	end
	if mvars.ply_playingDeliveryWarpSoundHandle then
		local e=TppSoundDaemon.IsEventPlaying("Play_truck_transfer",mvars.ply_playingDeliveryWarpSoundHandle)
		if(e==false)then
			TppSoundDaemon.ResetMute"Loading"mvars.ply_playingDeliveryWarpSoundHandle=nil
		else
			TppUI.ShowAccessIconContinue()
		end
	end
	if(mvars.ply_playingDeliveryWarpSoundHandle and(not mvars.ply_deliveryWarpSoundCannotCancel))and(bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.STANCE)==PlayerPad.STANCE)then
		mvars.ply_deliveryWarpSoundCannotCancel=true
		TppSoundDaemon.ResetMute"Loading"TppSoundDaemon.PostEventAndGetHandle("Stop_truck_transfer","Loading")
	end
	if(not mvars.ply_playingDeliveryWarpSoundHandle)then
		mvars.ply_deliveryWarpState=this.DELIVERY_WARP_STATE.START_FADE_IN
		TppSoundDaemon.ResetMute"Loading"TppGameStatus.Reset("TppPlayer.WarpByCboxDelivery","S_IS_BLACK_LOADING")
		if TppMission.GetMissionID()==30010 or TppMission.GetMissionID()==30020 then
			TppQuest.InitializeQuestLoad()
			TppQuest.InitializeQuestActiveStatus()
		end
		TppMission.ExecuteSystemCallback("OnEndDeliveryWarp",mvars.ply_selectedCboxDeliveryUniqueId)
		TppUI.FadeIn(TppUI.FADE_SPEED.FADE_NORMAL,"OnEndWarpByCboxDelivery")
	end
end
function this.OnEndFadeInWarpByCboxDelivery()
	mvars.ply_selectedCboxDeliveryUniqueId=nil
	mvars.ply_deliveryWarpState=nil
	mvars.ply_deliveryWarpSoundCannotCancel=nil
	GkEventTimerManagerStop"Timer_DeliveryWarpSoundCannotCancel"Player.ResetPadMask{settingName="CboxDelivery"}
end
function this.OnEnterIntelMarkerTrap(e,a)
	local a=mvars.ply_intelMarkerTrapInfo[e]
	local e=mvars.ply_intelFlagInfo[a]
	if e then
		if svars[e]then
			return
		end
	else
		return
	end
	local e=mvars.ply_intelMarkerObjectiveName[a]
	if e then
		TppMission.UpdateObjective{objectives={e}}
	end
end
function this.OnEnterIntelTrap(a,t)
	local a=mvars.ply_intelTrapInfo[a]this.ShowIconForIntel(a)
end
function this.OnExitIntelTrap(a,a)this.HideIconForIntel()
end
function this.OnIntelIconDisplayContinue(a,t,t)
	local a=mvars.ply_intelNameReverse[a]this.ShowIconForIntel(a)
end
function this.OnEnterQuestTrap(a,t)
	local a=mvars.ply_questStartTrapInfo[a]this.ShowIconForQuest(a)
	local e=mvars.ply_questStartFlagInfo[a]
	if e~=nil and e==false then
		TppSoundDaemon.PostEvent"sfx_s_ifb_mbox_arrival"end
end
function this.OnExitQuestTrap(a,a)this.HideIconForQuest()
end
function this.OnQuestIconDisplayContinue(a,t,t)
	local a=mvars.ply_questNameReverse[a]this.ShowIconForQuest(a)
end
function this.UpdateCheckPointOnMissionStartDrop()
	if not TppSequence.IsHelicopterStart()then
		return
	end
	if TppMission.IsEmergencyMission()then
		return
	end
	if not mvars.ply_doneUpdateCheckPointOnMissionStartDrop then
		TppMission.UpdateCheckPointAtCurrentPosition()
		mvars.ply_doneUpdateCheckPointOnMissionStartDrop=true
	end
end
function this.IsAlreadyDropped()
	return mvars.ply_doneUpdateCheckPointOnMissionStartDrop
end
function this.SaveCaptureAnimal()
	if mvars.loc_locationAnimalSettingTable==nil then
		return
	end
	local a=TppPlaced.GetCaptureCageInfo()
	for t,a in pairs(a)do
		local a,e,t,t=this.EvaluateCaptureCage(a.x,a.z,a.grade,a.material)
		if e~=0 then
			CaptureCage.RegisterCaptureAnimal(e,a)
		end
	end
	TppPlaced.DeleteAllCaptureCage()
end
function this.AggregateCaptureAnimal()
	local e=0
	local a=0
	local t=CaptureCage.GetCaptureAnimalList()
	for t,n in pairs(t)do
		local t=n.animalId
		local n=n.areaName
		TppMotherBaseManagement.DirectAddDataBaseAnimal{dataBaseId=t,areaNameHash=n,isNew=true}
		local n,r=TppMotherBaseManagement.GetAnimalHeroicPointAndGmp{dataBaseId=t}e=e+n
		a=a+r
		TppUiCommand.ShowBonusPopupAnimal(t,"regist")
	end
	if e>0 or a>0 then
		TppMotherBaseManagement.AddHeroicPointAndGmpByCageAnimal{heroicPoint=e,gmp=a,isAnnounce=true}
	end
end
function this.CheckCaptureCage(n,r)
	if mvars.loc_locationAnimalSettingTable==nil then
		return
	end
	if n<2 or n>4 then
		return
	end
	local a={}
	local t=5
	local o=r/t
	for r=1,o do
		if n==2 then
			Player.DEBUG_PlaceAround{radius=5,count=t,equipId=TppEquip.EQP_SWP_CaptureCage}
		elseif n==3 then
			Player.DEBUG_PlaceAround{radius=5,count=t,equipId=TppEquip.EQP_SWP_CaptureCage_G01}
		elseif n==4 then
			Player.DEBUG_PlaceAround{radius=5,count=t,equipId=TppEquip.EQP_SWP_CaptureCage_G02}
		end
		for e=1,t do
			coroutine.yield()
		end
		local t=TppPlaced.GetCaptureCageInfo()
		for n,t in pairs(t)do
			local n,t,r,e=this.EvaluateCaptureCage(t.x,t.z,t.grade,t.material)
			if t~=0 then
				TppMotherBaseManagement.DirectAddDataBaseAnimal{dataBaseId=t,areaName=n,isNew=true}
				if a[e]==nil then
					a[e]=1
				else
					a[e]=a[e]+1
				end
			end
		end
		TppPlaced.DeleteAllCaptureCage()
	end
	for a,e in pairs(a)do
		local e=(e/r)*100
	end
end
function this.GetCaptureAnimalSE(t)
	local e="sfx_s_captured_nom"local a=mvars.loc_locationAnimalSettingTable
	if a==nil then
		return e
	end
	local a=a.animalRareLevel
	if a[t]==nil then
		return e
	end
	local a=a[t]
	if a==TppMotherBaseManagementConst.ANIMAL_RARE_SR then
		e="sfx_s_captured_super"elseif a==TppMotherBaseManagementConst.ANIMAL_RARE_R then
		e="sfx_s_captured_rare"else
		e="sfx_s_captured_nom"end
	return e
end
function this._IsStartStatusValid(a)
	if(this.StartStatusList[a]==nil)then
		return false
	end
	return true
end
function this._IsAbilityNameValid(a)
	if(this.DisableAbilityList[a]==nil)then
		return false
	end
	return true
end
function this._IsControlModeValid(a)
	if(this.ControlModeList[a]==nil)then
		return false
	end
	return true
end
function this._CheckRotation(e,a,t,n,r)
	local r=mvars
	local r=vars.playerCameraRotation[0]
	local o=vars.playerCameraRotation[1]
	local e=foxmath.DegreeToRadian(r-e)e=foxmath.NormalizeRadian(e)
	local r=foxmath.RadianToDegree(e)
	local e=foxmath.DegreeToRadian(o-t)e=foxmath.NormalizeRadian(e)
	local e=foxmath.RadianToDegree(e)
	if(foxmath.Absf(r)<a)and(foxmath.Absf(e)<n)then
		return true
	else
		return false
	end
end
local function n(a)
	local n=math.random(0,99)
	local e=0
	local t=-1
	for r,a in pairs(a)do
		e=e+a[2]
		if n<e then
			t=a[1]break
		end
	end
	return t
end
local function p(e,a)
	for t,e in pairs(e)do
		if e==a then
			return true
		end
	end
	return false
end
function this.EvaluateCaptureCage(i,a,o,c)
	local t=mvars
	local r=t.loc_locationAnimalSettingTable
	local l=r.captureCageAnimalAreaSetting
	local t="wholeArea"for n,e in pairs(l)do
		if((i>=e.activeArea[1]and i<=e.activeArea[3])and a>=e.activeArea[2])and a<=e.activeArea[4]then
			t=e.areaName
			break
		end
	end
	local a=0
	if o==2 then
		a=n(this.CageRandomTableG3)
	elseif o==1 then
		a=n(this.CageRandomTableG2)
	else
		a=n(this.CageRandomTableG1)
	end
	local e=r.captureAnimalList
	local l=r.animalRareLevel
	local s=r.animalInfoList
	local n={}
	if e[t]==nil then
		t="wholeArea"end
	local i=false
	for t,e in pairs(e[t])do
		local t=l[e]
		if t>=TppMotherBaseManagementConst.ANIMAL_RARE_SR and o==2 then
			if not TppMotherBaseManagement.IsGotDataBase{dataBaseId=e}then
				table.insert(n,e)a=t
				i=true
				break
			end
		end
	end
	if not i then
		local r=a
		while a>=0 do
			for t,e in pairs(e[t])do
				if l[e]==a then
					table.insert(n,e)
				end
			end
			if table.maxn(n)>0 then
				break
			end
			a=a-1
		end
		if a<0 then
			a=r
			t="wholeArea"while a>=0 do
				for t,e in pairs(e[t])do
					if l[e]==a then
						table.insert(n,e)
					end
				end
				if table.maxn(n)>0 then
					break
				end
				a=a-1
			end
		end
	end
	local i=r.animalMaterial
	local o={}
	local r=a
	if i~=nil then
		while r>=0 do
			for a,e in pairs(e.wholeArea)do
				if i[e]==nil and l[e]==r then
					table.insert(o,e)
				end
			end
			if table.maxn(o)>0 then
				break
			end
			r=r-1
		end
	end
	local e=0
	local l=table.maxn(n)
	if l==1 then
		e=n[1]
	elseif l>1 then
		local a=math.random(1,l)e=n[a]
	end
	if#o==0 then
		local n=""return t,e,a,n
	end
	if i~=nil then
		local t=i[e]
		if t~=nil then
			if p(t,c)==false then
				local t=math.random(1,#o)e=o[t]a=r
			end
		end
	end
	local n=""if s~=nil then
		if e~=0 then
			n=s[e].name
		end
	end
	return t,e,a,n
end
function this.Refresh(e)
	if e then
		Player.ResetDirtyEffect()
	end
	vars.passageSecondsSinceOutMB=0 --rX44 This baby keeps track of health downgrade time :)
end

--r22 Fulton enable/disable code rework; flags to display messages only once
local currentFultonFlag=false
local previousFultonFlag=false

--r30 Better fulton handler
function this.FultonHandler()
	--r51 Settings
	if not TUPPMSettings.player_ENABLE_disablingFultonOption then return end

	--TODO --FIXED issue was with LRRP marking --rX6 this code sometimes messes up - one example when an armored vehicle is destroyed and Fulton is disabled

	--I think this variable is nil most of the time
	if mvars.mis_missionStateIsNotInGame then
		--    TUPPMLog.Log("Not in Game: "..tostring(mvars.mis_missionStateIsNotInGame))
		return
	end

	--TODO maybe causing problems with auto marking
	--Come back to this later
	-- r32 Do a fulton check every 3 seconds
	--  if Time.GetRawElapsedTimeSinceStartUp()-lastFultonCheckTime < 3 then
	--    return
	--  end
	--  lastFultonCheckTime=Time.GetRawElapsedTimeSinceStartUp()

	--r32 Return if fulton hasn't changed
	--r39 remove :/ stupid stupid stupid - current fulton level will never change at the start of a New Game
	--  if currentFultonGrade==Player.GetItemLevel(TppEquip.EQP_IT_Fulton)
	--    and currentWormholeGrade==Player.GetItemLevel(TppEquip.EQP_IT_Fulton_WormHole)
	--  then
	--    --    TUPPMLog.Log("Fulton not changed so returning")
	--    return
	--  end


	--r30 Return if M1 has not been completed; so fulton disabled message does not appear, quality is of utmost importance lol
	--r31 No need to have this, safely remove
	--r32 Enable so that fulton disabled message is not shown with a New Game
	--r50 Return if M2 has not been completed
	if TppStory.IsMissionCleard( 10030 )  == false then
		return
	end

	--r28 Except these
	if vars.missionCode == 50050
		or vars.missionCode == 40010
		or vars.missionCode == 40020
		or vars.missionCode == 40050
		or vars.missionCode == 40060
		or vars.missionCode == 1
		or vars.missionCode == 5
		or vars.missionCode == 6000
		--r30 Fulton fixes for specific missions, let the missions handle it themselves
		or vars.missionCode == 10010 --Prologue
		or vars.missionCode == 10030 --M2 Diamod Dogs
		or vars.missionCode == 10115 --M22 Retake The Platform
		or vars.missionCode == 10240 --M43 Shining Lights
		or vars.missionCode == 10280 --M46 The Truth
	then
		return
	end

	--  TUPPMLog.Log("Fulton changed so checking enable/disable logic")

	--rX50 Trying to implement disabled fulton
	--	TUPPMLog.Log(
	--	"Player.GetItemLevel(TppEquip.EQP_IT_Fulton):"..tostring(Player.GetItemLevel(TppEquip.EQP_IT_Fulton))
	--	.."\tPlayer.GetItemLevel(TppEquip.EQP_IT_Fulton_WormHole):"..tostring(Player.GetItemLevel(TppEquip.EQP_IT_Fulton_WormHole)),3)

	this.CarefullyDisableFulton() --r28 Fulton now enables/disables instantly on change
	this.CarefullyEnableFulton()

end

--r09 Function returns true if Level 1 fulton selected and not FOB and not Wormhole
--r44 Renamed functions
function this.CheckFultonLevels()
	--  if true then
	--    TUPPMLog.Log("Preemptive returning true")
	--    return true
	--  end

	--r29 No need
	--r27 Fulton fixed for New Game
	--  if TppStory.IsMissionCleard( 10020 )  == false then
	----    	 TUPPMLog.Log("Rescue miller not beaten so returning true")
	--    return true
	--  end

	local equipedFultonLvl=0 --r29
	local equipedWormholeLvl=0
	--	local isWomholeDeveloped=TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=16008}
	--	TUPPMLog.Log("isWomholeDeveloped: "..tostring(isWomholeDeveloped))

	equipedFultonLvl = Player.GetItemLevel(TppEquip.EQP_IT_Fulton)-- Range 1-4
	equipedWormholeLvl = Player.GetItemLevel(TppEquip.EQP_IT_Fulton_WormHole)--Either 1 or 0
	--  if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=16008} then
	--    equipedWormholeLvl = Player.GetItemLevel(TppEquip.EQP_IT_Fulton_WormHole)--Either 1 or 0
	--  end

	--r32 store currently equipped fulton info
	--  currentFultonGrade=equipedFultonLvl
	--  currentWormholeGrade=equipedWormholeLvl

	--  TUPPMLog.Log("equipedFultonLvl: "..tostring(equipedFultonLvl))
	--  TUPPMLog.Log("equipedWormholeLvl: "..tostring(equipedWormholeLvl))

	--r22 code rework
	--  if vars.missionCode
	--    and (
	--    (
	--    equipedFultonLvl <= 1 --r29 For a new game fulton level is 0 in the beginning; Handles Fulton 1
	--    and equipedWormholeLvl == 0 --Not Wormhole
	--         or
	--         equipedWormholeLvl == nil) --r27 Important when womhole fulton not developed
	--    and vars.missionCode ~= 50050 --Not FOBs
	--    and vars.missionCode ~= 10115 --r22 Not Mission 22 - Retake the Platform
	--r28 No need to disable fulton for these anymore
	--    and vars.missionCode ~= 30050 --r23 Not MB
	--    and vars.missionCode ~= 30150 --r23 Not Zoo
	--    and vars.missionCode ~= 30250 --r23 Not Ward aka MBQF
	--    )
	--    or vars.missionCode == 10240 --r22 Disable all fultons for Mission 43 - Shining Lights, Even in Death
	--    )
	--r22 since enable/disable fulton applied mission check can be removed
	--    and vars.missionCode ~= 10093 --Mission 35 - Cursed Legacy

	--r29 For a new game fulton level is 0 in the beginning; Handles Fulton 1
	--r30 New code doesn't need mission specific checks
	--r50 Added a separate No Fulton Device
	if
		equipedFultonLvl == 0
		and equipedWormholeLvl == 0 --Not Wormhole
	then
		--e.DebugPrint("Fulton disabled in TppPlayer; equipedFultonLvl="..equipedFultonLvl.. "; equipedWormholeLvl="..equipedWormholeLvl.."; vars.missionCode="..vars.missionCode)
		return true
	else
		return false
	end

	--return false
end



--r22 Fulton can be enabled/disabled mid mission on hitting a checkpoint
function this.CarefullyDisableFulton()

	--  TUPPMLog.Log("Disable check isFultonDisabled: "..tostring(this.testflag(vars.playerDisableActionFlag,PlayerDisableAction.FULTON)))
	if this.CheckFultonLevels()
	--    and (not currentFultonFlag
	--          or (  --r22 Exceptions for all Skulls missions;
	--                -- disable fulton irrespective of whether the flag is true or not
	--                -- provided Grade 1 Fulton device equipped
	--            this.IsSkullsMission()
	----            and
	----            not isSkullsMissionFultonDisabled
	--          )
	--        )
	then
		--    TUPPMLog.Log("Disabled fulton true")
		--    TUPPMLog.Log("Flag before disabling: "..tostring(vars.playerDisableActionFlag))

		--    TUPPMLog.Log("Flag after disabling: "..tostring(vars.playerDisableActionFlag))
		currentFultonFlag = true
		vars.playerDisableActionFlag=this.setflag(vars.playerDisableActionFlag,PlayerDisableAction.FULTON) --r22 works
		TppUiStatusManager.SetStatus("MbTop","BLOCK_FULTON_VIEW") --r28 Disable fulton counter on iDroid; should have forseen this, breaks cutscenes :/
		--TppBuddyService.SetDisableCallBuddyType(BuddyCommand.DOG_BARKING) --rX50 Trying to disable DDogs fulton command
	end

	if (previousFultonFlag~=currentFultonFlag) then --if flag changes then print
		--    TUPPMLog.Log("Fulton air support withdrawn")
		--r45 Fulton air support withdrawn message no longer appears with a New Game
		--    if Player.GetItemLevel(TppEquip.EQP_IT_Fulton)~=0 then
		--      TppUiCommand.AnnounceLogViewLangId("fulton_disabled") --r24 Muahahahahaha!
		--    end
		TppUiCommand.AnnounceLogViewLangId("fulton_disabled") --r50
		previousFultonFlag=currentFultonFlag
		--    if not mvars.mis_missionStateIsNotInGame then
		--      --TODO Disable fulton info from Map screen
		----            TUPPMLog.Log("Demo not playing, disabling fulton info in iDroid")
		--      TppUiStatusManager.SetStatus("MbTop","BLOCK_FULTON_VIEW") --r28 Disable fulton counter on iDroid; should have forseen this, breaks cutscenes :/
		--    end
	end



end

--r22 Fulton can be enabled disabled mid mission on hitting a checkpoint
function this.CarefullyEnableFulton()
	--  local equipedFultonLvl = Player.GetItemLevel(TppEquip.EQP_IT_Fulton) -- Range 1-4
	--  local equipedWormholeLvl = Player.GetItemLevel(TppEquip.EQP_IT_Fulton_WormHole) --Either 1 or 0

	--  local isFultonDisabled = bit.band(vars.playerDisableActionFlag,PlayerDisableAction.FULTON) --does not work, not part of lua lib

	--  TUPPMLog.Log("bit.test result: "..tostring(isFultonDisabled))

	--    TUPPMLog.Log("Enable check isFultonDisabled: "..tostring(this.testflag(vars.playerDisableActionFlag,PlayerDisableAction.FULTON)))
	if not this.CheckFultonLevels()
	then
		--    TUPPMLog.Log("Enabled fulton true")
		--    TUPPMLog.Log("Flag before enabling: "..tostring(vars.playerDisableActionFlag))

		--    vars.playerDisableActionFlag=vars.playerDisableActionFlag-PlayerDisableAction.FULTON
		--    TUPPMLog.Log("Flag after enabling: "..tostring(vars.playerDisableActionFlag))
		currentFultonFlag = false
		vars.playerDisableActionFlag=this.clrflag(vars.playerDisableActionFlag,PlayerDisableAction.FULTON) --r22 does not work, a bit buggy
		TppUiStatusManager.UnsetStatus("MbTop","BLOCK_FULTON_VIEW") --r28 Enable fulton counter on iDroid; should have forseen this, breaks cutscenes :/
		--TppBuddyService.UnsetDisableCallBuddyType(BuddyCommand.DOG_BARKING) --rX50 Trying to disable DDogs fulton command
	end

	if (previousFultonFlag~=currentFultonFlag) then --if flag changes then print
		--    TUPPMLog.Log("Fulton air support available")
		TppUiCommand.AnnounceLogViewLangId("fulton_enabled") --r24 Muahahahahaha!
		previousFultonFlag=currentFultonFlag
		--    if not mvars.mis_missionStateIsNotInGame then
		--      --TODO Disable fulton info from Map screen
		----            TUPPMLog.Log("Demo not playing, enabling fulton info in iDroid")
		--      TppUiStatusManager.UnsetStatus("MbTop","BLOCK_FULTON_VIEW") --r28 Enable fulton counter on iDroid; should have forseen this, breaks cutscenes :/
		--    end
	end

	--  TUPPMLog.Log("CarefullyEnableFulton completed successfully")
end

-->Not my code; found on internet; works better than bit.bxor plus bit.bor combo I tried earlier
--http://lua-users.org/wiki/BitUtils
function this.testflag(set, flag)
	return set % (2*flag) >= flag
end

function this.setflag(set, flag)
	if set % (2*flag) >= flag then
		return set
	end
	return set + flag
end

function this.clrflag(set, flag) -- clear flag
	if set % (2*flag) >= flag then
		return set - flag
end
return set
end
--<Not my code

--TEMPLATE: TUPPMLog.Log("")
--TEMPLATE: TUPPMLog.Log(": "..tostring())

--r44 Disable debug logs by default
--TUPPMSettings._debug_ENABLE=false
---r44 Added Debug Print function
--function this.DebugPrint(print)
--  --r44 Only print logs when setting is turned on - will save me a huge chunk of time in not removing print logs
--  if not TUPPMSettings._debug_ENABLE then return end
--  TppUiCommand.AnnounceLogView(print)
--end

------------------------------------------------------------> r64 OBSOLETE
--------------------------------------------------------------------------
----r45 Better debug method
----r46 Best debug method ever, sure it's heavier but much more useful for me
--this.MAX_ANNOUNCE_STRING=255
--function this.DebugPrint(message, debugPrintFlag, isForced, ...)
--
--	--r46 Now print logs and also why was the same method repeated??!
--
--	--Let's not do this
--	--	if type(message)~="string" then
--	--		message=InfInspect.Inspect(message)
--	--	end
--
--	--can enable trace, but trace won't tell which line the print was started from, only the function line
--	--	message=debug.traceback().." -> "..message
--
--	--Early return if not TUPPMSettings._debug_ENABLE and not forceAnnounceLog
--	if not (TUPPMSettings._debug_ENABLE or isForced) then return end
--
--	if not debugPrintFlag or type(debugPrintFlag)~="number" then return end
--
--	--debugPrintFlag can only be 1, 2 or 3 --this is for my convenience and not really for anybody else
--	debugPrintFlag=math.min(math.max(math.floor(debugPrintFlag),1),3)
--
--	local printToFile=this.testflag(debugPrintFlag, 1) and (TUPPMSettings._debug_ENABLE or isForced)
--	local announceLog=this.testflag(debugPrintFlag, 2) and (TUPPMSettings._debug_ENABLE or isForced)
--
--	--Early return if both are false
--	if not (printToFile or announceLog) then return end
--
----		message="vars.missionCode:"..tostring(vars.missionCode).." - "..message
--
--	if printToFile then
--		this.PrintToFileTex(message)
--	end
--
--	--r46 Unh unh, fuck it, works very well in some places and crap shit in others, the issue is the stack level can't be dynamic
--	--	local printMessage=""
--	--	local stackLevel = 1
--	--	local source=""
--	--	local stackInfo
--	--	stackInfo=debug.getinfo(stackLevel,"Snl")
--	--
--	----	while source=="" and stackLevel>0 do
--	----		stackInfo=debug.getinfo(stackLevel,"Snl")
--	----		if stackInfo and stackInfo.source~="" then
--	----			source=stackInfo.source
--	----		end
--	----		stackLevel=stackLevel-1
--	----	end
--	--
--	--  if stackInfo then
--	--    printMessage=
--	--    	stackInfo.source
--	--    	.." - "..stackInfo.currentline
--	----    	.." LD:"..stackInfo.linedefined
--	--    	.." - "..stackInfo.name
--	--    	.." > "..message
--	--  end
--	--	this.PrintToFileTex(printMessage)
--	--
--	if announceLog then
--		this.PrintLog(message,...)
--	end
--
--end
--
----r44 Renamed functions
----r45 Better print logs function
--function this.PrintLog(message,...)
--	--r09 Function for relatively easier printing
--	if message==nil then
--		TppUiCommand.AnnounceLogView("nil")
--		return
--	elseif type(message)~="string" then
--		message=tostring(message)
--	end
--
--	if ... then
--	--message=string.format(message,...)--DEBUGNOW
--	end
--
--	while string.len(message)>this.MAX_ANNOUNCE_STRING do
--		local printMessage=string.sub(message,0,this.MAX_ANNOUNCE_STRING)
--		TppUiCommand.AnnounceLogView(printMessage)
--		--    TppUiCommand.AnnounceLogView(printMessage,0,0,true) --rX46 trying to get colored logs, 6 doesn't work either
--		message=string.sub(message,this.MAX_ANNOUNCE_STRING+1)
--	end
--
--	TppUiCommand.AnnounceLogView(message)
--	--  TppUiCommand.AnnounceLogView(message,0,0,true) --rX46 trying to get colored logs, 6 doesn't work either
--end
--
----r46 tex did it again - file logging
----local handle = io.popen"cd"
----local readHandle = handle:read'*l'
----handle:close()
----os.execute("mkdir "..modLogFolderName)
----this.gamePath=readHandle--works! def path is MGSV_TPP.exe path
--
--local modLogFolderName="TUPPM"
--local prev="_prev"
--local ext=".txt"
--local nl="\r\n"
--local stringType="string"
--local functionType="function"
--
--this.gamePath=nil
----this.gamePath=".\\"--nope
----this.gamePath=os.execute("cd")--nope
----this.gamePath="C:\\MyData\\Games\\Steam\\steamapps\\common\\MGS_TPP"--tex TODO: find a way to get games path, otherwise have a chicken and egg
--this.modPath="\\"..modLogFolderName
--this.logFileName="tuppm_log_"..tostring(os.date("%Y.%m.%d"))
----this.logFileName="log_"..tostring(os.date("date_%m.%d.%Y_time_%H.%M.%S"))
----this.logFileName="log_"..tostring(os.date("%d.%b.%Y_%H.%M.%S"))
--
--
--local logFilePath=nil
--local logFilePathPrev=nil
----local logFilePath=this.gamePath..this.modPath.."\\"..this.logFileName..ext
----local logFilePathPrev=this.gamePath..this.modPath.."\\"..this.logFileName..prev..ext
--
----tex NMC from lua wiki
--local function Split(str,delim,maxNb)
--	-- Eliminate bad cases...
--	if string.find(str,delim)==nil then
--		return{str}
--	end
--	if maxNb==nil or maxNb<1 then
--		maxNb=0--No limit
--	end
--	local result={}
--	local pat="(.-)"..delim.."()"
--	local nb=0
--	local lastPos
--	for part,pos in string.gfind(str,pat) do
--		nb=nb+1
--		result[nb]=part
--		lastPos=pos
--		if nb==maxNb then break end
--	end
--	-- Handle the last field
--	if nb~=maxNb then
--		result[nb+1]=string.sub(str,lastPos)
--	end
--	return result
--end
--
--function this.GetCurrentLogPath(isForced)
--	--r47 Only for Windows
--	if Fox.GetPlatformName()~="Windows" then return end
--	if not TUPPMSettings._debug_ENABLE and not isForced then return end
--
--	--r46 ORIG but OBSOLETE
--	--works pretty well - no cmd popups when in game and fullscreen
--	--	local handle = io.popen"cd"
--	--	local readHandle = handle:read'*l'
--	--	handle:close()
--	--
--	os.execute("mkdir "..modLogFolderName)
--
--	-->tex
--	--		local paths=Split(package.path,";")
--	--	  local gamePath=paths[2]--tex first path is .\?.lua, second is <game path>\?.lua
--	--	  local stripLength=10--tex length "\lua\?.lua"
--	--	  gamePath=gamePath:gsub("\\","/")--tex because escaping sucks
--	--	  gamePath=gamePath:sub(1,-stripLength)
--	--<
--
--	--r46 Better way to get game path using lua package lib
--	local readHandle = Split(package.path,";")[2]:sub(1,-10)
--	this.gamePath=readHandle
--	logFilePath=this.gamePath..this.modPath.."\\"..this.logFileName..ext
--	logFilePathPrev=this.gamePath..this.modPath.."\\"..this.logFileName..prev..ext
--end
--
--this.GetCurrentLogPath() --cannot call a func before it is declared
--
--function this.PrintToFileTex(message)
--	--r47 Only for Windows
--	if Fox.GetPlatformName()~="Windows" then return end
--
--	--r51 Settings
--	if not logFilePath then
--		if not TUPPMSettings._debug_ENABLE_forcePrintLogs then return end
--		this.GetCurrentLogPath(TUPPMSettings._debug_ENABLE_forcePrintLogs)
--	end
--
--	local filePath=logFilePath
--
--	--tex NOTE io open append doesnt appear to work - 'Domain error'
--	--TODO think which would be better, just appending to string then writing that
--	--or (doing currently) reading exising and string append/write that
--	--either way performance will decrease as log size increases
--	local logFile,error=io.open(filePath,"r")
--	local logText=""
--	if logFile then
--		logText=logFile:read("*all")
--		logFile:close()
--	end
--
--	local logFile,error=io.open(filePath,"w")
--	--  local logFile,error=io.open("TUPPMLogs.txt","w")
--	if not logFile or error then
--		TppUiCommand.AnnounceLogView("IO Create log error: "..tostring(error))
--		return
--	end
--
--	--  local elapsedTime=Time.GetRawElapsedTimeSinceStartUp()
--	--  local elapsedTime=os.date("%H.%M.%S")..":"..elapsedTime.."\t"
--	local elapsedTime=os.date("%H.%M.%S").."\t"
--	--tex TODO os time?
--
--	local line="|"..elapsedTime.."| "..message
--	logFile:write(logText..line,nl)
--	logFile:close()
--
--end
--
--this.PrintToFileTex("------ Game startup start time: "..tostring(os.date("%Y/%m/%d %X")).." ------")
--this.PrintToFileTex("------ Current log path: "..tostring(this.gamePath).." ------")
--------------------------------------------------------------------------
------------------------------------------------------------< r64 OBSOLETE


--r45 Quiet's cell radio now starts correctly with on foot deployment to Med platform
function this.ForceActivateQuietsCellRadio()
	if vars.missionCode~=30050 then return end

	if f30050_sequence and f30050_sequence.PlayMusicFromQuietRoom then
		--        if TppStory.CanArrivalQuietInMB( false ) and not TppQuest.IsActive("mtbs_q99011") then
		--          local totalPlayTime = TppScriptVars.GetTotalPlayTime()
		--          local radioIndex = totalPlayTime%(#QUIET_RADIO_TELOP_LANG_LIST) + 1
		--          mvars.f30050_quietRadioName = string.format("sfx_m_prison_radio_%02d",radioIndex )
		--        end
		--        f30050_sequence.UpdateQuietRadio()
		--        f30050_sequence.StopMusicFromQuietRoom()
		f30050_sequence.PlayMusicFromQuietRoom()
		--    TUPPMLog.Log("Manually fired Quiet's radio since trap is not entered with on foot LZ")
	end
end

--r35 remove fake support heli that is spawned
--local removeFakeHeliTimer=0
function this.RemoveFirstFakeHeli()
	--r45 Updated for MB/Zoo/MBQF

	if mvars.mis_missionStateIsNotInGame then
		return
	end

	TUPPMLog.Log("RemoveFirstFakeHeli BEG",3)

	--	local isFirstLandStart = TppSequence.IsFirstLandStart() --true for free roam
	--	local isLandContinue = TppSequence.IsLandContinue() --true when continuing from checkpoint, not sure is true after heli start and then continuing from checkpoint - most likely true as well --can be used for MB at least as has very unique behavior on MB
	--
	--	TUPPMLog.Log("isFirstLandStart:"..tostring(isFirstLandStart)
	--					.." isLandContinue:"..tostring(isLandContinue)
	--		)

	if TppMain.firstFakeHeli==0 then return end

	--  TUPPMLog.Log("Can RemoveFirstFakeHeli")

	--    TUPPMLog.Log("svars.scoreTime: "..tostring(svars.scoreTime))
	--    TUPPMLog.Log("svars.clearTime: "..tostring(svars.clearTime))
	--    TUPPMLog.Log("svars.playTime: "..tostring(svars.playTime))

	local gameObjectId = GameObject.GetGameObjectId("TppHeli2", "SupportHeli")
	if gameObjectId==GameObject.NULL_ID then return end
	--  TUPPMLog.Log("gameObjectId not null")

	if gvars.heli_missionStartRoute==nil then
		return
	end

	local route = TppMain.GetUsingRouteDetails()

	if route==nil then
		return
	end
	local takeOffRoute = nil

	--r45 Only remove if not broken
	local isBroken=GameObject.SendCommand(gameObjectId,{id="IsBroken"})
	TUPPMLog.Log("Is heli broken?:"..tostring(isBroken),3)

	--DONE add continue from checkpoint exception for MB where if you destroy the heli before the timer finishes, then
	-- retry from Game Over screen, the heli route fires and spawns the damned thing out of thin air

	if
		not isBroken --not broken
		--  	and not TppSequence.IsLandContinue()
		and not TppMain.comingFromTitleDontFireHeliRemoval --not coming from title
		and not TppMain.mbVeryFastCheckpointReloadHeliRouteNotFireFIX --not checkoint load
	--  	and not gvars.sav_varRestoreForContinue --is FALSE at MB start since MB has no checkpoints except at end of cutscens where it will be useful BUT is true for missions and other free roam :?
	then
		if vars.missionCode==30050 or vars.missionCode==30150 or vars.missionCode==30250 then
			--    TUPPMLog.Log("For MB start")

			--	    GameObject.SendCommand(gameObjectId, { id="DisableDescentToLandingZone" })

			--	    	GameObject.SendCommand(gameObjectId, { id="SetForceRoute", route=route.takeOffRt})
			--		    GameObject.SendCommand( gameObjectId, { id="SetForceRoute", enabled=false })
			--    GameObject.SendCommand(gameObjectId, { id="EnablePullOut" } )

			--Now fire the route that was readied
			--SendPlayerAtRoute does not trigger if the heli is called to LZ or used for support

			--WARNING! It will also trigger after heli is destroyed - need a workaround
			--		    GameObject.SendCommand(gameObjectId, { id="SendPlayerAtRouteStart", route=route.takeOffRt})
			GameObject.SendCommand(gameObjectId, { id="SendPlayerAtRoute", route=route.takeOffRt})

			--rX46 have to be called from demo
			--				GameObject.SendCommand( { type="TppHeli2", index=0, }, { id="SetDemoToSendEnabled", enabled=true, route=route.takeOffRt } )
			--				GameObject.SendCommand( gameObjectId, { id="SetDemoToSendEnabled", enabled=true, route=route.takeOffRt } )

			takeOffRoute=route.takeOffRt
			--    TUPPMLog.Log("For SendPlayerAtRoute")
			--
			--    GameObject.SendCommand(gameObjectId, {id="CallToLandingZoneAtName", name=route.lzname}) --Cannot be fired from inside heli, cannot get out of heli if on route :/



			--    TUPPMLog.Log("For MB return")
			--    TppMain.firstFakeHeli=0
		else
			--  GameObject.SendCommand(gameObjectId, { id="SetLandingZnoeDoorFlag", route="lz_enemyBase_S0000|lz_enemyBase_S_0000", leftDoor="Open",rightDoor="Open" })
			--  GameObject.SendCommand(gameObjectId,{id="SetSendDoorOpenManually",enabled=true})

			--milli seconds - score time is mission time after hitting continue at loading screen
			-- play time starts once the continue option appears on the loading screen
			--  if svars.scoreTime < 4500 then
			--    return
			--  end

			--  --Unset route before calling SendPlayerAtRoute
			--  GameObject.SendCommand(gameObjectId, { id="RequestRoute", enabled=false})
			--  --Used after disabling route, warps heli to route start
			--  GameObject.SendCommand(gameObjectId, { id="SendPlayerAtRoute", route=route.name})
			----  GameObject.SendCommand(gameObjectId, { id="SendPlayerAtRoute", route=route.name, isTakeOff=true })
			--  TUPPMLog.Log("Non MB SendPlayerAtRoute")

			-- WORKING PULLOUT!
			--r45 OBSOLETE method for heli pullout
			--    GameObject.SendCommand( gameObjectId, { id="RequestRoute", enabled=false })
			--    GameObject.SendCommand( gameObjectId, { id="SetForceRoute", enabled=false })
			--    GameObject.SendCommand(gameObjectId, { id="EnablePullOut" } )
			--    GameObject.SendCommand(gameObjectId, { id="PullOut", forced=false}) --Forced true removes the heli instantly

			--TODO rX45 clean up this method
			--r45 Fire route that was readied
			--	    GameObject.SendCommand(gameObjectId, { id="DisableDescentToLandingZone" })

			--	    GameObject.SendCommand(gameObjectId, { id="SetForceRoute", route=route.takeOffRt})
			--	    GameObject.SendCommand( gameObjectId, { id="SetForceRoute", enabled=false })
			--	    GameObject.SendCommand(gameObjectId, { id="SendPlayerAtRouteStart", route=route.takeOffRt})
			GameObject.SendCommand(gameObjectId, { id="SendPlayerAtRoute", route=route.takeOffRt})
			takeOffRoute=route.takeOffRt

			--  GameObject.SendCommand(gameObjectId, { id="MoveToPosition", position=Vector3(vars.playerPosX, vars.playerPosY, vars.playerPosZ), rotationY=0})
			--  GameObject.SendCommand(gameObjectId, { id="WarpToPosition", position=Vector3(vars.playerPosX, vars.playerPosY, vars.playerPosZ), rotationY=0 })
			--  TppMain.firstFakeHeli=0

			--TODO find a way to save Quiet's attack point
			--  TppBuddy2BlockController.ReserveCallBuddy(vars.buddyType,BuddyInitStatus.RIDE,Vector3( 0, 0, 0 ), 0.0 )
			--  TppCheckPoint.UpdateAtCurrentPosition()
			--  TppCheckPoint.Update{}
			--  TppMission.VarSaveOnUpdateCheckPoint(true)
			--  TppMission.UpdateCheckPointAtCurrentPosition()
			--  mvars.ply_doneUpdateCheckPointOnMissionStartDrop=true

			--TODO works! Queit moves, however, she does not pick the attack point
			--  local QUIETgameObjectId = GameObject.GetGameObjectIdByIndex("TppBuddyQuiet2", 0)
			--  if QUIETgameObjectId==nil or QUIETgameObjectId==GameObject.NULL_ID then return end
			--
			--  local playerPosition = TppPlayer.GetPosition()
			--  local calcPosition = { 1.5, 0, -1.5, }
			--  local quietPosition = TppMath.AddVector( playerPosition, calcPosition )
			--  local QUIETgameObjectId = { type="TppBuddyQuiet2", index=0 }
			--  GameObject.SendCommand(QUIETgameObjectId, { id="MoveToPosition", position=Vector3(quietPosition), rotationY=0, index = 99, disableAim = true })
		end
	end

	TUPPMLog.Log("Pullout route:"..tostring(takeOffRoute),3)
	if takeOffRoute then

	end

	--r45 Set soldeirs to unsalute, fire before checkpoint. Unlike heli route firing above and checkpoint below, fire this even when continuing from checkpoint
	if vars.missionCode==30050 and f30050_enemy and f30050_enemy.UnsetSalutationEnemy then
		f30050_enemy.UnsetSalutationEnemy()
		TUPPMLog.Log("Setting soldiers to unsalute on MB",3)
	end

	--r45 FIX for Quiet's first sniping point - she has to be on the ground and ready before the first checkpoint triggers :)
	--Coming from title before this checkpoint has triggered messes up Quiets pos again
	if
		--  	not TppSequence.IsLandContinue()
		not TppMain.comingFromTitleDontFireHeliRemoval
		and not TppMain.mbVeryFastCheckpointReloadHeliRouteNotFireFIX
	--	  	and not TppMission.IsMbFreeMissions(vars.missionCode)
	--  	and not gvars.sav_varRestoreForContinue --is FALSE at MB start since MB has no checkpoints except at end of cutscens where it will be useful BUT is true for missions and other free roam :?
	then
		TUPPMLog.Log("Fire checkpoint after removing heli",3)
		TppMission.UpdateCheckPointAtCurrentPosition()
	end

	TppMain.comingFromTitleDontFireHeliRemoval=false
	TppMain.mbVeryFastCheckpointReloadHeliRouteNotFireFIX=false
	TppMain.firstFakeHeli=0

	TUPPMLog.Log("RemoveFirstFakeHeli END",3)
end

--rX45 Alternate heli removal with CallToLZ command
--Alternate failed fake heli removal method
--If called from EndFadeIn there is a delay between heli setting down to LZ
--Plus the player can get into heli
--Only bonus is buddies not jumping through closed doors as the doors do open up
function this.RemoveFirstFakeHeli2()
	if mvars.mis_missionStateIsNotInGame then
		return
	end

	if TppMain.firstFakeHeli==0 then return end
	TppMain.firstFakeHeli=0

	local gameObjectId = GameObject.GetGameObjectId("TppHeli2", "SupportHeli")
	if gameObjectId==GameObject.NULL_ID then return end

	if gvars.heli_missionStartRoute==nil then
		return
	end

	local route = TppMain.GetUsingRouteDetails()

	if route==nil then
		return
	end

	GameObject.SendCommand(gameObjectId, {id="CallToLandingZoneAtName", name=route.lzname})
	GkEventTimerManager.Start("RemoveFirstFakeHeliTimer2",5)

end

--rX45 Alternate heli removal with CallToLZ command
--The idea of this function was to set SendPlayerAtRouteReady to takeOffRt,
-- calling heli to LZ while in game using CallToLandingZoneAtName, and then firing a pullout
--Issues: heli takes a while to be called to LZ right. Plus, getting into the heli before a pullout stops
-- the pullout but if you get out again the heli immediately violently leaves
function this.PullOutFakeHeli()
	local gameObjectId = GameObject.GetGameObjectId("TppHeli2", "SupportHeli")
	if gameObjectId==GameObject.NULL_ID then return end

	if gvars.heli_missionStartRoute==nil then
		return
	end

	local route = TppMain.GetUsingRouteDetails()

	if route==nil then
		return
	end

	--Now fire the route that was readied
	--  GameObject.SendCommand( gameObjectId, { id="ChangeToIdleState" } ) --removes heli
	--  TUPPMLog.Log("ChangeToIdleState")

	--    GameObject.SendCommand(gameObjectId,{id="Realize"})
	--  GameObject.SendCommand(gameObjectId, { id="SendPlayerAtRouteReady", route=route.takeOffRt}) --SendPlayerAtRoute won't fire after CallToLandingZoneAtName
	--  GameObject.SendCommand(gameObjectId, { id="SendPlayerAtRoute", route=route.takeOffRt}) --SendPlayerAtRoute won't fire after CallToLandingZoneAtName
	--  TUPPMLog.Log("SendPlayerAtRoute start route:"..tostring(route.takeOffRt))

	--  GameObject.SendCommand(gameObjectId, { id="EnablePullOut" } ) --Enables pullout after getting into the heli
	--  TUPPMLog.Log("EnablePullOut")

	--Best approach as far as I tetsted
	GameObject.SendCommand(gameObjectId, { id="PullOut", forced=false}) --Forced true removes the heli instantly
	TUPPMLog.Log("Heli pullOut false",3)

	--  GameObject.SendCommand(gameObjectId, { id="PullOut", forced=true}) --Forced true removes the heli instantly
	--  TUPPMLog.Log("PullOut true")

	--Heli doors remain open as the heli starts from LZ, however if player gets in then gets stuck on infinite heli route loop
	--Plus no commands can be made to heli and has to be removed separately
	--  GameObject.SendCommand(gameObjectId, {id="SetForceRoute",route=route.takeOffRt})


	--r45 Set soldeirs to unsalute, fire before checkpoint
	if vars.missionCode==30050 and f30050_enemy and f30050_enemy.UnsetSalutationEnemy then
		f30050_enemy.UnsetSalutationEnemy()
	end

	--r45 FIX for Quiet's first sniping point - she has to be on the ground and ready before the first checkpoint triggers :)
	TppMission.UpdateCheckPointAtCurrentPosition()
	TUPPMLog.Log("PullOutFakeHeli Completed",3)
end

--TODO rX6 Testing on better solution to pullout support heli
function this.FuncHeliForceRouteOff()

	if mvars.mis_missionStateIsNotInGame then
		return
	end

	local gameObjectId = GameObject.GetGameObjectId("TppHeli2", "SupportHeli")

	if gameObjectId==GameObject.NULL_ID then
		return
	end

	--  GameObject.SendCommand( gameObjectId, { id="SetForceRoute", enabled=false })
	--  GameObject.SendCommand( gameObjectId, { id="RequestRoute", enabled=false })
	--  GameObject.SendCommand(gameObjectId, { id="EnableDescentToLandingZone" })
	--  GameObject.SendCommand( gameObjectId, { id="ChangeToIdleState" } ) --disappears
	--  GameObject.SendCommand(gameObjectId, { id="EnablePullOut" } )
	--  GameObject.SendCommand(gameObjectId, { id="PullOut", forced=true})
	--  GameObject.SendCommand(gameObjectId, { id="PullOut"})
	--GameObject.SendCommand(gameObjectId, { id="RequestRoute", enabled=true, route=gvars.heli_missionStartRoute, point=28, warp=true, isRelaxed=true })

	--GameObject.SendCommand(gameObjectId, { id="RequestRoute", enabled=false, route=gvars.heli_missionStartRoute, point=28, warp=true, isRelaxed=true })
	--GameObject.SendCommand(gameObjectId, { id="RequestRoute", enabled=false, route=gvars.heli_missionStartRoute, point=28, warp=true, isRelaxed=true })

	if not Tpp.IsHelicopter(vars.playerVehicleGameObjectId) then
		GameObject.SendCommand(gameObjectId, { id="CallToLandingZoneAtName",name="lz_enemyBase_S0000|lz_enemyBase_S_0000", point=28, warp=true })
		GameObject.SendCommand(gameObjectId, { id="SetLandingZnoeDoorFlag", route="lz_enemyBase_S0000|lz_enemyBase_S_0000", leftDoor="Open",rightDoor="Open" })
		GameObject.SendCommand(gameObjectId, { id="SetRequestedLandingZoneToCurrent" } )
		GameObject.SendCommand(gameObjectId, { id="EnableDescentToLandingZone" })
	else
		GameObject.SendCommand(gameObjectId, { id="CallToLandingZoneAtName",name="lz_enemyBase_N0000|lz_enemyBase_N_0000", point=28, warp=true })
		GameObject.SendCommand(gameObjectId, { id="SetLandingZnoeDoorFlag", route="lz_enemyBase_N0000|lz_enemyBase_N_0000", leftDoor="Open",rightDoor="Open" })
	end


end

--r46 Call to drop currently equiped weapon/item
local function DropWeaponOrItem()
	local slotType=vars.currentInventorySlot
	if slotType==6 then return end --Don't want to drop bionic arm varieties lol XD
	local subIndex=nil

	if vars.currentInventorySlot==PlayerSlotType.SUPPORT then
		subIndex=vars.currentSupportWeaponIndex
	end

	--TODO rX46 add a check for alredy empty slot and return early

	Player.UnsetEquip{
		slotType=slotType,
		subIndex=subIndex,
		dropPrevEquip=true,
	}

	--Nope
	--	Player.ChangeEquip{
	--		equipId = TppEquip.EQP_None,
	--		toActive = true,
	--		dropPrevEquip = true,
	--	}

	TUPPMLog.Log("Dropped slotType:"..tostring(slotType).." subIndex:"..tostring(subIndex),3)
end

--r46 Drop equiped weapon/item
--Refine - not in vehicle, not on buddy
local dropKeyButtonsHoldTime=0
function this.DropCurrentWeaponOrItem()

	if TppMission.IsFOBMission(vars.missionCode) then return end
	if vars.playerVehicleGameObjectId~=GameObject.NULL_ID then return end --takes care of vehicles, D-Horse, D-Walker and heli

	--NORMAL_ACTION --takes care of every unique action like using AA Guns, ladders, hanging, fultoning, getting in and out of supply boxes etc - pretty much everything. Seems to take care of buddies and vehicles too but did not test
	--BEHIND --is true when in cover, is false when aiming out of cover
	--LFET_STOCK (sic) --true when camera is over to the left of the player else false
	if not PlayerInfo.OrCheckStatus{PlayerStatus.NORMAL_ACTION,PlayerStatus.BEHIND} then return end

	if
		(bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.LIGHT_SWITCH)==PlayerPad.LIGHT_SWITCH)
		--r47 Aim weapon to drop in order to help gamepad players
		and (bit.band(PlayerVars.scannedButtonsDirect,PlayerPad.HOLD)==PlayerPad.HOLD)
	then
		if dropKeyButtonsHoldTime==0 then
			dropKeyButtonsHoldTime=Time.GetRawElapsedTimeSinceStartUp()
		end

		if
			dropKeyButtonsHoldTime~=0
			and Time.GetRawElapsedTimeSinceStartUp() - dropKeyButtonsHoldTime >= 0.7
		then
			local NORMAL_ACTION = PlayerInfo.OrCheckStatus{PlayerStatus.NORMAL_ACTION}
			local BEHIND = PlayerInfo.OrCheckStatus{PlayerStatus.BEHIND}
			local LFET_STOCK = PlayerInfo.OrCheckStatus{PlayerStatus.LFET_STOCK}
			--			TUPPMLog.Log("DropCurrentWeaponOrItem return"
			--			.." NORMAL_ACTION:"..tostring(NORMAL_ACTION)
			--			.." BEHIND:"..tostring(BEHIND)
			--			.." LFET_STOCK:"..tostring(LFET_STOCK)
			--			,3)
			DropWeaponOrItem()
			dropKeyButtonsHoldTime=0
		end
	else
		dropKeyButtonsHoldTime=0
	end

end

--r47 Disable radio calls if cassette tape playing
function this.DisableAllRadioIfCassettePlaying()

	if not TppMusicManager.IsPlayingMusicPlayer() then return end
	--want to play end mission result radio
	if mvars.mis_missionStateIsNotInGame or mvars.mis_loadRequest then
		return
	end
	--  if
	--  	TppMusicManager.IsPlayingMusicPlayer()
	----  	and RadioDaemon.IsPlayingRadio() --did not test
	----  	and TppRadioCommand.IsPlayingRadio() --the radio-in sound plays at least
	--  then
	--  	TppRadioCommand.StopDirect()
	--  end
	TppRadioCommand.StopDirect()
end

--r51 Settings
function this.SetCustomPlayerHealth()
	if not TUPPMSettings.player_ENABLE_customHealth then return end
	Player.ChangeLifeMaxValue(math.min(math.max(TUPPMSettings.player_customHealthPoints or 6000,1),50410))
end

--r36 Revised real time scale code
--local varsclockTimeScale=-1
--r51 Settings
--r65 Revised functionality
function this.SetRealTime()

	if mvars.mis_missionStateIsNotInGame then
		return
	end

	if mvars.mis_loadRequest then
		return
	end

	if TppMission.IsFOBMission(vars.missionCode) then return end

	local time_clockScale = math.max(TUPPMSettings.time_clockScale or 20,0)
	if time_clockScale==3600 then
		time_clockScale=3601
	end

	--	if varsclockTimeScale~=vars.clockTimeScale then
	--    TUPPMLog.Log("vars.clockTimeScale: "..tostring(vars.clockTimeScale))

	if
		vars.clockTimeScale==3600
	--      or (vars.clockTimeScale>=0 and vars.clockTimeScale<1) --Not necessary - high speed cam is safe
	then
	--      TUPPMLog.Log("Using cigar")
	--    TppCommand.Weather.SetClockTimeScale(vars.clockTimeScale) --this defines actual time scale
	else
		--      TUPPMLog.Log("Normal gameplay so setting time scale")
		--r51 Settings
		if TUPPMSettings.time_ENABLE_localComputerTime then
			local todaysDate=os.date("*t")
			local todaysTime=todaysDate.hour*60*60+todaysDate.min*60+todaysDate.sec
			vars.clock=todaysTime
			vars.clockTimeScale=1
		else
			vars.clockTimeScale=time_clockScale
		end
		--      TppCommand.Weather.SetClockTimeScale(vars.clockTimeScale) --this defines actual time scale
	end
	--		varsclockTimeScale=vars.clockTimeScale
	--	end

end

return this
