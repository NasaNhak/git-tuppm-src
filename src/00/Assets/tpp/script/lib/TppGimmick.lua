local e={}
local i=Fox.StrCode32
local m=GameObject.GetTypeIndex
local l=GameObject.GetGameObjectId
local o=GameObject.NULL_ID
local a=Tpp.IsTypeTable
e.MissionCollectionTable={[10020]={"col_diamond_s_s10020_0000"},[10033]={"col_develop_HighprecisionAR_s10033_0000"},[10036]={"col_herb_10036","col_material_CM_10036"},[10041]={"col_diamond_l_s10041_0000"},[10043]={"col_diamond_l_s10043_0000"},[10070]={"col_develop_Semiauto_SR_s10070_0000"},[10082]={"col_herb_r_s10082_0000"},[10085]={"col_herb_l_s10085_0000"},[10093]={"col_diamond_l_s10093_0000"},[10100]={"col_diamond_s_s10100_0000","col_diamond_s_s10100_0001","col_diamond_s_s10100_0002"},[10110]={"col_diamond_l_s10110_0000","col_diamond_l_s10110_0001","col_diamond_l_s10110_0002"},[10120]={"col_diamond_l_s10120_0000"},[10156]={"col_diamond_l_s10156_0000"},[10171]={"col_diamond_l_s10171_0000"},[10200]={"col_herb_l_s10200_0000","col_herb_l_s10200_0001","col_herb_l_s10200_0002"}}
e.MissionCollectionMissionTaskTable={[10020]={30},[10033]={17},[10036]={17,18},[10043]={"first"},[10070]={27},[10082]={22},[10085]={31},[10120]={12},[10093]={27},[10171]={40}}
e.GIMMICK_TYPE={NONE=0,ANTN=1,MCHN=2,CMMN=3,GUN=4,MORTAR=5,GNRT=6,CNTN=7,ANTIAIR=8,AACR=9,LIGHT=10,TOWER=11,TLET=12,TRSH=13,CSET=14,SWTC=15,FLOWSTATION_TANK001=100,FLOWSTATION_TANK002=101,FACTORY_WALL=102,FACTORY_FRAME=103,FACTORY_WTTR=104,FACTORY_TNNL=105,LAB_BRDG=106,FACTORY_TANK=107,FACTORY_WTNK=108,FACTORY_WSST=109,FLOWSTATION_PDOR=110,FACTORY_CRTN=111,FLOWSTATION_COPS=112,MAX=255}
local gimmickDestroyRadarTable={[e.GIMMICK_TYPE.AACR]="destroyRadar"}
e.COLLECTION_REPOP_COUNT_DECREMENT_TABLE={[TppCollection.TYPE_DIAMOND_LARGE]=60,[TppCollection.TYPE_DIAMOND_SMALL]=100,[TppCollection.TYPE_MATERIAL_CM_0]=100,[TppCollection.TYPE_MATERIAL_CM_1]=100,[TppCollection.TYPE_MATERIAL_CM_2]=100,[TppCollection.TYPE_MATERIAL_CM_3]=100,[TppCollection.TYPE_MATERIAL_CM_4]=100,[TppCollection.TYPE_MATERIAL_CM_5]=100,[TppCollection.TYPE_MATERIAL_CM_6]=100,[TppCollection.TYPE_MATERIAL_CM_7]=100,[TppCollection.TYPE_MATERIAL_MM_0]=100,[TppCollection.TYPE_MATERIAL_MM_1]=100,[TppCollection.TYPE_MATERIAL_MM_2]=100,[TppCollection.TYPE_MATERIAL_MM_3]=100,[TppCollection.TYPE_MATERIAL_MM_4]=100,[TppCollection.TYPE_MATERIAL_MM_5]=100,[TppCollection.TYPE_MATERIAL_MM_6]=100,[TppCollection.TYPE_MATERIAL_MM_7]=100,[TppCollection.TYPE_MATERIAL_PM_0]=100,[TppCollection.TYPE_MATERIAL_PM_1]=100,[TppCollection.TYPE_MATERIAL_PM_2]=100,[TppCollection.TYPE_MATERIAL_PM_3]=100,[TppCollection.TYPE_MATERIAL_PM_4]=100,[TppCollection.TYPE_MATERIAL_PM_5]=100,[TppCollection.TYPE_MATERIAL_PM_6]=100,[TppCollection.TYPE_MATERIAL_PM_7]=100,[TppCollection.TYPE_MATERIAL_FR_0]=100,[TppCollection.TYPE_MATERIAL_FR_1]=100,[TppCollection.TYPE_MATERIAL_FR_2]=100,[TppCollection.TYPE_MATERIAL_FR_3]=100,[TppCollection.TYPE_MATERIAL_FR_4]=100,[TppCollection.TYPE_MATERIAL_FR_5]=100,[TppCollection.TYPE_MATERIAL_FR_6]=100,[TppCollection.TYPE_MATERIAL_FR_7]=100,[TppCollection.TYPE_MATERIAL_BR_0]=100,[TppCollection.TYPE_MATERIAL_BR_1]=100,[TppCollection.TYPE_MATERIAL_BR_2]=100,[TppCollection.TYPE_MATERIAL_BR_3]=100,[TppCollection.TYPE_MATERIAL_BR_4]=100,[TppCollection.TYPE_MATERIAL_BR_5]=100,[TppCollection.TYPE_MATERIAL_BR_6]=100,[TppCollection.TYPE_MATERIAL_BR_7]=100,[TppCollection.TYPE_HERB_G_CRESCENT]=100,[TppCollection.TYPE_HERB_A_PEACH]=100,[TppCollection.TYPE_HERB_DIGITALIS_P]=100,[TppCollection.TYPE_HERB_DIGITALIS_R]=100,[TppCollection.TYPE_HERB_B_CARROT]=100,[TppCollection.TYPE_HERB_WORM_WOOD]=100,[TppCollection.TYPE_HERB_TARRAGON]=100,[TppCollection.TYPE_HERB_HAOMA]=100,[TppCollection.TYPE_HERB_0]=100,[TppCollection.TYPE_HERB_1]=100}
function e.Messages()
	return Tpp.StrCode32Table{Radio={{msg="Finish",sender="f1000_rtrg2020",func=function()
		TppUI.ShowAnnounceLog"unlockLz"end}},UI={{msg="EndFadeIn",sender="FadeInOnGameStart",func=function()
		e.OnMissionGameStart()
		end,option={isExecMissionPrepare=true,isExecMissionClear=true}}},nil}
