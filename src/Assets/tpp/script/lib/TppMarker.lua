local this={
	}
local StrCode32=Fox.StrCode32
local GetGameObjectId=GameObject.GetGameObjectId
local NULL_ID=GameObject.NULL_ID
local IsTypeTable=Tpp.IsTypeTable
local IsTypeString=Tpp.IsTypeString
local IsTypeNumber=Tpp.IsTypeNumber
local SendCommand=GameObject.SendCommand
this.GoalTypes={
	none="GOAL_NONE",
	moving="GOAL_MOVE",
	attack="GOAL_ATTACK",
	defend="GOAL_DEFENSE",
	moving_fix="GOAL_MOVE_FIX"
}
this.ViewTypes={
	map={"VIEW_MAP_GOAL"},
	all={"VIEW_MAP_GOAL","VIEW_WORLD_GOAL"},
	map_only_icon={"VIEW_MAP_ICON"},
	map_and_world_only_icon={"VIEW_MAP_ICON","VIEW_WORLD_ICON"}
}
function this.Messages()
	return Tpp.StrCode32Table{Player={
		{msg="LookingTarget",func=function(r,a)
			this._OnSearchTarget(a,r,"LookingTarget")
		end}
	},GameObject={
		{msg="Carried",func=function(a,r)
			if r==0 then
				this._OnSearchTarget(a,nil,"Carried")
			end
		end},
		{msg="Restraint",func=function(a,r)
			if r==0 then
				this._OnSearchTarget(a,nil,"Restraint")
			end
		end}
	},Marker={
		{msg="ChangeToEnable",func=this._OnMarkerChangeToEnable}
	},nil}
end
function this.Enable(gameObjectIdOrString,radiusLevel,goalTypeInput,viewLayerInput,randomLevel,isImportant,isNew,registerMapRadioInput,iconLangId,goalLangId,isInterrogation)

	--rX66 Never used for any marking by Player/Buddies
	TUPPMLog.Log(
	"gameObjectIdOrString:"..tostring(gameObjectIdOrString)..
	" radiusLevel:"..tostring(radiusLevel)..
	" goalTypeInput:"..tostring(goalTypeInput)..
	" viewLayerInput:"..tostring(viewLayerInput)..
	" randomLevel:"..tostring(randomLevel)..
	" isImportant:"..tostring(isImportant)..
	" isNew:"..tostring(isNew)..
	" registerMapRadioInput:"..tostring(registerMapRadioInput)..
	" iconLangId:"..tostring(iconLangId)..
	" goalLangId:"..tostring(goalLangId)..
	" isInterrogation:"..tostring(isInterrogation)
	,3,true)

	local gameObjectId
	if Tpp.IsTypeString(gameObjectIdOrString)then
		gameObjectId=GetGameObjectId(gameObjectIdOrString)
	elseif Tpp.IsTypeNumber(gameObjectIdOrString)then
		gameObjectId=gameObjectIdOrString
	else
		return
	end
	if gameObjectId==NULL_ID then
		return
	end
	if(not this._CanSetMarker(gameObjectId))then
		return
	end
	radiusLevel=radiusLevel or 0
	goalTypeInput=goalTypeInput or "moving"
	viewLayerInput=viewLayerInput or "map"
	randomLevel=randomLevel or 9
	if(type(radiusLevel)~="number")then
		return
	end
	if(radiusLevel<0 or radiusLevel>9)then
		return
	end
	if(type(randomLevel)~="number")then
		return
	end
	if(randomLevel<0 or randomLevel>9)then
		return
	end
	local goalType=this.GoalTypes[goalTypeInput]
	if(goalType==nil)then
		return
	end
	local viewLayer=this.ViewTypes[viewLayerInput]
	if(viewLayer==nil)then
		return
	end
	TppMarker2System.EnableMarker{gameObjectId=gameObjectId,viewLayer=viewLayer}
	local e={gameObjectId=gameObjectId,radiusLevel=radiusLevel,goalType=goalType,randomLevel=randomLevel}
	TppMarker2System.SetMarkerGoalType(e)
	if isImportant~=nil then
		local e={gameObjectId=gameObjectId,isImportant=isImportant}
		TppMarker2System.SetMarkerImportant(e)
	end
	if isNew~=nil then
		local e={gameObjectId=gameObjectId,isNew=isNew}
		TppMarker2System.SetMarkerNew(e)
	end
	if isInterrogation~=nil then
		local e={gameObjectId=gameObjectId,isInterrogation=isInterrogation}
		if TppMarker2System.SetMarkerInterrogation then
			TppMarker2System.SetMarkerInterrogation(e)
		end
	end
	if registerMapRadioInput~=nil then
		local e=StrCode32(registerMapRadioInput)
		TppUiCommand.RegisterMapRadio(gameObjectId,e)
	end
	if iconLangId~=nil then
		if goalLangId~=nil then
			TppUiCommand.RegisterIconUniqueInformation{markerId=gameObjectId,iconLangId=iconLangId,goalLangId=goalLangId}
		else
			TppUiCommand.RegisterIconUniqueInformation{markerId=gameObjectId,langId=iconLangId}
		end
	elseif goalLangId~=nil then
		TppUiCommand.RegisterIconUniqueInformation{markerId=gameObjectId,goalLangId=goalLangId}
	end
