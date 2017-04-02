local this={}
local StrCode32=Fox.StrCode32
local IsTypeFunc=Tpp.IsTypeFunc
local IsTypeTable=Tpp.IsTypeTable
local FindDemoBody=DemoDaemon.FindDemoBody
local IsDemoPlaying=DemoDaemon.IsDemoPlaying
local IsPlayingDemoId=DemoDaemon.IsPlayingDemoId
local IsDemoPaused=DemoDaemon.IsDemoPaused
local GetPlayingDemoId=DemoDaemon.GetPlayingDemoId
local fiveDaysInSeconds=((5*24)*60)*60
this.MOVET_TO_POSITION_RESULT={[StrCode32"success"]="success",[StrCode32"failure"]="failure",[StrCode32"timeout"]="timeout"}
this.messageExecTable={}
function this.Messages()
	return Tpp.StrCode32Table{
		Player={
			{msg="DemoSkipped",
				func=this.OnDemoSkipAndBlockLoadEnd,
				option={isExecDemoPlaying=true,isExecMissionClear=true,isExecGameOver=true}},
			{msg="DemoSkipStart",
				func=this.EnableWaitBlockLoadOnDemoSkip,
				option={isExecDemoPlaying=true,isExecMissionClear=true,isExecGameOver=true}},
			{msg="FinishInterpCameraToDemo",
				func=this.OnEndGameCameraInterp,
				option={isExecMissionClear=true,isExecGameOver=true}},
			{msg="FinishMovingToPosition",
				sender="DemoStartMoveToPosition",
				func=function(a,n)
					local e=this.MOVET_TO_POSITION_RESULT[n]
					mvars.dem_waitingMoveToPosition=nil
				end,
				option={isExecMissionClear=true,isExecGameOver=true}}
		},
		Demo={
			{msg="PlayInit",
				func=this._OnDemoInit,
				option={isExecMissionClear=true,isExecDemoPlaying=true,isExecGameOver=true}},
			{msg="Play",
				func=this._OnDemoPlay,
				option={isExecMissionClear=true,isExecDemoPlaying=true,isExecGameOver=true}},
			{msg="Finish",
				func=this._OnDemoEnd,
				option={isExecMissionClear=true,isExecDemoPlaying=true,isExecGameOver=true}},
			{msg="Interrupt",
				func=this._OnDemoInterrupt,
				option={isExecMissionClear=true,isExecDemoPlaying=true}},
			{msg="Skip",
				func=this._OnDemoSkip,
				option={isExecMissionClear=true,isExecDemoPlaying=true}},
			{msg="Disable",
				func=this._OnDemoDisable},
			{msg="StartMissionTelop",
				func=function()
					if mvars.dm_doneStartMissionTelop then
						return
					end
					local e=TppMission.GetNextMissionCodeForMissionClear()
					TppUI.StartMissionTelop(e)
					mvars.dm_doneStartMissionTelop=true
				end,
				option={isExecDemoPlaying=true,isExecMissionClear=true}},
			{msg="StartCastTelopLeft",
				func=function()
					TppTelop.StartCastTelop"LEFT_START"
				end,
				option={isExecDemoPlaying=true,isExecMissionClear=true}},
			{msg="StartCastTelopRight",
				func=function()
					TppTelop.StartCastTelop"RIGHT_START"
				end,
				option={isExecDemoPlaying=true,isExecMissionClear=true}},
			nil
		},
		UI={
			{msg="EndFadeOut",
				sender="DemoPlayFadeIn",
				func=function(n,e)
					local e=mvars.dem_invScdDemolist[e]
				end,
				option={isExecMissionClear=true,isExecDemoPlaying=true,isExecGameOver=true}},
			{msg="DemoPauseSkip",
				func=this.FadeOutOnSkip,
				option={isExecMissionClear=true,isExecDemoPlaying=true,isExecGameOver=true}}
		},
		Timer={
			{msg="Finish",
				sender="p31_080110_000_showLocationTelop",
				func=function()
					TppUiCommand.RegistInfoTypingText("location",1)
					TppUiCommand.RegistInfoTypingText("cpname",2,"platform_isolation")
					TppUiCommand.RegistInfoTypingText("disptime",2)
					TppUiCommand.ShowInfoTypingText()
				end,
				option={isExecDemoPlaying=true}}
		}
	}