end
function e.IsBroken(gimmickDetailsTable)
	if not a(gimmickDetailsTable)then
		return
	end
	local gimmickId,searchFromSaveData
	gimmickId=gimmickDetailsTable.gimmickId
	searchFromSaveData=gimmickDetailsTable.searchFromSaveData
	if not gimmickId then
		return
	end
	if not mvars.gim_identifierParamTable then
		return
	end
	local gimmickData=mvars.gim_identifierParamTable[gimmickId]
	if Gimmick.IsBrokenGimmick and gimmickData then
		if searchFromSaveData then
			return Gimmick.IsBrokenGimmick(gimmickData.type,gimmickData.locatorName,gimmickData.dataSetName)
		else
			return Gimmick.IsBrokenGimmick(gimmickData.type,gimmickData.locatorName,gimmickData.dataSetName,1)
		end
	end
end
function e.ResetGimmick(n)
	if not a(n)then
		return
	end
	if not e.IsBroken(n)then
		return
	end
	local e
	e=n.gimmickId
	if not e then
		return
	end
	local e=mvars.gim_identifierParamTable[e]
	if Gimmick.ResetGimmick and e then
		Gimmick.ResetGimmick(e.type,e.locatorName,e.dataSetName)
	end
end
function e.EnableMarkerGimmick(e)
	local e=mvars.gim_identifierParamTable[e]
	if not Gimmick.BreakGimmick then
		return
	end
	TUPPMLog.Log("EnableMarkerGimmick:"..tostring(InfInspect.Inspect(e)),1)
	Gimmick.EnableMarkerGimmick(e.type,e.locatorName,e.dataSetName,true)
end
function e.OnAllocate(e)
	if TppLocation.IsAfghan()then
		TppCollection.SetScriptDeclVars("col_daimondStatus_afgh","col_markerStatus_afgh","col_isRegisteredInDb_afgh")
	elseif TppLocation.IsMiddleAfrica()then
		TppCollection.SetScriptDeclVars("col_daimondStatus_mafr","col_markerStatus_mafr","col_isRegisteredInDb_mafr")
	elseif TppLocation.IsMotherBase()then
		TppCollection.SetScriptDeclVars("col_daimondStatus_mtbs","col_markerStatus_mtbs","col_isRegisteredInDb_mtbs")
	end
