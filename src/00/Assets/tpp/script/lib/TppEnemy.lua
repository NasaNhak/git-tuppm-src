local this={}
local StrCode32=Fox.StrCode32
local IsTypeFunc=Tpp.IsTypeFunc
local IsTypeTable=Tpp.IsTypeTable
local IsTypeString=Tpp.IsTypeString
local IsTypeNumber=Tpp.IsTypeNumber
local GetGameObjectId=GameObject.GetGameObjectId
local GetGameObjectIdByIndex=GameObject.GetGameObjectIdByIndex
local GAME_OBJECT_TYPE_VEHICLE=TppGameObject.GAME_OBJECT_TYPE_VEHICLE
local NULL_ID=GameObject.NULL_ID
local SendCommand=GameObject.SendCommand
local DEBUG_StrCode32ToString=Tpp.DEBUG_StrCode32ToString
local quest_cp="quest_cp"
local EnemySubType=EnemySubType or{}

local function u(e)
	local t={}
	for n,i in ipairs(e)do
		if IsTypeTable(i)then
			t[n]=u(i)
		else
			local e=GetGameObjectId(e[n])
			if e and e~=NULL_ID then
				t[e]=n
			end
		end
	end
	return t
end
function this.Messages()
	return Tpp.StrCode32Table{
		Player={
			{msg="RideHelicopterWithHuman",
				func=this._RideHelicopterWithHuman}
		},
		GameObject={
			{msg="Dead",
				func=this._OnDead},
			{msg="PlacedIntoVehicle",
				func=this._PlacedIntoVehicle},
			{msg="Damage",
				func=this._OnDamage},
			{msg="RoutePoint2",
				func=this._DoRoutePointMessage},
			{msg="LostControl",
				func=this._OnHeliBroken},
			{msg="VehicleBroken",
				func=this._OnVehicleBroken,
				option={isExecDemoPlaying=true}},
			{msg="WalkerGearBroken",
				func=this._OnWalkerGearBroken},
			{msg="ChangePhaseForAnnounce",
				func=this._AnnouncePhaseChange},
			{msg="InterrogateUpHero",
				func=function(n)
					local e=this.GetSoldierType(n)
					if(e~=EnemyType.TYPE_DD)then
						TppTrophy.Unlock(30)
					end
					PlayRecord.RegistPlayRecord"PLAYER_INTERROGATION"
				end
			}
		},
		Weather={
			--r48 Custom clock timer to fire randomized shift changes
			{msg="Clock",
				sender="ShiftChangeCUSTOM",
				func=function(n,n)
					math.randomseed(vars.clock)
					TppMain.Randomize()

					local timeOfDay = TppClock.GetTimeOfDay()
					local timeOfDayIncludeMidNight = TppClock.GetTimeOfDayIncludeMidNight()
					local currentTime = TppClock.GetTime"number"

					if timeOfDay~=timeOfDayIncludeMidNight then
						--If time is past 02:00:00 then consider it as night
						if currentTime < TppClock.TIME_AT_MIDNIGHT or currentTime > TppClock.ParseTimeString("02:00:00","number") then
							timeOfDayIncludeMidNight="night"
						end
					end

					--					TppClock.UnregisterClockMessage("ShiftChangeCUSTOM") --since the timer isn't repeating, no need to unregister the clock
					local randShift = math.random(3)
					if randShift==1 then
						this.ShiftChangeByTime"shiftAtNight"
						TUPPMLog.Log("ShiftChangeCUSTOM shiftAtNight occurring now at time "..tostring(TppClock.FormalizeTime(currentTime,"string")),3)
					elseif randShift==2 then
						this.ShiftChangeByTime"shiftAtMidNight"
						TUPPMLog.Log("ShiftChangeCUSTOM shiftAtMidNight occurring now at time "..tostring(TppClock.FormalizeTime(currentTime,"string")),3)
					else
						this.ShiftChangeByTime"shiftAtMorning"
						TUPPMLog.Log("ShiftChangeCUSTOM shiftAtMorning occurring now at time "..tostring(TppClock.FormalizeTime(currentTime,"string")),3)
					end

					--seems to have a pretty decent effect with the cigar but not in game
					--					if timeOfDayIncludeMidNight=="night" then
					--						this.ShiftChangeByTime"shiftAtNight"
					--						TUPPMLog.Log("ShiftChangeCUSTOM shiftAtNight "..tostring(TppClock.FormalizeTime(currentTime,"string")),3)
					--					elseif timeOfDayIncludeMidNight=="midnight" then
					--						this.ShiftChangeByTime"shiftAtMidNight"
					--						TUPPMLog.Log("ShiftChangeCUSTOM shiftAtMidNight "..tostring(TppClock.FormalizeTime(currentTime,"string")),3)
					--					else
					--						this.ShiftChangeByTime"shiftAtMorning"
					--						TUPPMLog.Log("ShiftChangeCUSTOM shiftAtMorning "..tostring(TppClock.FormalizeTime(currentTime,"string")),3)
					--					end
					TppMain.UnsetFixedRandomization()
				end
			},
			{msg="Clock",
				sender="ShiftChangeAtNight",
				func=function(n,n)
					this.ShiftChangeByTime"shiftAtNight"
				end
			},
			{msg="Clock",
				sender="ShiftChangeAtMorning",
				func=function(n,n)
					this.ShiftChangeByTime"shiftAtMorning"
				end
			},
			{msg="Clock",
				sender="ShiftChangeAtMidNight",
				func=function(n,n)
					this.ShiftChangeByTime"shiftAtMidNight"
				end
			}
		}
	}
end
this.POWER_SETTING={"NO_KILL_WEAPON","ARMOR","SOFT_ARMOR","SNIPER","SHIELD","MISSILE","MG","SHOTGUN","SMG","HELMET","NVG","GAS_MASK","GUN_LIGHT","STRONG_WEAPON","STRONG_PATROL","STRONG_NOTICE_TRANQ","FULTON_SPECIAL","FULTON_HIGH","FULTON_LOW","COMBAT_SPECIAL","COMBAT_HIGH","COMBAT_LOW","STEALTH_SPECIAL","STEALTH_HIGH","STEALTH_LOW","HOLDUP_SPECIAL","HOLDUP_HIGH","HOLDUP_LOW"}
this.PHASE={SNEAK=0,CAUTION=1,EVASION=2,ALERT=3,MAX=4}
this.ROUTE_SET_TYPES={"sneak_day","sneak_night","caution","hold","travel","sneak_midnight","sleep"}
this.LIFE_STATUS={NORMAL=0,DEAD=1,DYING=2,SLEEP=3,FAINT=4}
this.ACTION_STATUS={NORMAL=0,FULTON_RECOVERD=1,HOLD_UP_STAND=2,HOLD_UP_CROWL=3,NOW_CARRYING=4}
this.SOLDIER_DEFINE_RESERVE_TABLE_NAME=Tpp.Enum{"lrrpTravelPlan","lrrpVehicle"}
this.TAKING_OVER_HOSTAGE_LIST={"hos_takingOver_0000","hos_takingOver_0001","hos_takingOver_0002","hos_takingOver_0003"}
this.ROUTE_SET_TYPETAG={}
this.subTypeOfCpTable={SOVIET_A={afgh_field_cp=true,afgh_remnants_cp=true,afgh_tent_cp=true,afgh_fieldEast_ob=true,afgh_fieldWest_ob=true,afgh_remnantsNorth_ob=true,afgh_tentEast_ob=true,afgh_tentNorth_ob=true,afgh_01_16_lrrp=true,afgh_29_20_lrrp=true,afgh_29_16_lrrp=true,afgh_village_cp=true,afgh_slopedTown_cp=true,afgh_commFacility_cp=true,afgh_enemyBase_cp=true,afgh_commWest_ob=true,afgh_ruinsNorth_ob=true,afgh_slopedWest_ob=true,afgh_villageEast_ob=true,afgh_villageEast_ob=true,afgh_villageNorth_ob=true,afgh_villageWest_ob=true,afgh_enemyEast_ob=true,afgh_01_13_lrrp=true,afgh_02_14_lrrp=true,afgh_32_01_lrrp=true,afgh_32_04_lrrp=true,afgh_32_14_lrrp=true,afgh_34_02_lrrp=true,afgh_34_13_lrrp=true,afgh_35_02_lrrp=true,afgh_35_14_lrrp=true,afgh_35_15_lrrp=true,afgh_36_04_lrrp=true,afgh_36_15_lrrp=true,afgh_36_06_lrrp=true},SOVIET_B={afgh_bridge_cp=true,afgh_fort_cp=true,afgh_cliffTown_cp=true,afgh_bridgeNorth_ob=true,afgh_bridgeWest_ob=true,afgh_cliffEast_ob=true,afgh_cliffSouth_ob=true,afgh_cliffWest_ob=true,afgh_enemyNorth_ob=true,afgh_fortSouth_ob=true,afgh_fortWest_ob=true,afgh_slopedEast_ob=true,afgh_powerPlant_cp=true,afgh_sovietBase_cp=true,afgh_plantSouth_ob=true,afgh_plantWest_ob=true,afgh_sovietSouth_ob=true,afgh_waterwayEast_ob=true,afgh_citadel_cp=true,afgh_citadelSouth_ob=true},PF_A={mafr_outland_cp=true,mafr_outlandEast_ob=true,mafr_outlandNorth_ob=true,mafr_01_20_lrrp=true,mafr_03_20_lrrp=true,mafr_flowStation_cp=true,mafr_swamp_cp=true,mafr_pfCamp_cp=true,mafr_savannah_cp=true,mafr_swampEast_ob=true,mafr_swampWest_ob=true,mafr_swampSouth_ob=true,mafr_pfCampEast_ob=true,mafr_pfCampNorth_ob=true,mafr_savannahEast_ob=true,mafr_chicoVilWest_ob=true,mafr_hillSouth_ob=true,mafr_02_21_lrrp=true,mafr_02_22_lrrp=true,mafr_05_23_lrrp=true,mafr_06_16_lrrp=true,mafr_06_22_lrrp=true,mafr_06_24_lrrp=true,mafr_13_15_lrrp=true,mafr_13_16_lrrp=true,mafr_13_24_lrrp=true,mafr_15_16_lrrp=true,mafr_15_23_lrrp=true,mafr_16_23_lrrp=true,mafr_16_24_lrrp=true,mafr_23_33_lrrp=true},PF_B={mafr_factory_cp=true,mafr_lab_cp=true,mafr_labWest_ob=true,mafr_19_29_lrrp=true},PF_C={mafr_banana_cp=true,mafr_diamond_cp=true,mafr_hill_cp=true,mafr_savannahNorth_ob=true,mafr_savannahWest_ob=true,mafr_bananaEast_ob=true,mafr_bananaSouth_ob=true,mafr_hillNorth_ob=true,mafr_hillWest_ob=true,mafr_hillWestNear_ob=true,mafr_factorySouth_ob=true,mafr_factoryWest_ob=true,mafr_diamondNorth_ob=true,mafr_diamondSouth_ob=true,mafr_diamondWest_ob=true,mafr_07_09_lrrp=true,mafr_07_24_lrrp=true,mafr_08_10_lrrp=true,mafr_08_25_lrrp=true,mafr_09_25_lrrp=true,mafr_10_11_lrrp=true,mafr_10_18_lrrp=true,mafr_10_26_lrrp=true,mafr_11_10_lrrp=true,mafr_11_12_lrrp=true,mafr_11_26_lrrp=true,mafr_12_14_lrrp=true,mafr_14_27_lrrp=true,mafr_17_27_lrrp=true,mafr_18_26_lrrp=true,mafr_27_30_lrrp=true}}
this.subTypeOfCp={}
for t,n in pairs(this.subTypeOfCpTable)do
	for n,a in pairs(n)do
		this.subTypeOfCp[n]=t
	end
end
local TppEnemyBodyId=TppEnemyBodyId or{}
this.childBodyIdTable={TppEnemyBodyId.chd0_v00,TppEnemyBodyId.chd0_v01,TppEnemyBodyId.chd0_v02,TppEnemyBodyId.chd0_v03,TppEnemyBodyId.chd0_v05,TppEnemyBodyId.chd0_v06,TppEnemyBodyId.chd0_v07,TppEnemyBodyId.chd0_v08,TppEnemyBodyId.chd0_v09,TppEnemyBodyId.chd0_v10,TppEnemyBodyId.chd0_v11}
this.bodyIdTable={SOVIET_A={ASSAULT={TppEnemyBodyId.svs0_rfl_v00_a,TppEnemyBodyId.svs0_rfl_v00_a,TppEnemyBodyId.svs0_rfl_v01_a,TppEnemyBodyId.svs0_mcg_v00_a},ASSAULT_OB={TppEnemyBodyId.svs0_rfl_v02_a,TppEnemyBodyId.svs0_mcg_v02_a},SNIPER={TppEnemyBodyId.svs0_snp_v00_a},SHOTGUN={TppEnemyBodyId.svs0_rfl_v00_a,TppEnemyBodyId.svs0_rfl_v01_a},SHOTGUN_OB={TppEnemyBodyId.svs0_rfl_v02_a},MG={TppEnemyBodyId.svs0_mcg_v00_a,TppEnemyBodyId.svs0_mcg_v01_a},MG_OB={TppEnemyBodyId.svs0_mcg_v02_a},MISSILE={TppEnemyBodyId.svs0_rfl_v00_a},SHIELD={TppEnemyBodyId.svs0_rfl_v00_a},ARMOR={TppEnemyBodyId.sva0_v00_a},RADIO={TppEnemyBodyId.svs0_rdo_v00_a}},SOVIET_B={ASSAULT={TppEnemyBodyId.svs0_rfl_v00_b,TppEnemyBodyId.svs0_rfl_v00_b,TppEnemyBodyId.svs0_rfl_v01_b,TppEnemyBodyId.svs0_mcg_v00_b},ASSAULT_OB={TppEnemyBodyId.svs0_rfl_v02_b,TppEnemyBodyId.svs0_mcg_v02_b},SNIPER={TppEnemyBodyId.svs0_snp_v00_b},SHOTGUN={TppEnemyBodyId.svs0_rfl_v00_b,TppEnemyBodyId.svs0_rfl_v01_b},SHOTGUN_OB={TppEnemyBodyId.svs0_rfl_v02_b},MG={TppEnemyBodyId.svs0_mcg_v00_b,TppEnemyBodyId.svs0_mcg_v01_b},MG_OB={TppEnemyBodyId.svs0_mcg_v02_b},MISSILE={TppEnemyBodyId.svs0_rfl_v00_b},SHIELD={TppEnemyBodyId.svs0_rfl_v00_b},ARMOR={TppEnemyBodyId.sva0_v00_a},RADIO={TppEnemyBodyId.svs0_rdo_v00_b}},PF_A={ASSAULT={TppEnemyBodyId.pfs0_rfl_v00_a,TppEnemyBodyId.pfs0_mcg_v00_a},ASSAULT_OB={TppEnemyBodyId.pfs0_rfl_v00_a,TppEnemyBodyId.pfs0_rfl_v01_a,TppEnemyBodyId.pfs0_mcg_v00_a},SNIPER={TppEnemyBodyId.pfs0_snp_v00_a},SHOTGUN={TppEnemyBodyId.pfs0_rfl_v00_a},SHOTGUN_OB={TppEnemyBodyId.pfs0_rfl_v00_a,TppEnemyBodyId.pfs0_rfl_v01_a},MG={TppEnemyBodyId.pfs0_mcg_v00_a},MISSILE={TppEnemyBodyId.pfs0_rfl_v00_a},SHIELD={TppEnemyBodyId.pfs0_rfl_v00_a},ARMOR={TppEnemyBodyId.pfa0_v00_b},RADIO={TppEnemyBodyId.pfs0_rdo_v00_a}},PF_B={ASSAULT={TppEnemyBodyId.pfs0_rfl_v00_b,TppEnemyBodyId.pfs0_mcg_v00_b},ASSAULT_OB={TppEnemyBodyId.pfs0_rfl_v00_b,TppEnemyBodyId.pfs0_rfl_v01_b,TppEnemyBodyId.pfs0_mcg_v00_b},SNIPER={TppEnemyBodyId.pfs0_snp_v00_b},SHOTGUN={TppEnemyBodyId.pfs0_rfl_v00_b},SHOTGUN_OB={TppEnemyBodyId.pfs0_rfl_v00_b,TppEnemyBodyId.pfs0_rfl_v01_b},MG={TppEnemyBodyId.pfs0_mcg_v00_b},MISSILE={TppEnemyBodyId.pfs0_rfl_v00_b},SHIELD={TppEnemyBodyId.pfs0_rfl_v00_b},ARMOR={TppEnemyBodyId.pfa0_v00_a},RADIO={TppEnemyBodyId.pfs0_rdo_v00_b}},PF_C={ASSAULT={TppEnemyBodyId.pfs0_rfl_v00_c,TppEnemyBodyId.pfs0_mcg_v00_c},ASSAULT_OB={TppEnemyBodyId.pfs0_rfl_v00_c,TppEnemyBodyId.pfs0_rfl_v01_c,TppEnemyBodyId.pfs0_mcg_v00_c},SNIPER={TppEnemyBodyId.pfs0_snp_v00_c},SHOTGUN={TppEnemyBodyId.pfs0_rfl_v00_c},SHOTGUN_OB={TppEnemyBodyId.pfs0_rfl_v00_c,TppEnemyBodyId.pfs0_rfl_v01_c},MG={TppEnemyBodyId.pfs0_mcg_v00_c},MISSILE={TppEnemyBodyId.pfs0_rfl_v00_c},SHIELD={TppEnemyBodyId.pfs0_rfl_v01_c},ARMOR={TppEnemyBodyId.pfa0_v00_c},RADIO={TppEnemyBodyId.pfs0_rdo_v00_c}},
	DD_A={ASSAULT={TppEnemyBodyId.dds3_main0_v00}},
	DD_FOB={ASSAULT={TppEnemyBodyId.dds5_main0_v00}},
	DD_PW={ASSAULT={TppEnemyBodyId.dds0_main1_v00}}, --ABANDONED rX42 use on MB
	SKULL_CYPR={ASSAULT={TppEnemyBodyId.wss0_main0_v00}},SKULL_AFGH={ASSAULT={TppEnemyBodyId.wss4_main0_v00}},CHILD={ASSAULT=this.childBodyIdTable}}

---------------WEAPONS TESTING------------------------------------------------------------
--      --r13 better weapons
--      HANDGUN=TppEquip.EQP_WP_EX_hg_013, --r28 Tornado-6 Grade 7
--      SMG=TppEquip.EQP_WP_East_sm_020,
--      SHOTGUN=TppEquip.EQP_WP_Com_sg_020_FL,
--      ASSAULT=TppEquip.EQP_WP_East_ar_030_FL,
--      SNIPER=TppEquip.EQP_WP_EX_sr_000,
--      MG=TppEquip.EQP_WP_West_mg_030,
--      MISSILE=TppEquip.EQP_WP_Com_ms_020,
--      --      GRENADE=TppEquip.EQP_SWP_Grenade_G05, --r16 these don't work, maybe? --TODO WIP test
--      --      STUN_GRENADE=TppEquip.EQP_SWP_StunGrenade_G03,
--      --      SMOKE_GRENADE=TppEquip.EQP_SWP_SmokeGrenade_G04,
--      --      GRENADE_LAUNCHER=TppEquip.EQP_WP_EX_gl_000,
--      SHIELD=TppEquip.EQP_SLD_SV

--r40 tried weapon variety this way
-- works but also have to handle powers alongside
--      --      --r13 better weapons
--      HANDGUN=TppEquip.EQP_WP_EX_hg_013, --r28 Tornado-6 Grade 7
--      HANDGUN2=TppEquip.EQP_WP_West_hg_020,
--      SMG=TppEquip.EQP_WP_East_sm_020,
--      SMG2=TppEquip.EQP_WP_West_sm_020,
--      SMG3=TppEquip.EQP_WP_East_sm_010,
--      SHOTGUN=TppEquip.EQP_WP_Com_sg_020_FL,
--      SHOTGUN2=TppEquip.EQP_WP_Com_sg_011_FL,
--      ASSAULT=TppEquip.EQP_WP_East_ar_030_FL, --default
----      ASSAULT2=TppEquip.EQP_WP_West_ar_020_FL, --
----      ASSAULT2=TppEquip.EQP_WP_East_ar_020, --not work
----      ASSAULT3=TppEquip.EQP_WP_East_ar_010_FL, --works
--      ASSAULT2=TppEquip.EQP_WP_West_ar_050,
--      ASSAULT3=TppEquip.EQP_WP_West_ar_030,
--      SNIPER=TppEquip.EQP_WP_EX_sr_000,
--      SNIPER2=TppEquip.EQP_WP_West_sr_010,
--      SNIPER3=TppEquip.EQP_WP_West_sr_011,
--      SNIPER4=TppEquip.EQP_WP_West_sr_020,
--      SNIPER5=TppEquip.EQP_WP_East_sr_011,
--      SNIPER6=TppEquip.EQP_WP_East_sr_020,
--      MG=TppEquip.EQP_WP_West_mg_030,
--      MG2=TppEquip.EQP_WP_West_mg_010,
--      MG3=TppEquip.EQP_WP_East_mg_010,
--      MISSILE=TppEquip.EQP_WP_Com_ms_020,
--      MISSILE2=TppEquip.EQP_WP_West_ms_010,
--      --      GRENADE=TppEquip.EQP_SWP_Grenade_G05, --r16 these don't work, maybe? --TODO WIP test
--      --      STUN_GRENADE=TppEquip.EQP_SWP_StunGrenade_G03,
--      --      SMOKE_GRENADE=TppEquip.EQP_SWP_SmokeGrenade_G04,
--      --      GRENADE_LAUNCHER=TppEquip.EQP_WP_EX_gl_000,
--      SHIELD=TppEquip.EQP_SLD_SV


--r13 testing results
----      HANDGUN=TppEquip.EQP_WP_West_hg_010,      --AM D114 Grade 1
----      HANDGUN=TppEquip.EQP_WP_West_hg_010_WG,   --X
--      HANDGUN=TppEquip.EQP_WP_West_hg_020,      --AM D114 Grade 4 + FL + SUP *BEST* EQUIP:
----      HANDGUN=TppEquip.EQP_WP_West_hg_030,      --Geist P3 Grade 4, shotgun icon, not useful
----      HANDGUN=TppEquip.EQP_WP_West_hg_030_cmn,  --X
----      HANDGUN=TppEquip.EQP_WP_East_hg_010,      --Burkov Grade 1
----      HANDGUN=TppEquip.EQP_WP_West_thg_010,     --WU S.Pistol Grade 1 ZZZ, Broken reload when disarmed
----      HANDGUN=TppEquip.EQP_WP_West_thg_020,     --WU S.Pistol Grade 2 ZZZ No SUP, Broken reload when disarmed
----      HANDGUN=TppEquip.EQP_WP_West_thg_030,     --WU S.Pistol Grade 5 ZZZ, Broken reload when disarmed
----      HANDGUN=TppEquip.EQP_WP_West_thg_040,     --WU S.Pistol Grade 5 ZZZ, Broken reload when disarmed
----      HANDGUN=TppEquip.EQP_WP_West_thg_050,     --WU S.Pistol CB Grade 7 ZZZ No SUP, Broken reload when disarmed, cannot develop, unique butt
----      HANDGUN=TppEquip.EQP_WP_SkullFace_hg_010, --SKULL Cutom Grade 1, kick ass stats, somewhat animation, broken
----      HANDGUN=TppEquip.EQP_WP_SP_hg_010,        --X SP do not load, infinite loading
----      HANDGUN=TppEquip.EQP_WP_SP_hg_020,        --X SP do not load, infinite loading
----      HANDGUN=TppEquip.EQP_WP_EX_hg_000,        --AM A114RP Grade 9!!! Grenade launcher?! missing reload after CQC grab
--        HANDGUN=TppEquip.EQP_WP_EX_hg_000_G01,    --AM A114 RP ZZZ Grade 8, missing reload after CQC grab
--        HANDGUN=TppEquip.EQP_WP_EX_hg_000_G02,    --AM A114 RP ZZZ Grade 9, missing reload after CQC grab
--        HANDGUN=TppEquip.EQP_WP_EX_hg_000_G03,    --AM A114 RP ZZZ Grade 10, missing reload after CQC grab
--        HANDGUN=TppEquip.EQP_WP_EX_hg_000_G04,    --AM A114 RP ZZZ Grade 11, missing reload after CQC grab
--        HANDGUN=TppEquip.EQP_WP_EX_hg_010,    --Tornado Grade 3
--        HANDGUN=TppEquip.EQP_WP_EX_hg_011,    --Tornado Grade 5
--        HANDGUN=TppEquip.EQP_WP_EX_hg_012,    --Tornado Grade 6
--        HANDGUN=TppEquip.EQP_WP_EX_hg_013,    --Tornado Grade 7 *BEST*
--
--
--
----      SMG=TppEquip.EQP_WP_West_sm_010,      --ZE'EV Grade 3
----      SMG=TppEquip.EQP_WP_West_sm_010_WG,   --X
----      SMG=TppEquip.EQP_WP_West_sm_014,      --X
----      SMG=TppEquip.EQP_WP_West_sm_015,      --X
----      SMG=TppEquip.EQP_WP_West_sm_020,      --Mach 37 Grade 3
----      SMG=TppEquip.EQP_WP_East_sm_010,      --Sz. 336 Grade 3 EQUIP:
--      SMG=TppEquip.EQP_WP_East_sm_020,      --Sz. 336 CS Grade 5, matches Sz. 336 HS Grade 5 *BEST* EQUIP:
----      SMG=TppEquip.EQP_WP_East_sm_030,      --Sz. 336 Grade 3 + SUP + FL
----      SMG=TppEquip.EQP_WP_East_sm_042,      --Riot SMG Grade 1, cannot develop
----      SMG=TppEquip.EQP_WP_East_sm_043,      --X
----      SMG=TppEquip.EQP_WP_East_sm_044,      --X
----      SMG=TppEquip.EQP_WP_East_sm_045,      --X
----      SMG=TppEquip.EQP_WP_Pr_sm_010,        --X PR are Invisible
----      SMG=TppEquip.EQP_WP_SP_sm_010,        --X SP do not load, infinite loading
----      SMG=TppEquip.EQP_WP_West_sm_016,      --X
----      SMG=TppEquip.EQP_WP_West_sm_017,      --X
----      SMG=TppEquip.EQP_WP_East_sm_047,      --STN
----      SMG=TppEquip.EQP_WP_West_sm_019,      --X
----      SMG=TppEquip.EQP_WP_West_sm_01a,      --X
----      SMG=TppEquip.EQP_WP_West_sm_01b,      --X
----      SMG=TppEquip.EQP_WP_East_sm_049,      --X
----      SMG=TppEquip.EQP_WP_East_sm_04a,      --X
----      SMG=TppEquip.EQP_WP_East_sm_04b,      --X
--
--
--
----      ASSAULT=TppEquip.EQP_WP_West_ar_010,      --AM MRS-4R Grade 3, grouping slightly higher
----      ASSAULT=TppEquip.EQP_WP_West_ar_010_FL,   --AM MRS-4R Grade 3, grouping slightly higher + FL EQUIP:
----      ASSAULT=TppEquip.EQP_WP_West_ar_055,      --X
----      ASSAULT=TppEquip.EQP_WP_West_ar_020,      --UN-ARC Grade 3
----      ASSAULT=TppEquip.EQP_WP_West_ar_020_FL,   ----UN-ARC CS Grade 3 + FL
----      ASSAULT=TppEquip.EQP_WP_West_ar_030,      --UN-ARC-PT CS Grade 4 + FL, stats similar to UN-ARC Grade 4
----      ASSAULT=TppEquip.EQP_WP_West_ar_040,      --AM MRS-4 Grade 1
----      ASSAULT=TppEquip.EQP_WP_West_ar_042,      --X
----      ASSAULT=TppEquip.EQP_WP_West_ar_050,      --AM MRS-4R Grade 5 EQUIP:
----      ASSAULT=TppEquip.EQP_WP_West_ar_060,      --UN-ARC-NL Grade 2 STN
----      ASSAULT=TppEquip.EQP_WP_West_ar_063,      --X
----      ASSAULT=TppEquip.EQP_WP_West_ar_070,      --UN-ARC-NL Grade 4 STN + FL
----      ASSAULT=TppEquip.EQP_WP_West_ar_075,      --STN
----      ASSAULT=TppEquip.EQP_WP_East_ar_010,      --SVG-76 Grade 1
----      ASSAULT=TppEquip.EQP_WP_East_ar_010_FL,   --SVG-76 Grade 1 + FL
----      ASSAULT=TppEquip.EQP_WP_East_ar_020,      --SVG-67 Grade 4
----      ASSAULT=TppEquip.EQP_WP_East_ar_030,      --SVG-67 CS Grade 6, cannot develop
--      ASSAULT=TppEquip.EQP_WP_East_ar_030_FL,   --SVG-67 CS Grade 6 + FL, cannot develop *BEST*
----      ASSAULT=TppEquip.EQP_WP_Wood_ar_010,      --X ROFL as the name suggests is a wooden gun XD
----      ASSAULT=TppEquip.EQP_WP_Pr_ar_010,        --X Invisible
----      ASSAULT=TppEquip.EQP_WP_West_ar_057,      --X
----      ASSAULT=TppEquip.EQP_WP_West_ar_077,      --STN
----      ASSAULT=TppEquip.EQP_WP_West_ar_059,      --X
----      ASSAULT=TppEquip.EQP_WP_West_ar_05a,      --X
----      ASSAULT=TppEquip.EQP_WP_West_ar_05b,      --X
----      ASSAULT=TppEquip.EQP_WP_West_ar_079,      --X
----      ASSAULT=TppEquip.EQP_WP_West_ar_07a,      --X
----      ASSAULT=TppEquip.EQP_WP_West_ar_07b,      --X
--
--
--
----      SNIPER=TppEquip.EQP_WP_West_sr_010,       --M2000-D Grade 2
----      SNIPER=TppEquip.EQP_WP_West_sr_011,       --M2000-D CS Grade 2;  cannot develop, slighty less damage
----      SNIPER=TppEquip.EQP_WP_West_sr_013,       --X
----      SNIPER=TppEquip.EQP_WP_West_sr_014,       --X
--      SNIPER=TppEquip.EQP_WP_West_sr_020,       --AM MRS-71 CS Grade 5 *BEST* EQUIP:
----      SNIPER=TppEquip.EQP_WP_West_sr_037,       --AM MRS-73 NL Grade 1 ZZZ
----      SNIPER=TppEquip.EQP_WP_East_sr_011,       --Renov-ICKX CS Grade 1
----      SNIPER=TppEquip.EQP_WP_East_sr_020,       --Bambetov SV CS Grade 4
----      SNIPER=TppEquip.EQP_WP_East_sr_032,       --Renov-ICKX TP CS Grade 4 ZZZ
----      SNIPER=TppEquip.EQP_WP_East_sr_033,       --X
----      SNIPER=TppEquip.EQP_WP_East_sr_034,       --X
----      SNIPER=TppEquip.EQP_WP_Quiet_sr_010,      --Wicked Butterfly Grade 2
----      SNIPER=TppEquip.EQP_WP_Quiet_sr_020,      --Guilty Butterfly Grade 3
----      SNIPER=TppEquip.EQP_WP_Quiet_sr_030,      --Sinful Butterfly Grade 4
----      SNIPER=TppEquip.EQP_WP_BossQuiet_sr_010,  --X Invisible
----      SNIPER=TppEquip.EQP_WP_Pr_sr_010,         --X Invisible
----      SNIPER=TppEquip.EQP_WP_EX_sr_000,         --Molotok-68 Grade 9!!! WTF!  *BEST*  Extreme(unreliable) damage but guard towers are not destroyed
----      SNIPER=TppEquip.EQP_WP_West_sr_027,       --X
----      SNIPER=TppEquip.EQP_WP_West_sr_047,       --X
----      SNIPER=TppEquip.EQP_WP_West_sr_048,       --X
----      SNIPER=TppEquip.EQP_WP_West_sr_029,       --X
----      SNIPER=TppEquip.EQP_WP_West_sr_02a,       --X
----      SNIPER=TppEquip.EQP_WP_West_sr_02b,       --X
----      SNIPER=TppEquip.EQP_WP_West_sr_049,       --X
----      SNIPER=TppEquip.EQP_WP_West_sr_04a,       --X
----      SNIPER=TppEquip.EQP_WP_West_sr_04b,       --X
--
--
--
----      SHOTGUN=TppEquip.EQP_WP_Com_sg_010,       --S1000 Grade 2
----      SHOTGUN=TppEquip.EQP_WP_Com_sg_011,       --S1000 CS Grade 2 + FL; cannot develop
----      SHOTGUN=TppEquip.EQP_WP_Com_sg_011_FL,    --S1000 CS Grade 2 + FL; cannot develop
----      SHOTGUN=TppEquip.EQP_WP_Com_sg_013,       --X
----      SHOTGUN=TppEquip.EQP_WP_Com_sg_015,       --X
----      SHOTGUN=TppEquip.EQP_WP_Com_sg_020,       --Kabarga 83 Grade 4
--      SHOTGUN=TppEquip.EQP_WP_Com_sg_020_FL,    --Kabarga 83 Grade 4 + FL *BEST* EQUIP:
----      SHOTGUN=TppEquip.EQP_WP_Com_sg_023,       --S1000 Air-S CS Grade 3 STN
----      SHOTGUN=TppEquip.EQP_WP_Com_sg_024,       --X
----      SHOTGUN=TppEquip.EQP_WP_Com_sg_025,       --X
----      SHOTGUN=TppEquip.EQP_WP_Com_sg_030,       --S1000 Air-S CS Grade 6 STN + FL, cannot develop
----      SHOTGUN=TppEquip.EQP_WP_Pr_sg_010,        --X Invisible gun
----      SHOTGUN=TppEquip.EQP_WP_Volgin_sg_010,    --X S1000 Grade 1 Broken gun
----      SHOTGUN=TppEquip.EQP_WP_SP_sg_010,        --X SP do not load, infinite loading
----      SHOTGUN=TppEquip.EQP_WP_Com_sg_038,       --X
----      SHOTGUN=TppEquip.EQP_WP_Com_sg_016,       --X
----      SHOTGUN=TppEquip.EQP_WP_Com_sg_018,       --X--
--
--
--
----      MG=TppEquip.EQP_WP_West_mg_010,     --UN-AAM Grade 2 Cannot develop
----      MG=TppEquip.EQP_WP_West_mg_020,     --ALM 48 Grade 2 EQUIP:
----      MG=TppEquip.EQP_WP_West_mg_023,     --X
----      MG=TppEquip.EQP_WP_West_mg_024,     --X
----      MG=TppEquip.EQP_WP_West_mg_021,     --ALM 48 Grade 4 EQUIP:
--      MG=TppEquip.EQP_WP_West_mg_030,     --ALM 48 Grade 5 *BEST* EQUIP:
----      MG=TppEquip.EQP_WP_East_mg_010,     --LPG-61 Grade 4
----      MG=TppEquip.EQP_WP_mgm0_mgun0,      --X Invisible gun
----      MG=TppEquip.EQP_WP_West_mg_037,     --X
----      MG=TppEquip.EQP_WP_West_mg_039,     --X
----      MG=TppEquip.EQP_WP_West_mg_03a,     --X
----      MG=TppEquip.EQP_WP_West_mg_03b,     --X
--
--
--
----      MISSILE=TppEquip.EQP_WP_Com_ms_010,   --Killer Bee Grade 3 EQUIP:
----      MISSILE=TppEquip.EQP_WP_Com_ms_020,   --Killer Bee Grade 5 EQUIP: *BEST*
----      MISSILE=TppEquip.EQP_WP_Com_ms_023,   --X
----      MISSILE=TppEquip.EQP_WP_Com_ms_024,   --X
----      MISSILE=TppEquip.EQP_WP_West_ms_010,  --FB MR R-Launcher Grade 3
----      MISSILE=TppEquip.EQP_WP_West_ms_020,  --FB MR R-L NLSP. Grade 6, cannot develop, 2-8x Zoom, stats similar to lethal Grade 5
----      MISSILE=TppEquip.EQP_WP_East_ms_010,  --Grom-11 Grade 2
--      MISSILE=TppEquip.EQP_WP_East_ms_020,  --CGM 25 Grade 4 -- no explosion when sodiers use this(maybe coz tested as assualt - NOPE - confirmed broken)
----      MISSILE=TppEquip.EQP_WP_HoneyBee,     --Honey Bee Grade 1, equal to Killer Bee Grade 3
----      MISSILE=TppEquip.EQP_WP_Com_ms_026,   --X
----      MISSILE=TppEquip.EQP_WP_West_ms_029,   --X
----      MISSILE=TppEquip.EQP_WP_West_ms_02a,   --X
----      MISSILE=TppEquip.EQP_WP_West_ms_02b,   --X
----      MISSILE=TppEquip.EQP_WP_Com_ms_029,   --X
----      MISSILE=TppEquip.EQP_WP_Com_ms_02a,   --X
----      MISSILE=TppEquip.EQP_WP_Com_ms_02b,   --X
--
--
--
--        GRENADE_LAUNCHER=TppEquip.EQP_WP_EX_gl_000, --doesn't use by default
--
--      SHIELD=TppEquip.EQP_SLD_SV

