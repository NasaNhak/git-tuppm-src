local this={}
local StrCode32=Fox.StrCode32
local IsTypeTable=Tpp.IsTypeTable
local GetGameObjectId=GameObject.GetGameObjectId
local NULL_ID=GameObject.NULL_ID
local CallFadeIn=FadeFunction.CallFadeIn
local CallFadeOut=FadeFunction.CallFadeOut
local UNKnumber0=0

this.FADE_SPEED={
	FADE_MOMENT=0,
	FADE_HIGHESTSPEED=.5,
	FADE_HIGHSPEED=1,
	FADE_NORMALSPEED=2,
	FADE_LOWSPEED=4,
	FADE_LOWESTSPEED=8
}
this.ANNOUNCE_LOG_TYPE={
	updateMissionInfo="announce_mission_info_update",
	updateMissionInfo_AddDocument="announce_doc_add",
	updateMap="announce_map_update",
	recoverTarget="announce_target_extract",
	eliminateTarget="announce_target_eliminate",
	destroyTarget="announce_target_destroy",
	achieveObjectiveCount="announce_objective_complete_num",
	achieveAllObjectives="announce_objective_complete",
	emergencyMissionOccur="announce_mission_add_emerg",
	deleteEmergencyMission="announce_mission_del_emerg",
	getIntel="announce_get_intel_file",
	recoverTargetCount="announce_target_extract_num",
	recoverEnemy="announce_collection_enemy",
	recoverHostage="announce_collection_hostage",
	target_died="announce_target_died",
	target_eliminate_failed="announce_target_eliminate_failed",
	target_extract_failed="announce_target_extract_failed",
	staff_dead="announce_staff_dead",
	staff_dying="announce_staff_dying",
	hostage_died="announce_hostage_died",
	fob_sneaking_failed="announce_fob_sneaking_failed",
	boy_died="announce_boy_died",
	leaveHotZone="announce_left_hot_zone",
	closeOutOfMissionArea="announce_mission_area_warning",
	callHeliRecieved="announce_support_callheli_received",
	heliArrivedLZ="announce_heli_arrive_LZ",
	callSupportBuddyReceived="announce_support_callboddy_received",
	gmpGet="announce_ops_get_gmp",
	gmpCostFulton="announce_gmp_cost_fulton",
	gmpCostSupply="announce_gmp_cost_supply",
	gmpCostAttack="announce_gmp_cost_attack",
	gmpCostHeli="announce_gmp_cost_heli",
	gmpCostOps="announce_gmp_cost_ops",
	extractionAllived="announce_extraction_arrived",
	extractSoldiers="announce_extract_soldier",
	extractPrisoners="announce_extract_prisoner",
	getDiamond="announce_get_diamond",
	unitLvUpRd="announce_unit_lvup_RD",
	unitLvUpBaseDev="announce_unit_lvup_base_dev",
	unitLvUpSupport="announce_unit_lvup_support",
	unitLvUpIntel="announce_unit_lvup_intel",
	unitLvUpCombat="announce_unit_lvup_combat",
	unitLvUpSecurity="announce_unit_lvup_security",
	unitLvUpMedical="announce_unit_lvup_medical",
	unitLvDownRd="announce_unit_lvdown_RD",
	unitLvDownBaseDev="announce_unit_lvdown_base_dev",
	unitLvDownSupport="announce_unit_lvdown_support",
	unitLvDownIntel="announce_unit_lvdown_intel",
	unitLvDownCombat="announce_unit_lvdown_combat",
	unitLvDownSecurity="announce_unit_lvdown_security",
	unitLvDownMedical="announce_unit_lvdown_medical",
	missionListUpdate="announce_mission_list_update",
	missionAdd="announce_mission_add",
	extractionFailed="announce_extraction_failed",
	sunset="announce_sunset",
	sunrise="announce_sunrise",
	weather_sunny="announce_weather_sunny",
	weather_cloudy="announce_weather_cloudy",
	weather_rainy="announce_weather_rain",
	weather_sandstorm="announce_weather_sandstorm",
	weather_foggy="announce_weather_fog",
	getKyeItem="announce_ops_get_item",
	getPoster="announce_get_gravure",
	destroyRadar="announce_destroy_radar",
	unlockLz="announce_unlock_lz",
	heroicPointUp="announce_fame_up",
	heroicPointDown="announce_fame_down",
	outpost_neutralize="announce_outpost_neutralize",
	guradpost_neutralize="announce_guradpost_neutralize",
	announce_nuclear_zero="announce_nuclear_zero",
	fob_add="announce_fob_add",
	fobReqHelp="announce_fob_req_help",
	fobFindIntruder="announce_fob_find_intruder",
	fobFound="announce_fob_found",
	fobWormholeFrom="announce_fob_wormhole_from",
	fobWormholeTo="announce_fob_wormhole_to",
	fobReport="announce_online_910_from_0_prio_0",
	fobStolenStaff="announce_staff_num",
	task_complete="announce_task_complete",
	fobDefFailed="announce_fob_def_failed",
	fobDefSuccess="announce_fob_def_success",
	fobDefSuccessPra="announce_fob_def_success_pra",
	fobRivalArrive="announce_fob_helper_arrive",
	fobRivalEscape="announce_fob_helper_escape",
	fobIntruderEscape="announce_fob_intruder_escape",
	fobNoticeIntruder="announce_online_900_from_0_prio_0",
	fobReqPractice="announce_fob_req_practice",
	fobVisitFob="announce_fob_visit_fob",
	fobVisitFob1="announce_fob_visit_fob1",
	fobVisitFob2="announce_fob_visit_fob2",
	fobVisitFob3="announce_fob_visit_fob3",
	fobVisitFob4="announce_fob_visit_fob4",
	fobBatrayed="announce_fob_batrayed",
	fobBetray="announce_fob_betray",
	espPf_a="announce_esp_pf_a",
	espFulton_a="announce_esp_fulton_a",
	espFulton_d="announce_esp_fulton_d",
	espFultonContainer_a="announce_esp_container_fulton_a",
	espFultonContainer_d="announce_esp_container_fulton_d",
	espKill_a="announce_esp_kill_a",
	espKill_d="announce_esp_kill_d",
	espDestroy_a="announce_esp_destroy_a",
	espDestroy_d="announce_esp_destroy_d",
	espKillStaff_a="announce_esp_killstaff_a",
	espKillStaff_d="announce_esp_killstaff_d",
	espMarking_d="announce_esp_marking_d",
	espKillTarget_d="announce_esp_kill_target_d",
	fob_leave_owner="announce_fob_leave_owner",
	fob_leave_visiter="announce_fob_leave_fob",
	espFultonTarget_d="announce_esp_target_fulton_d",
	fob_practice_fin="announce_fob_practice_fin",
	esp_stun="announce_esp_stun",
	esp_sleep="announce_esp_sleep",
	esp_stun_d="announce_esp_stun_df",
	esp_sleep_d="announce_esp_sleep_df",
	esp_stun_a="announce_esp_stun_at",
	esp_sleep_a="announce_esp_sleep_at",
	esp_headshot_d="announce_esp_hs_df",
	esp_ttd_d="announce_esp_ttd_df",
	esp_headshot_a="announce_esp_hs_at",
	esp_ttd_a="announce_esp_ttd_at",
	fob_get_ransom="announce_fob_get_ransom_d90",
	mbstaff_died="announce_mbstaff_died",
	horse_died="announce_horse_died",
	quiet_died="announce_quiet_died",
	ddog_died="announce_ddog_died",
	dwalker_died="announce_dwalker_died",
	quest_add="announce_quest_add",
	quest_complete="announce_quest_complete",
	quest_delete="announce_quest_delete",
	quest_list_update="announce_quest_list_update",
	quest_defeat_armor="announce_quest_defeat_armor",
	quest_defeat_zombie="announce_quest_defeat_zombie",
	mine_quest_log="announce_quest_disposal_mine",
	quest_extract_elite="announce_quest_extract_elite",
	quest_extract_hostage="announce_quest_extract_hostage",
	quest_defeat_armor_vehicle="announce_quest_defeat_armor_vehicle",
	quest_defeat_tunk="announce_quest_defeat_tunk",
	quest_get_photo="announce_get_photo",
	quest_target_eliminate="announce_quest_target_destroy",
	find_keyitem="announce_find_keyitem",
	find_em_string="announce_find_em_string",
	find_em_back="announce_find_em_back",
	find_em_front="announce_find_em_front",
	get_tape="announce_get_tape",
	looting_weapon="announce_looting_weapon",
	get_wgear="announce_get_wgear",
	add_delivery_point="announce_add_delivery_point",
	get_invoice="announce_get_invoice",
	disposal_mine="announce_disposal_mine",
	disposal_decoy="announce_disposal_decoy",
	destroyed_skull="announce_destroyed_skull",
	trial_update="announce_trial_update",
	destroyed_support_heli="announce_destroyed_support_heli",
	add_alt_machine="announce_add_alt_machine",
	get_blueprint="announce_get_blueprint",
	recoveredFilmCase="announce_get_film_case",
	find_processed_res="announce_find_processed_res",
	find_diamond="announce_find_diamond",
	find_plant="announce_find_plant",
	refresh="announce_refresh",
	get_hero="announce_get_hero",
	lost_hero="announce_lost_hero",
	--> Patch 1090
	challenge_task="announce_challenge_task_d90"
--<
}
this.ANNOUNCE_LOG_PRIORITY={
	"eliminateTarget",
	"recoveredFilmCase",
	"recoverTarget",
	"destroyTarget",
	"achieveAllObjectives",
	"achieveObjectiveCount",
	"getIntel",
	"updateMissionInfo",
	"updateMissionInfo_AddDocument",
	"updateMap"
}
this.BUDDY_LANG_ID={
	[BuddyType.HORSE]="name_buddy_dh",
	[BuddyType.DOG]="name_buddy_dd",
	[BuddyType.QUIET]="marker_chara_quiet"}
