--TUPPM Header

--not present in v1.10

local this={}
local GetGameObjectId=GameObject.GetGameObjectId
local GetTypeIndex=GameObject.GetTypeIndex
local SendCommand=GameObject.SendCommand
local NULL_ID=GameObject.NULL_ID

function this._Random(n,E)
	local t=gvars.rev_revengeRandomValue
	if n>E then
		local e=n
		n=E
		E=e
	end
	local E=(E-n)+1
	return(t%E)+n
end

this.NO_REVENGE_MISSION_LIST={
	[10010]=true, --Prologue - Awakening
	[10030]=true, --Mission 2 - Flashback Diamond Dogs
	[10050]=true, --Mission 11 - Cloaked in Silence
	[11050]=true, --Mission 40 - [Extreme] Cloaked in Silence
	[10120]=true, --Mission 23 - The White Mamba
	[10140]=true, --Mission 29 - Metallic Archaea
	[11140]=true, --Mission 42 - [Extreme] Metallic Archaea
	[10151]=true, --Mission 31 - Sahelanthropus
	[10230]=true, --?
	[10240]=true, --Mission 43 - Shining Lights, Even in Death
	[10280]=true, --Mission 46 - Truth - The Man Who Sold the World
	--TODO Check travelling out of MB via Heli maybe shifts revenge
	[30050]=true, --rX42 Set to false to shift revenge
	[40010]=true, --Afghanistan
	[40020]=true, --Middle Africa
	[40050]=true, --Mother Base
	[50050]=true --FOB
}

this.NO_STEALTH_COMBAT_REVENGE_MISSION_LIST={
	[30010]=true, --rX42 Set to false to shift revenge
	[30020]=true, --rX42 Set to false to shift revenge
	[30050]=true, --rX42 Set to false to shift revenge
	[30150]=true --rX42 Set to false to shift revenge
}

--r28 Leave the vehicles home
this.USE_SUPER_REINFORCE_VEHICLE_MISSION={
	[10036]=true, --Mission 3 - A Heroes Way
	[11036]=true, --??
	[10093]=true --Mission 35 - Cursed Legacy
}

this.CANNOT_USE_ALL_WEAPON_MISSION={
	[10030]=true,
	[10070]=true,
	[10080]=true,
	[11080]=true,
	[10090]=true,
	[11090]=true,
	[10151]=true,
	[11151]=true,
	[10211]=true,
	[11211]=true,
	[30050]=true
}

--r51 Settings
if TUPPMSettings.rev_ENABLE_allWeaponsInRestrictedMissions then
	--r13 enabling all weapons in these missions
	this.CANNOT_USE_ALL_WEAPON_MISSION={
		[10030]=true, --Mission 2 - Flashback Diamond Dogs
		[10070]=false, --Mission 12 - Hellbound --No Shields nor Missiles
		[10080]=false, --Mission 13 - Pitch Dark
		[11080]=false, --Mission 44 - [Total Stealth] Pitch Dark
		[10090]=false, --Mission 16 - Traitors Caravan --No Shields
		[11090]=false, --Mission 37 - [Extreme] Traitors Caravan --No Shields
		[10151]=true, --Mission 31 - Sahelanthropus
		[11151]=true, --Mission 50 - [Extreme] Sahelanthropus
		[10211]=false, --Mission 26 - Hunting Down --No Shields
		[11211]=true, --??
		[30050]=false --r13 --Mother Base
	}
end

this.REVENGE_TYPE_NAME={
	--r43 INFO
	"STEALTH", --0 --Points max: 599 --Revenge blocking missions 3
	"NIGHT_S", --1 --Points max: 399 --Revenge blocking missions 1
	"COMBAT", --2 --Points max: 599 --Revenge blocking missions 5
	"NIGHT_C", --3 --Points max: 199 --Revenge blocking missions 1
	"LONG_RANGE", --4 --Points max: 299 --Revenge blocking missions 1
	"VEHICLE", --5 --Points max: 399 --Revenge blocking missions 1
	"HEAD_SHOT", --6 --Points max: 799 --Revenge blocking missions 1
	"TRANQ", --7 --Points max: ? --Revenge blocking missions 0
	"FULTON", --8 --Points max: ? --Revenge blocking missions 0
	"SMOKE", --9 --Points max: 399 --Revenge blocking missions 1
	"M_STEALTH", --10 --Points max: ? --Revenge blocking missions 0
	"M_COMBAT", --11 --Points max: ? --Revenge blocking missions 0
	"DUMMY", --12 Extra dummy values provided to match up with this.REVENGE_LV_MAX? - uuuhhhh maybe not
	"DUMMY2", --13
	"DUMMY3", --14
	"DUMMY4", --15

	--  --rX43 --REVAMPED REVENGE SYSTEM-- New revenge types separated from STEALTH and COMBAT
	--  "CAMERA", --16
	--  "DECOY", --17
	--  "MINE", --18
	--  "SHOTGUN", --19
	--  "MG", --20
	--  "SOFT_ARMOR", --21
	--  "SHIELD", --22
	--  "ARMOR", --23

	"MAX" --24 DEFAULT: 16
}

this.REVENGE_TYPE=TppDefine.Enum(this.REVENGE_TYPE_NAME)
this.REVENGE_LV_LIMIT_RANK_MAX=6

--K changed all revenge levels to max, but in my experience this does nothing
--r41 Fixed max revenge levels - reset to vanilla game
this.REVENGE_LV_MAX={
	--These have to be in EXACT same order as this.REVENGE_TYPE_NAME - uuhhhh maybe not, lua indexes start from 1 not 0 u idiot, check this.MaxOutRevengePoints()
	[this.REVENGE_TYPE.STEALTH]={0,1,2,3,4,5},
	[this.REVENGE_TYPE.NIGHT_S]={0,1,1,2,3,3},
	[this.REVENGE_TYPE.COMBAT]={0,1,2,3,4,5},
	[this.REVENGE_TYPE.NIGHT_C]={0,1,1,1,1,1},
	[this.REVENGE_TYPE.LONG_RANGE]={0,1,1,2,2,2},
	[this.REVENGE_TYPE.VEHICLE]={0,1,1,2,3,3},
	[this.REVENGE_TYPE.HEAD_SHOT]={0,1,2,3,5,7},
	[this.REVENGE_TYPE.TRANQ]={0,1,1,1,1,1},
	[this.REVENGE_TYPE.FULTON]={0,1,2,2,3,3},
	[this.REVENGE_TYPE.SMOKE]={0,1,1,2,3,3},
	[this.REVENGE_TYPE.M_STEALTH]={9,9,9,9,9,9},
	[this.REVENGE_TYPE.M_COMBAT]={9,9,9,9,9,9},

--  --rX43 --REVAMPED REVENGE SYSTEM-- - The revenge system is divided into 6 tiers
--  --Each tier is unlocked at a particular point in the story line - check GetRevengeLvLimitRank()
--  --This tables correspond to the same thing
--
--  --GetRevengeLvMax() will determine max allowed revenge level for a revenge type
--  -- till that point in the story, using GetRevengeLvLimitRank()
--  --The table entries decide the highest rank for a revenge that is possible upto a particular
--  -- point in the storyline. Tier is always 6 after OKB Zero(M31) - meaning the index 6 is picked as highest level possible for
--  -- each revenge type once M31 is complete
--
--  --These tables also decide the highest level to select for a revenge
--  -- Camera lvl 2 corresponds to CAMERA_2 in revengeDefine table
--
--  --Lvl 0 need not require a specific table entry in revengeDefine
--
--  --These ranks are set according to parent Stealth/Combat
--  [this.REVENGE_TYPE.CAMERA]={0,1,1,1,2,2}, --max points 299
--  [this.REVENGE_TYPE.DECOY]={0,0,1,1,2,2}, --max points 299
--  [this.REVENGE_TYPE.MINE]={0,0,0,1,1,1}, --max points 199
--  [this.REVENGE_TYPE.SHOTGUN]={0,1,1,1,2,2}, --Needs selection handling so does not show up with MG - vanilla game behavior
--  [this.REVENGE_TYPE.MG]={0,1,1,1,2,2}, --Needs selection handling so does not show up with SHOTGUN - vanilla game behavior
--  [this.REVENGE_TYPE.SOFT_ARMOR]={0,1,2,3,4,4},
--  [this.REVENGE_TYPE.SHIELD]={0,0,1,1,2,3},
--  [this.REVENGE_TYPE.ARMOR]={0,0,0,1,2,3},
}

this.REVENGE_POINT_OVER_MARGINE=100-1
this.REVENGE_POINT_PER_LV=100
this.REDUCE_REVENGE_POINT=10 --r41 reset to vanilla game -K remove revenge reduction

--K remove revenge reduction
--r41 reset to vanilla game
this.REDUCE_TENDENCY_POINT_TABLE={
	--This table is used only when using the Chicken Cap
	[this.REVENGE_TYPE.STEALTH]={-20,-20,-20,-20,-25,-50},
	[this.REVENGE_TYPE.COMBAT]={-20,-20,-20,-20,-25,-50},

--  --rX43 --REVAMPED REVENGE SYSTEM-- - reduce when Chicken Cap used similar to above
--  [this.REVENGE_TYPE.CAMERA]={-20,-20,-20,-20,-25,-50},
--  [this.REVENGE_TYPE.DECOY]={-20,-20,-20,-20,-25,-50},
--  [this.REVENGE_TYPE.MINE]={-20,-20,-20,-20,-25,-50},
--  [this.REVENGE_TYPE.SHOTGUN]={-20,-20,-20,-20,-25,-50},
--  [this.REVENGE_TYPE.MG]={-20,-20,-20,-20,-25,-50},
--  [this.REVENGE_TYPE.SOFT_ARMOR]={-20,-20,-20,-20,-25,-50},
--  [this.REVENGE_TYPE.SHIELD]={-20,-20,-20,-20,-25,-50},
--  [this.REVENGE_TYPE.ARMOR]={-20,-20,-20,-20,-25,-50},

}

--K remove revenge reduction
--r41 reset to vanilla game
this.REDUCE_POINT_TABLE={
	[this.REVENGE_TYPE.NIGHT_S]={-10,-50,-50,-50,-50,-50,-50,-50,-50,-50,-50},
	[this.REVENGE_TYPE.NIGHT_C]={-10,-50,-50,-50,-50,-50,-50,-50,-50,-50,-50},
	[this.REVENGE_TYPE.SMOKE]={-10,-50,-50,-50,-50,-50,-50,-50,-50,-50,-50},
	[this.REVENGE_TYPE.LONG_RANGE]={-10,-50,-50,-50,-50,-50,-50,-50,-50,-50,-50},
	[this.REVENGE_TYPE.VEHICLE]={-10,-50,-50,-50,-50,-50,-50,-50,-50,-50,-50}
}

this.REVENGE_TRIGGER_TYPE={
	HEAD_SHOT=1,
	ELIMINATED_IN_STEALTH=2,
	ELIMINATED_IN_COMBAT=3,
	FULTON=4,
	SMOKE=5,
	KILLED_BY_HELI=6,
	ANNIHILATED_IN_STEALTH=7,
	ANNIHILATED_IN_COMBAT=8,
	WAKE_A_COMRADE=9,
	DISCOVERY_AT_NIGHT=10,
	ELIMINATED_AT_NIGHT=11,
	SNIPED=12,
	KILLED_BY_VEHICLE=13,
	WATCH_SMOKE=14
}

this.BLOCKED_TYPE={
	GAS_MASK=0,
	HELMET=1,
	CAMERA=2,
	DECOY=3,
	MINE=4,
	NVG=5,
	SHOTGUN=6,
	MG=7,
	SOFT_ARMOR=8,
	SHIELD=9,
	ARMOR=10,
	GUN_LIGHT=11,
	SNIPER=12,
	MISSILE=13,
	MAX=14
}
--r24 How many missions it takes for Revenge blocking Dispatch Missions to show up;
-- setting to 0 removes effects of revenge blocking dispatch missions
this.BLOCKED_FOR_MISSION_COUNT=3

----rX43 --REVAMPED REVENGE SYSTEM--
----This is for reducing revenge points which are not reduced by combat deployment revenge blocking
---- dispatch missions in vanilla game which is absurd IMO
--this.BLOCK_MISSION_TO_REDUCE_REVENGE_TABLE={
--  --The idea is very simple, each blocked type should lower its corresponding vanilla revenge somewhat
--  -- This way the enemy preparedness goes down to level 0 if all missions are executed for a particular parent revenge(stealth/combat) type
--  --DEBUG Use positive values to increase revenge types and test
--
--  --reducePoints=-(MaxPointsForRevenge/MaxLevelForThatRevenge)
--  --reduceStealth or reduceCombat = MaxPointsForRevenge/TotalPossibleDispatchMissions
--  --TotalPossibleDispatchMissions = sum of max level of each new revenge type introduced
--  --USE -100 as lowest limit to keep things balanced
--
--  --Total possible dispatch missions for stealth = 2 Camera + 2 Decoy + 1 Mine = 5
--  --Total possible dispatch missions for combat = 2 Shotgun + 2 Mg + 4 Soft Armor + 3 Shield + 3 Armor = 14
--
--  [this.BLOCKED_TYPE.GAS_MASK]=   {type=this.REVENGE_TYPE.SMOKE,        reducePoints=-100,                        name="GAS_MASK REVENGE_TYPE.SMOKE"},      --DEPLOY_MISSION_ID_REVENGE_SMOKE
--  [this.BLOCKED_TYPE.HELMET]=     {type=this.REVENGE_TYPE.HEAD_SHOT,    reducePoints=-100,                        name="HELMET REVENGE_TYPE.HEAD_SHOT"},    --DEPLOY_MISSION_ID_REVENGE_HEAD_SHOT
--  [this.BLOCKED_TYPE.CAMERA]=     {type=this.REVENGE_TYPE.CAMERA,       reducePoints=-100,  reduceStealth=-100,   name="CAMERA REVENGE_TYPE.CAMERA"},      --DEPLOY_MISSION_ID_REVENGE_STEALTH1
--  [this.BLOCKED_TYPE.DECOY]=      {type=this.REVENGE_TYPE.DECOY,        reducePoints=-100,  reduceStealth=-100,   name="DECOY REVENGE_TYPE.DECOY"},       --DEPLOY_MISSION_ID_REVENGE_STEALTH2
--  [this.BLOCKED_TYPE.MINE]=       {type=this.REVENGE_TYPE.MINE,         reducePoints=-100,  reduceStealth=-100,   name="MINE REVENGE_TYPE.MINE"},        --DEPLOY_MISSION_ID_REVENGE_STEALTH3
--  [this.BLOCKED_TYPE.NVG]=        {type=this.REVENGE_TYPE.NIGHT_S,      reducePoints=-100,                        name="NVG REVENGE_TYPE.NIGHT_S"},         --DEPLOY_MISSION_ID_REVENGE_NIGHT_STEALTH
--  [this.BLOCKED_TYPE.SHOTGUN]=    {type=this.REVENGE_TYPE.SHOTGUN,      reducePoints=-100,  reduceCombat=-43,     name="SHOTGUN REVENGE_TYPE.COMBAT"},      --DEPLOY_MISSION_ID_REVENGE_COMBAT1
--  [this.BLOCKED_TYPE.MG]=         {type=this.REVENGE_TYPE.MG,           reducePoints=-100,  reduceCombat=-43,     name="MG REVENGE_TYPE.COMBAT"},           --DEPLOY_MISSION_ID_REVENGE_COMBAT2
--  [this.BLOCKED_TYPE.SOFT_ARMOR]= {type=this.REVENGE_TYPE.SOFT_ARMOR,   reducePoints=-100,  reduceCombat=-43,     name="SOFT_ARMOR REVENGE_TYPE.COMBAT"},   --DEPLOY_MISSION_ID_REVENGE_COMBAT3
--  [this.BLOCKED_TYPE.SHIELD]=     {type=this.REVENGE_TYPE.SHIELD,       reducePoints=-100,  reduceCombat=-43,     name="SHIELD REVENGE_TYPE.COMBAT"},       --DEPLOY_MISSION_ID_REVENGE_COMBAT4
--  [this.BLOCKED_TYPE.ARMOR]=      {type=this.REVENGE_TYPE.ARMOR,        reducePoints=-100,  reduceCombat=-43,     name="ARMOR REVENGE_TYPE.COMBAT"},        --DEPLOY_MISSION_ID_REVENGE_COMBAT5
--  [this.BLOCKED_TYPE.GUN_LIGHT]=  {type=this.REVENGE_TYPE.NIGHT_C,      reducePoints=-100,                        name="GUN_LIGHT REVENGE_TYPE.NIGHT_C"},   --DEPLOY_MISSION_ID_REVENGE_NIGHT_COMBAT
--  [this.BLOCKED_TYPE.SNIPER]=     {type=this.REVENGE_TYPE.LONG_RANGE,   reducePoints=-100,                        name="SNIPER REVENGE_TYPE.LONG_RANGE"},   --DEPLOY_MISSION_ID_REVENGE_LONG_RANGE
--  [this.BLOCKED_TYPE.MISSILE]=    {type=this.REVENGE_TYPE.VEHICLE,      reducePoints=-100,                        name="MISSILE REVENGE_TYPE.VEHICLE"}      --DEPLOY_MISSION_ID_REVENGE_VEHICLE
--
----  [this.REVENGE_TRIGGER_TYPE.WAKE_A_COMRADE]=this.REVENGE_TYPE.TRANQ, --no revenge blocking mission
----  [this.REVENGE_TRIGGER_TYPE.FULTON]=this.REVENGE_TYPE.FULTON, --no revenge blocking mission
--
----M_STEALTH and M_COMBAT work in the back ground. They only increase during a mission and
---- are reset to 0 in ApplyMissionTendency(missionId)
---- They increase STEALTH and COMBAT revenge points based on how you play and your current STEALTH and COMBAT revenge levels
--  }

this.DEPLOY_REVENGE_MISSION_BLOCKED_LIST={
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_SMOKE]=this.BLOCKED_TYPE.GAS_MASK,
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_HEAD_SHOT]=this.BLOCKED_TYPE.HELMET,
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_STEALTH1]=this.BLOCKED_TYPE.CAMERA,
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_STEALTH2]=this.BLOCKED_TYPE.DECOY,
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_STEALTH3]=this.BLOCKED_TYPE.MINE,
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_NIGHT_STEALTH]=this.BLOCKED_TYPE.NVG,
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_COMBAT1]=this.BLOCKED_TYPE.SHOTGUN,
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_COMBAT2]=this.BLOCKED_TYPE.MG,
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_COMBAT3]=this.BLOCKED_TYPE.SOFT_ARMOR,
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_COMBAT4]=this.BLOCKED_TYPE.SHIELD,
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_COMBAT5]=this.BLOCKED_TYPE.ARMOR,
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_NIGHT_COMBAT]=this.BLOCKED_TYPE.GUN_LIGHT,
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_LONG_RANGE]=this.BLOCKED_TYPE.SNIPER,
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_VEHICLE]=this.BLOCKED_TYPE.MISSILE}

