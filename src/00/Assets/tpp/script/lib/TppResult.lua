--TUPPM Header

local this={}
local SendCommand=GameObject.SendCommand
local IsTypeTable=Tpp.IsTypeTable
local bitBand,bitBor,bitBxor=bit.band,bit.bor,bit.bxor
local MAX_32BIT_UINT=TppDefine.MAX_32BIT_UINT

this.PLAYSTYLE_HEAD_SHOT=.9
this.RANK_THRESHOLD={S=13e4,A=1e5,B=6e4,C=3e4,D=1e4,E=0}
this.RANK_BASE_SCORE={S=11e4,A=9e4,B=7e4,C=5e4,D=3e4,E=0}
this.RANK_BASE_SCORE_10054={S=1e4,A=9e3,B=7e3,C=5e3,D=3e3,E=0}
this.RANK_BASE_SCORE_10040={S=2e4,A=18e3,B=14e3,C=1e4,D=6e3,E=0}
this.RANK_BASE_SCORE_10130={S=5e4,A=45e3,B=35e3,C=25e3,D=2e4,E=0}
this.RANK_BASE_SCORE_10140={S=1e5,A=8e4,B=65e3,C=5e4,D=35e3,E=0}
this.RANK_BASE_GMP={S=28e3,A=23400,B=2e4,C=18e3,D=13500,E=9999}
this.COMMON_SCORE_PARAM={noReflexBonus=1e4,noAlertBonus=5e3,noKillBonus=5e3,noRetryBonus=5e3,perfectStealthNoKillBonus=2e4,noTraceBonus=1e5,firstSpecialBonus=5e3,secondSpecialBonus=5e3,alertCount={valueToScoreRatio=-5e3},rediscoveryCount={valueToScoreRatio=-500},takeHitCount={valueToScoreRatio=-100},tacticalActionPoint={valueToScoreRatio=1e3},hostageCount={valueToScoreRatio=5e3},markingCount={valueToScoreRatio=30},interrogateCount={valueToScoreRatio=150},headShotCount={valueToScoreRatio=1e3},neutralizeCount={valueToScoreRatio=200}}

--These values are used to display GMP amount in the mission list
--Are not used for Actual GMP credit. Check TppTerminal..CorrectGMP() for that
--r23 Doubled GMP
this.MISSION_GUARANTEE_GMP={
  [10010]=nil,
  [10020]=8e4,
  [10030]=nil,
  [10036]=9e4,
  [10043]=1e5,
  [10033]=1e5,
  [10040]=11e4,
  [10041]=11e4,
  [10044]=12e4,
  [10052]=12e4,
  [10054]=13e4,
  [10050]=13e4,
  [10070]=13e4,
  [10080]=15e4,
  [10082]=15e4,
  [10086]=15e4,
  [10090]=17e4,
  [10195]=17e4,
  [10091]=17e4,
  [10100]=17e4,
  [10110]=17e4,
  [10121]=17e4,
  [10115]=19e4,
  [10120]=19e4,
  [10085]=19e4,
  [10200]=19e4,
  [10211]=19e4,
  [10081]=19e4,
  [10130]=21e4,
  [10140]=21e4,
  [10150]=21e4,
  [10151]=21e4,
  [10045]=21e4,
  [10093]=25e4,
  [10156]=26e4,
  [10171]=28e4,
  [10240]=3e5,
  [10260]=6e5,
  [10280]=nil,
  [11043]=3e5,
  [11054]=42e4,
  [11082]=5e5,
  [11090]=5e5,
  [11033]=4e5,
  [11050]=52e4,
  [11140]=6e5,
  [11080]=6e5,
  [11121]=68e4,
  [11130]=68e4,
  [11044]=68e4,
  [11151]=82e4,
  [11041]=19e4,
  [11085]=35e4,
  [11036]=15e4,
  [11091]=31e4,
  [11195]=31e4,
  [11211]=35e4,
  [11200]=35e4,
  [11171]=43e4,
  [11115]=35e4,
  [10230]=23e4
}
this.MISSION_TASK_LIST={
	[10010]={0,1},
	[10020]={0,1,2,3,4,5},
	[10030]={0,1,2,3,4},
	[10036]={0,1,2,3,4},
	[10043]={0,1,2,3,4,5},
	[10033]={0,1,2,3,4},
	[10040]={0,1,2,3,4,5},
	[10041]={0,1,2,3,4,5,6},
	[10044]={0,2,3,4,5,6,7},
	[10050]={0,1,2,5},
	[10052]={1,2,3,4,5},
	[10054]={0,1,2,3,4,5,6,7},
	[10070]={0,1,2,3,4,5},
	[10080]={0,1,2,3,4,5},
	[10086]={0,1,2,3,4,5,6},
	[10082]={1,2,3,4,5},
	[10090]={0,1,2,3,4,5,6,7},
	[10195]={0,1,2,3,4,5,6},
	[10091]={1,3,4,5,6,7},
	[10100]={0,1,2,3,4,5,6,7},
	[10110]={0,1,2,3,4,5},
	[10121]={0,1,2,3,4,5,6,7},
	[10115]={0},
	[10120]={1,2,3,4,5},
	[10085]={0,1,2,3,4,5,6},
	[10200]={2,3,4,5,6,7},
	[10211]={0,2,3,4,5,6},
	[10081]={1,2,3},
	[10130]={0,1,2,3,4,5},
	[10140]={0,1,2,3},
	[10150]={0,1,2,3,4,5},
	[10151]={0,1,2},
	[10045]={1,2,3,4,5,6},
	[10156]={0,1,2,3,4},
	[10093]={0,2,3,4,5,6},
	[10171]={0,1,3,4,5,6,7},
	[10240]={0,1},
	[10260]={0,1,2,3,4},
	[10280]={0,1}
}
this.HARD_MISSION_LIST={11043,11041,11054,11085,11082,11090,11036,11033,11050,11091,11195,11211,11140,11200,11080,11171,11121,11115,11130,11044,11052,11151}
for a,t in ipairs(this.HARD_MISSION_LIST)do
	local a=TppDefine.MISSING_NUMBER_MISSION_ENUM[tostring(t)]
	if not a then
		this.MISSION_TASK_LIST[t]=this.MISSION_TASK_LIST[t-1e3]
	end
end
this.NO_SPECIAL_BONUS={[10030]=true,[10115]=true,[10240]=true}
function this.AcquireSpecialBonus(t)
	if not IsTypeTable(t)then
		return
	end
	if t.first then
		if mvars.res_isExistFirstSpecialBonus then
			this._AcquireSpecialBonus(t.first,"bestScoreBounus","bestScoreBounusScore",mvars.res_firstSpecialBonusMaxCount,this.COMMON_SCORE_PARAM.firstSpecialBonus,"isCompleteFirstBonus",mvars.res_firstBonusMissionTask,mvars.res_firstSpecialBonusPointList,"isAcquiredFirstBonusInPointList")
		end
	end
	if t.second then
		if mvars.res_isExistSecondSpecialBonus then
			this._AcquireSpecialBonus(t.second,"bestScoreBounus2","bestScoreBounusScore2",mvars.res_secondSpecialBonusMaxCount,this.COMMON_SCORE_PARAM.secondSpecialBonus,"isCompleteSecondBonus",mvars.res_secondBonusMissionTask,mvars.res_secondSpecialBonusPointList,"isAcquiredSecondBonusInPointList")
		end
	end
end
function this._AcquireSpecialBonus(t,a,o,s,l,u,i,n,c)
	local r=t.isComplete
	if t.isComplete then
		r=true
		if(not n)and(not s)then
			svars[o]=l
		end
	end
	if t.count then
		if not s then
			return
		end
		if svars[a]<t.count then
			if t.count<=s then
				svars[a]=t.count
			else
				svars[a]=s
			end
			svars[o]=(svars[a]/s)*l
			if svars[a]==s then
				r=true
			end
		end
	end
	if t.pointIndex then
		if not n then
			return
		end
		local t=t.pointIndex
		if not Tpp.IsTypeNumber(t)then
			return
		end
		if t<1 then
			return
		end
		if t>#n then
			return
		end
		svars[c][t]=true
		local t,e=this.CalcPoinListBonusScore(n,c)svars[a]=t
		svars[o]=e
		if svars[a]==#n then
			r=true
		end
	end
	if r then
		this._CompleteBonus(u,i)
	else
		i.isHide=false
		TppUI.EnableMissionTask(i)
	end
end
function this.CalcPoinListBonusScore(a,s)
	local e=0
	local t=0
	for a,n in ipairs(a)do
		if svars[s][a]then
			e=e+1
			t=t+n
		end
	end
	return e,t
end
function this.SetSpecialBonusMaxCount(e)
	if not Tpp.IsTypeTable(e)then
		return
	end
	if e.first and e.first.maxCount then
		mvars.res_firstSpecialBonusMaxCount=e.first.maxCount
	end
	if e.second and e.second.maxCount then
		mvars.res_secondSpecialBonusMaxCount=e.second.maxCount
	end