this.EMBLEM_ANNOUNCE_LOG_TYPE={
	[Fox.StrCode32"front"]="find_em_front",
	[Fox.StrCode32"base"]="find_em_back",
	[Fox.StrCode32"word"]="find_em_string"
}
function this.Messages()
	return Tpp.StrCode32Table{
		GameObject={
			{msg="ArrivedAtLandingZoneWaitPoint",
				sender="SupportHeli",
				func=function()
					this.ShowAnnounceLog"heliArrivedLZ"
				end}
		},
		UI={
			{msg="EndFadeIn",
				func=this.EnableGameStatusOnFade,
				option={isExecMissionClear=true,isExecDemoPlaying=true,isExecGameOver=true}},
			{msg="EndFadeOut",
				func=this.DisableGameStatusOnFadeOutEnd,
				option={isExecMissionClear=true,isExecDemoPlaying=true,isExecGameOver=true}},
			{msg="ConfigurationUpdated",
				func=function()
					if vars.missionCode==TppDefine.SYS_MISSION_ID.INIT then
						return
					end
					TppSave.VarSaveConfig()
					if TppSave.IsSavingWithFileName(TppDefine.CONFIG_SAVE_FILE_NAME)or TppSave.HasQueue(TppDefine.CONFIG_SAVE_FILE_NAME)then
						return
					end
					TppSave.SaveConfigData()
				end,
				option={isExecGameOver=true}},
			{msg="DisplayTimerLap",
				func=function(e,n)
					if not mvars.ui_displayTimeSecSvarsName then
						return
					end
					svars[mvars.ui_displayTimeSecSvarsName]=e
				end},
			{msg="StartMissionTelopFadeOut",
				func=function()
					TppSoundDaemon.ResetMute"Telop"
				end}
		},
		Radio={
			{msg="Finish",
				func=function(n)
					if TppRadio.CheckRadioGroupIsCommonRadio(n,TppDefine.COMMON_RADIO.CALL_SUPPROT_BUDDY)then
						this.ShowCallSupportBuddyAnnounceLog()
					end
				end}
		}
	}
end
local function a(e)
	if type(e)=="string"then
		return Fox.StrCode32(e)
	elseif type(e)=="number"then
		return e
	end
	return nil
end
function this.FadeIn(t,i,o,n)
	local i=a(i)
	if n then
		mvars.ui_onEndFadeInExceptGameStatus=n.exceptGameStatus
	elseif mvars.ui_onEndFadeInOverrideExceptGameStatus then
		mvars.ui_onEndFadeInExceptGameStatus=mvars.ui_onEndFadeInOverrideExceptGameStatus
	else
		mvars.ui_onEndFadeInExceptGameStatus=nil
	end
	TppSoundDaemon.ResetMute"Outro"CallFadeIn(t,i,o)
	this.EnableGameStatusOnFadeInStart()
end
function this.OverrideFadeInGameStatus(e)
	mvars.ui_onEndFadeInOverrideExceptGameStatusTemporary=e
end
function this.UnsetOverrideFadeInGameStatus()
	mvars.ui_onEndFadeInOverrideExceptGameStatusTemporary=nil
end
function this.GetOverrideGameStatus()
	return mvars.ui_onEndFadeInOverrideExceptGameStatusTemporary
end
function this.SetFadeColorToBlack()FadeFunction.SetFadeColor(0,0,0,255)
end
function this.SetFadeColorToWhite()FadeFunction.SetFadeColor(255,255,255,255)
end
function this.FadeOut(fadeSpeed,fadeType,s,options)
	--TUPPMLog.Log("TppUI.FadeOut START",1)
	local setMute,exceptGameStatus
	if Tpp.IsTypeTable(options)then
		setMute=options.setMute
		exceptGameStatus=options.exceptGameStatus
	end
	local fadeTypeStrCode32=a(fadeType)
	this.DisableGameStatusOnFade(exceptGameStatus)
	if setMute then
		TppSound.SetMuteOnLoading()
	else
		if(not TppSoundDaemon.CheckCurrentMuteIs"Pause")and(not TppSoundDaemon.CheckCurrentMuteMoreThan"Outro")then
			TppSoundDaemon.SetMute"Outro"end
	end
	CallFadeOut(fadeSpeed,fadeTypeStrCode32,s)
	--TUPPMLog.Log("TppUI.FadeOut END",1)
