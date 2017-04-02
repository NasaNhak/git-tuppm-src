local this={}
local locationPackTable={}
locationPackTable[TppDefine.LOCATION_ID.INIT]={"/Assets/tpptest/pack/location/empty/empty.fpk"}
locationPackTable[TppDefine.LOCATION_ID.AFGH]={"/Assets/tpp/pack/location/afgh/afgh.fpk"}
locationPackTable[TppDefine.LOCATION_ID.MAFR]={"/Assets/tpp/pack/location/mafr/mafr.fpk"}
locationPackTable[TppDefine.LOCATION_ID.CYPR]={"/Assets/tpp/pack/location/cypr/cypr.fpk"}
locationPackTable[TppDefine.LOCATION_ID.GNTN]={"/Assets/tpp/pack/location/gntn/gntn.fpk"}
locationPackTable[TppDefine.LOCATION_ID.OMBS]={"/Assets/tpp/pack/location/ombs/ombs.fpk"}
locationPackTable[TppDefine.LOCATION_ID.MTBS]={"/Assets/tpp/pack/location/mtbs/mtbs.fpk"}
locationPackTable[TppDefine.LOCATION_ID.HLSP]={"/Assets/tpp/pack/location/hlsp/hlsp.fpk"}
locationPackTable[TppDefine.LOCATION_ID.MBQF]={"/Assets/tpp/pack/location/mbqf/mbqf.fpk"}
locationPackTable[TppDefine.LOCATION_ID.FLYK]={"/Assets/tpp/pack/location/flyk/flyk.fpk"}
locationPackTable[TppDefine.LOCATION_ID.SAND_AFGH]={"/Assets/tpp_sandbox/pack/game_core/stage/gc_afgh.fpk"}
locationPackTable[TppDefine.LOCATION_ID.SAND_MAFR]={"/Assets/tpp/pack/location/mafr/mafr.fpk"}
locationPackTable[TppDefine.LOCATION_ID.SAND_MTBS]={"/Assets/tpp_sandbox/pack/game_core/stage/gc_mtbs.fpk"}

local missionPackTable={}
missionPackTable[1]={
	"/Assets/tpp/pack/ui/gz/gz_pause_key_setting_data.fpk",
	"/Assets/tpp/pack/mission2/init/init.fpk"
}
missionPackTable[5]=function(p)
	TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/title_sequence.fpk"
	TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/init/title.fpk"end
missionPackTable[10010]=function(p)
	if TppPackList.IsMissionPackLabel"afterMissionClearMovie"then
		TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.AFGH_SCRIPT)
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/title_sequence.fpk"
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10010/s10010_l02.fpk"
	else
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/title_sequence.fpk"
		TppPackList.AddLocationCommonScriptPack(p)
		TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10010/s10010_l01.fpk"
		TppHostage2.SetHostageType{gameObjectType="TppHostageUnique",hostageType="Ishmael"}
		if TppHostage2.SetHostageType then
			TppHostage2.SetHostageType{gameObjectType="TppHostage2",hostageType="MobCyprus"}
			TppHostage2.SetHostageType{gameObjectType="TppHostageUnique2",hostageType="MobCyprus"}
		end
		if TppHostage2.SetUniquePartsPath then
			local s={awake_doctor="/Assets/tpp/parts/chara/dct/dct1_main0_def_v00.parts",dct_p21_010410_0000="/Assets/tpp/parts/chara/dct/dct0_main0_def_v00.parts",dct_p21_010410_0001="/Assets/tpp/parts/chara/dct/dct0_main0_def_v00.parts",awake_nurse="/Assets/tpp/parts/chara/nrs/nrs2_main0_def_v00.parts",nrs_p21_010360_0000="/Assets/tpp/parts/chara/nrs/nrs0_main0_def_v00.parts",nrs_p21_010410_0000="/Assets/tpp/parts/chara/nrs/nrs0_main0_def_v00.parts",nrs_p21_010410_0001="/Assets/tpp/parts/chara/nrs/nrs0_main0_def_v00.parts",nrs_p21_010410_0002="/Assets/tpp/parts/chara/nrs/nrs0_main0_def_v00.parts"}for s,p in pairs(s)do
				TppHostage2.SetUniquePartsPath{gameObjectType="TppHostageUnique2",locatorName=s,parts=p}end
			local s={ish_p21_010410_0000="/Assets/tpp/parts/chara/ish/ish0_main0_def_v00.parts"}for p,s in pairs(s)do
				TppHostage2.SetUniquePartsPath{gameObjectType="TppHostage2",locatorName=p,parts=s}end
		end
		local s={{636,0,0,1}}local p={{300,1},{301,1},{302,1},{303,1},{304,1},{305,1},{306,1},{307,1},{308,1},{309,1},{310,1},{311,1},{312,1},{313,1},{314,1},{315,1},{316,1},{317,1},{318,1},{319,1},{320,1},{321,1},{322,1},{323,1},{324,1},{325,1},{326,1},{327,1},{328,1},{329,1},{330,1},{331,1},{332,1},{333,1},{334,1},{337,1},{338,1},{339,1},{340,1},{341,1},{342,1},{343,1},{344,1},{345,1},{346,1},{347,1},{348,1},{349,1},{380,1},{381,1}}TppEneFova.AddUniquePackage{type="hostage",face=s,body=p}end