end
function this.Disable(gameObjectIdOrString,unregisterMapRadioInput,unknownDisableArg1)
	local gameObjectId
	if IsTypeString(gameObjectIdOrString)then
		gameObjectId=GetGameObjectId(gameObjectIdOrString)
	elseif IsTypeNumber(gameObjectIdOrString)then
		gameObjectId=gameObjectIdOrString
	end
	if gameObjectId==NULL_ID then
		return
	end
	if(not this._CanSetMarker(gameObjectId))then
		return
	end
	if Tpp.IsMarkerLocator(gameObjectId) or unknownDisableArg1 then
		TppMarker2System.DisableMarker{gameObjectId=gameObjectId}
	else
		TppMarker2System.SetMarkerImportant{gameObjectId=gameObjectId,isImportant=false}
	end
	TppUiCommand.UnRegisterIconUniqueInformation(gameObjectId)
	if unregisterMapRadioInput~=nil then
		TppUiCommand.UnregisterMapRadio(gameObjectId)
	end
end
function this.DisableAll()
	TppMarker2System.DisableAllMarker()
end
function this.SetUpSearchTarget(e)
	if IsTypeTable(e)then
		for a,e in pairs(e)do
			mvars.mar_searchTargetPrePareList[e.gameObjectName]={gameObjectName=e.gameObjectName,gameObjectType=e.gameObjectType,messageName=e.messageName,skeletonName=e.skeletonName,offSet=e.offSet,targetFox2Name=e.targetFox2Name,doDirectionCheck=e.doDirectionCheck,objectives=e.objectives,func=e.func,notImportant=e.notImportant,wideCheckRange=e.wideCheckRange}
		end
	end
end
function this.CompleteSearchTarget(a)
	local a=GetGameObjectId(a)
	if a~=NULL_ID then
		this._OnSearchTarget(a,nil,"script")
	end
end
function this.EnableSearchTarget(a)
	if not this._IsCheckSVarsSearchTargetName(a)then
		return
	end
	for e=0,TppDefine.SEARCH_TARGET_COUNT-1 do
		if svars.mar_searchTargetName[e]==StrCode32(a)then
			svars.mar_searchTargeEnable[e]=true
			return
		end
	end
end
function this.DisableSearchTarget(a)
	if not this._IsCheckSVarsSearchTargetName(a)then
		return
	end
	for e=0,TppDefine.SEARCH_TARGET_COUNT-1 do
		if svars.mar_searchTargetName[e]==StrCode32(a)then
			svars.mar_searchTargeEnable[e]=false
			return
		end
	end
