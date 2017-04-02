local this={}
this.storySequenceTable={}
this.storySequenceTable_Master={
	{main="s10010"},
	{main="s10020"},
	{main="s10030"},
	{flag={"s10036","s10043","s10033"},
		proceedCount=2},
	{main="s10040"},
	{flag={"s10041","s10044","s10052","s10054"},
		sub={"s10050"},
		defaultClose={s10050=true},
		proceedCount=3,
		condition=function()
			local isBuiltMbMedicalClusterSpecialPlatform
			if TppMotherBaseManagement.IsBuiltMbMedicalClusterSpecialPlatform then
				isBuiltMbMedicalClusterSpecialPlatform=TppMotherBaseManagement.IsBuiltMbMedicalClusterSpecialPlatform()
			else
				isBuiltMbMedicalClusterSpecialPlatform=true
			end
			return isBuiltMbMedicalClusterSpecialPlatform
		end,
		updateTiming={OnMissionStart=true,OnCompletedPlatform=true}},
	{main="s10070",
		defaultClose={s10070=true}},
	{main="s10080"},
	{flag={"s10086"}},
	{flag={"s10082"}},
	{main="s10090",
		condition=function()
			if TppMotherBaseManagement.CanOpenS10091()then
				TppMotherBaseManagement.LockedStaffsS10091()
			end
			return true
		end},
	{flag={"s10091"}},
	{main="s10100",flag={"s10195"}},
	{main="s10110"},
	{flag={"s10121","s10115"},
		defaultClose={s10115=true}},
	{main="s10120"},
	{flag={"s10085","s10200"}},
	{flag={"s10211"},
		condition=function()
			if TppMotherBaseManagement.CanOpenS10130()then
				TppMotherBaseManagement.LockedStaffsS10130()
			end
			if TppMotherBaseManagement.CanOpenS10081()then
				TppMotherBaseManagement.LockedStaffS10081()
			end
			return true
		end},
	{flag={"s10081"}},
	{main="s10130"},
	{main="s10140"},
	{main="s10150"},
	{main="s10151",
		condition=function()
			this.StartElapsedMissionEvent(TppDefine.ELAPSED_MISSION_EVENT.STORY_SEQUENCE,2)
			TppQuest.StartElapsedEvent(1)
			return true
		end},
	{flag={"s10045"},
		sub={"s11043","s11054"},
		condition=function()
			if TppQuest.IsCleard"tent_q99040"then
				this.StartElapsedMissionEvent(TppDefine.ELAPSED_MISSION_EVENT.STORY_SEQUENCE,2)
				TppQuest.StartElapsedEvent(1)
				return true
			end
		end,
		updateTiming={OnSideOpsClear=true,OnMissionStart=true}},
	{flag={"s10093"},
		sub={"s11082","s11090"},
		condition=function()
			return TppQuest.OpenChildSoldier_1()
		end,
		updateTiming={OnSideOpsClear=true,OnMissionStart=true}},
	{flag={"s10156"},
		sub={"s11033","s11050"},
		defaultClose={s11050=true},
		condition=function()
			return(TppQuest.IsCleard"tent_q20910"and TppQuest.IsCleard"fort_q20911")and TppQuest.IsCleard"sovietBase_q20912"
		end,
		updateTiming={OnMissionStart=true,OnSideOpsClear=true}},
	{main="s10171",
		condition=function()
			this.StartElapsedMissionEvent(TppDefine.ELAPSED_MISSION_EVENT.STORY_SEQUENCE,1)
			TppQuest.StartElapsedEvent(3)
			return true
		end},
	{sub={"s11140"},
		condition=function()
			if this.CanOpenS10240()then
				TppMotherBaseManagement.LockedStaffsS10240()
				return true
			else
				return false
			end
		end,
		updateTiming={OnMissionStart=true,OnUpdateCheckPoint=true,OnSideOpsClear=true}},
	{main="s10240",
		defaultClose={s10240=true},
		condition=function()
			this.StartElapsedMissionEvent(TppDefine.ELAPSED_MISSION_EVENT.STORY_SEQUENCE,1)
			TppQuest.StartElapsedEvent(3)
			return true
		end},
	{sub={"s11080"},
		condition=function()
			local n=TppQuest.IsNowOccurringElapsed()
			local t=this.IsNowOccurringElapsedMission(TppDefine.ELAPSED_MISSION_EVENT.STORY_SEQUENCE)
			if n or t then
				this.StartElapsedMissionEvent(TppDefine.ELAPSED_MISSION_EVENT.STORY_SEQUENCE,1)
				TppQuest.StartElapsedEvent(3)
				return true
			end
		end,
		updateTiming={OnMissionStart=true,OnSideOpsClear=true}},
	{sub={"s11121"},
		condition=function()
			local t=TppQuest.IsNowOccurringElapsed()
			local n=this.IsNowOccurringElapsedMission(TppDefine.ELAPSED_MISSION_EVENT.STORY_SEQUENCE)
			if t or n then
				this.SetDoneElapsedMission(TppDefine.ELAPSED_MISSION_EVENT.STORY_SEQUENCE)
				TppQuest.SetDoneElapsed()
				return true
			end
		end,
		updateTiming={OnMissionStart=true,OnSideOpsClear=true}},
	{sub={"s11130","s11044","s11151","s10260","s10280"},
		defaultClose={s10260=true,s10280=true},
		condition=function()
			if this.CanOpenS10280()and(not this.IsMissionOpen(10280))then
				this.MissionOpen(10280)
			end
			if this.IsMissionCleard(10280)then
				return true
			end
		end,
		updateTiming={BeforeBuddyBlockLoad=true}},{},{}
}
this.radioDemoTable={
	AttackedFromOtherPlayer_KnowWhereFrom={
		storyCondition=function()
			return true
		end,
		detailCondition=function()
			return TppDemo.mtbsPriorityFuncList.AttackedFromOtherPlayer_KnowWhereFrom()
		end,
		demoName="AttackedFromOtherPlayer_KnowWhereFrom"
	},
	AttackedFromOtherPlayer_UnknowWhereFrom={
		storyCondition=function()
			return true
		end,
		detailCondition=function()
			return TppDemo.mtbsPriorityFuncList.AttackedFromOtherPlayer_UnknowWhereFrom()
		end,
		demoName="AttackedFromOtherPlayer_UnknowWhereFrom"
	},
	AttackedFromOtherPlayerRadio={
		storyCondition=function(e)
			return e.demoName=="AttackedFromOtherPlayer_UnknowWhereFrom"or e.demoName=="AttackedFromOtherPlayer_KnowWhereFrom"
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f6000_rtrg0500"}
	},
	NuclearEliminationCeremony={
		storyCondition=function()
			return true
		end,
		detailCondition=function()
			return TppDemo.mtbsPriorityFuncList.NuclearEliminationCeremony()
		end,
		demoName="NuclearEliminationCeremony"
	},
	NuclearEliminationCeremonyRadio={
		storyCondition=function(e)
			return e.demoName=="NuclearEliminationCeremony"
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f6000_rtrg0325"}
	},
	EntrustDdog={
		storyCondition=function()
			return this.GetCurrentStorySequence()>=TppDefine.STORY_SEQUENCE.CLEARD_TO_MATHER_BASE
		end,
		detailCondition=function()
			return TppDemo.mtbsPriorityFuncList.EntrustDdog()
		end,
		demoName="EntrustDdog"
	},
	EntrustDdogRadio={
		storyCondition=function(e)
			return e.demoName=="EntrustDdog"
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f6000_rtrg0350"}
	},
	MoraleOfMBIsLow={
		storyCondition=function()
			return true
		end,
		detailCondition=function()
			return TppDemo.mtbsPriorityFuncList.MoraleOfMBIsLow()
		end,
		demoName="MoraleOfMBIsLow"
	},
	MoraleOfMBIsLowRadio={
		storyCondition=function(e)
			return e.demoName=="MoraleOfMBIsLow"
		end,
		detailCondition=function()
			return TppDemo.mtbsPriorityFuncList.MoraleOfMBIsLow()
		end,
		radioList={"f6000_rtrg0370"}
	},
	DdogComeToGet={
		storyCondition=function()
			return vars.missionCode==10040
		end,
		detailCondition=function()
			return TppDemo.mtbsPriorityFuncList.DdogComeToGet()
		end,
		demoName="DdogComeToGet"
	},
	DdogComeToGetRadio={
		storyCondition=function(e)
			return e.demoName=="DdogComeToGet"
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f6000_rtrg0380"}
	},
	DdogGoWithMe={
		storyCondition=function()
			return true
		end,
		detailCondition=function()
			return TppDemo.mtbsPriorityFuncList.DdogGoWithMe()
		end,
		demoName="DdogGoWithMe"
	},
	DdogGoWithMeRadio={
		storyCondition=function(e)
			return e.demoName=="DdogGoWithMe"
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f6000_rtrg0370"}
	},
	HappyBirthDayWithQuiet={
		storyCondition=function()
			return true
		end,
		detailCondition=function()
			TppDemo.UpdateHappyBirthDayFlag()
			local e=TppDemo.mtbsPriorityFuncList.HappyBirthDay()
			local n=TppMbFreeDemo.demoOptions.HappyBirthDay.GetNextDemoNameOrNil()~=nil
			return e and n
		end,
		demoName="HappyBirthDay"
	},
	HappyBirthDay={
		storyCondition=function()
			return true
		end,
		detailCondition=function()
			TppDemo.UpdateHappyBirthDayFlag()
			return TppDemo.mtbsPriorityFuncList.HappyBirthDay()
		end,
		demoName="HappyBirthDay"
	},
	HappyBirthDayRadio={
		storyCondition=function(e)
			return e.demoName=="HappyBirthDay"
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f6000_rtrg0511"}
	},
	QuietTreatment={
		storyCondition=function(e)
			return e.demoName=="ArrivedMotherBaseAfterQuietBattle"
		end,
		detailCondition=function(e)
			local e=not TppRadio.IsPlayed"f2000_rtrg1345"
			local n=TppBuddyService.DidObtainBuddyType(BuddyType.QUIET)
			local i=TppQuest.IsOpen"sovietBase_q99020"
			local t=not TppQuest.IsCleard"sovietBase_q99020"
			return((e and n)and i)and t
		end,
		radioList={"f2000_rtrg1345","f2000_rtrg1347"}
	},
	QuietTreatment2={
		storyCondition=function(e)
			return e.demoName=="ArrivedMotherBaseAfterQuietBattle"
		end,
		detailCondition=function(e)
			local t=not TppRadio.IsPlayed"f2000_rtrg1345"
			local n=TppBuddyService.DidObtainBuddyType(BuddyType.QUIET)
			local e=not TppQuest.IsOpen"sovietBase_q99020"
			local i=TppQuest.IsCleard"sovietBase_q99020"
			return(t and n)and(e or i)
		end,
		radioList={"f2000_rtrg1345","f2000_rtrg1346"}
	},
	QuietReceivesPersecution={
		storyCondition=function()
			local n=vars.missionCode==10085 or vars.missionCode==10200
			local e=this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_WHITE_MAMBA
			return n and e
		end,
		detailCondition=function()
			local n=TppBuddyService.CanSortieBuddyType(BuddyType.QUIET)
			local e=this.CanArrivalQuietInMB(true)
			return e and n
		end,
		demoName="QuietReceivesPersecution"
	},
	QuietReceivesPersecutionRadio={
		storyCondition=function(e)
			return e.demoName=="QuietReceivesPersecution"
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f6000_rtrg0360"}
	},
	QuietHasFriendshipWithChild={
		storyCondition=function()
			local n=this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_RETRIEVE_VOLGIN
			local t=TppQuest.IsNowOccurringElapsed()
			local e=this.GetElapsedMissionCount(TppDefine.ELAPSED_MISSION_EVENT.STORY_SEQUENCE)==1
			return n and(t or e)
		end,
		detailCondition=function()
			return TppDemo.mtbsPriorityFuncList.QuietHasFriendshipWithChild()
		end,
		demoName="QuietHasFriendshipWithChild"
	},
	QuietHasFriendshipWithChildRadio={
		storyCondition=function(e)
			return e.demoName=="QuietHasFriendshipWithChild"
		end,
		detailCondition=function()
			return true
		end,selectRadioFunction=function(e)
			if e.clearSideOpsName then
				return{"f2000_rtrg7350"}
			else
				return{"f6000_rtrg0350"}
			end
		end,
		radioList={"f6000_rtrg0350","f2000_rtrg7350"}
	},
	InterrogateQuiet={
		storyCondition=function()
			local t=TppQuest.IsNowOccurringElapsed()
			local n=this.IsNowOccurringElapsedMission(TppDefine.ELAPSED_MISSION_EVENT.STORY_SEQUENCE)
			local e=this.IsMissionCleard(10093)
			return(n or t)and e
		end,
		detailCondition=function()
			return TppDemo.mtbsPriorityFuncList.InterrogateQuiet()
		end,
		demoName="InterrogateQuiet"
	},
	InterrogateQuietRadio={
		storyCondition=function()
			return this.CanPlayDemoOrRadio"InterrogateQuiet"
		end,
		detailCondition=function(e)
			return true
		end,selectRadioFunction=function(e)
			if e.clearSideOpsName then
				return{"f2000_rtrg7330"}
			else
				return{"f6000_rtrg0330"}
			end
		end,
		radioList={"f6000_rtrg0330","f2000_rtrg7330"}
	},
	QuietPassage={
		storyCondition=function()
			return this.IsMissionCleard(10086)
		end,
		detailCondition=function()
			if TppQuest.IsOpen"mtbs_q99011"then
				local e=not TppQuest.IsCleard"mtbs_q99011"
				if e then
					TppCassette.Acquire{cassetteList={"tp_c_00000_13"},{delayTimeSec=2}}
					TppCassette.Acquire{cassetteList={"tp_m_10050_03"},{delayTimeSec=2}}
				end
				return e
			end
			return false
		end,
		radioList={"f2000_rtrg1350"}
	},
	WalkerGear={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_FLAG_MISSIONS_AFTER_FIND_THE_SECRET_WEAPON
		end,
		detailCondition=function()
			return TppMotherBaseManagement.IsBuiltMbMedicalClusterSpecialPlatform()
		end,
		radioList={"f2000_rtrg8420"}
	},
	WalkerGearRemind={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_FLAG_MISSIONS_AFTER_FIND_THE_SECRET_WEAPON
		end,
		detailCondition=function()
			return this.GetClearedMissionCount{10041,10044,10052,10054}==4
		end,
		radioList={"f2000_rtrg8421"}
	},
	AnableDevBattleGear={
		storyCondition=function()
			return vars.missionCode==10195
		end,
		detailCondition=function()
			return true
		end,
		demoName="AnableDevBattleGear"
	},
	AnableDevBattleGearRadio={
		storyCondition=function()
			return vars.missionCode==10195
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f6000_rtrg0300"}
	},
	AfterAnableDevbattleGear={
		storyCondition=function()
			return TppDemo.IsPlayedMBEventDemo"AnableDevBattleGear"
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg1515"}
	},
	DevelopedBattleGear_1={
		storyCondition=function()
			return vars.missionCode==10121
		end,
		detailCondition=function()
			return this.GetBattleGearDevelopLevel()==1
		end,
		demoName="DevelopedBattleGear1"
	},
	DevelopedBattleGear_1Radio={
		storyCondition=function()
			return this.CanPlayDemoOrRadio"DevelopedBattleGear_1"
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f6000_rtrg0400"}
	},
	OpenFindTheSecretWeapon={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_FLAG_MISSIONS_AFTER_TO_MATHER_BASE
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8030"}
	},
	CleardFindTheSecretWeapon={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8060"}
	},
	CleardToMotherBase={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_TO_MATHER_BASE
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8000"}
	},
	OpenPicthDark={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_RESCUE_HUEY
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8090"}
	},
	ZeroAndScalFace={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_RESCUE_HUEY
		end,
		detailCondition=function()
			local n=TppRadio.IsPlayed"f2000_rtrg8090"
			local e=TppMission.IsHelicopterSpace(vars.missionCode)
			return n and e
		end,
		radioList={"f2000_rtrg8100"}
	},
	OpenLinguaFranka={
		storyCondition=function()
			return this.IsMissionCleard(10080)and this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_DESTROY_THE_FLOW_STATION
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8115"}
	},
	OpenRemovalWalkerGear={
		storyCondition=function()
			return this.IsMissionCleard(10086)and this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_LINGUA_FRANKA
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8120"}
	},
	OpenCarLine={
		storyCondition=function()
			return this.IsMissionCleard(10082)and this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_FLAG_MISSIONS_AFTER_DESTROY_THE_FLOW_STATION
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8130"}
	},
	OpenRescueIntelAgents={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_TAKE_OUT_THE_CONVOY
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8140"}
	},
	OpenEliminateThePows={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_RESCUE_INTEL_AGENTS
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8150"}
	},
	OpenVoice={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_ELIMINATE_THE_POWS
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8160"}
	},
	OpenCaptureTheWeaponDealer={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_DEATH_FACTORY
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8180"}
	},
	OpenWhiteMamba={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_CAPTURE_THE_WEAPON_DEALER
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8185"}
	},
	OpenFlagMissionAfterWhiteMamba={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_WHITE_MAMBA
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8440"}
	},
	GeneOfEli={
		storyCondition=function()
			return(this.IsMissionCleard(10085)or this.IsMissionCleard(10200))and this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_WHITE_MAMBA
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8200"}
	},
	ParasiticWormCarrierQuarantine={
		storyCondition=function()
			local n=vars.missionCode==10085 or vars.missionCode==10200
			local e=this.GetClearedMissionCount{10085,10200}==2
			local t=not TppMotherBaseManagement.IsPandemicEventMode()
			return(n and e)and t
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f6000_rtrg0310"}
	},
	OpenHuntDown={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_FLAG_MISSIONS_AFTER_WHITE_MAMBA
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8210"}
	},
	OpenEliChallengeAndRootCause={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_ELIMINATE_THE_COMMANDER
		end,
		detailCondition=function()
			if TppQuest.IsOpen"mtbs_q99050"then
				this.radioDemoTable.OpenEliChallengeAndRootCause.
					radioList={"f2000_rtrg8190","f2000_rtrg8220"}
			else
				this.radioDemoTable.OpenEliChallengeAndRootCause.
					radioList={"f2000_rtrg8220"}
			end
			return true
		end,
		radioList={"f2000_rtrg8220"}
	},
	OpenEliChallenge={
		storyCondition=function()
			return this.GetCurrentStorySequence()>=TppDefine.STORY_SEQUENCE.CLEARD_ELIMINATE_THE_COMMANDER
		end,
		detailCondition=function()
			return TppQuest.IsOpen"mtbs_q99050"and(not TppQuest.IsCleard"mtbs_q99050")
		end,
		radioList={"f2000_rtrg8190"}
	},
	ClearEliChallenge={
		storyCondition=function(e)
			return e.clearSideOpsName=="mtbs_q99050"
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg1500"}
	},
	OpenCodeTalker={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_RESCUE_THE_BETRAYER
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8230"}
	},
	OpenMetallicArchaea={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_CODE_TALKER
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8240"}
	},
	OpenFlagMissionAfterOKBZERO={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8260"}
	},
	CanDevelopNuclear={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO
		end,
		detailCondition=function()
			return TppMission.IsHelicopterSpace(vars.missionCode)
		end,
		radioList={"f2000_rtrg8261"}
	},
	RafeAccidentalDeath={
		storyCondition=function()
			local t=this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO
			local n=TppQuest.IsNowOccurringElapsed()
			local e=this.GetElapsedMissionCount(TppDefine.ELAPSED_MISSION_EVENT.STORY_SEQUENCE)==1
			return t and(n or e)
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8280"}
	},
	OpenSideOpsAiPod={
		storyCondition=function()
			local i=this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO
			local t=TppQuest.IsNowOccurringElapsed()
			local n=this.IsNowOccurringElapsedMission(TppDefine.ELAPSED_MISSION_EVENT.STORY_SEQUENCE)
			local e=this.IsMissionCleard(10045)
			return((t or n)and e)and i
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8270"}
	},
	EliLookSnake={
		storyCondition=function()
			return this.CanPlayDemoOrRadio"RafeAccidentalDeath"
		end,
		detailCondition=function()
			return true
		end,
		demoName="EliLookSnake"
	},
	EliLookSnakeRadio={
		storyCondition=function()
			return this.CanPlayDemoOrRadio"RafeAccidentalDeath"
		end,
		detailCondition=function()
			return true
		end,selectRadioFunction=function(e)
			if e.clearSideOpsName then
				return{"f2000_rtrg7325"}
			else
				return{"f6000_rtrg0325"}
			end
		end,
		radioList={"f6000_rtrg0325","f2000_rtrg7325"}
	},
	CompliteDevelopBattleGear={
		storyCondition=function()
			return this.CanPlayDemoOrRadio"OpenSideOpsAiPod"
		end,
		detailCondition=function()
			return true
		end,
		demoName="DevelopedBattleGear5"
	},
	CompliteDevelopBattleGearRadio={
		storyCondition=function()
			return this.CanPlayDemoOrRadio"CompliteDevelopBattleGear"
		end,
		detailCondition=function(e)
			return true
		end,selectRadioFunction=function(e)
			if e.clearSideOpsName then
				return{"f2000_rtrg7120"}
			else
				return{"f6000_rtrg2120"}
			end
		end,
		radioList={"f6000_rtrg2120","f2000_rtrg7120"}
	},
	AfterCompliteDevelopBattleGear={
		storyCondition=function(e)
			return e.demoName=="DevelopedBattleGear5"
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg1517"}
	},
	LiquidAndChildSoldier={
		storyCondition=function()
			local n=vars.missionCode==10045 or vars.missionCode==10156
			local e=this.GetClearedMissionCount{10045,10156}==2
			return n and e
		end,
		detailCondition=function()
			return true
		end,
		demoName="LiquidAndChildSoldier"
	},
	RetrieveAIPod={
		storyCondition=function(e)
			return e.clearSideOpsName=="sovietBase_q99030"
		end,
		detailCondition=function()
			TppQuest.OpenAndActivateSpecialQuest{"tent_q99040"}
			return true
		end,
		radioList={"f2000_rtrg1530","f2000_rtrg1540"}
	},
	AfterRetrieveVolgin={
		storyCondition=function(e)
			return e.clearSideOpsName=="tent_q99040"
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8450"}
	},
	CorpseInAIPod={
		storyCondition=function()
			local t=this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_RETRIEVE_VOLGIN
			local n=TppQuest.IsNowOccurringElapsed()
			local e=this.GetElapsedMissionCount(TppDefine.ELAPSED_MISSION_EVENT.STORY_SEQUENCE)==1
			return t and(n or e)
		end,
		detailCondition=function()
			TppCassette.Acquire{cassetteList={"tp_m_10190_01"
				},
				isShowAnnounceLog={delayTimeSec=2}}
			return true
		end,
		radioList={"f2000_rtrg8370"}
	},
	StartQuestChildSoldier={
		storyCondition=function()
			return TppQuest.OpenChildSoldier_1()
		end,
		detailCondition=function()
			TppCassette.Acquire{cassetteList={"tp_m_10160_05"
				},
				isShowAnnounceLog={delayTimeSec=2}}
			return true
		end,
		radioList={"f2000_rtrg8451","f2000_rtrg8290"}
	},
	ProgressQuestChildSoldier={
		storyCondition=function()
			local n=TppQuest.IsCleard"outland_q20913"and TppQuest.IsCleard"lab_q20914"
			local e=not((TppQuest.IsOpen"tent_q20910"and TppQuest.IsOpen"fort_q20911")and TppQuest.IsOpen"sovietBase_q20912")
			return n and e
		end,
		detailCondition=function()
			TppQuest.OpenAndActivateSpecialQuest{"tent_q20910","fort_q20911","sovietBase_q20912"}
			return true
		end,
		radioList={"f2000_rtrg8310"}
	},
	LeakRadiationInMB={
		storyCondition=function()
			local e=this.IsMissionCleard(10156)
			local n=(TppQuest.IsCleard"tent_q20910"and TppQuest.IsCleard"fort_q20911")and TppQuest.IsCleard"sovietBase_q20912"
			return e or n
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8380"}
	},
	OpenProxyWar={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_FLAG_MISSIONS_BEFORE_ENDRESS_PROXY_WAR
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8452"}
	},
	EliImprisonment={
		storyCondition=function()
			return this.CanPlayDemoOrRadio"TheGreatEscapeLiquid"
		end,
		detailCondition=function(e)
			return true
		end,selectRadioFunction=function(e)
			if e.clearSideOpsName then
				return{"f2000_rtrg7332"}
			else
				return{"f6000_rtrg0332"}
			end
		end,
		radioList={"f6000_rtrg0332","f2000_rtrg7332"}
	},
	TheGreatEscapeLiquid={
		storyCondition=function()
			return vars.missionCode==10171
		end,
		detailCondition=function()
			return(not TppDemo.IsPlayedMBEventDemo"TheGreatEscapeLiquid")
		end,
		demoName="TheGreatEscapeLiquid"
	},
	AfterTheGreatEscapeLiquid={
		storyCondition=function(e)
			return e.demoName=="TheGreatEscapeLiquid"
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8350"}
	},
	OpenMissionAfterTheGreatEscapeLiquid={
		storyCondition=function()
			return TppDemo.IsPlayedMBEventDemo"TheGreatEscapeLiquid"
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8453"}
	},
	ReasonSahelanMove={
		storyCondition=function()
			return TppDemo.IsPlayedMBEventDemo"TheGreatEscapeLiquid"
		end,
		detailCondition=function()
			if TppMission.IsHelicopterSpace(vars.missionCode)then
				TppCassette.Acquire{cassetteList={"tp_m_10190_02"
					},
					isShowAnnounceLog={delayTimeSec=2}}
				return true
			end
			return false
		end,
		radioList={"f2000_rtrg8360"}
	},
	PermitParasiticWormCarrierKill={
		storyCondition=function()
			return this.CanPlayDemoOrRadio"ParasiticWormCarrierKill"
		end,
		detailCondition=function(e)
			return true
		end,selectRadioFunction=function(e)
			if e.clearSideOpsName then
				return{"f2000_rtrg7335"}
			else
				return{"f6000_rtrg0335"}
			end
		end,
		radioList={"f6000_rtrg0335","f2000_rtrg7335"}
	},
	OpenParasiticWormCarrierKill={
		storyCondition=function()
			return TppDemo.IsPlayedMBEventDemo"ParasiticWormCarrierKill"
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f2000_rtrg8391"}
	},
	ParasiticWormCarrierKill={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_FLAG_MISSIONS_BEFORE_MURDER_INFECTORS
		end,
		detailCondition=function()
			return(not TppDemo.IsPlayedMBEventDemo"ParasiticWormCarrierKill")
		end,
		demoName="ParasiticWormCarrierKill"
	},
	AfterParasiticWormCarrierKillFree={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_MURDER_INFECTORS
		end,
		detailCondition=function()
			this.StartElapsedMissionEvent(TppDefine.ELAPSED_MISSION_EVENT.DECISION_HUEY,TppDefine.INIT_ELAPSED_MISSION_COUNT.DECISION_HUEY)
			return true
		end,
		radioList={"f2000_rtrg8900"}
	},
	AfterParasiticWormCarrierKillHeli={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_AFTER_MURDER_INFECTORS_ONE_MISSION
		end,
		detailCondition=function()
			TppCassette.Acquire{cassetteList={"tp_m_10190_03"
				},
				isShowAnnounceLog={delayTimeSec=2}}
			if TppBuddy2BlockController.DidObtainBuddyType(BuddyType.DOG)then
				TppCassette.Acquire{cassetteList={"tp_m_10190_04"
					},
					isShowAnnounceLog={delayTimeSec=2}}
			end
			return true
		end,
		radioList={"f2000_rtrg8400"}
	},
	OpenDecisionHuey={
		storyCondition=function()
			return this.CanPlayDemoOrRadio"DecisionHuey"
		end,
		detailCondition=function(e)
			return true
		end,selectRadioFunction=function(e)
			if e.clearSideOpsName then
				return{"f2000_rtrg7338"}
			else
				return{"f6000_rtrg0338"}
			end
		end,
		radioList={"f6000_rtrg0338","f2000_rtrg7338"}
	},
	DecisionHuey={
		storyCondition=function()
			return this.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_AFTER_MURDER_INFECTORS_TWO_MISSIONS
		end,
		detailCondition=function()
			return(not TppDemo.IsPlayedMBEventDemo"DecisionHuey")
		end,
		demoName="DecisionHuey"
	},
	OpenQuietLost={
		storyCondition=function()
			return true
		end,
		detailCondition=function()
			if vars.missionCode==30050 then
				return false
			end
			return TppBuddyService.CheckBuddyCommonFlag(BuddyCommonFlag.BUDDY_QUIET_LOST)
		end,
		radioList={"f2000_rtrg2000","f2000_rtrg2010"}
	},
	AboutHeliSpace={
		storyCondition=function()
			return this.IsMissionCleard(10030)
		end,
		detailCondition=function()
			return TppMission.IsHelicopterSpace(TppMission.GetMissionID())
		end,
		radioList={"f2000_rtrg1010"}
	},
	AboutSideOps={
		storyCondition=function()
			if(this.GetClearedMissionCount{10036,10043,10033}==1)then
				return true
			end
			return false
		end,
		detailCondition=function()
			return((TppMission.GetMissionID()~=30050)and(TppMission.GetMissionID()~=30150))and(TppMission.GetMissionID()~=30250)
		end,
		radioList={"f1000_rtrg4030"}
	},
	AboutQuietSniper={
		storyCondition=function()
			return TppQuest.IsOpen"waterway_q99010"and not(this.IsMissionOpen(10050))
		end,
		detailCondition=function()
			local e=TppMission.IsFreeMission(TppMission.GetMissionID())and TppLocation.IsAfghan()
			if e then
				TppCassette.Acquire{cassetteList={"tp_m_10050_01"
					},
					isShowAnnounceLog={delayTimeSec=2}}
				return true
			end
		end,
		radioList={"f2000_rtrg1330"}
	},
	AboutGunsmith_B={
		storyCondition=function()
			return TppQuest.IsActive"sovietBase_q99070"
		end,
		detailCondition=function()
			return((TppMission.GetMissionID()~=30050)and(TppMission.GetMissionID()~=30150))and(TppMission.GetMissionID()~=30250)
		end,
		radioList={"f1000_rtrg5100"}
	},
	AboutGunsmith_Master={
		storyCondition=function()
			return TppQuest.IsActive"tent_q99072"
		end,
		detailCondition=function()
			return((TppMission.GetMissionID()~=30050)and(TppMission.GetMissionID()~=30150))and(TppMission.GetMissionID()~=30250)
		end,
		radioList={"f1000_rtrg5110"}
	},
	AboutAnalyzer={
		storyCondition=function()
			if Player.GetItemLevel(TppEquip.EQP_IT_Binocle)>1 then
				return true
			end
			return false
		end,
		detailCondition=function()
			return((TppMission.GetMissionID()~=30050)and(TppMission.GetMissionID()~=30150))and(TppMission.GetMissionID()~=30250)
		end,
		radioList={"f1000_rtrg5120"}
	},
	SuggestActiveSonar={
		storyCondition=function()
			return(TppMotherBaseManagement.IsEquipDevelopableWithDevelopID{equipDevelopID=18030})and not(TppMotherBaseManagement.IsEquipDeveloped{equipID=TppEquip.EQP_HAND_ACTIVESONAR})
		end,
		detailCondition=function()
			return((TppMission.GetMissionID()~=30050)and(TppMission.GetMissionID()~=30150))and(TppMission.GetMissionID()~=30250)
		end,
		radioList={"f1000_rtrg4550"}
	},
	UnlockBuddyDog={
		storyCondition=function()
			return TppDemo.IsPlayedMBEventDemo"DdogGoWithMe"
		end,
		detailCondition=function()
			return TppMission.IsHelicopterSpace(TppMission.GetMissionID())
		end,
		radioList={"f2000_rtrg1410"}
	},
	UnlockBuddyQuiet={
		storyCondition=function()
			return this.CanArrivalQuietInMB(true)and TppBuddyService.CanSortieBuddyType(BuddyType.QUIET)
		end,
		detailCondition=function()
			return TppMission.IsHelicopterSpace(TppMission.GetMissionID())
		end,
		radioList={"f1000_rtrg4590"}
	},
	AboutCallBuddy={
		storyCondition=function()
			return TppBuddyService.CanSortieBuddyType(BuddyType.DOG)or TppBuddyService.CanSortieBuddyType(BuddyType.QUIET)
		end,
		detailCondition=function()
			local t=0
			local n=1
			local e=TppBuddy2BlockController.GetActiveBuddyType()
			if(e==t or e==n)then
				if((TppMission.GetMissionID()~=30050)and(TppMission.GetMissionID()~=30150))and(TppMission.GetMissionID()~=30250)then
					return true
				end
			end
			return false
		end,
		radioList={"f1000_rtrg4560","f1000_rtrg4570"}
	},
	AboutBuddyDog={
		storyCondition=function()
			return TppBuddyService.CanSortieBuddyType(BuddyType.DOG)
		end,
		detailCondition=function()
			return TppMission.IsHelicopterSpace(TppMission.GetMissionID())
		end,
		radioList={"f1000_rtrg4580"}
	},
	UnlockIntelSearch={
		storyCondition=function()
			return TppMotherBaseManagement.IsActiveSectionFunc{sectionFuncId=TppMotherBaseManagementConst.SECTION_FUNC_ID_SPY_ENEMY_SEARCH}
		end,
		detailCondition=function()
			return((TppMission.GetMissionID()~=30050)and(TppMission.GetMissionID()~=30150))and(TppMission.GetMissionID()~=30250)
		end,
		radioList={"f2000_rtrg1300"}
	},
	UnlockSupportFire={
		storyCondition=function()
			return TppMotherBaseManagement.IsActiveSectionFunc{sectionFuncId=TppMotherBaseManagementConst.SECTION_FUNC_ID_SUPPORT_STRIKE}
		end,
		detailCondition=function()
			return((TppMission.GetMissionID()~=30050)and(TppMission.GetMissionID()~=30150))and(TppMission.GetMissionID()~=30250)
		end,
		radioList={"f2000_rtrg1310"}
	},
	AntiNuclearDeterrence={
		storyCondition=function()
			return TppHero.IsHero()
		end,
		detailCondition=function()
			return TppMission.IsHelicopterSpace(TppMission.GetMissionID())
		end,
		radioList={"f2000_rtrg1520"}
	},
	NuclearWorld={
		storyCondition=function()
			local t=TppServerManager.GetNuclearAbolitionCount()
			local n=TppServerManager.GetNuclearNum()
			local e=TppDemo.IsPlayedMBEventDemo"NuclearEliminationCeremony"if(t~=-1)then
				if(e)and(n>0)then
					return true
				end
			end
			return false
		end,
		detailCondition=function()
			return TppMission.IsHelicopterSpace(TppMission.GetMissionID())
		end,
		radioList={"f2000_rtrg1525"}
	},
	MotherBaseBurnOut={
		storyCondition=function()
			if(TppMotherBaseManagement.GetGmp()<0)then
				return true
			end
			return false
		end,
		detailCondition=function()
			return TppMission.IsHelicopterSpace(TppMission.GetMissionID())
		end,
		radioList={"f2000_rtrg1080"}
	},
	HowToPlayFreePlay={
		storyCondition=function()
			return true
		end,
		detailCondition=function()
			local n=Player.GetGameObjectIdIsRiddenToLocal()
			local e=7168
			if n~=e then
				if not(TppMission.IsHelicopterSpace(TppMission.GetMissionID()))then
					if(TppLocation.IsAfghan()or TppLocation.IsMiddleAfrica())then
						return true
					end
				end
			end
			return false
		end,
		radioList={"f2000_rtrg0010"}
	},
	GeneralPurposeRadio={
		storyCondition=function(e)
			if e.demoName then
				return true
			end
			return false
		end,
		detailCondition=function()
			return true
		end,
		radioList={"f6000_rtrg0325"}
	}
}