end
missionPackTable[10020]=function(p)TppPackList.AddLocationCommonScriptPack(p)if TppPackList.IsMissionPackLabel"afterMissionClearMovie"then
	TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10020/s10020_area02.fpk"else
	TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_TRUCK)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_TRUCK_MATERIAL)TppPackList.AddDefaultMissionAreaPack(p)local s={{TppEnemyBodyId.oce0_main0_v00,1},{TppEnemyBodyId.oce0_main0_v01,1}}TppEneFova.AddUniquePackage{type="hostage",body=s}do
		local s="sol_enemyBase_0014"local s={{type="enemy",name=s,faceId=635,bodyId=273}}TppEneFova.AddUniqueSettingPackage(s)end
end
end
missionPackTable[10030]=function(missionCode)
	TppPackList.AddLocationCommonScriptPack(missionCode)
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.DD_SOLDIER_WAIT)
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.OCELOT)
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MILLER)
	TppPackList.AddDefaultMissionAreaPack(missionCode)
	local p={{TppEnemyBodyId.oce0_main0_v00,1}}
	TppEneFova.AddUniquePackage{type="hostage",body=p}
end
missionPackTable[10033]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.AFGH_HOSTAGE)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_LV)TppPackList.AddDefaultMissionAreaPack(p)do
	local s="hos_s10033_0000"local s={{type="hostage",name=s,faceId=602,bodyId=110}}TppEneFova.AddUniqueSettingPackage(s)end
end
missionPackTable[10036]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_LV)TppPackList.AddDefaultMissionAreaPack(p)do
	local s="sol_vip_0000"local s={{type="enemy",name=s,faceId=600,bodyId=TppEnemyBodyId.svs0_unq_v010}}TppEneFova.AddUniqueSettingPackage(s)end
end
missionPackTable[10040]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.ENEMY_HELI)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_LV)TppPackList.AddDefaultMissionAreaPack(p)do
	local a="sol_s10040_0000"local p="sol_s10040_0001"local s="sol_s10040_0002"local s={{type="enemy",name=a,faceId=603,bodyId=TppEnemyBodyId.svs0_unq_v040},{type="enemy",name=p,faceId=604,bodyId=TppEnemyBodyId.svs0_unq_v050},{type="enemy",name=s,faceId=605,bodyId=TppEnemyBodyId.svs0_unq_v060}}TppEneFova.AddUniqueSettingPackage(s)end
end
missionPackTable[10041]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.AFGH_HOSTAGE)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_LV)TppPackList.AddDefaultMissionAreaPack(p)do
	local a="sol_vip_field"local s="sol_vip_village"local p="sol_vip_enemyBase"local s={{type="enemy",name=a,faceId=637,bodyId=268},{type="enemy",name=s,faceId=638,bodyId=269},{type="enemy",name=p,faceId=639,bodyId=270}}TppEneFova.AddUniqueSettingPackage(s)end
end
missionPackTable[10043]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.AFGH_HOSTAGE)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_TRUCK)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_TRUCK_MATERIAL)TppPackList.AddDefaultMissionAreaPack(p)end
missionPackTable[10044]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.AFGH_HOSTAGE)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_TRUCK)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_WAV)TppPackList.AddDefaultMissionAreaPack(p)do
	local s={{606,1,1,0}}local p={{258,1},{TppEnemyBodyId.svs0_unq_v080,1}}if TppSoldierFace.OverwriteMissionFovaData~=nil then
		TppSoldierFace.OverwriteMissionFovaData{face=s,body=p}end
end
end
missionPackTable[10052]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.AFGH_HOSTAGE)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_LV)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_WAV)TppPackList.AddDefaultMissionAreaPack(p)do
	local s="hos_target_0000"local p="sol_s10052_transportVehicle_0000"local s={{type="hostage",name=s,faceId=607,bodyId=200},{type="enemy",name=p,faceId=608,bodyId=263}}TppEneFova.AddUniqueSettingPackage(s)end
end
missionPackTable[10054]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.AFGH_HOSTAGE)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.ENEMY_HELI)TppPackList.AddMissionPack(TppHelicopter.GetEnemyColoringPack(TppDefine.ENEMY_HELI_COLORING_TYPE.BLACK))TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_LV)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_TRUCK)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_TRUCK_AMMUNITION)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_TRUCK_MATERIAL)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_TANK)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_WAV)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_WAV_ROCKET)TppPackList.AddDefaultMissionAreaPack(p)do
	local p="hos_s10054_0002"local s="hos_s10054_0004"local s={{type="hostage",name=p,faceId="female",bodyId=113},{type="hostage",name=s,faceId="female",bodyId=113}}TppEneFova.AddUniqueSettingPackage(s)end
