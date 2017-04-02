local this={}
local StrCode32=Fox.StrCode32
local IsTypeFunc=Tpp.IsTypeFunc
local IsTypeTable=Tpp.IsTypeTable
local IsTypeString=Tpp.IsTypeString
local IsTypeNumber=Tpp.IsTypeNumber
local GkEventTimerManagerStart=GkEventTimerManager.Start
local GetGameObjectId=GameObject.GetGameObjectId
local NULL_ID=GameObject.NULL_ID
local SVarsIsSynchronized=TppScriptVars.SVarsIsSynchronized
local RegistPlayRecord=PlayRecord.RegistPlayRecord
local bitBnot=bit.bnot
local bitBand,bitBor,bitBxor=bit.band,bit.bor,bit.bxor
local GkEventTimerManagerStart=GkEventTimerManager.Start
local GkEventTimerManagerStop=GkEventTimerManager.Stop
local GkEventTimerManagerIsTimerActive=GkEventTimerManager.IsTimerActive
local IsHelicopter=Tpp.IsHelicopter
local IsNotAlert=Tpp.IsNotAlert
local IsPlayerStatusNormal=Tpp.IsPlayerStatusNormal
local IsDemoPlaying=DemoDaemon.IsDemoPlaying
local UNKnumber10=10
local UNKnumber3=3
local outSideOfHotZoneCount=5
local outSideOfInnerZoneTime=2.5
local Timer_outsideOfInnerZone="Timer_outsideOfInnerZone"
local missionClearCodeNone=0
local maxObjective=64
local deathLimitToStealthAssistPopup=1
local deathLimitToPerfectStealthPopup=0
--local timeBeforeLilChickCapCanBeUsedAgain=1
local timeBeforeLilChickCapCanBeUsedAgain=(24*60)*60 --rX46

--r51 Settings
if TUPPMSettings.game_timeToLittleChickenHatReuse then
	timeBeforeLilChickCapCanBeUsedAgain=math.floor(math.min(math.max(TUPPMSettings.game_timeToLittleChickenHatReuse,1),(24*60)*60))
end

local UNKnumber2=2
local MAX_32BIT_UINT=TppDefine.MAX_32BIT_UINT

local function v()
	RegistPlayRecord"MISSION_TIMER_UPDATE"
end
function this.GetMissionID()
	return vars.missionCode
end
function this.GetMissionName()
	return mvars.mis_missionName
end
function this.GetMissionClearType()
	return svars.mis_missionClearType
end
function this.IsDefiniteMissionClear()
	return svars.mis_isDefiniteMissionClear
end
function this.RegiserMissionSystemCallback(n)
	this.RegisterMissionSystemCallback(n)
end
function this.RegisterMissionSystemCallback(n)
	if IsTypeTable(n)then
		if IsTypeFunc(n.OnEstablishMissionClear)then
			this.systemCallbacks.OnEstablishMissionClear=n.OnEstablishMissionClear
		end
		if IsTypeFunc(n.OnDisappearGameEndAnnounceLog)then
			this.systemCallbacks.OnDisappearGameEndAnnounceLog=n.OnDisappearGameEndAnnounceLog
		end
		if IsTypeFunc(n.OnEndMissionCredit)then
			this.systemCallbacks.OnEndMissionCredit=n.OnEndMissionCredit
		end
		if IsTypeFunc(n.OnEndMissionReward)then
			this.systemCallbacks.OnEndMissionReward=n.OnEndMissionReward
		end
		if IsTypeFunc(n.OnGameOver)then
			this.systemCallbacks.OnGameOver=n.OnGameOver
		end
		if IsTypeFunc(n.OnOutOfMissionArea)then
			this.systemCallbacks.OnOutOfMissionArea=n.OnOutOfMissionArea
		end
		if IsTypeFunc(n.OnUpdateWhileMissionPrepare)then
			this.systemCallbacks.OnUpdateWhileMissionPrepare=n.OnUpdateWhileMissionPrepare
		end
		if IsTypeFunc(n.OnFobDefenceGameOver)then
			this.systemCallbacks.OnFobDefenceGameOver=n.OnFobDefenceGameOver
		end
		if IsTypeFunc(n.OnFinishBlackTelephoneRadio)then
			this.systemCallbacks.OnFinishBlackTelephoneRadio=n.OnFinishBlackTelephoneRadio
		end
		if IsTypeFunc(n.OnOutOfHotZone)then
		end
		if IsTypeFunc(n.OnOutOfHotZoneMissionClear)then
			this.systemCallbacks.OnOutOfHotZoneMissionClear=n.OnOutOfHotZoneMissionClear
		end
		if IsTypeFunc(n.OnUpdateStorySequenceInGame)then
			this.systemCallbacks.OnUpdateStorySequenceInGame=n.OnUpdateStorySequenceInGame
		end
		if IsTypeFunc(n.CheckMissionClearFunction)then
			this.systemCallbacks.CheckMissionClearFunction=n.CheckMissionClearFunction
		end
		if IsTypeFunc(n.OnReturnToMission)then
			this.systemCallbacks.OnReturnToMission=n.OnReturnToMission
		end
		if IsTypeFunc(n.OnAddStaffsFromTempBuffer)then
			this.systemCallbacks.OnAddStaffsFromTempBuffer=n.OnAddStaffsFromTempBuffer
		end
		if IsTypeFunc(n.CheckMissionClearOnRideOnFultonContainer)then
			this.systemCallbacks.CheckMissionClearOnRideOnFultonContainer=n.CheckMissionClearOnRideOnFultonContainer
		end
		if IsTypeFunc(n.OnRecovered)then
			this.systemCallbacks.OnRecovered=n.OnRecovered
		end
		if IsTypeFunc(n.OnSetMissionFinalScore)then
			this.systemCallbacks.OnSetMissionFinalScore=n.OnSetMissionFinalScore
		end
		if IsTypeFunc(n.OnEndDeliveryWarp)then
			this.systemCallbacks.OnEndDeliveryWarp=n.OnEndDeliveryWarp
		end
		if IsTypeFunc(n.OnMissionGameEndFadeOutFinish)then
			this.systemCallbacks.OnMissionGameEndFadeOutFinish=n.OnMissionGameEndFadeOutFinish
		end
		if IsTypeFunc(n.OnFultonContainerMissionClear)then
			this.systemCallbacks.OnFultonContainerMissionClear=n.OnFultonContainerMissionClear
		end
	end
end
function this.UpdateObjective(n)
	if not mvars.mis_missionObjectiveDefine then
		return
	end
	if mvars.mis_objectiveSetting then
		this.ShowUpdateObjective(mvars.mis_objectiveSetting)
	end
	local i=n.radio
	local t=n.radioSecond
	local o=n.options
	mvars.mis_objectiveSetting=n.objectives
	mvars.mis_updateObjectiveRadioGroupName=nil
	if not IsTypeTable(mvars.mis_objectiveSetting)then
		return
	end
	local n
	if TppSequence.IsHelicopterStart()then
		if not TppPlayer.IsAlreadyDropped()then
			n=true
		end
	end
	if IsTypeTable(o)then
		if o.isForceHelicopterStart then
			n=true
		end
	end
	if n then
		mvars.mis_updateObjectiveOnHelicopterStart=true
	end
	local o=false
	for n,i in pairs(mvars.mis_objectiveSetting)do
		local n=not this.IsEnableMissionObjective(i)
		if n then
			n=not this.IsEnableAnyParentMissionObjective(i)
		end
		if n then
			o=true
			break
		end
	end
	if IsTypeTable(i)then
		if o then
			if not n then
				mvars.mis_updateObjectiveRadioGroupName=TppRadio.GetRadioNameAndRadioIDs(i.radioGroups)
			end
			local e=this.GetObjectiveRadioOption(i)
			TppRadio.Play(i.radioGroups,e)
		end
	end
	if IsTypeTable(t)then
		if o then
			local e=this.GetObjectiveRadioOption(t)
			if n then
				mvars.mis_updateObjectiveDoorOpenRadioGroups=t.radioGroups
				mvars.mis_updateObjectiveDoorOpenRadioOptions=e
			else
				e.isEnqueue=true
				TppRadio.Play(t.radioGroups,e)
			end
		end
	end
	if not IsTypeTable(i)then
		this.ShowUpdateObjective(mvars.mis_objectiveSetting)
	end
end
function this.SetHelicopterDoorOpenTime(e)
	if not IsTypeNumber(e)then
		return
	end
	mvars.mis_helicopterDoorOpenTimerTimeSec=e
end
function this.UpdateCheckPoint(e)
	TppCheckPoint.Update(e)
end
function this.UpdateCheckPointAtCurrentPosition()
	TppCheckPoint.UpdateAtCurrentPosition()
end
function this.IsMatchStartLocation(missionId)
	local e=TppPackList.GetLocationNameFormMissionCode(missionId)
	if TppLocation.IsAfghan()then
		if TppDefine.LOCATION_ID[e]~=TppDefine.LOCATION_ID.AFGH then
			return false
		end
	elseif TppLocation.IsMiddleAfrica()then
		if TppDefine.LOCATION_ID[e]~=TppDefine.LOCATION_ID.MAFR then
			return false
		end
	elseif TppLocation.IsMotherBase()then
		if TppDefine.LOCATION_ID[e]~=TppDefine.LOCATION_ID.MTBS then
			return false
		end
	else
		return false
	end
	return true
end
function this.RegistDiscoveryGameOver()
	mvars.mis_isExecuteGameOverOnDiscoveryNotice=true
end
function this.IsStartFromHelispace()
	return gvars.mis_isStartFromHelispace
end
function this.IsStartFromFreePlay()
	return gvars.mis_isStartFromFreePlay
end
function this.AcceptMission(n)
	if this.IsEmergencyMission(n)then
		return
	end
	if not this.IsHelicopterSpace(vars.missionCode)then
		return
	end
	this.SetNextMissionCodeForMissionClear(n)
	TppUiCommand.StartMissionPreparation()
end
function this.AcceptMissionOnFreeMission(n,s,t)
	if this.IsEmergencyMission(n)then
		return
	end
	local i=this.IsMatchStartLocation(n)
	if not i then
		return
	end
	local i=TppDefine.NO_ORDER_BOX_MISSION_ENUM[tostring(n)]
	if i then
		local i=TppDefine.NO_ORDER_FIX_HELICOPTER_ROUTE[n]
		if i then
			this.ReserveMissionClear{nextMissionId=n,nextHeliRoute=i,missionClearType=TppDefine.MISSION_CLEAR_TYPE.FREE_PLAY_NO_ORDER_BOX}
		else
			this.ReserveMissionClear{nextMissionId=n,missionClearType=TppDefine.MISSION_CLEAR_TYPE.FREE_PLAY_NO_ORDER_BOX}
		end
		return
	end
	local i=n
	if this.IsHardMission(i)then
		i=this.GetNormalMissionCodeFromHardMission(i)
	end
	local e=s[i]
	if e==nil then
		return
	end
	svars[t]=n
	TppScriptBlock.Load("orderBoxBlock",i,true)
	return true
end
function this.AcceptMissionOnMBFreeMission(missionId,grade,heliRouteTable)
	if this.IsEmergencyMission(missionId)then
		return
	end
	local i=this.IsMatchStartLocation(missionId)
	if not i then
		return
	end
	local i=TppDefine.NO_ORDER_FIX_HELICOPTER_ROUTE[missionId]
	if missionId==10115 then
		i=heliRouteTable[grade][1]
	end
	if i then
		this.ReserveMissionClear{nextHeliRoute=i,nextMissionId=missionId,missionClearType=TppDefine.MISSION_CLEAR_TYPE.FREE_PLAY_NO_ORDER_BOX}
	else
		this.ReserveMissionClear{nextMissionId=missionId,missionClearType=TppDefine.MISSION_CLEAR_TYPE.FREE_PLAY_NO_ORDER_BOX}
	end
end
function this.AcceptEmergencyMission(n,s,i,t)
	if not this.IsEmergencyMission(n)then
		return
	end
	local o=this.GetCurrentLocationHeliMissionAndLocationCode()
	if this.IsFOBMission(n)==true then
		vars.returnStaffHeader=vars.playerStaffHeader
		vars.returnStaffSeeds=vars.playerStaffSeed
	end
	this.AbortMission{emergencyMissionId=n,nextMissionId=o,nextLayoutCode=s,nextClusterId=i,nextMissionStartRoute=t,isNoSave=true,isInterrupt=true}
end
function this.AcceptStartFobSneaking(i,s,n)
	this.SetNextMissionCodeForMissionClear(n)
	mvars.mis_nextLayoutCode=TppLocation.ModifyMbsLayoutCode(i)
	mvars.mis_nextClusterId=s
end
function this.SelectNextMissionHeliStartRoute(n,i,t)
	local s
	if not t then
		s=this.IsEmergencyMission(n)
	end
	local t=TppDefine.NO_HELICOPTER_ROUTE_ENUM[tostring(n)]
	if not t then
		local e=TppDefine.NO_ORDER_FIX_HELICOPTER_ROUTE[n]
		if e then
			i=StrCode32(e)
		end
	else
		i=0
	end
	if not t then
		if i==0 then
		end
	end
	if s then
		gvars.mis_nextMissionCodeForEmergency=n
	else
		this.SetNextMissionCodeForMissionClear(n)
		gvars.heli_missionStartRoute=i
	end
end
function this.SetHelicopterMissionStartPosition(s,i,n,e)
	if s==1 then
		mvars.mis_helicopterMissionStartPosition={i,n,e}
	else
		mvars.mis_helicopterMissionStartPosition=nil
	end
end
function this.StartEmergencyMissionTimer(i)
	if not IsTypeTable(i)then
		return
	end
	local n=i.openTimer
	if not IsTypeTable(n)then
		return
	end
	local i=i.closeTimer
	if not IsTypeTable(i)then
		return
	end
	local s,t,a=n.name,n.timeSecFromHeli,n.timeSecFromLand
	local o,r,i=i.name,i.timeSecFromHeli,i.timeSecFromLand
	local n
	n=this._StartEmergencyMissionTimer(s,t,a)
	if n then
	else
		return
	end
	n=this._StartEmergencyMissionTimer(o,r,i)
	if n then
	else
		return
	end
end
function this._StartEmergencyMissionTimer(n,i,s)
	if not IsTypeString(n)then
		return
	end
	if not IsTypeNumber(i)then
		return
	end
	if not IsTypeNumber(s)then
		return
	end
	if this.IsStartFromHelispace()then
		GkEventTimerManagerStart(n,i)
		return i
	else
		GkEventTimerManagerStart(n,s)
		return s
	end
end
function this.Reload(options)
	--TUPPMLog.Log("TppMission.Reload START",1)
	local isNoFade,missionPackLabelName,locationCode,OnEndFadeOut,showLoadingTips,ignoreMtbsLoadLocationForce
	if options then
		isNoFade=options.isNoFade
		missionPackLabelName=options.missionPackLabelName
		locationCode=options.locationCode
		showLoadingTips=options.showLoadingTips
		ignoreMtbsLoadLocationForce=options.ignoreMtbsLoadLocationForce
		mvars.mis_nextLayoutCode=options.layoutCode
		mvars.mis_nextClusterId=options.clusterId
		OnEndFadeOut=options.OnEndFadeOut
	end
	if showLoadingTips~=nil then
		mvars.mis_showLoadingTipsOnReload=showLoadingTips
	else
		mvars.mis_showLoadingTipsOnReload=true
	end
	if ignoreMtbsLoadLocationForce then
		mvars.mis_ignoreMtbsLoadLocationForce=true
	end
	if missionPackLabelName then
		mvars.mis_missionPackLabelName=missionPackLabelName
	end
	if locationCode then
		mvars.mis_nextLocationCode=locationCode
	end
	if OnEndFadeOut and IsTypeFunc(OnEndFadeOut)then
		mvars.mis_reloadOnEndFadeOut=OnEndFadeOut
	else
		mvars.mis_reloadOnEndFadeOut=nil
	end
	if isNoFade then
		this.ExecuteReload()
	else
		TppUI.FadeOut(TppUI.FADE_SPEED.FADE_NORMALSPEED,"ReloadFadeOutFinish",nil,{setMute=true})
	end
end
function this.RestartMission(n)
	TppRevenge.seedValue=0 --r27 Different random seed for each soldier
	--r66 BUGFIX minor - takes care of restarts/checkpoints
	if TUPPMSettings.heli_ENABLE_skipRides then
		TppMain.isFakeHeliDropRequired=true --r35 Spawn fake heli on restart - works well enough
		TppMain.comingFromTitleDontFireHeliRemoval=false --r45 MB heli routes firing and title screen firing fix
		TppMain.mbVeryFastCheckpointReloadHeliRouteNotFireFIX=false
	end

	local s
	local i
	if n then
		s=n.isNoFade
		i=n.isReturnToMission
	end
	TppMain.EnablePause()
	if i then
		mvars.mis_isReturnToMission=true
	end
	if this.IsFOBMission(vars.missionCode)and(vars.fobSneakMode==FobMode.MODE_SHAM)then
		TppNetworkUtil.SessionEnableAccept(false)
		TppNetworkUtil.SessionDisconnectPreparingMembers()
	end
	if s then
		this.ExecuteRestartMission(mvars.mis_isReturnToMission)
	else
		TppUI.FadeOut(TppUI.FADE_SPEED.FADE_NORMALSPEED,"RestartMissionFadeOutFinish",nil,{setMute=true,exceptGameStatus={AnnounceLog="INVALID_LOG"}})
	end
end
function this.ExecuteRestartMission(i)
	TppRevenge.seedValue=0 --r27 Different random seed for each soldier
	--r66 BUGFIX minor - takes care of restarts/checkpoints
	if TUPPMSettings.heli_ENABLE_skipRides then
		TppMain.isFakeHeliDropRequired=true --r35 Spawn fake heli on restart - works well enough
		TppMain.comingFromTitleDontFireHeliRemoval=false --r45 MB heli routes firing and title screen firing fix
		TppMain.mbVeryFastCheckpointReloadHeliRouteNotFireFIX=false
	end

	this.SafeStopSettingOnMissionReload()
	TppQuest.OnMissionGameEnd()
	TppPlayer.ResetInitialPosition()
	TppMain.ReservePlayerLoadingPosition(TppDefine.MISSION_LOAD_TYPE.MISSION_RESTART)
	this.VarResetOnNewMission()
	local s
	if i then
		s=this.ExecuteOnReturnToMissionCallback()
		if(vars.missionCode==30050)then
			this.ResetMBFreeStartPositionToCommand()
		end
	end
	local n=TppPackList.GetLocationNameFormMissionCode(vars.missionCode)
	if n then
		local e=TppDefine.LOCATION_ID[n]
		if e then
			vars.locationCode=e
		end
	end
	TppSave.VarSave()
	if mvars.mis_needSaveConfigOnNewMission then
		TppSave.VarSaveConfig()
	end
	local n=nil
	if i then
		this.ClearFobMode()n=vars.missionCode
	end
	local n=function()
		TppUiStatusManager.SetStatus("AnnounceLog","INVALID_LOG")
		if gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_ESCAPE_THE_HOSPITAL then
			local i={force=true}
			if this.IsFOBMission(vars.missionCode)then
				i={force=true,waitOnLoadingTipsEnd=false}
			end
			this.RequestLoad(vars.missionCode,n,i)
		else
			this.Load(vars.missionCode,n,{force=true})
		end
	end
	if s then
		this.ShowAnnounceLogOnFadeOut(n)
	else
		n()
	end
end
function this.ContinueFromCheckPoint(n)
	TppRevenge.seedValue=0 --r27 Different random seed for each soldier
	--r66 BUGFIX minor - takes care of restarts/checkpoints
	if TUPPMSettings.heli_ENABLE_skipRides then
		TppMain.mbVeryFastCheckpointReloadHeliRouteNotFireFIX=true --r45 MB heli routes firing and title screen firing fix
		TppMain.firstFakeHeli=1
	end

	local i
	local s
	if n then
		i=n.isNoFade
		s=n.isReturnToMission
	end
	TppMain.EnablePause()
	if s then
		mvars.mis_isReturnToMission=true
	end
	if i then
		--rX46 Not the flow for game over screen checkpoint, probably used somewhere special
		--  	TUPPMLog.Log("ContinueFromCheckPoint about to ExecuteContinueFromCheckPoint",3)
		this.ExecuteContinueFromCheckPoint(nil,nil,mvars.mis_isReturnToMission)
	else
		--rX46 Flow for pause menu checkpoint
		--  	TUPPMLog.Log("ContinueFromCheckPoint about to TppUI.FadeOut",3)
		TppUI.FadeOut(TppUI.FADE_SPEED.FADE_NORMALSPEED,"ContinueFromCheckPointFadeOutFinish",nil,{setMute=true,exceptGameStatus={AnnounceLog="INVALID_LOG"}})
	end
end
function this.ReturnToMission(n)
	local n=n or{}n.isReturnToMission=true
	this.DisableInGameFlag()
	this.ResetEmegerncyMissionSetting()
	local s,i=vars.missionHeroicPoint,vars.missionOgrePoint
	if(vars.missionCode==50050)then
		TppSave.VarRestoreOnContinueFromCheckPoint()
		if TppNetworkUtil.IsSessionConnect()then
			TppNetworkUtil.CloseSession()
		end
		if n.withServerPenalty then
			TppServerManager.AbortDefenseMotherBase()
		end
	else
		TppSave.VarRestoreOnMissionStart()
	end
	this.SetHeroicAndOgrePointInSlot(s,i)
	this.RestartMission(n)