this.eventPlayTimmingTable={blackTelephone={{true,"OpenDecisionHuey"},{true,"EliImprisonment"},{false,"QuietReceivesPersecutionRadio"},{true,"PermitParasiticWormCarrierKill"},{true,"InterrogateQuietRadio"},{false,"QuietHasFriendshipWithChildRadio"},{true,"AnableDevBattleGearRadio"},{true,"ParasiticWormCarrierQuarantine"},{true,"CompliteDevelopBattleGearRadio"},{true,"DevelopedBattleGear_1Radio"},{true,"EliLookSnakeRadio"},{false,"EntrustDdogRadio"},{false,"DdogComeToGetRadio"},{false,"DdogGoWithMeRadio"},{false,"HappyBirthDayRadio"},{false,"AttackedFromOtherPlayerRadio"},{false,"NuclearEliminationCeremonyRadio"},{false,"MoraleOfMBIsLowRadio"},{false,"GeneralPurposeRadio"}},clearSideOpsForceMBDemo={{true,"DecisionHuey"},{true,"ParasiticWormCarrierKill"},{true,"TheGreatEscapeLiquid"},{true,"InterrogateQuiet"},{true,"QuietHasFriendshipWithChild"},{true,"CompliteDevelopBattleGear"},{true,"EliLookSnake"}},clearSideOpsForceMBRadio={{true,"OpenDecisionHuey"},{true,"PermitParasiticWormCarrierKill"},{true,"EliImprisonment"},{true,"InterrogateQuietRadio"},{true,"CompliteDevelopBattleGearRadio"},{true,"EliLookSnakeRadio"},{true,"QuietHasFriendshipWithChildRadio"}},forceMBDemo={{true,"DecisionHuey"},{true,"EliLookSnake"},{true,"QuietReceivesPersecution"},{true,"InterrogateQuiet"},{true,"QuietHasFriendshipWithChild"},{true,"AnableDevBattleGear"},{true,"TheGreatEscapeLiquid"},{true,"ParasiticWormCarrierKill"},{true,"CompliteDevelopBattleGear"},{true,"DevelopedBattleGear_1"},{true,"EntrustDdog"},{true,"DdogComeToGet"},{true,"DdogGoWithMe"},{true,"HappyBirthDayWithQuiet"},{true,"HappyBirthDay"},{true,"AttackedFromOtherPlayer_KnowWhereFrom"},{true,"AttackedFromOtherPlayer_UnknowWhereFrom"},{false,"NuclearEliminationCeremony"},{true,"MoraleOfMBIsLow"}},afterMBDemo={{true,"AfterTheGreatEscapeLiquid"},{true,"QuietTreatment"},{true,"QuietTreatment2"},{true,"AfterCompliteDevelopBattleGear"}},clearSideOps={{true,"AfterParasiticWormCarrierKillHeli"},{true,"RetrieveAIPod"},{true,"AfterRetrieveVolgin"},{true,"ClearEliChallenge"},{true,"ProgressQuestChildSoldier"},{true,"LeakRadiationInMB"},{true,"OpenProxyWar"}},freeHeliRadio={{true,"OpenQuietLost"},{true,"AfterParasiticWormCarrierKillFree"},{true,"AfterParasiticWormCarrierKillHeli"},{true,"ReasonSahelanMove"},{true,"OpenParasiticWormCarrierKill"},{true,"OpenMissionAfterTheGreatEscapeLiquid"},{true,"RafeAccidentalDeath"},{true,"OpenSideOpsAiPod"},{true,"OpenFindTheSecretWeapon"},{true,"OpenPicthDark"},{true,"ZeroAndScalFace"},{true,"OpenLinguaFranka"},{true,"OpenRemovalWalkerGear"},{true,"OpenCarLine"},{true,"OpenRescueIntelAgents"},{true,"OpenEliminateThePows"},{true,"OpenVoice"},{true,"OpenCaptureTheWeaponDealer"},{true,"OpenWhiteMamba"},{true,"OpenFlagMissionAfterWhiteMamba"},{true,"GeneOfEli"},{true,"OpenCodeTalker"},{true,"WalkerGear"},{true,"WalkerGearRemind"},{true,"QuietPassage"},{true,"CleardFindTheSecretWeapon"},{true,"CleardToMotherBase"},{true,"OpenHuntDown"},{true,"OpenEliChallengeAndRootCause"},{true,"OpenMetallicArchaea"},{true,"OpenFlagMissionAfterOKBZERO"},{true,"CanDevelopNuclear"},{true,"CorpseInAIPod"},{true,"StartQuestChildSoldier"},{true,"LeakRadiationInMB"},{true,"OpenProxyWar"},{true,"ProgressQuestChildSoldier"},{true,"OpenEliChallenge"},{true,"AboutHeliSpace"},{true,"AboutSideOps"},{true,"AboutQuietSniper"},{true,"AboutGunsmith_B"},{true,"AboutGunsmith_Master"},{true,"AboutAnalyzer"},{true,"SuggestActiveSonar"},{true,"UnlockBuddyDog"},{true,"UnlockBuddyQuiet"},{true,"AboutCallBuddy"},{true,"AboutBuddyDog"},{true,"UnlockIntelSearch"},{true,"UnlockSupportFire"},{true,"AntiNuclearDeterrence"},{true,"NuclearWorld"},{false,"MotherBaseBurnOut"},{true,"HowToPlayFreePlay"}}}
this.PLAY_DEMO_END_MISSION={[10010]=true,[10030]=true,[10050]=true,[10070]=true,[10100]=true,[10110]=true,[10120]=true,[10130]=true,[10140]=true,[10150]=true,[10151]=true,[10240]=true,[10260]=true,[10280]=true,[10230]=true,[11050]=true,[11070]=true,[11100]=true,[11110]=true,[11130]=true,[11140]=true,[11150]=true,[11151]=true,[11240]=true,[11260]=true,[11280]=true,[11230]=true}
function this.GetCurrentStorySequence()

	--rX4 Tried resetting story sequence, failed miserably

	-- Reset save file to NG+
	-- nope not good approach
	-- Weapons dev fucked up; some develop even when requirements are not met, others don't; confirmed - not because of changes to EquipDevelopConstSetting
	-- Radio dialogue missing as already triggered/set in original save file
	-- Med platform construction broken
	-- Cutscenes already set as played in save file
	-- Emblems stay unlocked though
	-- Weapons and base colors stay
	-- Staff lost
	-- Database saved i.e animals, codenames, key items etc
	-- Missions cleared
	-- SideOps retained
	-- Cassettes retained
	-- Buddies retained
	-- Quarantine unlocked in Staff tab as story sequence is reversed
	-- Weapon customization unlocked
	-- Buddy cutomization unlocked
	-- Vehicle customization unlocked
	-- Tutorials disabled as already set as complete
	-- Resources retained
	-- By default all MB units unlocked except Security and Combat(unlocked after Mission 8)
	-- Key Dispatch missions re-enabled
	-- Dispatch missions seem to be dependent on you're Heroism and not on MB level
	-- FOBs lost and as a result max MB staff count reset to 700
	-- Active Sonar radio plays
	-- Mission 11 Cloacked in Silence permanently broken; that is as far as this new game plus mod goes

	--rX4 Tried resetting story sequence, failed miserably
	--Startup game, start Mission 1, after checkpoint, quit and revert mod
	--  gvars.str_storySequence=TppDefine.STORY_SEQUENCE.CLEARD_ESCAPE_THE_HOSPITAL
	--
	----  if vars.missionCode~=1
	----    or vars.missionCode~=5
	----    or vars.missionCode~=60000
	----  then
	----    for index, value in pairs(gvars.str_missionClearedFlag) do
	----      TUPPMLog.Log("index: "..tostring(index)..", value: "..tostring(value))
	----      gvars.str_missionClearedFlag[index]=false
	----    end
	--
	--    for e=1,TppDefine.MISSION_COUNT_MAX do
	--      if e~=1 then
	--        gvars.str_missionOpenPermission[e]=false
	--        gvars.str_missionOpenFlag[e]=false
	--      end
	--      gvars.str_missionClearedFlag[e]=false
	--      gvars.str_missionNewOpenFlag[e]=true
	--    end
	--
	-- does nothing to side ops when all set to true or false :/
	--    for n,e in ipairs(TppDefine.QUEST_INDEX)do
	--      gvars.qst_questOpenFlag[e]=true
	--      gvars.qst_questActiveFlag[e]=true
	--      gvars.qst_questClearedFlag[e]=true
	--      gvars.qst_questRepopFlag[e]=true
	--    end

	--  end
	--  TUPPMLog.Log("Story sequence: "..tostring(gvars.str_storySequence))
	return gvars.str_storySequence
		--rX4 Tried resetting story sequence, failed miserably
		--  return TppDefine.STORY_SEQUENCE.STORY_FINISH --nope not good enough