---------------WEAPONS TESTING------------------------------------------------------------


--r40 Weapon variety table
--r41 Added more weapons to table - Weapon varieties updated - every possible NPC usable weapon is now made available
--r47 AFTER 1.10 DE Update SP weapons can be equipped on enemies as well as they no longer have missing textures/models
this.usableWeaponsTable={

		--r42 'X' at the end of comment means weapon has been included for DD Staff

		HANDGUN={
			TppEquip.EQP_WP_East_hg_010, --Burkov Grade 1 (1020) X No need
			TppEquip.EQP_WP_West_hg_010, --AM D114 Grade 1 (1010) X
			TppEquip.EQP_WP_West_hg_020, --AM D114 Grade 4 + FL + SUP (1013) X No need
			TppEquip.EQP_WP_EX_hg_013, --Tornado Grade 7 *BEST* (1100 - Grade 3 Tornado, Grade 7 is 1103) X No need
			--r47 Allow DLC HANDGUN for enemies
			TppEquip.EQP_WP_SP_hg_020, --WEAPON_ADAM_SKA_SP DLC Grade 3 (1090)
			TppEquip.EQP_WP_SP_hg_010, --WEAPON_WU_S333_CB_SP DLC Grade 3 (1091)
		},
		SMG={
			TppEquip.EQP_WP_West_sm_010, --ZE'EV Grade 3 (2010) X
			TppEquip.EQP_WP_West_sm_020, --Mach 37 Grade 3 (2020) X
			TppEquip.EQP_WP_East_sm_010, --Sz. 336 Grade 3 (Grade 2 - 2e3, Grade 3 - 2001) X
			TppEquip.EQP_WP_East_sm_030, --Sz. 336 Grade 3 + SUP + FL (Grade 2 - 2e3, Grade 3 - 2001) X
			TppEquip.EQP_WP_East_sm_020, --Sz. 336 CS Grade 5 (2003) X
			--r47 Allow DLC SMG for enemies
			TppEquip.EQP_WP_SP_sm_010, --WEAPON_MACHT_P5_WEISS DLC Grade 3 (2030)
		},
		ASSAULT={
			TppEquip.EQP_WP_West_ar_040, --AM MRS-4 Grade 1 (3030) X
			TppEquip.EQP_WP_East_ar_010, --SVG-76 Grade 1 (3e3) X
			TppEquip.EQP_WP_East_ar_010_FL, --SVG-76 Grade 1 + FL (3e3) X
			TppEquip.EQP_WP_West_ar_010, --AM MRS-4R Grade 3 (3036) X
			TppEquip.EQP_WP_West_ar_010_FL, --AM MRS-4R Grade 3 +FL (3036) X
			TppEquip.EQP_WP_West_ar_030, --UN-ARC-PT CS Grade 4 + FL (Grade 3 - 3055, Grade 4 - 3056) X
			TppEquip.EQP_WP_West_ar_050, --AM MRS-4R Grade 5 (3038) X
			TppEquip.EQP_WP_East_ar_020, --SVG-67 Grade 4 (3006) X
			TppEquip.EQP_WP_East_ar_030, --SVG-67 CS Grade 6 (Grade 5 - 3007, No grade 6) X
			TppEquip.EQP_WP_East_ar_030_FL, --SVG-67 CS Grade 6 + FL (Grade 5 - 3007, No grade 6) X
		--sadly no, player equip cannot be assigned to NPCs nor loaded through TppEquip.RequestLoadToEquipMissionBlock(equipLoadTable)
		--    TppEquip.EQP_WP_30336,
		--    TppEquip.EQP_WP_30233,
		--    TppEquip.EQP_WP_30203,
		--    TppEquip.EQP_WP_30101,
		--    TppEquip.EQP_WP_30025,
		},
		SNIPER={
			TppEquip.EQP_WP_East_sr_011, --Renov-ICKX CS Grade 1 (6e3 SR weapon) X
			TppEquip.EQP_WP_West_sr_010, --M2000-D Grade 2 (6010) X
			TppEquip.EQP_WP_West_sr_011, --M2000-D CS Grade 2 (6010) X
			TppEquip.EQP_WP_East_sr_020, --Bambetov SV CS Grade 4 (Grade 3 - 6020, Grade 4 - 6021) X
			TppEquip.EQP_WP_West_sr_020, --AM MRS-71 CS Grade 5 (Grade 3 - 6030, Grade 4 - 6031, Grade 5 -6032) X
			TppEquip.EQP_WP_EX_sr_000, --Molotok-68 Grade 9 (6050) X
		},
		SHOTGUN={
			TppEquip.EQP_WP_Com_sg_011, --S1000 CS Grade 2 (4020) X
			TppEquip.EQP_WP_Com_sg_011_FL, --S1000 CS Grade 2 + FL (4020) X
			TppEquip.EQP_WP_Com_sg_020, --Kabarga 83 Grade 4 (Grade 3 -4040, Grade 4 -4041) X
			TppEquip.EQP_WP_Com_sg_020_FL, --Kabarga 83 Grade 4 + FL (Grade 3 -4040, Grade 4 -4041) X
		--r47 Allow DLC SHOTGUN for enemies
		--    TppEquip.EQP_WP_SP_sg_010, --WEAPON_RASP_SB_SG_GOLD DLC Grade 3 (4060) --broken firing with Shield and alone there is no data for two shot mechanism for NPCs - treated as a pump action shotgun, don't use
		},
		MG={
			TppEquip.EQP_WP_West_mg_010, --UN-AAM Grade 2 (Grade 3 min - 7010) X
			TppEquip.EQP_WP_West_mg_020, --ALM 48 Grade 2 (7e3) X
			TppEquip.EQP_WP_East_mg_010, --LPG-61 Grade 4 (Grade 3 - 7020, Grade 4 - 7021) X
			TppEquip.EQP_WP_West_mg_021, --ALM 48 Grade 4 (7002) X
			TppEquip.EQP_WP_West_mg_030, --ALM 48 Grade 5 (7003) X
		},
		MISSILE={
			TppEquip.EQP_WP_East_ms_010, --Grom-11 Grade 2 (8e3) X
			TppEquip.EQP_WP_West_ms_010, --FB MR R-Launcher Grade 3 (8010) X
			--r42 remove multiple killer bees, this will also improve chances of above two appearing
			--r42    TppEquip.EQP_WP_HoneyBee, --Honey Bee Grade 1, equal to Killer Bee Grade 3 (Not developable, Killer Bee Grade 3 - 8020)
			--r42    TppEquip.EQP_WP_Com_ms_010, --Killer Bee Grade 3 (8020) X
			TppEquip.EQP_WP_Com_ms_020, --Killer Bee Grade 5 (8022) X
		},
		SHIELD={
			--    TppEquip.EQP_SLD_DD_G03, --DD Only for MB DD Staff, Skip this index for enemy soldiers (9e3) X
			TppEquip.EQP_SLD_SV, --Soviet (Not developable - 50056)
			TppEquip.EQP_SLD_PF_01, --PF_A (Not developable - 50058)
			TppEquip.EQP_SLD_PF_00, --PF_B (Not developable - 50057)
			TppEquip.EQP_SLD_PF_02, --PF_C (Not developable - 50059)
		--r47 Do not use DLC SHIELD for enemy soldiers
		--    TppEquip.EQP_WP_SP_SLD_030, --WEAPON_PB_SHIELD_SIL DLC Grade 2 (9010)
		--    TppEquip.EQP_WP_SP_SLD_010, --WEAPON_PB_SHIELD_OD DLC Grade 2 (9011)
		--    TppEquip.EQP_WP_SP_SLD_020, --WEAPON_PB_SHIELD_WHT DLC Grade 2 (9012)
		--    TppEquip.EQP_WP_SP_SLD_040, --WEAPON_PB_SHIELD_GLD DLC Grade 2 (9013)
		}
}

--r40 Select weapons table - create DD weapons table
--r42 Add more DD weapons
function this.PrepareUsableWeaponsTable()
	--r51 Settings
	if not TUPPMSettings.rev_ENABLE_weaponsVariety then return end
	
	if TppMission.IsFOBMission(vars.missionCode) then return end

	if
		--MB free roam should build a table
		not TppMission.IsMbFreeMissions(vars.missionCode)
		--r45 Mission specific fix
		--M2 should build a table
		and vars.missionCode~=10030
		--r45 Mission specific fix
		--M43 should build a table
		and vars.missionCode~=10240
	then
		return this.usableWeaponsTable
	end

	local usableWeaponsTable={
		HANDGUN={
			--r47 Are used for M43
			--r47 Enable all HANDGUN
			TppEquip.EQP_WP_East_hg_010, --Burkov Grade 1 (1020)
			TppEquip.EQP_WP_West_hg_010, --AM D114 Grade 1 (1010)
			TppEquip.EQP_WP_West_hg_020, --AM D114 Grade 4 + FL + SUP (1013)
			TppEquip.EQP_WP_EX_hg_013, --Tornado Grade 7 *BEST* (1100 - Grade 3 Tornado, Grade 7 is 1103)
			TppEquip.EQP_WP_SP_hg_020, --WEAPON_ADAM_SKA_SP DLC Grade 3 (1090)
			TppEquip.EQP_WP_SP_hg_010, --WEAPON_WU_S333_CB_SP DLC	Grade 3 (1091)
		},
		SMG={
		},
		ASSAULT={
			TppEquip.EQP_WP_West_ar_040, --AM MRS-4 Grade 1
			TppEquip.EQP_WP_East_ar_010, --SVG-76 Grade 1
			TppEquip.EQP_WP_East_ar_010_FL, --SVG-76 Grade 1 + FL
		},
		SNIPER={
		},
		SHOTGUN={
		},
		MG={
		},
		MISSILE={
		},
		SHIELD={
		}
	}

	----SMG
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=2010} then
		table.insert(usableWeaponsTable.SMG, TppEquip.EQP_WP_West_sm_010) --ZE'EV Grade 3
	end
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=2020} then
		table.insert(usableWeaponsTable.SMG, TppEquip.EQP_WP_West_sm_020 ) --Mach 37 Grade 3
	end
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=2001} then
		table.insert(usableWeaponsTable.SMG, TppEquip.EQP_WP_East_sm_010) --Sz. 336 Grade 3
		table.insert(usableWeaponsTable.SMG, TppEquip.EQP_WP_East_sm_030) --Sz. 336 Grade 3 + SUP + FL
	end
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=2003} then
		table.insert(usableWeaponsTable.SMG, TppEquip.EQP_WP_East_sm_020 ) --Sz. 336 CS Grade 5
	end
	--r47 Add DLC SMG when all are developed
	if
		(TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=2010}
		and TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=2020}
		and TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=2001}
		and TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=2003})
		or TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=2030}
	then
		table.insert(usableWeaponsTable.SMG, TppEquip.EQP_WP_SP_sm_010 ) --WEAPON_MACHT_P5_WEISS DLC Grade 3 (2030)
	end

	----ASSAULT
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=3036} then
		table.insert(usableWeaponsTable.ASSAULT, TppEquip.EQP_WP_West_ar_010) --AM MRS-4R Grade 3
		table.insert(usableWeaponsTable.ASSAULT, TppEquip.EQP_WP_West_ar_010_FL) --AM MRS-4R Grade 3 +FL, grouping slightly higher + FL
	end
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=3056} then
		table.insert(usableWeaponsTable.ASSAULT, TppEquip.EQP_WP_West_ar_030) --UN-ARC-PT CS Grade 4 + FL
	end
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=3038} then
		table.insert(usableWeaponsTable.ASSAULT, TppEquip.EQP_WP_West_ar_050) --AM MRS-4R Grade 5
	end
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=3006} then
		table.insert(usableWeaponsTable.ASSAULT, TppEquip.EQP_WP_East_ar_020) --SVG-67 Grade 4
	end
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=3007} then
		table.insert(usableWeaponsTable.ASSAULT, TppEquip.EQP_WP_East_ar_030) --SVG-67 CS Grade 6
		table.insert(usableWeaponsTable.ASSAULT, TppEquip.EQP_WP_East_ar_030_FL) --SVG-67 CS Grade 6 + FL
	end

	----SNIPER
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=6e3} then
		table.insert(usableWeaponsTable.SNIPER, TppEquip.EQP_WP_East_sr_011) --Renov-ICKX CS Grade 1
	end
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=6010} then
		table.insert(usableWeaponsTable.SNIPER, TppEquip.EQP_WP_West_sr_010) --M2000-D Grade 2
		table.insert(usableWeaponsTable.SNIPER, TppEquip.EQP_WP_West_sr_011) --M2000-D CS Grade 2
	end
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=6021} then
		table.insert(usableWeaponsTable.SNIPER, TppEquip.EQP_WP_East_sr_020) --Bambetov SV CS Grade 4
	end
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=6032} then
		table.insert(usableWeaponsTable.SNIPER, TppEquip.EQP_WP_West_sr_020) --AM MRS-71 CS Grade 5
	end
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=6050} then
		table.insert(usableWeaponsTable.SNIPER, TppEquip.EQP_WP_EX_sr_000) --Molotok-68 Grade 9
	end

	----SHOTGUN
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=4020} then
		table.insert(usableWeaponsTable.SHOTGUN, TppEquip.EQP_WP_Com_sg_011) --S1000 CS Grade 2
		table.insert(usableWeaponsTable.SHOTGUN, TppEquip.EQP_WP_Com_sg_011_FL) --S1000 CS Grade 2 + FL
	end
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=4041} then
		table.insert(usableWeaponsTable.SHOTGUN, TppEquip.EQP_WP_Com_sg_020) --Kabarga 83 Grade 4
		table.insert(usableWeaponsTable.SHOTGUN, TppEquip.EQP_WP_Com_sg_020_FL) --Kabarga 83 Grade 4 + FL
	end
	--r47 Add DLC SHOTGUN when all are developed
	if
		(TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=4020}
		and TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=4041})
		or TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=4060}
	then
		table.insert(usableWeaponsTable.SMG, TppEquip.EQP_WP_SP_sg_010 ) --WEAPON_RASP_SB_SG_GOLD DLC Grade 3 (4060) --broken firing for NPCs but at least OK for MB
	end

	----MG
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=7010} then
		table.insert(usableWeaponsTable.MG, TppEquip.EQP_WP_West_mg_010) --UN-AAM Grade 2
	end
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=7e3} then
		table.insert(usableWeaponsTable.MG, TppEquip.EQP_WP_West_mg_020) --ALM 48 Grade 2
	end
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=7021} then
		table.insert(usableWeaponsTable.MG, TppEquip.EQP_WP_East_mg_010) --LPG-61 Grade 4
	end
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=7002} then
		table.insert(usableWeaponsTable.MG, TppEquip.EQP_WP_West_mg_021) --ALM 48 Grade 4
	end
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=7003} then
		table.insert(usableWeaponsTable.MG, TppEquip.EQP_WP_West_mg_030) --ALM 48 Grade 5
	end

	----MISSILE
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=8e3} then
		table.insert(usableWeaponsTable.MISSILE, TppEquip.EQP_WP_East_ms_010) --Grom-11 Grade 2
	end
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=8010} then
		table.insert(usableWeaponsTable.MISSILE, TppEquip.EQP_WP_West_ms_010) --FB MR R-Launcher Grade 3
	end
	--Use higher grade killer bee first
	if TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=8022} then
		table.insert(usableWeaponsTable.MISSILE, TppEquip.EQP_WP_Com_ms_020) --Killer Bee Grade 5
	elseif TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=8020} then
		table.insert(usableWeaponsTable.MISSILE, TppEquip.EQP_WP_Com_ms_010) --Killer Bee Grade 3
	end

	----SHIELD
	--r47 Enable all shield varieties if even one is developed
	if
		TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=9e3}
		or TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=9010}
		or TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=9011}
		or TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=9012}
		or TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=9013}
	then
		table.insert(usableWeaponsTable.SHIELD, TppEquip.EQP_SLD_DD_G03) --Grade 3 Shield
		--rX47 Allow DLC Shields for DD
		table.insert(usableWeaponsTable.SHIELD, TppEquip.EQP_WP_SP_SLD_030) --WEAPON_PB_SHIELD_SIL DLC Grade 2 (9010)
		table.insert(usableWeaponsTable.SHIELD, TppEquip.EQP_WP_SP_SLD_010) --WEAPON_PB_SHIELD_OD DLC Grade 2 (9011)
		table.insert(usableWeaponsTable.SHIELD, TppEquip.EQP_WP_SP_SLD_020) --WEAPON_PB_SHIELD_WHT DLC Grade 2 (9012)
		table.insert(usableWeaponsTable.SHIELD, TppEquip.EQP_WP_SP_SLD_040) --WEAPON_PB_SHIELD_GLD DLC Grade 2 (9013)
	end

	return usableWeaponsTable
end

--r41 reset to vanilla
this.weaponIdTable={
	SOVIET_A={
		NORMAL={
			HANDGUN=TppEquip.EQP_WP_East_hg_010,
			SMG=TppEquip.EQP_WP_East_sm_010,
			ASSAULT=TppEquip.EQP_WP_East_ar_010,
			SNIPER=TppEquip.EQP_WP_East_sr_011,
			SHOTGUN=TppEquip.EQP_WP_Com_sg_011,
			MG=TppEquip.EQP_WP_East_mg_010,
			MISSILE=TppEquip.EQP_WP_East_ms_010,
			SHIELD=TppEquip.EQP_SLD_SV},
		STRONG={
			HANDGUN=TppEquip.EQP_WP_East_hg_010,
			SMG=TppEquip.EQP_WP_East_sm_020,
			ASSAULT=TppEquip.EQP_WP_East_ar_030,
			SNIPER=TppEquip.EQP_WP_East_sr_020,
			SHOTGUN=TppEquip.EQP_WP_Com_sg_020,
			MG=TppEquip.EQP_WP_East_mg_010,
			MISSILE=TppEquip.EQP_WP_Com_ms_010,
			SHIELD=TppEquip.EQP_SLD_SV}
	},
	PF_A={
		NORMAL={
			HANDGUN=TppEquip.EQP_WP_West_hg_010,
			SMG=TppEquip.EQP_WP_West_sm_010,
			ASSAULT=TppEquip.EQP_WP_West_ar_010,
			SNIPER=TppEquip.EQP_WP_West_sr_011,
			SHOTGUN=TppEquip.EQP_WP_Com_sg_011,
			MG=TppEquip.EQP_WP_West_mg_010,
			MISSILE=TppEquip.EQP_WP_West_ms_010,
			SHIELD=TppEquip.EQP_SLD_PF_01},
		STRONG={
			HANDGUN=TppEquip.EQP_WP_West_hg_010,
			SMG=TppEquip.EQP_WP_West_sm_020,
			ASSAULT=TppEquip.EQP_WP_West_ar_020,
			SNIPER=TppEquip.EQP_WP_West_sr_020,
			SHOTGUN=TppEquip.EQP_WP_Com_sg_020,
			MG=TppEquip.EQP_WP_West_mg_010,
			MISSILE=TppEquip.EQP_WP_Com_ms_010,
			SHIELD=TppEquip.EQP_SLD_PF_01}
	},
	PF_B={
		NORMAL={
			HANDGUN=TppEquip.EQP_WP_West_hg_010,
			SMG=TppEquip.EQP_WP_West_sm_010,
			ASSAULT=TppEquip.EQP_WP_West_ar_010,
			SNIPER=TppEquip.EQP_WP_West_sr_011,
			SHOTGUN=TppEquip.EQP_WP_Com_sg_011,
			MG=TppEquip.EQP_WP_West_mg_010,
			MISSILE=TppEquip.EQP_WP_West_ms_010,
			SHIELD=TppEquip.EQP_SLD_PF_00},
		STRONG={
			HANDGUN=TppEquip.EQP_WP_West_hg_010,
			SMG=TppEquip.EQP_WP_West_sm_020,
			ASSAULT=TppEquip.EQP_WP_West_ar_020,
			SNIPER=TppEquip.EQP_WP_West_sr_020,
			SHOTGUN=TppEquip.EQP_WP_Com_sg_020,
			MG=TppEquip.EQP_WP_West_mg_010,
			MISSILE=TppEquip.EQP_WP_Com_ms_010,
			SHIELD=TppEquip.EQP_SLD_PF_00}
	},
	PF_C={
		NORMAL={
			HANDGUN=TppEquip.EQP_WP_West_hg_010,
			SMG=TppEquip.EQP_WP_West_sm_010,
			ASSAULT=TppEquip.EQP_WP_West_ar_010,
			SNIPER=TppEquip.EQP_WP_West_sr_011,
			SHOTGUN=TppEquip.EQP_WP_Com_sg_011,
			MG=TppEquip.EQP_WP_West_mg_010,
			MISSILE=TppEquip.EQP_WP_West_ms_010,
			SHIELD=TppEquip.EQP_SLD_PF_02},
		STRONG={
			HANDGUN=TppEquip.EQP_WP_West_hg_010,
			SMG=TppEquip.EQP_WP_West_sm_020,
			ASSAULT=TppEquip.EQP_WP_West_ar_020,
			SNIPER=TppEquip.EQP_WP_West_sr_020,
			SHOTGUN=TppEquip.EQP_WP_Com_sg_020,
			MG=TppEquip.EQP_WP_West_mg_010,
			MISSILE=TppEquip.EQP_WP_Com_ms_010,
			SHIELD=TppEquip.EQP_SLD_PF_02}
	},
	DD=nil,
	SKULL_CYPR={
		NORMAL={
			HANDGUN=TppEquip.EQP_WP_West_hg_020,
			SMG=TppEquip.EQP_WP_East_sm_030}
	},
	SKULL={
		NORMAL={
			HANDGUN=TppEquip.EQP_WP_West_hg_020,
			SMG=TppEquip.EQP_WP_West_sm_020,
			ASSAULT=TppEquip.EQP_WP_West_ar_030,
			SNIPER=TppEquip.EQP_WP_West_sr_020,
			SHOTGUN=TppEquip.EQP_WP_Com_sg_011,
			MG=TppEquip.EQP_WP_West_mg_020,
			MISSILE=TppEquip.EQP_WP_West_ms_010,
			SHIELD=TppEquip.EQP_SLD_PF_02},
		STRONG={
			HANDGUN=TppEquip.EQP_WP_West_hg_020,
			SMG=TppEquip.EQP_WP_West_sm_020,
			ASSAULT=TppEquip.EQP_WP_West_ar_030,
			SNIPER=TppEquip.EQP_WP_West_sr_020,
			SHOTGUN=TppEquip.EQP_WP_Com_sg_020,
			MG=TppEquip.EQP_WP_West_mg_020,
			MISSILE=TppEquip.EQP_WP_Com_ms_010,
			SHIELD=TppEquip.EQP_SLD_PF_02}
	},
	CHILD={
		NORMAL={
			HANDGUN=TppEquip.EQP_WP_East_hg_010,
			ASSAULT=TppEquip.EQP_WP_East_ar_020}
	}
}

this.gunLightWeaponIds={[TppEquip.EQP_WP_Com_sg_011]=TppEquip.EQP_WP_Com_sg_011_FL,[TppEquip.EQP_WP_Com_sg_020]=TppEquip.EQP_WP_Com_sg_020_FL,[TppEquip.EQP_WP_West_ar_010]=TppEquip.EQP_WP_West_ar_010_FL,[TppEquip.EQP_WP_West_ar_020]=TppEquip.EQP_WP_West_ar_020_FL,[TppEquip.EQP_WP_East_ar_010]=TppEquip.EQP_WP_East_ar_010_FL,[TppEquip.EQP_WP_East_ar_030]=TppEquip.EQP_WP_East_ar_030_FL}
local n=MbsDevelopedEquipType or{}
this.DDWeaponIdInfo={HANDGUN={{equipId=TppEquip.EQP_WP_West_hg_010}},SMG={{equipId=TppEquip.EQP_WP_East_sm_04b,isNoKill=true,developedEquipType=n.SM_2040_NOKILL,developId=2102},{equipId=TppEquip.EQP_WP_East_sm_04a,isNoKill=true,developedEquipType=n.SM_2040_NOKILL,developId=2101},{equipId=TppEquip.EQP_WP_East_sm_049,isNoKill=true,developedEquipType=n.SM_2040_NOKILL,developId=2100},{equipId=TppEquip.EQP_WP_East_sm_047,isNoKill=true,developedEquipType=n.SM_2040_NOKILL,developId=2044},{equipId=TppEquip.EQP_WP_East_sm_045,isNoKill=true,developedEquipType=n.SM_2040_NOKILL,developId=2043},{equipId=TppEquip.EQP_WP_East_sm_044,isNoKill=true,developedEquipType=n.SM_2040_NOKILL,developId=2042},{equipId=TppEquip.EQP_WP_East_sm_043,isNoKill=true,developedEquipType=n.SM_2040_NOKILL,developId=2041},{equipId=TppEquip.EQP_WP_East_sm_042,isNoKill=true,developedEquipType=n.SM_2040_NOKILL,developId=2040},{equipId=TppEquip.EQP_WP_West_sm_01b,developedEquipType=n.SM_2014,developId=2072},{equipId=TppEquip.EQP_WP_West_sm_01a,developedEquipType=n.SM_2014,developId=2071},{equipId=TppEquip.EQP_WP_West_sm_019,developedEquipType=n.SM_2014,developId=2070},{equipId=TppEquip.EQP_WP_West_sm_017,developedEquipType=n.SM_2014,developId=2014},{equipId=TppEquip.EQP_WP_West_sm_016,developedEquipType=n.SM_2010,developId=2013},{equipId=TppEquip.EQP_WP_West_sm_015,developedEquipType=n.SM_2010,developId=2012},{equipId=TppEquip.EQP_WP_West_sm_014,developedEquipType=n.SM_2010,developId=2011},{equipId=TppEquip.EQP_WP_West_sm_010,developedEquipType=n.SM_2010,developId=2010}},SHOTGUN={{equipId=TppEquip.EQP_WP_Com_sg_038,isNoKill=true,developedEquipType=n.SG_4027_NOKILL,developId=4028},{equipId=TppEquip.EQP_WP_Com_sg_030,isNoKill=true,developedEquipType=n.SG_4027_NOKILL,developId=4027},{equipId=TppEquip.EQP_WP_Com_sg_025,isNoKill=true,developedEquipType=n.SG_4035_NOKILL,developId=4037},{equipId=TppEquip.EQP_WP_Com_sg_024,isNoKill=true,developedEquipType=n.SG_4035_NOKILL,developId=4036},{equipId=TppEquip.EQP_WP_Com_sg_023,isNoKill=true,developedEquipType=n.SG_4035_NOKILL,developId=4035},{equipId=TppEquip.EQP_WP_Com_sg_018,developedEquipType=n.SG_4040,developId=4044},{equipId=TppEquip.EQP_WP_Com_sg_016,developedEquipType=n.SG_4040,developId=4043},{equipId=TppEquip.EQP_WP_Com_sg_015,developedEquipType=n.SG_4040,developId=4042},{equipId=TppEquip.EQP_WP_Com_sg_020,developedEquipType=n.SG_4040,developId=4041},{equipId=TppEquip.EQP_WP_Com_sg_013,developedEquipType=n.SG_4040,developId=4040},{equipId=TppEquip.EQP_WP_Com_sg_011,developedEquipType=n.SG_4020,developId=4020}},ASSAULT={{equipId=TppEquip.EQP_WP_West_ar_07b,isNoKill=true,developedEquipType=n.AR_3060_NOKILL,developId=3132},{equipId=TppEquip.EQP_WP_West_ar_07a,isNoKill=true,developedEquipType=n.AR_3060_NOKILL,developId=3131},{equipId=TppEquip.EQP_WP_West_ar_079,isNoKill=true,developedEquipType=n.AR_3060_NOKILL,developId=3130},{equipId=TppEquip.EQP_WP_West_ar_077,isNoKill=true,developedEquipType=n.AR_3060_NOKILL,developId=3064},{equipId=TppEquip.EQP_WP_West_ar_075,isNoKill=true,developedEquipType=n.AR_3060_NOKILL,developId=3063},{equipId=TppEquip.EQP_WP_West_ar_070,isNoKill=true,developedEquipType=n.AR_3060_NOKILL,developId=3062},{equipId=TppEquip.EQP_WP_West_ar_063,isNoKill=true,developedEquipType=n.AR_3060_NOKILL,developId=3061},{equipId=TppEquip.EQP_WP_West_ar_060,isNoKill=true,developedEquipType=n.AR_3060_NOKILL,developId=3060},{equipId=TppEquip.EQP_WP_West_ar_05b,developedEquipType=n.AR_3036,developId=3102},{equipId=TppEquip.EQP_WP_West_ar_05a,developedEquipType=n.AR_3036,developId=3101},{equipId=TppEquip.EQP_WP_West_ar_059,developedEquipType=n.AR_3036,developId=3100},{equipId=TppEquip.EQP_WP_West_ar_057,developedEquipType=n.AR_3036,developId=3042},{equipId=TppEquip.EQP_WP_West_ar_050,developedEquipType=n.AR_3036,developId=3038},{equipId=TppEquip.EQP_WP_West_ar_055,developedEquipType=n.AR_3036,developId=3037},{equipId=TppEquip.EQP_WP_West_ar_010,developedEquipType=n.AR_3036,developId=3036},{equipId=TppEquip.EQP_WP_West_ar_042,developedEquipType=n.AR_3030,developId=3031},{equipId=TppEquip.EQP_WP_West_ar_040}},SNIPER={{equipId=TppEquip.EQP_WP_West_sr_04b,isNoKill=true,developedEquipType=n.SR_6037_NOKILL,developId=6132},{equipId=TppEquip.EQP_WP_West_sr_04a,isNoKill=true,developedEquipType=n.SR_6037_NOKILL,developId=6131},{equipId=TppEquip.EQP_WP_West_sr_049,isNoKill=true,developedEquipType=n.SR_6037_NOKILL,developId=6130},{equipId=TppEquip.EQP_WP_West_sr_048,isNoKill=true,developedEquipType=n.SR_6037_NOKILL,developId=6039},{equipId=TppEquip.EQP_WP_West_sr_047,isNoKill=true,developedEquipType=n.SR_6037_NOKILL,developId=6038},{equipId=TppEquip.EQP_WP_West_sr_037,isNoKill=true,developedEquipType=n.SR_6037_NOKILL,developId=6037},{equipId=TppEquip.EQP_WP_East_sr_034,isNoKill=true,developedEquipType=n.SR_6005_NOKILL,developId=6006},{equipId=TppEquip.EQP_WP_East_sr_033,isNoKill=true,developedEquipType=n.SR_6005_NOKILL,developId=6008},{equipId=TppEquip.EQP_WP_East_sr_032,isNoKill=true,developedEquipType=n.SR_6005_NOKILL,developId=6005},{equipId=TppEquip.EQP_WP_West_sr_02b,developedEquipType=n.SR_6030,developId=6102},{equipId=TppEquip.EQP_WP_West_sr_02a,developedEquipType=n.SR_6030,developId=6101},{equipId=TppEquip.EQP_WP_West_sr_029,developedEquipType=n.SR_6030,developId=6100},{equipId=TppEquip.EQP_WP_West_sr_027,developedEquipType=n.SR_6030,developId=6033},{equipId=TppEquip.EQP_WP_West_sr_020,developedEquipType=n.SR_6030,developId=6032},{equipId=TppEquip.EQP_WP_West_sr_014,developedEquipType=n.SR_6030,developId=6031},{equipId=TppEquip.EQP_WP_West_sr_013,developedEquipType=n.SR_6030,developId=6030},{equipId=TppEquip.EQP_WP_West_sr_011,developedEquipType=n.SR_6010,developId=6010}},MG={{equipId=TppEquip.EQP_WP_West_mg_03b,developedEquipType=n.MG_7000,developId=7052},{equipId=TppEquip.EQP_WP_West_mg_03a,developedEquipType=n.MG_7000,developId=7051},{equipId=TppEquip.EQP_WP_West_mg_039,developedEquipType=n.MG_7000,developId=7050},{equipId=TppEquip.EQP_WP_West_mg_037,developedEquipType=n.MG_7000,developId=7004},{equipId=TppEquip.EQP_WP_West_mg_030,developedEquipType=n.MG_7000,developId=7003},{equipId=TppEquip.EQP_WP_West_mg_024,developedEquipType=n.MG_7000,developId=7002},{equipId=TppEquip.EQP_WP_West_mg_023,developedEquipType=n.MG_7000,developId=7001},{equipId=TppEquip.EQP_WP_West_mg_020,developedEquipType=n.MG_7000,developId=7e3}},MISSILE={{equipId=TppEquip.EQP_WP_West_ms_02b,isNoKill=true,developedEquipType=n.MS_8013_NOKILL,developId=8072},{equipId=TppEquip.EQP_WP_West_ms_02a,isNoKill=true,developedEquipType=n.MS_8013_NOKILL,developId=8071},{equipId=TppEquip.EQP_WP_West_ms_029,isNoKill=true,developedEquipType=n.MS_8013_NOKILL,developId=8070},{equipId=TppEquip.EQP_WP_West_ms_020,isNoKill=true,developedEquipType=n.MS_8013_NOKILL,developId=8013},{equipId=TppEquip.EQP_WP_Com_ms_02b,developedEquipType=n.MS_8020,developId=8052},{equipId=TppEquip.EQP_WP_Com_ms_02a,developedEquipType=n.MS_8020,developId=8051},{equipId=TppEquip.EQP_WP_Com_ms_029,developedEquipType=n.MS_8020,developId=8050},{equipId=TppEquip.EQP_WP_Com_ms_026,developedEquipType=n.MS_8020,developId=8023},{equipId=TppEquip.EQP_WP_Com_ms_020,developedEquipType=n.MS_8020,developId=8022},{equipId=TppEquip.EQP_WP_Com_ms_024,developedEquipType=n.MS_8020,developId=8021},{equipId=TppEquip.EQP_WP_Com_ms_023,developedEquipType=n.MS_8020,developId=8020}},SHIELD={{equipId=TppEquip.EQP_SLD_DD,developedEquipType=n.SD_9000,developId=9e3}},GRENADE={{equipId=TppEquip.EQP_SWP_Grenade_G08,developedEquipType=n.GRENADE,developId=11122},{equipId=TppEquip.EQP_SWP_Grenade_G07,developedEquipType=n.GRENADE,developId=11121},{equipId=TppEquip.EQP_SWP_Grenade_G06,developedEquipType=n.GRENADE,developId=11120},{equipId=TppEquip.EQP_SWP_Grenade_G05,developedEquipType=n.GRENADE,developId=10045},{equipId=TppEquip.EQP_SWP_Grenade_G04,developedEquipType=n.GRENADE,developId=10044},{equipId=TppEquip.EQP_SWP_Grenade_G03,developedEquipType=n.GRENADE,developId=10043},{equipId=TppEquip.EQP_SWP_Grenade_G02,developedEquipType=n.GRENADE,developId=10042},{equipId=TppEquip.EQP_SWP_Grenade_G01,developedEquipType=n.GRENADE,developId=10041},{equipId=TppEquip.EQP_SWP_Grenade}},STUN_GRENADE={{equipId=TppEquip.EQP_SWP_StunGrenade_G06,isNoKill=true,developedEquipType=n.STUN_GRENADE,developId=11152},{equipId=TppEquip.EQP_SWP_StunGrenade_G05,isNoKill=true,developedEquipType=n.STUN_GRENADE,developId=11151},{equipId=TppEquip.EQP_SWP_StunGrenade_G04,isNoKill=true,developedEquipType=n.STUN_GRENADE,developId=11150},{equipId=TppEquip.EQP_SWP_StunGrenade_G03,isNoKill=true,developedEquipType=n.STUN_GRENADE,developId=10063},{equipId=TppEquip.EQP_SWP_StunGrenade_G02,isNoKill=true,developedEquipType=n.STUN_GRENADE,developId=10062},{equipId=TppEquip.EQP_SWP_StunGrenade_G01,isNoKill=true,developedEquipType=n.STUN_GRENADE,developId=10061},{equipId=TppEquip.EQP_SWP_StunGrenade,isNoKill=true,developedEquipType=n.STUN_GRENADE,developId=10060}},SNEAKING_SUIT={{equipId=9,isNoKill=true,developedEquipType=n.SNEAKING_SUIT,developId=19302},{equipId=8,isNoKill=true,developedEquipType=n.SNEAKING_SUIT,developId=19301},{equipId=7,isNoKill=true,developedEquipType=n.SNEAKING_SUIT,developId=19300},{equipId=6,isNoKill=true,developedEquipType=n.SNEAKING_SUIT,developId=19042},{equipId=5,isNoKill=true,developedEquipType=n.SNEAKING_SUIT,developId=19057},{equipId=4,isNoKill=true,developedEquipType=n.SNEAKING_SUIT,developId=19056},{equipId=3,isNoKill=true,developedEquipType=n.SNEAKING_SUIT,developId=19052},{equipId=2,isNoKill=true,developedEquipType=n.SNEAKING_SUIT,developId=19051},{equipId=1,isNoKill=true,developedEquipType=n.SNEAKING_SUIT,developId=19050}},BATTLE_DRESS={{equipId=9,developedEquipType=n.BATTLE_DRESS,developId=19352},{equipId=8,developedEquipType=n.BATTLE_DRESS,developId=19351},{equipId=7,developedEquipType=n.BATTLE_DRESS,developId=19350},{equipId=6,developedEquipType=n.BATTLE_DRESS,developId=19043},{equipId=5,developedEquipType=n.BATTLE_DRESS,developId=19059},{equipId=4,developedEquipType=n.BATTLE_DRESS,developId=19058},{equipId=3,developedEquipType=n.BATTLE_DRESS,developId=19055},{equipId=2,developedEquipType=n.BATTLE_DRESS,developId=19054},{equipId=1,developedEquipType=n.BATTLE_DRESS,developId=19053}}}
do
	this.ROUTE_SET_TYPETAG[StrCode32"day"]="day"
	this.ROUTE_SET_TYPETAG[StrCode32"night"]="night"
	this.ROUTE_SET_TYPETAG[StrCode32"caution"]="caution"
	this.ROUTE_SET_TYPETAG[StrCode32"hold"]="hold"
	this.ROUTE_SET_TYPETAG[StrCode32"travel"]="travel"
	this.ROUTE_SET_TYPETAG[StrCode32"new"]="new"
	this.ROUTE_SET_TYPETAG[StrCode32"old"]="old"
	this.ROUTE_SET_TYPETAG[StrCode32"midnight"]="midnight"
	this.ROUTE_SET_TYPETAG[StrCode32"sleep"]="sleep"