end
function this.ExecuteContinueFromCheckPoint(i,a,o)
	TppRevenge.seedValue=0 --r27 Different random seed for each soldier
	--r66 BUGFIX minor - takes care of restarts/checkpoints
	if TUPPMSettings.heli_ENABLE_skipRides then
		TppMain.mbVeryFastCheckpointReloadHeliRouteNotFireFIX=true --r45 MB heli routes firing and title screen firing fix
		TppMain.firstFakeHeli=1
	end

	TppQuest.OnMissionGameEnd()
	TppWeather.OnEndMissionPrepareFunction()
	this.SafeStopSettingOnMissionReload()
	local t=gvars.usingNormalMissionSlot
	local n=vars.missionCode
	if not this.IsFOBMission(n)then
		this.IncrementRetryCount()
	end
	if gvars.usingNormalMissionSlot==false then
		this.ResetEmegerncyMissionSetting()
		TppSave.VarRestoreOnContinueFromCheckPoint()
	end
	if this.IsFOBMission(n)then
		TppSave.VarRestoreOnContinueFromCheckPoint()
	end
	if TppSystemUtility.GetCurrentGameMode()=="TPP"then
		TppEnemy.StoreSVars(true)
	end
	TppWeather.StoreToSVars()
	TppMarker.StoreMarkerLocator()
	TppMain.ReservePlayerLoadingPosition(TppDefine.MISSION_LOAD_TYPE.CONTINUE_FROM_CHECK_POINT)
	TppPlayer.StoreSupplyCbox()
	TppPlayer.StoreSupportAttack()
	TppPlayer.StorePlayerDecoyInfos()
	TppRadioCommand.StoreRadioState()
	local s
	if o then
		s=this.ExecuteOnReturnToMissionCallback()
	end
	if t then
		if a==GameOverMenu.POPUP_RESULT_YES then
			if i==GameOverMenu.STEALTH_ASSIST_POPUP then
				svars.dialogPlayerDeadCount=0
			end
			if i==GameOverMenu.PERFECT_STEALTH_POPUP then
				svars.chickCapEnabled=true
			end
		end
		if this.IsHardMission(vars.missionCode)then
			TppPlayer.UnsetRetryFlag()
		else
			if svars.chickCapEnabled then
				TppPlayer.SetRetryFlagWithChickCap()
			elseif GameConfig.GetStealthAssistEnabled()then
				TppPlayer.SetRetryFlag()
			else
				TppPlayer.UnsetRetryFlag()
			end
		end
		TppSave.VarSaveOnRetry()
		if not this.IsFOBMission(vars.missionCode)then
			TppSave.SaveGameData(vars.missionCode,nil,nil,true)
		end
	end
	local n=function()
		TppUiStatusManager.SetStatus("AnnounceLog","INVALID_LOG")
		local i
		if this.IsFOBMission(n)then
			i={waitOnLoadingTipsEnd=false}
		end
		if gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_ESCAPE_THE_HOSPITAL then
			this.RequestLoad(vars.missionCode,n,i)
		else
			this.Load(vars.missionCode,n,i)
		end
	end
	if s then
		this.ShowAnnounceLogOnFadeOut(n)
	else
		n()
	end
end
function this.IncrementRetryCount()PlayRecord.RegistPlayRecord"MISSION_RETRY"Tpp.IncrementPlayData"totalRetryCount"TppSequence.IncrementContinueCount()
end
function this.ExecuteOnReturnToMissionCallback()
	local n
	if this.systemCallbacks and this.systemCallbacks.OnReturnToMission then
		n=this.systemCallbacks.OnReturnToMission
	end
	if n then
		TppMain.DisablePause()Player.SetPause()
		TppUiStatusManager.ClearStatus"AnnounceLog"n()
		TppTerminal.AddStaffsFromTempBuffer()
		TppSave.VarSave()
		TppSave.SaveGameData(nil,nil,nil,true)
	end
	return n
end
function this.AbortMission(n)
	local r
	local S
	local T
	local i
	local c
	local f
	local u
	local d
	local l
	local p
	local m
	local t,o,a=0,0,TppUI.FADE_SPEED.FADE_NORMALSPEED
	local O
	local M
	if IsTypeTable(n)then
		r=n.isNoFade
		f=n.emergencyMissionId
		u=n.nextMissionId
		d=n.nextLayoutCode
		l=n.nextClusterId
		p=n.nextMissionStartRoute
		c=n.isExecMissionClear
		S=n.isNoSave
		T=n.isInterrupt
		m=n.isAlreadyGameOver
		if n.delayTime then
			t=n.delayTime
		end
		if n.fadeDelayTime then
			o=n.fadeDelayTime
		end
		if n.fadeSpeed then
			a=n.fadeSpeed
		end
		O=n.presentationFunction
		i=n.isTitleMode
		M=n.playRadio
	end
	if not this.CheckMissionState(c,true)then
		return
	end
	if mvars.mis_isAborting then
		return
	end
	if t then
		mvars.mis_missionAbortDelayTime=t
	end
	if o then
		mvars.mis_missionAbortFadeDelayTime=o
	end
	if a then
		mvars.mis_missionAbortFadeSpeed=a
	end
	mvars.mis_abortPresentationFunction=O
	if i then
		mvars.mis_abortIsTitleMode=i
	end
	mvars.mis_abortWithPlayRadio=M
	mvars.mis_emergencyMissionCode=f
	mvars.mis_nextMissionCodeForAbort=u
	mvars.mis_nextLayoutCodeForAbort=d
	mvars.mis_nextClusterIdForAbort=l
	mvars.mis_nextMissionStartRouteForAbort=p
	if S then
		mvars.mis_abortWithSave=false
	else
		mvars.mis_abortWithSave=true
	end
	if r then
		mvars.mis_abortWithFade=false
	else
		mvars.mis_abortWithFade=true
	end
	if T then
		mvars.mis_isInterruptMission=true
	end
	if not m then
		this.ReserveGameOver(TppDefine.GAME_OVER_TYPE.ABORT,TppDefine.GAME_OVER_RADIO.OUT_OF_MISSION_AREA,true)
	else
		this.EstablishedMissionAbort()
	end
end
function this.ExecuteMissionAbort()
	this.VarSaveForMissionAbort()
	this.LoadForMissionAbort()
end
function this.VarSaveForMissionAbort()
	if this.IsFOBMission(vars.missionCode)then
		if(vars.fobSneakMode==FobMode.MODE_SHAM)then
			mvars.mis_abortWithSave=false
		else
			mvars.mis_abortWithSave=true
		end
	end
	if not mvars.mis_nextMissionCodeForAbort then
		Tpp.DEBUG_Fatal"Not defined next missionId!!"this.RestartMission()
		return
	end
	this.SafeStopSettingOnMissionReload()
	if TppServerManager.FobIsSneak()then
		TppServerManager.AbortSneakMotherBase()
	end
	this.UnsetFobSneakFlag(mvars.mis_nextMissionCodeForAbort)
	local missionCode=vars.missionCode
	if gvars.ini_isTitleMode then
		gvars.title_nextMissionCode=missionCode
		gvars.title_nextLocationCode=vars.locationCode
		TppVarInit.InitializeForNewMission{}
		Player.SetPause()
	end
	mvars.mis_missionAbortLoadingOption={}
	local isHelicopterSpace=this.IsHelicopterSpace(missionCode)
	local isFreeMission=this.IsFreeMission(missionCode)
	local nextIsHelicopterSpace=this.IsHelicopterSpace(mvars.mis_nextMissionCodeForAbort)
	local nextIsFreeMission=this.IsFreeMission(mvars.mis_nextMissionCodeForAbort)
	if mvars.mis_isInterruptMission then
		gvars.usingNormalMissionSlot=false
		if isHelicopterSpace then
			mvars.mis_missionAbortLoadingOption.showLoadingTips=false
		else
			mvars.mis_missionAbortLoadingOption.showLoadingTips=true
			mvars.mis_missionAbortLoadingOption.waitOnLoadingTipsEnd=false
		end
		if mvars.mis_emergencyMissionCode then
			gvars.mis_nextMissionCodeForEmergency=mvars.mis_emergencyMissionCode
		end
		if mvars.mis_nextLayoutCodeForAbort then
			gvars.mis_nextLayoutCodeForEmergency=mvars.mis_nextLayoutCodeForAbort
		end
		if mvars.mis_nextClusterIdForAbort then
			gvars.mis_nextClusterIdForEmergency=mvars.mis_nextClusterIdForAbort
		end
		if mvars.mis_nextMissionStartRouteForAbort then
			gvars.mis_nextMissionStartRouteForEmergency=mvars.mis_nextMissionStartRouteForAbort
		end
	end
	vars.missionCode=mvars.mis_nextMissionCodeForAbort
	mvars.mis_abortCurrentMissionCode=missionCode
	if this.IsFOBMission(vars.missionCode)then
		vars.mbLayoutCode=TppLocation.ModifyMbsLayoutCode(mvars.mis_nextLayoutCodeForAbort)
		vars.mbClusterId=mvars.mis_nextClusterIdForAbort
		vars.locationCode=TppDefine.LOCATION_ID.MTBS
	else
		local locationName=TppPackList.GetLocationNameFormMissionCode(vars.missionCode)
		if locationName then
			local locationCode=TppDefine.LOCATION_ID[locationName]
			if locationCode then
				vars.locationCode=locationCode
			end
		end
	end
	TppTerminal.ClearStaffNewIcon(isHelicopterSpace,isFreeMission,nextIsHelicopterSpace,nextIsFreeMission)
	TppEnemy.ClearDDParameter()
	if(not this.IsFOBMission(missionCode)and not this.IsFreeMission(missionCode))and not this.IsHelicopterSpace(missionCode)then
		TppRevenge.ReduceRevengePointOnAbort(missionCode)
	end
	if mvars.mis_abortWithSave then
		if nextIsFreeMission then
			this.ReserveMissionStartRecoverSoundDemo()
		else
			this.ClearMissionStartRecoverSoundDemo()
		end
		if not mvars.mis_abortByRestartFromHelicopter then
			TppEnemy.FultonRecoverOnMissionGameEnd()
			TppHero.AnnounceMissionAbort()
		end
		if nextIsHelicopterSpace then
			TppPlaced.DeleteAllCaptureCage()
		else
			TppPlayer.SaveCaptureAnimal()
		end
		TppClock.SaveMissionStartClock()
		TppWeather.SaveMissionStartWeather()
		TppTerminal.AddStaffsFromTempBuffer()
		TppRevenge.OnMissionClearOrAbort(missionCode)
		TppRevenge.SaveMissionStartMineArea()
		if gvars.solface_groupNumber>=4294967295 then
			gvars.solface_groupNumber=0
		else
			gvars.solface_groupNumber=gvars.solface_groupNumber+1
		end
		gvars.hosface_groupNumber=(math.random(0,65535)*65536)+math.random(1,65535)
		TppPlayer.SavePlayerCurrentWeapons()
		local areRestored=TppPlayer.RestoreWeaponsFromUsingTemp()
		if not areRestored then
			TppPlayer.SavePlayerCurrentAmmoCount()
		end
		TppPlayer.SavePlayerCurrentItems()
		TppPlayer.RestoreItemsFromUsingTemp()
		TppPlayer.StoreSupplyCbox()
		TppPlayer.StoreSupportAttack()
		Gimmick.StoreSaveDataPermanentGimmickFromMission()
		TppGimmick.DecrementCollectionRepopCount()
		--r51 Settings
		if TUPPMSettings.res_ENABLE_instantRepopOfCollectibles then
			TppGimmick.DecrementCollectionRepopCount()--r27 Instant repopulation of small collectibles
			TppGimmick.DecrementCollectionRepopCount()
			TppGimmick.DecrementCollectionRepopCount()
			TppGimmick.DecrementCollectionRepopCount()
		end
		this.ExecuteVehicleSaveCarryOnAbort()
		TppBuddyService.SetVarsMissionStart()
		this.KillDyingQuiet()
		if(not isHelicopterSpace)and nextIsFreeMission then
			--r51 Settings
			if not TUPPMSettings.player_ENABLE_keepWeaponsBetweenFreeMissionTransitions then
				--r46 Carry weapons between (Free Roam-Missions-ACC) --Mission abort via menu resets weapons to those at the time of starting the mission from free roam
				--r46 Keep weapons between free roam->mission and mission->free roam allowing for better OSP runs
				TppUiCommand.LoadoutSetMissionEndFromMissionToFree()
			end
		end
		if gvars.usingNormalMissionSlot then
			TppStory.FailedRetakeThePlatformIfOpened()
		end
		TppMotherBaseManagement.CheckMisogi()
	else
		if gvars.usingNormalMissionSlot then
			TppPlayer.RestoreWeaponsFromUsingTemp()
			TppPlayer.RestoreItemsFromUsingTemp()
			if not TppStory.IsAlwaysOpenRetakeThePlatform()then
				--rX65 This occurs on each mission abort via pause menu untill M22 is opened
				--TUPPMLog.Log("not TppStory.IsAlwaysOpenRetakeThePlatform():"..tostring(not TppStory.IsAlwaysOpenRetakeThePlatform()),3,true)
				TppStory.CloseRetakeThePlatform()
			end
		end
		this.ClearMissionStartRecoverSoundDemo()
		TppPlayer.ResetMissionStartPosition()
		TppUiStatusManager.SetStatus("AnnounceLog","INVALID_LOG")
	end
	if nextIsHelicopterSpace then
		--rX46 Carry weapons between (Free Roam-Missions-ACC) --Mission abort via menu resets weapons to those at the time of starting the mission from free roam
		TppUiCommand.LoadoutSetReturnHelicopter()
	end
	local unlockStaffForMission={
		[10091]=TppMotherBaseManagement.UnlockedStaffsS10091,
		[10081]=TppMotherBaseManagement.UnlockedStaffS10081,
		[10115]=TppMotherBaseManagement.UnlockedStaffsS10115
	}
	local unlockStaffFunc=unlockStaffForMission[missionCode]
	if unlockStaffFunc then
		if TppStory.IsMissionCleard(missionCode)then
			unlockStaffFunc{crossMedal=false} --rX46 Func call params
		end
	end
	TppBuddyService.BuddyMissionInit()
	TppMain.ReservePlayerLoadingPosition(TppDefine.MISSION_LOAD_TYPE.MISSION_ABORT,isHelicopterSpace,isFreeMission,nextIsHelicopterSpace,nextIsFreeMission,mvars.mis_abortWithSave)
	TppWeather.OnEndMissionPrepareFunction()
	this.VarResetOnNewMission()
	gvars.mis_orderBoxName=0
	if gvars.ini_isTitleMode then
		mvars.mis_missionAbortLoadingOption.showLoadingTips=false
		gvars.ini_isReturnToTitle=true
	else
		TppTerminal.ReserveMissionStartMbSync()
		local abortWithSave=false
		if mvars.mis_abortWithSave then
			abortWithSave=true
		end
		TppSave.VarSave(missionCode,abortWithSave)
		TppSave.SaveGameData(missionCode,nil,nil,true,abortWithSave)
		if mvars.mis_needSaveConfigOnNewMission then
			TppSave.VarSaveConfig()
			TppSave.SaveConfigData(nil,nil,reserveNextMissionStart)
		end
	end
end
function this.LoadForMissionAbort()
	TppUiStatusManager.SetStatus("AnnounceLog","INVALID_LOG")
	if gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_ESCAPE_THE_HOSPITAL then
		this.RequestLoad(vars.missionCode,mvars.mis_abortCurrentMissionCode,mvars.mis_missionAbortLoadingOption)
	else
		this.Load(vars.missionCode,mvars.mis_abortCurrentMissionCode,mvars.mis_missionAbortLoadingOption)
	end
end
function this.ReturnToTitle()
	if TppException.isNowGoingToMgo then
		return
	end
	if this.IsHelicopterSpace(vars.missionCode)then
		TppMotherBaseManagement.ProcessBeforeSync()
		TppMotherBaseManagement.StartSyncControl{}
		TppSave.SaveMBAndGlobal()
		this.CreateMbSaveCoroutine()
	end
	if gvars.str_storySequence<TppDefine.STORY_SEQUENCE.CLEARD_ESCAPE_THE_HOSPITAL then
		this.AbortMission{nextMissionId=10010,isNoSave=true,isTitleMode=true}
	else
		local n,i=this.GetCurrentLocationHeliMissionAndLocationCode()
		this.AbortMission{nextMissionId=n,isNoSave=true,isTitleMode=true}
	end
end
function this.GameOverReturnToTitle()
	gvars.title_nextMissionCode=vars.missionCode
	gvars.title_nextLocationCode=vars.locationCode
	gvars.ini_isTitleMode=true
	mvars.mis_abortWithSave=false
	if gvars.str_storySequence<TppDefine.STORY_SEQUENCE.CLEARD_ESCAPE_THE_HOSPITAL then
		mvars.mis_nextMissionCodeForAbort=10010
	else
		mvars.mis_nextMissionCodeForAbort=this.GetCurrentLocationHeliMissionAndLocationCode()
	end
	this.ExecuteMissionAbort()
end
function this.ReserveGameOver(gameOverType,radioChatter,isAbortingOnPurpose)
	if svars.mis_isDefiniteMissionClear then
		return false
	end
	if this.IsFOBMission(vars.missionCode)==true and TppServerManager.FobIsSneak()==true then
		TppMain.DisablePlayerPad()
		TppUiStatusManager.SetStatus("PauseMenu","INVALID")
	end
	mvars.mis_isAborting=isAbortingOnPurpose
	mvars.mis_isReserveGameOver=true
	svars.mis_isDefiniteGameOver=true
	if type(gameOverType)=="number"and gameOverType<TppDefine.GAME_OVER_TYPE.MAX then
		svars.mis_gameOverType=gameOverType
	end
	if type(radioChatter)=="number"and radioChatter<TppDefine.GAME_OVER_RADIO.MAX then
		svars.mis_gameOverRadio=radioChatter
	end
	return true
end
function this.ReserveGameOverOnPlayerKillChild(n)
	if not mvars.mis_childGameObjectIdKilledPlayer then
		mvars.mis_childGameObjectIdKilledPlayer=n
		this.ReserveGameOver(TppDefine.GAME_OVER_TYPE.PLAYER_KILL_CHILD_SOLDIER,TppDefine.GAME_OVER_RADIO.PLAYER_KILL_CHILD_SOLDIER)
	end
end
function this.IsGameOver()
	return svars.mis_isDefiniteGameOver
end
function this.CanMissionClear(e)
	mvars.mis_needSetCanMissionClear=true
	if IsTypeTable(e)then
		if e.jingle then
			mvars.mis_canMissionClearNeedJingle=e.jingle
		else
			mvars.mis_canMissionClearNeedJingle=true
		end
	end
end
function this._SetCanMissionClear()
	mvars.mis_needSetCanMissionClear=false
	if svars.mis_canMissionClear then
		return
	end
	svars.mis_canMissionClear=true
	TppHelicopter.SetNoTakeOffTime()
end
function this.IsCanMissionClear()
	return svars.mis_canMissionClear
end
function this.OnCanMissionClear()
	if mvars.mis_canMissionClearNeedJingle~=false then
		TppSound.PostJingleOnCanMissionClear()
	end
	if IsHelicopter(vars.playerVehicleGameObjectId)then
		local e=GameObject.SendCommand({type="TppHeli2",index=0},{id="GetUsingRoute"})
		if TppLandingZone.IsAssaultDropLandingZone(e)then
			GameObject.SendCommand({type="TppHeli2",index=0},{id="PullOut"})
		end
	end
	TppUiCommand.ShowHotZone()
	local e=mvars.snd_bgmList
	if e and e.bgm_escape then
		mvars.mis_needSetEscapeBgm=true
	end
end
function this.SetMissionClearState(state)
	--TUPPMLog.Log("TppMission.SetMissionClearState START returning func state:"..tostring(state),1)
	if gvars.mis_missionClearState<state then
		gvars.mis_missionClearState=state
		return true
	else
		return false
	end
end
function this.ResetMissionClearState()
	gvars.mis_missionClearState=TppDefine.MISSION_CLEAR_STATE.NOT_CLEARED_YET
end
function this.GetMissionClearState()
	return gvars.mis_missionClearState
end
function this.ReserveMissionClear(options)
	--TUPPMLog.Log("TppMission.ReserveMissionClear START",1)
	if svars.mis_isDefiniteGameOver then
		return false
	end
	if mvars.mis_isReserveMissionClear or svars.mis_isDefiniteMissionClear then
		return false
	end
	if this.IsFOBMission(vars.missionCode)==true and TppServerManager.FobIsSneak()==true then
		TppMain.DisablePlayerPad()
		TppUiStatusManager.SetStatus("PauseMenu","INVALID")
	end
	mvars.mis_isReserveMissionClear=true
	if options then
		if options.missionClearType then
			svars.mis_missionClearType=options.missionClearType
		end
		if options.nextMissionId then
			this.SetNextMissionCodeForMissionClear(options.nextMissionId)
		end
		if options.nextHeliRoute then
			mvars.heli_missionStartRoute=options.nextHeliRoute
		end
		if options.nextLayoutCode then
			mvars.mis_nextLayoutCode=options.nextLayoutCode
			--TUPPMLog.Log("TppMission.ReserveMissionClear options.nextLayoutCode BEFORE vars.mbLayoutCode: "..tostring(vars.mbLayoutCode),3,true)
			vars.mbLayoutCode=TppLocation.ModifyMbsLayoutCode(mvars.mis_nextLayoutCode)
			--TUPPMLog.Log("TppMission.ReserveMissionClear options.nextLayoutCode AFTER vars.mbLayoutCode: "..tostring(vars.mbLayoutCode),3,true)

		end
		if options.nextClusterId then
			mvars.mis_nextClusterId=options.nextClusterId
			vars.mbClusterId=options.nextClusterId
		end
		if options.isInterruptMissionEnd then
			mvars.mis_isInterruptMissionEnd=true
		end
	end
	svars.mis_isDefiniteMissionClear=true
	return true