end
function this.IncrementStorySequence()
	gvars.str_storySequence=gvars.str_storySequence+1
end
function this.PermitMissionOpen(e)
	local e=TppDefine.MISSION_ENUM[tostring(e)]
	if e then
		gvars.str_missionOpenPermission[e]=true
	end
end
function this.MissionOpen(n)
	this.SetMissionOpenFlag(n,true)
	TppCassette.AcquireOnMissionOpen(n)
	this.EnableMissionNewOpenFlag(n)
end
function this.MissionClose(n)
	this.SetMissionOpenFlag(n,false)
end
function this.SetMissionOpenFlag(e,t)
	local e=TppDefine.MISSION_ENUM[tostring(e)]
	if e then
		local n=gvars.str_missionOpenPermission[e]
		if n then
			gvars.str_missionOpenFlag[e]=t
		end
	end
end
function this.IsMissionOpen(e)
	local e=TppDefine.MISSION_ENUM[tostring(e)]
	if e then
		return gvars.str_missionOpenFlag[e]
	end
end
function this.IsMissionCleard(missionCode)
	local missionCodeEnumId=TppDefine.MISSION_ENUM[tostring(missionCode)]
	if missionCodeEnumId then
		return gvars.str_missionClearedFlag[missionCodeEnumId]
	end