this.DEPLOY_REVENGE_MISSION_CONDITION_LIST={
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_SMOKE]={revengeType=this.REVENGE_TYPE.SMOKE,lv=1},
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_HEAD_SHOT]={revengeType=this.REVENGE_TYPE.HEAD_SHOT,lv=1},
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_STEALTH1]={revengeType=this.REVENGE_TYPE.STEALTH,lv=1},
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_STEALTH2]={revengeType=this.REVENGE_TYPE.STEALTH,lv=2},
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_STEALTH3]={revengeType=this.REVENGE_TYPE.STEALTH,lv=3},
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_NIGHT_STEALTH]={revengeType=this.REVENGE_TYPE.NIGHT_S,lv=1},
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_COMBAT1]={revengeType=this.REVENGE_TYPE.COMBAT,lv=1},
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_COMBAT2]={revengeType=this.REVENGE_TYPE.COMBAT,lv=1},
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_COMBAT3]={revengeType=this.REVENGE_TYPE.COMBAT,lv=1},
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_COMBAT4]={revengeType=this.REVENGE_TYPE.COMBAT,lv=2},
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_COMBAT5]={revengeType=this.REVENGE_TYPE.COMBAT,lv=3},
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_NIGHT_COMBAT]={revengeType=this.REVENGE_TYPE.NIGHT_C,lv=1},
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_LONG_RANGE]={revengeType=this.REVENGE_TYPE.LONG_RANGE,lv=1},
	[TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_VEHICLE]={revengeType=this.REVENGE_TYPE.VEHICLE,lv=1},

--  --rX43 --REVAMPED REVENGE SYSTEM-- - Deployment missions affect corresponding revenge directly
--  --Comment above stealth/combat
--  [TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_STEALTH1]={revengeType=this.REVENGE_TYPE.CAMERA,lv=1},
--  [TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_STEALTH2]={revengeType=this.REVENGE_TYPE.DECOY,lv=1},
--  [TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_STEALTH3]={revengeType=this.REVENGE_TYPE.MINE,lv=1},
--  [TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_COMBAT1]={revengeType=this.REVENGE_TYPE.SHOTGUN,lv=1},
--  [TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_COMBAT2]={revengeType=this.REVENGE_TYPE.MG,lv=1},
--  [TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_COMBAT3]={revengeType=this.REVENGE_TYPE.SOFT_ARMOR,lv=1},
--  [TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_COMBAT4]={revengeType=this.REVENGE_TYPE.SHIELD,lv=1},
--  [TppMotherBaseManagementConst.DEPLOY_MISSION_ID_REVENGE_COMBAT5]={revengeType=this.REVENGE_TYPE.ARMOR,lv=1},
}

--K Revenge point table adjusted to give max revenge per level on each action
--r41 reset to vanilla game
this.REVENGE_POINT_TABLE={
	[this.REVENGE_TRIGGER_TYPE.HEAD_SHOT]={[this.REVENGE_TYPE.HEAD_SHOT]=5},
	[this.REVENGE_TRIGGER_TYPE.ELIMINATED_IN_STEALTH]={[this.REVENGE_TYPE.M_STEALTH]=5},
	[this.REVENGE_TRIGGER_TYPE.ELIMINATED_IN_COMBAT]={[this.REVENGE_TYPE.M_COMBAT]=5},
	[this.REVENGE_TRIGGER_TYPE.FULTON]={[this.REVENGE_TYPE.FULTON]=15},
	[this.REVENGE_TRIGGER_TYPE.SMOKE]={[this.REVENGE_TYPE.SMOKE]=15},
	[this.REVENGE_TRIGGER_TYPE.WATCH_SMOKE]={[this.REVENGE_TYPE.SMOKE]=15},
	[this.REVENGE_TRIGGER_TYPE.KILLED_BY_HELI]={[this.REVENGE_TYPE.VEHICLE]=10},
	[this.REVENGE_TRIGGER_TYPE.ANNIHILATED_IN_STEALTH]={[this.REVENGE_TYPE.M_STEALTH]=15},
	[this.REVENGE_TRIGGER_TYPE.ANNIHILATED_IN_COMBAT]={[this.REVENGE_TYPE.M_COMBAT]=15},
	[this.REVENGE_TRIGGER_TYPE.WAKE_A_COMRADE]={[this.REVENGE_TYPE.TRANQ]=5},
	[this.REVENGE_TRIGGER_TYPE.DISCOVERY_AT_NIGHT]={[this.REVENGE_TYPE.NIGHT_S]=15},
	[this.REVENGE_TRIGGER_TYPE.ELIMINATED_AT_NIGHT]={[this.REVENGE_TYPE.NIGHT_C]=10},
	[this.REVENGE_TRIGGER_TYPE.SNIPED]={[this.REVENGE_TYPE.LONG_RANGE]=30},
	[this.REVENGE_TRIGGER_TYPE.KILLED_BY_VEHICLE]={[this.REVENGE_TYPE.VEHICLE]=10}
}

--K Revenge reduction table which originally lowers revenge based on how u complete a mission - Stealth, Combat or Both(DRAW)
--r41 reset to vanilla
this.MISSION_TENDENCY_POINT_TABLE={
	STEALTH={
		--Combat reduced to lvl1
		STEALTH={25,25,25,25,50,50},
		COMBAT={0,0,-5,-10,-50,-50},

	--    --rX43 --REVAMPED REVENGE SYSTEM--
	--    --This is the way to go, child revenge types should only increase with parent lvls from vanilla game right
	--    --Other approach would increase all revenges all the tym
	--    --Plus with other approach, increments are too small! Not good - other approach is wrong
	--    --Each child starts to gain points one level lower than their activation level
	--    CAMERA={25,25,25,25,50,50},
	--    DECOY={0,25,25,25,50,50},
	--    MINE={0,0,25,25,50,50},
	--    SHOTGUN={0,0,-5,-10,-50,-50},
	--    MG={0,0,-5,-10,-50,-50},
	--    SOFT_ARMOR={0,0,-5,-10,-50,-50},
	--    SHIELD={0,0,-5,-10,-50,-50},
	--    ARMOR={0,0,-5,-10,-50,-50},
	--
	----    --rX43 --REVAMPED REVENGE SYSTEM-- - adjusted increase and decrease of each new power
	----    --Mind bending work
	----    --Each of these values are based on current revenge rank
	----    --Rank 0 points is the first entry in tables, Rank 1 points is second and so on
	----
	----    --Each revenge needs to increase/decrease at the same rate as vanilla game
	----    --However, levels are different between revenge(Stealth/Combat) and child revenges that have been created
	----    --It takes 4 missions and a +25 points for stealth to gain 1 level
	----    --On the same scale, it takes Camera 12 missions to go from level 1 to 2
	----    --This is because camera increases at Stealth lvl 1 and then again at Stealth level 4 - difference of 12 missions in between
	----    --As a result, points gained by Camera revenge at level 1 should be 9 per mission so that it takes 12 missions to get to Stealth lvl4 equivalent
	----
	----    --The opposite is in effect for decreases
	----    --It would take Shotgun at lvl2 34 missions and losing 3 points per mission to get to Combat lvl3 equivalent(or Shotgun lvl1)
	----
	----    --missions required for DECREASE from specified level
	----    --Lvl 5: 2 : cumulative reduction -50 (2 missions - 100 points)
	----    --Lvl 4: 2 : cumulative reduction -25 (4 missions - 200 points)
	----    --Lvl 3: 10 : cumulative reduction -7.1428571428571428571428571428571 (14 missions - 300 points)
	----    --Lvl 2: 20 : cumulative reduction -2.9411764705882352941176470588235 (34 missions - 400 points)
	----    --Lvl 1: 0 -- can't be decreased at all below lvl 1 - fucking stupid
	----    --Lvl 0: 0
	----    -- insane to think you can reduce stealth/combat to zero by adopting one style of play
	----
	----    --rX43 --REVAMPED REVENGE SYSTEM-- - revenge point tendency table
	----    CAMERA={25,9,50},
	----    DECOY={12.5,12.5,50},
	----    MINE={9,50},
	----    SHOTGUN={0,0,-3},
	----    MG={0,0,-3},
	----    SOFT_ARMOR={0,0,-3,-7.5,-25},
	----    SHIELD={0,0,-3,-7.5},
	----    ARMOR={0,0,-3,-7.5},
	},
	DRAW={
		--Both balance to lvl3
		STEALTH={20,20,20,0,-25,-10},
		COMBAT={20,20,20,0,-25,-10},

	--    --rX43 --REVAMPED REVENGE SYSTEM--
	--    --This is the way to go, child revenge types should only increase with parent lvls from vanilla game right
	--    --Other approach would increase all revenges all the tym
	--    --Plus with other approach, increments are too small! Not good - other approach is wrong
	--    --Each child starts to gain points one level lower than their activation level
	--    CAMERA={20,20,20,0,-25,-10},
	--    DECOY={0,20,20,0,-25,-10},
	--    MINE={0,0,20,0,-25,-10},
	--    SHOTGUN={20,20,20,0,-25,-10},
	--    MG={20,20,20,0,-25,-10},
	--    SOFT_ARMOR={20,20,20,0,-25,-10},
	--    SHIELD={0,20,20,0,-25,-10},
	--    ARMOR={0,0,20,0,-25,-10},
	--
	----    --rX43 --REVAMPED REVENGE SYSTEM--
	----    --Only lvl 4 and lvl 5 powers(vanilla game) can be reduced during a DRAW if they lose some attribute
	----    --Lvl 0,1,2 powers increase if they gain some new attribute otherwise no increase or decrease
	----    --Lvl 3 powers stay constant
	----    --The power should change to its Lvl 3 counter part as a result
	----    --Again a per mission point gain/loss has been calculated for each power
	----    --Difficult to maintain a constant table for DRAW
	----
	----    --rX43 --REVAMPED REVENGE SYSTEM--
	----    CAMERA={20,0,-7.5},
	----    DECOY={10,0,-7.5},
	----    MINE={7,0},
	----    SHOTGUN={20,0,-7.5},
	----    MG={20,0,-7.5},
	----    SOFT_ARMOR={20,20,20,0,-7.5},
	----    SHIELD={10,0,-25,-5},
	----    ARMOR={7,0,-25,-5},
	},
	COMBAT={
		--Stealth reduced to lvl1
		STEALTH={0,0,-5,-10,-50,-50},
		COMBAT={25,25,25,25,50,50},

	--    --rX43 --REVAMPED REVENGE SYSTEM--
	--    --This is the way to go, child revenge types should only increase with parent lvls from vanilla game right
	--    --Other approach would increase all revenges all the tym
	--    --Plus with other approach, increments are too small! Not good - other approach is wrong
	--    --Each child starts to gain points one level lower than their activation level
	--    CAMERA={0,0,-5,-10,-50,-50},
	--    DECOY={0,0,-5,-10,-50,-50},
	--    MINE={0,0,-5,-10,-50,-50},
	--    SHOTGUN={25,25,25,25,50,50},
	--    MG={25,25,25,25,50,50},
	--    SOFT_ARMOR={25,25,25,25,50,50},
	--    SHIELD={0,25,25,25,50,50},
	--    ARMOR={0,0,25,25,50,50},
	--
	----    --rX43 --REVAMPED REVENGE SYSTEM--
	----    --missions required for DECREASE from specified level
	----    --Lvl 5: 2 : cumulative reduction -50 (2 missions - 100 points)
	----    --Lvl 4: 2 : cumulative reduction -25 (4 missions - 200 points)
	----    --Lvl 3: 10 : cumulative reduction -7.1428571428571428571428571428571 (14 missions - 300 points)
	----    --Lvl 2: 20 : cumulative reduction -2.9411764705882352941176470588235 (34 missions - 400 points)
	----    --Lvl 1: 0 -- can't be decreased at all below lvl 1 - fucking stupid
	----    --Lvl 0: 0
	----
	----    --rX43 --REVAMPED REVENGE SYSTEM--
	----    CAMERA={0,0,-3},
	----    DECOY={0,0,-3},
	----    MINE={0,-7.5},
	----    SHOTGUN={25,9,50},
	----    MG={25,9,50},
	----    SOFT_ARMOR={25,25,25,25,50},
	----    SHIELD={12.5,12.5,25,50},
	----    ARMOR={9,25,25,50},
	}
}

--K Completely maxed all Revenge levels just in case
this.revengeDefine={
	--TODO study effects
	HARD_MISSION={IGNORE_BLOCKED=true},
	_ENABLE_CAMERA_LV=1, --rX43 --REVAMPED REVENGE SYSTEM-- - Come back to this later - decides what STEALTH level cameras are enabled at but is not used I think
	_ENABLE_DECOY_LV=2,
	_ENABLE_MINE_LV=3,
	--  _ENABLE_CAMERA_LV=8, --K no noticeable effect
	--  _ENABLE_DECOY_LV=8, --K no noticeable effect
	--  _ENABLE_MINE_LV=8, --K no noticeable effect
	STEALTH_0={STEALTH_LOW=true,HOLDUP_LOW=true},
	STEALTH_1={CAMERA="100%",HOLDUP_LOW=true},
	STEALTH_2={DECOY="100%",CAMERA="100%"},
	STEALTH_3={DECOY="100%",MINE="100%",CAMERA="100%",STEALTH_HIGH=true},
	STEALTH_4={DECOY="100%",MINE="100%",CAMERA="100%",STEALTH_HIGH=true,HOLDUP_HIGH=true,ACTIVE_DECOY=true,GUN_CAMERA=true},
	STEALTH_5={DECOY="100%",MINE="100%",CAMERA="100%",STEALTH_SPECIAL=true,HOLDUP_HIGH=true,ACTIVE_DECOY=true,GUN_CAMERA=true},

	--  --rX43 --REVAMPED REVENGE SYSTEM-- new Stealth revenge
	--  STEALTH_0={STEALTH_LOW=true,HOLDUP_LOW=true},
	--  STEALTH_1={HOLDUP_LOW=true},
	--  STEALTH_2={STEALTH_HIGH=true},
	--  STEALTH_3={STEALTH_HIGH=true},
	--  STEALTH_4={STEALTH_HIGH=true,HOLDUP_HIGH=true},
	--  STEALTH_5={STEALTH_SPECIAL=true,HOLDUP_HIGH=true},
	--
	--  --While the below approach works, it leads to a situation where combat deployment at camera level 5 sets camera level to 4
	--  -- but does not offer any advantages obviously - this approach required rank levels similar to stealth/combat - easier to do but not useful
	----  CAMERA_0={},
	----  CAMERA_1={CAMERA="100%"},
	----  CAMERA_2={CAMERA="100%"},
	----  CAMERA_3={CAMERA="100%"},
	----  CAMERA_4={CAMERA="100%",GUN_CAMERA=true},
	----  CAMERA_5={CAMERA="100%",GUN_CAMERA=true},
	----  DECOY_0={},
	----  DECOY_1={},
	----  DECOY_2={DECOY="100%"},
	----  DECOY_3={DECOY="100%"},
	----  DECOY_4={DECOY="100%",ACTIVE_DECOY=true},
	----  DECOY_5={DECOY="100%",ACTIVE_DECOY=true},
	----  MINE_0={},
	----  MINE_1={},
	----  MINE_2={},
	----  MINE_3={MINE="100%"},
	----  MINE_4={MINE="100%"},
	----  MINE_5={MINE="100%"},
	--
	--  --rX43 --REVAMPED REVENGE SYSTEM-- new Stealth child revenges
	--  --Revenge level 0 need not have any explicit declarations
	--  CAMERA_1={CAMERA="100%"},
	--  CAMERA_2={CAMERA="100%",GUN_CAMERA=true},
	--  DECOY_1={DECOY="100%"},
	--  DECOY_2={DECOY="100%",ACTIVE_DECOY=true},
	--  MINE_1={MINE="100%"},

	NIGHT_S_1={NVG="25%"},
	NIGHT_S_2={NVG="50%"},
	NIGHT_S_3={NVG="75%"},
	_ENABLE_SOFT_ARMOR_LV=1,
	_ENABLE_SHOTGUN_LV=1,
	_ENABLE_MG_LV=1,
	_ENABLE_SHIELD_LV=2,
	_ENABLE_ARMOR_LV=3,
	--  _ENABLE_SOFT_ARMOR_LV=8, --K no noticeable effect
	--  _ENABLE_SHOTGUN_LV=8, --K no noticeable effect
	--  _ENABLE_MG_LV=8, --K no noticeable effect
	--  _ENABLE_SHIELD_LV=8, --K no noticeable effect
	--  _ENABLE_ARMOR_LV=8, --K no noticeable effect
	COMBAT_0={COMBAT_LOW=true},
	COMBAT_1={
		{SOFT_ARMOR="25%",SHOTGUN=2},
		{SOFT_ARMOR="25%",MG=2}
	},
	COMBAT_2={
		{SOFT_ARMOR="50%",SHOTGUN=2,SHIELD=1},
		{SOFT_ARMOR="50%",MG=2,SHIELD=1}
	},
	COMBAT_3={
		{SOFT_ARMOR="75%",SHOTGUN=2,SHIELD=1,ARMOR=1,STRONG_WEAPON=true,COMBAT_HIGH=true,SUPER_REINFORCE=true},
		{SOFT_ARMOR="75%",MG=2,SHIELD=1,ARMOR=1,STRONG_WEAPON=true,COMBAT_HIGH=true,SUPER_REINFORCE=true}
	},
	COMBAT_4={
		--r68 BUGFIX: reinforcement calls were 99 with Combat revenge lvl 4
		{SOFT_ARMOR="100%",SHOTGUN=4,SHIELD=2,ARMOR=2,STRONG_WEAPON=true,COMBAT_HIGH=true,SUPER_REINFORCE=true,REINFORCE_COUNT=2},
		{SOFT_ARMOR="100%",MG=4,SHIELD=2,ARMOR=2,STRONG_WEAPON=true,COMBAT_HIGH=true,SUPER_REINFORCE=true,REINFORCE_COUNT=2}
	},
	COMBAT_5={
		{SOFT_ARMOR="100%",SHOTGUN=4,SHIELD=4,ARMOR=4,STRONG_WEAPON=true,COMBAT_SPECIAL=true,SUPER_REINFORCE=true,BLACK_SUPER_REINFORCE=true,REINFORCE_COUNT=3},
		{SOFT_ARMOR="100%",MG=4,SHIELD=4,ARMOR=4,STRONG_WEAPON=true,COMBAT_SPECIAL=true,SUPER_REINFORCE=true,BLACK_SUPER_REINFORCE=true,REINFORCE_COUNT=3}
	},

	--  --rX43 --REVAMPED REVENGE SYSTEM-- New combat revenge
	--  COMBAT_0={COMBAT_LOW=true},
	--  COMBAT_1={},
	--  COMBAT_2={},
	--  COMBAT_3={STRONG_WEAPON=true,COMBAT_HIGH=true,SUPER_REINFORCE=true},
	--  COMBAT_4={STRONG_WEAPON=true,COMBAT_HIGH=true,SUPER_REINFORCE=true,REINFORCE_COUNT=99},
	--  COMBAT_5={STRONG_WEAPON=true,COMBAT_SPECIAL=true,SUPER_REINFORCE=true,BLACK_SUPER_REINFORCE=true,REINFORCE_COUNT=99},
	--
	--  --rX43 --REVAMPED REVENGE SYSTEM-- new Combat child revenges
	--  SHOTGUN_1={SHOTGUN=2},
	--  SHOTGUN_2={SHOTGUN=4},
	--  MG_1={MG=2},
	--  MG_2={MG=4},
	--  SOFT_ARMOR_1={SOFT_ARMOR="25%"},
	--  SOFT_ARMOR_2={SOFT_ARMOR="50%"},
	--  SOFT_ARMOR_3={SOFT_ARMOR="75%"},
	--  SOFT_ARMOR_4={SOFT_ARMOR="100%"},
	--  SHIELD_1={SHIELD=1},
	--  SHIELD_2={SHIELD=2},
	--  SHIELD_3={SHIELD=4},
	--  ARMOR_1={ARMOR=1},
	--  ARMOR_2={ARMOR=2},
	--  ARMOR_3={ARMOR=4},

	NIGHT_C_1={GUN_LIGHT="75%"},
	LONG_RANGE_1={SNIPER=2},
	LONG_RANGE_2={SNIPER=2,STRONG_SNIPER=true},
	VEHICLE_1={MISSILE=2},
	VEHICLE_2={MISSILE=2,STRONG_MISSILE=true},
	VEHICLE_3={MISSILE=4,STRONG_MISSILE=true},

	--rX43 INFO --HEAD_SHOT only has a max level of 7 in effect - lol
	HEAD_SHOT_1={HELMET="10%"},
	HEAD_SHOT_2={HELMET="20%"},
	HEAD_SHOT_3={HELMET="30%"},
	HEAD_SHOT_4={HELMET="40%"},
	HEAD_SHOT_5={HELMET="50%"},
	HEAD_SHOT_6={HELMET="60%"},
	HEAD_SHOT_7={HELMET="70%"}, --rX48 INFO This is max possible helmet % based on game's existing code(flawed). Also 70% feels like 90
	HEAD_SHOT_8={HELMET="80%"},
	HEAD_SHOT_9={HELMET="90%"},
	HEAD_SHOT_10={HELMET="100%"},
	TRANQ_1={STRONG_NOTICE_TRANQ=true},
	FULTON_0={},
	FULTON_1={FULTON_LOW=true}, --r48 Fixed Retail bug with fulton although this doesn't matter with max revenge anyway
	FULTON_2={FULTON_HIGH=true},
	FULTON_3={FULTON_SPECIAL=true},
	SMOKE_1={GAS_MASK="25%"},
	SMOKE_2={GAS_MASK="50%"},
	SMOKE_3={GAS_MASK="75%"},
	FOB_NoKill={NO_KILL_WEAPON=true},
	FOB_EquipGrade_1={EQUIP_GRADE_LIMIT=1},
	FOB_EquipGrade_2={EQUIP_GRADE_LIMIT=2},
	FOB_EquipGrade_3={EQUIP_GRADE_LIMIT=3},
	FOB_EquipGrade_4={EQUIP_GRADE_LIMIT=4},
	FOB_EquipGrade_5={EQUIP_GRADE_LIMIT=5},
	FOB_EquipGrade_6={EQUIP_GRADE_LIMIT=6},
	FOB_EquipGrade_7={EQUIP_GRADE_LIMIT=7},
	FOB_EquipGrade_8={EQUIP_GRADE_LIMIT=8},
	FOB_EquipGrade_9={EQUIP_GRADE_LIMIT=9},
	FOB_EquipGrade_10={EQUIP_GRADE_LIMIT=10},
	FOB_ShortRange={SHOTGUN="30%",SHIELD="60%",SMG="100%"},
	FOB_MiddleRange={MG="40%",MISSILE="15%"},
	FOB_LongRange={SNIPER="50%"},
	FOB_ShortRange_1={},
	FOB_ShortRange_2={SHOTGUN="10%"},
	FOB_ShortRange_3={SHOTGUN="10%"},
	FOB_ShortRange_4={SMG="10%",SHOTGUN="10%",SHIELD="10%"},
	FOB_ShortRange_5={SMG="10%",SHOTGUN="10%",SHIELD="10%"},
	FOB_ShortRange_6={SMG="20%",SHOTGUN="10%",SHIELD="20%"},
	FOB_ShortRange_7={SMG="20%",SHOTGUN="20%",SHIELD="20%"},
	FOB_ShortRange_8={STRONG_WEAPON=true,SMG="20%",SHOTGUN="20%",SHIELD="20%"},
	FOB_ShortRange_9={STRONG_WEAPON=true,SMG="20%",SHOTGUN="25%",SHIELD="20%"},
	FOB_ShortRange_10={STRONG_WEAPON=true,SMG="30%",SHOTGUN="30%",SHIELD="30%"},
	FOB_MiddleRange_1={},
	FOB_MiddleRange_2={MG="10%"},
	FOB_MiddleRange_3={MG="10%"},
	FOB_MiddleRange_4={MG="20%"},
	FOB_MiddleRange_5={MG="20%"},
	FOB_MiddleRange_6={STRONG_WEAPON=true,MG="20%"},
	FOB_MiddleRange_7={STRONG_WEAPON=true,MG="30%"},
	FOB_MiddleRange_8={STRONG_WEAPON=true,MG="30%",SHOTGUN="10%"},
	FOB_MiddleRange_9={STRONG_WEAPON=true,MG="30%",SHOTGUN="10%",MISSILE="10%"},
	FOB_MiddleRange_10={STRONG_WEAPON=true,MG="40%",SHOTGUN="10%",SNIPER="10%",MISSILE="10%"},
	FOB_LongRange_1={},
	FOB_LongRange_2={SNIPER="10%"},
	FOB_LongRange_3={SNIPER="10%"},
	FOB_LongRange_4={SNIPER="15%"},
	FOB_LongRange_5={STRONG_SNIPER=true,SNIPER="15%"},
	FOB_LongRange_6={STRONG_SNIPER=true,SNIPER="20%",MISSILE="10%"},
	FOB_LongRange_7={STRONG_SNIPER=true,SNIPER="20%",MISSILE="10%"},
	FOB_LongRange_8={STRONG_WEAPON=true,STRONG_SNIPER=true,STRONG_MISSILE=true,SNIPER="20%",MISSILE="10%"},
	FOB_LongRange_9={STRONG_WEAPON=true,STRONG_SNIPER=true,STRONG_MISSILE=true,SNIPER="25%",MISSILE="10%"},
	FOB_LongRange_10={STRONG_WEAPON=true,STRONG_SNIPER=true,STRONG_MISSILE=true,SNIPER="30%",MISSILE="20%",MG="10%"}
}

