local this={}
local IsTypeTable=Tpp.IsTypeTable
local SendCommand=GameObject.SendCommand
local GetGameObjectId=GameObject.GetGameObjectId
local NULL_ID=GameObject.NULL_ID
local number500=500
local number1e3=1e3
local number4=4
--r51 Settings
this.GMP_POSTER=500*(TUPPMSettings.res_gmpPostersMultiplier or 1) --r25 Posters give x10 gmp reward --r16 Posters give x4 gmp reward
this.FOB_TUTORIAL_STATE={INIT=0,INTRODUCTION_CONSTRUCT_FOB=1,CONSTRUCT_FOB=2,INTRODUCTION_FOB_MISSIONS=3,FOB_MISSIONS=4,FINISH=127}
this.unitLvAnnounceLogTable={
	[Fox.StrCode32"Combat"]={up="unitLvUpCombat",down="unitLvDownCombat"},
	[Fox.StrCode32"Develop"]={up="unitLvUpRd",down="unitLvDownRd"},
	[Fox.StrCode32"Support"]={up="unitLvUpSupport",down="unitLvDownSupport"},
	[Fox.StrCode32"Medical"]={up="unitLvUpMedical",down="unitLvDownMedical"},
	[Fox.StrCode32"Spy"]={up="unitLvUpIntel",down="unitLvDownIntel"},
	[Fox.StrCode32"PrantDev"]={up="unitLvUpBaseDev",down="unitLvDownBaseDev"},
	[Fox.StrCode32"Security"]={up="unitLvUpSecurity",down="unitLvDownSecurity"}
}
this.keyItemAnnounceLogTable={
	[TppMotherBaseManagementConst.DESIGN_3011]="key_item_3011",
	[TppMotherBaseManagementConst.DESIGN_3012]="key_item_3012",
	[TppMotherBaseManagementConst.DESIGN_3006]="key_item_3006",
	[TppMotherBaseManagementConst.DESIGN_3005]="key_item_3005",
	[TppMotherBaseManagementConst.DESIGN_3000]="key_item_3000",
	[TppMotherBaseManagementConst.DESIGN_3009]="key_item_3009",
	[TppMotherBaseManagementConst.DESIGN_3002]="key_item_3002",
	[TppMotherBaseManagementConst.DESIGN_3007]="key_item_3007",
	[TppMotherBaseManagementConst.DESIGN_3001]="key_item_3001"
}

this.keyItemRewardTable={
	[TppMotherBaseManagementConst.DESIGN_3013]="key_item_3013",
	[TppMotherBaseManagementConst.DESIGN_3003]="key_item_3003",
	[TppMotherBaseManagementConst.DESIGN_3008]="key_item_3008",
	[TppMotherBaseManagementConst.DESIGN_3014]="key_item_3014",
	[TppMotherBaseManagementConst.DESIGN_3015]="key_item_3015",
	[TppMotherBaseManagementConst.DESIGN_3016]="key_item_3016",
	[TppMotherBaseManagementConst.DESIGN_3017]="key_item_3017",
	[TppMotherBaseManagementConst.DESIGN_3018]="key_item_3018",
	[TppMotherBaseManagementConst.DESIGN_3019]="key_item_3019",
	[TppMotherBaseManagementConst.DESIGN_3007]="key_item_3007",
	[TppMotherBaseManagementConst.DESIGN_3010]="key_item_3010",
	[TppMotherBaseManagementConst.DESIGN_3020]="key_item_3020"
}