end
function this.CheckAllMissionCleared()
	local o=true
	local s=true
	local a=true
	local d=true
	local r=true
	local i=true
	for e,n in pairs(TppDefine.MISSION_ENUM)do
		local t=TppDefine.MISSING_NUMBER_MISSION_ENUM[e]
		if not t then
			local t=tonumber(e)
			if(not gvars.str_missionClearedFlag[n])then
				if TppDefine.HARD_MISSION_ENUM[e]then
					r=false
				else
					a=false
				end
				o=false
			end
			local n=true
			local r={[10240]=true,[10115]=true,[10030]=true}
			if r[t]then
				n=false
			end
			if n and(TppResult.GetBestRank(t)~=TppDefine.MISSION_CLEAR_RANK.S)then
				if TppDefine.HARD_MISSION_ENUM[e]then
					i=false
				else
					d=false
				end
				s=false
			end
		end
	end
	return o,s,a,d,r,i
end
function this.CalcAllMissionClearedCount()
	local n=0
	local e=0
	for t,r in pairs(TppDefine.MISSION_ENUM)do
		local i=TppDefine.MISSING_NUMBER_MISSION_ENUM[t]
		if not i then
			local t=tonumber(t)
			if(gvars.str_missionClearedFlag[r])then
				n=n+1
			end
			e=e+1
		end
	end
	return n,e