--r51 Settings
if TUPPMSettings.rev_ENABLE_customModRevengeProfile then
	--	TUPPMLog.Log("BEFORE this.revengeDefine:"..tostring(InfInspect.Inspect(this.revengeDefine)),1,true)

	--K Adjusted NVG, 25% allows gas masks to show up, % is divided between nvg, helmets, gas masks
	this.revengeDefine.NIGHT_S_3={NVG="20%"} --r48 set to 20% --r41 set to 25%
	this.revengeDefine.COMBAT_5={
		--  SHIELD=4, --determines max shield carriers. Unfortunately, the game has a balance mechanism elsewhere. With higher *grade* weapons, I find shields spawn almost never in Afghanistan, and always in Africa. This is so because the game determines what weapon-type-soldiers to spawn somewhere else.
		--  ARMOR=4, --determines number of heavy armor users, having more than 4 breaks the game's ARMOR mechanics
		--  STRONG_WEAPON=true, -- Each weapon has strong types defined in TppEnemy.lua for each enemy 'faction'
		--  COMBAT_SPECIAL=true, --don't know what this is for. Heavy armor maybe? But ARMOR variable directly affects heavy armor so not sure
		--  SUPER_REINFORCE=true, --Heli
		--  BLACK_SUPER_REINFORCE=true, --Black Heli, much higher HP
		{SOFT_ARMOR="100%",SHOTGUN=4,SHIELD=4,ARMOR=4,STRONG_WEAPON=true,COMBAT_SPECIAL=true,SUPER_REINFORCE=true,BLACK_SUPER_REINFORCE=true,REINFORCE_COUNT=3},
		{SOFT_ARMOR="100%",MG=4,SHIELD=4,ARMOR=4,STRONG_WEAPON=true,COMBAT_SPECIAL=true,SUPER_REINFORCE=true,BLACK_SUPER_REINFORCE=true,REINFORCE_COUNT=3}
	}
	this.revengeDefine.NIGHT_C_1={GUN_LIGHT="100%"} --K all soldiers have gun lights
	--K Adjusted helmets, 25% allows gas masks to show up, % is divided between nvg, helmets, gas masks and heavy armor
	this.revengeDefine.HEAD_SHOT_7={HELMET="22%"} --r48 set to 22% --r41 set to 25%
	--K adjusted gas masks to ensure some spawn at least
	this.revengeDefine.SMOKE_3={GAS_MASK="20%"} --r48 set to 20% --r41 set to 25%

	--	TUPPMLog.Log("AFTER this.revengeDefine:"..tostring(InfInspect.Inspect(this.revengeDefine)),1,true)
end

--r68 --Allow 99 reinforcement calls during combat alert
if TUPPMSettings.rev_ENABLE_maxReinforceCalls then
	this.revengeDefine.COMBAT_5[1].REINFORCE_COUNT=99
	this.revengeDefine.COMBAT_5[2].REINFORCE_COUNT=99
end

--rX43 INFO Revenge in revengeDefine are loaded up here
function this.SelectRevengeType()
	local n=TppMission.GetMissionID()
	if this.IsNoRevengeMission(n)or n==10115 then
		return{}
	end
	local r=TppMission.IsHardMission(n)
	local t={}
	for E=0,this.REVENGE_TYPE.MAX-1 do
		local n
		if r then
			n=this.GetRevengeLvMax(E,REVENGE_LV_LIMIT_RANK_MAX)
		else
			n=this.GetRevengeLv(E)
		end
		if n>=0 then
			local n=this.REVENGE_TYPE_NAME[E+1]..("_"..tostring(n))
			local e=this.revengeDefine[n]
			if e then
				table.insert(t,n)
			end
		end
	end
	if r then
		table.insert(t,"HARD_MISSION")
	end
	return t
end
function this.SetForceRevengeType(e)
	if not Tpp.IsTypeTable(e)then
		e={e}
	end
	mvars.revenge_forceRevengeType=e
end
function this.IsNoRevengeMission(n)
	if n==nil then
		return false
	end
	local e=this.NO_REVENGE_MISSION_LIST[n]
	if e==nil then
		return false
	end
	return e
end
function this.IsNoStealthCombatRevengeMission(n)
	if n==nil then
		return false
	end
	local e=this.NO_STEALTH_COMBAT_REVENGE_MISSION_LIST[n]
	if e==nil then
		return false
	end
	return e
end

function this.GetEquipGradeLimit()
	return mvars.revenge_revengeConfig.EQUIP_GRADE_LIMIT
end
function this.IsUsingNoKillWeapon()
	return mvars.revenge_revengeConfig.NO_KILL_WEAPON
end
function this.IsUsingStrongWeapon()
	return mvars.revenge_revengeConfig.STRONG_WEAPON
end
function this.IsUsingStrongMissile()
	return mvars.revenge_revengeConfig.STRONG_MISSILE
end
function this.IsUsingStrongSniper()
	return mvars.revenge_revengeConfig.STRONG_SNIPER
end
function this.IsUsingSuperReinforce()
	if not mvars.revenge_isEnabledSuperReinforce then
		return false
	end
	return mvars.revenge_revengeConfig.SUPER_REINFORCE
end
function this.IsUsingBlackSuperReinforce()
	return mvars.revenge_revengeConfig.BLACK_SUPER_REINFORCE
end
function this.GetReinforceCount()
	local e=mvars.revenge_revengeConfig.REINFORCE_COUNT
	if e then
		return e+0
	end
	return 1
end
function this.CanUseArmor(e)

	if TppEneFova==nil then
		return false
	end

	local n=TppMission.GetMissionID()

	if TppEneFova.IsNotRequiredArmorSoldier(n) then --K This function decides which missions not to apply ARMOR to, Free play is included by default, ie. ARMOR does not show up during Free play mode.
		return false
	end

	if e then
		return TppEneFova.CanUseArmorType(n,e)
	end

	return true
end

local n=function(e)
	if e==nil then
		return 0
	end
	return(e:sub(1,-2)+0)/100
end
function this.GetMineRate()
	return n(mvars.revenge_revengeConfig.MINE)
end
function this.GetDecoyRate()
	return n(mvars.revenge_revengeConfig.DECOY)
end
function this.IsUsingActiveDecoy()
	return mvars.revenge_revengeConfig.ACTIVE_DECOY
end
function this.GetCameraRate()
	return n(mvars.revenge_revengeConfig.CAMERA)
end
function this.IsUsingGunCamera()
	return mvars.revenge_revengeConfig.GUN_CAMERA
end
function this.GetPatrolRate()
	if mvars.revenge_revengeConfig.STRONG_PATROL then
		return 1
	else
		return 0
	end
end
function this.IsIgnoreBlocked()
	return mvars.revenge_revengeConfig.IGNORE_BLOCKED
end
function this.IsBlocked(e)
	if e==nil then
		return false
	end
	--TUPPMLog.Log(e.." is Blocked "..tostring(gvars.rev_revengeBlockedCount[e]>0))

	--  --rX43 --REVAMPED REVENGE SYSTEM-- return blocked as true if revenge level is 0
	--  if this.BLOCK_MISSION_TO_REDUCE_REVENGE_TABLE[e]~=nil then
	--    local revengeType=this.BLOCK_MISSION_TO_REDUCE_REVENGE_TABLE[e].type
	--
	--    if this.GetRevengeLv(revengeType)==0 then
	--      --TUPPMLog.Log("Blocking: "..tostring(this.REVENGE_TYPE_NAME[revengeType+1])..", level: "..tostring(this.GetRevengeLv(revengeType)))
	--      return true
	--    end
	--  end

	return gvars.rev_revengeBlockedCount[e]>0
end
function this.SetEnabledSuperReinforce(e)
	mvars.revenge_isEnabledSuperReinforce=e
end
function this.SetHelmetAll()
	mvars.revenge_revengeConfig.HELMET="100%"end
function this.RegisterMineList(n,E)
	if not mvars.rev_usingBase then
		return
	end
	mvars.rev_mineBaseTable={}
	for n,e in ipairs(n)do
		if mvars.rev_usingBase[e]then
			mvars.rev_mineBaseTable[e]=n-1
		end
	end
	mvars.rev_mineBaseList=n
	mvars.rev_mineBaseCountMax=#n
	this.RegisterCommonMineList(E)
end
function this.RegisterCommonMineList(E)
	mvars.rev_mineTrapTable={}
	for n,e in pairs(E)do
		if mvars.rev_usingBase[n]then
			for E,e in ipairs(e)do
				local e=e.trapName
				local n={areaIndex=E,trapName=e,baseName=n}
				mvars.rev_mineTrapTable[Fox.StrCode32(e)]=n
			end
		end
	end
	mvars.rev_revengeMineList={}
	for n,E in pairs(E)do
		if mvars.rev_usingBase[n]then
			mvars.rev_revengeMineList[n]={}
			if Tpp.IsTypeTable(E)then
				if next(E)then
					for E,t in ipairs(E)do
						mvars.rev_revengeMineList[n][E]={}this._CopyRevengeMineArea(mvars.rev_revengeMineList[n][E],t,n,E)
					end
					local e=E.decoyLocatorList
					if e then
						mvars.rev_revengeMineList[n].decoyLocatorList={}
						for E,e in ipairs(e)do
							table.insert(mvars.rev_revengeMineList[n].decoyLocatorList,e)
						end
					end
				end
			end
		end
	end
end
function this.RegisterMissionMineList(n)
	for n,E in pairs(n)do
		this.AddBaseMissionMineList(n,E)
	end
end
function this.AddBaseMissionMineList(e,n)
	local a=mvars.rev_revengeMineList[e]
	if not a then
		return
	end
	if not Tpp.IsTypeTable(n)then
		return
	end
	local E=n.decoyLocatorList
	if E then
		local n=mvars.rev_revengeMineList[e].decoyLocatorList
		mvars.rev_revengeMineList[e].decoyLocatorList=mvars.rev_revengeMineList[e].decoyLocatorList or{}
		for E,n in ipairs(E)do
			table.insert(mvars.rev_revengeMineList[e].decoyLocatorList,n)
		end
	end
	for t,r in pairs(n)do
		local e=mvars.rev_mineTrapTable[Fox.StrCode32(t)]
		if e then
			local e=e.areaIndex
			local e=a[e]
			local n=r.mineLocatorList
			if n then
				e.mineLocatorList=e.mineLocatorList or{}
				for E,n in ipairs(n)do
					table.insert(e.mineLocatorList,n)
				end
			end
			if not E then
				local n=r.decoyLocatorList
				if n then
					e.decoyLocatorList=e.decoyLocatorList or{}
					for E,n in ipairs(n)do
						table.insert(e.decoyLocatorList,n)
					end
				end
			end
		else
			if t~="decoyLocatorList"then
			end
		end
	end
end
function this._CopyRevengeMineArea(e,n,E,E)
	local E=n.trapName
	if E then
		e.trapName=E
	else
		return
	end
	local E=n.mineLocatorList
	if E then
		e.mineLocatorList={}
		for E,n in ipairs(E)do
			e.mineLocatorList[E]=n
		end
	end
	local n=n.decoyLocatorList
	if n then
		e.decoyLocatorList={}
		for n,E in ipairs(n)do
			e.decoyLocatorList[n]=E
		end
	end
end
function this.OnEnterRevengeMineTrap(n)
	if not mvars.rev_mineTrapTable then
		return
	end
	local n=mvars.rev_mineTrapTable[n]
	if not n then
		return
	end
	local t,n,E=n.areaIndex,n.baseName,n.trapName
	this.UpdateLastVisitedMineArea(n,t,E)
end
function this.ClearLastRevengeMineBaseName()
	gvars.rev_lastUpdatedBaseName=0
end
function this.UpdateLastVisitedMineArea(n,t,e)
	local e=mvars.rev_LastVisitedMineAreaVarsName
	if not e then
		return
	end
	local E=Fox.StrCode32(n)
	if gvars.rev_lastUpdatedBaseName==E then
		return
	else
		gvars.rev_lastUpdatedBaseName=E
	end
	local n=mvars.rev_mineBaseTable[n]gvars[e][n]=t
end
function this.SaveMissionStartMineArea()
	local e,E=mvars.rev_missionStartMineAreaVarsName,mvars.rev_LastVisitedMineAreaVarsName
	if not e then
		return
	end
	for n=0,(TppDefine.REVENGE_MINE_BASE_MAX-1)do
		gvars[e][n]=gvars[E][n]
	end
end
function this.SetUpRevengeMine()
	if TppMission.IsMissionStart()then
		this._SetUpRevengeMine()
	end