end
missionPackTable[10070]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)if TppPackList.IsMissionPackLabel"beforeMotherBaseDemo"then
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.OCELOT)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MILLER)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HUEY)TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10070/s10070_area04.fpk"elseif TppPackList.IsMissionPackLabel"beforeSahelanAttackDemo"then
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HUEY)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.SAHELAN)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WALKERGEAR)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MANTIS)TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10070/s10070_area03.fpk"elseif TppPackList.IsMissionPackLabel"afterSahelanTestDemo"then
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.AFGH_MISSION_AREA)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WALKERGEAR)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.AFGH_DECOY)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.ENEMY_HELI)TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10070/s10070_area02.fpk"else
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HUEY)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.SKULLFACE)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_LV)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_TRUCK)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WALKERGEAR)TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10070/s10070_area01.fpk"end
end
missionPackTable[10080]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)if TppPackList.IsMissionPackLabel"afterPumpStopDemo"then
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WALKERGEAR)TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10080/s10080_area02.fpk"else
	TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10080/s10080_area01.fpk"end
end
missionPackTable[10086]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MAFR_HOSTAGE)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MAFR_HOSTAGE_WOMAN)TppPackList.AddDefaultMissionAreaPack(p)do
	local p="hos_mis_0000"local s="hos_mis_0001"local e="hos_mis_0002"local t="hos_mis_0003"local i="sol_interpreter"local a="sol_interrogator"local s={{type="hostage",name=p,faceId=610,bodyId=111},{type="hostage",name=s,faceId=611,bodyId=111},{type="hostage",name=e,faceId=612,bodyId=111},{type="hostage",name=t,faceId="female",bodyId=113},{type="enemy",name=i,faceId=609,bodyId=255},{type="enemy",name=a,faceId=629,bodyId=TppEnemyBodyId.pfs0_unq_v155}}TppEneFova.AddUniqueSettingPackage(s)end
end
missionPackTable[10082]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MAFR_HOSTAGE)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WALKERGEAR)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_TRUCK)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_TRUCK_ITEMBOX)TppPackList.AddDefaultMissionAreaPack(p)end
missionPackTable[10090]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_TRUCK)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_TRUCK_HOOD)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_WAV)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_WAV_CANNON)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_WAV_MACHINE_GUN)TppPackList.AddDefaultMissionAreaPack(p)end
missionPackTable[10121]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.ENEMY_HELI)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_TRUCK)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_LV)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WALKERGEAR)TppPackList.AddMissionPack(TppHelicopter.GetEnemyColoringPack(TppDefine.ENEMY_HELI_COLORING_TYPE.BLACK))TppPackList.AddDefaultMissionAreaPack(p)do
	local s="sol_pfCamp_vip_0001"local p="sol_pfCamp_vip_guard"local s={{type="enemy",name=s,faceId=617,bodyId=TppEnemyBodyId.pfa0_v00_b},{type="enemy",name=p,faceId=618,bodyId=254}}TppEneFova.AddUniqueSettingPackage(s)end
end
missionPackTable[10091]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.RAVEN)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.JACKAL)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_TRUCK)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_TRUCK_CONTAINER)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_LV)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MAFR_HOSTAGE)TppPackList.AddDefaultMissionAreaPack(p)do
	local s={{type="hostage",name="hos_s10091_0001",faceId="dd",bodyId=176},{type="hostage",name="hos_s10091_0000",faceId="dd",bodyId=143}}TppEneFova.AddUniqueSettingPackage(s)end
end
missionPackTable[10100]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_WAV)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_WAV_CANNON)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.ENEMY_HELI)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MAFR_DECOY)TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/mis_com_mafr.fpk"TppPackList.AddDefaultMissionAreaPack(p)do
	local o="sol_target_0000"local s=EnemyFova.INVALID_FOVA_VALUE
	local t="hos_diamond_0000"local i="hos_diamond_0001"local e="hos_diamond_0002"local p="hos_diamond_0003"local a="hos_diamond_0004"local s={{type="enemy",name=o,faceId=616,bodyId=251},{type="hostage",name=t,faceId=s,bodyId=130},{type="hostage",name=i,faceId=s,bodyId=131},{type="hostage",name=e,faceId=s,bodyId=132},{type="hostage",name=p,faceId=s,bodyId=133},{type="hostage",name=a,faceId=s,bodyId=134}}TppEneFova.AddUniqueSettingPackage(s)end