end
this.DEFAULT_HOLD_TIME=60
this.DEFAULT_TRAVEL_HOLD_TIME=15
this.DEFAULT_SLEEP_TIME=300
this.FOB_DD_SUIT_ATTCKER=1
this.FOB_DD_SUIT_SNEAKING=2
this.FOB_DD_SUIT_BTRDRS=3
this.FOB_PF_SUIT_ARMOR=4
function this._ConvertSoldierNameKeysToId(e)
	local t={}
	local n={}
	Tpp.MergeTable(n,e)
	for n,s in pairs(n)do
		if IsTypeString(n)then
			local i=GetGameObjectId("TppSoldier2",n)
			if i~=NULL_ID then
				table.insert(t,n)e[i]=s
			end
		end
	end
	for t,n in ipairs(t)do
		e[n]=nil
	end
end
function this._SetUpSoldierTypes(t,n)
	for a,n in ipairs(n)do
		if IsTypeTable(n)then
			this._SetUpSoldierTypes(t,n)
		else
			mvars.ene_soldierTypes[n]=EnemyType["TYPE_"..t]
		end
	end
end
function this.SetUpSoldierTypes(n)
	for n,t in pairs(n)do
		this._SetUpSoldierTypes(n,t)
	end
end
function this._SetUpSoldierSubTypes(t,n)
	for a,n in ipairs(n)do
		if IsTypeTable(n)then
			this._SetUpSoldierSubTypes(t,n)
		else
			local e=GetGameObjectId("TppSoldier2",n)
			mvars.ene_soldierSubType[e]=t
		end
	end
end
function this.SetUpSoldierSubTypes(n)
	for n,t in pairs(n)do
		this._SetUpSoldierSubTypes(n,t)
	end
end
function this.SetUpPowerSettings(e)
	mvars.ene_missionSoldierPowerSettings=e
	local n={}
	for t,e in pairs(e)do
		for e,t in pairs(e)do
			local e=e
			if Tpp.IsTypeNumber(e)then
				e=t
			end
			n[e]=true
		end
	end
	mvars.ene_missionRequiresPowerSettings=n
end
function this.ApplyPowerSettingsOnInitialize()
	local n=mvars.ene_missionSoldierPowerSettings
	for n,t in pairs(n)do
		local n=GetGameObjectId(n)
		if n==NULL_ID then
		else
			this.ApplyPowerSetting(n,t)
		end
	end
end
function this.DisablePowerSettings(e)
	local n={ASSAULT=true,HANDGUN=true}
	mvars.ene_disablePowerSettings={}
	for t,e in ipairs(e)do
		if n[e]then
		else
			mvars.ene_disablePowerSettings[e]=true
		end
	end
	if mvars.ene_disablePowerSettings.SMG then
		mvars.ene_disablePowerSettings.MISSILE=true
		mvars.ene_disablePowerSettings.SHIELD=true
	end
end
function this.SetUpPersonalAbilitySettings(e)
	mvars.ene_missionSoldierPersonalAbilitySettings=e
end
function this.ApplyPersonalAbilitySettingsOnInitialize()
	local n=mvars.ene_missionSoldierPersonalAbilitySettings
	for n,t in pairs(n)do
		local n=GetGameObjectId(n)
		if n==NULL_ID then
		else
			this.ApplyPersonalAbilitySettings(n,t)
		end
	end
end
function this.SetSoldierType(n,e)
	mvars.ene_soldierTypes[n]=e
	GameObject.SendCommand(n,{id="SetSoldier2Type",type=e})
end
function this.GetSoldierType(n)
	local e=TppMission.GetMissionID()
	if n==nil or n==NULL_ID then
		if e==10080 or e==11080 then
			return EnemyType.TYPE_PF
		end
		for n,e in pairs(mvars.ene_soldierTypes)do
			if e then
				return e
			end
		end
	else
		if mvars.ene_soldierTypes then
			local e=mvars.ene_soldierTypes[n]
			if e then
				return e
			end
		end
	end
	if(e==10150 or e==10151)or e==11151 then
		return EnemyType.TYPE_SKULL
	end
	local e=EnemyType.TYPE_SOVIET
	if TppLocation.IsAfghan()then
		e=EnemyType.TYPE_SOVIET
	elseif TppLocation.IsMiddleAfrica()then
		e=EnemyType.TYPE_PF
	elseif TppLocation.IsMotherBase()or TppLocation.IsMBQF()then
		e=EnemyType.TYPE_DD
	elseif TppLocation.IsCyprus()then
		e=EnemyType.TYPE_SKULL
	end
	return e
end
function this.SetSoldierSubType(e,n)
	mvars.ene_soldierSubType[e]=n
end
function this.GetSoldierSubType(t,a)
	local n=TppMission.GetMissionID()
	if n==10115 or n==11115 then
		return"DD_PW"end
	if TppMission.IsFOBMission(n)then
		return"DD_FOB"end
	local n=nil
	if mvars.ene_soldierSubType then
		n=mvars.ene_soldierSubType[t]
	end
	if n==nil then
		n=this.GetDefaultSoldierSubType(a)
	end
	return n
end
function this.GetCpSubType(t)
	if mvars.ene_soldierIDList then
		local n=mvars.ene_soldierIDList[t]
		if n~=nil then
			for n,t in pairs(n)do
				return this.GetSoldierSubType(n)
			end
		end
	end
	if mvars.ene_cpList then
		local n=mvars.ene_cpList[t]
		local e=this.subTypeOfCp[n]
		if e~=nil then
			return e
		end
	end
	return this.GetSoldierSubType(nil)
end
function this.GetDefaultSoldierSubType(n)
	if n==nil then
		n=this.GetSoldierType(nil)
	end
	if TppLocation.IsCyprus()then
		return"SKULL_CYPR"end
	if n==EnemyType.TYPE_SOVIET then
		return"SOVIET_A"elseif n==EnemyType.TYPE_PF then
		return"PF_A"elseif n==EnemyType.TYPE_DD then
		return"DD_A"elseif n==EnemyType.TYPE_SKULL then
		return"SKULL_AFGH"elseif n==EnemyType.TYPE_CHILD then
		return"CHILD_A"else
		return"SOVIET_A"end
	return nil
end
function this._CreateDDWeaponIdTable(developedEquipGradeTable,soldierEquipGrade,isNoKillMode) --r28 update
	local ddWeaponIdTable={NORMAL={}} --r28 update
	local ddWeaponNORMALTable=ddWeaponIdTable.NORMAL
	mvars.ene_ddWeaponCount=0
	ddWeaponNORMALTable.IS_NOKILL={}
	local e=this.DDWeaponIdInfo
	for a,e in pairs(e)do
		for n,e in ipairs(e)do
			local n=false
			local i=e.developedEquipType
			if i==nil then
				n=true
			elseif e.isNoKill and not isNoKillMode then
				n=false
			else
				local e=e.developId
				local e=TppMotherBaseManagement.GetEquipDevelopRank(e)
				if(soldierEquipGrade>=e and developedEquipGradeTable[i]>=e)then
					n=true
				end
			end
			if n then
				mvars.ene_ddWeaponCount=mvars.ene_ddWeaponCount+1
				if ddWeaponNORMALTable[a]then
				else
					ddWeaponNORMALTable[a]=e.equipId
					if e.isNoKill then
						ddWeaponNORMALTable.IS_NOKILL[a]=true
					end
				end
			end
		end
	end

	--r42 BUGFIX
	--Turns out it is important to have the table formed at least, otherwise DD only get ASSAULT
	--r46 Need to form table for MBQF as well
	--r51 Settings
	if TUPPMSettings.rev_ENABLE_weaponsVariety and TppMission.IsMbFreeMissions(vars.missionCode) then
		ddWeaponIdTable={
			NORMAL={
				HANDGUN={},
				SMG={},
				ASSAULT={},
				SNIPER={},
				SHOTGUN={},
				MG={},
				MISSILE={},
				SHIELD={}
			},
			STRONG={
				HANDGUN={},
				SMG={},
				ASSAULT={},
				SNIPER={},
				SHOTGUN={},
				MG={},
				MISSILE={},
				SHIELD={}
			}
		}
	end

	return ddWeaponIdTable
end
function this.GetDDWeaponCount()
	return mvars.ene_ddWeaponCount
end
function this.ClearDDParameter()
	this.weaponIdTable.DD=nil
end
function this.PrepareDDParameter(t,a)
	if TppMotherBaseManagement.GetMbsDevelopedEquipGradeTable==nil then
		this.weaponIdTable.DD={NORMAL={HANDGUN=TppEquip.EQP_WP_West_hg_010,ASSAULT=TppEquip.EQP_WP_West_ar_040}}
		return
	end
	local i=TppMotherBaseManagement.GetMbsDevelopedEquipGradeTable()t=t or 9999
	if gvars.ini_isTitleMode then
		this.ClearDDParameter()
	end
	if this.weaponIdTable.DD~=nil then
	else
		this.weaponIdTable.DD=this._CreateDDWeaponIdTable(i,t,a)
	end
	local a=i[n.FULTON_16001]
	local i=i[n.FULTON_16008]
	if a>t then
		a=t
	end
	if i>t then
		i=t
	end
	local n=0
	if a>=4 then
		n=3
	elseif a>=3 then
		n=2
	elseif a>=1 then
		n=1
	end
	local t=false
	if i~=0 then
		t=true
	end
	this.weaponIdTable.DD.NORMAL.FULTON_LV=n
	this.weaponIdTable.DD.NORMAL.WORMHOLE_FULTON=t
end
function this.SetUpDDParameter()
	if not GameObject.DoesGameObjectExistWithTypeName"TppSoldier2"then
		return
	end
	local t={type="TppCommandPost2"}
	local n={id="SetFultonLevel",fultonLevel=this.weaponIdTable.DD.NORMAL.FULTON_LV,isWormHole=this.weaponIdTable.DD.NORMAL.WORMHOLE_FULTON}
	GameObject.SendCommand(t,n)
	if(this.weaponIdTable.DD.NORMAL.SNEAKING_SUIT and this.weaponIdTable.DD.NORMAL.SNEAKING_SUIT>=3)or(this.weaponIdTable.DD.NORMAL.BATTLE_DRESS and this.weaponIdTable.DD.NORMAL.BATTLE_DRESS>=3)then
		TppRevenge.SetHelmetAll()
	end
	local n=this.weaponIdTable.DD.NORMAL.GRENADE or TppEquip.EQP_SWP_Grenade
	local e=this.weaponIdTable.DD.NORMAL.STUN_GRENADE or TppEquip.EQP_None
	GameObject.SendCommand({type="TppSoldier2"},{id="RegistGrenadeId",grenadeId=n,stunId=e})
end
function this.GetWeaponIdTable(t,a)
	local n={}
	local n={}
	if t==EnemyType.TYPE_SOVIET then
		n=this.weaponIdTable.SOVIET_A
	elseif t==EnemyType.TYPE_PF then
		n=this.weaponIdTable.PF_A
		if a=="PF_B"then
			n=this.weaponIdTable.PF_B
		elseif a=="PF_C"then
			n=this.weaponIdTable.PF_C
		end
	elseif t==EnemyType.TYPE_DD then
		n=this.weaponIdTable.DD
	elseif t==EnemyType.TYPE_SKULL then
		if a=="SKULL_CYPR"then
			n=this.weaponIdTable.SKULL_CYPR
		else
			n=this.weaponIdTable.SKULL
		end
	elseif t==EnemyType.TYPE_CHILD then
		n=this.weaponIdTable.CHILD
	else
		n=this.weaponIdTable.SOVIET_A
	end
	return n
end

function this.GetWeaponId(soldierId,config)
	local primary,secondary,tertiary
	local soldierType=this.GetSoldierType(soldierId)
	local soldierSubType=this.GetSoldierSubType(soldierId,soldierType)
	local missionCode=TppMission.GetMissionID()
	if(missionCode==10080 or missionCode==11080)and soldierType==EnemyType.TYPE_CHILD then
		return TppEquip.EQP_WP_Wood_ar_010,TppEquip.EQP_WP_West_hg_010,nil
	end
	local weaponIdTableFull=this.GetWeaponIdTable(soldierType,soldierSubType)
	if weaponIdTableFull==nil then
		return nil,nil,nil
	end
	local currentWeaponIdTable={}
	if TppRevenge.IsUsingStrongWeapon()and weaponIdTableFull.STRONG then
		currentWeaponIdTable=weaponIdTableFull.STRONG
	else
		currentWeaponIdTable=weaponIdTableFull.NORMAL
	end
	tertiary=TppEquip.EQP_None
	secondary=currentWeaponIdTable.HANDGUN
	local sniperWeaponTable={}
	if TppRevenge.IsUsingStrongSniper()and weaponIdTableFull.STRONG then
		sniperWeaponTable=weaponIdTableFull.STRONG
	else
		sniperWeaponTable=weaponIdTableFull.NORMAL
	end
	local missileWeaponTable={}
	if TppRevenge.IsUsingStrongMissile()and weaponIdTableFull.STRONG then
		missileWeaponTable=weaponIdTableFull.STRONG
	else
		missileWeaponTable=weaponIdTableFull.NORMAL
	end
	if config.SNIPER and sniperWeaponTable.SNIPER then
		primary=sniperWeaponTable.SNIPER
	elseif config.SHOTGUN and currentWeaponIdTable.SHOTGUN then
		primary=currentWeaponIdTable.SHOTGUN
	elseif config.MG and currentWeaponIdTable.MG then
		primary=currentWeaponIdTable.MG
	elseif config.SMG and currentWeaponIdTable.SMG then
		primary=currentWeaponIdTable.SMG
	else
		primary=currentWeaponIdTable.ASSAULT
	end
	if config.SHIELD and currentWeaponIdTable.SHIELD then
		tertiary=currentWeaponIdTable.SHIELD
	elseif config.MISSILE and missileWeaponTable.MISSILE then
		tertiary=missileWeaponTable.MISSILE
	end

	--r40 Weapon varieties
	local usableWeaponsTable=this.PrepareUsableWeaponsTable()
	
	if usableWeaponsTable then
		--r43 BUGFIX - MB not loading because weapon tables would have zero entries
		-- if no weapons developed - not necessary here but still good practice
		if #usableWeaponsTable.HANDGUN~=0 then
			local index=math.random(1,#usableWeaponsTable.HANDGUN)
			secondary=usableWeaponsTable.HANDGUN[index]
		end
	
		if config.SNIPER and #usableWeaponsTable.SNIPER~=0 then
			TppMain.Randomize()
			local index=math.random(1,#usableWeaponsTable.SNIPER)
			primary=usableWeaponsTable.SNIPER[index]
		elseif config.SHOTGUN and #usableWeaponsTable.SHOTGUN~=0 then
			TppMain.Randomize()
			local index=math.random(1,#usableWeaponsTable.SHOTGUN)
			primary=usableWeaponsTable.SHOTGUN[index]
		elseif config.MG and #usableWeaponsTable.MG~=0 then
			local index=math.random(1,#usableWeaponsTable.MG)
			primary=usableWeaponsTable.MG[index]
		elseif config.SMG and #usableWeaponsTable.SMG~=0 then
			TppMain.Randomize()
			local index=math.random(1,#usableWeaponsTable.SMG)
			primary=usableWeaponsTable.SMG[index]
		elseif #usableWeaponsTable.ASSAULT~=0 then
			TppMain.Randomize()
			local index=math.random(1,#usableWeaponsTable.ASSAULT)
			primary=usableWeaponsTable.ASSAULT[index]
		end
		--r42 fixed shield code for DD staff
		if config.SHIELD and currentWeaponIdTable.SHIELD then
			TppMain.Randomize()
			tertiary=currentWeaponIdTable.SHIELD
	
			--r40 Randomize shields for XOF - they are mercenaries who have been around the globe afterall XD
			--r47 Better logic
			if (soldierType==EnemyType.TYPE_SKULL or soldierType==EnemyType.TYPE_DD) and #usableWeaponsTable.SHIELD~=0 then
				TppMain.Randomize()
				local index=math.random(1,#usableWeaponsTable.SHIELD)
				tertiary=usableWeaponsTable.SHIELD[index]
				--        TUPPMLog.Log("TYPE_SKULL or TYPE_DD usableWeaponsTable.SHIELD: "..tostring(usableWeaponsTable.SHIELD[index]))
			end
		elseif config.MISSILE and #usableWeaponsTable.MISSILE~=0 then
			TppMain.Randomize()
			local index=math.random(1,#usableWeaponsTable.MISSILE)
			tertiary=usableWeaponsTable.MISSILE[index]
		end
	end

	--TODO rX42 Add gun light to all weapons
	if config.GUN_LIGHT then
		local e=this.gunLightWeaponIds[primary] --made a return(\n) here
		primary=e or primary
	end
	return primary,secondary,tertiary
end

function this.GetBodyId(soldierID,cpType,cpSubType,config)
	local bodyIdSelected
	local cpTypeBodyIdTable={}
	if cpType==EnemyType.TYPE_SOVIET then
		cpTypeBodyIdTable=this.bodyIdTable.SOVIET_A
		if cpSubType=="SOVIET_B"then
			cpTypeBodyIdTable=this.bodyIdTable.SOVIET_B
		end
	elseif cpType==EnemyType.TYPE_PF then
		cpTypeBodyIdTable=this.bodyIdTable.PF_A
		if cpSubType=="PF_B"then
			cpTypeBodyIdTable=this.bodyIdTable.PF_B
		elseif cpSubType=="PF_C"then
			cpTypeBodyIdTable=this.bodyIdTable.PF_C
		end
	elseif cpType==EnemyType.TYPE_DD then
		cpTypeBodyIdTable=this.bodyIdTable.DD_A
		if cpSubType=="DD_FOB"then
			cpTypeBodyIdTable=this.bodyIdTable.DD_FOB
		elseif cpSubType=="DD_PW"then
			cpTypeBodyIdTable=this.bodyIdTable.DD_PW
		end
	elseif cpType==EnemyType.TYPE_SKULL then
		if this.bodyIdTable[cpSubType]then
			cpTypeBodyIdTable=this.bodyIdTable[cpSubType]
		else
			cpTypeBodyIdTable=this.bodyIdTable.SKULL_AFGH
		end
	elseif cpType==EnemyType.TYPE_CHILD then
		cpTypeBodyIdTable=this.bodyIdTable.CHILD
	else
		cpTypeBodyIdTable=this.bodyIdTable.SOVIET_A
	end
	if cpTypeBodyIdTable==nil then
		return nil
	end

	local selectBodyId=function(soldierId,bodyId)
		if#bodyId==0 then
			return bodyId[1]
		end
		return bodyId[(soldierId%#bodyId)+1] --rX7 soldier type IDs start with a particular number then?
	end

	if config.ARMOR and cpTypeBodyIdTable.ARMOR then
		return selectBodyId(soldierID,cpTypeBodyIdTable.ARMOR)
	end
	if(mvars.ene_soldierLrrp[soldierID]or config.RADIO)and cpTypeBodyIdTable.RADIO then
		return selectBodyId(soldierID,cpTypeBodyIdTable.RADIO)
	end
	if config.MISSILE and cpTypeBodyIdTable.MISSILE then
		return selectBodyId(soldierID,cpTypeBodyIdTable.MISSILE)
	end
	if config.SHIELD and cpTypeBodyIdTable.SHIELD then
		return selectBodyId(soldierID,cpTypeBodyIdTable.SHIELD)
	end
	if config.SNIPER and cpTypeBodyIdTable.SNIPER then
		bodyIdSelected=selectBodyId(soldierID,cpTypeBodyIdTable.SNIPER)
	elseif config.SHOTGUN and cpTypeBodyIdTable.SHOTGUN then
		if config.OB and cpTypeBodyIdTable.SHOTGUN_OB then
			bodyIdSelected=selectBodyId(soldierID,cpTypeBodyIdTable.SHOTGUN_OB)
		else
			bodyIdSelected=selectBodyId(soldierID,cpTypeBodyIdTable.SHOTGUN)
		end
	elseif config.MG and cpTypeBodyIdTable.MG then
		if config.OB and cpTypeBodyIdTable.MG_OB then
			bodyIdSelected=selectBodyId(soldierID,cpTypeBodyIdTable.MG_OB)
		else
			bodyIdSelected=selectBodyId(soldierID,cpTypeBodyIdTable.MG)
		end
	elseif cpTypeBodyIdTable.ASSAULT then
		if config.OB and cpTypeBodyIdTable.ASSAULT_OB then
			bodyIdSelected=selectBodyId(soldierID,cpTypeBodyIdTable.ASSAULT_OB)
		else
			bodyIdSelected=selectBodyId(soldierID,cpTypeBodyIdTable.ASSAULT)
		end
	end
	return bodyIdSelected
end
function this.GetFaceId(n,e,n,n)
	if e==EnemyType.TYPE_SKULL then
		return EnemyFova.INVALID_FOVA_VALUE
	elseif e==EnemyType.TYPE_DD then
		return EnemyFova.INVALID_FOVA_VALUE
	elseif e==EnemyType.TYPE_CHILD then
		return 630
	end
	return nil
end
function this.GetBalaclavaFaceId(t,e,t,n)
	if e==EnemyType.TYPE_SKULL then
		return EnemyFova.NOT_USED_FOVA_VALUE
	elseif e==EnemyType.TYPE_DD then
		if n.HELMET then
			return TppEnemyFaceId.dds_balaclava0
		else
			return TppEnemyFaceId.dds_balaclava2
		end
	end
	return nil
end
function this.IsSniper(e)
	local e=mvars.ene_soldierPowerSettings[e]
	if e~=nil and e.SNIPER then
		return true
	end
	return false
end
function this.IsMissile(e)
	local e=mvars.ene_soldierPowerSettings[e]
	if e~=nil and e.MISSILE then
		return true
	end
	return false
end
function this.IsShield(e)
	local e=mvars.ene_soldierPowerSettings[e]
	if e~=nil and e.SHIELD then
		return true
	end
	return false
end
function this.IsArmor(soldierId)
	local e=mvars.ene_soldierPowerSettings[soldierId]
	if e~=nil and e.ARMOR then
		return true
	end
	return false
end
function this.IsHelmet(e)
	local e=mvars.ene_soldierPowerSettings[e]
	if e~=nil and e.HELMET then
		return true
	end
	return false
end
function this.IsNVG(e)
	local e=mvars.ene_soldierPowerSettings[e]
	if e~=nil and e.NVG then
		return true
	end
	return false
end
function this.AddPowerSetting(n,a)
	local t=mvars.ene_soldierPowerSettings[n]or{}
	for a,n in pairs(a)do
		t[a]=n
	end
	this.ApplyPowerSetting(n,t)
end

--r28 update
function this.ApplyPowerSetting(soldierID,powerSettingsTable)

	--K this function decides enemy equipment combinations for outposts(not guardposts or patrols) and for reinforcements
	-- is called from TppRevenge.ApplyPowerSettingsForReinforce(r) only for reinforcements
	if soldierID==NULL_ID then
		return
	end

	local cpType=this.GetSoldierType(soldierID)
	local cpSubType=this.GetSoldierSubType(soldierID,cpType)
	local finalPowerSettings={}

	for e,t in pairs(powerSettingsTable)do
		if Tpp.IsTypeNumber(e)then
			finalPowerSettings[t]=true
		else
			finalPowerSettings[e]=t
		end
	end

	local o={
		SMG=true,
		MG=true,
		SHOTGUN=true,
		SNIPER=true,
		MISSILE=true,
		--    GRENADE=true, --TODO WIP try
		--    STUN_GRENADE=true,
		--    SMOKE_GRENADE=true,
		--    GRENADE_LAUNCHER=true,
		SHIELD=true
	}

	for e,t in pairs(o)do
		if finalPowerSettings[e]and not mvars.revenge_loadedEquip[e]then
			finalPowerSettings[e]=nil
		end
	end

	if cpType==EnemyType.TYPE_SKULL then
		if cpSubType=="SKULL_CYPR"then
			finalPowerSettings.SNIPER=nil
			finalPowerSettings.SHOTGUN=nil
			finalPowerSettings.MG=nil
			finalPowerSettings.SMG=true
			finalPowerSettings.GUN_LIGHT=true
		else
			finalPowerSettings.HELMET=true
			finalPowerSettings.SOFT_ARMOR=true --default for in case ARMOR is disabled by 'not TppRevenge.CanUseArmor(a)'
			--finalPowerSettings.ARMOR=true --does not work even when armor is enabled for Mission 30 - Skull Face in TppEneFova
		end
	end

	if finalPowerSettings.ARMOR and not TppRevenge.CanUseArmor(cpSubType)then
		finalPowerSettings.ARMOR=nil
	end

	if finalPowerSettings.QUEST_ARMOR then
		finalPowerSettings.ARMOR=true
	end

	--r43 WildCard Soldiers power handling - if any issues come up
	if finalPowerSettings.WILDCARDED then
		--    TUPPMLog.Log("WildCard soldier ID: "..tostring(soldierID))
		finalPowerSettings.ARMOR=nil --true does not work
	end

	--r13
	--removing power settings for CHILDren, important for missions with CHILDren in them
	if TppEnemy.GetSoldierType(soldierID)==EnemyType.TYPE_CHILD then
		--TUPPMLog.Log("is child in TppEnemy")
		finalPowerSettings.GAS_MASK=nil
--		finalPowerSettings.HELMET=nil --r51 TEST!
		finalPowerSettings.NVG=nil
		finalPowerSettings.SOFT_ARMOR=nil
		finalPowerSettings.ARMOR=nil
		finalPowerSettings.STRONG_WEAPON=nil
		finalPowerSettings.MG=nil
		finalPowerSettings.SHOTGUN=nil
		finalPowerSettings.SHIELD=nil
		finalPowerSettings.SNIPER=nil
		finalPowerSettings.MISSILE=nil
	end

	--r41 Better FOB check --r13
	--r51 Settings
	if TUPPMSettings.rev_ENABLE_weaponCombos and not TppMission.IsFOBMission(vars.missionCode) then
		local randomVariable = math.random() --r13

		--r15 More randomization for weapons and blocked weapons handling
		if finalPowerSettings.ARMOR then

			if finalPowerSettings.MG or finalPowerSettings.SHOTGUN then

				local chanceMG = 0.34
				local chanceSHOTGUN = 0.67
				local chanceASSAULT = 1

				if not (TppRevenge.IsIgnoreBlocked() or not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.MG)) then
					chanceMG = 0
				end

				if not (TppRevenge.IsIgnoreBlocked() or not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.SHOTGUN)) then
					chanceSHOTGUN = 0
				end

				if chanceSHOTGUN == 0 then
					if chanceMG~=0 then
						chanceMG=chanceMG+0.16
					end
				end

				if chanceMG == 0 then
					if chanceSHOTGUN~=0 then
						chanceSHOTGUN=chanceSHOTGUN-0.17
					end
				end

				local isWeaponSet=false
				while not isWeaponSet do
					--r27 More random
					TppMain.Randomize()
					randomVariable = math.random()
					if randomVariable <= chanceMG and (TppRevenge.IsIgnoreBlocked() or not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.MG)) then
						finalPowerSettings.SHOTGUN=nil
						finalPowerSettings.SMG=nil
						finalPowerSettings.MG=true  --true
						finalPowerSettings.SNIPER=nil
						--finalPowerSettings.MISSILE=nil
						finalPowerSettings.SHIELD=nil
						finalPowerSettings.ASSAULT=nil
						isWeaponSet=true
						TppMain.Randomize()
					elseif randomVariable <= chanceSHOTGUN and (TppRevenge.IsIgnoreBlocked() or not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.SHOTGUN)) then
						finalPowerSettings.SMG=nil
						finalPowerSettings.MG=nil
						finalPowerSettings.SHOTGUN=true  --true
						finalPowerSettings.SNIPER=nil
						--finalPowerSettings.MISSILE=nil
						finalPowerSettings.SHIELD=nil
						finalPowerSettings.ASSAULT=nil
						isWeaponSet=true
						TppMain.Randomize()
					elseif randomVariable <= chanceASSAULT then
						finalPowerSettings.SMG=nil
						finalPowerSettings.MG=nil
						finalPowerSettings.SHOTGUN=nil
						finalPowerSettings.SNIPER=nil
						--finalPowerSettings.MISSILE=nil
						finalPowerSettings.SHIELD=nil
						finalPowerSettings.ASSAULT=true --true
						isWeaponSet=true
						TppMain.Randomize()
					end
				end
			end

			if finalPowerSettings.SNIPER then
				finalPowerSettings.SMG=nil
				finalPowerSettings.MG=nil
				finalPowerSettings.SHOTGUN=nil
				finalPowerSettings.SNIPER=true  --true
				finalPowerSettings.MISSILE=nil
				finalPowerSettings.SHIELD=nil
				finalPowerSettings.ASSAULT=nil
			end
		end

		--K r09 new logic for randomizing non ARMOR CP weapons
		if finalPowerSettings.MISSILE and not finalPowerSettings.ARMOR then

			local chanceSMG = 0.25
			local chanceMG = 0.5
			local chanceSHOTGUN = 0.75
			local chanceASSAULT = 1

			if not (TppRevenge.IsIgnoreBlocked() or not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.MG)) then
				chanceMG = 0
			end

			if not (TppRevenge.IsIgnoreBlocked() or not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.SHOTGUN)) then
				chanceSHOTGUN = 0
			end

			if chanceSHOTGUN == 0 then
				if chanceMG~=0 then
					chanceMG=chanceMG+0.17
					chanceSMG=chanceSMG+0.09
				end
			end

			if chanceMG == 0 then
				if chanceSHOTGUN~=0 then
					chanceSHOTGUN=chanceSHOTGUN-0.08
					chanceSMG=chanceSMG+0.09
				end
			end

			if chanceMG == 0 and chanceSHOTGUN == 0 then
				chanceSMG=chanceSMG+0.25
			end

			local isWeaponSet=false
			while not isWeaponSet do
				--r27 More random
				TppMain.Randomize()
				randomVariable = math.random()
				if randomVariable <= chanceSMG then
					finalPowerSettings.SNIPER=nil
					finalPowerSettings.SHOTGUN=nil
					finalPowerSettings.MG=nil
					finalPowerSettings.SMG=true  --true
					finalPowerSettings.ASSAULT=nil
					isWeaponSet=true
					TppMain.Randomize()
				elseif randomVariable <= chanceMG and (TppRevenge.IsIgnoreBlocked() or not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.MG)) then
					finalPowerSettings.SNIPER=nil
					finalPowerSettings.SHOTGUN=nil
					finalPowerSettings.MG=true  --true
					finalPowerSettings.SMG=nil
					finalPowerSettings.ASSAULT=nil
					isWeaponSet=true
					TppMain.Randomize()
				elseif randomVariable <= chanceSHOTGUN and (TppRevenge.IsIgnoreBlocked() or not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.SHOTGUN)) then
					finalPowerSettings.SNIPER=nil
					finalPowerSettings.SHOTGUN=true  --true
					finalPowerSettings.MG=nil
					finalPowerSettings.SMG=nil
					finalPowerSettings.ASSAULT=nil
					isWeaponSet=true
					TppMain.Randomize()
				elseif randomVariable <= chanceASSAULT then
					finalPowerSettings.SNIPER=nil
					finalPowerSettings.SHOTGUN=nil
					finalPowerSettings.MG=nil
					finalPowerSettings.SMG=nil
					finalPowerSettings.ASSAULT=true  --true
					isWeaponSet=true
					TppMain.Randomize()
				end
			end
		end

		--K r09 new logic for randomizing ARMOR CP weapons
		if finalPowerSettings.MISSILE and finalPowerSettings.ARMOR then

			local chanceSMG = 0.25
			local chanceMG = 0.5
			local chanceSHOTGUN = 0.75
			local chanceASSAULT = 1

			if not (TppRevenge.IsIgnoreBlocked() or not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.MG)) then
				chanceMG = 0
			end

			if not (TppRevenge.IsIgnoreBlocked() or not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.SHOTGUN)) then
				chanceSHOTGUN = 0
			end

			if chanceSHOTGUN == 0 then
				if chanceMG~=0 then
					chanceMG=chanceMG+0.17
					chanceSMG=chanceSMG+0.09
				end
			end

			if chanceMG == 0 then
				if chanceSHOTGUN~=0 then
					chanceSHOTGUN=chanceSHOTGUN-0.08
					chanceSMG=chanceSMG+0.09
				end
			end

			if chanceMG == 0 and chanceSHOTGUN == 0 then
				chanceSMG=chanceSMG+0.25
			end

			local isWeaponSet=false
			while not isWeaponSet do
				--r27 More random
				TppMain.Randomize()
				randomVariable = math.random()
				if randomVariable <= chanceSMG then
					finalPowerSettings.SNIPER=nil
					finalPowerSettings.SHOTGUN=nil
					finalPowerSettings.MG=nil
					finalPowerSettings.SMG=true  --true
					finalPowerSettings.ASSAULT=nil
					isWeaponSet=true
					TppMain.Randomize()
				elseif randomVariable <= chanceMG and (TppRevenge.IsIgnoreBlocked() or not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.MG)) then
					finalPowerSettings.SNIPER=nil
					finalPowerSettings.SHOTGUN=nil
					finalPowerSettings.MG=true  --true
					finalPowerSettings.SMG=nil
					finalPowerSettings.ASSAULT=nil
					isWeaponSet=true
					TppMain.Randomize()
				elseif randomVariable <= chanceSHOTGUN and (TppRevenge.IsIgnoreBlocked() or not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.SHOTGUN)) then
					finalPowerSettings.SNIPER=nil
					finalPowerSettings.SHOTGUN=true  --true
					finalPowerSettings.MG=nil
					finalPowerSettings.SMG=nil
					finalPowerSettings.ASSAULT=nil
					isWeaponSet=true
					TppMain.Randomize()
				elseif randomVariable <= chanceASSAULT then
					finalPowerSettings.SNIPER=nil
					finalPowerSettings.SHOTGUN=nil
					finalPowerSettings.MG=nil
					finalPowerSettings.SMG=nil
					finalPowerSettings.ASSAULT=true  --true
					isWeaponSet=true
					TppMain.Randomize()
				end
			end
		end

		--K r09 randomizing weapons for SHIELD CPs
		if finalPowerSettings.SHIELD then
			--n.ARMOR=nil --r12 commented for some reason

			local chanceSMG = 0.34
			local chanceSHOTGUN = 0.67
			local chanceASSAULT = 1

			if not (TppRevenge.IsIgnoreBlocked() or not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.SHOTGUN)) then
				chanceSHOTGUN = 0
			end

			if chanceSHOTGUN == 0 then
				chanceSMG=chanceSMG+0.16
			end

			local isWeaponSet=false
			while not isWeaponSet do
				--r27 More random
				TppMain.Randomize()
				randomVariable = math.random()
				if randomVariable <= chanceSMG then
					--n.SOFT_ARMOR=true --enables ARMOR for some some reason
					finalPowerSettings.SNIPER=nil
					finalPowerSettings.SHOTGUN=nil
					finalPowerSettings.MG=nil
					finalPowerSettings.SMG=true  --true
					finalPowerSettings.ASSAULT=nil
					isWeaponSet=true
					TppMain.Randomize()
				elseif randomVariable <= chanceSHOTGUN and (TppRevenge.IsIgnoreBlocked() or not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.SHOTGUN)) then
					--n.SOFT_ARMOR=true
					finalPowerSettings.SNIPER=nil
					finalPowerSettings.SHOTGUN=true  --true, very deadly combo
					finalPowerSettings.MG=nil
					finalPowerSettings.SMG=nil
					finalPowerSettings.ASSAULT=nil
					isWeaponSet=true
					TppMain.Randomize()
				elseif randomVariable <= chanceASSAULT then
					--n.SOFT_ARMOR=true
					finalPowerSettings.SNIPER=nil
					finalPowerSettings.SHOTGUN=nil
					finalPowerSettings.MG=nil
					finalPowerSettings.SMG=nil
					finalPowerSettings.ASSAULT=true  --true, works
					isWeaponSet=true
					TppMain.Randomize()
				end
			end
		end

		if finalPowerSettings.SNIPER then  --SNIPER is preferred over almost all other weapons, SHIELD not used with SNIPER
			finalPowerSettings.SMG=nil
			finalPowerSettings.MG=nil
			finalPowerSettings.SHOTGUN=nil
			finalPowerSettings.MISSILE=nil  --works but SNIPER only used
			finalPowerSettings.SHIELD=nil  --does not use SHIELD although it will be on soldier's back
		end

	else
		--r13 default logic for FOB events
		--TUPPMLog.Log("Default FOB logic")
		if finalPowerSettings.ARMOR then
			finalPowerSettings.SNIPER=nil
			finalPowerSettings.SHIELD=nil
			finalPowerSettings.MISSILE=nil
			finalPowerSettings.SMG=nil

			if not finalPowerSettings.SHOTGUN and not finalPowerSettings.MG then
				if mvars.revenge_loadedEquip.MG then
					finalPowerSettings.MG=true
				elseif mvars.revenge_loadedEquip.SHOTGUN then
					finalPowerSettings.SHOTGUN=true
				end
			end
			if finalPowerSettings.MG then
				finalPowerSettings.SHOTGUN=nil
			end
			if finalPowerSettings.SHOTGUN then
				finalPowerSettings.MG=nil
			end
		end

		if finalPowerSettings.MISSILE or finalPowerSettings.SHIELD then
			finalPowerSettings.SNIPER=nil
			finalPowerSettings.SHOTGUN=nil
			finalPowerSettings.MG=nil
			finalPowerSettings.SMG=true
		end

		if finalPowerSettings.GAS_MASK then
			--r41 BUGFIX
			if cpSubType~="DD_FOB"then
				finalPowerSettings.HELMET=nil
				finalPowerSettings.NVG=nil
			end
		end

		if finalPowerSettings.NVG then
			--r41 BUGFIX
			if cpSubType~="DD_FOB"then
				finalPowerSettings.HELMET=nil
				finalPowerSettings.GAS_MASK=nil
			end
		end

		if finalPowerSettings.HELMET then
			--r41 BUGFIX
			if cpSubType~="DD_FOB"then
				finalPowerSettings.GAS_MASK=nil
				finalPowerSettings.NVG=nil
			end
		end
	end --r13 end logic for FOB events

	mvars.ene_soldierPowerSettings[soldierID]=finalPowerSettings
	powerSettingsTable=finalPowerSettings
	local wearEquipFlag=0
	local bodyId=this.GetBodyId(soldierID,cpType,cpSubType,powerSettingsTable)
	local faceId=this.GetFaceId(soldierID,cpType,cpSubType,powerSettingsTable)
	local balaclavaFaceId=this.GetBalaclavaFaceId(soldierID,cpType,cpSubType,powerSettingsTable)
	local primary,secondary,tertiary=this.GetWeaponId(soldierID,powerSettingsTable)
	
	--rX41 moved this down to see if helmet pops off during headshot--No use
	if powerSettingsTable.HELMET then
		wearEquipFlag=wearEquipFlag+WearEquip.HELMET
	end
	if powerSettingsTable.GAS_MASK then
		wearEquipFlag=wearEquipFlag+WearEquip.GAS_MASK
	end
	if powerSettingsTable.NVG then
		wearEquipFlag=wearEquipFlag+WearEquip.NVG
	end
	if powerSettingsTable.SOFT_ARMOR then
		wearEquipFlag=wearEquipFlag+WearEquip.SOFT_ARMOR
	end
	
	if(primary~=nil or secondaryWeapon~=nil)or tertiary~=nil then
		GameObject.SendCommand(soldierID,{id="SetEquipId",primary=primary,secondary=secondary,tertiary=tertiary}
		)
	end

	--r51 Settings
	if TUPPMSettings.rev_ENABLE_strongerGrenades and not TppMission.IsFOBMission(vars.missionCode) then
		--r41 Enemies use strongest grenade type
		--Grenade types - works but Stun Grenades stun enemies also lol
		local grenadeId=TppEquip.EQP_SWP_Grenade_G08
		local stunId=TppEquip.EQP_None
		--  local stunId=TppEquip.EQP_SWP_StunGrenade_G06
		GameObject.SendCommand(soldierID,{id="RegistGrenadeId",grenadeId=grenadeId,stunId=stunId})
	end

	GameObject.SendCommand(soldierID,{id="ChangeFova",bodyId=bodyId,faceId=faceId,balaclavaFaceId=balaclavaFaceId})
	GameObject.SendCommand(soldierID,{id="SetWearEquip",flag=wearEquipFlag})
	local e={SOVIET_A=EnemySubType.SOVIET_A,SOVIET_B=EnemySubType.SOVIET_B,PF_A=EnemySubType.PF_A,PF_B=EnemySubType.PF_B,PF_C=EnemySubType.PF_C,DD_A=EnemySubType.DD_A,DD_FOB=EnemySubType.DD_FOB,DD_PW=EnemySubType.DD_PW,CHILD_A=EnemySubType.CHILD_A,SKULL_AFGH=EnemySubType.SKULL_AFGH,SKULL_CYPR=EnemySubType.SKULL_CYPR}
	GameObject.SendCommand(soldierID,{id="SetSoldier2SubType",type=e[cpSubType]})