end
this.PLAY_REQUEST_START_FUNC={
	missionStateCheck=function(demoId,options)
		local n=options.isExecMissionClear
		local a=options.isExecGameOver
		local e=options.isExecDemoPlaying
		if not TppMission.CheckMissionState(n,a,e,false)then
			return false
		end
		return true
	end,
	gameCameraInterpedToDemo=function(demoId)
		if not FindDemoBody(demoId)then
			return
		end
		if mvars.dem_gameCameraInterpWaitingDemoName~=nil then
			return false
		end
		mvars.dem_gameCameraInterpWaitingDemoName=demoId
		Player.RequestToInterpCameraToDemo(demoId,1,2,Vector3(.4,.6,-1),true)
		return true
	end,
	playerModelReloaded=function(demoId)
		if mvars.dem_tempPlayerInfo~=nil then
			return false
		end
		TppUI.FadeOut(TppUI.FADE_SPEED.FADE_MOMENT)
		mvars.dem_tempPlayerInfo={}
		mvars.dem_tempPlayerInfo.playerType=vars.playerType
		mvars.dem_tempPlayerInfo.playerPartsType=vars.playerPartsType
		mvars.dem_tempPlayerInfo.playerCamoType=vars.playerCamoType
		mvars.dem_tempPlayerInfo.playerFaceId=vars.playerFaceId
		mvars.dem_tempPlayerInfo.playerFaceEquipId=vars.playerFaceEquipId
		mvars.dem_tempPlayerSuitLevel=Player.GetItemLevel(TppEquip.EQP_SUIT)
		TppPlayer.ForceChangePlayerToSnake(true)
		mvars.dem_tempPlayerReloadCounter={}
		mvars.dem_tempPlayerReloadCounter.start=0
		mvars.dem_tempPlayerReloadCounter.finish=0
		return true
	end,
	demoBlockLoaded=function(demoId)
		TppScriptBlock.RequestActivate"demo_block"
		return true
	end,
	playerActionAllowed=function(demoId)
		return true
	end,
	playerMoveToPosition=function(demoId,options)
		if mvars.dem_waitingMoveToPosition then
			return false
		end
		local e=options.playerMoveToPosition
		if not e.position then
			return false
		end
		if not e.direction then
			return false
		end
		Player.RequestToSetTargetStance(PlayerStance.STAND)
		Player.RequestToMoveToPosition{name="DemoStartMoveToPosition",position=e.position,direction=e.direction,onlyInterpPosition=true,timeout=10}
		mvars.dem_waitingMoveToPosition=true
		return true
	end,
	waitTextureLoadOnDemoPlay=function(demoId)
		mvars.dem_setTempCamera=false
		mvars.dem_textureLoadWaitOnDemoPlayEndTime=nil
		return true
	end
}
this.PLAY_REQUEST_START_CHECK_FUNC={missionStateCheck=function(e)
	return true
end,gameCameraInterpedToDemo=function(e)
	if mvars.dem_gameCameraInterpWaitingDemoName then
		return false
	else
		return true
	end
end,demoBlockLoaded=function(e)
	local e=FindDemoBody(e)
	if not e then
		TppUI.ShowAccessIconContinue()
	end
	return e
end,playerModelReloaded=function(e)
	if mvars.dem_tempPlayerReloadCounter==nil then
		return false
	end
	if mvars.dem_tempPlayerReloadCounter.start<10 then
		mvars.dem_tempPlayerReloadCounter.start=mvars.dem_tempPlayerReloadCounter.start+1
		return false
	end
	if PlayerInfo.OrCheckStatus{PlayerStatus.PARTS_ACTIVE}then
		return true
	else
		return false
	end
end,playerActionAllowed=function(e)
	local e=Player.CanPlayDemo(0)
	if e==false then
	end
	return e
end,playerMoveToPosition=function(e)
	if mvars.dem_waitingMoveToPosition then
		return false
	else
		return true
	end
end,waitTextureLoadOnDemoPlay=function(e)
	local n=FindDemoBody(e)
	if not n then
		TppUI.ShowAccessIconContinue()
		return false
	end
	if not mvars.dem_setTempCamera then
		mvars.dem_setTempCamera=true
		Demo.EnableTempCamera(e)
	end
	if not mvars.dem_textureLoadWaitOnDemoPlayEndTime then
		mvars.dem_textureLoadWaitOnDemoPlayEndTime=Time.GetRawElapsedTimeSinceStartUp()+10
	end
	local e=mvars.dem_textureLoadWaitOnDemoPlayEndTime-Time.GetRawElapsedTimeSinceStartUp()
	local n=Mission.GetTextureLoadedRate()
	if(e<=0)then
		return true
	else
		TppUI.ShowAccessIconContinue()
		return false
	end
end}
this.FINISH_WAIT_START_FUNC={waitBlockLoadEndOnDemoSkip=function(e)
	mvars.dem_enableWaitBlockLoadOnDemoSkip=true
	TppGameStatus.Set("TppDemo.OnDemoSkip","S_IS_BLACK_LOADING")
	return true
end,waitTextureLoadOnDemoEnd=function(e)
	return true
end,playerModelReloaded=function(e)
	if mvars.dem_tempPlayerInfo==nil then
		return
	end
	if mvars.dem_donePlayerRestoreFadeOut==nil then
		mvars.dem_donePlayerRestoreFadeOut=true
		TppUI.FadeOut(TppUI.FADE_SPEED.FADE_MOMENT)
	end
	for e,n in pairs(mvars.dem_tempPlayerInfo)do
		vars[e]=n
	end
	if mvars.dem_tempPlayerSuitLevel then
		Player.SetItemLevel(TppEquip.EQP_SUIT,mvars.dem_tempPlayerSuitLevel)
		mvars.dem_tempPlayerSuitLevel=nil
	end
	mvars.dem_tempPlayerInfo=nil
	return true
end}
this.FINISH_WAIT_CHECK_FUNC={waitBlockLoadEndOnDemoSkip=function(e)
	if mvars.dem_enableWaitBlockLoadOnDemoSkip then
		TppUI.ShowAccessIconContinue()
		return false
	else
		TppGameStatus.Reset("TppDemo.OnDemoSkip","S_IS_BLACK_LOADING")
		return true
	end
end,waitTextureLoadOnDemoEnd=function(e)
	if mvars.dem_enableWaitBlockLoadOnDemoSkip then
		return false
	end
	if not mvars.dem_textureLoadWaitEndTime then
		mvars.dem_textureLoadWaitEndTime=Time.GetRawElapsedTimeSinceStartUp()+30
	end
	local n=mvars.dem_textureLoadWaitEndTime-Time.GetRawElapsedTimeSinceStartUp()
	local e=Mission.GetTextureLoadedRate()
	if(e>.35)or(n<=0)then
		return true
	else
		TppUI.ShowAccessIconContinue()
		return false
	end
end,playerModelReloaded=function(e)
	if mvars.dem_donePlayerRestoreFadeOut then
		mvars.dem_donePlayerRestoreFadeOut=nil
		return false
	end
	if mvars.dem_tempPlayerReloadCounter==nil then
		return false
	end
	if mvars.dem_tempPlayerReloadCounter.finish<10 then
		mvars.dem_tempPlayerReloadCounter.finish=mvars.dem_tempPlayerReloadCounter.finish+1
		return false
	end
	if PlayerInfo.OrCheckStatus{PlayerStatus.PARTS_ACTIVE}then
		return true
	else
		return false
	end
end}
function this.Play(demoName,functionTable,options)
	--	TUPPMLog.Log("TppDemo.Play START demoName:"..tostring(demoName),1)
	
--	if TUPPMSettings.game_ENABLE_hideCredits then
--		TUPPMLog.Log("TppDemo.Play stopping teleop cast",3,true)
--		TppUiCommand.AllResetTelopCast()
----		TppUiCommand.EraseTelopCast()
----		TppUiCommand.StopTelopCast()
--	end
	
--	TUPPMLog.Log("TppDemo.Play - mvars.tlp_mainCharacters:"..tostring(InfInspect.Inspect(mvars.tlp_mainCharacters)),3,true)
--	TUPPMLog.Log("TppDemo.Play - mvars.tlp_guestCharacters:"..tostring(InfInspect.Inspect(mvars.tlp_guestCharacters)),3,true)
--	TUPPMLog.Log("TppDemo.Play - mvars.tlp_enemyCombatants:"..tostring(InfInspect.Inspect(mvars.tlp_enemyCombatants)),3,true)
--	TUPPMLog.Log("TppDemo.Play - mvars.tlp_specialMechanics:"..tostring(InfInspect.Inspect(mvars.tlp_specialMechanics)),3,true)
--	TUPPMLog.Log("TppDemo.Play - mvars.tlp_levelDesigners:"..tostring(InfInspect.Inspect(mvars.tlp_levelDesigners)),3,true)
--	TUPPMLog.Log("TppDemo.Play - mvars.tlp_writers:"..tostring(InfInspect.Inspect(mvars.tlp_writers)),3,true)
	
	local demoId=mvars.dem_demoList[demoName]
	if(demoId==nil)then
		return
	end
	mvars.dem_enableWaitBlockLoadOnDemoSkip=false
	mvars.dem_demoFuncs[demoName]=functionTable
	options=options or{}
	if options.isInGame then
		if options.waitBlockLoadEndOnDemoSkip==nil then
			options.waitBlockLoadEndOnDemoSkip=false
		end
	else
		if options.isSnakeOnly==nil then
			options.isSnakeOnly=true
		end
		if options.waitBlockLoadEndOnDemoSkip==nil then
			options.waitBlockLoadEndOnDemoSkip=true
		end
	end
	if demoId=="p31_040010_000_final"then
		options.waitBlockLoadEndOnDemoSkip=false
		mvars.dem_resereveEnableInGameFlag=false
	end
	if(demoId=="p51_070020_000_final")or(demoId=="p21_020010")then
		mvars.dem_resereveEnableInGameFlag=false
	end
	mvars.dem_demoFlags[demoName]=options
	return this.AddPlayReqeustInfo(demoId,options)