end
function e.Init(n)
	e.messageExecTable=Tpp.MakeMessageExecTable(e.Messages())
	if TppMission.IsFreeMission(vars.missionCode)then
		Gimmick.EspionageBoxOnGround(false)
	else
		Gimmick.EspionageBoxOnGround(true)
	end
	if TppMission.IsFreeMission(vars.missionCode)then
		mvars.gim_shownEspionageBox=true
		Gimmick.EspionageBoxAllInvisible(false)
	elseif(gvars.heli_missionStartRoute~=0)or(not TppMission.IsMissionStart())then
		mvars.gim_shownEspionageBox=false
		Gimmick.EspionageBoxAllInvisible(true)
	else
		mvars.gim_shownEspionageBox=true
		Gimmick.EspionageBoxAllInvisible(false)
	end
	TppTerminal.InitializeBluePrintLocatorIdTable()
	if TppMission.IsMissionStart()then
		for i,t in pairs(e.MissionCollectionTable)do
			local n=(vars.missionCode==i)
			if n==false then
				if TppMission.IsHardMission(vars.missionCode)then
					local e=TppMission.GetNormalMissionCodeFromHardMission(vars.missionCode)n=(e==i)
				end
			end
			e.EnableCollectionTable(t,n,true)
		end
		do
			local t={"col_develop_Revolver_Shotgun"}
			local n
			local i=TppStory.GetCurrentStorySequence()
			if i>=TppDefine.STORY_SEQUENCE.CLEARD_TAKE_OUT_THE_CONVOY then
				n=true
			else
				n=false
			end
			e.EnableCollectionTable(t,n)
		end
		do
			local i={"col_develop_Emergencyrescue"}
			local n
			local t=TppStory.GetCurrentStorySequence()
			if t>=TppDefine.STORY_SEQUENCE.CLEARD_ELIMINATE_THE_POWS then
				n=true
			else
				n=false
			end
			e.EnableCollectionTable(i,n)
		end
		do
			local t={"col_develop_Antimaterial"}
			local n
			local i=TppStory.GetCurrentStorySequence()
			if i>=TppDefine.STORY_SEQUENCE.CLEARD_WHITE_MAMBA then
				n=true
			else
				n=false
			end
			e.EnableCollectionTable(t,n)
		end
		do
			local t={"col_develop_Highprecision_SMG"}
			local n
			local i=TppStory.GetCurrentStorySequence()
			if i>=TppDefine.STORY_SEQUENCE.CLEARD_WHITE_MAMBA then
				n=true
			else
				n=false
			end
			e.EnableCollectionTable(t,n)
		end
		do
			local i={"col_develop_FLamethrower"}
			local n
			local t=TppStory.GetCurrentStorySequence()
			if t>=TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO then
				n=true
			else
				n=false
			end
			e.EnableCollectionTable(i,n)
		end
		do
			local t={"col_develop_HighprecisionAR"}
			local n
			local i=TppStory.GetCurrentStorySequence()
			if i>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON then
				n=true
			else
				n=false
			end
			e.EnableCollectionTable(t,n)
		end
		do
			local t={"col_develop_Semiauto_SR"}
			local n
			local i=TppStory.GetCurrentStorySequence()
			if i>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON then
				n=true
			else
				n=false
			end
			e.EnableCollectionTable(t,n)
		end
		do
			local i={"col_develop_Shield"}
			local n
			local t=TppStory.GetCurrentStorySequence()
			if t>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON then
				n=true
			else
				n=false
			end
			e.EnableCollectionTable(i,n)
		end
		do
			local i={"col_develop_Shield0000"}
			local n
			local t=TppStory.GetCurrentStorySequence()
			if t>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON then
				n=true
			else
				n=false
			end
			e.EnableCollectionTable(i,n)
		end
		do
			local t={"col_develop_Shield0001"}
			local n
			local i=TppStory.GetCurrentStorySequence()
			if i>=TppDefine.STORY_SEQUENCE.CLEARD_FLAG_MISSIONS_AFTER_TO_MATHER_BASE then
				n=true
			else
				n=false
			end
			e.EnableCollectionTable(t,n)
		end
		do
			local t={"col_develop_Shield0002"}
			local n
			local i=TppStory.GetCurrentStorySequence()
			if i>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON then
				n=true
			else
				n=false
			end
			e.EnableCollectionTable(t,n)
		end
	else
		e.RepopMissionTaskCollection()
		if vars.missionCode==10200 then
			local n=e.MissionCollectionTable[10200]
			local e=0
			for i,n in pairs(n)do
				if TppCollection.RepopCountOperation("GetAt",n)>0 then
					e=e+1
				end
			end
			local e=e-svars.CollectiveCount
			for i,n in pairs(n)do
				if e>0 then
					if TppCollection.RepopCountOperation("GetAt",n)>0 then
						TppCollection.RepopCountOperation("SetAt",n,0)e=e-1
					end
				end
			end
		end
	end
	local n={"col_develop_BullpupAR","col_develop_LongtubeShotgun","col_develop_RevolverGrenade0001","col_develop_RevolverGrenade0002","col_develop_RevolverGrenade0003","col_develop_RevolverGrenade0004","col_develop_EuropeSMG0001","col_develop_EuropeSMG0002","col_develop_EuropeSMG0003","col_develop_EuropeSMG0004","col_develop_Stungrenade"}
	e.EnableCollectionTable(n,true)
	e.InitQuest()