end

function this.ApplyPersonalAbilitySettings(soldierID,finalDecidedAbilities)
	if soldierID==NULL_ID then
		return
	end
	mvars.ene_soldierPersonalAbilitySettings[soldierID]=finalDecidedAbilities
	GameObject.SendCommand(soldierID,{id="SetPersonalAbility",ability=finalDecidedAbilities})
end
function this.SetOccasionalChatList()
	if not GameObject.DoesGameObjectExistWithTypeName"TppSoldier2"then
		return
	end
	local chatList={}

	table.insert(chatList,"USSR_story_04")
	table.insert(chatList,"USSR_story_05")
	table.insert(chatList,"USSR_story_06")
	table.insert(chatList,"USSR_story_07")
	table.insert(chatList,"USSR_story_08")
	table.insert(chatList,"USSR_story_15")
	table.insert(chatList,"USSR_story_16")
	table.insert(chatList,"USSR_story_17")
	table.insert(chatList,"USSR_story_18")
	table.insert(chatList,"USSR_story_19")
	table.insert(chatList,"PF_story_01")
	table.insert(chatList,"PF_story_04")
	table.insert(chatList,"PF_story_05")
	table.insert(chatList,"PF_story_06")
	table.insert(chatList,"PF_story_07")
	table.insert(chatList,"PF_story_08")
	table.insert(chatList,"PF_story_12")
	table.insert(chatList,"PF_story_13")
	table.insert(chatList,"PF_story_14")
	table.insert(chatList,"PF_story_15")
	table.insert(chatList,"MB_story_07")
	table.insert(chatList,"MB_story_08")
	table.insert(chatList,"MB_story_18")
	table.insert(chatList,"MB_story_19")

	local storySequence=gvars.str_storySequence

	--r46 Add these dialogue always
	--r51 Settings
  if TUPPMSettings.rev_ENABLE_moreChatDialogue or storySequence<TppDefine.STORY_SEQUENCE.CLEARD_RESCUE_HUEY then
		table.insert(chatList,"USSR_story_01")
		table.insert(chatList,"USSR_story_02")
		table.insert(chatList,"USSR_story_03")
	end
	if not TppBuddyService.DidObtainBuddyType(BuddyType.QUIET)and not TppStory.IsMissionCleard(10050)then
		table.insert(chatList,"USSR_story_10")
	end
	if storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON then
		table.insert(chatList,"USSR_story_11")
	end

	--r46 Add these dialogue always
	--r51 Settings
  if storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON and (TUPPMSettings.rev_ENABLE_moreChatDialogue or storySequence<TppDefine.STORY_SEQUENCE.CLEARD_RESCUE_HUEY) then
		table.insert(chatList,"USSR_story_12")table.insert(chatList,"USSR_story_13")
	end

	--r46 Add these dialogue always
	--r51 Settings
	if storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON and (TUPPMSettings.rev_ENABLE_moreChatDialogue or storySequence<TppDefine.STORY_SEQUENCE.CLEARD_SKULLFACE) then
		table.insert(chatList,"USSR_story_14")
	end

	--r46 Add these dialogue always
	--r51 Settings
	if storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_DESTROY_THE_FLOW_STATION and (TUPPMSettings.rev_ENABLE_moreChatDialogue or storySequence<TppDefine.STORY_SEQUENCE.CLEARD_METALLIC_ARCHAEA) then
		table.insert(chatList,"PF_story_02")
	end

	--r46 Add these dialogue always
	--r51 Settings
	if storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_DESTROY_THE_FLOW_STATION and (TUPPMSettings.rev_ENABLE_moreChatDialogue or storySequence<TppDefine.STORY_SEQUENCE.CLEARD_ELIMINATE_THE_COMMANDER) then
		table.insert(chatList,"PF_story_03")
	end

	--r46 Add these dialogue always
	--r51 Settings
	if storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_DESTROY_THE_FLOW_STATION and (TUPPMSettings.rev_ENABLE_moreChatDialogue or storySequence<TppDefine.STORY_SEQUENCE.CLEARD_SKULLFACE) then
		table.insert(chatList,"PF_story_09")
	end

	--r46 Add these dialogue always
	--r51 Settings
	if storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_DESTROY_THE_FLOW_STATION and (TUPPMSettings.rev_ENABLE_moreChatDialogue or storySequence<TppDefine.STORY_SEQUENCE.CLEARD_CODE_TALKER) then
		table.insert(chatList,"PF_story_10")
	end
	if storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_DESTROY_THE_FLOW_STATION then
		table.insert(chatList,"PF_story_11")
	end
	
	--r55 Enabled this chat dialogue
	if((storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON and TppResult.GetTotalNeutralizeCount()<10) and TppResult.IsTotalPlayStyleStealth()) or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		table.insert(chatList,"MB_story_01")
	end
	
	if storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON and TppMotherBaseManagement.GetOgrePoint()>=5e4 then
		table.insert(chatList,"MB_story_02")
	end

	--r46 Add these dialogue always
	--r51 Settings
	if TppMotherBaseManagement.IsOpenedSection{section="Security"} and (TUPPMSettings.rev_ENABLE_moreChatDialogue or TppMotherBaseManagement.GetSectionLv{section="Security"}< 20) then
		--TODO Find what this dialogue is and revise if to always open it or not
		table.insert(chatList,"MB_story_03")
	end

	--r46 Add these dialogue always
	--r51 Settings
	if storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_ELIMINATE_THE_POWS and (TUPPMSettings.rev_ENABLE_moreChatDialogue or storySequence<TppDefine.STORY_SEQUENCE.CLEARD_MURDER_INFECTORS) then
		table.insert(chatList,"MB_story_04")
	end

	if TppTerminal.IsBuiltAnimalPlatform()then
		table.insert(chatList,"MB_story_05")
	end

	if TppBuddyService.DidObtainBuddyType(BuddyType.QUIET)and not TppBuddyService.IsDeadBuddyType(BuddyType.QUIET)then
		table.insert(chatList,"MB_story_09")
	end
	if(TppBuddyService.DidObtainBuddyType(BuddyType.DOG)and not TppBuddyService.CanSortieBuddyType(BuddyType.DOG))and not TppBuddyService.IsDeadBuddyType(BuddyType.DOG)then
		table.insert(chatList,"MB_story_10")
	end
	if(TppBuddyService.DidObtainBuddyType(BuddyType.DOG)and TppBuddyService.CanSortieBuddyType(BuddyType.DOG))and not TppBuddyService.IsDeadBuddyType(BuddyType.DOG)then
		table.insert(chatList,"MB_story_11")
	end


	if TppMotherBaseManagement.IsPandemicEventMode()then
		table.insert(chatList,"MB_story_12")
	end

	--r46 Add these dialogue always
	--r51 Settings
	if storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO and (TUPPMSettings.rev_ENABLE_moreChatDialogue or storySequence<TppDefine.STORY_SEQUENCE.CLEARD_MURDER_INFECTORS) then
		table.insert(chatList,"MB_story_13")
	end

	if storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO then
		table.insert(chatList,"MB_story_14")
	end

	if storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_MURDER_INFECTORS then
		table.insert(chatList,"MB_story_15")
	end

	--	TUPPMLog.Log("SetOccasionalChatList gvars.pazLookedPictureCount:"..tostring(gvars.pazLookedPictureCount),3)

	--r46 Add these dialogue always
	--r51 Settings
	if gvars.pazLookedPictureCount>=1 and (TUPPMSettings.rev_ENABLE_moreChatDialogue or gvars.pazLookedPictureCount<10) then
		table.insert(chatList,"MB_story_16")
	end

	if TppDemo.IsPlayedMBEventDemo"DecisionHuey"then
		table.insert(chatList,"MB_story_17")
	end

	--r46 Enabling revenge related stuff is easy since revenge levels are always obtained as max anyway

	--r46 Add these dialogue always
	--r51 Settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.FULTON)==1 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		table.insert(chatList,"USSR_revenge_01")
		table.insert(chatList,"PF_revenge_01")
	end

	--r55 Enabled additional chat dialogue since max revenge can be toggled via settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.FULTON)>=2 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		table.insert(chatList,"USSR_revenge_02")
		table.insert(chatList,"PF_revenge_02")
	end

	--r46 Add these dialogue always
	--r51 Settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)==1 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		table.insert(chatList,"USSR_revenge_03")
		table.insert(chatList,"PF_revenge_03")
	end

	--r46 Add these dialogue always
	--r51 Settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)==2 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		table.insert(chatList,"USSR_revenge_04")
		table.insert(chatList,"PF_revenge_04")
	end

	--r46 Add these dialogue always
	--r51 Settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)==3 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		table.insert(chatList,"USSR_revenge_05")
		table.insert(chatList,"PF_revenge_05")
	end

	--r46 Add these dialogue always
	--r51 Settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.STEALTH)==1 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		table.insert(chatList,"USSR_revenge_06")
		table.insert(chatList,"PF_revenge_06")
	end

	--r46 Add these dialogue always
	--r51 Settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.STEALTH)==2 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		table.insert(chatList,"USSR_revenge_07")
		table.insert(chatList,"PF_revenge_07")
	end

	--r46 Add these dialogue always
	--r51 Settings
	if (TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.HEAD_SHOT)==0 and TppRevenge.GetRevengePoint(TppRevenge.REVENGE_TYPE.HEAD_SHOT)>=50) or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		table.insert(chatList,"USSR_revenge_08")
		table.insert(chatList,"PF_revenge_08")
	end

	--r46 Add these dialogue always
	--r51 Settings
	if (TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.VEHICLE)==0 and TppRevenge.GetRevengePoint(TppRevenge.REVENGE_TYPE.VEHICLE)>=50) or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		table.insert(chatList,"USSR_revenge_09")
		table.insert(chatList,"PF_revenge_09")
	end

	--r46 Add these dialogue always
	--r51 Settings
	if (TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.VEHICLE)==0 and TppRevenge.GetRevengePoint(TppRevenge.REVENGE_TYPE.VEHICLE)>=50) or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		table.insert(chatList,"USSR_revenge_10")
		table.insert(chatList,"PF_revenge_10")
	end

	--r46 Add these dialogue always
	--r51 Settings
	if (TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.LONG_RANGE)==0 and TppRevenge.GetRevengePoint(TppRevenge.REVENGE_TYPE.LONG_RANGE)>=50) or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		table.insert(chatList,"USSR_revenge_11")
		table.insert(chatList,"PF_revenge_11")
	end

	--r46 Add these dialogue always
	--r51 Settings
	if (TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.NIGHT_S)==0 and TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.NIGHT_C)==0) or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		if TppRevenge.GetRevengePoint(TppRevenge.REVENGE_TYPE.NIGHT_S)>=50 or TppRevenge.GetRevengePoint(TppRevenge.REVENGE_TYPE.NIGHT_C)>=50 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
			table.insert(chatList,"USSR_revenge_12")
			table.insert(chatList,"PF_revenge_12")
		end
	end

	--r46 Add these dialogue always
	--r51 Settings
	if (TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.STEALTH)==3 and TppRevenge.GetRevengePoint(TppRevenge.REVENGE_TYPE.TRANQ)>0) or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		table.insert(chatList,"USSR_revenge_13")
		table.insert(chatList,"PF_revenge_13")
	end
	
	--r55 Enabled additional chat dialogue since max revenge can be toggled via settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.STEALTH)>=3 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.MINE)then
			table.insert(chatList,"USSR_counter_01")
			table.insert(chatList,"PF_counter_01")
		end
	end

	--r46 Vanilla Bug - Headshot max level is 7 - but will work fine
	--r51 Settings
	if (TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.HEAD_SHOT)>=1 and TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.HEAD_SHOT)<=9) or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.HELMET) then
			--    	TUPPMLog.Log("Added chat list for HEAD_SHOT<=9",3)
			table.insert(chatList,"USSR_counter_03")
			table.insert(chatList,"PF_counter_03")
		end
	end

	--r46 Vanilla Bug - Headshot max level is 7
	--  if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.HEAD_SHOT)==10 then
	--r51 Settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.HEAD_SHOT)==7 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.HELMET)then
			--    	TUPPMLog.Log("Added chat list for HEAD_SHOT==7",3)
			table.insert(chatList,"USSR_counter_04")
			table.insert(chatList,"PF_counter_04")
		end
	end
	
	--r55 Enabled additional chat dialogue since max revenge can be toggled via settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)>=1 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.SOFT_ARMOR)then
			table.insert(chatList,"USSR_counter_05")
			table.insert(chatList,"PF_counter_05")
		end
	end
	
	--r55 Enabled additional chat dialogue since max revenge can be toggled via settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)>=1 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.SHIELD)then
			table.insert(chatList,"USSR_counter_06")
			table.insert(chatList,"PF_counter_06")
		end
	end

	--r55 Enabled additional chat dialogue since max revenge can be toggled via settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.NIGHT_S)>=1 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.NVG)then
			table.insert(chatList,"USSR_counter_07")
			table.insert(chatList,"PF_counter_07")
		end
	end
	
	--r55 Enabled additional chat dialogue since max revenge can be toggled via settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.NIGHT_C)>=1 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.GUN_LIGHT)then
			table.insert(chatList,"USSR_counter_08")
			table.insert(chatList,"PF_counter_08")
		end
	end
	
	--r55 Enabled additional chat dialogue since max revenge can be toggled via settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)>=3 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.ARMOR)then
			table.insert(chatList,"USSR_counter_10")
			table.insert(chatList,"PF_counter_10")
		end
	end
	
	--r55 Enabled additional chat dialogue since max revenge can be toggled via settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)>=3 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		table.insert(chatList,"USSR_counter_11")
		table.insert(chatList,"PF_counter_11")
	end
	
	--r55 Enabled additional chat dialogue since max revenge can be toggled via settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)>=3 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		table.insert(chatList,"USSR_counter_12")
		table.insert(chatList,"PF_counter_12")
	end
	
	--r55 Enabled additional chat dialogue since max revenge can be toggled via settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)>=3 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		table.insert(chatList,"USSR_counter_13")
		table.insert(chatList,"PF_counter_13")
	end
	
	--r55 Enabled additional chat dialogue since max revenge can be toggled via settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)>=3 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		table.insert(chatList,"USSR_counter_14")
		table.insert(chatList,"PF_counter_14")
	end
	
	--r55 Enabled additional chat dialogue since max revenge can be toggled via settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)>=3 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.SHOTGUN)or not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.MG)then
			table.insert(chatList,"USSR_counter_15")
			table.insert(chatList,"PF_counter_15")
		end
	end
	
	--r55 Enabled additional chat dialogue since max revenge can be toggled via settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.LONG_RANGE)>=2 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.SNIPER)then
			table.insert(chatList,"USSR_counter_16")
			table.insert(chatList,"PF_counter_16")
		end
	end

	--r46 Add these dialogue always
	--r51 Settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.VEHICLE)==1 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.MISSILE)then
			table.insert(chatList,"USSR_counter_17")
			table.insert(chatList,"PF_counter_17")
		end
	end
	
	--r55 Enabled additional chat dialogue since max revenge can be toggled via settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.VEHICLE)>=2 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.MISSILE)then
			table.insert(chatList,"USSR_counter_18")
			table.insert(chatList,"PF_counter_18")
		end
	end
	
	--r55 Enabled additional chat dialogue since max revenge can be toggled via settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.STEALTH)>=2 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.DECOY)then
			table.insert(chatList,"USSR_counter_19")
			table.insert(chatList,"PF_counter_19")
		end
	end
	
	--r55 Enabled additional chat dialogue since max revenge can be toggled via settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.STEALTH)>=1 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		if not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.CAMERA)then
			table.insert(chatList,"USSR_counter_20")
			table.insert(chatList,"PF_counter_20")
		end
	end
	
	--r55 Enabled additional chat dialogue since max revenge can be toggled via settings
	if TppRevenge.GetRevengeLv(TppRevenge.REVENGE_TYPE.COMBAT)>=3 or TUPPMSettings.rev_ENABLE_moreChatDialogue then
		table.insert(chatList,"USSR_counter_22")
	end

	--rX48 randomizing order seems to make no diff, hell adding all the dialogues doesn't seemt to make a diff either - chats seem to play out from most to least latest story event
	--  TUPPMLog.Log("BEFORE chatList: "..tostring(InfInspect.Inspect(chatList)),1)
	--  chatList=this.ShuffleRoutes(chatList)
--	  TUPPMLog.Log("AFTER chatList: "..tostring(InfInspect.Inspect(chatList)),1)

	local objectType={type="TppSoldier2"}
	GameObject.SendCommand(objectType,{id="SetConversationList",list=chatList})
end
function this.SetSaluteVoiceList()
	if not GameObject.DoesGameObjectExistWithTypeName"TppSoldier2"then
		return
	end
	local highNormal={}
	local highOnce={}
	local midNormal={}
	local midOnce={}
	local lowNormal={}
	local lowOnce={}
	
	table.insert(lowNormal,"EVF010")
	table.insert(lowNormal,"salute0180")
	table.insert(lowNormal,"salute0220")
	table.insert(lowNormal,"salute0310")
	table.insert(lowNormal,"salute0320")
	table.insert(midNormal,"salute0410")
	table.insert(midNormal,"salute0420")
	
	local storySequence=gvars.str_storySequence

	if TppMotherBaseManagement.GetOgrePoint()>=5e4 then
		table.insert(highOnce,"salute0080")
	elseif Player.GetSmallFlyLevel()>=5 then
		table.insert(highOnce,"salute0050")
	elseif Player.GetSmallFlyLevel()>=3 then
		table.insert(highOnce,"salute0040")
	else
		table.insert(highOnce,"salute0060")
	end
	
	local staffCount=TppMotherBaseManagement.GetStaffCount()
	local totalStaffCountLimit=0
	totalStaffCountLimit=totalStaffCountLimit+TppMotherBaseManagement.GetSectionStaffCountLimit{section=TppMotherBaseManagementConst.SECTION_COMBAT}
	totalStaffCountLimit=totalStaffCountLimit+TppMotherBaseManagement.GetSectionStaffCountLimit{section=TppMotherBaseManagementConst.SECTION_DEVELOP}
	totalStaffCountLimit=totalStaffCountLimit+TppMotherBaseManagement.GetSectionStaffCountLimit{section=TppMotherBaseManagementConst.SECTION_BASE_DEV}
	totalStaffCountLimit=totalStaffCountLimit+TppMotherBaseManagement.GetSectionStaffCountLimit{section=TppMotherBaseManagementConst.SECTION_SUPPORT}
	totalStaffCountLimit=totalStaffCountLimit+TppMotherBaseManagement.GetSectionStaffCountLimit{section=TppMotherBaseManagementConst.SECTION_SPY}
	totalStaffCountLimit=totalStaffCountLimit+TppMotherBaseManagement.GetSectionStaffCountLimit{section=TppMotherBaseManagementConst.SECTION_MEDICAL}
	totalStaffCountLimit=totalStaffCountLimit+TppMotherBaseManagement.GetSectionStaffCountLimit{section=TppMotherBaseManagementConst.SECTION_SECURITY}
	local percStaffLimit=staffCount/totalStaffCountLimit
	
	if percStaffLimit<.2 then
		table.insert(lowNormal,"salute0100")
	elseif percStaffLimit<.4 then
		table.insert(lowNormal,"salute0090")
	elseif percStaffLimit>.8 then
		table.insert(lowNormal,"salute0120")
	end
	
	if TppMotherBaseManagement.GetGmp()<0 then
		table.insert(lowNormal,"salute0150")
	end
	
	if TppMotherBaseManagement.GetDevelopableEquipCount()>8 then
		table.insert(lowNormal,"salute0160")
	end
	
	if(TppMotherBaseManagement.GetResourceUsableCount{resource="CommonMetal"}<500 or TppMotherBaseManagement.GetResourceUsableCount{resource="FuelResource"}<200)or TppMotherBaseManagement.GetResourceUsableCount{resource="BioticResource"}<200 then
		table.insert(lowNormal,"salute0170")
	end
	
	if TppMotherBaseManagement.IsBuiltFirstFob()then
		table.insert(lowNormal,"salute0190")
	end
	
	if TppTerminal.IsReleaseSection"Combat"then
		table.insert(lowNormal,"salute0200")
	end
	
	if TppMotherBaseManagement.IsOpenedSectionFunc{sectionFuncId=TppMotherBaseManagementConst.SECTION_FUNC_ID_SUPPORT_BATTLE}then
		local n=TppMotherBaseManagement.GetSectionFuncRank{sectionFuncId=TppMotherBaseManagementConst.SECTION_FUNC_ID_SUPPORT_BATTLE}
		if n>=TppMotherBaseManagementConst.SECTION_FUNC_RANK_E then
			table.insert(lowNormal,"salute0230")
		end
	end
	if(TppBuddyService.DidObtainBuddyType(BuddyType.DOG)and not TppBuddyService.CanSortieBuddyType(BuddyType.DOG))and not TppBuddyService.IsDeadBuddyType(BuddyType.DOG)then
		table.insert(lowNormal,"salute0240")
	end
	if(TppBuddyService.DidObtainBuddyType(BuddyType.QUIET)and not TppBuddyService.CanSortieBuddyType(BuddyType.QUIET))and not TppBuddyService.IsDeadBuddyType(BuddyType.QUIET)then
		table.insert(lowNormal,"salute0250")
	end
	if TppMotherBaseManagement.GetResourceUsableCount{resource="Plant2000"}<100 or TppMotherBaseManagement.GetResourceUsableCount{resource="Plant2005"}<100 then
		table.insert(lowNormal,"salute0260")
	end
	if storySequence==TppDefine.STORY_SEQUENCE.CLEARD_TAKE_OUT_THE_CONVOY then
		table.insert(midNormal,"salute0270")
	end
	if TppMotherBaseManagement.IsPandemicEventMode()or storySequence==TppDefine.STORY_SEQUENCE.CLEARD_FLAG_MISSIONS_BEFORE_MURDER_INFECTORS then
		table.insert(midNormal,"salute0280")
	end
	--r51 Settings
	--r55 Adjusted salute dialogue conditions
	if storySequence==TppDefine.STORY_SEQUENCE.CLEARD_ELIMINATE_THE_POWS or (TUPPMSettings.mtbs_ENABLE_moreSaluteDialogue and storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_ELIMINATE_THE_POWS) then
		table.insert(midNormal,"salute0290")
	end
	if TppTerminal.IsBuiltAnimalPlatform()then
		table.insert(lowNormal,"salute0300")
	end
	--r51 Settings
	--r55 Adjusted salute dialogue conditions
	if storySequence==TppDefine.STORY_SEQUENCE.CLEARD_RESCUE_INTEL_AGENTS or (TUPPMSettings.mtbs_ENABLE_moreSaluteDialogue and storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_RESCUE_INTEL_AGENTS) then
		table.insert(midNormal,"salute0330")
	end
	--r51 Settings
	--r55 Adjusted salute dialogue conditions
	if storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_METALLIC_ARCHAEA and (storySequence<=TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO or TUPPMSettings.mtbs_ENABLE_moreSaluteDialogue) then
		table.insert(midNormal,"salute0340")
	end
	--r51 Settings
	--r55 Set proper condition for salute dialodue so it does not play from the start of a new game
	if storySequence==TppDefine.STORY_SEQUENCE.CLEARD_MURDER_INFECTORS or (TUPPMSettings.mtbs_ENABLE_moreSaluteDialogue and storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_MURDER_INFECTORS) then
		table.insert(midNormal,"salute0350")
		table.insert(midNormal,"salute0360")
	end
	--r55 Adjusted salute dialogue conditions
	if storySequence>=TppDefine.STORY_SEQUENCE.CLEARD_THE_TRUTH or TUPPMSettings.mtbs_ENABLE_moreSaluteDialogue then
		table.insert(lowNormal,"salute0370")
	end
	if TppUiCommand.IsBirthDay()then
		table.insert(highNormal,"salute0380")
	end
	
--	local saluteListTable={
--		high={normal=highNormal,once=highOnce},
--		mid={normal=midNormal,once=midOnce},
--		low={normal=lowNormal,once=lowOnce}
--	}
--	TUPPMLog.Log("BEFORE saluteListTable: "..tostring(InfInspect.Inspect(saluteListTable)),1)
	
	--r51 Settings
	if TUPPMSettings.mtbs_ENABLE_moreSaluteDialogue then
		local tableToIterate ={}
		table.insert(tableToIterate,highOnce)
		table.insert(tableToIterate,midNormal)
		table.insert(tableToIterate,midOnce)
		table.insert(tableToIterate,lowNormal)
		table.insert(tableToIterate,lowOnce)
		
		for index, saluteTableSmall in pairs(tableToIterate) do
			while #saluteTableSmall>0 do
				table.insert(highNormal,saluteTableSmall[1])
				table.remove(saluteTableSmall,1)
			end
		end
	end
	
	local saluteListTable={
		high={normal=highNormal,once=highOnce},
		mid={normal=midNormal,once=midOnce},
		low={normal=lowNormal,once=lowOnce}
	}
--	TUPPMLog.Log("AFTER saluteListTable: "..tostring(InfInspect.Inspect(saluteListTable)),1)
	
	local objectType={type="TppSoldier2"}
	GameObject.SendCommand(objectType,{id="SetSaluteVoiceList",list=saluteListTable})
end
function this.RequestLoadWalkerGearEquip()
	TppEquip.RequestLoadToEquipMissionBlock{TppEquip.EQP_WP_West_hg_010}
end
function this.SetSoldier2CommonPackageLabel(e)
	mvars.ene_soldier2CommonBlockPackageLabel=e
end
function this.AssignUniqueStaffType(staffDetailsTable)
	if not IsTypeTable(staffDetailsTable)then
		return
	end
	local locaterName=staffDetailsTable.locaterName
	local gameObjectId=staffDetailsTable.gameObjectId
	local uniqueStaffTypeId=staffDetailsTable.uniqueStaffTypeId
	local alreadyExistParam=staffDetailsTable.alreadyExistParam
	if not IsTypeNumber(uniqueStaffTypeId)then
		return
	end
	if(not IsTypeNumber(gameObjectId))and(not IsTypeString(locaterName))then
		return
	end
	local e
	if IsTypeNumber(gameObjectId)then
		e=gameObjectId
	elseif IsTypeString(locaterName)then
		e=GetGameObjectId(locaterName)
	end
	if not TppDefine.IGNORE_EXIST_STAFF_CHECK[uniqueStaffTypeId]then
		if TppMotherBaseManagement.IsExistStaff{uniqueTypeId=uniqueStaffTypeId}then
			if alreadyExistParam then
				local e={gameObjectId=e}
				for n,t in pairs(alreadyExistParam)do
					e[n]=t
				end
				TppMotherBaseManagement.RegenerateGameObjectStaffParameter(e)
				return
			else
				return
			end
		end
	end
	if e~=NULL_ID then
		TppMotherBaseManagement.RegenerateGameObjectStaffParameter{gameObjectId=e,staffType="Unique",uniqueTypeId=uniqueStaffTypeId}
	end
end
function this.IsActiveSoldierInRange(n,e)
	local e={id="IsActiveSoldierInRange",position=n,range=e}
	return SendCommand({type="TppSoldier2"},e)
end
function this._SetOutOfArea(n,t)
	if IsTypeTable(n)then
		for a,n in ipairs(n)do
			this._SetOutOfArea(n,t)
		end
	else
		local e=GetGameObjectId("TppSoldier2",n)table.insert(t,e)
	end
end
function this.SetOutOfArea(a,i)
	local n={}
	this._SetOutOfArea(a,n)
	local e={id="SetOutOfArea",soldiers=n,isOut=i}SendCommand({type="TppSoldier2"},e)
end
--r28 update
function this.SetEliminateTargets(targetList,exceptionList)
	mvars.ene_eliminateTargetList={}
	mvars.ene_eliminateHelicopterList={}
	mvars.ene_eliminateVehicleList={}
	mvars.ene_eliminateWalkerGearList={}
	local invalidTarget={} --r28 update
	if Tpp.IsTypeTable(exceptionList)then
		if Tpp.IsTypeTable(exceptionList.exceptMissionClearCheck)then
			for label,name in pairs(exceptionList.exceptMissionClearCheck)do
				invalidTarget[name]=true
				--r23 Mission Targets no longer auto marked and do not have their markers reset to non-important markers
				--Do not enable/disable markers on targets that are special in a mission
				--r31 Corrected
				local gameObjectId = GameObject.GetGameObjectId(name)
				if gameObjectId~=nil and gameObjectId ~= GameObject.NULL_ID then
					table.insert(TppMain.importantMarkerObjects,gameObjectId)
					TppMain.importantMarkerObjects[gameObjectId]=true
					--          TUPPMLog.Log("Invalid-Index: "..tostring(0)..", Target: "..tostring(gameObjectId)..", TargetName: "..tostring(name))
				end
			end
		end
	end
	--r28 update
	for lable,name in pairs(targetList)do
		local t=GetGameObjectId(name)
		if t~=NULL_ID then
			if Tpp.IsSoldier(t)then
				if not invalidTarget[name]then
					mvars.ene_eliminateTargetList[t]=name
				end
				this.RegistHoldRecoveredState(name)
				this.SetTargetOption(name)
			elseif Tpp.IsEnemyHelicopter(t)then
				if not invalidTarget[name]then
					mvars.ene_eliminateHelicopterList[t]=name
				end
			elseif Tpp.IsVehicle(t)then
				if not invalidTarget[name]then
					mvars.ene_eliminateVehicleList[t]=name
				end
				this.RegistHoldRecoveredState(name)
				this.RegistHoldBrokenState(name)
			elseif Tpp.IsEnemyWalkerGear(t)then
				if not invalidTarget[name]then
					mvars.ene_eliminateWalkerGearList[t]=name
				end
				this.RegistHoldRecoveredState(name)
			end
			if invalidTarget[name]then
			end
		end
	end