TppHostage2.SetHostageType{gameObjectType="TppHostageUnique",hostageType="MovingChild"}end
missionPackTable[10110]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_LV)if TppPackList.IsMissionPackLabel"AfterVolginDemo"then
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MANTIS)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.VOLGIN)TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10110/s10110_area02.fpk"else
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MAFR_MISSION_AREA)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.RAVEN)TppPackList.AddDefaultMissionAreaPack(p)end
TppHostage2.SetHostageType{gameObjectType="TppHostageUnique",hostageType="Naedoko"}TppHostage2.SetUniquePartsPath{gameObjectType="TppHostageUnique",locatorName="TppHostage2GameObjectLocator",parts="/Assets/tpp/parts/chara/plh/plh3_main0_def_v00.parts"}TppHostage2.SetUniquePartsPath{gameObjectType="TppHostageUnique",locatorName="TppHostage2GameObjectLocator0000",parts="/Assets/tpp/parts/chara/plh/plh2_main0_def_v00.parts"}local p={"TppHostage2GameObjectLocator0001","TppHostage2GameObjectLocator0002","TppHostage2GameObjectLocator0003","TppHostage2GameObjectLocator0004","TppHostage2GameObjectLocator0005","TppHostage2GameObjectLocator0006","TppHostage2GameObjectLocator0007","TppHostage2GameObjectLocator0008","TppHostage2GameObjectLocator0009","TppHostage2GameObjectLocator0010"}for p,s in ipairs(p)do
	TppHostage2.SetUniquePartsPath{gameObjectType="TppHostageUnique",locatorName=s,parts="/Assets/tpp/parts/chara/plh/plh0_main0_def_v00.parts"}end
end
missionPackTable[10195]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MAFR_HOSTAGE)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.ENEMY_HELI)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_LV)TppPackList.AddDefaultMissionAreaPack(p)do
	local s="sol_dealer"local p="sol_vip"local s={{type="enemy",name=s,faceId=614,bodyId=250},{type="enemy",name=p,faceId=615,bodyId=256}}TppEneFova.AddUniqueSettingPackage(s)end
end
missionPackTable[10115]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)TppPackList.AddDefaultMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MTBS_DECOY)TppPackList.AddFOBLayoutPack(p)do
	local t="hos_s10115_0000"local e="hos_s10115_0001"local i="hos_s10115_0002"local p="hos_s10115_0003"local a="hos_s10115_0004"local s="hos_s10115_0005"local s={{type="hostage",name=t,faceId="dd",bodyId=143},{type="hostage",name=e,faceId="dd",bodyId=143},{type="hostage",name=i,faceId="dd",bodyId=143},{type="hostage",name=p,faceId="dd",bodyId=143},{type="hostage",name=a,faceId="dd",bodyId=143},{type="hostage",name=s,faceId="dd",bodyId=143}}TppEneFova.AddUniqueSettingPackage(s)end
end
missionPackTable[10120]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.CHILD_SOLDIER)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.LIQUID)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MAFR_HOSTAGE_WOMAN)TppPackList.AddDefaultMissionAreaPack(p)do
	local s="hos_mis_woman"local s={{type="hostage",name=s,faceId="female",bodyId=113}}TppEneFova.AddUniqueSettingPackage(s)end
end
missionPackTable[10085]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MAFR_HOSTAGE)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MAFR_HOSTAGE_WOMAN)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_LV)TppPackList.AddDefaultMissionAreaPack(p)do
	local p="hos_target_0000"local s="hos_target_0001"local p={{type="hostage",name=p,faceId=642,bodyId=111}}local s={{type="hostage",name=s,faceId=643,bodyId=113}}TppEneFova.AddUniqueSettingPackage(p)TppEneFova.AddUniqueSettingPackage(s)end
end
missionPackTable[10211]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MAFR_HOSTAGE)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_LV)TppPackList.AddDefaultMissionAreaPack(p)do
	local s="sol_mis_0000"local s={{type="enemy",name=s,faceId=620,bodyId=253}}TppEneFova.AddUniqueSettingPackage(s)end
end
missionPackTable[10200]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.CHILD_SOLDIER)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MAFR_HOSTAGE)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_LV)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)TppPackList.AddDefaultMissionAreaPack(p)do
	local s="hos_hillNorth_0000"local p="sol_hillNorth_0004"local s={{type="hostage",name=s,faceId=619,bodyId=201}}TppEneFova.AddUniqueSettingPackage(s)end
end
missionPackTable[10081]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MAFR_HOSTAGE)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_LV)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_TRUCK)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_TRUCK_ITEMBOX)TppPackList.AddDefaultMissionAreaPack(p)do
	local s="hos_spy"local s={{type="hostage",name=s,faceId="dd",bodyId=201}}TppEneFova.AddUniqueSettingPackage(s)end
end
missionPackTable[10130]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.CODETALKER)TppPackList.AddMissionPack(TppHelicopter.GetEnemyColoringPack(TppDefine.ENEMY_HELI_COLORING_TYPE.BLACK))TppPackList.AddMissionPack(TppHelicopter.GetEnemyColoringPack(TppDefine.ENEMY_HELI_COLORING_TYPE.RED))if TppPackList.IsMissionPackLabel"CamoParasiteAllKill"then
	TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/mis_com_mafr.fpk"TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_WAV)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_WAV_CANNON)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.ENEMY_HELI)TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10130/s10130_area02.fpk"elseif TppPackList.IsMissionPackLabel"CodeTalkerClearDemo"then
	TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10130/s10130_area03.fpk"else
	TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/mis_com_mafr.fpk"TppPackList.AddDefaultMissionAreaPack(p)end