end
function this.EnableGameStatus(t,e)
	local e=e or{}
	local n=TppUI.GetOverrideGameStatus()
	if n then
		for a,n in pairs(n)do
			e[a]=n
		end
	end
	Tpp.SetGameStatus{target=t,except=e,enable=true,scriptName="TppDemo.lua"}
end
function this.DisableGameStatusOnPlayRequest(isInGame)
	--	TUPPMLog.Log("TppDemo.DisableGameStatusOnPlayRequest START",1)
	if not isInGame then
		Tpp.SetGameStatus{target="all",enable=false,except={S_DISABLE_NPC=false},scriptName="TppDemo.lua"}
	end
	--	TUPPMLog.Log("TppDemo.DisableGameStatusOnPlayRequest END",1)
end
function this.DisableGameStatusOnPlayStart()
	if this.IsNotPlayable()then
		HighSpeedCamera.RequestToCancel()
		Tpp.SetGameStatus{target="all",enable=false,scriptName="TppDemo.lua"}
	end
end
function this.OnEndGameCameraInterp()
	if mvars.dem_gameCameraInterpWaitingDemoName==nil then
	end
	mvars.dem_gameCameraInterpWaitingDemoName=nil
end
function this.PlayOnDemoBlock()
	this.ProcessPlayRequest(mvars.demo_playRequestInfo.demoBlock)
end
function this.FinalizeOnDemoBlock()
	if IsDemoPlaying()then
		DemoDaemon.SkipAll()
	end
end
function this.SetDemoTransform(n,e)
	local t=mvars.dem_demoList[n]
	if(t==nil)then
		return
	end
	if(IsTypeTable(e)==false)then
		return
	end
	local n
	local a
	if(e.usePlayer==true)then
		n=Vector3(vars.playerPosX,vars.playerPosY,vars.playerPosZ)a=Quat.RotationY(TppMath.DegreeToRadian(vars.playerRotY))
	elseif(e.identifier and e.locatorName)then
		n,a=Tpp.GetLocatorByTransform(e.identifier,e.locatorName)
	else
		return
	end
	if n==nil then
		return
	end
	DemoDaemon.SetDemoTransform(t,a,n)
end
function this.GetDemoStartPlayerPosition(e)
	local e=mvars.dem_demoList[e]
	if(e==nil)then
		return
	end
	local n,a,e=DemoDaemon.GetStartPosition(e,"Player")
	if not n then
		return
	end
	local e=Tpp.GetRotationY(e)
	local e={position=a,direction=e}
	return e