end
function this.MissionGameEnd(options)
	--TUPPMLog.Log("TppMission.MissionGameEnd START",1)
	local delayTime=0
	local fadeDelayTime=0
	local fadeSpeed=TppUI.FADE_SPEED.FADE_NORMALSPEED
	if Tpp.IsTypeTable(options)then
		delayTime=options.delayTime or 0
		fadeSpeed=options.fadeSpeed or TppUI.FADE_SPEED.FADE_NORMALSPEED
		fadeDelayTime=options.fadeDelayTime or 0
		if options.loadStartOnResult~=nil then
			mvars.mis_doMissionFinalizeOnMissionTelopDisplay=options.loadStartOnResult
		else
			mvars.mis_doMissionFinalizeOnMissionTelopDisplay=false
		end
	end
	if mvars.mis_doMissionFinalizeOnMissionTelopDisplay then
		this.SetNeedWaitMissionInitialize()
	else
		this.ResetNeedWaitMissionInitialize()
	end
	mvars.mis_missionGameEndDelayTime=delayTime
	this.FadeOutOnMissionGameEnd(fadeDelayTime,fadeSpeed,"MissionGameEndFadeOutFinish")
	PlayRecord.RegistPlayRecord"MISSION_CLEAR"
	TUPPMLog.Log("TppMission.MissionGameEnd END",1)
end
function this.FadeOutOnMissionGameEnd(n,i,s)
	--TUPPMLog.Log("TppMission.FadeOutOnMissionGameEnd START",1)
	if n==0 then
		this._FadeOutOnMissionGameEnd(i,s)
	else
		mvars.mis_missionGameEndFadeSpeed=i
		mvars.mis_missionGameEndFadeId=s
		GkEventTimerManagerStart("Timer_FadeOutOnMissionGameEndStart",n)
	end
	--TUPPMLog.Log("TppMission.FadeOutOnMissionGameEnd END",1)
end
function this._FadeOutOnMissionGameEnd(mis_missionGameEndFadeSpeed,mis_missionGameEndFadeId)
	--TUPPMLog.Log("TppMission._FadeOutOnMissionGameEnd START",1)
	TppUI.FadeOut(mis_missionGameEndFadeSpeed,mis_missionGameEndFadeId,nil,{exceptGameStatus={AnnounceLog="SUSPEND_LOG"}})
	--TUPPMLog.Log("TppMission._FadeOutOnMissionGameEnd END",1)
end
function this.CheckGameOverDemo(e)
	if e>TppDefine.GAME_OVER_TYPE.GAME_OVER_DEMO_MASK then
		return false
	end
	if bitBand(svars.mis_gameOverType,TppDefine.GAME_OVER_TYPE.GAME_OVER_DEMO_MASK)==e then
		return true
	else
		return false
	end
end
function this.ShowGameOverMenu(i)
	local n
	if IsTypeTable(i)then
		if type(i.delayTime)=="number"then
			n=i.delayTime
		end
	end
	if n and n>0 then
		GkEventTimerManagerStart("Timer_GameOverPresentation",n)
	else
		this.ExecuteShowGameOverMenu()
	end
end
function this.ShowStealthAssistPopup()
	if((vars.missionCode==10010)or(vars.missionCode==10240))or(vars.missionCode==10280)then
		return GameOverMenu.NO_POPUP
	end
	if this.IsHardMission(vars.missionCode)then
		return GameOverMenu.NO_POPUP
	end
	if mvars.mis_isGameOverReasonSuicide then
		return GameOverMenu.NO_POPUP
	end
	if svars.chickCapEnabled then
		return GameOverMenu.NO_POPUP
	end
	if GameConfig.GetStealthAssistEnabled()then
		if svars.dialogPlayerDeadCount>deathLimitToPerfectStealthPopup then
			if gvars.elapsedTimeSinceLastUseChickCap>=timeBeforeLilChickCapCanBeUsedAgain then
				return GameOverMenu.PERFECT_STEALTH_POPUP
			else
				return GameOverMenu.NO_POPUP
			end
		else
			return GameOverMenu.NO_POPUP
		end
	else
		if svars.dialogPlayerDeadCount>deathLimitToStealthAssistPopup then
			return GameOverMenu.STEALTH_ASSIST_POPUP
		else
			return GameOverMenu.NO_POPUP
		end
	end
end
function this.ExecuteShowGameOverMenu()
	TppRadio.Stop()
	local e=this.ShowStealthAssistPopup()
	TppUiCommand.StartGameOver(e)
end
function this.ShowMissionGameEndAnnounceLog()
	this.SetMissionClearState(TppDefine.MISSION_CLEAR_STATE.MISSION_GAME_END)
	if mvars.res_noResult then
		this.ShowAnnounceLogOnFadeOut(this.OnEndResultBlockLoad)
	else
		this.ShowAnnounceLogOnFadeOut(TppUiCommand.StartResultBlockLoad)
	end
end
function this.ShowAnnounceLogOnFadeOut(e)
	if TppUiCommand.GetSuspendAnnounceLogNum()>0 then
		TppUiStatusManager.ClearStatus"AnnounceLog"mvars.mis_endAnnounceLogFunction=e
	else
		e()
	end
end
function this.OnEndResultBlockLoad()
	TppUiStatusManager.SetStatus("GmpInfo","INVALID")
	if this.systemCallbacks.OnDisappearGameEndAnnounceLog then
		this.systemCallbacks.OnDisappearGameEndAnnounceLog(svars.mis_missionClearType)
	end
end
function this.EnablePauseForShowResult()
	if not gvars.enableResultPause then
		TppPause.RegisterPause"ShowResult"gvars.enableResultPause=true
	end
end
function this.DisablePauseForShowResult()
	--TUPPMLog.Log("TppMission.DisablePauseForShowResult START",1)
	if gvars.enableResultPause then
		TppPause.UnregisterPause"ShowResult"
		gvars.enableResultPause=false
	end
	--TUPPMLog.Log("TppMission.DisablePauseForShowResult END",1)
end
function this.ShowMissionResult()
	TppUiStatusManager.SetStatus("AnnounceLog","INVALID_LOG")
	TppRadio.Stop()
	TppSoundDaemon.SetMute"Loading"
	TppSoundDaemon.SetMute"Result"
	TppSound.EndJingleOnClearHeli()
	this.EnablePauseForShowResult()
	TppMotherBaseManagement.AddBonusPopupFromBonusPopupFlagStaffs()
	TppRadioCommand.SetEnableIgnoreGamePause(true)
	TppSound.PostJingleStartResultPresentation(svars.bestRank)
	--rX6
	TppUiCommand.CallMissionEndTelop() -- This seems to be responsible for the results screen as well as well as the teleop
	TppSound.SafeStopAndPostJingleOnShowResult()
	TppRadio.PlayResultRadio()
end
function this.ShowMissionReward()
	--TUPPMLog.Log("TppMission.ShowMissionReward START",1)
	if TppReward.IsStacked()and(vars.missionCode~=50050)then
		--TUPPMLog.Log("TppMission.ShowMissionReward Call to TppReward.ShowAllReward()",1)
		TppReward.ShowAllReward()
	else
		this.OnEndMissionReward()
	end
	--TUPPMLog.Log("TppMission.ShowMissionReward END",1)
end
function this.OnEndMissionReward()
	--TUPPMLog.Log("TppMission.OnEndMissionReward START",1)
	if gvars.needWaitMissionInitialize then
		this.ResetMissionClearState()
	else
		this.SetMissionClearState(TppDefine.MISSION_CLEAR_STATE.REWARD_END)
	end
	if IsTypeFunc(this.systemCallbacks.OnEndMissionReward)then
		this.systemCallbacks.OnEndMissionReward()
	else
		if gvars.needWaitMissionInitialize==false then
			this.ExecuteMissionFinalize()
		end
	end
	this.ResetNeedWaitMissionInitialize()
	--TUPPMLog.Log("TppMission.OnEndMissionReward END",1)
end
function this.MissionFinalize(options)
	--TUPPMLog.Log("TppMission.MissionFinalize START",1)
	local isNoFade,isExecGameOver,showLoadingTips,setMute,isInterruptMissionEnd,ignoreMtbsLoadLocationForce
	if IsTypeTable(options)then
		isNoFade=options.isNoFade
		isExecGameOver=options.isExecGameOver
		showLoadingTips=options.showLoadingTips
		setMute=options.setMute
		isInterruptMissionEnd=options.isInterruptMissionEnd
		ignoreMtbsLoadLocationForce=options.ignoreMtbsLoadLocationForce
	end
	if showLoadingTips~=nil then
		mvars.mis_showLoadingTipsOnMissionFinalize=showLoadingTips
	else
		mvars.mis_showLoadingTipsOnMissionFinalize=true
	end
	if setMute then
		mvars.mis_setMuteOnMissionFinalize=setMute
	end
	if isInterruptMissionEnd then
		mvars.mis_isInterruptMissionEnd=true
	end
	if ignoreMtbsLoadLocationForce then
		mvars.mis_missionFinalizeIgnoreMtbsLoadLocationForce=true
	end
	if isNoFade then
		this.ExecuteMissionFinalize()
	else
		if isExecGameOver then
			TppUI.FadeOut(TppUI.FADE_SPEED.FADE_NORMALSPEED,"MissionFinalizeAtGameOverFadeOutFinish",nil,{setMute=true})
		else
			TppUI.FadeOut(TppUI.FADE_SPEED.FADE_NORMALSPEED,"MissionFinalizeFadeOutFinish",nil,{setMute=true})
		end
	end
	--TUPPMLog.Log("TppMission.MissionFinalize END",1)
end
function this.ExecuteMissionFinalize()
	--TUPPMLog.Log("TppMission.ExecuteMissionFinalize START",1)
	local nextLocationName=TppPackList.GetLocationNameFormMissionCode(gvars.mis_nextMissionCodeForMissionClear)
	if nextLocationName then
		mvars.mis_nextLocationCode=TppDefine.LOCATION_ID[nextLocationName]
	end
	this.SafeStopSettingOnMissionReload{setMute=mvars.mis_setMuteOnMissionFinalize}
	this.SetMissionClearState(TppDefine.MISSION_CLEAR_STATE.MISSION_FINALIZED)
	this.UnsetFobSneakFlag(gvars.mis_nextMissionCodeForMissionClear)
	if mvars.mis_doMissionFinalizeOnMissionTelopDisplay then
		if TppUiCommand.IsEndMissionTelop()then
		end
		this.ShowMissionReward()
		this.systemCallbacks.OnFinishBlackTelephoneRadio=nil
		this.systemCallbacks.OnEndMissionCredit=nil
	end
	local waitOnLoadingTipsEnd
	local missionCode=vars.missionCode
	local locationCode=vars.locationCode
	local isHelicopterSpace,nextIsHelicopterSpace
	local isFreeMission,nextIsFreeMission
	if not(mvars.mis_isInterruptMissionEnd or(not TppSave.CanSaveMbMangementData()))then
		TppMotherBaseManagement.CheckMisogi()
	end
	if this.IsFOBMission(gvars.mis_nextMissionCodeForMissionClear)then
		waitOnLoadingTipsEnd=false
		TppSave.VarSave(missionCode,true)
		TppSave.SaveGameData(missionCode,nil,nil,nil,true)
	end
	if gvars.mis_nextMissionCodeForMissionClear~=missionClearCodeNone then
		isHelicopterSpace=this.IsHelicopterSpace(vars.missionCode)
		isFreeMission=this.IsFreeMission(vars.missionCode)
		nextIsHelicopterSpace=this.IsHelicopterSpace(gvars.mis_nextMissionCodeForMissionClear)
		nextIsFreeMission=this.IsFreeMission(gvars.mis_nextMissionCodeForMissionClear)
		if mvars.heli_missionStartRoute then
			if Tpp.IsTypeString(mvars.heli_missionStartRoute)then
				gvars.heli_missionStartRoute=StrCode32(mvars.heli_missionStartRoute)
			elseif Tpp.IsTypeNumber(mvars.heli_missionStartRoute)then
				gvars.heli_missionStartRoute=mvars.heli_missionStartRoute
			else
				return
			end
		end
		if mvars.mis_nextLayoutCode then
			--TUPPMLog.Log("TppMission.ExecuteMissionFinalize mvars.mis_nextLayoutCode BEFORE vars.mbLayoutCode: "..tostring(vars.mbLayoutCode),3,true)
			vars.mbLayoutCode=TppLocation.ModifyMbsLayoutCode(mvars.mis_nextLayoutCode)
			--TUPPMLog.Log("TppMission.ExecuteMissionFinalize mvars.mis_nextLayoutCode AFTER vars.mbLayoutCode: "..tostring(vars.mbLayoutCode),3,true)
		else
			local nextMissionMBLayoutCode=TppDefine.STORY_MISSION_LAYOUT_CODE[gvars.mis_nextMissionCodeForMissionClear]
			if nextMissionMBLayoutCode then
				--TUPPMLog.Log("TppMission.ExecuteMissionFinalize nextMissionMBLayoutCode BEFORE vars.mbLayoutCode: "..tostring(vars.mbLayoutCode),3,true)
				vars.mbLayoutCode=TppLocation.ModifyMbsLayoutCode(nextMissionMBLayoutCode)
				--TUPPMLog.Log("TppMission.ExecuteMissionFinalize nextMissionMBLayoutCode AFTER vars.mbLayoutCode: "..tostring(vars.mbLayoutCode),3,true)
			end
		end
		if mvars.mis_nextClusterId then
			vars.mbClusterId=mvars.mis_nextClusterId
		end
		vars.locationCode=mvars.mis_nextLocationCode
		vars.missionCode=gvars.mis_nextMissionCodeForMissionClear
	else
		if not mvars.mis_isInterruptMissionEnd then
			Tpp.DEBUG_Fatal"Not defined next missionId!!"this.RestartMission()
			return
		end
	end
	TppTerminal.ClearStaffNewIcon(isHelicopterSpace,isFreeMission,nextIsHelicopterSpace,nextIsFreeMission)
	if isHelicopterSpace then
		TppClock.SetTimeFromHelicopterSpace(mvars.mis_selectedDeployTime,locationCode,vars.locationCode)
		if TppSave.CanSaveMbMangementData()then
			TppTerminal.ReserveMissionStartMbSync()
		end
	end
	TppPlayer.SavePlayerCurrentWeapons()
	local areRestored=TppPlayer.RestoreWeaponsFromUsingTemp()
	TppPlayer.SavePlayerCurrentItems()
	TppPlayer.RestoreItemsFromUsingTemp()
	if not areRestored then
		TppPlayer.SavePlayerCurrentAmmoCount()
	end
	if missionCode==10030 and TppSave.CanSaveMbMangementData(missionCode)then
		vars.items[2]=TppEquip.EQP_IT_TimeCigarette
		vars.items[3]=TppEquip.EQP_IT_Nvg
		vars.initItems[2]=TppEquip.EQP_IT_TimeCigarette
		vars.initItems[3]=TppEquip.EQP_IT_Nvg
		TppUiCommand.LoadoutSetItemEquipInfoInMission{slotIndex=2,equipId=TppEquip.EQP_IT_TimeCigarette,level=1}
		TppUiCommand.LoadoutSetItemEquipInfoInMission{slotIndex=3,equipId=TppEquip.EQP_IT_Nvg,level=1}
	end
	if(not isHelicopterSpace)then
		if this.IsMbFreeMissions(gvars.mis_nextMissionCodeForMissionClear)then
			--r51 Settings
			if not TUPPMSettings.player_ENABLE_keepWeaponsBetweenFreeMissionTransitions then
				--r46 Carry weapons between (Free Roam-Missions-ACC) --Mission abort via menu resets weapons to those at the time of starting the mission from free roam
				--r46 Keep weapons between free roam->mission and mission->free roam allowing for better OSP runs
				TppUiCommand.LoadoutSetMissionRecieveFromFreeToMission()
			end
		elseif nextIsFreeMission then
			--r51 Settings
			if not TUPPMSettings.player_ENABLE_keepWeaponsBetweenFreeMissionTransitions then
				--r46 Carry weapons between (Free Roam-Missions-ACC) --Mission abort via menu resets weapons to those at the time of starting the mission from free roam
				--r46 Keep weapons between free roam->mission and mission->free roam allowing for better OSP runs
				TppUiCommand.LoadoutSetMissionEndFromMissionToFree()
			end
		end
	end
	if not(isHelicopterSpace and nextIsFreeMission)then
		TppUiCommand.RemovedAllUserMarker()
	end
	if nextIsHelicopterSpace then
		--rX46 Carry weapons between (Free Roam-Missions-ACC) --Mission abort via menu resets weapons to those at the time of starting the mission from free roam
		--Enemy weapons do show up in the ACC! Soviet shield lying behind you for example. However! Deploying with those weapons again won't work. The variables use settings from the sortie prep menus and not what Snake actually has equipped at the time
		TppUiCommand.LoadoutSetReturnHelicopter()
	end
	if not isHelicopterSpace and not isFreeMission then
		TppGimmick.DecrementCollectionRepopCount()
		--r51 Settings
		if TUPPMSettings.res_ENABLE_instantRepopOfCollectibles then
			TppGimmick.DecrementCollectionRepopCount()--r27 Instant repopulation of small collectibles
			TppGimmick.DecrementCollectionRepopCount()
			TppGimmick.DecrementCollectionRepopCount()
			TppGimmick.DecrementCollectionRepopCount()
		end
		Gimmick.StoreSaveDataPermanentGimmickForMissionClear()
		Gimmick.StoreSaveDataPermanentGimmickFromMissionAfterClear()
	end
	if isFreeMission then
		--r51 Settings
		if TUPPMSettings.res_ENABLE_instantRepopOfCollectibles then
			TppGimmick.DecrementCollectionRepopCount()
			TppGimmick.DecrementCollectionRepopCount()
			TppGimmick.DecrementCollectionRepopCount()
			TppGimmick.DecrementCollectionRepopCount()
			TppGimmick.DecrementCollectionRepopCount()
		end
		Gimmick.StoreSaveDataPermanentGimmickFromMission()
	end
	local lockStaffForMission={
		[10091]=function()
			if TppMotherBaseManagement.CanOpenS10091()then
				TppMotherBaseManagement.LockedStaffsS10091()
			end
		end,
		[10081]=function()
			if TppMotherBaseManagement.CanOpenS10081()then
				TppMotherBaseManagement.LockedStaffS10081()
			end
		end,
		[10115]=function()
			if TppMotherBaseManagement.CanOpenS10115{section="Develop"}then
				TppMotherBaseManagement.LockedStaffsS10115{section="Develop"}
			end
		end
	}
	local lockStaffFunc=lockStaffForMission[gvars.mis_nextMissionCodeForMissionClear]
	if lockStaffFunc then
		if TppStory.IsMissionCleard(vars.missionCode)then
			lockStaffFunc()
		end
	end
	if nextIsFreeMission then
		vars.requestFlagsAboutEquip=255
	end
	TppEnemy.ClearDDParameter()
	TppRevenge.OnMissionClearOrAbort(missionCode)
	if gvars.solface_groupNumber>=4294967295 then
		gvars.solface_groupNumber=0
	else
		gvars.solface_groupNumber=gvars.solface_groupNumber+1
	end
	gvars.hosface_groupNumber=(math.random(0,65535)*65536)+math.random(1,65535)
	TppPlayer.StoreSupplyCbox()
	TppPlayer.StoreSupportAttack()
	TppRadioCommand.StoreRadioState()
	local isMission22=false
	if vars.missionCode==10115 then
		isMission22=true
	end
	local locationChangeRequired=(vars.locationCode~=locationCode)
	if not isHelicopterSpace then
		TppTerminal.AddStaffsFromTempBuffer(nil,isMission22)
	end
	TppClock.SaveMissionStartClock()
	TppWeather.SaveMissionStartWeather()
	TppBuddyService.SetVarsMissionStart()
	TppBuddyService.BuddyMissionInit()
	TppRevenge.SaveMissionStartMineArea()
	TppMain.ReservePlayerLoadingPosition(TppDefine.MISSION_LOAD_TYPE.MISSION_FINALIZE,isHelicopterSpace,isFreeMission,nextIsHelicopterSpace,nextIsFreeMission,nil,locationChangeRequired)
	TppWeather.OnEndMissionPrepareFunction()
	this.VarResetOnNewMission()
	if not this.IsFOBMission(vars.missionCode)then
		local i=true
		TppSave.VarSave(missionCode,true)
		local e=false
		do
			e=true
		end
		if e and(not isMission22)then
			TppSave.SaveGameData(missionCode,nil,nil,i,true)
		end
		if mvars.mis_needSaveConfigOnNewMission then
			TppSave.VarSaveConfig()
			TppSave.SaveConfigData(nil,nil,i)
		end
	end
	if mvars.mis_isInterruptMissionEnd then
		local missionHeroicPoint,missionOgrePoint=vars.missionHeroicPoint,vars.missionOgrePoint
		this.ResetEmegerncyMissionSetting()
		TppSave.VarSaveMBAndGlobal()
		TppSave.VarRestoreOnContinueFromCheckPoint()
		TppPlayer.ResetInitialPosition()
		TppMain.ReservePlayerLoadingPosition(TppDefine.MISSION_LOAD_TYPE.MISSION_RESTART)
		if(vars.missionCode==30050)then
			this.ResetMBFreeStartPositionToCommand()
		end
		this.VarResetOnNewMission()
		if(vars.missionCode==10240)then
			local locationName=TppPackList.GetLocationNameFormMissionCode(vars.missionCode)
			if locationName then
				local locationCode=TppDefine.LOCATION_ID[locationName]
				if locationCode then
					vars.locationCode=locationCode
				end
			end
		end
		TppSave.VarSave()
		this.SetHeroicAndOgrePointInSlot(missionHeroicPoint,missionOgrePoint)
		TppSave.SaveGameData(vars.missionCode)
	end
	if TppRadio.playingBlackTelInfo then
		mvars.mis_showLoadingTipsOnMissionFinalize=false
	end
	this.RequestLoad(vars.missionCode,missionCode,{showLoadingTips=mvars.mis_showLoadingTipsOnMissionFinalize,waitOnLoadingTipsEnd=waitOnLoadingTipsEnd,ignoreMtbsLoadLocationForce=mvars.mis_missionFinalizeIgnoreMtbsLoadLocationForce})
	--TUPPMLog.Log("TppMission.ExecuteMissionFinalize END",1)