end
function this.DeleteEliminateTargetSetting(n)
	if not mvars.ene_eliminateTargetList then
		return
	end
	local e=GetGameObjectId(n)
	if e==NULL_ID then
		return
	end
	if mvars.ene_eliminateTargetList[e]then
		mvars.ene_eliminateTargetList[e]=nil
		local e=GetGameObjectId("TppSoldier2",n)
		if e==NULL_ID then
		else
			SendCommand(e,{id="ResetSoldier2Flag"})
		end
	elseif mvars.ene_eliminateHelicopterList[e]then
		mvars.ene_eliminateHelicopterList[e]=nil
	elseif mvars.ene_eliminateVehicleList[e]then
		mvars.ene_eliminateVehicleList[e]=nil
	elseif mvars.ene_eliminateWalkerGearList[e]then
		mvars.ene_eliminateWalkerGearList[e]=nil
	else
		return
	end
	return true
end
function this.SetRescueTargets(t,n)
	mvars.ene_rescueTargetList={}
	mvars.ene_rescueTargetOptions=n or{}
	for t,n in pairs(t)do
		local t=GetGameObjectId(n)
		if t~=NULL_ID then
			mvars.ene_rescueTargetList[t]=n
			this.RegistHoldRecoveredState(n)
		end
	end
end
function this.SetVipHostage(n)
	this.SetRescueTargets(n)
end
function this.SetExcludeHostage(e)
	mvars.ene_excludeHostageGameObjectId=GetGameObjectId(e)
end
function this.GetAllHostages()
	local e={"TppHostage2","TppHostageUnique","TppHostageUnique2"}
	local s=TppGameObject.NPC_STATE_DISABLE
	local o={}
	for e,r in ipairs(e)do
		local e=1
		local i=0
		while i<e do
			local n=GetGameObjectIdByIndex(r,i)
			if n==NULL_ID then
				break
			end
			if e==1 then
				e=SendCommand({type=r},{id="GetMaxInstanceCount"})
				if not e or e<1 then
					break
				end
			end
			local e=true
			if mvars.ene_excludeHostageGameObjectId and mvars.ene_excludeHostageGameObjectId==n then
				e=false
			end
			if e then
				local e=SendCommand(n,{id="GetLifeStatus"})
				local t=SendCommand(n,{id="GetStatus"})
				if(t~=s)and(e~=TppGameObject.NPC_LIFE_STATE_DEAD)then
					table.insert(o,n)
				end
			end
			i=i+1
		end
	end
	return o
end
function this.GetAllActiveEnemyWalkerGear()
	local r={}
	local e=1
	local n=0
	while n<e do
		local i=GetGameObjectIdByIndex("TppCommonWalkerGear2",n)
		if i==NULL_ID then
			break
		end
		if e==1 then
			e=SendCommand({type="TppCommonWalkerGear2"},{id="GetMaxInstanceCount"})
			if not e or e<1 then
				break
			end
		end
		local a=SendCommand(i,{id="IsBroken"})
		local e=SendCommand(i,{id="IsFultonCaptured"})
		if(a==false)and(e==false)then
			table.insert(r,i)
		end
		n=n+1
	end
	return r
end
function this.SetChildTargets(n)
	mvars.ene_childTargetList={}
	for t,n in pairs(n)do
		local t=GetGameObjectId(n)
		if t~=NULL_ID then
			mvars.ene_childTargetList[t]=n
			this.SetTargetOption(n)
		end
	end
end
function this.SetTargetOption(e)
	local e=GetGameObjectId(e)
	if e==NULL_ID then
	else
		SendCommand(e,{id="SetVip"})SendCommand(e,{id="SetForceRealize"})SendCommand(e,{id="SetIgnoreSupportBlastInUnreal",enabled=true})
	end
end
function this.LetCpHasTarget(n,t)
	local e
	if IsTypeNumber(n)then
		e=n
	elseif IsTypeString(n)then
		e=GetGameObjectId(n)
	else
		return
	end
	if e==NULL_ID then
		return
	end
	GameObject.SendCommand(e,{id="SetCpMissionTarget",enable=t})
end
function this.GetPhase(e)
	local n=GetGameObjectId(e)
	return SendCommand(n,{id="GetPhase",cpName=e})
end
function this.GetPhaseByCPID(e)
	return SendCommand(e,{id="GetPhase",cpName=mvars.ene_cpList[e]})
end
function this.GetLifeStatus(e)
	if not e then
		return
	end
	if IsTypeString(e)then
		e=GameObject.GetGameObjectId(e)
	end
	return SendCommand(e,{id="GetLifeStatus"})
end
function this.GetActionStatus(e)
	if not e then
		return
	end
	if IsTypeString(e)then
		e=GameObject.GetGameObjectId(e)
	end
	return SendCommand(e,{id="GetActionStatus"})
end
function this.GetStatus(n)
	local e
	if IsTypeString(n)then
		e=GetGameObjectId(n)
	else
		e=n
	end
	if e~=NULL_ID then
		return SendCommand(e,{id="GetStatus"})
	else
		return
	end
end
function this.IsEliminated(n)
	local t=this.GetLifeStatus(n)
	local n=this.GetStatus(n)
	return this._IsEliminated(t,n)
end
function this.IsNeutralized(n)
	local t=this.GetLifeStatus(n)
	local n=this.GetStatus(n)
	return this._IsNeutralized(t,n)
end
function this.IsRecovered(e)
	if not mvars.ene_recoverdStateIndexByName then
		return
	end
	local n
	if IsTypeString(e)then
		n=mvars.ene_recoverdStateIndexByName[e]
	elseif IsTypeNumber(e)then
		n=mvars.ene_recoverdStateIndexByGameObjectId[e]
	end
	if n then
		return svars.ene_isRecovered[n]
	end
end
function this.ChangeLifeState(n)
	if not Tpp.IsTypeTable(n)then
		return"Support table only"end
	local e=n.lifeState
	local t=0
	local i=4
	if not((e>t)and(e<i))then
		return"lifeState must be index"end
	local n=n.targetName
	if not IsTypeString(n)then
		return"targetName must be string"end
	local t=GetGameObjectId(n)
	if t~=NULL_ID then
		GameObject.SendCommand(t,{id="ChangeLifeState",state=e})
	else
		return"Cannot get gameObjectId. targetName = "..tostring(n)
	end
end
function this.SetSneakRoute(e,s,n,r)
	if not e then
		return
	end
	if IsTypeString(e)then
		e=GameObject.GetGameObjectId(e)
	end
	n=n or 0
	local i=false
	if Tpp.IsTypeTable(r)then
		i=r.isRelaxed
	end
	if e~=NULL_ID then
		SendCommand(e,{id="SetSneakRoute",route=s,point=n,isRelaxed=i})
	end
end
function this.UnsetSneakRoute(e)
	if not e then
		return
	end
	if IsTypeString(e)then
		e=GameObject.GetGameObjectId(e)
	end
	if e~=NULL_ID then
		SendCommand(e,{id="SetSneakRoute",route=""})
	end
end
function this.SetCautionRoute(e,i,n,r)
	if not e then
		return
	end
	if IsTypeString(e)then
		e=GameObject.GetGameObjectId(e)
	end
	n=n or 0
	if e~=NULL_ID then
		SendCommand(e,{id="SetCautionRoute",route=i,point=n})
	end
end
function this.UnsetCautionRoute(e)
	if not e then
		return
	end
	if IsTypeString(e)then
		e=GameObject.GetGameObjectId(e)
	end
	if e~=NULL_ID then
		SendCommand(e,{id="SetCautionRoute",route=""})
	end
end
function this.SetAlertRoute(e,i,n,r)
	if not e then
		return
	end
	if IsTypeString(e)then
		e=GameObject.GetGameObjectId(e)
	end
	n=n or 0
	if e~=NULL_ID then
		SendCommand(e,{id="SetAlertRoute",enabled=true,route=i,point=n})
	end
end
function this.UnsetAlertRoute(e)
	if not e then
		return
	end
	if IsTypeString(e)then
		e=GameObject.GetGameObjectId(e)
	end
	if e~=NULL_ID then
		SendCommand(e,{id="SetAlertRoute",enabled=false,route=""})
	end
end
function this.RegistRoutePointMessage(e)
	if not IsTypeTable(e)then
		return
	end
	mvars.ene_routePointMessage=mvars.ene_routePointMessage or{}
	mvars.ene_routePointMessage.main=mvars.ene_routePointMessage.main or{}
	mvars.ene_routePointMessage.sequence=mvars.ene_routePointMessage.sequence or{}
	local n={}n[StrCode32"GameObject"]=Tpp.StrCode32Table(e.messages)
	local n=(Tpp.MakeMessageExecTable(n))[StrCode32"GameObject"]
	local e=e.sequenceName
	if e then
		mvars.ene_routePointMessage.sequence[e]=mvars.ene_routePointMessage.sequence[e]or{}
		Tpp.MergeTable(mvars.ene_routePointMessage.sequence[e],n,true)
	else
		Tpp.MergeTable(mvars.ene_routePointMessage.main,n,true)
	end
end
function this.IsBaseCp(e)
	if not mvars.ene_baseCpList then
		return
	end
	return mvars.ene_baseCpList[e]
end
function this.IsOuterBaseCp(e)
	if not mvars.ene_outerBaseCpList then
		return
	end
	return mvars.ene_outerBaseCpList[e]
end
function this.ChangeRouteSets(n,a)
	mvars.ene_routeSetsTemporary=mvars.ene_routeSets
	mvars.ene_routeSetsPriorityTemporary=mvars.ene_routeSetsPriority
	this.MergeRouteSetDefine(n)
	mvars.ene_routeSets={}
	mvars.ene_routeSetsPriority={}
	mvars.ene_routeSetsFixedShiftChange={}
	this.UpdateRouteSet(mvars.ene_routeSetsDefine)
	local n={{{"old","immediately"},{"new","immediately"}}}
	for e,a in pairs(mvars.ene_cpList)do
		SendCommand(e,{id="ChangeRouteSets"})SendCommand(e,{id="ShiftChange",schedule=n})
	end
end
function this.InitialRouteSetGroup(e)
	local i=GetGameObjectId(e.cpName)
	local o=e.groupName
	if not IsTypeTable(e.soldierList)then
		return
	end
	local n={}
	for t,e in pairs(e.soldierList)do
		local e=GetGameObjectId(e)
		if e~=NULL_ID then
			n[t]=e
		end
	end
	if i==NULL_ID then
		return
	end
	SendCommand(i,{id="AssignSneakRouteGroup",soldiers=n,group=o})
end
function this.RegisterHoldTime(e,n)
	local e=GetGameObjectId(e)
	if e==NULL_ID then
		return
	end
	mvars.ene_holdTimes[e]=n
end
function this.ChangeHoldTime(n,t)
	local n=GetGameObjectId(n)
	if n==NULL_ID then
		return
	end
	mvars.ene_holdTimes[n]=t
	this.MakeShiftChangeTable()
end
function this.RegisterSleepTime(e,n)
	local e=GetGameObjectId(e)
	if e==NULL_ID then
		return
	end
	mvars.ene_sleepTimes[e]=n
end
function this.ChangeSleepTime(n,t)
	local n=GetGameObjectId(n)
	if n==NULL_ID then
		return
	end
	mvars.ene_sleepTimes[n]=t
	this.MakeShiftChangeTable()
end
function this.NoShifhtChangeGruopSetting(e,n)
	local e=GetGameObjectId(e)
	if e==NULL_ID then
		return
	end
	mvars.ene_noShiftChangeGroupSetting[e]=mvars.ene_noShiftChangeGroupSetting[e]or{}
	mvars.ene_noShiftChangeGroupSetting[e][StrCode32(n)]=true
end
function this.RegisterCombatSetting(a)
	local function i(t,e)
		local n={}
		for e,a in pairs(e)do
			n[e]=a
			if t[e]then
				n[e]=t[e]
			end
		end
		return n
	end
	if not IsTypeTable(a)then
		return
	end
	for n,e in pairs(a)do
		if e.USE_COMMON_COMBAT and mvars.loc_locationCommonCombat then
			if mvars.loc_locationCommonCombat[n]then
				if e.combatAreaList then
					e.combatAreaList=i(e.combatAreaList,mvars.loc_locationCommonCombat[n].combatAreaList)
				else
					e=mvars.loc_locationCommonCombat[n]
				end
			end
		end
		if e.combatAreaList and IsTypeTable(e.combatAreaList)then
			for t,e in pairs(e.combatAreaList)do
				for t,e in pairs(e)do
					if e.guardTargetName and e.locatorSetName then
						TppCombatLocatorProvider.RegisterCombatLocatorSetToCpforLua{cpName=n,locatorSetName=e.guardTargetName}
						TppCombatLocatorProvider.RegisterCombatLocatorSetToCpforLua{cpName=n,locatorSetName=e.locatorSetName}
					end
				end
			end
			local t={type="TppCommandPost2"}
			local e={id="SetCombatArea",cpName=n,combatAreaList=e.combatAreaList}
			GameObject.SendCommand(t,e)
		else
			for t,e in ipairs(e)do
				TppCombatLocatorProvider.RegisterCombatLocatorSetToCpforLua{cpName=n,locatorSetName=e}
			end
		end
	end
end
function this.SetEnable(e)
	if IsTypeString(e)then
		e=GameObject.GetGameObjectId(e)
	end
	if e~=NULL_ID then
		SendCommand(e,{id="SetEnabled",enabled=true})
	end
end
function this.SetDisable(e,n)
	if IsTypeString(e)then
		e=GameObject.GetGameObjectId(e)
	end
	if e~=NULL_ID then
		SendCommand(e,{id="SetEnabled",enabled=false,noAssignRoute=n})
	end
end
function this.SetEnableRestrictNotice(e)
	if IsTypeString(e)then
		e=GameObject.GetGameObjectId(e)
	end
	if e~=NULL_ID then
		SendCommand(e,{id="SetRestrictNotice",enabled=true})
	end
end
function this.SetDisableRestrictNotice(e)
	if IsTypeString(e)then
		e=GameObject.GetGameObjectId(e)
	end
	if e~=NULL_ID then
		SendCommand(e,{id="SetRestrictNotice",enabled=false})
	end
end
function this.RealizeParasiteSquad()
	if not IsTypeTable(mvars.ene_parasiteSquadList)then
		return
	end
	for n,e in pairs(mvars.ene_parasiteSquadList)do
		local e=GetGameObjectId("TppParasite2",e)
		if e~=NULL_ID then
			SendCommand(e,{id="Realize"})
		end
	end
end
function this.UnRealizeParasiteSquad()
	if not IsTypeTable(mvars.ene_parasiteSquadList)then
		return
	end
	for n,e in pairs(mvars.ene_parasiteSquadList)do
		local e=GetGameObjectId("TppParasite2",e)
		if e~=NULL_ID then
			SendCommand(e,{id="Unrealize"})
		end
	end
end
function this.OnAllocate(n)
	this.SetMaxSoldierStateCount(TppDefine.DEFAULT_SOLDIER_STATE_COUNT)
	if n.enemy then
		this.SetMaxSoldierStateCount(n.enemy.MAX_SOLDIER_STATE_COUNT)
	end
	if TppCommandPost2 then
		TppCommandPost2.SetSVarsKeyNames{names="cpNames",flags="cpFlags"}
	end
	TppSoldier2.SetSVarsKeyNames{name="solName",state="solState",flagAndStance="solFlagAndStance",weapon="solWeapon",location="solLocation",marker="solMarker",fovaSeed="solFovaSeed",faceFova="solFaceFova",bodyFova="solBodyFova",cp="solCp",cpRoute="solCpRoute",scriptSneakRoute="solScriptSneakRoute",scriptCautionRoute="solScriptCautionRoute",scriptAlertRoute="solScriptAlertRoute",routeNodeIndex="solRouteNodeIndex",routeEventIndex="solRouteEventIndex",travelName="solTravelName",travelStepIndex="solTravelStepIndex",optionalNamesName="solOptName",optionalParam1Name="solOptParam1",optionalParam2Name="solOptParam2",passengerInfoName="passengerInfoName",passengerFlagName="passengerFlagName",passengerNameName="passengerNameName",noticeObjectType="noticeObjectType",noticeObjectPosition="noticeObjectPosition",noticeObjectOwnerName="noticeObjectOwnerName",noticeObjectOwnerId="noticeObjectOwnerId",noticeObjectAttachId="noticeObjectAttachId",randomSeed="solRandomSeed"}
	if TppSoldierFace~=nil then
		if TppSoldierFace.ConvertFova2PathToFovaFile~=nil then
			TppSoldierFace.ConvertFova2PathToFovaFile()
		end
	end
	if TppHostage2 then
		if TppHostage2.SetSVarsKeyNames2 then
			TppHostage2.SetSVarsKeyNames2{name="hosName",state="hosState",flagAndStance="hosFlagAndStance",weapon="hosWeapon",location="hosLocation",marker="hosMarker",fovaSeed="hosFovaSeed",faceFova="hosFaceFova",bodyFova="hosBodyFova",scriptSneakRoute="hosScriptSneakRoute",routeNodeIndex="hosRouteNodeIndex",routeEventIndex="hosRouteEventIndex",optionalParam1Name="hosOptParam1",optionalParam2Name="hosOptParam2",randomSeed="hosRandomSeed"}
		end
	end
	mvars.ene_disablePowerSettings={}
	mvars.ene_soldierTypes={}
	if n.enemy then
		if n.enemy.syncRouteTable and SyncRouteManager then
			SyncRouteManager.Create(n.enemy.syncRouteTable)
		end
		if n.enemy.OnAllocate then
			n.enemy.OnAllocate()
		end
		mvars.ene_funcRouteSetPriority=n.enemy.GetRouteSetPriority
		if n.enemy.hostageDefine then
			mvars.ene_hostageDefine=n.enemy.hostageDefine
		end
		if n.enemy.vehicleDefine then
			mvars.ene_vehicleDefine=n.enemy.vehicleDefine
		end
		if n.enemy.vehicleSettings then
			this.RegistVehicleSettings(n.enemy.vehicleSettings)
		end
		if IsTypeTable(n.enemy.disablePowerSettings)then
			this.DisablePowerSettings(n.enemy.disablePowerSettings)
		end
		if n.enemy.soldierTypes then
			this.SetUpSoldierTypes(n.enemy.soldierTypes)
		end
	end
	mvars.ene_soldierPowerSettings={}
	mvars.ene_missionSoldierPowerSettings={}
	mvars.ene_missionRequiresPowerSettings={}
	mvars.ene_soldierPersonalAbilitySettings={}
	mvars.ene_missionSoldierPersonalAbilitySettings={}
	mvars.ene_soldier2CommonBlockPackageLabel="default"mvars.ene_questTargetList={}
	mvars.ene_questVehicleList={}
	mvars.ene_questGetLoadedFaceTable={}
	mvars.ene_questArmorId=0
	mvars.ene_questBalaclavaId=0
	mvars.ene_isQuestSetup=false
	mvars.ene_isQuestHeli=false
end
function this.DeclareSVars(t)
	local n=0
	local e=TppMission.GetMissionID()
	if TppMission.IsFOBMission(e)then
		n=TppDefine.MAX_UAV_COUNT
	end
	local e=0
	if t.enemy then
		local n=t.enemy.soldierDefine
		if n~=nil then
			for n,n in pairs(n)do
				e=e+1
			end
		end
	end
	if e==1 then
		e=2
	end
	mvars.ene_cpCount=e
	local n={{name="cpNames",arraySize=e,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="cpFlags",arraySize=e,type=TppScriptVars.TYPE_UINT8,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="solName",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="solState",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT8,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="solFlagAndStance",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="solWeapon",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="solLocation",arraySize=mvars.ene_maxSoldierStateCount*4,type=TppScriptVars.TYPE_FLOAT,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="solMarker",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_RETRY},{name="solFovaSeed",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="solFaceFova",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="solBodyFova",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="solCp",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="solCpRoute",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="solScriptSneakRoute",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="solScriptCautionRoute",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="solScriptAlertRoute",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="solRouteNodeIndex",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="solRouteEventIndex",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="solTravelName",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="solTravelStepIndex",arraySize=mvars.ene_maxSoldierStateCount,type=TppScriptVars.TYPE_UINT8,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="solOptName",arraySize=TppDefine.DEFAULT_SOLDIER_OPTION_VARS_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="solOptParam1",arraySize=TppDefine.DEFAULT_SOLDIER_OPTION_VARS_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="solOptParam2",arraySize=TppDefine.DEFAULT_SOLDIER_OPTION_VARS_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="passengerInfoName",arraySize=TppDefine.DEFAULT_PASSAGE_INFO_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="passengerFlagName",arraySize=TppDefine.DEFAULT_PASSAGE_FLAG_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="passengerNameName",arraySize=TppDefine.DEFAULT_PASSAGE_FLAG_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="passengerVehicleNameName",arraySize=TppDefine.DEFAULT_PASSAGE_INFO_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="noticeObjectType",arraySize=TppDefine.DEFAULT_NOTICE_INFO_COUNT,type=TppScriptVars.TYPE_UINT8,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="noticeObjectPosition",arraySize=TppDefine.DEFAULT_NOTICE_INFO_COUNT*3,type=TppScriptVars.TYPE_FLOAT,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="noticeObjectOwnerName",arraySize=TppDefine.DEFAULT_NOTICE_INFO_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="noticeObjectOwnerId",arraySize=TppDefine.DEFAULT_NOTICE_INFO_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="noticeObjectAttachId",arraySize=TppDefine.DEFAULT_NOTICE_INFO_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="solRandomSeed",arraySize=1,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="hosName",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="hosState",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT8,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="hosFlagAndStance",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="hosWeapon",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="hosLocation",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT*4,type=TppScriptVars.TYPE_FLOAT,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="hosMarker",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_RETRY},{name="hosFovaSeed",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="hosFaceFova",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="hosBodyFova",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="hosScriptSneakRoute",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="hosRouteNodeIndex",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="hosRouteEventIndex",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="hosOptParam1",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="hosOptParam2",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="hosRandomSeed",arraySize=TppDefine.DEFAULT_HOSTAGE_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="enemyHeliName",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="enemyHeliLocation",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT*4,type=TppScriptVars.TYPE_FLOAT,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="enemyHeliCp",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="enemyHeliFlag",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="enemyHeliSneakRoute",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="enemyHeliCautionRoute",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="enemyHeliAlertRoute",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="enemyHeliRouteNodeIndex",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="enemyHeliRouteEventIndex",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="enemyHeliMarker",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_RETRY},{name="enemyHeliLife",arraySize=TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="ene_wkrg_name",arraySize=4,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="ene_wkrg_life",arraySize=4,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="ene_wkrg_partslife",arraySize=4*24,type=TppScriptVars.TYPE_UINT8,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="ene_wkrg_location",arraySize=4*4,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="ene_wkrg_bulletleft",arraySize=4*2,type=TppScriptVars.TYPE_UINT16,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="ene_wkrg_marker",arraySize=4*2,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_RETRY},{name="ene_holdRecoveredStateName",arraySize=TppDefine.MAX_HOLD_RECOVERED_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="ene_isRecovered",arraySize=TppDefine.MAX_HOLD_RECOVERED_STATE_COUNT,type=TppScriptVars.TYPE_BOOL,value=false,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="ene_holdBrokenStateName",arraySize=TppDefine.MAX_HOLD_VEHICLE_BROKEN_STATE_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="ene_isVehicleBroken",arraySize=TppDefine.MAX_HOLD_VEHICLE_BROKEN_STATE_COUNT,type=TppScriptVars.TYPE_BOOL,value=false,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="liquidLifeStatus",arraySize=1,type=TppScriptVars.TYPE_UINT8,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="liquidMarker",arraySize=1,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_RETRY},{name="uavName",arraySize=n,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="uavIsDead",arraySize=n,type=TppScriptVars.TYPE_UINT8,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="uavMarker",arraySize=n,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_RETRY},{name="uavCp",arraySize=n,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="uavPatrolRoute",arraySize=n,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="uavCombatRoute",arraySize=n,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="securityCameraCp",arraySize=TppDefine.MAX_SECURITY_CAMERA_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},{name="securityCameraMarker",arraySize=TppDefine.MAX_SECURITY_CAMERA_COUNT,type=TppScriptVars.TYPE_UINT32,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_RETRY},{name="securityCameraFlag",arraySize=TppDefine.MAX_SECURITY_CAMERA_COUNT,type=TppScriptVars.TYPE_UINT8,value=0,save=true,sync=false,wait=false,category=TppScriptVars.CATEGORY_MISSION},nil}
	if Vehicle.svars then
		local e=Vehicle.instanceCountMax
		if mvars.ene_vehicleDefine and mvars.ene_vehicleDefine.instanceCount then
			e=mvars.ene_vehicleDefine.instanceCount
		end
		Tpp.ApendArray(n,Vehicle.svars{instanceCount=e})
	end
	return n
end
function this.ResetSoldier2CommonBlockPackageLabel()
	gvars.ene_soldier2CommonPackageLabelIndex=TppDefine.DEFAULT_SOLIDER2_COMMON_PACKAGE
end
function this.RegisterSoldier2CommonMotionPackagePath(n)
	local t=TppDefine.SOLIDER2_COMMON_PACK[n]
	local a=TppDefine.SOLIDER2_COMMON_PACK_PREREQUISITES[n]
	if t then
		if IsTypeString(n)then
			gvars.ene_soldier2CommonPackageLabelIndex=StrCode32(n)
		else
			gvars.ene_soldier2CommonPackageLabelIndex=n
		end
	else
		t=TppDefine.SOLIDER2_COMMON_PACK.default
		a=TppDefine.SOLIDER2_COMMON_PACK_PREREQUISITES.default
		this.ResetSoldier2CommonBlockPackageLabel()
	end
	TppSoldier2CommonBlockController.SetPackagePathWithPrerequisites{path=t,prerequisites=a}
end
function this.IsRequiredToLoadSpecialSolider2CommonBlock()
	if StrCode32(mvars.ene_soldier2CommonBlockPackageLabel)~=TppDefine.DEFAULT_SOLIDER2_COMMON_PACKAGE then
		return true
	else
		return false
	end
end
function this.IsRequiredToLoadDefaultSoldier2CommonPackage()
	local e=StrCode32(mvars.ene_soldier2CommonBlockPackageLabel)
	if(e==TppDefine.DEFAULT_SOLIDER2_COMMON_PACKAGE)then
		return true
	else
		return false
	end
end
function this.IsLoadedDefaultSoldier2CommonPackage()
	if gvars.ene_soldier2CommonPackageLabelIndex==TppDefine.DEFAULT_SOLIDER2_COMMON_PACKAGE then
		return true
	else
		return false
	end
end
function this.LoadSoldier2CommonBlock()
	this.RegisterSoldier2CommonMotionPackagePath(mvars.ene_soldier2CommonBlockPackageLabel)
	while not TppSoldier2CommonBlockController.IsReady()do
		coroutine.yield()
	end
end
function this.UnloadSoldier2CommonBlock()
	TppSoldier2CommonBlockController.SetPackagePathWithPrerequisites{}
end
function this.SetMaxSoldierStateCount(e)
	if Tpp.IsTypeNumber(e)and(e>0)then
		mvars.ene_maxSoldierStateCount=e
	end
end
function this.RestoreOnMissionStart2()
	local t=0
	local a=0
	if EnemyFova~=nil then
		if EnemyFova.INVALID_FOVA_VALUE~=nil then
			t=EnemyFova.INVALID_FOVA_VALUE
			a=EnemyFova.INVALID_FOVA_VALUE
		end
	end
	local n=0
	if mvars.ene_cpList~=nil then
		for t,e in pairs(mvars.ene_cpList)do
			if n<mvars.ene_cpCount then
				svars.cpNames[n]=StrCode32(e)svars.cpFlags[n]=0
				n=n+1
			end
		end
	end
	for e=0,mvars.ene_maxSoldierStateCount-1 do
		svars.solName[e]=0
		svars.solState[e]=0
		svars.solFlagAndStance[e]=0
		svars.solWeapon[e]=0
		svars.solLocation[e*4+0]=0
		svars.solLocation[e*4+1]=0
		svars.solLocation[e*4+2]=0
		svars.solLocation[e*4+3]=0
		svars.solMarker[e]=0
		svars.solFovaSeed[e]=0
		svars.solFaceFova[e]=t
		svars.solBodyFova[e]=a
		svars.solCp[e]=0
		svars.solCpRoute[e]=GsRoute.ROUTE_ID_EMPTY
		svars.solScriptSneakRoute[e]=GsRoute.ROUTE_ID_EMPTY
		svars.solScriptCautionRoute[e]=GsRoute.ROUTE_ID_EMPTY
		svars.solScriptAlertRoute[e]=GsRoute.ROUTE_ID_EMPTY
		svars.solRouteNodeIndex[e]=0
		svars.solRouteEventIndex[e]=0
		svars.solTravelName[e]=0
		svars.solTravelStepIndex[e]=0
	end
	for e=0,TppDefine.DEFAULT_SOLDIER_OPTION_VARS_COUNT-1 do
		svars.solOptName[e]=0
		svars.solOptParam1[e]=0
		svars.solOptParam2[e]=0
	end
	if svars.passengerInfoName~=nil then
		for e=0,TppDefine.DEFAULT_PASSAGE_INFO_COUNT-1 do
			svars.passengerInfoName[e]=0
		end
	end
	if svars.passengerFlagName~=nil then
		for e=0,TppDefine.DEFAULT_PASSAGE_FLAG_COUNT-1 do
			svars.passengerFlagName[e]=0
		end
	end
	if svars.passengerNameName~=nil then
		for e=0,TppDefine.DEFAULT_PASSAGE_FLAG_COUNT-1 do
			svars.passengerNameName[e]=0
		end
	end
	if svars.passengerNameName~=nil then
		for e=0,TppDefine.DEFAULT_PASSAGE_FLAG_COUNT-1 do
			svars.passengerNameName[e]=0
		end
	end
	this._RestoreOnMissionStart_Hostage2()
	for e=0,TppDefine.DEFAULT_ENEMY_HELI_STATE_COUNT-1 do
		svars.enemyHeliName=0
		svars.enemyHeliLocation[0]=0
		svars.enemyHeliLocation[1]=0
		svars.enemyHeliLocation[2]=0
		svars.enemyHeliLocation[3]=0
		svars.enemyHeliCp=0
		svars.enemyHeliFlag=0
		svars.enemyHeliSneakRoute=0
		svars.enemyHeliCautionRoute=0
		svars.enemyHeliAlertRoute=0
		svars.enemyHeliRouteNodeIndex=0
		svars.enemyHeliRouteEventIndex=0
		svars.enemyHeliMarker=0
		svars.enemyHeliLife=0
	end
	for e=0,TppDefine.MAX_SECURITY_CAMERA_COUNT-1 do
		svars.securityCameraCp[e]=0
		svars.securityCameraMarker[e]=0
		svars.securityCameraFlag[e]=0
	end
end
function this.RestoreOnContinueFromCheckPoint2()do
	local e={type="TppCommandPost2"}SendCommand(e,{id="RestoreFromSVars"})
end
if GameObject.GetGameObjectIdByIndex("TppSoldier2",0)~=NULL_ID then
	local e={type="TppSoldier2"}SendCommand(e,{id="RestoreFromSVars"})
end
this._RestoreOnContinueFromCheckPoint_Hostage2()
if GameObject.GetGameObjectIdByIndex("TppEnemyHeli",0)~=NULL_ID then
	local e={type="TppEnemyHeli"}SendCommand(e,{id="RestoreFromSVars"})
end
if GameObject.GetGameObjectIdByIndex("TppVehicle2",0)~=NULL_ID then
	SendCommand({type="TppVehicle2"},{id="RestoreFromSVars"})
end
if GameObject.GetGameObjectIdByIndex("TppCommonWalkerGear2",0)~=NULL_ID then
	SendCommand({type="TppCommonWalkerGear2"},{id="RestoreFromSVars"})
end
if GameObject.GetGameObjectIdByIndex("TppLiquid2",0)~=NULL_ID then
	SendCommand({type="TppLiquid2"},{id="RestoreFromSVars"})
end
if GameObject.GetGameObjectIdByIndex("TppUav",0)~=NULL_ID then
	SendCommand({type="TppUav"},{id="RestoreFromSVars"})
end
if GameObject.GetGameObjectIdByIndex("TppSecurityCamera2",0)~=NULL_ID then
	SendCommand({type="TppSecurityCamera2"},{id="RestoreFromSVars"})
end
end
function this.RestoreOnContinueFromCheckPoint()
	this._RestoreOnContinueFromCheckPoint_Hostage()
end
function this.RestoreOnMissionStart()
	this._RestoreOnMissionStart_Hostage()
end
function this.StoreSVars(i)
	local n=false
	if i then
		n=true
	end
	do
		local e={type="TppCommandPost2"}SendCommand(e,{id="StoreToSVars"})
	end
	if GameObject.GetGameObjectIdByIndex("TppSoldier2",0)~=NULL_ID then
		local e={type="TppSoldier2"}SendCommand(e,{id="StoreToSVars",markerOnly=n})
	end
	this._StoreSVars_Hostage(n)
	if GameObject.GetGameObjectIdByIndex("TppEnemyHeli",0)~=NULL_ID then
		SendCommand({type="TppEnemyHeli"},{id="StoreToSVars"})
	end
	if GameObject.GetGameObjectIdByIndex("TppVehicle2",0)~=NULL_ID then
		SendCommand({type="TppVehicle2"},{id="StoreToSVars"})
	end
	if GameObject.GetGameObjectIdByIndex("TppCommonWalkerGear2",0)~=NULL_ID then
		SendCommand({type="TppCommonWalkerGear2"},{id="StoreToSVars"})
	end
	if GameObject.GetGameObjectIdByIndex("TppLiquid2",0)~=NULL_ID then
		SendCommand({type="TppLiquid2"},{id="StoreToSVars"})
	end
	if GameObject.GetGameObjectIdByIndex("TppUav",0)~=NULL_ID then
		SendCommand({type="TppUav"},{id="StoreToSVars"})
	end
	if GameObject.GetGameObjectIdByIndex("TppSecurityCamera2",0)~=NULL_ID then
		SendCommand({type="TppSecurityCamera2"},{id="StoreToSVars"})
	end
end
function this.PreMissionLoad(nextMissionCode,currentMissionCode)
	this.InitializeHostage2()
	TppEneFova.PreMissionLoad(nextMissionCode,currentMissionCode)
end
function this.InitializeHostage2()
	if TppHostage2.ClearHostageType then
		TppHostage2.ClearHostageType()
	end
	if TppHostage2.ClearUniquePartsPath then
		TppHostage2.ClearUniquePartsPath()
	end
end
function this.Init(n)
	mvars.ene_routeAnimationGaniPathTable={{"SoldierLookWatch","/Assets/tpp/motion/SI_game/fani/bodies/enem/enemasr/enemasr_s_pat_idl_act_a.gani"},{"SoldierWipeFace","/Assets/tpp/motion/SI_game/fani/bodies/enem/enemasr/enemasr_s_pat_idl_act_d.gani"},{"SoldierYawn","/Assets/tpp/motion/SI_game/fani/bodies/enem/enemasr/enemasr_s_pat_idl_act_f.gani"},{"SoldierSneeze","/Assets/tpp/motion/SI_game/fani/bodies/enem/enemasr/enemasr_s_pat_idl_act_g.gani"},{"SoldierFootStep","/Assets/tpp/motion/SI_game/fani/bodies/enem/enemasr/enemasr_s_pat_idl_act_h.gani"},{"SoldierCough","/Assets/tpp/motion/SI_game/fani/bodies/enem/enemasr/enemasr_s_pat_idl_act_i.gani"},{"SoldierScratchHead","/Assets/tpp/motion/SI_game/fani/bodies/enem/enemasr/enemasr_s_pat_idl_act_o.gani"},{"SoldierHungry","/Assets/tpp/motion/SI_game/fani/bodies/enem/enemasr/enemasr_s_pat_idl_act_p.gani"},nil}
	mvars.ene_eliminateTargetList={}
	mvars.ene_routeSets={}
	mvars.ene_noShiftChangeGroupSetting={}
	this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
	this.RegistCommonRoutePointMessage()
	if n.enemy then
		if n.enemy.parasiteSquadList then
			mvars.ene_parasiteSquadList=n.enemy.parasiteSquadList
		end
		if n.enemy.USE_COMMON_REINFORCE_PLAN then
			mvars.ene_useCommonReinforcePlan=true
		end
	end
	if mvars.loc_locationCommonTravelPlans then
		mvars.ene_lrrpNumberDefine={}
		for e,n in pairs(mvars.loc_locationCommonTravelPlans.lrrpNumberDefine)do
			mvars.ene_lrrpNumberDefine[e]=n
		end
		mvars.ene_cpLinkDefine=this.MakeCpLinkDefineTable(mvars.ene_lrrpNumberDefine,mvars.loc_locationCommonTravelPlans.cpLinkMatrix)
		mvars.ene_defaultTravelRouteGroup=mvars.loc_locationCommonTravelPlans.defaultTravelRouteGroup
		local e
		if n.enemy and n.enemy.lrrpNumberDefine then
			e=n.enemy.lrrpNumberDefine
		end
		if e then
			for n,e in ipairs(n.enemy.lrrpNumberDefine)do
				local n=#mvars.ene_lrrpNumberDefine+1
				mvars.ene_lrrpNumberDefine[n]=e
				mvars.ene_lrrpNumberDefine[e]=n
			end
		end
		if n.enemy and n.enemy.cpLink then
			local t=n.enemy.cpLink
			for e,n in pairs(t)do
				mvars.ene_cpLinkDefine[e]=mvars.ene_cpLinkDefine[e]or{}
				for a,n in ipairs(mvars.ene_lrrpNumberDefine)do
					mvars.ene_cpLinkDefine[n]=mvars.ene_cpLinkDefine[n]or{}
					if t[e][n]then
						mvars.ene_cpLinkDefine[e][n]=true
						mvars.ene_cpLinkDefine[n][e]=true
					else
						mvars.ene_cpLinkDefine[e][n]=false
						mvars.ene_cpLinkDefine[n][e]=false
					end
				end
			end
		end
	end
	local e
	local n=TppStory.GetCurrentStorySequence()
	--r27 NG+ patch enable fultoning SKULLS
	--r51 NG+ Settings
	if (n>=TppDefine.STORY_SEQUENCE.CLEARD_METALLIC_ARCHAEA) or TppTerminal.IsNewGameMode() then
		e=true
	else
		e=false
	end
	local n={"TppBossQuiet2","TppParasite2"}
	for t,n in ipairs(n)do
		if GameObject.DoesGameObjectExistWithTypeName(n)then
			GameObject.SendCommand({type=n},{id="SetFultonEnabled",enabled=e})
		end
	end
