local this={}
local missionTypePrefixTable={"s","e","f","h","o"}
local missionTypesTable={"story","extra","free","heli","online"}
function this.MakeDefaultMissionPackList(n)
this.AddDefaultMissionAreaPack(n)
this.AddLocationCommonScriptPack(n)
end
function this.AddMissionPack(missionAreaPackPath)
	if Tpp.IsTypeString(missionAreaPackPath)then
		table.insert(this.missionPackList,missionAreaPackPath)
	end
end
function this.DeleteMissionPack(i)
if Tpp.IsTypeString(i)then
local n
for e,s in ipairs(this.missionPackList)do
if s==i then
n=e
break
end
end
if n then
table.remove(this.missionPackList,n)
end
end
end
function this.AddDefaultMissionAreaPack(missionCode)
	local defaultMissionAreaPackPath=this.MakeDefaultMissionAreaPackPath(missionCode)
	if defaultMissionAreaPackPath then
		this.AddMissionPack(defaultMissionAreaPackPath)
	end
end
function this.MakeDefaultMissionAreaPackPath(missionCode)
	local localMissionCode=missionCode
	if TppMission.IsHardMission(localMissionCode)then
		localMissionCode=TppMission.GetNormalMissionCodeFromHardMission(localMissionCode)
	end
	local missionType,missionName=this.GetMissionTypeAndMissionName(localMissionCode)
	if missionType and missionName then
		local defaultMissionAreaPackPath="/Assets/tpp/pack/mission2/"..(missionType..("/"..(missionName..("/"..(missionName.."_area.fpk")))))
		return defaultMissionAreaPackPath
	end
end
function this.AddLocationCommonScriptPack(missionCode)
	local locationName=TppLocation.GetLocationName()
	if locationName=="afgh"then
		this.AddMissionPack(TppDefine.MISSION_COMMON_PACK.AFGH_SCRIPT)
	elseif locationName=="mafr"then
		this.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MAFR_SCRIPT)
	elseif locationName=="cypr"then
		this.AddMissionPack(TppDefine.MISSION_COMMON_PACK.CYPR_SCRIPT)
	elseif locationName=="mtbs"then
		this.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MTBS_SCRIPT)
	elseif locationName=="mbqf"then
		this.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MTBS_SCRIPT)
	end
	local n=TppDefine.MISSION_ENUM[tostring(missionCode)]
	if n then
		this.AddMissionPack"/Assets/tpp/pack/mission2/common/online_challenge.fpk"
	end
end
function this.AddLocationCommonMissionAreaPack(n)
local n=TppLocation.GetLocationName()
if n=="afgh"then
this.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)
this.AddMissionPack(TppDefine.MISSION_COMMON_PACK.AFGH_MISSION_AREA)
this.AddMissionPack(TppDefine.MISSION_COMMON_PACK.AFGH_DECOY)
elseif n=="mafr"then
this.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)
this.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MAFR_MISSION_AREA)
this.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MAFR_DECOY)
end
end
function this.IsMissionPackLabelList(n)
if not Tpp.IsTypeTable(n)then
return
end
for i,n in ipairs(n)do
if this.IsMissionPackLabel(n)then
return true
end
end
return false
end
function this.IsMissionPackLabel(e)
if not Tpp.IsTypeString(e)then
return
end
if gvars.pck_missionPackLabelName==Fox.StrCode32(e)then
return true
else
return false
end
end
function this.AddColoringPack(n)
if TppColoringSystem then
local n=TppColoringSystem.GetAdditionalColoringPackFilePaths{missionCode=n}
for i,n in ipairs(n)do
this.AddMissionPack(n)
end
else
this.AddMissionPack"/Assets/tpp/pack/fova/mecha/all/mfv_scol_c11.fpk"this.AddMissionPack"/Assets/tpp/pack/fova/mecha/all/mfv_scol_c07.fpk"end
end
function this.AddFOBLayoutPack(n)
local s,i=this.GetMissionTypeAndMissionName(n)
if n==50050 then
end
if(n==50050)or(n==10115)then
local i="/Assets/tpp/pack/mission2/"..(s..("/"..(i..("/"..(i..string.format("_area_ly%03d",vars.mbLayoutCode))))))
local a=i..".fpk"local s=vars.mbClusterId
if(n==10115)then
s=TppDefine.CLUSTER_DEFINE.Develop
end
local n=i..(string.format("_cl%02d",s)..".fpk")
this.AddMissionPack(a)
this.AddMissionPack(n)
elseif n==30050 then
local n="/Assets/tpp/pack/mission2/"..(s..("/"..(i..("/"..(i..string.format("_ly%03d",vars.mbLayoutCode))))))
local n=n..".fpk"this.AddMissionPack(n)
end
end
function this.AddAvatarEditPack()
local n=TppDefine.MISSION_COMMON_PACK.AVATAR_ASSET_LIST
for i,n in ipairs(n)do
this.AddMissionPack(n)
end
this.AddMissionPack(TppDefine.MISSION_COMMON_PACK.AVATAR_EDIT)
end
function this.SetUseDdEmblemFova(e)
if((e==10030)or(e==10050))or(e==10240)then
TppSoldierFace.SetUseBlackDdFova{enabled=false}
return
end
if gvars.s10240_isPlayedFuneralDemo then
TppSoldierFace.SetUseBlackDdFova{enabled=true}
else
TppSoldierFace.SetUseBlackDdFova{enabled=false}
end
end
function this.SetMissionPackLabelName(mis_missionPackLabelName)
	if Tpp.IsTypeString(mis_missionPackLabelName)then
		gvars.pck_missionPackLabelName=Fox.StrCode32(mis_missionPackLabelName)
	end
end
function this.SetDefaultMissionPackLabelName()
this.SetMissionPackLabelName"default"end
function this.MakeMissionPackList(n,i)
this.missionPackList={}
if Tpp.IsTypeFunc(i)then
i(n)
end
local i=true
if n==10010 and this.IsMissionPackLabel"afterMissionClearMovie"then
i=false
end
if i then
this.AddColoringPack(n)
end
return this.missionPackList
end
function this.GetMissionTypeAndMissionName(missionCode)
	local missionTypeIndex=math.floor(missionCode/1e4)
	local missionType=missionTypesTable[missionTypeIndex]
	local missionName
	if missionTypePrefixTable[missionTypeIndex]then
		missionName=missionTypePrefixTable[missionTypeIndex]..missionCode
	end
	return missionType,missionName
end
function this.GetLocationNameFormMissionCode(missionCode)
	local e
	for locationName,missionsInLocTable in pairs(TppDefine.LOCATION_HAVE_MISSION_LIST)do
		for index,missionCodeInTable in pairs(missionsInLocTable)do
			if missionCodeInTable==missionCode then
				e=locationName
				break
			end
		end
		if e then
			break
		end
	end
	return e
end
return this