end
function this.ParseMissionName(missionNameString)
	local missionCode=string.sub(missionNameString,2)
	missionCode=tonumber(missionCode)
	local missionTypeString=string.sub(missionNameString,1,1)
	local missionType
	if(missionTypeString=="s")then
		missionType="story"
	elseif(missionTypeString=="e")then
		missionType="extra"
	elseif(missionTypeString=="f")then
		missionType="free"
	elseif(missionTypeString=="h")then
		missionType="heli"
	end
	return missionCode,missionType
end
function this.IsStoryMission(e)
	local e=math.floor(e/1e4)
	if e==1 then
		return true
	else
		return false
	end
end
function this.IsHelicopterSpace(e)
	local e=math.floor(e/1e4)
	if e==4 then
		return true
	else
		return false
	end
end
function this.IsFreeMission(e)
	local e=math.floor(e/1e4)
	if e==3 then
		return true
	else
		return false
	end
end
function this.IsMbFreeMissions(e)
	local n={[30050]=true,[30150]=true,[30250]=true}
	if n[e]then
		return true
	else
		return false
	end
end
function this.IsFOBMission(e)
	local e=math.floor(e/1e4)
	if e==5 then
		return true
	else
		return false
	end
end
function this.IsHardMission(e)
	local n=math.floor(e/1e3)
	local e=math.floor(e/1e4)*10
	if(n-e)==1 then
		return true
	else
		return false
	end
end
function this.GetNormalMissionCodeFromHardMission(e)
	return e-1e3
end
function this.IsSubsistenceMission()
	if(vars.missionCode==11043)or(vars.missionCode==11044)then
		return true
	else
		return false
	end
end
function this.IsPerfectStealthMission()
	if(((vars.missionCode==11082)or(vars.missionCode==11033))or(vars.missionCode==11080))or(vars.missionCode==11121)then
		return true
	else
		return false
	end
end
function this.SetFOBMissionFlag()Mission.SetMissionFlags(bit.bor(Mission.MISSION_FLAGS_FOB,Mission.MISSION_FLAGS_MB))
end
function this.IsMissionStart()
	if gvars.sav_varRestoreForContinue then
		return false
	else
		return true
	end
end
function this.IsSysMissionId(n)
	local e
	for i,e in pairs(TppDefine.SYS_MISSION_ID)do
		if n==e then
			return true
		end
	end
	return false
end
function this.IsEmergencyMission(e)
	if e then
		if e==50050 then
			if TppServerManager.FobIsSneak()then
				return false
			else
				return true
			end
		end
		if e==10115 then
			if TppStory.IsAlwaysOpenRetakeThePlatform()then
				return false
			else
				return true
			end
		end
	else
		return not gvars.usingNormalMissionSlot
	end
end
function this.Messages()
	return Tpp.StrCode32Table{
		Player={
			{msg="Dead",
				func=this.OnPlayerDead,
				option={isExecGameOver=true}},
			{msg="Exit",
				sender="outerZone",
				func=function()
					mvars.mis_isOutsideOfMissionArea=true
				end,
				option={isExecMissionPrepare=true,isExecDemoPlaying=true}},
			{msg="Enter",
				sender="outerZone",
				func=function()
					mvars.mis_isOutsideOfMissionArea=false
				end,
				option={isExecMissionPrepare=true,isExecDemoPlaying=true}},
			{msg="Exit",
				sender="innerZone",
				func=function()
					if mvars.mis_fobDisableAlertMissionArea==true then
						return
					end
					mvars.mis_isAlertOutOfMissionArea=true
					if not this.CheckMissionClearOnOutOfMissionArea()then
						this.EnableAlertOutOfMissionArea()
					end
				end,
				option={isExecMissionPrepare=true,isExecDemoPlaying=true}},
			{msg="Enter",
				sender="innerZone",
				func=function()
					mvars.mis_isAlertOutOfMissionArea=false
					this.DisableAlertOutOfMissionArea()
				end,
				option={isExecMissionPrepare=true,isExecDemoPlaying=true}},
			{msg="Exit",
				sender="hotZone",
				func=function()
					mvars.mis_isOutsideOfHotZone=true
					this.ExitHotZone()
				end,
				option={isExecMissionPrepare=true,isExecDemoPlaying=true}},
			{msg="Enter",
				sender="hotZone",
				func=function()
					mvars.mis_isOutsideOfHotZone=false
					if TppSequence.IsMissionPrepareFinished()then
						this.PlayCommonRadioOnInsideOfHotZone()
					end
				end,
				option={isExecMissionPrepare=true,isExecDemoPlaying=true}},
			{msg="RideHelicopter",
				func=function()
					GkEventTimerManagerStart("Timer_PlayCommonRadioOnRideHelicopter",1)
				end},
			{msg="OnInjury",
				func=function()
					TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.RECOMMEND_CURE)
				end},
			{msg="PlayerFultoned",
				func=this.OnPlayerFultoned},
			{msg="FinishOpeningDemoOnHeli",
				func=function()
					TppSound.StopHelicopterStartSceneBGM()
					TppUiStatusManager.ClearStatus"EquipPanel"
					TppUiStatusManager.ClearStatus"HeadMarker"
					TppUiStatusManager.ClearStatus"WorldMarker"
					if this.IsFreeMission(vars.missionCode)or(this.IsFOBMission(vars.missionCode)and(vars.fobSneakMode==FobMode.MODE_VISIT))then
						TppUiStatusManager.ClearStatus"AnnounceLog"
					end
					if mvars.mis_updateObjectiveOnHelicopterStart then
						this.ShowUpdateObjective(mvars.mis_objectiveSetting)
						if mvars.mis_updateObjectiveDoorOpenRadioGroups then
							TppRadio.Play(mvars.mis_updateObjectiveDoorOpenRadioGroups,mvars.mis_updateObjectiveDoorOpenRadioOptions)
						end
					end
				end}
		},
		UI={
			{msg="EndTelopCast",
				func=function()
					if mvars.f30050_demoName=="NuclearEliminationCeremony"then
						return
					end
					TppUiStatusManager.ClearStatus"AnnounceLog"
				end},
			{msg="EndFadeOut",
				sender="MissionGameEndFadeOutFinish",
				func=this.OnMissionGameEndFadeOutFinish,
				option={isExecMissionClear=true,isExecDemoPlaying=true}},
			{msg="EndFadeOut",
				sender="MissionFinalizeFadeOutFinish",
				func=this.ExecuteMissionFinalize,
				option={isExecMissionClear=true,isExecDemoPlaying=true,isExecGameOver=true}},
			{msg="EndFadeOut",
				sender="MissionFinalizeAtGameOverFadeOutFinish",
				func=this.ExecuteMissionFinalize,
				option={isExecGameOver=true,isExecMissionClear=true}},
			{msg="EndFadeOut",
				sender="RestartMissionFadeOutFinish",
				func=function()
					this.ExecuteRestartMission(mvars.mis_isReturnToMission)
				end,
				option={isExecMissionClear=true,isExecMissionPrepare=true}},
			{msg="EndFadeOut",
				sender="ContinueFromCheckPointFadeOutFinish",
				func=function()
					this.ExecuteContinueFromCheckPoint(nil,nil,mvars.mis_isReturnToMission)
				end,
				option={isExecMissionClear=true,isExecGameOver=true,isExecMissionPrepare=true}},
			{msg="EndFadeOut",
				sender="ReloadFadeOutFinish",
				func=function()
					if mvars.mis_reloadOnEndFadeOut then
						mvars.mis_reloadOnEndFadeOut()
					end
					this.ExecuteReload()
				end,
				option={isExecMissionClear=true,isExecMissionPrepare=true}},
			{msg="EndFadeOut",
				sender="AbortMissionFadeOutFinish",
				func=function()
					if mvars.mis_missionAbortDelayTime>0 then
						GkEventTimerManagerStart("Timer_MissionAbort",mvars.mis_missionAbortDelayTime)
					else
						this.OnEndFadeOutMissionAbort()
					end
				end,
				option={isExecGameOver=true}},
			{msg="EndFadeIn",
				sender="FadeInOnGameStart",
				func=function()
					if TppSequence.IsHelicopterStart()then
						this.StartHelicopterDoorOpenTimer()
					end
					if TppSequence.IsLandContinue()then
						local e=this.IsHelicopterSpace(vars.missionCode)
						if((vars.missionCode~=10010)and(vars.missionCode~=10280))and(not e)then
							TppTerminal.ShowLocationAndBaseTelopForContinue()
						end
					end
					TppTerminal.GetFobStatus()
					this.ShowAnnounceLogOnGameStart()
				end},
			{msg="EndFadeIn",
				sender="FadeInOnStartMissionGame",
				func=function()
					this.ShowAnnounceLogOnGameStart()
				end},
			{msg="EndFadeIn",
				sender="OnEndGameStartFadeIn",
				func=function()
					if(vars.missionCode==30050)then
						TppTerminal.GetFobStatus()
					end
				end},
			{msg="GameOverOpen",
				func=TppMain.DisableGameStatusOnGameOverMenu,
				option={isExecGameOver=true}},
			{msg="GameOverContinue",
				func=this.ExecuteContinueFromCheckPoint,
				option={isExecGameOver=true}},
			{msg="GameOverAbortMission",
				func=this.GameOverAbortMission,
				option={isExecGameOver=true,isExecMissionClear=true}},
			{msg="GameOverAbortMissionGoToAcc",
				func=this.GameOverAbortMission,
				option={isExecGameOver=true,isExecMissionClear=true}},
			{msg="GameOverReturnToMission",
				func=function()
					this.ReturnToMission{isNoFade=true}
				end,
				option={isExecGameOver=true,isExecMissionClear=true}},
			{msg="GameOverRestart",
				func=function()
					this.ExecuteRestartMission()
				end,
				option={isExecGameOver=true}},
			{msg="GameOverReturnToTitle",
				func=this.GameOverReturnToTitle,
				option={isExecGameOver=true}},
			{msg="GameOverRestartFromHelicopter",
				func=function()
					mvars.mis_abortByRestartFromHelicopter=true
					this.AbortForRideOnHelicopter{isNoSave=false,isAlreadyGameOver=true}
				end,
				option={isExecGameOver=true}},
			{msg="PauseMenuCheckpoint",
				func=this.ContinueFromCheckPoint},
			{msg="PauseMenuAbortMission",
				func=this.AbortMissionByMenu},
			{msg="PauseMenuAbortMissionGoToAcc",
				func=this.AbortMissionByMenu},
			{msg="PauseMenuFinishFobManualPlaecementMode",
				func=this.AbortMissionByMenu},
			{msg="PauseMenuRestart",
				func=this.RestartMission},
			{msg="PauseMenuReturnToTitle",
				func=this.ReturnToTitle},
			{msg="PauseMenuRestartFromHelicopter",
				func=function()
					mvars.mis_abortByRestartFromHelicopter=true
					this.AbortForRideOnHelicopter{isNoSave=false}
				end},
			{msg="PauseMenuReturnToMission",
				func=function()
					this.ReturnToMission{withServerPenalty=true}
				end},
			{msg="RequestPlayRecordClearInfo",
				func=this.SetPlayRecordClearInfo},
			{msg="EndMissionTelopDisplay",
				func=function()
					if mvars.mis_doMissionFinalizeOnMissionTelopDisplay then
						this.MissionFinalize{isNoFade=true,setMute="Result"}
					end
				end,
				option={isExecMissionClear=true,isExecGameOver=true}},
			{msg="EndAnnounceLog",
				func=function()
					if mvars.mis_endAnnounceLogFunction then
						mvars.mis_endAnnounceLogFunction()
						mvars.mis_endAnnounceLogFunction=nil
					end
				end,
				option={isExecMissionClear=true,isExecGameOver=true,isExecMissionPrepare=true}},
			{msg="EndResultBlockLoad",
				func=this.OnEndResultBlockLoad,
				option={isExecMissionClear=true,isExecGameOver=true,isExecDemoPlaying=true}},
			{msg="EndReloginSync",
				func=function() --> Patch 1090
					if this.IsHelicopterSpace(vars.missionCode)then
						TppVarInit.InitializeOnlineChallengeTaskVarsForNewMission()
				end
				end}
		}, --< Patch 1090
		Radio={
			{msg="Finish",
				func=this.OnFinishUpdateObjectiveRadio}
		},
		Timer={
			{msg="Finish",
				sender="Timer_OutsideOfHotZoneCount",
				func=this.OutsideOfHotZoneCount,nil},
			{msg="Finish",
				sender="Timer_OnEndReturnToTile",
				func=this.RestartMission,
				option={isExecGameOver=true},nil},
			{msg="Finish",
				sender="Timer_GameOverPresentation",
				func=this.ExecuteShowGameOverMenu,
				option={isExecGameOver=true},nil},
			{msg="Finish",
				sender="Timer_MissionGameEndStart",
				func=this.OnMissionGameEndFadeOutFinish2nd,
				option={isExecMissionClear=true,isExecDemoPlaying=true}
			},
			{msg="Finish",
				sender="Timer_MissionGameEndStart2nd",
				func=this.ShowMissionGameEndAnnounceLog,
				option={isExecMissionClear=true,isExecDemoPlaying=true}
			},
			{msg="Finish",
				sender="Timer_FadeOutOnMissionGameEndStart",
				func=function()
					this._FadeOutOnMissionGameEnd(mvars.mis_missionGameEndFadeSpeed,mvars.mis_missionGameEndFadeId)
				end,
				option={isExecMissionClear=true,isExecDemoPlaying=true}
			},
			{msg="Finish",
				sender="Timer_StartMissionAbortFadeOut",
				func=this.FadeOutOnMissionAbort,
				option={isExecGameOver=true}},
			{msg="Finish",
				sender="Timer_MissionAbort",
				func=this.OnEndFadeOutMissionAbort,
				option={isExecGameOver=true}},
			{msg="Finish",
				sender="Timer_PlayCommonRadioOnRideHelicopter",
				func=function()
					if Tpp.IsHelicopter(vars.playerVehicleGameObjectId)then
						this.PlayCommonRadioOnRideHelicopter()
					end
				end},
			{msg="Finish",
				sender="Timer_RemoveUserMarker",
				func=function()
					if Tpp.IsHelicopter(vars.playerVehicleGameObjectId)then
						TppUiCommand.RemovedAllUserMarker()
					end
				end},
			{msg="Finish",
				sender=Timer_outsideOfInnerZone,
				func=function()
					if(mvars.mis_isAlertOutOfMissionArea==false)then
						return
					end
					if this.CheckMissionClearOnOutOfMissionArea()then
						if mvars.mis_enableAlertOutOfMissionArea then
							this.DisableAlertOutOfMissionArea()
						end
					else
						if not mvars.mis_enableAlertOutOfMissionArea then
							this.EnableAlertOutOfMissionArea()
						end
					end
				end},
			{msg="Finish",
				sender="Timer_UpdateCheckPoint",
				func=function()
					TppStory.UpdateStorySequence{updateTiming="OnUpdateCheckPoint",isInGame=true}
				end},
			{msg="Finish",
				sender="Timer_MissionStartHeliDoorOpen",
				func=function()
					GameObject.SendCommand({type="TppHeli2",index=0},{id="RequestSnedDoorOpen"})
				end}
		},
		GameObject={
			{msg="ChangePhase",
				func=function(i,n)
					if mvars.mis_isExecuteGameOverOnDiscoveryNotice
						or (
						--r65 game_ENABLE_missionFailureOnCombatAlert
						TUPPMSettings.game_ENABLE_missionFailureOnCombatAlert
						and not TppMission.IsFOBMission(vars.missionCode)
						and vars.missionCode~=10260 --M45 A Quiet Exit
						and  not (
						--r65 game_ENABLE_ignoreFreePlayForMissionFailureOnCombatAlert
						TUPPMSettings.game_ENABLE_ignoreFreePlayForMissionFailureOnCombatAlert
						and (vars.missionCode==30010 or vars.missionCode==30020)
						)
						)
					then
						if n==TppGameObject.PHASE_ALERT then
							this.ReserveGameOver(TppDefine.GAME_OVER_TYPE.ON_DISCOVERY,TppDefine.GAME_OVER_RADIO.OTHERS)
						end
					end
				end},
			{msg="HeliDoorClosed",
				sender="SupportHeli",
				func=this.MissionClearOrAbortOnHeliDoorClosed},
			{msg="CalledFromStandby",
				sender="SupportHeli",
				func=function()
					if this.GetMissionName()~="s10020"then
						TppUI.ShowAnnounceLog"callHeliRecieved"
						local e=TppSupportRequest.GetCallRescueHeliGmpCost()
						TppTerminal.UpdateGMP{gmp=-e,gmpCostType=TppDefine.GMP_COST_TYPE.CALL_HELLI}
						svars.supportGmpCost=svars.supportGmpCost+e
					end
					TppSound.ClearOnDecendingLandingZoneJingleFlag()
				end},
			{msg="DescendToLandingZone",
				func=function()
					local e=this.CheckMissionClearOnOutOfMissionArea()
					local n=svars.mis_canMissionClear
					if e or n then
						TppSound.PostJingleOnDecendingLandingZone()
					else
						TppSound.PostJingleOnDecendingLandingZoneWithOutCanMissionClear()
					end
				end},
			{msg="StartedPullingOut",
				func=function()
					GkEventTimerManagerStart("Timer_RemoveUserMarker",1)
				end},
			{msg="LostControl",
				func=function(e,n,i)
					local e=GameObject.GetTypeIndex(e)
					if e~=TppGameObject.GAME_OBJECT_TYPE_HELI2 then
						return
					end
					if n==StrCode32"Start"then
						TppHelicopter.SetNewestPassengerTable()
						local e=TppHelicopter.GetPassengerlist()
						if IsTypeTable(e)and next(e)then
							TppUI.ShowAnnounceLog"extractionFailed"end
					end
					if n==StrCode32"End"then
						local e=TppSupportRequest.GetCrashRescueHeliGmpCost()
						TppTerminal.UpdateGMP{gmp=-e,gmpCostType=TppDefine.GMP_COST_TYPE.DESTROY_SUPPORT_HELI}
						if Tpp.IsPlayer(i)then
							TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.HELI_LOST_CONTROL_END)
						else
							TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.HELI_LOST_CONTROL_END_ENEMY_ATTACK)
						end
						svars.supportGmpCost=svars.supportGmpCost+e
					end
				end},
			{msg="Damage",
				func=function(e,n,i)
					local e=GameObject.GetTypeIndex(e)
					if e~=TppGameObject.GAME_OBJECT_TYPE_HELI2 then
						return
					end
					if Tpp.IsPlayer(i)and TppDamage.IsActiveByAttackId(n)then
						TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.HELI_DAMAGE_FROM_PLAYER)
					end
				end},
			{msg="DisableTranslate",
				func=function(e)
					local e=TppEnemy.GetSoldierType(e)
					if e==EnemyType.TYPE_SOVIET then
						if not TppQuest.IsCleard"ruins_q19010"then
							TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.DISABLE_TRANSLATE_RUSSIAN,true)
						end
					elseif e==EnemyType.TYPE_PF then
						if not TppQuest.IsCleard"outland_q19011"then
							TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.DISABLE_TRANSLATE_AFRIKANS,true)
						end
					end
				end}
		},
		Terminal={{msg="MbDvcActCallRescueHeli",
			func=function(n,e)do
				if e==2 then
					TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.CALL_HELI_FIRST_TIME_HOT_ZONE)
				else
					TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.CALL_HELI_SECOND_TIME)
				end
			end
			end},
		{msg="MbDvcActSelectLandPointEmergency",
			func=this.AcceptEmergencyMission},
		{msg="MbDvcActAcceptMissionList",
			func=this.AcceptEmergencyMission},
		{msg="MbDvcActHeliLandStartPos",
			func=this.SetHelicopterMissionStartPosition}
		},
		MotherBaseManagement={
			{msg="UpSectionLv",
				func=function(n,i,e)
					TppUI.ShowAnnounceLog(TppTerminal.unitLvAnnounceLogTable[n].up,e)
				end},
			{msg="DownSectionLv",
				func=function(e,i,n)
					TppUI.ShowAnnounceLog(TppTerminal.unitLvAnnounceLogTable[e].down,n)
				end},
			{msg="CompletedPlatform",
				func=function(e,e,e)
					TppStory.UpdateStorySequence{updateTiming="OnCompletedPlatform",isInGame=true}
				end},
			{msg="RequestSaveMbManagement",
				func=function()
					if((TppSave.IsForbidSave()or(vars.missionCode==10030))or(vars.missionCode==10115))or(not this.CheckMissionState())then
						TppMotherBaseManagement.SetRequestSaveResultFailure()
						return
					end
					TppSave.SaveOnlyMbManagement(TppSave.ReserveNoticeOfMbSaveResult)
				end,
				option={isExecMissionClear=true,isExecDemoPlaying=true,isExecGameOver=true,isExecMissionPrepare=true}},
			{msg="RequestSavePersonal",
				func=function()
					TppSave.CheckAndSavePersonalData()
				end}
		},
		Trap={
			{msg="Enter",
				sender="trap_mission_failed_area",
				func=function()
					if Tpp.IsHelicopter(vars.playerVehicleGameObjectId)then
					else
						this.ReserveGameOver(TppDefine.GAME_OVER_TYPE.OUTSIDE_OF_MISSION_AREA,TppDefine.GAME_OVER_RADIO.OUT_OF_MISSION_AREA)
					end
				end}
		}
	}
