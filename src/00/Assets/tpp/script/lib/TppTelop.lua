--TUPPM Header

--not present in p1080

local this={}
local IsTypeTable=Tpp.IsTypeTable
local IsTypeString=Tpp.IsTypeString
local t=3
local n=6
local s=1
local s={
	CAST_MODE={
		LEFT_START={"LeftCenter","RightCenter","LeftUp","RightUp"},
		RIGHT_START={"RightCenter","LeftCenter","RightUp","LeftUp"}
	},
	STAFF_MODE={
		LEFT_START={"LeftCenter","LeftUp","RightCenter","RightUp"},
		RIGHT_START={"RightCenter","RightUp","LeftCenter","LeftUp"}
	}
}
function this.GetRandomStartSide()
	if mvars.tlp_startSide then
		return mvars.tlp_startSide
	end
	if(os.time()%2)==0 then
		return"LEFT_START"else --rp this decides credits overlay position
		return"RIGHT_START"end
end
function this.GetTelopPosition(e,a,t)
	local e=s[e][a]
	local t=t%4+1
	return e[t]
end
function this.GetFirstLangId(t,e)
	if t==1 then
		return e
	else
		return""end
end
function this.GetLangIdTable(e)
	if IsTypeTable(e)then
		return e
	elseif IsTypeString(e)then
		return{e}
	else
		return{}
	end
end
function this.StartCastTelop(telopStartSide)
	if TppSequence.GetContinueCount()>0 then
		return
	end
	if telopStartSide then
		mvars.tlp_startSide=telopStartSide
	end
	
--	TUPPMLog.Log("TppTelop.StartCastTelop - telopStartSide:"..tostring(telopStartSide),3,true)
--	TUPPMLog.Log("TppTelop.StartCastTelop TUPPMSettings.game_ENABLE_hideCredits:"..tostring(TUPPMSettings.game_ENABLE_hideCredits),3,true)
	
	--r51 Settings
	if not TUPPMSettings.game_ENABLE_hideCredits then
		--K Skip in game(non cutscene) credits
		this.PostMainCharacters(mvars.tlp_mainCharacters)
		this.PostEnemyCombatants(mvars.tlp_enemyCombatants)
		this.PostGuestCharacters(mvars.tlp_guestCharacters)
		this.PostSpecialMechanics(mvars.tlp_specialMechanics)
		this.PostLevelDesign(mvars.tlp_levelDesigners)
		this.PostWrittenBy(mvars.tlp_writers)
		this.PostCreativeProducers()
		this.PostDirectedBy()
	end
	
	this.PostMissionObjective(vars.locationCode,vars.missionCode)
	TppUiCommand.StartTelopCast()
end
function this.StartMissionObjective()
	if TppSequence.GetContinueCount()>0 then
		return
	end
	this.PostMissionObjective(vars.locationCode,vars.missionCode)
	TppUiCommand.StartTelopCast()
end
function this.PostMainCharacters(a)
--	TUPPMLog.Log("TppTelop.PostMainCharacters - data:"..tostring(InfInspect.Inspect(a)),3,true)
	if not next(a)then
		return
	end
	local s=this.GetRandomStartSide()
	for a,n in ipairs(a)do
		local i=this.GetFirstLangId(a,"post_starring")
		local a=this.GetTelopPosition("CAST_MODE",s,a-1)
		local e=this.GetLangIdTable(n)
		TppUiCommand.RegistTelopCast(a,t,i,e[1],e[2],e[3],e[4])
		TppUiCommand.RegistTelopCast("PageBreak",1)
	end
end
function this.PostGuestCharacters(a)
--	TUPPMLog.Log("TppTelop.PostGuestCharacters - data:"..tostring(InfInspect.Inspect(a)),3,true)
	if not next(a)then
		return
	end
	local s=this.GetRandomStartSide()
	for a,i in ipairs(a)do
		local n=this.GetFirstLangId(a,"post_guest_characters")
		local a=this.GetTelopPosition("CAST_MODE",s,a-1)
		local e=this.GetLangIdTable(i)
		TppUiCommand.RegistTelopCast(a,t,n,e[1],e[2],e[3],e[4])
		TppUiCommand.RegistTelopCast("PageBreak",1)
	end
end
function this.PostEnemyCombatants(a)
--	TUPPMLog.Log("TppTelop.PostEnemyCombatants - data:"..tostring(InfInspect.Inspect(a)),3,true)
	if not next(a)then
		return
	end
	local s=this.GetRandomStartSide()
	for a,i in ipairs(a)do
		local n=this.GetFirstLangId(a,"post_Enemy_Combatants")
		local a=this.GetTelopPosition("CAST_MODE",s,a-1)
		local e=this.GetLangIdTable(i)
		TppUiCommand.RegistTelopCast(a,t,n,e[1],e[2],e[3],e[4])
		TppUiCommand.RegistTelopCast("PageBreak",1)
	end