end
missionPackTable[10140]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)if TppPackList.IsMissionPackLabel"MBdemo"then
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MILLER)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HUEY)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.OCELOT)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.DD_SOLDIER_WAIT)TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10140/s10140_area01.fpk"TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/free/f30050/f30050_Buddy.fpk"elseif TppPackList.IsMissionPackLabel"AfterClear"then
	TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/mis_com_mafr.fpk"TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.OCELOT)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.CODETALKER)TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10140/s10140_area00.fpk"else
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.CODETALKER)TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/mis_com_mafr.fpk"TppPackList.AddDefaultMissionAreaPack(p)end
end
missionPackTable[10150]=function(p)
	TppPackList.AddLocationCommonScriptPack(p)
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.XOF_SOLDIER)
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)
	TppPackList.AddMissionPack(TppHelicopter.GetEnemyColoringPack(TppDefine.ENEMY_HELI_COLORING_TYPE.BLACK))
	if TppPackList.IsMissionPackLabel"SkullFaceAppearance"then
		TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.ENEMY_HELI)
		TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.SKULLFACE)
		TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_LV)
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10150/s10150_area02.fpk"
	elseif TppPackList.IsMissionPackLabel"StartingSahelan"then
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10150/s10150_area03.fpk"
	else
		TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MANTIS)
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10150/s10150_area01.fpk"end
end
missionPackTable[10151]=function(p)
	TppPackList.AddLocationCommonScriptPack(p)
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)
	if TppPackList.IsMissionPackLabel"OkbEnding"then
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10151/s10151_area02.fpk"
	else
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10151/s10151_area01.fpk"
	end
	local p={{375,1},{376,1}}TppEneFova.AddUniquePackage{type="hostage",body=p}end
missionPackTable[10045]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.AFGH_HOSTAGE)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WALKERGEAR)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_LV)TppPackList.AddDefaultMissionAreaPack(p)do
	local s="hos_vip_0000"local p="sol_executioner_0000"local s={{type="hostage",name=s,faceId=644,bodyId=271}}TppEneFova.AddUniqueSettingPackage(s)end
end
missionPackTable[10156]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.RAVEN)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.AFGH_HOSTAGE)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_LV)TppPackList.AddDefaultMissionAreaPack(p)end
missionPackTable[10093]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_LV)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.ENEMY_HELI)TppPackList.AddDefaultMissionAreaPack(p)do
	local s="sol_vip_0000"local s={{type="enemy",name=s,faceId=649,bodyId=272}}TppEneFova.AddUniqueSettingPackage(s)end
end
missionPackTable[10171]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.ENEMY_HELI)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_WAV)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_WAV_MACHINE_GUN)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_WAV_CANNON)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.WEST_TANK)TppPackList.AddDefaultMissionAreaPack(p)TppPackList.AddMissionPack(TppHelicopter.GetEnemyColoringPack(TppDefine.ENEMY_HELI_COLORING_TYPE.BLACK))do
	local s="sol_pfCamp_vip"local s={{type="enemy",name=s,faceId=645,bodyId=267}}TppEneFova.AddUniqueSettingPackage(s)end
end
missionPackTable[10230]=function(p)TppPackList.AddDefaultMissionAreaPack(p)end
missionPackTable[10240]=function(p)TppPackList.AddLocationCommonScriptPack(p)if TppPackList.IsMissionPackLabel"InQuarantineFacility"then
	TppSoldier2.DisableMarkerModelEffect()TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10240/s10240_area02.fpk"else
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.DD_SOLDIER_WAIT)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10240/s10240_area.fpk"end
end
missionPackTable[10050]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.QUIET)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.RAVEN)if TppPackList.IsMissionPackLabel"MotherBaseDemo"then
	TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/story/s10050/s10050_area01.fpk"else
	TppPackList.AddDefaultMissionAreaPack(p)end
end
missionPackTable[10260]=function(p)TppPackList.AddLocationCommonScriptPack(p)TppPackList.AddLocationCommonMissionAreaPack(p)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.ENEMY_HELI)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_TANK)TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.EAST_WAV)TppPackList.AddMissionPack(TppHelicopter.GetEnemyColoringPack(TppDefine.ENEMY_HELI_COLORING_TYPE.BLACK))TppPackList.AddDefaultMissionAreaPack(p)end
missionPackTable[10280]=missionPackTable[10010]missionPackTable[11043]=missionPackTable[10043]missionPackTable[11041]=missionPackTable[10041]missionPackTable[11054]=missionPackTable[10054]missionPackTable[11085]=missionPackTable[10085]missionPackTable[11082]=missionPackTable[10082]missionPackTable[11090]=missionPackTable[10090]missionPackTable[11036]=missionPackTable[10036]missionPackTable[11033]=missionPackTable[10033]missionPackTable[11050]=missionPackTable[10050]missionPackTable[11091]=missionPackTable[10091]missionPackTable[11195]=missionPackTable[10195]missionPackTable[11211]=missionPackTable[10211]missionPackTable[11140]=missionPackTable[10140]missionPackTable[11200]=missionPackTable[10200]missionPackTable[11080]=missionPackTable[10080]missionPackTable[11171]=missionPackTable[10171]missionPackTable[11121]=missionPackTable[10121]missionPackTable[11115]=missionPackTable[10115]missionPackTable[11130]=missionPackTable[10130]missionPackTable[11044]=missionPackTable[10044]missionPackTable[11052]=missionPackTable[10052]missionPackTable[11151]=missionPackTable[10151]