end
function this.MessagesWhileLoading()
	return Tpp.StrCode32Table{
		UI={
			{msg="EndMissionTelopFadeOut",func=function()
				--TUPPMLog.Log("TppMission.MessagesWhileLoading.EndMissionTelopFadeOut START returning func",1)
				this.DisablePauseForShowResult()
				if not gvars.needWaitMissionInitialize then
					if gvars.mis_missionClearState==TppDefine.MISSION_CLEAR_STATE.NOT_CLEARED_YET then
						return
					end
					this.SetMissionClearState(TppDefine.MISSION_CLEAR_STATE.SHOW_CREDIT_END)
					if IsTypeFunc(this.systemCallbacks.OnEndMissionCredit)then
						this.systemCallbacks.OnEndMissionCredit()
					else
						if not TppRadio.playingBlackTelInfo then
							this.ShowMissionReward()
						end
					end
				end
				--TUPPMLog.Log("TppMission.MessagesWhileLoading.EndMissionTelopFadeOut END",1)
			end},
			{msg="BonusPopupAllClose",func=this.OnEndMissionReward}
		},
		Radio={
			{msg="Finish",func=TppRadio.OnFinishBlackTelephoneRadio},nil
		},
		Video={
			{msg="VideoPlay",func=function(e)
				TppMovie.DoMessage(e,"onStart")
			end},
			{msg="VideoStopped",func=function(e)
				TppMovie.DoMessage(e,"onEnd")
			end}
		}
	}
end
local f=StrCode32"FallDeath"local c=StrCode32"Suicide"function this.OnPlayerDead(s,n)
	if not TppNetworkUtil.IsHost()then
		return
	end
	local i=this.IsFOBMission(vars.missionCode)
	if(not i)or TppPlayer.IsSneakPlayerInFOB(s)then
		if n==f then
			mvars.mis_isGameOverReasonSuicide=true
			this.ReserveGameOver(TppDefine.GAME_OVER_TYPE.PLAYER_FALL_DEAD,TppDefine.GAME_OVER_RADIO.PLAYER_DEAD)
		else
			if n==c then
				mvars.mis_isGameOverReasonSuicide=true
			end
			this.ReserveGameOver(TppDefine.GAME_OVER_TYPE.PLAYER_DEAD,TppDefine.GAME_OVER_RADIO.PLAYER_DEAD)
		end
	else
		svars.mis_fobDefenceGameOver=TppDefine.FOB_DEFENCE_GAME_OVER_TYPE.PLAYER_DEAD
	end
end
function this.OnEndMissionPreparation(n,s)
	mvars.mis_selectedDeployTime=n
	if gvars.mis_nextMissionCodeForEmergency==0 then
		local i
		if gvars.heli_missionStartRoute==0 then
			i=mvars.heli_missionStartRoute
		end
		local n=TppDefine.STORY_MISSION_CLUSTER_ID[gvars.mis_nextMissionCodeForMissionClear]
		if s then
			n=s
		end
		this.ReserveMissionClear{missionClearType=TppDefine.MISSION_CLEAR_TYPE.FROM_HELISPACE,nextMissionId=gvars.mis_nextMissionCodeForMissionClear,nextHeliRoute=i,nextClusterId=n}
	else
		gvars.usingNormalMissionSlot=false
		this.GoToEmergencyMission()
	end
end
function this.GetNextMissionCodeForEmergency()
	return(mvars.mis_emergencyMissionCode or gvars.mis_nextMissionCodeForEmergency)
end
function this.OnAbortMissionPreparation()
	this.SetNextMissionCodeForMissionClear(missionClearCodeNone)
	gvars.heli_missionStartRoute=0
end
function this.WaitFinishMissionEndPresentation()
	while(not TppUiCommand.IsEndMissionTelop())do
		if TppUiCommand.KeepMissionStartTelopBg then
			TppUiCommand.KeepMissionStartTelopBg(false)
		end
		coroutine.yield()
	end
	while(TppRadio.playingBlackTelInfo~=nil)do
		coroutine.yield()
	end
	TppUiCommand.StartResultBlockUnload()
	if gvars.needWaitMissionInitialize then
		TppMain.DisablePause()
	end
	while(gvars.needWaitMissionInitialize)do
		coroutine.yield()
	end
	TppMain.EnablePause()
end
function this.SetNeedWaitMissionInitialize()
	gvars.needWaitMissionInitialize=true
end
function this.ResetNeedWaitMissionInitialize()
	gvars.needWaitMissionInitialize=false
end
function this.CancelLoadOnResult()
	mvars.mis_doMissionFinalizeOnMissionTelopDisplay=nil
	this.ResetNeedWaitMissionInitialize()
end
function this.OnAllocate(n)
	this.systemCallbacks={
		OnEstablishMissionClear=
		function()
			this.MissionGameEnd{loadStartOnResult=false}
		end,
		OnDisappearGameEndAnnounceLog=this.ShowMissionResult,
		OnEndMissionCredit=nil,
		OnEndMissionReward=nil,
		OnGameOver=nil,
		OnOutOfMissionArea=nil,
		OnUpdateWhileMissionPrepare=nil,
		OnFobDefenceGameOver=nil,
		OnFinishBlackTelephoneRadio=
		function()
			if not gvars.needWaitMissionInitialize then
				this.ShowMissionReward()
			end
		end,
		OnOutOfHotZone=nil,
		OnOutOfHotZoneMissionClear=nil,
		OnUpdateStorySequenceInGame=nil,
		CheckMissionClearFunction=nil,
		OnReturnToMission=nil,
		OnAddStaffsFromTempBuffer=nil,
		CheckMissionClearOnRideOnFultonContainer=nil,
		OnRecovered=nil,
		OnSetMissionFinalScore=nil,
		OnEndDeliveryWarp=nil,
		OnFultonContainerMissionClear=nil
	}
	this.RegisterMissionID()
	if n.sequence then
		local i=n.sequence.missionObjectiveDefine
		local t=n.sequence.missionObjectiveTree
		local o=n.sequence.missionObjectiveEnum
		if i and t then
			this.SetMissionObjectives(i,t,o)
		end
		if n.sequence.missionStartPosition then
			if IsTypeTable(n.sequence.missionStartPosition.orderBoxList)then
				mvars.mis_orderBoxList=n.sequence.missionStartPosition.orderBoxList
			end
		end
		if n.sequence.ENABLE_DEFAULT_HELI_MISSION_CLEAR then
			mvars.mis_enableDefaultHeliMisionClear=true
		end
		mvars.mis_helicopterDoorOpenTimerTimeSec=15
		if n.sequence.HELICOPTER_DOOR_OPEN_TIME_SEC then
			mvars.mis_helicopterDoorOpenTimerTimeSec=n.sequence.HELICOPTER_DOOR_OPEN_TIME_SEC
		end
	end
	mvars.mis_isOutsideOfMissionArea=false
	mvars.mis_isOutsideOfHotZone=true
	this.MessageHandler={OnMessage=function(i,n,s,t,a,o)
		this.OnMessageWhileLoading(i,n,s,t,a,o)
	end}
	GameMessage.SetMessageHandler(this.MessageHandler,{"UI","Radio","Video","Network","Nt"})
end
function this.DisableInGameFlag()
	mvars.mis_missionStateIsNotInGame=true
end
function this.EnableInGameFlag(n)
	if(not gvars.usingNormalMissionSlot)and this.IsHelicopterSpace(vars.missionCode)then
		n=true
	end
	if gvars.mis_missionClearState<=TppDefine.MISSION_CLEAR_STATE.NOT_CLEARED_YET then
		mvars.mis_missionStateIsNotInGame=false
		if not n then
			TppSoundDaemon.ResetMute"Loading"end
	else
		mvars.mis_missionStateIsNotInGame=true
	end
end
function this.ExecuteSystemCallback(s,n)
	--  TUPPMLog.Log("ExecuteSystemCallback: "..tostring(s)..", "..tostring(n))
	local e=this.systemCallbacks[s]
	if IsTypeFunc(e)then
		return e(n)
	end
end
function this.Init(n)
	this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
	this.messageExecTableWhileLoading=Tpp.MakeMessageExecTable(this.MessagesWhileLoading())
	local n=this.IsHelicopterSpace(vars.missionCode)
	local e=this.IsFreeMission(vars.missionCode)
	if((not n)and(not e))and(not TppLocation.IsCyprus())then
		mvars.mis_isAlertOutOfMissionArea=true
	else
		mvars.mis_isAlertOutOfMissionArea=false
	end
	if vars.missionCode==10030 then
		mvars.mis_isAlertOutOfMissionArea=false
	end
	if vars.missionCode==10140 or vars.missionCode==11140 then
		mvars.mis_isAlertOutOfMissionArea=false
	end
	if vars.missionCode==10240 then
		mvars.mis_isAlertOutOfMissionArea=false
	end
	if vars.missionCode==50050 then
		mvars.mis_isAlertOutOfMissionArea=false
	end
end
function this.OnReload(n)
	this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
	this.messageExecTableWhileLoading=Tpp.MakeMessageExecTable(this.MessagesWhileLoading())
	if n.sequence then
		local i=n.sequence.missionObjectiveDefine
		local s=n.sequence.missionObjectiveTree
		local n=n.sequence.missionObjectiveEnum
		if i and s then
			this.SetMissionObjectives(i,s,n)
		end
	end
	local n={"OnEstablishMissionClear","OnDisappearGameEndAnnounceLog","OnEndMissionCredit","OnEndMissionReward","OnGameOver","OnOutOfMissionArea","OnUpdateWhileMissionPrepare","OnFobDefenceGameOver","OnFinishBlackTelephoneRadio","OnOutOfHotZone","OnOutOfHotZoneMissionClear","OnUpdateStorySequenceInGame","CheckMissionClearFunction","OnReturnToMission","OnAddStaffsFromTempBuffer","CheckMissionClearOnRideOnFultonContainer","OnRecovered","OnMissionGameEndFadeOutFinish","OnFultonContainerMissionClear"}
	for n,i in ipairs(n)do
		local n=_G.TppMission.systemCallbacks
		if n then
			local n=n[i]
			this.systemCallbacks=this.systemCallbacks or{}
			this.systemCallbacks[i]=n
		end
	end
end
function this.RegisterMissionID()
	mvars.mis_missionName=this._CreateMissionName(vars.missionCode)
end
function this.DeclareSVars()
	return{{name="mis_canMissionClear",type=TppScriptVars.TYPE_BOOL,value=false,save=true,notify=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="mis_isDefiniteGameOver",type=TppScriptVars.TYPE_BOOL,value=false,save=false,sync=true,wait=true,category=TppScriptVars.CATEGORY_MISSION},{name="mis_gameOverType",type=TppScriptVars.TYPE_UINT8,value=0,save=false,sync=true,wait=true,category=TppScriptVars.CATEGORY_MISSION},{name="mis_gameOverRadio",type=TppScriptVars.TYPE_UINT8,value=0,save=false,sync=true,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="mis_isDefiniteMissionClear",type=TppScriptVars.TYPE_BOOL,value=false,save=true,sync=true,wait=true,category=TppScriptVars.CATEGORY_MISSION},{name="mis_missionClearType",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=true,wait=true,category=TppScriptVars.CATEGORY_MISSION},{name="mis_objectiveEnable",arraySize=maxObjective,type=TppScriptVars.TYPE_BOOL,value=false,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="mis_fobDefenceGameOver",type=TppScriptVars.TYPE_UINT8,value=0,save=false,sync=true,wait=true,category=TppScriptVars.CATEGORY_MISSION},{name="chickCapEnabled",type=TppScriptVars.TYPE_BOOL,value=false,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_RETRY},{name="dialogPlayerDeadCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_RETRY},nil}
end
function this.CheckMessageOptionWhileLoading()
	return true
end
function this.OnMessageWhileLoading(t,a,o,r,i,s)
	local n=Tpp.DEBUG_StrCode32ToString
	local n
	Tpp.DoMessage(this.messageExecTableWhileLoading,this.CheckMessageOptionWhileLoading,t,a,o,r,i,s,n)
end
function this.OnMessage(t,s,i,n,o,r,a)
	Tpp.DoMessage(this.messageExecTable,this.CheckMessageOption,t,s,i,n,o,r,a)
end
function this.CheckMessageOption(n)
	local t=false
	local a=false
	local r=false
	local i=false
	if n and IsTypeTable(n)then
		t=n[StrCode32"isExecMissionClear"]a=n[StrCode32"isExecGameOver"]r=n[StrCode32"isExecDemoPlaying"]i=n[StrCode32"isExecMissionPrepare"]
	end
	return this.CheckMissionState(t,a,r,i)
end
function this.CheckMissionState(isExecMissionClear,isExecGameOver,isExecDemoPlaying,isExecMissionPrepare)
	local mvars=mvars
	local svars=svars
	if svars==nil then
		return
	end
	local mis_isReserveMissionClear_OR_mis_isDefiniteMissionClear=mvars.mis_isReserveMissionClear or svars.mis_isDefiniteMissionClear
	local mis_isReserveGameOver_OR_mis_isDefiniteGameOver=mvars.mis_isReserveGameOver or svars.mis_isDefiniteGameOver
	local demoIsNotPlayable=TppDemo.IsNotPlayable()
	local missionStarted=false
	if svars.seq_sequence<=1 then
		missionStarted=true
	end
	if mis_isReserveMissionClear_OR_mis_isDefiniteMissionClear and not isExecMissionClear then
		return false
	elseif mis_isReserveGameOver_OR_mis_isDefiniteGameOver and not isExecGameOver then
		return false
	elseif demoIsNotPlayable and not isExecDemoPlaying then
		return false
	elseif missionStarted and not isExecMissionPrepare then
		return false
	else
		return true
	end
end
function this.CheckMissionClearOnOutOfMissionArea()
	if this.systemCallbacks.CheckMissionClearFunction then
		return this.systemCallbacks.CheckMissionClearFunction()
	else
		return false
	end
end
function this.EnableAlertOutOfMissionAreaIfAlertAreaStart()
	if mvars.mis_isAlertOutOfMissionArea then
		this.EnableAlertOutOfMissionArea()
	end
end
function this.IgnoreAlertOutOfMissionAreaForBossQuiet(e)
	if e==true then
		mvars.mis_ignoreAlertOfMissionArea=true
	else
		mvars.mis_ignoreAlertOfMissionArea=false
	end
end
function this.EnableAlertOutOfMissionArea()
	local e=false
	if mvars.mis_ignoreAlertOfMissionArea==true then
		e=true
	end
	if svars.mis_canMissionClear then
		return
	end
	if mvars.mis_missionStateIsNotInGame then
		return
	end
	if not IsHelicopter(vars.playerVehicleGameObjectId)then
		mvars.mis_enableAlertOutOfMissionArea=true
		TppUI.ShowAnnounceLog"closeOutOfMissionArea"TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.OUTSIDE_MISSION_AREA)
		if not e then
			TppTerminal.PlayTerminalVoice("VOICE_WARN_MISSION_AREA",true,1)
			TppOutOfMissionRangeEffect.Enable(3)
		end
	end
end
function this.DisableAlertOutOfMissionArea()
	mvars.mis_enableAlertOutOfMissionArea=false
	TppOutOfMissionRangeEffect.Disable(1)
	TppTerminal.PlayTerminalVoice("VOICE_WARN_MISSION_AREA",false)
end
function this.ExitHotZone()
	this.ExecuteSystemCallback"OnOutOfHotZone"if svars.mis_canMissionClear then
		TppUI.ShowAnnounceLog"leaveHotZone"if not IsNotAlert()and not IsHelicopter(vars.playerVehicleGameObjectId)then
			TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.OUTSIDE_HOTZONE_ALERT)
		else
			TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.OUTSIDE_HOTZONE)
		end
	end
end
function this.PlayCommonRadioOnInsideOfHotZone()
	if svars.mis_canMissionClear then
		local e=not IsHelicopter(vars.playerVehicleGameObjectId)
		if e then
			TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.RETURN_HOTZONE)
		end
	end
end
function this.OnChangeFobDefenceGameOver()
	if svars.mis_fobDefenceGameOver==TppDefine.FOB_DEFENCE_GAME_OVER_TYPE.INIT then
		return
	end
	if TppNetworkUtil.IsHost()then
		return
	end
	if this.systemCallbacks.OnFobDefenceGameOver then
		this.systemCallbacks.OnFobDefenceGameOver(svars.mis_fobDefenceGameOver)
	end
end
function this.PlayCommonRadioOnRideHelicopter()
	if svars.mis_canMissionClear then
		this.StartJingleOnHelicopterClear()
	else
		TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.ABORT_BY_HELI)
	end
end
function this.StartJingleOnHelicopterClear()
	TppSound.StartJingleOnClearHeli()
	TppSoundDaemon.SetMute"HeliClosing"end
function this.MissionClearOrAbortOnHeliDoorClosed()
	if not mvars.mis_enableDefaultHeliMisionClear then
		return
	end
	if svars.mis_canMissionClear then
		this.ReserveMissionClearOnRideOnHelicopter()
	else
		this.AbortForRideOnHelicopter{isNoSave=false}
	end
end
function this.ReserveMissionStartRecoverSoundDemo()
	if Tpp.IsEnemyWalkerGear(vars.playerVehicleGameObjectId)then
		gvars.mis_missionStartRecoverDemoType=TppDefine.MISSION_START_RECOVER_DEMO_TYPE.WALKER_GEAR
		TppTerminal.ReserveHelicopterSoundOnMissionGameEnd()
	elseif Tpp.IsVehicle(vars.playerVehicleGameObjectId)then
		gvars.mis_missionStartRecoverDemoType=TppDefine.MISSION_START_RECOVER_DEMO_TYPE.VEHICLE
	else
		this.ClearMissionStartRecoverSoundDemo()
	end
end
function this.ClearMissionStartRecoverSoundDemo()
	gvars.mis_missionStartRecoverDemoType=TppDefine.MISSION_START_RECOVER_DEMO_TYPE.NONE
end
function this.GetMissionStartRecoverDemoType()
	return gvars.mis_missionStartRecoverDemoType
end
function this.OutsideOfHotZoneCount()
	if mvars.mis_isOutsideOfHotZone then
		this.ReserveMissionClearOnOutOfHotZone()
	end
end
local function c()
	if GkEventTimerManagerIsTimerActive"Timer_OutsideOfHotZoneCount"then
		GkEventTimerManagerStop"Timer_OutsideOfHotZoneCount"end
end
function this.CheckMissionClearOnRideOnFultonContainer()
	if this.systemCallbacks.CheckMissionClearOnRideOnFultonContainer then
		return this.systemCallbacks.CheckMissionClearOnRideOnFultonContainer()
	else
		return false
	end
end
function this.OnPlayerFultoned()
	if this.IsFOBMission(vars.missionCode)then
		return
	end
	if this.IsCanMissionClear()or this.CheckMissionClearOnRideOnFultonContainer()then
		this.ReserveMissionClearOnRideOnFultonContainer()
	else
		this.AbortForRideFultonContainer()
	end
end
function this.Update()
	local n=mvars
	local i=svars
	local s=this.GetMissionName()
	if n.mis_needSetCanMissionClear then
		this._SetCanMissionClear()
	end
	if n.mis_missionStateIsNotInGame then
		return
	end
	local f,S,u,c=this.GetSyncMissionStatus()
	local p=n.mis_isAlertOutOfMissionArea
	local o=n.mis_isOutsideOfMissionArea
	local d=n.mis_isOutsideOfHotZone
	local r=i.mis_canMissionClear
	if f and S then
		TppMain.DisableGameStatus()HighSpeedCamera.RequestToCancel()
		this.EstablishedMissionClear(i.mis_missionClearType)
	elseif u and c then
		TppMain.DisableGameStatus()HighSpeedCamera.RequestToCancel()
		if n.mis_isAborting then
			this.EstablishedMissionAbort()
		else
			this.EstablishedGameOver()
		end
	elseif r then
		this.UpdateAtCanMissionClear(d,o)
	else
		if o then
			local n=not IsHelicopter(vars.playerVehicleGameObjectId)
			if n then
				if this.CheckMissionClearOnOutOfMissionArea()then
					this.ReserveMissionClearOnOutOfHotZone()
				else
					if this.systemCallbacks.OnOutOfMissionArea==nil then
						this.AbortForOutOfMissionArea{isNoSave=false}
					else
						this.systemCallbacks.OnOutOfMissionArea()
					end
				end
			end
		end
		if p then
			if not GkEventTimerManagerIsTimerActive(Timer_outsideOfInnerZone)then
				GkEventTimerManagerStart(Timer_outsideOfInnerZone,outSideOfInnerZoneTime)
			end
		else
			if GkEventTimerManagerIsTimerActive(Timer_outsideOfInnerZone)then
				GkEventTimerManagerStop(Timer_outsideOfInnerZone)
			end
		end
	end
	if TppSequence.IsMissionPrepareFinished()then
		v()
	end
	this.ResumeMbSaveCoroutine()
	if n.mis_needSetEscapeBgm then
		if s=="s10090"or s=="s11090"then
			TppSound.StartEscapeBGM()
		else
			if vars.playerPhase>TppEnemy.PHASE.SNEAK then
				TppSound.StartEscapeBGM()
			else
				TppSound.StopEscapeBGM()
			end
		end
	end