end
function this._CompleteBonus(t,e)
	local a=true
	if svars[t]then
		a=false
	end
	svars[t]=true
	if e then
		e.isComplete=true
		TppUI.EnableMissionTask(e,a)
	end
end
function this.RegistNoMissionClearRank()
	mvars.res_noMissionClearRank=true
end
function this.SetMissionScoreTable(e)
	if not IsTypeTable(e)then
		return
	end
	mvars.res_missionScoreTable=e
end
function this.SetMissionFinalScore()
	if mvars.res_noResult then
		return
	end
	this.RegistUsedLimitedItemLangId()
	TppBuddyService.BuddyProcessMissionSuccess()
	this.SaveBestCount()
	local a,t=this.CalcBaseScore()
	this.CalcTimeScore(a,t)
	this.CalcEachScore()
	local n=this.CalcTotalScore()
	local missionClearRankCode=this.DecideMissionClearRank()
	local a
	if TppMission.IsFOBMission(vars.missionCode)then
		return
	end
	Tpp.IncrementPlayData"totalMissionClearCount"
	this.SetSpecialBonusResultScore()
	if missionClearRankCode~=TppDefine.MISSION_CLEAR_RANK.NOT_DEFINED then
		TppHero.MissionClear(missionClearRankCode)
	end
	if missionClearRankCode==TppDefine.MISSION_CLEAR_RANK.S then
		TppEmblem.AcquireOnSRankClear(vars.missionCode)
	end
	TppMotherBaseManagement.AwardedMeritMedalPointToPlayerStaff{clearRank=missionClearRankCode}
	if bit.band(vars.playerPlayFlag,PlayerPlayFlag.USE_CHICKEN_CAP)==PlayerPlayFlag.USE_CHICKEN_CAP then
		if gvars.chickenCapClearCount<MAX_32BIT_UINT then
			gvars.chickenCapClearCount=gvars.chickenCapClearCount+1
		end
	end
	--  TUPPMLog.Log("svars.bestScoreKillScore: "..tostring(svars.bestScoreKillScore))
	--  TUPPMLog.Log("svars.bestScoreAlertScore: "..tostring(svars.bestScoreAlertScore))
	--r51 Settings
	if TUPPMSettings.game_ENABLE_awardHonorMedalToStaff and missionClearRankCode==TppDefine.MISSION_CLEAR_RANK.S and svars.bestScoreKillScore>0 and svars.bestScoreAlertScore>0 then --r23 Honor Medal for Staff when playing offline; S Rank with No Kills and No Alerts
		TppMotherBaseManagement.AwardedHonorMedalToPlayerStaff() --TODO test on Snake
	end
	if(vars.playerType==PlayerType.DD_MALE or vars.playerType==PlayerType.DD_FEMALE)then
		TppTrophy.Unlock(11)
	end
	a=this.UpdateGmpOnMissionClear(vars.missionCode,missionClearRankCode,n)
	if vars.totalBatteryPowerAsGmp then
		TppUiCommand.SetResultBatteryGmp(vars.totalBatteryPowerAsGmp)
		TppTerminal.UpdateGMP{gmp=vars.totalBatteryPowerAsGmp}
	end
	this.SetBestRank(vars.missionCode,missionClearRankCode)
	if a then
		local t=this.CalcMissionClearHistorySize()
		this.SetMissionClearHistorySize(t)
		this.AddMissionClearHistory(vars.missionCode)
	end
	if vars.missionCode==10020 then
		if TppStory.GetCurrentStorySequence()==TppDefine.STORY_SEQUENCE.CLEARD_RECUE_MILLER then
			local e=TppMotherBaseManagement.GetGmp()
			gvars.firstRescueMillerClearedGMP=e
		end
	end
	if mvars.res_enablePlayStyle then
		this.SaveMissionClearPlayStyleParameter()
		svars.playStyle=this.DecidePlayStyle()
		TppEmblem.AcquireByPlayStyle(svars.playStyle)
		this.AddNewPlayStyleHistory()
	else
		svars.playStyle=0
		this.ClearNewestPlayStyleHistory()
	end
	--> Patch 1090
	if OnlineChallengeTask then
		OnlineChallengeTask.DecideTaskFromResult()
	end
	--<
end
function this.IsUsedChickCap()
	if bit.band(vars.playerPlayFlag,PlayerPlayFlag.USE_CHICK_CAP)==PlayerPlayFlag.USE_CHICK_CAP then
		return true
	else
		return false
	end
end
function this.RegistUsedLimitedItemLangId()
	--r24 Remove rank limitiations based on weapon/item usage
	mvars.res_isUsedRankLimitedItem=false
	--ORIG
	local rankRestrictingItems={
		{PlayerPlayFlag.USE_CHICKEN_CAP,"name_st_chiken"},
		{PlayerPlayFlag.USE_STEALTH,"name_it_12043"},
		{PlayerPlayFlag.USE_INSTANT_STEALTH,"name_it_12040"},
		{PlayerPlayFlag.USE_FULTON_MISSILE,"name_dw_31007"},
		{PlayerPlayFlag.USE_PARASITE_CAMO,"name_it_13050"},
		{PlayerPlayFlag.USE_MUGEN_BANDANA,"name_st_37002"},
		{PlayerPlayFlag.USE_HIGHGRADE_EQUIP,"result_spcialitem_etc"}
	}
	
	--r51 Settings
	if TUPPMSettings.game_DISABLE_missionRankRestrictions then
		rankRestrictingItems={{PlayerPlayFlag.USE_CHICKEN_CAP,"name_st_chiken"}}
	end
	
	for index,itemDetails in ipairs(rankRestrictingItems)do
		local itemUsed,itemName=itemDetails[1],itemDetails[2]
		if itemUsed then
			if bit.band(vars.playerPlayFlag,itemUsed)==itemUsed then
				mvars.res_isUsedRankLimitedItem=true
				TppUiCommand.SetResultScore(itemName,"ranklimited")
			end
		end
	end
	
	--r51 Settings
  if not TUPPMSettings.game_DISABLE_missionRankRestrictions and svars.isUsedSupportHelicopterAttack then
    if not mvars.res_rankLimitedSetting.permitSupportHelicopterAttack then
      mvars.res_isUsedRankLimitedItem=true
      TppUiCommand.SetResultScore("func_heli_attack","ranklimited")
    end
  end
  
  --r51 Settings
  if not TUPPMSettings.game_DISABLE_missionRankRestrictions and svars.isUsedFireSupport then
    if not mvars.res_rankLimitedSetting.permitFireSupport then
      mvars.res_isUsedRankLimitedItem=true
      TppUiCommand.SetResultScore("func_spprt_battle","ranklimited")
    end
  end
end
function this.IsUsedRankLimitedItem()
	return mvars.res_isUsedRankLimitedItem