end
function this.CalcAllMissionTaskCompletedCount()
	local n=0
	local e=0
	for t,i in pairs(TppDefine.MISSION_ENUM)do
		local i=TppDefine.MISSING_NUMBER_MISSION_ENUM[t]
		if not i then
			local t=tonumber(t)
			n=n+TppUI.GetTaskCompletedNumber(t)
			e=e+TppUI.GetMaxMissionTask(t)
		end
	end
	return n,e
end
function this.UpdateMissionCleardFlag(missionCode)
	local missionCodeEnum=TppDefine.MISSION_ENUM[tostring(missionCode)]
	if missionCodeEnum then
		gvars.str_missionClearedFlag[missionCodeEnum]=true
		TppCassette.AcquireOnMissionClear(missionCode)
		TppEmblem.AcquireOnMissionClear(missionCode)
		TppTerminal.AddUniqueVolunteerStaff(missionCode)
		TppTrophy.UnlockOnMissionClear(missionCode)
	end
end
function this.CloseEmergencyMission()
	for e,e in ipairs(TppDefine.EMERGENCY_MISSION_LIST)do
	end
end
function this.GetStorySequenceName(e)
	return TppDefine.STORY_SEQUENCE_LIST[e+1]
end
function this.GetStorySequenceTable(currentStorySequence)
	return this.storySequenceTable[currentStorySequence+1]
end
function this.GetCurrentStorySequenceTable()
	local n=this.GetCurrentStorySequence()
	local e=this.GetStorySequenceTable(n)
	return e
end
function this.IsMainMission()
	for e,n in pairs(this.storySequenceTable)do
		local e=0
		if n.main then
			e=TppMission.ParseMissionName(n.main)
		end
		if e==vars.missionCode then
			return true
		end
	end
	return false
end
function this.GetOpenMissionCount()
	local e=0
	for n=0,TppDefine.MISSION_COUNT_MAX do
		if gvars.str_missionOpenFlag[n]then
			e=e+1
		end
	end
	return e
end
function this.GetClearedMissionCount(t)
	local n=0
	for i,r in ipairs(t)do
		if this.IsMissionCleard(t[i])==true then
			n=n+1
		end
	end
	return n
end
function this.GetElapsedMissionEventName(e)
	return TppDefine.ELAPSED_MISSION_EVENT_LIST[e+1]
end
function this.StartElapsedMissionEvent(t,n)
	if not this.GetElapsedMissionEventName(t)then
		return
	end
	if not Tpp.IsTypeNumber(n)then
		return
	end
	if n<1 or n>128 then
		return
	end
	gvars.str_elapsedMissionCount[t]=n
end
function this.GetElapsedMissionCount(n)
	if not this.GetElapsedMissionEventName(n)then
		return
	end
	local e=gvars.str_elapsedMissionCount[n]
	return e
end
function this.IsNowOccurringElapsedMission(n)
	if not this.GetElapsedMissionEventName(n)then
		return
	end
	if gvars.str_elapsedMissionCount[n]==TppDefine.ELAPSED_MISSION_COUNT.NOW_OCCURRING then
		return true
	else
		return false
	end
end
function this.SetDoneElapsedMission(n)
	if not TppDefine.ELAPSED_MISSION_EVENT_LIST[n+1]then
		return
	end
	if this.IsNowOccurringElapsedMission(n)then
		gvars.str_elapsedMissionCount[n]=TppDefine.ELAPSED_MISSION_COUNT.DONE_EVENT
	else
		if gvars.str_elapsedMissionCount[n]>TppDefine.ELAPSED_MISSION_COUNT.NOW_OCCURRING then
		end
	end
end
function this.SetMissionClearedS10030()
	gvars.isMissionClearedS10030=this.IsMissionCleard(10030)
end
function this.CanOccurRetakeThePlatform()
	local n={[10121]=true}
	local n=n[vars.missionCode]
	if not n then
		return false
	end
	if TppTerminal.IsCleardRetakeThePlatform()then
		return false
	end
	local n=true
	local e=this.GetElapsedMissionCount(TppDefine.ELAPSED_MISSION_EVENT.FAILED_RETAKE_THE_PLATFORM)
	if(e==TppDefine.ELAPSED_MISSION_COUNT.INIT)then
		if vars.missionCode==10121 then
			return true
		end
	end
	return false
end
function this.OpenRetakeThePlatform()
	--TUPPMLog.Log("TppMotherBaseManagement.CanOpenS10115{section=\"Develop\"}:"..tostring(TppMotherBaseManagement.CanOpenS10115{section="Develop"}),3,true)
	if TppMotherBaseManagement.CanOpenS10115{section="Develop"}then
		TppMotherBaseManagement.LockedStaffsS10115{section="Develop"}
	end
	this.MissionOpen(10115)
	TppMotherBaseManagement.CompletedClusterBuild{base="MotherBase",category="Develop",grade=1}
	TppRadio.Play"f1000_rtrg1010"
	TppUI.ShowEmergencyAnnounceLog()
	TppUI.ShowAnnounceLog"missionListUpdate"
end
function this.CheckAndOpenRetakeThePlatform()
	--TUPPMLog.Log("this.CanOccurRetakeThePlatform():"..tostring(this.CanOccurRetakeThePlatform()),3,true)
	--TUPPMLog.Log("not this.IsMissionOpen(10115):"..tostring(not this.IsMissionOpen(10115)),3,true)
	
	if this.CanOccurRetakeThePlatform()then
		if not this.IsMissionOpen(10115)then
			this.OpenRetakeThePlatform()
		end
	end
end
function this.IsAlwaysOpenRetakeThePlatform()
	local n=TppDefine.MISSION_ENUM[tostring(10115)]
	if(gvars.str_missionOpenPermission[n]==false)then
		return false
	end
	if TppTerminal.IsCleardRetakeThePlatform()then
		return true
	end
	local e=this.GetElapsedMissionCount(TppDefine.ELAPSED_MISSION_EVENT.FAILED_RETAKE_THE_PLATFORM)
	if(e==TppDefine.ELAPSED_MISSION_COUNT.INIT)then
		return false
	else
		return true
	end
end
function this.CloseRetakeThePlatform()
	TppMotherBaseManagement.UnlockedStaffsS10115{crossMedal=false}
	this.MissionClose(10115)
	--TUPPMLog.Log("END OF TppStory.CloseRetakeThePlatform()",3,true)
end
function this.FailedRetakeThePlatform()
	TppUI.ShowAnnounceLog"deleteEmergencyMission"
	local n=TppMotherBaseManagement.GetStaffsS10115()
	TppMotherBaseManagement.RemoveStaffsS10115{staffIds={n[1],n[2],n[3],n[4],n[5],n[6]}}
	TppMotherBaseManagement.UnlockedStaffsS10115{crossMedal=false}
	TppUiCommand.SetMission10115Emergency(false)
	this.StartElapsedMissionEvent(TppDefine.ELAPSED_MISSION_EVENT.FAILED_RETAKE_THE_PLATFORM,TppDefine.INIT_ELAPSED_MISSION_COUNT.FAILED_RETAKE_THE_PLATFORM)
end
function this.FailedRetakeThePlatformIfOpened()
	if this.IsMissionOpen(10115)and(not this.IsAlwaysOpenRetakeThePlatform())then
		this.FailedRetakeThePlatform()
	end