end
function e.RepopMissionTaskCollection()
	local n=vars.missionCode
	if TppMission.IsHardMission(n)then
		n=TppMission.GetNormalMissionCodeFromHardMission(n)
	end
	local i=e.MissionCollectionMissionTaskTable[n]
	if not i then
		return
	end
	local e=e.MissionCollectionTable[n]
	for t,n in pairs(e)do
		if TppCollection.IsExistLocator(n)and(TppCollection.RepopCountOperation("GetAt",n)>0)then
			local e=false
			local i=i[t]
			if i=="first"then
				if not svars.isCompleteFirstBonus then
					e=true
				end
			else
				if(svars.mis_objectiveEnable[i]==false)then
					e=true
				end
			end
			if e then
				TppCollection.RepopCountOperation("SetAt",n,0)
			end
		end
	end
end
function e.OnReload()
	e.messageExecTable=Tpp.MakeMessageExecTable(e.Messages())
end
function e.OnMessage(a,n,i,t,o,r,l)
	Tpp.DoMessage(e.messageExecTable,TppMission.CheckMessageOption,a,n,i,t,o,r,l)
end
function e.OnMissionGameStart()
	if not TppMission.IsFreeMission(vars.missionCode)then
		if mvars.gim_shownEspionageBox then
			Gimmick.EspionageBoxFadeout()
		end
	end
end
function e.DecrementCollectionRepopCount()
	for n,e in pairs(e.COLLECTION_REPOP_COUNT_DECREMENT_TABLE)do
		TppCollection.RepopCountOperation("DecByType",n,e)
	end
end
function e.MafrRiverPrimSetting()
	if not TppEffectUtility.UpdatePrimRiver then
		return
	end
	if vars.missionCode==10080 or vars.missionCode==11080 then
		e.SetMafrRiverPrimVisibility(false)
	else
		e.SetMafrRiverPrimVisibility(true)
	end
end
function e.SetMafrRiverPrimVisibility(o)
	local e={"cleanRiver","dirtyRiver","oilMud_open","dirtyFlow"}
	local i={true,false,false,false}
	for n,t in ipairs(e)do
		local e
		if o then
			e=i[n]
		else
			e=not i[n]
		end
		TppEffectUtility.SetPrimRiverVisibility(t,e)
	end
	TppEffectUtility.UpdatePrimRiver()
end
function e.SetUpIdentifierTable(e)
	mvars.gim_identifierParamTable={}
	Tpp.MergeTable(mvars.gim_identifierParamTable,e)
	mvars.gim_identifierParamStrCode32Table={}
	mvars.gim_gimmackNameStrCode32Table={}
	for n,t in pairs(e)do
		local e=i(n)
		mvars.gim_identifierParamStrCode32Table[e]=t
		mvars.gim_gimmackNameStrCode32Table[e]=n
	end
	mvars.gim_identifierTable={}
	for o,e in pairs(e)do
		local n=e.type
		local t=e.locatorName
		local a=e.dataSetName
		mvars.gim_identifierTable[n]=mvars.gim_identifierTable[n]or{}
		local e=mvars.gim_identifierTable[n]e[i(t)]=e[i(t)]or{}
		local e=e[i(t)]e[Fox.PathFileNameCode32(a)]=o
	end
end
function e.SetUpBreakConnectTable(e)
	mvars.gim_breakConnectTable={}
	for n,e in pairs(e)do
		mvars.gim_breakConnectTable[n]=e
		mvars.gim_breakConnectTable[e]=n
	end
end
function e.SetUpCheckBrokenAndBreakConnectTable(n)
	mvars.gim_checkBrokenAndBreakConnectTable={}
	for n,i in pairs(n)do
		e._SetUpCheckBrokenAndBreakConnectTable(n,i)
	end
end
function e._SetUpCheckBrokenAndBreakConnectTable(e,i)
	if not mvars.gim_identifierParamTable[e]then
		return
	end
	local t=i.breakGimmickId
	local n=i.checkBrokenGimmickId
	if not t then
		return
	end
	if not n then
		return
	end
	if not mvars.gim_identifierParamTable[t]then
		return
	end
	if not mvars.gim_identifierParamTable[n]then
		return
	end
	mvars.gim_checkBrokenAndBreakConnectTable[e]=i
	mvars.gim_checkBrokenAndBreakConnectTable[n]={checkBrokenGimmickId=e,breakGimmickId=t}
