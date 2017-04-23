--r51 Settings file driven approach
local this={
	--Yes this is a lua file instead of a settings text file, I am just too lazy to write a Lua I/O read - does that make me a bad programmer? Well that's up for debate but this method saves unnecessary processing to read variables and assign them to a table

	--:READ THIS FIRST!
	--DO NOT DELETE ANY ENTRIES FROM THIS FILE
	--Deleting entries will have the same effect as disabling that feature or may break the game+mod combo
	--To disable a feature, set the toggle to false
	--Variables have to be comma separated! No double commas after the last variable!
	--Adding brand new entries will not do anything at all - they are custom conditions defined by me
	--Multipliers are number based and will have a VANILLA game value of 1, unless specified
	--For multiplier, do not use negative values or very large values that may result in Lua going over the 16 bit limit
	--For all variables, no type checks have been setup so changing to non-number or non-boolean values will definitely break the game+mod combo


	--:DEBUG MODE SETTINGS
	_debug_ENABLE=false, --DEFAULT: false --Enable or disable debug mode. Leads to logging under TUPPM folder in game directory. Hold <DASH> and <RELOAD> at any time to enable debug mode
	_debug_ENABLE_forcePrintLogs=false, --DEFAULT: false --Enables forced logging to work. This is purely for my testing/debugging purposes when I don't want all logs to print i.e. when _debug_ENABLE is false
	_debug_ENABLE_skipMissionAndGoToACC=false, --DEFAULT: false --This will return you to the ACC if you are stuck/facing loading issues in any mission. Use this only if its a game breaking/loading bug


	--:NEW GAME+ MODE SETTINGS
	newGamePlus_ENABLE=false, --DEFAULT: false --Switches the mod to New Game + mode. BACKUP your save before you switch this on! No issues but your save state will never be the same!


	--:HELI SETTINGS
	heli_ENABLE_skipRides=true, --DEFAULT: true --Skips Heli Rides! Best feature ever too!
	heli_ENABLE_forceSearchLightAlwaysOn=true, --DEFAULT: true --Force the heli search light to be always on
	heli_ENABLE_heroicMusicOnLeaveMotherbase=true, --DEFAULT: true --Plays the awesome BGM from M2 every time you leave MB via heli
	heli_ENABLE_customLife=false, --DEFAULT: false --Set custom heli health
	heli_lifePoints=10000, --Set heli health points. heli_ENABLE_customLife has to be true. No idea about vanilla heli life points but less than 8,000 and the heli starts smoking. Min 1


	--:TIME SCALE SETTINGS
	time_ENABLE_customScale=false, --DEFAULT: false --Allows setting a custom time scale in the game
	time_clockScale=1, --VANILLA: 20 --Set to 1 to have real time scale. time_ENABLE_customScale has to be true. Set to large values to view a time lapse. Does not time lapse soldiers like the Phantom Cigar however
	time_ENABLE_localComputerTime=false, --DEFAULT: false --time_ENABLE_customScale has to be true. When true, the game's clock will sync with your computer clock. As soon as the Phantom Cigar is finished, time of day will sync to system time so day may turn to night!


	--:HARDCORE SETTINGS
	hardcore_ENABLE_useCustomSoldierParams=false, --DEFAULT: false --Set custom soldier parameters below. Does not affect FOBs. Below values will only be used when this is true. Will override Hardcore mod
	hardcore_maxLife=2600, --VANILLA: 2600 --Soldier torso life. Less than 530 will instant kill. Min 0
	hardcore_maxStamina=3000, --VANILLA: 3000 --Soldier stamina. Min 0
	hardcore_maxLimbLife=1500, --VANILLA: 1500 --Soldier limb life. Less than 530 will instant kill. Min 0
	hardcore_maxArmorLife=7500, --VANILLA: 7500 --ARMOR life. Min 0 --Interesting, this decides only torso health for ARMORed soldiers, limbs and helmet life for ARMOR is not set via ReloadSoldier2ParameterTables
	hardcore_maxHelmetLife=500, --VANILLA: 500 --Helmet life. Min 0
	hardcore_sleepRecoverSec=300, --VANILLA: 300 --Sleep recovery time. Set to 0 to never wake up
	--NOT USED --hardcore_faintRecoverSec=50, --VANILLA: 50 --Faint recovery time. Does not seem to have any effect sadly :/ STN knockout time seems to be very different for different damage types. Also, a Grade 8 STN shotgun causes much longer KO times than tranq! Did not test thoroughly with other STN weapons. My guess is that STN KO times are longer cause enemies go on alert when they wake up
	hardcore_dyingSec=60, --VANILLA: 60 --Dying time for soldiers. Set to 0 to never die
	hardcore_enemySightScale=1, --VANILLA: 1 --Multiplier for soldier sight. Value of 1.5 means 150%. Set to 0 to never be seen, except when using Phantom Cigar
	hardcore_enemySoundScale=1, --VANILLA: 1 --Multiplier for soldier noise hearing. Value of 1.5 means 150%. Set to 0 to never be heard


	--WEAPONS SETTINGS
	weapons_ENABLE_useCustomWeaponsSettings=false, --DEFAULT: false --Enable to use custom weapon settings below. Will override Hardcore mod
	weapons_infiniteSuppressorsValue=-1, --VANILLA: -1 --When -1 suppressors are infinite. Set to 60 to give all vanilla infinite suppressors 60 shot breaking. If you are setting this to 0, you would want to set weapons_normalSuppressorMultiplier to 0 as well. Changes may not be reflected mid mission. Min -1
	weapons_normalSuppressorMultiplier=1, --VANILLA: 1 --Set to -1 to set infinite suppressors(very huge values have the same effect). Set to 0 to remove suppressors. Set to 2 to have twice stronger suppressors and so on. Changes may not be reflected mid mission. Min -1
	weapons_totalAmmoMultiplier=1,  --VANILLA: 1 --Set to 0 for infinite ammo(very huge values have the same effect). Set to 2 to double the total weapon ammo. Set to the value 0.71428571428571428571428571428571 for best effect. Changes may not be reflected mid mission. Min 0
	weapons_supportAmmoMultiplier=1, --VANILLA: 1 --Multiplier for support weapons and items ammo. Best value is 0.4. Set to 0 for infinite(large values have same effect). Min 0
	weapons_supportMagazineValue=-1, --VANILLA: -1 --Set the amount of spare magazines you want. -1 or 0 means infinite. Affects FOBs! Min -1
	weapons_damageMultiplier=1, --VANILLA: 1 --Multiplier for all kinds of damage! Set to 999 to max all weapon damage. Set to 0 to remove all bullet damage(Lethal headshots no longer work, Non lethal headshots still work though). A fail safe has been added to ensure damage lies between 0 and 65535. Min 0
	weapons_weaponSwayMultiplier=1, --VANILLA: 1 --Multiplier for weapons sway in Third person/ADS mode. Best value to remove sway is 0.1. When set to 0, bullet drop effect of lethal weapons is not shown but still exists. Set to more than 1 to increase sway. Min 0


	--CAMO SETTINGS
	camo_ENABLE_useCustomCamoSettings=false, --DEFAULT: false --Enable to use custom camo settings below. Will override Hardcore mod
	camo_camoIndexValue=50, --VANILLA: 50 --Camouflage index. TBH changing this seems to have little to no effect if the value is between 0 and 100. A value like 1000 will hide u in plain sight provided u have the right camo! But if they hear you, they will eventually see you. 2000 will ensure they do not even see u sprinting. Min 0


	--:RESOURCE HARVEST SETTINGS
	res_gmpSmallDiamondMultiplier=3, --DEFAULT: 3, VANILLA: 1 --Multiplier for small diamonds GMP
	res_gmpLargeDiamondMultiplier=3, --DEFAULT: 3, VANILLA: 1 --Multiplier for large diamonds GMP
	res_gmpMissionsMultiplier=2, --DEFAULT: 2, VANILLA: 1 --Multiplier for missions GMP
	res_gmpSideOpsMultiplier=2, --DEFAULT: 2, VANILLA: 1 --Multiplier for side-ops GMP
	res_gmpPostersMultiplier=5, --DEFAULT: 5, VANILLA: 1 --Multiplier for posters GMP
	--NOT USED --res_BaseExtractingTimeMinuteMultiplier=1, --DEFAULT: 1, VANILLA: 1 --THIS IS UNUSED. It should reduce the resource mining time but any value less than 1 seems to stops resource mining entirely! Min 0. Feel free to test!
	res_fuelResourceMultiplier=10, --DEFAULT: 10, VANILLA: 1 --Multiplier for fuel collectibles
	res_minorMetalMultiplier=20, --DEFAULT: 20, VANILLA: 1 --Multiplier for minor metal collectibles
	res_parasitesMultiplier=100, --DEFAULT: 100, VANILLA: 1 --Multiplier for parasites secured from each SKULLS
	res_plantResourceMultiplier=25, --DEFAULT: 25, VANILLA: 1 --Multiplier for plant collectibles
	res_preciousMetalMultiplier=100, --DEFAULT: 100, VANILLA: 1 --Multiplier for precious metal collectibles
	res_autoMiningAmountsMultiplier=5, --DEFAULT: 5, VANILLA: 1 --Automatic resource mining reward multiplier. Min 0
	res_bioticResourceMultiplier=10, --DEFAULT: 10, VANILLA: 1 --Multiplier for biotic collectibles
	res_containerRedMultiplier=10, --DEFAULT: 10, VANILLA: 1 --Resource multiplier for red containers. Min 0
	res_containerWhiteMultiplier=10, --DEFAULT: 10, VANILLA: 1 --Resource multiplier for white containers. Min 0
	res_containerYellowMultiplier=10, --DEFAULT: 10, VANILLA: 1 --Resource multiplier for yellow containers. FOBs only(I think, maybe wrong) but you are not supposed to play online with mods anyway! Min 0
	res_combatSectionAutoGmpMultiplier=2, --DEFAULT: 2, VANILLA: 1 --Automatic combat deployment GMP reward multiplier. Min 0
	res_commonMetalMultiplier=10, --DEFAULT: 10, VANILLA: 1 --Multiplier for common metal collectibles
	res_containerProcessingAmountsMultiplier=10, --DEFAULT: 10, VANILLA: 1 --Container resource reward multiplier. Min 0
	res_containerProcessingTimeMultiplier=0.2, --DEFAULT: 0.2, VANILLA: 1 --Container processing time multiplier. Min 0
	res_ENABLE_additionalMissionCompletionRewards=true, --DEFAULT: true --Receive a fixed amount of resources based on mission clear rank
	res_ENABLE_doNotReduceFultonedContainerResources=true, --DEFAULT: true --Containers fultoned repeatedly in certain missions do not reduce resources received. Seems to be for mission specific containers only like in M12
	res_ENABLE_doNotReduceMissionGMPReward=true, --DEFAULT: true --Mission GMP reward is not reduced upon completing a mission multiple times
	res_ENABLE_instantRepopOfCollectibles=true, --DEFAULT: true --Instantly repopulate collectibles in the game world. This includes diamonds, processed resources and plants


	--:MOTHERBASE GAMEPLAY SETTINGS
	mtbs_ENABLE_randomMBStaffOutfits=true, --DEFAULT: true --Allow MB staff to use different outfits from Tiger stripe camo, Sneaking Suit and BattleDress
	mtbs_ENABLE_alwaysUseSwimsuitsOnMB=false, --DEFAULT: false --Always use swimsuit on MB for Staff. mtbs_ENABLE_randomMBStaffOutfits has to be true
	mtbs_ENABLE_outfitRandomizationOnCheckpointReload=true, --DEFAULT: true --Randomizes DD Outfits on checkpoint reloads to be in sync with faces, names and guns. mtbs_ENABLE_randomMBStaffOutfits has to be true
	mtbs_ENABLE_extraSoldiersOnMB=true, --DEFAULT: true --Allow extra soldiers on MB
	mtbs_totalStaffCountOnEachMBCluster=36, --DEFAULT: 36, VANILLA: 18 --Sets the total staff per MB cluster. Min 18(vanilla), Max 36. mtbs_ENABLE_extraSoldiersOnMB has to be true
	mtbs_ENABLE_moreFemalesOnMB=true, --DEFAULT: true --Allows more females on MB cluster. Min will always be 2(vanilla)
	mtbs_ENABLE_staffOnMBQFAfterCapture=true, --DEFAULT: true --Allows staff to show up on MBQF after SKULLS/MOF have been captured
	mtbs_ENABLE_mixedStaffForMBQF=true, --DEFAULT: true --Allow staff from all units on MBQF and allow females as well. Vanilla game only uses staff from Security team
	mtbs_ENABLE_lethalWeaponsOnMB=true, --DEFAULT: true --Allows lethal weapons on MB and MBQF
	mtbs_ENABLE_moreSaluteDialogue=true, --DEFAULT: true --Enables more salute dialogue by not disabling salutes due to story progress
	mtbs_ENABLE_randomShifts=true, --DEFAULT: true --Enables frequent staff patrol shifts on MB
	mtbs_ENABLE_unlockFOBGoalDoors=true, --DEFAULT: true --Unlocks FOB Goal Doors on MB
	mtbs_ENABLE_theBratDidntReallyStealSahelan=true, --DEFAULT: true --Always show Sahelanthropus
	mtbs_ENABLE_bbPostersOnMB=true, --DEFAULT: true --Enable BB Posters on MB even after beating M43
	mtbs_bbPostersChance=0.15, --DEFAULT: 0.15 --Percentage(%) chance for BB posters to show up even after beating M43. Fractional value between 0 and 1. Min 0(vanilla), Max 1. mtbs_ENABLE_bbPostersOnMB has to be true
	mtbs_dDogMovementRadius=3000, --DEFAULT: 3000, VANILLA: 45 --Define how far DD can follow you on MB. Min 45(vanilla), Max 3000(enough to cover all 7 clusters)
	mtbs_ENABLE_maxStaffMorale=false, --DEFAULT: false --When enabled staff morale will always be maxed out. Never be bothered by dropping morale :)


	--:REVENGE SYSTEM SETTINGS
	rev_ENABLE_maxRevengeAlways=true, --DEFAULT: true --Max all revenge levels always. If rev_ENABLE_maxRevengeLvlLimitFromStart is true then all revenge levels will be maxed out irrespective of story sequence. If rev_ENABLE_maxRevengeLvlLimitFromStart is false then revenge levels will be maxed as much as the current story sequence allows
	rev_ENABLE_maxRevengeLvlLimitFromStart=true, --DEFAULT: true --Enable max revenge level(6 - this is an index! Each revenge type has varying number of levels) irrespective of story progress
	rev_ENABLE_customModAbilitiesProfile=true, --DEFAULT: true --Enable custom mod based abilities profile. All soldier attack and defense abilities are maxed out. Fulton shooting ability is varied from soldier to soldier for better balance, instead of having them always shoot down the balloon. If rev_ENABLE_maxRevengeAlways is true, then I suggest to make this true as well
	rev_ENABLE_customModRevengeProfile=true, --DEFAULT: true --Enable custom mod based revenge profile. This changes the vanilla revenge settings and also adds a lot of randomization
	rev_ENABLE_powersForLRRPAndGuardposts=true, --DEFAULT: true --LRRP and Guardpost soldiers have revenge applied to them as well. rev_ENABLE_customModRevengeProfile has to be true
	rev_ENABLE_weaponCombos=true, --DEFAULT: true --Enables new weapon combos. Allows weapon combos not available in vanilla game
	rev_ENABLE_weaponsVariety=true, --DEFAULT: true --Enables weapon variety. Allows different weapons for each category
	rev_ENABLE_allWeaponsInRestrictedMissions=true, --DEFAULT: true --Removes weapon restrictions from certain missions
	rev_ENABLE_ARMORInExtraMissions=true, --DEFAULT: true --Allow use of ARMORed soldiers in free roam and extra missions
	rev_freeMissionARMORCountPerOutpost=2, --DEFAULT: 2 --Min 0(vanilla), Max 4. Is slightly buggy when playing around in free roam for long periods of time. Quit to title screen and continue to fix missing ARMOR/collision issues. rev_ENABLE_ARMORInExtraMissions has to be true
	rev_ENABLE_allMinefields=true, --DEFAULT: true --Enable all mine fields around an outpost
	rev_ENABLE_2ndStrongestMines=true, --DEFAULT: true --All mine fields have the 2nd strongest mines. Strongest mines cannot be marked by D-Dog
	rev_ENABLE_strongerGrenades=true, --DEFAULT: true --Enables strongest grenade type to be used by enemy soldiers
	rev_ENABLE_moreChatDialogue=true, --DEFAULT: true --Enables more chat dialogue by not disabling chats due to story progress
	rev_ENABLE_minOutRevengePoints=false, --DEFAULT: false --Reset revenge points to 0. This is a one time setting and you do not want it enabled all the time!
	rev_ENABLE_maxOutRevengePoints=false, --DEFAULT: false --Max out all revenge points. This is a one time setting and you do not want it enabled all the time!


	--:REINFORCEMENTS SYSTEM SETTINGS
	reinforce_ENABLE_customModRevengeProfile=true, --DEFAULT: true --Enable custom mod based revenge for reinforcements
	reinforce_ENABLE_redReinforceHeli=true, --DEFAULT: true --Reinforce heli is RED - strongest heli type
	reinforce_ENABLE_reinforcementsWithHeli=true, --DEFAULT: true --Will spawn reinforcements with the reinforce heli call
	reinforce_ENABLE_ARMORedReinforcements=true, --DEFAULT: true --Allows reinforcements to be ARMORed. reinforce_ENABLE_customModRevengeProfile has to be true


	--:ENEMY PHASE SETTINGS
	phase_ENABLE_alwaysAlertCPs=false, --DEFAULT: false --When true alerts will be triggered regularly for nearby CPs


	--:WILDCARD SOLDIER SETTINGS
	wildcard_ENABLE=true, --DEFAULT: true --Use wild card soldiers in missions and free roam. May separate the two at a later time


	--:SOLDIER ROUTES SETTINGS
	routes_ENABLE_shuffle=true, --DEFAULT: true --Shuffles routes for enemies soldiers as well as MB staff. No more 'sniper-here-ARMOR-there' on playing a mission at the same time of day. Also sends the base into disarray when a caution alert is triggered


	--:GAMEPLAY SETTINGS
	game_DISABLE_missionRankRestrictions=true, --DEFAULT: true --Disables rank being restricted on the use of Stealth Camo, Fulton Launcher, Parasites, Infinity Bandanna, High Grade Sneaking Suit/Battledress, Heli support, Fire support
	game_ENABLE_autoMarking=true, --DEFAULT: true --Enables auto marking :) Best feature ever! Auto marking increments mark counter for all objects except animals and the in mission re-marking counter for disappearing SKULLS snipers/Quiet
	game_ENABLE_autoMarkWithoutSRank=false, --DEFAULT: false --Enables auto marking even if Intel Unit Scouting Function is not S rank. game_ENABLE_autoMarking has to be true
	game_ENABLE_armoredVehiclesAndTanksInFreeRoam=true, --DEFAULT: true --APCs and Tanks are seen in free roam
	game_ENABLE_hideCredits=true, --DEFAULT: true --In game credits are not shown. Removes cutscene credits as well. May separate the two later
	game_ENABLE_highRankingSoldiersInTheField=true, --DEFAULT: true --Enables S++ and S+ soldiers in the field as average base unit level increases
	game_ENABLE_clearCompletedTasksDuringMission=true, --DEFAULT: true --Clears mission tasks during a mission so they do not appear grayed out
	game_ENABLE_mbMoraleBoost=true, --DEFAULT: true --Allow MB morale boost from time to time
	game_ENABLE_noWaitAfterLoadingScreen=true, --DEFAULT: true --No need to hit SPACE to start a mission after loading. _debug_ENABLE will override this however
	game_ENABLE_awardHonorMedalToStaff=true, --DEFAULT: true --Allow Honor Medal to be awarded to DD staff if a mission is S ranked with no kills and no alerts
	game_ENABLE_fastHeliPulloutDuringFreeRoamAlert=true, --DEFAULT: true --If an alert has been triggered during free roam, the heli will pull out with a 1 second(minimum possible) delay when you get in
	game_ENABLE_realTimeSpySearch=true,  --DEFAULT: true --Enable real time, highly accurate spy search for Intel A/S Rank Scouting Unit Function for Intel Unit. game_ENABLE_autoMarking should be false for S Rank effect to be seen
	game_ENABLE_repopRadioCassettesInGameWorld=true, --DEFAULT: true --All radios in the game world are repopulated with Cassette tapes so that the world feels a bit more lively. This seems a little off and may not always work for a reason I haven't tracked down yet
	game_ENABLE_resetAllGimmicks=true, --DEFAULT: true --Gimmicks like cargo containers, guard towers, AA guns, mortars, machine guns etc etc are reset between missions. May separate this into individual categories in the future
	game_timeToLittleChickenHatReuse=(24*60)*60, --DEFAULT: (24*60)*60 --Decides time(in seconds) before little chicken hat can be used again. Min 1 second, Max 1 day(vanilla). Current value is 1 day
	game_ENABLE_missionFailureOnCombatAlert=false, --DEFAULT: false --Enables instant mission failure on combat alert
	game_ENABLE_ignoreFreePlayForMissionFailureOnCombatAlert=true, --DEFAULT: true --When set to true, ignore free play from instant mission failure when game_ENABLE_missionFailureOnCombatAlert is set to true


	--:UI SETTINGS
	ui_disableHeadMarkers=false, --DEFAULT: false --Disables head markers for soldiers etc
	ui_disableXrayMarkers=false, --DEFAULT: false --Disables X-Ray effect for soldiers so you cannot sense them through solid objects. Changing this effect requires a checkpoint reload
	ui_disableWorldMarkers=false, --DEFAULT: false --Disables world markers etc
	ui_disableAnnounceLog=false, --DEFAULT: false --Disables announce log completely. While re-enabling this, the message for TUPPM settings being reloaded will not appear


	--:MOTHERBASE DEV SETTINGS
	mbBaseDev_gmpMultiplier=1, --DEFAULT: 1, VANILLA: 1  --Base dev GMP multiplier
	mbBaseDev_resourceMultiplier=1, --DEFAULT: 1, VANILLA: 1  --Base dev resources multiplier
	mbBaseDev_ENABLE_buildTimeOverride=true, --DEFAULT: true --Allow changing base dev time
	mbBaseDev_fixedBuildTime=10, --DEFAULT: 10 --Set a fixed time for base platform development. mbBaseDev_ENABLE_buildTimeOverride has to be true. Min 0


	--:MOTHERBASE SUPPORT SETTINGS
	mbSup_enemySoldierEnmityMultiplier=0, --DEFAULT: 0, VANILLA:1 --This sets the multiplier for the brig time it takes for captured soldiers to convert to DD Staff. Anything higher than 1 will increase the vanilla game brig time significantly! Safe values are between 0 and 1. Min 0
	mbSup_medBayTreatmentTimeMultiplier=0.5, --DEFAULT: 0.5, VANILLA:1 --Med bay treatment time multiplier. Min 0
	mbSup_supportAttackGmpMultiplier=0.25, --DEFAULT: 0.25, VANILLA:1 --Support strike GMP multiplier. Min 0


	--:EQUIP DEV SETTINGS
	development_gmpMultiplier=1, --DEFAULT: 1, VANILLA: 1 --Dev GMP multiplier
	development_resourceMultiplier=1, --DEFAULT: 1, VANILLA: 1  --Dev resources multiplier
	development_timeMultiplier=0, --DEFAULT: 0, VANILLA:1 --Multiplier for equipment development time. Anything higher than 1 will increase the vanilla game development time significantly! Safe values are between 0 and 1. Min 0
	development_ENABLE_reduceUnitLvlReq=false, --DEFAULT: false --Reduce dev unit level requirements to 1
	development_ENABLE_removeSpecialEquipDevReq=false, --DEFAULT: false --Removes special requirements from equip dev like Tranq Specialist etc


	--:DEPLOYMENT SETTINGS
	deployment_gmpMultiplier=0.25, --DEFAULT: 0.25, VANILLA:1 --Multiplier for deployment GMP costs. Anything higher than 1 will increase the vanilla game deployment GMP costs significantly! Safe values are between 0 and 1. Min 0
	deployment_resourceMultiplier=0.25, --DEFAULT: 0.25, VANILLA:1 --Multiplier for deployment resource costs. Anything higher than 1 will increase the vanilla game deployment resource costs significantly! Safe values are between 0 and 1. Min 0


	--:DISPATCH MISSIONS SETTINGS
	dispatch_ENABLE_highRankStaffRewards=true, --DEFAULT: true --Dispatch missions will give S++, S+ staff as reward
	dispatch_ENABLE_ignoreBlockedForRevengeDispatchMissions=true, --DEFAULT: true --Ignores that a revenge type is blocked and still shows it's dispatch mission
	dispatch_missionsGmpMultiplier=2, --DEFAULT: 2, VANILLA:1 --Dispatch mission GMP reward multiplier. Min 0
	dispatch_resourceDrawCountMultiplier=2, --DEFAULT: 2, VANILLA:1 --Dispatch mission resource amount multiplier. Min 0
	dispatch_staffDrawCountMultiplier=2, --DEFAULT: 2, VANILLA:1 --Dispatch mission staff amount multiplier. Min 0
	dispatch_staffHitRateMultiplier=2, --DEFAULT: 2, VANILLA:1 --Dispatch mission staff % chance multiplier. Min 0
	dispatch_ENABLE_customNormalMissionsTimes=true, --DEFAULT: true --If true, normal dispatch mission times can be controlled below
	dispatch_normalMissionsTimeFixed=1, --DEFAULT: 1 -- Min 0
	dispatch_normalMissionsTimeRandom=19, --DEFAULT: 19 -- Min 0
	dispatch_ENABLE_customRevengeMissionsTimes=true, --DEFAULT: true --If true, revenge blocking dispatch mission times can be controlled below
	dispatch_revengeMissionsTimeFixed=0, --DEFAULT: 0 -- Min 0
	dispatch_revengeMissionsTimeRandom=0, --DEFAULT: 0 -- Min 0


	--:PLAYER AND EQUIPMENT SETTINGS
	player_ENABLE_avatarWithoutBeatingM46=true, --DEFAULT: true --Unlocks Avatar from the start without having to complete M46
	player_ENABLE_avatarInM1WhenPlayingNewGame=false, --DEFAULT: false --When playing a new game, start M1 with Avatar instead of Snake
	player_ENABLE_disablingFultonOption=true, --DEFAULT: true --Fulton disabling device is optional. When 'No Fulton Device' is equipped you cannot fulton anything. If true and when playing a new game, remember to switch to the Grade 1 Balloon Fulton at least once to re-enable fultoning
	player_ENABLE_additionalNoneWeaponSlots=true, --DEFAULT: true --Adds NONE slots for Primary Hip and Secondary weapons. Do not use these NONE slots on FOBs!
	player_ENABLE_ddSoldiersInCutscenes=true, --DEFAULT: true --Allows use of DD soldiers and Avatar in all cutscenes
	player_ENABLE_ddSoldiersForM2andM43=true, --DEFAULT: true --Allows use of DD soldiers and Avatar for M2 and M43
	player_ENABLE_autoAcquirePerishableCassettes=true, --DEFAULT: true --Perishable tapes will be automatically added to your tape player between missions provided M31 has been completed
	player_ENABLE_equipmentDropping=true, --DEFAULT: true --Allows dropping of weapons and support items. Hold <AIM> + <TOGGLE FLASHLIGHT> for 2 seconds
	player_ENABLE_keepWeaponsBetweenFreeMissionTransitions=true, --DEFAULT: true --Keep weapons between free roam to missions and vice versa
	player_ENABLE_missionPrepForMoreMissions=true, --DEFAULT: true --Allows Sortie Prep for all missions except M0 and M46. Enables buddy, vehicle and time selection for certain missions
	player_ENABLE_refreshBloodyEffectBetweenMissions=false, --DEFAULT: false --Refreshes the player between missions, easily get rid of bloody effect.  Does not remove flies effect though! This is on purpose
	player_ENABLE_refreshFliesBetweenMissions=true, --DEFAULT: true --Refreshes the player between missions, easily get rid of flies.  Does not remove blood effect though! This is on purpose. This resets the health to max
	player_ENABLE_stopRadioWhenPlayingCassette=true, --DEFAULT: true --Stops all radio calls when a cassette tape is playing
	player_ENABLE_demonPointsManipViaZoo=true, --DEFAULT: true --Kill animals at the Zoo to gain 40,000 demon points each. Fulton a single animal at the Zoo to reset demon points to 0
	player_ENABLE_customHealth=false, --DEFAULT: false --Change player health. Works even when disabling cheat mode. Does not affect FOBs
	player_customHealthPoints=2000, --VANILLA: 6000 --Min 1(LOL - have fun), Max 50410(max possible without breaking 16 bit overflow with the game's health modifiers). player_ENABLE_customHealth has to be true. Does not affect FOBs


	--:HANDS AND TOOLS SETTINGS
	tool_bioArm_activeSonar=3, --DEFAULT: 3 --Change the active sonar arm upgrade levels. Range 0-3. Hand upgrades must be developed or will not equip
	tool_bioArm_mobility=3, --DEFAULT: 3 --Change the mobility arm upgrade levels. Range 0-3. Hand upgrades must be developed or will not equip
	tool_bioArm_precision=3, --DEFAULT: 3 --Change the precision arm upgrade levels. Range 0-3. Hand upgrades must be developed or will not equip
	tool_bioArm_medical=3, --DEFAULT: 3 --Change the medical arm upgrade levels. Range 0-3. Hand upgrades must be developed or will not equip
	tool_intScope=4, --DEFAULT: 4 --Change the intScope upgrade levels. Range 1-4. IntScope upgrades must be developed or will not equip
	tool_iDroid=4, --DEFAULT: 4 --Change the iDroid upgrade levels. Range 1-4. iDroid upgrades must be developed or will not equip


	--:BUDDY SETTINGS
	buddy_ENABLE_setCustomPoints=false, --DEFAULT: false --Enable to set buddy points from below. Range 0 to 100. Negative or values over 100 will max bond
	buddy_ddBondPoints=100, --Set D-Dog's bond points
	buddy_dHorseBondPoints=100, --Set D-Horse's bond points
	buddy_quietBondPoints=100, --Set Quiet's bond points


	--:CAMERA SETTINGS
	camera_ENABLE_customSettings=false, --DEFAULT: false --Enables customized camera. Has to be true if you want to enable custom camera settings via camera_settingsTable
	camera_settingsTable={
		offset=Vector3(-0.3,0.7,0), --VANILLA: Vector3(-0.3,0.7,0) --Camera offset from Snake. (X,Y,Z) --X: +ve moves horizontally left, -ve moves horizontally right. Default is negative value(-0.65 I think) --Y is height: +ve moves vertically up, -ve moves vertically down(but will never go below the floor) --Z: +ve moves horizontally up, -ve moves horizontally down
		distance=5.1, --VANILLA: 5.1 --Camera distance from Snake
		focalLength=21, --VANILLA: 21 --Should not be zero! How much to focus in on the target point
		focusDistance=8.75, --VANILLA: 8.75 --If 0, blur is removed. Higher values set blur distance farther from the screen
		aperture = 1.6, --VANILLA: 1.6 --If 0, blur is removed. Higher values reduce blur
		targetInterpTime=0, --VANILLA: 0 --Time taken for camera to acquire new pos
		targetIsPlayer=true, --VANILLA: true --Sets whether camera target is player or not
		target=Vector3(2,10,10), --VANILLA: Vector3(2,10,10) --When targetIsPlayer is false, the camera targets these co-ords. Diving breaks this camera as focus goes back to Snake. Can be set to Vector3(vars.playerPosX,vars.playerPosY,vars.playerPosZ)
		ignoreCollisionGameObjectName="Player", --No idea what this does
		rotationLimitMinX=-60, --VANILLA: -60 --Lower vertical rotation, Min should ideally be -90. Lower values will rotate camera further
		rotationLimitMaxX=80, --VANILLA: 80 --Upper vertical rotation, Max should ideally be +90. Higher values will rotate camera further
		alphaDistance=.5, --VANILLA: .5 --Distance from cam Snake starts to disappear. This is not in meters unlike all other distance/offset values
	},


	--:GAME STARTUP SETTINGS
	startup_ENABLE_autoSavePopUpSkip=true, --DEFAULT: true --Skip the auto save pop-up during game startup
	startup_ENABLE_loginSkip=true, --DEFAULT: true --Skip the login during game startup
	startup_ENABLE_reattempLogin=false, --DEFAULT: false --Re-attempt login during startup till logged into servers
	startup_maxReloginAttempts=5, --DEFAULT: 5 --Number of tries to re-attempt login
	startup_ENABLE_logosSkip=true, --DEFAULT: true --Skip logos during game startup


	--:PAUSE MENU SETTINGS
	menu_DISABLE_checkpointReloadOption=true, --DEFAULT: true --Disable checkpoint option in pause menu
	menu_ENABLE_restartOptionForFreeRoam=false, --DEFAULT: false --Add restart option to free roam pause menu. Not very useful unless debugging
	menu_ENABLE_restartOptionForZooAndMBQF=true, --DEFAULT: true --Add restart option to Zoo and MBQF pause menu. Not very useful unless debugging


	--:CHEATS SETTINGS
	cheats_ENABLE=true, --DEFAULT: true --Enables cheat mode. Super Health(plus removes damage and damage collision completely), Infinite ammo, Infinite suppressors, Infinite fultons and Player Warping. Hold <AIM>, <RADIO CALL> and <QUICK DIVE> for 2 seconds to activate cheat mode - hold again to deactivate. Remember to reactivate after loading checkpoints/missions
	cheats_ENABLE_cheatsAlwaysOn=false, --DEFAULT: false --Always start the game with cheats already enabled. cheats_ENABLE has to be true. This setting makes my life easier when debugging/testing
	cheats_DISABLE_godMode=false, --DEFAULT: false --Disable God mode settings if you do not want them - this includes infinite health, no damage reaction and infinite ammo
	cheats_ENABLE_wormholeWarping=true, --DEFAULT: true --Hold <CALL> + <ACTION> for 0.25 seconds to warp to last placed marker. If set to true, warping will use the wormhole effect. When false warping will be instantaneous
	cheats_wormholeWarpOutHeight=3, --DEFAULT: 3 --Set the height for wormhole warp-out. 3 is a decent number and ensures you do not clip through the floor. Min 0
	cheats_ENABLE_quickSaveAnywhere=false, --DEFAULT: false --Hold <CALL> + <RELOAD> for 0.25 seconds to save the game anywhere while in game. BACKUP your save before you try this everywhere as it may cause issues.  Cannot save during cutscenes or certain missions. This is for my debugging. cheats_ENABLE has to be true


	--:WEATHER SETTINGS
	weather_ENABLE_customSettings=true, --DEFAULT: true --Enable setting custom weather, like rain in Afghanistan and sandstorms in Africa. Does not affect FOBs. This has to be true for ALL of the duration/probability settings to take effect
	weather_ENABLE_keepCurrentWeatherBetweenTransitions=true, --DEFAULT: true --Sandstorm or Fog is not cleared between mission transitions. Does not affect FOBs
	weather_ENABLE_randomDurations=true, --DEFAULT: true --Randomize weather durations to mod's settings. Has to be false for custom weather durations below to take effect
	weather_ENABLE_randomProbabilities=true, --DEFAULT: true --Randomize weather probabilities to mod's settings. Has to be false for custom weather probabilities below to take effect
	weather_ENABLE_wildWeatherMode=false, --DEFAULT: false --Enables wild weather! weather_ENABLE_customSettings has to be true. This settings allows for slightly more control over special weather types. Basically, special weather types can be made to start a little after or as the mission starts. Ignores weather_ENABLE_randomDurations and weather_ENABLE_randomProbabilities
	weather_ENABLE_startMissionWithWildWeather=false, --DEFAULT: false --Start the mission/demo with preferred weather type. weather_ENABLE_customSettings and weather_ENABLE_wildWeatherMode have to be true. Set custom durations and probabilities to have it always rain for example. Some missions/demos force weather types at certain times/events

	--:WEATHER CUSTOM DURATIONS
	--These are time values, min is 0
	weatherDur_sunnyMIN = 0, --hours. VANILLA: 8
	weatherDur_sunnyMAX = 0, --hours. VANILLA: 5
	weatherDur_cloudyMIN = 0, --hours. VANILLA: 3
	weatherDur_cloudyMAX = 0, --hours. VANILLA: 5
	weatherDur_sandstormMIN = 0, --minutes. VANILLA: 13
	weatherDur_sandstormMAX = 0, --minutes. VANILLA: 20
	weatherDur_rainyMIN = 999, --hours. VANILLA: 1
	weatherDur_rainyMAX = 999, --hours. VANILLA: 2
	weatherDur_foggyMIN = 0, --minutes. VANILLA: 13
	weatherDur_foggyMAX = 0, --minutes. VANILLA: 20

	--:WEATHER CUSTOM PROBABILITIES
	--These are percentage(%) values and for an area should equate to 100 for best balance, min is 0
	--Normal weather types and special weather types are grouped separately for each area
	--Normal weather types
	weatherProb_afghSunny = 0, --VANILLA: 80
	weatherProb_afghCloudy = 0, --VANILLA: 20
	weatherProb_mafrSunny = 0, --VANILLA: 70
	weatherProb_mafrCloudy = 0, --VANILLA: 30
	weatherProb_mtbsSunny = 0, --VANILLA: 80
	weatherProb_mtbsCloudy = 0, --VANILLA: 20
	--Special weather types
	weatherProb_afghSandstorm = 0, --VANILLA: 100
	weatherProb_afghRainy = 100, --VANILLA: 0
	weatherProb_afghFoggy = 0, --VANILLA: 0
	weatherProb_mafrSandstorm = 0, --VANILLA: 0
	weatherProb_mafrRainy = 100, --VANILLA: 100
	weatherProb_mafrFoggy = 0, --VANILLA: 0
	weatherProb_mtbsSandstorm = 0, --VANILLA: 0
	weatherProb_mtbsRainy = 100, --VANILLA: 50
	weatherProb_mtbsFoggy = 0, --VANILLA: 50
	--Helispace
	weatherProb_afghHeliSandstorm = 0, --VANILLA: 0
	weatherProb_afghHeliRainy = 100, --VANILLA: 0
	weatherProb_afghHeliFoggy = 0, --VANILLA: 0
	weatherProb_mafrHeliSandstorm = 0, --VANILLA: 0
	weatherProb_mafrHeliRainy = 100, --VANILLA: 100
	weatherProb_mafrHeliFoggy = 0, --VANILLA: 0
	weatherProb_mtbsHeliSandstorm = 0, --VANILLA: 0
	weatherProb_mtbsHeliRainy = 100, --VANILLA: 100
	weatherProb_mtbsHeliFoggy = 0, --VANILLA: 0
	--Afgh No Sandstorm specially handled
	weatherProb_afghNOSANDSTORMSandstorm = 0, --VANILLA: 0
	weatherProb_afghNOSANDSTORMRainy = 100, --VANILLA: 0
	weatherProb_afghNOSANDSTORMFoggy = 0, --VANILLA: 0


--:NEW

}
return this