end
function this._SetUpRevengeMine()
	local missionStartMineAreaVarsName=mvars.rev_missionStartMineAreaVarsName
	if not missionStartMineAreaVarsName then
		return
	end
	if not mvars.rev_mineBaseTable then
		return
	end
	local addMines,addDecoys=false,false
	if this.GetMineRate()>.5 then
		addMines=true
	else
		addMines=false
	end
	if this.GetDecoyRate()>.5 then
		addDecoys=true
	else
		addDecoys=false
	end
	for cpName,cpIndex in pairs(mvars.rev_mineBaseTable)do
		local cpMineList=mvars.rev_revengeMineList[cpName]
		local cpMineFieldIndex=gvars[missionStartMineAreaVarsName][cpIndex]
		if cpMineFieldIndex==0 and#cpMineList>0 then
			cpMineFieldIndex=math.random(1,#cpMineList)
			gvars[missionStartMineAreaVarsName][cpIndex]=cpMineFieldIndex
		end
		local locatorList=cpMineList.decoyLocatorList
		local t=false
		for index,mineField in ipairs(cpMineList)do
			local mineLocatorList=mineField.mineLocatorList
			if mineLocatorList then
				local enable=addMines and (index==cpMineFieldIndex or TUPPMSettings.rev_ENABLE_allMinefields) --r51 Settings --r33 Activate all mines - thank you tex
				if enable then
					t=false
				end
				for index,locatorName in ipairs(mineLocatorList)do
					TppPlaced.SetEnableByLocatorName(locatorName,enable)
				end
			end
			local decoyLocatorList=mineField.decoyLocatorList
			if locatorList then
				this._EnableDecoy(cpName,locatorList,addDecoys)
				if addDecoys then
					t=false
				end
			end
			if decoyLocatorList then
				local enable=addDecoys and (index==cpMineFieldIndex)
				this._EnableDecoy(cpName,decoyLocatorList,enable)
				if enable then
					t=false
				end
			end
		end
		if t then
		end
	end
end
function this._GetDecoyType(e)
	local n={PF_A=1,PF_B=2,PF_C=3}
	local e=GetGameObjectId(e)
	local e=TppEnemy.GetCpSubType(e)
	return n[e]
end
function this._EnableDecoy(n,t,E)
	local n=n.."_cp"
	local n=this._GetDecoyType(n)
	local r=this.IsUsingActiveDecoy()
	for t,e in ipairs(t)do
		if n then
			TppPlaced.SetCorrelationValueByLocatorName(e,n)
		end
		if r then
			TppPlaced.ChangeEquipIdByLocatorName(e,TppEquip.EQP_SWP_ActiveDecoy) --r43 Reverted back to Active Decoys as shock decoys may sometimes be advantageous
			--      TppPlaced.ChangeEquipIdByLocatorName(e,TppEquip.EQP_SWP_ShockDecoy_G02) --r33 shock decoy
		end
		TppPlaced.SetEnableByLocatorName(e,E)
	end
end
function this._SetupCamera()
	if not GameObject.DoesGameObjectExistWithTypeName"TppSecurityCamera2"then
		return
	end
	if TppLocation.IsMotherBase()or TppLocation.IsMBQF()then
		return
	end
	local n=false
	if this.GetCameraRate()>.5 then
		n=true
	else
		n=false
	end
	GameObject.SendCommand({type="TppSecurityCamera2"},{id="SetEnabled",enabled=n})
	if this.IsUsingGunCamera()then
		GameObject.SendCommand({type="TppSecurityCamera2"},{id="SetGunCamera"})
	else
		GameObject.SendCommand({type="TppSecurityCamera2"},{id="SetNormalCamera"})
	end
end
function this.OnAllocate(n)
	mvars.revenge_isEnabledSuperReinforce=true
	this.SetUpMineAreaVarsName()
	if n.sequence then
		local e=n.sequence.baseList
		if e then
			local n=TppLocation.GetLocationName()
			mvars.rev_usingBase={}
			for E,e in ipairs(e)do
				local e=n..("_"..e)
				mvars.rev_usingBase[e]=true
			end
		end
	end
end
function this.SetUpMineAreaVarsName()
	if TppLocation.IsAfghan()then
		mvars.rev_missionStartMineAreaVarsName="rev_baseMissionStartMineAreaAfgh"mvars.rev_LastVisitedMineAreaVarsName="rev_baseLastVisitedMineAreaAfgh"elseif TppLocation.IsMiddleAfrica()then
		mvars.rev_missionStartMineAreaVarsName="rev_baseMissionStartMineAreaMafr"mvars.rev_LastVisitedMineAreaVarsName="rev_baseLastVisitedMineAreaMafr"else
		return
	end
end
function this.DecideRevenge(n)
	this._SetUiParameters()
	mvars.revenge_revengeConfig=mvars.revenge_revengeConfig or{}
	mvars.revenge_revengeType=mvars.revenge_forceRevengeType
	if mvars.revenge_revengeType==nil then
		mvars.revenge_revengeType=this.SelectRevengeType()
	end
	mvars.revenge_revengeConfig=this._CreateRevengeConfig(mvars.revenge_revengeType)
	if(n.enemy and n.enemy.soldierDefine)or vars.missionCode>6e4 then
		this._AllocateResources(mvars.revenge_revengeConfig)
	end
end
function this.SetUpEnemy()
	if mvars.ene_soldierDefine==nil then
		return
	end
	if mvars.ene_soldierIDList==nil then
		return
	end
	this._SetMbInterrogate()
	local n=this.GetReinforceCount()
	GameObject.SendCommand({type="TppCommandPost2"},{id="SetReinforceCount",count=n})
	if TppLocation.IsMotherBase()or TppLocation.IsMBQF()then
		TppEnemy.SetUpDDParameter()
	end
	this._SetupCamera()
	for cpName,soldierList in pairs(mvars.ene_soldierDefine)do
		local cpId=GetGameObjectId(cpName)
		if cpId==NULL_ID then
		else
			if TppLocation.IsMotherBase()or TppLocation.IsMBQF()then
				for plantNumber=0,3 do
					--TUPPMLog.Log("BEFORE cpID: "..tostring(n).." plant: "..tostring(E).." seedValue: "..tostring(this.seedValue))
					this._ApplyRevengeToCp(cpId,mvars.revenge_revengeConfig,plantNumber)
					--TUPPMLog.Log("AFTER cpID: "..tostring(n).." plant: "..tostring(E).." seedValue: "..tostring(this.seedValue))
				end
			else
				this._ApplyRevengeToCp(cpId,mvars.revenge_revengeConfig)
			end
		end
	end
end
function this.GetRevengeLvLimitRank()

	--r51 Settings
	if TUPPMSettings.rev_ENABLE_maxRevengeLvlLimitFromStart then
		return 6
	end

	--K set Revenge *LEVEL* to max from the start, there's a war in Afghanistan afterall
	local e=gvars.str_storySequence
	if e<TppDefine.STORY_SEQUENCE.CLEARD_FIND_THE_SECRET_WEAPON then
		return 1
	elseif e<TppDefine.STORY_SEQUENCE.CLEARD_RESCUE_HUEY then
		return 2
	elseif e<TppDefine.STORY_SEQUENCE.CLEARD_ELIMINATE_THE_POWS then
		return 3
	elseif e<TppDefine.STORY_SEQUENCE.CLEARD_WHITE_MAMBA then
		return 4
	elseif e<TppDefine.STORY_SEQUENCE.CLEARD_OKB_ZERO then
		return 5
	else
		return 6
	end
	return 6
end
function this.GetRevengeLv(revengeType)
	--r51 Settings
	if TUPPMSettings.rev_ENABLE_maxRevengeAlways then
		--r57 Fixed missing dependency between rev_ENABLE_maxRevengeAlways and rev_ENABLE_maxRevengeLvlLimitFromStart
		return this.GetRevengeLvMax(revengeType) --K Set all Revenge to max *LEVEL* - this is key to max enemy preparedness --does not increase actual revenge points for each revenge type
	else
		return gvars.rev_revengeLv[revengeType] --vanilla game
	end
end
function this.GetRevengeLvMax(revengeType,maxAllowedLimit)
	local maxLimit=maxAllowedLimit or this.GetRevengeLvLimitRank()
	local limitsForRevengeType=this.REVENGE_LV_MAX[revengeType]
	if Tpp.IsTypeTable(limitsForRevengeType)then
		local maxLimitForRevenge=limitsForRevengeType[maxLimit]
		return maxLimitForRevenge or 0
	end
	return 0
end
function this.GetRevengePoint(e)
	return gvars.rev_revengePoint[e]
end
function this.AddRevengePoint(n,E)this.SetRevengePoint(n,gvars.rev_revengePoint[n]+E)
end
function this.GetRevengeTriggerName(n)
	for e,E in pairs(this.REVENGE_TRIGGER_TYPE)do
		if E==n then
			return e
		end
	end
	return""
end
function this.AddRevengePointByTriggerType(n)
	local E=TppMission.GetMissionID()
	if this.IsNoRevengeMission(E)then
		return
	end
	local t="###REVENGE### "..(tostring(E)..(" / AddRevengePointBy ["..(this.GetRevengeTriggerName(n).."] : ")))
	local n=this.REVENGE_POINT_TABLE[n]
	for n,E in pairs(n)do
		n=n+0
		E=E+0
		local r=gvars.rev_revengePoint[n]this.SetRevengePoint(n,gvars.rev_revengePoint[n]+E)
		local E=gvars.rev_revengePoint[n]t=t..(this.REVENGE_TYPE_NAME[n+1]..(":"..(tostring(r)..("->"..(tostring(E).." ")))))
	end
end
function this.SetRevengePoint(revengeType,points)
	local maxRevLevel=this.GetRevengeLvMax(revengeType)
	local maxPossiblePoints=maxRevLevel*this.REVENGE_POINT_PER_LV+this.REVENGE_POINT_OVER_MARGINE
	if points<0 then
		points=0
	end
	if points>maxPossiblePoints then
		points=maxPossiblePoints
	end
	gvars.rev_revengePoint[revengeType]=points
end
function this.ResetRevenge()
	for n=0,this.REVENGE_TYPE.MAX-1 do
		this.SetRevengePoint(n,0)
	end
	this.UpdateRevengeLv()
end
function this.UpdateRevengeLv(n)
	if n==nil then
		n=TppMission.GetMissionID()
	end
	for n=0,this.REVENGE_TYPE.MAX-1 do
		local E=this.GetRevengeLvMax(n)
		local e=this.GetRevengePoint(n)
		local e=math.floor(e/100)
		if e>E then
			e=E
		end
		gvars.rev_revengeLv[n]=e
	end
	this._SetEnmityLv()
end
function this._GetUiParameterValue(E)
	local r=4
	local t=5
	local n=this.GetRevengeLv(E)
	if n>=this.GetRevengeLvMax(E,t)then
		return 3
	elseif n>=this.GetRevengeLvMax(E,r)then
		return 2
	elseif n>=1 then
		return 1
	end
	return 0
end
function this._SetUiParameters()
	local a=this._GetUiParameterValue(this.REVENGE_TYPE.FULTON)
	local r=this._GetUiParameterValue(this.REVENGE_TYPE.HEAD_SHOT)
	local E=this._GetUiParameterValue(this.REVENGE_TYPE.STEALTH)
	local n=this._GetUiParameterValue(this.REVENGE_TYPE.COMBAT)
	local t=math.min(3,math.max(this.GetRevengeLv(this.REVENGE_TYPE.NIGHT_S),this.GetRevengeLv(this.REVENGE_TYPE.NIGHT_C)))
	local e=this._GetUiParameterValue(this.REVENGE_TYPE.LONG_RANGE)
	TppUiCommand.RegisterEnemyRevengeParameters{fulton=a,headShot=r,stealth=E,combat=n,night=t,longRange=e}
end
function this._SetMbInterrogate()
	--TODO rX41 mess with this
	if not GameObject.DoesGameObjectExistWithTypeName"TppSoldier2"then
		return
	end
	local E=0
	local n={
		--rX43 --REVAMPED REVENGE SYSTEM-- look into this
		{MbInterrogate.FULUTON,this.REVENGE_TYPE.FULTON,1},
		{MbInterrogate.GAS,this.REVENGE_TYPE.SMOKE,1,this.BLOCKED_TYPE.GAS_MASK},
		{MbInterrogate.MET,this.REVENGE_TYPE.HEAD_SHOT,1,this.BLOCKED_TYPE.HELMET},
		{MbInterrogate.FLASH,this.REVENGE_TYPE.NIGHT_C,1,this.BLOCKED_TYPE.GUN_LIGHT},
		{MbInterrogate.SNIPER,this.REVENGE_TYPE.LONG_RANGE,1,this.BLOCKED_TYPE.SNIPER},
		{MbInterrogate.MISSILE,this.REVENGE_TYPE.VEHICLE,1,this.BLOCKED_TYPE.MISSILE},
		{MbInterrogate.NIGHT,this.REVENGE_TYPE.NIGHT_S,1,this.BLOCKED_TYPE.NVG},
		{MbInterrogate.CAMERA,this.REVENGE_TYPE.STEALTH,this.revengeDefine._ENABLE_CAMERA_LV,this.BLOCKED_TYPE.CAMERA},
		{MbInterrogate.DECOY,this.REVENGE_TYPE.STEALTH,this.revengeDefine._ENABLE_DECOY_LV,this.BLOCKED_TYPE.DECOY},
		{MbInterrogate.MINE,this.REVENGE_TYPE.STEALTH,this.revengeDefine._ENABLE_MINE_LV,this.BLOCKED_TYPE.MINE},
		{MbInterrogate.SHOTGUN,this.REVENGE_TYPE.COMBAT,this.revengeDefine._ENABLE_SHOTGUN_LV,this.BLOCKED_TYPE.SHOTGUN},
		{MbInterrogate.MACHINEGUN,this.REVENGE_TYPE.COMBAT,this.revengeDefine._ENABLE_MG_LV,this.BLOCKED_TYPE.MG},
		{MbInterrogate.BODY,this.REVENGE_TYPE.COMBAT,this.revengeDefine._ENABLE_SOFT_ARMOR_LV,this.BLOCKED_TYPE.SOFT_ARMOR},
		{MbInterrogate.SHIELD,this.REVENGE_TYPE.COMBAT,this.revengeDefine._ENABLE_SHIELD_LV,this.BLOCKED_TYPE.SHIELD},
		{MbInterrogate.ARMOR,this.REVENGE_TYPE.COMBAT,this.revengeDefine._ENABLE_ARMOR_LV,this.BLOCKED_TYPE.ARMOR}
	}
	for t,n in ipairs(n)do
		local t=n[1]
		local a=n[2]
		local r=n[3]
		local n=n[4]
		if n and this.IsBlocked(n)then
		elseif this.GetRevengeLv(a)>=r then
			E=bit.bor(E,t)
		end
	end
	GameObject.SendCommand({type="TppSoldier2"},{id="SetMbInterrogate",enableMask=E})
end
function this._SetEnmityLv()
	local n=this.GetRevengePoint(this.REVENGE_TYPE.STEALTH)
	local e=this.GetRevengePoint(this.REVENGE_TYPE.COMBAT)
	local t=math.max(n,e)
	local e={TppMotherBaseManagementConst.STAFF_INIT_ENMITY_LV_NONE,TppMotherBaseManagementConst.STAFF_INIT_ENMITY_LV_10,TppMotherBaseManagementConst.STAFF_INIT_ENMITY_LV_20,TppMotherBaseManagementConst.STAFF_INIT_ENMITY_LV_30,TppMotherBaseManagementConst.STAFF_INIT_ENMITY_LV_40,TppMotherBaseManagementConst.STAFF_INIT_ENMITY_LV_50,TppMotherBaseManagementConst.STAFF_INIT_ENMITY_LV_60,TppMotherBaseManagementConst.STAFF_INIT_ENMITY_LV_70,TppMotherBaseManagementConst.STAFF_INIT_ENMITY_LV_80,TppMotherBaseManagementConst.STAFF_INIT_ENMITY_LV_90,TppMotherBaseManagementConst.STAFF_INIT_ENMITY_LV_100}
	local n=500
	local E=#e
	local n=math.floor((t*(E-1))/n)+1
	if n>=E then
		n=#e
	end
	local e=e[n]
	TppMotherBaseManagement.SetStaffInitEnmityLv{lv=e}
end

function this.OnMissionClearOrAbort(missionId)
	gvars.rev_revengeRandomValue=math.random(0,2147483647)
	this.seedValue=0 --r27 Randomize seed for each soldier
	this.ApplyMissionTendency(missionId)
	this._ReduceRevengePointByChickenCap(missionId)
	this._ReduceBlockedCount(missionId)
	this._ReceiveClearedDeployRevengeMission()
	this.UpdateRevengeLv(missionId)
	this._AddDeployRevengeMission()
end
function this._ReduceBlockedCount(n)
	if not TppMission.IsHelicopterSpace(n)then
		return
	end
	for n=0,this.BLOCKED_TYPE.MAX-1 do
		local e=gvars.rev_revengeBlockedCount[n]
		if e>0 then
			gvars.rev_revengeBlockedCount[n]=e-1
		end
	end
end
function this._GetBlockedName(n)
	for E,e in pairs(this.BLOCKED_TYPE)do
		if e==n then
			return E
		end
	end
	return"unknown"
end


function this._ReceiveClearedDeployRevengeMission()
	if not TppMotherBaseManagement.GetClearedDeployRevengeMissionFlag then
		return
	end
	for deployMissionId,revengeTypeToBlock in pairs(this.DEPLOY_REVENGE_MISSION_BLOCKED_LIST)do
		local clearFlag=TppMotherBaseManagement.GetClearedDeployRevengeMissionFlag{deployMissionId=deployMissionId}
		if clearFlag then

			--r43 --REVAMPED REVENGE SYSTEM--
			--Block the revenge as is vanilla game behavior - alternately do not block it
			-- but that would require precise handling of revenge points. For example,
			-- blocking ARMOR should reduce COMBAT points by 100 so ARMOR is no longer used.
			-- Similarly blocking SHIELD should also reduce revenge by 100. However! if shields are
			-- blocked before ARMOR then we have a bit of a tricky situation on our hands.
			-- The game only enables armor at the highest COMBAT level after enabling shields

			--So this sort of an implementation with reducing reveng points would
			-- require a whole new revenge system
			--Totally possible and will look into it if I am super bored one day

			--        --rX43 --REVAMPED REVENGE SYSTEM-- do not block any revenge type
			gvars.rev_revengeBlockedCount[revengeTypeToBlock]=this.BLOCKED_FOR_MISSION_COUNT
			TppMotherBaseManagement.UnsetClearedDeployRevengeMissionFlag{deployMissionId=deployMissionId}

			--        --rX43 --REVAMPED REVENGE SYSTEM-- Reduce revenge each time a revenge blocking mission is completed
			--        local revengeReduceDetails = this.BLOCK_MISSION_TO_REDUCE_REVENGE_TABLE[revengeTypeToBlock]
			--        this.AddRevengePoint(revengeReduceDetails.type,revengeReduceDetails.reducePoints)
			--        this.UpdateRevengeLv()
			--        --rX43 --REVAMPED REVENGE SYSTEM-- reduce stealth and combat points in case any specific RCDM is completed
			--        if (revengeReduceDetails.type==16 or revengeReduceDetails.type==17 or revengeReduceDetails.type==18) then
			--          this.AddRevengePoint(0,revengeReduceDetails.reduceStealth)
			--          this.UpdateRevengeLv()
			--          --TUPPMLog.Log("Reduced: STEALTH, type: 0, points: "..tostring(gvars.rev_revengePoint[0])..", level: "..tostring(this.GetRevengeLv(0)))
			--        end
			--        if (revengeReduceDetails.type==19 or revengeReduceDetails.type==20 or revengeReduceDetails.type==21 or revengeReduceDetails.type==22 or revengeReduceDetails.type==23) then
			--          this.AddRevengePoint(2,revengeReduceDetails.reduceCombat)
			--          this.UpdateRevengeLv()
			--          --TUPPMLog.Log("Reduced: COMBAT, type: 2, points: "..tostring(gvars.rev_revengePoint[2])..", level: "..tostring(this.GetRevengeLv(2)))
			--        end
			--        --TUPPMLog.Log("Reduced: "..tostring(revengeReduceDetails.name)..", type: "..tostring(revengeReduceDetails.type)..", points: "..tostring(gvars.rev_revengePoint[revengeReduceDetails.type])..", level: "..tostring(this.GetRevengeLv(revengeReduceDetails.type)))

		end
	end
end
function this._AddDeployRevengeMission()
	for deployMissionId,blockDetails in pairs(this.DEPLOY_REVENGE_MISSION_CONDITION_LIST)do
		local blockType=this.DEPLOY_REVENGE_MISSION_BLOCKED_LIST[deployMissionId]

		--    TUPPMLog.Log("Revenge name: "..tostring(this.REVENGE_TYPE_NAME[blockDetails.revengeType+1])..", level: "..tostring(this.GetRevengeLv(blockDetails.revengeType)))

		--r43 Revenge blocking deploy missions are always available for better spamming
		--Keep adding blocking missions over and over
		-- irrespective of 3 mission length
		--TBH revenge blocking missions should have been based on (BLOCKED_FOR_MISSION_COUNT-1)
		-- so that they would become available again in the 3rd mission itself instead of the 4th
		--Ofcourse they were never meant to be spammed in vanilla game but still
		if
			(not this.IsBlocked(blockType) or TUPPMSettings.dispatch_ENABLE_ignoreBlockedForRevengeDispatchMissions) --r51 Settings --Remove blocked check to re-add instantly
			and this.GetRevengeLv(blockDetails.revengeType)>=blockDetails.lv then
			local e=TppMotherBaseManagement.RequestAddDeployRevengeMission{deployMissionId=deployMissionId}
		else
			if not TppMotherBaseManagement.RequestDeleteDeployRevengeMission then
				return
			end
			TppMotherBaseManagement.RequestDeleteDeployRevengeMission{deployMissionId=deployMissionId}
		end
	end
end
function this._ReduceRevengePointStealthCombat()
	for n,E in pairs(this.REDUCE_TENDENCY_POINT_TABLE)do
		local t=this.GetRevengePoint(n)
		local r=this.GetRevengeLv(n)
		local E=E[r+1]this.SetRevengePoint(n,(t+E))
	end
end
function this._ReduceRevengePointOther()
	local r={
		[this.REVENGE_TYPE.STEALTH]=true,
		[this.REVENGE_TYPE.COMBAT]=true,
		[this.REVENGE_TYPE.M_STEALTH]=true,
		[this.REVENGE_TYPE.M_COMBAT]=true,

	--  --rX43 --REVAMPED REVENGE SYSTEM-- Exclude these from standard point reduction just like parents
	--  [this.REVENGE_TYPE.CAMERA]=true,
	--  [this.REVENGE_TYPE.DECOY]=true,
	--  [this.REVENGE_TYPE.MINE]=true,
	--  [this.REVENGE_TYPE.SHOTGUN]=true,
	--  [this.REVENGE_TYPE.MG]=true,
	--  [this.REVENGE_TYPE.SOFT_ARMOR]=true,
	--  [this.REVENGE_TYPE.SHIELD]=true,
	--  [this.REVENGE_TYPE.ARMOR]=true,
	}
	for E=0,this.REVENGE_TYPE.MAX-1 do
		local a=this.GetRevengePoint(E)
		local t=this.GetRevengeLv(E)
		local n=0
		if r[E]then
			n=0
		elseif bit.band(vars.playerPlayFlag,PlayerPlayFlag.USE_CHICKEN_CAP)==PlayerPlayFlag.USE_CHICKEN_CAP then
			n=100
		elseif this.REDUCE_POINT_TABLE[E]then
			n=this.REDUCE_POINT_TABLE[E][t+1]
			if n==nil then
				n=50
			else
				n=-n
			end
		else
			n=this.REDUCE_REVENGE_POINT*(t+1)
			if n>50 then
				n=50
			end
		end
		this.SetRevengePoint(E,a-n)
	end
end
function this.ReduceRevengePointOnMissionClear(n)
	if n==nil then
		n=TppMission.GetMissionID()
	end
	if this.IsNoRevengeMission(n)then
		return
	end
	if bit.band(vars.playerPlayFlag,PlayerPlayFlag.USE_CHICKEN_CAP)==PlayerPlayFlag.USE_CHICKEN_CAP then
		return
	end
	this._ReduceRevengePointOther() --TODO rX46 The game already reduces revenge points on mission clear - adjust Revamped Revenge Mod
end
function this._ReduceRevengePointByChickenCap(n)
	if n==nil then
		n=TppMission.GetMissionID()
	end
	if this.IsNoRevengeMission(n)then
		return
	end
	if bit.band(vars.playerPlayFlag,PlayerPlayFlag.USE_CHICKEN_CAP)==PlayerPlayFlag.USE_CHICKEN_CAP then
		this._ReduceRevengePointStealthCombat()this._ReduceRevengePointOther()
	end
end
function this.ReduceRevengePointOnAbort(e)
end

--r43 INFO
function this._GetMissionTendency(missionId)
	local missionStealthPoints=this.GetRevengePoint(this.REVENGE_TYPE.M_STEALTH)
	local missionRevengePoints=this.GetRevengePoint(this.REVENGE_TYPE.M_COMBAT)

	if missionStealthPoints==0 and missionRevengePoints==0 then
		return"STEALTH"
	end
	if missionRevengePoints==0 then
		return"STEALTH"
	end
	if missionStealthPoints==0 then
		return"COMBAT"
	end

	local differenceOfPoints=missionStealthPoints-missionRevengePoints
	local multiplier=.3
	local minNecessaryPointDifference=10
	local comparisonPoints=(missionStealthPoints+missionRevengePoints)*multiplier
	if comparisonPoints<minNecessaryPointDifference then
		comparisonPoints=minNecessaryPointDifference
	end

	local playStyle="DRAW"
	if differenceOfPoints>=comparisonPoints then
		playStyle="STEALTH"
	elseif differenceOfPoints<=-comparisonPoints then
		playStyle="COMBAT"
	end
	return playStyle
end

--r43 INFO
function this.ApplyMissionTendency(missionId)
	if missionId==nil then
		missionId=TppMission.GetMissionID()
	end
	if(not this.IsNoRevengeMission(missionId)and not this.IsNoStealthCombatRevengeMission(missionId))and bit.band(vars.playerPlayFlag,PlayerPlayFlag.USE_CHICKEN_CAP)~=PlayerPlayFlag.USE_CHICKEN_CAP then
		local tendencyType=this._GetMissionTendency(missionId)
		local tendencyPointsTable=this.MISSION_TENDENCY_POINT_TABLE[tendencyType]
		if tendencyPointsTable then
			local stealthLevel=this.GetRevengeLv(this.REVENGE_TYPE.STEALTH)+1
			local combatLevel=this.GetRevengeLv(this.REVENGE_TYPE.COMBAT)+1
			-- #tendencyPointsTable.STEALTH or #tendencyPointsTable.COMBAT will always be 6
			if stealthLevel>#tendencyPointsTable.STEALTH then
				stealthLevel=#tendencyPointsTable.STEALTH
			end
			if combatLevel>#tendencyPointsTable.COMBAT then
				combatLevel=#tendencyPointsTable.COMBAT
			end
			--This basically increases stealth or combat revenge type based on how you played a mission
			this.AddRevengePoint(this.REVENGE_TYPE.STEALTH,tendencyPointsTable.STEALTH[stealthLevel])
			this.AddRevengePoint(this.REVENGE_TYPE.COMBAT,tendencyPointsTable.COMBAT[combatLevel])

			--      --rX43 --REVAMPED REVENGE SYSTEM-- increase new child revenge points
			----      this.AddRevengePoint(this.REVENGE_TYPE.CAMERA,tendencyPointsTable.CAMERA[this.GetRevengeLv(this.REVENGE_TYPE.CAMERA)+1])
			----      this.AddRevengePoint(this.REVENGE_TYPE.DECOY,tendencyPointsTable.DECOY[this.GetRevengeLv(this.REVENGE_TYPE.DECOY)+1])
			----      this.AddRevengePoint(this.REVENGE_TYPE.MINE,tendencyPointsTable.MINE[this.GetRevengeLv(this.REVENGE_TYPE.MINE)+1])
			----      this.AddRevengePoint(this.REVENGE_TYPE.SHOTGUN,tendencyPointsTable.SHOTGUN[this.GetRevengeLv(this.REVENGE_TYPE.SHOTGUN)+1])
			----      this.AddRevengePoint(this.REVENGE_TYPE.MG,tendencyPointsTable.MG[this.GetRevengeLv(this.REVENGE_TYPE.MG)+1])
			----      this.AddRevengePoint(this.REVENGE_TYPE.SOFT_ARMOR,tendencyPointsTable.SOFT_ARMOR[this.GetRevengeLv(this.REVENGE_TYPE.SOFT_ARMOR)+1])
			----      this.AddRevengePoint(this.REVENGE_TYPE.SHIELD,tendencyPointsTable.SHIELD[this.GetRevengeLv(this.REVENGE_TYPE.SHIELD)+1])
			----      this.AddRevengePoint(this.REVENGE_TYPE.ARMOR,tendencyPointsTable.ARMOR[this.GetRevengeLv(this.REVENGE_TYPE.ARMOR)+1])
			--
			--      --This is the way to go, child revenge types should only increase with parent lvls from vanilla game right
			--      this.AddRevengePoint(this.REVENGE_TYPE.CAMERA,tendencyPointsTable.CAMERA[stealthLevel])
			--      this.AddRevengePoint(this.REVENGE_TYPE.DECOY,tendencyPointsTable.DECOY[stealthLevel])
			--      this.AddRevengePoint(this.REVENGE_TYPE.MINE,tendencyPointsTable.MINE[stealthLevel])
			--      this.AddRevengePoint(this.REVENGE_TYPE.SHOTGUN,tendencyPointsTable.SHOTGUN[combatLevel])
			--      this.AddRevengePoint(this.REVENGE_TYPE.MG,tendencyPointsTable.MG[combatLevel])
			--      this.AddRevengePoint(this.REVENGE_TYPE.SOFT_ARMOR,tendencyPointsTable.SOFT_ARMOR[combatLevel])
			--      this.AddRevengePoint(this.REVENGE_TYPE.SHIELD,tendencyPointsTable.SHIELD[combatLevel])
			--      this.AddRevengePoint(this.REVENGE_TYPE.ARMOR,tendencyPointsTable.ARMOR[combatLevel])

		end
	end
	--Reset M_STEALTH and M_COMBAT to 0 after every mission completion/abort
	this.SetRevengePoint(this.REVENGE_TYPE.M_STEALTH,0)
	this.SetRevengePoint(this.REVENGE_TYPE.M_COMBAT,0)
end
function this.CanUseReinforceVehicle()
	local missionId=TppMission.GetMissionID()
	return this.USE_SUPER_REINFORCE_VEHICLE_MISSION[missionId]
end
function this.CanUseReinforceHeli()
	return not GameObject.DoesGameObjectExistWithTypeName"TppEnemyHeli" --TODO K Always Use Heli --test it out
end
function this.SelectReinforceType()
	if mvars.reinforce_reinforceType==TppReinforceBlock.REINFORCE_TYPE.HELI then
		return TppReinforceBlock.REINFORCE_TYPE.HELI
	end
	if not this.IsUsingSuperReinforce()then
		return TppReinforceBlock.REINFORCE_TYPE.NONE
	end
	local reinforceVehicles={}
	local canUserReinforceVehicle=this.CanUseReinforceVehicle()
	local canUseReinforceHeli=this.CanUseReinforceHeli()
	if canUserReinforceVehicle then
		--TODO Debug and check Ground vehicle usage
		local reinforceVehiclesForLocation={
			AFGH={TppReinforceBlock.REINFORCE_TYPE.EAST_WAV,TppReinforceBlock.REINFORCE_TYPE.EAST_TANK},
			MAFR={TppReinforceBlock.REINFORCE_TYPE.WEST_WAV,TppReinforceBlock.REINFORCE_TYPE.WEST_WAV_CANNON,TppReinforceBlock.REINFORCE_TYPE.WEST_TANK}
		}
		if TppLocation.IsAfghan()then
			reinforceVehicles=reinforceVehiclesForLocation.AFGH
		elseif TppLocation.IsMiddleAfrica()then
			reinforceVehicles=reinforceVehiclesForLocation.MAFR
		end
	end
	if canUseReinforceHeli then
		table.insert(reinforceVehicles,TppReinforceBlock.REINFORCE_TYPE.HELI)
	end
	if#reinforceVehicles==0 then
		return TppReinforceBlock.REINFORCE_TYPE.NONE
	end
	local randomVehicleType=math.random(1,#reinforceVehicles)
	return reinforceVehicles[randomVehicleType]
end

function this.ApplyPowerSettingsForReinforce(soldierIds)
	for n,soldierId in ipairs(soldierIds)do
		GameObject.SendCommand(soldierId,{id="RegenerateStaffIdForReinforce"})
	end

	local loadOut={}

	--r51 Settings
	if not TUPPMSettings.reinforce_ENABLE_customModRevengeProfile then
		--Vanilla behavior
		do
			local headshotRevengeLevel=this.GetRevengeLv(this.REVENGE_TYPE.HEAD_SHOT)
			local helmetLimit=headshotRevengeLevel/10
			if math.random()<helmetLimit and(this.IsIgnoreBlocked()or not this.IsBlocked(this.BLOCKED_TYPE.HELMET))then
				table.insert(loadOut,"HELMET")
			end
		end
		if this.IsUsingStrongWeapon()then
			table.insert(loadOut,"STRONG_WEAPON")
		end
		if this.IsUsingNoKillWeapon()then
			table.insert(loadOut,"NO_KILL_WEAPON")
		end
		do
			local combatLimit=0
			local combatRevengeLevel=this.GetRevengeLv(this.REVENGE_TYPE.COMBAT)
			if combatRevengeLevel>=4 then
				combatLimit=99
			elseif combatRevengeLevel>=3 then
				combatLimit=.75
			elseif combatRevengeLevel>=1 then
				combatLimit=.5
			end
			if math.random()<combatLimit and(this.IsIgnoreBlocked()or not this.IsBlocked(this.BLOCKED_TYPE.SOFT_ARMOR))then
				table.insert(loadOut,"SOFT_ARMOR")
			end
			if math.random()<combatLimit then
				if mvars.revenge_loadedEquip.SHOTGUN and(this.IsIgnoreBlocked()or not this.IsBlocked(this.BLOCKED_TYPE.SHOTGUN))then
					table.insert(loadOut,"SHOTGUN")
				elseif mvars.revenge_loadedEquip.MG and(this.IsIgnoreBlocked()or not this.IsBlocked(this.BLOCKED_TYPE.MG))then
					table.insert(loadOut,"MG")
				end
			end
		end

		for E,soldierId in ipairs(soldierIds)do
			TppEnemy.ApplyPowerSetting(soldierId,loadOut)
		end

	else
		--K let's fuck things up!
		-- add a non FOB check! -- maybe not
		-- more testing
		-- Edit: tested, below changes work in conjunction with TppEnemy function e.ApplyPowerSetting(t,i) !!!
		-- Stop item usage here or in TppEnemy function e.ApplyPowerSetting(t,i)

		for E,cpId in ipairs(soldierIds)do --Randomize reinforcement equipment in a controlled manner

			loadOut={} --clean table
			--r41 Adding NVGs and Gasmasks into the mix
			local isUsingArmor = false
			local isUsingHelmet = false
			local canUseNVG = false
			local isUsingNVG = false
			local canUseGasMask = false
			local isUsingGasMask = false


			table.insert(loadOut,"STRONG_WEAPON")

			if (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.HELMET)) then
				table.insert(loadOut,"HELMET")
				isUsingHelmet=true
			end

			--r51 Settings
			if TUPPMSettings.reinforce_ENABLE_ARMORedReinforcements and (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.ARMOR)) then
				table.insert(loadOut,"ARMOR") -- works! All reinforcements have ARMOR!
				isUsingArmor = true
			end

			--TODO rX7 try removing soft armor completely when ARMOR used --DONE
			if not isUsingArmor
				and (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.SOFT_ARMOR)) then
				table.insert(loadOut,"SOFT_ARMOR")
			end

			--r41 Added NVGs and Gasmasks into the mix
			if not isUsingArmor
				and (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.NVG))
				and TppClock.GetTimeOfDay()=="night"
			then
				canUseNVG=true
			end

			if not isUsingArmor
				and (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.GAS_MASK)) then
				canUseGasMask=true
			end

			local randomVariable = math.random()
			randomVariable = math.random()
			if canUseNVG then
				if randomVariable<=0.33 then
					table.insert(loadOut,"NVG")
					isUsingNVG = true
					TppMain.Randomize()
				end
			end

			randomVariable = math.random()
			if canUseGasMask and not isUsingNVG then
				if randomVariable<=0.33 then
					table.insert(loadOut,"GAS_MASK")
					isUsingGasMask = true
					TppMain.Randomize()
				end
			end

			randomVariable = math.random()
			if (isUsingGasMask or isUsingNVG) and (canUseGasMask and canUseNVG) then
				if randomVariable<=0.33 then
					table.insert(loadOut,"NVG")
					table.insert(loadOut,"GAS_MASK")
					TppMain.Randomize()
				end
			end

			randomVariable = math.random()

			--TUPPMLog.Log("powerSettings.ARMOR is "..tostring(powerSettings.ARMOR)) --this will be nil even when ARMOR is added to the table. The value for the record is nil.
			--TUPPMLog.Log("powerSettings[\"ARMOR\"] is "..tostring(powerSettings["ARMOR"]))  -- same nil value; remember not nil is true

			local isWeaponSet=false
			while not isWeaponSet do
				randomVariable = math.random()
				if randomVariable <= 0.1666666666666667 and (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.SNIPER)) then
					table.insert(loadOut,"SNIPER")
					isWeaponSet=true
					TppMain.Randomize()
				elseif randomVariable <= 0.3333333333333333 and (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.MISSILE)) then
					table.insert(loadOut,"MISSILE")
					isWeaponSet=true
					TppMain.Randomize()
				elseif randomVariable <= 0.5 and (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.MG)) then
					table.insert(loadOut,"MG")
					isWeaponSet=true
					TppMain.Randomize()
				elseif randomVariable <= 0.6666666666666667 and (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.SHOTGUN)) then
					table.insert(loadOut,"SHOTGUN")
					isWeaponSet=true
					TppMain.Randomize()
				elseif randomVariable <= 0.8333333333333333 then
					table.insert(loadOut,"ASSAULT")
					isWeaponSet=true
					TppMain.Randomize()
				elseif randomVariable <= 1
					and not isUsingArmor
					and (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.SHIELD))
				then
					--TUPPMLog.Log("Shields are used")
					table.insert(loadOut,"SHIELD") --r15 Adding Shield when ARMOR is blocked
					isWeaponSet=true
					TppMain.Randomize()
				end
			end

			TppEnemy.ApplyPowerSetting(cpId,loadOut)
		end
	end