end
function e.SetUpUseGimmickRouteTable(e)
	mvars.gim_routeGimmickConnectTable={}
	for e,n in pairs(e)do
		mvars.gim_routeGimmickConnectTable[i(e)]=n.gimmickId
	end
	Tpp.DEBUG_DumpTable(mvars.gim_routeGimmickConnectTable)
end
function e.GetRouteConnectedGimmickId(e)
	if not mvars.gim_routeGimmickConnectTable then
		return
	end
	return mvars.gim_routeGimmickConnectTable[e]
end
function e.SetUpConnectLandingZoneTable(assaultLZsMergerTable)
	mvars.gim_connectLandingZoneTable={}
	for radarId,assaultLZDetails in pairs(assaultLZsMergerTable)do
		mvars.gim_connectLandingZoneTable[radarId]=assaultLZDetails.aprLandingZoneName
	end
end
function e.SetUpConnectPowerCutTable(e)
	mvars.gim_connectPowerCutAreaTable={}
	mvars.gim_connectPowerCutCpTable={}
	for n,e in pairs(e)do
		local t=e.powerCutAreaName
		local e=e.cpName
		mvars.gim_connectPowerCutAreaTable[n]=t
		if e then
			local i=l(e)
			if i~=o then
				mvars.gim_connectPowerCutCpTable[n]=i
				local i={type="TppCommandPost2"}
				local n=mvars.gim_identifierParamTable[n]
				local e={id="SetPowerSourceGimmick",cpName=e,gimmicks=n,areaName=t}
				GameObject.SendCommand(i,e)
			end
		end
	end
end
function e.SetUpConnectVisibilityTable(e)
	mvars.gim_connectVisibilityTable={}
	for e,n in pairs(e)do
		mvars.gim_connectVisibilityTable[e]=n
	end
end
function e.SetCommunicateGimmick(e)
	if not a(e)then
		return
	end
	mvars.gim_gimmickIdToCpTable=mvars.gim_gimmickIdToCpTable or{}
	local r={type="TppCommandPost2"}
	for n,e in pairs(e)do
		local a={}
		for e,t in ipairs(e)do
			local e=mvars.gim_identifierParamTable[t]
			if e then
				table.insert(a,e)
			end
			local e=l(n)
			if e~=o then
				mvars.gim_gimmickIdToCpTable[i(t)]=e
			end
		end
		local i=e.isCommunicateBase
		local e=e.groupName
		local e={id="SetCommunicateGimmick",cpName=n,isCommunicateBase=i,gimmicks=a,groupName=e}
		GameObject.SendCommand(r,e)
	end
end
function e.BreakGimmick(a,n,t,i)
	local gimmickId=e.GetGimmickID(a,n,t)
	if not gimmickId then
		return
	end
	e.BreakConnectedGimmick(gimmickId)
	e.CheckBrokenAndBreakConnectedGimmick(gimmickId)
	e.HideAsset(gimmickId)
	e.ShowAnnounceLog(gimmickId)
	e.UnlockLandingZone(gimmickId)
	local t=false
	if(i==o)then
		t=true
	end
	e.PowerCut(gimmickId,true,t)
	e.SetHeroicAndOrgPoint(gimmickId,i)
end
function e.GetGimmickID(e,n,i)
	local t=m(e)
	local e=mvars.gim_identifierTable
	if not e then
		return
	end
	local e=e[t]
	if not e then
		return
	end
	local e=e[n]
	if not e then
		return
	end
	local n=e[i]
	if not e then
		return
	end
	return n
end
function e.GetGameObjectId(e)
	local e=mvars.gim_identifierParamTable[e]
	if not e then
		return
	end
	return Gimmick.GetGameObjectId(e.type,e.locatorName,e.dataSetName)
end
function e.BreakConnectedGimmick(e)
	local e=mvars.gim_breakConnectTable[e]
	if not e then
		return
	end
	local e=mvars.gim_identifierParamTable[e]
	Gimmick.BreakGimmick(e.type,e.locatorName,e.dataSetName,false)
end
function e.CheckBrokenAndBreakConnectedGimmick(n)
	if not mvars.gim_checkBrokenAndBreakConnectTable then
		return
	end
	local n=mvars.gim_checkBrokenAndBreakConnectTable[n]
	if not n then
		return
	end
	local i=n.checkBrokenGimmickId
	local n=n.breakGimmickId
	if e.IsBroken{gimmickId=i}then
		local e=mvars.gim_identifierParamTable[n]
		if e then
			Gimmick.BreakGimmick(e.type,e.locatorName,e.dataSetName,false)
		end
	end