end
function this.UpdateForMissionLoad()
	if mvars.mis_loadRequest then
		this.LoadWithChunkCheck()
	end
end
function this.CreateMbSaveCoroutine()
	local function n()
		while(not TppMotherBaseManagement.IsEndedSyncControl())do
			coroutine.yield()
		end
		if TppMotherBaseManagement.IsResultSuccessedSyncControl()then
			TppSave.SaveOnlyMbManagement()
		end
	end
	this.waitMbSyncAndSaveCoroutine=coroutine.create(n)
end
function this.ResumeMbSaveCoroutine()
	if this.waitMbSyncAndSaveCoroutine then
		local n,n=coroutine.resume(this.waitMbSyncAndSaveCoroutine)
		if coroutine.status(this.waitMbSyncAndSaveCoroutine)=="dead"then
			this.waitMbSyncAndSaveCoroutine=nil
			return
		end
	end
end
function this.GetSyncMissionStatus()
	local o=mvars
	local e=svars
	local a=TppNetworkUtil.IsHost()
	local r=TppNetworkUtil.IsSessionConnect()
	local i=false
	local n=false
	local t=false
	local s=false
	if a then
		i=e.mis_isDefiniteMissionClear and SVarsIsSynchronized"mis_isDefiniteMissionClear"n=SVarsIsSynchronized"mis_missionClearType"t=e.mis_isDefiniteGameOver and SVarsIsSynchronized"mis_isDefiniteGameOver"s=SVarsIsSynchronized"mis_gameOverType"else
		if r then
			i=e.mis_isDefiniteMissionClear
			n=true
			t=e.mis_isDefiniteGameOver
			s=e.mis_gameOverType
		else
			i=o.mis_isReserveMissionClear
			n=true
			t=o.mis_isDefiniteGameOver
			s=true
		end
	end
	return i,n,t,s
end
function this.SeizeReliefVehicleOnAbort()
	if mvars.mis_abortIsTitleMode then
		return
	end
	if not GameObject.DoesGameObjectExistWithTypeName"TppVehicle2"then
		return
	end
	local e=GameObject.CreateGameObjectId("TppVehicle2",0)
	if not GameObject.SendCommand(e,{id="IsAlive"})then
		return
	end
	if mvars.mis_abortWithSave and not mvars.mis_abortByRestartFromHelicopter then
		if e~=vars.playerVehicleGameObjectId then
			if Player.GetItemLevel(TppEquip.EQP_IT_Fulton_Cargo)>=2 or Player.GetItemLevel(TppEquip.EQP_IT_Fulton_WormHole)>=1 then
				local n=GameObject.SendCommand(e,{id="GetResourceId"})
				local i=not Tpp.IsHelicopter(vars.playerVehicleGameObjectId)
				TppTerminal.OnFulton(e,nil,nil,n,nil,i,PlayerInfo.GetLocalPlayerIndex())
			end
		end
	else
		GameObject.SendCommand(e,{id="Seize",options={"Fulton","CheckFultonType","DirectAccount"}})
	end
end
function this.SeizeReliefVehicleOnClear()
	if not GameObject.DoesGameObjectExistWithTypeName"TppVehicle2"then
		return
	end
	local n=GameObject.CreateGameObjectId("TppVehicle2",0)
	if not GameObject.SendCommand(n,{id="IsAlive"})then
		return
	end
	if n~=vars.playerVehicleGameObjectId then
		local i={"Fulton","CheckFultonType"}
		local s=this.GetMissionClearType()
		if not this.EvaluateReliefVehicleSeizable(s)then
			table.insert(i,"CheckFarFromPlayer")
		end
		GameObject.SendCommand(n,{id="Seize",options=i})
	end
end
function this.SeizeReliefVehicleOnForceGoToMb()
	if not GameObject.DoesGameObjectExistWithTypeName"TppVehicle2"then
		return
	end
	local e=GameObject.CreateGameObjectId("TppVehicle2",0)
	if not GameObject.SendCommand(e,{id="IsAlive"})then
		return
	end
	GameObject.SendCommand(e,{id="Seize",options={"Fulton","CheckFultonType","DirectAccount"}})
end
function this.EvaluateReliefVehicleSeizable(e)
	if((e~=TppDefine.MISSION_CLEAR_TYPE.FREE_PLAY_ORDER_BOX_DEMO and e~=TppDefine.MISSION_CLEAR_TYPE.QUEST_BOSS_QUIET_BATTLE_END)and e~=TppDefine.MISSION_CLEAR_TYPE.QUEST_LOST_QUIET_END)and e~=TppDefine.MISSION_CLEAR_TYPE.QUEST_INTRO_RESCUE_EMERICH_END then
		return true
	end
	return false
end
function this.EvaluateVehicleCarryOption(i)
	local n={}
	if this.EvaluateReliefVehicleSeizable(i)then
		table.insert(n,"Abandon")
	end
	return n
end
function this.ExecuteVehicleSaveCarryOnAbort()
	if mvars.mis_abortByRestartFromHelicopter then
		return
	end
	Vehicle.SaveCarry()
end
function this.ExecuteVehicleSaveCarryOnClear()
	local n=vars.locationCode
	if n~=TppDefine.LOCATION_ID.AFGH and n~=TppDefine.LOCATION_ID.MAFR then
		return
	end
	local n=this.GetMissionClearType()
	local t=this.EvaluateVehicleCarryOption(n)
	local s=nil
	local i=nil
	if n==TppDefine.MISSION_CLEAR_TYPE.FREE_PLAY_ORDER_BOX_DEMO then
		if mvars.mis_orderBoxList then
			if gvars.mis_orderBoxName~=0 then
				local n=this.FindOrderBoxName(gvars.mis_orderBoxName)
				local e,n=this.GetOrderBoxLocator(n)
				if e then
					local t=Vector3(0,-.75,1.98)
					local e=Vector3(e[1],e[2],e[3])
					local t=-Quat.RotationY(TppMath.DegreeToRadian(n)):Rotate(t)s=t+e
					i=n
				end
			end
		end
	end
	Vehicle.SaveCarry{options=t,initialPosition=s,initialRotY=i}
end
function this.EstablishedMissionAbort()
	--r66 BUGFIX minor - takes care of restarts/checkpoints
	if TUPPMSettings.heli_ENABLE_skipRides then
		--r45 Fake heli removal fixes
		TppMain.comingFromTitleDontFireHeliRemoval=false
		TppMain.mbVeryFastCheckpointReloadHeliRouteNotFireFIX=false
		--TUPPMLog.Log("EstablishedMissionAbort so reset heli removal flags to false")
	end

	this.SeizeReliefVehicleOnAbort()
	TppQuest.OnMissionGameEnd()
	if mvars.mis_abortWithPlayRadio then
		TppRadio.PlayGameOverRadio()
	end
	if mvars.mis_abortIsTitleMode then
		gvars.ini_isTitleMode=true
	end
	if mvars.mis_abortPresentationFunction then
		mvars.mis_abortPresentationFunction()
	end
	if mvars.mis_abortWithFade then
		if mvars.mis_missionAbortFadeDelayTime==0 then
			this.FadeOutOnMissionAbort()
		else
			GkEventTimerManagerStart("Timer_StartMissionAbortFadeOut",mvars.mis_missionAbortFadeDelayTime)
		end
	else
		this.ExecuteMissionAbort()
	end
end
function this.FadeOutOnMissionAbort()
	local e
	if mvars.mis_abortWithSave then
		TppHero.MissionAbort()e={AnnounceLog="SUSPEND_LOG"}
	else
		e={AnnounceLog="INVALID_LOG"}
	end
	TppUI.FadeOut(mvars.mis_missionAbortFadeSpeed,"AbortMissionFadeOutFinish",nil,{setMute=true,exceptGameStatus=e})
end
function this.OnEndFadeOutMissionAbort()
	this.VarSaveForMissionAbort()
	this.ShowAnnounceLogOnFadeOut(this.LoadForMissionAbort)
end
function this.EstablishedGameOver()
	TppMusicManager.StopJingleEvent()
	local n={}
	local i=TppStory.GetCurrentStorySequence()
	for e=i,TppDefine.STORY_SEQUENCE.STORY_START,-1 do
		local e=TppDefine.CONTINUE_TIPS_TABLE[e]
		if e then
			for i,e in ipairs(e)do
				table.insert(n,e)
			end
		end
	end
	if#n>0 then
		local e=gvars.continueTipsCount
		if(e>#n)then
			e=1
			gvars.continueTipsCount=1
		end
		local n=n[e]
		local e
		if n then
			e=TppDefine.TIPS[n]
		end
		if Tpp.IsTypeNumber(e)then
			TppUiCommand.SeekLoadingTips(tostring(e))
			gvars.continueTipsCount=gvars.continueTipsCount+1
		end
	end
	local n
	if this.systemCallbacks.OnGameOver then
		n=this.systemCallbacks.OnGameOver()
	end
	if not mvars.mis_isGameOverReasonSuicide then
		svars.dialogPlayerDeadCount=svars.dialogPlayerDeadCount+1
	end
	if not n then
		if this.CheckGameOverDemo(TppDefine.GAME_OVER_TYPE.PLAYER_FALL_DEAD)then
			TppPlayer.PlayFallDeadCamera()
			this.ShowGameOverMenu{delayTime=TppPlayer.PLAYER_FALL_DEAD_DELAY_TIME}
		else
			this.ShowGameOverMenu()
		end
	end
end
function this.UpdateAtCanMissionClear(n,o)
	if not n then
		mvars.mis_lastOutSideOfHotZoneButAlert=nil
		c()
		return
	end
	local i=IsNotAlert()
	local n=IsPlayerStatusNormal()
	local s=not IsHelicopter(vars.playerVehicleGameObjectId)
	if o then
		if n and s then
			c()
			this.ReserveMissionClearOnOutOfHotZone()
		end
	else
		if(i and n)and s then
			if not GkEventTimerManagerIsTimerActive"Timer_OutsideOfHotZoneCount"then
				GkEventTimerManagerStart("Timer_OutsideOfHotZoneCount",outSideOfHotZoneCount)
			end
		else
			if not i then
				mvars.mis_lastOutSideOfHotZoneButAlert=true
			end
			c()
		end
	end
end
function this.ReserveMissionClearOnOutOfHotZone()
	if this.systemCallbacks.OnOutOfHotZoneMissionClear then
		this.systemCallbacks.OnOutOfHotZoneMissionClear()
		return
	end
	this._ReserveMissionClearOnOutOfHotZone()
end
function this._ReserveMissionClearOnOutOfHotZone()
	if mvars.mis_lastOutSideOfHotZoneButAlert then
		TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.OUTSIDE_HOTZONE_CHANGE_SNEAK)
	end
	if TppLocation.IsAfghan()then
		this.ReserveMissionClear{missionClearType=TppDefine.MISSION_CLEAR_TYPE.ON_FOOT,nextMissionId=TppDefine.SYS_MISSION_ID.AFGH_FREE}
	elseif TppLocation.IsMiddleAfrica()then
		this.ReserveMissionClear{missionClearType=TppDefine.MISSION_CLEAR_TYPE.ON_FOOT,nextMissionId=TppDefine.SYS_MISSION_ID.MAFR_FREE}
	else
		this.ReserveMissionClear{missionClearType=TppDefine.MISSION_CLEAR_TYPE.ON_FOOT,nextMissionId=TppDefine.SYS_MISSION_ID.AFGH_FREE}
	end
end
function this.ReserveMissionClearOnRideOnHelicopter()
	if TppLocation.IsAfghan()then
		this.ReserveMissionClear{missionClearType=TppDefine.MISSION_CLEAR_TYPE.RIDE_ON_HELICOPTER,nextMissionId=TppDefine.SYS_MISSION_ID.AFGH_HELI}
	elseif TppLocation.IsMiddleAfrica()then
		this.ReserveMissionClear{missionClearType=TppDefine.MISSION_CLEAR_TYPE.RIDE_ON_HELICOPTER,nextMissionId=TppDefine.SYS_MISSION_ID.MAFR_HELI}
	elseif TppLocation.IsMotherBase()then
		this.ReserveMissionClear{missionClearType=TppDefine.MISSION_CLEAR_TYPE.RIDE_ON_HELICOPTER,nextMissionId=TppDefine.SYS_MISSION_ID.MTBS_HELI}
	else
		this.ReserveMissionClear{missionClearType=TppDefine.MISSION_CLEAR_TYPE.RIDE_ON_HELICOPTER,nextMissionId=TppDefine.SYS_MISSION_ID.AFGH_HELI}
	end
end
function this.ReserveMissionClearOnRideOnFultonContainer()
	if this.systemCallbacks.OnFultonContainerMissionClear then
		this.systemCallbacks.OnFultonContainerMissionClear()
	else
		local n=this.GetCurrentLocationHeliMissionAndLocationCode()
		this.ReserveMissionClear{missionClearType=TppDefine.MISSION_CLEAR_TYPE.RIDE_ON_FULTON_CONTAINER,nextMissionId=n}
	end
end
function this.AbortMissionByMenu()
	if this.IsFOBMission(vars.missionCode)then
		TppSoundDaemon.PostEvent"env_wormhole_out"this.ReserveGameOver(TppDefine.GAME_OVER_TYPE.FOB_ABORT,TppDefine.GAME_OVER_RADIO.OUT_OF_MISSION_AREA)
	else
		if gvars.mis_isStartFromHelispace then
			this.AbortForRideOnHelicopter()
		elseif gvars.mis_isStartFromFreePlay then
			this.AbortForOutOfMissionArea()
		else
			this.AbortForRideOnHelicopter()
		end
	end
end
function this.AbortForOutOfMissionArea(r)
	local n=true
	local t
	local i,o
	local a
	if IsTypeTable(r)then
		if r.isNoSave then
			n=true
		else
			n=false
			i=5.5
			o=TppUI.FADE_SPEED.FADE_HIGHSPEED
			t=TppPlayer.PlayMissionAbortCamera
			a=true
		end
	end
	if TppLocation.IsAfghan()then
		this.AbortMission{nextMissionId=TppDefine.SYS_MISSION_ID.AFGH_FREE,isNoSave=n,fadeDelayTime=i,fadeSpeed=o,presentationFunction=t,playRadio=a}
	elseif TppLocation.IsMiddleAfrica()then
		this.AbortMission{nextMissionId=TppDefine.SYS_MISSION_ID.MAFR_FREE,isNoSave=n,fadeDelayTime=i,fadeSpeed=o,presentationFunction=t,playRadio=a}
	else
		this.AbortMission{nextMissionId=TppDefine.SYS_MISSION_ID.AFGH_FREE,isNoSave=n,fadeDelayTime=i,fadeSpeed=o,presentationFunction=t,playRadio=a}
	end
end
function this.AbortForRideOnHelicopter(t)
	local n=true
	local i=false
	if IsTypeTable(t)then
		if t.isNoSave then
			n=true
		else
			n=false
		end
		if t.isAlreadyGameOver then
			i=true
		end
	end
	if TppLocation.IsAfghan()then
		gvars.ini_isTitleMode=false
		this.AbortMission{nextMissionId=TppDefine.SYS_MISSION_ID.AFGH_HELI,isNoSave=n,isAlreadyGameOver=i}
	elseif TppLocation.IsMiddleAfrica()then
		gvars.ini_isTitleMode=false
		this.AbortMission{nextMissionId=TppDefine.SYS_MISSION_ID.MAFR_HELI,isNoSave=n,isAlreadyGameOver=i}
	elseif TppLocation.IsMotherBase()then
		gvars.ini_isTitleMode=false
		this.AbortMission{nextMissionId=TppDefine.SYS_MISSION_ID.MTBS_HELI,isNoSave=n,isAlreadyGameOver=i}
	else
		gvars.ini_isTitleMode=false
		this.AbortMission{nextMissionId=TppDefine.SYS_MISSION_ID.AFGH_HELI,isNoSave=n,isAlreadyGameOver=i}
	end
end
function this.AbortForRideFultonContainer(n)
	this.AbortForRideOnHelicopter{isNoSave=false}
end
function this.GameOverAbortMission()
	if gvars.mis_isStartFromHelispace then
		this.GameOverAbortForRideOnHelicopter()
	elseif gvars.mis_isStartFromFreePlay then
		this.GameOverAbortForOutOfMissionArea()
	else
		this.GameOverAbortForRideOnHelicopter()
	end
	this.ExecuteMissionAbort()
end
function this.GameOverAbortForOutOfMissionArea()
	if TppLocation.IsAfghan()then
		mvars.mis_abortWithSave=false
		mvars.mis_nextMissionCodeForAbort=TppDefine.SYS_MISSION_ID.AFGH_FREE
	elseif TppLocation.IsMiddleAfrica()then
		mvars.mis_abortWithSave=false
		mvars.mis_nextMissionCodeForAbort=TppDefine.SYS_MISSION_ID.MAFR_FREE
	else
		mvars.mis_abortWithSave=false
		mvars.mis_nextMissionCodeForAbort=TppDefine.SYS_MISSION_ID.AFGH_FREE
	end
end
function this.GameOverAbortForRideOnHelicopter()
	if TppLocation.IsAfghan()then
		mvars.mis_abortWithSave=false
		mvars.mis_nextMissionCodeForAbort=TppDefine.SYS_MISSION_ID.AFGH_HELI
	elseif TppLocation.IsMiddleAfrica()then
		mvars.mis_abortWithSave=false
		mvars.mis_nextMissionCodeForAbort=TppDefine.SYS_MISSION_ID.MAFR_HELI
	elseif TppLocation.IsMotherBase()then
		mvars.mis_abortWithSave=false
		mvars.mis_nextMissionCodeForAbort=TppDefine.SYS_MISSION_ID.MTBS_HELI
	elseif TppLocation.IsMBQF()then
		mvars.mis_abortWithSave=false
		mvars.mis_nextMissionCodeForAbort=TppDefine.SYS_MISSION_ID.MTBS_HELI
	else
		mvars.mis_abortWithSave=false
		mvars.mis_nextMissionCodeForAbort=TppDefine.SYS_MISSION_ID.AFGH_HELI
	end
end
function this.OnChangeSVars(n,i)
	if n=="mis_isDefiniteMissionClear"then
		if(svars.mis_isDefiniteMissionClear)then
			mvars.mis_isReserveMissionClear=true
		end
	end
	if n=="mis_isDefiniteGameOver"then
		if(svars.mis_isDefiniteGameOver)then
			mvars.mis_isDefiniteGameOver=true
		end
	end
	if n=="mis_fobDefenceGameOver"then
		this.OnChangeFobDefenceGameOver()
	end
	if n=="mis_canMissionClear"then
		if svars.mis_canMissionClear then
			this.OnCanMissionClear()
		end
		if mvars.mis_isAlertOutOfMissionArea then
			this.EnableAlertOutOfMissionArea()
		else
			this.DisableAlertOutOfMissionArea()
		end
		if mvars.mis_isOutsideOfHotZone then
			this.ExitHotZone()
		end
	end
end
function this.PostMissionOrderBoxPositionToBuddyDog()
	if(not this.IsFreeMission(vars.missionCode))then
		if mvars.mis_orderBoxList then
			local n={}
			for s,i in pairs(mvars.mis_orderBoxList)do
				local e,i=this.GetOrderBoxLocatorByTransform(i)
				if e then
					table.insert(n,e)
				end
			end
			TppBuddyService.SetMissionGroundStartPositions{positions=n}
		else
			TppBuddyService.ResetDogLeakedInformation()
		end
	else
		TppBuddyService.ResetDogLeakedInformation()
	end
end
function this.SetIsStartFromHelispace()
	gvars.mis_isStartFromHelispace=true
end
function this.ResetIsStartFromHelispace()
	gvars.mis_isStartFromHelispace=false
end
function this.SetIsStartFromFreePlay()
	gvars.mis_isStartFromFreePlay=true
end
function this.ResetIsStartFromFreePlay()
	gvars.mis_isStartFromFreePlay=false
end
function this.CanMissionAbortByMenu()
	if gvars.mis_isStartFromHelispace or gvars.mis_isStartFromFreePlay then
		return true
	else
		return false
	end
end
function this.SetMissionOrderBoxPosition()
	if not mvars.mis_orderBoxList then
		return
	end
	if gvars.mis_orderBoxName==0 then
		return
	end
	local n=this.FindOrderBoxName(gvars.mis_orderBoxName)
	return this._SetMissionOrderBoxPosition(n)
end
function this._SetMissionOrderBoxPosition(n)
	local e,n=this.GetOrderBoxLocator(n)
	if e then
		local i=Vector3(0,-.75,1.98)
		local e=Vector3(e[1],e[2],e[3])
		local i=-Quat.RotationY(TppMath.DegreeToRadian(n)):Rotate(i)
		local e=i+e
		local e=TppMath.Vector3toTable(e)
		local n=n
		TppPlayer.SetInitialPosition(e,n)
		TppPlayer.SetMissionStartPosition(e,n)
		return true
	end
end
function this.FindOrderBoxName(n)
	for i,e in pairs(mvars.mis_orderBoxList)do
		if StrCode32(e)==n then
			return e
		end
	end