end
function this.PostSpecialMechanics(a)
--	TUPPMLog.Log("TppTelop.PostSpecialMechanics - data:"..tostring(InfInspect.Inspect(a)),3,true)
	if not next(a)then
		return
	end
	local s=this.GetRandomStartSide()
	for a,n in ipairs(a)do
		local i=this.GetFirstLangId(a,"post_special_mechanic")
		local a=this.GetTelopPosition("CAST_MODE",s,a-1)
		local e=this.GetLangIdTable(n)
		TppUiCommand.RegistTelopCast(a,t,i,e[1],e[2],e[3],e[4])
		TppUiCommand.RegistTelopCast("PageBreak",1)
	end
end
function this.PostLevelDesign(a)
--	TUPPMLog.Log("TppTelop.PostLevelDesign - data:"..tostring(InfInspect.Inspect(a)),3,true)
	if not next(a)then
		return
	end
	local n=this.GetRandomStartSide()
	local e=this.GetTelopPosition("STAFF_MODE",n,1)
	TppUiCommand.RegistTelopCast(e,t,"post_level_design",a[1],a[2])
	TppUiCommand.RegistTelopCast("PageBreak",1)
end
function this.PostWrittenBy(e)
--	TUPPMLog.Log("TppTelop.PostWrittenBy - data:"..tostring(InfInspect.Inspect(e)),3,true)
	if not next(e)then
		return
	end
	TppUiCommand.RegistTelopCast("LeftUp",t,"post_wrriten_by",e[1],e[2])
	TppUiCommand.RegistTelopCast("PageBreak",1)
end
function this.PostCreativeProducers()
--	TUPPMLog.Log("TppTelop.PostCreativeProducers",3,true)
	TppUiCommand.RegistTelopCast("RightUp",t,"post_Creative_Producers","staff_yoshikazu_matsuhana","staff_yuji_korekado")
	TppUiCommand.RegistTelopCast("PageBreak",1)
end
function this.PostDirectedBy()
--	TUPPMLog.Log("TppTelop.PostCreativeProducers",3,true)
	TppUiCommand.RegistTelopCast("RightCenter",t,"post_Created_and_Directed_by","staff_hideo_kojima")
	TppUiCommand.RegistTelopCast("PageBreak",1)
end
function this.PostMissionObjective(a,e)
	if(e>=11e3)and(e<12e3)then
		e=e-1e3
	end
	local t=string.format("obj_mission_%2d_%5d_00",a,e)
	local e=string.format("obj_mission_en_%2d_%5d_00",a,e)
	if AssetConfiguration.GetDefaultCategory"Language"=="jpn"then
		TppUiCommand.RegistTelopCast("CenterLarge",n,t,e)
	else
		TppUiCommand.RegistTelopCast("CenterLarge",n,t)
	end
	TppUiCommand.RegistTelopCast("PageBreak",1)
end
function this.Init(missionTable)
--	TUPPMLog.Log("TppTelop.Init - missionTable:"..tostring(InfInspect.Inspect(missionTable)),3,true)

	TppUiCommand.AllResetTelopCast()
	mvars.tlp_mainCharacters={"cast_venom_snake","cast_sharashka_ocelot","cast_kazuhira_miller"}
	mvars.tlp_guestCharacters={}
	mvars.tlp_enemyCombatants={}
	mvars.tlp_specialMechanics={}
	mvars.tlp_levelDesigners={"staff_tsuyoshi_osada","staff_satoshi_matsuno"}
	mvars.tlp_writers={"staff_shuyo_murata"}
	if not missionTable.telop then
		return
	end
	local missionTelop=missionTable.telop
	mvars.tlp_mainCharacters=missionTelop.mainCharacterLangList
	if missionTelop.cfaLangList then
		mvars.tlp_cfa=missionTelop.cfaLangList
	end
	if missionTelop.guestCharacterLangList then
		mvars.tlp_guestCharacters=missionTelop.guestCharacterLangList
	end
	if missionTelop.enemyCombatantsLangList then
		mvars.tlp_enemyCombatants=missionTelop.enemyCombatantsLangList
	end
	if missionTelop.specialMechanicLangList then
		mvars.tlp_specialMechanics=missionTelop.specialMechanicLangList
	end
	mvars.tlp_levelDesigners=missionTelop.missionLevelDesigner
	mvars.tlp_writers=missionTelop.missionWriter
end
return this