this.parasiteSquadFultonResouceId={
	--r27 Parasites recovered are now 500 for all types
	--r51 Settings
	[Fox.StrCode32"Cam"]={TppMotherBaseManagementConst.RESOURCE_ID_PARASITE_CAMOFLA,5*(TUPPMSettings.res_parasitesMultiplier or 1)},
	[Fox.StrCode32"Fog"]={TppMotherBaseManagementConst.RESOURCE_ID_PARASITE_FOG,5*(TUPPMSettings.res_parasitesMultiplier or 1)},
	[Fox.StrCode32"Metal"]={TppMotherBaseManagementConst.RESOURCE_ID_PARASITE_CURING,5*(TUPPMSettings.res_parasitesMultiplier or 1)}
}
this.MOTHER_BASE_SECTION_LIST={"Combat","BaseDev","Spy","Medical","Security","Hospital","Prison","Separation"}
local t=TppMotherBaseManagementConst or{}
local T={Combat={DispatchSoldier=t.SECTION_FUNC_ID_COMBAT_DEPLOY,DispatchFobDefence=t.SECTION_FUNC_ID_COMBAT_DEFENCE}
	,Develop={Weapon=t.SECTION_FUNC_ID_DEVELOP_WEAPON,SupportHelicopter=t.SECTION_FUNC_ID_DEVELOP_HELI,Quiet=t.SECTION_FUNC_ID_DEVELOP_QUIET,D_Dog=t.SECTION_FUNC_ID_DEVELOP_D_DOG,D_Horse=t.SECTION_FUNC_ID_DEVELOP_D_HORSE,D_Walker=t.SECTION_FUNC_ID_DEVELOP_D_WALKER,BattleGear=t.SECTION_FUNC_ID_DEVELOP_BATTLE_GEAR,SecurityDevice=t.SECTION_FUNC_ID_DEVELOP_SECURITY_DEVICE}
	,BaseDev={Mining=t.SECTION_FUNC_ID_BASE_DEV_RESOURCE_MINING,Processing=t.SECTION_FUNC_ID_BASE_DEV_RESOURCE_PROCESSING,Extention=t.SECTION_FUNC_ID_BASE_DEV_PLATFORM_EXTENTION,Construct=t.SECTION_FUNC_ID_BASE_DEV_FOB_CONSTRUCT,NuclearDevelop=t.SECTION_FUNC_ID_BASE_DEV_NUCLEAR_DEVELOP}
	,Support={Fulton=t.SECTION_FUNC_ID_SUPPORT_FULTON,Supply=t.SECTION_FUNC_ID_SUPPORT_SUPPLY,Battle=t.SECTION_FUNC_ID_SUPPORT_BATTLE,BattleArtillery=t.SECTION_FUNC_ID_SUPPORT_STRIKE,BattleSmoke=t.SECTION_FUNC_ID_SUPPORT_SMOKE,BattleSleepGas=t.SECTION_FUNC_ID_SUPPORT_SLEEP_GAS,BattleChaff=t.SECTION_FUNC_ID_SUPPORT_CHAFF,BattleWeather=t.SECTION_FUNC_ID_SUPPORT_WEATHER,TranslationRussian=t.SECTION_FUNC_ID_SUPPORT_RUSSIAN_TRANSLATE,TranslationAfrikaans=t.SECTION_FUNC_ID_SUPPORT_AFRIKAANS_TRANSLATE,TranslationKikongo=t.SECTION_FUNC_ID_SUPPORT_KIKONGO_TRANSLATE,TranslationPashto=t.SECTION_FUNC_ID_SUPPORT_PASHTO_TRANSLATE}
	,Spy={Information=t.SECTION_FUNC_ID_SPY_MISSION_INFO_COLLECTING,Scouting=t.SECTION_FUNC_ID_SPY_ENEMY_SEARCH,SearchResource=t.SECTION_FUNC_ID_SPY_RESOURCE_SEARCH,WeatherInformation=t.SECTION_FUNC_ID_SPY_WEATHER_INFO}
	,Medical={Emergency=t.SECTION_FUNC_ID_MEDICAL_STAFF_EMERGENCY,Treatment=t.SECTION_FUNC_ID_MEDICAL_STAFF_TREATMENT,AntiReflex=t.SECTION_FUNC_ID_MEDICAL_ANTI_REFLEX}
	,Security={BaseDefence=t.SECTION_FUNC_ID_SECURITY_BASE_DEFENCE_STAFF,MachineDefence=t.SECTION_FUNC_ID_SECURITY_BASE_DEFENCE_MACHINE,BaseBlockade=t.SECTION_FUNC_ID_SECURITY_BASE_BLOCKADE,SecurityInfo=t.SECTION_FUNC_ID_SPY_SECURITY_INFO}
}
this.setUpMenuList={}
this.MBDVCMENU={
	ALL="all",
	MBM="MBM",
	MBM_REWORD="MBM_REWORD",
	MBM_CUSTOM="MBM_CUSTOM",
	MBM_CUSTOM_WEAPON="MBM_CUSTOM_WEAPON",
	MBM_CUSTOM_ARMS="MBM_CUSTOM_ARMS",
	MBM_CUSTOM_ARMS_HELI="MBM_CUSTOM_ARMS_HELI",
	MBM_CUSTOM_ARMS_VEHICLE="MBM_CUSTOM_ARMS_VEHICLE",
	MBM_CUSTOM_BUDDY="MBM_CUSTOM_BUDDY",
	MBM_CUSTOM_BUDDY_HORSE="MBM_CUSTOM_BUDDY_HORSE",
	MBM_CUSTOM_BUDDY_DOG="MBM_CUSTOM_BUDDY_DOG",
	MBM_CUSTOM_BUDDY_QUIET="MBM_CUSTOM_BUDDY_QUIET",
	MBM_CUSTOM_BUDDY_WALKER="MBM_CUSTOM_BUDDY_WALKER",
	MBM_CUSTOM_BUDDY_BATTLE="MBM_CUSTOM_BUDDY_BATTLE",
	MBM_CUSTOM_DESIGN="MBM_CUSTOM_DESIGN",
	MBM_CUSTOM_DESIGN_EMBLEM="MBM_CUSTOM_DESIGN_EMBLEM",
	MBM_CUSTOM_DESIGN_BASE="MBM_CUSTOM_DESIGN_BASE",
	MBM_CUSTOM_AVATAR="MBM_CUSTOM_AVATAR",
	MBM_DEVELOP="MBM_DEVELOP",
	MBM_DEVELOP_WEAPON="MBM_DEVELOP_WEAPON",
	MBM_DEVELOP_ARMS="MBM_DEVELOP_ARMS",
	MBM_RESOURCE="MBM_RESOURCE",
	MBM_STAFF="MBM_STAFF",
	MBM_COMBAT="MBM_COMBAT",
	MBM_BASE="MBM_BASE",
	MBM_BASE_SECURITY="MBM_BASE_SECURITY",
	MBM_BASE_EXPANTION="MBM_BASE_EXPANTION",
	MBM_DB="MBM_DB",
	MBM_DB_ENCYCLOPEDIA="MBM_DB_ENCYCLOPEDIA",
	MBM_DB_KEYITEM="MBM_DB_KEYITEM",
	MBM_DB_CASSETTE="MBM_DB_CASSETTE",
	MBM_DB_PFRATING="MBM_DB_PFRATING",
	MBM_LOG="MBM_LOG",
	MSN="MSN",
	MSN_EMERGENCIE_N="MSN_EMERGENCIE_N",
	MSN_EMERGENCIE_F="MSN_EMERGENCIE_F",
	MSN_DROP="MSN_DROP",
	MSN_DROP_BULLET="MSN_DROP_BULLET",
	MSN_DROP_WEAPON="MSN_DROP_WEAPON",
	MSN_DROP_LOADOUT="MSN_DROP_LOADOUT",
	MSN_DROP_VEHICLE="MSN_DROP_VEHICLE",
	MSN_BUDDY="MSN_BUDDY",
	MSN_BUDDY_HORSE="MSN_BUDDY_HORSE",
	MSN_BUDDY_HORSE_DISMISS="MSN_BUDDY_HORSE_DISMISS",
	MSN_BUDDY_DOG="MSN_BUDDY_DOG",
	MSN_BUDDY_DOG_DISMISS="MSN_BUDDY_DOG_DISMISS",
	MSN_BUDDY_QUIET_SCOUT="MSN_BUDDY_QUIET_SCOUT",
	MSN_BUDDY_QUIET_ATTACK="MSN_BUDDY_QUIET_ATTACK",
	MSN_BUDDY_QUIET_DISMISS="MSN_BUDDY_QUIET_DISMISS",
	MSN_BUDDY_WALKER="MSN_BUDDY_WALKER",
	MSN_BUDDY_WALKER_DISMISS="MSN_BUDDY_WALKER_DISMISS",
	MSN_BUDDY_BATTLE="MSN_BUDDY_BATTLE",
	MSN_BUDDY_BATTLE_DISMISS="MSN_BUDDY_BATTLE_DISMISS",
	MSN_BUDDY_EQUIP="MSN_BUDDY_EQUIP",
	MSN_ATTACK="MSN_ATTACK",
	MSN_ATTACK_ARTILLERY="MSN_ATTACK_ARTILLERY",
	MSN_ATTACK_SMOKE="MSN_ATTACK_SMOKE",
	MSN_ATTACK_SLEEP="MSN_ATTACK_SLEEP",
	MSN_ATTACK_CHAFF="MSN_ATTACK_CHAFF",
	MSN_ATTACK_WEATHER="MSN_ATTACK_WEATHER",
	MSN_ATTACK_WEATHER_SANDSTORM="MSN_ATTACK_WEATHER_SANDSTORM",
	MSN_ATTACK_WEATHER_STORM="MSN_ATTACK_WEATHER_STORM",
	MSN_ATTACK_WEATHER_CLEAR="MSN_ATTACK_WEATHER_CLEAR",
	MSN_HELI="MSN_HELI",
	MSN_HELI_RENDEZVOUS="MSN_HELI_RENDEZVOUS",
	MSN_HELI_ATTACK="MSN_HELI_ATTACK",
	MSN_HELI_DISMISS="MSN_HELI_DISMISS",
	MSN_MISSIONLIST="MSN_MISSIONLIST",
	MSN_SIDEOPSLIST="MSN_SIDEOPSLIST",
	MSN_CHALLENGE="MSN_CHALLENGE",
	MSN_LOCATION="MSN_LOCATION",
	MSN_RETURNMB="MSN_RETURNMB",
	MSN_FOB="MSN_FOB",
	MSN_FRIEND="MSN_FRIEND",
	MSN_LOG="MSN_LOG"
}
this.BUDDY_MB_DVC_MENU={
	[BuddyType.QUIET]={{menu=this.MBDVCMENU.MSN_BUDDY_QUIET_SCOUT,active=true}
		,{menu=this.MBDVCMENU.MSN_BUDDY_QUIET_ATTACK,active=true}
		,{menu=this.MBDVCMENU.MSN_BUDDY_QUIET_DISMISS,active=true}
	}
	,[BuddyType.DOG]={{menu=this.MBDVCMENU.MSN_BUDDY_DOG,active=true}
		,{menu=this.MBDVCMENU.MSN_BUDDY_DOG_DISMISS,active=true}
	}
	,[BuddyType.HORSE]={{menu=this.MBDVCMENU.MSN_BUDDY_HORSE,active=true}
		,{menu=this.MBDVCMENU.MSN_BUDDY_HORSE_DISMISS,active=true}
	}
	,[BuddyType.WALKER_GEAR]={{menu=this.MBDVCMENU.MSN_BUDDY_WALKER,active=true}
		,{menu=this.MBDVCMENU.MSN_BUDDY_WALKER_DISMISS,active=true}
	}
	,[BuddyType.BATTLE_GEAR]={{menu=this.MBDVCMENU.MSN_BUDDY_BATTLE,active=true}
		,{menu=this.MBDVCMENU.MSN_BUDDY_BATTLE_DISMISS,active=true}
	}
}
this.RESOURCE_INFORMATION_TABLE={
	--r51 Settings
	[TppCollection.TYPE_MATERIAL_CM_0]={resourceName="CommonMetal",count=100*(TUPPMSettings.res_commonMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_CM_1]={resourceName="CommonMetal",count=100*(TUPPMSettings.res_commonMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_CM_2]={resourceName="CommonMetal",count=100*(TUPPMSettings.res_commonMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_CM_3]={resourceName="CommonMetal",count=100*(TUPPMSettings.res_commonMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_CM_4]={resourceName="CommonMetal",count=100*(TUPPMSettings.res_commonMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_CM_5]={resourceName="CommonMetal",count=100*(TUPPMSettings.res_commonMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_CM_6]={resourceName="CommonMetal",count=100*(TUPPMSettings.res_commonMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_CM_7]={resourceName="CommonMetal",count=100*(TUPPMSettings.res_commonMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_MM_0]={resourceName="MinorMetal",count=50*(TUPPMSettings.res_minorMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_MM_1]={resourceName="MinorMetal",count=50*(TUPPMSettings.res_minorMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_MM_2]={resourceName="MinorMetal",count=50*(TUPPMSettings.res_minorMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_MM_3]={resourceName="MinorMetal",count=50*(TUPPMSettings.res_minorMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_MM_4]={resourceName="MinorMetal",count=50*(TUPPMSettings.res_minorMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_MM_5]={resourceName="MinorMetal",count=50*(TUPPMSettings.res_minorMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_MM_6]={resourceName="MinorMetal",count=50*(TUPPMSettings.res_minorMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_MM_7]={resourceName="MinorMetal",count=50*(TUPPMSettings.res_minorMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_PM_0]={resourceName="PreciousMetal",count=10*(TUPPMSettings.res_preciousMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_PM_1]={resourceName="PreciousMetal",count=10*(TUPPMSettings.res_preciousMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_PM_2]={resourceName="PreciousMetal",count=10*(TUPPMSettings.res_preciousMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_PM_3]={resourceName="PreciousMetal",count=10*(TUPPMSettings.res_preciousMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_PM_4]={resourceName="PreciousMetal",count=10*(TUPPMSettings.res_preciousMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_PM_5]={resourceName="PreciousMetal",count=10*(TUPPMSettings.res_preciousMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_PM_6]={resourceName="PreciousMetal",count=10*(TUPPMSettings.res_preciousMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_PM_7]={resourceName="PreciousMetal",count=10*(TUPPMSettings.res_preciousMetalMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_FR_0]={resourceName="FuelResource",count=100*(TUPPMSettings.res_fuelResourceMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_FR_1]={resourceName="FuelResource",count=100*(TUPPMSettings.res_fuelResourceMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_FR_2]={resourceName="FuelResource",count=100*(TUPPMSettings.res_fuelResourceMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_FR_3]={resourceName="FuelResource",count=100*(TUPPMSettings.res_fuelResourceMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_FR_4]={resourceName="FuelResource",count=100*(TUPPMSettings.res_fuelResourceMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_FR_5]={resourceName="FuelResource",count=100*(TUPPMSettings.res_fuelResourceMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_FR_6]={resourceName="FuelResource",count=100*(TUPPMSettings.res_fuelResourceMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_FR_7]={resourceName="FuelResource",count=100*(TUPPMSettings.res_fuelResourceMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_BR_0]={resourceName="BioticResource",count=100*(TUPPMSettings.res_bioticResourceMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_BR_1]={resourceName="BioticResource",count=100*(TUPPMSettings.res_bioticResourceMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_BR_2]={resourceName="BioticResource",count=100*(TUPPMSettings.res_bioticResourceMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_BR_3]={resourceName="BioticResource",count=100*(TUPPMSettings.res_bioticResourceMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_BR_4]={resourceName="BioticResource",count=100*(TUPPMSettings.res_bioticResourceMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_BR_5]={resourceName="BioticResource",count=100*(TUPPMSettings.res_bioticResourceMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_BR_6]={resourceName="BioticResource",count=100*(TUPPMSettings.res_bioticResourceMultiplier or 1)},
	[TppCollection.TYPE_MATERIAL_BR_7]={resourceName="BioticResource",count=100*(TUPPMSettings.res_bioticResourceMultiplier or 1)},
	[TppCollection.TYPE_HERB_G_CRESCENT]={resourceName="Plant2000",count=10*(TUPPMSettings.res_plantResourceMultiplier or 1)},
	[TppCollection.TYPE_HERB_A_PEACH]={resourceName="Plant2001",count=10*(TUPPMSettings.res_plantResourceMultiplier or 1)},
	[TppCollection.TYPE_HERB_DIGITALIS_P]={resourceName="Plant2002",count=10*(TUPPMSettings.res_plantResourceMultiplier or 1)},
	[TppCollection.TYPE_HERB_DIGITALIS_R]={resourceName="Plant2003",count=10*(TUPPMSettings.res_plantResourceMultiplier or 1)},
	[TppCollection.TYPE_HERB_B_CARROT]={resourceName="Plant2004",count=10*(TUPPMSettings.res_plantResourceMultiplier or 1)},
	[TppCollection.TYPE_HERB_WORM_WOOD]={resourceName="Plant2005",count=10*(TUPPMSettings.res_plantResourceMultiplier or 1)},
	[TppCollection.TYPE_HERB_TARRAGON]={resourceName="Plant2006",count=10*(TUPPMSettings.res_plantResourceMultiplier or 1)},
	[TppCollection.TYPE_HERB_HAOMA]={resourceName="Plant2007",count=10*(TUPPMSettings.res_plantResourceMultiplier or 1)},
	[TppCollection.TYPE_POSTER_SOL_AFGN]={resourceName="Poster1000",count=1},
	[TppCollection.TYPE_POSTER_SOL_MAFR]={resourceName="Poster1001",count=1},
	[TppCollection.TYPE_POSTER_SOL_ZRS]={resourceName="Poster1002",count=1},
	[TppCollection.TYPE_POSTER_GRAVURE_V]={resourceName="Poster1003",count=1},
	[TppCollection.TYPE_POSTER_GRAVURE_H]={resourceName="Poster1004",count=1},
	[TppCollection.TYPE_POSTER_MOE_V]={resourceName="Poster1005",count=1},
	[TppCollection.TYPE_POSTER_MOE_H]={resourceName="Poster1006",count=1}
}
this.BLUE_PRINT_LOCATOR_TABLE={col_develop_Revolver_Shotgun=t.DESIGN_2002,col_develop_Highprecision_SMG=t.DESIGN_2006,col_develop_HighprecisionAR=t.DESIGN_2007,col_develop_HighprecisionAR_s10033_0000=t.DESIGN_2007,col_develop_BullpupAR=t.DESIGN_2008,col_develop_LongtubeShotgun=t.DESIGN_2009,col_develop_RevolverGrenade0001=t.DESIGN_2011,col_develop_RevolverGrenade0002=t.DESIGN_2011,col_develop_RevolverGrenade0003=t.DESIGN_2011,col_develop_RevolverGrenade0004=t.DESIGN_2011,col_develop_Semiauto_SR=t.DESIGN_2013,col_develop_Semiauto_SR_s10070_0000=t.DESIGN_2013,col_develop_Antimaterial=t.DESIGN_2015,col_develop_EuropeSMG0001=t.DESIGN_2016,col_develop_EuropeSMG0002=t.DESIGN_2016,col_develop_EuropeSMG0003=t.DESIGN_2016,col_develop_EuropeSMG0004=t.DESIGN_2016,col_develop_Stungrenade=t.DESIGN_2019,col_develop_Stungun=t.DESIGN_2020,col_develop_Infraredsensor=t.DESIGN_2021,col_develop_Theftprotection=t.DESIGN_2022,col_develop_Emergencyrescue=t.DESIGN_3001,col_develop_FLamethrower=t.DESIGN_2026,col_develop_Shield=t.DESIGN_2025,col_develop_Shield0000=t.DESIGN_2025,col_develop_Shield0001=t.DESIGN_2025,col_develop_Shield0002=t.DESIGN_2025,col_develop_GunCamera=t.DESIGN_2023,col_develop_UAV=t.DESIGN_2024,col_develop_q60115=t.DESIGN_2027}
this.BLUE_PRINT_LANG_ID={[t.DESIGN_2002]="key_bprint_2002",[t.DESIGN_2006]="key_bprint_2006",[t.DESIGN_2007]="key_bprint_2007",[t.DESIGN_2008]="key_bprint_2008",[t.DESIGN_2009]="key_bprint_2009",[t.DESIGN_2011]="key_bprint_2011",[t.DESIGN_2013]="key_bprint_2013",[t.DESIGN_2015]="key_bprint_2015",[t.DESIGN_2016]="key_bprint_2016",[t.DESIGN_2019]="key_bprint_2019",[t.DESIGN_2020]="key_bprint_2020",[t.DESIGN_2021]="key_bprint_2021",[t.DESIGN_2022]="key_bprint_2022",[t.DESIGN_2023]="key_bprint_2023",[t.DESIGN_2024]="key_bprint_2024",[t.DESIGN_2025]="key_bprint_2025",[t.DESIGN_2026]="key_bprint_2026",[t.DESIGN_2027]="key_bprint_2027",[t.DESIGN_3001]="key_item_3001"}
this.EMBLEM_LOCATOR_TABLE={["ly003_cl00_collct0000|cl00pl0_uq_0000_collct|col_develop_MTBS_0000"]="front8",["ly003_cl00_collct0000|cl00pl0_uq_0000_collct|col_develop_MTBS_0001"]="front10",["ly003_cl00_collct0000|cl00pl0_uq_0000_collct|col_develop_MTBS_0002"]="front15",["ly003_cl00_collct0000|cl00pl0_uq_0000_collct|col_develop_MTBS_0003"]="front16",["ly003_cl04_collct0000|cl04pl0_uq_0040_collct|col_emblem_quiet"]="front9",col_develop_MTBS_30150_0000="front11",col_develop_MTBS_30250_0000="front7"}
local n={}
if TppDefine.GMP_COST_TYPE then
	n[TppDefine.GMP_COST_TYPE.FULTON]="gmpCostFulton"n[TppDefine.GMP_COST_TYPE.SUPPORT_SUPPLY]="gmpCostSupply"n[TppDefine.GMP_COST_TYPE.SUPPORT_ATTACK]="gmpCostAttack"n[TppDefine.GMP_COST_TYPE.CALL_HELLI]="gmpCostHeli"n[TppDefine.GMP_COST_TYPE.BUDDY]="gmpCostOps"n[TppDefine.GMP_COST_TYPE.CLEAR_SIDE_OPS]="gmpGet"n[TppDefine.GMP_COST_TYPE.DESTROY_SUPPORT_HELI]="add_alt_machine"end
function this.UpdateGMP(e)
	if not TppMotherBaseManagement.AddGmp then
		return
	end
	if not IsTypeTable(e)then
		return
	end
	local t=e.gmp
	local a=math.abs(t)
	local r=e.withOutAnnouceLog
	if t>0 then
		TppMotherBaseManagement.AddGmp{gmp=t}
	else
		TppMotherBaseManagement.SubGmp{gmp=a}
	end
	if not r then
		if gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_RECUE_MILLER and e.gmpCostType then
			local e=n[e.gmpCostType]
			if e then
				TppUI.ShowAnnounceLog(e,a)
			end
		end
	end
end
function this.CorrectGMP(gmpClear)
	if not TppMotherBaseManagement.CorrectGmp then
		return
	end
	if not IsTypeTable(gmpClear)then
		return
	end
	local gmpValue=gmpClear.gmp
	if not gmpValue then
		return gmpValue
	end
	return TppMotherBaseManagement.CorrectGmp{gmp=gmpValue} --ORIG
		--return ((TppMotherBaseManagement.CorrectGmp{gmp=gmpValue})*2) --r23 Change here for Doubled mission clear rewards
end
function this.ClearStaffNewIcon(isHelicopterSpace,isFreeMission,nextIsHelicopterSpace,nextIsFreeMission)
	if TppMission.IsEmergencyMission()then
		return
	end
	if isHelicopterSpace or isFreeMission then
		if(not nextIsHelicopterSpace)and(not nextIsFreeMission)then
			--TODO rX46 Cleared on starting a mission
			TppMotherBaseManagement.ClearAllStaffNew()
		end
	end
end
function this.AddStaffsFromTempBuffer(t,n)
	if(vars.fobSneakMode==FobMode.MODE_SHAM)then
		return
	end
	local a=TppMotherBaseManagement.IsExistTempStaff{skill="TranslateRussian"}
	local o=TppMotherBaseManagement.IsExistStaff{skill="TranslateRussian"}
	if a and not o then
		TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.RECOVERED_RUSSIAN_INTERPRETER)
	end
	for e=0,(number4-1)do
		if svars.trm_isBuddyRecovered[e]then
			TppBuddyService.SetObtainedBuddyType(e)
			if e==BuddyType.QUIET then
			end
			if e==BuddyType.DOG then
				TppEmblem.Add("word146",false,true)
				if(TppBuddyService.IsBuddyDogGot()==false)then
					TppBuddyService.SetBuddyDogGot()
				elseif(TppBuddyService.IsBuddyDogSecondGot()==false)then
					TppBuddyService.IsBuddyDogSecondGot()
				end
				TppBuddyService.UnsetDeadBuddyType(BuddyType.DOG)
			end
		end
	end
	if mvars.trm_needHeliSoundOnAddStaffsFromTempBuffer then
		TppSound.PostEventForFultonRecover()
	end
	mvars.trm_needHeliSoundOnAddStaffsFromTempBuffer=false
	TppMotherBaseManagement.AddStaffsFromTempStaffBuffer()
	if not n then
		if t then
			TppMotherBaseManagement.StartSyncControl{readOnly=t}
		else
			this.ReserveMissionStartMbSync()
		end
	end
	TppUiCommand.AddAnimalEmblemTextureByDataBase()
end
function this.ReserveMissionStartMbSync()
	gvars.reservedMissionStartMbSync=true
end
function this.StartSyncMbManagementOnMissionStart()
	if gvars.reservedMissionStartMbSync then
		TppMotherBaseManagement.ProcessBeforeSync()
		TppMotherBaseManagement.StartSyncControl{}
		TppSave.SaveGameData(nil,nil,nil,true)
	end
end
function this.VarSaveMbMissionStartSyncEnd()
	if gvars.reservedMissionStartMbSync then
		gvars.reservedMissionStartMbSync=false
		TppSave.VarSaveMbMangement()
	end
end
function this.AcquireKeyItem(n)
	local t=n.dataBaseId
	local a=n.isShowAnnounceLog
	local n=n.pushReward
	if(TppMotherBaseManagement.IsGotDataBase{dataBaseId=t}==false)then
		TppMotherBaseManagement.DirectAddDataBase{dataBaseId=t,isNew=true}
		if a then
			local e=this.keyItemAnnounceLogTable[t]
			if e then
				TppUI.ShowAnnounceLog("find_keyitem",e)
			end
		elseif n then
			local e=this.keyItemRewardTable[t]
			if e then
				TppReward.Push{category=TppScriptVars.CATEGORY_MB_MANAGEMENT,langId=e,rewardType=TppReward.TYPE.KEY_ITEM}
			end
		end
	end
end
function this.ReserveHelicopterSoundOnMissionGameEnd()
	mvars.trm_needHeliSoundOnAddStaffsFromTempBuffer=true
end
function this.AddVolunteerStaffs()
	local e=TppStory.GetCurrentStorySequence()
	if e<TppDefine.STORY_SEQUENCE.CLEARD_TO_MATHER_BASE then
		return
	end
	local e={[10010]=true,[10030]=true,[10240]=true,[10280]=true,[30050]=true,[30150]=true,[30250]=true,[50050]=true}
	if e[vars.missionCode]then
		return
	end
	local e=TppMission.IsHelicopterSpace(vars.missionCode)
	if e then
		return
	end
	local t=svars.killCount
	local e=(svars.scoreTime/1e3)/60
	local e={missionId=vars.missionCode,clearTimeMinute=e,killCount=t}
	if(vars.missionCode~=30010)and(vars.missionCode~=30020)then
		TppMotherBaseManagement.AddVolunteerStaffs(e)
	else
		TppMotherBaseManagement.AddOgreUserVolunteerStaffs(e)
	end
	if TppMotherBaseManagement.AddMinimumSecurityStaffs then
		TppMotherBaseManagement.AddMinimumSecurityStaffs()
	end
end
function this.UnSetUsageRestriction(t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_REWORD,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_DEVELOP,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_STAFF,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_COMBAT,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_BASE,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_BASE_EXPANTION,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_BASE_SECURITY,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_RESOURCE,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_DB,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_DB_PFRATING,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_DB_CASSETTE,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_CUSTOM,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MSN_EMERGENCIE_F,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MSN_EMERGENCIE_N,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MSN_SIDEOPSLIST,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MSN_LOCATION,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MSN_RETURNMB,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MSN_DROP,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MSN_BUDDY,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MSN_ATTACK,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MSN_HELI,t)
end
function this.UnSetUsageRestrictionOnFOB(t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_REWORD,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_DEVELOP,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_STAFF,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_COMBAT,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_BASE,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_BASE_EXPANTION,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_BASE_SECURITY,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_RESOURCE,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_DB,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_DB_PFRATING,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_DB_CASSETTE,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MBM_CUSTOM,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MSN_EMERGENCIE_F,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MSN_EMERGENCIE_N,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MSN_SIDEOPSLIST,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MSN_CHALLENGE,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MSN_LOCATION,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MSN_RETURNMB,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MSN_DROP,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MSN_BUDDY,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MSN_ATTACK,t)
	TppUiCommand.SetMbTopMenuItemActive(this.MBDVCMENU.MSN_HELI,t)
end
function this.SetDevelpedByDevelopIdList(e)
	for t,e in ipairs(e)do
		TppMotherBaseManagement.SetEquipDeveloped{equipDevelopID=e}
	end
end
function this.IsNeedPlayPandemicTutorialRadio()
	if gvars.trm_donePandemicEvent then
		return false
	end
	if gvars.trm_donePandemicTutorial then
		return false
	end
	if(not TppMission.IsHelicopterSpace(vars.missionCode))then
		return false
	end
	return this.PandemicTutorialStoryCondition()
end
function this.PandemicTutorialStoryCondition()
	if TppStory.GetCurrentStorySequence()>=TppDefine.STORY_SEQUENCE.CLEARD_FLAG_MISSIONS_AFTER_WHITE_MAMBA then
		return true
	end
	return false
end
function this.StartPandemicEvent()
	if gvars.trm_donePandemicEvent then
		return
	end
	if not TppMotherBaseManagement.IsPandemicEventMode()then
		TppUiCommand.RequestMbDvcOpenCondition{isTopModeMotherBase=true}
		TppMotherBaseManagement.StartPandemicEventMode()
	end
end
function this.IsNeedStartPandemicTutorial()
	if not TppMotherBaseManagement.IsPandemicEventMode()then
		return false
	end
	if gvars.trm_donePandemicEvent then
		return false
	end
	if gvars.trm_donePandemicTutorial then
		return false
	end
	return true
end
function this.FinishPandemicTutorial()
	if gvars.trm_donePandemicTutorial then
		return
	end
	gvars.trm_donePandemicTutorial=true
end
function this.IsPandemicTutorialFinished()
	return gvars.trm_donePandemicTutorial
end
function this.CheckPandemicEventFinish()
	if TppStory.GetCurrentStorySequence()>=TppDefine.STORY_SEQUENCE.CLEARD_METALLIC_ARCHAEA then
		return true
	end
end
function this.FinishPandemicEvent()
	TppMotherBaseManagement.DisableKikongoFirst()
	if gvars.trm_donePandemicEvent then
		return
	end
	if TppMotherBaseManagement.IsPandemicEventMode()then
		TppMotherBaseManagement.EndPandemicEventMode()
		gvars.trm_donePandemicEvent=true
	end
end
function this.UpdatePandemicEventBingoCount()
	local t,e=TppMotherBaseManagement.GetPandemicBingoCount()
	gvars.trm_lastPandemicBingoCount=gvars.trm_currentPandemicBingoCount
	gvars.trm_currentPandemicBingoCount=t
	gvars.trm_currentPandemicRestCount=e
end
function this.GetPandemicBingoCount()
	local e=gvars.trm_lastPandemicBingoCount
	if e<1 then
		e=1
	end
	local t=gvars.trm_currentPandemicBingoCount/e
	local e=gvars.trm_currentPandemicBingoCount+gvars.trm_currentPandemicRestCount
	if e<1 then
		e=1
	end
	local e=gvars.trm_currentPandemicBingoCount/e
	return gvars.trm_currentPandemicBingoCount,t,e
end

--ORIG
local dlcSoldiersUnlock={
	GROUP_A={
		storySequence=TppDefine.STORY_SEQUENCE.CLEARD_TO_MATHER_BASE,
		missionList={10033,10043,10036},
		proceedCount=1,
		privilegeNameList={"RESCUE_HOSTAGE_E20010_001","RESCUE_HOSTAGE_E20010_002","RESCUE_HOSTAGE_E20010_003","RESCUE_HOSTAGE_E20010_004","RESCUE_FRIENDMAN"},
		dlcItem={STAFF_STAFF1_FOX={"STAFF_STAFF1_FOX_01","STAFF_STAFF1_FOX_02"}
		}
	},
	GROUP_B={
		storySequence=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON,
		privilegeNameList={"RESCUE_SP_HOSTAGE","RESCUE_HOSTAGE_E20020_000","RESCUE_HOSTAGE_E20020_001","RESCUE_ENEMY_US_MISSION_TARGET_CENTER000","RESCUE_ENEMY_US_MISSION_TARGET_SQUAD000"},
		dlcItem={STAFF_STAFF2_MSF={"STAFF_STAFF2_MSF_01","STAFF_STAFF2_MSF_02"}
		}
	},
	GROUP_C={
		storySequence=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON,
		missionList={10041,10044,10052,10054},
		proceedCount=2,
		privilegeNameList={"RESCUE_HOSTAGE_E20030_000","RESCUE_HOSTAGE_E20030_001","RESCUE_HOSTAGE_E20030_002","RESCUE_E20030_BETRAYER","RESCUE_E20030_MASTERMIND"},
		dlcItem={STAFF_STAFF3_DD={"STAFF_STAFF3_DD_01","STAFF_STAFF3_DD_02"}
		}
	},
	GROUP_D={
		storySequence=TppDefine.STORY_SEQUENCE.CLEARD_RESCUE_HUEY,
		privilegeNameList={"RESCUE_HOSTAGE_E20050_000","RESCUE_HOSTAGE_E20050_001","RESCUE_HOSTAGE_E20050_002","RESCUE_HOSTAGE_E20050_003","RESCUE_GENOME_SOILDER_SAVE"},
		dlcItem={STAFF_STAFF4_FOX_HOUND={"STAFF_STAFF4_FOX_HOUND_01","STAFF_STAFF4_FOX_HOUND_02"}
		}
	}
}
function this.AcquirePrivilegeStaff()
	if(vars.missionCode==10030)or(TppMission.IsFOBMission(vars.missionCode))then
		return
	end
	local currentStorySequence=TppStory.GetCurrentStorySequence()
	for group,unlockConditions in pairs(dlcSoldiersUnlock)do
		--r51 NG+ Settings
		if unlockConditions.storySequence<=currentStorySequence or TppTerminal.IsNewGameMode() then
			local a=true
			local n=unlockConditions.missionList
			--r51 NG+ Settings
			if TppTerminal.IsNewGameMode() then
				n=nil
			end
			if n then
				local e=TppStory.GetClearedMissionCount(n)
				if e<unlockConditions.proceedCount then
					a=false
				end
			end
			if a then
				for n,t in ipairs(unlockConditions.privilegeNameList)do
					this.AcquireGzPrivilege(t,this._AcquireGzPrivilegeStaff)
				end
				for t,n in pairs(unlockConditions.dlcItem)do
					local t=DlcItem[t]
					if t then
						this.AcquireDlcItem(t,this._AcquireDlcItemStaff,n)
					end
				end
			end
		end
	end
	gvars.mb_isRecoverd_dlc_staffs=true
end
function this._AcquireGzPrivilegeStaff(t)
	return this._AcquirePrivilegeStaff(t,"fromGZ")
end
function this._AcquireDlcItemStaff(n,t)
	for n,t in ipairs(t)do
		local e=this._AcquirePrivilegeStaff(t,"fromExtra")
		if not e then
			return
		end
	end
	return true
end
function this._AcquirePrivilegeStaff(t,n)
	local t=TppDefine.UNIQUE_STAFF_TYPE_ID[t]
	if not t then
		return
	end
	return this._AddUniqueVolunteerStaff(t,n)
end
function this.AcquirePrivilegeInTitleScreen()
	this.AcquireGzPrivilegeKeyItem()
	this.AcquireDlcItemKeyItem()
	this.AcquireDlcItemEmblem()
end
function this.AcquireGzPrivilegeKeyItem()
	local t={SAVEDATA_EXIST=t.EXTRA_4011,CLEAR_MISSION_20060=t.EXTRA_4012}
	local function n(e)
		local e=t[e]
		TppMotherBaseManagement.DirectAddDataBase{dataBaseId=e,isNew=true}
		return true
	end
	for t,a in pairs(t)do
		this.AcquireGzPrivilege(t,n)
	end
	--RETAILPATCH 1.10>
	if TppMotherBaseManagement.IsGotDataBase{dataBaseId=TppMotherBaseManagementConst.EXTRA_4011}then
		TppMotherBaseManagement.DirectAddDataBase{dataBaseId=TppMotherBaseManagementConst.EXTRA_6000,isNew=false}
	end
	--<
end
function this.AcquireDlcItemKeyItem()
	local dlcKeyItemsTable={
		WEAPON_MACHT_P5_WEISS=t.EXTRA_4000,
		WEAPON_RASP_SB_SG_GOLD=t.EXTRA_4001,
		WEAPON_PB_SHIELD_SIL=t.EXTRA_4002,
		WEAPON_PB_SHIELD_OD=t.EXTRA_4003,
		WEAPON_PB_SHIELD_WHT=t.EXTRA_4004,
		WEAPON_PB_SHIELD_GLD=t.EXTRA_4005,
		ITEM_CBOX_APD=t.EXTRA_4006,
		ITEM_CBOX_RT=t.EXTRA_4007,
		ITEM_CBOX_WET=t.EXTRA_4008,
		SUIT_FATIGUES_APD=t.EXTRA_4015,
		SUIT_FATIGUES_GRAY_URBAN=t.EXTRA_4016,
		SUIT_FATIGUES_BLUE_URBAN=t.EXTRA_4017,
		SUIT_FATIGUES_BLACK_OCELOT=t.EXTRA_4018,
		WEAPON_ADAM_SKA_SP=t.EXTRA_4024,
		WEAPON_WU_S333_CB_SP=t.EXTRA_4025,
		SUIT_MGS3_NORMAL=t.EXTRA_4019,
		SUIT_MGS3_SNEAK=t.EXTRA_4022,
		SUIT_MGS3_TUXEDO=t.EXTRA_4023,
		SUIT_THE_BOSS=t.EXTRA_4026,
		SUIT_EVA=t.EXTRA_4027,
		HORSE_WESTERN=t.EXTRA_4028,
		HORSE_PARADE=t.EXTRA_4009,
		ARM_GOLD=t.EXTRA_6000 --RETAILPATCH 1.10>
	}
	local function direcAddDLCKeyItem(dlcItem,keyIndex)
		local dlcKeyItem=dlcKeyItemsTable[keyIndex]
		TppMotherBaseManagement.DirectAddDataBase{dataBaseId=dlcKeyItem,isNew=true}
		return true
	end
	local function isXboxExclusiveDLC(a,keyIndex) --rX46 Never called?
		local platformName=Fox.GetPlatformName()
		local dlcKeyItem=dlcKeyItemsTable[keyIndex]
		if platformName=="Xbox360"or platformName=="XboxOne"then
			if((dlcKeyItem==t.EXTRA_4025)or(dlcKeyItem==t.EXTRA_4003))or(dlcKeyItem==t.EXTRA_4008)then
				return false
			end
		end
		TppMotherBaseManagement.DirectRemoveDataBase{dataBaseId=dlcKeyItem}
		return true
	end
	for keyIndex,dlcKeyItem in pairs(dlcKeyItemsTable)do
		local dlcItem=DlcItem[keyIndex]
		if dlcItem then
			this.EraseDlcItem(dlcItem,isXboxExclusiveDLC,keyIndex)
			this.AcquireDlcItem(dlcItem,direcAddDLCKeyItem,keyIndex)
		end
	end
end
function this.AcquireDlcItemEmblem()
	local t={EMBLEM_FRONT_VENOM_SNAKE="front85"}
	local function r(t,e)
		return TppEmblem.Add(e)
	end
	local function a(t,e)
		return TppEmblem.Remove(e)
	end
	for t,n in pairs(t)do
		local t=DlcItem[t]
		if t then
			this.EraseDlcItem(t,a,n)
			this.AcquireDlcItem(t,r,n)
		end
	end
end
function this.AcquireGzPrivilege(e,t)
	if not TppUiCommand.CheckGzSaveDataFlag(e)then
		return
	end
	if TppUiCommand.CheckGzPrivilegeAcquiredFlag(e) and gvars.mb_isRecoverd_dlc_staffs then
		return
	end
	if not Tpp.IsTypeFunc(t)then
		return
	end
	local t=t(e)
	if t then
		TppUiCommand.SetGzPrivilegeAcquired(e)
	end
end
function this.AcquireDlcItem(dlcItem,funcToAddDLC,keyIndex)
	if not TppUiCommand.CheckDlcFlag(dlcItem)then
		return
	end
	if TppUiCommand.CheckDlcAcquiredFlag(dlcItem)then
		return
	end
	if not Tpp.IsTypeFunc(funcToAddDLC)then
		return
	end
	local t=funcToAddDLC(dlcItem,keyIndex)
	if true then
		TppUiCommand.SetDlcAcquired(dlcItem)
	end
end
function this.EraseDlcItem(dlcItem,funcToRemoveDLC,keyIndex)
	if not TppUiCommand.CheckDlcAcquiredFlag(dlcItem)then
		return
	end
	if TppUiCommand.CheckDlcFlag(dlcItem)then
		return
	end
	if not Tpp.IsTypeFunc(funcToRemoveDLC)then
		return
	end
	local t=true
	if t then
		TppUiCommand.ResetDlcAcquired(dlcItem)
	end
end
local n={[t.STAFF_UNIQUE_TYPE_ID_OCELOT]=TppDefine.STORY_SEQUENCE.CLEARD_TO_MATHER_BASE,[t.STAFF_UNIQUE_TYPE_ID_MILLER]=TppDefine.STORY_SEQUENCE.CLEARD_TO_MATHER_BASE,[t.STAFF_UNIQUE_TYPE_ID_HEUY]=TppDefine.STORY_SEQUENCE.CLEARD_RESCUE_HUEY,[t.STAFF_UNIQUE_TYPE_ID_CODE_TALKER]=TppDefine.STORY_SEQUENCE.CLEARD_METALLIC_ARCHAEA}
function this.AddUniqueCharactor()
	local t=TppStory.GetCurrentStorySequence()
	for e,n in pairs(n)do
		if n<=t then
			local e=TppMotherBaseManagement.GenerateStaffParameter{staffType="Unique",uniqueTypeId=e}
			if not TppMotherBaseManagement.IsExistStaff{staffId=e}then
				TppMotherBaseManagement.DirectAddStaff{staffId=e}
			end
		end
	end
end
function this.GetFobStatus()
	if gvars.ini_isTitleMode then
		return
	end
	TppServerManager.GetFobStatus()
end
function this.OnNoticeFobSneaked(t,n)
	if this.IsDisableNoticeFobSneaked()then
		return
	end
	local n={[FobMode.MODE_ACTUAL]="fobNoticeIntruder",[FobMode.MODE_SHAM]="fobReqPractice",[FobMode.MODE_VISIT]="fobVisitFob"}
	local t=n[t]
	if t then
		TppMotherBaseManagement.SetMyFobEmergency{emergency=true}
		this.ShowNoticeFobSneaked(t)
	end
end
function this.OnNoticeSupporterFobSneaked()
	if this.IsDisableNoticeFobSneaked()then
		return
	end
	TppMotherBaseManagement.SetFollowerFobEmergency{emergency=true}
	this.ShowNoticeFobSneaked"fobReqHelp"end
function this.IsDisableNoticeFobSneaked()
	local e=false
	local n={[10010]=true,[10030]=true,[10115]=true,[10150]=true,[10151]=true,[10240]=true,[10260]=true,[10280]=true,[11151]=true}
	local t=vars.missionCode
	if n[t]and(not TppStory.IsMissionCleard(t))then
		e=true
	end
	if TppMission.IsFOBMission(t)then
		e=true
	end
	if gvars.ini_isTitleMode then
		e=true
	end
	return e
end
function this.ShowNoticeFobSneaked(e)
	TppUI.ShowEmergencyAnnounceLog(true)
	TppUiCommand.ShowMissionIcon("urgent_time",6,TppUI.ANNOUNCE_LOG_TYPE[e])

	--ABANDONED rX42 MB on alert if FOB sneaked
	-- routes for caution/evasion/alert missing right
	--  if TppMission.IsMbFreeMissions(vars.missionCode) then
	--    if mvars.ene_soldierDefine then
	--      for cpName, soldierNameList in pairs(mvars.ene_soldierDefine) do
	--        local cpId=GameObject.GetGameObjectId("TppCommandPost2", cpName)
	--        local command={id="SetPhase",phase=TppGameObject.PHASE_CAUTION} --soldiers stop following routes, no announcement by CP
	----        local command={id="SetPhase",phase=TppGameObject.PHASE_EVASION} --soldiers get into cover and hold position, CP announces someone as missing
	--        GameObject.SendCommand(cpId,command)
	--      end
	--    end
	--    TUPPMLog.Log("Set alert")
	--  end

end
function this.OnAllocate(e)
	mvars.trm_fultonInfo={}
end
function this.Init(t)
	TppClock.RegisterClockMessage("TerminalVoiceOnSunSet",TppClock.DAY_TO_NIGHT)
	TppClock.RegisterClockMessage("TerminalVoiceOnSunRise",TppClock.NIGHT_TO_DAY)
	TppClock.RegisterClockMessage("WolfHowl","00:00:00")
	if t.sequence then
		if t.sequence.ALLWAYS_DIRECT_ADD_STAFF then
			mvars.trm_isAlwaysDirectAddStaff=true
		end
		if t.sequence.SKIP_ADD_STAFF_TO_TEMP_BUFFER then
			mvars.trm_isAlwaysDirectAddStaff=true
		end
		if t.sequence.SKIP_ADD_RESOURCE_TO_TEMP_BUFFER then
			mvars.trm_isSkipAddResourceToTempBuffer=true
		end
		if vars.missionCode==30150 or vars.missionCode==30250 then
			mvars.trm_isAlwaysDirectAddStaff=true
			mvars.trm_isSkipAddResourceToTempBuffer=true
		end
	end
	mvars.trm_voiceDisabled=mvars.trm_voiceDisabled or false
	this.SetUp()
	this.ReleaseMbSection()
	this.ReleaseFunctionOfMbSection()
	this.ReleaseFreePlay()
	this.InitNuclearAbolitionCount()
	this.RemoveStaffsAfterS10240()
	TppUiCommand.SetTutorialMode(false)
	TppUiCommand.SetAllInvalidMbSoundControllerVoice(false)
	mvars.trm_EmblemLocatorIdTable={}
	for t,e in pairs(this.EMBLEM_LOCATOR_TABLE)do
		local t=TppCollection.GetUniqueIdByLocatorName(t)
		mvars.trm_EmblemLocatorIdTable[t]=e
	end
	TppUiCommand.ClearMbDvcOpenConditionRequest()
end
function this.MakeMessage()
	this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
end
function this.OnReload(t)
	this.Init(t)
	this.MakeMessage()
end
function this.OnMissionGameStart(e)
	if not mvars.trm_currentIntelCpName then
		TppUiCommand.DeactivateSpySearchForCP()
		TppUiCommand.ActivateSpySearchForField()
	end
end
function this.DeclareSVars()
	return{{name="trm_missionFultonCount",type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MB_MANAGEMENT},{name="trm_isBuddyRecovered",type=TppScriptVars.TYPE_BOOL,arraySize=number4,value=false,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MB_MANAGEMENT},nil}
end
function this.Messages()
	local cpIntelTrapTable=TppEnemy.GetCpIntelTrapTable()
	local trapMessagesTable
	if cpIntelTrapTable and next(cpIntelTrapTable)then
		trapMessagesTable={}

		for a,t in pairs(cpIntelTrapTable)do

			local messageOnEnterCpIntelTrap={
				msg="Enter",
				sender=t,
				func=function(t,t)
					this.OnEnterCpIntelTrap(a)
					if TppSequence.IsMissionPrepareFinished()then
						this.ShowLocationAndBaseTelop()
					end
				end,
				option={isExecMissionPrepare=true}
			}
			table.insert(trapMessagesTable,messageOnEnterCpIntelTrap)

			local messageOnExitCpIntelTrap={
				msg="Exit",
				sender=t,
				func=function(t,t)
					this.OnExitCpIntelTrap(a)
				end,
				option={isExecMissionPrepare=true}
			}
			table.insert(trapMessagesTable,messageOnExitCpIntelTrap)

		end

		table.insert(trapMessagesTable,
			{msg="Enter",
				sender="trap_intel_afgh_waterway_cp",
				func=function(t,t)
					this.SetBaseTelopName"afgh_waterWay_cp"
					if TppSequence.IsMissionPrepareFinished()then
						this.ShowLocationAndBaseTelop()
					end
				end,
				option={isExecMissionPrepare=true}
			})

		table.insert(trapMessagesTable,
			{msg="Exit",
				sender="trap_intel_afgh_waterway_cp",
				func=function(t,t)
					this.ClearBaseTelopName()
				end,
				option={isExecMissionPrepare=true}
			})

		table.insert(trapMessagesTable,
			{msg="Enter",
				sender="trap_intel_afgh_ruins_cp",
				func=function(t,t)
					this.SetBaseTelopName"afgh_ruins_cp"
					if TppSequence.IsMissionPrepareFinished()then
						this.ShowLocationAndBaseTelop()
					end
				end,option={isExecMissionPrepare=true}
			})

		table.insert(trapMessagesTable,
			{msg="Exit",
				sender="trap_intel_afgh_ruins_cp",
				func=function(t,t)
					this.ClearBaseTelopName()
				end,option={isExecMissionPrepare=true}
			})

	end

	return Tpp.StrCode32Table{
		GameObject={
			{msg="Fulton",
				func=function(r,n,t,a)
					if not TppMission.IsFOBMission(vars.missionCode)then
						this.OnFultonMessage(r,n,t,a)
					end
				end,
				option={isExecMissionClear=true,isExecDemoPlaying=true}},
			{msg="FultonInfo",
				func=function(n,t,a)
					if not TppMission.IsFOBMission(vars.missionCode)then
						this.OnFultonInfoMessage(n,t,a)
					end
				end,
				option={isExecMissionClear=true,isExecDemoPlaying=true}},
			{msg="FultonFailedEnd",
				func=this.OnFultonFailedEnd},
			{msg="HeliDoorClosed",
				func=this.OnRecoverByHelicopter,
				option={isExecDemoPlaying=true}},
			{msg="Returned",
				func=this.OnRecoverByHelicopter,
				option={isExecDemoPlaying=true}}
		},
		MotherBaseManagement={
			{msg="AssignedStaff",
				func=function(e,n)
					if(e==t.SECTION_SEPARATION)and(n>0)then
						gvars.trm_doneIsolateByManual=true
						if(TppMission.IsFreeMission(vars.missionCode)or TppMission.IsHelicopterSpace(vars.missionCode))and TppRadio.IsRadioPlayable()then
							TppFreeHeliRadio._PlayRadio(TppFreeHeliRadio.PANDEMIC_RADIO.ON_ISOLATE_STAFF)
						end
					end
				end}
		},
		Weather={
			{msg="WeatherForecast",
				func=this.TerminalVoiceWeatherForecast},
			{msg="Clock",
				sender="TerminalVoiceOnSunSet",
				func=this.TerminalVoiceOnSunSet},
			{msg="Clock",
				sender="TerminalVoiceOnSunRise",
				func=this.TerminalVoiceOnSunRise},
			{msg="Clock",
				sender="WolfHowl",
				func=function()
					if TppLocation.GetLocationName()=="afgh"then
						if not TppMission.IsHelicopterSpace(vars.missionCode)then
							TppSoundDaemon.PostEvent"sfx_s_mdnt_date_cng"
						end
					end
				end}
		},
		Terminal={
			{msg="MbDvcActCallBuddy",
				func=function(e,t)
					TppUI.SetSupportCallBuddyType(e)
					TppUI.ShowCallSupportBuddyAnnounceLog()
				end}
		},
		Trap=trapMessagesTable,
		Network={
			{msg="NoticeSneakMotherBase",
				func=this.OnNoticeFobSneaked},
			{msg="NoticeSneakSupportedMotherBase",
				func=this.OnNoticeSupporterFobSneaked}
		}
	}
end
function this.OnMessage(a,o,_,M,n,r,t)
	Tpp.DoMessage(this.messageExecTable,TppMission.CheckMessageOption,a,o,_,M,n,r,t)
end
function this.OnFultonMessage(e,n,t,a)
	mvars.trm_fultonInfo=mvars.trm_fultonInfo or{}
	mvars.trm_fultonInfo[e]={e,n,t,a}
end
function this.OnFultonInfoMessage(n,a,r)
	mvars.trm_fultonInfo=mvars.trm_fultonInfo or{}
	local t=mvars.trm_fultonInfo[n]
	if t then
		this.OnFulton(t[1],t[2],t[3],t[4],nil,nil,a,r)
		mvars.trm_fultonInfo[n]=nil
	end
	mvars.trm_fultonFaileEndInfo=mvars.trm_fultonFaileEndInfo or{}
	local t=mvars.trm_fultonFaileEndInfo[n]
	if t then
		this._OnFultonFailedEnd(t[1],t[2],t[3],t[4],a)
		mvars.trm_fultonFaileEndInfo[n]=nil
	end
end
function this.SetUp()
	--r51 Settings
	if TUPPMSettings.player_ENABLE_avatarWithoutBeatingM46 then
		--K Enable Avatar from Start
		vars.isAvatarPlayerEnable=1
	end

	--r51 NG+ Settings
	--This check is not over TppTerminal.IsNewGameMode() as we want language interpret to be unlocked from the start
	if TUPPMSettings.newGamePlus_ENABLE then
		--r27 NG+ All language translators unlocked from the start
		vars.isRussianTranslatable=1
		vars.isAfrikaansTranslatable=1
		vars.isKikongoTranslatable=1
		vars.isPashtoTranslatable=1

		--r27 NG+
		--Buddies Unlocked from start
		if TppTerminal.IsNewGameMode() then
			TppBuddyService.SetSortieBuddyType(BuddyType.HORSE)
			TppBuddyService.SetObtainedBuddyType(BuddyType.DOG)
			TppBuddyService.SetSortieBuddyType(BuddyType.DOG)

			local EntrustDdogDemoPlayed=TppDemo.IsPlayedMBEventDemo"EntrustDdog"
			local DdogComeToGetDemoPlayed=TppDemo.IsPlayedMBEventDemo"DdogComeToGet"
			local DdogGoWithMeDemoPlayed=TppDemo.IsPlayedMBEventDemo"DdogGoWithMe"

			if not DdogComeToGetDemoPlayed then
				if TppStory.GetClearedMissionCount{10036,10043,10033}>=2 then
					TppBuddyService.UnsetSortieBuddyType(BuddyType.DOG)
				end
			end

			if not DdogGoWithMeDemoPlayed then
				if TppStory.GetClearedMissionCount{10041,10044,10052,10054}>=3 then
					TppBuddyService.UnsetSortieBuddyType(BuddyType.DOG)
				end
			end

			if not gvars.str_didLostQuiet then
				TppBuddyService.SetObtainedBuddyType(BuddyType.QUIET) --Need to obtain in order to sortie
				TppBuddyService.SetSortieBuddyType(BuddyType.QUIET)
				TppBuddyService.UnsetBuddyCommonFlag(BuddyCommonFlag.BUDDY_QUIET_DYING)
				local quiteMissionRequirements=TppStory.GetClearedMissionCount{10041,10044,10052,10054}

				if TppStory.IsMissionCleard(10050)== false then
					if quiteMissionRequirements>=1 then
						TppBuddyService.UnsetObtainedBuddyType(BuddyType.QUIET)
						TppBuddyService.UnsetSortieBuddyType(BuddyType.QUIET)
						TppBuddyService.UnsetBuddyCommonFlag(BuddyCommonFlag.BUDDY_QUIET_DYING)--Reset Quiet so Mission 11 can begin
					end
				end

				local quietMBVisitComplete=TppQuest.IsCleard"mtbs_q99011"
				local QuietWishGoMissionDemoPlayed=TppDemo.IsPlayedMBEventDemo"QuietWishGoMission"

				TppStory._UpdateS10260OpenFlag() --allow normal opening of SideOps 150; just making sure
				-- Will only set Quiet Lost flag to true once ever
				-- SetUp() function is called after the call for this in TppStory

				local isQuietObtained=TppBuddy2BlockController.DidObtainBuddyType(BuddyType.QUIET)
				local canSortieQuiet=TppBuddyService.CanSortieBuddyType(BuddyType.QUIET)
				local isQuietLost=TppBuddyService.CheckBuddyCommonFlag(BuddyCommonFlag.BUDDY_QUIET_LOST)

			else

				local isQuietObtained=TppBuddy2BlockController.DidObtainBuddyType(BuddyType.QUIET)
				local canSortieQuiet=TppBuddyService.CanSortieBuddyType(BuddyType.QUIET)
				local isQuietLost=TppBuddyService.CheckBuddyCommonFlag(BuddyCommonFlag.BUDDY_QUIET_LOST)

				if isQuietLost then
					TppStory.RequestReunionQuiet()
				end
			end
			vars.mbmMasterGunsmithSkill=1 --this is the key to unlocking weapons customization menu
			--< TppTerminal.IsNewGameMode() check ends here
		end
		--< TUPPMSettings.newGamePlus_ENABLE check ends here
	end


	---Regular function starts here
	if gvars.str_storySequence<=TppDefine.STORY_SEQUENCE.CLEARD_ESCAPE_THE_HOSPITAL then
		local t=TppMission.IsHelicopterSpace(vars.missionCode)
		if t then
			this.SetUpStoryBeforeCleardRescueMillerOnHelicopter()
		else
			this.SetUpStoryBeforeCleardRescueMiller()
		end
	elseif TppTerminal.IsNewGameMode() then
		--r51 NG+ Settings
		this.SetUpStoryAfterCleardPitchDark()
	elseif gvars.str_storySequence<=TppDefine.STORY_SEQUENCE.CLEARD_RECUE_MILLER then
		this.SetUpStoryCleardRescueMiller()
	elseif gvars.str_storySequence<=TppDefine.STORY_SEQUENCE.CLEARD_TO_MATHER_BASE then
		this.SetUpStoryCleardToMotherBase()
	elseif gvars.str_storySequence<=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON then
		this.SetUpStoryCleardHoneyBee()
	elseif gvars.str_storySequence<=TppDefine.STORY_SEQUENCE.CLEARD_DESTROY_THE_FLOW_STATION then
		this.SetUpStoryCleardPitchDark()
	else
		this.SetUpStoryAfterCleardPitchDark()
	end
	if this.IsReleaseSection"Combat"then
		this.EnableDvcMenuByList{{menu=this.MBDVCMENU.MBM_COMBAT,active=true}}
	end
	if this.IsReleaseSection"Security"then
		TppUiStatusManager.UnsetStatus("MbOceanAreaSell","INVALID")
	else
		TppUiStatusManager.SetStatus("MbOceanAreaSell","INVALID")
	end
	--r51 NG+ Settings
	if TppStory.IsMissionCleard(10033) or TppTerminal.IsNewGameMode() then
		TppUiStatusManager.UnsetStatus("CommonTab","BLOCK_ARTIFICIAL_ARM_TAB")
	else
		TppUiStatusManager.SetStatus("CommonTab","BLOCK_ARTIFICIAL_ARM_TAB")
	end
	if gvars.str_storySequence<TppDefine.STORY_SEQUENCE.CLEARD_RECUE_MILLER then
		TppUiStatusManager.SetStatus("MbMotherBaseInfo","INVALID")
		TppUiStatusManager.SetStatus("MbTop","BLOCK_FULTON_VIEW")
		TppUiStatusManager.SetStatus("CommonTab","BLOCK_ANIMAL_TAB")
		TppUiStatusManager.SetStatus("MbPauseHelp","IS_KAZ_MISSION")
	else
		TppUiStatusManager.UnsetStatus("MbMotherBaseInfo","INVALID")
		TppUiStatusManager.UnsetStatus("MbTop","BLOCK_FULTON_VIEW")
		TppUiStatusManager.UnsetStatus("CommonTab","BLOCK_ANIMAL_TAB")
		TppUiStatusManager.UnsetStatus("MbPauseHelp","IS_KAZ_MISSION")
	end
	if gvars.str_storySequence<TppDefine.STORY_SEQUENCE.CLEARD_RESCUE_HUEY then
		TppUiStatusManager.SetStatus("CommonTab","BLOCK_MAFR_TAB")
		TppUiStatusManager.SetStatus("CommonTab","BLOCK_RESOURCE_WALKER_GEAR_TAB")
	else
		TppUiStatusManager.UnsetStatus("CommonTab","BLOCK_MAFR_TAB")
		TppUiStatusManager.UnsetStatus("CommonTab","BLOCK_RESOURCE_WALKER_GEAR_TAB")
	end
	--r51 NG+ Settings
	if gvars.str_storySequence<TppDefine.STORY_SEQUENCE.CLEARD_METALLIC_ARCHAEA and not TppTerminal.IsNewGameMode() then
		TppUiStatusManager.SetStatus("CommonTab","BLOCK_PARASITE_TAB")
		TppUiStatusManager.SetStatus("MbMap","BLOCK_OKB_ZERO")
	else
		TppUiStatusManager.UnsetStatus("CommonTab","BLOCK_PARASITE_TAB")
		TppUiStatusManager.UnsetStatus("MbMap","BLOCK_OKB_ZERO")
	end
	this.SetUpArmsMBDVCMenu()
	this.SetUpBuddyMBDVCMenu()
	this.SetUpCustomWeaponMBDVCMenu()
	if TppMission.IsSubsistenceMission()then
		this.EnableDvcMenuByList{{menu=this.MBDVCMENU.MSN_DROP,active=false},{menu=this.MBDVCMENU.MSN_BUDDY,active=false},{menu=this.MBDVCMENU.MSN_ATTACK,active=false},{menu=this.MBDVCMENU.MSN_HELI_ATTACK,active=false}}
		TppUiStatusManager.SetStatus("Subjective","SUPPORT_NO_USE")
	else
		TppUiStatusManager.UnsetStatus("Subjective","SUPPORT_NO_USE")
	end
end
function this.SetUpArmsMBDVCMenu()
	if this.IsOpenMBDvcArmsMenu()then
		this.EnableDvcMenuByList{{menu=this.MBDVCMENU.MBM_DEVELOP_ARMS,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_ARMS,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_ARMS_HELI,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_ARMS_VEHICLE,active=true}}
	end
end
function this.SetUpCustomWeaponMBDVCMenu()
	--r51 NG+ Settings
	if gvars.str_storySequence<TppDefine.STORY_SEQUENCE.CLEARD_DESTROY_THE_FLOW_STATION and not TppTerminal.IsNewGameMode() then
		return
	end
	do
		this.EnableDvcMenuByList{{menu=this.MBDVCMENU.MBM_CUSTOM_WEAPON,active=true}}
	end
end
function this.SetUpBuddyMBDVCMenu()
	--r51 NG+ Settings
	if gvars.str_storySequence<=TppDefine.STORY_SEQUENCE.CLEARD_RECUE_MILLER and not TppTerminal.IsNewGameMode() then
		return
	end
	this.EnableDvcMenuByList{{menu=this.MBDVCMENU.MSN_BUDDY,active=true}}
	this.EnableDvcMenuByList{{menu=this.MBDVCMENU.MSN_BUDDY_EQUIP,active=true}}
	local buddies={HORSE=BuddyType.HORSE,DDOG=BuddyType.DOG,QUIET=BuddyType.QUIET,WALKER_GEAR=BuddyType.WALKER_GEAR,BATTLE_GEAR=BuddyType.BATTLE_GEAR}
	for type,buddy in pairs(buddies)do
		--r51 NG+ Settings
		local canSortieBuddy=TppBuddyService.CanSortieBuddyType(buddy) or TppTerminal.IsNewGameMode()
		-- or TppMission.IsMbFreeMissions(vars.missionCode) --rX5 Enable buddies on MB, doesn't do anything
		if canSortieBuddy then
			local t=this.BUDDY_MB_DVC_MENU[buddy]
			if t then
				this.EnableDvcMenuByList(t)
			end
		end
	end
end
function this.DoFuncByFultonTypeSwitch(e,n,r,a,o,t,M,_,E,i,u,s,p,T,S,d,l,c)
	if Tpp.IsSoldier(e)then
		return _(e,n,r,a,o,t)
	elseif Tpp.IsVolgin(e)then
		return E(e)
	elseif Tpp.IsHostage(e)then
		return i(e,n,r,a,o,t)
	elseif Tpp.IsVehicle(e)then
		return u(e,n,r,a,nil,t)
	elseif Tpp.IsFultonContainer(e)then
		return s(e,n,r,a,nil,t,M)
	elseif Tpp.IsFultonableGimmick(e)then
		return p(e,n,r,a,nil,t)
	elseif Tpp.IsEnemyWalkerGear(e)then
		return S(e,n,r,a,nil,t)
	elseif Tpp.IsAnimal(e)then
		return d(e,n,r,a,nil,t)
	elseif Tpp.IsBossQuiet(e)then
		return l(e,n,r,a,o,t)
	elseif Tpp.IsParasiteSquad(e)then
		return c(e,n,r,a,nil,t)
	else
		local o=Tpp.GetBuddyTypeFromGameObjectId(e)
		if o then
			return T(e,n,r,a,o,t)
		end
	end
end
function this.OnFulton(t,n,r,a,M,_,o,i)
	if _ then
		mvars.trm_needHeliSoundOnAddStaffsFromTempBuffer=true
	end
	TppEnemy.SetRecovered(t)
	TppEnemy.ExecuteOnRecoveredCallback(t,n,r,a,M,_,o)
	if Tpp.IsLocalPlayer(o)then
		TppEnemy._OnFulton(t,n,r,a)
	end
	this.DoFuncByFultonTypeSwitch(t,n,r,a,M,o,i,this.OnFultonSoldier,this.OnFultonVolgin,this.OnFultonHostage,this.OnFultonVehicle,this.OnFultonContainer,this.OnFultonGimmickCommon,this.OnFultonBuddy,this.OnFultonEnemyWalkerGear,this.OnFultonAnimal,this.OnFultonBossQuiet,this.OnFultonParasiteSquad)
end
function this.IncrementFultonCount()svars.trm_missionFultonCount=svars.trm_missionFultonCount+1
end
function this.GetMissionHumanFultonCount()
	return svars.trm_missionFultonCount
end
function this.IncrementRecoveredSoldierCount()
	gvars.trm_recoveredSoldierCount=gvars.trm_recoveredSoldierCount+1
	this.GetFultonCountKeyItem()
	TppChallengeTask.RequestUpdate"PLAY_RECORD"end
function this.GetRecoveredSoldierCount()
	return gvars.trm_recoveredSoldierCount
end
function this.IncrementRecoveredHostageCount()
	gvars.trm_recoveredHostageCount=gvars.trm_recoveredHostageCount+1
	this.GetFultonCountKeyItem()
	TppChallengeTask.RequestUpdate"PLAY_RECORD"end
function this.GetRecoveredHostageCount()
	return gvars.trm_recoveredHostageCount
end
function this.GetFultonCountKeyItem()
	local n=gvars.trm_recoveredSoldierCount+gvars.trm_recoveredHostageCount
	if n>=number500 then
		this.AcquireKeyItem{dataBaseId=t.DESIGN_3006,isShowAnnounceLog=true}
	end
	if n>=number1e3 then
		this.AcquireKeyItem{dataBaseId=t.DESIGN_3005,isShowAnnounceLog=true}
	end
end
function this.IsEqualOrMoreTotalFultonCount(e)
	local t=gvars.trm_recoveredSoldierCount+gvars.trm_recoveredHostageCount
	if(t>=e)then
		return true
	else
		return false
	end
end
function this.OnFultonSoldier(t,a,a,r,n,o)
	if n then
		local e={id="SetToHeliRecoveredComplete"}
		GameObject.SendCommand(t,e)
	end
	local M=TppMotherBaseManagement.GetTempStaffStatusFromGameObject{gameObjectId=t}
	local a
	if r then
		a=r
	else
		a=TppMotherBaseManagement.GetStaffIdFromGameObject{gameObjectId=t}
	end
	if Tpp.IsLocalPlayer(o)then
		TppHero.OnFultonSoldier(t,n)
		this.IncrementFultonCount()
		if not n then
			this.IncrementRecoveredSoldierCount()
			local e=TppEnemy.GetSoldierType(t)
			if e~=EnemyType.TYPE_DD then
				TppTrophy.Unlock(29)
			end
		end
		PlayRecord.RegistPlayRecord"SOLDIER_RESCUE"Tpp.IncrementPlayData"totalRescueCount"
		--> Patch 1090
		TppUI.UpdateOnlineChallengeTask{detectType=2,diff=1}
		--<
	end
	this.AddTempStaffFulton{staffId=a,gameObjectId=t,tempStaffStatus=M,fultonedPlayer=o}
end
function this.OnFultonVolgin(e)
	if mvars.trm_isSkipAddResourceToTempBuffer then
		return
	end
	TppMotherBaseManagement.AddTempCorpse()
end
function this.OnFultonHostage(t,n,n,r,a,o)
	local M=TppMotherBaseManagement.GetTempStaffStatusFromGameObject{gameObjectId=t}
	local n
	if r then
		n=r
	else
		n=TppMotherBaseManagement.GetStaffIdFromGameObject{gameObjectId=t}
	end
	if Tpp.IsLocalPlayer(o)then
		TppHero.OnFultonHostage(t,a)
		this.IncrementFultonCount()
		if not a then
			this.IncrementRecoveredHostageCount()
		end
		PlayRecord.RegistPlayRecord"HOSTAGE_RESCUE"Tpp.IncrementPlayData"totalRescueCount"local e=GameObject.SendCommand(t,{id="IsFemale"})
		if e then
			TppTrophy.Unlock(31)
		end
		--> Patch 1090
		TppUI.UpdateOnlineChallengeTask{detectType=3,diff=1}
		--<
	end
	this.AddTempStaffFulton{staffId=n,gameObjectId=t,tempStaffStatus=M,fultonedPlayer=o}
end
function this.OnFultonVehicle(t,r,r,a,r,n)
	if mvars.trm_isSkipAddResourceToTempBuffer then
		return
	end
	this.AddTempResource(a,nil,n)
	--> Patch 1090
	if OnlineChallengeTask then
		OnlineChallengeTask.UpdateOnFultonVehicle(t)
	end
	--< Patch 1090
end
function this.OnFultonContainer(o,t,n,M,M,a,alreadyExtractedThisContainer)
	if mvars.trm_isSkipAddResourceToTempBuffer then
		return
	end
	if TppMission.IsFOBMission(vars.missionCode)then
		if not this.CheckAddTempBuffer(a)then
			return
		end
		local e,t,n=MotherBaseConstructConnector.GetContainerResourceId(t,n)
		if e==nil then
			e=0
		end
		TppMotherBaseManagement.AddTempResource{resourceId=e,count=1,visual=t,owner=n}
	else
		local containerId=TppGimmick.GetGimmickID(o,t,n)
		if not containerId then
			containerId="commFacility_cntn001"
		end
		local reduceResourceCount=false
		if(alreadyExtractedThisContainer==1)then
			reduceResourceCount=true
		end
		
		--r51 Settings
		if TUPPMSettings.res_ENABLE_doNotReduceFultonedContainerResources then
			reduceResourceCount=false --r22 Always false so resource container amounts are never reduced on multiple extractions; for example Mission 12 Hellbound; got this ryt on first attempt lol
			--    TUPPMLog.Log("alreadyExtractedThisContainer: "..tostring(alreadyExtractedThisContainer)) --WIP
			--    TUPPMLog.Log("containerName: "..tostring(containerId)) --WIP
			--    TUPPMLog.Log("reduceResourceCount: "..tostring(reduceResourceCount))
		end
		
		Gimmick.CallFindContainerResourceLog(containerId,reduceResourceCount)
		TppMotherBaseManagement.AddTempGimmickResource{gimmickName=containerId,reduceAmount=reduceResourceCount} --r22 max can only be 10k :/
	end
end
this.GIMMICK_RESOURCE_ID_TABLE={[1845465265]=t.RESOURCE_ID_EMPLACEMENT_GUN_EAST,[2207998916]=t.RESOURCE_ID_EMPLACEMENT_GUN_WEST,[1187982616]=t.RESOURCE_ID_MORTAR_NORMAL,[3601635493]=t.RESOURCE_ID_ANTI_AIR_GATLING_GUN_EAST,[20562949]=t.RESOURCE_ID_ANTI_AIR_GATLING_GUN_WEST}
function this.OnFultonGimmickCommon(n,n,n,a,n,t)
	if mvars.trm_isSkipAddResourceToTempBuffer then
		return
	end
	local n=this.GIMMICK_RESOURCE_ID_TABLE[a]
	if n then
		this.AddTempResource(n,nil,t)
	else
		this.AddTempResource(a,nil,t)
	end
end
function this.OnFultonBuddy(t,t,t,t,e,t)
	if mvars.trm_isSkipAddResourceToTempBuffer then
		return
	end
	svars.trm_isBuddyRecovered[e]=true
	if e==BuddyType.QUIET then
		TppMotherBaseManagement.AddTempBuddy()
	end
	if e==BuddyType.DOG then
		TppMotherBaseManagement.AddTempPuppy()
	end
end
function this.OnFultonEnemyWalkerGear(n,n,n,t,n,n)
	if mvars.trm_isSkipAddResourceToTempBuffer then
		return
	end
	this.AddTempResource(t)
	--> Patch 1090
	TppUI.UpdateOnlineChallengeTask{detectType=8,diff=1}
	--< Patch 1090
end
function this.OnFultonAnimal(a,n)
	if mvars.trm_isSkipAddResourceToTempBuffer then
		return
	end
	local n=TppAnimal.GetDataBaseIdFromAnimalId(n)
	if this.IsAnimalDog(n)then
		this.AddAnimalRecoverHistory(t.ANIMAL_TYPE_DOG)
	elseif this.IsAnimalHorse(n)then
		this.AddAnimalRecoverHistory(t.ANIMAL_TYPE_HORSE)
	elseif this.IsAnimalBear(n)then
		this.AddAnimalRecoverHistory(t.ANIMAL_TYPE_BEAR)
	elseif this.IsAnimalGoat(n)then
		this.AddAnimalRecoverHistory(t.ANIMAL_TYPE_GOAT)
	else
		local t=0
		this.AddAnimalRecoverHistory(t)
	end
	local a=TppMotherBaseManagement.DataBaseIdToAnimalGroup{dataBaseId=n}
	if(a==t.ANIMAL_GROUP_1900)or(a==t.ANIMAL_GROUP_1920)then
		gvars.trm_recoveredAfghGoatCount=gvars.trm_recoveredAfghGoatCount+1
	elseif(a==t.ANIMAL_GROUP_1940)or(a==t.ANIMAL_GROUP_1960)then
		gvars.trm_recoveredMafrGoatCount=gvars.trm_recoveredMafrGoatCount+1
	elseif(n==t.ANIMAL_200)then
		gvars.trm_recoveredDonkeyCount=gvars.trm_recoveredDonkeyCount+1
	elseif(n==t.ANIMAL_210)then
		gvars.trm_recoveredZebraCount=gvars.trm_recoveredZebraCount+1
	elseif(n==t.ANIMAL_220)then
		gvars.trm_recoveredOkapiCount=gvars.trm_recoveredOkapiCount+1
	end
	PlayRecord.RegistPlayRecord"ANIMAL_RESCUE"this.AddTempDataBaseAnimal(n,tostring(mvars.animalBlockAreaName))
end
function this.GetRecoveredAfghGoatCount()
	return gvars.trm_recoveredAfghGoatCount
end
function this.GetRecoveredMafrGoatCount()
	return gvars.trm_recoveredMafrGoatCount
end
function this.GetRecoveredDonkeyCount()
	return gvars.trm_recoveredDonkeyCount
end
function this.GetRecoveredZebraCount()
	return gvars.trm_recoveredZebraCount
end
function this.GetRecoveredOkapiCount()
	return gvars.trm_recoveredOkapiCount
end
function this.IsRecoveredCompleatedGoat()
	return(((((((((TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1900}or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1901})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1902})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1903})and(((TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1910}or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1911})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1912})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1913}))and(((TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1920}or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1921})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1922})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1923}))and(((TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1930}or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1931})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1932})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1933}))and(((((((TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1940}or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1941})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1942})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1943})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1944})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1945})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1946})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1947}))and(((((((TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1950}or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1951})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1952})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1953})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1954})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1955})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1956})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1957}))and(((((((TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1960}or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1961})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1962})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1963})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1964})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1965})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1966})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1967}))and(((((((TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1970}or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1971})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1972})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1973})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1974})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1975})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1976})or TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_1977})