end
function this.ShowAnnounceLog(announceId,param1,param2,delayTime,missionSubGoalNumber)
	if gvars.ini_isTitleMode then
		return
	end
	--rX1
	--TUPPMLog.Log("announceId: "..tostring(announceId))
	--TUPPMLog.Log(", param1: "..tostring(param1))
	--TUPPMLog.Log(", param2: "..tostring(param2))
	--TUPPMLog.Log(", delayTime: "..tostring(delayTime))
	--TUPPMLog.Log(", missionSubGoalNumber: "..tostring(missionSubGoalNumber))
	local e=this.ANNOUNCE_LOG_TYPE[announceId]
	if e then
		if delayTime then
			TppUiCommand.AnnounceLogDelayTime(delayTime)
		end
		TppUiCommand.AnnounceLogViewLangId(e,param1,param2)
	elseif missionSubGoalNumber then
		local e=TppUiCommand.GetCurrentMissionSubGoalByNo(missionSubGoalNumber)
		TppUiCommand.AnnounceLogViewLangId(e)
	end
end
function this.ShowColorAnnounceLog(i,t,a,n)
	if gvars.ini_isTitleMode then
		return
	end
	local e=this.ANNOUNCE_LOG_TYPE[i]
	if e then
		if n then
			TppUiCommand.AnnounceLogDelayTime(n)
		end
		TppUiCommand.AnnounceLogViewLangId(e,t,a,0,0,true)
	end
end
function this.ShowJoinAnnounceLog(i,o,t,a,n)
	if gvars.ini_isTitleMode then
		return
	end
	local i=this.ANNOUNCE_LOG_TYPE[i]
	local e=this.ANNOUNCE_LOG_TYPE[o]
	if i and e then
		if n then
			TppUiCommand.AnnounceLogDelayTime(n)
		end
		TppUiCommand.AnnounceLogViewJoinLangId(i,e,t,a)
	end
end
function this.ShowColorJoinAnnounceLog(n,t,o,a,i)
	if gvars.ini_isTitleMode then
		return
	end
	local n=this.ANNOUNCE_LOG_TYPE[n]
	local e=this.ANNOUNCE_LOG_TYPE[t]
	if n and e then
		if i then
			TppUiCommand.AnnounceLogDelayTime(i)
		end
		TppUiCommand.AnnounceLogViewJoinLangId(n,e,o,a,0,0,true)
	end
end
function this.ShowEmergencyAnnounceLog(n)
	this.ShowAnnounceLog"emergencyMissionOccur"if not(TppUiStatusManager.CheckStatus("AnnounceLog","INVALID_LOG")or TppUiStatusManager.CheckStatus("AnnounceLog","SUSPEND_LOG"))then
		if n==true then
			TppSoundDaemon.PostEvent"sfx_s_fob_emergency"else
			TppSoundDaemon.PostEvent"sfx_s_fob_alert"end
	end
end
function this.EnableMissionPhoto(e,i,n,t,a)
	TppUiCommand.EnableMissionPhotoId(e)
	if TppUiCommand.IsMissionPhotoIdEnable(e)then
		if i or n then
			if i==nil then
				i=false
			end
			if n==nil then
				n=false
			end
			TppUiCommand.SetAdditonalMissionPhotoId(e,i,n)
		end
		if t then
		end
		if a then
			local n=StrCode32(a)
			TppUiCommand.SetMissionPhotoRadioGroupName(e,n)
		end
	end
end
function this.DisableMissionPhoto(e,n)
	if TppUiCommand.IsMissionPhotoIdEnable(e)then
		if n then
			TppUiCommand.ResetMissionPhotoRadioGroupName(e)
		end
		TppUiCommand.DisableMissionPhotoId(e)
	end
end
function this.EnableMissionSubGoal(e)
	TppUiCommand.SetCurrentMissionSubGoalNo(e)
end
function this.EnableSpySearch(e)
	if not IsTypeTable(e)then
		return
	end
	local n,i
	if Tpp.IsTypeString(e.gameObjectName)then
		i=e.gameObjectName
		n=GetGameObjectId(i)
	elseif Tpp.IsTypeNumber(e.gameObjectId)then
		n=e.gameObjectId
	else
		return
	end
	if n==NULL_ID then
		return
	end
	e.gameObjectId=n
	TppUiCommand.ActivateSpySearchForGameObject(e)
end
function this.DisableSpySearch(e)
	if not IsTypeTable(e)then
		return
	end
	local n,i
	if Tpp.IsTypeString(e.gameObjectName)then
		i=e.gameObjectName
		n=GetGameObjectId(i)
	elseif Tpp.IsTypeNumber(e.gameObjectId)then
		n=e.gameObjectId
	else
		return
	end
	if n==NULL_ID then
		return
	end
	e.gameObjectId=n
	TppUiCommand.DeactivateSpySearchForGameObject(e)
end
function this.StartMissionTelop(telopId,showDDLogoAtMissionTitle,waitForFadeOutToPrintMissionTimeAndLoc)
	--This function is for the mission title flash! Not for demo telop

--	TUPPMLog.Log("StartMissionTelop - telopId:"..tostring(telopId).." UNKvar1:"..tostring(showDDLogoAtMissionTitle).." UNKvar2:"..tostring(waitForFadeOutToPrintMissionTimeAndLoc),3,true)
--	TUPPMLog.Log("StartMissionTelop TUPPMSettings.game_ENABLE_hideCredits:"..tostring(TUPPMSettings.game_ENABLE_hideCredits),3,true)
	
--	if TUPPMSettings.game_ENABLE_hideCredits then return end
-- TppUiCommand.CallMissionStartTelop needs to fire so that a related Message can fire
-- which means demo telop(sic) cannot be toggled (here at least)
	
	TppSoundDaemon.SetMute"Telop"
	if telopId 
	--and not TUPPMSettings.game_ENABLE_hideCredits --NOPE Did not even test this thing out, don't know what this does
	then
		TppUiCommand.SetMissionStartTelopId(telopId)
	end
	
--	if TUPPMSettings.game_ENABLE_hideCredits then
--		showDDLogoAtMissionTitle=false
--		waitForFadeOutToPrintMissionTimeAndLoc=false
--	end
	
--	if TUPPMSettings.game_ENABLE_hideCredits then
--		TppUiCommand.AllResetTelopCast() --NOPE --so we are just going to reset the damned thing :)
--		
--		--BELOW are NOPE too
--		mvars.tlp_mainCharacters={}
--		mvars.tlp_guestCharacters={}
--		mvars.tlp_enemyCombatants={}
--		mvars.tlp_specialMechanics={}
--		mvars.tlp_levelDesigners={}
--		mvars.tlp_writers={}
--	end
	
	TppUiCommand.CallMissionStartTelop(showDDLogoAtMissionTitle,waitForFadeOutToPrintMissionTimeAndLoc)
	TppSound.PostJingleOnMissionStartTelop()
end
function this.GetMaxMissionTask(e)
	local e=TppResult.MISSION_TASK_LIST[e]
	if e then
		return#e
	end