end
function this.GetOrderBoxLocator(e)
	if not IsTypeString(e)then
		return
	end
	return Tpp.GetLocator("OrderBoxIdentifier",e)
end
function this.GetOrderBoxLocatorByTransform(e)
	if not IsTypeString(e)then
	end
	return Tpp.GetLocatorByTransform("OrderBoxIdentifier",e)
end
function this.SetFobPlayerStartPoint()
	local n={"Command","Combat","Develop","Support","Medical","Spy","BaseDev"}
	local e=255
	if not MotherBaseStage.GetFirstCluster then
		e=MotherBaseStage.GetCurrentCluster()
	else
		e=MotherBaseStage.GetFirstCluster()
	end
	local i=n[e+1]
	local n=TppMotherBaseManagement.GetMbsClusterGrade{category=i}
	if TppMotherBaseManagement.GetMbsClusterBuildStatus{category=i}~="Completed"then
		n=n-1
	end
	local n=n-1
	if n<0 then
		return false
	end
	local n=""if TppNetworkUtil.IsHost()==false then
		n="player_locator_clst"..(e.."_plnt0_df0")
		local e,n=Tpp.GetLocator("MtbsStartPointIdentifier",n)
		if e then
			TppPlayer.SetInitialPosition(e,n)
			return true
		end
		return false
	end
end
function this.IsNeedSetMissionStartPositionToClusterPosition()
	if gvars.forcePlayerPositionDemoCenter then
		gvars.forcePlayerPositionDemoCenter=false
		return true
	end
	if not TppLocation.IsMotherBase()then
		return false
	end
	if this.IsSysMissionId(vars.missionCode)then
		return false
	end
	if TppPackList.GetLocationNameFormMissionCode(vars.missionCode)=="MTBS"then
		return false
	else
		return true
	end
end
function this.ReserveForcePlayerPositionToMbDemoCenter()
	gvars.forcePlayerPositionDemoCenter=true
end
function this.SetMissionStartPositionMtbsClusterPosition()
	if mtbs_cluster==nil then
		return
	end
	local e=MotherBaseStage.GetFirstCluster()
	local n=mtbs_cluster.GetClusterName(MotherBaseStage.GetFirstCluster()+1)
	local e=MotherBaseStage.GetDemoCenter(e)
	local e=TppMath.Vector3toTable(e)
	TppPlayer.SetInitialPosition(e,0)
end
function this.EstablishedMissionClear()
	DemoDaemon.StopAll()
	GkEventTimerManager.StopAll()
	if Tpp.IsHorse(vars.playerVehicleGameObjectId)then
		GameObject.SendCommand(vars.playerVehicleGameObjectId,{id="HorseForceStop"})
	end
	this.SeizeReliefVehicleOnClear()
	vars.playerDisableActionFlag=PlayerDisableAction.SUBJECTIVE_CAMERA
	TppHero.SetFirstMissionClearHeroPoint()
	if this.systemCallbacks.OnSetMissionFinalScore then
		this.systemCallbacks.OnSetMissionFinalScore(svars.mis_missionClearType)
	end
	this.SetMissionClearState(TppDefine.MISSION_CLEAR_STATE.ESTABLISHED_CLEAR)
	if(svars.mis_missionClearType==TppDefine.MISSION_CLEAR_TYPE.RIDE_ON_FULTON_CONTAINER)then
		TppUI.FadeOut(TppUI.FADE_SPEED.FADE_NORMALSPEED,"EstablishedMissionClearOnRideOnFultonContainer",nil,{exceptGameStatus={AnnounceLog="SUSPEND_LOG"}})
	end
	this.systemCallbacks.OnEstablishMissionClear(svars.mis_missionClearType)
end
function this.OnMissionGameEndFadeOutFinish()
	--TUPPMLog.Log("TppMission.OnMissionGameEndFadeOutFinish START",1)
	local n=this.IsHelicopterSpace(gvars.mis_nextMissionCodeForMissionClear)
	if not n then
		this.ReserveMissionStartRecoverSoundDemo()
	else
		this.ClearMissionStartRecoverSoundDemo()
	end
	TppEnemy.FultonRecoverOnMissionGameEnd()
	TppPlayer.SaveCaptureAnimal()
	TppTerminal.AddVolunteerStaffs()
	if Player.CallRemovingChickenCapSE~=nil then
		Player.CallRemovingChickenCapSE()
	end
	if this.systemCallbacks.OnMissionGameEndFadeOutFinish then
		this.systemCallbacks.OnMissionGameEndFadeOutFinish()
	end
	if(mvars.mis_missionGameEndDelayTime>.1)then
		GkEventTimerManagerStart("Timer_MissionGameEndStart",mvars.mis_missionGameEndDelayTime)
	else
		GkEventTimerManagerStart("Timer_MissionGameEndStart",.1)
	end
	--TUPPMLog.Log("TppMission.OnMissionGameEndFadeOutFinish END",1)
end
function this.OnMissionGameEndFadeOutFinish2nd()
	--TUPPMLog.Log("TppMission.OnMissionGameEndFadeOutFinish2nd START",1)
	TppUiStatusManager.ClearStatus"GmpInfo"TppStory.UpdateStorySequence{updateTiming="OnMissionClear",missionId=this.GetMissionID()}
	TppResult.SetMissionFinalScore()
	this.KillDyingQuiet()
	TppTrophy.UnlockOnBuddyFriendlyMax()
	TppTrophy.UnlockOnAllMissionTaskCompleted()
	local a,r,o,n,i,s=TppStory.CheckAllMissionCleared()
	if a then
		TppStory.CompleteAllMissionCleared()
		TppTrophy.Unlock(12)
	end
	if r then
		TppStory.CompleteAllMissionSRankCleared()
		TppTrophy.Unlock(14)
	end
	if o then
		TppStory.CompleteAllNormalMissionCleared()
		TppEmblem.AcquireOnAllMissionCleared()
	end
	if n then
		TppStory.CompleteAllNormalMissionSRankCleared()
		TppEmblem.AcquireOnAllMissionSRankCleared()
	end
	if i then
		TppStory.CompleteAllHardMissionCleared()
	end
	if s then
		TppStory.CompleteAllHardMissionSRankCleared()
	end
	if vars.totalMarkingCount>=750 then
		TppTerminal.AcquireKeyItem{dataBaseId=TppMotherBaseManagementConst.DESIGN_3020,pushReward=true}
	end
	if TppBuddyService.CanSortieBuddyType(BuddyType.DOG)then
		TppTrophy.Unlock(24,1e3,-1e3)
	end
	if TppBuddyService.CanSortieBuddyType(BuddyType.QUIET)then
		TppTrophy.Unlock(25,1e3,-1e3)
	end
	if TppUiCommand.CheckMbTopMenuDHorseCustomizeOpen~=nil then
		if TppBuddyService.GetFriendlyPoint(BuddyFriendlyType.HORSE)>=100 then
			if TppUiCommand.CheckMbTopMenuDHorseCustomizeOpen()==false then
				TppUiCommand.SetMbTopMenuDHorseCustomizeOpen(true)
				this._PushReward(TppScriptVars.CATEGORY_MB_MANAGEMENT,"reward_403",TppReward.TYPE.COMMON)
			end
		end
		if TppBuddyService.GetFriendlyPoint(BuddyFriendlyType.DOG)>=100 then
			if TppUiCommand.CheckMbTopMenuDDogCustomizeOpen()==false then
				TppUiCommand.SetMbTopMenuDDogCustomizeOpen(true)
				this._PushReward(TppScriptVars.CATEGORY_MB_MANAGEMENT,"reward_404",TppReward.TYPE.COMMON)
			end
		end
	end
	TppQuest.OnMissionGameEnd()
	TppTerminal.OnEstablishMissionClear()
	TppTerminal.PushRewardOnMbSectionOpen()
	TppHero.UpdateHero()
	TppCassette.OnEstablishMissionClear()
	TppRanking.UpdateOpenRanking()
	local n=TppMotherBaseManagement.GetResourceUsableCount{resource="NuclearWaste"}
	TppRanking.UpdateScore("NuclearDisposeCount",n)
	TppRanking.SendCurrentRankingScore()do
		local n=this.GetMissionID()
		--rX42 Execute to shift revenge during free roam/ACC
		-- but being unseen leads to max camera revenge, plus middle levels of helmet and combat revenge
		if(not this.IsFOBMission(n)and not this.IsFreeMission(n))and not this.IsHelicopterSpace(n)then
			TppRevenge.ReduceRevengePointOnMissionClear(n)
		end
	end
	TppTutorial.OpenTipsOnCurrentStory()
	if gvars.usingNormalMissionSlot then
		TppStory.FailedRetakeThePlatformIfOpened()
	end
	local n=this.GetMissionClearType()
	if(n==TppDefine.MISSION_CLEAR_TYPE.FREE_PLAY_ORDER_BOX_DEMO)or(n==TppDefine.MISSION_CLEAR_TYPE.FREE_PLAY_NO_ORDER_BOX)then
		--r51 Settings
		if not TUPPMSettings.player_ENABLE_keepWeaponsBetweenFreeMissionTransitions then
			--r46 Carry weapons between (Free Roam-Missions-ACC) --Mission abort via menu resets weapons to those at the time of starting the mission from free roam
			--r46 Keep weapons between free roam->mission and mission->free roam allowing for better OSP runs
			TppUiCommand.LoadoutSetMissionRecieveFromFreeToMission()
		end
	end
	TppHero.AnnounceFirstMissionClearHeroPoint()
	TppPlayer.AggregateCaptureAnimal()
	if not this.IsHelicopterSpace(this.GetMissionID())then
		TppTerminal.AddStaffsFromTempBuffer()
	end
	this.ExecuteVehicleSaveCarryOnClear()
	this.ForceGoToMbFreeIfExistMbDemo()
	if not this.IsFOBMission(gvars.mis_nextMissionCodeForMissionClear)then
		TppSave.EraseAllGameDataSaveRequest()
		TppSave.VarSave()
	end
	GkEventTimerManagerStart("Timer_MissionGameEndStart2nd",.1)
	--TUPPMLog.Log("TppMission.OnMissionGameEndFadeOutFinish2nd END",1)
end
function this.SetMissionObjectives(i,n,e)
	mvars.mis_missionObjectiveDefine=i
	mvars.mis_missionObjectiveTree=n
	mvars.mis_missionObjectiveEnum=e
	if mvars.mis_missionObjectiveTree then
		for n,e in Tpp.BfsPairs(mvars.mis_missionObjectiveTree)do
			for e,i in pairs(e)do
				local e=mvars.mis_missionObjectiveDefine[e]
				if e then
					e.parent=e.parent or{}
					e.parent[n]=true
				end
			end
		end
	end
	if mvars.mis_missionObjectiveTree and mvars.mis_missionObjectiveEnum==nil then
		return
	end
	if#mvars.mis_missionObjectiveEnum>maxObjective then
		return
	end
end
function this.OnFinishUpdateObjectiveRadio(n)
	if n==StrCode32(mvars.mis_updateObjectiveRadioGroupName)then
		this.ShowUpdateObjective(mvars.mis_objectiveSetting)
	end
end
function this.ShowUpdateObjective(n)
	if not IsTypeTable(n)then
		return
	end
	local i={}
	for n,s in pairs(n)do
		local n=mvars.mis_missionObjectiveDefine[s]
		local t=not this.IsEnableMissionObjective(s)
		if t then
			t=(not this.IsEnableAnyParentMissionObjective(s))
		end
		if n.packLabel then
			if not TppPackList.IsMissionPackLabelList(n.packLabel)then
				t=false
			end
		end
		if n and t then
			this.DisableChildrenObjective(s)
			this._ShowObjective(n,true)
			local t={isMissionAnnounce=false,subGoalId=nil}
			if n.announceLog then
				t.isMissionAnnounce=true
				if n.subGoalId then
					t.subGoalId=n.subGoalId
				end
				i[n.announceLog]=t
			end
			this.SetMissionObjectiveEnable(s,true)
		end
	end
	if next(i)then
		for e=1,#TppUI.ANNOUNCE_LOG_PRIORITY do
			local n=TppUI.ANNOUNCE_LOG_PRIORITY[e]
			local e=i[n]
			if e then
				if e.isMissionAnnounce then
					TppUI.ShowAnnounceLog(n)
					if e.subGoalId and e.subGoalId>0 then
						TppUI.ShowAnnounceLog("subGoalContent",nil,nil,nil,e.subGoalId)
					end
				end
				i[n]=nil
			end
		end
		if next(i)then
			for e,n in pairs(i)do
				TppUI.ShowAnnounceLog(e)
			end
		end
		TppSoundDaemon.PostEvent"sfx_s_terminal_data_fix"end
	mvars.mis_objectiveSetting=nil
	mvars.mis_updateObjectiveRadioGroupName=nil
	mvars.mis_updateObjectiveOnHelicopterStart=nil
end
function this._ShowObjective(e,s)
	if e.packLabel then
		if not TppPackList.IsMissionPackLabelList(e.packLabel)then
			return
		end
	end
	if e.setInterrogation==nil then
		e.setInterrogation=true
	end
	if e.gameObjectName then
		TppMarker.Enable(e.gameObjectName,e.visibleArea,e.goalType,e.viewType,e.randomRange,e.setImportant,e.setNew,e.mapRadioName,e.langId,e.goalLangId,e.setInterrogation)
	end
	if e.gimmickId then
		local i,n=TppGimmick.GetGameObjectId(e.gimmickId)
		if i then
			TppMarker.Enable(n,e.visibleArea,e.goalType,e.viewType,e.randomRange,e.setImportant,e.setNew,e.mapRadioName,e.langId,e.goalLangId,e.setInterrogation)
		end
	end
	if e.photoId then
		TppUI.EnableMissionPhoto(e.photoId,e.addFirst,e.addSecond,e.isComplete,e.photoRadioName)
	end
	if e.hudPhotoId then
		TppUiCommand.ShowPictureInfoHud(e.hudPhotoId,1,3)
	end
	if e.subGoalId then
		TppUI.EnableMissionSubGoal(e.subGoalId)
		if e.subGoalId>0 then
			if not e.announceLog then
				e.announceLog="updateMissionInfo"end
		end
	end
	if e.showEnemyRoutePoints then
		if TppUiCommand.ShowEnemyRoutePoints then
			local n=e.showEnemyRoutePoints.radioGroupName
			if IsTypeString(n)then
				e.showEnemyRoutePoints.radioGroupName=StrCode32(n)
			end
			TppUiCommand.ShowEnemyRoutePoints(e.showEnemyRoutePoints)
		end
	end
	if e.targetBgmCp then
		TppEnemy.LetCpHasTarget(e.targetBgmCp,true)
	end
	if e.missionTask then
		TppUI.EnableMissionTask(e.missionTask,s)
	end
	if e.spySearch then
		TppUI.EnableSpySearch(e.spySearch)
	end
end
function this.RestoreShowMissionObjective()
	if not mvars.mis_missionObjectiveEnum then
		return
	end
	for n,i in ipairs(mvars.mis_missionObjectiveEnum)do
		if not svars.mis_objectiveEnable[n]then
			local n=mvars.mis_missionObjectiveDefine[i]
			if n then
				this.DisableObjective(n)
			end
		end
	end
	for n,i in ipairs(mvars.mis_missionObjectiveEnum)do
		if svars.mis_objectiveEnable[n]then
			local n=mvars.mis_missionObjectiveDefine[i]
			if n then
				this._ShowObjective(n,false)
			end
		end
	end
end
function this.SetMissionObjectiveEnable(e,n)
	if not mvars.mis_missionObjectiveEnum then
		return
	end
	local e=mvars.mis_missionObjectiveEnum[e]
	if not e then
		return
	end
	svars.mis_objectiveEnable[e]=n
end
function this.IsEnableMissionObjective(e)
	if not mvars.mis_missionObjectiveEnum then
		return
	end
	local e=mvars.mis_missionObjectiveEnum[e]
	if not e then
		return
	end
	return svars.mis_objectiveEnable[e]
end
function this.GetParentObjectiveName(e)
	local e=mvars.mis_missionObjectiveDefine[e]
	if not e then
		return
	end
	return e.parent
end
function this.IsEnableAnyParentMissionObjective(n)
	local n=mvars.mis_missionObjectiveDefine[n]
	if not n then
		return
	end
	if not n.parent then
		return false
	end
	local i
	for n,s in pairs(n.parent)do
		if this.IsEnableMissionObjective(n)then
			return true
		else
			i=this.IsEnableAnyParentMissionObjective(n)
			if i then
				return true
			end
		end
	end
	return false
end
function this.DisableChildrenObjective(s)
	local n
	for i,e in Tpp.BfsPairs(mvars.mis_missionObjectiveTree)do
		if i==s then
			n=e
			break
		end
	end
	if not n then
		return
	end
	for i,n in Tpp.BfsPairs(n)do
		local n=mvars.mis_missionObjectiveDefine[i]
		if n then
			this.SetMissionObjectiveEnable(i,false)
			this.DisableObjective(n)
		end
	end
end
function this.DisableObjective(e)
	if e.packLabel then
		if not TppPackList.IsMissionPackLabelList(e.packLabel)then
			return
		end
	end
	if e.gameObjectName then
		TppMarker.Disable(e.gameObjectName,e.mapRadioName)
	end
	if e.gimmickId then
		local n,i=TppGimmick.GetGameObjectId(e.gimmickId)
		if n then
			TppMarker.Disable(i,e.mapRadioName)
		end
	end
	if e.photoId then
		TppUI.DisableMissionPhoto(e.photoId,e.photoRadioName)
	end
	if e.showEnemyRoutePoints then
		local e=e.showEnemyRoutePoints.groupIndex
		if TppUiCommand.InitEnemyRoutePoints then
			TppUiCommand.InitEnemyRoutePoints(e)
		end
	end
	if e.targetBgmCp then
		TppEnemy.LetCpHasTarget(e.targetBgmCp,false)
	end
	if e.missionTask then
		TppUiCommand.DisableMissionTask(e.missionTask)
	end
	if e.spySearch then
		TppUI.DisableSpySearch(e.spySearch)
	end
end
function this.VarSaveOnUpdateCheckPoint(n)
	gvars.isNewGame=false
	TppTerminal.OnRecoverByHelicopterOnCheckPoint()
	TppTerminal.AddStaffsFromTempBuffer(true)
	TppSave.ReserveVarRestoreForContinue()
	if TppSystemUtility.GetCurrentGameMode()=="TPP"then
		TppEnemy.StoreSVars()
	end
	TppWeather.StoreToSVars()
	TppMarker.StoreMarkerLocator()
	TppPlayer.StoreSupplyCbox()
	TppPlayer.StoreSupportAttack()
	TppPlayer.StorePlayerDecoyInfos()
	if not Tpp.IsHelicopter(vars.playerVehicleGameObjectId)then
		svars.ply_isUsedPlayerInitialAction=true
	end
	TppRadioCommand.StoreRadioState()
	if Gimmick.StoreSaveDataPermanentGimmickFromCheckPoint then
		Gimmick.StoreSaveDataPermanentGimmickFromCheckPoint()
	end
	TppMotherBaseManagement.CheckMisogi()
	TppSave.VarSave(vars.missionCode)
	if vars.missionCode==10115 then
		return
	end
	if not n then
		TppSave.SaveGameData(nil,nil,nil,nil,true)
		this.CreateMbSaveCoroutine()
	end
end
function this.SafeStopSettingOnMissionReload(options)
	--TUPPMLog.Log("TppMission.SafeStopSettingOnMissionReload START",1)
	local setMute
	if options and options.setMute then
		setMute=options.setMute
	end
	mvars.mis_missionStateIsNotInGame=true
	gvars.canExceptionHandling=false
	SubtitlesCommand.SetIsEnabledUiPrioStrong(false)
	TppRadio.Stop()
	TppMusicManager.StopMusicPlayer(1)
	TppMusicManager.EndSceneMode()
	TppRadioCommand.SetEnableIgnoreGamePause(false)
	if TppBuddy2BlockController.Unload then
		TppBuddy2BlockController.Unload()
	end
	GkEventTimerManager.StopAll()
	if Tpp.IsHorse(vars.playerVehicleGameObjectId)then
		GameObject.SendCommand(vars.playerVehicleGameObjectId,{id="HorseForceStop"})
	end
	if setMute then
		TppSoundDaemon.SetMute(setMute)
	else
		TppSound.SetMuteOnLoading()
	end
	TppOutOfMissionRangeEffect.Disable(1)
	TppTerminal.PlayTerminalVoice("VOICE_WARN_MISSION_AREA",false)
	--TUPPMLog.Log("TppMission.SafeStopSettingOnMissionReload END",1)
end
function this.VarResetOnNewMission()
	TppScriptVars.InitForNewMission()
	TppCheckPoint.Reset()
	TppQuest.ResetQuestStatus()
	TppPackList.SetDefaultMissionPackLabelName()
	TppPlayer.UnsetRetryFlag()
	if GameConfig.GetStealthAssistEnabled()then
		mvars.mis_needSaveConfigOnNewMission=true
		GameConfig.SetStealthAssistEnabled(false)
	end
	TppPlayer.ResetStealthAssistCount()
	TppSave.ReserveVarRestoreForMissionStart()
	TppResult.ClearNewestPlayStyleHistory()
	this.SetNextMissionCodeForMissionClear(missionClearCodeNone)
	this.ResetMissionClearState()