end
function this.IsRecoveredCompleatedHorse()
	return(TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_200}and TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_210})and TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_220}
end
function this.IsRecoveredCompleatedDog()
	return(TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_100}and TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_110})and TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_120}
end
function this.IsRecoveredCompleatedBear()
	return TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_600}and TppMotherBaseManagement.IsGotDataBase{dataBaseId=t.ANIMAL_610}
end
function this.GetAnimalTypeCountFromRecoveredHistory(t)
	local e=0
	for n=0,(TppDefine.MAX_ANIMAL_RECOVERED_HISTORY_SIZE-1)do
		if gvars.trm_animalRecoverHistory[n]==t then
			e=e+1
		end
	end
	return e
end
function this.AddAnimalRecoverHistory(t)
	local e=gvars.trm_animalRecoverHistorySize
	if e<TppDefine.MAX_ANIMAL_RECOVERED_HISTORY_SIZE then
		gvars.trm_animalRecoverHistory[e]=t
		gvars.trm_animalRecoverHistorySize=e+1
	else
		for e=1,(TppDefine.MAX_ANIMAL_RECOVERED_HISTORY_SIZE-1)do
			gvars.trm_animalRecoverHistory[e-1]=gvars.trm_animalRecoverHistory[e]
		end
		gvars.trm_animalRecoverHistory[TppDefine.MAX_ANIMAL_RECOVERED_HISTORY_SIZE-1]=t
		gvars.trm_animalRecoverHistorySize=TppDefine.MAX_ANIMAL_RECOVERED_HISTORY_SIZE
	end