missionPackTable[30010]=function(p)
	TppPackList.AddLocationCommonScriptPack(p)
	TppPackList.AddLocationCommonMissionAreaPack(p)
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.ORDER_BOX)
	if TppPackList.IsMissionPackLabel"recoverVolginDemo"then
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/free/f30010/f30011.fpk"
	else
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/free/f30010/f30010.fpk"
	end

	--TODO WIP Zombie soldiers... will this work?
	--  TppSoldierFace.SetUseZombieFova{enabled=true}
end

missionPackTable[30020]=function(p)
	TppPackList.AddLocationCommonScriptPack(p)
	TppPackList.AddLocationCommonMissionAreaPack(p)
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.ORDER_BOX)
	TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/free/f30020/f30020.fpk"

	--TODO WIP Zombie soldiers... will this work?
	--  TppSoldierFace.SetUseZombieFova{enabled=true}
end

missionPackTable[30050]=function(missionCode)
	TppPackList.AddLocationCommonScriptPack(missionCode)
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MTBS_MISSION_AREA)

	--r12 load Sneaking Suit and Battledress data
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.DD_SOLDIER_SNEAKING)
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.DD_SOLDIER_BTRDRS)
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.DD_SOLDIER_ATTACKER)
	--r42 Beach party mode bikinis pack
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.DD_SOLDIER_SWIM_SUIT)


	--rX5 using non reinforce vehicles
	--WEST
	--  TppPackList.AddMissionPack"/Assets/tpp/pack/vehicle/veh_rl_west_tnk.fpk" --works
	--  TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/veh_mc_west_tnk.fpk" --does not work, this does not have complete parts
	--  TppPackList.AddMissionPack"/Assets/tpp/pack/soldier/reinforce/reinforce_veh_west_tnk_a.fpk" --does not work, am guessing missing parts

	--EAST
	--  TppPackList.AddMissionPack"/Assets/tpp/pack/vehicle/veh_rl_east_tnk.fpk" --works
	--  TppPackList.AddMissionPack"/Assets/tpp/pack/soldier/reinforce/reinforce_veh_east_tnk.fpk" --does not work, am guessing missing parts
	--  TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/veh_mc_east_tnk.fpk" --does not work, this does not have complete parts

	--rX5 using non reinforce vehicles; Obviously does not work
	--  ScriptBlock.Load(ScriptBlock.GetScriptBlockId(mvars.reinforce_reinforceBlockName),"/Assets/tpp/pack/soldier/reinforce/reinforce_veh_east_tnk.fpk")
	--  ScriptBlock.Load("/Assets/tpp/pack/soldier/reinforce/reinforce_veh_east_tnk.fpk")

	--rp does not work
	-- UAVs and Cams testing
	--TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/online/o50050/o50050_area.fpk"
	--TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/online/o50050/o50050_additional.fpk"
	--TppPackList.AddDefaultMissionAreaPack(p)
	--TppPackList.AddFOBLayoutPack(p)

	do
		if TppPackList.IsMissionPackLabel"AfterDemo" or TppPackList.IsMissionPackLabel"BattleHanger" then
			TppDemo.SetNextMBDemo(nil)
		else
			if not TppPackList.IsMissionPackLabel"USE_USER_SETTING" and TppDemo.CanUpdateMBDemo()then
				TppDemo.UpdateMBDemo()local s=TppDemo.GetMBDemoName()
				if TppDemo.IsQuestStart()and(not TppDemo.IsSortieMBDemo(s))then
					TppDemo.SetNextMBDemo(nil)
				end
			end
		end
		local s=TppDemo.IsUseMBDemoStage(TppDemo.GetMBDemoName())
		if TppPackList.IsMissionPackLabel"DemoStage" then
			s=true
			TppDemo.SetNextMBDemo(nil)
		end
		if TppPackList.IsMissionPackLabel"BattleHanger" or TppDemo.IsBattleHangerDemo(TppDemo.GetMBDemoName()) then
			local s=string.format("/Assets/tpp/pack/mission2/free/f30050/f30050_hanger_btg%.2d.fpk",TppStory.GetBattleGearDevelopLevel())
			TppPackList.AddMissionPack(s)
			do
				local s=378
				if TppStory.HueyHasKantokuGrass() then
					s=379
				end
				local p={}
				table.insert(p,{type="hostage",name="TppHuey2GameObjectLocator",faceId=EnemyFova.INVALID_FOVA_VALUE,bodyId=s})
				TppEneFova.AddUniqueSettingPackage(p)
			end
			gvars.f30050_missionPackIndex=2
		elseif s then
			TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/free/f30050/f30051.fpk"
			TppPackList.SetMissionPackLabelName"DemoStage"
			gvars.f30050_missionPackIndex=1
		else
			do
				TppEneFova.AddUniquePackage{type="hostage",body={{371,1}}}
			end
			TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.DD_SOLDIER_WAIT)
			TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/free/f30050/f30050.fpk"
			TppPackList.AddFOBLayoutPack(missionCode)
			gvars.f30050_missionPackIndex=0
		end
	end
	TppHostage2.SetHostageType{gameObjectType="TppHostageUnique",hostageType="Paz"}

	--rX7 UAVs on MB trials
	--  TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/online/o50050/o50050_additional.fpk" --does not load
	--  TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/online/o50050/o50055_area.fpk" --works but can't return to ACC
	--  TppPackList.AddLocationCommonScriptPack(50050) --works but can't return to ACC
	--  TppPackList.AddDefaultMissionAreaPack(50050) --works but can't return to ACC
	--  TppPackList.AddFOBLayoutPack(50050) --does not load

	--rX56 Trying to get the pullout music from M2 to play
	--TppPackList.AddDefaultMissionAreaPack(10030) --NOPE