end
function this.CanOpenS10240()
	local t=this.GetClearedMissionCount{10010,10020,10030,10036,10043,10033,10040,10041,10044,10052,10054,10050,10070,10080,10086,10082,10090,10091,10195,10100,10110,10121,10115,10120,10085,10200,10211,10081,10130,10140,10150,10151,10045,10156,10093,10171}
	local n=this.IsNowOccurringElapsedMission(TppDefine.ELAPSED_MISSION_EVENT.STORY_SEQUENCE)
	local i=TppQuest.IsNowOccurringElapsed()
	local e=TppMotherBaseManagement.CanOpenS10240()
	if((t>=36)and e)and(n or i)then
		return true
	else
		return false
	end
end
function this.CanOpenS10260()
	local hueyExiled=TppDemo.IsPlayedMBEventDemo"DecisionHuey"
	local canSortieQuiet=TppBuddyService.CanSortieBuddyType(BuddyType.QUIET)
	local isQuietDead=TppBuddyService.IsDeadBuddyType(BuddyType.QUIET)
	local quietFriendlyPoints=TppBuddyService.GetFriendlyPoint(BuddyFriendlyType.QUIET)
	local notUsingButterflyEmblem=not TppUiCommand.IsUsingButterflyEmblem()
	if(((hueyExiled and canSortieQuiet)and(not isQuietDead))and(quietFriendlyPoints>=100))and notUsingButterflyEmblem then
		return true
	else
		return false
	end
end
function this.CanOpenS10280()
	if TppGameSequence.GetSpecialVersionName()=="e3_2015"then
		return false
	end
	local hueyExiled=TppDemo.IsPlayedMBEventDemo"DecisionHuey"
	local e="tp_m_10160_11" --r27 Eli's DNA test
	local gotCassette=TppMotherBaseManagement.IsGotCassetteTapeTrack(e)
	local didNotPlayCassette=TppMotherBaseManagement.IsNewCassetteTapeTrack(e)
	return(hueyExiled and gotCassette)and not(didNotPlayCassette)
end
function this.CanPlayMgo(e)
	local e=e or gvars.str_storySequence
	if e<TppDefine.STORY_SEQUENCE.CLEARD_ESCAPE_THE_HOSPITAL then
		return false
	else
		return true
	end
end
function this.OnReload(n)
	this.SetUpStorySequenceTable()
end
function this.SetUpStorySequenceTable()
	this.storySequenceTable=this.storySequenceTable_Master
end
function this.Init(n)
	if this.IsAlwaysOpenRetakeThePlatform()then
		this.SetMissionOpenFlag(missionId,true)
	end
	this.UpdateStorySequence{updateTiming="OnMissionStart"}
end
this.SetUpStorySequenceTable()
function this.UpdateStorySequence(t)
	if not Tpp.IsTypeTable(t)then
		return
	end
	if TppMission.IsFOBMission(vars.missionCode)or TppMission.IsFOBMission(TppMission.GetNextMissionCodeForEmergency())then
		return
	end
	if(gvars.str_storySequence==TppDefine.STORY_SEQUENCE.CLEARD_ENDRESS_PROXY_WAR)and(not TppSave.CanSaveMbMangementData())then
		return
	end
	local n
	local i=t.updateTiming
	local r=t.isInGame
	this._UpdateS11050OpenFlag(storySequence)
	if i=="BeforeBuddyBlockLoad"or i=="OnMissionClear"then
		this._UpdateS10260OpenFlag(storySequence)
	end
	if i=="OnMissionClear"then
		local t=t.missionId
		n=this.UpdateStorySequenceOnMissionClear(t)
	else
		local t=this.GetCurrentStorySequenceTable()
		if(t and t.updateTiming)and t.updateTiming[i]then
			n=this._UpdateStorySequence()
		end
	end
	if n and r then
		TppMission.ExecuteSystemCallback("OnUpdateStorySequenceInGame",n)
	end
	if n then
		if next(n)then
			gvars.mis_isExistOpenMissionFlag=true
		end
		local e=this.GetCurrentStorySequence()
		if TppDefine.CONTINUE_TIPS_TABLE[e]then
			gvars.continueTipsCount=1
		end
	end
	return n
end
function this.UpdateStorySequenceOnMissionClear(missionCode)
	for missionType,missionId in pairs(TppDefine.SYS_MISSION_ID)do
		if(missionCode==missionId)then
			return
		end
	end
	local missionCodeEnumId=TppDefine.MISSION_ENUM[tostring(missionCode)]
	if not missionCodeEnumId then
		return
	end
	if gvars.str_missionOpenFlag[missionCodeEnumId]==false then
		return
	end
	this.UpdateMissionCleardFlag(missionCode)
	this.DecreaseElapsedMissionClearCount()
	this.UpdateDemoFlagQuietWishGoMission()
	if missionCode~=10050 then
		this.ResetCounterReunionQuiet()
	end
	local e=this._UpdateStorySequence()
	TppTerminal.AcquirePrivilegeStaff()
	return e
end
function this._UpdateS11050OpenFlag()
	local n=this.GetCurrentStorySequence()
	if(n>=TppDefine.STORY_SEQUENCE.CLEARD_RETRIEVE_CHILD_DESERTER and TppDemo.IsPlayedMBEventDemo"ArrivedMotherBaseAfterQuietBattle")and(not this.IsMissionOpen(11050))then
		this.MissionOpen(11050)
	end
end
function this._UpdateS10260OpenFlag()
	if(not this.IsMissionCleard(10260))and this.CanOpenS10260()then
		TppBuddyService.SetBuddyCommonFlag(BuddyCommonFlag.BUDDY_QUIET_LOST)
		TppBuddyService.SetDisableBuddyType(BuddyType.QUIET)
		TppMotherBaseManagement.RefreshQuietStatus()
	end
end
function this._UpdateStorySequence()
	local currentStorySequence=this.GetCurrentStorySequence()
	if currentStorySequence>=TppDefine.STORY_SEQUENCE.STORY_FINISH then
		return
	end
	local t,nextStorySequenceConditionTable
	local i
	repeat
		nextStorySequenceConditionTable=this.GetStorySequenceTable(currentStorySequence)
		if nextStorySequenceConditionTable==nil then
			return
		end
		local canProgressStory=this.CheckNeedProceedStorySequence(nextStorySequenceConditionTable)
		if not canProgressStory then
			break
		end
		t=this.ProceedStorySequence()
		currentStorySequence=this.GetCurrentStorySequence()
		if currentStorySequence<TppDefine.STORY_SEQUENCE.STORY_FINISH then
			i=false
		else
			i=true
		end
	until(i or next(t))
	return t
end
function this.CheckNeedProceedStorySequence(nextStorySequenceConditionTable)
	local missionsToClearTable={}
	local function i(missionNameString)
		local missionCode=TppMission.ParseMissionName(missionNameString)
		local missionClearFlag=this.IsMissionCleard(missionCode)
		table.insert(missionsToClearTable,missionClearFlag)
	end
	if nextStorySequenceConditionTable.main then
		i(nextStorySequenceConditionTable.main)
	end
	if nextStorySequenceConditionTable.flag then
		for n,missionNameString in pairs(nextStorySequenceConditionTable.flag)do
			i(missionNameString)
		end
	end
	local canProgressStory=true
	local missionAlreadyCleared=0
	for e=1,#missionsToClearTable do
		if missionsToClearTable[e]then
			missionAlreadyCleared=missionAlreadyCleared+1
		end
	end
	local missionsToClearCount=#missionsToClearTable
	if nextStorySequenceConditionTable.proceedCount then
		missionsToClearCount=nextStorySequenceConditionTable.proceedCount
	end
	if missionAlreadyCleared<missionsToClearCount then
		canProgressStory=false
	end
	if canProgressStory and nextStorySequenceConditionTable.condition then
		canProgressStory=nextStorySequenceConditionTable.condition()
	end
	return canProgressStory
end
function this.ProceedStorySequence()
	this.IncrementStorySequence()
	local currentStorySequence=this.GetCurrentStorySequence()
	local nextStorySequenceConditionTable=this.GetStorySequenceTable(currentStorySequence)
	if nextStorySequenceConditionTable==nil then
		return
	end
	local i={}
	local function t(n,t)
		local r=t or{}
		local t=TppMission.ParseMissionName(n)
		this.PermitMissionOpen(t)
		if not r[n]then
			table.insert(i,n)
			this.MissionOpen(t)
		end
	end
	if nextStorySequenceConditionTable.main then
		t(nextStorySequenceConditionTable.main,nextStorySequenceConditionTable.defaultClose)
	end
	if nextStorySequenceConditionTable.flag then
		for i,e in pairs(nextStorySequenceConditionTable.flag)do
			t(e,nextStorySequenceConditionTable.defaultClose)
		end
	end
	if nextStorySequenceConditionTable.sub then
		for i,e in pairs(nextStorySequenceConditionTable.sub)do
			t(e,nextStorySequenceConditionTable.defaultClose)
		end
	end
	for e,e in pairs(i)do
	end
	return i
end
function this.CompleteAllMissionCleared()
	if not gvars.str_isAllMissionCleared then
		gvars.str_isAllMissionCleared=true
		TppHero.SetAndAnnounceHeroicOgrePoint(TppHero.ALL_MISSION_CLEAR)
	end
end
function this.CompleteAllMissionSRankCleared()
	if not gvars.str_isAllMissionSRankCleared then
		gvars.str_isAllMissionSRankCleared=true
		TppHero.SetAndAnnounceHeroicOgrePoint(TppHero.ALL_MISSION_S_RANK_CLEAR)
	end
end
function this.CompleteAllNormalMissionCleared()
	TppTerminal.AcquireKeyItem{dataBaseId=TppMotherBaseManagementConst.DESIGN_3016,pushReward=true}
end
function this.CompleteAllNormalMissionSRankCleared()
	TppTerminal.AcquireKeyItem{dataBaseId=TppMotherBaseManagementConst.DESIGN_3017,pushReward=true}
end
function this.CompleteAllHardMissionCleared()
	TppTerminal.AcquireKeyItem{dataBaseId=TppMotherBaseManagementConst.DESIGN_3018,pushReward=true}
end
function this.CompleteAllHardMissionSRankCleared()
	TppTerminal.AcquireKeyItem{dataBaseId=TppMotherBaseManagementConst.DESIGN_3019,pushReward=true}
end
function this.IsCompletedMbMedicalSpecialPlatform(e,n,t)
	if((e==Fox.StrCode32"MotherBase")and(n==Fox.StrCode32"Medical"))and(t==1)then
		return true
	else
		return false
	end
end
function this.IsOccuringBossQuiet()
	local quiteMissionRequirements=this.GetClearedMissionCount{10041,10044,10052,10054}
	local isMedClusterBuilt=TppMotherBaseManagement.IsBuiltMbMedicalClusterSpecialPlatform()
	local isQuietAvailable=TppBuddy2BlockController.DidObtainBuddyType(BuddyType.QUIET)
	local isBossKilled=TppBuddyService.CheckBuddyCommonFlag(BuddyCommonFlag.BOSS_QUIET_KILL)
	if((isMedClusterBuilt and(quiteMissionRequirements>=1))and(not isQuietAvailable))and(not isBossKilled)then
		return true
	else
		return false
	end