end
function this.EnableMissionTask(a,t)
	if t==nil then
		t=true
	end
	if not IsTypeTable(a)then
		return
	end
	local missionTask={}
	for e,i in pairs(a)do
		missionTask[e]=i
	end
	local taskNumber=missionTask.taskNo
	if not taskNumber then
		return
	end
	if missionTask.isHide==nil then
		if missionTask.isFirstHide then
			if not TppStory.IsMissionCleard(vars.missionCode)and(not this.IsTaskLastCompleted(taskNumber))then
				missionTask.isHide=true
			else
				missionTask.isHide=false
			end
		else
			missionTask.isHide=false
		end
	end
	if missionTask.isComplete then
		missionTask.isHide=false
		local missionCode=vars.missionCode
		local taskCompletedNumberBeforeSettingComplete=this.GetTaskCompletedNumber(missionCode)
		--rX23 Updates misison tasks in Heli based on previous mission result;
		-- This seems to be global as in for the save file
		-- Setting to false will only enable tasks as completed which
		-- were actually completed on last mission play
		--      this.SetTaskLastCompleted(taskNumber,false)
		this.SetTaskLastCompleted(taskNumber,true) --ORIG
		local taskCompletedNumberAfterSettingComplete=this.GetTaskCompletedNumber(missionCode)
		local maxMissionTask=this.GetMaxMissionTask(missionCode)
		if maxMissionTask==nil then
			return
		end
		if t then
			if taskCompletedNumberAfterSettingComplete>taskCompletedNumberBeforeSettingComplete then
				this.ShowAnnounceLog("task_complete",taskCompletedNumberAfterSettingComplete,maxMissionTask)
			end
		end
		TppMission.SetPlayRecordClearInfo()
		TppChallengeTask.RequestUpdate"MISSION_TASK"
		--> Patch 1090
		this.UpdateOnlineChallengeTask{detectType=(34+taskNumber),diff=1}
		--<
		if this.IsAllTaskCompleted(missionCode)then
			TppEmblem.AcquireOnAllMissionTaskComleted(missionCode)
		end
	end
	if this.IsTaskLastCompleted(taskNumber)then
		missionTask.isLastCompleted=true --ORIG
		
		--r51 Settings
		if TUPPMSettings.game_ENABLE_clearCompletedTasksDuringMission then
			--r23 Determines objective flag while in Mission ;
			-- setting to false here removes the greyed out look for already completed objectives
			missionTask.isLastCompleted=false
		end
		
	else
		missionTask.isLastCompleted=false
	end
	TppUiCommand.EnableMissionTask(missionTask)
end
function this.IsTaskLastCompleted(n)
	local e=this.GetLastCompletedFlagIndex(n)
	if e then
		return gvars.ui_isTaskLastComleted[e]
	end
end
function this.SetTaskLastCompleted(taskNumber,isCompleted)
	local e=this.GetLastCompletedFlagIndex(taskNumber)
	if e then
		gvars.ui_isTaskLastComleted[e]=isCompleted
	end
end
function this.GetLastCompletedFlagIndex(n)
	return this._GetLastCompletedFlagIndex(vars.missionCode,n)
end
function this._GetLastCompletedFlagIndex(n,e)
	local n=TppDefine.MISSION_ENUM[tostring(n)]
	if not n then
		return
	end
	if not Tpp.IsTypeNumber(e)then
		return
	end
	if(e<0)or(e>=TppDefine.MAX_MISSION_TASK_COUNT)then
		return
	end
	return n*TppDefine.MAX_MISSION_TASK_COUNT+e
end
function this.GetTaskCompletedNumber(missionCode)
	local missionCodeEnumId=TppDefine.MISSION_ENUM[tostring(missionCode)]
	if not missionCodeEnumId then
		return 0
	end
	local e=0
	for i=0,TppDefine.MAX_MISSION_TASK_COUNT-1 do
		local n=missionCodeEnumId*TppDefine.MAX_MISSION_TASK_COUNT+i
		if gvars.ui_isTaskLastComleted[n]then
			e=e+1
		end
	end
	return e
end
function this.IsAllTaskCompleted(n)
	local i=this.GetTaskCompletedNumber(n)
	local e=this.GetMaxMissionTask(n)
	if e==nil then
		return false
	end
	if i>=e then
		return true
	end
	return false
end
--> Patch 1090
function this.UpdateOnlineChallengeTask(e)
	if OnlineChallengeTask then
		OnlineChallengeTask.Update(e)
	end
end
--<
function this.ShowControlGuide(n)
	if not IsTypeTable(n)then
		return
	end
	local a,s,i,p,t,o,r
	a=n.actionName
	s=n.continue
	i=n.time
	p=n.isOnce
	t=n.isOnceThisGame
	o=n.pauseControl
	r=n.ignoreRadio
	if not this.IsEnableToShowGuide(true)then
		return
	end
	if type(a)~="string"then
		return
	end
	local e=TppDefine.CONTROL_GUIDE[a]
	local n=TppDefine.CONTROL_GUIDE_LANG_ID_LIST[e]
	if n==nil then
		return
	end
	if p then
		if gvars.ui_isControlGuideShownOnce[e]then
			return
		end
		gvars.ui_isControlGuideShownOnce[e]=true
	end
	if t then
		if gvars.ui_isControlGuidShownInThisGame[e]then
			return
		end
		gvars.ui_isControlGuidShownInThisGame[e]=true
	end
	if not i then
		i=TppTutorial.DISPLAY_TIME.DEFAULT
	end
	TppUiCommand.SetButtonGuideDispTime(i)
	if not o then
		if(s==true)then
			TppUiCommand.CallButtonGuideContinue(n,false,false,false)
		else
			TppUiCommand.CallButtonGuide(n,false,false,false)
		end
	else
		local e=TppDefine.PAUSE_CONTROL_GUIDE[e]
		if e then
			TppUiCommand.CallControllerHelp(e,n)
		end
	end
	local e=TppTutorial.ControlGuideRadioList[e]
	if e then
		TppTutorial.PlayRadio(e)
	end
end
function this.ShowTipsGuide(n)
	if not IsTypeTable(n)then
		return
	end
	local i,a,t,r,p,o,s
	i=n.contentName
	a=n.isOnce
	t=n.isOnceThisGame
	p=n.time
	o=n.ignoreRadio
	s=n.ignoreDisplay
	if not this.IsEnableToShowGuide(o)then
		return
	end
	if not s then
		if TppUiCommand.IsDispGuide"TipsGuide"then
			return
		end
	end
	if type(i)~="string"then
		return
	end
	local e=TppDefine.TIPS[i]
	if e==nil then
		return
	end
	local n=nil
	local i=TppDefine.TIPS_REDUNDANT_REF[e]
	if not i then
		n=tostring(e)
	else
		n=tostring(i)
	end
	if n==nil then
		return
	end
	if a and t then
		return
	end
	if a then
		if gvars.ui_isTipsGuideShownOnce[e]then
			return
		end
		gvars.ui_isTipsGuideShownOnce[e]=true
	end
	if t then
		if gvars.ui_isTipsGuidShownInThisGame[e]then
			return
		end
		gvars.ui_isTipsGuidShownInThisGame[e]=true
	end
	TppUiCommand.EnableTips(n,true)
	TppUiCommand.SetButtonGuideDispTime(TppTutorial.DISPLAY_TIME.DEFAULT)
	TppUiCommand.DispTipsGuide(n)
	TppUiCommand.SeekTips(n)
	local e=TppTutorial.TipsGuideRadioList[e]
	if e then
		TppTutorial.PlayRadio(e)
	end
end
function this.IsEnableToShowGuide(e)
	if TppUiCommand.IsMbDvcTerminalOpened()then
		return false
	end
	if not e then
		if TppRadioCommand.IsPlayingRadio()then
			return false
		end
	end
	if TppDemo.IsNotPlayable()then
		return false
	end
	return true
end
function this.OpenTips(n)
	if type(n)~="string"then
		return
	end
	local n=TppDefine.TIPS_ON_STORY[n]
	local n=TppDefine.TIPS_ON_STORY_LANG_ID_LIST[n]
	this.RegisterTips(n)