end

missionPackTable[30150]=function(p)
	TppPackList.AddLocationCommonScriptPack(p)
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)
	TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/free/f30150/f30150.fpk"
end

missionPackTable[30250]=function(p)
	TppPackList.AddLocationCommonScriptPack(p)
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.DD_SOLDIER_WAIT)
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)
	TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/free/f30250/f30250.fpk"
	if TppHostage2.SetHostageType then
		TppHostage2.SetHostageType{gameObjectType="TppHostageUnique",hostageType="Volgin"}
		TppHostage2.SetHostageType{gameObjectType="TppHostage2",hostageType="Parasite"}
	end
	if TppHostage2.SetUniquePartsPath then
		local s={
			hos_wmu00_0000="/Assets/tpp/parts/chara/wmu/wmu0_main0_def_v00.parts",
			hos_wmu00_0001="/Assets/tpp/parts/chara/wmu/wmu0_main0_def_v00.parts",
			hos_wmu01_0000="/Assets/tpp/parts/chara/wmu/wmu1_main0_def_v00.parts",
			hos_wmu01_0001="/Assets/tpp/parts/chara/wmu/wmu1_main0_def_v00.parts",
			hos_wmu03_0000="/Assets/tpp/parts/chara/wmu/wmu3_main0_def_v00.parts",
			hos_wmu03_0001="/Assets/tpp/parts/chara/wmu/wmu3_main0_def_v00.parts"
		}
		for s,p in pairs(s)do
			TppHostage2.SetUniquePartsPath{gameObjectType="TppHostage2",locatorName=s,parts=p}
		end
	end

	--r46 Added additional packs for DD outfits
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.DD_SOLDIER_SNEAKING)
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.DD_SOLDIER_BTRDRS)
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.DD_SOLDIER_ATTACKER)
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.DD_SOLDIER_SWIM_SUIT)

end

missionPackTable[40010]=function(p)
	if gvars.ini_isTitleMode then
		TppPackList.SetDefaultMissionPackLabelName()
	end
	TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/heli/heli_common_script.fpk"
	if TppPackList.IsMissionPackLabel"PS3Store"then
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/title_sequence.fpk"
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/helispace_ps3store.fpk"
	elseif TppPackList.IsMissionPackLabel"avatarEdit"then
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/title_sequence.fpk"
		TppPackList.AddAvatarEditPack()
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/heli/h40010/h40010_avatar.fpk"
	else
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/title_sequence.fpk"
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/heli/heli_ui.fpk"
		TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)
		TppPackList.AddLocationCommonScriptPack(p)
		TppPackList.AddDefaultMissionAreaPack(p)
	end
	TppHostage2.SetHostageType{gameObjectType="TppHostage2",hostageType="Mob"}
end
missionPackTable[40020]=function(p)
	if gvars.ini_isTitleMode then
		TppPackList.SetDefaultMissionPackLabelName()
	end
	TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/heli/heli_common_script.fpk"
	if TppPackList.IsMissionPackLabel"PS3Store"then
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/title_sequence.fpk"
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/helispace_ps3store.fpk"
	elseif TppPackList.IsMissionPackLabel"avatarEdit"then
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/title_sequence.fpk"
		TppPackList.AddAvatarEditPack()
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/heli/h40020/h40020_avatar.fpk"else
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/title_sequence.fpk"
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/heli/heli_ui.fpk"
		TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)
		TppPackList.AddLocationCommonScriptPack(p)
		TppPackList.AddDefaultMissionAreaPack(p)
	end
	TppHostage2.SetHostageType{gameObjectType="TppHostage2",hostageType="Mob"}
end
missionPackTable[40050]=function(p)
	if gvars.ini_isTitleMode then
		TppPackList.SetDefaultMissionPackLabelName()
	end
	TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/heli/heli_common_script.fpk"
	if TppPackList.IsMissionPackLabel"PS3Store"then
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/title_sequence.fpk"
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/helispace_ps3store.fpk"
	elseif TppPackList.IsMissionPackLabel"avatarEdit"then
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/title_sequence.fpk"
		TppPackList.AddAvatarEditPack()
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/heli/h40050/h40050_avatar.fpk"else
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/common/title_sequence.fpk"
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/heli/heli_ui.fpk"
		TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)
		TppPackList.AddLocationCommonScriptPack(p)
		TppPackList.AddDefaultMissionAreaPack(p)
	end
	TppHostage2.SetHostageType{gameObjectType="TppHostage2",hostageType="Mob"}