end
function this.PlayOpening(m,n)
	local l=n or{}l.isSnakeOnly=false
	local d="_openingDemo"local n="p31_020000"local a={"p31_020000","p31_020001","p31_020002"}
	local t=math.random(#a)n=a[t]
	this.AddDemo(d,n)
	local o,r
	local t,a
	local u=Vector3(vars.playerPosX,vars.playerPosY,vars.playerPosZ)
	local s=Vector3(0,0,1.98)
	local i=Quat.RotationY(TppMath.DegreeToRadian(vars.playerRotY))
	if gvars.mis_orderBoxName~=0 and mvars.mis_orderBoxList~=nil then
		local e=TppMission.FindOrderBoxName(gvars.mis_orderBoxName)
		if e~=nil then
			t,a=TppMission.GetOrderBoxLocatorByTransform(e)
		end
	end
	if t then
		local e=-a:Rotate(s)o=e+t
		r=a
	else
		local e=-i:Rotate(s)o=e+u
		r=i
	end
	TppMusicManager.StopMusicPlayer(1)DemoDaemon.SetDemoTransform(n,r,o)
	this.Play(d,m,l)
end
function this.PlayGetIntelDemo(l,d,i,n,t)
	local o=n or{}o.isSnakeOnly=false
	local n,a
	if t then
		n,a="p31_010026","p31_010026_001"else
		n,a="p31_010025","p31_010025_001"end
	local t="_getInteldemo"local r="_getInteldemo02"this.AddDemo(t,n)
	this.AddDemo(r,a)
	local a,r=Tpp.GetLocatorByTransform(d,i)
	local i=Tpp.GetRotationY(r)Player.RequestToSetTargetStance(PlayerStance.STAND)
	if a~=nil then
		DemoDaemon.SetDemoTransform(n,r,a)
		this.Play(t,l,o)
		TppUI.ShowAnnounceLog"getIntel"end
end
function this.IsNotPlayable()
	if IsDemoPlaying()or IsDemoPaused()then
		local e=GetPlayingDemoId()
		for n,e in ipairs(e)do
			local e=mvars.dem_invDemoList[e]
			if e then
				local e=mvars.dem_demoFlags[e]or{}
				if not e.isInGame then
					return true
				end
			end
		end
		return false
	else
		return false
	end
end
function this.ReserveEnableInGameFlag()
	mvars.dem_resereveEnableInGameFlag=true
end
function this.EnableInGameFlagIfResereved()
	if mvars.dem_resereveEnableInGameFlag then
		mvars.dem_resereveEnableInGameFlag=false
		TppMission.EnableInGameFlag()
	end
end
function this.ReserveInTheBackGround(n)
	if not IsTypeTable(n)then
		return
	end
	local a=n.demoName
	local a=mvars.dem_demoList[a]
	if not a then
		return
	end
	mvars.dem_reservedDemoId=a
	mvars.dem_reservedDemoLoadPosition=n.position
	local a=true
	if n.playerPause then
		a=n.playerPause
	end
	if a then
		mvars.dem_reservedPlayerWarpAndPause=true
		this.SetPlayerPause()
	end
end
function this.ExecuteBackGroundLoad(n)
	if mvars.dem_reservedDemoLoadPosition then
		this.SetStageBlockLoadPosition(mvars.dem_reservedDemoLoadPosition)
		this.SetPlayerWarpAndPause(mvars.dem_reservedDemoLoadPosition)
		mvars.dem_DoneBackGroundLoading=true
	else
		local a,n,t=DemoDaemon.GetStartPosition(n,"Player")
		if not a then
			mvars.dem_DoneBackGroundLoading=true
			return
		end
		this.SetStageBlockLoadPosition(n)
		this.SetPlayerWarp(n,t)
		mvars.dem_DoneBackGroundLoading=true
	end
end
function this.SetStageBlockLoadPosition(e)
	TppGameStatus.Set("TppDemo.ReserveInTheBackground","S_IS_BLACK_LOADING")
	mvars.dem_isSetStageBlockPosition=true
	StageBlockCurrentPositionSetter.SetEnable(true)StageBlockCurrentPositionSetter.SetPosition(e:GetX(),e:GetZ())
end
function this.SetPlayerPause()
	mvars.dem_isPlayerPausing=true
	Player.SetPause()
end
function this.SetPlayerWarp(e,a)
	mvars.dem_isPlayerPausing=true
	Player.SetPause()
	local n={type="TppPlayer2",index=0}
	local e={id="WarpAndWaitBlock",pos={e:GetX(),e:GetY(),e:GetZ()},rotY=a}
	GameObject.SendCommand(n,e)
end
function this.UnsetStageBlockLoadPosition()
	TppGameStatus.Reset("TppDemo.ReserveInTheBackground","S_IS_BLACK_LOADING")
	if mvars.dem_isSetStageBlockPosition then
		StageBlockCurrentPositionSetter.SetEnable(false)
	end
	mvars.dem_isSetStageBlockPosition=false
end
function this.UnsetPlayerPause()
	if mvars.dem_isPlayerPausing then
		Player.UnsetPause()
	end
	mvars.dem_isPlayerPausing=false
end
function this.ClearReserveInTheBackGround()
	mvars.dem_reservedDemoId=nil
	mvars.dem_reservedDemoLoadPosition=nil
end
function this.CheckEventDemoDoor(r,n,e)
	local t=TppPlayer.GetPosition()
	local a=30
	if r==nil then
		return false
	end
	if Tpp.IsTypeTable(n)then
		t=n
	elseif n==nil then
	end
	if Tpp.IsTypeNumber(e)and e>0 then
		a=e
	elseif e==nil then
	end
	local n=0
	local i,l=0,1
	local o=Tpp.IsNotAlert()
	local a=TppEnemy.IsActiveSoldierInRange(t,a)
	local e
	if o==true and a==false then
		n=i
		e=true
	else
		n=l
		e=false
	end
	Player.SetEventLockDoorIcon{doorId=r,isNgIcon=n}
	return e,o,(not a)
end
function this.SpecifyIgnoreNpcDisable(e)
	local n
	if Tpp.IsTypeString(e)then
		n={e}
	elseif IsTypeTable(e)then
		n=e
	else
		return
	end
	mvars.dem_npcDisableList=mvars.dem_npcDisableList or{}
	for n,e in ipairs(n)do
		local n=TppEnemy.SetIgnoreDisableNpc(e,true)
		if n then
			table.insert(mvars.dem_npcDisableList,e)
		end
	end
end
function this.ClearIgnoreNpcDisableOnDemoEnd()
	if not mvars.dem_npcDisableList then
		return
	end
	for n,e in ipairs(mvars.dem_npcDisableList)do
		TppEnemy.SetIgnoreDisableNpc(e,false)
	end
	mvars.dem_npcDisableList=nil
end
function this.IsPlayedMBEventDemo(e)
	local e=TppDefine.MB_FREEPLAY_DEMO_ENUM[e]
	if e then
		return gvars.mbFreeDemoPlayedFlag[e]
	end
end
function this.ClearPlayedMBEventDemoFlag(e)
	local e=TppDefine.MB_FREEPLAY_DEMO_ENUM[e]
	if e then
		gvars.mbFreeDemoPlayedFlag[e]=false
	end
end
function this.OnAllocate(n)
	mvars.dem_demoList={}
	mvars.dem_invDemoList={}
	mvars.dem_invScdDemolist={}
	mvars.dem_demoFuncs={}
	mvars.dem_demoFlags={}
	mvars.dem_playedList={}
	mvars.dem_isSkipped={}
	this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
	mvars.demo_playRequestInfo={}
	mvars.demo_playRequestInfo={missionBlock={},demoBlock={}}
	mvars.demo_finishWaitRequestInfo={}
	local n=n.demo
	if n and IsTypeTable(n.demoList)then
		this.Register(n.demoList)
	end
end
function this.Init(n)
	this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
end
function this.OnReload(n)
	this.OnAllocate(n)
	this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
end
function this.Update()
	local n=mvars
	local e=this
	if n.dem_reservedDemoId then
		if FindDemoBody(n.dem_reservedDemoId)then
			if not n.dem_DoneBackGroundLoading then
				e.ExecuteBackGroundLoad(n.dem_reservedDemoId)
			end
		end
	end
	e.ProcessPlayRequest(n.demo_playRequestInfo.missionBlock)
	e.ProcessFinishWaitRequestInfo()
	
end

--r51 Separate update function
function this.RemoveTelopFromDemos()
	if not IsDemoPlaying() then return end

	--r51 Settings - has to be via Update func sadly, so am starting to think (and this kinda confirms) that each and every telop during a demo is formed and then posted at a particular time in the demo. Since the update func here is resetting *every* frame, I am able to hide the telops
--		TUPPMLog.Log("TppDemo.Update stopping teleop cast",3,true)
		TppUiCommand.AllResetTelopCast() --WORKS! Removes all cast! But will also remove the mission objective if shown during a demo - not sure if that happens ever
--		TppUiCommand.EraseTelopCast() --NOPE
--		TppUiCommand.StopTelopCast() --All appear overlapping once cutscene is skipped/finishes
end

function this.Register(e)
	mvars.dem_demoList=e
	for n,e in pairs(e)do
		mvars.dem_invDemoList[e]=n
		mvars.dem_invScdDemolist[StrCode32(e)]=n
	end
end
function this.AddDemo(e,n)
	mvars.dem_demoList[e]=n
	mvars.dem_invDemoList[n]=e
	mvars.dem_invScdDemolist[StrCode32(n)]=e
end
function this.OnMessage(i,r,o,a,t,l,n)
	Tpp.DoMessage(this.messageExecTable,TppMission.CheckMessageOption,i,r,o,a,t,l,n)
end
function this.FadeOutOnSkip()
	TppUI.FadeOut(TppUI.FADE_SPEED.FADE_MOMENT)
end
function this.OnDemoPlay(a,t)
	if mvars.dem_playedList[a]==nil then
		return
	end
	local n=mvars.dem_demoFlags[a]or{}
	if not n.startNoFadeIn then
		local e=n.fadeSpeed or TppUI.FADE_SPEED.FADE_NORMALSPEED
		TppUI.FadeIn(e,"DemoPlayFadeIn",t)
	end
	if n.useDemoBlock then
		mvars.dem_startedDemoBlockDemo=false
	end
	if mvars.dem_resereveEnableInGameFlag then
		if TppMission.GetMissionClearState()<=TppDefine.MISSION_CLEAR_STATE.MISSION_GAME_END then
			TppSoundDaemon.ResetMute"Loading"end
	end
	local n=mvars.dem_demoList[a]
	if(n=="p31_080110_000_final")then
		GkEventTimerManager.Start("p31_080110_000_showLocationTelop",12+(34/60))
	end
	this.UnsetStageBlockLoadPosition()
	this.UnsetPlayerPause()
end
function this.OnDemoEnd(a)
	if mvars.dem_playedList[a]==nil then
		return
	end
	local n=mvars.dem_demoFlags[a]or{}
	local a=mvars.dem_demoList[a]
	local t={p31_070050_001_final=true}
	if t[a]then
		TppSound.SetMuteOnLoading()
	end
	if mvars.dem_tempPlayerInfo then
		this.AddFinishWaitRequestInfo(a,n,"playerModelReloaded")
	end
	if n.waitTextureLoadOnDemoEnd then
		this.AddFinishWaitRequestInfo(a,n,"waitTextureLoadOnDemoEnd")
	end
	this.AddFinishWaitRequestInfo(a,n)
end
function this.OnDemoInterrupt(n)
	if mvars.dem_playedList[n]==nil then
		return
	end
	this.OnDemoEnd(n)
end
function this.OnDemoSkip(e,a)
	local n=mvars.dem_demoList[e]
	local t=mvars.dem_demoFlags[e]or{}
	local t={p31_010010=true,p41_030005_000_final=true,p51_070020_000_final=true,p31_050026_000_final=true}
	if t[n]then
		TppSoundDaemon.SetMuteInstant"Loading"end
	if(n=="p31_080110_000_final")then
		if GkEventTimerManager.IsTimerActive"p31_080110_000_showLocationTelop"then
			GkEventTimerManager.Stop"p31_080110_000_showLocationTelop"end
		TppUiCommand.HideInfoTypingText()
	end
	mvars.dem_isSkipped[n]=true
	mvars.dem_currentSkippedDemoName=e
	mvars.dem_currentSkippedScdDemoID=a
	if mvars.dem_playedList[e]==nil then
		return
	end
end
function this.EnableWaitBlockLoadOnDemoSkip()
	local a=mvars.dem_currentSkippedDemoName
	if not a then
		return
	end
	local n=mvars.dem_demoFlags[a]or{}
	local a=mvars.dem_demoList[a]
	if n.waitBlockLoadEndOnDemoSkip then
		this.AddFinishWaitRequestInfo(a,n,"waitBlockLoadEndOnDemoSkip")
		if not n.finishFadeOut then
			this.AddFinishWaitRequestInfo(a,n,"waitTextureLoadOnDemoEnd")
		end
	end
end
function this.OnDemoSkipAndBlockLoadEnd()
	if mvars.dem_enableWaitBlockLoadOnDemoSkip~=nil then
		mvars.dem_enableWaitBlockLoadOnDemoSkip=nil
	end
end
function this.DoOnEndMessage(n,r,o,t,a)
	if(not r)then
		local e=true
		if t and(not a)then
			e=false
		end
		if e then
			TppUI.FadeIn(TppUI.FADE_SPEED.FADE_NORMALSPEED,"DemoSkipFadeIn",mvars.dem_currentSkippedScdDemoID,{exceptGameStatus=o})
		end
	end
	this._DoMessage(n,"onEnd")
	mvars.dem_currentSkippedDemoName=nil
	mvars.dem_currentSkippedScdDemoID=nil
	this.EnableInGameFlagIfResereved()
	this.EnableNpc(n)
end
function this.OnDemoDisable(n)
	if mvars.dem_playedList[n]==nil then
		return
	end
	this.OnDemoEnd(n)
end
function this.AddPlayReqeustInfo(demoId,options)
	--	TUPPMLog.Log("TppDemo.AddPlayReqeustInfo START demoId:"..tostring(demoId),1)
	local playRequestOptions=this.MakeNewPlayRequestInfo(options)
	for r,o in pairs(playRequestOptions)do
		local isPlayRequestValid=true
		local playRequestStartFuncToCall=this.PLAY_REQUEST_START_FUNC[r]
		if playRequestStartFuncToCall then
			isPlayRequestValid=playRequestStartFuncToCall(demoId,options)
		else
			if playRequestStartFuncToCall==nil then
				playRequestOptions[r]=nil
				isPlayRequestValid=true
			end
		end
		if not isPlayRequestValid then
			return false
		end
	end
	if not options.isInGame then
		TppRadio.Stop()
	end
	this.DisableGameStatusOnPlayRequest(options.isInGame)
	if options and options.useDemoBlock then
		mvars.demo_playRequestInfo.demoBlock[demoId]=playRequestOptions
	else
		mvars.demo_playRequestInfo.missionBlock[demoId]=playRequestOptions
	end
	return true
end
function this.MakeNewPlayRequestInfo(options)
	--	TUPPMLog.Log("TppDemo.MakeNewPlayRequestInfo START",1)
	if options==nil then
		return{}
	end
	local gameCameraInterpedToDemo
	if options.interpGameToDemo then
		gameCameraInterpedToDemo=false
	end
	local demoBlockLoaded
	if options.useDemoBlock then
		demoBlockLoaded=false
	end
	local playerModelReloaded
	if options.isSnakeOnly then
		if(vars.playerType==PlayerType.DD_MALE or vars.playerType==PlayerType.DD_FEMALE)then
			playerModelReloaded=false
		end
	end
	local playerActionAllowed
	if(not options.isInGame)or(options.isNotAllowedPlayerAction)then
		playerActionAllowed=false
	end
	local playerMoveToPosition
	if options.playerMoveToPosition then
		playerMoveToPosition=false
	end
	local waitTextureLoadOnDemoPlay
	if options.waitTextureLoadOnDemoPlay then
		waitTextureLoadOnDemoPlay=false
	end
	local e={missionStateCheck=false,gameCameraInterpedToDemo=gameCameraInterpedToDemo,demoBlockLoaded=demoBlockLoaded,playerModelReloaded=playerModelReloaded,playerActionAllowed=playerActionAllowed,playerMoveToPosition=playerMoveToPosition,waitTextureLoadOnDemoPlay=waitTextureLoadOnDemoPlay}
	return e
end
function this.DeletePlayRequestInfo(e,n)
	if n and n.useDemoBlock then
		mvars.demo_playRequestInfo.demoBlock[e]=nil
	else
		mvars.demo_playRequestInfo.missionBlock[e]=nil
	end
end
function this.ProcessPlayRequest(n)
	if not next(n)then
		return
	end
	for n,a in pairs(n)do
		local a=this.CanStartPlay(n,a)
		if a then
			if not IsDemoPaused()then
				if not IsPlayingDemoId(n)then
					local a=mvars.dem_invDemoList[n]
					local t=mvars.dem_demoFlags[a]
					this._Play(a,n)
					this.DeletePlayRequestInfo(n,t)
				end
			end
		end
	end
end
function this.CanStartPlay(o,t)
	local a=true
	for n,r in pairs(t)do
		if r==false then
			local e=this.PLAY_REQUEST_START_CHECK_FUNC[n](o)
			if e then
				t[n]=true
			else
				a=false
			end
		end
	end
	return a
end
function this.AddFinishWaitRequestInfo(t,a,n)
	local a
	local o=true
	if n then
		a=this.FINISH_WAIT_START_FUNC[n]
		if a then
			o=a(t)
		else
			return
		end
	end
	local e
	e=mvars.demo_finishWaitRequestInfo[t]or{}
	if(o==true)then
		if n then
			e[n]=false
		end
	else
		return
	end
	mvars.demo_finishWaitRequestInfo[t]=e
end
function this.ProcessFinishWaitRequestInfo()
	local n=mvars.demo_finishWaitRequestInfo
	if not next(n)then
		return
	end
	for a,n in pairs(n)do
		local n=this.CanFinishPlay(a,n)
		if n then
			local t=mvars.dem_invDemoList[a]
			local n=mvars.dem_demoFlags[t]or{}
			mvars.demo_finishWaitRequestInfo[a]=nil
			this.DoOnEndMessage(t,n.finishFadeOut,n.exceptGameStatus,n.isInGame,mvars.dem_isSkipped[a])
			if(not n.finishFadeOut)and(not n.isInGame)then
				TppTerminal.GetFobStatus()
			end
		end
	end
end
function this.CanFinishPlay(o,t)
	local n=true
	for a,r in pairs(t)do
		if r==false then
			local e=this.FINISH_WAIT_CHECK_FUNC[a](o)
			if e then
				t[a]=true
			else
				n=false
			end
		end
	end
	return n
end
function this._Play(n,a)
	mvars.dem_playedList[n]=true
	this.ClearReserveInTheBackGround()
--	if TUPPMSettings.game_ENABLE_hideCredits then
--		TUPPMLog.Log("TppDemo._Play stopping teleop cast",3,true)
--		TppUiCommand.AllResetTelopCast()
----		TppUiCommand.EraseTelopCast()
----		TppUiCommand.StopTelopCast()
--	end
	DemoDaemon.Play(a)
end
function this._OnDemoInit(n)
	local n=mvars.dem_invScdDemolist[n]
	if n then
		this._DoMessage(n,"onInit")
	end
end
function this._OnDemoPlay(a)
	local n=mvars.dem_invScdDemolist[a]
	if n then
		this.DisableGameStatusOnPlayStart()
		this.OnDemoPlay(n,a)
		this._DoMessage(n,"onStart")
	end
end
function this._OnDemoEnd(n)
	local n=mvars.dem_invScdDemolist[n]
	if n then
		this.OnDemoEnd(n)
		mvars.dem_playedList[n]=nil
	end
end
function this._OnDemoInterrupt(n)
	local n=mvars.dem_invScdDemolist[n]
	if n then
		this.OnDemoInterrupt(n)
		this._DoMessage(n,"onInterrupt")
	end
end
function this._OnDemoSkip(a)
	local n=mvars.dem_invScdDemolist[a]
	if n then
		this.OnDemoSkip(n,a)
		this._DoMessage(n,"onSkip")
	end
end
function this._OnDemoDisable(n)
	local n=mvars.dem_invScdDemolist[n]
	if n then
		this.OnDemoDisable(n)
		this._DoMessage(n,"onDisable")
		mvars.dem_playedList[n]=nil
	end
end
function this._DoMessage(n,a)
	if((mvars.dem_demoFuncs==nil or mvars.dem_demoFuncs[n]==nil)or mvars.dem_demoFuncs[n][a]==nil)then
		return
	end
	mvars.dem_demoFuncs[n][a]()
end
this.mtbsPriorityFuncList={TheGreatEscapeLiquid=function()
	return false
end,NuclearEliminationCeremony=function()
	if not gvars.f30050_isInitNuclearAbolitionCount then
		return false
	end
	local n=TppStory.GetCurrentStorySequence()>=TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO
	local e=TppServerManager.GetNuclearAbolitionCount()
	local a=e>=0
	local e=gvars.f30050_NuclearAbolitionCount<e
	if(a and n)and e then
		if vars.mbmIsNuclearDeveloping==0 and TppMotherBaseManagement.GetResourceUsableCount{resource="NuclearWeapon"}==0 then
			return true
		else
			gvars.f30050_needUpdateNuclearFlag=true
			return false
		end
	end
	return false
end,ForKeepNuclearElimination=function()
	return false
end,SacrificeOfNuclearElimination=function()
	return false
end,GoToMotherBaseAfterQuietBattle=function()
	return gvars.mbFreeDemoPlayRequestFlag[TppDefine.MB_FREEPLAY_DEMO_REQUESTFLAG_DEFINE.PlayAfterQuietBattle]
end,ArrivedMotherBaseLiquid=function()
	return gvars.mbFreeDemoPlayRequestFlag[TppDefine.MB_FREEPLAY_DEMO_REQUESTFLAG_DEFINE.PlayAfterWhiteMamba]
end,ArrivedMotherBaseFromDeathFactory=function()
	return gvars.mbFreeDemoPlayRequestFlag[TppDefine.MB_FREEPLAY_DEMO_REQUESTFLAG_DEFINE.PlayAfterDethFactory]
end,EntrustDdog=function()
	if this.IsPlayedMBEventDemo"EntrustDdog"then
		return false
	end
	if TppBuddyService.DidObtainBuddyType(BuddyType.DOG)then
		return true
	else
		return false
	end
end,DdogComeToGet=function()
	if this.IsPlayedMBEventDemo"DdogComeToGet"then
		return false
	end
	local n=TppStory.GetClearedMissionCount{10036,10043,10033}>=2
	local t=TppBuddyService.DidObtainBuddyType(BuddyType.DOG)
	local a=not TppBuddyService.CanSortieBuddyType(BuddyType.DOG)
	local e=TppStory.IsNowOccurringElapsedMission(TppDefine.ELAPSED_MISSION_EVENT.D_DOG_COME_TO_GET)
	return((n and t)and a)and e
end,DdogGoWithMe=function()
	local a=TppStory.GetClearedMissionCount{10041,10044,10052,10054}>=3
	local n=not TppBuddyService.CanSortieBuddyType(BuddyType.DOG)
	local e=TppStory.IsNowOccurringElapsedMission(TppDefine.ELAPSED_MISSION_EVENT.D_DOG_GO_WITH_ME)
	return(a and n)and e
end,LongTimeNoSee_DDSoldier=function()
	local n=TppStory.IsMissionCleard(10030)
	local e=gvars.elapsedTimeSinceLastPlay>=fiveDaysInSeconds
	return n and e
end,LongTimeNoSee_DdogPup=function()
	local e=gvars.elapsedTimeSinceLastPlay>=fiveDaysInSeconds
	local n=TppBuddyService.DidObtainBuddyType(BuddyType.DOG)
	local a=not TppBuddyService.CanSortieBuddyType(BuddyType.DOG)
	return(e and n)and a
end,LongTimeNoSee_DdogLowLikability=function()
	local e=TppStory.IsMissionCleard(10050)
	local n=gvars.elapsedTimeSinceLastPlay>=fiveDaysInSeconds
	local a=TppBuddyService.CanSortieBuddyType(BuddyType.DOG)
	local t=TppBuddyService.GetFriendlyPoint(BuddyFriendlyType.DOG)<25
	return((e and n)and a)and t
end,LongTimeNoSee_DdogHighLikability=function()
	local e=TppStory.IsMissionCleard(10050)
	local n=gvars.elapsedTimeSinceLastPlay>=fiveDaysInSeconds
	local a=TppBuddyService.CanSortieBuddyType(BuddyType.DOG)
	local t=25<=TppBuddyService.GetFriendlyPoint(BuddyFriendlyType.DOG)and TppBuddyService.GetFriendlyPoint(BuddyFriendlyType.DOG)<75
	return((e and n)and a)and t
end,LongTimeNoSee_DdogSuperHighLikability=function()
	local o=TppStory.IsMissionCleard(10050)
	local n=gvars.elapsedTimeSinceLastPlay>=fiveDaysInSeconds
	local a=TppBuddyService.CanSortieBuddyType(BuddyType.DOG)
	local e=TppBuddyService.GetFriendlyPoint(BuddyFriendlyType.DOG)>=75
	return((o and n)and a)and e
end,AttackedFromOtherPlayer_KnowWhereFrom=function()
	if this.IsPlayedMBEventDemo"AttackedFromOtherPlayer_KnowWhereFrom"or this.IsPlayedMBEventDemo"AttackedFromOtherPlayer_UnknowWhereFrom"then
		return false
	end
	local n=TppStory.GetCurrentStorySequence()>=TppDefine.STORY_SEQUENCE.CLEARD_CAPTURE_THE_WEAPON_DEALER
	local e=vars.mbmDemoAttackedFromOtherPlayerKnowWhereFrom~=0
	return n and e
end,AttackedFromOtherPlayer_UnknowWhereFrom=function()
	if this.IsPlayedMBEventDemo"AttackedFromOtherPlayer_KnowWhereFrom"or this.IsPlayedMBEventDemo"AttackedFromOtherPlayer_UnknowWhereFrom"then
		return false
	end
	local e=TppStory.GetCurrentStorySequence()>=TppDefine.STORY_SEQUENCE.CLEARD_CAPTURE_THE_WEAPON_DEALER
	local n=vars.mbmRequestDemoAttackedFromOtherPlayer~=0
	return e and n
end,MoraleOfMBIsLow=function()
	if this.IsPlayedMBEventDemo"MoraleOfMBIsLow"then
		return false
	end
	local n=TppStory.GetCurrentStorySequence()>=TppDefine.STORY_SEQUENCE.CLEARD_TO_MATHER_BASE
	local e=TppMotherBaseManagement.GetGmp()<0
	return n and e
end,OcelotIsPupilOfSnake=function()
	if this.IsPlayedMBEventDemo"OcelotIsPupilOfSnake"then
		return false
	end
	local n=TppStory.IsMissionCleard(10040)
	local e=0
	for n=TppMotherBaseManagementConst.SECTION_COMBAT,TppMotherBaseManagementConst.SECTION_SECURITY do
		e=e+#TppMotherBaseManagement.GetOutOnMotherBaseStaffs{sectionId=n}
	end
	local e=e>=3
	return n and e
end,HappyBirthDay=function()
	if this.IsPlayedMBEventDemo"HappyBirthDay"then
		return false
	end
	local a=TppUiCommand.IsBirthDay()
	local n=TppStory.GetCurrentStorySequence()>=TppDefine.STORY_SEQUENCE.CLEARD_TO_MATHER_BASE
	local e=TppStory.GetClearedMissionCount{10036,10043,10033}>=1
	return(a and n)and e
end,HappyBirthDayWithQuiet=function()
	return false
end,QuietOnHeliInRain=function()
	if this.IsPlayedMBEventDemo"QuietOnHeliInRain"then
		return false
	else
		local n=TppStory.GetCurrentStorySequence()>=TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO
		local t=TppBuddyService.GetFriendlyPoint(BuddyFriendlyType.QUIET)>=80
		local a=(vars.buddyType==BuddyType.QUIET)
		local e=TppStory.CanArrivalQuietInMB(false)
		return((n and t)and a)and e
	end
end,QuietHasFriendshipWithChild=function()
	if this.IsPlayedMBEventDemo"QuietHasFriendshipWithChild"then
		return false
	else
		local t=TppLocation.GetLocalMbStageClusterGrade(TppDefine.CLUSTER_DEFINE.Medical+1)>=2
		local a=TppStory.CanArrivalQuietInMB(true)
		local n=TppStory.GetCurrentStorySequence()>=TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO
		local e=not(TppQuest.IsOpen"outland_q20913"or TppQuest.IsOpen"lab_q20914")
		return((t and a)and n)and e
	end
end,QuietWishGoMission=function()
	if this.IsPlayedMBEventDemo"QuietWishGoMission"then
		return false
	end
	if TppStory.CanArrivalQuietInMB(false)then
		if TppQuest.IsOpen"mtbs_q99011"then
			return TppStory.IsNowOccurringElapsedMission(TppDefine.ELAPSED_MISSION_EVENT.QUIET_WITH_GO_MISSION)
		else
			return true
		end
	end
end,QuietReceivesPersecution=function()
	return false
end,SnakeHasBadSmell_WithoutQuiet=function()
	if this.IsPlayedMBEventDemo"SnakeHasBadSmell_WithoutQuiet"then
		return false
	end
	local e=TppStory.IsMissionCleard(10040)
	local n=Player.GetSmallFlyLevel()>=1
	return e and n
end,SnakeHasBadSmell_000=function()
	if this.IsPlayedMBEventDemo"SnakeHasBadSmell_000"then
		return false
	end
	local n=TppStory.IsMissionCleard(10086)
	local e=TppStory.CanArrivalQuietInMB(false)
	local a=Player.GetSmallFlyLevel()>=1
	local t=TppBuddyService.GetFriendlyPoint(BuddyFriendlyType.QUIET)>=60
	return((n and e)and a)and t
end,SnakeHasBadSmell_001=function()
	return false
end,EliLookSnake=function()
	if this.IsPlayedMBEventDemo"EliLookSnake"then
		return false
	end
	return false
end,LiquidAndChildSoldier=function()
	if this.IsPlayedMBEventDemo"LiquidAndChildSoldier"then
		return false
	end
	local n=TppStory.GetCurrentStorySequence()>=TppDefine.STORY_SEQUENCE.CLEARD_WHITE_MAMBA
	local e=TppQuest.IsOpen"sovietBase_q99030"return n and not e
end,InterrogateQuiet=function()
	if this.IsPlayedMBEventDemo"InterrogateQuiet"then
		return false
	else
		local n=TppStory.CanArrivalQuietInMB(true)
		local e=TppQuest.IsOpen"sovietBase_q99030"local a=not TppRadio.IsPlayed"f2000_rtrg8290"return(n and e)and a
	end
end,AnableDevBattleGear=function()
	if this.IsPlayedMBEventDemo"AnableDevBattleGear"then
		return false
	end
	return TppRadio.IsPlayed"f2000_rtrg8175"and(TppStory.GetClearedMissionCount{10085,10200}==0)
end,CodeTalkerSunBath=function()
	if this.IsPlayedMBEventDemo"CodeTalkerSunBath"then
		return false
	end
	local n=TppStory.GetCurrentStorySequence()>=TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO
	local e=TppStory.IsMissionCleard(10130)
	return n and e
end,ParasiticWormCarrierKill=function()
	return false
end,DecisionHuey=function()
	if this.IsPlayedMBEventDemo"DecisionHuey"then
		return false
	end
	if TppStory.IsNowOccurringElapsedMission(TppDefine.ELAPSED_MISSION_EVENT.DECISION_HUEY)and TppRadio.IsPlayed"f2000_rtrg8410"then
		return true
	else
		return false
	end
end,DetailsNuclearDevelop=function()
	return false
end,EndingSacrificeOfNuclear=function()
	return false
end}
function this.UpdateHappyBirthDayFlag()
	if this.IsPlayedMBEventDemo"HappyBirthDay"then
		if TppUiCommand.IsBirthDay()then
			if gvars.elapsedTimeSinceLastPlay>(24*60)*60 and(not gvars.isPlayedHappyBirthDayToday)then
				this.ClearPlayedMBEventDemoFlag"HappyBirthDay"end
		else
			this.ClearPlayedMBEventDemoFlag"HappyBirthDay"gvars.isPlayedHappyBirthDayToday=false
		end
	end
end
function this.GetMBDemoName()
	return TppDefine.MB_FREEPLAY_DEMO_PRIORITY_LIST[gvars.mbFreeDemoPlayNextIndex]
end
function this.UpdateMBDemo()
	this.UpdateHappyBirthDayFlag()
	gvars.mbFreeDemoPlayNextIndex=0
	for n,a in ipairs(TppDefine.MB_FREEPLAY_DEMO_PRIORITY_LIST)do
		local e=this.mtbsPriorityFuncList[a]
		if e and e()then
			gvars.mbFreeDemoPlayNextIndex=n
			return
		end
	end
end
function this.IsUseMBDemoStage(e)
	if not TppMission.IsMissionStart()then
		return false
	end
	if e then
		for a,n in pairs(TppDefine.MB_FREEPLAY_LARGEDEMO)do
			if n==e then
				return true
			end
		end
	end
	return false
end
function this.SetNextMBDemo(n)
	local e=TppDefine.MB_FREEPLAY_DEMO_ENUM[n]
	if n and e then
		gvars.mbFreeDemoPlayNextIndex=e+1
	else
		gvars.mbFreeDemoPlayNextIndex=0
	end
end
function this.CanUpdateMBDemo()
	for n,e in pairs(TppDefine.MB_FREEPLAY_DEMO_REQUESTFLAG_DEFINE)do
		if gvars.mbFreeDemoPlayRequestFlag[e]then
			return true
		end
	end
	if not TppMission.IsStartFromHelispace()then
		return false
	end
	return true
end
function this.IsQuestStart()
	if not TppMission.IsStartFromHelispace()then
		return false
	end
	if TppQuest.IsActive"mtbs_q99050"and MotherBaseStage.GetFirstCluster()==TppDefine.CLUSTER_DEFINE.Develop then
		return true
	end
	if TppQuest.IsActive"mtbs_q99011"and MotherBaseStage.GetFirstCluster()==TppDefine.CLUSTER_DEFINE.Medical then
		return true
	end
	return false
end
function this.IsSortieMBDemo(e)
	if TppDefine.MB_FREEPLAY_RIDEONHELI_DEMO_DEFINE[e]then
		return true
	else
		return false
	end
end
function this.IsBattleHangerDemo(e)
	local n={"DevelopedBattleGear1","DevelopedBattleGear2","DevelopedBattleGear4","DevelopedBattleGear5"}
	for a,n in ipairs(n)do
		if n==e then
			return true
		end
	end
	return false
end
function this.EnableNpc(t)
	local a=mvars.dem_demoFlags[t]or{}
	if not a.isInGame then
		local n="all"local t=mvars.dem_demoList[t]
		if a.finishFadeOut or mvars.dem_isSkipped[t]then
			n={}
			for a,e in pairs(TppDefine.GAME_STATUS_TYPE_ALL)do
				n[a]=e
			end
		end
		this.EnableGameStatus(n,a.exceptGameStatus)
	end
	this.ClearIgnoreNpcDisableOnDemoEnd()
end
function this.UpdateNuclearAbolitionFlag()
	if gvars.f30050_needUpdateNuclearFlag then
		gvars.f30050_NuclearAbolitionCount=TppServerManager.GetNuclearAbolitionCount()
		gvars.f30050_discardNuclearCountFromLastAbolition=TppMotherBaseManagement.GetResourceUsableCount{resource="NuclearWaste"}
		gvars.f30050_needUpdateNuclearFlag=false
	end
end
return this