end
function this.OnFultonBossQuiet(t,t,t,t)
	local t=SendCommand({type="TppBossQuiet2"},{id="GetQuietType"})
	local t=this.parasiteSquadFultonResouceId[t]
	if t then
		this._OnFultonParasiteSquad(t)
	end
end
function this.OnFultonParasiteSquad(t,n,n,n)
	local t=SendCommand(t,{id="GetParasiteType"})
	local t=this.parasiteSquadFultonResouceId[t]
	if t then
		this._OnFultonParasiteSquad(t)
	end
end
function this._OnFultonParasiteSquad(t)
	local t,n=t[1],t[2]
	this.AddTempResource(t,n)
	TppHero.SetAndAnnounceHeroicOgrePoint(TppHero.FULTON_PARASITE)
end
function this.IsAnimalDog(e)
	return TppMotherBaseManagement.IsAnimalType{dataBaseId=e,animalType=t.ANIMAL_TYPE_DOG}
end
function this.IsAnimalHorse(e)
	return TppMotherBaseManagement.IsAnimalType{dataBaseId=e,animalType=t.ANIMAL_TYPE_HORSE}
end
function this.IsAnimalBear(e)
	return TppMotherBaseManagement.IsAnimalType{dataBaseId=e,animalType=t.ANIMAL_TYPE_BEAR}