end
function this.GetSearchTargetIsFound(a)
	if not this._IsCheckSVarsSearchTargetName(a)then
		return
	end
	for e=0,TppDefine.SEARCH_TARGET_COUNT-1 do
		if svars.mar_searchTargetName[e]==StrCode32(a)then
			return svars.mar_searchTargeIsFound[e]
		end
	end
	return false
end
function this.SetQuestMarker(e)
	local a
	if Tpp.IsTypeString(e)then
		a=GetGameObjectId(e)
	elseif Tpp.IsTypeNumber(e)then
		a=e
	end
	if a==NULL_ID then
	else
		local e={gameObjectId=a,isImportant=true,isQuestImportant=true}
		TppMarker2System.SetMarkerImportant(e)
	end
end
function this.SetQuestMarkerGimmick(e)
	local a,e=TppGimmick.GetGameObjectId"q40010_cntn001"
	if e==NULL_ID then
	else
		local e={gameObjectId=e,isImportant=true,isQuestImportant=true}
		TppMarker2System.SetMarkerImportant(e)
	end
end
function this.EnableQuestTargetMarker(n)
	local a
	if Tpp.IsTypeString(n)then
		a=GetGameObjectId(n)
	elseif Tpp.IsTypeNumber(n)then
		a=n
	end
	if a==NULL_ID then
	else
		this.Enable(a,0,"defend","map_and_world_only_icon",0,false,true)
		this.SetQuestMarker(a)
		TppUI.ShowAnnounceLog("updateMap",nil,nil,1)
	end
end
function this.DeclareSVars()
	return{
		{name="mar_searchTargetName",arraySize=TppDefine.SEARCH_TARGET_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="mar_searchTargeEnable",arraySize=TppDefine.SEARCH_TARGET_COUNT,type=TppScriptVars.TYPE_BOOL,value=false,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="mar_searchTargeIsFound",arraySize=TppDefine.SEARCH_TARGET_COUNT,type=TppScriptVars.TYPE_BOOL,value=false,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},
		{name="mar_locatorMarker",arraySize=100,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},nil}
end
function this.OnAllocate()
	mvars.mar_searchTargetList={
		}
	mvars.mar_searchTargetPrePareList={
		}
end
function this.Init(a)
	this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
end
function this.OnMissionCanStart()
	for s,a in pairs(mvars.mar_searchTargetPrePareList)do
		local t=GetGameObjectId(s)
		if t==NULL_ID then
		else
			mvars.mar_searchTargetList[t]=a
			if not this._IsCheckSVarsSearchTargetName(s)then
				for e=0,TppDefine.SEARCH_TARGET_COUNT-1 do
					if svars.mar_searchTargetName[e]==0 then
						svars.mar_searchTargetName[e]=StrCode32(s)break
					end
				end
			end
			if not this._IsCheckSVarsSearchTarget(t,"mar_searchTargeIsFound")then
				TppPlayer.SetSearchTarget(s,a.gameObjectType,a.messageName,a.skeletonName,a.offSet,a.targetFox2Name,a.doDirectionCheck,a.wideCheckRange)
				this.EnableSearchTarget(s)
			end
		end
	end
	mvars.mar_searchTargetPrePareList=nil
end
function this.OnReload()
	this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
end
function this.OnMessage(i,n,s,r,t,o,a)
	Tpp.DoMessage(this.messageExecTable,TppMission.CheckMessageOption,i,n,s,r,t,o,a)
end
function this.RestoreMarkerLocator()
	if this.IsExistMarkerLocatorSystem()then
		local e={type="TppMarker2LocatorSystem"}SendCommand(e,{id="RestoreFromSVars"})
	end
end
function this.StoreMarkerLocator()
	if this.IsExistMarkerLocatorSystem()then
		local e={type="TppMarker2LocatorSystem"}SendCommand(e,{id="StoreToSVars"})
	end