end
function e.HideAsset(e)
	local e=mvars.gim_connectVisibilityTable[e]
	if not e then
		return
	end
	for i,n in pairs(e.invisibilityList)do
		TppDataUtility.SetVisibleDataFromIdentifier(e.identifierName,n,false,true)
	end
end
function e.Show(n)
	local e=e.SetVisibility(n,false)
end
function e.Hide(n)
	e.SetVisibility(n,true)
end
function e.SetVisibility(e,n)
	local e=mvars.gim_identifierParamTable[e]
	if not e then
		return
	end
	Gimmick.InvisibleGimmick(e.type,e.locatorName,e.dataSetName,n)
	return true
end
function e.UnlockLandingZone(radarId)
	if TppLandingZone.IsDisableUnlockLandingZoneOnMission()then
		return
	end
	local assaultLZName=mvars.gim_connectLandingZoneTable[radarId]
	if not assaultLZName then
		return
	end
	local newlyUnlockedLZ
	for i,lzName in pairs(assaultLZName)do
		if TppHelicopter.GetLandingZoneExists{landingZoneName=lzName}then
			TppHelicopter.SetEnableLandingZone{landingZoneName=lzName}
			newlyUnlockedLZ=true
		end
	end
	if newlyUnlockedLZ then
		TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.UNLOCK_LANDING_ZONE)
	end
end
function e.ShowAnnounceLog(n)
	local i=mvars.gim_identifierParamTable[n].gimmickType
	if not i then
		return
	end
	local i=gimmickDestroyRadarTable[i]
	if i then
		TppUI.ShowAnnounceLog(i)
	end
	e._ShowCommCutOffAnnounceLog(n)
end
function e._ShowCommCutOffAnnounceLog(e)
	if not mvars.gim_gimmickIdToCpTable then
		return
	end
	local e=mvars.gim_gimmickIdToCpTable[i(e)]
	if not e then
		return
	end
	GameObject.SendCommand(e,{id="SetCommunicateAnnounce"})
end
function e.SwitchGimmick(n,i,t,o)
	local n=e.GetGimmickID(n,i,t)
	if not n then
		return
	end
	local i=false
	if(o==0)then
		i=true
	end
	e.PowerCut(n,i,false)
end
function e.PowerCut(e,n,i)
	local e=mvars.gim_connectPowerCutAreaTable[e]
	if e then
		if n then
			Gimmick.PowerCutOn(e,i)
		else
			Gimmick.PowerCutOff(e)
		end
	end
end
function e.SetHeroicAndOrgPoint(n,e)
	if e==o then
		return
	end
	local e=mvars.gim_identifierParamTable[n].gimmickType
	if not e then
		return
	end
	TppHero.AnnounceBreakGimmickByGimmickType(e)
end
function e.EnableCollectionTable(t,e,o)
	local n=0
	if not e then
		n=1
	end
	local function i(e)
		local n=TppCollection.GetTypeIdByLocatorName(e)
		if n~=TppCollection.TYPE_DEVELOPMENT_FILE then
			return false
		end
		local e=TppCollection.GetUniqueIdByLocatorName(e)
		local e=TppTerminal.GetBluePrintKeyItemId(e)
		if e then
			if TppMotherBaseManagement.IsGotDataBase{dataBaseId=e}then
				return true
			end
		end
		return false
	end
	for t,e in pairs(t)do
		if TppCollection.IsExistLocator(e)then
			if not i(e)or o then
				TppCollection.RepopCountOperation("SetAt",e,n)
			end
		end
	end
end
function e.DEBUG_DumpIdentiferParam(n,e)
	if e then
	end
end
function e.InitQuest()
	mvars.gim_questTargetList={}
	mvars.gim_isQuestSetup=false
	mvars.gim_isquestMarkStart=false
	mvars.gim_questMarkStartName=nil
	mvars.gim_questMarkStartLocator=nil
	mvars.gim_questMarkStartData=nil
	mvars.gim_questMarkSetIndex=0
	mvars.gim_questMarkCount=0
	mvars.gim_questMarkTotalCount=0
end
function e.OnAllocateQuest(e)
	if e==nil then
		return
	end
	if mvars.gim_isQuestSetup==false then
	end