end
function this.IsAnimalGoat(e)
	return TppMotherBaseManagement.IsAnimalType{dataBaseId=e,animalType=t.ANIMAL_TYPE_GOAT}
end
function this.OnRecoverByHelicopter()
	TppHelicopter.SetNewestPassengerTable()
	this.OnRecoverByHelicopterAlreadyGetPassengerList()
	TppHelicopter.ClearPassengerTable()
end
function this.OnRecoverByHelicopterOnCheckPoint()
	TppHelicopter.SetNewestPassengerTable()
	local t=TppHelicopter.GetPassengerlist()
	if t then
		TppHelicopter.ForcePullOut()
	end
	this.OnRecoverByHelicopterAlreadyGetPassengerList()
	TppHelicopter.ClearPassengerTable()
end
function this.OnRecoverByHelicopterAlreadyGetPassengerList()
	local t=TppHelicopter.GetPassengerlist()
	if t==nil then
		TppHelicopter.ClearPassengerTable()
		return
	end
	for n,t in ipairs(t)do
		if not Tpp.IsPlayer(t)then
			this.OnFulton(t,nil,nil,nil,true,false,PlayerInfo.GetLocalPlayerIndex())
		end
	end
end
function this.CheckAddTempBuffer(e)
	if TppMission.IsFOBMission(vars.missionCode)then
		if TppServerManager.FobIsSneak()then
			if e==0 then
				return true
			else
				return false
			end
		else
			return false
		end
	else
		return true
	end