end
function this.RegisterTips(e,n)
	if type(e)=="string"then
		local i="tips_name_"..e
		TppUiCommand.DeleteTips(e)
		TppUiCommand.RegistTipsTitle(e,i)
		if not n then
			local n="tips_info_"..e
			TppUiCommand.RegistTipsDoc(e,n)
		end
	elseif type(e)=="table"then
		local i="tips_name_"..e[1]
		TppUiCommand.DeleteTips(e[1])
		TppUiCommand.RegistTipsTitle(e[1],i)
		if not n then
			for i,n in pairs(e)do
				local n="tips_info_"..n
				TppUiCommand.RegistTipsDoc(e[1],n)
			end
		end
	end
end
function this.StartDisplayTimer(e)
	if not IsTypeTable(e)then
		return
	end
	if not e.svarsName then
		return
	end
	local i=e.svarsName
	local n=svars[i]
	if not n then
		return
	end
	if n<0 then
		return
	end
	local e=e.cautionTimeSec or 30
	mvars.ui_displayTimeSecSvarsName=i
	TppUiStatusManager.SetStatus("DisplayTimer","NO_TIMECOUNT_SUB")
	TppUiStatusManager.UnsetStatus("DisplayTimer","NO_TIMECOUNT")
	TppUiCommand.StartDisplayTimer(n,e)
end
function this.ShowSavingIcon(e)
	TppUiCommand.CallSaveMessage(e)
end
function this.ShowLoadingIcon()
	TppUiCommand.CallLoadMessage()
end
function this.ShowAccessIcon()
	TppUiCommand.CallAccessMessage()
end
function this.ShowAccessIconContinue()
	TppUiCommand.CallAccessContinueMessage()
end
function this.HideAccessIcon()
	TppUiCommand.HideAccessMessage()
end
function this.ShowTextureLogo()
	TppUiCommand.ShowTextureLogo()
end
function this.HideTextureLogo()
	TppUiCommand.HideTextureLogo()
end
function this.ShowCallSupportBuddyAnnounceLog()
	local n=this.BUDDY_LANG_ID[mvars.ui_callSupportBuddyType]
	if n then
		local i=TppSupportRequest.GetCallBuddyGmpCost(mvars.ui_callSupportBuddyType)
		this.ShowAnnounceLog("callSupportBuddyReceived",n)
		TppTerminal.UpdateGMP{gmp=-i,gmpCostType=TppDefine.GMP_COST_TYPE.BUDDY}svars.supportGmpCost=svars.supportGmpCost+i
		mvars.ui_callSupportBuddyType=nil
	end
end
function this.SetSupportCallBuddyType(e)
	mvars.ui_callSupportBuddyType=e
end
function this.StartLoadingTips()
	TppUiCommand.StartLoadingTipsCommon()
end
function this.FinishLoadingTips()
	TppUiCommand.RequestEndLoadingTips()
end
function this.StartLyricOkb(e)
	TppUiCommand.LyricTexture("disp","okb_lyric_15",5.5,1.43)
	TppUiCommand.LyricTexture("disp","okb_lyric_16",6,.23)
	TppUiCommand.LyricTexture("disp","okb_lyric_17",6.75,.38)
	TppUiCommand.LyricTexture("disp","okb_lyric_18",2.47,.17)
	TppUiCommand.LyricTexture("disp","okb_lyric_19",7.2,.33)
	TppUiCommand.LyricTexture("disp","okb_lyric_20",7.03,2.02)
	TppUiCommand.LyricTexture("disp","okb_lyric_21",4.12,.17)
	TppUiCommand.LyricTexture("disp","okb_lyric_22",3.4,.27)
	TppUiCommand.LyricTexture("disp","okb_lyric_23",3.2,.3)
	TppUiCommand.LyricTexture("disp","okb_lyric_24",3.03,.3)
	TppUiCommand.LyricTexture("disp","okb_lyric_25",6.9,.07)
	TppUiCommand.LyricTexture("disp","okb_lyric_26",7.33,6.23)
	TppUiCommand.LyricTexture("disp","okb_lyric_27",6.43,.2)
	TppUiCommand.LyricTexture("disp","okb_lyric_28",3.73,0)
	TppUiCommand.LyricTexture("start",e)
end
function this.StartLyricEnding(e)
	TppUiCommand.LyricTexture("disp","okb_lyric_01",5.83,.53)
	TppUiCommand.LyricTexture("disp","okb_lyric_02",6.43,.47)
	TppUiCommand.LyricTexture("disp","okb_lyric_03",6.73,.33)
	TppUiCommand.LyricTexture("disp","okb_lyric_04",7.9,(2.57+101.85))
	TppUiCommand.LyricTexture("disp","okb_lyric_19",6.8,.3)
	TppUiCommand.LyricTexture("disp","okb_lyric_10",6.23,.33)
	TppUiCommand.LyricTexture("disp","okb_lyric_11",6.47,.27)
	TppUiCommand.LyricTexture("disp","okb_lyric_12",2.9,.23)
	TppUiCommand.LyricTexture("disp","okb_lyric_13",3.5,.33)
	TppUiCommand.LyricTexture("disp","okb_lyric_14",5.07,26.93)
	TppUiCommand.LyricTexture("disp","okb_lyric_15",5.5,1.43)
	TppUiCommand.LyricTexture("disp","okb_lyric_16",6,.23)
	TppUiCommand.LyricTexture("disp","okb_lyric_17",6.75,.38)
	TppUiCommand.LyricTexture("disp","okb_lyric_18",2.47,.17)
	TppUiCommand.LyricTexture("disp","okb_lyric_19",7.2,.33)
	TppUiCommand.LyricTexture("disp","okb_lyric_20",7.03,2.02)
	TppUiCommand.LyricTexture("disp","okb_lyric_21",4.12,.17)
	TppUiCommand.LyricTexture("disp","okb_lyric_22",3.4,.27)
	TppUiCommand.LyricTexture("disp","okb_lyric_23",3.2,.3)
	TppUiCommand.LyricTexture("disp","okb_lyric_24",3.03,.3)
	TppUiCommand.LyricTexture("disp","okb_lyric_25",6.9,.07)
	TppUiCommand.LyricTexture("disp","okb_lyric_26",7.33,6.23)
	TppUiCommand.LyricTexture("disp","okb_lyric_27",6.43,.2)
	TppUiCommand.LyricTexture("disp","okb_lyric_28",3.73,0)
	TppUiCommand.LyricTexture("start",e)