end
function e.OnActivateQuest(n)
	if n==nil then
		return
	end
	if mvars.gim_isQuestSetup==false then
		e.InitQuest()
	end
	local t=false
	if mvars.gim_isQuestSetup==false then
		if(n.targetGimmicklList and Tpp.IsTypeTable(n.targetGimmicklList))and next(n.targetGimmicklList)then
			for n,e in pairs(n.targetGimmicklList)do
				local n={gimmickId=e,messageId="None",idType="Gimmick"}table.insert(mvars.gim_questTargetList,n)
				TppMarker.SetQuestMarkerGimmick(e)
			end
			t=true
		end
		if(n.targetDevelopList and Tpp.IsTypeTable(n.targetDevelopList))and next(n.targetDevelopList)then
			for n,e in pairs(n.targetDevelopList)do
				local e={developId=e,messageId="None",idType="Develop"}table.insert(mvars.gim_questTargetList,e)
			end
			t=true
		end
		if(n.gimmickMarkList and Tpp.IsTypeTable(n.gimmickMarkList))and next(n.gimmickMarkList)then
			for n,e in pairs(n.gimmickMarkList)do
				if e.isStartGimmick==true then
					mvars.gim_questMarkStartName=i(e.locatorName)
					mvars.gim_questMarkStartLocator=e.locatorName
					mvars.gim_questMarkStartData=e.dataSetName
					Gimmick.InvisibleGimmick(TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE,mvars.gim_questMarkStartLocator,mvars.gim_questMarkStartData,true)
				else
					local e={locatorName=e.locatorName,dataSetName=e.dataSetName,messageId="None",setIndex=e.setIndex}table.insert(mvars.gim_questTargetList,e)t=true
					mvars.gim_questMarkTotalCount=mvars.gim_questMarkTotalCount+1
				end
			end
			t=true
			e.SetQuestInvisibleGimmick(0,true,true)
		end
		if n.gimmickTimerList then
			mvars.gim_questDisplayTimeSec=n.gimmickTimerList.displayTimeSec
			mvars.gim_questCautionTimeSec=n.gimmickTimerList.cautionTimeSec
			t=true
		end
		if n.gimmickOffsetType then
			local n,e=mtbs_cluster.GetDemoCenter(n.gimmickOffsetType,"plnt0")Gimmick.SetOffsetPosition(n,e)
			if mvars.gim_questMarkStartName then
				Gimmick.InvisibleGimmick(TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE,mvars.gim_questMarkStartLocator,mvars.gim_questMarkStartData,false)
			end
			t=true
		end
		if(n.containerList and Tpp.IsTypeTable(n.containerList))and next(n.containerList)then
			for n,e in pairs(n.containerList)do
				local n=e.locatorName
				local e=e.dataSetName
				Gimmick.SetFultonableContainerForMission(n,e,0,false)
			end
			t=true
		end
	end
	if t==true then
		mvars.gim_isQuestSetup=true
	end
end
function e.OnDeactivateQuest(n)
	if mvars.gim_isQuestSetup==true then
		local n=e.CheckQuestAllTarget(n.questType,nil,true)
		TppQuest.ClearWithSave(n)
		e.SetQuestInvisibleGimmick(0,true,true)
	end
end
function e.OnTerminateQuest(n)
	if mvars.gim_isQuestSetup==true then
		e.InitQuest()
	end
end
function e.CheckQuestAllTarget(n,a,l)
	local t=TppDefine.QUEST_CLEAR_TYPE.NONE
	local r=l or false
	local l=false
	local s=TppQuest.GetCurrentQuestName()
	if TppQuest.IsEnd(s)then
		return t
	end
	if r==false then
		if n==TppDefine.QUEST_TYPE.DEVELOP_RECOVERED then
			for n,e in pairs(mvars.gim_questTargetList)do
				if e.idType=="Develop"then
					if a==TppCollection.GetUniqueIdByLocatorName(e.developId)then
						e.messageId="Recovered"end
				end
			end
		elseif n==TppDefine.QUEST_TYPE.SHOOTING_PRACTIVE then
			for n,e in pairs(mvars.gim_questTargetList)do
				local n=i(e.locatorName)
				if a==n then
					e.messageId="Break"l=true
					mvars.gim_questMarkCount=mvars.gim_questMarkCount+1
					break
				end
			end
		elseif n==TppDefine.QUEST_TYPE.GIMMICK_RECOVERED then
			if Tpp.IsFultonContainer(a)then
				for i,n in pairs(mvars.gim_questTargetList)do
					if n.idType=="Gimmick"then
						local i,e=e.GetGameObjectId(n.gimmickId)
						if e==o then
						else
							if a==e then
								n.messageId="Recovered"end
						end
					end
				end
			end
		end
	end
	if n==TppDefine.QUEST_TYPE.DEVELOP_RECOVERED or n==TppDefine.QUEST_TYPE.GIMMICK_RECOVERED then
		local n=0
		local e=0
		for t,i in pairs(mvars.gim_questTargetList)do
			if i.messageId=="Recovered"then
				n=n+1
			end
			e=e+1
		end
		if e>0 then
			if n>=e then
				t=TppDefine.QUEST_CLEAR_TYPE.CLEAR
			end
		end
	elseif n==TppDefine.QUEST_TYPE.SHOOTING_PRACTIVE then
		if l==true then
			local n={}
			local n=true
			for i,e in pairs(mvars.gim_questTargetList)do
				if e.setIndex==mvars.gim_questMarkSetIndex then
					if e.messageId=="None"then
						n=false
					end
				end
			end
			if n==true then
				if mvars.gim_questMarkCount<mvars.gim_questMarkTotalCount then
					mvars.gim_questMarkSetIndex=mvars.gim_questMarkSetIndex+1
					e.SetQuestInvisibleGimmick(mvars.gim_questMarkSetIndex,false,false)
				end
			end
			if mvars.gim_questMarkCount>=mvars.gim_questMarkTotalCount then
				t=TppDefine.QUEST_CLEAR_TYPE.SHOOTING_CLEAR
			else
				t=TppDefine.QUEST_CLEAR_TYPE.UPDATE
			end
		else
			if r==true then
				if mvars.gim_isquestMarkStart==true then
					t=TppDefine.QUEST_CLEAR_TYPE.SHOOTING_RETRY
				end
			end
		end
	end
	return t