end
function this.AddTempStaffFulton(t)
	if mvars.trm_isAlwaysDirectAddStaff~=true then
		local n=t.fultonedPlayer or 0
		if this.CheckAddTempBuffer(n)then
			TppMotherBaseManagement.AddTempStaffFulton(t)
		end
	end
end
function this.AddTempResource(a,n,t)
	local t=t or 0
	if not this.CheckAddTempBuffer(t)then
		return
	end
	local e=n or 1
	TppMotherBaseManagement.AddTempResource{resourceId=a,count=e}
end
function this.AddTempDataBase(e)
	TppMotherBaseManagement.AddTempDataBase{dataBaseId=e}
end
function this.AddTempDataBaseAnimal(t,e)
	TppMotherBaseManagement.AddTempDataBaseAnimal{dataBaseId=t,areaName=e}
end
local n=4
local n=1.67
function this.AddPickedUpResourceToTempBuffer(t,a)
	if not this.RESOURCE_INFORMATION_TABLE[t]then
		return
	end
	local n=this.RESOURCE_INFORMATION_TABLE[t].resourceName
	local e=this.RESOURCE_INFORMATION_TABLE[t].count
	if TppCollection.IsHerbByType(t)then
		local t=Player.GetRateOfGettingHarb()e=e*t
		TppUI.ShowAnnounceLog("find_plant",a,e)
	end
	if t>=TppCollection.TYPE_POSTER_SOL_AFGN and t<=TppCollection.TYPE_POSTER_MOE_H then
		TppMotherBaseManagement.DirectAddResource{resource=n,count=e,isNew=true}
	else
		TppMotherBaseManagement.AddTempResource{resource=n,count=e}
	end
end
function this.SetUpOnHelicopterSpace()
	this.SetUp()
end
function this.SetUpStoryBeforeCleardRescueMiller()
	this._SetUpDvcMenu{{menu=this.MBDVCMENU.MSN,active=true},{menu=this.MBDVCMENU.MSN_EMERGENCIE_N,active=true},{menu=this.MBDVCMENU.MSN_EMERGENCIE_F,active=true},{menu=this.MBDVCMENU.MSN_LOG,active=true},{menu=this.MBDVCMENU.MBM_REWORD,active=true},{menu=this.MBDVCMENU.MBM_DB_CASSETTE,active=true}}
end
function this.SetUpStoryBeforeCleardRescueMillerOnHelicopter()
	this._SetUpDvcMenu{{menu=this.MBDVCMENU.MSN,active=true},{menu=this.MBDVCMENU.MSN_EMERGENCIE_N,active=true},{menu=this.MBDVCMENU.MSN_EMERGENCIE_F,active=true},{menu=this.MBDVCMENU.MSN_LOG,active=true},{menu=this.MBDVCMENU.MBM_REWORD,active=true},{menu=this.MBDVCMENU.MBM_DB_CASSETTE,active=true}}
end
function this.SetUpStoryCleardRescueMiller()
	this._SetUpDvcMenu{{menu=this.MBDVCMENU.MBM,active=true},{menu=this.MBDVCMENU.MSN,active=true},{menu=this.MBDVCMENU.MBM_REWORD,active=true},{menu=this.MBDVCMENU.MBM_STAFF,active=true},{menu=this.MBDVCMENU.MBM_DEVELOP,active=true},{menu=this.MBDVCMENU.MBM_DEVELOP_WEAPON,active=true},{menu=this.MBDVCMENU.MBM_BASE,active=true},{menu=this.MBDVCMENU.MBM_LOG,active=true},{menu=this.MBDVCMENU.MSN_DROP,active=true},{menu=this.MBDVCMENU.MSN_DROP_BULLET,active=true},{menu=this.MBDVCMENU.MSN_DROP_LOADOUT,active=true},{menu=this.MBDVCMENU.MSN_DROP_VEHICLE,active=true},{menu=this.MBDVCMENU.MSN_HELI,active=true},{menu=this.MBDVCMENU.MSN_HELI_RENDEZVOUS,active=true},{menu=this.MBDVCMENU.MSN_HELI_ATTACK,active=true},{menu=this.MBDVCMENU.MSN_HELI_DISMISS,active=true},{menu=this.MBDVCMENU.MSN_EMERGENCIE_N,active=true},{menu=this.MBDVCMENU.MSN_EMERGENCIE_F,active=true},{menu=this.MBDVCMENU.MSN_LOG,active=true},{menu=this.MBDVCMENU.MSN_LOCATION,active=true},{menu=this.MBDVCMENU.MSN_RETURNMB,active=true},{menu=this.MBDVCMENU.MBM_DB,active=true},{menu=this.MBDVCMENU.MBM_DB_ENCYCLOPEDIA,active=true},{menu=this.MBDVCMENU.MBM_DB_KEYITEM,active=true},{menu=this.MBDVCMENU.MBM_DB_CASSETTE,active=true}}
end
function this.SetUpStoryCleardToMotherBase()
	local t={{menu=this.MBDVCMENU.MBM,active=true},{menu=this.MBDVCMENU.MSN,active=true},{menu=this.MBDVCMENU.MBM_REWORD,active=true},{menu=this.MBDVCMENU.MBM_STAFF,active=true},{menu=this.MBDVCMENU.MBM_DEVELOP,active=true},{menu=this.MBDVCMENU.MBM_DEVELOP_WEAPON,active=true},{menu=this.MBDVCMENU.MBM_BASE,active=true},{menu=this.MBDVCMENU.MBM_BASE_EXPANTION,active=true},{menu=this.MBDVCMENU.MBM_RESOURCE,active=true},{menu=this.MBDVCMENU.MBM_LOG,active=true},{menu=this.MBDVCMENU.MSN_DROP,active=true},{menu=this.MBDVCMENU.MSN_DROP_BULLET,active=true},{menu=this.MBDVCMENU.MSN_DROP_WEAPON,active=true},{menu=this.MBDVCMENU.MSN_DROP_LOADOUT,active=true},{menu=this.MBDVCMENU.MSN_DROP_VEHICLE,active=true},{menu=this.MBDVCMENU.MSN_HELI,active=true},{menu=this.MBDVCMENU.MSN_HELI_RENDEZVOUS,active=true},{menu=this.MBDVCMENU.MSN_HELI_ATTACK,active=true},{menu=this.MBDVCMENU.MSN_HELI_DISMISS,active=true},{menu=this.MBDVCMENU.MSN_EMERGENCIE_N,active=true},{menu=this.MBDVCMENU.MSN_EMERGENCIE_F,active=true},{menu=this.MBDVCMENU.MSN_MISSIONLIST,active=true},{menu=this.MBDVCMENU.MSN_SIDEOPSLIST,active=TppQuest.CanOpenSideOpsList()},{menu=this.MBDVCMENU.MSN_LOG,active=true},{menu=this.MBDVCMENU.MSN_LOCATION,active=true},{menu=this.MBDVCMENU.MSN_RETURNMB,active=true},{menu=this.MBDVCMENU.MBM_DB,active=true},{menu=this.MBDVCMENU.MBM_DB_ENCYCLOPEDIA,active=true},{menu=this.MBDVCMENU.MBM_DB_KEYITEM,active=true},{menu=this.MBDVCMENU.MBM_DB_CASSETTE,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_DESIGN,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_DESIGN_EMBLEM,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_DESIGN_BASE,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_AVATAR,active=true}}
	this._SetUpDvcMenu(t)
end
function this.IsOpenMBDvcArmsMenu()
	--r51 NG+ Settings
	if
		((gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_TO_MATHER_BASE)
		and(TppStory.GetClearedMissionCount{10033,10036,10043}>=1))
		or TppTerminal.IsNewGameMode()
	then
		return true
	else
		return false
	end
end
function this.SetUpStoryCleardHoneyBee()
	local t={{menu=this.MBDVCMENU.MBM,active=true},{menu=this.MBDVCMENU.MSN,active=true},{menu=this.MBDVCMENU.MBM_REWORD,active=true},{menu=this.MBDVCMENU.MBM_STAFF,active=true},{menu=this.MBDVCMENU.MBM_DEVELOP,active=true},{menu=this.MBDVCMENU.MBM_DEVELOP_WEAPON,active=true},{menu=this.MBDVCMENU.MBM_DEVELOP_ARMS,active=true},{menu=this.MBDVCMENU.MBM_BASE,active=true},{menu=this.MBDVCMENU.MBM_BASE_EXPANTION,active=true},{menu=this.MBDVCMENU.MBM_RESOURCE,active=true},{menu=this.MBDVCMENU.MBM_LOG,active=true},{menu=this.MBDVCMENU.MSN_DROP,active=true},{menu=this.MBDVCMENU.MSN_DROP_BULLET,active=true},{menu=this.MBDVCMENU.MSN_DROP_WEAPON,active=true},{menu=this.MBDVCMENU.MSN_DROP_LOADOUT,active=true},{menu=this.MBDVCMENU.MSN_DROP_VEHICLE,active=true},{menu=this.MBDVCMENU.MSN_ATTACK,active=true},{menu=this.MBDVCMENU.MSN_ATTACK_ARTILLERY,active=true},{menu=this.MBDVCMENU.MSN_HELI,active=true},{menu=this.MBDVCMENU.MSN_HELI_RENDEZVOUS,active=true},{menu=this.MBDVCMENU.MSN_HELI_ATTACK,active=true},{menu=this.MBDVCMENU.MSN_HELI_DISMISS,active=true},{menu=this.MBDVCMENU.MSN_EMERGENCIE_N,active=true},{menu=this.MBDVCMENU.MSN_EMERGENCIE_F,active=true},{menu=this.MBDVCMENU.MSN_MISSIONLIST,active=true},{menu=this.MBDVCMENU.MSN_SIDEOPSLIST,active=true},{menu=this.MBDVCMENU.MSN_LOG,active=true},{menu=this.MBDVCMENU.MSN_LOCATION,active=true},{menu=this.MBDVCMENU.MSN_RETURNMB,active=true},{menu=this.MBDVCMENU.MBM_DB,active=true},{menu=this.MBDVCMENU.MBM_DB_ENCYCLOPEDIA,active=true},{menu=this.MBDVCMENU.MBM_DB_KEYITEM,active=true},{menu=this.MBDVCMENU.MBM_DB_CASSETTE,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_DESIGN,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_DESIGN_EMBLEM,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_DESIGN_BASE,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_AVATAR,active=true}}
	this._SetUpDvcMenu(t)
end
function this.SetUpStoryCleardPitchDark()
	this._SetUpDvcMenu{{menu=this.MBDVCMENU.MBM,active=true},{menu=this.MBDVCMENU.MSN,active=true},{menu=this.MBDVCMENU.MBM_REWORD,active=true},{menu=this.MBDVCMENU.MBM_STAFF,active=true},{menu=this.MBDVCMENU.MBM_DEVELOP,active=true},{menu=this.MBDVCMENU.MBM_DEVELOP_WEAPON,active=true},{menu=this.MBDVCMENU.MBM_DEVELOP_ARMS,active=true},{menu=this.MBDVCMENU.MBM_COMBAT,active=true},{menu=this.MBDVCMENU.MBM_BASE,active=true},{menu=this.MBDVCMENU.MBM_BASE_EXPANTION,active=true},{menu=this.MBDVCMENU.MBM_RESOURCE,active=true},{menu=this.MBDVCMENU.MBM_LOG,active=true},{menu=this.MBDVCMENU.MSN_DROP,active=true},{menu=this.MBDVCMENU.MSN_DROP_BULLET,active=true},{menu=this.MBDVCMENU.MSN_DROP_WEAPON,active=true},{menu=this.MBDVCMENU.MSN_DROP_LOADOUT,active=true},{menu=this.MBDVCMENU.MSN_DROP_VEHICLE,active=true},{menu=this.MBDVCMENU.MSN_ATTACK,active=true},{menu=this.MBDVCMENU.MSN_ATTACK_ARTILLERY,active=true},{menu=this.MBDVCMENU.MSN_HELI,active=true},{menu=this.MBDVCMENU.MSN_HELI_RENDEZVOUS,active=true},{menu=this.MBDVCMENU.MSN_HELI_ATTACK,active=true},{menu=this.MBDVCMENU.MSN_HELI_DISMISS,active=true},{menu=this.MBDVCMENU.MSN_EMERGENCIE_N,active=true},{menu=this.MBDVCMENU.MSN_EMERGENCIE_F,active=true},{menu=this.MBDVCMENU.MSN_MISSIONLIST,active=true},{menu=this.MBDVCMENU.MSN_SIDEOPSLIST,active=true},{menu=this.MBDVCMENU.MSN_LOG,active=true},{menu=this.MBDVCMENU.MSN_LOCATION,active=true},{menu=this.MBDVCMENU.MSN_RETURNMB,active=true},{menu=this.MBDVCMENU.MBM_DB,active=true},{menu=this.MBDVCMENU.MBM_DB_ENCYCLOPEDIA,active=true},{menu=this.MBDVCMENU.MBM_DB_KEYITEM,active=true},{menu=this.MBDVCMENU.MBM_DB_CASSETTE,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_DESIGN,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_DESIGN_EMBLEM,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_DESIGN_BASE,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_AVATAR,active=true}}