end
function this.StartLyricQuiet(e)
	TppUiCommand.LyricTexture("disp","quiet_lyric_01",2.05,1.53)
	TppUiCommand.LyricTexture("disp","quiet_lyric_02",3.83,1.57)
	TppUiCommand.LyricTexture("disp","quiet_lyric_03",2.8,.8)
	TppUiCommand.LyricTexture("disp","quiet_lyric_04",5.03,1.57)
	TppUiCommand.LyricTexture("disp","quiet_lyric_05",2.23,1.3)
	TppUiCommand.LyricTexture("disp","quiet_lyric_06",3.53,1.3)
	TppUiCommand.LyricTexture("disp","quiet_lyric_07",2.4,2.47)
	TppUiCommand.LyricTexture("disp","quiet_lyric_08",4.53,1.37)
	TppUiCommand.LyricTexture("disp","quiet_lyric_09",2.33,1.23)
	TppUiCommand.LyricTexture("disp","quiet_lyric_10",3.47,1.37)
	TppUiCommand.LyricTexture("disp","quiet_lyric_11",2.7,1.9)
	TppUiCommand.LyricTexture("disp","quiet_lyric_12",3.8,2.17)
	TppUiCommand.LyricTexture("disp","quiet_lyric_13",2.53,.2)
	TppUiCommand.LyricTexture("disp","quiet_lyric_14",4.43,1)
	TppUiCommand.LyricTexture("disp","quiet_lyric_15",3.23,1.7)
	TppUiCommand.LyricTexture("disp","quiet_lyric_16",4.9,1.47)
	TppUiCommand.LyricTexture("disp","quiet_lyric_17",3.27,1.17)
	TppUiCommand.LyricTexture("disp","quiet_lyric_18",4.23,.25)
	TppUiCommand.LyricTexture("disp","quiet_lyric_19",4.02,.37)
	TppUiCommand.LyricTexture("disp","quiet_lyric_20",4.93,.2)
	TppUiCommand.LyricTexture("disp","quiet_lyric_21",4.73,.2)
	TppUiCommand.LyricTexture("disp","quiet_lyric_22",4.4,.37)
	TppUiCommand.LyricTexture("disp","quiet_lyric_23",4.63,.03)
	TppUiCommand.LyricTexture("disp","quiet_lyric_24",3.13,1.53)
	TppUiCommand.LyricTexture("disp","quiet_lyric_25",4.73,.33)
	TppUiCommand.LyricTexture("disp","quiet_lyric_26",4.23,.67)
	TppUiCommand.LyricTexture("disp","quiet_lyric_27",4.53,.1)
	TppUiCommand.LyricTexture("disp","quiet_lyric_28",6.63,0)
	TppUiCommand.LyricTexture("start",e)
end
function this.StartLyricCyprus(e)
	TppUiCommand.LyricTexture("disp","cyprus_lyric_01",7.87,.57)
	TppUiCommand.LyricTexture("disp","cyprus_lyric_02",7.93,.53)
	TppUiCommand.LyricTexture("disp","cyprus_lyric_03",7.5,0)
	TppUiCommand.LyricTexture("disp","cyprus_lyric_04",8.47,2.07)
	TppUiCommand.LyricTexture("disp","cyprus_lyric_05",3.7,.53)
	TppUiCommand.LyricTexture("disp","cyprus_lyric_06",3.7,.43)
	TppUiCommand.LyricTexture("disp","cyprus_lyric_07",3.8,.43)
	TppUiCommand.LyricTexture("disp","cyprus_lyric_08",4,12.03)
	TppUiCommand.LyricTexture("disp","cyprus_lyric_09",7.4,1.13)
	TppUiCommand.LyricTexture("disp","cyprus_lyric_10",7.93,.53)
	TppUiCommand.LyricTexture("disp","cyprus_lyric_11",7.3,0)
	TppUiCommand.LyricTexture("disp","cyprus_lyric_12",8.6,2)
	TppUiCommand.LyricTexture("disp","cyprus_lyric_13",3.73,.57)
	TppUiCommand.LyricTexture("disp","cyprus_lyric_14",3.6,.5)
	TppUiCommand.LyricTexture("disp","cyprus_lyric_15",3.83,.43)
	TppUiCommand.LyricTexture("disp","cyprus_lyric_16",4.73,5.93)
	TppUiCommand.LyricTexture("disp","cyprus_lyric_17",3.73,.6)
	TppUiCommand.LyricTexture("disp","cyprus_lyric_18",3.63,.4)
	TppUiCommand.LyricTexture("disp","cyprus_lyric_19",3.83,.43)
	TppUiCommand.LyricTexture("disp","cyprus_lyric_20",4.27,0)
	TppUiCommand.LyricTexture("start",e)
end
function this.OnAllocate(n)
	if n.sequence then
		if n.sequence.OVERRIDE_SYSTEM_EXCEPT_GAME_STATUS then
			mvars.ui_onEndFadeInOverrideExceptGameStatus=n.sequence.OVERRIDE_SYSTEM_EXCEPT_GAME_STATUS
		end
	end
	local i=true
	if n.sequence and n.sequence.NO_LOAD_UI_DEFAULT_BLOCK then
		i=false
	end
	if i then
		this.LoadAndWaitUiDefaultBlock()
	else
		return
	end
	TppUiCommand.ClearAllMissionPhotoIds()
	if n.sequence and n.sequence.UNSET_UI_SETTING then
		mvars.ui_unsetUiSetting=n.sequence.UNSET_UI_SETTING
	end
	if TppMission.IsMissionStart()then
		this.EnableMissionSubGoal(UNKnumber0)
	end
	if TppUiCommand.InitAllEnemyRoutePoints then
		TppUiCommand.InitAllEnemyRoutePoints()
	end
	TppUiCommand.ClearIconUniqueInformation()
end
function this.LoadAndWaitUiDefaultBlock()
	TppUiCommand.LoadUiDefaultBlock()
	local e=0
	local e,i=0,25
	local n=false
	n=not TppUiCommand.IsTppUiReady()
	while n and(e<i)do
		n=not TppUiCommand.IsTppUiReady()e=e+Time.GetFrameTime()coroutine.yield()
	end
end
function this.OnMissionStart()
	local e=vars.missionCode
	local n=TppMission.IsHelicopterSpace(e)
	if n then
		return
	end
	local e=TppMission.IsFreeMission(e)
	if e then
		return
	end
	TppUiCommand.RemovedAllUserMarker()
end