end
function this.RegistCommonRoutePointMessage()
end
function this.OnReload(n)
	this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
	this.RegistCommonRoutePointMessage()
	if n.enemy then
		this.SetUpCommandPost()
		this.SetUpSwitchRouteFunc()
	end
end
function this.OnMessage(t,n,a,s,o,i,r)
	Tpp.DoMessage(this.messageExecTable,TppMission.CheckMessageOption,t,n,a,s,o,i,r)
end
function this.DefineSoldiers(n)
	mvars.ene_soldierDefine={}
	Tpp.MergeTable(mvars.ene_soldierDefine,n,true)
	mvars.ene_soldierIDList={}
	mvars.ene_cpList={}
	mvars.ene_baseCpList={}
	mvars.ene_outerBaseCpList={}
	mvars.ene_holdTimes={}
	mvars.ene_sleepTimes={}
	mvars.ene_lrrpTravelPlan={}
	mvars.ene_lrrpVehicle={}
	for i,t in pairs(n)do
		local n=GetGameObjectId(i)
		if n==NULL_ID then
		else
			mvars.ene_cpList[n]=i
			mvars.ene_holdTimes[n]=this.DEFAULT_HOLD_TIME
			mvars.ene_sleepTimes[n]=this.DEFAULT_SLEEP_TIME
			mvars.ene_soldierIDList[n]={}
			if t.lrrpTravelPlan then
				mvars.ene_lrrpTravelPlan[n]=t.lrrpTravelPlan
			end
			if t.lrrpVehicle then
				mvars.ene_lrrpVehicle[n]=t.lrrpVehicle
			end
			for t,i in pairs(t)do
				if IsTypeString(t)then
					if not this.SOLDIER_DEFINE_RESERVE_TABLE_NAME[t]then
					end
				else
					local e=GetGameObjectId(i)
					if e==NULL_ID then
					else
						mvars.ene_soldierIDList[n][e]=t
					end
				end
			end
		end
	end
end
function this.SetUpSoldiers()
	if not IsTypeTable(mvars.ene_soldierDefine)then
		return
	end
	local o=TppMission.GetMissionID()
	for i,n in pairs(mvars.ene_soldierDefine)do
		local n=GetGameObjectId(i)
		if n==NULL_ID then
		else
			if string.sub(i,-4)=="lrrp"then
				SendCommand(n,{id="SetLrrpCp"})
			end
			local a=string.sub(i,-2)
			if a=="ob"then
				GameObject.SendCommand(n,{id="SetOuterBaseCp"})
				mvars.ene_outerBaseCpList[n]=true
			end
			if a=="cp"then
				local t=true
				if i=="mafr_outland_child_cp"then
					t=false
				end
				if t then
					this.AddCpIntelTrapTable(i)
					mvars.ene_baseCpList[n]=true
				end
			end
			TppEmblem.SetUpCpEmblemTag(i,n)
			if mvars.loc_locationSiren then
				local e=mvars.loc_locationSiren[i]
				if e then
					SendCommand(n,{id="SetCpSirenType",type=e.sirenType,pos=e.pos})
				end
			end
			local e
			if(o==10150 or o==10151)or o==11151 then
				e={id="SetCpType",type=CpType.TYPE_AMERICA}
			elseif TppLocation.IsAfghan()then
				e={id="SetCpType",type=CpType.TYPE_SOVIET}
			elseif TppLocation.IsMiddleAfrica()then
				e={id="SetCpType",type=CpType.TYPE_AFRIKAANS}
			elseif TppLocation.IsMotherBase()or TppLocation.IsMBQF()then
				e={id="SetCpType",type=CpType.TYPE_AMERICA}
			end
			if e then
				GameObject.SendCommand(n,e)
			end
		end
	end
	for e,n in pairs(mvars.ene_cpList)do
		if mvars.ene_baseCpList[e]then
			local e=mvars.ene_soldierDefine[n]
			for n,e in ipairs(e)do
				local e=GetGameObjectId(e)
				if e==NULL_ID then
				else
					SendCommand(e,{id="AddRouteAssignMember"})
				end
			end
		end
	end
	for i,n in pairs(mvars.ene_cpList)do
		if not mvars.ene_baseCpList[i]then
			local e=mvars.ene_soldierDefine[n]
			for n,e in ipairs(e)do
				local e=GetGameObjectId(e)
				if e==NULL_ID then
				else
					SendCommand(e,{id="AddRouteAssignMember"})
				end
			end
		end
	end
	this.AssignSoldiersToCP()
end
function this.AssignSoldiersToCP()
	local r=TppMission.GetMissionID()
	this._ConvertSoldierNameKeysToId(mvars.ene_soldierTypes)
	mvars.ene_soldierSubType=mvars.ene_soldierSubType or{}
	mvars.ene_soldierLrrp=mvars.ene_soldierLrrp or{}
	local n=this.subTypeOfCp
	for a,p in pairs(mvars.ene_soldierIDList)do
		local i=mvars.ene_cpList[a]
		local o=n[i]
		local s=false
		for n,p in pairs(p)do
			SendCommand(n,{id="SetCommandPost",cp=i})
			if mvars.ene_lrrpTravelPlan[a]then
				SendCommand(n,{id="SetLrrp",travelPlan=mvars.ene_lrrpTravelPlan[a]})
				mvars.ene_soldierLrrp[n]=true
				if mvars.ene_lrrpVehicle[a]then
					local e=GameObject.GetGameObjectId("TppVehicle2",mvars.ene_lrrpVehicle[a])
					local e={id="SetRelativeVehicle",targetId=e,rideFromBeginning=true}SendCommand(n,e)
				end
			end
			local t
			local e=this.GetSoldierType(n)t={id="SetSoldier2Type",type=e}
			GameObject.SendCommand(n,t)
			if(e~=EnemyType.TYPE_SKULL and e~=EnemyType.TYPE_CHILD)and o then
				mvars.ene_soldierSubType[n]=o
			end
			if r~=10080 and r~=11080 then
				if e==EnemyType.TYPE_CHILD then
					s=true
				end
			end
		end
		if s then
			SendCommand(a,{id="SetChildCp"})
		end
	end
end
function this.InitCpGroups()
	mvars.ene_cpGroups={}
end
function this.RegistCpGroups(n)
	this.SetCommonCpGroups()
	if IsTypeTable(n)then
		for e,n in pairs(n)do
			mvars.ene_cpGroups[e]=mvars.ene_cpGroups[e]or{}
			for t,n in pairs(n)do
				table.insert(mvars.ene_cpGroups[e],n)
			end
		end
	end
end
function this.SetCommonCpGroups()
	if not IsTypeTable(mvars.loc_locationCommonCpGroups)then
		return
	end
	for n,t in pairs(mvars.loc_locationCommonCpGroups)do
		if IsTypeTable(t)then
			mvars.ene_cpGroups[n]={}
			for e,a in pairs(mvars.ene_soldierDefine)do
				if t[e]then
					table.insert(mvars.ene_cpGroups[n],e)
				end
			end
		end
	end
end
function this.SetCpGroups()
	local e={type="TppCommandPost2"}
	local n={id="SetCpGroups",cpGroups=mvars.ene_cpGroups}SendCommand(e,n)
end
function this.RegistVehicleSettings(e)
	if not IsTypeTable(e)then
		return
	end
	mvars.ene_vehicleSettings=e
	local n=0
	for e,e in pairs(e)do
		n=n+1
	end
	mvars.ene_vehicleDefine=mvars.ene_vehicleDefine or{}
	mvars.ene_vehicleDefine.instanceCount=n
end
function this.SpawnVehicles(n)
	for t,n in ipairs(n)do
		this.SpawnVehicle(n)
	end
end
function this.SpawnVehicle(e)
	if not IsTypeTable(e)then
		return
	end
	if e.id~="Spawn"then
		e.id="Spawn"end
	local n=e.locator
	if not n then
		return
	end
	local e=GameObject.SendCommand({type="TppVehicle2"},e)
	if not e then
	end
end
function this.RespawnVehicle(e)
	if not IsTypeTable(e)then
		return
	end
	if e.id~="Respawn"then
		e.id="Respawn"end
	local n=e.name
	if not n then
		return
	end
	local e=GameObject.SendCommand({type="TppVehicle2"},e)
	if not e then
	end
end
function this.DespawnVehicles(n)
	for t,n in ipairs(n)do
		this.DespawnVehicle(n)
	end
end
function this.DespawnVehicle(e)
	if not IsTypeTable(e)then
		return
	end
	if e.id~="Despawn"then
		e.id="Despawn"end
	local n=e.locator
	if not n then
		return
	end
	local e=GameObject.SendCommand({type="TppVehicle2"},e)
	if not e then
	end
end
function this.SetUpVehicles()
	--rX5 doesn't seem to be used anywhere
	if mvars.ene_vehicleSettings==nil then
		return
	end
	for n,e in pairs(mvars.ene_vehicleSettings)do
		if(IsTypeString(n)and IsTypeTable(e))and e.type then
			local n={id="Spawn",locator=n,type=e.type}
			if e.subType then
				n.subType=e.subType
			end
			--      TUPPMLog.Log("SetUpVehicles for: "..tostring(n.locator)..", type: "..tostring(e.type)..", subtype: "..tostring(e.subType))
			SendCommand({type="TppVehicle2"},n)
		end
	end
end
function this.AddCpIntelTrapTable(e)
	mvars.ene_cpIntelTrapTable=mvars.ene_cpIntelTrapTable or{}
	mvars.ene_cpIntelTrapTable[e]="trap_intel_"..e
end
function this.GetCpIntelTrapTable()
	return mvars.ene_cpIntelTrapTable
end
--rX47 Deminification
function this.GetCurrentRouteSetType(routeTypeStrCode32,cpPhase,cpId)

	local routeTypeSelectorFunc=function(cpId,routeTypeString)
		if not routeTypeString then
			routeTypeString=TppClock.GetTimeOfDayIncludeMidNight()
		end
		local routeTypeToSelect="sneak"..("_"..routeTypeString)
		if cpId then
			local sneakMidnightRouteNotPresent=not next(mvars.ene_routeSets[cpId].sneak_midnight)
			if routeTypeToSelect=="sneak_midnight"and sneakMidnightRouteNotPresent then
				routeTypeToSelect="sneak_night"end
		end
		return routeTypeToSelect
	end

	if routeTypeStrCode32==0 then
		routeTypeStrCode32=false
	end
	local routeTypeToSelect
	if routeTypeStrCode32 then
		local routeTypeString=this.ROUTE_SET_TYPETAG[routeTypeStrCode32]
		if routeTypeString=="travel"then
			return"travel"
		end
		if routeTypeString=="hold"then
			return"hold"
		end
		if routeTypeString=="sleep"then
			return"sleep"
		end
		if cpPhase==this.PHASE.SNEAK then
			routeTypeToSelect=routeTypeSelectorFunc(cpId,routeTypeString)
		else
			routeTypeToSelect="caution"
		end
	else
		if cpPhase==this.PHASE.SNEAK then
			routeTypeToSelect=routeTypeSelectorFunc(cpId)
		else
			routeTypeToSelect="caution"
		end
	end
	return routeTypeToSelect