end
function this.SetUpStoryAfterCleardPitchDark()
	this._SetUpDvcMenu{{menu=this.MBDVCMENU.MBM,active=true},{menu=this.MBDVCMENU.MSN,active=true},{menu=this.MBDVCMENU.MBM_REWORD,active=true},{menu=this.MBDVCMENU.MBM_STAFF,active=true},{menu=this.MBDVCMENU.MBM_DEVELOP,active=true},{menu=this.MBDVCMENU.MBM_DEVELOP_WEAPON,active=true},{menu=this.MBDVCMENU.MBM_DEVELOP_ARMS,active=true},{menu=this.MBDVCMENU.MBM_COMBAT,active=true},{menu=this.MBDVCMENU.MBM_BASE,active=true},{menu=this.MBDVCMENU.MBM_BASE_SECURITY,active=true},{menu=this.MBDVCMENU.MBM_BASE_EXPANTION,active=true},{menu=this.MBDVCMENU.MBM_RESOURCE,active=true},{menu=this.MBDVCMENU.MBM_LOG,active=true},{menu=this.MBDVCMENU.MSN_DROP,active=true},{menu=this.MBDVCMENU.MSN_DROP_BULLET,active=true},{menu=this.MBDVCMENU.MSN_DROP_WEAPON,active=true},{menu=this.MBDVCMENU.MSN_DROP_LOADOUT,active=true},{menu=this.MBDVCMENU.MSN_DROP_VEHICLE,active=true},{menu=this.MBDVCMENU.MSN_ATTACK,active=true},{menu=this.MBDVCMENU.MSN_ATTACK_ARTILLERY,active=true},{menu=this.MBDVCMENU.MSN_ATTACK_SMOKE,active=true},{menu=this.MBDVCMENU.MSN_ATTACK_SLEEP,active=true},{menu=this.MBDVCMENU.MSN_ATTACK_CHAFF,active=true},{menu=this.MBDVCMENU.MSN_ATTACK_WEATHER,active=true},{menu=this.MBDVCMENU.MSN_ATTACK_WEATHER_SANDSTORM,active=true},{menu=this.MBDVCMENU.MSN_ATTACK_WEATHER_STORM,active=true},{menu=this.MBDVCMENU.MSN_ATTACK_WEATHER_CLEAR,active=true},{menu=this.MBDVCMENU.MSN_HELI,active=true},{menu=this.MBDVCMENU.MSN_HELI_RENDEZVOUS,active=true},{menu=this.MBDVCMENU.MSN_HELI_ATTACK,active=true},{menu=this.MBDVCMENU.MSN_HELI_DISMISS,active=true},{menu=this.MBDVCMENU.MSN_EMERGENCIE_N,active=true},{menu=this.MBDVCMENU.MSN_EMERGENCIE_F,active=true},{menu=this.MBDVCMENU.MSN_MISSIONLIST,active=true},{menu=this.MBDVCMENU.MSN_SIDEOPSLIST,active=true},{menu=this.MBDVCMENU.MSN_FOB,active=true},{menu=this.MBDVCMENU.MSN_FRIEND,active=true},{menu=this.MBDVCMENU.MSN_LOG,active=true},{menu=this.MBDVCMENU.MSN_LOCATION,active=true},{menu=this.MBDVCMENU.MSN_RETURNMB,active=true},{menu=this.MBDVCMENU.MBM_DB,active=true},{menu=this.MBDVCMENU.MBM_DB_ENCYCLOPEDIA,active=true},{menu=this.MBDVCMENU.MBM_DB_KEYITEM,active=true},{menu=this.MBDVCMENU.MBM_DB_CASSETTE,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_BUDDY,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_BUDDY_HORSE,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_BUDDY_DOG,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_BUDDY_QUIET,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_BUDDY_WALKER,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_BUDDY_BATTLE,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_DESIGN,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_DESIGN_EMBLEM,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_DESIGN_BASE,active=true},{menu=this.MBDVCMENU.MBM_CUSTOM_AVATAR,active=true}}
end
function this.StopChangeDayTerminalAnnounce()
	mvars.trm_stopChangeDayTerminalAnnounce=true
end
function this.StartChangeDayTerminalAnnounce()
	mvars.trm_stopChangeDayTerminalAnnounce=nil
end
function this.TerminalVoiceWeatherForecast(t)
	local n={[TppDefine.WEATHER.SUNNY]="VOICE_WEATHER_CLAER",[TppDefine.WEATHER.CLOUDY]=nil,[TppDefine.WEATHER.RAINY]=nil,[TppDefine.WEATHER.SANDSTORM]="VOICE_WEATHER_SANDSTORM",[TppDefine.WEATHER.FOGGY]=nil}
	local a={[TppDefine.WEATHER.SUNNY]="weather_sunny",[TppDefine.WEATHER.CLOUDY]="weather_cloudy",[TppDefine.WEATHER.RAINY]="weather_rainy",[TppDefine.WEATHER.SANDSTORM]="weather_sandstorm",[TppDefine.WEATHER.FOGGY]="weather_foggy"}
	local n=n[t]
	local t=a[t]
	if n then
		this.PlayTerminalVoice(n)
	end
	if t then
		TppUI.ShowAnnounceLog(t)
	end
end
function this.TerminalVoiceOnSunSet()
	if mvars.trm_stopChangeDayTerminalAnnounce then
		return
	end
	this.PlayTerminalVoice"VOICE_SUN_SET"TppUI.ShowAnnounceLog"sunset"TppTutorial.DispGuide_Comufrage()
end
function this.TerminalVoiceOnSunRise()
	if mvars.trm_stopChangeDayTerminalAnnounce then
		return
	end
	this.PlayTerminalVoice"VOICE_SUN_RISE"TppUI.ShowAnnounceLog"sunrise"TppTutorial.DispGuide_DayAndNight()
end
function this.TerminalVoiceOnSupportFireIncoming()
	this.PlayTerminalVoice"VOICE_SUPPORT_FIRE_INCOMING"end
function this.SetBaseTelopName(e)
	mvars.trm_baseTelopCpName=e
end
function this.ClearBaseTelopName()
	mvars.trm_baseTelopCpName=nil
end
function this.GetLocationAndBaseTelop()
	return mvars.trm_currentIntelCpName or mvars.trm_baseTelopCpName
end
function this.ShowLocationAndBaseTelop()
	if TppUiCommand.IsStartTelopCast and TppUiCommand.IsStartTelopCast()then
		return
	end
	TppUiCommand.RegistInfoTypingText("location",1)
	local e=this.GetLocationAndBaseTelop()
	if e then
		TppUiCommand.RegistInfoTypingText("cpname",2,e)
	end
	TppUiCommand.ShowInfoTypingText()
end
function this.ShowLocationAndBaseTelopForStartFreePlay()
	TppUiCommand.RegistInfoTypingText("gametime",1)
	TppUiCommand.RegistInfoTypingText("location",2)
	local e=this.GetLocationAndBaseTelop()
	if e then
		TppUiCommand.RegistInfoTypingText("cpname",3,e)
	end
	TppUiCommand.ShowInfoTypingText()
end
function this.ShowLocationAndBaseTelopForContinue()
	if TppMission.IsFreeMission(vars.missionCode)then
		this.ShowLocationAndBaseTelopForStartFreePlay()
	else
		TppUiCommand.RegistInfoTypingText("episode",1)
		TppUiCommand.RegistInfoTypingText("mission",2)
		TppUiCommand.RegistInfoTypingText("gametime",3)
		TppUiCommand.RegistInfoTypingText("location",4)
		local e=this.GetLocationAndBaseTelop()
		if e then
			TppUiCommand.RegistInfoTypingText("cpname",5,e)
		end
		TppUiCommand.ShowInfoTypingText()
	end
end
function this.OnEnterCpIntelTrap(e)
	mvars.trm_currentIntelCpName=e
	TppUiCommand.ActivateSpySearchForCP{cpName=e}
	TppUiCommand.DeactivateSpySearchForField()
	TppFreeHeliRadio.OnEnterCpIntelTrap(e)
	if Player.OnEnterBase~=nil then
		Player.OnEnterBase()
	end
end
function this.OnExitCpIntelTrap(e)
	mvars.trm_currentIntelCpName=nil
	TppUiCommand.DeactivateSpySearchForCP()
	TppUiCommand.ActivateSpySearchForField()
	TppFreeHeliRadio.OnExitCpIntelTrap(e)
	TppRevenge.ClearLastRevengeMineBaseName()
	if Player.OnExitBase~=nil then
		Player.OnExitBase()
	end
end
function this.IsReleaseMedicalSection()
	--r51 NG+ Settings
	if
		((gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON)
		and(TppStory.GetClearedMissionCount{10041,10044,10052,10054}>=1))
		or TppTerminal.IsNewGameMode()
	then
		return true
	else
		return false
	end
end
this.SectionOpenCondition={
	Combat=function()
		--r51 NG+ Settings
		if
			((gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON)
			and(TppStory.GetClearedMissionCount{10041,10044,10052,10054}>=2))
			or TppTerminal.IsNewGameMode()
		then
			return true
		else
			return false
		end
	end,
	BaseDev=function()
		--r51 NG+ Settings
		if
			((gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_TO_MATHER_BASE)
			and(TppStory.GetClearedMissionCount{10033,10036,10043}>=2))
			or TppTerminal.IsNewGameMode()
		then
			return true
		else
			return false
		end
	end,
	Spy=function()
		--r51 NG+ Settings
		if
			(gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON)
			or TppTerminal.IsNewGameMode()
		then
			return true
		else
			return false
		end
	end,
	Medical=this.IsReleaseMedicalSection,
	Security=function()
		--r51 NG+ Settings
		if this.IsCleardRetakeThePlatform() or TppTerminal.IsNewGameMode() then
			return true
		else
			return false
		end
	end,
	Hospital=function()
		if this.IsReleaseMedicalSection()then
			return TppMotherBaseManagement.IsBuiltMbMedicalClusterSpecialPlatform()
		else
			return false
		end
	end,
	Prison=function()
		if gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_TO_MATHER_BASE then
			return true
		else
			return false
		end
	end,
	Separation=function()
		if
			gvars.trm_isPushRewardSeparationPlatform
			and(not this.CheckPandemicEventFinish())
		then
			return true
		else
			return false
		end
	end
}
function this.IsReleaseSection(t)
	local e=this.SectionOpenCondition[t]
	if e then
		return e()
	end
end
function this.ReleaseMbSection()
	for n,t in ipairs(this.MOTHER_BASE_SECTION_LIST)do
		local e=this.IsReleaseSection(t)
		if e~=nil then
			TppMotherBaseManagement.OpenedSection{section=t,opened=e}
		end
	end
end
function this.OpenAllSection()
	for t,e in ipairs(this.MOTHER_BASE_SECTION_LIST)do
		TppMotherBaseManagement.OpenedSection{section=e,opened=true}
	end
end
function this.OnEstablishMissionClear()
	--r51 NG+ Settings
	if
		((gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON)
		and(TppStory.GetClearedMissionCount{10041,10044,10052,10054}>=1))
		or TppTerminal.IsNewGameMode()
	then
		local t=1
		this.ForceStartBuildPlatform("Medical",t)
		this.ForceStartBuildPlatform("Develop",t)
	end
	this.PushRewardOnMbSectionOpen()
	if this.IsBuiltAnimalPlatform()and(not gvars.trm_isPushRewardAnimalPlatform)then
		gvars.trm_isPushRewardAnimalPlatform=true
		TppReward.Push{category=TppScriptVars.CATEGORY_MB_MANAGEMENT,langId="reward_107",rewardType=TppReward.TYPE.COMMON}
	end
	if this.IsReleaseSection"Security"then
		if not gvars.trm_isPushRewardOpenFob then
			gvars.trm_isPushRewardOpenFob=true
			TppReward.Push{category=TppScriptVars.CATEGORY_MB_MANAGEMENT,langId="reward_109",rewardType=TppReward.TYPE.COMMON}
		end
	end
	--r51 NG+ Settings
	if this.IsConstructedFirstFob() or TppTerminal.IsNewGameMode() then
		if not gvars.trm_isPushConstructedFirstFob then
			gvars.trm_isPushConstructedFirstFob=true
			TppReward.Push{category=TppScriptVars.CATEGORY_MB_MANAGEMENT,langId="reward_110",rewardType=TppReward.TYPE.COMMON}
			TppReward.Push{category=TppScriptVars.CATEGORY_MB_MANAGEMENT,langId="reward_111",rewardType=TppReward.TYPE.COMMON}
		end
	end
	--r51 NG+ Settings
	if TppStory.IsMissionCleard(10033) or TppTerminal.IsNewGameMode() then
		if not gvars.trm_isPushRewardCanDevArm then
			gvars.trm_isPushRewardCanDevArm=true
			TppReward.Push{category=TppScriptVars.CATEGORY_MB_MANAGEMENT,langId="reward_300",rewardType=TppReward.TYPE.COMMON}
		end
	end
	if this.IsOpenMBDvcArmsMenu()and(not gvars.trm_isPushRewardOpenMBDvcArmsMenu)then
		gvars.trm_isPushRewardOpenMBDvcArmsMenu=true
		TppReward.Push{category=TppScriptVars.CATEGORY_MB_MANAGEMENT,langId="reward_301",rewardType=TppReward.TYPE.COMMON}
		TppReward.Push{category=TppScriptVars.CATEGORY_MB_MANAGEMENT,langId="reward_302",rewardType=TppReward.TYPE.COMMON}
		TppReward.Push{category=TppScriptVars.CATEGORY_MB_MANAGEMENT,langId="reward_401",rewardType=TppReward.TYPE.COMMON}
	end
	local n=TppStory.GetCurrentStorySequence()
	--r51 NG+ Settings
	if n>=TppDefine.STORY_SEQUENCE.CLEARD_METALLIC_ARCHAEA or TppTerminal.IsNewGameMode() then
		if not gvars.trm_isPushRewardCanDevParasiteSuit then
			gvars.trm_isPushRewardCanDevParasiteSuit=true
			TppReward.Push{category=TppScriptVars.CATEGORY_MB_MANAGEMENT,langId="reward_307",rewardType=TppReward.TYPE.COMMON}
		end
	end
	if vars.mbmMasterGunsmithSkill==1 then
		if not gvars.trm_isPushRewardOpenWeaponCustomize then
			gvars.trm_isPushRewardOpenWeaponCustomize=true
			TppReward.Push{category=TppScriptVars.CATEGORY_MB_MANAGEMENT,langId="reward_400",rewardType=TppReward.TYPE.COMMON}
		end
	end
	if not gvars.trm_isPushRewardCanCustomVehicle then
		if this.HasVehicle()==true then
			gvars.trm_isPushRewardCanCustomVehicle=true
			TppReward.Push{category=TppScriptVars.CATEGORY_MB_MANAGEMENT,langId="reward_402",rewardType=TppReward.TYPE.COMMON}
		end
	end
	--r51 NG+ Settings
	if n>=TppDefine.STORY_SEQUENCE.CLEARD_DESTROY_THE_FLOW_STATION or TppTerminal.IsNewGameMode() then
		TppBuddyService.SetObtainedBuddyType(BuddyType.WALKER_GEAR)
		TppBuddyService.SetSortieBuddyType(BuddyType.WALKER_GEAR)
		if not gvars.trm_isPushRewardCanDevDWalker then
			gvars.trm_isPushRewardCanDevDWalker=true
			TppReward.Push{category=TppScriptVars.CATEGORY_MB_MANAGEMENT,langId="reward_305",rewardType=TppReward.TYPE.COMMON}
			TppReward.Push{category=TppScriptVars.CATEGORY_MB_MANAGEMENT,langId="reward_405",rewardType=TppReward.TYPE.COMMON}
		end
	end
	if TppStory.CanPlayDemoOrRadio"CompliteDevelopBattleGear"or TppStory.GetBattleGearDevelopLevel()==5 then
		if not gvars.trm_isPushRewardBattleGearDevelopComplete then
			gvars.trm_isPushRewardBattleGearDevelopComplete=true
			TppReward.Push{category=TppScriptVars.CATEGORY_MB_MANAGEMENT,langId="reward_115",rewardType=TppReward.TYPE.COMMON}
			TppMotherBaseManagement.SetDeployableBattleGear{deployable=true}
		end
	end
	if this.PandemicTutorialStoryCondition()then
		if not gvars.trm_isPushRewardSeparationPlatform then
			gvars.trm_isPushRewardSeparationPlatform=true
			TppReward.Push{category=TppScriptVars.CATEGORY_MB_MANAGEMENT,langId="reward_112",rewardType=TppReward.TYPE.COMMON}
		end
	end
	--r51 NG+ Settings
	if n>=TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO or TppTerminal.IsNewGameMode() then
		if not gvars.trm_isPushRewardCanDevNuclear then
			gvars.trm_isPushRewardCanDevNuclear=true
			vars.mbmIsEnableNuclearDevelop=1
			TppReward.Push{category=TppScriptVars.CATEGORY_MB_MANAGEMENT,langId="reward_113",rewardType=TppReward.TYPE.COMMON}
		end
	end
	--r51 NG+ Settings
	if TppQuest.IsCleard"mtbs_q99011" or TppTerminal.IsNewGameMode() then
		if not gvars.trm_isPushRewardCanDevQuietEquip then
			TppReward.Push{category=TppScriptVars.CATEGORY_MB_MANAGEMENT,langId="reward_304",rewardType=TppReward.TYPE.COMMON}
			gvars.trm_isPushRewardCanDevQuietEquip=true
		end
		TppEmblem.Add("front9",true,false)
	end
	local buddyCommandsTable={
		BuddyCommand.HORSE_SHIT,
		BuddyCommand.DOG_BARKING,
		BuddyCommand.QUIET_AIM_TARGET,
		BuddyCommand.QUIET_COMBAT_START,
		BuddyCommand.QUIET_SHOOT_THIS
	}
	local buddyCommandsRewardsLangIdsTable={"reward_500","reward_501","reward_502","reward_503","reward_504"}
	for index,buddyCommand in ipairs(buddyCommandsTable)do
		if TppBuddyService.IsEnableBuddyCommand(buddyCommand)then
			local buddyCommandRewardIndex=index-1
			if not gvars.trm_isPushRewardBuddyCommand[buddyCommandRewardIndex]then
				gvars.trm_isPushRewardBuddyCommand[buddyCommandRewardIndex]=true
				local buddyCommandRewardLangId=buddyCommandsRewardsLangIdsTable[index]
				TppReward.Push{category=TppScriptVars.CATEGORY_MB_MANAGEMENT,langId=buddyCommandRewardLangId,rewardType=TppReward.TYPE.COMMON}
			end
		end
	end
	if n>=TppDefine.STORY_SEQUENCE.CLEARD_RESCUE_HUEY then
		TppMotherBaseManagement.EnableStaffInitLangKikongo()
	end
	--r51 NG+ Settings
	if n>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON or TppTerminal.IsNewGameMode() then
		local t={t.DEPLOY_MISSION_ID_SEQ_1001,t.DEPLOY_MISSION_ID_SEQ_1002,t.DEPLOY_MISSION_ID_SEQ_1003,t.DEPLOY_MISSION_ID_SEQ_1004,t.DEPLOY_MISSION_ID_SEQ_1005,t.DEPLOY_MISSION_ID_SEQ_1006,t.DEPLOY_MISSION_ID_SEQ_1007}
		this.OpenDeployMission(t)
	end
	--r51 NG+ Settings
	if n>=TppDefine.STORY_SEQUENCE.CLEARD_RESCUE_HUEY or TppTerminal.IsNewGameMode() then
		local t={t.DEPLOY_MISSION_ID_SEQ_1008,t.DEPLOY_MISSION_ID_SEQ_1009,t.DEPLOY_MISSION_ID_SEQ_1010,t.DEPLOY_MISSION_ID_SEQ_1011}
		this.OpenDeployMission(t)
	end
	--r51 NG+ Settings
	if n>=TppDefine.STORY_SEQUENCE.CLEARD_TAKE_OUT_THE_CONVOY or TppTerminal.IsNewGameMode() then
		local t={t.DEPLOY_MISSION_ID_SEQ_1012}
		this.OpenDeployMission(t)
	end
	--r51 NG+ Settings
	if n>=TppDefine.STORY_SEQUENCE.CLEARD_DEATH_FACTORY or TppTerminal.IsNewGameMode() then
		local t={t.DEPLOY_MISSION_ID_SEQ_1013,t.DEPLOY_MISSION_ID_SEQ_1014}
		this.OpenDeployMission(t)
	end
	if n>=TppDefine.STORY_SEQUENCE.CLEARD_WHITE_MAMBA then
		if not gvars.trm_doneUpdatePandemicLimit then
			gvars.trm_doneUpdatePandemicLimit=true
			TppMotherBaseManagement.UpdatePandemicEventLimit()
		end
	end
	--r51 NG+ Settings
	if n>=TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO or TppTerminal.IsNewGameMode() then
		local t={t.DEPLOY_MISSION_ID_SEQ_1015,t.DEPLOY_MISSION_ID_SEQ_1016,t.DEPLOY_MISSION_ID_SEQ_1017,t.DEPLOY_MISSION_ID_SEQ_1018,t.DEPLOY_MISSION_ID_SEQ_1019,t.DEPLOY_MISSION_ID_SEQ_1020}
		this.OpenDeployMission(t)
	end
	if n>=TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO then
		TppServerManager.StartFobPickup()
	end
	--r51 NG+ Settings
	if n>=TppDefine.STORY_SEQUENCE.CLEARD_THE_TRUTH or TppTerminal.IsNewGameMode() then
		vars.isAvatarPlayerEnable=1
	end
	this.AddUniqueCharactor()