--K r09 removed continue option from pause menu
function this.Init()
	this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
	TppUiCommand.SetMotherBaseStageSecurityTable{
		numInSpecialPlatform=TppDefine.SECURITY_SETTING.numInSpecialPlatform,
		numInCommonPlatform=TppDefine.SECURITY_SETTING.numInCommonPlatform,
		numInCommandPlatform=TppDefine.SECURITY_SETTING.numInCommandPlatform,
		numInBaseDevPlatform=TppDefine.SECURITY_SETTING.numInBaseDevPlatform
	}
	local isHelicopterSpace=TppMission.IsHelicopterSpace(vars.missionCode)
	local isFreeMission=TppMission.IsFreeMission(vars.missionCode)
	local isFOBMission=TppMission.IsFOBMission(vars.missionCode)
	if isHelicopterSpace or isFreeMission then
		TppUiCommand.HideOuterZone()
	else
		TppUiCommand.ShowOuterZone()
	end
	if isHelicopterSpace then
		TppUiStatusManager.SetStatus("MbEquipDevelop","NO_OPEN_SUPPORT_DIALOG")
	else
		TppUiStatusManager.UnsetStatus("MbEquipDevelop","NO_OPEN_SUPPORT_DIALOG")
	end
	if TppMission.IsCanMissionClear()then
		TppUiCommand.ShowHotZone()
	else
		TppUiCommand.HideHotZone()
	end
	TppUiCommand.ResetCurrentMissionSubGoalNo()
	this._RegisterDefaultLandPoint()
	local instanceOfUiCommonDataManager=(UiCommonDataManager.GetInstance()~=nil)
	if instanceOfUiCommonDataManager then
		if isHelicopterSpace then
			this.RegisterHeliSpacePauseMenuPage(true)
		elseif isFreeMission then
			local pauseMenu={
				GamePauseMenu.RETURN_TO_TITLE,
				GamePauseMenu.SIGN_IN,
				GamePauseMenu.STORE_ITEM,
				GamePauseMenu.RECORDS_ITEM,
				GamePauseMenu.CONTROLS_AND_TIPS_ITEM,
				GamePauseMenu.OPEN_OPTION_MENU
			}
			if TppMission.IsMbFreeMissions(vars.missionCode)then
				if(vars.missionCode==30050)then
					table.insert(pauseMenu,1,GamePauseMenu.RESTART_FROM_MISSION_START)
					--K r12 adding Abort to ACC to MB/MBQF/Zoo pause menus
					--r46 Changed to Return to ACC option
					table.insert(pauseMenu,2,GamePauseMenu.RESTART_FROM_HELICOPTER) --K r12
					
					--r51 Settings
					if not TUPPMSettings.menu_DISABLE_checkpointReloadOption then
						--r46 Enable extra pause menu and game over menu options in debug mode
						--rX45
						table.insert(pauseMenu,1,GamePauseMenu.RESTART_FROM_CHECK_POINT) --DEBUG AID --rX1
					end
				else
					--r46 Changed to Return to ACC option
					table.insert(pauseMenu,1,GamePauseMenu.RESTART_FROM_HELICOPTER) --K r12
					--table.insert(pauseMenu,3,GamePauseMenu.SIGN_IN) --r13 not needed, once signed in the menu appears itself
					
					--r51 Settings
					if TUPPMSettings.menu_ENABLE_restartOptionForZooAndMBQF then
					--r46 Enable extra pause menu and game over menu options in debug mode
						table.insert(pauseMenu,1,GamePauseMenu.RESTART_FROM_MISSION_START) --DEBUG AID
					end
					--r51 Settings
					if not TUPPMSettings.menu_DISABLE_checkpointReloadOption then
						--rX46
						--rX45
						table.insert(pauseMenu,1,GamePauseMenu.RESTART_FROM_CHECK_POINT) --DEBUG AID --rX1
					end
				end
			else
				table.insert(pauseMenu,1,GamePauseMenu.RESTART_FROM_HELICOPTER) --This is Return to ACC for Free Roam
				
				--r51 Settings
				if TUPPMSettings.menu_ENABLE_restartOptionForFreeRoam then
					--r46 Enable extra pause menu and game over menu options in debug mode
					table.insert(pauseMenu,1,GamePauseMenu.RESTART_FROM_MISSION_START) --DEBUG AID --Restart option for Free Roam :)
				end
				--r51 Settings
				if not TUPPMSettings.menu_DISABLE_checkpointReloadOption then
					--rX45
					table.insert(pauseMenu,1,GamePauseMenu.RESTART_FROM_CHECK_POINT) --DEBUG AID --rX1
				end
			end
			TppUiCommand.RegisterPauseMenuPage(pauseMenu)
		elseif TppMission.IsEmergencyMission()then
			if isFOBMission then
				TppUiCommand.RegisterPauseMenuPage{GamePauseMenu.RETURN_TO_MISSION_FROM_EMERGENCY_MISSION}
			else
				TppUiCommand.RegisterPauseMenuPage{
					GamePauseMenu.RETURN_TO_MISSION_FROM_EMERGENCY_MISSION,
					GamePauseMenu.SIGN_IN,
					GamePauseMenu.STORE_ITEM,
					GamePauseMenu.RECORDS_ITEM,
					GamePauseMenu.CONTROLS_AND_TIPS_ITEM,
					GamePauseMenu.OPEN_OPTION_MENU
				}
			end
		elseif isFOBMission then
			this.RegisterFobSneakPauseMenuPage()
		else
			local pauseMenu={
				GamePauseMenu.RESTART_FROM_MISSION_START,
				GamePauseMenu.RETURN_TO_TITLE,
				GamePauseMenu.SIGN_IN,
				GamePauseMenu.STORE_ITEM,
				GamePauseMenu.CONTROLS_AND_TIPS_ITEM,
				GamePauseMenu.OPEN_OPTION_MENU
			}
			if gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_TO_MATHER_BASE then
				table.insert(pauseMenu,6,GamePauseMenu.RECORDS_ITEM)
			end
			if TppMission.IsStartFromHelispace()then
				table.insert(pauseMenu,3,GamePauseMenu.ABORT_MISSION_RETURN_TO_ACC)
			end
			if TppMission.IsStartFromFreePlay()then
				table.insert(pauseMenu,3,GamePauseMenu.ABORT_MISSION)
			end
			if vars.missionCode~=10115 then
				--r46 Enable extra pause menu and game over menu options in debug mode
				--r51 Settings
				if not TUPPMSettings.menu_DISABLE_checkpointReloadOption then
					--rX45
					---r09 BOOM! continue from checkpoint removed from pause menu
					table.insert(pauseMenu,1,GamePauseMenu.RESTART_FROM_CHECK_POINT) --rX1
					--TppUiCommand.AnnounceLogView("Removed checkpoint option from PAUSE menu")
				end
			end
			TppUiCommand.RegisterPauseMenuPage(pauseMenu)
		end
		local ignoreActorPause=false
		if isFOBMission then
			ignoreActorPause=true
		end
		TppPauseMenu.SetIgnoreActorPause(ignoreActorPause)
	end
	if instanceOfUiCommonDataManager then
		if isFreeMission then
			--rX46 For Free afghan/mafr/mb/mbzoo/mbqf
			local gameOverMenuOptions={GameOverMenu.GAME_OVER_CONTINUE,GameOverMenu.GAME_OVER_TITLE}
			--r46 Always show Return to ACC option, don't exclude 30050
			table.insert(gameOverMenuOptions,2,GameOverMenu.GAME_OVER_RESTART_HELI) --Return to ACC from Free Roam, this is not Abort Option :)
			--ORIG
			--      if vars.missionCode~=30050 then
			--        table.insert(gameOverMenuOptions,2,GameOverMenu.GAME_OVER_RESTART_HELI)
			--      end
			TppUiCommand.RegisterGameOverMenuItems(gameOverMenuOptions)
		elseif TppMission.IsEmergencyMission()then
			TppUiCommand.RegisterGameOverMenuItems{GameOverMenu.GAME_OVER_RETURN_TO_MISSION}
		elseif isFOBMission then
			this.RegisterFobSneakGameOverMenuItems()
		else
			--rX46 For Missions
			local gameOverMenuOptions={GameOverMenu.GAME_OVER_RESTART,GameOverMenu.GAME_OVER_TITLE}
			if TppMission.IsStartFromHelispace()then
				table.insert(gameOverMenuOptions,3,GameOverMenu.GAME_OVER_ABORT_RETURN_TO_ACC)
			end
			if TppMission.IsStartFromFreePlay()then
				table.insert(gameOverMenuOptions,3,GameOverMenu.GAME_OVER_ABORT)
			end
			if vars.missionCode~=10115 then
				table.insert(gameOverMenuOptions,1,GameOverMenu.GAME_OVER_CONTINUE)
			end
			TppUiCommand.RegisterGameOverMenuItems(gameOverMenuOptions)
		end
	end
	if instanceOfUiCommonDataManager then
		TppUiCommand.RegisterSideOpsListFunction("TppQuest","GetSideOpsListTable")
	end
	TppUiCommand.SetMBMapArrowIcon(false)
	GameConfig.ApplyAllConfig()
	TppUiCommand.EraseDisplayTimer()
	TppUiCommand.ResetCpNameBaseLangId()
	if TppUiCommand.RegistCpNameBaseLangId and mvars.loc_locationBaseTelop then
		for n,e in ipairs(mvars.loc_locationBaseTelop.cpLangIdTable)do
			local n,e,i=e[1],e[2],e[3]
			TppUiCommand.RegistCpNameBaseLangId(n,e,i)
		end
	end
	TppUiCommand.RegistCpNameBaseLangId("helicopterSpace","tpp_heli_acc")
	TppUiCommand.ClearAllMissionTask()
	TppUiStatusManager.UnsetStatus("EquipHudAll","ALL_KILL_NOUSE")
	TppUiStatusManager.UnsetStatus("QuestAreaAnnounce","INVALID")
	TppUiStatusManager.UnsetStatus("SideFobInfo","INVALID")
	TppUiCommand.SetupMapIconRadiusMeters{radiusTable={0,30,40,62.5,125,200,325,450,600,1200}}
	if TppStory.IsAlwaysOpenRetakeThePlatform()then
		TppUiCommand.SetMission10115Emergency(false)
	else
		TppUiCommand.SetMission10115Emergency(true)
	end
	TppUiCommand.HidePictureInfoHud()
	TppUiCommand.RegisterMemorialMission{10010,10030,10240}
	if TppStory.IsMissionCleard(10260)then
		TppUiCommand.SetMissionNameStatus{missionId=10260,type="REPLAY"}
		if TppStory.CanPlayReunionQuietMission()then
			TppUiCommand.SetMissionNameStatus{missionId=10050,type="REUNION"}
		else
			TppUiCommand.SetMissionNameStatus{missionId=10050,type="REPLAY"}
		end
	else
		TppUiCommand.SetMissionNameStatus{missionId=10050,type="DEFAULT"}
		TppUiCommand.SetMissionNameStatus{missionId=10260,type="DEFAULT"}
	end
	TppUiCommand.SetMissionNameStatus{missionId=10070,type="DEFAULT"}
	TppUiCommand.SetMissionNameStatus{missionId=10120,type="DEFAULT"}
	if TppDemo.IsPlayedMBEventDemo"TheGreatEscapeLiquid"then
		TppUiCommand.SetMissionNameStatus{missionId=10120,type="REPLAY"}
	end
	if TppDemo.IsPlayedMBEventDemo"DecisionHuey"then
		TppUiCommand.SetMissionNameStatus{missionId=10070,type="REPLAY"}
	end
	if TppUiCommand.SetMotherBaseInfoPhotoParameters~=nil then
		TppUiCommand.SetMotherBaseInfoPhotoParameters{
			battleGearDevelopLevel=TppStory.GetBattleGearDevelopLevel(),
			isEnableSahelan=TppStory.CanArrivalSahelanInMB()
		}
	end