end
--rX47 Deminification
function this.GetPrioritizedRouteTable(cpId,selectedRoutesForCpId,routeSetsPriority,sysPhaseOrSoldierGroupOrLrrpTravelOrDefault)
	--	TUPPMLog.Log("__TppEnemy.GetPrioritizedRouteTable BEG__"
	--	.."\tcpId: "..tostring(cpId)
	--  .."\tsysPhase: "..tostring(sysPhaseOrSoldierGroupOrLrrpTravelOrDefault)
	--  ,1)
	local routesToUse={}
	local priorityRouteSetsForCP=routeSetsPriority[cpId]
	if not IsTypeTable(priorityRouteSetsForCP)then
		return
	end
	if mvars.ene_funcRouteSetPriority then
		routesToUse=mvars.ene_funcRouteSetPriority(cpId,selectedRoutesForCpId,routeSetsPriority,sysPhaseOrSoldierGroupOrLrrpTravelOrDefault)
	else
		local t=0
		for a,e in ipairs(priorityRouteSetsForCP)do
			if selectedRoutesForCpId[e]then
				local e=#selectedRoutesForCpId[e]
				if e>t then
					t=e
				end
			end
		end
		local e=1
		for t=1,t do
			for r,a in ipairs(priorityRouteSetsForCP)do
				local n=selectedRoutesForCpId[a]
				if n then
					local n=n[t]
					if n and Tpp.IsTypeTable(n)then --rX48 for Sniper routes tables
						routesToUse[e]=n
						e=e+1
					end
				end
			end
		end
		for r=1,t do
			for a,t in ipairs(priorityRouteSetsForCP)do
				local n=selectedRoutesForCpId[t]
				if n then
					local n=n[r]
					if n and not Tpp.IsTypeTable(n)then --rX48 for non table routes
						routesToUse[e]=n
						e=e+1
					end
				end
			end
		end
	end
	-->r48 Routes shuffle
	--  TUPPMLog.Log(
	--  "selectedRoutesForCpId: "..tostring(InfInspect.Inspect(selectedRoutesForCpId))
	--  .."\n routeSetsPriority["..tostring(cpId).."]: "..tostring(InfInspect.Inspect(routeSetsPriority[cpId]))
	--  ,1)
	--  TUPPMLog.Log(
	--  "-------------------BeforeShuffle-------------------"
	--  .."\n routesToUse: "..tostring(InfInspect.Inspect(routesToUse))
	--  .."\n routesToUseSize: "..tostring(InfInspect.Inspect(#routesToUse))
	--  ,1)
	--r51 Settings
	if TUPPMSettings.routes_ENABLE_shuffle then
		routesToUse=this.ShuffleRoutes(routesToUse)
	end
	--  TUPPMLog.Log(
	--  "-------------------AfterSuffle-------------------"
	--  .."\n routesToUse: "..tostring(InfInspect.Inspect(routesToUse))
	--  .."\n routesToUseSize: "..tostring(InfInspect.Inspect(#routesToUse))
	--  ,1)
	--  TppClock.RegisterClockMessage("ShiftChangeCUSTOM",vars.clock+2)
	--		TppCommand.Weather.RegisterClockMessage{id=Fox.StrCode32("ShiftChangeCUSTOM"),seconds=vars.clock+10,isRepeat=false,nil}
	--<r48 Routes shuffle
	return routesToUse
end

--r47 Func to shuffle routes array table
function this.ShuffleRoutes(routesToUse)
	if TppMission.IsFOBMission(vars.missionCode) then
		return routesToUse
	end

	--r48 Not for missions cause VIP targets tend to avoid safety
	--r49 Enabled route shuffle for missions as well
	--	if not TppMission.IsMbFreeMissions(vars.missionCode) then
	--		return routesToUse
	--	end

	TppMain.SetFixedRandomization()

	local tempRoutesList = {}
	local actualRoutesCopy={}

	if #routesToUse > 0 then
		for k,v in pairs(routesToUse) do
			table.insert(actualRoutesCopy, v)
		end
	end

	--r49 Keep VIPs at top of priority table - the only VIP attr seems to be for M3, did not find other missions yet - most missions I tried have explicit control over VIPs
	for index, routeDetails in pairs(actualRoutesCopy) do
		if Tpp.IsTypeTable(routeDetails) then
			if routeDetails.attr then
				if routeDetails.attr=="VIP" then
					table.insert(tempRoutesList, actualRoutesCopy[index])
					table.remove(actualRoutesCopy, index)
				end
			end
		end
	end

--	TUPPMLog.Log(
--	"TppEnemy.ShuffleRoutes"
--	.."\n vars.missionCode:"..tostring(vars.missionCode)
--	.." vars.mbLayoutCode:"..tostring(vars.mbLayoutCode)
--	.."\n actualRoutesCopy:"..tostring(InfInspect.Inspect(actualRoutesCopy))
--	,3,true)
	
	while #actualRoutesCopy>0 do
		local index=math.random(#actualRoutesCopy)
		table.insert(tempRoutesList, actualRoutesCopy[index])
		table.remove(actualRoutesCopy, index)
		TppMain.Randomize()
	end

--	TUPPMLog.Log(
--	"TppEnemy.ShuffleRoutes"
--	.."\n vars.missionCode:"..tostring(vars.missionCode)
--	.." vars.mbLayoutCode:"..tostring(vars.mbLayoutCode)
--	.."\n tempRoutesList:"..tostring(InfInspect.Inspect(tempRoutesList))
--	,3,true)
	
	TppMain.UnsetFixedRandomization()
	return tempRoutesList

		--	for index,routeName in ipairs(routesToUse) do
		--		table.insert(tempRoutesList, routeName)
		--		table.remove(routesToUse, index)
		--	end
		--	TppMain.Randomize()
		--	while #tempRoutesList > 0 do
		--		local index=math.random(#tempRoutesList)
		--		table.insert(routesToUse, tempRoutesList[index])
		--		table.remove(tempRoutesList, index)
		--	end
		--
		--	return routesToUse

end
--rX47 Deminification
function this.RouteSelector(cpId,routeTypeStrCode32,sysPhaseOrSoldierGroupOrLrrpTravelOrDefault)
	--sysPhaseOrSoldierGroupOrLrrpTravelOrDefault - check mvars.ene_routeSets for clarity on absurd naming
	local routeSetsForCpId=mvars.ene_routeSets[cpId]
	if routeSetsForCpId==nil then
		return{"dummyRoute"}
	end
	if sysPhaseOrSoldierGroupOrLrrpTravelOrDefault==StrCode32"immediately"then
		if routeTypeStrCode32==StrCode32"old"then
			local routeTypeToSelect=this.GetCurrentRouteSetType(nil,this.GetPhaseByCPID(cpId),cpId)
			return this.GetPrioritizedRouteTable(cpId,mvars.ene_routeSetsTemporary[cpId][routeTypeToSelect],mvars.ene_routeSetsPriorityTemporary)
		else
			local routeTypeToSelect=this.GetCurrentRouteSetType(nil,this.GetPhaseByCPID(cpId),cpId)
			return this.GetPrioritizedRouteTable(cpId,routeSetsForCpId[routeTypeToSelect],mvars.ene_routeSetsPriority)
		end
	end
	if sysPhaseOrSoldierGroupOrLrrpTravelOrDefault==StrCode32"SYS_Sneak"then
		local routeTypeToSelect=this.GetCurrentRouteSetType(nil,this.PHASE.SNEAK,cpId)
		return this.GetPrioritizedRouteTable(cpId,routeSetsForCpId[routeTypeToSelect],mvars.ene_routeSetsPriority,sysPhaseOrSoldierGroupOrLrrpTravelOrDefault)
	end
	if sysPhaseOrSoldierGroupOrLrrpTravelOrDefault==StrCode32"SYS_Caution"then
		local routeTypeToSelect=this.GetCurrentRouteSetType(nil,this.PHASE.CAUTION,cpId)
		return this.GetPrioritizedRouteTable(cpId,routeSetsForCpId[routeTypeToSelect],mvars.ene_routeSetsPriority,sysPhaseOrSoldierGroupOrLrrpTravelOrDefault)
	end
	local routeTypeToSelect=this.GetCurrentRouteSetType(routeTypeStrCode32,this.GetPhaseByCPID(cpId),cpId)
	local routesToUse=routeSetsForCpId[routeTypeToSelect][sysPhaseOrSoldierGroupOrLrrpTravelOrDefault]
	if routesToUse then
		-->r48 Routes shuffle
		--  	TUPPMLog.Log(
		--	  "__RouteSelector EarlyReturn__"
		--	  .."\tcpId: "..tostring(cpId)
		--	  .."\n routeTypeToSelect: "..tostring(routeTypeToSelect)
		--	  .."\n sysPhaseOrSoldierGroupOrLrrpTravelOrDefault: "..tostring(sysPhaseOrSoldierGroupOrLrrpTravelOrDefault)
		--  	,1)

		--  	local tableSize=0
		--  	for k,v in pairs(routeSetsForCpId[routeTypeToSelect]) do
		--  		tableSize=tableSize+1
		--  	end

		--  	TUPPMLog.Log(
		--  	"routeSetsForCpId["..tostring(routeTypeToSelect).."]: "..tostring(InfInspect.Inspect(routeSetsForCpId[routeTypeToSelect]))
		--  	.."\n routeSetsForCpId["..tostring(routeTypeToSelect).."]Size: "..tostring(tableSize)
		--  	,1)
		--	  TUPPMLog.Log(
		--	  "-------------------BeforeShuffle-------------------"
		--	  .."\n routesToUse: "..tostring(InfInspect.Inspect(routesToUse))
		--	  .."\n routesToUseSize: "..tostring(InfInspect.Inspect(#routesToUse))
		--	  ,1)

		-->rX48 Get new routes from a different group
		--	  --Nope sadly, even with the conditions, while you can "fix" LRRP routes while *at* an outpost, the moment they leave new routes are selected using this same function. So, simply exclude LRRP from this over randomization
		--  	if tableSize>1 and routeTypeToSelect~="travel" and not string.find(routesToUse[1], '_l_') and not string.find(routesToUse[1], '_lin_') and not string.find(routesToUse[1], '_lout_') then
		--  		TppMain.Randomize()
		--  		local indexOfRouteToSelect = math.random(tableSize)
		--  		local i=0
		--  		local nameOfNewRouteToSelect=nil
		--  		for indexName, routes in pairs(routeSetsForCpId[routeTypeToSelect]) do
		--  			i=i+1
		--  			if (i==indexOfRouteToSelect) then
		--  				nameOfNewRouteToSelect=indexName
		--  				break
		--  			end
		--  		end
		----  		TUPPMLog.Log(
		----  		"Setting new route! OLDsysPhaseOrSoldierGroupOrLrrpTravelOrDefault:"..tostring(sysPhaseOrSoldierGroupOrLrrpTravelOrDefault)
		----  		.." nameOfNewRouteToSelect:"..tostring(nameOfNewRouteToSelect)
		----  		,1)
		--  		routesToUse=routeSetsForCpId[routeTypeToSelect][nameOfNewRouteToSelect]
		--  	end
		--<rX48 Get new routes for a different set
		--r51 Settings
		if TUPPMSettings.routes_ENABLE_shuffle then
			routesToUse=this.ShuffleRoutes(routesToUse)
		end
		--	  TUPPMLog.Log(
		--	  "-------------------AfterSuffle-------------------"
		--	  .."\n routesToUse: "..tostring(InfInspect.Inspect(routesToUse))
		--	  .."\n routesToUseSize: "..tostring(InfInspect.Inspect(#routesToUse))
		--	  ,1)

		--	  if routeTypeToSelect=="sneak_night" or routeTypeToSelect=="sneak_midnight" or routeTypeToSelect=="sneak_day" then
		--  	TppClock.RegisterClockMessage("ShiftChangeCUSTOM",vars.clock+2)
		--			TppCommand.Weather.RegisterClockMessage{id=Fox.StrCode32("ShiftChangeCUSTOM"),seconds=vars.clock+10,isRepeat=false,nil}
		--	  end

		--<r48 Routes shuffle
		return routesToUse
	else
		if routeTypeToSelect=="hold"then
			local routeTypeToSelect=this.GetCurrentRouteSetType(nil,this.GetPhaseByCPID(cpId),cpId)
			return this.GetPrioritizedRouteTable(cpId,routeSetsForCpId[routeTypeToSelect],mvars.ene_routeSetsPriority)
		else
			local routeTypeToSelect=this.GetCurrentRouteSetType(nil,this.GetPhaseByCPID(cpId),cpId)
			return this.GetPrioritizedRouteTable(cpId,routeSetsForCpId[routeTypeToSelect],mvars.ene_routeSetsPriority)
		end
	end
end
this.STR32_CAN_USE_SEARCH_LIGHT=StrCode32"CanUseSearchLight"
this.STR32_CAN_NOT_USE_SEARCH_LIGHT=StrCode32"CanNotUseSearchLight"
this.STR32_IS_GIMMICK_BROKEN=StrCode32"IsGimmickBroken"
this.STR32_IS_NOT_GIMMICK_BROKEN=StrCode32"IsNotGimmickBroken"
function this.SetUpSwitchRouteFunc()
	if not GameObject.DoesGameObjectExistWithTypeName"TppSoldier2"then
		return
	end
	SendCommand({type="TppSoldier2"},{id="SetSwitchRouteFunc",func=this.SwitchRouteFunc})
end
function this.SwitchRouteFunc(a,n,t,a,a)
	if n==this.STR32_CAN_USE_SEARCH_LIGHT then
		local e=mvars.gim_gimmackNameStrCode32Table[t]
		if TppGimmick.IsBroken{gimmickId=e}then
			return false
		else
			if TppClock.GetTimeOfDay()~="night"then
				return false
			end
			return true
		end
	end
	if n==this.STR32_CAN_NOT_USE_SEARCH_LIGHT then
		local e=mvars.gim_gimmackNameStrCode32Table[t]
		if TppGimmick.IsBroken{gimmickId=e}then
			return true
		else
			if TppClock.GetTimeOfDay()~="night"then
				return true
			end
			return false
		end
	end
	if n==this.STR32_IS_GIMMICK_BROKEN then
		local e=mvars.gim_gimmackNameStrCode32Table[t]
		if TppGimmick.IsBroken{gimmickId=e}then
			return true
		else
			return false
		end
	end
	if n==this.STR32_IS_NOT_GIMMICK_BROKEN then
		local e=mvars.gim_gimmackNameStrCode32Table[t]
		if TppGimmick.IsBroken{gimmickId=e}then
			return false
		else
			return true
		end
	end
	return true
end
function this.SetUpCommandPost()
	if not IsTypeTable(mvars.ene_soldierIDList)then
		return
	end
	for cpId,cpName in pairs(mvars.ene_cpList)do
		SendCommand(cpId,{id="SetRouteSelector",func=this.RouteSelector})
	end
end
function this.RegisterRouteAnimation()
	if TppRouteAnimationCollector then
		TppRouteAnimationCollector.ClearGaniPath()
		TppRouteAnimationCollector.RegisterGaniPath(mvars.ene_routeAnimationGaniPathTable)
	end
end
function this.MergeRouteSetDefine(o)
	local function i(n,t)
		if t.priority then
			mvars.ene_routeSetsDefine[n].priority={}
			mvars.ene_routeSetsDefine[n].fixedShiftChangeGroup={}
			for e=1,#(t.priority)do
				mvars.ene_routeSetsDefine[n].priority[e]=t.priority[e]
			end
		end
		if t.fixedShiftChangeGroup then
			for e=1,#(t.fixedShiftChangeGroup)do
				mvars.ene_routeSetsDefine[n].fixedShiftChangeGroup[e]=t.fixedShiftChangeGroup[e]
			end
		end
		for a,e in pairs(this.ROUTE_SET_TYPES)do
			mvars.ene_routeSetsDefine[n][e]=mvars.ene_routeSetsDefine[n][e]or{}
			if t[e]then
				for t,a in pairs(t[e])do
					mvars.ene_routeSetsDefine[n][e][t]={}
					if IsTypeTable(a)then
						for i,a in ipairs(a)do
							mvars.ene_routeSetsDefine[n][e][t][i]=a
						end
					end
				end
			end
		end
	end
	for e,n in pairs(o)do
		mvars.ene_routeSetsDefine[e]=mvars.ene_routeSetsDefine[e]or{}
		local n=n
		if n.walkergearpark then
			local e=GetGameObjectId(e)SendCommand(e,{id="SetWalkerGearParkRoute",routes=n.walkergearpark})
		end
		if mvars.loc_locationCommonRouteSets then
			if mvars.loc_locationCommonRouteSets[e]then
				if mvars.loc_locationCommonRouteSets[e].outofrain then
					local a=GetGameObjectId(e)
					if n.outofrain then
						SendCommand(a,{id="SetOutOfRainRoute",routes=n.outofrain})
					else
						SendCommand(a,{id="SetOutOfRainRoute",routes=mvars.loc_locationCommonRouteSets[e].outofrain})
					end
				end
			end
			if n.USE_COMMON_ROUTE_SETS then
				if mvars.loc_locationCommonRouteSets[e]then
					i(e,mvars.loc_locationCommonRouteSets[e])
				end
			end
		end
		i(e,n)
	end
end
function this.UpdateRouteSet(n)
	for n,t in pairs(n)do
		local n=GetGameObjectId(n)
		if n==NULL_ID then
		else
			mvars.ene_routeSets[n]=mvars.ene_routeSets[n]or{}
			if t.priority then
				mvars.ene_routeSetsPriority[n]={}
				mvars.ene_routeSetsFixedShiftChange[n]={}
				for e=1,#(t.priority)do
					mvars.ene_routeSetsPriority[n][e]=StrCode32(t.priority[e])
				end
			end
			if t.fixedShiftChangeGroup then
				for e=1,#(t.fixedShiftChangeGroup)do
					mvars.ene_routeSetsFixedShiftChange[n][StrCode32(t.fixedShiftChangeGroup[e])]=e
				end
			end
			if mvars.ene_noShiftChangeGroupSetting[n]then
				for t,e in pairs(mvars.ene_noShiftChangeGroupSetting[n])do
					mvars.ene_routeSetsFixedShiftChange[n][t]=e
				end
			end
			for a,e in pairs(this.ROUTE_SET_TYPES)do
				mvars.ene_routeSets[n][e]=mvars.ene_routeSets[n][e]or{}
				if t[e]then
					for t,a in pairs(t[e])do
						mvars.ene_routeSets[n][e][StrCode32(t)]=mvars.ene_routeSets[n][e][StrCode32(t)]or{}
						if type(a)=="number"then
						else
							for a,i in ipairs(a)do
								mvars.ene_routeSets[n][e][StrCode32(t)][a]=i
							end
						end
					end
				end
			end
		end
	end
end
function this.RegisterRouteSet(n)
	mvars.ene_routeSetsDefine={}
	this.MergeRouteSetDefine(n)
	mvars.ene_routeSets={}
	mvars.ene_routeSetsPriority={}
	mvars.ene_routeSetsFixedShiftChange={}
	this.UpdateRouteSet(mvars.ene_routeSetsDefine)
	TppClock.RegisterClockMessage("ShiftChangeAtNight",TppClock.DAY_TO_NIGHT)
	TppClock.RegisterClockMessage("ShiftChangeAtMorning",TppClock.NIGHT_TO_DAY)
	TppClock.RegisterClockMessage("ShiftChangeAtMidNight",TppClock.NIGHT_TO_MIDNIGHT)
end
function this._InsertShiftChangeUnit(t,a,n)
	for e,i in pairs(mvars.ene_shiftChangeTable[t])do
		if n[e]and next(n[e])then
			if n[e].hold then
				mvars.ene_shiftChangeTable[t][e][a*2-1]={n[e].start,n[e].hold,holdTime=n[e].holdTime}
				mvars.ene_shiftChangeTable[t][e][a*2]={n[e].hold,n[e].goal}
			else
				mvars.ene_shiftChangeTable[t][e][a*2-1]={n[e].start,n[e].goal}
				mvars.ene_shiftChangeTable[t][e][a*2]="dummy"end
		end
	end
end
function this._GetShiftChangeRouteGroup(n,o,a,l,s,i,p,t)
	local e=(o-a)+1
	local r=a
	if t[n[a]]then
		e=r
	else
		local i=0
		for a=1,a do
			if t[n[a]]then
				i=i+1
			end
		end
		e=e+i
		local a=0
		for i=e,o do
			if t[n[i]]then
				a=a+1
			end
		end
		e=e-a
		local a=e
		local i=0
		local r=t[n[a]]
		while r do
			i=i+1
			a=a-1
			r=t[n[a]]
		end
		e=e-i
	end
	local a=n[e]
	local t="default"if l[i]then
		t=i
	end
	local e=nil
	if p then
		e="default"if s[i]then
			e=i
		end
	end
	local n=n[r]
	return a,t,e,n
end
function this._MakeShiftChangeUnit(t,i,n,r,o,d,l,a,T,u,_)
	if mvars.ene_noShiftChangeGroupSetting[t]and mvars.ene_noShiftChangeGroupSetting[t][n]then
		return nil
	end
	local n,i,e,a=this._GetShiftChangeRouteGroup(i,a,T,r,d,n,o,_)
	local e={}
	for n,t in pairs(mvars.ene_shiftChangeTable[t])do
		e[n]={}
	end
	if(i~="default")or(IsTypeTable(r[StrCode32"default"])and next(r[StrCode32"default"]))then
		e.shiftAtNight.start={"day",n}
		e.shiftAtNight.hold={"hold",i}
		e.shiftAtNight.holdTime=mvars.ene_holdTimes[t]
		e.shiftAtNight.goal={"night",a}
		e.shiftAtMorning.hold={"hold",i}
		e.shiftAtMorning.holdTime=mvars.ene_holdTimes[t]
		e.shiftAtMorning.goal={"day",a}
	else
		e.shiftAtNight.start={"day",n}
		e.shiftAtNight.goal={"night",a}
		e.shiftAtMorning.goal={"day",a}
	end
	if o then
		e.shiftAtMidNight.start={"night",n}
		e.shiftAtMidNight.hold={"sleep",i}
		e.shiftAtMidNight.holdTime=mvars.ene_sleepTimes[t]
		if l then
			e.shiftAtMidNight.goal={"midnight",a}
		else
			e.shiftAtMidNight.goal={"night",n}
		end
		e.shiftAtMorning.start={"midnight",n}
	else
		e.shiftAtMorning.start={"night",n}
	end
	return e
end
function this.MakeShiftChangeTable()
	mvars.ene_shiftChangeTable={}
	for n,t in pairs(mvars.ene_routeSetsPriority)do
		if not IsTypeTable(t)then
			return
		end
		local r=false
		local o=false
		if next(mvars.ene_routeSets[n].sleep)then
			mvars.ene_shiftChangeTable[n]={shiftAtNight={},shiftAtMorning={},shiftAtMidNight={}}r=true
			if next(mvars.ene_routeSets[n].sneak_midnight)then
				o=true
			end
		else
			mvars.ene_shiftChangeTable[n]={shiftAtNight={},shiftAtMorning={}}
		end
		local p=mvars.ene_routeSets[n].hold
		local s=nil
		if r then
			s=mvars.ene_routeSets[n].sleep
		end
		local a=1
		local l=#t
		for _,d in ipairs(t)do
			local i
			i=this._MakeShiftChangeUnit(n,t,d,p,r,s,o,l,_,a,mvars.ene_routeSetsFixedShiftChange[n])
			if i then
				this._InsertShiftChangeUnit(n,a,i)a=a+1
			end
		end
	end
end
--r48 Fire a clock event that in turn fires random shift change
function this.SetCustomShift(isComingFromOnMissionCanStart)
	--isComingFromOnMissionCanStart is not used for now - can't figure out a reliable way to implement fixed time shifts when restarting from checkpoints
	
	--r51 Settings - Currently only used for MB
	if not TUPPMSettings.mtbs_ENABLE_randomShifts then return end
	
	if TppMission.IsFOBMission(vars.missionCode) then return end

	--r48 Only set for MB currently untill I find a better approach for missions
	if not TppMission.IsMbFreeMissions(vars.missionCode) then return end

	math.randomseed(vars.clock)
	TppMain.Randomize()

	local missionStartTime=nil
	local scheduledTimeForShiftChange=nil

	local hoursToChangeShiftFromNow=3 --3 hours seems enough for soldiers to move to new position on larger bases

	hoursToChangeShiftFromNow=math.random(hoursToChangeShiftFromNow,6)

	if TppMission.IsMbFreeMissions(vars.missionCode) then
		hoursToChangeShiftFromNow=math.random(3)
	end

	scheduledTimeForShiftChange=vars.clock+(hoursToChangeShiftFromNow*60*60)

	--r48 manage clock overflow
	if scheduledTimeForShiftChange>24*60*60 then
		scheduledTimeForShiftChange=scheduledTimeForShiftChange-(24*60*60)
	end
	--set isRepeat if you want to set a fixed time afer mission start but don't want it changing on checkpoint reloads. Since the clock will be active and re-registered with the same name, this is safe
	TppCommand.Weather.RegisterClockMessage{id=Fox.StrCode32("ShiftChangeCUSTOM"),seconds=scheduledTimeForShiftChange,isRepeat=false,nil}
	TUPPMLog.Log("SetCustomShift alwaysRandom:"..tostring(isComingFromOnMissionCanStart).." scheduledTimeForShiftChange:"..tostring(TppClock.FormalizeTime(scheduledTimeForShiftChange,"string")),3)

	TppMain.UnsetFixedRandomization()
end

function this.ShiftChangeByTime(n)
	--r48 Shift change for MB too! Yay!
	--r51 Settings
  if not TUPPMSettings.mtbs_ENABLE_randomShifts and (TppLocation.IsMotherBase()or TppLocation.IsMBQF()) then
    return
  end
	if not IsTypeTable(mvars.ene_shiftChangeTable)then
		return
	end

	this.SetCustomShift(false) --r48 Set shift timer every time a shift is decided

	for a,e in pairs(mvars.ene_shiftChangeTable)do
		if e[n]then
			SendCommand(a,{id="ShiftChange",schedule=e[n]})
		end
	end
end
local function d(n,e,a)
	local t=SendCommand(a,{id="GetPosition"})
	local e=e-t
	local e=e:GetLengthSqr()
	if e>n then
		return false
	else
		return true
	end
end
function this.MakeCpLinkDefineTable(t,n)
	local e={}
	for a=1,#n do
		local i=Tpp.SplitString(n[a],"	")
		local n=t[a]
		if n then
			e[n]=e[n]or{}
			for a,i in pairs(i)do
				local t=t[a]
				if t then
					e[n][t]=e[n][t]or{}
					local a=false
					if tonumber(i)>0 then
						a=true
					end
					e[n][t]=a
				end
			end
		end
	end
	return e
end
function this.MakeReinforceTravelPlan(i,a,p,n,t)
	if not Tpp.IsTypeTable(t)then
		return
	end
	local a=a[n]
	if a==nil then
		return
	end
	mvars.ene_travelPlans=mvars.ene_travelPlans or{}
	local r=0
	for r,t in pairs(t)do
		if mvars.ene_soldierDefine[t]then
			if a[t]then
				local o=i[n]
				local r=i[t]
				local a="rp_"..(n..("_From_"..t))
				mvars.ene_travelPlans[a]=mvars.ene_travelPlans[a]or{}
				local s=string.format("rp_%02dto%02d",r,o)
				local e=this.GetFormattedLrrpCpNameByLrrpNum(o,r,p,i)
				mvars.ene_travelPlans[a]={{cp=e,routeGroup={"travel",s}},{cp=n,finishTravel=true}}
				mvars.ene_reinforcePlans[a]={{toCp=n,fromCp=t,type="respawn"}}
			end
		end
	end
end
function this.MakeTravelPlanTable(T,_,d,t,n,l)
	if((not Tpp.IsTypeTable(n)or not Tpp.IsTypeTable(n[1]))or not Tpp.IsTypeString(t))or(n[1].cp==nil and n[1].base==nil)then
		return
	end
	mvars.ene_travelPlans=mvars.ene_travelPlans or{}
	mvars.ene_travelPlans[t]=mvars.ene_travelPlans[t]or{}
	local o=mvars.ene_travelPlans[t]
	local p=#n
	local i,r
	if(not n.ONE_WAY)and n[#n].base then
		i=n[#n]
	end
	for t=1,p do
		local a
		if n.ONE_WAY and(t==p)then
			a=true
		end
		if n[t].base then
			if t==1 then
				r=n[t]
			else
				i=n[t-1]r=n[t]
			end
			this.AddLinkedBaseTravelCourse(T,_,d,l,o,i,r,a)
		elseif n[t].cp then
			local n=n[t]
			if IsTypeTable(n)then
				this.AddTravelCourse(o,n,a)
			end
		end
	end
end
function this.AddLinkedBaseTravelCourse(d,l,o,i,s,a,t,p)
	local n
	if a and a.base then
		n=a.base
	end
	local a=t.base
	local r=false
	if n then
		r=l[n][a]
	end
	if r then
		local n,t=this.GetFormattedLrrpCpName(n,a,o,d)
		local n={cp=n,routeGroup={"travel",t}}
		this.AddTravelCourse(s,n)
	elseif n==nil then
	end
	local o
	if t.wait then
		o=t.wait
	else
		o=i
	end
	local i
	if t.routeGroup and Tpp.IsTypeTable(t.routeGroup)then
		i={t.routeGroup[1],t.routeGroup[2]}
	else
		local t
		local e=mvars.ene_defaultTravelRouteGroup
		if((e and r)and e[n])and Tpp.IsTypeTable(e[n][a])then
			t=e[n][a]
		end
		if t then
			i={t[1],t[2]}
		else
			i={"travel","lrrpHold"}
		end
	end
	local n={cp=a,routeGroup=i,wait=o}
	this.AddTravelCourse(s,n,p)
end
function this.GetFormattedLrrpCpNameByLrrpNum(e,n,i,t)
	local t,a
	if e<n then
		t=e
		a=n
	else
		t=n
		a=e
	end
	local t=string.format("%s_%02d_%02d_lrrp",i,t,a)
	local e=string.format("lrrp_%02dto%02d",e,n)
	return t,e
end
function this.GetFormattedLrrpCpName(t,a,i,n)
	local t=n[t]
	local a=n[a]
	return this.GetFormattedLrrpCpNameByLrrpNum(t,a,i,n)
end
function this.AddTravelCourse(t,e,n)
	if n then
		e.finishTravel=true
	else
		e.finishTravel=nil
	end
	table.insert(t,e)
end
function this.SetTravelPlans(i)
	mvars.ene_reinforcePlans={}
	mvars.ene_travelPlans={}
	if mvars.loc_locationCommonTravelPlans then
		local n=TppLocation.GetLocationName()
		if n then
			local t=mvars.ene_lrrpNumberDefine
			local a=mvars.ene_cpLinkDefine
			for r,i in pairs(i)do
				this.MakeTravelPlanTable(t,a,n,r,i,this.DEFAULT_TRAVEL_HOLD_TIME)
			end
			local i=mvars.loc_locationCommonTravelPlans.reinforceTravelPlan
			if mvars.ene_useCommonReinforcePlan and i then
				for i,r in pairs(i)do
					if mvars.ene_soldierDefine[i]then
						this.MakeReinforceTravelPlan(t,a,n,i,r)
					end
				end
			end
		end
	else
		mvars.ene_travelPlans=i
	end
	SendCommand({type="TppSoldier2"},{id="SetTravelPlan",travelPlan=mvars.ene_travelPlans})
	if next(mvars.ene_reinforcePlans)then
		SendCommand({type="TppCommandPost2"},{id="SetReinforcePlan",reinforcePlan=mvars.ene_reinforcePlans})
	end
end
function this.RegistHoldBrokenState(n)
	if not IsTypeString(n)then
		return
	end
	local t=GetGameObjectId(n)
	if t==NULL_ID then
		return
	end
	local e=this.AddBrokenStateList(n)
	if not e then
		return
	end
	mvars.ene_vehicleBrokenStateIndexByName=mvars.ene_vehicleBrokenStateIndexByName or{}
	mvars.ene_vehicleBrokenStateIndexByName[n]=e
	mvars.ene_vehicleBrokenStateIndexByGameObjectId=mvars.ene_vehicleBrokenStateIndexByGameObjectId or{}
	mvars.ene_vehicleBrokenStateIndexByGameObjectId[t]=e
end
function this.AddBrokenStateList(n)
	local e
	local a=StrCode32(n)
	for t=0,(TppDefine.MAX_HOLD_VEHICLE_BROKEN_STATE_COUNT-1)do
		local n=svars.ene_holdBrokenStateName[t]
		if(n==0)or(n==a)then
			e=t
			break
		end
	end
	if e then
		svars.ene_holdBrokenStateName[e]=a
		return e
	else
		return
	end
end
function this._OnHeliBroken(n,t)
	if t==StrCode32"Start"then
		this.PlayTargetEliminatedRadio(n)
	end
end
function this._OnVehicleBroken(n,t)
	this.SetVehicleBroken(n)
	if t==StrCode32"End"then
		this.PlayTargetEliminatedRadio(n)
	end
end
function this._OnWalkerGearBroken(t,n)
	if n==StrCode32"End"then
		this.PlayTargetEliminatedRadio(t)
	end
end
function this.SetVehicleBroken(e)
	if not mvars.ene_vehicleBrokenStateIndexByGameObjectId then
		return
	end
	local e=mvars.ene_vehicleBrokenStateIndexByGameObjectId[e]
	if e then
		svars.ene_isVehicleBroken[e]=true
	end
end
function this.IsVehicleBroken(e)
	local n
	if IsTypeString(e)then
		n=mvars.ene_vehicleBrokenStateIndexByName[e]
	elseif IsTypeNumber(e)then
		n=mvars.ene_vehicleBrokenStateIndexByGameObjectId[e]
	end
	if n then
		return svars.ene_isVehicleBroken[n]
	end
end
function this.IsVehicleAlive(n)
	local e
	if IsTypeString(n)then
		e=GetGameObjectId(n)
	elseif IsTypeNumber(n)then
		e=n
	end
	if e==NULL_ID then
		return
	end
	return SendCommand(e,{id="IsAlive"})
end
function this.PlayTargetRescuedRadio(n)
	local t=this.IsEliminateTarget(n)
	local e=this.IsRescueTarget(n)
	if t then
		TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.TARGET_ELIMINATED)
	elseif e then
		TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.TARGET_RECOVERED)
	end
end
function this.PlayTargetEliminatedRadio(n)
	local e=this.IsEliminateTarget(n)
	if e then
		TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.TARGET_ELIMINATED)
	end
end
function this.RegistHoldRecoveredState(n)
	if not IsTypeString(n)then
		return
	end
	local t=GetGameObjectId(n)
	if t==NULL_ID then
		return
	end
	local e=this.AddRecoveredStateList(n)
	if not e then
		return
	end
	mvars.ene_recoverdStateIndexByName=mvars.ene_recoverdStateIndexByName or{}
	mvars.ene_recoverdStateIndexByName[n]=e
	mvars.ene_recoverdStateIndexByGameObjectId=mvars.ene_recoverdStateIndexByGameObjectId or{}
	mvars.ene_recoverdStateIndexByGameObjectId[t]=e
end
function this.AddRecoveredStateList(n)
	local e
	local a=StrCode32(n)
	for n=0,(TppDefine.MAX_HOLD_RECOVERED_STATE_COUNT-1)do
		local t=svars.ene_holdRecoveredStateName[n]
		if(t==0)or(t==a)then
			e=n
			break
		end
	end
	if e then
		svars.ene_holdRecoveredStateName[e]=a
		return e
	else
		return
	end
end
function this.SetRecovered(e)
	if not mvars.ene_recoverdStateIndexByGameObjectId then
		return
	end
	local e=mvars.ene_recoverdStateIndexByGameObjectId[e]
	if e then
		svars.ene_isRecovered[e]=true
	end
end
function this.ExecuteOnRecoveredCallback(n,s,r,o,a,i,t)
	if not mvars.ene_recoverdStateIndexByGameObjectId then
		return
	end
	local e=mvars.ene_recoverdStateIndexByGameObjectId[n]
	if not e then
		return
	end
	local e
	if TppMission.systemCallbacks and TppMission.systemCallbacks.OnRecovered then
		e=TppMission.systemCallbacks.OnRecovered
	end
	if not e then
		return
	end
	if not TppMission.CheckMissionState(true,false,true,false)then
		return
	end
	e(n,s,r,o,a,i,t)
end
local T=10*10
function this.CheckAllVipClear(n)
	return this.CheckAllTargetClear(n)
end
function this.CheckAllTargetClear(n)
	local n=mvars
	local e=this
	local a=Vector3(vars.playerPosX,vars.playerPosY,vars.playerPosZ)
	TppHelicopter.SetNewestPassengerTable()
	local t={{n.ene_eliminateTargetList,e.CheckSoldierEliminateTarget,"EliminateTargetSoldier"},{n.ene_eliminateHelicopterList,e.CheckHelicopterEliminateTarget,"EliminateTargetHelicopter"},{n.ene_eliminateVehicleList,e.CheckVehicleEliminateTarget,"EliminateTargetVehicle"},{n.ene_eliminateWalkerGearList,e.CheckWalkerGearEliminateTarget,"EliminateTargetWalkerGear"},{n.ene_childTargetList,e.CheckRescueTarget,"childTarget"}}
	if n.ene_rescueTargetOptions then
		if not n.ene_rescueTargetOptions.orCheck then
			table.insert(t,{n.ene_rescueTargetList,e.CheckRescueTarget,"RescueTarget"})
		end
	end
	for e=1,#t do
		local e,t,n=t[e][1],t[e][2],t[e][3]
		if IsTypeTable(e)and next(e)then
			for n,e in pairs(e)do
				if not t(n,a,e)then
					return false
				end
			end
		end
	end
	if n.ene_rescueTargetOptions and n.ene_rescueTargetOptions.orCheck then
		local t=false
		for n,i in pairs(n.ene_rescueTargetList)do
			if e.CheckRescueTarget(n,a,i)then
				t=true
			end
		end
		return t
	end
	return true
end
function this.CheckSoldierEliminateTarget(n,i,a)
	local a=SendCommand(n,{id="GetLifeStatus"})
	local t=SendCommand(n,{id="GetStatus"})
	if this._IsEliminated(a,t)then
		return true
	elseif this._IsNeutralized(a,t)then
		if d(T,i,n)then
			return true
		else
			return false
		end
	end
	return false
end
function this.CheckHelicopterEliminateTarget(e,n,n)
	local e=GameObject.SendCommand(e,{id="IsBroken"})
	if e then
		return true
	else
		return false
	end
end
function this.CheckVehicleEliminateTarget(n,t,t)
	if this.IsRecovered(n)then
		return true
	elseif this.IsVehicleBroken(n)then
		return true
	else
		return false
	end
end
function this.CheckWalkerGearEliminateTarget(e,n,n)
	local n=GameObject.SendCommand(e,{id="IsBroken"})
	if n then
		return true
	elseif GameObject.SendCommand(e,{id="IsFultonCaptured"})then
		return true
	else
		return false
	end
end
function this.CheckRescueTarget(n,t,a)
	if this.IsRecovered(n)then
		return true
	elseif d(T,t,n)then
		return true
	elseif TppHelicopter.IsInHelicopter(n)then
		return true
	else
		return false
	end
end
function this.FultonRecoverOnMissionGameEnd()
	if mvars.ene_soldierIDList==nil then
		return
	end
	local i=Vector3(vars.playerPosX,vars.playerPosY,vars.playerPosZ)
	local n=10
	local t=TppMission.GetMissionID()
	if TppMission.IsFOBMission(t)then
		n=0
	end
	local a=n*n
	local n
	if Tpp.IsHelicopter(vars.playerVehicleGameObjectId)then
		n=false
	else
		n=true
	end
	local t=this.GetAllActiveEnemyWalkerGear()
	for t,e in pairs(t)do
		if d(a,i,e)then
			local t={id="GetResourceId"}
			local t=GameObject.SendCommand(e,t)
			TppTerminal.OnFulton(e,nil,nil,t,true,n,PlayerInfo.GetLocalPlayerIndex())
		end
	end
	TppHelicopter.SetNewestPassengerTable()
	TppTerminal.OnRecoverByHelicopterAlreadyGetPassengerList()
	for r,t in pairs(mvars.ene_soldierIDList)do
		for t,r in pairs(t)do
			if d(a,i,t)and(not this.IsQuestNpc(t))then
				this.AutoFultonRecoverNeutralizedTarget(t,n)
			end
		end
	end
	local t=this.GetAllHostages()
	for r,t in pairs(t)do
		if((not TppHelicopter.IsInHelicopter(t))and d(a,i,t))and(not this.IsQuestNpc(t))then
			local e=TppMotherBaseManagement.GetStaffIdFromGameObject{gameObjectId=t}
			TppTerminal.OnFulton(t,nil,nil,e,true,n,PlayerInfo.GetLocalPlayerIndex())
		end
	end
	TppHelicopter.ClearPassengerTable()
end
function this.AutoFultonRecoverNeutralizedTarget(n,a)
	local t=SendCommand(n,{id="GetLifeStatus"})
	if t==this.LIFE_STATUS.SLEEP or t==this.LIFE_STATUS.FAINT then
		local e
		e=TppMotherBaseManagement.GetStaffIdFromGameObject{gameObjectId=n}
		TppTerminal.OnFulton(n,nil,nil,e,nil,a,PlayerInfo.GetLocalPlayerIndex())
	end
end
function this.CheckQuestTargetOnOutOfActiveArea(n)
	if not IsTypeTable(n)then
		return
	end
	local o=Vector3(vars.playerPosX,vars.playerPosY,vars.playerPosZ)
	local t=10
	local i=t*t
	local t=false
	for n,n in pairs(n)do
		local n=GetGameObjectId(soliderName)
		if n~=NULL_ID then
			if d(i,o,n)then
				t=true
				this.AutoFultonRecoverNeutralizedTarget(n)
			end
		end
	end
	return t
end
function this.ChangeRouteUsingGimmick(e,n,a,n)
	local n=TppGimmick.GetRouteConnectedGimmickId(e)
	if(n~=nil)and TppGimmick.IsBroken{gimmickId=n}then
		local n
		for e,t in pairs(mvars.ene_soldierIDList)do
			if t[a]then
				n=e
				break
			end
		end
		if n then
			local e={id="SetRouteEnabled",routes={e},enabled=false}SendCommand(n,e)
		end
	else
		mvars.ene_usingGimmickRouteEnemyList=mvars.ene_usingGimmickRouteEnemyList or{}
		mvars.ene_usingGimmickRouteEnemyList[e]=mvars.ene_usingGimmickRouteEnemyList[e]or{}
		mvars.ene_usingGimmickRouteEnemyList[e]=a
		SendCommand(a,{id="SetSneakRoute",route=e})
	end
end
function this.DisableUseGimmickRouteOnShiftChange(a,e)
	if not IsTypeTable(e)then
		return
	end
	if mvars.ene_usingGimmickRouteEnemyList==nil then
		return
	end
	for n,e in pairs(e)do
		local n=StrCode32(e)
		local n=mvars.ene_usingGimmickRouteEnemyList[n]
		if n then
			SendCommand(n,{id="SetSneakRoute",route=""})
		end
		local n=mvars.gim_routeGimmickConnectTable[StrCode32(e)]
		if(n~=nil)and TppGimmick.IsBroken{gimmickId=n}then
			local e={id="SetRouteEnabled",routes={e},enabled=false}SendCommand(a,e)
		end
	end
end
function this.IsEliminateTarget(e)
	local a=mvars.ene_eliminateTargetList and mvars.ene_eliminateTargetList[e]
	local n=mvars.ene_eliminateHelicopterList and mvars.ene_eliminateHelicopterList[e]
	local t=mvars.ene_eliminateVehicleList and mvars.ene_eliminateVehicleList[e]
	local e=mvars.ene_eliminateWalkerGearList and mvars.ene_eliminateWalkerGearList[e]
	local e=((a or n)or t)or e
	return e
end
function this.IsRescueTarget(e)
	local e=mvars.ene_rescueTargetList and mvars.ene_rescueTargetList[e]
	return e
end
function this.IsChildTarget(e)
	local e=mvars.ene_childTargetList and mvars.ene_childTargetList[e]
	return e
end
function this.IsChildHostage(e)
	if IsTypeString(e)then
		e=GameObject.GetGameObjectId(e)
	end
	local e=GameObject.SendCommand(e,{id="IsChild"})
	return e
end
function this.IsFemaleHostage(e)
	if IsTypeString(e)then
		e=GameObject.GetGameObjectId(e)
	end
	local e=GameObject.SendCommand(e,{id="isFemale"})
	return e
end
function this.AddTakingOverHostage(n)
	local a=GameObject.GetTypeIndex(n)
	if(a~=TppGameObject.GAME_OBJECT_TYPE_HOSTAGE2)then
		return
	end
	if this.IsRecovered(n)then
		return
	end
	if TppHelicopter.IsInHelicopter(n)then
		return
	end
	if mvars.ene_ignoreTakingOverHostage and mvars.ene_ignoreTakingOverHostage[n]then
		return
	end
	if this.IsRescueTarget(n)then
		return
	end
	local t=SendCommand(n,{id="GetMarkerEnabled"})
	if t then
		this._AddTakingOverHostage(n)
	end
end
function this._AddTakingOverHostage(n)
	if gvars.ene_takingOverHostageCount>=TppDefine.MAX_TAKING_OVER_HOSTAGE_COUNT then
		return
	end
	local e=gvars.ene_takingOverHostageCount
	local a=SendCommand(n,{id="GetPosition"})
	local o,r=SendCommand(n,{id="GetStaffId",divided=true})
	local i=SendCommand(n,{id="GetFaceId"})
	local n=SendCommand(n,{id="GetKeepFlagValue"})
	gvars.ene_takingOverHostagePositions[e*3+0]=a:GetX()
	gvars.ene_takingOverHostagePositions[e*3+1]=a:GetY()
	gvars.ene_takingOverHostagePositions[e*3+2]=a:GetZ()
	gvars.ene_takingOverHostageStaffIdsUpper[e]=o
	gvars.ene_takingOverHostageStaffIdsLower[e]=r
	gvars.ene_takingOverHostageFaceIds[e]=i
	gvars.ene_takingOverHostageFlags[e]=n
	gvars.ene_takingOverHostageCount=gvars.ene_takingOverHostageCount+1
end
function this.IsNeedHostageTakingOver(e)
	if TppMission.IsSysMissionId(vars.missionCode)then
		return false
	end
	if TppMission.IsHelicopterSpace(e)then
		return false
	end
	if(TppLocation.IsAfghan()or TppLocation.IsMiddleAfrica())then
		return true
	else
		return false
	end
end
function this.ResetTakingOverHostageInfo()
	gvars.ene_takingOverHostageCount=0
	for e=0,TppDefine.MAX_TAKING_OVER_HOSTAGE_COUNT-1 do
		for n=0,2 do
			gvars.ene_takingOverHostagePositions[e*3+n]=0
		end
		gvars.ene_takingOverHostageStaffIdsUpper[e]=0
		gvars.ene_takingOverHostageStaffIdsLower[e]=0
		gvars.ene_takingOverHostageFaceIds[e]=0
		gvars.ene_takingOverHostageFlags[e]=0
	end
end
function this.SpawnTakingOverHostage(n)
	if not IsTypeTable(n)then
		return
	end
	for t,n in ipairs(n)do
		this._SpawnTakingOverHostage(t-1,n)
	end
end
function this._SpawnTakingOverHostage(n,e)
	local e=GetGameObjectId(e)
	if e==NULL_ID then
		return
	end
	if n<gvars.ene_takingOverHostageCount then
		local a=gvars.ene_takingOverHostageStaffIdsUpper[infoIndex]
		local i=gvars.ene_takingOverHostageStaffIdsLower[infoIndex]SendCommand(e,{id="SetStaffId",divided=true,staffId=a,staffId2=i})
		if TppMission.IsMissionStart()then
			SendCommand(e,{id="SetEnabled",enabled=true})
			local a=Vector3(gvars.ene_takingOverHostagePositions[n*3],gvars.ene_takingOverHostagePositions[n*3+1],gvars.ene_takingOverHostagePositions[n*3+2])SendCommand(e,{id="Warp",position=a})SendCommand(e,{id="SetFaceId",faceId=gvars.ene_takingOverHostageFaceIds[n]})SendCommand(e,{id="SetKeepFlagValue",keepFlagValue=gvars.ene_takingOverHostageFlags[n]})
		end
	else
		SendCommand(e,{id="SetEnabled",enabled=false})
	end
end
function this.SetIgnoreTakingOverHostage(e)
	if not IsTypeTable(e)then
		return
	end
	mvars.ene_ignoreTakingOverHostage=mvars.ene_ignoreTakingOverHostage or{}
	for n,e in ipairs(e)do
		local e=GetGameObjectId(e)
		if e~=NULL_ID then
			mvars.ene_ignoreTakingOverHostage[e]=true
		else
			return
		end
	end
end
function this.SetIgnoreDisableNpc(n,i)
	local e
	if IsTypeNumber(n)then
		e=n
	elseif IsTypeString(n)then
		e=GetGameObjectId(n)
	else
		return
	end
	if e==NULL_ID then
		return
	end
	SendCommand(e,{id="SetIgnoreDisableNpc",enable=i})
	return true
end
function this.NPCEntryPointSetting(e)
	--  TUPPMLog.Log("NPCEntryPointSetting")
	local e=e[gvars.heli_missionStartRoute]
	if not e then
		return
	end
	for e,n in pairs(e)do
		local t,n=n[1],n[2]
		--r43 Vehicle landing point debugging
		--    TUPPMLog.Log("e: "..tostring(e))
		--    TUPPMLog.Log("t: "..tostring(t))
		--    TUPPMLog.Log("n: "..tostring(n))

		--    if e==EntryBuddyType.VEHICLE then
		--      TUPPMLog.Log("Vehicle drop point: "..tostring(t))
		--      local newPosition= Vector3(t:GetX(),t:GetY()-1,t:GetZ())
		--      TUPPMLog.Log("Vehicle drop newPosition: "..tostring(newPosition))
		--      t=newPosition
		--    end

		TppBuddyService.SetMissionEntryPosition(e,t)
		TppBuddyService.SetMissionEntryRotationY(e,n)
	end
end
function this.SetupQuestEnemy()
	local t="quest_cp"local n="gt_quest_0000"if mvars.ene_soldierDefine.quest_cp==nil then
		return
	end
	for n,e in ipairs(mvars.ene_soldierDefine.quest_cp)do
		local e=GameObject.GetGameObjectId("TppSoldier2",e)
		if e~=NULL_ID then
			GameObject.SendCommand(e,{id="SetEnabled",enabled=false})
		end
	end
	TppCombatLocatorProvider.RegisterCombatLocatorSetToCpforLua{cpName=t,locatorSetName=n}
end
function this.OnAllocateQuest(e,n,a)
	local function i(e,n)
		local t="SetNone"if IsTypeTable(n)and IsTypeTable(e)then
			TppSoldierFace.SetAndConvertExtendFova{face=n,body=e}t="SetFaceAndBody"elseif IsTypeTable(n)then
			TppSoldierFace.SetAndConvertExtendFova{face=n}t="SetFace"elseif IsTypeTable(e)then
			TppSoldierFace.SetAndConvertExtendFova{body=e}t="SetBody"end
		return t
	end
	if n==nil and e==nil then
		return
	end
	a=a or false
	if a==false then
		local t
		local a=i(e,n)
		if a=="SetFaceAndBody"then
			t={id="InitializeAndAllocateExtendFova",face=n,body=e}
		elseif a=="SetFace"then
			t={id="InitializeAndAllocateExtendFova",face=n}
		elseif a=="SetBody"then
			t={id="InitializeAndAllocateExtendFova",body=e}
		end
		GameObject.SendCommand({type="TppSoldier2"},t)
		GameObject.SendCommand({type="TppCorpse"},t)
	else
		if e then
			local n={}
			for t,e in ipairs(e)do
				local t=e[1]
				if IsTypeNumber(t)then
					table.insert(n,e[1])
				end
			end
			TppSoldierFace.SetBodyFovaUserType{hostage=hostageBodyTable}
		end
		local t=i(e,n)
		if t=="SetFaceAndBody"then
			TppSoldierFace.ReserveExtendFovaForHostage{face=n,body=e}
		elseif t=="SetFace"then
			TppSoldierFace.ReserveExtendFovaForHostage{face=n}
		elseif t=="SetBody"then
			TppSoldierFace.ReserveExtendFovaForHostage{body=e}
		end
	end
end
function this.OnAllocateQuestFova(n)
	local a={}
	local t={}
	local s=false
	local o=false
	local p=false
	local d=false
	mvars.ene_questArmorId=0
	mvars.ene_questBalaclavaId=0
	if n.isQuestBalaclava==true then
		local e={}
		if TppLocation.IsAfghan()then
			mvars.ene_questBalaclavaId=TppDefine.QUEST_FACE_ID_LIST.AFGH_BALACLAVA
		elseif TppLocation.IsMiddleAfrica()then
			mvars.ene_questBalaclavaId=TppDefine.QUEST_FACE_ID_LIST.MAFR_BALACLAVA
		end
		mvars.ene_questGetLoadedFaceTable=TppSoldierFace.GetLoadedFaceTable{}
		if mvars.ene_questGetLoadedFaceTable~=nil then
			local n=#mvars.ene_questGetLoadedFaceTable
			if mvars.ene_questBalaclavaId~=0 and n>0 then
				e={mvars.ene_questBalaclavaId,TppDefine.QUEST_ENEMY_MAX,0}table.insert(a,e)o=true
			end
		end
	end
	if n.isQuestArmor==true then
		local e={}
		if TppLocation.IsAfghan()then
			mvars.ene_questArmorId=TppDefine.QUEST_BODY_ID_LIST.AFGH_ARMOR
		elseif TppLocation.IsMiddleAfrica()then
			if n.soldierSubType=="PF_A"then
				mvars.ene_questArmorId=TppDefine.QUEST_BODY_ID_LIST.MAFR_ARMOR_CFA
			elseif n.soldierSubType=="PF_B"then
				mvars.ene_questArmorId=TppDefine.QUEST_BODY_ID_LIST.MAFR_ARMOR_ZRS
			elseif n.soldierSubType=="PF_C"then
				mvars.ene_questArmorId=TppDefine.QUEST_BODY_ID_LIST.MAFR_ARMOR_RC
			end
		end
		if mvars.ene_questArmorId~=0 then
			e={mvars.ene_questArmorId,TppDefine.QUEST_ENEMY_MAX,0}table.insert(t,e)s=true
		end
	end
	if(n.enemyList and Tpp.IsTypeTable(n.enemyList))and next(n.enemyList)then
		for n,e in pairs(n.enemyList)do
			if e.enemyName then
				if e.bodyId then
					local n=1
					local e={e.bodyId,n,0}table.insert(t,e)s=true
				end
				if e.faceId then
					local n=1
					local e={e.faceId,n,0}table.insert(a,e)o=true
				end
			end
		end
	end
	if(n.hostageList and Tpp.IsTypeTable(n.hostageList))and next(n.hostageList)then
		for n,e in pairs(n.hostageList)do
			if e.hostageName then
				if e.bodyId then
					local n=1
					local e={e.bodyId,0,n}table.insert(t,e)p=true
				end
				if e.faceId then
					local n=1
					local e={e.faceId,0,n}table.insert(a,e)d=true
				end
				if e.isFaceRandom then
					local e=TppQuest.GetRandomFaceId()
					if e then
						local n=1
						local e={e,0,n}table.insert(a,e)d=true
					end
				end
			end
		end
	end
	if p==true then
		local a={}
		local n=false
		for t,e in ipairs(t)do
			if e[3]>=1 then
				local e=e[1]
				if IsTypeNumber(e)then
					table.insert(a,e)n=true
				end
			end
		end
		if n==true then
			TppSoldierFace.SetBodyFovaUserType{hostage=hostageBodyTable}
		end
	end
	local i="SetNone"if((s==true or o==true)or p==true)or d==true then
		local n=s or p
		local e=o or d
		if n==true and e==true then
			TppSoldierFace.SetAndConvertExtendFova{face=a,body=t}i="SetFaceAndBody"elseif e==true then
			TppSoldierFace.SetAndConvertExtendFova{face=a}i="SetFace"elseif n==true then
			TppSoldierFace.SetAndConvertExtendFova{body=t}i="SetBody"end
	end
	local r
	if s==true or o==true then
		if i=="SetFaceAndBody"then
			r={id="InitializeAndAllocateExtendFova",face=a,body=t}
		elseif i=="SetFace"then
			r={id="InitializeAndAllocateExtendFova",face=a}
		elseif i=="SetBody"then
			r={id="InitializeAndAllocateExtendFova",body=t}
		end
		if r then
			GameObject.SendCommand({type="TppSoldier2"},r)
			GameObject.SendCommand({type="TppCorpse"},r)
		end
	end
	if p==true or d==true then
		if i=="SetFaceAndBody"then
			TppSoldierFace.ReserveExtendFovaForHostage{face=a,body=t}
		elseif i=="SetFace"then
			TppSoldierFace.ReserveExtendFovaForHostage{face=a}
		elseif i=="SetBody"then
			TppSoldierFace.ReserveExtendFovaForHostage{body=t}
		end
	end
	local n=n.heliList
	if(n and Tpp.IsTypeTable(n))and next(n)then
		this.LoadQuestHeli(n[1].coloringType)
	end
end
function this.OnActivateQuest(n)
	if n==nil then
		return
	end
	if mvars.ene_isQuestSetup==false then
		mvars.ene_questTargetList={}
		mvars.ene_questVehicleList={}
	end
	local t=false
	if(n.targetList and Tpp.IsTypeTable(n.targetList))and next(n.targetList)then
		this.SetupActivateQuestTarget(n.targetList)t=true
	end
	if(n.vehicleList and Tpp.IsTypeTable(n.vehicleList))and next(n.vehicleList)then
		this.SetupActivateQuestVehicle(n.vehicleList,n.targetList)t=true
	end
	if(n.heliList and Tpp.IsTypeTable(n.heliList))and next(n.heliList)then
		this.SetupActivateQuestHeli(n.heliList)t=true
	end
	if(n.cpList and Tpp.IsTypeTable(n.cpList))and next(n.cpList)then
		this.SetupActivateQuestCp(n.cpList)t=true
	end
	if(n.enemyList and Tpp.IsTypeTable(n.enemyList))and next(n.enemyList)then
		this.SetupActivateQuestEnemy(n.enemyList)
		t=true
	end
	if n.isQuestZombie==true then
		local e={type="TppSoldier2"}
		GameObject.SendCommand(e,{id="RegistSwarmEffect"})t=true
	end
	if(n.hostageList and Tpp.IsTypeTable(n.hostageList))and next(n.hostageList)then
		this.SetupActivateQuestHostage(n.hostageList)t=true
	end
	if t==true then
		mvars.ene_isQuestSetup=true
	end
end
function this.SetupActivateQuestTarget(n)
	if mvars.ene_isQuestSetup==false then
		for n,t in pairs(n)do
			local n=t
			if IsTypeString(n)then
				n=GameObject.GetGameObjectId(n)
			end
			if n==NULL_ID then
			else
				this.SetQuestEnemy(n,true)
				TppMarker.SetQuestMarker(t)
			end
		end
	end
end
function this.SetupActivateQuestVehicle(n,t)
	if mvars.ene_isQuestSetup==false then
		mvars.ene_questVehicleList={}
		this.SpawnVehicles(n)
		for a,n in ipairs(n)do
			if n.locator then
				local e={id="Despawn",locator=n.locator}table.insert(mvars.ene_questVehicleList,e)
			end
			for a,t in ipairs(t)do
				if n.locator==t then
					this.SetQuestEnemy(n.locator,true)
					TppMarker.SetQuestMarker(n.locator)
				else
					this.SetQuestEnemy(n.locator,false)
				end
			end
		end
	end
end
function this.SetupActivateQuestHeli(t)
	if mvars.ene_isQuestSetup==false then
		if not this.IsQuestHeli()then
			return
		end
		local i=false
		for n,t in ipairs(t)do
			if t.routeName then
				local n=GameObject.GetGameObjectId(TppReinforceBlock.REINFORCE_HELI_NAME)
				if n==NULL_ID then
				else
					GameObject.SendCommand(n,{id="RequestRoute",route=t.routeName})
					GameObject.SendCommand(n,{id="DisablePullOut"})i=true
					this.SetQuestEnemy(n,false)
				end
			end
		end
		if i==true then
			this.ActivateQuestHeli(t.coloringType)
		end
	end
end
function this.SetupActivateQuestCp(e)
	if mvars.ene_isQuestSetup==false then
		for n,e in pairs(e)do
			if not e.cpName then
			else
				local n=e.cpName
				if IsTypeString(n)then
					n=GameObject.GetGameObjectId(n)
				end
				if n==NULL_ID then
				else
					if e.isNormalCp==true then
						GameObject.SendCommand(n,{id="SetNormalCp"})
					end
					if e.isOuterBaseCp==true then
						GameObject.SendCommand(n,{id="SetOuterBaseCp"})
					end
					if e.isMarchCp==true then
						GameObject.SendCommand(n,{id="SetMarchCp"})
					end
					if((e.cpPosition_x and e.cpPosition_y)and e.cpPosition_z)and e.cpPosition_r then
						GameObject.SendCommand(n,{id="SetCpPosition",x=e.cpPosition_x,y=e.cpPosition_y,z=e.cpPosition_z,r=e.cpPosition_r})
					end
					if e.gtName then
						if((not e.gtPosition_x or not e.gtPosition_y)or not e.gtPosition_z)or not e.gtPosition_r then
						end
						local a={type="TppCommandPost2"}
						local r=e.gtPosition_x or e.cpPosition_x
						local i=e.gtPosition_y or e.cpPosition_y
						local t=e.gtPosition_z or e.cpPosition_z
						local n=e.gtPosition_r or e.cpPosition_r
						GameObject.SendCommand(a,{id="SetLocatorPosition",name=e.gtName,x=r,y=i,z=t,r=n})
					end
				end
			end
		end
	end
end
function this.SetupActivateQuestEnemy(p)
	local i=1
	local function s(n,r)
		local t=n.enemyName
		if IsTypeString(t)then
			t=GameObject.GetGameObjectId(t)
		end
		if t==NULL_ID then
		else
			if r==false then
				if mvars.ene_isQuestSetup==false then
					if n.soldierType then
						this.SetSoldierType(t,n.soldierType)
					end
					if n.soldierSubType then
						this.SetSoldierSubType(t,n.soldierSubType)
					else
						if TppLocation.IsMiddleAfrica()then
						end
					end
					local a=true
					if n.powerSetting then
						for n,e in ipairs(n.powerSetting)do
							if e=="QUEST_ARMOR"then
								if mvars.ene_questArmorId==0 then
									a=false
								end
							end
						end
					end
					if a==true then
						local n=n.powerSetting or{nil}
						this.ApplyPowerSetting(t,n)
					else
						this.ApplyPowerSetting(t,{nil})
					end
					if n.cpName then
						GameObject.SendCommand(t,{id="SetCommandPost",cp=n.cpName})
					end
					if(n.staffTypeId or n.skill)or n.uniqueTypeId then
						local a=n.staffTypeId or TppDefine.STAFF_TYPE_ID.NORMAL
						local e=n.skill or false
						local n=n.uniqueTypeId or false
						if e==false and n==false then
							TppMotherBaseManagement.RegenerateGameObjectStaffParameter{gameObjectId=t,staffTypeId=a}
						elseif e~=false and IsTypeString(e)then
							TppMotherBaseManagement.RegenerateGameObjectStaffParameter{gameObjectId=t,staffTypeId=a,skill=e}
						elseif n~=false then
							TppMotherBaseManagement.RegenerateGameObjectStaffParameter{gameObjectId=t,staffType="Unique",uniqueTypeId=n}
						end
					else
						if mvars.ene_questTargetList[t]then
							TppMotherBaseManagement.RegenerateGameObjectQuestStaffParameter{gameObjectId=t}
						end
					end
					if n.voiceType then
						if((n.voiceType=="ene_a"or n.voiceType=="ene_b")or n.voiceType=="ene_c")or n.voiceType=="ene_d"then
							GameObject.SendCommand(t,{id="SetVoiceType",voiceType=n.voiceType})
						end
					else
						local n={"ene_a","ene_b","ene_c","ene_d"}
						local e=math.random(4)
						local e=n[e]
						GameObject.SendCommand(t,{id="SetVoiceType",voiceType=e})
					end
				end
				if n.bodyId or n.faceId then
					local e=n.faceId or false
					local n=n.bodyId or false
					if IsTypeNumber(n)and IsTypeNumber(e)then
						GameObject.SendCommand(t,{id="ChangeFova",bodyId=n,faceId=e})
					elseif IsTypeNumber(e)then
						GameObject.SendCommand(t,{id="ChangeFova",faceId=e})
					elseif IsTypeNumber(n)then
						GameObject.SendCommand(t,{id="ChangeFova",bodyId=n})
					end
				end
				if n.isBalaclava==true then
					if mvars.ene_questGetLoadedFaceTable~=nil then
						local e=mvars.ene_questGetLoadedFaceTable
						local e=#mvars.ene_questGetLoadedFaceTable
						if e>0 and mvars.ene_questBalaclavaId~=0 then
							local e=mvars.ene_questGetLoadedFaceTable[i]
							if mvars.ene_questGetLoadedFaceTable[i+1]then
								i=i+1
							else
								i=1
							end
							if n.soldierSubType=="PF_A"or n.soldierSubType=="PF_C"then
								GameObject.SendCommand(t,{id="ChangeFova",isScarf=true})
							else
								GameObject.SendCommand(t,{id="ChangeFova",balaclavaFaceId=mvars.ene_questBalaclavaId,faceId=e})
							end
						end
					end
				end
				if mvars.ene_isQuestSetup==false then
					if n.route_d then
						this.SetSneakRoute(t,n.route_d)
					end
					if n.route_c then
						this.SetCautionRoute(t,n.route_c)
					end
					if n.route_a then
						this.SetAlertRoute(t,n.route_a)
					end
					if n.rideFromVehicleId then
						local e=n.rideFromVehicleId
						if IsTypeString(e)then
							e=GameObject.GetGameObjectId(e)
						end
						GameObject.SendCommand(t,{id="SetRelativeVehicle",targetId=e,rideFromBeginning=true})
					end
					if n.isZombie then
						GameObject.SendCommand(t,{id="SetZombie",enabled=true,isMsf=false,isZombieSkin=true,isHagure=true})
					end
					if n.isMsf then
						GameObject.SendCommand(t,{id="SetZombie",enabled=true,isMsf=true})
					end
					if n.isZombieUseRoute then
						GameObject.SendCommand(t,{id="SetZombieUseRoute",enabled=true})
					end
					if n.isBalaclava==true then
						GameObject.SendCommand(t,{id="SetSoldier2Flag",flag="highRank",on=true})
					end
					GameObject.SendCommand(t,{id="SetEnabled",enabled=true})
					this.SetQuestEnemy(t,false)
				end
			else
				local e=n.isDisable or false
				if e==true then
					GameObject.SendCommand(t,{id="SetEnabled",enabled=false})
				end
			end
		end
	end
	for n,e in pairs(p)do
		if e.enemyName then
			s(e,false)
		elseif e.setCp then
			local n=GetGameObjectId(e.setCp)
			if n==NULL_ID then
			else
				local n=nil
				for t,a in pairs(mvars.ene_cpList)do
					if a==e.setCp then
						n=t
					end
				end
				if n then
					for n,t in pairs(mvars.ene_soldierIDList[n])do
						local e={enemyName=n,isDisable=e.isDisable}s(e,true)
					end
				end
			end
		end
	end
end
function this.SetupActivateQuestHostage(n)
	local r=TppLocation.IsAfghan()
	local i=TppLocation.IsMiddleAfrica()
	for t,n in pairs(n)do
		if n.hostageName then
			local t=n.hostageName
			if IsTypeString(t)then
				t=GameObject.GetGameObjectId(t)
			end
			if t==NULL_ID then
			else
				if mvars.ene_isQuestSetup==false then
					if(n.staffTypeId or n.skill)or n.uniqueTypeId then
						local a=n.staffTypeId or TppDefine.STAFF_TYPE_ID.NORMAL
						local e=n.skill or false
						local n=n.uniqueTypeId or false
						if e==false and n==false then
							TppMotherBaseManagement.RegenerateGameObjectStaffParameter{gameObjectId=t,staffTypeId=a}
						elseif e~=false and IsTypeString(e)then
							TppMotherBaseManagement.RegenerateGameObjectStaffParameter{gameObjectId=t,staffTypeId=a,skill=e}
						elseif n~=false then
							TppMotherBaseManagement.RegenerateGameObjectStaffParameter{gameObjectId=t,staffType="Unique",uniqueTypeId=n}
						end
					else
						if mvars.ene_questTargetList[t]then
							TppMotherBaseManagement.RegenerateGameObjectQuestStaffParameter{gameObjectId=t}
						end
					end
					if n.voiceType then
						if IsTypeTable(n.voiceType)then
							local e=#n.voiceType
							local e=math.random(e)
							local e=n.voiceType[e]
							if((e=="hostage_a"or e=="hostage_b")or e=="hostage_c")or e=="hostage_d"then
								GameObject.SendCommand(t,{id="SetVoiceType",voiceType=e})
							end
						else
							local e=n.voiceType
							if((e=="hostage_a"or e=="hostage_b")or e=="hostage_c")or e=="hostage_d"then
								GameObject.SendCommand(t,{id="SetVoiceType",voiceType=e})
							end
						end
					else
						local n={"hostage_a","hostage_b","hostage_c","hostage_d"}
						local e=math.random(4)
						local e=n[e]
						GameObject.SendCommand(t,{id="SetVoiceType",voiceType=e})
					end
					if n.langType then
						GameObject.SendCommand(t,{id="SetLangType",langType=n.langType})
					else
						if this.IsFemaleHostage(t)==false then
							if r==true then
								GameObject.SendCommand(t,{id="SetLangType",langType="russian"})
							elseif i==true then
								GameObject.SendCommand(t,{id="SetLangType",langType="afrikaans"})
							end
						else
							GameObject.SendCommand(t,{id="SetLangType",langType="english"})
						end
					end
					if n.path then
						GameObject.SendCommand(t,{id="SpecialAction",action="PlayMotion",path=n.path,autoFinish=false,enableMessage=true,commandId=Fox.StrCode32"CommandA",enableGravity=false,enableCollision=false})
					end
					this.SetQuestEnemy(t,false)
				end
				if(n.bodyId or n.faceId)or n.isFaceRandom then
					local e=n.faceId or false
					local a=n.bodyId or false
					if n.isFaceRandom then
						e=TppQuest.GetRandomFaceId()
					end
					if IsTypeNumber(a)and IsTypeNumber(e)then
						GameObject.SendCommand(t,{id="ChangeFova",bodyId=a,faceId=e})
					elseif IsTypeNumber(e)then
						GameObject.SendCommand(t,{id="ChangeFova",faceId=e})
					elseif IsTypeNumber(a)then
						GameObject.SendCommand(t,{id="ChangeFova",bodyId=a})
					end
				end
			end
		end
	end
end
function this.OnDeactivateQuest(n)
	if mvars.ene_isQuestSetup==true then
		if(n.vehicleList and Tpp.IsTypeTable(n.vehicleList))and next(n.vehicleList)then
			this.SetupDeactivateQuestVehicle(n.vehicleList)
		end
		if(n.heliList and Tpp.IsTypeTable(n.heliList))and next(n.heliList)then
			this.SetupDeactivateQuestQuestHeli(n.heliList)
		end
		if(n.cpList and Tpp.IsTypeTable(n.cpList))and next(n.cpList)then
			this.SetupDeactivateQuestCp(n.cpList)
		end
		if n.isQuestZombie==true then
			local e={type="TppSoldier2"}
			GameObject.SendCommand(e,{id="UnregistSwarmEffect"})
		end
		if(n.enemyList and Tpp.IsTypeTable(n.enemyList))and next(n.enemyList)then
			this.SetupDeactivateQuestEnemy(n.enemyList)
		end
		if(n.hostageList and Tpp.IsTypeTable(n.hostageList))and next(n.hostageList)then
			this.SetupDeactivateQuestHostage(n.hostageList)
		end
		if not mvars.qst_isMissionEnd then
			local e=this.CheckQuestAllTarget(n.questType,nil,nil,true)
			TppQuest.ClearWithSave(e)
		end
	end
end
function this.SetupDeactivateQuestVehicle(e)
end
function this.SetupDeactivateQuestQuestHeli(e)
end
function this.SetupDeactivateQuestCp(e)
end
function this.SetupDeactivateQuestEnemy(n)
	for n,t in pairs(n)do
		if t.enemyName then
			local n=t.enemyName
			if IsTypeString(n)then
				n=GameObject.GetGameObjectId(n)
			end
			if n==NULL_ID then
			else
				local a={type="TppCorpse"}
				if this.CheckQuestDistance(n)then
					if TppMission.CheckMissionState(true,false,true,false)then
						this.AutoFultonRecoverNeutralizedTarget(n,true)
					end
				end
				if t.bodyId or t.faceId then
					local e={id="ChangeFova",faceId=EnemyFova.INVALID_FOVA_VALUE,bodyId=EnemyFova.INVALID_FOVA_VALUE}
					GameObject.SendCommand(n,e)
					local e={id="ChangeFovaCorpse",name=t.enemyName,faceId=EnemyFova.INVALID_FOVA_VALUE,bodyId=EnemyFova.INVALID_FOVA_VALUE}
					GameObject.SendCommand(a,e)
				end
				if this.CheckQuestDistance(n)then
					if TppMission.CheckMissionState(true,false,true,false)then
						GameObject.SendCommand(n,{id="RequestVanish"})
						GameObject.SendCommand(a,{id="RequestDisableWithFadeout",name=t.enemyName})
					end
				end
			end
		elseif t.setCp then
		end
	end
end
function this.SetupDeactivateQuestHostage(n)
	for n,t in pairs(n)do
		if t.hostageName then
			local n=t.hostageName
			if IsTypeString(n)then
				n=GameObject.GetGameObjectId(n)
			end
			if n==NULL_ID then
			else
				if this.CheckQuestDistance(n)then
					if TppMission.CheckMissionState(true,false,true,false)then
						local e=TppMotherBaseManagement.GetStaffIdFromGameObject{gameObjectId=n}
						TppTerminal.OnFulton(n,nil,nil,e,nil,true)
					end
				end
				if t.bodyId or t.faceId then
					local e={id="ChangeFova",faceId=EnemyFova.INVALID_FOVA_VALUE,bodyId=EnemyFova.INVALID_FOVA_VALUE}
					GameObject.SendCommand(n,e)
				end
				if this.CheckQuestDistance(n)then
					if TppMission.CheckMissionState(true,false,true,false)then
						GameObject.SendCommand(n,{id="RequestVanish"})
					end
				end
			end
		end
	end
end
function this.OnTerminateQuest(n)
	if mvars.ene_isQuestSetup==true then
		if(n.vehicleList and Tpp.IsTypeTable(n.vehicleList))and next(n.vehicleList)then
			this.SetupTerminateQuestVehicle(n.vehicleList)
		end
		if(n.heliList and Tpp.IsTypeTable(n.heliList))and next(n.heliList)then
			this.SetupTerminateQuestHeli(n.heliList)
		end
		if(n.cpList and Tpp.IsTypeTable(n.cpList))and next(n.cpList)then
			this.SetupTerminateQuestCp(n.cpList)
		end
		if n.isQuestZombie==true then
			local e={type="TppSoldier2"}
			GameObject.SendCommand(e,{id="UnregistSwarmEffect"})
		end
		if(n.enemyList and Tpp.IsTypeTable(n.enemyList))and next(n.enemyList)then
			if GameObject.GetGameObjectIdByIndex("TppSoldier2",0)~=NULL_ID then
				this.SetupTerminateQuestEnemy(n.enemyList)
			end
		end
		if(n.hostageList and Tpp.IsTypeTable(n.hostageList))and next(n.hostageList)then
			this.SetupTerminateQuestHostage(n.hostageList)
		end
	end
	if GameObject.GetGameObjectIdByIndex("TppSoldier2",0)~=NULL_ID then
		local e={type="TppSoldier2"}
		GameObject.SendCommand(e,{id="FreeExtendFova"})
	end
	if GameObject.GetGameObjectIdByIndex("TppCorpse",0)~=NULL_ID then
		local e={type="TppCorpse"}
		GameObject.SendCommand(e,{id="FreeExtendFova"})
	end
	TppSoldierFace.ClearExtendFova()
	TppSoldierFace.ReserveExtendFovaForHostage{}
	mvars.ene_questTargetList={}
	mvars.ene_questVehicleList={}
	mvars.ene_isQuestSetup=false
end
function this.SetupTerminateQuestVehicle(n)
	this.DespawnVehicles(mvars.ene_questVehicleList)
end
function this.SetupTerminateQuestHeli(n)
	this.DeactivateQuestHeli()
	this.UnloadQuestHeli()
end
function this.SetupTerminateQuestCp(e)
end
function this.SetupTerminateQuestEnemy(s)
	local p=TppLocation.IsAfghan()
	local i=TppLocation.IsMiddleAfrica()
	local function t(n,t)
		local e=n.enemyName
		if IsTypeString(e)then
			e=GameObject.GetGameObjectId(e)
		end
		if e==NULL_ID then
		else
			if t==false then
				local t={type="TppCorpse"}
				GameObject.SendCommand(e,{id="SetEnabled",enabled=false})
				GameObject.SendCommand(e,{id="SetCommandPost",cp="quest_cp"})
				GameObject.SendCommand(e,{id="SetZombie",enabled=false,isMsf=false,isZombieSkin=true,isHagure=false})
				GameObject.SendCommand(e,{id="SetZombieUseRoute",enabled=false})
				GameObject.SendCommand(e,{id="SetEverDown",enabled=false})
				GameObject.SendCommand(e,{id="SetSoldier2Flag",flag="highRank",on=false})
				GameObject.SendCommand(e,{id="Refresh"})
				GameObject.SendCommand(t,{id="RequestVanish",name=n.enemyName})
				if n.powerSetting then
					for i,a in ipairs(n.powerSetting)do
						if a=="QUEST_ARMOR"then
							local a={id="ChangeFova",faceId=EnemyFova.INVALID_FOVA_VALUE,bodyId=EnemyFova.INVALID_FOVA_VALUE}
							GameObject.SendCommand(e,a)
							local e={id="ChangeFovaCorpse",name=n.enemyName,faceId=EnemyFova.INVALID_FOVA_VALUE,bodyId=EnemyFova.INVALID_FOVA_VALUE}
							GameObject.SendCommand(t,e)
						end
					end
				end
				if p==true then
					GameObject.SendCommand(e,{id="SetSoldier2Type",type=EnemyType.TYPE_SOVIET})
				elseif i==true then
					GameObject.SendCommand(e,{id="SetSoldier2Type",type=EnemyType.TYPE_PF})
				end
			else
				local n=n.isDisable or false
				if n==true then
					GameObject.SendCommand(e,{id="SetEnabled",enabled=true})
				end
			end
		end
	end
	for n,e in pairs(s)do
		if e.enemyName then
			t(e,false)
			TppUiCommand.UnRegisterIconUniqueInformation(GameObject.GetGameObjectId(e.enemyName))
		elseif e.setCp then
			local n=GetGameObjectId(e.setCp)
			if n==NULL_ID then
			else
				local n=nil
				for a,t in pairs(mvars.ene_cpList)do
					if t==e.setCp then
						n=a
					end
				end
				if n then
					for n,a in pairs(mvars.ene_soldierIDList[n])do
						local e={enemyName=n,isZombie=e.isZombie,isMsf=e.isMsf,isDisable=e.isDisable}t(e,true)
					end
				end
			end
		end
	end
end
function this.SetupTerminateQuestHostage(e)
end
function this.CheckQuestDistance(e)
	if Tpp.IsSoldier(e)or Tpp.IsHostage(e)then
		local t=Vector3(vars.playerPosX,vars.playerPosY,vars.playerPosZ)
		local n=10
		local n=n*n
		if d(n,t,e)then
			return true
		end
	end
	return false
end
function this.CheckQuestNpcLifeStatus(e)
	if e~=nil then
		local e=GameObject.SendCommand(e,{id="GetLifeStatus"})
		if e==TppGameObject.NPC_LIFE_STATE_DEAD then
			return false
		else
			return true
		end
	end
end
function this.IsQuestInHelicopter()
	TppHelicopter.SetNewestPassengerTable()
	for e,n in pairs(mvars.ene_questTargetList)do
		if TppHelicopter.IsInHelicopter(e)then
			return true
		end
	end
	return false
end
function this.IsQuestInHelicopterGameObjectId(n)
	TppHelicopter.SetNewestPassengerTable()
	for e,t in pairs(mvars.ene_questTargetList)do
		if TppHelicopter.IsInHelicopter(e)then
			if e==n then
				return true
			end
		end
	end
	return false
end
function this.IsQuestTarget(e)
	if mvars.ene_isQuestSetup==false then
		return false
	end
	if not next(mvars.ene_questTargetList)then
		return false
	end
	for n,t in pairs(mvars.ene_questTargetList)do
		if t.isTarget==true then
			if e==n then
				return true
			end
		end
	end
	return false
end
function this.IsQuestNpc(e)
	for n,t in pairs(mvars.ene_questTargetList)do
		if e==n then
			return true
		end
	end
	return false
end
function this.GetQuestCount()
	local n=0
	local e=0
	for a,t in pairs(mvars.ene_questTargetList)do
		if t.isTarget==true then
			n=n+1
			if t.messageId~="None"then
				e=e+1
			end
		end
	end
	return e,n
end
function this.SetQuestEnemy(e,n)
	if IsTypeString(e)then
		e=GameObject.GetGameObjectId(e)
	end
	if e==NULL_ID then
	end
	if not mvars.ene_questTargetList[e]then
		local n={messageId="None",isTarget=n}
		mvars.ene_questTargetList[e]=n
	end
end
function this.CheckDeactiveQuestAreaForceFulton()
	if mvars.ene_isQuestSetup==false then
		return
	end
	if not next(mvars.ene_questTargetList)then
		return
	end
	for n,t in pairs(mvars.ene_questTargetList)do
		if Tpp.IsSoldier(n)or Tpp.IsHostage(n)then
			if this.CheckQuestDistance(n)then
				if this.CheckQuestNpcLifeStatus(n)then
					GameObject.SendCommand(n,{id="RequestForceFulton"})
					TppRadio.Play"f1000_rtrg5140"TppSoundDaemon.PostEvent"sfx_s_rescue_pow"else
					GameObject.SendCommand(n,{id="RequestDisableWithFadeout"})
				end
			end
		end
	end
end
function this.CheckQuestAllTarget(p,S,T,a,t)
	local n=TppDefine.QUEST_CLEAR_TYPE.NONE
	local l=a or false
	local c=t or false
	local u=false
	local r=0
	local a=0
	local o=0
	local s=0
	local d=0
	local i=0
	local t=true
	local _=false
	local f=TppQuest.GetCurrentQuestName()
	if TppQuest.IsEnd(f)then
		return n
	end
	if mvars.ene_questTargetList[T]then
		local e=mvars.ene_questTargetList[T]
		if e.messageId~="None"and e.isTarget==true then
			_=true
		elseif e.isTarget==false then
			_=true
		end
		e.messageId=S or"None"u=true
	end
	if(l==false and c==false)and u==false then
		return n
	end
	for n,p in pairs(mvars.ene_questTargetList)do
		local _=false
		local T=p.isTarget or false
		if l==true then
			if Tpp.IsSoldier(n)or Tpp.IsHostage(n)then
				if this.CheckQuestDistance(n)then
					p.messageId="Fulton"a=a+1
					_=false
					t=true
				end
			end
		end
		if T==true then
			if _==false then
				local e=p.messageId
				if e~="None"then
					if e=="Fulton"then
						a=a+1
						t=true
					elseif e=="InHelicopter"then
						i=i+1
						t=true
					elseif e=="FultonFailed"then
						o=o+1
						t=true
					elseif(e=="Dead"or e=="VehicleBroken")or e=="LostControl"then
						s=s+1
						t=true
					elseif e=="Vanished"then
						d=d+1
						t=true
					end
				end
				if l==true then
					t=false
				end
			end
			r=r+1
		end
	end
	if _==true then
		t=false
	end
	if r>0 then
		if p==TppDefine.QUEST_TYPE.RECOVERED then
			if a+i>=r then
				n=TppDefine.QUEST_CLEAR_TYPE.CLEAR
			elseif o>0 or s>0 then
				n=TppDefine.QUEST_CLEAR_TYPE.FAILURE
			elseif a+i>0 then
				if t==true then
					n=TppDefine.QUEST_CLEAR_TYPE.UPDATE
				end
			end
		elseif p==TppDefine.QUEST_TYPE.ELIMINATE then
			if((a+o)+s)+i>=r then
				n=TppDefine.QUEST_CLEAR_TYPE.CLEAR
			elseif((a+o)+s)+i>0 then
				if t==true then
					n=TppDefine.QUEST_CLEAR_TYPE.UPDATE
				end
			end
		elseif p==TppDefine.QUEST_TYPE.MSF_RECOVERED then
			if a>=r or i>=r then
				n=TppDefine.QUEST_CLEAR_TYPE.CLEAR
			elseif(o>0 or s>0)or d>0 then
				n=TppDefine.QUEST_CLEAR_TYPE.FAILURE
			end
		end
	end
	if c==true then
		if n==TppDefine.QUEST_CLEAR_TYPE.NONE or n==TppDefine.QUEST_CLEAR_TYPE.UPDATE then
			n=TppDefine.QUEST_CLEAR_TYPE.NONE
		end
	end
	return n
end
function this.ReserveQuestHeli()
	local e=GetGameObjectId("TppCommandPost2",quest_cp)
	TppRevenge.SetEnabledSuperReinforce(false)
	mvars.ene_isQuestHeli=true
end
function this.UnreserveQuestHeli()
	local e=GetGameObjectId("TppCommandPost2",quest_cp)
	TppReinforceBlock.FinishReinforce(e)
	TppReinforceBlock.UnloadReinforceBlock(e)
	TppRevenge.SetEnabledSuperReinforce(true)
	mvars.ene_isQuestHeli=false
end
function this.LoadQuestHeli(n)
	local e=GetGameObjectId("TppCommandPost2",quest_cp)
	TppReinforceBlock.LoadReinforceBlock(TppReinforceBlock.REINFORCE_TYPE.HELI,e,n)
end
function this.UnloadQuestHeli()
	local e=GetGameObjectId("TppCommandPost2",quest_cp)
	TppReinforceBlock.UnloadReinforceBlock(e)
end
function this.ActivateQuestHeli(n)
	local e=GetGameObjectId("TppCommandPost2",quest_cp)
	if not TppReinforceBlock.IsLoaded()then
		TppReinforceBlock.LoadReinforceBlock(TppReinforceBlock.REINFORCE_TYPE.HELI,e,n)
	end
	TppReinforceBlock.StartReinforce(e)
end
function this.DeactivateQuestHeli()
	local e=GetGameObjectId("TppCommandPost2",quest_cp)
	TppReinforceBlock.FinishReinforce(e)
end
function this.IsQuestHeli()
	return mvars.ene_isQuestHeli
end
function this.GetDDSuit()
	local n=TppDefine.FOB_EVENT_ID_LIST.ARMOR
	local t=TppServerManager.GetEventId()
	for a,n in ipairs(n)do
		if t==n then
			return this.FOB_PF_SUIT_ARMOR
		end
	end
	local n=this.weaponIdTable.DD.NORMAL.SNEAKING_SUIT
	if n and n>0 then
		return this.FOB_DD_SUIT_SNEAKING
	end
	local n=this.weaponIdTable.DD.NORMAL.BATTLE_DRESS
	if n and n>0 then
		return this.FOB_DD_SUIT_BTRDRS
	end
	return this.FOB_DD_SUIT_ATTCKER
end
function this.IsHostageEventFOB()
	local n=TppDefine.FOB_EVENT_ID_LIST.HOSTAGE
	local e=TppServerManager.GetEventId()
	for t,n in ipairs(n)do
		if e==n then
			return true
		end
	end
	return false
end
function this.IsZombieEventFOB()
	local e=TppDefine.FOB_EVENT_ID_LIST.ZOMBIE
	local n=TppServerManager.GetEventId()
	for t,e in ipairs(e)do
		if n==e then
			return true
		end
	end
	return false
end
function this.IsParasiteMetalEventFOB()
	local e=TppDefine.FOB_EVENT_ID_LIST.PARASITE_METAL
	local n=TppServerManager.GetEventId()
	for t,e in ipairs(e)do
		if n==e then
			return true
		end
	end
	return false
end
function this.IsSpecialEventFOB()
	return this.IsParasiteMetalEventFOB()
end
function this._OnDead(n,i)
	local a
	if i then
		a=Tpp.IsPlayer(i)
	end
	local i=this.IsEliminateTarget(n)
	local r=this.IsRescueTarget(n)
	if a then
		if Tpp.IsHostage(n)then
			if this.IsChildHostage(n)then
				if TppMission.GetMissionID()~=10100 then
					TppMission.ReserveGameOverOnPlayerKillChild(n)
				end
			else
				if not i and not r then
					TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.HOSTAGE_DEAD)
				end
			end
		end
	end
	if Tpp.IsSoldier(n)then
		local e=this.GetSoldierType(n)
		if(e==EnemyType.TYPE_CHILD)then
			TppMission.ReserveGameOverOnPlayerKillChild(n)
		end
	end
	if Tpp.IsHostage(n)and TppMission.GetMissionID()~=10100 then
		local e=SendCommand(n,{id="IsChild"})
		if e then
			TppMission.ReserveGameOverOnPlayerKillChild(n)
		end
	end
	this.PlayTargetEliminatedRadio(n)
end
function this._OnRecoverNPC(n,t)
	this._PlayRecoverNPCRadio(n)
end
function this._PlayRecoverNPCRadio(n)
	local t=this.IsEliminateTarget(n)
	local a=this.IsRescueTarget(n)
	if Tpp.IsSoldier(n)and not t then
		TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.ENEMY_RECOVERED)
	elseif Tpp.IsHostage(n)and not a then
		TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.HOSTAGE_RECOVERED)
	else
		this.PlayTargetRescuedRadio(n)
	end
end
function this._OnFulton(n,a,a,t)
	this._OnRecoverNPC(n,t)
end
function this._OnDamage(a,n,t)
	if this.IsRescueTarget(a)then
		this._OnDamageOfRescueTarget(n,t)
	end
end
function this._OnDamageOfRescueTarget(e,n)
	if TppDamage.IsActiveByAttackId(e)then
		if Tpp.IsPlayer(n)then
			TppRadio.PlayCommonRadio(TppDefine.COMMON_RADIO.HOSTAGE_DAMAGED_FROM_PC)
		end
	end
end
function this._PlacedIntoVehicle(t,n,a)
	if Tpp.IsHelicopter(n)then
		this.PlayTargetRescuedRadio(t)
	end
end
function this._RideHelicopterWithHuman(t,n,t)
	this.PlayTargetRescuedRadio(n)
end
function this._AnnouncePhaseChange(n,t)
	local n=this.GetCpSubType(n)
	local e="cmmn_ene_soviet"if n=="SOVIET_A"or n=="SOVIET_B"then
		e="cmmn_ene_soviet"elseif n=="PF_A"then
		e="cmmn_ene_cfa"elseif n=="PF_B"then
		e="cmmn_ene_zrs"elseif n=="PF_C"then
		e="cmmn_ene_coyote"elseif n=="DD_A"then
		return
	elseif n=="DD_PW"then
		e="cmmn_ene_pf"elseif n=="DD_FOB"then
		e="cmmn_ene_pf"elseif n=="SKULL_AFGH"then
		e="cmmn_ene_xof"elseif n=="SKULL_CYPR"then
		return
	elseif n=="CHILD_A"then
		return
	end
	if t==TppGameObject.PHASE_ALERT then
		TppUiCommand.AnnounceLogViewLangId("announce_phase_to_alert",e)
	elseif t==TppGameObject.PHASE_EVASION then
		TppUiCommand.AnnounceLogViewLangId("announce_phase_to_evasion",e)
	elseif t==TppGameObject.PHASE_CAUTION then
		TppUiCommand.AnnounceLogViewLangId("announce_phase_to_caution",e)
	elseif t==TppGameObject.PHASE_SNEAK then
		TppUiCommand.AnnounceLogViewLangId("announce_phase_to_sneak",e)
	end
end
function this._IsGameObjectIDValid(e)
	local e=GetGameObjectId(e)
	if(e==NULL_ID)then
		return false
	else
		return true
	end
end
function this._IsRouteSetTypeValid(n)
	if(n==nil or type(n)~="string")then
		return false
	end
	for t,t in paris(this.ROUTE_SET_TYPES)do
		if(n==this.ROUTE_SET_TYPES[i])then
			return true
		end
	end
	return false
end
function this._ShiftChangeByTime(n)
	for e,a in pairs(mvars.ene_cpList)do
		SendCommand(e,{id="ShiftChange",schedule=mvars.ene_shiftChangeTable[e][n]})
	end
end
function this._IsEliminated(t,n)
	if(t==this.LIFE_STATUS.DEAD)or(n==TppGameObject.NPC_STATE_DISABLE)then
		return true
	else
		return false
	end
end
function this._IsNeutralized(n,t)
	if(n>this.LIFE_STATUS.NORMAL)or(t>TppGameObject.NPC_STATE_NORMAL)then
		return true
	else
		return false
	end
end
function this._RestoreOnContinueFromCheckPoint_Hostage()
end
function this._RestoreOnContinueFromCheckPoint_Hostage2()
	if TppHostage2.SetSVarsKeyNames2 then
		local e={"TppHostage2","TppHostageUnique","TppHostageUnique2","TppHostageKaz","TppOcelot2","TppHuey2","TppCodeTalker2","TppSkullFace2","TppMantis2"}
		for n,e in ipairs(e)do
			if GameObject.GetGameObjectIdByIndex(e,0)~=NULL_ID then
				SendCommand({type=e},{id="RestoreFromSVars"})
			end
		end
	end
end
function this._RestoreOnMissionStart_Hostage()
end
function this._RestoreOnMissionStart_Hostage2()
	if TppHostage2.SetSVarsKeyNames2 then
		local n=EnemyFova.INVALID_FOVA_VALUE
		local t=EnemyFova.INVALID_FOVA_VALUE
		for e=0,TppDefine.DEFAULT_HOSTAGE_STATE_COUNT-1 do
			svars.hosName[e]=0
			svars.hosState[e]=0
			svars.hosFlagAndStance[e]=0
			svars.hosWeapon[e]=0
			svars.hosLocation[e*4+0]=0
			svars.hosLocation[e*4+1]=0
			svars.hosLocation[e*4+2]=0
			svars.hosLocation[e*4+3]=0
			svars.hosMarker[e]=0
			svars.hosFovaSeed[e]=0
			svars.hosFaceFova[e]=n
			svars.hosBodyFova[e]=t
			svars.hosScriptSneakRoute[e]=GsRoute.ROUTE_ID_EMPTY
			svars.hosRouteNodeIndex[e]=0
			svars.hosRouteEventIndex[e]=0
			svars.hosOptParam1[e]=0
			svars.hosOptParam2[e]=0
			svars.hosRandomSeed[e]=0
		end
	end
end
function this._StoreSVars_Hostage(i)
	local n={"TppHostage2","TppHostageUnique","TppHostageUnique2","TppHostageKaz","TppOcelot2","TppHuey2","TppCodeTalker2","TppSkullFace2","TppMantis2"}
	if TppHostage2.SetSVarsKeyNames2 then
		for n,e in ipairs(n)do
			if GameObject.GetGameObjectIdByIndex(e,0)~=NULL_ID then
				SendCommand({type=e},{id="ReadyToStoreToSVars"})
			end
		end
	end
	for n,e in ipairs(n)do
		if GameObject.GetGameObjectIdByIndex(e,0)~=NULL_ID then
			SendCommand({type=e},{id="StoreToSVars",markerOnly=i})
		end
	end
end
function this._DoRoutePointMessage(t,a,i,o)
	local n=mvars.ene_routePointMessage
	if not n then
		return
	end
	local r=TppSequence.GetCurrentSequenceName()
	local r=n.sequence[r]
	local s=""if r then
		this.ExecuteRoutePointMessage(r,t,a,i,o,s)
	end
	this.ExecuteRoutePointMessage(n.main,t,a,i,o,s)
end
function this.ExecuteRoutePointMessage(n,i,a,t,e,r)
	local n=n[e]
	if not n then
		return
	end
	Tpp.DoMessageAct(n,TppMission.CheckMessageOption,t,a,i,e,r)
end
return this