end

--r13 add shields and missiles to all missions Hellbound is exception
-- not here!
function this._CreateRevengeConfig(revengeTypes)
	local revengeConfig={}
	local disablePowerSettings=mvars.ene_disablePowerSettings
	do
		local requiredPowerSettings=mvars.ene_missionRequiresPowerSettings
		local revengeComboExclusionList={
			MISSILE={"SHIELD"},SHIELD={"MISSILE"},SHOTGUN={"MG"},MG={"SHOTGUN"}
		}
		
		--r51 Settings
		if TUPPMSettings.rev_ENABLE_allWeaponsInRestrictedMissions then
			revengeComboExclusionList={
				--r40 Removed mission power restrictions - works!
				--If a mission like M30 Skull Face requires MISSILES, then SHIELDS are blocked for that mission completely through this table
				--Removing entries here does not immediately enable shields in that mission tho - I saw only 1
				--Interestingly, disabling MISSILES for that mission still allows missiles because it is a
				--reuired power type for that mission, and also immediately allows shields if removed from here

				--      MISSILE={"SHIELD"},
				--      SHIELD={"MISSILE"},
				--      SHOTGUN={"MG"},
				--      MG={"SHOTGUN"}
				}
		end

		for powerType,E in pairs(requiredPowerSettings)do
			local exclusionList=revengeComboExclusionList[powerType]
			if exclusionList then
				for n,powerType in ipairs(exclusionList)do
					if not mvars.ene_missionRequiresPowerSettings[powerType] then
						--TUPPMLog.Log("blocking "..tostring(powerType))
						disablePowerSettings[powerType]=true
					end
				end
			end
		end
	end

	--    disablePowerSettings={}  --r13 removes all power settings

	for r,revengeType in ipairs(revengeTypes)do
		local revengeTypeDetails=this.revengeDefine[revengeType]
		if revengeTypeDetails~=nil then
			if revengeTypeDetails[1]~=nil then
				local rnd=this._Random(1,#revengeTypeDetails)
				revengeTypeDetails=revengeTypeDetails[rnd]
			end
			--      --rX43 --REVAMPED REVENGE SYSTEM-- Load only Shotgun or MG revenge - keep in line with vanilla
			--      local shotgunOrMg=this._Random(1,2)
			for powerType,powerSetting in pairs(revengeTypeDetails)do
				if disablePowerSettings[powerType]then
				--        --rX43 --REVAMPED REVENGE SYSTEM-- This little code allows for only SHOTGUN or MG similar to vanilla game
				--        elseif shotgunOrMg==1 and powerType=="SHOTGUN" then
				--          --TUPPMLog.Log("Skipping SHOTGUN")
				--        elseif shotgunOrMg==2 and powerType=="MG" then
				--          --TUPPMLog.Log("Skipping MG")
				else
					revengeConfig[powerType]=powerSetting
				end
			end
		end
	end

	if not revengeConfig.IGNORE_BLOCKED then
		for powerType,powerSetting in pairs(revengeConfig)do
			if this.IsBlocked(this.BLOCKED_TYPE[powerType])then
				revengeConfig[powerType]=nil
			end
		end
	end
	--TppUiCommand.AnnounceLogView("ARMOR allowed "..tostring(n.ARMOR))
	if Tpp.IsTypeNumber(revengeConfig.ARMOR) and not this.CanUseArmor() then
		if not disablePowerSettings.SHIELD then
			local shieldCount=revengeConfig.SHIELD or 0
			if Tpp.IsTypeNumber(shieldCount)then
				revengeConfig.SHIELD=shieldCount+revengeConfig.ARMOR
			end
		end
		revengeConfig.ARMOR=nil
	end
	local revengeComboExclusionNonRequire={NO_KILL_WEAPON={"MG"}}

	if not mvars.ene_missionRequiresPowerSettings.SHIELD then
		revengeComboExclusionNonRequire.MISSILE={"SHIELD"}
	end
	if not mvars.ene_missionRequiresPowerSettings.MG then
		revengeComboExclusionNonRequire.SHOTGUN={"MG"}
	end
	local doExcludePower={}
	for powerType,excludePowers in pairs(revengeComboExclusionNonRequire)do
		if revengeConfig[powerType] and not doExcludePower[powerType]then
			for n,powerType in ipairs(excludePowers)do
				doExcludePower[powerType]=true
			end
		end
	end

	for powerType,bool in pairs(doExcludePower)do
		revengeConfig[powerType]=nil
	end

	local missionId=TppMission.GetMissionID()
	if TppMission.IsFOBMission(missionId)then
		local weaponTable=TppEnemy.weaponIdTable.DD
		if revengeConfig.NO_KILL_WEAPON and weaponTable then
			local normalTable=weaponTable.NORMAL
			if normalTable and normalTable.IS_NOKILL then
				if not normalTable.IS_NOKILL.SHOTGUN then
					revengeConfig.SHOTGUN=nil
				end
				if not normalTable.IS_NOKILL.MISSILE then
					revengeConfig.MISSILE=nil
				end
				if not normalTable.IS_NOKILL.SNIPER then
					revengeConfig.SNIPER=nil
				end
				if not normalTable.IS_NOKILL.SMG then
					revengeConfig.SHIELD=nil
					revengeConfig.MISSILE=nil
				end
			end
		end
	end
	return revengeConfig
end

function this._AllocateResources(config)
	mvars.revenge_loadedEquip={}
	local missionRequiresSettings=mvars.ene_missionRequiresPowerSettings
	local loadWeaponIds={}
	local nullId=NULL_ID
	local defaultSoldierType=TppEnemy.GetSoldierType(nullId)
	local defaultSoldierSubType=TppEnemy.GetSoldierSubType(nullId)
	local weaponIdTable=TppEnemy.GetWeaponIdTable(defaultSoldierType,defaultSoldierSubType)
	if weaponIdTable==nil then
		TppEnemy.weaponIdTable.DD={NORMAL={HANDGUN=TppEquip.EQP_WP_West_hg_010,ASSAULT=TppEquip.EQP_WP_West_ar_040}}
		weaponIdTable=TppEnemy.weaponIdTable.DD
	end
	local disablePowerSettings=mvars.ene_disablePowerSettings --r13 powers are already disabled for mentioned missions
	local missionId=TppMission.GetMissionID()
	local useAllWeapons=true

	--r13 Enable powers for these missions
	--r51 Settings
	if
		TUPPMSettings.rev_ENABLE_allWeaponsInRestrictedMissions and
		(
		vars.missionCode==10070 --Mission 12 - Hellbound --No Shields nor Missiles
		or vars.missionCode==10080 --Mission 13 - Pitch Dark
		or vars.missionCode==11080 --Mission 44 - [Total Stealth] Pitch Dark
		or vars.missionCode==10090 --Mission 16 - Traitors Caravan --No Shields
		or vars.missionCode==11090 --Mission 37 - [Extreme] Traitors Caravan --No Shields
		or vars.missionCode==10211 --Mission 26 - Hunting Down --No Shields
		)
	then
		--enabling power settings here does not interfere with dispatch mission blocking of powers
		for powerType,value in pairs(disablePowerSettings) do
			--TUPPMLog.Log("Before disablePowerSettings."..tostring(powerType).." is "..tostring(disablePowerSettings[powerType]))
			disablePowerSettings[powerType]=nil --enable powers for these missions
			--TUPPMLog.Log("After disablePowerSettings."..tostring(powerType).." is "..tostring(disablePowerSettings[powerType]))
		end
		--    disablePowerSettings.SHIELD=nil
		--    disablePowerSettings.MISSILE=nil
	end

	--  TUPPMLog.Log("CANNOT_USE_ALL_WEAPON_MISSION "..tostring(tppRevengeObj.CANNOT_USE_ALL_WEAPON_MISSION[missionId]))
	if this.CANNOT_USE_ALL_WEAPON_MISSION[missionId] then
		useAllWeapons=false
		--    TUPPMLog.Log("useAllWeapons set as false")
	end
	local restrictWeaponTable={}
	--  TUPPMLog.Log("useAllWeapons "..tostring(useAllWeapons))
	if not useAllWeapons then
		if not config.SHIELD or config.MISSILE then
			if not missionRequiresSettings.SHIELD then
				restrictWeaponTable.SHIELD=true
				disablePowerSettings.SHIELD=true
			end
		else
			if not missionRequiresSettings.MISSILE then
				restrictWeaponTable.MISSILE=true
				disablePowerSettings.MISSILE=true
			end
		end
		if defaultSoldierType~=EnemyType.TYPE_DD then
			if config.SHOTGUN then
				if not missionRequiresSettings.MG then
					restrictWeaponTable.MG=true
					disablePowerSettings.MG=true
				end
			else
				if not missionRequiresSettings.SHOTGUN then
					restrictWeaponTable.SHOTGUN=true
					disablePowerSettings.SHOTGUN=true
				end
			end
		end
	end

	for powerType,n in pairs(missionRequiresSettings)do
		restrictWeaponTable[powerType]=nil
		disablePowerSettings[powerType]=nil
	end

	do
		local basePowerTypes={HANDGUN=true,SMG=true,ASSAULT=true,SHOTGUN=true,MG=true,SHIELD=true}
		local baseWeaponIdTable=weaponIdTable.NORMAL
		if this.IsUsingStrongWeapon()and weaponIdTable.STRONG then
			baseWeaponIdTable=weaponIdTable.STRONG
		end
		if Tpp.IsTypeTable(baseWeaponIdTable)then
			for powerType,n in pairs(baseWeaponIdTable)do
				if not basePowerTypes[powerType] then
				elseif disablePowerSettings[powerType]then
				elseif restrictWeaponTable[powerType]then
				else
					loadWeaponIds[n]=true
					mvars.revenge_loadedEquip[powerType]=n
				end
			end
		end
	end

	if not disablePowerSettings.MISSILE and not restrictWeaponTable.MISSILE then
		local weaponTable={}
		if this.IsUsingStrongMissile()and weaponIdTable.STRONG then
			weaponTable=weaponIdTable.STRONG
		else
			weaponTable=weaponIdTable.NORMAL
		end
		local missile=weaponTable.MISSILE
		if missile then
			loadWeaponIds[missile]=true
			mvars.revenge_loadedEquip.MISSILE=missile
		end
	end

	if not disablePowerSettings.SNIPER and not restrictWeaponTable.SNIPER then
		local weaponTable={}
		if this.IsUsingStrongSniper()and weaponIdTable.STRONG then
			weaponTable=weaponIdTable.STRONG
		else
			weaponTable=weaponIdTable.NORMAL
		end
		local sniper=weaponTable.SNIPER
		if sniper then
			loadWeaponIds[sniper]=true
			mvars.revenge_loadedEquip.SNIPER=sniper
		end
	end

	do
		local e,n,E=TppEnemy.GetWeaponId(NULL_ID,{})
		TppSoldier2.SetDefaultSoldierWeapon{primary=e,secondary=n,tertiary=E}
	end

	local weaponsToLoad={}
	for n,E in pairs(loadWeaponIds)do
		table.insert(weaponsToLoad,n)
	end
	if missionId==10080 or missionId==11080 then
		table.insert(weaponsToLoad,TppEquip.EQP_WP_Wood_ar_010)
	end
	if TppEquip.RequestLoadToEquipMissionBlock then
		TppEquip.RequestLoadToEquipMissionBlock(weaponsToLoad)

		if not TppMission.IsFOBMission(vars.missionCode) then
			--r40 Weapons load here
			local equipLoadTable={}
			--r40 Weapon varieties
			local usableWeaponsTable=TppEnemy.PrepareUsableWeaponsTable()
			if usableWeaponsTable then
				for weaponType, weaponsInType in pairs(usableWeaponsTable) do
					for index, weaponId in pairs(weaponsInType)do
						table.insert(equipLoadTable,weaponId)
					end
				end
			end
			TppEquip.RequestLoadToEquipMissionBlock(equipLoadTable)
		end

	end
end

--K Outpost soldier distribution code
function this._GetSettingSoldierCount(powerType,soldiersAllowedForParticularPower,totalSoldierCount)
	local powersWithoutCountLimit={
		NO_KILL_WEAPON=true,
		STRONG_WEAPON=true,
		STRONG_PATROL=true,
		STRONG_NOTICE_TRANQ=true,
		STEALTH_SPECIAL=true,
		STEALTH_HIGH=true,
		STEALTH_LOW=true,
		COMBAT_SPECIAL=true,
		COMBAT_HIGH=true,
		COMBAT_LOW=true,
		FULTON_SPECIAL=true,
		FULTON_HIGH=true,
		FULTON_LOW=true,
		HOLDUP_SPECIAL=true,
		HOLDUP_HIGH=true,
		HOLDUP_LOW=true
	}

	if powersWithoutCountLimit[powerType]then
		return totalSoldierCount
	end

	local returnSolCount=0

	-- if t=="ARMOR" then
	-- --TppUiCommand.AnnounceLogView("ARMOR allowed by power setting "..tostring(n))
	-- end

	if Tpp.IsTypeNumber(soldiersAllowedForParticularPower)then
		returnSolCount=soldiersAllowedForParticularPower
	elseif Tpp.IsTypeString(soldiersAllowedForParticularPower)then
		if soldiersAllowedForParticularPower:sub(-1)=="%"then
			local n=soldiersAllowedForParticularPower:sub(1,-2)+0
			returnSolCount=math.ceil(totalSoldierCount*(n/100))
		end
	end

	if returnSolCount>totalSoldierCount then
		returnSolCount=totalSoldierCount
	end

	-- if t=="ARMOR" then
	-- --TppUiCommand.AnnounceLogView("ARMOR set "..tostring(e))
	-- end

	-- if t=="ARMOR" then --K sets every soldier on the map to fake ARMOR. In Afghanistan, only soldiers who get actual ARMOR appear at the guardpost South and South West of Wakh Sindh Barracks
	-- e=999 --Having more than 4 breaks the game's ARMOR mechanics
	-- end

	do
		local allowedArmorCount

		if vars.missionCode ~= 30010
			and vars.missionCode ~= 30020
		then
			allowedArmorCount={ARMOR=4} --K default, try changing and test. Although, setting this to 8 and above COMBAT value to 4 kept outposts soldiers vanilla i.e. number of ARMOR type soldiers did not increase from 4, having more than 4 breaks the game's ARMOR mechanics
		else
			allowedArmorCount={ARMOR=math.floor(math.min(math.max(TUPPMSettings.rev_freeMissionARMORCountPerOutpost or 0,0),4))} --r51 Settings --r15 ARMOR made available in Free roam
		end

		local possibleArmors=allowedArmorCount[powerType]
		if possibleArmors and returnSolCount>possibleArmors then
			returnSolCount=possibleArmors
			--      TUPPMLog.Log("Number of armored soldiers: "..tostring(e))
		end
	end

	-- if t=="ARMOR" then
	-- TppUiCommand.AnnounceLogView("Max ARMOR set "..tostring(e))
	-- end

	return returnSolCount
end

--r27
this.seedValue=0 --Initialize random seed as zero

--K Applying revenge params
function this._ApplyRevengeToCp(cpId,revengeConfig,plant)
	local soldierIDList=mvars.ene_soldierIDList[cpId]
	local soldierIdsForConfigIdTable={}
	local totalSoldierCount=0

	if TppLocation.IsMotherBase()or TppLocation.IsMBQF()then
		local r=0
		local cpName=mvars.ene_cpList[cpId]
		if(mtbs_enemy and mtbs_enemy.cpNameToClsterIdList~=nil)and mvars.mbSoldier_enableSoldierLocatorList~=nil then
			local clusterIdList=mtbs_enemy.cpNameToClsterIdList[cpName]

			if clusterIdList then
				soldierIDList={}
				local soldierLocatorsList=mvars.mbSoldier_enableSoldierLocatorList[clusterIdList]

				for n,soldierName in ipairs(soldierLocatorsList)do
					local soldierPlant=tonumber(string.sub(soldierName,-6,-6))

					if soldierPlant~=nil and soldierPlant==plant then
						local soldierID=GameObject.GetGameObjectId("TppSoldier2",soldierName)
						soldierIDList[soldierID]=r
					end
				end
			end
		end
	end

	if soldierIDList==nil then
		return
	end

	local missionPowerSoldiers={}

	for soldierName,missionPowerSetting in pairs(mvars.ene_missionSoldierPowerSettings)do
		local soldierId=GetGameObjectId("TppSoldier2",soldierName)
		missionPowerSoldiers[soldierId]=missionPowerSetting
	end

	local missionAbilitySoldiers={}

	for soldierName,missionAbilitySetting in pairs(mvars.ene_missionSoldierPersonalAbilitySettings)do
		local soldierId=GetGameObjectId("TppSoldier2",soldierName)
		missionAbilitySoldiers[soldierId]=missionAbilitySetting
	end

	local outerBaseCpList=mvars.ene_outerBaseCpList[cpId]
	local specialSoldiersTable={}
	local outerBaseSoldiersTable={}
	local onlyGuardposts={} --r09
	local onlyPatrols={} --r10

	for soldierId,E in pairs(soldierIDList)do
		table.insert(soldierIdsForConfigIdTable,soldierId)
		totalSoldierCount=totalSoldierCount+1

		if missionPowerSoldiers[soldierId]then
			specialSoldiersTable[totalSoldierCount]=true
		elseif mvars.ene_eliminateTargetList[soldierId]then
			specialSoldiersTable[totalSoldierCount]=true
		elseif TppEnemy.GetSoldierType(soldierId)==EnemyType.TYPE_CHILD then
			specialSoldiersTable[totalSoldierCount]=true
		elseif outerBaseCpList then
			outerBaseSoldiersTable[totalSoldierCount]=true
			onlyGuardposts[totalSoldierCount]=true
		elseif mvars.ene_lrrpTravelPlan[cpId]then
			outerBaseSoldiersTable[totalSoldierCount]=true
			onlyPatrols[totalSoldierCount]=true
		end
	end

	local cpConfig={}

	for soldierToConfig=1,totalSoldierCount do
		if outerBaseCpList then
			cpConfig[soldierToConfig]={OB=true}
		else
			cpConfig[soldierToConfig]={}
		end
	end

	local powerComboExclusionList={
		ARMOR={"SOFT_ARMOR","HELMET","GAS_MASK","NVG","SNIPER","SHIELD","MISSILE"},
		SOFT_ARMOR={"ARMOR"},
		SNIPER={"SHOTGUN","MG","MISSILE","GUN_LIGHT","ARMOR","SHIELD","SMG"},
		SHOTGUN={"SNIPER","MG","MISSILE","SHIELD","SMG"},
		MG={"SNIPER","SHOTGUN","MISSILE","GUN_LIGHT","SHIELD","SMG"},
		SMG={"SNIPER","SHOTGUN","MG"},
		MISSILE={"ARMOR","SHIELD","SNIPER","SHOTGUN","MG"},
		SHIELD={"ARMOR","SNIPER","MISSILE","SHOTGUN","MG"},
		HELMET={"ARMOR","GAS_MASK","NVG"},
		GAS_MASK={"ARMOR","HELMET","NVG"},
		NVG={"ARMOR","HELMET","GAS_MASK"},
		GUN_LIGHT={"SNIPER","MG"}
	}
	
	--r51 Settings
	if TUPPMSettings.rev_ENABLE_weaponCombos then
	--If only thisis switched on, it allows Gas masks/NVGs/Helmets combos
	
	--TODO --rX51 All three combo is not enabled here, maybe add in the future
	
	powerComboExclusionList={
			ARMOR={"SOFT_ARMOR","HELMET","GAS_MASK","NVG","SNIPER","SHIELD", --K stop excluding ARMOR and SHIELD combos
				"MISSILE"},
			SOFT_ARMOR={"ARMOR"},
			SNIPER={"SHOTGUN","MG","MISSILE","GUN_LIGHT","ARMOR","SHIELD","SMG"},
			SHOTGUN={"SNIPER","MG","MISSILE","SHIELD", --K use SHOTGUN and SHIELD
				"SMG"},
			MG={"SNIPER","SHOTGUN","MISSILE","GUN_LIGHT","SHIELD","SMG"},
			SMG={"SNIPER","SHOTGUN","MG"},
			MISSILE={"ARMOR","SHIELD","SNIPER","SHOTGUN","MG"},
			SHIELD={"ARMOR","SNIPER","MISSILE","SHOTGUN", --K use SHOTGUN and SHIELD
				"MG"},
			HELMET={"ARMOR"}, --r10 Use Gas masks/NVG with Helmets
			GAS_MASK={"ARMOR","NVG"}, --r10
			NVG={"ARMOR","GAS_MASK"}, --r10
			GUN_LIGHT={"SNIPER","MG"}
		}
	end

	local abilitiesList={
		STEALTH_LOW=true,
		STEALTH_HIGH=true,
		STEALTH_SPECIAL=true,
		COMBAT_LOW=true,
		COMBAT_HIGH=true,
		COMBAT_SPECIAL=true,
		HOLDUP_LOW=true,
		HOLDUP_HIGH=true,
		HOLDUP_SPECIAL=true,
		FULTON_LOW=true,
		FULTON_HIGH=true,
		FULTON_SPECIAL=true
	}

	for index,powerType in ipairs(TppEnemy.POWER_SETTING)do
		local soldiersAllowedCountOrPercentage=revengeConfig[powerType]

		if soldiersAllowedCountOrPercentage then
			local soldierCountForCurrentPower=this._GetSettingSoldierCount(powerType,soldiersAllowedCountOrPercentage,totalSoldierCount) --K added 32 extra soldiers to r! :D XD
			-- +32 not possible here
			-- +2 not possible here
			local excludedPowersForCurrentType=powerComboExclusionList[powerType]or{}
			local soldierCountForCurrentPower=soldierCountForCurrentPower --K added 32 extra soldiers to r! :D XD
			-- +32 not possible here
			-- +2 not possible here

			for soldierToConfig=1,totalSoldierCount do

				--K identify guardpost and patrol CPs
				-- local guardPostOrPatrolCP = false
				-- if _[n] then
				-- guardPostOrPatrolCP = true
				-- else
				-- guardPostOrPatrolCP = false
				-- end

				local isSpecialSol=specialSoldiersTable[soldierToConfig]
				--r51 Settings
				local notAnAbilityAndIsOuterBase=(not abilitiesList[powerType]) and (outerBaseSoldiersTable[soldierToConfig] and not (TUPPMSettings.rev_ENABLE_customModRevengeProfile and TUPPMSettings.rev_ENABLE_powersForLRRPAndGuardposts))

				if
					(not isSpecialSol
					and not notAnAbilityAndIsOuterBase --K Comment this line to apply Enemy prep to all soldiers(but at a game messing up price)! Thanks to tinmantex for locating this! :D :) --Have created custom enemy prep call below for guardposts/patrols
					--rX43 TODO better balance for LRRPs
					)
					and soldierCountForCurrentPower>0
				then
					local wantToConfigurePower=true

					if cpConfig[soldierToConfig][powerType]then
						soldierCountForCurrentPower=soldierCountForCurrentPower-1
						wantToConfigurePower=false
					end

					if wantToConfigurePower then
						for index,excludeThisPower in ipairs(excludedPowersForCurrentType)do
							if cpConfig[soldierToConfig][excludeThisPower]then
								wantToConfigurePower=false
							end
						end
					end

					if wantToConfigurePower then
						soldierCountForCurrentPower=soldierCountForCurrentPower-1
						cpConfig[soldierToConfig][powerType]=true

						--K was trying to avoid ARMOR from being added to guardposts/patrols, when they are allowed POWER_SETTINGS; this approach does work although I have devised a better alternative below; this code can be removed, kept only for reference
						-- if guardPostOrPatrolCP and E=="ARMOR" then
						-- --K do nothing, do not add ARMOR to guardposts/patrols otherwise game breaking ARMOR mechanics
						-- TppUiCommand.AnnounceLogView("CP is guardpost/partol, not adding armor")
						-- else
						-- t[n][E]=true
						-- end

						if powerType=="MISSILE"and this.IsUsingStrongMissile()then
							cpConfig[soldierToConfig].STRONG_MISSILE=true
						end

						if powerType=="SNIPER"and this.IsUsingStrongSniper()then
							cpConfig[soldierToConfig].STRONG_SNIPER=true
						end
					end
				end
			end
		end
	end

	--  TUPPMLog.Log("rev_revengeRandomValue: "..tostring(gvars.rev_revengeRandomValue))
	--  if vars.missionCode ~= 30050 then --r13 --why exclude mother base? I think weapons were being randomized with the soldiers
	--    math.randomseed(gvars.rev_revengeRandomValue) --r11
	--    math.random()math.random()math.random()
	--  end

	--      TUPPMLog.Log("gvars.rev_revengeRandomValue: "..tostring(gvars.rev_revengeRandomValue))
	--r27 Assign different random seed to each soldier
	if this.seedValue <= 0 --only reset seed if it is 0(or less but that won't happen)
		and not TppMission.IsMbFreeMissions(vars.missionCode) --r46 MB+MBQF --let seed be on MB be different
	--      or gvars.sav_varRestoreForContinue --nope will be true for all soldiers
	then
		--      TUPPMLog.Log("Reset mission seedValue")
		this.seedValue=gvars.rev_revengeRandomValue
		TppMain.Randomize()
	elseif this.seedValue <= 0 and TppMission.IsMbFreeMissions(vars.missionCode) then --r46 MB+MBQF
		--          TUPPMLog.Log("Reset Motherbase seedValue")
		--WORKING! :D --Resets seed on MB - each soldier gets unique seed just like free raom/missions
		-- MB resets soldiers on reloading checkpoints/restarts anyway so this works better
		--r43 Seed at MB is truly random using below, on 0-2147483647 we get a negative number for some reason
		-- also added above <=0 condition
		this.seedValue=math.random(2147483647)
		--    TUPPMLog.Log("NEW* MB seedValue: "..tostring(this.seedValue))
		TppMain.Randomize()
		--          this.seedValue=os.time() --TODO Test this too
	end

	--  math.randomseed(this.seedValue)

	--  if vars.missionCode~=30050 then
	--    TUPPMLog.Log("Not MB seedValue: "..tostring(this.seedValue))
	--    math.randomseed(this.seedValue)
	--    this.seedValue=this.seedValue*2 --change seed for next soldier
	--  end

	--r43 Wild randomization at MB
	--  if vars.missionCode==30050 then
	--    this.seedValue=this.seedValue*2
	--    TppMain.Randomize()
	--  else
	--    this.seedValue=this.seedValue*2 --change seed for next soldier
	--  end
	--  TUPPMLog.Log("seedValue: "..tostring(this.seedValue))

	--  TUPPMLog.Log("USING seedValue: "..tostring(this.seedValue))

	math.randomseed(this.seedValue)
	this.seedValue=this.seedValue*2 --change seed for next CP
	TppMain.Randomize()

	for solIdIndex,powerSettingsTable in ipairs(cpConfig)do
		local soldierID=soldierIdsForConfigIdTable[solIdIndex]

		--r43 Moved custom revenge config to own function for better maintainance
		this.ApplyCustomRevengeConfig(soldierID, solIdIndex, powerSettingsTable, outerBaseSoldiersTable, onlyGuardposts, onlyPatrols)

		TppEnemy.ApplyPowerSetting(soldierID,powerSettingsTable)

		if missionAbilitySoldiers[soldierID]==nil then
			local finalDecidedAbilities={}do
				local stealthPicked

				if powerSettingsTable.STEALTH_SPECIAL then
					stealthPicked="sp"
				elseif powerSettingsTable.STEALTH_HIGH then
					stealthPicked="high"
				elseif powerSettingsTable.STEALTH_LOW then
					stealthPicked="low"
				end
				finalDecidedAbilities.notice=stealthPicked
				finalDecidedAbilities.cure=stealthPicked
				finalDecidedAbilities.reflex=stealthPicked
			end

			do
				local combatPicked
				if powerSettingsTable.COMBAT_SPECIAL then
					combatPicked="sp"
				elseif powerSettingsTable.COMBAT_HIGH then
					combatPicked="high"
				elseif powerSettingsTable.COMBAT_LOW then
					combatPicked="low"
				end
				finalDecidedAbilities.shot=combatPicked
				finalDecidedAbilities.grenade=combatPicked
				finalDecidedAbilities.reload=combatPicked
				finalDecidedAbilities.hp=combatPicked
			end

			do
				local speedPicked
				if powerSettingsTable.STEALTH_SPECIAL or powerSettingsTable.COMBAT_SPECIAL then
					speedPicked="sp"
				elseif powerSettingsTable.STEALTH_HIGH or powerSettingsTable.COMBAT_HIGH then
					speedPicked="high"
				elseif powerSettingsTable.STEALTH_LOW or powerSettingsTable.COMBAT_LOW then
					speedPicked="low"
				end
				finalDecidedAbilities.speed=speedPicked
			end

			do
				local fultonPicked
				if powerSettingsTable.FULTON_SPECIAL then
					fultonPicked="sp"
				elseif powerSettingsTable.FULTON_HIGH then
					fultonPicked="high"
				elseif powerSettingsTable.FULTON_LOW then
					fultonPicked="low"
				end
				finalDecidedAbilities.fulton=fultonPicked
			end

			do
				local holdupPicked
				if powerSettingsTable.HOLDUP_SPECIAL then
					holdupPicked="sp"
				elseif powerSettingsTable.HOLDUP_HIGH then
					holdupPicked="high"
				elseif powerSettingsTable.HOLDUP_LOW then
					holdupPicked="low"
				end
				finalDecidedAbilities.holdup=holdupPicked
			end

			--r43 Max out all abilities
			this.ApplyCustomAbilitiesConfig(finalDecidedAbilities)

			TppEnemy.ApplyPersonalAbilitySettings(soldierID,finalDecidedAbilities)
		end
	end
	math.randomseed(os.time()) --r11
end

function this.Messages()
	return Tpp.StrCode32Table{
		GameObject={
			{msg="HeadShot",
				func=this._OnHeadShot},
			{msg="Dead",
				func=this._OnDead},
			{msg="Unconscious",
				func=this._OnUnconscious},
			{msg="ComradeFultonDiscovered",
				func=this._OnComradeFultonDiscovered},
			{msg="CommandPostAnnihilated",
				func=this._OnAnnihilated},
			{msg="ChangePhase",
				func=this._OnChangePhase},
			{msg="Damage",
				func=this._OnDamage},
			{msg="AntiSniperNoticed",
				func=this._OnAntiSniperNoticed},
			{msg="SleepingComradeRecoverd",
				func=this._OnSleepingComradeRecoverd},
			{msg="SmokeDiscovered",
				func=this._OnSmokeDiscovered},
			{msg="ReinforceRespawn",
				func=this._OnReinforceRespawn}
		},
		Trap={
			{msg="Enter",
				func=this._OnEnterTrap}
		}
	}
end
function this.Init(n)
	this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
end
function this.OnReload(n)this.messageExecTable=Tpp.MakeMessageExecTable(this.Messages())
end
function this.OnMessage(r,E,n,t,a,o,_)
	Tpp.DoMessage(this.messageExecTable,TppMission.CheckMessageOption,r,E,n,t,a,o,_)
end
local damageTypeFunc=function(e)
	--rX50 Original game bugfix but does not do anything as the function is called incorrectly
	if(((((((((((((e==TppDamage.ATK_VehicleHit or e==TppDamage.ATK_Tankgun_20mmAutoCannon)or e==TppDamage.ATK_Tankgun_30mmAutoCannon)or e==TppDamage.ATK_Tankgun_105mmRifledBoreGun)or e==TppDamage.ATK_Tankgun_120mmSmoothBoreGun)or e==TppDamage.ATK_Tankgun_125mmSmoothBoreGun)or e==TppDamage.ATK_Tankgun_82mmRocketPoweredProjectile)or e==TppDamage.ATK_Tankgun_30mmAutoCannon)or e==TppDamage.ATK_Wav1)or e==TppDamage.ATK_WavCannon)or e==TppDamage.ATK_TankCannon)or e==TppDamage.ATK_WavRocket)or e==TppDamage.ATK_HeliMiniGun)or e==TppDamage.ATK_HeliChainGun)or attackid==TppDamage.ATK_WalkerGear_BodyAttack then
		return true
	end
	return false
end
function this._OnReinforceRespawn(n)
	if TppMission.IsFOBMission(vars.missionCode)then
		TppEnemy.AddPowerSetting(n,{})
		o50050_enemy.AssignAndSetupRespawnSoldier(n)
	else
		this.ApplyPowerSettingsForReinforce{n}
		--r51 Settings
		if TUPPMSettings.game_ENABLE_autoMarking then
			--r28 This is needed to mark non first reinforcements correctly
			TppMain.AutoMarkReinforcements(n)
		end

		--  TUPPMLog.Log("_OnReinforceRespawn completed")
	end
end
function this._OnHeadShot(E,t,t,n)
	if GetTypeIndex(E)~=TppGameObject.GAME_OBJECT_TYPE_SOLDIER2 then
		return
	end
	if bit.band(n,HeadshotMessageFlag.IS_JUST_UNCONSCIOUS)==0 then
		return
	end
	this.AddRevengePointByTriggerType(this.REVENGE_TRIGGER_TYPE.HEAD_SHOT)
end
local E=function(n)
	if n==nil then
		n=vars.playerPhase
	end
	if n~=TppGameObject.PHASE_SNEAK or vars.playerPhase~=TppGameObject.PHASE_SNEAK then
		this.AddRevengePointByTriggerType(this.REVENGE_TRIGGER_TYPE.ELIMINATED_IN_COMBAT)
	else
		this.AddRevengePointByTriggerType(this.REVENGE_TRIGGER_TYPE.ELIMINATED_IN_STEALTH)
	end
	if TppClock.GetTimeOfDay()=="night"then
		this.AddRevengePointByTriggerType(this.REVENGE_TRIGGER_TYPE.ELIMINATED_AT_NIGHT)
	end
end
function this._OnDead(t,n,i)
	if GetTypeIndex(t)~=TppGameObject.GAME_OBJECT_TYPE_SOLDIER2 then
		return
	end
	local o=(Tpp.IsVehicle(vars.playerVehicleGameObjectId)or Tpp.IsEnemyWalkerGear(vars.playerVehicleGameObjectId))or Tpp.IsPlayerWalkerGear(vars.playerVehicleGameObjectId)
	local _=damageTypeFunc(attackId) --rX50 Called incorrectly, attackId is global
	local r=Tpp.IsEnemyWalkerGear(n)or Tpp.IsPlayerWalkerGear(n)
	local t=(n==GameObject.GetGameObjectIdByIndex("TppPlayer2",PlayerInfo.GetLocalPlayerIndex()))
	if(r or _)or(t and o)then
		this.AddRevengePointByTriggerType(this.REVENGE_TRIGGER_TYPE.KILLED_BY_VEHICLE)
	end
	E(i)
	if GetTypeIndex(n)==TppGameObject.GAME_OBJECT_TYPE_HELI2 then
		this.AddRevengePointByTriggerType(this.REVENGE_TRIGGER_TYPE.KILLED_BY_HELI)
	end
end
function this._OnUnconscious(e,t,n)
	if GetTypeIndex(e)~=TppGameObject.GAME_OBJECT_TYPE_SOLDIER2 then
		return
	end
	local e=GameObject.SendCommand(e,{id="GetLifeStatus"})
	if e==TppGameObject.NPC_LIFE_STATE_DYING or e==TppGameObject.NPC_LIFE_STATE_DEAD then
		return
	end
	E(n)
end
function this._OnAnnihilated(E,n,t)
	if t==0 then
		if TppEnemy.IsBaseCp(E)or TppEnemy.IsOuterBaseCp(E)then
			if n==nil then
				n=vars.playerPhase
			end
			if n~=TppGameObject.PHASE_SNEAK or vars.playerPhase~=TppGameObject.PHASE_SNEAK then
				this.AddRevengePointByTriggerType(this.REVENGE_TRIGGER_TYPE.ANNIHILATED_IN_COMBAT)
			else
				this.AddRevengePointByTriggerType(this.REVENGE_TRIGGER_TYPE.ANNIHILATED_IN_STEALTH)
			end
		end
	end
end

----rX5 trying to add an alert timer lol
--this.timerStart = function ()
--	TppUI.StartDisplayTimer{
--		svarsName = "displayTimeSec",
--		cautionTimeSec = TIME_LIMIT.CAUTION_TIME_SEC,
--	}
--	TppUiCommand.SetDisplayTimerText( "timeCount_10054_00" )
--end

--r24 Alert flag
this.hasAlertBeenTriggered=false
function this._OnChangePhase(E,n)

	if n~=TppGameObject.PHASE_ALERT then

		--r51 Settings
		if TUPPMSettings.game_ENABLE_fastHeliPulloutDuringFreeRoamAlert then
			--r24 Get local var phase number
			local phaseNumber = tostring(n)
			--  TUPPMLog.Log("Phase: "..phaseNumber)

			--r24 If alert is triggered then set heli take off time to 0 seconds
			if phaseNumber=="0" and this.hasAlertBeenTriggered then
				--        TUPPMLog.Log("Alert has passed so Default take off time")
				this.hasAlertBeenTriggered=false
				TppHelicopter.SetDefaultTakeOffTime() --Deafult take off take otherwise
			end
		end

		return
	end

	--r51 Settings
	if TUPPMSettings.game_ENABLE_fastHeliPulloutDuringFreeRoamAlert then
		--r24 Get local var phase number
		local phaseNumber = tostring(n)
		--  TUPPMLog.Log("Phase: "..phaseNumber)

		--r24 If alert is triggered then set heli take off time to 0 seconds
		if phaseNumber=="3" and (vars.missionCode == 30010 or vars.missionCode == 30020) then
			--    TUPPMLog.Log("Is alert so pulling out instantly")
			this.hasAlertBeenTriggered=true
			TppHelicopter.SetNoTakeOffTime() --set take off time to 0 seconds on combat alert
			--    TppHelicopter.ForcePullOut() --rX3 pulls out instantly without you! :D
		end

		--rX3 WIP Alert/Evasion timer?
		--  TppUiStatusManager.SetStatus("DisplayTimer", "NO_TIMECOUNT_SUB")
		--  TppUI.StartDisplayTimer{
		--      svarsName = "timeLimitforVisiting",
		--      cautionTimeSec = 59,
		--    }
		--  TppUiCommand.SetDisplayTimerText( "timeCount_50050_50" )
		--
		--  TUPPMLog.Log("Timer printed")

		--  if phaseNumber=="3" then
		--      TppUI.StartDisplayTimer{
		--      svarsName = "displayTimeSec",
		--      cautionTimeSec = 60,
		--    }
		--    TppUiCommand.SetDisplayTimerText( "timeCount_10054_00" )
		--  elseif phaseNumber=="2" then
		--      TppUI.StartDisplayTimer{
		--      svarsName = "displayTimeSec",
		--      cautionTimeSec = 60,
		--    }
		--    TppUiCommand.SetDisplayTimerText( "timeCount_10054_00" )
		--  else
		--    TppUiCommand.EraseDisplayTimer()
		--  end
	end


	if TppClock.GetTimeOfDay()=="night"then
		this.AddRevengePointByTriggerType(this.REVENGE_TRIGGER_TYPE.DISCOVERY_AT_NIGHT)
	end
end

function this._OnComradeFultonDiscovered(n,n)this.AddRevengePointByTriggerType(this.REVENGE_TRIGGER_TYPE.FULTON)
end
local n=function(e)
	if((((((((((((e==TppDamage.ATK_Smoke or e==TppDamage.ATK_SmokeOccurred)or e==TppDamage.ATK_SleepGus)or e==TppDamage.ATK_SleepGusOccurred)or e==TppDamage.ATK_SupportHeliFlareGrenade)or e==TppDamage.ATK_SupplyFlareGrenade)or e==TppDamage.ATK_SleepingGusGrenade)or e==TppDamage.ATK_SleepingGusGrenade_G1)or e==TppDamage.ATK_SleepingGusGrenade_G2)or e==TppDamage.ATK_SmokeAssist)or e==TppDamage.ATK_SleepGusAssist)or e==TppDamage.ATK_Grenader_Smoke)or e==TppDamage.ATK_Grenader_Sleep)or e==TppDamage.ATK_SmokeGrenade then
		return true
	end
	return false
end
function this._OnDamage(t,E,r)
	if GetTypeIndex(t)~=TppGameObject.GAME_OBJECT_TYPE_SOLDIER2 then
		return
	end
	if n(E)then
		this.AddRevengePointByTriggerType(this.REVENGE_TRIGGER_TYPE.SMOKE)
	end
end
function this._OnSmokeDiscovered(n)this.AddRevengePointByTriggerType(this.REVENGE_TRIGGER_TYPE.WATCH_SMOKE)
end
function this._OnAntiSniperNoticed(n)this.AddRevengePointByTriggerType(this.REVENGE_TRIGGER_TYPE.SNIPED)
end
function this._OnSleepingComradeRecoverd(n)this.AddRevengePointByTriggerType(this.REVENGE_TRIGGER_TYPE.WAKE_A_COMRADE)
end
function this._OnEnterTrap(n)this.OnEnterRevengeMineTrap(n)
end

--rX43 Max revenge points for each revenge - this is different than maxing revenge levels
--r59 Integrated into main mod
function this.MaxOutRevengePoints()
	if not TUPPMSettings.rev_ENABLE_maxOutRevengePoints then return end
	
	for revengeTypeCode=0,this.REVENGE_TYPE.MAX-1 do
		TUPPMLog.Log("BEFORE Revenge: "..tostring(this.REVENGE_TYPE_NAME[revengeTypeCode+1])..", points set to: "..tostring(gvars.rev_revengePoint[revengeTypeCode])..", level: "..tostring(this.GetRevengeLv(revengeTypeCode)),3)
		this.SetRevengePoint(revengeTypeCode,9999)
		TUPPMLog.Log("AFTER Revenge: "..tostring(this.REVENGE_TYPE_NAME[revengeTypeCode+1])..", points set to: "..tostring(gvars.rev_revengePoint[revengeTypeCode])..", level: "..tostring(this.GetRevengeLv(revengeTypeCode)),3)
	end
	this.UpdateRevengeLv()
end

--r59 Reset revenge points to 0
function this.MinOutRevengePoints()
	if not TUPPMSettings.rev_ENABLE_minOutRevengePoints then return end
	
	for revengeTypeCode=0,this.REVENGE_TYPE.MAX-1 do
		TUPPMLog.Log("BEFORE Revenge: "..tostring(this.REVENGE_TYPE_NAME[revengeTypeCode+1])..", points set to: "..tostring(gvars.rev_revengePoint[revengeTypeCode])..", level: "..tostring(this.GetRevengeLv(revengeTypeCode)),3)
		this.SetRevengePoint(revengeTypeCode,0)
		TUPPMLog.Log("AFTER Revenge: "..tostring(this.REVENGE_TYPE_NAME[revengeTypeCode+1])..", points set to: "..tostring(gvars.rev_revengePoint[revengeTypeCode])..", level: "..tostring(this.GetRevengeLv(revengeTypeCode)),3)
	end
	this.UpdateRevengeLv()
end

--r43 Added function for custom abilities handling
function this.ApplyCustomAbilitiesConfig(finalDecidedAbilities)
	--r51 Settings
	if not TUPPMSettings.rev_ENABLE_customModAbilitiesProfile then return end

	if TppMission.IsFOBMission(vars.missionCode) then return end

	--r43 Max out abilities
	local special="sp"
	finalDecidedAbilities.notice=special
	finalDecidedAbilities.cure=special
	finalDecidedAbilities.reflex=special
	finalDecidedAbilities.shot=special
	finalDecidedAbilities.grenade=special
	finalDecidedAbilities.reload=special
	finalDecidedAbilities.hp=special
	finalDecidedAbilities.speed=special

	--r48 Fulton revenge is always maxed so instead of having enemies always shoot down fultons, added some controlled randomization to soldier alertness for fultons
	if math.random()<0.1 then
		finalDecidedAbilities.fulton=nil
	elseif math.random()<0.3 then
		finalDecidedAbilities.fulton="low"
	elseif math.random()<0.7 then
		finalDecidedAbilities.fulton="high"
	else
		finalDecidedAbilities.fulton=special
	end

	--Do not max out hold up, leads to all kinds of trouble - every enemy soldier refuses to be held up
	--      finalDecidedAbilities.holdup=special
end

--r43 Added function for custom revenge power handling
function this.ApplyCustomRevengeConfig(soldierID, solIdIndex, powerSettingsTable, outerBaseSoldiersTable, onlyGuardposts, onlyPatrols)
	--r51 Settings
	if not TUPPMSettings.rev_ENABLE_customModRevengeProfile then return end

	--r41 BUGFIX Exclude bloody FOBs
	if TppMission.IsFOBMission(vars.missionCode) then return end

	--K r09 For Outposts(r09)/Guardposts/Patrols do this logic

	--r09 Exclude these missions from Revenge - to avoid invisible helmet problem(in below mentioned Missions)
	if vars.missionCode ~= 50050 --FOBs
		and vars.missionCode ~= 10030 --Mission 2 Diamond Dogs
		and vars.missionCode ~= 10115 --Mission 22 - Retake the Platform
		and vars.missionCode ~= 10240 --Mission 43 Shining Lights
	--and vars.missionCode ~= 30050 --MB --r12 No Helmets for MB
	--START randomization for all
	then

		--r13
		--r46 exclude MB+MBQF
		if not TppMission.IsMbFreeMissions(vars.missionCode) then
			--r13 introducing revenge blocking based on dispatch missions
			table.insert(powerSettingsTable,"STRONG_WEAPON")


			if
				vars.missionCode ~= 30010
				and vars.missionCode ~= 30020
				and (this.IsIgnoreBlocked()
				or not this.IsBlocked(this.BLOCKED_TYPE.HELMET))
			then
				--r48 Let base game decide Helmets for Outposts - handle Guardposts/LRRPs here
				if (outerBaseSoldiersTable[solIdIndex]) and not powerSettingsTable.HELMET then
					--Feels like less than 50%
					if math.random()<0.5 then
						table.insert(powerSettingsTable,"HELMET")
					end
				end
			end
		end

		--      if vars.missionCode == 30050 then --r13
		--          table.insert(e,"SOFT_ARMOR")
		--      end

		--r10 Randomize headgear for Patrols/Guardposts
		--START Patrol/Guardposts randomization
		if outerBaseSoldiersTable[solIdIndex] then
			--r10 Get CP type and subtype
			local cpType=TppEnemy.GetSoldierType(soldierID)
			local cpSubType=TppEnemy.GetSoldierSubType(soldierID,cpType)
			--TUPPMLog.Log("cpSubType="..tostring(cpSubType))

			--TUPPMLog.Log("For soldier: "..tostring(soldierID))
			--        for a,b in pairs(powerSettingsTable) do
			--        TUPPMLog.Log("a: "..tostring(a)..", b: "..tostring(b))
			--        end

			powerSettingsTable.ARMOR=nil --do not armor Patrols/Guardposts

			--r10
			if onlyGuardposts[solIdIndex] then
				if
					this.IsIgnoreBlocked()
					or not this.IsBlocked(this.BLOCKED_TYPE.SOFT_ARMOR)
				then
					table.insert(powerSettingsTable,"SOFT_ARMOR")
				end
			end

			if onlyPatrols[solIdIndex] --r15
				and (cpSubType=="SOVIET_A" or cpSubType=="SOVIET_B") --Exclude soviet LRRPs to avoid missing radio problem
			then
				--TUPPMLog.Log("Disabling soft armor for Soviet A and B")
				powerSettingsTable.SOFT_ARMOR=nil
			end

			if onlyPatrols[solIdIndex] --r10
				and (cpSubType~="SOVIET_A" and cpSubType~="SOVIET_B") --Exclude soviet LRRPs to avoid missing radio problem
			then
				if this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.SOFT_ARMOR)
				then
					table.insert(powerSettingsTable,"SOFT_ARMOR")
				end
			end

		end --END Patrol/Guardposts randomization

		--r13
		--r46 exclude MB+MBQF
		if not TppMission.IsMbFreeMissions(vars.missionCode) then
			local randomVariable = math.random()
			--r48 Adjusted random values
			if randomVariable<=0.89 then
				--r10 do nothing
				TppMain.Randomize()
				--r48 5% chance
			elseif randomVariable<=0.94 then
				if not powerSettingsTable.NVG
					and not powerSettingsTable.ARMOR
					and (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.GAS_MASK))
				then
					table.insert(powerSettingsTable,"GAS_MASK")
					powerSettingsTable.NVG=nil
					TppMain.Randomize()
				end
				--r48 5% chance
			elseif randomVariable<=0.99 then
				if not powerSettingsTable.GAS_MASK
					and not powerSettingsTable.ARMOR
					and (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.NVG))
				then
					table.insert(powerSettingsTable,"NVG")
					powerSettingsTable.GAS_MASK=nil
					TppMain.Randomize()
				end
				--r48 1% chance
			elseif randomVariable<=1 then
				if not powerSettingsTable.ARMOR
					and (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.NVG))
					and (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.GAS_MASK))
				then
					table.insert(powerSettingsTable,"NVG")
					table.insert(powerSettingsTable,"GAS_MASK")
					TppMain.Randomize()
				end
			end
		end

		--rX48 GUN_LIGHT is really the light on the gun and not the flashlight - I think all soldiers already have flashlights
		--			if powerSettingsTable.NVG then
		--				TUPPMLog.Log("ApplyCustomRevengeConfig removing GUN_LIGHT for soldierId:"..tostring(soldierID),3)
		--				powerSettingsTable.GUN_LIGHT=nil
		--			end

		--      powerSettingsTable.MG=nil
		--      powerSettingsTable.SHOTGUN=nil
		--      powerSettingsTable.SHIELD=nil
		--      powerSettingsTable.SNIPER=nil
		--      powerSettingsTable.MISSILE=nil
		--      --r17 try
		--      table.insert(powerSettingsTable,"GRENADE")
		--      table.insert(powerSettingsTable,"STUN_GRENADE")
		--      table.insert(powerSettingsTable,"SMOKE_GRENADE")
		--      table.insert(powerSettingsTable,"GRENADE_LAUNCHER")

		--r13 Algo for limiting proliferation of powers when blocked by dispatch missions
		--r24 Adjusted weapon random chances
		--r27 Adjusted weapon random chances again
		--r41 Adjusted weapon random chances
		local chanceASSAULT = 0.30  --30% chance
		local chanceMG = 0.52       --22% chance
		local chanceSHOTGUN = 0.74  --22% chance
		local chanceSHIELD = 0.90   --16% chance
		local chanceSNIPER = 0.95   --05% chance
		local chanceMISSILE = 1     --05% chance

		if not (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.MG)) then
			chanceMG = 0
			chanceASSAULT = chanceASSAULT + 0.22
		end

		if not (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.SHOTGUN)) then
			chanceSHOTGUN = 0
			chanceASSAULT = chanceASSAULT + 0.22
		end

		if not (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.SHIELD)) then
			chanceSHIELD = 0
			chanceASSAULT = chanceASSAULT + 0.16
		end

		if not (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.SNIPER)) then
			chanceSNIPER = 0
			chanceASSAULT = chanceASSAULT + 0.05
		end

		if not (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.MISSILE)) then
			chanceMISSILE = 0
			chanceASSAULT = chanceASSAULT + 0.05
		end

		if chanceMISSILE == 0 then
			if chanceSNIPER~=0 then
				chanceSNIPER=chanceSNIPER+0.05
			end
			if chanceSHIELD~=0 then
				chanceSHIELD=chanceSHIELD+0.05
			end
			if chanceSHOTGUN~=0 then
				chanceSHOTGUN=chanceSHOTGUN+0.05
			end
			if chanceMG~=0 then
				chanceMG=chanceMG+0.05
			end
		end

		if chanceSNIPER == 0 then
			if chanceSHIELD~=0 then
				chanceSHIELD=chanceSHIELD+0.05
			end
			if chanceSHOTGUN~=0 then
				chanceSHOTGUN=chanceSHOTGUN+0.05
			end
			if chanceMG~=0 then
				chanceMG=chanceMG+0.05
			end
		end

		if chanceSHIELD == 0 then
			if chanceSHOTGUN~=0 then
				chanceSHOTGUN=chanceSHOTGUN+0.16
			end
			if chanceMG~=0 then
				chanceMG=chanceMG+0.16
			end
		end

		if chanceSHOTGUN == 0 then
			if chanceMG~=0 then
				chanceMG=chanceMG+0.22
			end
		end

		--    TUPPMLog.Log("chanceASSAULT: "..chanceASSAULT..", chanceMG: "..chanceMG..", chanceSHOTGUN: "..chanceSHOTGUN..", chanceSHIELD: "..chanceSHIELD..", chanceSNIPER: "..chanceSNIPER..", chanceMISSILE: "..chanceMISSILE)

		--r27 Balancing patrol and guardposts' weapons
		if
			--      true or --r27 remove weapons for all soldiers and reassign, even outposts
			onlyPatrols[solIdIndex]
			or onlyGuardposts[solIdIndex]
		then
			-- these can be reset as well

			--      powerSettingsTable.MG=nil
			--      powerSettingsTable.SHOTGUN=nil
			--      powerSettingsTable.SHIELD=nil
			powerSettingsTable.SNIPER=nil --remove only sniper and missile coz otherwise all guardposts/patrols end up with too many of these
			powerSettingsTable.MISSILE=nil
		end

		local isWeaponSet=false
		local randomVariable
		while not isWeaponSet do
			TppMain.Randomize()
			randomVariable = math.random()
			if randomVariable <= chanceASSAULT then
				--do not remove existing power setting when setting ASSAULT. Let the game fuck up a lil
				--          e.MG=nil
				--          e.SHOTGUN=nil
				--          e.SHIELD=nil
				--          e.SNIPER=nil
				--          e.MISSILE=nil
				table.insert(powerSettingsTable,"ASSAULT")
				isWeaponSet=true
				TppMain.Randomize()
				--r11 adjusted random chances
			elseif randomVariable <= chanceMG and (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.MG)) then
				table.insert(powerSettingsTable,"MG")
				isWeaponSet=true
				TppMain.Randomize()
			elseif randomVariable <= chanceSHOTGUN and (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.SHOTGUN)) then
				table.insert(powerSettingsTable,"SHOTGUN")
				isWeaponSet=true
				TppMain.Randomize()
			elseif randomVariable <= chanceSHIELD and not powerSettingsTable.ARMOR  and (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.SHIELD)) then
				table.insert(powerSettingsTable,"SHIELD")
				isWeaponSet=true
				TppMain.Randomize()
			elseif randomVariable <= chanceSNIPER and not powerSettingsTable.ARMOR  and (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.SNIPER)) then
				table.insert(powerSettingsTable,"SNIPER")
				isWeaponSet=true
				TppMain.Randomize()
			elseif randomVariable <= chanceMISSILE and (this.IsIgnoreBlocked() or not this.IsBlocked(this.BLOCKED_TYPE.MISSILE)) then
				table.insert(powerSettingsTable,"MISSILE")
				isWeaponSet=true
				TppMain.Randomize()
			end

		end

	end --END randomization for all
	--K resuming normal function

	--r13
	--r46 include MB+MBQF
	if TppMission.IsMbFreeMissions(vars.missionCode) then
		--          for k,v in pairs(e)do
		--            if(k=="NVG" or k=="GAS_MASK" or k=="HELMET" or k=="STRONG_WEAPON" or k=="SOFT_ARMOR")  then
		--              --TUPPMLog.Log("k: "..tostring(k).." v: "..tostring(v))
		--            end
		--          end

		powerSettingsTable.GAS_MASK=nil
		powerSettingsTable.HELMET=nil
		powerSettingsTable.NVG=nil
		powerSettingsTable.SOFT_ARMOR=nil
		powerSettingsTable.ARMOR=nil
		powerSettingsTable.MG=nil
		powerSettingsTable.SHOTGUN=nil
		powerSettingsTable.SHIELD=nil
		powerSettingsTable.SNIPER=nil
		powerSettingsTable.MISSILE=nil
		--e.STRONG_WEAPON=nil --removes all advanced weapons

		TppMain.Randomize()

		local randomVariable = math.random()
		if randomVariable<0.3 then
			table.insert(powerSettingsTable,"ASSAULT")
			TppMain.Randomize()
		elseif randomVariable<0.5 then
			table.insert(powerSettingsTable,"MG")
			TppMain.Randomize()
		elseif randomVariable<0.7 then
			table.insert(powerSettingsTable,"SHOTGUN")
			TppMain.Randomize()
		elseif randomVariable<0.8 then
			table.insert(powerSettingsTable,"SHIELD")
			TppMain.Randomize()
		elseif randomVariable<0.9 then
			table.insert(powerSettingsTable,"SNIPER")
			TppMain.Randomize()
		elseif randomVariable<99 then
			table.insert(powerSettingsTable,"MISSILE")
			TppMain.Randomize()
		end

		--TUPPMLog.Log("After setting false")
		--          for k,v in pairs(e)do
		----            if(k=="NVG"
		----            or k=="GAS_MASK"
		----            or k=="HELMET"
		----            or k=="STRONG_WEAPON"
		----            or k=="SOFT_ARMOR")  then
		--              --TUPPMLog.Log("k: "..tostring(k).." v: "..tostring(v))
		----            end
		--          end
		--TUPPMLog.Log("Complete")
	end --r13 end MB staff condition

	--does not work here for some damned reason
	--     if TppEnemy.GetSoldierType(soldierID)==EnemyType.TYPE_CHILD then
	--      --TUPPMLog.Log("is child")
	--      powerSettingsTable.GAS_MASK=nil
	--      powerSettingsTable.HELMET=nil
	--      powerSettingsTable.NVG=nil
	--      powerSettingsTable.SOFT_ARMOR=nil
	--      powerSettingsTable.ARMOR=nil
	--      powerSettingsTable.STRONG_WEAPON=nil
	--      powerSettingsTable.MG=nil
	--      powerSettingsTable.SHOTGUN=nil
	--      powerSettingsTable.SHIELD=nil
	--      powerSettingsTable.SNIPER=nil
	--      powerSettingsTable.MISSILE=nil
	--     end

end

return this