end
function this.IsExistMarkerLocatorSystem()
	if GameObject.GetGameObjectIdByIndex("TppMarker2LocatorSystem",0)~=NULL_ID then
		return true
	else
		return false
	end
end
function this._OnSearchTarget(a,t,s)
	if not mvars.mar_searchTargetList[a]then
		return
	end
	if this._IsCheckSVarsSearchTarget(a,"mar_searchTargeIsFound")then
		return
	end
	if not this._IsCheckSVarsSearchTarget(a,"mar_searchTargeEnable")then
		return
	end
	for n=0,TppDefine.SEARCH_TARGET_COUNT-1 do
		local r=this._GetStrCode32SearchTargetName(a)
		if svars.mar_searchTargetName[n]==r then
			if mvars.mar_searchTargetList[a].objectives==nil then
				local r
				if mvars.mar_searchTargetList[a].notImportant then
					r=false
				else
					r=true
				end
				this.Enable(mvars.mar_searchTargetList[a].gameObjectName,0,"moving","map_and_world_only_icon",0,r,true)
			else
				local e={
					}
				if IsTypeTable(mvars.mar_searchTargetList[a].objectives)then
					e=mvars.mar_searchTargetList[a].objectives
				else
					table.insert(e,mvars.mar_searchTargetList[a].objectives)
				end
				TppMission.UpdateObjective{objectives=e}
			end
			if mvars.mar_searchTargetList[a].func then
				mvars.mar_searchTargetList[a].func(t,a,s)
			end
			TppSoundDaemon.PostEvent"sfx_s_enemytag_main_tgt"this._CallSearchTargetEnabledRadio(a)svars.mar_searchTargeIsFound[n]=true
			return
		end
	end
end
function this._GetStrCode32SearchTargetName(a)
	for r,e in pairs(mvars.mar_searchTargetList)do
		local e=e.gameObjectName
		if a==GetGameObjectId(e)then
			return StrCode32(e)
		end
	end
	return nil
end
function this._IsCheckSVarsSearchTargetName(e)
	local a=StrCode32(e)
	for e=0,TppDefine.SEARCH_TARGET_COUNT-1 do
		if svars.mar_searchTargetName[e]==a then
			return true
		end
	end
	return false
end
function this._IsCheckSVarsSearchTarget(a,r)
	local n=this._GetStrCode32SearchTargetName(a)
	if n==nil then
		return false
	end
	for a=0,TppDefine.SEARCH_TARGET_COUNT-1 do
		local e=false
		if r==nil then
			e=true
		else
			e=svars[r][a]
		end
		if svars.mar_searchTargetName[a]==n and e then
			return true
		end
	end
	return false
end
function this._OnMarkerChangeToEnable(n,n,r,a)
	if a==Fox.StrCode32"Player"then
		this._CallMarkerRadio(r)
	end
end
function this._CallMarkerRadio(a)
	if not this._IsRadioTarget(a)then
		return
	end
	if mvars.mar_searchTargetList[a]and this._IsCheckSVarsSearchTarget(a,"mar_searchTargeEnable")then
		if not this._IsCheckSVarsSearchTarget(a,"mar_searchTargeIsFound")then
			TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.TARGET_MARKED)
		end
	else
		TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.SEARCH_TARGET_ENABLED)
	end
end
function this._CallSearchTargetEnabledRadio(a)
	if not this._IsRadioTarget(a)then
		return
	end
	TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.SEARCH_TARGET_ENABLED)
end
function this._IsRadioTarget(e)
	local a=TppEnemy.IsEliminateTarget(e)
	local e=TppEnemy.IsRescueTarget(e)
	if not a and not e then
		return false
	end
	return true
end
function this._CanSetMarker(e)
	if Tpp.IsVehicle(e)then
		return TppEnemy.IsVehicleAlive(e)
	else
		return true
	end
end
return this