end
function this.CanArrivalQuietInMB(n)
	local i=TppBuddy2BlockController.DidObtainBuddyType(BuddyType.QUIET)
	local e=not TppBuddyService.CheckBuddyCommonFlag(BuddyCommonFlag.BUDDY_QUIET_HOSPITALIZE)
	if n then
		e=true
	end
	local n=not TppBuddyService.CheckBuddyCommonFlag(BuddyCommonFlag.BUDDY_QUIET_LOST)
	local t=not TppBuddyService.IsDeadBuddyType(BuddyType.QUIET)
	return((i and e)and n)and t
end
function this.RequestLoseQuiet()
	if not gvars.str_didLostQuiet then
		gvars.str_didLostQuiet=true
		TppBuddyService.UnsetObtainedBuddyType(BuddyType.QUIET)
		TppBuddyService.UnsetSortieBuddyType(BuddyType.QUIET)
		TppBuddyService.UnsetBuddyCommonFlag(BuddyCommonFlag.BUDDY_QUIET_DYING)
		TppBuddyService.SetFriendlyPoint(BuddyFriendlyType.QUIET,0)
	end
end
function this.RequestReunionQuiet()
	TppBuddyService.UnsetBuddyCommonFlag(BuddyCommonFlag.BUDDY_QUIET_LOST)
	TppBuddyService.SetObtainedBuddyType(BuddyType.QUIET)
	TppBuddyService.SetSortieBuddyType(BuddyType.QUIET)
	TppBuddyService.UnsetBuddyCommonFlag(BuddyCommonFlag.BUDDY_QUIET_DYING)
	TppBuddyService.SetFriendlyPoint(BuddyFriendlyType.QUIET,100)
	this.ResetCounterReunionQuiet()
	TppMotherBaseManagement.RefreshQuietStatus()
end
function this.UpdateCounterReunionQuiet()
	gvars.str_quietReunionMissionCount=gvars.str_quietReunionMissionCount+1
end
function this.ResetCounterReunionQuiet()
	gvars.str_quietReunionMissionCount=0
end
function this.CanPlayReunionQuietMission()
	return gvars.str_quietReunionMissionCount>=TppDefine.QUIET_REUNION_MISSION_COUNT
end
function this.CanReunionQuiet()
	return gvars.str_quietReunionMissionCount>TppDefine.QUIET_REUNION_MISSION_COUNT
end
function this.CanArrivalLiquidInMB()
	local e=this.GetCurrentStorySequence()>=TppDefine.STORY_SEQUENCE.CLEARD_WHITE_MAMBA
	local n=not TppDemo.IsPlayedMBEventDemo"TheGreatEscapeLiquid"
	return e and n
end
function this.CanArrivalHueyInMB()
	local n=this.GetCurrentStorySequence()>=TppDefine.STORY_SEQUENCE.CLEARD_RESCUE_HUEY
	local e=not TppDemo.IsPlayedMBEventDemo"DecisionHuey"
	return n and e
end
function this.HueyHasKantokuGrass()
	return this.GetCurrentStorySequence()>=TppDefine.STORY_SEQUENCE.CLEARD_METALLIC_ARCHAEA
end
function this.CanArrivalCodeTalkerInMB()
	return this.GetCurrentStorySequence()>=TppDefine.STORY_SEQUENCE.CLEARD_CODE_TALKER
end
function this.CanArrivalDDogInMB()
	local e=TppBuddyService.CanSortieBuddyType(BuddyType.DOG)
	local n=not TppBuddyService.IsDeadBuddyType(BuddyType.DOG)
	return e and n
end
function this.CanArrivalSahelanInMB()
	--r18 Sahelanthropus is now available on R&D platform
	local clearedOKBZ=this.GetCurrentStorySequence()>=TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO
	local liquidEscaped=not TppDemo.IsPlayedMBEventDemo"TheGreatEscapeLiquid"
	
	--r51 Settings
	if TUPPMSettings.mtbs_ENABLE_theBratDidntReallyStealSahelan then
		return clearedOKBZ
	else
		return clearedOKBZ and liquidEscaped
	end
end
function this.CanArrivalChildrenInMB()
	if this.IsMissionCleard(10100)then
		if TppDemo.IsPlayedMBEventDemo"TheGreatEscapeLiquid"then
			return false
		end
		local n=TppQuest.IsCleard"outland_q20913"or TppQuest.IsCleard"lab_q20914"
		local e=(TppQuest.IsCleard"tent_q20910"and TppQuest.IsCleard"fort_q20911")and TppQuest.IsCleard"sovietBase_q20912"
		if n and(not e)then
			return false
		end
		return true
	end
	return false
end
function this.CanArrivalAIPodInMB()
	return TppQuest.IsCleard"sovietBase_q99030"
end
function this.GetBattleGearDevelopLevel()
	local n=this.GetCurrentStorySequence()
	if gvars.forceMbRadioPlayedFlag[TppDefine.FORCE_MB_RETURN_RADIO_ENUM.CompliteDevelopBattleGearRadio]or TppDemo.IsPlayedMBEventDemo"DevelopedBattleGear5"then
		return 5
	elseif n>=TppDefine.STORY_SEQUENCE.CLEARD_METALLIC_ARCHAEA then
		return 4
	elseif n>=TppDefine.STORY_SEQUENCE.CLEARD_ELIMINATE_THE_COMMANDER then
		return 3
	elseif this.GetClearedMissionCount{10085,10200}>=1 then
		return 2
	elseif this.IsMissionCleard(10121)then
		return 1
	elseif TppDemo.IsPlayedMBEventDemo"AnableDevBattleGear"then
		return 0
	end
	return-1
end
function this.CanPlayDemoOrRadio(n)
	local e=this.radioDemoTable[n]
	if e then
		return e.storyCondition()and e.detailCondition()
	end
	return false
end
function this.GetStoryRadioListFromIndex(n,t)
	local n=this.eventPlayTimmingTable[n]
	if not n then
		return nil
	end
	local n=n[t][2]
	return this.radioDemoTable[n].radioList
end
function this.GetForceMBDemoNameOrRadioList(n,i)
	if i==nil then
		i={}
	end
	if not this.eventPlayTimmingTable[n]then
		return
	end
	if(n=="forceMBDemo"or n=="blackTelephone")and this.PLAY_DEMO_END_MISSION[vars.missionCode]then
		return
	end
	for a,t in ipairs(this.eventPlayTimmingTable[n])do
		local s=t[1]
		local o=t[2]
		local t=this.radioDemoTable[o]
		local r=this._GetRadioList(t,i)
		if(not this.IsDoneEvent(t,s,n,o)and t.storyCondition(i))and t.detailCondition(i)then
			if t.demoName then
				if this.DEBUG_SkipDemoRadio then
					TppMbFreeDemo.PlayMtbsEventDemo{demoName=t.demoName}
				end
				return t.demoName,a
			elseif r then
				if n=="blackTelephone"or n=="clearSideOpsForceMBRadio"then
					gvars.forceMbRadioPlayedFlag[TppDefine.FORCE_MB_RETURN_RADIO_ENUM[o]]=true
				end
				if n=="freeHeliRadio"then
					mvars.str_currentFreeHeliRadioList=r
				end
				return r,a
			end
		end
	end
end
function this.GetCurrentFreeHeliRadioList()
	return mvars.str_currentFreeHeliRadioList
end
function this._GetRadioList(e,n)
	if e.selectRadioFunction then
		return e.selectRadioFunction(n)
	end
	return e.radioList
end
function this.IsDoneEvent(e,t,n,i)
	if not t then
		return false
	end
	if e.demoName then
		return TppDemo.IsPlayedMBEventDemo(e.demoName)
	end
	if e.radioList then
		for n,e in ipairs(e.radioList)do
			if TppRadio.IsPlayed(e)then
				return true
			end
		end
		if n=="blackTelephone"or n=="clearSideOpsForceMBRadio"then
			if gvars.forceMbRadioPlayedFlag[TppDefine.FORCE_MB_RETURN_RADIO_ENUM[i]]then
				for n,e in ipairs(e.radioList)do
					TppRadio.SetPlayedGlobalFlag(e)
				end
				return true
			end
		end
		return false
	end
	return true
end
function this.UpdateDemoFlagQuietWishGoMission()
	if not TppDemo.IsPlayedMBEventDemo"QuietWishGoMission"and gvars.mis_quietCallCountOnMissionStart~=vars.buddyCallCount[BuddyType.QUIET]then
		this.StartElapsedMissionEvent(TppDefine.ELAPSED_MISSION_EVENT.QUIET_WITH_GO_MISSION,TppDefine.INIT_ELAPSED_MISSION_COUNT.QUIET_WITH_GO_MISSION)
	end
end
function this.DEBUG_GetUnclearedMissionCode()
	for t,e in pairs(TppDefine.MISSION_ENUM)do
		local n=gvars.str_missionOpenFlag[e]
		local e=gvars.str_missionClearedFlag[e]
		if n and(not e)then
			return tonumber(t)
		end
	end
end
function this.DEBUG_TestStorySequence()
	this.DEBUG_SkipDemoRadio=true
	TppScriptVars.InitForNewGame()
	TppGVars.AllInitialize()
	TppVarInit.InitializeOnNewGame()
	function TppMission.IsHelicopterSpace()
		return true
	end
	this.DEBUG_InitQuestFlagsForTest()
	local n
	repeat
		local t=""for i,n in ipairs(TppDefine.MISSION_LIST)do
			if this.IsMissionCleard(n)then
				t=t..(","..tostring(n))
			end
		end
		coroutine.yield()
		TppTerminal.ReleaseMbSection()
		this.UpdateStorySequence{updateTiming="OnMissionClear",missionId=TppMission.GetMissionID()}
		this.DEBUG_SetNeedStoryTest(vars.missionCode)
		local t=this.GetForceMBDemoNameOrRadioList"forceMBDemo"this.GetForceMBDemoNameOrRadioList("blackTelephone",{demoName=t})
		this.GetForceMBDemoNameOrRadioList"freeHeliRadio"this.GetForceMBDemoNameOrRadioList"freeHeliRadio"repeat
			coroutine.yield()
			TppQuest.UpdateActiveQuest{debugUpdate=true}until(not this.DEBUG_ClearQuestForTest(vars.missionCode))
		this.MissionOpen(10260)
		local t=this.DEBUG_GetUnclearedMissionCode()
		if mvars.str_DEBUG_needClearOneMission then
			t=10036
			mvars.str_DEBUG_needClearOneMission=false
		end
		if t==nil then
			break
		end
		vars.missionCode=t
		local t=this.GetCurrentStorySequence()
		if t<TppDefine.STORY_SEQUENCE.STORY_FINISH then
			n=false
		else
			n=true
		end
		coroutine.yield()until(n or mvars.str_testBreak)
	this.DEBUG_SkipDemoRadio=nil