end
function this.DeclareSVars()
	return{
		{name="bestScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestRank",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="playCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="clearCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="noAlertClearCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="noKillClearCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="stealthClearCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="rankSClearCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="failedCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_RETRY},
		{name="timeParadoxCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_RETRY},
		{name="retryCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_RETRY},
		{name="gameOverCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_RETRY},
		{name="scoreTime",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="playTime",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_RETRY},
		{name="squatTime",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="crawlTime",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="clearTime",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="shotCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="hitCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="headshotCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="killCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="dyingCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="holdupCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="stunCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="sleepCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="interrogationCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="discoveryCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="alertCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="oldTakeHitCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="takeHitCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="reflexCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="rediscoveryCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="tacticalActionPoint",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="traceCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="headshotCount2",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="neutralizeCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="shootNeutralizeCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="destroyVehicleCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="destroyHeriCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="ratCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="crowCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="useWeapon",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="hostageCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="soldierCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="markingEnemyCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="mbTerminalCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="externalCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="externalScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="reinforceCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="stealthAssistCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="interrogateCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="supportGmpCost",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="heroicPointDiff",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="gmpDiamond",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="gmpAnimal",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreTime",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreAlert",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreKill",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreHostage",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreGameOver",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreBounus",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreBounus2",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="isAcquiredFirstBonusInPointList",type=TppScriptVars.TYPE_BOOL,value=false,save=true,arraySize=16,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="isAcquiredSecondBonusInPointList",type=TppScriptVars.TYPE_BOOL,value=false,save=true,arraySize=16,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="isCompleteFirstBonus",type=TppScriptVars.TYPE_BOOL,value=false,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="isCompleteSecondBonus",type=TppScriptVars.TYPE_BOOL,value=false,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreRediscoveryCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreTacticalActionPoint",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreTimeScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreAlertScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreKillScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreHostageScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreGameOverScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreRediscoveryCountScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreTakeHitCountScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreTacticalActionPointScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreBounusScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreBounusScore2",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreNoKillScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreNoRetryScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreNoReflexScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScorePerfectStealthNoKillBonusScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreNoTraceBonusScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreDeductScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreMarkingCountScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreInterrogateScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreHeadShotBonusScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreNeutralizeBonusScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="bestScoreHitRatioBonusScore",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="gmpClear",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="gmpOutcome",type=TppScriptVars.TYPE_INT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="playStyle",type=TppScriptVars.TYPE_INT8,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="isUsedSupportHelicopterAttack",type=TppScriptVars.TYPE_BOOL,value=false,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="isUsedFireSupport",type=TppScriptVars.TYPE_BOOL,value=false,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="questScoreTime",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		nil
	}
end
function this.Init(t)
	this.SetRankTable(this.RANK_THRESHOLD)
	this.SetScoreTable(this.COMMON_SCORE_PARAM)
	this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
	if TppUiCommand.RegisterMbMissionListFunction then
		if TppUiCommand.IsTppUiReady()then
			TppUiCommand.RegisterMbMissionListFunction("TppResult","GetMbMissionListParameterTable")
		end
	end
	do
		for t,e in ipairs{10043,11043}do
			local e=TppDefine.MISSION_ENUM[tostring(e)]
			if gvars.res_bestRank[e]==TppDefine.MISSION_CLEAR_RANK.NOT_DEFINED then
				gvars.res_bestRank[e]=TppDefine.MISSION_CLEAR_RANK.E+1
			end
		end
	end
	if t.sequence then
		if t.sequence.NO_TAKE_HIT_COUNT then
			mvars.res_noTakeHitCount=true
		end
		if t.sequence.NO_TACTICAL_TAKE_DOWN then
			mvars.res_noTacticalTakeDown=true
		end
		if t.sequence.NO_RESULT then
			mvars.res_noResult=true
			mvars.res_noTakeHitCount=true
			mvars.res_noTacticalTakeDown=true
		end
		if t.sequence.NO_PLAY_STYLE then
			mvars.res_enablePlayStyle=false
		else
			mvars.res_enablePlayStyle=true
		end
		if t.sequence.NO_AQUIRE_GMP then
			mvars.res_noAquireGmp=true
		end
		if t.sequence.NO_MISSION_CLEAR_RANK then
			mvars.res_noMissionClearRank=true
		end
		if t.sequence.specialBonus then
			local e=t.sequence.specialBonus.first
			if e then
				mvars.res_isExistFirstSpecialBonus=true
				if e.maxCount then
					mvars.res_firstSpecialBonusMaxCount=e.maxCount
				end
				local t=e.missionTask
				if t then
					mvars.res_firstBonusMissionTask={}
					for e,t in pairs(t)do
						mvars.res_firstBonusMissionTask[e]=t
					end
					mvars.res_firstBonusMissionTask.isFirstHide=true
				end
				if e.pointList then
					if Tpp.IsTypeTable(e.pointList)then
						mvars.res_firstSpecialBonusPointList=e.pointList
						mvars.res_firstSpecialBonusMaxCount=#e.pointList
					end
				end
			end
			local e=t.sequence.specialBonus.second
			if e then
				mvars.res_isExistSecondSpecialBonus=true
				if e.maxCount then
					mvars.res_secondSpecialBonusMaxCount=e.maxCount
				end
				local t=e.missionTask
				if t then
					mvars.res_secondBonusMissionTask={}
					for e,t in pairs(t)do
						mvars.res_secondBonusMissionTask[e]=t
					end
					mvars.res_secondBonusMissionTask.isFirstHide=true
				end
				if e.pointList then
					if Tpp.IsTypeTable(e.pointList)then
						mvars.res_secondSpecialBonusPointList=e.pointList
						mvars.res_secondSpecialBonusMaxCount=#e.pointList
					end
				end
			end
		end
		mvars.res_rankLimitedSetting={}
		if t.sequence.rankLimitedSetting then
			mvars.res_rankLimitedSetting=t.sequence.rankLimitedSetting
		end
		mvars.res_hitRatioBonusParam={hitRatioBaseScoreUnit=30,numOfBulletsPerNeutralizeCount=10,exponetHitRatio=6,limitHitRatioBonus=1e3,perfectBonusBase=3e4}
		if t.sequence.hitRatioBonusParam then
			for t,e in pairs(t.sequence.hitRatioBonusParam)do
				mvars.res_hitRatioBonusParam[t]=e
			end
		end
	end
	if TppMission.IsHelicopterSpace(vars.missionCode)or TppMission.IsFreeMission(vars.missionCode)then
		mvars.res_noResult=true
	end
	if mvars.res_noResult then
		return
	end
	if t.score and t.score.missionScoreTable then
		this.SetMissionScoreTable(t.score.missionScoreTable)
	else
		this.SetMissionScoreTable{baseTime={S=300,A=600,B=1800,C=5580,D=6480,E=8280},tacticalTakeDownPoint={countLimit=40},missionUniqueBonus={5e3,5e3}}
	end
	mvars.res_bonusMissionClearTimeRatio=mvars.res_missionScoreTable.baseTime.S/600
	if mvars.res_bonusMissionClearTimeRatio<1 then
		mvars.res_bonusMissionClearTimeRatio=1
	end
end
function this.OnReload(t)
	this.Init(t)
end
function this.OnMessage(o,r,n,i,t,a,s)
	Tpp.DoMessage(this.messageExecTable,TppMission.CheckMessageOption,o,r,n,i,t,a,s)
end
function this.OnMissionCanStart()
	if mvars.res_firstBonusMissionTask then
		if svars.isCompleteFirstBonus then
			this._CompleteBonus("isCompleteFirstBonus",mvars.res_firstBonusMissionTask)
		else
			TppUI.EnableMissionTask(mvars.res_firstBonusMissionTask,false)
		end
	end
	if mvars.res_secondBonusMissionTask then
		if svars.isCompleteSecondBonus then
			this._CompleteBonus("isCompleteSecondBonus",mvars.res_secondBonusMissionTask)
		else
			TppUI.EnableMissionTask(mvars.res_secondBonusMissionTask,false)
		end
	end
end
function this.SetScoreTable(e)
	if not IsTypeTable(e)then
		return
	end
	mvars.res_scoreTable=e
end
function this.SetRankTable(t)
	if not IsTypeTable(t)then
		return
	end
	mvars.res_rankTable=t
end
this.saveCountTable={{"bestScoreTime","scoreTime"},{"bestScoreAlert","alertCount"},{"bestScoreKill","killCount"},{"bestScoreHostage","hostageCount"},{"bestScoreGameOver","failedCount"},{"bestScoreGameOver","timeParadoxCount"},{"bestScoreTacticalActionPoint","tacticalActionPoint"}}
function this.SaveBestCount()
	local t=svars
	for a,e in pairs(this.saveCountTable)do
		t[e[1]]=0
	end
	for a,e in pairs(this.saveCountTable)do
		t[e[1]]=t[e[1]]+t[e[2]]
	end
end
function this.DEBUG_Count()
	for e,e in pairs(this.saveCountTable)do
	end
end
local i=1e3
function this.CalcBaseScore()
	if not mvars.res_missionScoreTable then
		return
	end
	local o=svars
	local a
	local n,s
	local t=TppMission.GetMissionName()
	local r=#TppDefine.MISSION_CLEAR_RANK_LIST
	for e=1,r do
		a=TppDefine.MISSION_CLEAR_RANK_LIST[e]
		local t=mvars.res_missionScoreTable.baseTime[a]*i
		if o.bestScoreTime<=t then
			n=e
			break
		end
	end
	if n==nil then
		n=r
	end
	if t=="s10040"then
		s=this.RANK_BASE_SCORE_10040[a]
	elseif t=="s10054"or t=="s11054"then
		s=this.RANK_BASE_SCORE_10054[a]
	elseif t=="s10130"or t=="s11130"then
		s=this.RANK_BASE_SCORE_10130[a]
	elseif t=="s10140"or t=="s11140"then
		s=this.RANK_BASE_SCORE_10140[a]
	else
		s=this.RANK_BASE_SCORE[a]
	end
	if this.IsUsedChickCap()then
		s=0
		n=TppDefine.MISSION_CLEAR_RANK.E
	end
	return s,n
end
local a=1/1e3
local t=60
local r=(t*60)*5
local u=(t*60)*.25
local i=(t*60)*1
local o=(t*60)*4
local l=(t*60)*.5
function this.CalcTimeScore(c,s)
	if not mvars.res_missionScoreTable then
		return
	end
	local n=svars
	local S=TppDefine.MISSION_CLEAR_RANK_LIST[s]
	local S=mvars.res_missionScoreTable.baseTime[S]
	local a=S-(n.bestScoreTime*a)
	if a<0 then
		a=0
	end
	local t=a*t
	local a=TppMission.GetMissionName()
	if s>TppDefine.MISSION_CLEAR_RANK.S then
		if a=="s10040"then
			if t>l then
				t=l
			end
		elseif a=="s10054"or a=="s11054"then
			if t>u then
				t=u
			end
		elseif a=="s10130"or a=="s11130"then
			if t>i then
				t=i
			end
		elseif a=="s10140"or a=="s11140"then
			if t>o then
				t=o
			end
		else
			if t>r then
				t=r
			end
		end
	end
	if this.IsUsedChickCap()then
		t=0
		c=0
	end
	n.bestScoreTimeScore=t+c
end
this.calcScoreTable={
	bestScoreAlertScore={"alertCount","bestScoreAlert"},
	bestScoreHostageScore={"hostageCount","bestScoreHostage"},
	bestScoreTakeHitCountScore={"takeHitCount","takeHitCount"},
	bestScoreTacticalActionPointScore={"tacticalActionPoint","tacticalActionPoint","tacticalTakeDownPoint"},
	bestScoreMarkingCountScore={"markingCount",vars="playerMarkingCountInMission"},
	bestScoreInterrogateScore={"interrogateCount","interrogateCount"},
	bestScoreHeadShotBonusScore={"headShotCount","headshotCount2"},
	bestScoreNeutralizeBonusScore={"neutralizeCount","neutralizeCount"}
}
this.bonusScoreTable={
	bestScoreNoReflexScore={"reflexCount","noReflexBonus",nil},
	bestScoreAlertScore={"alertCount","noAlertBonus",true},
	bestScoreKillScore={"bestScoreKill","noKillBonus",nil},
	bestScoreNoRetryScore={"retryCount","noRetryBonus",true},
	bestScorePerfectStealthNoKillBonusScore={
		{"alertCount","bestScoreKill","reflexCount"},
		"perfectStealthNoKillBonus",
		true
	}
}
this.eachScoreLimit={bestScoreHeadShotBonusScore=100,bestScoreNeutralizeBonusScore=100,bestScoreMarkingCountScore=100,bestScoreInterrogateScore=100}
function this.CalcEachScore()
	local svars=svars
	for n,a in pairs(this.calcScoreTable)do
		local s
		if a.vars then
			s=vars[a.vars]
		else
			s=svars[a[2]]
		end
		svars[n]=this.CalcScore(s,mvars.res_scoreTable[a[1]],mvars.res_missionScoreTable[a[3]],this.eachScoreLimit[n])
	end
	if not this.IsUsedChickCap()then
		for scoreType,scoreCriteria in pairs(this.bonusScoreTable)do
			local scoreTypeCount
			if IsTypeTable(scoreCriteria[1])then
				scoreTypeCount=scoreCriteria[1]
			else
				scoreTypeCount={scoreCriteria[1]}
			end
			local isScoringValid=true
			for index,countForScoreType in ipairs(scoreTypeCount)do
				if svars[countForScoreType]>0 then
					isScoringValid=false
					break
				end
			end
			local res_bonusMissionClearTimeRatio=1
			if scoreCriteria[3]then
				res_bonusMissionClearTimeRatio=mvars.res_bonusMissionClearTimeRatio
			end
			if isScoringValid and(not isUsedChickCap)then
				svars[scoreType]=mvars.res_scoreTable[scoreCriteria[2]]*res_bonusMissionClearTimeRatio
			end
		end
		svars.bestScoreHitRatioBonusScore=this.CalcHitRatioBonusScore(vars.shootHitCountInMission,vars.playerShootCountInMission,vars.shootHitCountEliminatedInMission,svars.shootNeutralizeCount,mvars.res_hitRatioBonusParam.hitRatioBaseScoreUnit,mvars.res_hitRatioBonusParam.numOfBulletsPerNeutralizeCount,mvars.res_hitRatioBonusParam.exponetHitRatio,mvars.res_hitRatioBonusParam.limitHitRatioBonus,mvars.res_hitRatioBonusParam.perfectBonusBase)
		if(bit.band(vars.playerPlayFlag,PlayerPlayFlag.FAILED_NO_TRACE_PLAY)==0)and(svars.bestScorePerfectStealthNoKillBonusScore>0)then
			svars.bestScoreNoTraceBonusScore=mvars.res_scoreTable.noTraceBonus*mvars.res_bonusMissionClearTimeRatio
		end
	end
end
local r=999999
local i=-999999
function this.CalcScore(n,s,a,l)
	local t=s.unitValue or 1
	local n=n/t
	local t=0
	local o=s.valueToScoreRatio or 1
	local s=l or 999999
	if a and a.countLimit then
		s=a.countLimit
	end
	if n>s then
		n=s
	end
	t=n*o
	if t<i then
		t=i
	elseif t>r then
		t=r
	end
	if this.IsUsedChickCap()then
		t=0
	end
	return t
end
function this.CalcHitRatioBonusScore(s,r,i,t,a,l,c,o,n)
	local r=r-i
	if r<=0 then
		return 0
	end
	local r=r
	local i=s/r
	if t<1 then
		t=.5
	end
	local l=(((a*2)*r)/(t*l))*(i^c)
	local a=(a+l)*s
	if a>(t*o)then
		a=t*o
	end
	local s
	if i>=1 then
		s=(((n/2)*t)/10)*(t/r)
		if s>n then
			s=n
		end
		a=a+s
	end
	a=math.ceil(a)
	return a
end
this.playScoreList={"bestScoreTimeScore","bestScoreTakeHitCountScore","bestScoreTacticalActionPointScore","bestScoreHeadShotBonusScore","bestScoreHitRatioBonusScore","bestScoreNeutralizeBonusScore","bestScoreMarkingCountScore","bestScoreInterrogateScore","bestScoreHostageScore"}
this.bounusScoreList={"bestScoreBounusScore","bestScoreBounusScore2","bestScoreNoRetryScore","bestScoreKillScore","bestScoreNoReflexScore","bestScoreAlertScore","bestScorePerfectStealthNoKillBonusScore","bestScoreNoTraceBonusScore"}
local n=999999
local r=-999999
function this.CalcTotalScore()
	local currentScore=0
	local a=0
	for a,e in pairs(this.playScoreList)do
		local a=svars[e]
		currentScore=currentScore+svars[e]
	end
	for s,e in pairs(this.bounusScoreList)do
		local s=svars[e]
		currentScore=currentScore+svars[e]
		a=a+svars[e]
	end
	if currentScore>=n then
		currentScore=n
	elseif currentScore<=r then
		currentScore=r
	end
	if this.IsUsedChickCap()then
		currentScore=0
		a=0
	end
	svars.bestScore=currentScore
	if a>=n then
		a=n
	elseif a<=0 then
		a=0
	end
	local missionCodeEnumId=TppDefine.MISSION_ENUM[tostring(vars.missionCode)]
	if missionCodeEnumId then
		local isUsedRankLimitedItem=this.IsUsedRankLimitedItem()
		if isUsedRankLimitedItem then
			if currentScore>gvars.rnk_missionBestScoreUsedLimitEquip[missionCodeEnumId]then
				gvars.rnk_missionBestScoreUsedLimitEquip[missionCodeEnumId]=currentScore
			end
		else
			if currentScore>gvars.rnk_missionBestScore[missionCodeEnumId]then
				gvars.rnk_missionBestScore[missionCodeEnumId]=currentScore
			end
		end
		if not(((vars.missionCode==10043)or(vars.missionCode==11043))and mvars.res_noMissionClearRank)then
			TppRanking.RegistMissionClearRankingResult(isUsedRankLimitedItem,vars.missionCode,currentScore)
		end
	end
	return a
end
function this.DecideMissionClearRank()
	local t
	local s=svars.bestScore
	local a=#TppDefine.MISSION_CLEAR_RANK_LIST
	if not mvars.res_noMissionClearRank then
		for e=1,a do
			local a=TppDefine.MISSION_CLEAR_RANK_LIST[e]
			if s>=mvars.res_rankTable[a]then
				t=e
				break
			end
		end
		if t==nil then
			t=a
		end
	else
		t=TppDefine.MISSION_CLEAR_RANK.NOT_DEFINED
	end
	if this.IsUsedRankLimitedItem()then
		if t==TppDefine.MISSION_CLEAR_RANK.S then
			t=TppDefine.MISSION_CLEAR_RANK.A
		end
	end
	svars.bestRank=t
	return svars.bestRank
end
function this.UpdateGmpOnMissionClear(missionCode,missionClearRankCode,s)
	local missionRewardGMP=this.MISSION_GUARANTEE_GMP[missionCode]
	if not missionRewardGMP then
		return
	end
	if missionCode==10020 and(not TppStory.IsMissionCleard(missionCode))then
		return
	end
	--ORIG
	local gmpClear=this.GetMissionGuaranteeGMP(missionCode)
	svars.gmpClear=TppTerminal.CorrectGMP{gmp=gmpClear}
	--Alternate FIX
	--  local gmpClear=missionRewardGMP --r23 GMP fixed does not decrease
	--  svars.gmpClear=gmpClear
	if missionClearRankCode~=TppDefine.MISSION_CLEAR_RANK.NOT_DEFINED then
		local gmpOutcome=this.GetMissionClearRankGMP(missionClearRankCode,missionCode)
		gmpOutcome=gmpOutcome+s
		svars.gmpOutcome=TppTerminal.CorrectGMP{gmp=gmpOutcome}

		--r27 Give out rewards on mission completion
		this.AddResultResources(missionClearRankCode)
	else
		svars.gmpOutcome=0
	end
	local finalCreditGMP=svars.gmpClear+svars.gmpOutcome
	TppTerminal.UpdateGMP{gmp=finalCreditGMP,withOutAnnouceLog=true}
	return finalCreditGMP
end
function this.SetBestRank(missionCode,missionClearRankCode)
	local a=TppDefine.MISSION_ENUM[tostring(missionCode)]
	if not a then
		return
	end
	if(missionClearRankCode<TppDefine.MISSION_CLEAR_RANK.NOT_DEFINED)or(missionClearRankCode>#TppDefine.MISSION_CLEAR_RANK_LIST)then
		return
	end
	if((missionCode==10043)or(missionCode==11043))and(missionClearRankCode==TppDefine.MISSION_CLEAR_RANK.NOT_DEFINED)then
		return
	end
	if missionClearRankCode<gvars.res_bestRank[a]then
		gvars.res_bestRank[a]=missionClearRankCode
	end
end
function this.GetBestRank(e)
	local e=TppDefine.MISSION_ENUM[tostring(e)]
	if not e then
		return
	end
	return gvars.res_bestRank[e]
end
function this.GetMissionClearRankGMP(missionClearRank,missionCode)
	local s=this.GetBestRank(missionCode)
	if not s then
		return 0
	end
	local r=this.GetRepeatPlayGMPReduceRatio(missionCode)
	local t=0
	local a=#TppDefine.MISSION_CLEAR_RANK_LIST
	for a=a,missionClearRank,-1 do
		local n=TppDefine.MISSION_CLEAR_RANK_LIST[a]
		local e=this.RANK_BASE_GMP[n]
		if a<s then
			t=t+e
		else
			t=t+e*r
		end
	end
	return t
end
function this.GetMbMissionListParameterTable()
	local missionListParameterTable={}
	for t,a in pairs(TppDefine.MISSION_ENUM)do
		local missionCode=tonumber(t)
		local missionParams={}
		missionParams.missionId=missionCode
		if this.MISSION_GUARANTEE_GMP[missionCode]then
			--r51 Settings
			missionParams.baseGmp=this.MISSION_GUARANTEE_GMP[missionCode]*(TUPPMSettings.res_gmpMissionsMultiplier or 1)
			missionParams.currentGmp=this.GetMissionGuaranteeGMP(missionCode)
		end
		if this.MISSION_TASK_LIST[missionCode]then
			missionParams.completedTaskNum=TppUI.GetTaskCompletedNumber(missionCode)
			missionParams.maxTaskNum=#this.MISSION_TASK_LIST[missionCode]
			missionParams.taskList=this.MISSION_TASK_LIST[missionCode]
		end
		table.insert(missionListParameterTable,missionParams)
	end
	return missionListParameterTable
end
function this.GetMissionGuaranteeGMP(missionCode)
	--r51 Settings
	local rewardGMP=this.MISSION_GUARANTEE_GMP[missionCode]*(TUPPMSettings.res_gmpMissionsMultiplier or 1)
	local reducedRatio=this.GetRepeatPlayGMPReduceRatio(missionCode)
	local finalCreditGMP
	if this.IsUsedChickCap()then
		finalCreditGMP=(rewardGMP*reducedRatio)/2
	else
		finalCreditGMP=rewardGMP*reducedRatio
	end
	return finalCreditGMP
end
local pointFive=.5
function this.GetRepeatPlayGMPReduceRatio(missionCode)
	local numberOfTimesMissionCompleted=this.GetMissionClearCountFromHistory(missionCode)
	local reducedRatio=pointFive^numberOfTimesMissionCompleted
	
	--r51 Settings
	if TUPPMSettings.res_ENABLE_doNotReduceMissionGMPReward then
		return 1 --r23 Mission Rewards Ratio never reduced :D
	else
		return reducedRatio
	end
end
local a=0
function this.AddMissionClearHistory(missionCode)
	local sizeMinusOne=gvars.res_missionClearHistorySize-1
	for e=sizeMinusOne,0,-1 do
		gvars.res_missionClearHistory[e+1]=gvars.res_missionClearHistory[e]
	end
	gvars.res_missionClearHistory[0]=missionCode
	this.ClearOverSizeHistory(gvars.res_missionClearHistorySize)
end
function this.GetMissionClearCountFromHistory(missionCode)
	local e=0
	local a=gvars.res_missionClearHistorySize-1
	for a=0,a do
		if gvars.res_missionClearHistory[a]==missionCode then
			e=e+1
		end
	end
	return e
end
local n=.6
function this.CalcMissionClearHistorySize()
	local openMissionCount=TppStory.GetOpenMissionCount()
	local missionClearHistorySize
	if openMissionCount<=1 then
		missionClearHistorySize=1
	else
		missionClearHistorySize=math.floor(openMissionCount*n)
	end
	return missionClearHistorySize
end
function this.SetMissionClearHistorySize(t)
	if t>=TppDefine.MISSION_CLEAR_HISTORY_LIMIT then
		return
	end
	gvars.res_missionClearHistorySize=t
	this.ClearOverSizeHistory(t)
end
function this.ClearOverSizeHistory(res_missionClearHistorySize)
	for index=res_missionClearHistorySize,TppDefine.MISSION_CLEAR_HISTORY_LIMIT-1 do
		gvars.res_missionClearHistory[index]=a
	end
end
function this.SetSpecialBonusResultScore()
	if this.NO_SPECIAL_BONUS[vars.missionCode]then
		TppUiCommand.SetResultScore("invalid","bonus",0)
		TppUiCommand.SetResultScore("invalid","bonus",1)
		return
	end
	if mvars.res_isExistFirstSpecialBonus then
		this._SetSpecialBonusResultScore(0,"bestScoreBounus","bestScoreBounusScore",mvars.res_firstSpecialBonusMaxCount,this.COMMON_SCORE_PARAM.firstSpecialBonus,"isCompleteFirstBonus",mvars.res_firstBonusMissionTask)
	end
	if mvars.res_isExistSecondSpecialBonus then
		this._SetSpecialBonusResultScore(1,"bestScoreBounus2","bestScoreBounusScore2",mvars.res_secondSpecialBonusMaxCount,this.COMMON_SCORE_PARAM.secondSpecialBonus,"isCompleteSecondBonus",mvars.res_secondBonusMissionTask)
	end
end
function this._SetSpecialBonusResultScore(t,i,o,r,n,s,a)
	if not a.taskNo then
		TppUiCommand.SetResultScore("invalid","bonus",t)
		return
	end
	local n=this.MakeMissionTaskLangId(a.taskNo)
	local a=svars[i]
	if(not svars[s])and(a==0)then
		TppUiCommand.SetResultScore("invalid","bonus",t)
		return
	end
	local s=svars[o]
	local e=-1
	if a>0 then
		e=a
	end
	if e==-1 then
		TppUiCommand.SetResultScore(n,"bonus",t,e,s)
	else
		TppUiCommand.SetResultScore(n,"bonus_rate",t,e,r,s)
	end
end
function this.MakeMissionTaskLangId(t)
	local e=vars.missionCode
	if(e>=11e3)and(e<12e3)then
		e=e-1e3
	end
	return"task_mission_"..(string.format("%02d",vars.locationCode)..("_"..(tostring(e)..("_"..string.format("%02d",t)))))
end
function this.SaveMissionClearPlayStyleParameter()
	if svars.bestScorePerfectStealthNoKillBonusScore>0 then
		gvars.res_isPerfectStealth[0]=true
		Tpp.IncrementPlayData"totalPerfectStealthMissionClearCount"elseif svars.alertCount==0 then
		gvars.res_isStealth[0]=true
		Tpp.IncrementPlayData"totalStealthMissionClearCount"end
end
function this.DecidePlayStyle()
	local t=TppStory.GetCurrentStorySequence()
	if t<TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON then
		return 1
	end
	if vars.playerPlayFlag then
		if(bit.band(vars.playerPlayFlag,PlayerPlayFlag.USE_CHICKEN_CAP)==PlayerPlayFlag.USE_CHICKEN_CAP)then
			return 2
		end
	end
	local t=true
	for e=0,TppDefine.PLAYSTYLE_HISTORY_MAX do
		if gvars.res_isPerfectStealth[e]==false then
			t=false
			break
		end
	end
	if t then
		return 3
	end
	local t=true
	for e=0,TppDefine.PLAYSTYLE_HISTORY_MAX do
		if gvars.res_isStealth[e]==false then
			t=false
			break
		end
	end
	if t then
		return 4
	end
	local a,t=this.GetTotalHeadShotCount(),this.GetTotalNeutralizeCount()
	if t<1 then
		t=1
	end
	local t=a/t
	if t>=this.PLAYSTYLE_HEAD_SHOT then
		return 6
	end
	return this.DecideNeutralizePlayStyle()
end
function this.DEBUG_Init()
	mvars.debug.showHitRatio=false;(nil).AddDebugMenu("LuaMission","RES.hitRatio","bool",mvars.debug,"showHitRatio")
	mvars.debug.showMissionClearHistory=false;(nil).AddDebugMenu("LuaMission","RES.clearHistory","bool",mvars.debug,"showMissionClearHistory")
	mvars.debug.showMissionScoreTable=false;(nil).AddDebugMenu("LuaMission","RES.scoreTable","bool",mvars.debug,"showMissionScoreTable")
	mvars.debug.showPlayData=false;(nil).AddDebugMenu("LuaMission","RES.showPlayData","bool",mvars.debug,"showPlayData")
	mvars.debug.showPlayStyleHistory=false;(nil).AddDebugMenu("LuaMission","showPlayStyleHistory","bool",mvars.debug,"showPlayStyleHistory")
	mvars.debug.showPlayDataNeutralizeCount=false;(nil).AddDebugMenu("LuaMission","showPlayDataNeutralizeCount","bool",mvars.debug,"showPlayDataNeutralizeCount")
	mvars.debug.doForceSetPlayStyle=false;(nil).AddDebugMenu("LuaMission","doForceSetStyle","bool",mvars.debug,"doForceSetPlayStyle")
	mvars.debug.playStyleHistory=0;(nil).AddDebugMenu("LuaMission","styleHistory","int32",mvars.debug,"playStyleHistory")
	mvars.debug.playStyleIsPerfectStealth=false;(nil).AddDebugMenu("LuaMission","styleIsPerfectStealth","bool",mvars.debug,"playStyleIsPerfectStealth")
	mvars.debug.playStyleIsStealth=false;(nil).AddDebugMenu("LuaMission","styleIsStealth","bool",mvars.debug,"playStyleIsStealth")
	mvars.debug.playStyleHeadShotCount=0;(nil).AddDebugMenu("LuaMission","styleHeadShotCount","int32",mvars.debug,"playStyleHeadShotCount")
	mvars.debug.playStyleSaveIndex=-1;(nil).AddDebugMenu("LuaMission","styleSaveIndex","int32",mvars.debug,"playStyleSaveIndex")
	mvars.debug.playStyleNeutralizeCount=0;(nil).AddDebugMenu("LuaMission","styleNeutralizeCount","int32",mvars.debug,"playStyleNeutralizeCount")
	mvars.debug.addNewPlayStyleHistory=false;(nil).AddDebugMenu("LuaMission","addNewPlayStyleHistory","bool",mvars.debug,"addNewPlayStyleHistory")
	mvars.debug.beforeMaxPlayRecord=false;(nil).AddDebugMenu("LuaMission","beforeMaxPlayRecord","bool",mvars.debug,"beforeMaxPlayRecord")
end
this.DEBUG_NEUTRALIZE_TYPE_TEXT={" HOLDUP","    CQC","NO_KILL","  KNIFE","HANDGUN","SUBMGUN","SHOTGUN","ASSAULT","MCH_GUN"," SNIPER","MISSILE","GRENADE","   MINE","  QUIET","  D_DOG","D_HORSE","D_WLKER","VEHICLE","SP_HELI"," ASSIST"}
function this.DebugUpdate()
	local r=5
	local s=svars
	local mvars=mvars
	local t=(nil).NewContext()
	if mvars.debug.showHitRatio then
		local e=vars.playerShootCountInMission-vars.shootHitCountEliminatedInMission
		local a=0
		if e>0 then
			a=vars.shootHitCountInMission/e
		end(nil).Print(t,{.5,.5,1},"LuaMission RES.hitRatio");(nil).Print(t,"vars.playerShootCountInMission = "..tostring(vars.playerShootCountInMission));(nil).Print(t,"vars.shootHitCountInMission = "..tostring(vars.shootHitCountInMission));(nil).Print(t,"vars.shootHitCountEliminatedInMission = "..tostring(vars.shootHitCountEliminatedInMission));(nil).Print(t,"valid shoot count = "..tostring(e));(nil).Print(t,"hitRatio = "..tostring(a));(nil).Print(t,"svars.headshotCount2 = "..tostring(s.headshotCount2));(nil).Print(t,"svars.neutralizeCount = "..tostring(s.neutralizeCount));(nil).Print(t,"svars.shootNeutralizeCount = "..tostring(s.shootNeutralizeCount))
	end
	if mvars.debug.showMissionClearHistory then(nil).Print(t,{.5,.5,1},"LuaMission RES.clearHistory");(nil).Print(t,"historySize = "..tostring(gvars.res_missionClearHistorySize))
		local a={}
		local s,e=0,1
		local n=gvars.res_missionClearHistorySize-1
		for t=0,n do
			e=math.floor(s/r)+1
			a[e]=a[e]or"   "a[e]=a[e]..(tostring(gvars.res_missionClearHistory[t])..", ")s=s+1
		end
		for e=1,e do(nil).Print(t,a[e])
		end
	end
	if mvars.debug.showMissionScoreTable and mvars.res_missionScoreTable then(nil).Print(t,{.5,.5,1},"LuaMission RES.scoreTable");(nil).Print(t,"baseTime")
		for s,e in ipairs(TppDefine.MISSION_CLEAR_RANK_LIST)do
			local a=mvars.res_missionScoreTable.baseTime[e];(nil).Print(t,"rank = "..(tostring(e)..(": baseTime = "..(tostring(a).."[s]."))))
		end
		if mvars.res_missionScoreTable.tacticalTakeDownPoint then(nil).Print(t,"tacticalTakeDownPoint : countLimit = "..tostring(mvars.res_missionScoreTable.tacticalTakeDownPoint.countLimit))
		else(nil).Print(t,"cannot find tacticalTakeDown param")
		end
	end
	if mvars.debug.showPlayData then(nil).Print(t,{.5,.5,1},"LuaMission RES.showPlayData");(nil).Print(t,"gvars.totalMissionClearCount = "..tostring(gvars.totalMissionClearCount));(nil).Print(t,"gvars.totalPerfectStealthMissionClearCount = "..tostring(gvars.totalPerfectStealthMissionClearCount));(nil).Print(t,"gvars.totalStealthMissionClearCount = "..tostring(gvars.totalStealthMissionClearCount));(nil).Print(t,"gvars.totalRetryCount = "..tostring(gvars.totalRetryCount));(nil).Print(t,"gvars.totalNeutralizeCount = "..tostring(gvars.totalNeutralizeCount));(nil).Print(t,"gvars.totalKillCount = "..tostring(gvars.totalKillCount));(nil).Print(t,"gvars.totalHelicopterDestoryCount = "..tostring(gvars.totalHelicopterDestoryCount));(nil).Print(t,"gvars.totalBreakVehicleCount = "..tostring(gvars.totalBreakVehicleCount));(nil).Print(t,"gvars.totalBreakPlacedGimmickCount = "..tostring(gvars.totalBreakPlacedGimmickCount));(nil).Print(t,"gvars.totalBreakBurglarAlarmCount = "..tostring(gvars.totalBreakBurglarAlarmCount));(nil).Print(t,"gvars.totalWalkerGearDestoryCount = "..tostring(gvars.totalWalkerGearDestoryCount));(nil).Print(t,"gvars.totalMineRemoveCount = "..tostring(gvars.totalMineRemoveCount));(nil).Print(t,"gvars.totalAnnihilateOutPostCount = "..tostring(gvars.totalAnnihilateOutPostCount));(nil).Print(t,"gvars.totalAnnihilateBaseCount = "..tostring(gvars.totalAnnihilateBaseCount));(nil).Print(t,"gvars.totalInterrogateCount = "..tostring(gvars.totalInterrogateCount));(nil).Print(t,"gvars.totalRescueCount = "..tostring(gvars.totalRescueCount));(nil).Print(t,"vars.totalMarkingCount = "..tostring(vars.totalMarkingCount))
	end
	if mvars.debug.showPlayStyleHistory then(nil).Print(t,{.5,.5,1},"LuaMission RES.showPlayStyleHistory");(nil).Print(t,{.5,1,.5},"gvars.res_neutralizeHistorySize = "..tostring(gvars.res_neutralizeHistorySize));(nil).Print(t,{.5,1,.5}," history = 0         | history = 1          | history = 2        ");(nil).Print(t,{.5,1,.5},"isPerfectStealth");(nil).Print(t,"( "..(tostring(gvars.res_isPerfectStealth[0])..(" ) | ( "..(tostring(gvars.res_isPerfectStealth[1])..(" ) | ( "..(tostring(gvars.res_isPerfectStealth[2]).." )"))))));(nil).Print(t,{.5,1,.5},"isStealth");(nil).Print(t,"( "..(tostring(gvars.res_isStealth[0])..(" ) | ( "..(tostring(gvars.res_isStealth[1])..(" ) | ( "..(tostring(gvars.res_isStealth[2]).." )"))))));(nil).Print(t,{.5,1,.5},"Head shot count");(nil).Print(t,string.format("( %07d ) | ( %07d ) | ( %07d )",gvars.res_headShotCount[0],gvars.res_headShotCount[1],gvars.res_headShotCount[2]));(nil).Print(t,{.5,1,.5},"( historyIndex, neutralizeType, count )")
		for s=0,TppDefine.PLAYSTYLE_SAVE_INDEX_MAX-1 do
			local a=""local n=this.DEBUG_NEUTRALIZE_TYPE_TEXT[s+1]
			for e=0,TppDefine.PLAYSTYLE_HISTORY_MAX do
				local e=string.format("( %02d, %s, %03d ) | ",e,n,gvars.res_neutralizeCount[e*TppDefine.PLAYSTYLE_SAVE_INDEX_MAX+s])a=a..e
			end(nil).Print(t,a)
		end
	end
	if mvars.debug.showPlayDataNeutralizeCount then(nil).Print(t,{.5,.5,1},"LuaMission RES.showPlayDataNeutralizeCount");(nil).Print(t,{.5,1,.5},"( neutralizeType, count )")
		for a=0,TppDefine.PLAYSTYLE_SAVE_INDEX_MAX-1 do
			local e=this.DEBUG_NEUTRALIZE_TYPE_TEXT[a+1]
			local e=string.format("( %s, %016d ) | ",e,gvars.res_neutralizeCountForPlayData[a]);(nil).Print(t,e)
		end
	end
	if mvars.debug.doForceSetPlayStyle then
		mvars.debug.doForceSetPlayStyle=false
		local e=mvars.debug.playStyleHistory
		if e<0 then
			e=0
			mvars.debug.playStyleHistory=0
		end
		if e>2 then
			e=2
			mvars.debug.playStyleHistory=2
		end
		gvars.res_isPerfectStealth[e]=mvars.debug.playStyleIsPerfectStealth
		gvars.res_isStealth[e]=mvars.debug.playStyleIsStealth
		if mvars.debug.playStyleHeadShotCount>0 then
			gvars.res_headShotCount[e]=mvars.debug.playStyleHeadShotCount
		end
		local t=mvars.debug.playStyleSaveIndex
		if t<0 then
			mvars.debug.playStyleSaveIndex=0
			t=0
		end
		if t>=TppDefine.PLAYSTYLE_SAVE_INDEX_MAX then
			mvars.debug.playStyleSaveIndex=TppDefine.PLAYSTYLE_SAVE_INDEX_MAX-1
			t=TppDefine.PLAYSTYLE_SAVE_INDEX_MAX-1
		end
		if mvars.debug.playStyleNeutralizeCount>0 then
			gvars.res_neutralizeCount[e*TppDefine.PLAYSTYLE_SAVE_INDEX_MAX+t]=mvars.debug.playStyleNeutralizeCount
		end
	end
	if mvars.debug.addNewPlayStyleHistory then
		mvars.debug.addNewPlayStyleHistory=false
		this.AddNewPlayStyleHistory()
	end
	if mvars.debug.beforeMaxPlayRecord then
		mvars.debug.beforeMaxPlayRecord=false
		local e=999999997
		local t={"totalMissionClearCount","totalPerfectStealthMissionClearCount","totalStealthMissionClearCount","totalRetryCount","totalNeutralizeCount","totalKillCount","totalBreakVehicleCount","totalHelicopterDestoryCount","totalWalkerGearDestoryCount","totalBreakPlacedGimmickCount","totalBreakBurglarAlarmCount","totalMineRemoveCount","totalAnnihilateOutPostCount","totalAnnihilateBaseCount","totalMarkingCount","totalInterrogateCount","totalRescueCount","totalheadShotCount","rnk_TotalTacticalTakeDownCount"}
		for a,t in ipairs(t)do
			gvars[t]=e
		end
		for t=0,19 do
			gvars.res_neutralizeCountForPlayData[t]=e
		end
		gvars.chickenCapClearCount=e
	end
end
function this.Messages()
	return Tpp.StrCode32Table{
		Player={
			{msg="PlayerDamaged",
				func=this.IncrementTakeHitCount}
		},
		GameObject={
			{msg="Dead",
				func=function(t,e,a,a)
					if not Tpp.IsLocalPlayer(e)then
						return
					end
					if Tpp.IsEnemyWalkerGear(t)then
						Tpp.IncrementPlayData"totalWalkerGearDestoryCount"
					end
				end},
			{msg="TapHeadShotFar",
				func=function(t)
					this.OnTacticalActionPoint(t,"TapHeadShotFar")
				end},
			{msg="TapRocketArm",
				func=function(t)
					this.OnTacticalActionPoint(t,"TapRocketArm")
				end},
			{msg="TapHoldup",
				func=function(t)
					this.OnTacticalActionPoint(t,"TapHoldup")
				end},
			{msg="TapCqc",
				func=function(t)
					this.OnTacticalActionPoint(t,"TapCqc")
				end},
			{msg="HeadShot",
				func=this.OnHeadShot},
			{msg="Neutralize",
				func=this.OnNeutralize},
			{msg="InterrogateSetMarker",
				func=this.IncrementInterrogateCount},
			{msg="BreakGimmickBurglarAlarm",
				func=function(e)
					if not Tpp.IsLocalPlayer(e)then
						return
					end
					Tpp.IncrementPlayData"totalBreakBurglarAlarmCount"
				end}
		}
	}
end
local t=MAX_32BIT_UINT
local t=MAX_32BIT_UINT
local t=true
local n=false
function this.IncrementInterrogateCount()
	Tpp.IncrementPlayData"totalInterrogateCount"TppChallengeTask.RequestUpdate"PLAY_RECORD"if svars.interrogateCount<MAX_32BIT_UINT then
		svars.interrogateCount=svars.interrogateCount+1
	end
end
function this.IncrementTakeHitCount()
	if mvars.res_noTakeHitCount then
		return
	end
	if svars.oldTakeHitCount<svars.takeHitCount then
		svars.oldTakeHitCount=svars.takeHitCount
		this.CallCountAnnounce("result_hit",svars.takeHitCount,t)
	end
end
function this.OnTacticalActionPoint(t,a)
	if SendCommand(t,{id="IsDoneTacticalTakedown"})then
	else
		SendCommand(t,{id="SetTacticalTakedown"})
		this.AddTacticalActionPoint{isSneak=true,gameObjectId=t,tacticalTakeDownType=a}
	end
end
function this.GetTacticalActionPoint(e)
	if e then
		return svars.tacticalActionPoint
	else
		if vars.missionCode~=50050 then
			return 0
		end
		return svars.tacticalActionPointClient
	end
end
function this.AddTacticalActionPoint(t)
	if mvars.res_noTacticalTakeDown then
		return
	end
	local function r(t,e)
		if t then
			svars.tacticalActionPoint=e
		else
			if vars.missionCode~=50050 then
				return
			end
			svars.tacticalActionPointClient=e
		end
	end
	local a=true
	if t and(t.isSneak==false)then
		a=false
	end
	local s=this.GetTacticalActionPoint(a)
	if a then
		Tpp.IncrementPlayData"rnk_TotalTacticalTakeDownCount"TppChallengeTask.RequestUpdate"PLAY_RECORD"
		--> Patch 1090
		TppUI.UpdateOnlineChallengeTask{detectType=31,diff=1}
		--<
	end
	if s>=mvars.res_missionScoreTable.tacticalTakeDownPoint.countLimit then
		return
	end
	r(a,s+1)
	if a then
		this.CallCountAnnounce("result_tactical_takedown",svars.tacticalActionPoint,n)
		TppTutorial.DispGuide("TAKE_DOWN",TppTutorial.DISPLAY_OPTION.TIPS)
		local e=t and t.tacticalTakeDownType
		if e then
			Mission.SendMessage("Mission","OnAddTacticalActionPoint",t.gameObjectId,t.tacticalTakeDownType)
		end
	end
end
function this.CallCountAnnounce(t,a,s)
	TppUiCommand.CallCountAnnounce(t,a,s)
end
this.PLAYER_CAUSE_TO_SAVE_INDEX={[NeutralizeCause.CQC]=1,[NeutralizeCause.NO_KILL]=2,[NeutralizeCause.NO_KILL_BULLET]=2,[NeutralizeCause.CQC_KNIFE]=3,[NeutralizeCause.HANDGUN]=4,[NeutralizeCause.SUBMACHINE_GUN]=5,[NeutralizeCause.SHOTGUN]=6,[NeutralizeCause.ASSAULT_RIFLE]=7,[NeutralizeCause.MACHINE_GUN]=8,[NeutralizeCause.SNIPER_RIFLE]=9,[NeutralizeCause.MISSILE]=10,[NeutralizeCause.GRENADE]=11,[NeutralizeCause.MINE]=12}
this.NPC_CAUSE_TO_SAVE_INDEX={[NeutralizeCause.QUIET]=13,[NeutralizeCause.D_DOG]=14,[NeutralizeCause.D_HORSE]=15,[NeutralizeCause.D_WALKER_GEAR]=16,[NeutralizeCause.VEHICLE]=17,[NeutralizeCause.SUPPORT_HELI]=18,[NeutralizeCause.ASSIST]=19}
this.NEUTRALIZE_PLAY_STYLE_ID={7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,26,27,28}
function this.GetPlayStyleSaveIndex(n,r,a,t)
	if a==NeutralizeType.INVALID then
		return
	end
	local n=this.NPC_CAUSE_TO_SAVE_INDEX[t]
	if n then
		return n
	end
	if a==NeutralizeType.HOLDUP then
		return 0
	end
	if Tpp.IsPlayer(r)then
		local a={[NeutralizeCause.NO_KILL_BULLET]=true,[NeutralizeCause.HANDGUN]=true,[NeutralizeCause.SUBMACHINE_GUN]=true,[NeutralizeCause.SHOTGUN]=true,[NeutralizeCause.ASSAULT_RIFLE]=true,[NeutralizeCause.MACHINE_GUN]=true,[NeutralizeCause.SNIPER_RIFLE]=true,[NeutralizeCause.MISSILE]=true}
		if a[t]then
			if svars.shootNeutralizeCount<MAX_32BIT_UINT then
				svars.shootNeutralizeCount=svars.shootNeutralizeCount+1
			end
		end
		local e=this.PLAYER_CAUSE_TO_SAVE_INDEX[t]
		if e then
			return e
		else
			return
		end
	end
end
function this.OnNeutralize(r,n,a,t)
	local t=this.GetPlayStyleSaveIndex(r,n,a,t)
	if not t then
		return
	end
	this.IncrementPlayDataNeutralizeCount(t)
	if mvars.res_noResult then
		return
	end
	if svars.neutralizeCount<MAX_32BIT_UINT then
		svars.neutralizeCount=svars.neutralizeCount+1
	end
	local e=gvars.res_neutralizeCount[t]
	if e>=255 then
		return
	end
	gvars.res_neutralizeCount[t]=e+1
end
function this.IncrementPlayDataNeutralizeCount(e)
	Tpp.IncrementPlayData"totalNeutralizeCount"if gvars.res_neutralizeCountForPlayData[e]<MAX_32BIT_UINT then
		gvars.res_neutralizeCountForPlayData[e]=gvars.res_neutralizeCountForPlayData[e]+1
	end
end
function this.OnHeadShot(n,n,a,t)
	if not Tpp.IsPlayer(a)then
		return
	end
	local e=this.IsCountUpHeadShot(t)
	if e then
		Tpp.IncrementPlayData"totalheadShotCount"TppChallengeTask.RequestUpdate"PLAY_RECORD"
		--> Patch 1090
		TppUI.UpdateOnlineChallengeTask{detectType=29,diff=1}
		--<
	end
	if mvars.res_noResult then
		return
	end
	if e then
		if svars.headshotCount2<MAX_32BIT_UINT then
			svars.headshotCount2=svars.headshotCount2+1
			TppUiCommand.CallCountAnnounce("playdata_playing_headshot",svars.headshotCount2,false)
		end
		if gvars.res_headShotCount[0]<255 then
			gvars.res_headShotCount[0]=gvars.res_headShotCount[0]+1
		end
	end
end
function this.IsCountUpHeadShot(t)
	local e=false
	if bit.band(t,HeadshotMessageFlag.IS_JUST_UNCONSCIOUS)==HeadshotMessageFlag.IS_JUST_UNCONSCIOUS then
		if HeadshotMessageFlag.NEUTRALIZE_DONE==nil then
			e=true
		else
			if bit.band(t,HeadshotMessageFlag.NEUTRALIZE_DONE)~=HeadshotMessageFlag.NEUTRALIZE_DONE then
				e=true
			end
		end
	end
	return e
end
function this.AddNewPlayStyleHistory()
	if gvars.res_neutralizeHistorySize<TppDefine.PLAYSTYLE_HISTORY_MAX then
		gvars.res_neutralizeHistorySize=gvars.res_neutralizeHistorySize+1
	end
	for t=(TppDefine.PLAYSTYLE_HISTORY_MAX-1),0,-1 do
		for e=0,TppDefine.PLAYSTYLE_SAVE_INDEX_MAX-1 do
			gvars.res_neutralizeCount[(t+1)*TppDefine.PLAYSTYLE_SAVE_INDEX_MAX+e]=gvars.res_neutralizeCount[t*TppDefine.PLAYSTYLE_SAVE_INDEX_MAX+e]
		end
		gvars.res_headShotCount[(t+1)]=gvars.res_headShotCount[t]
		gvars.res_isStealth[(t+1)]=gvars.res_isStealth[t]
		gvars.res_isPerfectStealth[(t+1)]=gvars.res_isPerfectStealth[t]
	end
	this.ClearNewestPlayStyleHistory()
end
function this.ClearNewestPlayStyleHistory()
	for e=0,TppDefine.PLAYSTYLE_SAVE_INDEX_MAX-1 do
		gvars.res_neutralizeCount[e]=0
	end
	gvars.res_headShotCount[0]=0
	gvars.res_isStealth[0]=false
	gvars.res_isPerfectStealth[0]=false
end
function this.GetTotalHeadShotCount()
	local e=0
	for t=0,TppDefine.PLAYSTYLE_HISTORY_MAX do
		e=e+gvars.res_headShotCount[t]
	end
	return e
end
function this.GetTotalNeutralizeCount()
	local e=0
	for t=0,TppDefine.PLAYSTYLE_HISTORY_MAX do
		for a=0,TppDefine.PLAYSTYLE_SAVE_INDEX_MAX-1 do
			e=e+gvars.res_neutralizeCount[t*TppDefine.PLAYSTYLE_SAVE_INDEX_MAX+a]
		end
	end
	return e
end
function this.IsTotalPlayStyleStealth()
	local e=true
	for t=0,TppDefine.PLAYSTYLE_HISTORY_MAX do
		if gvars.res_isStealth[t]==false then
			e=false
			break
		end
	end
	return e
end
function this.GetNeutralizeCountBySaveIndex(t)
	local e=0
	for a=0,TppDefine.PLAYSTYLE_HISTORY_MAX do
		e=e+gvars.res_neutralizeCount[a*TppDefine.PLAYSTYLE_SAVE_INDEX_MAX+t]
	end
	return e
end
function this.DecideNeutralizePlayStyle()
	local t
	local n
	local a=-1
	for s=0,TppDefine.PLAYSTYLE_SAVE_INDEX_MAX-1 do
		local r=this.GetNeutralizeCountBySaveIndex(s)
		if a<r then
			t=false
			n=s
			a=r
		elseif a==this.GetNeutralizeCountBySaveIndex(s)then
			t=true
		end
	end
	if t then
		return 28
	else
		local e=this.NEUTRALIZE_PLAY_STYLE_ID[n+1]
		if e then
			return e
		else
			return
		end
	end
end

--r27 Processed resources and medicinal plants are rewarded on mission completion based on clear rank
function this.AddResultResources(missionClearRankCode)
	--r51 Settings
	if not TUPPMSettings.res_ENABLE_additionalMissionCompletionRewards then return end
	
	local materialNames={
		"CommonMetal",
		"MinorMetal",
		"PreciousMetal",
		"FuelResource",
		"BioticResource",
	}
	local plantsName={
		"Plant2000",
		"Plant2001",
		"Plant2002",
		"Plant2003",
		"Plant2004",
		"Plant2005",
		"Plant2006",
		"Plant2007",
	}

	if missionClearRankCode==nil then
		missionClearRankCode=1
	end

	--  local unProcessedResourcesCount={S=20000,A=8000,B=4000,C=2000,D=1000,E=500} --can't get unprocessed resources to work
	local processedResourcesCount={S=5000,A=3000,B=2000,C=1000,D=500,E=100} --r28 Adjusted rewards
	local plantsCount={S=250,A=150,B=100,C=50,D=25,E=10}

	local missionClearRank=TppDefine.MISSION_CLEAR_RANK_LIST[missionClearRankCode]

	--  TUPPMLog.Log("missionClearRankCode "..tostring(missionClearRankCode))
	--  TUPPMLog.Log("missionClearRank "..tostring(missionClearRank))
	for index, name in pairs(materialNames) do
		--    TppMotherBaseManagement.AddTempResource{resource=name,count=unProcessedResourcesCount[missionClearRank]}
		--    TppMotherBaseManagement.AddTempGimmickResource{resource=name,count=unProcessedResourcesCount[missionClearRank]}
		--    TppMotherBaseManagement.DirectAddResource{resource=name,count=unProcessedResourcesCount[missionClearRank],requestProcess=true}
		TppMotherBaseManagement.DirectAddResource{resource=name,count=processedResourcesCount[missionClearRank]}
		--    TUPPMLog.Log("Added "..tostring(name).." unprocessed x"..tostring(unProcessedResourcesCount[missionClearRank]).." processed x"..tostring(processedResourcesCount[missionClearRank]))
	end

	for index, name in pairs(plantsName) do
		TppMotherBaseManagement.DirectAddResource{resource=name,count=plantsCount[missionClearRank]}
		--    TUPPMLog.Log("Added "..tostring(name).." count x"..tostring(plantsCount[missionClearRank]))
	end

	TppUiCommand.AnnounceLogViewLangId("reward_processed_materials", processedResourcesCount[missionClearRank])
	TppUiCommand.AnnounceLogViewLangId("reward_harvested_plants", plantsCount[missionClearRank])
end

return this