end
function e.IsQuestTarget(i)
	if mvars.gim_isQuestSetup==false then
		return false
	end
	if not next(mvars.gim_questTargetList)then
		return false
	end
	for t,n in pairs(mvars.gim_questTargetList)do
		if n.idType=="Gimmick"then
			local n,e=e.GetGameObjectId(n.gimmickId)
			if e==i then
				return true
			end
		end
	end
	return false
end
function e.SetQuestInvisibleGimmick(t,i,e)
	local n=e or false
	for o,e in pairs(mvars.gim_questTargetList)do
		if t==mvars.gim_questMarkSetIndex or n==true then
			Gimmick.InvisibleGimmick(TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE,e.locatorName,e.dataSetName,i)
		end
	end
end
function e.SetQuestSootingTargetInvincible(n)
	for i,e in pairs(mvars.gim_questTargetList)do
		Gimmick.InvincibleGimmickData(TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE,"mtbs_bord001_vrtn003_ev_gim_i0000|TppPermanentGimmick_mtbs_bord001_vrtn003_ev",e.dataSetName,n)break
	end
end
function e.IsQuestStartSwitchGimmick(e)
	if e==mvars.gim_questMarkStartName then
		return true
	end
	return false
end
function e.StartQuestShootingPractice()
	e.SetQuestInvisibleGimmick(mvars.gim_questMarkSetIndex,false,false)
	mvars.gim_isquestMarkStart=true
end
function e.SetQuestShootingPracticeTargetInvisible()
	e.SetQuestInvisibleGimmick(mvars.gim_questMarkSetIndex,true,true)
end
function e.EndQuestShootingPractice(e)
	if e==TppDefine.QUEST_CLEAR_TYPE.SHOOTING_RETRY then
		mvars.gim_isquestMarkStart=false
		for n,e in pairs(mvars.gim_questTargetList)do
			e.messageId="None"end
		mvars.gim_questMarkCount=0
	end
end
function e.IsStartQuestShootingPractice()
	return mvars.gim_isquestMarkStart
end
function e.GetQuestShootingPracticeCount()
	return mvars.gim_questMarkCount,mvars.gim_questMarkTotalCount
end
function e.SetUpMineQuest(e)
	if mvars.gim_isQuestSetup==false then
		mvars.gim_questmineCount=0
		mvars.gim_questmineTotalCount=e
		mvars.gim_isQuestSetup=true
	end
end
function e.OnTerminateMineQuest()
	if mvars.gim_isQuestSetup==true then
		mvars.gim_questmineCount=0
		mvars.gim_questmineTotalCount=0
		mvars.gim_isQuestSetup=false
	end
end
function e.CheckQuestPlaced(i,n)
	if e.CheckQuestMine(i,n)then
		mvars.gim_questmineCount=mvars.gim_questmineCount+1
		TppUI.ShowAnnounceLog("mine_quest_log",mvars.gim_questmineCount,mvars.gim_questmineTotalCount)
	end
	if mvars.gim_questmineCount>=mvars.gim_questmineTotalCount then
		return true
	else
		return false
	end
end
function e.CheckQuestMine(n,e)
	for t,i in pairs(TppDefine.QUEST_MINE_TYPE_LIST)do
		if n==i then
			if TppPlaced.IsQuestBlock(e)then
				return true
			else
				return false
			end
		end
	end
	return false
end
return e