end
function this.DEBUG_InitQuestFlagsForTest()
	for n,e in ipairs(TppDefine.QUEST_INDEX)do
		gvars.qst_questOpenFlag[e]=false
		gvars.qst_questActiveFlag[e]=false
		gvars.qst_questClearedFlag[e]=false
		gvars.qst_questRepopFlag[e]=false
	end
end
function this.DEBUG_ClearQuestForTest(e)
	for n,e in ipairs(TppDefine.QUEST_DEFINE)do
		if TppQuest.IsOpen(e)and not TppQuest.IsCleard(e)then
			TppQuest.Clear(e)
			return true
		end
	end
	return false
end
function this.DEBUG_SetNeedStoryTest(n)
	if n==10050 then
		if TppBuddyService.CheckBuddyCommonFlag(BuddyCommonFlag.BUDDY_QUIET_LOST)then
		else
			TppBuddy2BlockController.SetObtainedBuddyType(BuddyType.QUIET)
			local n=this.GetElapsedMissionCount(TppDefine.ELAPSED_MISSION_EVENT.QUIET_WITH_GO_MISSION)
			if n==TppDefine.ELAPSED_MISSION_COUNT.INIT then
				this.StartElapsedMissionEvent(TppDefine.ELAPSED_MISSION_EVENT.QUIET_WITH_GO_MISSION,TppDefine.INIT_ELAPSED_MISSION_COUNT.QUIET_WITH_GO_MISSION)
				this.StartElapsedMissionEvent(TppDefine.ELAPSED_MISSION_EVENT.QUIET_VISIT_MISSION,TppDefine.INIT_ELAPSED_MISSION_COUNT.QUIET_VISIT_MISSION)
			end
			if TppQuest.IsCleard"mtbs_q99011"then
				TppBuddyService.SetSortieBuddyType(BuddyType.QUIET)
				TppBuddyService.UnsetDeadBuddyType(BuddyType.QUIET)
			end
		end
		TppBuddyService.SetSortieBuddyType(BuddyType.QUIET)
		this.MissionOpen(10070)
		vars.mbmTppGmp=-1e3
	end
	if n==10121 then
		this.MissionOpen(10115)
	end
	if n==10043 then
		TppBuddyService.SetObtainedBuddyType(BuddyType.DOG)
	end
	if this.GetClearedMissionCount{10041,10044,10052,10054}==2 then
		TppMotherBaseManagement.SetClusterSvars{base="MotherBase",category="Medical",grade=4,buildStatus="Completed",timeMinute=0,isNew=false}
	end
	if n==10200 then
		TppMotherBaseManagement.SetMbsClusterParam{category="Develop",grade=4,buildStatus="Completed"}coroutine.yield()
	end
	if n==10151 then
		TppMotherBaseManagement.SetMbsClusterParam{category="Medical",grade=4,buildStatus="Completed"}coroutine.yield()
	end
	if n==10054 then
		this.MissionOpen"10050"
	end
	if n==10171 then
		TppMotherBaseManagement.SetClusterSvars{base="MotherBase",category="Command",grade=4,buildStatus="Completed",timeMinute=0,isNew=false}
		TppMotherBaseManagement.SetClusterSvars{base="MotherBase",category="Combat",grade=4,buildStatus="Completed",timeMinute=0,isNew=false}
		TppMotherBaseManagement.SetClusterSvars{base="MotherBase",category="Develop",grade=4,buildStatus="Completed",timeMinute=0,isNew=false}
		TppMotherBaseManagement.SetClusterSvars{base="MotherBase",category="BaseDev",grade=4,buildStatus="Completed",timeMinute=0,isNew=false}
		TppMotherBaseManagement.SetClusterSvars{base="MotherBase",category="Support",grade=4,buildStatus="Completed",timeMinute=0,isNew=false}
		TppMotherBaseManagement.SetClusterSvars{base="MotherBase",category="Spy",grade=4,buildStatus="Completed",timeMinute=0,isNew=false}
		TppMotherBaseManagement.SetClusterSvars{base="MotherBase",category="Medical",grade=4,buildStatus="Completed",timeMinute=0,isNew=false}coroutine.yield()
		TppMotherBaseManagement.DEBUG_DirectAddRandomStaffs{count=3500}
	end
	if n==10240 then
		TppBuddyService.SetFriendlyPoint(BuddyFriendlyType.QUIET,100)
		TppMotherBaseManagement.SetCassetteTapeTrackNewFlag("tp_m_10160_11",false)
	end
	vars.personalBirthdayMonth=3 --TODO rX5 birthday controls
	vars.personalBirthdayDay=10
end
function this.DEBUG_SetStorySequence(t,o)
	do
	return
end
if(t<TppDefine.STORY_SEQUENCE.STORY_START)and(t>TppDefine.STORY_SEQUENCE.STORY_FINISH)then
	return
end
gvars.str_storySequence=t
for e=0,TppDefine.MISSION_COUNT_MAX do
	gvars.str_missionOpenPermission[e]=false
	gvars.str_missionOpenFlag[e]=false
	gvars.str_missionClearedFlag[e]=false
	gvars.str_missionNewOpenFlag[e]=false
end
if TppDebugMbDevelop then
	local n
	local i
	for t=TppDefine.STORY_SEQUENCE.STORY_START,gvars.str_storySequence do
		local e=this.GetStorySequenceName(t)
		if TppDebugMbDevelop[e]then
			n=TppDebugMbDevelop[e]i=e
		end
	end
	if n then
		n()
	else
		TppDebugMbDevelop.AllDeveloped()
	end
end
local function r(t,o,a,i,n)
	local r=n or{}
	local n=TppMission.ParseMissionName(t)
	local i=(t==i)
	this.PermitMissionOpen(n)
	if(not r[t])or(i)then
		this.MissionOpen(n)
		if(o<a)and(not i)then
			this.DisableMissionNewOpenFlag(n)
			this.UpdateMissionCleardFlag(n)
		end
	end
	return i
end
local n
for i=0,t do
	local e=this.GetStorySequenceTable(i)
	if e==nil then
		break
	end
	if e.main then
		local e=r(e.main,i,t,o,e.defaultClose)
		n=n or e
	end
	if e.flag then
		for s,a in pairs(e.flag)do
			local e=r(a,i,t,o,e.defaultClose)
			n=n or e
		end
	end
	if e.sub then
		for s,a in pairs(e.sub)do
			local e=r(a,i,t,o,e.defaultClose)
			n=n or e
		end
	end
	if n then
		gvars.str_storySequence=i
		break
	end
end
local n=TppResult.CalcMissionClearHistorySize()
TppResult.SetMissionClearHistorySize(n)
if gvars.str_storySequence>TppDefine.STORY_SEQUENCE.CLEARD_RECUE_MILLER then
	TppVarInit.SetHorseObtainedAndCanSortie()
end
if gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_FLAG_MISSIONS_AFTER_FIND_THE_SECRET_WEAPON then
	this.MissionOpen(10050)
	this.UpdateMissionCleardFlag(10050)
end
if gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_RESCUE_HUEY then
	this.MissionOpen(10070)
	this.UpdateMissionCleardFlag(10070)
end

if gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_CAPTURE_THE_WEAPON_DEALER then
	this.MissionOpen(10115)
	this.UpdateMissionCleardFlag(10115)
	TppMotherBaseManagement.SetFobSvars{fob="Fob1",got=true,oceanAreaId=2,topologyType=10,color="Orange"}
end
if gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_FLAG_MISSIONS_BEFORE_ENDRESS_PROXY_WAR then
	this.MissionOpen(11050)
	this.UpdateMissionCleardFlag(11050)
end
if gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_MURDER_INFECTORS then
	this.MissionOpen(10240)
	this.UpdateMissionCleardFlag(10240)
end
if gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_THE_TRUTH then
	local n={11080,11121,11130,11044,11151,10260,10280}
	if TppGameSequence.GetSpecialVersionName()=="e3_2015"then
		n={11080,11121,11130,11044,11151,10260}
	end
	for t,n in ipairs(n)do
		this.MissionOpen(n)
		this.UpdateMissionCleardFlag(n)
	end
	if TppQuest.QAReleaseFullOpen then
		TppQuest.QAReleaseFullOpen()
	end
end
if TppTerminal.PandemicTutorialStoryCondition()then
	TppTerminal.FinishPandemicTutorial()
	TppTerminal.StartPandemicEvent()
end
if TppTerminal.CheckPandemicEventFinish()then
	TppTerminal.FinishPandemicTutorial()
	TppTerminal.FinishPandemicEvent()
end
if this.IsAlwaysOpenRetakeThePlatform()then
	TppUiCommand.SetMission10115Emergency(false)
else
	TppUiCommand.SetMission10115Emergency(true)
end
if gvars.str_storySequence==TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO then
	this.StartElapsedMissionEvent(TppDefine.ELAPSED_MISSION_EVENT.STORY_SEQUENCE,2)
	TppQuest.StartElapsedEvent(1)
end
if gvars.str_storySequence==TppDefine.STORY_SEQUENCE.CLEARD_RETRIEVE_VOLGIN then
	this.StartElapsedMissionEvent(TppDefine.ELAPSED_MISSION_EVENT.STORY_SEQUENCE,2)
	TppQuest.StartElapsedEvent(1)
end
if gvars.str_storySequence==TppDefine.STORY_SEQUENCE.CLEARD_MURDER_INFECTORS then
	this.StartElapsedMissionEvent(TppDefine.ELAPSED_MISSION_EVENT.STORY_SEQUENCE,1)
	TppQuest.StartElapsedEvent(3)
end
if gvars.str_storySequence==TppDefine.STORY_SEQUENCE.CLEARD_AFTER_MURDER_INFECTORS_ONE_MISSION then
	this.StartElapsedMissionEvent(TppDefine.ELAPSED_MISSION_EVENT.STORY_SEQUENCE,1)
	TppQuest.StartElapsedEvent(3)
end
if gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO then
	gvars.qst_questOpenFlag[TppDefine.QUEST_INDEX.sovietBase_q99030]=true
	gvars.qst_questOpenFlag[TppDefine.QUEST_INDEX.tent_q99040]=true
end
TppTerminal.OnEstablishMissionClear()
TppRanking.UpdateOpenRanking()
end
function this.DecreaseElapsedMissionClearCount()
	for n=0,TppDefine.ELAPSED_MISSION_COUNT_MAX-1 do
		if n~=TppDefine.ELAPSED_MISSION_EVENT.STORY_SEQUENCE or(not this.PLAY_DEMO_END_MISSION[vars.missionCode])then
			if gvars.str_elapsedMissionCount[n]>0 then
				local e=gvars.str_elapsedMissionCount[n]-1
				gvars.str_elapsedMissionCount[n]=e
			end
		end
	end
end
function this.EnableMissionNewOpenFlag(n)
	this.SetMissionNewOpenFlag(n,true)
end
function this.DisableMissionNewOpenFlag(n)
	this.SetMissionNewOpenFlag(n,false)
end
function this.SetMissionNewOpenFlag(e,n)
	if TppMission.IsSysMissionId(e)then
		return
	end
	local e=TppDefine.MISSION_ENUM[tostring(e)]
	if e then
		gvars.str_missionNewOpenFlag[e]=n
	end
end

return this