end
function this.GetCurrentLocationHeliMissionAndLocationCode()
	if TppLocation.IsAfghan()then
		return TppDefine.SYS_MISSION_ID.AFGH_HELI,TppDefine.LOCATION_ID.AFGH
	elseif TppLocation.IsMiddleAfrica()then
		return TppDefine.SYS_MISSION_ID.MAFR_HELI,TppDefine.LOCATION_ID.MAFR
	elseif TppLocation.IsMotherBase()then
		return TppDefine.SYS_MISSION_ID.MTBS_HELI,TppDefine.LOCATION_ID.MTBS
	elseif TppLocation.IsMBQF()then
		return TppDefine.SYS_MISSION_ID.MTBS_HELI,TppDefine.LOCATION_ID.MTBS
	else
		return TppDefine.SYS_MISSION_ID.AFGH_HELI,TppDefine.LOCATION_ID.AFGH
	end
end
function this.ResetEmegerncyMissionSetting()
	gvars.usingNormalMissionSlot=true
	gvars.mis_nextMissionCodeForEmergency=0
	gvars.mis_nextLayoutCodeForEmergency=TppDefine.INVALID_LAYOUT_CODE
	gvars.mis_nextClusterIdForEmergency=TppDefine.INVALID_CLUSTER_ID
	gvars.mis_nextMissionStartRouteForEmergency=0
	vars.returnStaffHeader=0
	vars.returnStaffSeeds=0
end
function this.GoToEmergencyMission()
	local t=gvars.mis_nextMissionCodeForEmergency
	local s
	if t~=TppDefine.SYS_MISSION_ID.FOB then
		if gvars.mis_nextMissionStartRouteForEmergency~=0 then
			s=gvars.mis_nextMissionStartRouteForEmergency
		else
			return
		end
	end
	local n
	if gvars.mis_nextLayoutCodeForEmergency~=TppDefine.INVALID_LAYOUT_CODE then
		n=gvars.mis_nextLayoutCodeForEmergency
	else
		n=TppDefine.STORY_MISSION_LAYOUT_CODE[missionCode]or TppDefine.OFFLINE_MOHTER_BASE_LAYOUT_CODE
	end
	local i=2
	if gvars.mis_nextClusterIdForEmergency~=TppDefine.INVALID_CLUSTER_ID then
		i=gvars.mis_nextClusterIdForEmergency
	end
	this.ReserveMissionClear{missionClearType=TppDefine.MISSION_CLEAR_TYPE.FROM_HELISPACE,nextMissionId=t,nextHeliRoute=s,nextLayoutCode=n,nextClusterId=i}
end
function this.RequestLoad(nextMission,currentMission,options)
	--TUPPMLog.Log("TppMission.RequestLoad START returning func",1)
	if not mvars then
		return
	end
	if gvars.isLoadedInitMissionOnSignInUserChanged then
		return
	end
	TppMain.EnablePause()
	--rX36 No more hitting SPACE to Continue after loading
	--  n.waitOnLoadingTipsEnd=false
	mvars.mis_loadRequest={nextMission=nextMission,currentMission=currentMission,options=options}
	--TUPPMLog.Log("TppMission.RequestLoad END",1)
end
function this.LoadWithChunkCheck()
	--TUPPMLog.Log("TppMission.LoadWithChunkCheck START",1)
	local nextMission,currentMission,options=mvars.mis_loadRequest.nextMission,mvars.mis_loadRequest.currentMission,mvars.mis_loadRequest.options
	local i=Tpp.GetChunkIndex(vars.locationCode)
	if this.IsChunkLoading(i)then
		return
	end
	this.Load(nextMission,currentMission,options)
	mvars.mis_loadRequest=nil
	--TUPPMLog.Log("TppMission.LoadWithChunkCheck END",1)
end
function this.IsChunkLoading(e)
	if Chunk.GetChunkState(e)==Chunk.STATE_INSTALLED then
		if mvars.mis_isChunkLoading then
			Chunk.SetChunkInstallSpeed(Chunk.INSTALL_SPEED_NORMAL)
			mvars.mis_isChunkLoading=false
		end
		if TppUiCommand.IsShowPopup(TppDefine.ERROR_ID.NOW_INSTALLING)then
			TppUiCommand.ErasePopup()
		end
		return false
	end
	if not mvars.mis_isChunkLoading then
		Chunk.PrefetchChunk(e)Chunk.SetChunkInstallSpeed(Chunk.INSTALL_SPEED_FAST)
		mvars.mis_isChunkLoading=true
	end
	if SplashScreen.GetSplashScreenWithName"konamiLogo"then
		return true
	end
	if SplashScreen.GetSplashScreenWithName"kjpLogo"then
		return true
	end
	if SplashScreen.GetSplashScreenWithName"foxLogo"then
		return true
	end
	Tpp.ShowChunkInstallingPopup(e,false)
	return true
end
--rX46 Deminification
function this.Load(nextMissionCode,currentMissionCode,options)
	TUPPMLog.Log("TppMission.Load"
		.." currentMissionCode:"..tostring(currentMissionCode)
		.." nextMissionCode:"..tostring(nextMissionCode)
		.." options:"..tostring(InfInspect.Inspect(options))
		,1)
	local showLoadingTips
	if(options and options.showLoadingTips~=nil)then
		showLoadingTips=options.showLoadingTips
	else
		showLoadingTips=true
	end
	--TUPPMLog.Log("TppMission.Load showLoadingTips:"..tostring(showLoadingTips),1)

	if(options and options.waitOnLoadingTipsEnd~=nil)then
		gvars.waitLoadingTipsEnd=options.waitOnLoadingTipsEnd
	else
		gvars.waitLoadingTipsEnd=true
	end
	--TUPPMLog.Log("TppMission.Load gvars.waitLoadingTipsEnd:"..tostring(gvars.waitLoadingTipsEnd),1)

	--r51 Settings
	if TUPPMSettings.game_ENABLE_noWaitAfterLoadingScreen then
		--r36 No more hitting SPACE to Continue after loading
		gvars.waitLoadingTipsEnd=false
	end

	TppMain.EnablePause()
	TppMain.EnableBlackLoading(showLoadingTips)

	if not TppEnemy.IsLoadedDefaultSoldier2CommonPackage()then
		TppEnemy.UnloadSoldier2CommonBlock()
		--TUPPMLog.Log("TppMission.Load UnloadSoldier2CommonBlock completed",1)
	end

	--if options then
	--TUPPMLog.Log("TppMission.Load options.force:"..tostring(options.force),1)
	--else
	--TUPPMLog.Log("TppMission.Load NO OPTIONS options.force:"..tostring(false),1)
	--end

	if(currentMissionCode~=nextMissionCode)or(options and options.force)then
		--TUPPMLog.Log("Either new mission or forced option",1)
		--  	TUPPMLog.Log("TppMission.Load mission load forced",3)

		local nextLocName=TppPackList.GetLocationNameFormMissionCode(nextMissionCode)
		local currentLocName=TppPackList.GetLocationNameFormMissionCode(currentMissionCode)

		--TUPPMLog.Log("TppMission.Load nextLocName:"..tostring(nextLocName),1)
		--TUPPMLog.Log("TppMission.Load currentLocName:"..tostring(currentLocName),1)

		local forceLoadLocation
		if nextLocName=="MTBS"and currentLocName=="MTBS"then
			if nextMissionCode~=TppDefine.SYS_MISSION_ID.MTBS_HELI then
				if not(options and options.ignoreMtbsLoadLocationForce)then
					forceLoadLocation={force=true}
					--TUPPMLog.Log("TppMission.Load Set forceLoadLocation for MB",1)
				end
			end
		end
		if TppLocation.IsMotherBase()then
			--TUPPMLog.Log("TppMission.Load IsMotherBase should not be here for M0/M46",1)

			local isBaseParamsApplied=TppLocation.ApplyPlatformParamToMbStage(nextMissionCode,"MotherBase")
			local nextMbLayoutCode=TppDefine.STORY_MISSION_LAYOUT_CODE[nextMissionCode] --next cause let's say going from Zoo to MB
			if nextMbLayoutCode then
				if currentMissionCode==nil and nextMissionCode==30050 then
				else
					--TUPPMLog.Log("TppMission.Load NOT currentMissionCode==nil and nextMissionCode==30050 BEFORE"
					--.." vars.mbLayoutCode: "..tostring(vars.mbLayoutCode)
					--.." isBaseParamsApplied: "..tostring(isBaseParamsApplied)
					--.." nextMbLayoutCode: "..tostring(nextMbLayoutCode)
					--,1,true)
					vars.mbLayoutCode=TppLocation.ModifyMbsLayoutCode(nextMbLayoutCode)
					--TUPPMLog.Log("TppMission.Load NOT currentMissionCode==nil and nextMissionCode==30050 AFTER"
					--.." vars.mbLayoutCode: "..tostring(vars.mbLayoutCode)
					--.." isBaseParamsApplied: "..tostring(isBaseParamsApplied)
					--.." nextMbLayoutCode: "..tostring(nextMbLayoutCode)
					--,1,true)
				end
			else
				if isBaseParamsApplied then
					--rX55 Before and after is same here - change happens elsewhere
					--TUPPMLog.Log("TppMission.Load isBaseParamsApplied BEFORE vars.mbLayoutCode: "..tostring(vars.mbLayoutCode),3,true)
					vars.mbLayoutCode=TppLocation.ModifyMbsLayoutCode(TppMotherBaseManagement.GetMbsTopologyType())
					--TUPPMLog.Log("TppMission.Load isBaseParamsApplied AFTER vars.mbLayoutCode: "..tostring(vars.mbLayoutCode),3,true)
				end
			end
		end
		if TppSystemUtility.GetCurrentGameMode()=="TPP"then
			--TUPPMLog.Log("TppMission.Load TppSystemUtility.GetCurrentGameMode() is indeed TPP",1)
			TppEneFova.InitializeUniqueSetting()
			TppEnemy.PreMissionLoad(nextMissionCode,currentMissionCode)
			--TUPPMLog.Log("TppMission.Load finished TppEneFova.InitializeUniqueSetting & TppEnemy.PreMissionLoad",1)
		end
		Mission.LoadLocation(forceLoadLocation)
		Mission.LoadMission(options)
		--TUPPMLog.Log("TppMission.Load finished Mission.LoadLocation & Mission.LoadMission --exe classes",1)
	else
		TUPPMLog.Log("TppMission.Load mission load not forced",3)

		--r51 Settings
		if TUPPMSettings.mtbs_ENABLE_outfitRandomizationOnCheckpointReload and (nextMissionCode==30050 or nextMissionCode==30250) then
			--r46 Yup works, DD outfits randomized on loading a checkpoint as well now
			--Yes sure not realistic but
			--POSSIBLE ISSUES! with cutscenes n shit
			--come back later and rever if issues seen
			TUPPMLog.Log("Forcing TppEneFova.PreMissionLoad with MB/MBQF checkpoint reload in order to reload DD outfit data",3)
			TppEneFova.PreMissionLoad(nextMissionCode,currentMissionCode) --r46 DD outfits reloaded for MB/MBQF

			--rX46 only want to reload loc so BB posters reload as well
			--EnableBiggBossPosters is called on checkpoint reload, however, the assets are loaded by LoadLocation
			--If shown or hidden, they remain the same way
			--LOL everything above proven wrong, not needed - trouble is once shown posters stay visible
			--Simple disable first in f30050_sequence.EnableBiggBossPosters
			--POSSIBLE ISSUES! with cutscenes n shit
			--come back later and rever if issues seen
			Mission.LoadLocation({force=true}) --TODO r46 required in order to load face fovas correctly for MBQF, otherwise some faces end up replaced by gas masks --try to use MB approach

			--rX46 can be called with nil options
			--  		Mission.LoadMission() --Don't know exactly what this does, leave it alone
		end

		Mission.RequestToReload()
		--TUPPMLog.Log("TppMission.Load finished non forced Mission.RequestToReload --exe classes",1)
	end
	TppUI.ShowAccessIcon()
	--TUPPMLog.Log("TppMission.Load END",1)
end
function this.ExecuteReload()
	--TUPPMLog.Log("TppMission.ExecuteReload START",1)
	if mvars.mis_nextLocationCode then
		vars.locationCode=mvars.mis_nextLocationCode
	end
	if mvars.mis_nextLayoutCode then
		--TUPPMLog.Log("TppMission.ExecuteReload mvars.mis_nextLayoutCode BEFORE vars.mbLayoutCode: "..tostring(vars.mbLayoutCode),3,true)
		vars.mbLayoutCode=TppLocation.ModifyMbsLayoutCode(mvars.mis_nextLayoutCode)
		--TUPPMLog.Log("TppMission.ExecuteReload mvars.mis_nextLayoutCode AFTER vars.mbLayoutCode: "..tostring(vars.mbLayoutCode),3,true)
	end
	if mvars.mis_nextClusterId then
		vars.mbClusterId=mvars.mis_nextClusterId
	end
	this.SafeStopSettingOnMissionReload()
	TppPackList.SetMissionPackLabelName(mvars.mis_missionPackLabelName)
	TppPlayer.ForceSetAllInitialWeapon()
	TppSave.VarSave()
	TppSave.CheckAndSavePersonalData()
	this.RequestLoad(vars.missionCode,nil,{force=true,showLoadingTips=mvars.mis_showLoadingTipsOnReload,ignoreMtbsLoadLocationForce=mvars.mis_ignoreMtbsLoadLocationForce})
	--TUPPMLog.Log("TppMission.ExecuteReload END",1)
end
function this.CanStart()
	if mvars.mis_alwaysMissionCanStart then
		return true
	else
		return Mission.CanStart()
	end
end
function this.SetNextMissionCodeForMissionClear(e)
	gvars.mis_nextMissionCodeForMissionClear=e
end
function this.GetNextMissionCodeForMissionClear()
	return gvars.mis_nextMissionCodeForMissionClear
end
function this.AlwaysMissionCanStart()
	mvars.mis_alwaysMissionCanStart=true
end
function this.KillDyingQuiet()
	if TppBuddyService.BuddyProcessMissionEnd then
		TppBuddyService.BuddyProcessMissionEnd()
	else
		if TppBuddyService.IsQuietDeadFromDying and TppBuddyService.IsQuietDeadFromDying()then
			TppBuddyService.QuietDyingToDead()
		end
	end
end
function this.SetSortieBuddy()
	if TppDemo.IsPlayedMBEventDemo"DdogGoWithMe"then
		TppBuddyService.SetSortieBuddyType(BuddyType.DOG)
	end
	if TppBuddyService.CheckBuddyCommonFlag(BuddyCommonFlag.BUDDY_QUIET_LOST)then
	else
		if TppQuest.IsCleard"mtbs_q99011"then
			if TppBuddyService.DidObtainBuddyType(BuddyType.QUIET)then
				if not TppBuddyService.CanSortieBuddyType(BuddyType.QUIET)then
					TppStory.StartElapsedMissionEvent(TppDefine.ELAPSED_MISSION_EVENT.QUIET_WITH_GO_MISSION,TppDefine.INIT_ELAPSED_MISSION_COUNT.QUIET_WITH_GO_MISSION)
				end
				TppBuddyService.SetSortieBuddyType(BuddyType.QUIET)
			end
		end
	end
end
function this.ResetQuietEquipIfUndevelop()
	if vars.buddyQuietEquipType==4 then
		if not TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=6094}then
			TppBuddyService.SetVarsQuietWeaponType(0)
		end
	end
end
local n={[30050]=true,[50050]=true}
local i={[TppDefine.MISSION_CLEAR_TYPE.ON_FOOT]=true,[TppDefine.MISSION_CLEAR_TYPE.RIDE_ON_HELICOPTER]=true,[TppDefine.MISSION_CLEAR_TYPE.RIDE_ON_VEHILCE]=true,[TppDefine.MISSION_CLEAR_TYPE.RIDE_ON_FULTON_CONTAINER]=true}
function this.ForceGoToMbFreeIfExistMbDemo()
	if n[vars.missionCode]then
		return
	end
	local n=this.GetMissionClearType()
	if not i[n]then
		return
	end
	local n=TppStory.GetForceMBDemoNameOrRadioList"forceMBDemo"if n then
		TppDemo.SetNextMBDemo(n)
		if TppDefine.MB_FREEPLAY_RIDEONHELI_DEMO_DEFINE[n]~=nil then
			this.SetNextMissionStartHeliRoute"ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr"end
		this.SetNextMissionCodeForMissionClear(TppDefine.SYS_MISSION_ID.MTBS_FREE)
		this.SeizeReliefVehicleOnForceGoToMb()
	end
	local n=TppStory.GetForceMBDemoNameOrRadioList("blackTelephone",{demoName=n})
	if n then
		TppRadio.SaveRewardEndRadioList(n)
		if n[1]=="f6000_rtrg0310"then
			this.SetNextMissionCodeForMissionClear(TppDefine.SYS_MISSION_ID.MAFR_HELI)
		else
			this.SetNextMissionCodeForMissionClear(TppDefine.SYS_MISSION_ID.MTBS_FREE)
		end
	end
end
function this.ResetMBFreeStartPositionToCommand()
	TppHelicopter.ResetMissionStartHelicopterRoute()
	TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
	TppPlayer.ResetInitialPosition()
	TppPlayer.ResetMissionStartPosition()
	TppPlayer.ResetNoOrderBoxMissionStartPosition()
	this.ResetIsStartFromHelispace()
	this.ResetIsStartFromFreePlay()
	vars.mbClusterId=TppDefine.CLUSTER_DEFINE.Command
end
function this.SetNextMissionStartHeliRoute(e)
	mvars.heli_missionStartRoute=e
end
function this.ClearFobMode()
	vars.fobSneakMode=FobMode.MODE_NONE
	vars.fobIsPlaceMode=0
end
function this.UnsetFobSneakFlag(mis_nextMissionCodeForMissionClear)
	--TUPPMLog.Log("TppMission.UnsetFobSneakFlag START",1)
	if not this.IsFOBMission(mis_nextMissionCodeForMissionClear)then
		if TppServerManager.FobIsSneak()then
			vars.fobIsSneak=0
		end
	end
	--TUPPMLog.Log("TppMission.UnsetFobSneakFlag END",1)
end
function this.StartHelicopterDoorOpenTimer()
	local e=mvars.mis_helicopterDoorOpenTimerTimeSec
	GameObject.SendCommand({type="TppHeli2",index=0},{id="SetSendDoorOpenManually",enabled=true})GkEventTimerManagerStart("Timer_MissionStartHeliDoorOpen",e)
end
function this.GetObjectiveRadioOption(n)
	local e={}
	if IsTypeTable(n.radioOptions)then
		for i,n in pairs(n.radioOptions)do
			e[i]=n
		end
	end
	if FadeFunction.IsFadeProcessing()then
		local n=e.delayTime
		local i=TppUI.FADE_SPEED.FADE_NORMALSPEED+1.2
		if IsTypeString(n)then
			e.delayTime=TppRadio.PRESET_DELAY_TIME[n]+i
		elseif IsTypeNumber(n)then
			e.delayTime=n+i
		else
			e.delayTime=i
		end
	end
	return e
end
function this.OnMissionStart()
	if this.IsMissionStart()then
		gvars.mis_quietCallCountOnMissionStart=vars.buddyCallCount[BuddyType.QUIET]
		if vars.buddyType==BuddyType.QUIET then
			gvars.mis_quietCallCountOnMissionStart=gvars.mis_quietCallCountOnMissionStart-1
		end
	end
end
function this.SetPlayRecordClearInfo()
	local n,e=TppStory.CalcAllMissionClearedCount()
	TppUiCommand.SetPlayRecordClearInfo{recordId="MissionClear",clearCount=n,allCount=e}
	local n,e=TppStory.CalcAllMissionTaskCompletedCount()
	TppUiCommand.SetPlayRecordClearInfo{recordId="MissionTaskClear",clearCount=n,allCount=e}
	local e,n=TppQuest.CalcQuestClearedCount()
	TppUiCommand.SetPlayRecordClearInfo{recordId="SideOpsClear",clearCount=e,allCount=n}
end
function this.IsBossBattle()
	if not mvars.mis_isBossBattle then
		return false
	end
	return true
end
function this.StartBossBattle()
	mvars.mis_isBossBattle=true
end
function this.FinishBossBattle()
	mvars.mis_isBossBattle=false
end
function this.ShowAnnounceLogOnGameStart()
	local n,e=this.ParseMissionName(this.GetMissionName())
	if(e=="free"or e=="heli")then
		if gvars.mis_isExistOpenMissionFlag then
			TppUI.ShowAnnounceLog"missionListUpdate"TppUI.ShowAnnounceLog"missionAdd"gvars.mis_isExistOpenMissionFlag=false
		end
		TppQuest.ShowAnnounceLogQuestOpen()
	end
end
function this.SetHeroicAndOgrePointInSlot(e,n)
	TppScriptVars.SetVarValueInSlot(TppDefine.SAVE_SLOT.MISSION_START,"vars","missionHeroicPoint",e)
	TppScriptVars.SetVarValueInSlot(TppDefine.SAVE_SLOT.CHECK_POINT_RESTARTABLE,"vars","missionHeroicPoint",e)
	TppScriptVars.SetVarValueInSlot(TppDefine.SAVE_SLOT.MISSION_START,"vars","missionOgrePoint",n)
	TppScriptVars.SetVarValueInSlot(TppDefine.SAVE_SLOT.CHECK_POINT_RESTARTABLE,"vars","missionOgrePoint",n)
end
function this._CreateMissionName(i)
	local n=string.sub(tostring(i),1,1)
	local e
	if(n=="1")then
		e="s"elseif(n=="2")then
		e="e"elseif(n=="3")then
		e="f"elseif(n=="4")then
		e="h"elseif(n=="5")then
		e="o"else
		return nil
	end
	return e..tostring(i)
end
function this._PushReward(e,i,n)
	TppReward.Push{category=e,langId=i,rewardType=n}
end
return this