end
function this.RegisterHeliSpacePauseMenuPage(registerStore)
	local heliSpaceMenu={
		GamePauseMenu.RETURN_TO_TITLE,
		GamePauseMenu.ONLINE_NEWS,
		GamePauseMenu.RECORDS_ITEM,
		GamePauseMenu.CONTROLS_AND_TIPS_ITEM,
		GamePauseMenu.OPEN_OPTION_MENU,
		GamePauseMenu.GOTO_MGO
	}
	if registerStore then
		table.insert(heliSpaceMenu,2,GamePauseMenu.STORE_ITEM)
	end
	--r13 Since login is never tried during startup, add a SIGN IN option to pause menu
	--if not(TppGameMode.GetUserMode()<=TppGameMode.U_SIGN_OUT)then
	--  table.insert(heliSpaceMenu,2,GamePauseMenu.SIGN_IN)
	--end
	--r17 Re added online menu option
	--r16 remove sign in option
	table.insert(heliSpaceMenu,2,GamePauseMenu.SIGN_IN) --r13 added sign in option for when startup sign in process does not occur
	TppUiCommand.RegisterPauseMenuPage(heliSpaceMenu)
end
function this.RegisterFobSneakPauseMenuPage()
	local e
	if vars.fobIsPlaceMode~=1 then
		e={GamePauseMenu.ABORT_MISSION_RETURN_TO_ACC}
	else
		e={GamePauseMenu.ABORT_MISSION_PLACEMENT_MODE}
	end
	if(vars.fobSneakMode==FobMode.MODE_SHAM)and(TppNetworkUtil.GetSessionMemberCount()==1)then
		table.insert(e,1,GamePauseMenu.RESTART_FROM_MISSION_START)
	end
	TppUiCommand.RegisterPauseMenuPage(e)
end
function this.RegisterFobSneakGameOverMenuItems()
	local e={GameOverMenu.GAME_OVER_ABORT}
	if(vars.fobSneakMode==FobMode.MODE_SHAM)and(TppNetworkUtil.GetSessionMemberCount()==1)then
		table.insert(e,1,GameOverMenu.GAME_OVER_RESTART)
	end
	TppUiCommand.RegisterGameOverMenuItems(e)
end
function this.OnReload()
	this.Init()
end
function this.OnMessage(o,t,p,s,i,a,n)
	Tpp.DoMessage(this.messageExecTable,TppMission.CheckMessageOption,o,t,p,s,i,a,n)
end
function this.OnChangeSVars(n,e)
	if FobUI then
		FobUI.OnChangeSVars(n,e)
	end
end
function this.DisableGameStatusOnFade(e)
	local n={S_DISABLE_NPC=false}
	if IsTypeTable(e)then
		for e,i in pairs(e)do
			n[e]=i
		end
	end
	Tpp.SetGameStatus{target="all",enable=false,except=n,scriptName="TppUI.lua"}
end
function this.DisableGameStatusOnFadeOutEnd()
	Tpp.SetGameStatus{target="all",enable=false,scriptName="TppUI.lua"}
end
function this.EnableGameStatusOnFadeInStart()
	Tpp.SetGameStatus{
		target={S_DISABLE_NPC=true,
			S_DISABLE_NPC_NOTICE=true,
			S_DISABLE_TARGET=true,
			S_DISABLE_PLAYER_PAD=true,
			S_DISABLE_PLAYER_DAMAGE=true,
			S_DISABLE_THROWING=true,
			S_DISABLE_PLACEMENT=true},
		enable=true,
		scriptName="TppUI.lua"
	}
end
function this.EnableGameStatusOnFade()
	local e,n
	if IsTypeTable(mvars.ui_onEndFadeInExceptGameStatus)then
		n=mvars.ui_onEndFadeInExceptGameStatus
	elseif IsTypeTable(mvars.ui_onEndFadeInOverrideExceptGameStatusTemporary)then
		n=mvars.ui_onEndFadeInOverrideExceptGameStatusTemporary
	else
		if TppDemo.IsNotPlayable()then
			e=e or{}
			for n,i in pairs(TppDefine.UI_STATUS_TYPE_ALL)do
				e[n]=false
			end
			e.PauseMenu=nil
			e.InfoTypingText=nil
		end
	end
	if n then
		e={}
		for n,i in pairs(n)do
			e[n]=i
		end
	end
	Tpp.SetGameStatus{target="all",enable=true,except=e,scriptName="TppUI.lua"}
end
function this._RegisterDefaultLandPoint()
	local e=TppDefine.DEFAULT_DROP_ROUTE
	for n,e in pairs(e)do
		if e then
			TppUiCommand.RegisterDefaultLandPoint{missionId=n,routeId=e}
		end
	end
end
return this