end
missionPackTable[65020]={"/Assets/tpp/pack/show/e3_2014/s65020/s65020_area.fpk","/Assets/tpp/pack/location/afgh/pack_common/afgh_script.fpk"}missionPackTable[65030]={"/Assets/tpp/pack/show/e3_2014/s65030/s65030_area.fpk"}missionPackTable[65050]={"/Assets/tpp/pack/show/e3_2014/s65050/s65050_area.fpk"}missionPackTable[65414]={"/Assets/tpp/pack/show/gc_2014/s65414/s65414_area.fpk"}missionPackTable[65060]=function(p)TppPackList.AddMissionPack"/Assets/tpp/pack/show/tgs_2014/s65060/s65060_area.fpk"TppPackList.AddLocationCommonScriptPack(p)do
	local s="hos_s65060_0000"local s={{type="hostage",name=s,faceId=621,bodyId=111}}TppEneFova.AddUniqueSettingPackage(s)end
end
missionPackTable[65415]={"/Assets/tpp/pack/show/tgs_2014/s65415/s65415_area.fpk"}missionPackTable[65416]={"/Assets/tpp/pack/show/tgs_2014/s65416/s65416_area.fpk"}
missionPackTable[50050]=function(s)
	local p=TppEnemy.GetDDSuit()
	--RETAILPATCH 1.10>
	if TppMotherBaseManagement.GetMbsClusterSecurityIsEquipSwimSuit()then
		TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.DD_SOLDIER_SWIM_SUIT)
		--<
	elseif p==TppEnemy.FOB_DD_SUIT_SNEAKING then
		TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.DD_SOLDIER_SNEAKING)
	elseif p==TppEnemy.FOB_DD_SUIT_BTRDRS then
		TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.DD_SOLDIER_BTRDRS)
	elseif p==TppEnemy.FOB_PF_SUIT_ARMOR then
		TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.DD_SOLDIER_ARMOR)
	else
		TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.DD_SOLDIER_ATTACKER)
	end
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.HELICOPTER)
	TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.MTBS_DECOY)
	if TppEnemy.IsHostageEventFOB()then
		TppPackList.AddMissionPack(TppDefine.MISSION_COMMON_PACK.FOB_HOSTAGE)
		do
			local s={
				{type="hostage",name="hos_o50050_event5_0000",faceId=621,bodyId=143},
				{type="hostage",name="hos_o50050_event5_0001",faceId=640,bodyId=143},
				{type="hostage",name="hos_o50050_event5_0002",faceId=641,bodyId=143},
				{type="hostage",name="hos_o50050_event5_0003",faceId=646,bodyId=143}}
			TppEneFova.AddUniqueSettingPackage(s)
		end
	end
	if TppEnemy.IsZombieEventFOB()then
		TppSoldierFace.SetUseZombieFova{enabled=true}
	end
	if TppEnemy.IsParasiteMetalEventFOB()then
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/online/o50050/o50055_parasite_metal.fpk"
	end
	TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/online/o50050/o50050_additional.fpk"
	TppPackList.AddLocationCommonScriptPack(s)
	if TppEnemy.IsSpecialEventFOB()then
		TppPackList.AddMissionPack"/Assets/tpp/pack/mission2/online/o50050/o50055_area.fpk"
	else
		TppPackList.AddDefaultMissionAreaPack(s)
	end
	TppPackList.AddFOBLayoutPack(s)
end
function this.GetLocationPackagePath(s)
	local p=locationPackTable[s]
	if p then
	end
	TppLocation.SetBuddyBlock(s)return p
end

function this.GetMissionPackagePath(missionCode)
	TppPackList.SetUseDdEmblemFova(missionCode)
	local packPath
	if missionPackTable[missionCode]==nil then
		packPath=TppPackList.MakeMissionPackList(missionCode,TppPackList.MakeDefaultMissionPackList)
	elseif Tpp.IsTypeFunc(missionPackTable[missionCode])then
		packPath=TppPackList.MakeMissionPackList(missionCode,missionPackTable[missionCode])
	elseif Tpp.IsTypeTable(missionPackTable[missionCode])then
		packPath=missionPackTable[missionCode]
	end
	--  TUPPMLog.Log("Loading mission packs for: "..tostring(missionCode))
	--19 More Vehicles
	--Doesn't work for missions
	TppMain.AddVehiclePacks(missionCode,packPath)--tex
	return packPath
end
if Mission.SetLocationPackagePathFunc then
	Mission.SetLocationPackagePathFunc(this.GetLocationPackagePath)
end
if Mission.SetMissionPackagePathFunc then
	Mission.SetMissionPackagePathFunc(this.GetMissionPackagePath)
end

function this.IsStartHeliToMB()
end
return this