end
function this.AddUniqueVolunteerStaff(n)
	local a={{186},{209},{210,211},{212},{213},{214},{215},{216,217},{218},{187},{185},{188,189,190,191,192,193},{194,195,196,197,198,199}}
	local t={[10033]=1,[10036]=1,[10043]=1,[10080]=2,[10086]=3,[10082]=4,[10091]=5,[10195]=6,[10100]=7,[10110]=8,[10121]=9,[10070]=10,[10090]=11,[10151]=12,[10280]=13}
	local t=t[n]
	if t then
		local t=a[t]
		for n,t in ipairs(t)do
			this._AddUniqueVolunteerStaff(t)
		end
	end
end
function this._AddUniqueVolunteerStaff(e,n)
	if TppMotherBaseManagement.IsExistStaff{uniqueTypeId=e}then
		return
	end
	local t=false
	if n~=nil then
		t=true
	end
	local e=TppMotherBaseManagement.GenerateStaffParameter{staffType="Unique",uniqueTypeId=e}
	TppMotherBaseManagement.DirectAddStaff{staffId=e,section="Wait",isNew=true,specialContract=t}
	TppUiCommand.ShowBonusPopupStaff(e,n)
	return true
end
function this.ForceStartBuildPlatform(e,t)
	local n=TppMotherBaseManagement.GetClusterGrade{base="MotherBase",category=e}
	if n<t then
		local t=TppMotherBaseManagement.GetClusterBuildStatus{base="MotherBase",category=e}
		if t=="Completed"then
			TppMotherBaseManagement.SetClusterSvars{base="MotherBase",category=e,grade=0,buildStatus="Building",timeMinute=0,isNew=true}
		end
	end
end
function this.OpenDeployMission(t)
	for t,e in ipairs(t)do
		TppMotherBaseManagement.SetSequentialMissionIdLimit{deployMissionId=e}
	end
end
this.RewardLangIdTable={Combat={"reward_105","reward_106"},BaseDev={"reward_100","reward_101"},Spy={"reward_102"},Medical={"reward_103"},Security={"reward_108"},Hospital={"reward_104"}}
function this.PushRewardOnMbSectionOpen()
	for a,n in ipairs(this.MOTHER_BASE_SECTION_LIST)do
		local t=this.RewardLangIdTable[n]
		local e=this.IsReleaseSection(n)
		if e~=nil and t then
			if e then
				if not gvars.trm_isPushRewardOpenSection[a]then
					gvars.trm_isPushRewardOpenSection[a]=true
					for t,e in ipairs(t)do
						TppReward.Push{category=TppScriptVars.CATEGORY_MB_MANAGEMENT,langId=e,rewardType=TppReward.TYPE.COMMON}
					end
				end
			end
		end
	end
end
function this.IsCleardRetakeThePlatform()
	--r51 NG+ Settings
	return TppStory.IsMissionCleard(10115)
		--r63 BUGFIX Removed incorrect condition
		--or ( TppTerminal.IsNewGameMode())
end
function this.IsFailedRetakeThePlatform()
	local e=TppStory.GetElapsedMissionCount(TppDefine.ELAPSED_MISSION_EVENT.FAILED_RETAKE_THE_PLATFORM)
	if e==TppDefine.ELAPSED_MISSION_COUNT.INIT then
		return false
	else
		return true
	end
end
function this.CanConstructFirstFob()
	--r51 NG+ Settings
	if gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_DEATH_FACTORY or TppTerminal.IsNewGameMode() then
		if this.IsCleardRetakeThePlatform()then
			return true
		end
	end
	return false
end
function this.IsConstructedFirstFob()
	--r51 NG+ Settings
	if TppTerminal.IsNewGameMode() then
		return true
	end

	if TppMotherBaseManagement.IsBuiltFirstFob then
		return TppMotherBaseManagement.IsBuiltFirstFob()
	else
		return true
	end
end
function this.IsReleaseFunctionBattle()
	--r51 NG+ Settings
	if gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON or TppTerminal.IsNewGameMode() then
		return true
	else
		return false
	end
end
function this.IsReleaseFunctionNuclearDevelop()
	--r51 NG+ Settings
	if gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO or TppTerminal.IsNewGameMode() then
		return true
	else
		return false
	end
end
this.SectionFuncOpenCondition={
	Combat={
		DispatchSoldier=true,
		DispatchFobDefence=this.IsCleardRetakeThePlatform
	},
	Develop={
		Weapon=true,
		SupportHelicopter=this.IsOpenMBDvcArmsMenu,
		Quiet=function()
			return TppBuddyService.CanSortieBuddyType(BuddyType.QUIET)
		end,
		D_Dog=function()
			return TppBuddyService.CanSortieBuddyType(BuddyType.DOG)
		end,
		D_Horse=this.IsOpenMBDvcArmsMenu,
		D_Walker=function()
			return TppBuddyService.CanSortieBuddyType(BuddyType.WALKER_GEAR)
		end,
		BattleGear=function()
			return TppBuddyService.CanSortieBuddyType(BuddyType.BATTLE_GEAR)
		end,
		SecurityDevice=this.IsConstructedFirstFob
	},
	BaseDev={
		Mining=true,
		Processing=true,
		Extention=true,
		Construct=this.IsCleardRetakeThePlatform,
		NuclearDevelop=this.IsReleaseFunctionNuclearDevelop
	},
	Support={
		Fulton=true,
		Supply=true,
		Battle=this.IsReleaseFunctionBattle,
		BattleArtillery=this.IsReleaseFunctionBattle,
		BattleSmoke=this.IsReleaseFunctionBattle,
		BattleSleepGas=this.IsReleaseFunctionBattle,
		BattleChaff=this.IsReleaseFunctionBattle,
		BattleWeather=this.IsReleaseFunctionBattle
	},
	Spy={
		Information=true,
		Scouting=true,
		SearchResource=true,
		WeatherInformation=true
	},
	Medical={
		Emergency=true,
		Treatment=true,
		AntiReflex=this.IsConstructedFirstFob
	},
	Security={
		BaseDefence=true,
		MachineDefence=this.IsConstructedFirstFob,
		BaseBlockade=this.IsConstructedFirstFob,
		SecurityInfo=this.IsConstructedFirstFob
	}
}
function this.ReleaseFunctionOfMbSection()
	local r=TppMotherBaseManagement.OpenedSectionFunc
	for a,t in pairs(T)do
		for o,n in pairs(t)do
			local t
			if this.SectionFuncOpenCondition[a]then
				t=this.SectionFuncOpenCondition[a][o]
			end
			if(t==true)then
				r{sectionFuncId=n,opened=true}
			elseif t then
				if t(a)then
					r{sectionFuncId=n,opened=true}
				else
					r{sectionFuncId=n,opened=false}
				end
			end
		end
	end
end
function this.ReleaseFreePlay()
	TppUiCommand.ClearAllChangeLocationMenu()
	if gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_TO_MATHER_BASE then
		TppUiCommand.EnableChangeLocationMenu{locationId=10,missionId=30010}
	end
	if gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_DESTROY_THE_FLOW_STATION then
		TppUiCommand.EnableChangeLocationMenu{locationId=20,missionId=30020}
	end
	if gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_TO_MATHER_BASE then
		TppUiCommand.EnableChangeLocationMenu{locationId=50,missionId=30050}
	end
	if this.IsBuiltAnimalPlatform()then
		TppUiCommand.EnableChangeLocationMenu{locationId=50,missionId=30150}
	end
	if gvars.trm_isPushRewardSeparationPlatform then
		TppUiCommand.EnableChangeLocationMenu{locationId=50,missionId=30250}
	end
end
function this.IsBuiltAnimalPlatform()
	local e=gvars.trm_animalRecoverHistorySize
	--r51 NG+ Settings
	if
		(((gvars.str_storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON)
		and(TppStory.GetClearedMissionCount{10041,10044,10052,10054}>=3))
		and(e>5))
		or TppTerminal.IsNewGameMode()
	then
		return true
	else
		return false
	end
end
function this.InitNuclearAbolitionCount()
	if not gvars.f30050_isInitNuclearAbolitionCount then
		--r51 NG+ Settings
		if TppStory.GetCurrentStorySequence()>=TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO or TppTerminal.IsNewGameMode() then
			local e=TppServerManager.GetNuclearAbolitionCount()
			if e>=0 then
				gvars.f30050_NuclearAbolitionCount=e
				gvars.f30050_isInitNuclearAbolitionCount=true
			end
		end
	end
end
function this.RemoveStaffsAfterS10240()
	if TppStory.IsMissionCleard(10240)then
		TppMotherBaseManagement.RemoveStaffsS10240()
	end
end
function this.PickUpBluePrint(a,n)
	local t=nil
	if n then
		t=n
	else
		t=mvars.trm_bluePrintLocatorIdTable[a]
	end
	if not t then
		return
	end
	this.AddTempDataBase(t)
	local e=this.BLUE_PRINT_LANG_ID[t]
	TppUI.ShowAnnounceLog("get_blueprint",e)
end
function this.InitializeBluePrintLocatorIdTable()
	mvars.trm_bluePrintLocatorIdTable={}
	for e,t in pairs(this.BLUE_PRINT_LOCATOR_TABLE)do
		local e=TppCollection.GetUniqueIdByLocatorName(e)
		mvars.trm_bluePrintLocatorIdTable[e]=t
	end
end
function this.GetBluePrintKeyItemId(e)
	return mvars.trm_bluePrintLocatorIdTable[e]
end
function this.PickUpEmblem(e)
	local e=mvars.trm_EmblemLocatorIdTable[e]
	if not e then
		return
	end
	TppEmblem.Add(e,false,true)
end
function this.EnableTerminalVoice(e)
	mvars.trm_voiceDisabled=not e
end
function this.PlayTerminalVoice(t,e,n)
	if mvars.trm_voiceDisabled and e~=false then
		return
	end
	TppUiCommand.RequestMbSoundControllerVoice(t,e,n)
end
function this.OnFultonFailedEnd(e,t,n,a)
	mvars.trm_fultonFaileEndInfo=mvars.trm_fultonFaileEndInfo or{}
	mvars.trm_fultonFaileEndInfo[e]={e,t,n,a}
end
function this._OnFultonFailedEnd(t,t,t,t,e)
	if Tpp.IsLocalPlayer(e)then
		TppUI.ShowAnnounceLog"extractionFailed"end
end
function this.HasVehicle()
	local e=TppMotherBaseManagement.GetTempResourceBufferVehicleIncrementCount()
	if e>0 then
		return true
	end
	local e=TppMotherBaseManagement.GetResourceUsableCount{resource="4wdEast"}
	if e>0 then
		return true
	end
	local e=TppMotherBaseManagement.GetResourceUsableCount{resource="4wdWest"}
	if e>0 then
		return true
	end
	local e=TppMotherBaseManagement.GetResourceUsableCount{resource="TruckEast"}
	if e>0 then
		return true
	end
	local e=TppMotherBaseManagement.GetResourceUsableCount{resource="TruckWest"}
	if e>0 then
		return true
	end
	local e=TppMotherBaseManagement.GetResourceUsableCount{resource="ArmoredVehicleEast"}
	if e>0 then
		return true
	end
	local e=TppMotherBaseManagement.GetResourceUsableCount{resource="ArmoredVehicleWest"}
	if e>0 then
		return true
	end
	local e=TppMotherBaseManagement.GetResourceUsableCount{resource="WheeledArmoredVehicleWest"}
	if e>0 then
		return true
	end
	local e=TppMotherBaseManagement.GetResourceUsableCount{resource="TankEast"}
	if e>0 then
		return true
	end
	local e=TppMotherBaseManagement.GetResourceUsableCount{resource="TankWest"}
	if e>0 then
		return true
	end
	return false
end
function this._SetUpDvcMenu(t)
	if not Tpp.IsTypeTable(t)then
		return
	end
	TppUiCommand.InitAllMbTopMenuItemVisible(false)
	TppUiCommand.InitAllMbTopMenuItemActive(true)
	this.EnableDvcMenuByList(t)
end
function this.EnableDvcMenuByList(e)
	for t=1,table.getn(e)do
		if e[t]==nil then
			return
		else
			TppUiCommand.SetMbTopMenuItemVisible(e[t].menu,true)
			if e[t].active~=nil then
				TppUiCommand.SetMbTopMenuItemActive(e[t].menu,e[t].active)
			end
		end
	end
end
function this.SetUpDvcMenuAll()
	TppUiCommand.InitAllMbTopMenuItemVisible(true)
	TppUiCommand.InitAllMbTopMenuItemActive(true)
end
function this.SetActiveTerminalMenu(t)
	if not Tpp.IsTypeTable(t)then
		return
	end
	if t[1]==this.MBDVCMENU.ALL then
		TppUiCommand.InitAllMbTopMenuItemActive(true)
	else
		TppUiCommand.InitAllMbTopMenuItemActive(false)
		for e=1,table.getn(t)do
			if t[e]==nil then
				return
			else
				TppUiCommand.SetMbTopMenuItemActive(t[e],true)
			end
		end
	end
end

--r27 NG+ is New Game mode function for testing NG+
function this.IsNewGameMode()
	--r51 NG+ Settings
  if not TUPPMSettings.newGamePlus_ENABLE then
  	return false
  end
  
  if TppStory.IsMissionCleard(10030)==true then
    return true
  end
  return false
end

return this
