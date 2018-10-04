--TUPPM Header

local this={}
local ApendArray=Tpp.ApendArray
local DEBUG_StrCode32ToString=Tpp.DEBUG_StrCode32ToString
local IsTypeFunc=Tpp.IsTypeFunc
local IsTypeTable=Tpp.IsTypeTable
local IsSavingOrLoading=TppScriptVars.IsSavingOrLoading
local UpdateScriptsInScriptBlocks=ScriptBlock.UpdateScriptsInScriptBlocks
local GetCurrentMessageResendCount=Mission.GetCurrentMessageResendCount

local moduleUpdateFuncs={}
local moduleUpdateFuncsSize=0
local missionScriptOnUpdateFuncs={}
local missionScriptOnUpdateFuncsSize=0
local UNKsomeTable1={}
local UNKsomeTable1Size=0
local UNKsomeTable2={}
local UNKsomeTable2Size=0
local onMessageTable={}
local UNKsomeTable3={}
local onMessageTableSize=0
local messageExecTable={}
local UNKsomeTable4={}
local messageExecTableSize=0

--r19 Special check when coming from title screen
local canRandomizeVehiclesAsComingFromTitle = false
--r35 For resetting gimmicks
local cannotResetGimmicksAsComingFromTitle = false

--r45 Do no set MB soldiers to salute if loading checkpoint or coming from title
--But set salute if restarting! Follow these vars to see how I did it
--These vars are set back to false at the end of TppPlayer.RemoveFakeHeli()
--Since the function executes on a timer, these two vars need to be set to false when RESTARTING as well!
this.comingFromTitleDontFireHeliRemoval = false
this.mbVeryFastCheckpointReloadHeliRouteNotFireFIX=false

local StrCode32=Fox.StrCode32

--r55 Fixed MB layout based LZs
this.LZPositionsMB={
	[500]={
		--Zoo routes
		--LZ: Middle
		[StrCode32"ly500_cl00_30150_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={9.1155920028687,8.7501268386841,-42.430213928223}, rotY=0, isDefault=true, dropRt="ly500_cl00_30150_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly500_cl00_30150_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly500_cl00_30150_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: East
		[StrCode32"ly500_cl00_30150_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={159.4271697998,8.7501268386841,9.6170091629028}, rotY=-92, dropRt="ly500_cl00_30150_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly500_cl00_30150_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly500_cl00_30150_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: South
		[StrCode32"ly500_cl00_30150_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-131.97308349609,8.7501268386841,100.23579406738}, rotY=133, dropRt="ly500_cl00_30150_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly500_cl00_30150_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly500_cl00_30150_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: North
		[StrCode32"ly500_cl00_30150_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-104.23648071289,8.7501268386841,-131.96905517578}, rotY=42, dropRt="ly500_cl00_30150_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly500_cl00_30150_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly500_cl00_30150_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	},
	[0]={
		--Grade 1 Command Cluster - vars.mbLayoutCode==0

		--LZ: MB Core 1
		[StrCode32"ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={9.11800766,8.7501268386841,-37.25537109}, rotY=0, isDefault=true, dropRt="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: MB Core top
		[StrCode32"ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|rt_apr"]={pos={-1.816040158,26.005094528198+5,14.06035423}, rotY=180, dropRt="ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|lz_cl00", takeOffRt=1481559281, point=120}, --MB Core top LZ - string take off route below does not work for this LZ
		--LZ: MB Core 2
		[StrCode32"ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={156.4494934,8.7501268386841,9.572790146}, rotY=-92, disableClusterIndex=(TppDefine.CLUSTER_DEFINE.Develop+1), dropRt="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: MB Core 3
		[StrCode32"ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={246.4705963,8.7501268386841,-101.3812866}, rotY=-45, disableClusterIndex=(TppDefine.CLUSTER_DEFINE.Combat+1), dropRt="ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: MB Core 4 - LZ lies over bridge, not accessible/never used :)
		[StrCode32"ly003_cl00_30050_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={376.71340942383,8.7501268386841,-57.736152648926}, rotY=0, disableClusterIndex=(TppDefine.CLUSTER_DEFINE.Develop+1), dropRt="ly003_cl00_30050_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl00_30050_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--TODO NEED TO ADJUST
		--LZ: Combat 1
		[StrCode32"ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={833.7506714,8.7501268386841,-558.2138672}, rotY=-44, dropRt="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Combat 2
		[StrCode32"ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={817.8605957,8.7501268386841,-701.0460205}, rotY=0, dropRt="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Combat 3
		[StrCode32"ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={939.6651001,8.7501268386841,-759.539978}, rotY=-46, dropRt="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Combat 4
		[StrCode32"ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1067.022583,8.7501268386841,-714.6171265}, rotY=-97, dropRt="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--TODO NEED TO ADJUST
		--LZ: R&D 1
		[StrCode32"ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={876.8227539,8.7501268386841,389.5261841}, rotY=-138, dropRt="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: R&D top -- no adjustment for pos
		[StrCode32"ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_apr"]={pos={867.09564208984,37.018760681152+1,318.51306152344}, rotY=-33, dropRt="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|lz_cl02", takeOffRt=3066193510, point=120}, --R&D top LZ - string take off route below does not work for this LZ
		--LZ: R&D 2 -- no adjustment for pos
		[StrCode32"ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1020.71875,8.7501268386841,374.0953979}, rotY=-91, dropRt="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: R&D 3
		[StrCode32"ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1109.594116,8.7501268386841,262.1197815}, rotY=-48, dropRt="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: R&D 4 -- no adjustment for pos
		[StrCode32"ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1236.669189,8.7501268386841,306.7989502}, rotY=-89, dropRt="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--TODO NEED TO ADJUST
		--LZ: Support 1 -- no adjustment for pos
		[StrCode32"ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={557.5081177,8.7501268386841,832.888855}, rotY=-137, dropRt="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Support 2 -- no adjustment for pos
		[StrCode32"ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={700.8033447,8.7501268386841,817.8010864}, rotY=-91, dropRt="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Support 3 -- no adjustment for pos
		[StrCode32"ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={759.0396118,8.7501268386841,939.2703857}, rotY=-137, dropRt="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Support 4 -- no adjustment for pos
		[StrCode32"ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={714.6287842,8.7501268386841,1066.402954}, rotY=178, dropRt="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--TODO NEED TO ADJUST
		--LZ: Med 1
		[StrCode32"ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-1050.138672,8.7501268386841,-31.65367889}, rotY=89, dropRt="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Med 2
		[StrCode32"ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-1108.665405,8.7501268386841,-152.9125824}, rotY=42, dropRt="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Med 3
		[StrCode32"ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-1251.527954,8.7501268386841,-137.5338593}, rotY=87, dropRt="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Med 4
		[StrCode32"ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-1309.918945,8.7501268386841,-258.9028625}, rotY=41, dropRt="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--TODO NEED TO ADJUST
		--LZ: Intel 1 -- no adjustment for pos
		[StrCode32"ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-30.01058197,8.7501268386841,1050.314575}, rotY=175, dropRt="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Intel 2 -- no adjustment for pos
		[StrCode32"ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={81.77433777,8.7501268386841,1140.340332}, rotY=-136, dropRt="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Intel 3 -- no adjustment for pos
		[StrCode32"ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={37.29440689,8.7501268386841,1267.697632}, rotY=177, dropRt="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Intel 4 -- no adjustment for pos
		[StrCode32"ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={149.2370911,8.7501268386841,1357.648071}, rotY=-138, dropRt="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--TODO NEED TO ADJUST
		--LZ: Base 1
		[StrCode32"ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-761.9554443,8.7501268386841,730.319397}, rotY=133, dropRt="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Base 2
		[StrCode32"ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-888.9977417,8.7501268386841,685.6290894}, rotY=88, dropRt="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Base 3
		[StrCode32"ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-979.048645,8.7501268386841,797.4684448}, rotY=132, dropRt="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Base 4
		[StrCode32"ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-1106.12207,8.7501268386841,753.0143433}, rotY=88, dropRt="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--Ward route
		--LZ: MBQF single LZ, rotY 0 is just fine
		[StrCode32"ly003_cl07_30050_heli0000|cl07pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-162.5267791748,8.7501268386841,-2104.9208984375}, rotY=0,isSeparation=true, dropRt="ly003_cl07_30050_heli0000|cl07pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl07_30050_heli0000|cl07pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl07_30050_heli0000|cl07pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	},
	[1]={
		--Grade 2 Command Cluster - vars.mbLayoutCode==1

		--LZ: MB Core 1
		[StrCode32"ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={9.11800766,8.7501268386841,-37.25537109}, rotY=0, isDefault=true, dropRt="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: MB Core top
		[StrCode32"ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|rt_apr"]={pos={-1.816040158,26.005094528198+5,14.06035423}, rotY=180, dropRt="ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|lz_cl00", takeOffRt=1481559281, point=120}, --MB Core top LZ - string take off route below does not work for this LZ
		--LZ: MB Core 2
		[StrCode32"ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={156.4494934,8.7501268386841,9.572790146}, rotY=-92, disableClusterIndex=(TppDefine.CLUSTER_DEFINE.Develop+1), dropRt="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: MB Core 3
		[StrCode32"ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={246.4705963,8.7501268386841,-101.3812866}, rotY=-45, disableClusterIndex=(TppDefine.CLUSTER_DEFINE.Combat+1), dropRt="ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: MB Core 4 - LZ lies over bridge, not accessible/never used :)
		[StrCode32"ly003_cl00_30050_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={376.71340942383,8.7501268386841,-57.736152648926}, rotY=0, disableClusterIndex=(TppDefine.CLUSTER_DEFINE.Develop+1), dropRt="ly003_cl00_30050_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl00_30050_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--TODO NEED TO ADJUST
		--LZ: Combat 1
		[StrCode32"ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={950.3547974,8.7501268386841,-561.7766724}, rotY=-44, dropRt="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Combat 2
		[StrCode32"ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={934.8603516,8.7501268386841,-704.2421265}, rotY=0, dropRt="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Combat 3
		[StrCode32"ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1056.127563,8.7501268386841,-762.6891479}, rotY=-46, dropRt="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Combat 4
		[StrCode32"ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1183.565918,8.7501268386841,-718.1204834}, rotY=-90, dropRt="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--TODO NEED TO ADJUST
		--LZ: R&D 1
		[StrCode32"ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={993.8190308,8.7501268386841,409.0224304}, rotY=-138, dropRt="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: R&D top -- no adjustment for pos
		[StrCode32"ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_apr"]={pos={984.45190429688,37.018760681152+1,337.64984130859}, rotY=-33, dropRt="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|lz_cl02", takeOffRt=3066193510, point=120}, --R&D top LZ - string take off route below does not work for this LZ
		--LZ: R&D 2 -- no adjustment for pos
		[StrCode32"ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1136.552246,8.7501268386841,393.5750732}, rotY=-91, dropRt="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: R&D 3
		[StrCode32"ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1226.800659,8.7501268386841,281.4152527}, rotY=-48, dropRt="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: R&D 4 -- no adjustment for pos
		[StrCode32"ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1353.773438,8.7501268386841,326.2388916}, rotY=-89, dropRt="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--TODO NEED TO ADJUST
		--LZ: Support 1 -- no adjustment for pos
		[StrCode32"ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={279.744812,8.7501268386841,979.5592651}, rotY=173, dropRt="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Support 2 -- no adjustment for pos
		[StrCode32"ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={391.4856873,8.7501268386841,1069.525879}, rotY=-139, dropRt="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Support 3 -- no adjustment for pos
		[StrCode32"ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={347.0460815,8.7501268386841,1196.692871}, rotY=178, dropRt="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Support 4 -- no adjustment for pos
		[StrCode32"ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={225.7304688,8.7501268386841,1255.221436}, rotY=129, dropRt="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--TODO NEED TO ADJUST
		--LZ: Med 1
		[StrCode32"ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-242.6888885,8.7501268386841,-903.8168335}, rotY=42, dropRt="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Med 2
		[StrCode32"ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-198.1287537,8.7501268386841,-1031.238647}, rotY=-2, dropRt="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Med 3
		[StrCode32"ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-309.9580383,8.7501268386841,-1121.153564}, rotY=45, dropRt="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Med 4
		[StrCode32"ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-265.6166382,8.7501268386841,-1248.839233}, rotY=-3, dropRt="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--LZ: Intel 1 -- no adjustment for pos
		[StrCode32"ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-716.5980225,8.7501268386841,558.55896}, rotY=138, dropRt="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Intel 2 -- no adjustment for pos
		[StrCode32"ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-700.86419677734,8.7501268386841,703.29937744141}, rotY=177, dropRt="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Intel 3 -- no adjustment for pos
		[StrCode32"ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-823.72180175781,8.7501268386841,761.10437011719}, rotY=133, dropRt="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Intel 4 -- no adjustment for pos
		[StrCode32"ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-806.88293457031,8.7501268386841,904.57025146484}, rotY=179, dropRt="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--LZ: Base 1
		[StrCode32"ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-786.5388794,8.7501268386841,-381.3916016}, rotY=88, dropRt="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Base 2
		[StrCode32"ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-844.5698242,8.7501268386841,-502.568512}, rotY=45, dropRt="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Base 3
		[StrCode32"ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-987.5096436,8.7501268386841,-487.4503174}, rotY=87, dropRt="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Base 4
		[StrCode32"ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-1045.859619,8.7501268386841,-608.6819458}, rotY=41, dropRt="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--Ward route
		--LZ: MBQF single LZ, rotY 0 is just fine
		[StrCode32"ly003_cl07_30050_heli0000|cl07pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-162.5267791748,8.7501268386841,-2104.9208984375}, rotY=0,isSeparation=true, dropRt="ly003_cl07_30050_heli0000|cl07pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl07_30050_heli0000|cl07pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl07_30050_heli0000|cl07pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	},
	[2]={
		--Grade 3 Command Cluster - vars.mbLayoutCode==2

		--LZ: MB Core 1
		[StrCode32"ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={9.11800766,8.7501268386841,-37.25537109}, rotY=0, isDefault=true, dropRt="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: MB Core top
		[StrCode32"ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|rt_apr"]={pos={-1.816040158,26.005094528198+5,14.06035423}, rotY=180, dropRt="ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|lz_cl00", takeOffRt=1481559281, point=120}, --MB Core top LZ - string take off route below does not work for this LZ
		--LZ: MB Core 2
		[StrCode32"ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={156.4494934,8.7501268386841,9.572790146}, rotY=-92, disableClusterIndex=(TppDefine.CLUSTER_DEFINE.Develop+1), dropRt="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: MB Core 3
		[StrCode32"ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={246.4705963,8.7501268386841,-101.3812866}, rotY=-45, disableClusterIndex=(TppDefine.CLUSTER_DEFINE.Combat+1), dropRt="ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: MB Core 4 - LZ lies over bridge, not accessible/never used :)
		[StrCode32"ly003_cl00_30050_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={376.71340942383,8.7501268386841,-57.736152648926}, rotY=0, disableClusterIndex=(TppDefine.CLUSTER_DEFINE.Develop+1), dropRt="ly003_cl00_30050_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl00_30050_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--LZ: Combat 1
		[StrCode32"ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1166.960083,8.7501268386841,-628.1369629}, rotY=-44, dropRt="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Combat 2
		[StrCode32"ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1152.156372,8.7501268386841,-769.901001}, rotY=0, dropRt="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Combat 3
		[StrCode32"ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1272.316406,8.7501268386841,-828.7625122}, rotY=-46, dropRt="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Combat 4
		[StrCode32"ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1399.423584,8.7501268386841,-785.5760498}, rotY=-97, dropRt="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--TODO NEED TO ADJUST
		--LZ: R&D 1
		[StrCode32"ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1095.408203125,8.7501268386841,323.56674194336}, rotY=-138, dropRt="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: R&D top -- no adjustment for pos
		[StrCode32"ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_apr"]={pos={1084.7421875,37.018760681152+1,250.79963684082}, rotY=-33, dropRt="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|lz_cl02", takeOffRt=3066193510, point=120}, --R&D top LZ - string take off route below does not work for this LZ
		--LZ: R&D 2 -- no adjustment for pos
		[StrCode32"ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1238.8735351563,8.7501268386841,306.72796630859}, rotY=-91, dropRt="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: R&D 3
		[StrCode32"ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1326.832031,8.7501268386841,194.7989349}, rotY=-48, dropRt="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: R&D 4 -- no adjustment for pos
		[StrCode32"ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1456.1591796875,8.7501268386841,239.37481689453}, rotY=-89, dropRt="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--LZ: Support 1 -- no adjustment for pos
		[StrCode32"ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={362.35015869141,8.7501268386841,905.54925537109}, rotY=173, dropRt="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Support 2 -- no adjustment for pos
		[StrCode32"ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={475.70230102539,8.7501268386841,995.08782958984}, rotY=-139, dropRt="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Support 3 -- no adjustment for pos
		[StrCode32"ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={429.70343017578,8.7501268386841,1122.8355712891}, rotY=178, dropRt="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Support 4 -- no adjustment for pos
		[StrCode32"ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={306.84616088867,8.7501268386841,1180.6407470703}, rotY=129, dropRt="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--LZ: Med 1
		[StrCode32"ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-158.4561157,8.7501268386841,-991.7202148}, rotY=37, dropRt="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Med 2
		[StrCode32"ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-114.7096863,8.7501268386841,-1117.64978}, rotY=-2, dropRt="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Med 3
		[StrCode32"ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-225.7994385,8.7501268386841,-1208.796021}, rotY=45, dropRt="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Med 4
		[StrCode32"ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-182.2274017,8.7501268386841,-1335.326416}, rotY=-3, dropRt="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--LZ: Intel 1 -- no adjustment for pos
		[StrCode32"ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-717.70281982422,8.7501268386841,559.83355712891}, rotY=138, dropRt="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Intel 2 -- no adjustment for pos
		[StrCode32"ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-700.86419677734,8.7501268386841,703.29937744141}, rotY=177, dropRt="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Intel 3 -- no adjustment for pos
		[StrCode32"ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-823.72180175781,8.7501268386841,761.10437011719}, rotY=133, dropRt="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Intel 4 -- no adjustment for pos
		[StrCode32"ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-806.88293457031,8.7501268386841,904.57025146484}, rotY=179, dropRt="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--LZ: Base 1
		[StrCode32"ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-786.5388794,8.7501268386841,-381.3916016}, rotY=88, dropRt="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Base 2
		[StrCode32"ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-844.5698242,8.7501268386841,-502.568512}, rotY=45, dropRt="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Base 3
		[StrCode32"ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-987.5096436,8.7501268386841,-487.4503174}, rotY=87, dropRt="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Base 4
		[StrCode32"ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-1045.859619,8.7501268386841,-608.6819458}, rotY=41, dropRt="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--Ward route
		--LZ: MBQF single LZ, rotY 0 is just fine
		[StrCode32"ly003_cl07_30050_heli0000|cl07pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-162.5267791748,8.7501268386841,-2104.9208984375}, rotY=0,isSeparation=true, dropRt="ly003_cl07_30050_heli0000|cl07pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl07_30050_heli0000|cl07pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl07_30050_heli0000|cl07pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	},
	[3]={
		--Grade 4 Command Cluster - vars.mbLayoutCode==3

		--LZ: MB Core 1
		[StrCode32"ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={9.11800766,8.7501268386841,-37.25537109}, rotY=0, isDefault=true, dropRt="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: MB Core top
		[StrCode32"ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|rt_apr"]={pos={-1.816040158,26.005094528198+5,14.06035423}, rotY=180, dropRt="ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|lz_cl00", takeOffRt=1481559281, point=120}, --MB Core top LZ - string take off route below does not work for this LZ
		--LZ: MB Core 2
		[StrCode32"ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={156.4494934,8.7501268386841,9.572790146}, rotY=-92, disableClusterIndex=(TppDefine.CLUSTER_DEFINE.Develop+1), dropRt="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: MB Core 3
		[StrCode32"ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={246.4705963,8.7501268386841,-101.3812866}, rotY=-45, disableClusterIndex=(TppDefine.CLUSTER_DEFINE.Combat+1), dropRt="ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: MB Core 4 - LZ lies over bridge, not accessible/never used :)
		[StrCode32"ly003_cl00_30050_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={376.71340942383,8.7501268386841,-57.736152648926}, rotY=0, disableClusterIndex=(TppDefine.CLUSTER_DEFINE.Develop+1), dropRt="ly003_cl00_30050_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl00_30050_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--LZ: Combat 1
		[StrCode32"ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1166.960083,8.7501268386841,-628.1369629}, rotY=-44, dropRt="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Combat 2
		[StrCode32"ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1152.156372,8.7501268386841,-769.901001}, rotY=0, dropRt="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Combat 3
		[StrCode32"ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1272.316406,8.7501268386841,-828.7625122}, rotY=-46, dropRt="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Combat 4
		[StrCode32"ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1399.423584,8.7501268386841,-785.5760498}, rotY=-97, dropRt="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--LZ: R&D 1
		[StrCode32"ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1210.013062,8.7501268386841,340.6793823}, rotY=-138, dropRt="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: R&D top -- no adjustment for pos
		[StrCode32"ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_apr"]={pos={1201.7384033203,37.018760681152+1,270.29614257813}, rotY=-33, dropRt="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|lz_cl02", takeOffRt=3066193510, point=120}, --R&D top LZ - string take off route below does not work for this LZ
		--LZ: R&D 2 -- no adjustment for pos
		[StrCode32"ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1355.8697509766,8.7501268386841,326.22448730469}, rotY=-91, dropRt="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: R&D 3
		[StrCode32"ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1442.886841,8.7501268386841,215.1510162}, rotY=-48, dropRt="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: R&D 4 -- no adjustment for pos
		[StrCode32"ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1573.1553955078,8.7501268386841,258.87133789063}, rotY=-89, dropRt="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--LZ: Support 1 -- no adjustment for pos
		[StrCode32"ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={362.35015869141,8.7501268386841,905.54925537109}, rotY=173, dropRt="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Support 2 -- no adjustment for pos
		[StrCode32"ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={475.70230102539,8.7501268386841,995.08782958984}, rotY=-139, dropRt="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Support 3 -- no adjustment for pos
		[StrCode32"ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={429.70343017578,8.7501268386841,1122.8355712891}, rotY=178, dropRt="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Support 4 -- no adjustment for pos
		[StrCode32"ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={306.84616088867,8.7501268386841,1180.6407470703}, rotY=129, dropRt="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--LZ: Med 1
		[StrCode32"ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-158.4561157,8.7501268386841,-991.7202148}, rotY=37, dropRt="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Med 2
		[StrCode32"ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-114.7096863,8.7501268386841,-1117.64978}, rotY=-2, dropRt="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Med 3
		[StrCode32"ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-225.7994385,8.7501268386841,-1208.796021}, rotY=45, dropRt="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Med 4
		[StrCode32"ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-182.2274017,8.7501268386841,-1335.326416}, rotY=-3, dropRt="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--LZ: Intel 1 -- no adjustment for pos
		[StrCode32"ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-717.70281982422,8.7501268386841,559.83355712891}, rotY=138, dropRt="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Intel 2 -- no adjustment for pos
		[StrCode32"ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-700.86419677734,8.7501268386841,703.29937744141}, rotY=177, dropRt="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Intel 3 -- no adjustment for pos
		[StrCode32"ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-823.72180175781,8.7501268386841,761.10437011719}, rotY=133, dropRt="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Intel 4 -- no adjustment for pos
		[StrCode32"ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-806.88293457031,8.7501268386841,904.57025146484}, rotY=179, dropRt="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--LZ: Base 1
		[StrCode32"ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-786.5388794,8.7501268386841,-381.3916016}, rotY=88, dropRt="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Base 2
		[StrCode32"ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-844.5698242,8.7501268386841,-502.568512}, rotY=45, dropRt="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Base 3
		[StrCode32"ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-987.5096436,8.7501268386841,-487.4503174}, rotY=87, dropRt="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
		--LZ: Base 4
		[StrCode32"ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-1045.859619,8.7501268386841,-608.6819458}, rotY=41, dropRt="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

		--Ward route
		--LZ: MBQF single LZ, rotY 0 is just fine
		[StrCode32"ly003_cl07_30050_heli0000|cl07pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-162.5267791748,8.7501268386841,-2104.9208984375}, rotY=0,isSeparation=true, dropRt="ly003_cl07_30050_heli0000|cl07pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl07_30050_heli0000|cl07pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl07_30050_heli0000|cl07pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	},
}


--r51 Using a single table for MB and Others - should have used this from the start!
--rX51 Awww shit, MB *map* changes based on number of platforms constructed so co-ords will not be always accurate untill all 28 plats are built. Evident on R&D platform 1!
this.LZPositions={
	--r18 No Heli rides when moving between MB/Zoo/Ward added
	--r21 Comment out this table's entries to enable heli rides between MB/Zoo/Ward
	--MB routes

	--r45 Fixed LZ rotation
	--r45 Added dropRt, takeOffRt and corrected LZ names
	--r45 Adjusted LZ positions - for every position that is adjusted, the line just below it holds the true position
	-- Pos was adjusted for some LZs as buddies only spawn and play their drop animation in the heli if you are more than 6m away from them

	--Found "SendPlayerAtRoute" by chance in M2 sequence file. Found rt_tkof somewhere else
	-- "SendPlayerAtRouteReady" readies heli at route, "SendPlayerAtRoute" or "SendPlayerAtRouteStart" fires route
	-- MB Core and R&D top LZs have differently named routes
	-- Monitored changes in support heli route using GameObject.SendCommand({type="TppHeli2",index=0},{id="GetUsingRoute"})
	-- and manually added take off rotues for these two LZs

	-- Same can be applied to free roam - IF you can get the take off route for EACH LZ by boarding the heli and noting down the route,
	-- and firing "SendPlayerAtRouteReady" followed by "SendPlayerAtRoute" in a similar manner. However, this is tedious work
	-- And take off route is not the same as the default leaving route after dropping player off

	--LZ: MB Core 1
	[StrCode32"ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={9.11800766,8.7501268386841,-37.25537109}, rotY=0, isDefault=true, dropRt="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={9.1155920028687,8.7501268386841,-42.430213928223}, rotY=0, isDefault=true, dropRt="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={9.1155920028687,8.7501268386841,-42.430213928223}, rotY=0, isDefault=true, dropRt="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={9.1155920028687,8.7501268386841,-42.430213928223}, rotY=0, isDefault=true, dropRt="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={9.1155920028687,8.7501268386841,-42.430213928223}, rotY=0, isDefault=true, dropRt="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: MB Core top
	[StrCode32"ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|rt_apr"]={pos={-1.816040158,26.005094528198,14.06035423}, rotY=180, dropRt="ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|lz_cl00", takeOffRt=1481559281, point=120}, --MB Core top LZ - string take off route below does not work for this LZ
	--  [StrCode32"ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|rt_apr"]={pos={-1.9415365457535,26.005094528198,17.777017593384}, rotY=180, dropRt="ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050", takeOffRt=1481559281, point=120}, --MB Core top LZ - string take off route below does not work for this LZ
	--  [StrCode32"ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|rt_apr"]={pos={-1.9415365457535,26.005094528198,17.777017593384}, rotY=0, dropRt="ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050", takeOffRt="ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|rt_tkof", point=120}, --MB Core top LZ ORIG- keep this one commented
	--  [StrCode32"ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|rt_apr"]={pos={-1.9415365457535,26.005094528198,17.777017593384}, rotY=0, dropRt="ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050", takeOffRt="ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|rt_apr"]={pos={-1.9415365457535,26.005094528198,17.777017593384}, rotY=0, dropRt="ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050", takeOffRt="ly003_cl00_30050_heli0000|cl00pl0_uq_0000_heli_30050|rt_tkof", point=120},

	--LZ: MB Core 2
	[StrCode32"ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={156.4494934,8.7501268386841,9.572790146}, rotY=-92, disableClusterIndex=(TppDefine.CLUSTER_DEFINE.Develop+1), dropRt="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={159.4271697998,8.7501268386841,9.6170091629028}, rotY=-92, disableClusterIndex=(TppDefine.CLUSTER_DEFINE.Develop+1), dropRt="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={159.4271697998,8.7501268386841,9.6170091629028}, rotY=0, dropRt="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={159.4271697998,8.7501268386841,9.6170091629028}, rotY=0, dropRt="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl00_30050_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: MB Core 3
	[StrCode32"ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={246.4705963,8.7501268386841,-101.3812866}, rotY=-45, disableClusterIndex=(TppDefine.CLUSTER_DEFINE.Combat+1), dropRt="ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={248.96594238281,8.7501268386841,-103.73515319824}, rotY=-45, disableClusterIndex=(TppDefine.CLUSTER_DEFINE.Combat+1), dropRt="ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={248.96594238281,8.7501268386841,-103.73515319824}, rotY=0, dropRt="ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl00_30050_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: MB Core 4 - LZ lies over bridge, not accessible/never used :)
	[StrCode32"ly003_cl00_30050_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={376.71340942383,8.7501268386841,-57.736152648926}, rotY=0, disableClusterIndex=(TppDefine.CLUSTER_DEFINE.Develop+1), dropRt="ly003_cl00_30050_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl00_30050_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl00_30050_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: Combat 1
	--  [StrCode32"ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1048.2072753906,8.7501268386841,-631.77398681641}, rotY=0, dropRt="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	[StrCode32"ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1166.960083,8.7501268386841,-628.1369629}, rotY=-44, dropRt="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1168.978515625,8.7501268386841,-630.18487548828}, rotY=-44, dropRt="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={834.69958496094,8.7501268386841,-559.33135986328}, rotY=0, dropRt="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={951.6923828125,8.7501268386841,-562.83123779297}, rotY=0, dropRt="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl01_30050_heli0000|cl01pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: Combat 2
	--  [StrCode32"ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1031.3685302734,8.7501268386841,-775.23950195313}, rotY=0, dropRt="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	[StrCode32"ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1152.156372,8.7501268386841,-769.901001}, rotY=0, dropRt="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1152.1398925781,8.7501268386841,-773.650390625}, rotY=0, dropRt="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={817.86083984375,8.7501268386841,-702.79693603516}, rotY=0, dropRt="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={934.85363769531,8.7501268386841,-706.29681396484}, rotY=0, dropRt="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl01_30050_heli0000|cl01pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: Combat 3
	--  [StrCode32"ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1057.7108154297,8.7501268386841,-764.10192871094}, rotY=0, dropRt="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1154.2257080078,8.7501268386841,-833.04461669922}, rotY=0, dropRt="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	[StrCode32"ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1272.316406,8.7501268386841,-828.7625122}, rotY=-46, dropRt="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1274.9969482422,8.7501268386841,-831.45550537109}, rotY=-46, dropRt="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={940.71807861328,8.7501268386841,-760.60205078125}, rotY=0, dropRt="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl01_30050_heli0000|cl01pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: Combat 4
	--  [StrCode32"ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1068.4658203125,8.7501268386841,-714.60314941406}, rotY=0, dropRt="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1185.4586181641,8.7501268386841,-718.10302734375}, rotY=0, dropRt="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1281.9735107422,8.7501268386841,-787.04571533203}, rotY=0, dropRt="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	[StrCode32"ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1399.423584,8.7501268386841,-785.5760498}, rotY=-97, dropRt="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1402.7447509766,8.7501268386841,-785.45660400391}, rotY=-97, dropRt="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl01_30050_heli0000|cl01pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: R&D 1
	--  [StrCode32"ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1095.408203125,8.7501268386841,323.56674194336}, rotY=0, dropRt="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	[StrCode32"ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1210.013062,8.7501268386841,340.6793823}, rotY=-138, dropRt="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1212.4044189453,8.7501268386841,343.06323242188}, rotY=-138, dropRt="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={878.12158203125,8.7501268386841,390.92022705078}, rotY=0, dropRt="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={995.11791992188,8.7501268386841,410.41690063477}, rotY=0, dropRt="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl02_30050_heli0000|cl02pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: R&D top -- no adjustment for pos
	--  [StrCode32"ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_apr"]={pos={1084.7421875,37.018760681152,250.79963684082}, rotY=0, dropRt="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050", takeOffRt="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_tkof", point=120},
	[StrCode32"ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_apr"]={pos={1201.7384033203,37.018760681152,270.29614257813}, rotY=-33, dropRt="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|lz_cl02", takeOffRt=3066193510, point=120}, --R&D top LZ - string take off route below does not work for this LZ
	--  [StrCode32"ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_apr"]={pos={1201.7384033203,37.018760681152,270.29614257813}, rotY=-33, dropRt="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050", takeOffRt="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_tkof", point=120}, --ORIG
	--  [StrCode32"ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_apr"]={pos={867.09564208984,37.018760681152,318.51306152344}, rotY=0, dropRt="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050", takeOffRt="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_apr"]={pos={984.45190429688,37.018760681152,337.64984130859}, rotY=0, dropRt="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050", takeOffRt="ly003_cl02_30050_heli0000|cl02pl0_uq_0020_heli_30050|rt_tkof", point=120},

	--LZ: R&D 2 -- no adjustment for pos
	--  [StrCode32"ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1021.5867919922,8.7501268386841,374.08148193359}, rotY=0, dropRt="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1138.5832519531,8.7501268386841,393.57818603516}, rotY=0, dropRt="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1238.8735351563,8.7501268386841,306.72796630859}, rotY=0, dropRt="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	[StrCode32"ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1355.8697509766,8.7501268386841,326.22448730469}, rotY=-91, dropRt="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl02_30050_heli0000|cl02pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: R&D 3
	--  [StrCode32"ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1111.1253662109,8.7501268386841,260.72958374023}, rotY=0, dropRt="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1228.1217041016,8.7501268386841,280.22622680664}, rotY=0, dropRt="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1328.4119873047,8.7501268386841,193.37603759766}, rotY=0, dropRt="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	[StrCode32"ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1442.886841,8.7501268386841,215.1510162}, rotY=-48, dropRt="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1445.408203125,8.7501268386841,212.87255859375}, rotY=-48, dropRt="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl02_30050_heli0000|cl02pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: R&D 4 -- no adjustment for pos
	--  [StrCode32"ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1238.8725585938,8.7501268386841,306.72833251953}, rotY=0, dropRt="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1355.8688964844,8.7501268386841,326.22500610352}, rotY=0, dropRt="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1456.1591796875,8.7501268386841,239.37481689453}, rotY=0, dropRt="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	[StrCode32"ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={1573.1553955078,8.7501268386841,258.87133789063}, rotY=-89, dropRt="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl02_30050_heli0000|cl02pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: Support 1 -- no adjustment for pos
	--  [StrCode32"ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={279.6535949707,8.7501268386841,981.46038818359}, rotY=0, dropRt="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	[StrCode32"ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={362.35015869141,8.7501268386841,905.54925537109}, rotY=173, dropRt="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={362.35015869141,8.7501268386841,905.54925537109}, rotY=0, dropRt="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={559.3310546875,8.7501268386841,834.69848632813}, rotY=0, dropRt="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl03_30050_heli0000|cl03pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: Support 2 -- no adjustment for pos
	--  [StrCode32"ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={393.00555419922,8.7501268386841,1070.9992675781}, rotY=0, dropRt="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	[StrCode32"ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={475.70230102539,8.7501268386841,995.08782958984}, rotY=-139, dropRt="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={475.70230102539,8.7501268386841,995.08782958984}, rotY=0, dropRt="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={702.79632568359,8.7501268386841,817.85980224609}, rotY=0, dropRt="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl03_30050_heli0000|cl03pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: Support 3 -- no adjustment for pos
	--  [StrCode32"ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={347.00640869141,8.7501268386841,1198.7468261719}, rotY=0, dropRt="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	[StrCode32"ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={429.70343017578,8.7501268386841,1122.8355712891}, rotY=178, dropRt="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={429.70343017578,8.7501268386841,1122.8355712891}, rotY=0, dropRt="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={760.60131835938,8.7501268386841,940.71697998047}, rotY=0, dropRt="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl03_30050_heli0000|cl03pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: Support 4 -- no adjustment for pos
	--  [StrCode32"ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={224.14906311035,8.7501268386841,1256.5518798828}, rotY=0, dropRt="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	[StrCode32"ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={306.84616088867,8.7501268386841,1180.6407470703}, rotY=129, dropRt="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={306.84616088867,8.7501268386841,1180.6407470703}, rotY=0, dropRt="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={714.60266113281,8.7501268386841,1068.4644775391}, rotY=0, dropRt="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl03_30050_heli0000|cl03pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: Med 1
	--  [StrCode32"ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-1052.3092041016,8.7501268386841,-31.604196548462}, rotY=0, dropRt="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	[StrCode32"ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-158.4561157,8.7501268386841,-991.7202148}, rotY=37, dropRt="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-160.6671295166,8.7501268386841,-993.63580322266}, rotY=37, dropRt="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-160.6671295166,8.7501268386841,-993.63580322266}, rotY=0, dropRt="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-244.19276428223,8.7501268386841,-905.35906982422}, rotY=0, dropRt="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl04_30050_heli0000|cl04pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: Med 2
	--  [StrCode32"ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-1110.1140136719,8.7501268386841,-154.46151733398}, rotY=0, dropRt="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	[StrCode32"ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-114.7096863,8.7501268386841,-1117.64978}, rotY=-2, dropRt="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-114.66819000244,8.7501268386841,-1121.3830566406}, rotY=-2, dropRt="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-114.66819000244,8.7501268386841,-1121.3830566406}, rotY=0, dropRt="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-198.19381713867,8.7501268386841,-1033.1063232422}, rotY=0, dropRt="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl04_30050_heli0000|cl04pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: Med 3
	--  [StrCode32"ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-1253.5795898438,8.7501268386841,-137.62275695801}, rotY=0, dropRt="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	[StrCode32"ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-225.7994385,8.7501268386841,-1208.796021}, rotY=45, dropRt="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-228.02030944824,8.7501268386841,-1210.9216308594}, rotY=45, dropRt="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-228.02030944824,8.7501268386841,-1210.9216308594}, rotY=0, dropRt="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-311.54595947266,8.7501268386841,-1122.6448974609}, rotY=0, dropRt="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl04_30050_heli0000|cl04pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: Med 4
	--  [StrCode32"ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-1311.3845214844,8.7501268386841,-260.48007202148}, rotY=0, dropRt="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	[StrCode32"ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-182.2274017,8.7501268386841,-1335.326416}, rotY=-3, dropRt="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-182.02145385742,8.7501268386841,-1338.6690673828}, rotY=0, dropRt="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-265.54711914063,8.7501268386841,-1250.3923339844}, rotY=0, dropRt="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl04_30050_heli0000|cl04pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: Intel 1 -- no adjustment for pos
	--  [StrCode32"ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-30.111001968384,8.7501268386841,1052.3082275391}, rotY=0, dropRt="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	[StrCode32"ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-717.70281982422,8.7501268386841,559.83355712891}, rotY=138, dropRt="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-717.70281982422,8.7501268386841,559.83355712891}, rotY=0, dropRt="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-717.70281982422,8.7501268386841,559.83355712891}, rotY=0, dropRt="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl05_30050_heli0000|cl05pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: Intel 2 -- no adjustment for pos
	[StrCode32"ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-700.86419677734,8.7501268386841,703.29937744141}, rotY=177, dropRt="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-700.86419677734,8.7501268386841,703.29937744141}, rotY=0, dropRt="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-700.86419677734,8.7501268386841,703.29937744141}, rotY=0, dropRt="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={83.241088867188,8.7501268386841,1141.8471679688}, rotY=0, dropRt="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl05_30050_heli0000|cl05pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: Intel 3 -- no adjustment for pos
	[StrCode32"ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-823.72180175781,8.7501268386841,761.10437011719}, rotY=133, dropRt="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-823.72180175781,8.7501268386841,761.10437011719}, rotY=0, dropRt="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-823.72180175781,8.7501268386841,761.10437011719}, rotY=0, dropRt="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={37.241870880127,8.7501268386841,1269.5948486328}, rotY=0, dropRt="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl05_30050_heli0000|cl05pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: Intel 4 -- no adjustment for pos
	[StrCode32"ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-806.88293457031,8.7501268386841,904.57025146484}, rotY=179, dropRt="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-806.88293457031,8.7501268386841,904.57025146484}, rotY=0, dropRt="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-806.88293457031,8.7501268386841,904.57025146484}, rotY=0, dropRt="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={150.59407043457,8.7501268386841,1359.1336669922}, rotY=0, dropRt="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl05_30050_heli0000|cl05pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: Base 1
	--  [StrCode32"ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-763.33709716797,8.7501268386841,731.60040283203}, rotY=88, dropRt="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	[StrCode32"ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-786.5388794,8.7501268386841,-381.3916016}, rotY=88, dropRt="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-788.7958984375,8.7501268386841,-381.5334777832}, rotY=0, dropRt="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-788.7958984375,8.7501268386841,-381.5334777832}, rotY=0, dropRt="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl06_30050_heli0000|cl06pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: Base 2
	[StrCode32"ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-844.5698242,8.7501268386841,-502.568512}, rotY=45, dropRt="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-846.60076904297,8.7501268386841,-504.39074707031}, rotY=45, dropRt="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-846.60076904297,8.7501268386841,-504.39074707031}, rotY=0, dropRt="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-846.60076904297,8.7501268386841,-504.39074707031}, rotY=0, dropRt="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-891.08483886719,8.7501268386841,685.6015625}, rotY=0, dropRt="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl06_30050_heli0000|cl06pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: Base 3
	--  [StrCode32"ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-980.62347412109,8.7501268386841,798.95379638672}, rotY=0, dropRt="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	[StrCode32"ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-987.5096436,8.7501268386841,-487.4503174}, rotY=87, dropRt="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-990.06616210938,8.7501268386841,-487.55209350586}, rotY=0, dropRt="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-990.06616210938,8.7501268386841,-487.55209350586}, rotY=0, dropRt="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl06_30050_heli0000|cl06pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--LZ: Base 4
	[StrCode32"ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-1045.859619,8.7501268386841,-608.6819458}, rotY=41, dropRt="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-1047.8713378906,8.7501268386841,-610.40930175781}, rotY=0, dropRt="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-1047.8713378906,8.7501268386841,-610.40930175781}, rotY=0, dropRt="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--  [StrCode32"ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-1108.3712158203,8.7501268386841,752.95513916016}, rotY=0, dropRt="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050", takeOffRt="ly003_cl06_30050_heli0000|cl06pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--Zoo routes
	--LZ: Middle
	[StrCode32"ly500_cl00_30150_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={9.1155920028687,8.7501268386841,-42.430213928223}, rotY=0, isDefault=true, dropRt="ly500_cl00_30150_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly500_cl00_30150_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly500_cl00_30150_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--LZ: East
	[StrCode32"ly500_cl00_30150_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_apr"]={pos={159.4271697998,8.7501268386841,9.6170091629028}, rotY=-92, dropRt="ly500_cl00_30150_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly500_cl00_30150_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly500_cl00_30150_heli0000|cl00pl1_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--LZ: South
	[StrCode32"ly500_cl00_30150_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-131.97308349609,8.7501268386841,100.23579406738}, rotY=133, dropRt="ly500_cl00_30150_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly500_cl00_30150_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly500_cl00_30150_heli0000|cl00pl2_mb_fndt_plnt_heli_30050|rt_tkof", point=120},
	--LZ: North
	[StrCode32"ly500_cl00_30150_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-104.23648071289,8.7501268386841,-131.96905517578}, rotY=42, dropRt="ly500_cl00_30150_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly500_cl00_30150_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly500_cl00_30150_heli0000|cl00pl3_mb_fndt_plnt_heli_30050|rt_tkof", point=120},

	--Ward route
	--LZ: MBQF single LZ, rotY 0 is just fine
	[StrCode32"ly003_cl07_30050_heli0000|cl07pl0_mb_fndt_plnt_heli_30050|rt_apr"]={pos={-162.5267791748,8.7501268386841,-2104.9208984375}, rotY=0,isSeparation=true, dropRt="ly003_cl07_30050_heli0000|cl07pl0_mb_fndt_plnt_heli_30050|rt_apr", lzname="ly003_cl07_30050_heli0000|cl07pl0_mb_fndt_plnt_heli_30050|lz_plnt", takeOffRt="ly003_cl07_30050_heli0000|cl07pl0_mb_fndt_plnt_heli_30050|rt_tkof", point=120},


	--rX4 takeOffRt do not seem to exist, at least replacing drp with tkof isn't the solution

	--r21 Comment out this table's entries to enable heli rides in missions/free roam
	--K Credits to tinmantex for already having done the dirty work so that I didn't have to

	--r28 Fixed rotations for all mission specific LZ
	-- LZs that are shared between missions can not obviously have different rotations
	-- Added logic to change rotations for 3 specific missions
	--story missions unique lzs

	--r45 Renamed dropRts var correctly
	--r45 Added takeOffRt for every LZ - I soo did not spend 2 days getting pullout routes for each LZ manually, not that dumb
	--r45 Updated LZ rotations with vanilla LZ rotations if heli drop is used with default heli side - only those rotations are not changed which may have been inconvenient
	--r45 Documented each LZs default heli side
	--r45 Added fixed vehicle spawn locations for every single LZ - cannot remember the number of times I have gone over each LZ in both maps now

	--Afgh is +15 or -15 from map 0 (maybe)
	--Mafr is +90 or -90 from map 0 (confirmed)


	--[Mission Unique LZs]
	--M23 The White Mamba
	[StrCode32"lz_drp_outland_N0000|rt_drp_outland_N_0000"]={defHeliSide="R", vehiclePos=Vector3(-793.9970093,-1.895408869,532.3474731), pos={-807.61,3.47,516.01},rotY=1, dropRt="lz_drp_outland_N0000|rt_drp_outland_N_0000", lzname="lz_outland_N0000|lz_outland_N_0000", takeOffRt=404051228, point=28},
	--M24 Close Contact
	[StrCode32"lz_drp_hillNorth_W0000|rt_drp_hillNorth_W_0000"]={defHeliSide="R", vehiclePos=Vector3(1751.086914,62.91062164,-396.8042908), pos={1734.22,66.01,-407.54},rotY=60, dropRt="lz_drp_hillNorth_W0000|rt_drp_hillNorth_W_0000", lzname="lz_hillNorth_W0000|lz_hillNorth_W_0000", takeOffRt=860757520, point=38},
	--M28 Code talker --TEST takeOffRt since mission does not have LZ at start point --Mission takes care of vehicle position
	[StrCode32"rts_drp_lab_S_0000"]={defHeliSide="R", vehiclePos=Vector3(2458.991943,72.00780487,-1196.398071), pos={2441.72,78.25,-1191.68},rotY=165, ORIGrotY=-112, dropRt="rts_drp_lab_S_0000", takeOffRt=1544613335, point=15}, --Not worth rotation change
	--M43 Shining Lights, Even in Death
	[StrCode32"rt_drp_mbqf_N"]={defHeliSide="", vehiclePos=nil, pos={-162.70,4.97,-2105.86}, dropRt="rt_drp_mbqf_N", takeOffRt=nil, point=nil},

	--[30010] Afghanistan
	--HOSTILE
	[StrCode32"lz_drp_cliffTown_I0000|rt_drp_cliffTown_I0000"]={hostile=true,defHeliSide="", vehiclePos=nil, pos={759.83,452.30,-1113.10},rotY=-4.08, dropRt="lz_drp_cliffTown_I0000|rt_drp_cliffTown_I0000", lzname="lz_cliffTown_I0000|lz_cliffTown_I_0000", takeOffRt=3897330797, point=nil},
	[StrCode32"lz_drp_commFacility_I0000|rt_drp_commFacility_I_0000"]={hostile=true,defHeliSide="", vehiclePos=nil, pos={1444.40,364.14,390.78},rotY=42.41, dropRt="lz_drp_commFacility_I0000|rt_drp_commFacility_I_0000", lzname="lz_commFacility_I0000|lz_commFacility_I_0000", takeOffRt=2124425530, point=nil},
	[StrCode32"lz_drp_enemyBase_I0000|rt_drp_enemyBase_I_0000"]={hostile=true,defHeliSide="", vehiclePos=nil, pos={-596.89,353.02,497.40},rotY=176.17, dropRt="lz_drp_enemyBase_I0000|rt_drp_enemyBase_I_0000", lzname="lz_enemyBase_I0000|lz_enemyBase_I_0000", takeOffRt=3326201039, point=nil},
	[StrCode32"lz_drp_field_I0000|rt_drp_field_I_0000"]={hostile=true,defHeliSide="", vehiclePos=nil, pos={418.33,278.22,2261.37},rotY=102.35, dropRt="lz_drp_field_I0000|rt_drp_field_I_0000", lzname="lz_field_I0000|lz_drp_field_I0000", takeOffRt=3697948679, point=nil},
	[StrCode32"lz_drp_fort_I0000|rt_drp_fort_I_0000"]={hostile=true,defHeliSide="", vehiclePos=nil, pos={2106.16,463.64,-1747.21},rotY=151.95, dropRt="lz_drp_fort_I0000|rt_drp_fort_I_0000", lzname="lz_fort_I0000|lz_fort_I_0000", takeOffRt=2624853706, point=nil},
	[StrCode32"lz_drp_powerPlant_E0000|rt_drp_powerPlant_E_0000"]={hostile=true,defHeliSide="", vehiclePos=nil, pos={-662.20,556.88,-1489.06},rotY=-150.97, dropRt="lz_drp_powerPlant_E0000|rt_drp_powerPlant_E_0000", lzname="lz_powerPlant_E0000|lz_powerPlant_E_0000", takeOffRt=2201855341, point=nil},
	[StrCode32"lz_drp_remnants_I0000|rt_drp_remnants_I_0000"]={hostile=true,defHeliSide="", vehiclePos=nil, pos={-805.54,291.88,1820.65},rotY=-38.93, dropRt="lz_drp_remnants_I0000|rt_drp_remnants_I_0000", lzname="lz_remnants_I0000|lz_remnants_I_0000", takeOffRt=620867751, point=nil},
	[StrCode32"lz_drp_slopedTown_I0000|rt_drp_slopedTown_I_0000"]={hostile=true,defHeliSide="", vehiclePos=nil, pos={512.11,316.60,167.44},rotY=108.72, dropRt="lz_drp_slopedTown_I0000|rt_drp_slopedTown_I_0000", lzname="lz_slopedTown_I0000|lz_slopedTown_I_0000", takeOffRt=2054689748, point=nil},
	[StrCode32"lz_drp_sovietBase_E0000|rt_drp_sovietBase_E_0000"]={hostile=true,defHeliSide="", vehiclePos=nil, pos={-2355.80,445.52,-1431.61},rotY=-5.26, dropRt="lz_drp_sovietBase_E0000|rt_drp_sovietBase_E_0000", lzname="lz_sovietBase_E0000|lz_sovietBase_E_0000", takeOffRt=3841335353, point=nil},
	[StrCode32"lz_drp_tent_I0000|rt_drp_tent_I_0000"]={hostile=true,defHeliSide="", vehiclePos=nil, pos={-1761.73,317.69,806.51},rotY=35.82, dropRt="lz_drp_tent_I0000|rt_drp_tent_I_0000", lzname="lz_tent_I0000|lz_tent_I_0000", takeOffRt=3238576420, point=nil},
	---------

	--MISSIONS
	--M3
	[StrCode32"lz_drp_field_N0000|rt_drp_field_N_0000"]={defHeliSide="R", vehiclePos=Vector3(799.4597778,338.1951904,1657.615479), pos={802.56,345.37,1637.75},rotY=-60, dropRt="lz_drp_field_N0000|rt_drp_field_N_0000", lzname="lz_field_N0000|lz_field_N_0000", takeOffRt=1682467279, point=22},
	[StrCode32"lz_drp_field_W0000|rt_drp_field_W_0000"]={defHeliSide="R", vehiclePos=Vector3(-355.4511108,278.2827759,1736.796143), pos={-359.62,283.42,1714.79},rotY=56, dropRt="lz_drp_field_W0000|rt_drp_field_W_0000", lzname="lz_field_W0000|lz_field_W_0000", takeOffRt=463434363, point=30},
	--M4
	--  [StrCode32"lz_drp_ruinsNorth_S0000|rt_drp_ruinsNorth_S_0000"]={defHeliSide="", vehiclePos=Vector3(x,y,z), pos={1275.22,337.42,1313.33},rotY=102, dropRt="lz_drp_ruinsNorth_S0000|rt_drp_ruinsNorth_S_0000", lzname="lz_ruinsNorth_S0000|lz_ruinsNorth_S_0000", takeOffRt=nil, point=30},
	--M5
	[StrCode32"lz_drp_enemyBase_N0000|rt_drp_enemyBase_N_0000"]={defHeliSide="L", vehiclePos=Vector3(-298.3803101,340.1132812,268.9901428), pos={-289.80,346.69,269.68},rotY=-97, dropRt="lz_drp_enemyBase_N0000|rt_drp_enemyBase_N_0000", lzname="lz_enemyBase_N0000|lz_enemyBase_N_0000", takeOffRt=1194703866, point=32}, --rX61 OR takeOffRt="lz_enemyBase_N0000|rt_rtn_enemyBase_N_0000" refer _heli.fox2
	[StrCode32"lz_drp_enemyBase_S0000|rt_drp_enemyBase_S_0000"]={defHeliSide="L", vehiclePos=Vector3(-372.9597473,315.8540039,763.0968018), pos={-351.61,321.89,768.34},rotY=-127, dropRt="lz_drp_enemyBase_S0000|rt_drp_enemyBase_S_0000", lzname="lz_enemyBase_S0000|lz_enemyBase_S_0000", takeOffRt=465401421, point=29}, --rX61 OR takeOffRt="lz_enemyBase_S0000|rt_rtn_enemyBase_S_0000" refer _heli.fox2
	--M6
	[StrCode32"lz_drp_slopedTownEast_E0000|rt_drp_slopedTownEast_E_0000"]={defHeliSide="R", vehiclePos=Vector3(1204.610718,315.9397583,0.3941566348), pos={1187.73,320.98,-10.40},rotY=93, dropRt="lz_drp_slopedTownEast_E0000|rt_drp_slopedTownEast_E_0000", lzname="lz_slopedTownEast_E0000|lz_slopedTownEast_E_0000", takeOffRt=1638767626, point=30}, --r49 BUGFIX corrected pullout route for M6 LZ
	--M7
	[StrCode32"lz_drp_slopedTown_E0000|rt_drp_slopedTown_E_0000"]={defHeliSide="L", vehiclePos=Vector3(831.1821899,353.6598816,276.1671143), pos={822.37,360.44,292.44},rotY=179, dropRt="lz_drp_slopedTown_E0000|rt_drp_slopedTown_E_0000", lzname="lz_slopedTown_E0000|lz_slopedTown_E_0000", takeOffRt=3790368106, point=56},
	[StrCode32"lz_drp_ruinsNorth_S0000|rt_drp_ruinsNorth_S_0000"]={defHeliSide="L", vehiclePos=Vector3(1274.758667,332.818634,1327.174683), pos={1275.22,337.42,1313.33},rotY=-174, dropRt="lz_drp_ruinsNorth_S0000|rt_drp_ruinsNorth_S_0000", lzname="lz_ruinsNorth_S0000|lz_ruinsNorth_S_0000", takeOffRt=367877138, point=25},
	--M8
	[StrCode32"lz_drp_cliffTown_N0000|rt_drp_clifftown_N_0000"]={defHeliSide="L", vehiclePos=Vector3(817.6660767,444.7048645,-1406.137573), pos={834.42,451.21,-1420.10},rotY=6, dropRt="lz_drp_cliffTown_N0000|rt_drp_clifftown_N_0000", lzname="lz_cliffTown_N0000|lz_cliffTown_N_0000", takeOffRt=4287163223, point=38},
	[StrCode32"lz_drp_cliffTown_S0000|rt_drp_cliffTown_S_0000"]={defHeliSide="L", vehiclePos=Vector3(470.0114441,417.8918152,-693.2276611), pos={491.46,418.47,-693.19},rotY=-45, dropRt="lz_drp_cliffTown_S0000|rt_drp_cliffTown_S_0000", lzname="lz_cliffTown_S0000|lz_cliffTown_S_0000", takeOffRt=1148960783, point=59},
	--M9
	--always heli rides
	--M10
	[StrCode32"lz_drp_remnants_S0000|rt_drp_remnants_S_0000"]={defHeliSide="L", vehiclePos=Vector3(-444.1759644,281.9442139,1995.889038), pos={-424.83,289.10,2004.96},rotY=-89, dropRt="lz_drp_remnants_S0000|rt_drp_remnants_S_0000", lzname="lz_remnants_S0000|lz_remnants_S_0000", takeOffRt=3012880205, point=37},
	--M11
	--M12
	--M13
	--M32 --already taken care of
	--  [StrCode32"lz_drp_field_N0000|rt_drp_field_N_0000"]={defHeliSide="", vehiclePos=Vector3(x,y,z), pos={802.56,345.37,1637.75},rotY=-12, dropRt="lz_drp_field_N0000|rt_drp_field_N_0000", lzname="lz_field_N0000|lz_field_N_0000", takeOffRt=nil, point=30},
	--M38
	--  [StrCode32"lz_drp_ruinsNorth_S0000|rt_drp_ruinsNorth_S_0000"]={defHeliSide="", vehiclePos=Vector3(x,y,z), pos={1275.22,337.42,1313.33},rotY=-7, dropRt="lz_drp_ruinsNorth_S0000|rt_drp_ruinsNorth_S_0000", lzname="lz_ruinsNorth_S0000|lz_ruinsNorth_S_0000", takeOffRt=nil, point=30},
	[StrCode32"lz_drp_ruins_S0000|rt_drp_ruins_S_0000"]={defHeliSide="R", vehiclePos=Vector3(1291.250854,322.6456604,1855.532837), pos={1272.20,329.63,1853.51},rotY=96, dropRt="lz_drp_ruins_S0000|rt_drp_ruins_S_0000", lzname="lz_ruins_S0000|lz_ruins_S_0000", takeOffRt=2941631018, point=23},

	--Afghan RANDOM
	[StrCode32"lz_drp_bridge_S0000|rt_drp_bridge_S_0000"]={defHeliSide="L", vehiclePos=Vector3(1905.831299,364.8658447,56.88925552), pos={1904.32,368.36,81.33},rotY=-30, dropRt="lz_drp_bridge_S0000|rt_drp_bridge_S_0000", lzname="lz_bridge_S0000|lz_bridge_S_0000", takeOffRt=1692996658, point=47},
	[StrCode32"lz_drp_citadelSouth_S0000|rt_drp_citadelSouth_S_0000"]={defHeliSide="L", vehiclePos=Vector3(-1676.745239,533.9998169,-2217.510498), pos={-1663.71,536.63,-2201.78},rotY=44, dropRt="lz_drp_citadelSouth_S0000|rt_drp_citadelSouth_S_0000", lzname="lz_citadelSouth_S0000|lz_citadelSouth_S_0000", takeOffRt=1659277557, point=61},
	[StrCode32"lz_drp_cliffTownWest_S0000|rt_drp_cliffTownWest_S_0000"]={defHeliSide="R", vehiclePos=Vector3(84.51322937,429.0958557,-827.2250366), pos={64.77,434.32,-842.65},rotY=51, dropRt="lz_drp_cliffTownWest_S0000|rt_drp_cliffTownWest_S_0000", lzname="lz_cliffTownWest_S0000|lz_cliffTownWest_S_0000", takeOffRt=1399872191, point=35},
	[StrCode32"lz_drp_commFacility_S0000|rt_drp_commFacility_S_0000"]={defHeliSide="L", vehiclePos=Vector3(1645.074097,350.1439209,570.435791), pos={1651.17,353.38,587.98},rotY=85, dropRt="lz_drp_commFacility_S0000|rt_drp_commFacility_S_0000", lzname="lz_commFacility_S0000|lz_commFacility_S_0000", takeOffRt=2303880414, point=62},
	[StrCode32"lz_drp_commFacility_W0000|rt_drp_commFacility_W_0000"]={defHeliSide="R", vehiclePos=Vector3(1060.595581,356.1007996,486.2606506), pos={1060.06,362.05,467.90},rotY=23, dropRt="lz_drp_commFacility_W0000|rt_drp_commFacility_W_0000", lzname="lz_commFacility_W0000|lz_commFacility_W_0000", takeOffRt=4052877383, point=70},
	[StrCode32"lz_drp_fieldWest_S0000|rt_drp_fiieldWest_S_0000"]={defHeliSide="L", vehiclePos=Vector3(154.0937195,271.8386841,2338.738525), pos={141.47,275.51,2353.44},rotY=86, dropRt="lz_drp_fieldWest_S0000|rt_drp_fiieldWest_S_0000", lzname="lz_fieldWest_S0000|lz_fieldWest_S_0000", takeOffRt=2693743288, point=50},
	[StrCode32"lz_drp_fort_E0000|rt_drp_fort_E_0000"]={defHeliSide="R", vehiclePos=Vector3(2312.655029,389.2704468,-940.9870605), pos={2305.28,394.03,-923.73},rotY=170, ORIGrotY=90, dropRt="lz_drp_fort_E0000|rt_drp_fort_E_0000", lzname="lz_fort_E0000|lz_fort_E_0000", takeOffRt=3719573456, point=60},
	[StrCode32"lz_drp_fort_W0000|rt_drp_fort_W_0000"]={defHeliSide="R", vehiclePos=Vector3(1665.526001,486.4527588,-1341.721558), pos={1649.11,491.21,-1340.58},rotY=0, dropRt="lz_drp_fort_W0000|rt_drp_fort_W_0000", lzname="lz_fort_W0000|lz_fort_W_0000", takeOffRt=3331226354, point=61},
	[StrCode32"lz_drp_powerPlant_S0000|rt_drp_powerPlant_S_0000"]={defHeliSide="R", vehiclePos=Vector3(-615.1000977,439.3661499,-899.9552002), pos={-630.25,444.69,-910.73},rotY=30, ORIGrotY=120, dropRt="lz_drp_powerPlant_S0000|rt_drp_powerPlant_S_0000", lzname="lz_powerPlant_S0000|lz_powerPlant_S_0000", takeOffRt=3269046189, point=69},
	[StrCode32"lz_drp_remnantsNorth_N0000|rt_drp_remnantsNorth_N_0000"]={defHeliSide="L", vehiclePos=Vector3(-833.9033813,284.8435974,1596.697632), pos={-836.84,288.90,1574.03},rotY=-14, dropRt="lz_drp_remnantsNorth_N0000|rt_drp_remnantsNorth_N_0000", lzname="lz_remnantsNorth_N0000|lz_remnantsNorth_N_0000", takeOffRt=4230519680, point=9},--actually South LZ
	[StrCode32"lz_drp_remnantsNorth_S0000|rt_drp_remnantsNorth_S_0000"]={defHeliSide="R", vehiclePos=Vector3(-1255.779419,300.0667725,1347.978394), pos={-1273.30,305.48,1342.07},rotY=150, dropRt="lz_drp_remnantsNorth_S0000|rt_drp_remnantsNorth_S_0000", lzname="lz_remnantsNorth_S0000|lz_remnantsNorth_S_0000", takeOffRt=2739942891, point=40},--actally North LZ
	[StrCode32"lz_drp_slopedTown_W0000|rt_drp_slopedTown_W_0000"]={defHeliSide="L", vehiclePos=Vector3(64.35207367,320.0874329,242.385788), pos={95.31,320.37,243.91}, rotY=-105, dropRt="lz_drp_slopedTown_W0000|rt_drp_slopedTown_W_0000", lzname="lz_slopedTown_W0000|lz_slopedTown_W_0000", takeOffRt=1046531345, point=53},
	[StrCode32"lz_drp_sovietBase_N0000|rt_drp_sovietBase_N_0000"]={defHeliSide="R", vehiclePos=Vector3(-1721.90918,467.2399597,-1737.112427), pos={-1718.06,474.38,-1713.62},rotY=-112, dropRt="lz_drp_sovietBase_N0000|rt_drp_sovietBase_N_0000", lzname="lz_sovietBase_N0000|lz_sovietBase_N_0000", takeOffRt=1668402063, point=68},
	[StrCode32"lz_drp_sovietBase_S0000|rt_drp_sovietBase_S_0000"]={defHeliSide="R", vehiclePos=Vector3(-1935.167603,435.1315918,-1159.472534), pos={-1949.57,439.73,-1170.39},rotY=-70, ORIGrotY=-37, dropRt="lz_drp_sovietBase_S0000|rt_drp_sovietBase_S_0000", lzname="lz_sovietBase_S0000|lz_sovietBase_S_0000", takeOffRt=2012433708, point=38},
	[StrCode32"lz_drp_sovietSouth_S0000|rt_drp_sovietSouth_S_0000"]={defHeliSide="R", vehiclePos=Vector3(-1225.188232,411.2200928,-870.5426025), pos={-1219.28,416.14,-886.41},rotY=-39, ORIGrotY=175, dropRt="lz_drp_sovietSouth_S0000|rt_drp_sovietSouth_S_0000", lzname="lz_sovietSouth_S0000|lz_sovietSouth_S_0000", takeOffRt=2176858454, point=60},
	[StrCode32"lz_drp_tent_E0000|rt_drp_tent_E_0000"]={defHeliSide="R", vehiclePos=Vector3(-1390.401611,313.7731323,928.5588379), pos={-1372.18,318.33,934.68},rotY=1, dropRt="lz_drp_tent_E0000|rt_drp_tent_E_0000", lzname="lz_tent_E0000|lz_tent_E_0000", takeOffRt=4236048574, point=45},
	[StrCode32"lz_drp_tent_N0000|rt_drp_tent_N_0000"]={defHeliSide="L", vehiclePos=Vector3(-1889.446167,334.789917,547.8456421), pos={-1868.78,338.48,538.78},rotY=-32, dropRt="lz_drp_tent_N0000|rt_drp_tent_N_0000", lzname="lz_tent_N0000|lz_tent_N_0000", takeOffRt=4005362023, point=80},
	[StrCode32"lz_drp_village_N0000|rt_drp_village_N_0000"]={defHeliSide="R", vehiclePos=Vector3(601.03479,350.6882629,934.3290405), pos={612.73,355.48,911.22},rotY=-39, dropRt="lz_drp_village_N0000|rt_drp_village_N_0000", lzname="lz_village_N0000|lz_village_N_0000", takeOffRt=2859793319, point=50},
	[StrCode32"lz_drp_village_W0000|rt_drp_village_W_0000"]={defHeliSide="R", vehiclePos=Vector3(35.23143768,323.9627075,868.7990112), pos={20.70,329.63,888.03},rotY=170, dropRt="lz_drp_village_W0000|rt_drp_village_W_0000", lzname="lz_village_W0000|lz_village_W_0000", takeOffRt=3256606636, point=51},
	[StrCode32"lz_drp_waterway_I0000|rt_drp_waterway_I_0000"]={defHeliSide="R", vehiclePos=Vector3(-1637.295532,359.1705627,-331.2169495), pos={-1677.59,360.88,-321.82},rotY=159, dropRt="lz_drp_waterway_I0000|rt_drp_waterway_I_0000", lzname="lz_waterway_I0000|lz_waterway_I_0000", takeOffRt=3828038567, point=35},
	--------------------------------------------------

	--[30020] Africa
	--HOSTILE
	[StrCode32"lz_drp_banana_I0000|rt_drp_banana_I_0000"]={hostile=true,defHeliSide="", vehiclePos=nil, pos={300.61,50.06,-1237.66},rotY=-40.98, dropRt="lz_drp_banana_I0000|rt_drp_banana_I_0000", lzname="lz_banana_I0000|lz_banana_I_0000", takeOffRt=3359910119, point=nil},
	[StrCode32"lz_drp_diamond_I0000|rt_drp_diamond_I_0000"]={hostile=true,defHeliSide="", vehiclePos=nil, pos={1381.85,137.05,-1516.01},rotY=51.3, dropRt="lz_drp_diamond_I0000|rt_drp_diamond_I_0000", lzname="lz_diamond_I0000|lz_diamond_I_0000", takeOffRt=520750827, point=nil},
	[StrCode32"lz_drp_flowStation_I0000|rt_drp_flowStation_I_0000"]={hostile=true,defHeliSide="", vehiclePos=nil, pos={-1001.38,-7.20,-199.16},rotY=-178.15, dropRt="lz_drp_flowStation_I0000|rt_drp_flowStation_I_0000", lzname="lz_flowStation_I0000|lz_flowStation_I_0000", takeOffRt=3115386127, point=nil},
	[StrCode32"lz_drp_hill_I0000|rt_drp_hill_I_0000"]={hostile=true,defHeliSide="", vehiclePos=nil, pos={2154.83,63.09,366.70},rotY=83.13, dropRt="lz_drp_hill_I0000|rt_drp_hill_I_0000", lzname="lz_hill_I0000|lz_hill_I_0000", takeOffRt=3554542117, point=nil},
	[StrCode32"lz_drp_pfCamp_I0000|rt_drp_pfCamp_I_0000"]={hostile=true,defHeliSide="", vehiclePos=nil, pos={846.46,-4.97,1148.62},rotY=93.6, dropRt="lz_drp_pfCamp_I0000|rt_drp_pfCamp_I_0000", lzname="lz_pfCamp_I0000|lz_pfCamp_I_0000", takeOffRt=206877924, point=nil},
	[StrCode32"lz_drp_savannah_I0000|rt_drp_savannah_I_0000"]={hostile=true,defHeliSide="", vehiclePos=nil, pos={1014.25,57.18,-221.46},rotY=-71.73, dropRt="lz_drp_savannah_I0000|rt_drp_savannah_I_0000", lzname="lz_savannah_I0000|lz_savannah_I_0000", takeOffRt=2317865511, point=nil},
	[StrCode32"lz_drp_swamp_I0000|rt_drp_swamp_I_0000"]={hostile=true,defHeliSide="", vehiclePos=nil, pos={-19.63,11.17,140.91},rotY=-153.76, dropRt="lz_drp_swamp_I0000|rt_drp_swamp_I_0000", lzname="lz_swamp_I0000|lz_swamp_I_0000", takeOffRt=3471037992, point=nil},
	---------

	--MISSIONS
	--M14
	[StrCode32"lz_drp_swamp_S0000|rt_drp_swamp_S_0000"]={defHeliSide="L", vehiclePos=Vector3(-156.0004272,4.701086044,367.7856445), pos={-163.59,7.96,385.58},rotY=-179, dropRt="lz_drp_swamp_S0000|rt_drp_swamp_S_0000", lzname="lz_swamp_S0000|lz_swamp_S_0000", takeOffRt=3341415659, point=30},
	[StrCode32"lz_drp_swamp_W0000|lz_drp_swamp_W_0000"]={defHeliSide="L", vehiclePos=Vector3(-605.7457275,-1.034551978,215.9143982), pos={-618.09,6.48,232.79},rotY=150, dropRt="lz_drp_swamp_W0000|lz_drp_swamp_W_0000", lzname="lz_swamp_W0000|lz_swamp_W_0000", takeOffRt=1017298203, point=30},
	--M15
	[StrCode32"lz_drp_pfCampNorth_S0000|rt_drp_pfCampNorth_S_0000"]={defHeliSide="R", vehiclePos=Vector3(599.484314,-7.880494118,406.263092), pos={582.54,-3.14,418.17},rotY=149, ORIGrotY=120, dropRt="lz_drp_pfCampNorth_S0000|rt_drp_pfCampNorth_S_0000", lzname="lz_pfCampNorth_S0000|lz_pfCampNorth_S_0000", takeOffRt=3087170286, point=16}, --Not worth rotation change
	--M16
	--  [StrCode32"lz_drp_pfCampNorth_S0000|rt_drp_pfCampNorth_S_0000"]={defHeliSide="", vehiclePos=Vector3(x,y,z), pos={582.54,-3.14,418.17},rotY=71, dropRt="lz_drp_pfCampNorth_S0000|rt_drp_pfCampNorth_S_0000", lzname="lz_pfCampNorth_S0000|lz_pfCampNorth_S_0000", takeOffRt=nil, point=30},
	--M17
	[StrCode32"lz_drp_flowStation_E0000|lz_drp_flowStation_E_0000"]={defHeliSide="R", vehiclePos=Vector3(-598.5084839,8.565347672,-380.5661011), pos={-610.26,13.10,-398.20},rotY=49, dropRt="lz_drp_flowStation_E0000|lz_drp_flowStation_E_0000", lzname="lz_flowStation_E0000|lz_flowStation_E_0000", takeOffRt=3289759020, point=30},
	--  [StrCode32"lz_drp_swamp_W0000|lz_drp_swamp_W_0000"]={defHeliSide="", vehiclePos=Vector3(x,y,z), pos={-618.09,6.48,232.79},rotY=126, dropRt="lz_drp_swamp_W0000|lz_drp_swamp_W_0000", lzname="lz_swamp_W0000|lz_swamp_W_0000", takeOffRt=nil, point=30},
	--M18
	[StrCode32"lz_drp_savannahWest_N0000|lz_drp_savannahWest_N_0000"]={defHeliSide="R", vehiclePos=Vector3(501.1091003,14.87893295,-750.8900146), pos={510.10,20.43,-732.55},rotY=-149, dropRt="lz_drp_savannahWest_N0000|lz_drp_savannahWest_N_0000", lzname="lz_savannahWest_N0000|lz_savannahWest_N_0000", takeOffRt=267141307, point=17},
	--M19
	[StrCode32"lz_drp_savannahEast_N0000|rt_drp_savannahEast_N_0000"]={defHeliSide="L", vehiclePos=Vector3(1214.981445,19.44896889,-118.8935852), pos={1233.17,25.84,-127.05},rotY=0, dropRt="lz_drp_savannahEast_N0000|rt_drp_savannahEast_N_0000", lzname="lz_savannahEast_N0000|lz_savannahEast_N_0000", takeOffRt=2557877760, point=19},
	[StrCode32"lz_drp_savannahEast_S0000|lz_drp_savannahEast_S_0000"]={defHeliSide="L", vehiclePos=Vector3(1114.766479,6.351079941,294.0106201), pos={1119.97,10.72,317.63},rotY=-72, ORIGrotY=150, dropRt="lz_drp_savannahEast_S0000|lz_drp_savannahEast_S_0000", lzname="lz_savannahEast_S0000|lz_savannahEast_S_0000", takeOffRt=3584792694, point=23}, --Not worth rotation change
	--M20
	--  [StrCode32"lz_drp_hillWest_S0000|lz_drp_hillWest_S_0000"]={defHeliSide="", vehiclePos=Vector3(x,y,z), pos={1769.46,28.60,560.59},rotY=131, dropRt="lz_drp_hillWest_S0000|lz_drp_hillWest_S_0000", lzname="lz_hillWest_S0000|lz_hillWest_S_0000", takeOffRt=nil, point=30},
	--M21
	[StrCode32"lz_drp_pfCamp_N0000|rt_drp_pfcamp_N_0000"]={defHeliSide="R", vehiclePos=Vector3(1064.544556,0.06908261776,751.7553711), pos={1061.84,6.78,731.21},rotY=-33, ORIGrotY=0, dropRt="lz_drp_pfCamp_N0000|rt_drp_pfcamp_N_0000", lzname="lz_pfCamp_N0000|lz_pfCamp_N_0000", takeOffRt=384106623, point=20}, --Not worth rotation change
	--M22
	--M23 look above
	--M24
	[StrCode32"lz_drp_hillWest_S0000|lz_drp_hillWest_S_0000"]={defHeliSide="L", vehiclePos=Vector3(1768.978882,24.38768196,541.0545044), pos={1769.46,28.60,560.59},rotY=144, ORIGrotY=165, dropRt="lz_drp_hillWest_S0000|lz_drp_hillWest_S_0000", lzname="lz_hillWest_S0000|lz_hillWest_S_0000", takeOffRt=2779079175, point=30}, --Not worth rotation change
	--[Mission Unique LZs]
	--M25 --tinmantex missed this --r45 BUGFIX corrected route point
	[StrCode32"lz_drp_hillNorth_N0000|rt_drp_hillNorth_N_0000"]={defHeliSide="R", vehiclePos=Vector3(1686.033569,106.1043701,-730.513855), pos={1666.75,113.91,-740.61},rotY=30, dropRt="lz_drp_hillNorth_N0000|rt_drp_hillNorth_N_0000", lzname="lz_hillNorth_N0000|lz_hillNorth_N_0000", takeOffRt=112915129, point=21},
	--M26
	[StrCode32"lz_drp_bananaSouth_N0000|rt_drp_bananaSouth_N_0000"]={defHeliSide="R", vehiclePos=Vector3(87.91792297,13.33944225,-673.9992676), pos={74.70,18.20,-689.41},rotY=45, dropRt="lz_drp_bananaSouth_N0000|rt_drp_bananaSouth_N_0000", lzname="lz_bananaSouth_N0000|lz_bananaSouth_N_0000", takeOffRt=1742933729, point=22},
	--  [StrCode32"lz_drp_savannahEast_N0000|rt_drp_savannahEast_N_0000"]={defHeliSide="", vehiclePos=Vector3(x,y,z), pos={1233.17,25.84,-127.05},rotY=-39, dropRt="lz_drp_savannahEast_N0000|rt_drp_savannahEast_N_0000", lzname="lz_savannahEast_N0000|lz_savannahEast_N_0000", takeOffRt=nil, point=30},
	--  [StrCode32"lz_drp_swamp_S0000|rt_drp_swamp_S_0000"]={defHeliSide="", vehiclePos=Vector3(x,y,z), pos={-163.59,7.96,385.58},rotY=177, dropRt="lz_drp_swamp_S0000|rt_drp_swamp_S_0000", lzname="lz_swamp_S0000|lz_swamp_S_0000", takeOffRt=nil, point=30},
	--M27
	[StrCode32"lz_drp_diamondSouth_W0000|rt_drp_diamondSouth_W_0000"]={defHeliSide="L", vehiclePos=Vector3(1203.547852,104.6172104,-811.5087891), pos={1203.80,107.74,-792.16},rotY=-149, dropRt="lz_drp_diamondSouth_W0000|rt_drp_diamondSouth_W_0000", lzname="lz_diamondSouth_W0000|lz_diamondSouth_W_0000", takeOffRt=3320584352, point=9},
	--M28
	[StrCode32"lz_drp_factory_N0000|rt_drp_factory_N_0000"]={defHeliSide="R", vehiclePos=Vector3(2458.991943,72.00780487,-1196.398071), pos={2441.72,78.25,-1191.68},rotY=165, ORIGrotY=-112, dropRt="lz_drp_factory_N0000|rt_drp_factory_N_0000", lzname="lz_factory_N0000|lz_factory_N_0000", takeOffRt=1544613335, point=15}, --Not worth rotation change
	--M29
	--M30
	--M31
	--M35
	[StrCode32"lz_drp_lab_S0000|rt_drp_lab_S_0000"]={defHeliSide="R", vehiclePos=Vector3(2533.54126,108.0052872,-1850.117798), pos={2521.90,111.82,-1833.82},rotY=150, dropRt="lz_drp_lab_S0000|rt_drp_lab_S_0000", lzname="lz_lab_S0000|lz_lab_S_0000", takeOffRt=652049971, point=22},
	[StrCode32"lz_drp_lab_W0000|rt_drp_lab_W_0000"]={defHeliSide="R", vehiclePos=Vector3(2337.946533,204.6042328,-2467.245117), pos={2331.11,208.01,-2487.00},rotY=45, dropRt="lz_drp_lab_W0000|rt_drp_lab_W_0000", lzname="lz_lab_W0000|lz_lab_W_0000", takeOffRt=2428442978, point=38},
	--M41
	--  [StrCode32"lz_drp_hillWest_S0000|lz_drp_hillWest_S_0000"]={defHeliSide="", vehiclePos=Vector3(x,y,z), pos={1769.46,28.60,560.59},rotY=131, dropRt="lz_drp_hillWest_S0000|lz_drp_hillWest_S_0000", lzname="lz_hillWest_S0000|lz_hillWest_S_0000", takeOffRt=nil, point=30},
	--  [StrCode32"lz_drp_savannahEast_S0000|lz_drp_savannahEast_S_0000"]={defHeliSide="", vehiclePos=Vector3(x,y,z), pos={1119.97,10.72,317.63},rotY=153, dropRt="lz_drp_savannahEast_S0000|lz_drp_savannahEast_S_0000", lzname="lz_savannahEast_S0000|lz_savannahEast_S_0000", takeOffRt=nil, point=30},
	[StrCode32"lz_drp_swamp_N0000|lz_drp_swamp_N_0000"]={defHeliSide="L", vehiclePos=Vector3(-164.7724609,11.1586113,-371.5517578), pos={-145.52,16.15,-379.20},rotY=-74, dropRt="lz_drp_swamp_N0000|lz_drp_swamp_N_0000", lzname="lz_swamp_N0000|lz_swamp_N_0000", takeOffRt=770850619, point=30},

	--Africa RANDOM
	[StrCode32"lz_drp_diamondSouth_S0000|lz_drp_diamondSouth_S_0000"]={defHeliSide="R", vehiclePos=Vector3(1641.250854,83.20354462,-568.7444458), pos={1648.35,87.11,-555.26},rotY=-134, ORIGrotY=75, dropRt="lz_drp_diamondSouth_S0000|lz_drp_diamondSouth_S_0000", lzname="lz_diamondSouth_S0000|lz_diamondSouth_S_0000", takeOffRt=100926798, point=32}, --Not worth rotation change
	[StrCode32"lz_drp_diamondWest_S0000|lz_drp_diamondWest_S_0000"]={defHeliSide="L", vehiclePos=Vector3(904.914978,37.4603653,-934.0591431), pos={924.72,44.01,-931.28},rotY=-89, dropRt="lz_drp_diamondWest_S0000|lz_drp_diamondWest_S_0000", lzname="lz_diamondWest_S0000|lz_diamondWest_S_0000", takeOffRt=3214899049, point=43},
	[StrCode32"lz_drp_diamond_N0000|rt_drp_diamond_N_0000"]={defHeliSide="R", vehiclePos=Vector3(1114.90625,145.9358521,-1693.297852), pos={1096.40,150.86,-1685.39},rotY=90, dropRt="lz_drp_diamond_N0000|rt_drp_diamond_N_0000", lzname="lz_diamond_N0000|lz_diamond_N_0000", takeOffRt=1031458359, point=60},
	[StrCode32"lz_drp_factoryWest_S0000|lz_drp_factoryWest_S_0000"]={defHeliSide="R", vehiclePos=Vector3(2254.729736,81.4617157,-422.5802002), pos={2271.82,84.84,-418.59},rotY=-179, dropRt="lz_drp_factoryWest_S0000|lz_drp_factoryWest_S_0000", lzname="lz_factoryWest_S0000|lz_factoryWest_S_0000", takeOffRt=2630235699, point=60},
	[StrCode32"lz_drp_hillSouth_W0000|lz_drp_hillSouth_W_0000"]={defHeliSide="R", vehiclePos=Vector3(1702.848145,-7.973237991,1532.864868), pos={1688.90,-3.65,1520.55},rotY=105, dropRt="lz_drp_hillSouth_W0000|lz_drp_hillSouth_W_0000", lzname="lz_hillSouth_W0000|lz_hillSouth_W_0000", takeOffRt=3825085084, point=28},
	[StrCode32"lz_drp_hill_E0000|lz_drp_hill_E_0000"]={defHeliSide="L", vehiclePos=Vector3(2449.437988,65.62116241,238.2451935), pos={2465.21,71.47,230.49},rotY=-88, ORIGrotY=-179, dropRt="lz_drp_hill_E0000|lz_drp_hill_E_0000", lzname="lz_hill_E0000|lz_hill_E_0000", takeOffRt=2748245171, point=33}, --Not worth rotation change
	[StrCode32"lz_drp_hill_N0000|lz_drp_hill_N_0000"]={defHeliSide="L", vehiclePos=Vector3(1933.851318,41.58298492,73.85757446), pos={1951.46,49.82,88.58},rotY=-176, ORIGrotY=-104, dropRt="lz_drp_hill_N0000|lz_drp_hill_N_0000", lzname="lz_hill_N0000|lz_hill_N_0000", takeOffRt=3197474477, point=46}, --Not worth rotation change
	[StrCode32"lz_drp_labWest_W0000|rt_drp_labWest_W_0000"]={defHeliSide="L", vehiclePos=Vector3(1766.182861,165.7373962,-2129.374268), pos={1786.78,170.73,-2130.50},rotY=-49, ORIGrotY=-89, dropRt="lz_drp_labWest_W0000|rt_drp_labWest_W_0000", lzname="lz_labWest_W0000|lz_labWest_W_0000", takeOffRt=2471330527, point=47}, --Not worth rotation change but OK
	[StrCode32"lz_drp_outland_S0000|rt_drp_outland_S_0000"]={defHeliSide="L", vehiclePos=Vector3(-471.7783813,1.088059664,1094.10791), pos={-440.57,-14.39,1339.17},rotY=-146, ORIGrotY=-88, dropRt="lz_drp_outland_S0000|rt_drp_outland_S_0000", lzname="lz_outland_S0000|lz_outland_S_0000", takeOffRt=532020924, point=26}, --Not worth rotation change
	[StrCode32"lz_drp_pfCamp_S0000|lz_drp_pfCamp_S_0000"]={defHeliSide="R", vehiclePos=Vector3(990.9278564,-9.159130096,1563.829468), pos={1007.02,-4.46,1557.61},rotY=-140, ORIGrotY=90, dropRt="lz_drp_pfCamp_S0000|lz_drp_pfCamp_S_0000", lzname="lz_pfCamp_S0000|lz_pfCamp_S_0000", takeOffRt=3287428819, point=33}, --Not worth rotation change
	[StrCode32"lz_drp_swampEast_N0000|lz_drp_swampEast_N_0000"]={defHeliSide="L", vehiclePos=Vector3(286.3874207,-2.904768944,-230.5048218), pos={266.57,1.56,-234.08},rotY=60, dropRt="lz_drp_swampEast_N0000|lz_drp_swampEast_N_0000", lzname="lz_swampEast_N0000|lz_swampEast_N_0000", takeOffRt=857165525, point=40},
--------------------------------------------------
}

--r27 Tried SideOpsLZs to avoid - Quest CPs do not react to helis so pointless - they may be set to react I think, but haven't tried yet --TODO
--local sideOpsLZConflictTable={
--
--["ruins_q19010"]={locationId=30010, pos={1622.974,322.257,1062.973}, radius=5},
--["commFacility_q19013"]={locationId=30010, pos={1589.157,352.634,47.628}, radius=5},
--["outland_q19011"]={locationId=30020, pos={222.113,20.445,-930.962}, radius=5},
--["hill_q19012"]={locationId=30020, pos={1910.658,59.872,-231.274}, radius=5},
--["ruins_q60115"]={locationId=30010, pos={501.702,321.852,1194.651}, radius=4.5},
--["sovietBase_q60110"]={locationId=30010, pos={-719.57,536.851,-1571.775}, radius=4.5},
--["citadel_q60112"]={locationId=30010, pos={785.013,473.162,-916.954}, radius=4.5},
--["outland_q60113"]={locationId=30020, pos={-281.612,-8.36,751.687}, radius=4.5},
--["pfCamp_q60114"]={locationId=30020, pos={712.931,-3.225,1221.926}, radius=4.5},
--["sovietBase_q60111"]={locationId=30010, pos={-2330.799,438.515,-1568.261}, radius=4.5},
--["tent_q10010"]={locationId=30010, pos={-1426.164,319.449,1053.029}, radius=5.5},
--["field_q10020"]={locationId=30010, pos={574.394,320.805,1091.39}, radius=5},
--["fort_q10080"]={locationId=30010, pos={2144.585,459.984,-1764.566}, radius=5},
--["cliffTown_q10050"]={locationId=30010, pos={545.646,339.103,7.983}, radius=5},
--["waterway_q10040"]={locationId=30010, pos={-1200,399,-660}, radius=5},
--["commFacility_q10060"]={locationId=30010, pos={1580.025,346.609,47.889}, radius=5},
--["pfCamp_q10200"]={locationId=30020, pos={1830.153,-12.065,1217.415}, radius=5},
--["outland_q10100"]={locationId=30020, pos={-1117,-22,-250}, radius=5},
--["savannah_q10300"]={locationId=30020, pos={352.291,-5.991,.927}, radius=5},
--["banana_q10500"]={locationId=30020, pos={846.97,36.452,-917.762}, radius=5},
--["hill_q10400"]={locationId=30020, pos={2155.126,56.012,392.11}, radius=5},
--["diamond_q10600"]={locationId=30020, pos={1611.429,128.189,-848.904}, radius=5},
--["ruins_q10030"]={locationId=30010, pos={1301.97,331.741,1746.641}, radius=5},
--["sovietBase_q10070"]={locationId=30010, pos={-2081.274,436.152,-1532.619}, radius=5},
--["lab_q10700"]={locationId=30020, pos={2695.907,154.625,-2304.778}, radius=5},
--["citadel_q10090"]={locationId=30010, pos={-1258.72,598.68,-3055.925}, radius=5},
--["quest_q20065"]={locationId=30010, pos={1481.748,359.7492,467.3845}, radius=4.5},
--["quest_q20025"]={locationId=30010, pos={419.7284,270.3819,2206.412}, radius=4.5},
--["quest_q20075"]={locationId=30010, pos={-2200.667,443.142,-1632.121}, radius=5},
--["quest_q20805"]={locationId=30010, pos={1876.726,321.956,-426.263}, radius=4.5},
--["quest_q20905"]={locationId=30010, pos={1807.693,468.119,-1232.137}, radius=4.5},
--["quest_q20305"]={locationId=30020, pos={303.023,-5.295,401.582}, radius=5},
--["quest_q20035"]={locationId=30010, pos={1444.029,332.4536,1493.478}, radius=4.5},
--["quest_q23005"]={locationId=30020, pos={269.693,43.457,-1208.378}, radius=4.5},
--["quest_q20045"]={locationId=30010, pos={-1721.014,349.7935,-300.9322}, radius=4.5},
--["quest_q21005"]={locationId=30010, pos={-902.816,288.046,1905.899}, radius=4.5},
--["quest_q20105"]={locationId=30020, pos={-318.246,-13.006,1078.101}, radius=4},
--["quest_q24005"]={locationId=30020, pos={2527.301,71.168,-817.188}, radius=4.5},
--["quest_q20505"]={locationId=30020, pos={592.412,52.144,-955.067}, radius=4},
--["quest_q20605"]={locationId=30020, pos={1532.148,127.692,-1296.662}, radius=5},
--["quest_q25005"]={locationId=30020, pos={967.334,-11.938,1269.883}, radius=4.5},
--["quest_q27005"]={locationId=30020, pos={2073.421,51.254,355.372}, radius=4.5},
--["quest_q26005"]={locationId=30020, pos={1728.982,155.168,-1869.883}, radius=4.5},
--["quest_q20055"]={locationId=30010, pos={784.1397,474.0518,-1008.116}, radius=4},
--["quest_q22005"]={locationId=30010, pos={-1326.552,598.564,-3041.07}, radius=4.5},
--["quest_q20405"]={locationId=30020, pos={2172.657,56.106,377.634}, radius=4},
--["field_q30010"]={locationId=30010, pos={516.088,321.572,1065.328}, radius=5},
--["waterway_q39010"]={locationId=30010, pos={-473.987,417.258,-496.137}, radius=7},
--["lab_q39011"]={locationId=30020, pos={2656.23,144.117,-2173.246}, radius=7},
--["pfCamp_q39012"]={locationId=30020, pos={1367.551,-3.12,1892.457}, radius=7},
--["commFacility_q80060"]={locationId=30010, pos={1385.748,368,-23.469}, radius=5},
--["field_q80020"]={locationId=30010, pos={482.031,286.844,2474.655}, radius=5},
--["outland_q80100"]={locationId=30020, pos={-454.016,3.955,977.738}, radius=5},
--["pfCamp_q80200"]={locationId=30020, pos={338.505,1.002,1746.528}, radius=5},
--["diamond_q80600"]={locationId=30020, pos={1460.408,121.347,-1411.282}, radius=5},
--["hill_q80400"]={locationId=30020, pos={2566.009,68,-200.753}, radius=5},
--["tent_q80010"]={locationId=30010, pos={-1396.746,286.758,1009.375}, radius=5},
--["lab_q80700"]={locationId=30020, pos={2702.945,127.026,-1972.265}, radius=5},
--["fort_q80080"]={locationId=30010, pos={1408.371,500.486,-1300.667}, radius=5},
--["waterway_q80040"]={locationId=30010, pos={-1839.279,358.371,-339.326}, radius=5},
--["quest_q20015"]={locationId=30010, pos={-1764.669,311.1947,805.5405}, radius=4.5},--61 - Unlucky Dog 01>
--["quest_q20085"]={locationId=30010, pos={2154.21,458.245,-1782.244}, radius=4.5},
--["quest_q20205"]={locationId=30020, pos={911.094,-3.444,1072.21}, radius=6},
--["quest_q20705"]={locationId=30020, pos={2643.892,143.728,-2179.943}, radius=7},
--["quest_q20095"]={locationId=30010, pos={-1216.737,609.074,-3102.734}, radius=5.5},--65 - Unlucky Dog 05<
--["tent_q11010"]={locationId=30010, pos={-1058.028,290.648,1472.578}, radius=5},
--["tent_q11020"]={locationId=30010, pos={-1143.261,322.876,839.478}, radius=5},
--["waterway_q11030"]={locationId=30010, pos={-1347.736,397.481,-729.448}, radius=5},
--["cliffTown_q11040"]={locationId=30010, pos={369.861,413.892,-905.375}, radius=5},
--["savannah_q11400"]={locationId=30020, pos={1200.66,7.889,113.637}, radius=5},
--["pfCamp_q11200"]={locationId=30020, pos={1555.195,-12.034,1790.219}, radius=5},
--["commFacility_q11080"]={locationId=30010, pos={1475.388,344.972,13.41}, radius=5},
--["fort_q11060"]={locationId=30010, pos={1812.198,465.938,-1241.909}, radius=5},
--["outland_q11090"]={locationId=30020, pos={-386.984,9.648,762.663}, radius=5},
--["banana_q11600"]={locationId=30020, pos={563.844,77.95,-1070.378}, radius=5},
--["cliffTown_q11050"]={locationId=30020, pos={2383.08,86.157,-1125.214}, radius=5},
--["hill_q11500"]={locationId=30020, pos={2342.049,68.132,-104.587}, radius=5},
--["savannah_q11300"]={locationId=30020, pos={965.708,-4.035,287.023}, radius=5},
--["banana_q11700"]={locationId=30020, pos={713.795,33.409,-904.592}, radius=5},
--["fort_q11070"]={locationId=30010, pos={2194.519,429.075,-1284.068}, radius=5},
--["outland_q11100"]={locationId=30020, pos={-552.513,-.011,-197.752}, radius=5},
--["sovietBase_q99020"]={locationId=30010, pos={-716.5531,536.7278,-1485.517}, radius=5,isImportant=true},
--["ruins_q60010"]={locationId=30010, pos={1331.732,295.46,2164.405}, radius=4},
--["tent_q60011"]={locationId=30010, pos={-513.1647,372.9764,1148.782}, radius=5},
--["outland_q60024"]={locationId=30020, pos={-1205.26,-21.20666,129.0079}, radius=5},
--["fort_q60013"]={locationId=30010, pos={1921.452,456.3248,-1253.83}, radius=4},
--["hill_q60021"]={locationId=30020, pos={2151.132,70.83097,-116.7761}, radius=4.5},
--["pfCamp_q60020"]={locationId=30020, pos={1555.736,-8.822165,1725.071}, radius=4},
--["cliffTown_q60012"]={locationId=30010, pos={369.4612,412.6812,-844.1393}, radius=4},
--["banana_q60023"]={locationId=30020, pos={646.064,103.2225,-1122.37}, radius=4},
--["sovietBase_q60014"]={locationId=30010, pos={-1440.167,415.0882,-1282.796}, radius=4},
--["lab_q60022"]={locationId=30020, pos={2658.126,139.3819,-2146.524}, radius=4},
--["quest_q52030"]={locationId=30010, pos={-1889.494,332.666,546.761}, radius=5},
--["quest_q52010"]={locationId=30010, pos={1388.719,299.004,1976.527}, radius=6},
--["quest_q52040"]={locationId=30010, pos={-1589.128,511.561,-2113.037}, radius=5},
--["quest_q52020"]={locationId=30020, pos={-380.063,-2.53,490.478}, radius=5},
--["quest_q52050"]={locationId=30020, pos={672.542,-3.727,108.875}, radius=6},
--["quest_q52070"]={locationId=30020, pos={2364.716,56.688,314.611}, radius=5},
--["quest_q52060"]={locationId=30020, pos={1156.773,-12.097,1524.507}, radius=5},
--["quest_q52080"]={locationId=30010, pos={793.002,347.536,255.957}, radius=5},
--["quest_q52090"]={locationId=30020, pos={1722.589,152.294,-2079.907}, radius=5},
--["quest_q52100"]={locationId=30020, pos={810.898,-11.701,1194.177}, radius=5},
--["quest_q52130"]={locationId=30010, pos={-1836.664,358.543,-326.481}, radius=6},
--["quest_q52110"]={locationId=30020, pos={-1007.882,-14.2,-231.401}, radius=5},
--["quest_q52120"]={locationId=30020, pos={840.141,4.947,-130.741}, radius=5},
--["quest_q52140"]={locationId=30010, pos={-608.622,278.374,1694.876}, radius=5},
--["outland_q99071"]={locationId=30020, pos={-648.583,-18.483,1032.586}, radius=5},
--["sovietBase_q99070"]={locationId=30010, pos={-2127.887,436.594,-1564.366}, radius=5},
--["tent_q99072"]={locationId=30010, pos={-1761.536,310.333,806.76}, radius=5},
--["outland_q40010"]={locationId=30020, pos={222.904,20.496,-932.784}, radius=5},
----["mtbs_q99011"]={locationId=TppDefine.LOCATION_ID.MTBS,clusterId=TppDefine.CLUSTER_DEFINE.Medical,plntId=TppDefine.PLNT_DEFINE.Special,isImportant=true},
--["cliffTown_q99080"]={locationId=30010, pos={530.911,335.119,29.67}, radius=5},
----["mtbs_q99050"]={locationId=TppDefine.LOCATION_ID.MTBS,clusterId=TppDefine.CLUSTER_DEFINE.Develop,plntId=TppDefine.PLNT_DEFINE.Common1,isImportant=true},
--["quest_q52035"]={locationId=30010, pos={730.943,320.818,88.148}, radius=5},
--["quest_q52025"]={locationId=30010, pos={-608.622,278.374,1694.876}, radius=5},
--["quest_q52015"]={locationId=30010, pos={-1836.664,358.543,-326.481}, radius=6},
--["quest_q52075"]={locationId=30020, pos={1349.26,11.259,285.945}, radius=5},
--["quest_q52065"]={locationId=30020, pos={811.036,-11.657,1193.033}, radius=5},
--["quest_q52045"]={locationId=30020, pos={1722.589,152.294,-2079.907}, radius=5},
--["quest_q52055"]={locationId=30020, pos={-350.247,-2.555,-190.417}, radius=5},
--["quest_q52095"]={locationId=30020, pos={2429.92,61.019,189.081}, radius=6},
--["quest_q52085"]={locationId=30010, pos={-1898.048,316.223,610.601}, radius=5},
--["quest_q52105"]={locationId=30020, pos={672.542,-3.727,108.875}, radius=5},
--["quest_q52135"]={locationId=30010, pos={1393.775,299.887,1910.528}, radius=5},
--["quest_q52115"]={locationId=30020, pos={-775.086,-3.786,563.539}, radius=6},
--["quest_q52125"]={locationId=30020, pos={1156.773,-12.097,1524.507}, radius=6},
--["quest_q52145"]={locationId=30010, pos={-1589.128,511.561,-2113.037}, radius=5},
--["tent_q71010"]={locationId=30010, pos={-1759.032,310.695,806.245}, radius=5},
--["savannah_q71300"]={locationId=30020, pos={803.255,-11.806,1225.636}, radius=5},
--["field_q71020"]={locationId=30010, pos={421.778,269.679,2207.088}, radius=5},
--["lab_q71600"]={locationId=30020, pos={2522.474,100.128,-896.065}, radius=5},
--["tent_q71030"]={locationId=30010, pos={-859.822,301.749,1954.213}, radius=5},
--["sovietBase_q71070"]={locationId=30010, pos={-675.085,533.228,-1482.026}, radius=5},
--["cliffTown_q71050"]={locationId=30010, pos={527.023,328.63,50}, radius=5},
--["lab_q71700"]={locationId=30020, pos={2746.635,200.042,-2401.35}, radius=5},
--["field_q71090"]={locationId=30010, pos={474.7,322.281,1062.864}, radius=5},
--["waterway_q71040"]={locationId=30010, pos={-1490.294,396.138,-792.581}, radius=5},
--["fort_q71080"]={locationId=30010, pos={2080.718,456.726,-1927.582}, radius=5},
--["cliffTown_q71060"]={locationId=30010, pos={782.651,463.722,-1027.08}, radius=5},
--["diamond_q71500"]={locationId=30020, pos={1518,145,-2115}, radius=5},
--["banana_q71400"]={locationId=30020, pos={278.127,42.996,-1232.378}, radius=5},
--["outland_q71200"]={locationId=30020, pos={-594.489,-17.482,1095.318}, radius=5},
--["sovietBase_q99030"]={locationId=30010, pos={-2199.997,456.352,-1581.944}, radius=6,isImportant=true},
--["tent_q99040"]={locationId=30010, pos={-1762.503,310.288,802.482}, radius=5,isImportant=true},
--["outland_q20913"]={locationId=30020, pos={-958.532,-14.1,-224.044}, radius=5,isImportant=true},
--["lab_q20914"]={locationId=30020, pos={2747.504,200.042,-2401.418}, radius=5,isImportant=true},
--["sovietBase_q20912"]={locationId=30010, pos={-1573.917,369.848,-321.113}, radius=5,isImportant=true},
--["tent_q20910"]={locationId=30010, pos={-865.471,300.445,1949.157}, radius=5,isImportant=true},
--["fort_q20911"]={locationId=30010, pos={2181.73,470.912,-1815.881}, radius=5,isImportant=true},
--["waterway_q99012"]={locationId=30010, pos={-1335.904,398.264,-739.165}, radius=5,isImportant=true},
----["mtbs_q42010"]={locationId=TppDefine.LOCATION_ID.MTBS,clusterId=TppDefine.CLUSTER_DEFINE.Command,plntId=TppDefine.PLNT_DEFINE.Special},
----["mtbs_q42020"]={locationId=TppDefine.LOCATION_ID.MTBS,clusterId=TppDefine.CLUSTER_DEFINE.Develop,plntId=TppDefine.PLNT_DEFINE.Special},
----["mtbs_q42030"]={locationId=TppDefine.LOCATION_ID.MTBS,clusterId=TppDefine.CLUSTER_DEFINE.Support,plntId=TppDefine.PLNT_DEFINE.Special},
----["mtbs_q42040"]={locationId=TppDefine.LOCATION_ID.MTBS,clusterId=TppDefine.CLUSTER_DEFINE.BaseDev,plntId=TppDefine.PLNT_DEFINE.Special},
----["mtbs_q42060"]={locationId=TppDefine.LOCATION_ID.MTBS,clusterId=TppDefine.CLUSTER_DEFINE.Spy,plntId=TppDefine.PLNT_DEFINE.Special},
----["mtbs_q42050"]={locationId=TppDefine.LOCATION_ID.MTBS,clusterId=TppDefine.CLUSTER_DEFINE.Medical,plntId=TppDefine.PLNT_DEFINE.Special},
----["mtbs_q42070"]={locationId=TppDefine.LOCATION_ID.MTBS,clusterId=TppDefine.CLUSTER_DEFINE.Combat,plntId=TppDefine.PLNT_DEFINE.Special}
--
--}

local function n()
	if QuarkSystem.GetCompilerState()==QuarkSystem.COMPILER_STATE_WAITING_TO_LOAD then
		QuarkSystem.PostRequestToLoad()coroutine.yield()
		while QuarkSystem.GetCompilerState()==QuarkSystem.COMPILER_STATE_WAITING_TO_LOAD do
			coroutine.yield()
		end
	end
end
function this.DisableGameStatus()
	TppMission.DisableInGameFlag()
	Tpp.SetGameStatus{target="all",enable=false,except={S_DISABLE_NPC=false},scriptName="TppMain.lua"}
end
function this.DisableGameStatusOnGameOverMenu()
	TppMission.DisableInGameFlag()
	Tpp.SetGameStatus{target="all",enable=false,scriptName="TppMain.lua"}
end
function this.EnableGameStatus()
	TppMission.EnableInGameFlag()
	Tpp.SetGameStatus{target={S_DISABLE_PLAYER_PAD=true,S_DISABLE_TARGET=true,S_DISABLE_NPC=true,S_DISABLE_NPC_NOTICE=true,S_DISABLE_PLAYER_DAMAGE=true,S_DISABLE_THROWING=true,S_DISABLE_PLACEMENT=true},enable=true,scriptName="TppMain.lua"}
end
function this.EnableGameStatusForDemo()
	TppDemo.ReserveEnableInGameFlag()
	Tpp.SetGameStatus{target={S_DISABLE_PLAYER_PAD=true,S_DISABLE_TARGET=true,S_DISABLE_NPC=true,S_DISABLE_NPC_NOTICE=true,S_DISABLE_PLAYER_DAMAGE=true,S_DISABLE_THROWING=true,S_DISABLE_PLACEMENT=true},enable=true,scriptName="TppMain.lua"}
end
function this.EnableAllGameStatus()
	TppMission.EnableInGameFlag()
	Tpp.SetGameStatus{target="all",enable=true,scriptName="TppMain.lua"}
end
function this.EnablePlayerPad()
	TppGameStatus.Reset("TppMain.lua","S_DISABLE_PLAYER_PAD")
end
function this.DisablePlayerPad()
	TppGameStatus.Set("TppMain.lua","S_DISABLE_PLAYER_PAD")
end
function this.EnablePause()
	--TUPPMLog.Log("TppMain.EnablePause START",1)
	TppPause.RegisterPause"TppMain.lua"
	--TUPPMLog.Log("TppMain.EnablePause END",1)
end
function this.DisablePause()
	TppPause.UnregisterPause"TppMain.lua"
end
function this.EnableBlackLoading(e)
	TppGameStatus.Set("TppMain.lua","S_IS_BLACK_LOADING")
	if e then
		--r45 Loading tips are not shown if Debug Mode is On
		if not TUPPMSettings._debug_ENABLE then
			TppUI.StartLoadingTips() --rX44 DEBUG AID--
		end
	end
end
function this.DisableBlackLoading()
	TppGameStatus.Reset("TppMain.lua","S_IS_BLACK_LOADING")
	TppUI.FinishLoadingTips()
end
function this.OnAllocate(missionTable)
	--TUPPMLog.Log("TppMain.OnAllocate START",1)
	TppWeather.OnEndMissionPrepareFunction()

	if TppMission.IsFOBMission(vars.missionCode) then
		--r51 Custom weather related fix for FOBs
		--This EXTRA setting may seem redundant BUT this ensures that
		--any custom weather modifications are not reflected on FOBs
		--These functions are called from TppMain.OnMissionCanStart() but by then the game
		--would have already used the custom settings to decide the very first weather type on the FOB
		--Again one of the workarounds for poorly written code by KJP
		TppWeather.SetDefaultWeatherProbabilities()
		TppWeather.SetDefaultWeatherDurations()
	end

	this.DisableGameStatus()
	this.EnablePause()
	TppClock.Stop()
	moduleUpdateFuncs={}
	moduleUpdateFuncsSize=0
	UNKsomeTable1={}
	UNKsomeTable1Size=0
	TppUI.FadeOut(TppUI.FADE_SPEED.FADE_MOMENT,nil,nil)
	TppSave.WaitingAllEnqueuedSaveOnStartMission()
	if TppMission.IsFOBMission(vars.missionCode)then
		TppMission.SetFOBMissionFlag()
		TppGameStatus.Set("Mission","S_IS_ONLINE")
	else
		TppGameStatus.Reset("Mission","S_IS_ONLINE")
	end
	Mission.Start()
	TppMission.WaitFinishMissionEndPresentation()
	TppMission.DisableInGameFlag()
	TppException.OnAllocate(missionTable)
	TppClock.OnAllocate(missionTable)
	TppTrap.OnAllocate(missionTable)
	TppCheckPoint.OnAllocate(missionTable)
	TppUI.OnAllocate(missionTable)
	TppDemo.OnAllocate(missionTable)
	TppScriptBlock.OnAllocate(missionTable)
	TppSound.OnAllocate(missionTable)
	TppPlayer.OnAllocate(missionTable)
	TppMission.OnAllocate(missionTable)
	TppTerminal.OnAllocate(missionTable)
	TppEnemy.OnAllocate(missionTable)
	TppRadio.OnAllocate(missionTable)
	TppGimmick.OnAllocate(missionTable)
	TppMarker.OnAllocate(missionTable)
	TppRevenge.OnAllocate(missionTable)
	this.ClearStageBlockMessage()
	TppQuest.OnAllocate(missionTable)
	TppAnimal.OnAllocate(missionTable)

	--r58 Custom weapons and suppressors settings
	TUPPM.SetCustomWeaponSettings()
	--r61 Separated camo setting
	TUPPM.SetCustomCamoSettings()
	--r51 Settings
	TUPPM.SetCustomSoldierParams()

	local function locationOnAllocate()
		if TppLocation.IsAfghan()then
			if afgh then
				afgh.OnAllocate()
			end
		elseif TppLocation.IsMiddleAfrica()then
			if mafr then
				mafr.OnAllocate()
			end
		elseif TppLocation.IsCyprus()then
			if cypr then
				cypr.OnAllocate()
			end
		elseif TppLocation.IsMotherBase()then
			if mtbs then
				mtbs.OnAllocate()
			end
		end
	end
	locationOnAllocate()
	if missionTable.sequence then
		if f30050_sequence then
			function f30050_sequence.NeedPlayQuietWishGoMission()
				local i=TppQuest.IsCleard"mtbs_q99011"
				local n=not TppDemo.IsPlayedMBEventDemo"QuietWishGoMission"
				local e=TppDemo.GetMBDemoName()==nil
				return(i and n)and e
			end
		end
		if IsTypeFunc(missionTable.sequence.MissionPrepare)then
			missionTable.sequence.MissionPrepare()
		end
		if IsTypeFunc(missionTable.sequence.OnEndMissionPrepareSequence)then
			TppSequence.SetOnEndMissionPrepareFunction(missionTable.sequence.OnEndMissionPrepareSequence)
		end
	end
	for name,scriptName in pairs(missionTable)do
		if IsTypeFunc(scriptName.OnLoad)then
			scriptName.OnLoad()
		end
	end
	do
		local a={}
		for i,e in ipairs(Tpp._requireList)do
			if _G[e]then
				if _G[e].DeclareSVars then
					ApendArray(a,_G[e].DeclareSVars(missionTable))
				end
			end
		end
		local o={}
		for n,e in pairs(missionTable)do
			if IsTypeFunc(e.DeclareSVars)then
				ApendArray(o,e.DeclareSVars())
			end
			if IsTypeTable(e.saveVarsList)then
				ApendArray(o,TppSequence.MakeSVarsTable(e.saveVarsList))
			end
		end
		if OnlineChallengeTask then
			ApendArray(o,OnlineChallengeTask.DeclareSVars())
		end
		ApendArray(a,o)
		TppScriptVars.DeclareSVars(a)
		TppScriptVars.SetSVarsNotificationEnabled(false)
		while IsSavingOrLoading()do
			coroutine.yield()
		end
		TppRadioCommand.SetScriptDeclVars()
		local mbLayoutCode=vars.mbLayoutCode
		--TUPPMLog.Log("TppMain.OnAllocate INITIALIZED mbLayoutCode: "..tostring(mbLayoutCode),3,true)
		--TUPPMLog.Log("TppMain.OnAllocate INITIALIZED vars.mbLayoutCode: "..tostring(vars.mbLayoutCode),3,true)
		if gvars.ini_isTitleMode then
			TppPlayer.MissionStartPlayerTypeSetting()
		else
			if TppMission.IsMissionStart()then
				TppVarInit.InitializeForNewMission(missionTable)
				TppPlayer.MissionStartPlayerTypeSetting()
				if not TppMission.IsFOBMission(vars.missionCode)then
					TppSave.VarSave(vars.missionCode,true)
				end
			else
				TppVarInit.InitializeForContinue(missionTable)
			end
			--r19 Special check when coming from title screen
			if gvars.isContinueFromTitle then
				canRandomizeVehiclesAsComingFromTitle = true
				--r35 For resetting gimmicks
				cannotResetGimmicksAsComingFromTitle = true
				--r66 BUGFIX minor - takes care of restarts/checkpoints
				if TUPPMSettings.heli_ENABLE_skipRides then
					--r45 Fob MB soldiers
					this.comingFromTitleDontFireHeliRemoval = true
				end
			end
			TppVarInit.ClearIsContinueFromTitle()
		end
		TppUiCommand.ExcludeNonPermissionContents()
		TppStory.SetMissionClearedS10030()
		if(not TppMission.IsDefiniteMissionClear())then
			TppTerminal.StartSyncMbManagementOnMissionStart()
		end
		if TppLocation.IsMotherBase()then
			if mbLayoutCode~=vars.mbLayoutCode then
				if vars.missionCode==30050 then
					--TUPPMLog.Log("TppMain.OnAllocate mbLayoutCode~=vars.mbLayoutCode AND vars.missionCode==30050 BEFORE mbLayoutCode: "..tostring(mbLayoutCode),3,true)
					--TUPPMLog.Log("TppMain.OnAllocate mbLayoutCode~=vars.mbLayoutCode AND vars.missionCode==30050 BEFORE vars.mbLayoutCode: "..tostring(vars.mbLayoutCode),3,true)
					vars.mbLayoutCode=mbLayoutCode
					--TUPPMLog.Log("TppMain.OnAllocate mbLayoutCode~=vars.mbLayoutCode AND vars.missionCode==30050 AFTER vars.mbLayoutCode: "..tostring(mbLayoutCode),3,true)
					--TUPPMLog.Log("TppMain.OnAllocate mbLayoutCode~=vars.mbLayoutCode AND vars.missionCode==30050 AFTER vars.mbLayoutCode: "..tostring(vars.mbLayoutCode),3,true)
				else
					--TUPPMLog.Log("TppMain.OnAllocate vars.missionCode~=30050 BEFORE vars.mbLayoutCode: "..tostring(vars.mbLayoutCode),3,true)
					vars.mbLayoutCode=TppLocation.ModifyMbsLayoutCode(TppMotherBaseManagement.GetMbsTopologyType())
					--TUPPMLog.Log("TppMain.OnAllocate vars.missionCode~=30050 AFTER vars.mbLayoutCode: "..tostring(vars.mbLayoutCode),3,true)
				end
			end
		end
		TppPlayer.FailSafeInitialPositionForFreePlay()
		this.StageBlockCurrentPosition(true)
		TppMission.SetSortieBuddy()
		if vars.missionCode~=10260 then
			TppMission.ResetQuietEquipIfUndevelop()
		end
		TppStory.UpdateStorySequence{updateTiming="BeforeBuddyBlockLoad"}
		if missionTable.sequence then
			local e=missionTable.sequence.DISABLE_BUDDY_TYPE

			--rX5 Enable buddies on MB
			--      if TppMission.IsMbFreeMissions(vars.missionCode) then--tex no DISABLE_BUDDY_TYPE
			--        e=nil
			--      end--

			if e then
				local n
				if IsTypeTable(e)then
					n=e
				else
					n={e}
				end
				for n,e in ipairs(n)do
					TppBuddyService.SetDisableBuddyType(e)
				end
			end
		end
		if(vars.missionCode==11043)or(vars.missionCode==11044)then
			TppBuddyService.SetDisableAllBuddy()
		end
		if TppGameSequence.GetGameTitleName()=="TPP"then
			if missionTable.sequence and missionTable.sequence.OnBuddyBlockLoad then
				missionTable.sequence.OnBuddyBlockLoad()
			end
			if TppLocation.IsAfghan()or TppLocation.IsMiddleAfrica()then
				TppBuddy2BlockController.Load()
			end
		end
		TppSequence.SaveMissionStartSequence()
		TppScriptVars.SetSVarsNotificationEnabled(true)
	end
	if missionTable.enemy then
		if IsTypeTable(missionTable.enemy.soldierPowerSettings)then
			TppEnemy.SetUpPowerSettings(missionTable.enemy.soldierPowerSettings)
		end
	end
	TppRevenge.DecideRevenge(missionTable)
	if TppEquip.CreateEquipMissionBlockGroup then
		if(vars.missionCode>6e4)then
			TppEquip.CreateEquipMissionBlockGroup{size=(380*1024)*24}
		else
			TppPlayer.SetEquipMissionBlockGroupSize()
		end
	end
	if TppEquip.CreateEquipGhostBlockGroups then
		if TppSystemUtility.GetCurrentGameMode()=="MGO"then
			TppEquip.CreateEquipGhostBlockGroups{ghostCount=16}
		elseif TppMission.IsFOBMission(vars.missionCode)then
			TppEquip.CreateEquipGhostBlockGroups{ghostCount=1}
		end
	end
	TppEquip.StartLoadingToEquipMissionBlock()
	TppPlayer.SetMaxPickableLocatorCount()
	TppPlayer.SetMaxPlacedLocatorCount()
	--rX45 Instance limits for enemy equip?
	TppEquip.AllocInstances{instance=60,realize=60}
	TppEquip.ActivateEquipSystem()
	if TppEnemy.IsRequiredToLoadDefaultSoldier2CommonPackage()then
		TppEnemy.LoadSoldier2CommonBlock()
	end
	if missionTable.sequence then
		mvars.mis_baseList=missionTable.sequence.baseList
		TppCheckPoint.RegisterCheckPointList(missionTable.sequence.checkPointList)
	end
	--TUPPMLog.Log("TppMain.OnAllocate END",1)
	--RETAILPATCH 1.12 >
	if not TppMission.IsFOBMission(vars.missionCode)then
		TppPlayer.ForceChangePlayerFromOcelot()
	end
	--RETAILPATCH 1.12 <
end
--r28 update
function this.OnInitialize(missionTable)
	--r19 More Vehicles
	--r51 Settings
	if (TUPPMSettings.game_ENABLE_armoredVehiclesAndTanksInFreeRoam or TUPPMSettings.wildcard_ENABLE)
		and (vars.missionCode==30010 or vars.missionCode==30020) then
		this.SpecialInitialize(missionTable)
	end

	--TODO	--rX51
	--	this.ResetAACRs()

	if TppMission.IsFOBMission(vars.missionCode)then
		TppMission.SetFobPlayerStartPoint()
	elseif TppMission.IsNeedSetMissionStartPositionToClusterPosition()then
		TppMission.SetMissionStartPositionMtbsClusterPosition()
		this.StageBlockCurrentPosition(true)
	else
		TppCheckPoint.SetCheckPointPosition()
	end
	if TppEnemy.IsRequiredToLoadSpecialSolider2CommonBlock()then
		TppEnemy.LoadSoldier2CommonBlock()
	end
	if TppMission.IsMissionStart()then
		TppTrap.InitializeVariableTraps()
	else
		TppTrap.RestoreVariableTrapState()
	end
	TppAnimalBlock.InitializeBlockStatus()
	if TppQuestList then
		TppQuest.RegisterQuestList(TppQuestList.questList)
		TppQuest.RegisterQuestPackList(TppQuestList.questPackList)
	end
	TppHelicopter.AdjustBuddyDropPoint()
	--r43 Override vehicle spawn position so they don't crash into the heli
	-- mission specificic positioning is done next

	--r51 Settings
	if TUPPMSettings.heli_ENABLE_skipRides then
		this.OverrideVehiclePos2(missionTable)
	end

	if missionTable.sequence then
		local e=missionTable.sequence.NPC_ENTRY_POINT_SETTING
		if IsTypeTable(e)then
			TppEnemy.NPCEntryPointSetting(e)
		end
	end
	TppLandingZone.OverwriteBuddyVehiclePosForALZ()
	if missionTable.enemy then
		if IsTypeTable(missionTable.enemy.vehicleSettings)then
			TppEnemy.SetUpVehicles()
		end
		if IsTypeFunc(missionTable.enemy.SpawnVehicleOnInitialize)then
			missionTable.enemy.SpawnVehicleOnInitialize()
		end
		TppReinforceBlock.SetUpReinforceBlock()
	end
	for i,e in pairs(missionTable)do
		if IsTypeFunc(e.Messages)then
			missionTable[i]._messageExecTable=Tpp.MakeMessageExecTable(e.Messages())
		end
	end
	if mvars.loc_locationCommonTable then
		mvars.loc_locationCommonTable.OnInitialize()
	end

	--r51 Settings
	if TUPPMSettings.rev_ENABLE_2ndStrongestMines then
		this.ModifyMineTypes() --r33 Modify mines
	end

	TppLandingZone.OnInitialize()

	--  --r51
	--	this.ResetAACRs()

	for i,e in ipairs(Tpp._requireList)do
		if _G[e].Init then
			_G[e].Init(missionTable)
		end
	end
	if OnlineChallengeTask then
		OnlineChallengeTask.Init()
	end
	if missionTable.enemy then
		if GameObject.DoesGameObjectExistWithTypeName"TppSoldier2"then
			GameObject.SendCommand({type="TppSoldier2"},{id="CreateFaceIdList"})
		end
		if IsTypeTable(missionTable.enemy.soldierDefine)then
			TppEnemy.DefineSoldiers(missionTable.enemy.soldierDefine)
		end
		if missionTable.enemy.InitEnemy and IsTypeFunc(missionTable.enemy.InitEnemy)then
			missionTable.enemy.InitEnemy()
		end
		if IsTypeTable(missionTable.enemy.soldierPersonalAbilitySettings)then
			TppEnemy.SetUpPersonalAbilitySettings(missionTable.enemy.soldierPersonalAbilitySettings)
		end
		if IsTypeTable(missionTable.enemy.travelPlans)then
			TppEnemy.SetTravelPlans(missionTable.enemy.travelPlans)
		end
		TppEnemy.SetUpSoldiers()
		if IsTypeTable(missionTable.enemy.soldierDefine)then
			TppEnemy.InitCpGroups()
			TppEnemy.RegistCpGroups(missionTable.enemy.cpGroups)
			TppEnemy.SetCpGroups()
			if mvars.loc_locationGimmickCpConnectTable then
				TppGimmick.SetCommunicateGimmick(mvars.loc_locationGimmickCpConnectTable)
			end
		end
		if IsTypeTable(missionTable.enemy.interrogation)then
			TppInterrogation.InitInterrogation(missionTable.enemy.interrogation)
		end
		if IsTypeTable(missionTable.enemy.useGeneInter)then
			TppInterrogation.AddGeneInter(missionTable.enemy.useGeneInter)
		end
		if IsTypeTable(missionTable.enemy.uniqueInterrogation)then
			TppInterrogation.InitUniqueInterrogation(missionTable.enemy.uniqueInterrogation)
		end
		do
			local e
			if IsTypeTable(missionTable.enemy.routeSets)then
				e=missionTable.enemy.routeSets
				for e,n in pairs(e)do
					if not IsTypeTable(mvars.ene_soldierDefine[e])then
					end
				end
			end
			if e then
				--rX47 - Randomizing soldier routes
				--TUPPMLog.Log("Setting route switch info for CPs "..tostring(vars.missionCode),3)
				TppEnemy.RegisterRouteSet(e)
				TppEnemy.MakeShiftChangeTable()
				TppEnemy.SetUpCommandPost()
				TppEnemy.SetUpSwitchRouteFunc()
			end
		end
		if missionTable.enemy.soldierSubTypes then
			TppEnemy.SetUpSoldierSubTypes(missionTable.enemy.soldierSubTypes)
		end
		TppRevenge.SetUpEnemy()
		TppEnemy.ApplyPowerSettingsOnInitialize()
		TppEnemy.ApplyPersonalAbilitySettingsOnInitialize()
		TppEnemy.SetOccasionalChatList()
		TppEneFova.ApplyUniqueSetting()
		if missionTable.enemy.SetUpEnemy and IsTypeFunc(missionTable.enemy.SetUpEnemy)then
			missionTable.enemy.SetUpEnemy()
		end
		if TppMission.IsMissionStart()then
			TppEnemy.RestoreOnMissionStart2()
		else
			TppEnemy.RestoreOnContinueFromCheckPoint2()
		end
	end
	if not TppMission.IsMissionStart()then
		TppWeather.RestoreFromSVars()
		TppMarker.RestoreMarkerLocator()
	end
	TppPlayer.RestoreSupplyCbox()
	TppPlayer.RestoreSupportAttack()
	TppTerminal.MakeMessage()
	if missionTable.sequence then
		local e=missionTable.sequence.SetUpRoutes
		if e and IsTypeFunc(e)then
			e()
		end
		TppEnemy.RegisterRouteAnimation()
		local e=missionTable.sequence.SetUpLocation
		if e and IsTypeFunc(e)then
			e()
		end
	end
	for n,e in pairs(missionTable)do
		if e.OnRestoreSVars then
			e.OnRestoreSVars()
		end
	end
	TppMission.RestoreShowMissionObjective()
	TppRevenge.SetUpRevengeMine()
	if TppPickable.StartToCreateFromLocators then
		TppPickable.StartToCreateFromLocators()
	end
	if TppPlaced and TppPlaced.StartToCreateFromLocators then
		TppPlaced.StartToCreateFromLocators()
	end
	if TppMission.IsMissionStart()then
		TppRadioCommand.RestoreRadioState()
	else
		TppRadioCommand.RestoreRadioStateContinueFromCheckpoint()
	end
	TppMission.SetPlayRecordClearInfo()
	TppChallengeTask.RequestUpdateAllChecker()
	TppMission.PostMissionOrderBoxPositionToBuddyDog()
	this.SetUpdateFunction(missionTable)
	this.SetMessageFunction(missionTable)
	TppQuest.UpdateActiveQuest()
	TppDevelopFile.OnMissionCanStart()
	if TppMission.GetMissionID()==30010 or TppMission.GetMissionID()==30020 then
		if TppQuest.IsActiveQuestHeli()then
			TppEnemy.ReserveQuestHeli()
		end
	end
	TppDemo.UpdateNuclearAbolitionFlag()
	TppQuest.AcquireKeyItemOnMissionStart()
	--r28 update
	this.DoSpecialThings(missionTable)
end
function this.SetUpdateFunction(missionTable)
	moduleUpdateFuncs={}
	moduleUpdateFuncsSize=0
	missionScriptOnUpdateFuncs={}
	missionScriptOnUpdateFuncsSize=0
	UNKsomeTable1={}
	UNKsomeTable1Size=0
	moduleUpdateFuncs={
		TppMission.Update,
		TppSequence.Update,
		TppSave.Update,
		TppDemo.Update,
		TppPlayer.Update,
		TppMission.UpdateForMissionLoad
	}

	--r65 Enabled TUPPM update function
	table.insert(moduleUpdateFuncs, TUPPM.Update)

	moduleUpdateFuncsSize=#moduleUpdateFuncs
	for n,e in pairs(missionTable)do
		if IsTypeFunc(e.OnUpdate)then
			missionScriptOnUpdateFuncsSize=missionScriptOnUpdateFuncsSize+1
			missionScriptOnUpdateFuncs[missionScriptOnUpdateFuncsSize]=e.OnUpdate
		end
	end
end
function this.OnEnterMissionPrepare()
	if TppMission.IsMissionStart()then
		TppScriptBlock.PreloadSettingOnMissionStart()
	end
	TppScriptBlock.ReloadScriptBlock()
end
function this.OnTextureLoadingWaitStart()
	if not TppMission.IsHelicopterSpace(vars.missionCode)then
		StageBlockCurrentPositionSetter.SetEnable(false)
	end
	gvars.canExceptionHandling=true
end
function this.OnMissionStartSaving()
end
function this.OnMissionCanStart()
	if TppMission.IsMissionStart()then
		TppWeather.SetDefaultWeatherProbabilities()
		TppWeather.SetDefaultWeatherDurations()
		if(not gvars.ini_isTitleMode)and(not TppMission.IsFOBMission(vars.missionCode))then
			TppSave.VarSave(nil,true)
		end
	end
	TppLocation.ActivateBlock()
	TppWeather.OnMissionCanStart()
	TppMarker.OnMissionCanStart()
	TppResult.OnMissionCanStart()
	TppQuest.InitializeQuestLoad()
	TppRatBird.OnMissionCanStart()
	TppMission.OnMissionStart()
	if mvars.loc_locationCommonTable then
		mvars.loc_locationCommonTable.OnMissionCanStart()
	end
	TppLandingZone.OnMissionCanStart()
	TppOutOfMissionRangeEffect.Disable(0)
	if TppLocation.IsMiddleAfrica()then
		TppGimmick.MafrRiverPrimSetting()
	end
	if MotherBaseConstructConnector.RefreshGimmicks then
		if vars.locationCode==TppDefine.LOCATION_ID.MTBS then
			MotherBaseConstructConnector.RefreshGimmicks()
		end
	end
	if vars.missionCode==10240 and TppLocation.IsMBQF()then
		Player.AttachGasMask()
	end
	if(vars.missionCode==10150)then
		local e=TppSequence.GetMissionStartSequenceIndex()
		if(e~=nil)and(e<TppSequence.GetSequenceIndex"Seq_Game_SkullFaceToPlant")then
			if(svars.mis_objectiveEnable[17]==false)then
				Gimmick.ForceResetOfRadioCassetteWithCassette()
			end
		end
	end
	--TODO rX45 Maybe use this place as a hook to open heli doors and do other heli related stuff, maybe timers also?
	--rX45 Possible to change stance, but why bother
	--  if this.firstFakeHeli==1 then
	--  	Player.RequestToSetTargetStance(PlayerStance.SQUAT)
	--  end

	--r55 Safely adjust player pos if mb layout code has changed
	this.PlayerStartOnFootMBSafetyNet()

	--r51 Settings
	this.ForceChangeWildWeather()

	--	this.ReloadDevFiles() --rX46 Cannot reload these files - forget it, when connected online a different table is used for deployment costs anyway even if some offline item costs are updated as well
	this.ForceCreateHeli() --r46 Moved create heli call here - works better for setting MB soldiers on 1st platform to Salute
	TppEnemy.SetCustomShift(true) --r48 Set random shift timer every time a mission starts

	--TppBuddyService.SummonBuddy() --rX50 does summon buddy but does not help with them jumping out of closed heli door

	--r56 Change heli life
	TUPPM.SetHeliLife()

	--r66 Custom UI markers settings
	TUPPM.ChangeUIElements()

	--TODO --rX66 Zombie testing
	--	this.SetZombie()
	--	this.UnSetZombie()

	TUPPMLog.Log("TppMain.OnMissionCanStart END",3)
end

--r55 Safely adjust player pos if mb layout code has changed
--r55 Fix for MB on foot starts after upgrading Command cluster
function this.PlayerStartOnFootMBSafetyNet()
	if not TUPPMSettings.heli_ENABLE_skipRides then return end

	--The sole purpose of this function is to warp the player to the same LZ start pos
	--This acts as a safety net when Command cluster layout changes, hence
	--changing vars.mbLayoutCode but is not reflected in ReservePlayerLoadingPosition as
	--vars.mbLayoutCode is only updated in TppMission.Load
	if vars.missionCode~=30050 then return end
	if this.recordedMbLayoutCode==vars.mbLayoutCode then return end

	TUPPMLog.Log("TppMain.PlayerStartOnFootMBSafetyNet conditions valid",3)

	if gvars.heli_missionStartRoute==nil then
		return
	end

	local route = TppMain.GetUsingRouteDetails()
	if route==nil then
		return
	end

	local posX=route.pos[1]
	local posY=route.pos[2]
	local posZ=route.pos[3]

	--Roof LZs and other LZs need a height adjustment to avoid fall animation
	if posY<9 then
		posY=posY-5
	else
		--Roof LZs
		posY=posY-3
	end

	local pos={posX,posY,posZ}
	TppPlayer.Warp{pos=pos,rotY=route.rotY}

end

--rX46 Trying to reload dev file info - doesn't work
--Script.LoadLibrary seems to be a one time load and run thing
function this.ReloadDevFiles()
	TUPPMLog.Log("TppMain.ReloadDevFiles BEG",3)

	local function YieldFrame()
		coroutine.yield()
	end

	--rX46 I think Script.LoadLibrary loads a lua script once and executes it. If called again it checks if the script was loaded earlier and does not load/run it hence
	--What I am thinking is that it loads the library into memory ONCE and executes it. Any future calls check if the lib is loaded and do not load/run it.
	--	Script.LoadLibrary"/Assets/tpp/motherbase/script/EquipDevelopConstSetting.lua" --nope costs "patched" after connecting online are not reset by this call
	--	TUPPMLog.Log("LoadLibrary EquipDevelopConstSetting",3)
	----  coroutine.yield() --nope game does not load
	--  Script.LoadLibrary"/Assets/tpp/motherbase/script/EquipDevelopFlowSetting.lua" --nope costs "patched" after connecting online are not reset by this call
	--	TUPPMLog.Log("LoadLibrary EquipDevelopFlowSetting",3)
	----  coroutine.yield() --nope game does not load
	--
	--	Script.LoadLibraryAsync"/Assets/tpp/motherbase/script/EquipDevelopConstSetting.lua" --nope costs "patched" after connecting online are not reset by this call
	--	TUPPMLog.Log("LoadLibraryAsync EquipDevelopConstSetting",3)
	--  Script.LoadLibraryAsync"/Assets/tpp/motherbase/script/EquipDevelopFlowSetting.lua" --nope costs "patched" after connecting online are not reset by this call
	--	TUPPMLog.Log("LoadLibraryAsync EquipDevelopFlowSetting",3)

	--	dofile"/Assets/tpp/motherbase/script/EquipDevelopConstSetting.lua" --crashes game - weapons developed multiple times then :/
	--	TUPPMLog.Log("dofile EquipDevelopConstSetting",3)
	--  dofile"/Assets/tpp/motherbase/script/EquipDevelopFlowSetting.lua" --crashes game - weapons developed multiple times then :/
	--	TUPPMLog.Log("dofile EquipDevelopFlowSetting",3)

	--	Script.ReloadAll(true) --nope --messes up a lot more!

	TUPPMLog.Log("TppMain.ReloadDevFiles END",3)
end
function this.OnMissionGameStart(n)
	TppClock.Start()
	if not gvars.ini_isTitleMode then
		PlayRecord.RegistPlayRecord"MISSION_START"end
	TppQuest.InitializeQuestActiveStatus()
	if mvars.seq_demoSequneceList[mvars.seq_missionStartSequence]then
		this.EnableGameStatusForDemo()
	else
		this.EnableGameStatus()
	end
	if Player.RequestChickenHeadSound~=nil then
		Player.RequestChickenHeadSound()
	end
	TppTerminal.OnMissionGameStart()
	if TppSequence.IsLandContinue()then
		TppMission.EnableAlertOutOfMissionAreaIfAlertAreaStart()
	end
	TppSoundDaemon.ResetMute"Telop"end
function this.ClearStageBlockMessage()StageBlock.ClearLargeBlockNameForMessage()StageBlock.ClearSmallBlockIndexForMessage()
end

--> OLD ReservePlayerLoadingPosition
--r51 Preserve for historical purposes
--function this.ReservePlayerLoadingPosition(missionLoadType,isHeliSpace,isFreeMission,nextIsHeliSpace,nextIsFreeMission,abortWithSave,isLocationChange)
--	--r35 DO NOT DO THIS!
--	--  this.isFakeHeliDropRequired=false
--
--	--  TUPPMLog.Log("missionLoadType: "..tostring(missionLoadType))
--	--  TUPPMLog.Log("isHeliSpace: "..tostring(isHeliSpace))
--	--  TUPPMLog.Log("isFreeMission: "..tostring(isFreeMission))
--	--  TUPPMLog.Log("nextIsHeliSpace: "..tostring(nextIsHeliSpace))
--	--  TUPPMLog.Log("nextIsFreeMission: "..tostring(nextIsFreeMission))
--	--  TUPPMLog.Log("abortWithSave: "..tostring(abortWithSave))
--	--  TUPPMLog.Log("isLocationChange: "..tostring(isLocationChange))
--
--	this.DisableGameStatus()
--	if missionLoadType==TppDefine.MISSION_LOAD_TYPE.MISSION_FINALIZE then
--		if nextIsHeliSpace then
--			TppHelicopter.ResetMissionStartHelicopterRoute()
--			TppPlayer.ResetInitialPosition()
--			TppPlayer.ResetMissionStartPosition()
--			TppPlayer.ResetNoOrderBoxMissionStartPosition()
--			TppMission.ResetIsStartFromHelispace()
--			TppMission.ResetIsStartFromFreePlay()
--		elseif isHeliSpace then
--			--K Heavily changed existing code to ensure on foot deployment from ACC except for missions where the
--			-- the helicopter sequence is story relevant/part of the narrative
--			if gvars.heli_missionStartRoute~=0 then
--
--				if (vars.missionCode==TppDefine.SYS_MISSION_ID.FOB) --FOBs should always have heli ride so as not to break the timer
--					or(vars.missionCode==10054) --Mission 9 - Backup Back Down
--					or(vars.missionCode==11054) --Mission 34 - [Extreme] Backup, Back Down
--					or(vars.missionCode==10115) --Mission 22 - Retake the Platform
--					or(vars.missionCode==10080) --Mission 13 - Pitch Dark
--				--or(vars.missionCode==10260) --Mission 45 - A Quiet Exit --Useless makes no difference here; removed r03
--				--and(mvars.mis_helicopterMissionStartPosition) --r27 Bugfix - Smartass
--				then
--					TppPlayer.SetStartStatusRideOnHelicopter()
--					if mvars.mis_helicopterMissionStartPosition then --r27 Bugfix - Smartass
--						TppPlayer.SetInitialPosition(mvars.mis_helicopterMissionStartPosition,0)
--						TppPlayer.SetMissionStartPosition(mvars.mis_helicopterMissionStartPosition,0)
--					end
--				elseif (vars.missionCode==TppDefine.SYS_MISSION_ID.AFGH_FREE) --Afghanistan Free Roam no heli
--					or(vars.missionCode==TppDefine.SYS_MISSION_ID.MAFR_FREE) --Africa Free Roam no heli
--				--and(mvars.mis_helicopterMissionStartPosition) --r27 --r27 Bugfix - Smartass
--				then
--					--Improved Free Roam location spawning
--					--TUPPMLog.Log("Heli Route: "..tostring(gvars.heli_missionStartRoute))
--					--TUPPMLog.Log("Heli Route: "..gvars.heli_missionStartRoute) --numerical value
--					local coordinates=this.LZPositions[gvars.heli_missionStartRoute]--Credits: tinmantex
--
--					if coordinates then --r21 A bit of complicated but still workaround for regular MB rides
--						local position = coordinates.pos
--						local rotation = coordinates.rotY
--
--						--debugging
--						--          for k, v in pairs(position) do
--						--            TUPPMLog.Log(v)
--						--          end
--
--						--TUPPMLog.Log(groundStartPos)
--						--TUPPMLog.Log("rotation: "..tostring(rotation))
--
--						if rotation==nil then
--							--TUPPMLog.Log("rotation is nil")
--							rotation=0
--							--              rotation=math.random(360) --r27 start facing a random direction since am too lazy/hardworking to fix rotations
--						end
--
--						TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
--						TppPlayer.SetInitialPosition(position,rotation)
--						TppPlayer.SetMissionStartPosition(position,rotation)
--						--r35 Fake Heli Drop
--						this.isFakeHeliDropRequired=true
--						--            TppHelicopter.SetRouteToHelicopterOnStartMission() --rX6 Test
--
--						--r27 When starting on foot please fix Quiet's positions
--						--            local e={
--						--              [gvars.heli_missionStartRoute] = {
--						----                [EntryBuddyType.VEHICLE] = { Vector3(-1825.866, 350.025, -135.594), 90 },
--						--                [EntryBuddyType.BUDDY] = { Vector3(position), rotation },
--						--              },
--						--            }
--						--            if i(e)then
--						--              TppEnemy.NPCEntryPointSetting(e)
--						--              TUPPMLog.Log("Fixed buddy spawn position")
--						--            end
--
--						--r27 New logic for LZs conflicting with Side Ops areas - not useful as quest cps do not react to Heli landing
--						--Works but seems a bit off for some quest areas
--						--            local positionVector=Vector3(position)
--						--            local minDistance=math.huge
--						--            local minDistanceQuestName
--						--            local minDistanceQuestPositionVector
--						--            local minDistanceQuestRadius
--						--
--						--            for questName, details in pairs(sideOpsLZConflictTable) do
--						--
--						--              if vars.missionCode==details.locationId and TppQuest.IsActive(questName) then
--						--                TUPPMLog.Log(
--						--                      "questName: "..tostring(questName)
--						--                    ..", IsOpen: "..tostring(TppQuest.IsOpen(questName))
--						--                    ..", IsActive: "..tostring(TppQuest.IsActive(questName))
--						--                    )
--						--
--						--                local questPositionVector=Vector3(details.pos)
--						--                local distanceFromQuestCenterVector=positionVector-questPositionVector
--						--                local distanceFromCenter=distanceFromQuestCenterVector:GetLengthSqr()
--						--                --this is about x166 of the distance in meter
--						--                --determined by pure marker placing and moving around in game
--						--                --153m is distanceFromCenter 25,332 units
--						--                --radius of 6==320m
--						--                --so multiplier for radius should be (320/6)*166 = 8830.326797385621
--						--
--						--                --For DEBUGGING
--						--                if distanceFromCenter < minDistance then
--						--                  minDistance=distanceFromCenter
--						--                  minDistanceQuestName=questName
--						--                  minDistanceQuestPositionVector=questPositionVector
--						--                  minDistanceQuestRadius=details.radius
--						--                end
--						--
--						----                TUPPMLog.Log(
--						----                    "questName "..tostring(questName)
--						----                    ..", distanceFromCenter: "..tostring(distanceFromCenter)
--						----                    ..", radius: "..tostring(details.radius)
--						----                    )
--						--
--						--                if distanceFromCenter <= (details.radius*8830) then
--						--                  coordinates.hostile=true --UNCOMMENT for final functionality
--						--                  TUPPMLog.Log("LZ is within quest radius "..tostring(details.radius*8830))
--						--                end
--						--              end
--						--            end
--						--
--						--            --For DEBUGGING
--						--            TUPPMLog.Log(
--						--                    "Closest to quest "..tostring(minDistanceQuestName)
--						----                    ..", Center: "..tostring(minDistanceQuestPositionVector)
--						--                    ..", radius: "..tostring(minDistanceQuestRadius)
--						--                    ..", inGameRadius: "..tostring(minDistanceQuestRadius*8830)
--						--                    ..", distanceFromCenter: "..tostring(minDistance)
--						--                    )
--
--						--TODO rX6 use this
--						--            TppLandingZone.IsAssaultDropLandingZone(gvars.heli_missionStartRoute)
--
--						--rX45 DEBUG
--						--						coordinates.hostile=true --DEBUG
--						if coordinates.hostile then
--							--TUPPMLog.Log("Oh my its a hostile LZ so lets use the heli then")
--							--r45 BUGFIX
--							this.isFakeHeliDropRequired=false
--							TppPlayer.SetStartStatusRideOnHelicopter()
--							if mvars.mis_helicopterMissionStartPosition then --r27 --r27 Bugfix - Smartass
--								TppPlayer.SetInitialPosition(mvars.mis_helicopterMissionStartPosition,0)
--								TppPlayer.SetMissionStartPosition(mvars.mis_helicopterMissionStartPosition,0)
--							end
--						end
--					else --r21 A bit of complicated but still workaround for regular MB rides
--						TppPlayer.SetStartStatusRideOnHelicopter()
--						if mvars.mis_helicopterMissionStartPosition then --r27 --r27 Bugfix - Smartass
--							TppPlayer.SetInitialPosition(mvars.mis_helicopterMissionStartPosition,0)
--							TppPlayer.SetMissionStartPosition(mvars.mis_helicopterMissionStartPosition,0)
--						end
--					end
--
--				elseif (vars.missionCode==TppDefine.SYS_MISSION_ID.MTBS_FREE) --Code for spawing at any MB landing zone, otherwise will only spawn on Command Platform if not done right
--					or(vars.missionCode==TppDefine.SYS_MISSION_ID.MTBS_WARD) --MBQF given instant spawing to fit with rest of MB
--					or(vars.missionCode==TppDefine.SYS_MISSION_ID.MTBS_ZOO) --Zoo given given instant spawing otherwise only spawn on Central Zoo Platform
--				--          and(mvars.mis_helicopterMissionStartPosition) --r27 Bugfix - Smartass
--				then
--					--r45 BUGFIX for no heli rides patch
--					--          TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
--					--          if mvars.mis_helicopterMissionStartPosition then --r27 Bugfix - Smartass
--					--            --K this is the holy grail to land on any platform at MB/Zoo/MBQF and not the Central LZ only
--					--            -- Randomize MB rotations - works decently coolly
--					--            TppPlayer.SetMissionStartPosition(mvars.mis_helicopterMissionStartPosition,math.random(360))
--					--          end
--
--					--r45 BUGFIX for no heli rides patch
--					TppPlayer.SetStartStatusRideOnHelicopter()
--					if mvars.mis_helicopterMissionStartPosition then
--						TppPlayer.SetInitialPosition(mvars.mis_helicopterMissionStartPosition,0)
--						TppPlayer.SetMissionStartPosition(mvars.mis_helicopterMissionStartPosition,0)
--					end
--
--					if this.LZPositions[gvars.heli_missionStartRoute] then
--						--r45 Setting player start pos correctly now
--						local route=this.LZPositions[gvars.heli_missionStartRoute]
--						local position=route.pos
--						local rotY=route.rotY
--						if rotY==nil then rotY=math.random(360) end
--
--						TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
--						TppPlayer.SetInitialPosition(position,rotY)
--						TppPlayer.SetMissionStartPosition(position,rotY)
--
--						--r45  Enabled fake heli drop for MB
--						this.isFakeHeliDropRequired=true
--					end
--
--					--r27 When starting on foot please fix Quiet's positions
--					--          local e={
--					--            [gvars.heli_missionStartRoute] = {
--					----                [EntryBuddyType.VEHICLE] = { Vector3(-1825.866, 350.025, -135.594), 90 },
--					--              [EntryBuddyType.BUDDY] = { Vector3(position), rotation },
--					--            },
--					--          }
--					--          if i(e)then
--					--            TppEnemy.NPCEntryPointSetting(e)
--					--            TUPPMLog.Log("Fixed buddy spawn position")
--					--          end
--
--				else
--					if(vars.missionCode==10260)then --K Fix for starting Mission 45(A Quiet Exit) with heli ride from the ACC
--						-- It seems gvars.heli_missionStartRoute~=0 is true for Mission 45
--						-- but mvars.mis_helicopterMissionStartPosition is false
--						-- Now do stuff specific for Mission 45 - All other missions work correctly without this fix
--						local e=TppDefine.NO_ORDER_FIX_HELICOPTER_ROUTE[vars.missionCode]
--						if e then
--							TppPlayer.SetStartStatusRideOnHelicopter()
--							TppMission.SetIsStartFromHelispace()
--							TppMission.ResetIsStartFromFreePlay()
--						else
--							TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
--							TppHelicopter.ResetMissionStartHelicopterRoute()
--							TppMission.ResetIsStartFromHelispace()
--							TppMission.SetIsStartFromFreePlay()
--						end
--						local e=TppMission.GetMissionClearType()
--						TppQuest.SpecialMissionStartSetting(e)  --Special Mission include QUEST_BOSS_QUIET_BATTLE_END, QUEST_LOST_QUIET_END and QUEST_INTRO_RESCUE_EMERICH_END
--					else -- End doing stuff specific for Mission 45
--						--r18
--						--This code was incorrect yet worked. Instead of spawning at the LZ, the player would end up spawning at the very
--						-- first acceptable free roam mission start point - i think.
--						--            TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
--						--            local e=TppDefine.NO_HELICOPTER_MISSION_START_POSITION[vars.missionCode]
--						--
--						--            if e then
--						--              TppPlayer.SetInitialPosition(e,0)
--						--              TppPlayer.SetMissionStartPosition(e,0)
--						--            else
--						--              TppPlayer.ResetInitialPosition()
--						--              TppPlayer.ResetMissionStartPosition()
--						--            end
--
--						--r18
--						--TUPPMLog.Log("Fixed code for mission LZ landings")
--						--TUPPMLog.Log("Heli Route: "..tostring(gvars.heli_missionStartRoute))
--						--            TUPPMLog.Log("Heli Route: "..gvars.heli_missionStartRoute) --numerical value
--						local coordinates=this.LZPositions[gvars.heli_missionStartRoute]--Credits: tinmantex
--
--						if coordinates then --r21 A bit of complicated but still workaround for regular MB rides
--							local position = coordinates.pos
--							local rotation = coordinates.rotY
--
--							--debugging
--							--            for k, v in pairs(position) do
--							--              TUPPMLog.Log(v)
--							--            end
--
--							--              TUPPMLog.Log(position)
--							--TUPPMLog.Log("rotation: "..tostring(rotation))
--
--							--r28 Set some special mission based rotations
--							if not coordinates.hostile then
--								if vars.missionCode==10043 then --M4
--									rotation=102
--								elseif vars.missionCode==10090 then --M16
--									rotation=71
--								elseif vars.missionCode==10110 then --M20
--									rotation=131
--								else
--								end
--							end
--
--							--r28 All mission LZs covered so I dnt think this even matters anymore
--							if rotation==nil then
--								--TUPPMLog.Log("rotation is nil")
--								rotation=0
--								--r27 start facing a random direction since am too lazy/hardworking to fix rotations
--								--                rotation=math.random(360)
--							end
--
--							TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
--							TppPlayer.SetInitialPosition(position,rotation)
--							TppPlayer.SetMissionStartPosition(position,rotation)
--							--r35 Fake Heli Drop
--							this.isFakeHeliDropRequired=true
--
--							--r27 When starting on foot please fix Quiet's positions
--							--              local e={
--							--                [gvars.heli_missionStartRoute] = {
--							--  --                [EntryBuddyType.VEHICLE] = { Vector3(-1825.866, 350.025, -135.594), 90 },
--							--                  [EntryBuddyType.BUDDY] = { Vector3(position), rotation },
--							--                },
--							--              }
--							--              if i(e)then
--							--                TppEnemy.NPCEntryPointSetting(e)
--							--                TUPPMLog.Log("Fixed buddy spawn position")
--							--              end
--
--							--rX45 DEBUG
--							--							coordinates.hostile=true --DEBUG
--							if coordinates.hostile then
--								--TUPPMLog.Log("Oh my its a hostile LZ so lets use the heli then")
--								--r45 BUGFIX
--								this.isFakeHeliDropRequired=false
--								TppPlayer.SetStartStatusRideOnHelicopter()
--								if mvars.mis_helicopterMissionStartPosition then
--									TppPlayer.SetInitialPosition(mvars.mis_helicopterMissionStartPosition,0)
--									TppPlayer.SetMissionStartPosition(mvars.mis_helicopterMissionStartPosition,0)
--								end
--							end
--						else --r21 A bit of complicated but still workaround for regular MB rides
--							TppPlayer.SetStartStatusRideOnHelicopter()
--							if mvars.mis_helicopterMissionStartPosition then --r27 --r27 Bugfix - Smartass
--								TppPlayer.SetInitialPosition(mvars.mis_helicopterMissionStartPosition,0)
--								TppPlayer.SetMissionStartPosition(mvars.mis_helicopterMissionStartPosition,0)
--							end
--						end
--
--					end
--
--				end
--			else
--				--r27 Starting mission 22 from mission 21 - this was not the cause
--				--        if (vars.missionCode==10115) --Mission 22 - Retake the Platform
--				--          and(mvars.mis_helicopterMissionStartPosition)
--				--        then
--				--          TppPlayer.SetStartStatusRideOnHelicopter()
--				--          TppPlayer.SetInitialPosition(mvars.mis_helicopterMissionStartPosition,0)
--				--          TppPlayer.SetMissionStartPosition(mvars.mis_helicopterMissionStartPosition,0)
--				--        else
--				--r18 K If not starting a mission from ACC but starting from Free Roam then do this
--				TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
--				local e=TppDefine.NO_HELICOPTER_MISSION_START_POSITION[vars.missionCode]
--
--				if e then
--					TppPlayer.SetInitialPosition(e,0)
--					TppPlayer.SetMissionStartPosition(e,0)
--				else
--					TppPlayer.ResetInitialPosition()
--					TppPlayer.ResetMissionStartPosition()
--				end
--				--        end
--			end
--
--			TppPlayer.ResetNoOrderBoxMissionStartPosition()
--			TppMission.SetIsStartFromHelispace()
--			TppMission.ResetIsStartFromFreePlay()
--
--		elseif nextIsFreeMission then
--			if TppLocation.IsMotherBase()then
--				--        TUPPMLog.Log("nextIsFreeMission && TppLocation.IsMotherBase()") --between MB/Ward/Zoo
--				TppPlayer.SetStartStatusRideOnHelicopter()
--			else
--				--TppUiCommand.AnnounceLogView("else part - shouldn't be here")
--				--        TUPPMLog.Log("nextIsFreeMission && NOT TppLocation.IsMotherBase()")
--				TppPlayer.ResetInitialPosition()
--				TppHelicopter.ResetMissionStartHelicopterRoute()
--				TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
--				TppPlayer.SetMissionStartPositionToCurrentPosition()
--			end
--
--			--TppUiCommand.AnnounceLogView("after else")
--			TppPlayer.ResetNoOrderBoxMissionStartPosition()
--			TppMission.ResetIsStartFromHelispace()
--			TppMission.ResetIsStartFromFreePlay()
--
--			--      if gvars.heli_missionStartRoute then
--			--        TUPPMLog.Log("heli_missionStartRoute: "..gvars.heli_missionStartRoute)
--			--      end
--
--			if this.LZPositions[gvars.heli_missionStartRoute] then
--				--        TUPPMLog.Log("MB Starting on foot true")
--				local coordinates=this.LZPositions[gvars.heli_missionStartRoute]--Credits: tinmantex
--				local position = coordinates.pos
--				local rotation = coordinates.rotY
--
--				if rotation==nil then
--					rotation=math.random(360) --r27 start facing a random direction since am too lazy/hardworking to fix rotations
--				end
--
--				TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
--				TppPlayer.SetInitialPosition(position,rotation)
--				TppPlayer.SetMissionStartPosition(position,rotation)
--				--r35 Fake Heli Drop
--				--TODO Points do not work for MB it seems - need more testing
--				--r45 Enabled fake heli drop for MB
--				this.isFakeHeliDropRequired=true
--				--        TUPPMLog.Log("Set this.isFakeHeliDropRequired for MB free roam")
--			else
--				--TppUiCommand.AnnounceLogView("before special "..TppMission.GetMissionClearType())
--				TppLocation.MbFreeSpecialMissionStartSetting(TppMission.GetMissionClearType()) --Commenting this call leads to on foot spawing at core platform while traveling between MB/Zoo/MBQF, this is where the Heli-ride magic happens
--				--TppUiCommand.AnnounceLogView("after special "..TppMission.GetMissionClearType())
--			end
--
--
--		elseif(isFreeMission and TppLocation.IsMotherBase())then
--			--      TUPPMLog.Log("isFreeMission && TppLocation.IsMotherBase()")
--			if gvars.heli_missionStartRoute~=0 then
--				TppPlayer.SetStartStatusRideOnHelicopter()
--			else
--				TppPlayer.ResetInitialPosition()
--				TppPlayer.ResetMissionStartPosition()
--			end
--			TppPlayer.ResetNoOrderBoxMissionStartPosition()
--			TppMission.SetIsStartFromHelispace()
--			TppMission.ResetIsStartFromFreePlay()
--		else
--			if isFreeMission then
--				if mvars.mis_orderBoxName then
--					TppMission.SetMissionOrderBoxPosition()
--					TppPlayer.ResetNoOrderBoxMissionStartPosition()
--				else
--					TppPlayer.ResetInitialPosition()
--					TppPlayer.ResetMissionStartPosition()
--					local e={
--						[10020]={1449.3460693359,339.18698120117,1467.4300537109,-104}, --Mission 1 - Phantom Limbs
--						[10050]={-1820.7060546875,349.78659057617,-146.44400024414,139}, --Mission 11 - Cloaked in Silence
--						[10070]={-792.00512695313,537.3740234375,-1381.4598388672,136}, --Mission 12 - Hellbound
--						[10080]={-439.28802490234,-20.472593307495,1336.2784423828,-151}, --Mission 13 - Pitch Dark
--						[10140]={499.91635131836,13.07358455658,1135.1315917969,79}, --Mission 29 - Metallic Archaea
--						[10150]={-1732.0286865234,543.94067382813,-2225.7587890625,162}, --Mission 30 - Skull Face
--						[10260]={-1260.0454101563,298.75305175781,1325.6383056641,51} --Mission 45 - A Quiet Exit
--					}
--
--					e[11050]=e[10050] --Mission 40 - [Extreme] Cloaked in Silence
--					e[11080]=e[10080] --Mission 44 - [Total Stealth] Pitch Dark
--					e[11140]=e[10140] --Mission 42 - [Extreme] Metallic Archaea
--					e[10151]=e[10150] --Mission 31 - Sahelanthropus
--					e[11151]=e[10150] --Mission 50 - [Extreme] Sahelanthropus
--					local e=e[vars.missionCode]
--
--					if TppDefine.NO_ORDER_BOX_MISSION_ENUM[tostring(vars.missionCode)]and e then
--						TppPlayer.SetNoOrderBoxMissionStartPosition(e,e[4])
--					else
--						TppPlayer.ResetNoOrderBoxMissionStartPosition()
--					end
--				end
--
--				local e=TppDefine.NO_ORDER_FIX_HELICOPTER_ROUTE[vars.missionCode]
--
--				if e then
--					TppPlayer.SetStartStatusRideOnHelicopter()
--					TppMission.SetIsStartFromHelispace()
--					TppMission.ResetIsStartFromFreePlay()
--				else
--					TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
--					TppHelicopter.ResetMissionStartHelicopterRoute()
--					TppMission.ResetIsStartFromHelispace()
--					TppMission.SetIsStartFromFreePlay()
--				end
--
--				local e=TppMission.GetMissionClearType()
--				TppQuest.SpecialMissionStartSetting(e)
--
--			else
--				TppPlayer.ResetInitialPosition()
--				TppPlayer.ResetMissionStartPosition()
--				TppPlayer.ResetNoOrderBoxMissionStartPosition()
--				TppMission.ResetIsStartFromHelispace()
--				TppMission.ResetIsStartFromFreePlay()
--			end
--		end
--	elseif missionLoadType==TppDefine.MISSION_LOAD_TYPE.MISSION_ABORT then
--		TppPlayer.ResetInitialPosition()
--		TppHelicopter.ResetMissionStartHelicopterRoute()
--		TppMission.ResetIsStartFromHelispace()
--		TppMission.ResetIsStartFromFreePlay()
--		if abortWithSave then
--			if nextIsFreeMission then
--				TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
--				TppHelicopter.ResetMissionStartHelicopterRoute()
--				TppPlayer.SetMissionStartPositionToCurrentPosition()
--				TppPlayer.ResetNoOrderBoxMissionStartPosition()
--			elseif nextIsHeliSpace then
--				TppPlayer.ResetMissionStartPosition()
--			elseif vars.missionCode~=5 then
--			end
--		else
--			if nextIsHeliSpace then
--				TppHelicopter.ResetMissionStartHelicopterRoute()
--				TppPlayer.ResetInitialPosition()
--				TppPlayer.ResetMissionStartPosition()
--			elseif nextIsFreeMission then
--				TppMission.SetMissionOrderBoxPosition()
--			elseif vars.missionCode~=5 then
--			end
--		end
--	elseif missionLoadType==TppDefine.MISSION_LOAD_TYPE.MISSION_RESTART then
--	elseif missionLoadType==TppDefine.MISSION_LOAD_TYPE.CONTINUE_FROM_CHECK_POINT then
--	end
--
--	if isHeliSpace and isLocationChange then
--		Mission.AddLocationFinalizer(function()this.StageBlockCurrentPosition()
--			end)
--	else
--		this.StageBlockCurrentPosition()
--	end
--end
--< OLD ReservePlayerLoadingPosition

--r55 Better logic for picking start on foot pos and heli routes
this.recordedMbLayoutCode=nil
function this.GetUsingRouteDetails()
	local route=nil

	--	local mbLayoutCodeViaGetMbsTopologyTypeModifyMbsLayoutCode=TppLocation.ModifyMbsLayoutCode(TppMotherBaseManagement.GetMbsTopologyType()) --NOPE
	--
	--	local isBaseParamsApplied=TppLocation.ApplyPlatformParamToMbStage(30050,"MotherBase")
	--	local mbLayoutCodeViaTppDefineModifyMbsLayoutCode=TppLocation.ModifyMbsLayoutCode(0)
	--
	--	local mbCurrentLayout=MotherBaseStage.GetCurrentLayout()
	--
	--	local commandClusterGradeViaTppLocation=TppLocation.GetMbStageClusterGrade(1) --NOPE
	--	local commandClusterGradeViaTppMotherBaseManagement=TppMotherBaseManagement.GetMbsClusterGrade{category=TppDefine.CLUSTER_NAME[1]}

	if TppMission.IsMbFreeMissions(vars.missionCode) then
		route=this.LZPositionsMB[vars.mbLayoutCode][gvars.heli_missionStartRoute]
	else
		route=this.LZPositions[gvars.heli_missionStartRoute]
	end

	TUPPMLog.Log(
		"TppMain.GetUsingRouteDetails called from "..tostring(debug.getinfo(2,"Snl").name)
		.."\n gvars.heli_missionStartRoute:"..tostring(gvars.heli_missionStartRoute)
		.."\n mvars.mis_helicopterMissionStartPosition:"..tostring(InfInspect.Inspect(mvars.mis_helicopterMissionStartPosition))
		.."\n vars.mbLayoutCode:"..tostring(vars.mbLayoutCode)
		--	.."\n mvars.mis_nextLayoutCode:"..tostring(mvars.mis_nextLayoutCode)
		--	.."\n mbLayoutCodeViaGetMbsTopologyTypeModifyMbsLayoutCode:"..tostring(mbLayoutCodeViaGetMbsTopologyTypeModifyMbsLayoutCode)
		--	.."\n isBaseParamsApplied:"..tostring(isBaseParamsApplied)
		--	.."\n mbLayoutCodeViaTppDefineModifyMbsLayoutCode:"..tostring(mbLayoutCodeViaTppDefineModifyMbsLayoutCode)
		--	.."\n mbCurrentLayout:"..tostring(mbCurrentLayout)
		--	.."\n commandClusterGradeViaTppLocation:"..tostring(commandClusterGradeViaTppLocation)
		--	.."\n commandClusterGradeViaTppMotherBaseManagement:"..tostring(commandClusterGradeViaTppMotherBaseManagement)
		.."\n route:"..tostring(InfInspect.Inspect(route))
		,1)

	return route
end

--r35 Fake Heli Drop
this.isFakeHeliDropRequired=false

function this.ReservePlayerLoadingPosition(missionLoadType,isHeliSpace,isFreeMission,nextIsHeliSpace,nextIsFreeMission,abortWithSave,isLocationChange)

	TUPPMLog.Log(
		"TppMain.ReservePlayerLoadingPosition"
		.."\n vars.missionCode:"..tostring(vars.missionCode)
		.." vars.mbLayoutCode:"..tostring(vars.mbLayoutCode)
		.."\n missionLoadType:"..tostring(missionLoadType)
		.."\n isHeliSpace:"..tostring(isHeliSpace)
		.."\n isFreeMission:"..tostring(isFreeMission)
		.."\n nextIsHeliSpace:"..tostring(nextIsHeliSpace)
		.."\n nextIsFreeMission:"..tostring(nextIsFreeMission)
		.."\n abortWithSave:"..tostring(abortWithSave)
		.."\n isLocationChange:"..tostring(isLocationChange)
		,1)

	this.DisableGameStatus()
	if missionLoadType==TppDefine.MISSION_LOAD_TYPE.MISSION_FINALIZE then
		if nextIsHeliSpace then
			TppHelicopter.ResetMissionStartHelicopterRoute()
			TppPlayer.ResetInitialPosition()
			TppPlayer.ResetMissionStartPosition()
			TppPlayer.ResetNoOrderBoxMissionStartPosition()
			TppMission.ResetIsStartFromHelispace()
			TppMission.ResetIsStartFromFreePlay()
		elseif isHeliSpace then
			if gvars.heli_missionStartRoute~=0 then
				TppPlayer.SetStartStatusRideOnHelicopter()
				if mvars.mis_helicopterMissionStartPosition then
					TppPlayer.SetInitialPosition(mvars.mis_helicopterMissionStartPosition,0)
					TppPlayer.SetMissionStartPosition(mvars.mis_helicopterMissionStartPosition,0)
				end
			else
				TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
				local posTableForNoHeliStart=TppDefine.NO_HELICOPTER_MISSION_START_POSITION[vars.missionCode]
				if posTableForNoHeliStart then
					TppPlayer.SetInitialPosition(posTableForNoHeliStart,0)
					TppPlayer.SetMissionStartPosition(posTableForNoHeliStart,0)
				else
					TppPlayer.ResetInitialPosition()
					TppPlayer.ResetMissionStartPosition()
				end
			end
			TppPlayer.ResetNoOrderBoxMissionStartPosition()
			TppMission.SetIsStartFromHelispace()
			TppMission.ResetIsStartFromFreePlay()
		elseif nextIsFreeMission then
			if TppLocation.IsMotherBase()then
				TppPlayer.SetStartStatusRideOnHelicopter()
			else
				TppPlayer.ResetInitialPosition()
				TppHelicopter.ResetMissionStartHelicopterRoute()
				TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
				TppPlayer.SetMissionStartPositionToCurrentPosition()
			end
			TppPlayer.ResetNoOrderBoxMissionStartPosition()
			TppMission.ResetIsStartFromHelispace()
			TppMission.ResetIsStartFromFreePlay()
			TppLocation.MbFreeSpecialMissionStartSetting(TppMission.GetMissionClearType())
		elseif(isFreeMission and TppLocation.IsMotherBase())then
			if gvars.heli_missionStartRoute~=0 then
				TppPlayer.SetStartStatusRideOnHelicopter()
			else
				TppPlayer.ResetInitialPosition()
				TppPlayer.ResetMissionStartPosition()
			end
			TppPlayer.ResetNoOrderBoxMissionStartPosition()
			TppMission.SetIsStartFromHelispace()
			TppMission.ResetIsStartFromFreePlay()
		else
			if isFreeMission then
				if mvars.mis_orderBoxName then
					TppMission.SetMissionOrderBoxPosition()
					TppPlayer.ResetNoOrderBoxMissionStartPosition()
				else
					TppPlayer.ResetInitialPosition()
					TppPlayer.ResetMissionStartPosition()
					local freeMissionNoBoxOrderStartPosTable={
						[10020]={1449.3460693359,339.18698120117,1467.4300537109,-104},
						[10050]={-1820.7060546875,349.78659057617,-146.44400024414,139},
						[10070]={-792.00512695313,537.3740234375,-1381.4598388672,136},
						[10080]={-439.28802490234,-20.472593307495,1336.2784423828,-151},
						[10140]={499.91635131836,13.07358455658,1135.1315917969,79},
						[10150]={-1732.0286865234,543.94067382813,-2225.7587890625,162},
						[10260]={-1260.0454101563,298.75305175781,1325.6383056641,51}
					}
					freeMissionNoBoxOrderStartPosTable[11050]=freeMissionNoBoxOrderStartPosTable[10050]
					freeMissionNoBoxOrderStartPosTable[11080]=freeMissionNoBoxOrderStartPosTable[10080]
					freeMissionNoBoxOrderStartPosTable[11140]=freeMissionNoBoxOrderStartPosTable[10140]
					freeMissionNoBoxOrderStartPosTable[10151]=freeMissionNoBoxOrderStartPosTable[10150]
					freeMissionNoBoxOrderStartPosTable[11151]=freeMissionNoBoxOrderStartPosTable[10150]
					local startPosNoBoxOrder=freeMissionNoBoxOrderStartPosTable[vars.missionCode]
					if TppDefine.NO_ORDER_BOX_MISSION_ENUM[tostring(vars.missionCode)]and startPosNoBoxOrder then
						TppPlayer.SetNoOrderBoxMissionStartPosition(startPosNoBoxOrder,startPosNoBoxOrder[4])
					else
						TppPlayer.ResetNoOrderBoxMissionStartPosition()
					end
				end
				local noBoxOrderHeliRoute=TppDefine.NO_ORDER_FIX_HELICOPTER_ROUTE[vars.missionCode]
				if noBoxOrderHeliRoute then
					TppPlayer.SetStartStatusRideOnHelicopter()
					TppMission.SetIsStartFromHelispace()
					TppMission.ResetIsStartFromFreePlay()
				else
					TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
					TppHelicopter.ResetMissionStartHelicopterRoute()
					TppMission.ResetIsStartFromHelispace()
					TppMission.SetIsStartFromFreePlay()
				end
				local missionClearType=TppMission.GetMissionClearType()
				TppQuest.SpecialMissionStartSetting(missionClearType)
			else
				TppPlayer.ResetInitialPosition()
				TppPlayer.ResetMissionStartPosition()
				TppPlayer.ResetNoOrderBoxMissionStartPosition()
				TppMission.ResetIsStartFromHelispace()
				TppMission.ResetIsStartFromFreePlay()
			end
		end
	elseif missionLoadType==TppDefine.MISSION_LOAD_TYPE.MISSION_ABORT then
		TppPlayer.ResetInitialPosition()
		TppHelicopter.ResetMissionStartHelicopterRoute()
		TppMission.ResetIsStartFromHelispace()
		TppMission.ResetIsStartFromFreePlay()
		if abortWithSave then
			if nextIsFreeMission then
				TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
				TppHelicopter.ResetMissionStartHelicopterRoute()
				TppPlayer.SetMissionStartPositionToCurrentPosition()
				TppPlayer.ResetNoOrderBoxMissionStartPosition()
			elseif nextIsHeliSpace then
				TppPlayer.ResetMissionStartPosition()
			elseif vars.missionCode~=5 then
			end
		else
			if nextIsHeliSpace then
				TppHelicopter.ResetMissionStartHelicopterRoute()
				TppPlayer.ResetInitialPosition()
				TppPlayer.ResetMissionStartPosition()
			elseif nextIsFreeMission then
				TppMission.SetMissionOrderBoxPosition()
			elseif vars.missionCode~=5 then
			end
		end
	elseif missionLoadType==TppDefine.MISSION_LOAD_TYPE.MISSION_RESTART then
	elseif missionLoadType==TppDefine.MISSION_LOAD_TYPE.CONTINUE_FROM_CHECK_POINT then
	end

	--r51 Simple code to skip heli rides - seems to work fine but may be breaking somewhere - needs more testing over time XD
	--r51 Settings
	if
		TUPPMSettings.heli_ENABLE_skipRides and
		(
		not TppMission.IsFOBMission(vars.missionCode)
		and vars.missionCode~=10054 --Mission 9 - Backup Back Down
		and vars.missionCode~=10115 --Mission 22 - Retake the Platform
		and vars.missionCode~=10080 --Mission 13 - Pitch Dark
		and vars.missionCode~=11054 --Mission 34 - [Extreme] Backup, Back Down
		and vars.missionCode~=10260 --Mission 45- A Quiet Exit
		)
	then
		if isHeliSpace or nextIsFreeMission then
			if gvars.heli_missionStartRoute~=0 then
				local route=TppMain.GetUsingRouteDetails()

				if route and not route.hostile then
					this.recordedMbLayoutCode=vars.mbLayoutCode
					local position = route.pos
					local rotation = route.rotY

					if vars.missionCode==10043 then --M4
						rotation=102
					elseif vars.missionCode==10090 then --M16
						rotation=71
					elseif vars.missionCode==10110 then --M20
						rotation=131
					end

					if rotation==nil then
						rotation=0
					end

					TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.ON_FOOT)
					TppPlayer.SetInitialPosition(position,rotation)
					TppPlayer.SetMissionStartPosition(position,rotation)
					--					mvars.mis_helicopterMissionStartPosition=position
					--rX62 Alternate short heli ride
					--TppPlayer.SetStartStatus(TppDefine.INITIAL_PLAYER_STATE.RIDEON_HELICOPTER)
					this.isFakeHeliDropRequired=true

				end
			end
		end
	end


	if isHeliSpace and isLocationChange then
		Mission.AddLocationFinalizer(function()this.StageBlockCurrentPosition()end)
	else
		this.StageBlockCurrentPosition()
	end
end


function this.StageBlockCurrentPosition(e)
	if vars.initialPlayerFlag==PlayerFlag.USE_VARS_FOR_INITIAL_POS then
		StageBlockCurrentPositionSetter.SetEnable(true)StageBlockCurrentPositionSetter.SetPosition(vars.initialPlayerPosX,vars.initialPlayerPosZ)
	else
		StageBlockCurrentPositionSetter.SetEnable(false)
	end
	if TppMission.IsHelicopterSpace(vars.missionCode)then
		StageBlockCurrentPositionSetter.SetEnable(true)StageBlockCurrentPositionSetter.DisablePosition()
		if e then
			while not StageBlock.LargeAndSmallBlocksAreEmpty()do
				coroutine.yield()
			end
		end
	end
end
function this.OnReload(n)
	for i,e in pairs(n)do
		if IsTypeFunc(e.OnLoad)then
			e.OnLoad()
		end
		if IsTypeFunc(e.Messages)then
			n[i]._messageExecTable=Tpp.MakeMessageExecTable(e.Messages())
		end
	end
	if OnlineChallengeTask then
		OnlineChallengeTask.OnReload()
	end
	if n.enemy then
		if IsTypeTable(n.enemy.routeSets)then
			TppClock.UnregisterClockMessage"ShiftChangeAtNight"TppClock.UnregisterClockMessage"ShiftChangeAtMorning"TppEnemy.RegisterRouteSet(n.enemy.routeSets)
			TppEnemy.MakeShiftChangeTable()
		end
	end
	for i,e in ipairs(Tpp._requireList)do
		if _G[e].OnReload then
			_G[e].OnReload(n)
		end
	end
	if mvars.loc_locationCommonTable then
		mvars.loc_locationCommonTable.OnReload()
	end
	if n.sequence then
		TppCheckPoint.RegisterCheckPointList(n.sequence.checkPointList)
	end
	this.SetUpdateFunction(n)
	this.SetMessageFunction(n)
end
function this.OnUpdate(e)
	local e
	local moduleUpdateFuncs=moduleUpdateFuncs
	local n=missionScriptOnUpdateFuncs
	local e=UNKsomeTable1
	for updateFuncIndex=1,moduleUpdateFuncsSize do
		moduleUpdateFuncs[updateFuncIndex]()
	end
	for e=1,missionScriptOnUpdateFuncsSize do
		n[e]()
	end
	UpdateScriptsInScriptBlocks()
end
function this.OnChangeSVars(e,i,n)
	for t,e in ipairs(Tpp._requireList)do
		if _G[e].OnChangeSVars then
			_G[e].OnChangeSVars(i,n)
		end
	end
end
function this.SetMessageFunction(e)
	onMessageTable={}
	onMessageTableSize=0
	messageExecTable={}messageExecTableSize=0
	for n,e in ipairs(Tpp._requireList)do
		if _G[e].OnMessage then
			onMessageTableSize=onMessageTableSize+1
			onMessageTable[onMessageTableSize]=_G[e].OnMessage
		end
	end
	for n,i in pairs(e)do
		if e[n]._messageExecTable then
			messageExecTableSize=messageExecTableSize+1
			messageExecTable[messageExecTableSize]=e[n]._messageExecTable
		end
	end
end
function this.OnMessage(n,e,i,a,p,t,o)
	local n=mvars
	local s=""local T
	local u=Tpp.DoMessage
	local c=TppMission.CheckMessageOption
	local T=TppDebug
	local T=UNKsomeTable3
	local T=UNKsomeTable4
	local T=TppDefine.MESSAGE_GENERATION[e]and TppDefine.MESSAGE_GENERATION[e][i]
	if not T then
		T=TppDefine.DEFAULT_MESSAGE_GENERATION
	end
	local m=GetCurrentMessageResendCount()
	if m<T then
		return Mission.ON_MESSAGE_RESULT_RESEND
	end
	for n=1,onMessageTableSize do
		local s=s
		onMessageTable[n](e,i,a,p,t,o,s)
	end
	for r=1,messageExecTableSize do
		local n=s
		u(messageExecTable[r],c,e,i,a,p,t,o,n)
	end
	if OnlineChallengeTask then
		OnlineChallengeTask.OnMessage(e,i,a,p,t,o,s)
	end
	if n.loc_locationCommonTable then
		n.loc_locationCommonTable.OnMessage(e,i,a,p,t,o,s)
	end
	if n.order_box_script then
		n.order_box_script.OnMessage(e,i,a,p,t,o,s)
	end
	if n.animalBlockScript and n.animalBlockScript.OnMessage then
		n.animalBlockScript.OnMessage(e,i,a,p,t,o,s)
	end
end
function this.OnTerminate(e)
	if e.sequence then
		if IsTypeFunc(e.sequence.OnTerminate)then
			e.sequence.OnTerminate()
		end
	end
end



local vehicleBaseTypes={
	LIGHT_VEHICLE={--jeep
		ivar="vehiclePatrolLvEnable",
		seats=4,
	},
	TRUCK={
		ivar="vehiclePatrolTruckEnable",
		seats=2,
		easternVehicles={
			"EASTERN_TRUCK",
			"EASTERN_TRUCK_CARGO_AMMUNITION",
			"EASTERN_TRUCK_CARGO_MATERIAL",
			"EASTERN_TRUCK_CARGO_DRUM",
			"EASTERN_TRUCK_CARGO_GENERATOR",
		},
		westernVehicles={
			"WESTERN_TRUCK",
			"WESTERN_TRUCK_CARGO_ITEM_BOX",
			"WESTERN_TRUCK_CARGO_CONTAINER",
		--"WESTERN_TRUCK_HOOD",--tex OFF only used in one mission TODO: build own pack with it
		},
	},
	WHEELED_ARMORED_VEHICLE={
		ivar="vehiclePatrolWavEnable",
		seats=1,--6,
		--    enclosed=true,
		easternVehicles={
			"EASTERN_WHEELED_ARMORED_VEHICLE",
		},
		westernVehicles={
			"WESTERN_WHEELED_ARMORED_VEHICLE_TURRET_MACHINE_GUN",
		},
	},
	WHEELED_ARMORED_VEHICLE_HEAVY={
		ivar="vehiclePatrolWavHeavyEnable",
		seats=1,--6,
		--    enclosed=true,
		easternVehicles={
			"EASTERN_WHEELED_ARMORED_VEHICLE_ROCKET_ARTILLERY",
		},
		westernVehicles={
			"WESTERN_WHEELED_ARMORED_VEHICLE_TURRET_CANNON",
		},
	},
	TRACKED_TANK={
		ivar="vehiclePatrolTankEnable",
		seats=1,--tex actually seats 2, but still behaviour with it stopping, dropping off a dude, then attacking
	--    enclosed=true,
	},
}

this.VEHICLE_SPAWN_TYPE={--SYNC vehicleSpawnInfoTable
	"EASTERN_LIGHT_VEHICLE",
	"WESTERN_LIGHT_VEHICLE",
	"EASTERN_TRUCK",
	"EASTERN_TRUCK_CARGO_AMMUNITION",
	"EASTERN_TRUCK_CARGO_MATERIAL",
	"EASTERN_TRUCK_CARGO_DRUM",
	"EASTERN_TRUCK_CARGO_GENERATOR",
	"WESTERN_TRUCK",
	"WESTERN_TRUCK_CARGO_ITEM_BOX",
	"WESTERN_TRUCK_CARGO_CONTAINER",
	"WESTERN_TRUCK_CARGO_CISTERN",
	"WESTERN_TRUCK_HOOD",
	"EASTERN_WHEELED_ARMORED_VEHICLE",
	"EASTERN_WHEELED_ARMORED_VEHICLE_ROCKET_ARTILLERY",
	"WESTERN_WHEELED_ARMORED_VEHICLE",
	"WESTERN_WHEELED_ARMORED_VEHICLE_TURRET_MACHINE_GUN",
	"WESTERN_WHEELED_ARMORED_VEHICLE_TURRET_CANNON",
	"EASTERN_TRACKED_TANK",
	"WESTERN_TRACKED_TANK",
}

local vehicleSpawnInfoTable={--SYNC VEHICLE_SPAWN_TYPE
	EASTERN_LIGHT_VEHICLE={
		baseType="LIGHT_VEHICLE",
		type=Vehicle.type.EASTERN_LIGHT_VEHICLE,
		subType=Vehicle.subType.NONE,
		class=nil,
		paintType=nil,
	},
	WESTERN_LIGHT_VEHICLE={
		baseType="LIGHT_VEHICLE",
		type=Vehicle.type.WESTERN_LIGHT_VEHICLE,
		subType=Vehicle.subType.NONE,
		class=nil,
		paintType=nil,
	},

	EASTERN_TRUCK={
		baseType="TRUCK",
		type=Vehicle.type.EASTERN_TRUCK,
		subType=Vehicle.subType.NONE,
		class=nil,
		paintType=nil,
	},
	EASTERN_TRUCK_CARGO_AMMUNITION={
		baseType="TRUCK",
		type=Vehicle.type.EASTERN_TRUCK,
		subType=Vehicle.subType.EASTERN_TRUCK_CARGO_AMMUNITION,
		class=nil,
		paintType=nil,
	},
	EASTERN_TRUCK_CARGO_MATERIAL={
		baseType="TRUCK",
		type=Vehicle.type.EASTERN_TRUCK,
		subType=Vehicle.subType.EASTERN_TRUCK_CARGO_MATERIAL,
		class=nil,
		paintType=nil,
	},
	EASTERN_TRUCK_CARGO_DRUM={
		baseType="TRUCK",
		type=Vehicle.type.EASTERN_TRUCK,
		subType=Vehicle.subType.EASTERN_TRUCK_CARGO_DRUM,
		class=nil,
		paintType=nil,
	},
	EASTERN_TRUCK_CARGO_GENERATOR={
		baseType="TRUCK",
		type=Vehicle.type.EASTERN_TRUCK,
		subType=Vehicle.subType.EASTERN_TRUCK_CARGO_GENERATOR,
		class=nil,
		paintType=nil,
	},

	WESTERN_TRUCK={
		baseType="TRUCK",
		type=Vehicle.type.WESTERN_TRUCK,
		subType=Vehicle.subType.NONE,
		class=nil,
		paintType=nil,
	},

	WESTERN_TRUCK_CARGO_ITEM_BOX={
		baseType="TRUCK",
		type=Vehicle.type.WESTERN_TRUCK,
		subType=Vehicle.subType.WESTERN_TRUCK_CARGO_ITEM_BOX,
		class=nil,
		paintType=nil,
	},

	WESTERN_TRUCK_CARGO_CONTAINER={
		baseType="TRUCK",
		type=Vehicle.type.WESTERN_TRUCK,
		subType=Vehicle.subType.WESTERN_TRUCK_CARGO_CONTAINER,
		class=nil,
		paintType=nil,
	},

	WESTERN_TRUCK_CARGO_CISTERN={
		baseType="TRUCK",
		type=Vehicle.type.WESTERN_TRUCK,
		subType=Vehicle.subType.WESTERN_TRUCK_CARGO_CISTERN,
		class=nil,
		paintType=nil,
	},

	WESTERN_TRUCK_HOOD={
		baseType="TRUCK",
		type=Vehicle.type.WESTERN_TRUCK,
		subType=Vehicle.subType.WESTERN_TRUCK_HOOD,
		class=nil,
		paintType=nil,
	},

	EASTERN_WHEELED_ARMORED_VEHICLE={
		baseType="WHEELED_ARMORED_VEHICLE",
		type=Vehicle.type.EASTERN_WHEELED_ARMORED_VEHICLE,
		subType=Vehicle.subType.NONE,
		class=nil,
		paintType=nil,
		packPath="/Assets/tpp/pack/vehicle/veh_rl_east_wav.fpk",
	--    packPath="/Assets/tpp/pack/soldier/reinforce/reinforce_veh_east_wav.fpk",
	--    packPath="/Assets/tpp/pack/mission2/common/veh_mc_east_wav.fpk",
	},

	EASTERN_WHEELED_ARMORED_VEHICLE_ROCKET_ARTILLERY={
		baseType="WHEELED_ARMORED_VEHICLE",
		type=Vehicle.type.EASTERN_WHEELED_ARMORED_VEHICLE,
		subType=Vehicle.subType.EASTERN_WHEELED_ARMORED_VEHICLE_ROCKET_ARTILLERY,
		class=nil,
		paintType=nil,
		packPath="/Assets/tpp/pack/vehicle/veh_rl_east_wav_rocket.fpk",
	--    packPath="/Assets/tpp/pack/soldier/reinforce/reinforce_veh_east_wav_roc.fpk",
	--    packPath="/Assets/tpp/pack/mission2/common/veh_mc_east_wav_rocket.fpk",
	},

	WESTERN_WHEELED_ARMORED_VEHICLE={--Nope, vehicle seems almost complete, just no turret and no use cases in game
		baseType="WHEELED_ARMORED_VEHICLE",
		type=Vehicle.type.WESTERN_WHEELED_ARMORED_VEHICLE,
		subType=Vehicle.subType.NONE,
		class=nil,
		paintType=nil,
	},

	WESTERN_WHEELED_ARMORED_VEHICLE_TURRET_MACHINE_GUN={
		baseType="WHEELED_ARMORED_VEHICLE",
		type=Vehicle.type.WESTERN_WHEELED_ARMORED_VEHICLE,
		subType=Vehicle.subType.WESTERN_WHEELED_ARMORED_VEHICLE_TURRET_MACHINE_GUN,
		class=nil,
		paintType=nil,
		packPath="/Assets/tpp/pack/vehicle/veh_rl_west_wav_machinegun.fpk",
	--    packPath="/Assets/tpp/pack/soldier/reinforce/reinforce_veh_west_wav_a.fpk",
	--    packPath="/Assets/tpp/pack/mission2/common/veh_mc_west_wav_trt_machinegun.fpk",
	},

	WESTERN_WHEELED_ARMORED_VEHICLE_TURRET_CANNON={
		baseType="WHEELED_ARMORED_VEHICLE",
		type=Vehicle.type.WESTERN_WHEELED_ARMORED_VEHICLE,
		subType=Vehicle.subType.WESTERN_WHEELED_ARMORED_VEHICLE_TURRET_CANNON,
		class=nil,
		paintType=nil,
		packPath="/Assets/tpp/pack/vehicle/veh_rl_west_wav_cannon.fpk",
	--    packPath="/Assets/tpp/pack/soldier/reinforce/reinforce_veh_west_wav_can_a.fpk",
	--    packPath="/Assets/tpp/pack/mission2/common/veh_mc_west_wav_trt_cannon.fpk",
	},

	EASTERN_TRACKED_TANK={
		baseType="TRACKED_TANK",
		type=Vehicle.type.EASTERN_TRACKED_TANK,
		subType=Vehicle.subType.NONE,
		class=nil,
		paintType=nil,
		packPath="/Assets/tpp/pack/vehicle/veh_rl_east_tnk.fpk",
	--    packPath="/Assets/tpp/pack/soldier/reinforce/reinforce_veh_east_tnk.fpk",
	--    packPath="/Assets/tpp/pack/mission2/common/veh_mc_east_tnk.fpk",
	},

	WESTERN_TRACKED_TANK={
		baseType="TRACKED_TANK",
		type=Vehicle.type.WESTERN_TRACKED_TANK,
		subType=Vehicle.subType.NONE,
		class=nil,
		paintType=nil,
		packPath="/Assets/tpp/pack/vehicle/veh_rl_west_tnk.fpk",
	--    packPath="/Assets/tpp/pack/soldier/reinforce/reinforce_veh_west_tnk_a.fpk",
	--    packPath="/Assets/tpp/pack/mission2/common/veh_mc_west_tnk.fpk",
	},
}


local soldierPool={}

--------------SpecialInitialize
function this.SpecialInitialize(missionTable)
	local IsTable=Tpp.IsTypeTable

	if missionTable.enemy then
		local enemyTable=missionTable.enemy
		--    TUPPMLog.Log("Vehicles random seed: "..tostring(gvars.rev_revengeRandomValue))
		--r37 Better random seed so that vehicles remain the same on continue from title screen
		math.randomseed(gvars.rev_revengeRandomValue) --r21 Important to completely randomize now that automarking is in effect
		TppMain.Randomize()

		--		TUPPMLog.Log(
		--		"SpecialInitialize gvars.sav_varRestoreForContinue:"..tostring(gvars.sav_varRestoreForContinue)
		--		.." randomNum:"..tostring(math.random())
		--				)
		--r19 logic for creating new vehicle types
		-- added additional logic as tex's version is based on activation/deactivation
		if IsTable(enemyTable.soldierDefine) then

			--r43 Create power and ability tables here for WildCards, if not present - in free roam they won't really be present
			enemyTable.soldierPowerSettings=enemyTable.soldierPowerSettings or {}
			enemyTable.soldierPersonalAbilitySettings=enemyTable.soldierPersonalAbilitySettings or {}

			--r45 BUGFIX and CODECLEANUP - found why vehicles were randomizing

			--r51 Settings
			if TUPPMSettings.game_ENABLE_armoredVehiclesAndTanksInFreeRoam then
				if IsTable(enemyTable.VEHICLE_SPAWN_LIST) then
					this.ModifyVehiclePatrol(enemyTable.VEHICLE_SPAWN_LIST)
				end

				soldierPool={}

				this.ModifyVehiclePatrolSoldiers(enemyTable.soldierDefine)
			end

			--r51 Settings
			if TUPPMSettings.wildcard_ENABLE then
				this.AddWildCards(enemyTable.soldierDefine, enemyTable.soldierPowerSettings, enemyTable.soldierPersonalAbilitySettings)
			end

		end
		math.randomseed(os.time())
		TppMain.Randomize()
	end
end

--------------ModifyVehiclePatrol
function this.ModifyVehiclePatrol(vehicleSpawnList)

	--r45 BUGFIX - randomized free roam vehicles should no longer randomize further. My poor understanding of the code and
	-- lua tables lead me to be a smartass and initialize the table only once, DESPITE the fact that I clearly remember seeing
	-- tinmantex had initialized it every time this function was called -_-
	--The table patrolVehicleEnabledList was initialized ONLY once and populated by index, hence math.random() below over the
	-- size of the table would give different results depending on how many times this code was called. And yet, I did manage to see
	-- a non random pattern consistently after 3-4 calls - weird :/
	--I did not fully understand local vs object level at the time
	--Thank you for being a better coder than me tex, I guess it was eventually your code anyway that forced me to learn

	local patrolVehicleEnabledList={}

	for baseType,typeInfo in pairs(vehicleBaseTypes) do
		patrolVehicleEnabledList[#patrolVehicleEnabledList+1]=baseType
	end

	if #patrolVehicleEnabledList==0 then
		return
	end

	mvars.patrolVehicleBaseInfo={}

	local index = 1
	local singularBaseType=nil
	for n,spawnInfo in pairs(vehicleSpawnList)do
		local exisitingColor = spawnInfo.paintType
		if string.find(spawnInfo.locator, "veh_trc_000")
			or string.find(spawnInfo.locator, "veh_lv_000") --r19 Added outpost vehicles into the mix as well
		then--tex only replacing certain ids, seen in free mission vehicle spawn list
			local vehicle=nil
			local vehicleType=nil

			local baseType=patrolVehicleEnabledList[math.random(#patrolVehicleEnabledList)]
			--      if Ivars.vehiclePatrolProfile:Is"SINGULAR" then
			--              if singularBaseType==nil then
			--                singularBaseType=baseType
			--              else
			--                baseType=singularBaseType
			--              end
			--      end
			local baseTypeInfo=vehicleBaseTypes[baseType]
			if baseTypeInfo~=nil then
				local vehicles=nil
				local locationName=""
				if TppLocation.IsAfghan()then
					vehicles=baseTypeInfo.easternVehicles
					locationName="EASTERN_"
				elseif TppLocation.IsMiddleAfrica()then
					vehicles=baseTypeInfo.westernVehicles
					locationName="WESTERN_"
				end
				--r21 more random
				TppMain.Randomize()

				if vehicles==nil then
					vehicleType=locationName..baseType
				else
					vehicleType=vehicles[math.random(#vehicles)]
				end

				if vehicleType==nil then
					break
				end

				vehicle=vehicleSpawnInfoTable[vehicleType]
				if vehicle==nil then
					break
				end

				mvars.patrolVehicleBaseInfo[spawnInfo.locator]=baseTypeInfo
				spawnInfo.type=vehicle.type
				spawnInfo.subType=vehicle.subType

				--r32 Use class on all vehicles except PF Trucks and Jeeps
				if (spawnInfo.type~=Vehicle.type.WESTERN_LIGHT_VEHICLE and spawnInfo.type~=Vehicle.type.WESTERN_TRUCK) then
					spawnInfo.paintType=nil --TODO WIP change to existing vehicle fova, does not work for armored vehicles though :/
					spawnInfo.class=math.random(0,2) --r32 Random classes
				end

				--        TUPPMLog.Log("prev index: "..tostring(spawnInfo.index))
				--        spawnInfo.index=index
				--        TUPPMLog.Log("curr index: "..tostring(spawnInfo.index))
				--index=index+1

				--spawnInfo.paintType=Vehicle.paintType.FOVA_0

				--TODO WIP change class
				--        if (baseType~="LIGHT_VEHICLE" and baseType~="TRUCK" ) then
				--          TUPPMLog.Log("Assigning class")
				--          spawnInfo.class=Vehicle.class.OXIDE_RED
				--          --spawnInfo.class=Vehicle.class.DARK_GRAY
				--        end

				--                TUPPMLog.Log(
				--                  "spawnInfo.locator: "..tostring(spawnInfo.locator)
				--        --        ..", vehicle: "..tostring(tostring(vehicle))
				--                ..", spawnInfo.type: "..tostring(vehicle.type)
				--                ..", spawnInfo.subType: "..tostring(vehicle.subType)
				--                ..", spawnInfo.paintType: "..tostring(spawnInfo.paintType)
				--                ..", spawnInfo.class: "..tostring(spawnInfo.class)
				--                )

				--TODO WIP add code to make new vehicles usable
				--TppEnemy.AddRecoveredStateList(spawnInfo.locator)
				--TUPPMLog.Log("Enabled recover state for: "..tostring(spawnInfo.locator))

				--        local spawnVehicle = { --This spawns the same vehicles for the same routes, I think
				--                              id = "Spawn",
				--                              locator = spawnInfo.locator,
				--                              type = spawnInfo.type,
				--                              subType = spawnInfo.subType,
				--                              paintType = spawnInfo.paintType,
				--                              index = spawnInfo.index
				--                              }
				--        TppEnemy.SpawnVehicle(spawnVehicle)
			end
		end

		--nope does not make reinforce vehicles usable
		--   TppEnemy.RegistHoldRecoveredState(spawnInfo.locator)
		--   TUPPMLog.Log("Registered hold recovered for: "..tostring(spawnInfo.locator))
		--> end for loop on vehicleSpawnList
	end

	--  Player.RequestToShowIcon {
	--      type = ActionIcon.ACTION,
	--      icon = ActionIcon.RIDE_MILITALY_VEHICLE,
	--      message = Fox.StrCode32("RideOk"),
	--      messageArg = "message_arg"
	--    }
	--
	--  Player.RequestToShowIcon {
	--      type = ActionIcon.ACTION,
	--      icon = ActionIcon.RIDE_VEHICLE,
	--      message = Fox.StrCode32("RideOk"),
	--      messageArg = "message_arg"
	--    }

	--TODO rX46 RETICLE_UI_VEHICLE = 10 <- load through TppEquip
	--		BL_TankCannon = 72,
	--    BL_TankCannonHoming = 74,
	--    BL_Tankgun_105mmRifledBoreGun = 78,
	--    BL_Tankgun_105mmRifledBoreGun_Homing = 81,
	--    BL_Tankgun_120mmSmoothBoreGun = 79,
	--    BL_Tankgun_120mmSmoothBoreGun_Homing = 82,
	--    BL_Tankgun_125mmSmoothBoreGun = 80,
	--    BL_Tankgun_125mmSmoothBoreGun_Homing = 83,
	--    BL_Tankgun_20mmAutoCannon = 76,
	--    BL_Tankgun_30mmAutoCannon = 77,
	--    BL_Tankgun_82mmRocketPoweredProjectile = 84,
	--    BL_Tankgun_MultipleRocketLauncher = 85,

end

--------------FillLrrp
local function FillLrrp(num,soldierPool,cpDefine)
	local soldiers={}
	while num>0 and #soldierPool>0 do
		local soldierName=soldierPool[#soldierPool]
		if soldierName then
			table.remove(soldierPool)--pop
			table.insert(cpDefine,soldierName)
			table.insert(soldiers,soldierName)
			num=num-1
		end
	end
	return soldiers
end

--------------ModifyVehiclePatrolSoldiers
function this.ModifyVehiclePatrolSoldiers(soldierDefine)

	--local initPoolSize=#this.soldierPool--DEBUG
	for cpName,cpDefine in pairs(soldierDefine)do
		local numCpSoldiers=0
		for n,soldierName in ipairs(cpDefine)do
			numCpSoldiers=numCpSoldiers+1
		end

		if cpDefine.lrrpVehicle then
			local numSeats=2
			if mvars.patrolVehicleBaseInfo then
				local baseTypeInfo=mvars.patrolVehicleBaseInfo[cpDefine.lrrpVehicle]
				if baseTypeInfo then
					numSeats=math.random(math.min(numSeats,baseTypeInfo.seats),baseTypeInfo.seats)
					--InfMenu.DebugPrint(cpDefine.lrrpVehicle .. " numVehSeats "..numSeats)--DEBUG
				end
			end
			--
			if numCpSoldiers>numSeats then
				local gotSeat=0
				local clearIndices={}
				for n,soldierName in ipairs(cpDefine)do
					gotSeat=gotSeat+1
					if gotSeat>numSeats then
						table.insert(soldierPool,soldierName)
						cpDefine[n]=nil
					end
				end
			else
				numSeats=numSeats-numCpSoldiers
				--InfMenu.DebugPrint(cpDefine.lrrpVehicle .. " numfillSeats "..numSeats)--DEBUG
				if numSeats>0 then
					FillLrrp(numSeats,soldierPool,cpDefine)
				end
			end

			--r29 Don't do this, i think this causes the dialogue to play twice
			--TODO r24 WOOPS! Doesn't work; Assign vehicle to lrrp soldiers SOLVED;
			--      local lrrpVehicleObjectId=GameObject.GetGameObjectId("TppVehicle2",cpDefine.lrrpVehicle)
			--      --      local command={id="SetRelativeVehicle",targetId=lrrpVehicleObjectId,rideFromBeginning=false}
			--      --TODO r31 Enable again - Will test further
			--      local command={id="SetRelativeVehicle",targetId=lrrpVehicleObjectId, rideFromBeginning=true, isMust = true}
			--      for n, soldierName in pairs(cpDefine) do
			--        if Tpp.IsTypeString(soldierName) then
			--          local soldierId = GameObject.GetGameObjectId("TppSoldier2", soldierName)
			--          if soldierId~=GameObject.NULL_ID then
			--            --            TUPPMLog.Log("soldierName: "..tostring(soldierName)..", vehicleName: "..tostring(cpDefine.lrrpVehicle))
			--            --            TUPPMLog.Log("soldierId: "..tostring(soldierId)..", vehicleId: "..tostring(lrrpVehicleObjectId))
			--            GameObject.SendCommand(soldierId,command)
			--          end
			--        end
			--      end

			--if lrrpVehicle<
		end
		--for soldierdefine<
	end
	--local poolChange=#this.soldierPool-initPoolSize--DEBUG
	--InfMenu.DebugPrint("pool change:"..poolChange)--DEBUG

	--InfMain.ResetTrueRandom()
end

--r32 Use to set Vehicle Paints/Classes
--Unused for now until I add Paint Fovas
function this.SetVehiclePaint(vehicleSpawnList, cpDefine)

	if vars.missionCode==30020 then

		--  local pfType={PF_A=1,PF_B=2,PF_C=3}
		--    local pfTypeToPaintMapping={
		--    PF_A=Vehicle.paintType.FOVA_0,
		--    PF_B=Vehicle.paintType.FOVA_1,
		--    PF_C=Vehicle.paintType.FOVA_2
		--    }

		for cpName,cpDetails in pairs(cpDefine)do
			if cpDetails.lrrpVehicle then
				--        local firstSoldier = cpDetails[0]
				--        local soldierId=GameObject.GetGameObjectId(firstSoldier)
				--        local soldierType=TppEnemy.GetSoldierType(soldierId)
				--        local soldierSubType=TppEnemy.GetCpSubType(soldierId, soldierType)
				--
				--        TUPPMLog.Log("soldierType: "..tostring(soldierType))
				--        TUPPMLog.Log("soldierSubType: "..tostring(soldierSubType))

				for n, spawnInfo in pairs(vehicleSpawnList)do
					if cpDetails.lrrpVehicle==spawnInfo.locator then
						--            spawnInfo.paintType=pfTypeToPaintMapping[soldierSubType]
						--            TUPPMLog.Log("spawnInfo.paintType: "..tostring(spawnInfo.paintType))
						if (spawnInfo.type~=Vehicle.type.WESTERN_LIGHT_VEHICLE or spawnInfo.type~=Vehicle.type.WESTERN_TRUCK) then
							spawnInfo.paintType=nil
						end
					end
				end

			end
		end

	end
end

--------------AddMissionPack
local function AddMissionPack(packPath,missionPackPath)
	if Tpp.IsTypeString(packPath)then
		table.insert(missionPackPath,packPath)
	end
end

--------------AddVehiclePacks
function this.AddVehiclePacks(missionCode,missionPackPath)
	for baseType,typeInfo in pairs(vehicleBaseTypes) do
		local vehicles=nil
		local vehicleType=""
		local locationName=""
		if TppLocation.IsAfghan()then
			vehicles=typeInfo.easternVehicles
			locationName="EASTERN_"
		elseif TppLocation.IsMiddleAfrica()then
			vehicles=typeInfo.westernVehicles
			locationName="WESTERN_"
		end


		local GetPackPath=function(vehicleType)
			local vehicle=vehicleSpawnInfoTable[vehicleType]
			if vehicle~=nil then
				return vehicle.packPath or nil
			end
		end

		if vehicles==nil then
			vehicleType=locationName..baseType
			local packPath=GetPackPath(vehicleType)
			if packPath~=nil then
				--InfMenu.DebugPrint("packpath: "..tostring(packPath))--DEBUG
				AddMissionPack(packPath,missionPackPath)
			end
		else
			for n, vehicleType in pairs(vehicles) do
				local packPath=GetPackPath(vehicleType)
				if packPath~=nil then
					--InfMenu.DebugPrint("packpath: "..tostring(packPath))--DEBUG
					AddMissionPack(packPath,missionPackPath)
				end
			end
		end
	end--for vehicle base types
end

--------------DoSpecialThings
function this.DoSpecialThings(missionTable)
	--    TUPPMLog.Log("--------------In DoSpecialThings--------------")

	--r24 Reset Alert flag
	TppRevenge.hasAlertBeenTriggered=false
	--r25
	--  this.MBMoraleBoost()
	--r32 Increase mission/total marking count
	--r38 Renamed tables
	this.playerMarkingCountInMissionKeeper={}
	this.totalMarkingCountKeeper={}

	--r51 Settings
	if TUPPMSettings.game_ENABLE_repopRadioCassettesInGameWorld then
		--r33 Radios that play cassettes now repopulate with their cassettes offering a much livelier game world (somewhat)
		Gimmick.ForceResetOfRadioCassetteWithCassette() --rX51 Does not work reliably for some reason, like when radio is loaded too late
	end

	--r51 Settings
	if TUPPMSettings.player_ENABLE_autoAcquirePerishableCassettes then
		--r34 Acquire usable tapes
		this.AcquirePerishableCassetteTapes()
	end

	--r35 Force search light on for Support Heli at all times
	--  this.ForceCreateHeli()

	--r51 Settings
	if TUPPMSettings.game_ENABLE_resetAllGimmicks then
		--r35 Reset useful gimmicks
		this.ResetAllGimmicks()
	end

	--r51 Settings
	if TUPPMSettings.player_ENABLE_refreshFliesBetweenMissions then
		--		Player.ResetDirtyEffect() --Removes blood and stuff
		vars.passageSecondsSinceOutMB=0 --Removes fly effect and health drop
	end

	--r51 Settings
	if TUPPMSettings.player_ENABLE_refreshBloodyEffectBetweenMissions then
		Player.ResetDirtyEffect() --Removes blood and stuff
		--		vars.passageSecondsSinceOutMB=0 --Removes fly effect and health drop
	end

	--  this.lastMarkTime=0

	--r43 Override vehicle spawn position so they don't crash into the heli
	--  this.OverrideVehiclePos(missionTable)

	--r51
	--  this.ResetAARadars()

	--r59 Min and Max out revenge points options
	TppRevenge.MinOutRevengePoints()
	TppRevenge.MaxOutRevengePoints()

	--r63 Set buddy points
	TUPPM.SetBuddyBondPoints()
	--r63 Max MB Morale
	TUPPM.MaxMBMorale()

	--r67 Modify hand and tool levels
	TUPPM.ModifyHandsLevels()
	TUPPM.ModifyToolsLevels()

end

--r22 Maintain list of quest cps so that their markers are neither marked nor disabled
--r31 renamed variable to make more sense
this.importantMarkerObjects = {}

--r22 Populate quest cp list
--------------UpdateQuestCpIds
function this.UpdateQuestCpIds()

	--r38 BUGFIX for auto marking on Zoo
	if mvars.ene_soldierDefine then
		if mvars.ene_soldierDefine.quest_cp then
			for index, soldierName in pairs(mvars.ene_soldierDefine.quest_cp) do
				local gameObjectId = GameObject.GetGameObjectId(soldierName)
				if gameObjectId~=nil and gameObjectId ~= GameObject.NULL_ID then
					table.insert(this.importantMarkerObjects,gameObjectId)
					this.importantMarkerObjects[gameObjectId]=true
					--        TUPPMLog.Log("Q-CP-Index: "..tostring(index)..", Target: "..tostring(gameObjectId)..", TargetName: "..tostring(soldierName))
				end
			end
		end
	end

	if mvars.ene_eliminateTargetList then
		for index, soldierName in pairs(mvars.ene_eliminateTargetList) do
			local gameObjectId = GameObject.GetGameObjectId(soldierName)
			if gameObjectId~=nil and gameObjectId ~= GameObject.NULL_ID then
				table.insert(this.importantMarkerObjects,gameObjectId)
				this.importantMarkerObjects[gameObjectId]=true
				--        TUPPMLog.Log("MT-Index: "..tostring(index)..", Target: "..tostring(gameObjectId)..", TargetName: "..tostring(soldierName))
			end
		end
	end

	if mvars.ene_questTargetList then
		for index, soldierName in pairs(mvars.ene_questTargetList) do
			local gameObjectId = GameObject.GetGameObjectId(soldierName)
			if gameObjectId~=nil and gameObjectId ~= GameObject.NULL_ID then
				table.insert(this.importantMarkerObjects,gameObjectId)
				this.importantMarkerObjects[gameObjectId]=true
				--        TUPPMLog.Log("QT-Index: "..tostring(index)..", Target: "..tostring(gameObjectId)..", TargetName: "..tostring(soldierName))
			end
		end
	end

	--r31 Maintain walker gears as well
	if mvars.ene_eliminateWalkerGearList then
		for gameObjectId, name in pairs(mvars.ene_eliminateWalkerGearList) do
			table.insert(this.importantMarkerObjects,gameObjectId)
			this.importantMarkerObjects[gameObjectId]=true
		end
	end

	--r31 Maintain side ops animals
	if mvars.ani_questGameObjectIdList then
		for index, animalObjectId in pairs(mvars.ani_questGameObjectIdList) do
			table.insert(this.importantMarkerObjects,animalObjectId)
			this.importantMarkerObjects[animalObjectId]=true
		end
	end

	--r31 Maintain mission target vehicles --works
	if mvars.ene_eliminateVehicleList then
		for gameObjectId, name in pairs(mvars.ene_eliminateVehicleList) do
			table.insert(this.importantMarkerObjects,gameObjectId)
			this.importantMarkerObjects[gameObjectId]=true
		end
	end

	--r31 Maintain side quest target vehicles
	if mvars.ene_questVehicleList then
		for index, command in pairs(mvars.ene_questVehicleList) do
			--      TUPPMLog.Log("command.locator: "..tostring(command.locator))
			local gameObjectId = GameObject.GetGameObjectId(command.locator)
			if gameObjectId ~= GameObject.NULL_ID then
				table.insert(this.importantMarkerObjects,gameObjectId)
				this.importantMarkerObjects[gameObjectId]=true
			end
		end
	end


	--dnt know what searchTarget really is for? Hostages? Or important targets as well?
	--  if mvars.mar_searchTargetList then
	--    for index, soldierName in pairs(mvars.mar_searchTargetList) do
	--      local gameObjectId = GameObject.GetGameObjectId(soldierName)
	--      if gameObjectId~=nil and gameObjectId ~= GameObject.NULL_ID then
	--        table.insert(this.importantMarkerObjects,gameObjectId)
	--        this.importantMarkerObjects[gameObjectId]=true
	--        TUPPMLog.Log("ST-Index: "..tostring(index)..", Target: "..tostring(gameObjectId)..", TargetName: "..tostring(soldierName))
	--      end
	--    end
	--  end

end

--------------GetMaintainQuestCpMap --r22 not currently used anywhere; defunct
--function this.GetMaintainQuestCpMap()
--  return this.importantMarkerObjects
--end

--r27 Found this by accident in TppEnemy; set enemies close to player
--------------CloseToPlayer
function this.CloseToPlayer(gameObject, markingRange)

	--r32 IMPLEMENT THIS
	--local SkullId = GameObject.GetGameObjectId( "SkullFace" )
	--local position, rotY = GameObject.SendCommand( SkullId, { id="GetPosition", } )
	--local SquarePlayerToSkullDistance=TppMath.FindDistance( TppMath.Vector3toTable(position), TppPlayer.GetPosition() )
	--
	--local playerToSkullDistance = math.sqrt(SquarePlayerToSkullDistance)
	--
	--return playerToSkullDistance


	local gameObjectId
	if Tpp.IsTypeString(gameObject) then
		gameObjectId = GameObject.GetGameObjectId(gameObject)
	elseif Tpp.IsTypeNumber(gameObject) then
		gameObjectId = gameObject
	else
		return false
	end

	--  gameObjectId = gameObject
	if gameObjectId==GameObject.NULL_ID then
		return false
	end

	local playerPos=Vector3(vars.playerPosX,vars.playerPosY,vars.playerPosZ)
	local gameObjectPosition=GameObject.SendCommand(gameObjectId,{id="GetPosition"})

	if markingRange==nil then
		markingRange=90601 --default to 301m
	end

	--markingRange=810000 --DEBUG AID
	local distanceFromObject=playerPos-gameObjectPosition
	local shortestDistance=distanceFromObject:GetLengthSqr()
	if shortestDistance<=markingRange then --lol works!
		--this is about x394 of the distance in meter
		--not at all 100% accurate and varies from place to place
		--multiplier may lie in range x340-x430 (very very very off)
		--possibly due to how the location is calculated but may actually change
		--or maybe when the soldier actually isn't visible on the map

		--116K~300m; 150K~380m-400m; 250K~450m give or take 100m
		--    TUPPMLog.Log("distanceFromObject of "..tostring(gameObjectId).." is "..tostring(distanceFromObject).." which is less than 200000m so returning true")
		--    TUPPMLog.Log("shortestDistance of "..tostring(gameObjectId).." is "..tostring(shortestDistance).." which is less than 200000m so returning true")
		return true
	else
		--    TUPPMLog.Log("distanceFromObject of "..tostring(gameObjectId).." is "..tostring(distanceFromObject).." which is more than 2000m so returning false")
		--    TUPPMLog.Log("shortestDistance of "..tostring(gameObjectId).." is "..tostring(shortestDistance).." which is more than 2000m so returning false")
		return false
	end
end

--r27 Determine out of range soldiers
--------------FarFromPlayer
function this.FarFromPlayer(gameObject)
	local gameObjectId
	if Tpp.IsTypeString(gameObject) then
		gameObjectId = GameObject.GetGameObjectId(gameObject)
	elseif Tpp.IsTypeNumber(gameObject) then
		gameObjectId = gameObject
	else
		return true
	end

	--  gameObjectId = gameObject
	if gameObjectId==GameObject.NULL_ID then
		return true
	end

	local playerPos=Vector3(vars.playerPosX,vars.playerPosY,vars.playerPosZ)
	local gameObjectPosition=GameObject.SendCommand(gameObjectId,{id="GetPosition"})

	--  TUPPMLog.Log("Far from player position: "..tostring(gameObjectPosition))

	if gameObjectPosition==nil or gameObjectPosition==GameObject.NULL_ID then
		return true
	end

	local distanceFromObject=playerPos-gameObjectPosition
	local shortestDistance=distanceFromObject:GetLengthSqr()
	if shortestDistance>=810000 then
		--Disable markers farther than 900+m
		return true
	else
		return false
	end
end

--r25 Callable marking function
--------------MarkEm
function this.MarkEm(gameObject)
	local gameObjectId
	if Tpp.IsTypeString(gameObject) then
		gameObjectId = GameObject.GetGameObjectId(gameObject)
	elseif Tpp.IsTypeNumber(gameObject) then
		gameObjectId = gameObject
	else
		return
	end

	if gameObjectId==GameObject.NULL_ID then
		return
	end

	--rX3 WIP Test these all out
	--local viewLayer = "all"
	--local viewLayer = "map"
	--local viewLayer = "map_only_icon"
	--  local viewLayer = "map_and_world_only_icon"
	--  TppMarker2System.EnableMarker{gameObjectId=gameObjectId,viewLayer=viewLayer}
	TppMarker.Enable( gameObjectId, 0, "none", "map_and_world_only_icon", 0, false, false )

	--  TppMarker2System.EnableMarker{
	--    gameObjectId=gameObjectId,
	--    visibleArea=0,
	--    goalLayer="none",
	--    viewLayer="map_and_world_only_icon",
	--    randomRange=0,
	--    isImportant = true,
	--    isNew = true,
	--    announceLog = "updateMap",
	--    langId = "marker_info_mission_target",
	--  }

	--  TppMarker.Enable(
	--    gameObjectId,
	--    0,
	--    "none",
	--    "map_and_world_only_icon",
	--    0,
	--    false,
	--    false,
	--    "updateMap"
	--  )
end

--this.markedSoldiersInRange={}

--r27 Range based un marking
--------------DisableAllSoldierMarkersOutOfRange
function this.DisableAllSoldierMarkersOutOfRange()
	--TUPPMLog.Log("Disabling all soldier markers so we can cleanly re-enable")
	if mvars.ene_soldierDefine then
		for cpName, soldierNameList in pairs(mvars.ene_soldierDefine) do
			for _, soldierName in pairs( soldierNameList ) do
				local gameObjectId = GameObject.GetGameObjectId(soldierName)
				if gameObjectId ~= GameObject.NULL_ID
					--          and this.markedSoldiersInRange[gameObjectId]==true
					and this.importantMarkerObjects[gameObjectId]~=true --r22 do not disable quest soldier markers
					and this.FarFromPlayer(gameObjectId) --r27 Boo yah!
				--          and not this.CloseToPlayer(gameObjectId) --r27
				then
					TppMarker2System.DisableMarker{gameObjectId=gameObjectId}
					TppUiCommand.UnRegisterIconUniqueInformation(gameObjectId) --r27 Should have used this all along - disables markers on the map
					--r35 Do this too
					TppUiCommand.UnregisterMapRadio(gameObjectId)
					--          TppMarker.Disable( gameObjectId )
					--          this.markedSoldiersInRange[gameObjectId]=false
				end
			end
		end
	end

	--r31 Unmark walker gears
	local walkerGearsTable = TppEnemy.GetAllActiveEnemyWalkerGear()
	if walkerGearsTable~=nil then
		for index, gameObjectId in pairs(walkerGearsTable) do
			if gameObjectId ~= GameObject.NULL_ID
				and this.FarFromPlayer(gameObjectId) --r27
				and this.importantMarkerObjects[gameObjectId]~=true --r31
			--          and not mvars.ene_eliminateWalkerGearList[gameObjectId] --r28, do not use this, is fucked up, fucks up mission abort with a marked walker gear. avoid marking mission objective gears like in Footprints of Phantoms
			then
				TppMarker2System.DisableMarker{gameObjectId=gameObjectId}
				TppUiCommand.UnRegisterIconUniqueInformation(gameObjectId)
			end
		end
	end

	--r31 Unmark vehicles
	for count=0,24 do --Not a good approach but GetMaxInstanceCount doesn't work on vehicles
		local vehicleObjectId=GameObject.GetGameObjectIdByIndex("TppVehicle2",count)
		if vehicleObjectId ~= GameObject.NULL_ID
			and TppEnemy.IsVehicleAlive(vehicleObjectId)
			and this.FarFromPlayer(vehicleObjectId) --r27
			and this.importantMarkerObjects[vehicleObjectId]~=true
		then
			TppMarker2System.DisableMarker{gameObjectId=vehicleObjectId}
			TppUiCommand.UnRegisterIconUniqueInformation(vehicleObjectId)
		end
	end

	--rX47 Doesn't help unmark animals - all animals(at least 5x6 goats) even disappear when a combat alert is triggered
	--r51 Optimizing max counts
	local animalTypeList = {
		{"TppWolf",maxIndex=4},
		{"TppJackal",maxIndex=4},
		{"TppZebra",maxIndex=30},
		{"TppBear",maxIndex=2},
		{"TppGoat",maxIndex=24},
		{"TppNubian",maxIndex=24},
		{"TppRat",maxIndex=10},
		{"TppEagle",maxIndex=10},
		{"TppCritterBird",maxIndex=10},
		{"TppStork",maxIndex=10},
	}
	for i, animalTypeDetails in ipairs( animalTypeList ) do
		for count=0,animalTypeDetails.maxIndex do
			local animalObjectId=GameObject.GetGameObjectIdByIndex(animalTypeDetails[1],count)
			if animalObjectId ~= nil
				and animalObjectId ~= GameObject.NULL_ID
				and this.importantMarkerObjects[animalObjectId]~=true --do not disable quest animal markers
			then
				TppMarker2System.DisableMarker{gameObjectId=animalObjectId}
				TppUiCommand.UnRegisterIconUniqueInformation(animalObjectId)
			end
		end
	end

end

--r32 Increase mission/total marking count
--r38 Renamed tables
this.playerMarkingCountInMissionKeeper={}
this.totalMarkingCountKeeper={}
--TODO rX5 r33 Optional to not increase total marking count
--r38 Renamed functions
function this.UpdatePlayerMarkingCountInMissionKeeper(gameObjectId)
	if this.playerMarkingCountInMissionKeeper[gameObjectId]==nil then
		table.insert(this.playerMarkingCountInMissionKeeper,gameObjectId)
		this.playerMarkingCountInMissionKeeper[gameObjectId]=true
		vars.playerMarkingCountInMission=vars.playerMarkingCountInMission+1
	end
end

function this.UpdateTotalMarkingCountKeeper(gameObjectId)
	if this.totalMarkingCountKeeper[gameObjectId]==nil then
		table.insert(this.totalMarkingCountKeeper,gameObjectId)
		this.totalMarkingCountKeeper[gameObjectId]=true
		vars.totalMarkingCount=vars.totalMarkingCount+1
	end
end

function this.UpdateBOTHMarkingCountKeepers(gameObjectId)
	if this.playerMarkingCountInMissionKeeper[gameObjectId]==nil then
		table.insert(this.playerMarkingCountInMissionKeeper,gameObjectId)
		this.playerMarkingCountInMissionKeeper[gameObjectId]=true
		vars.playerMarkingCountInMission=vars.playerMarkingCountInMission+1
	end

	if this.totalMarkingCountKeeper[gameObjectId]==nil then
		table.insert(this.totalMarkingCountKeeper,gameObjectId)
		this.totalMarkingCountKeeper[gameObjectId]=true
		vars.totalMarkingCount=vars.totalMarkingCount+1
	end

	--TODO rX6
	--    TppUI.ShowAnnounceLog"updateMap"
	--    TppSoundDaemon.PostEvent( 'sfx_s_enemytag_main_tgt' )
	--    TppSoundDaemon.PostEvent( 'sfx_s_enemytag_tgt' )
	--    TppSoundDaemon.PostEvent( 'sfx_s_enemytag_sol' )
	--    TppSoundDaemon.PostEvent( 'sfx_s_esc_alert' ) --Vehicle leaving area in M9, M34

	--    TppSoundDaemon.PostEvent( 'sfx_s_tag' )
	--    TppSoundDaemon.PostEvent( 'sfx_s_tagging' )
	--    TppSoundDaemon.PostEvent( 'sfx_s_mark' )
	--    TppSoundDaemon.PostEvent( 'sfx_s_marking' )

	--    TppSoundDaemon.PostEvent('sfx_s_mdnt_date_cng') --wolf howls
end


--local startCPMarkTime=0
--local lastCPSolMarkTime=0
--local markingTimeBuffer=0
--local totalMarkCount=0
--this.lastMarkAnnounceTime=Time.GetRawElapsedTimeSinceStartUp()
--r31 Maintain last mark time
-- this.lastMarkTime=0
--r27 Range based auto marking
--------------AutomarkAllSoldeirsInRange
function this.AutomarkAllSoldeirsInRange()

	--TODO rX46 try using this: TppEnemy..IsActiveSoldierInRange(n,e)
	--	local e={id="IsActiveSoldierInRange",position=n,range=e}
	--  return SendCommand({type="TppSoldier2"},e)

	--TODO rX5 try using this
	--  local IsSavingOrLoading = TppScriptVars.IsSavingOrLoading

	--r31 Mark only every 4 seconds
	--  if svars.scoreTime-this.lastMarkTime < 4000 then
	--    return
	--  end

	--I thinks this variable is always nil unless set somewhere
	if mvars.mis_missionStateIsNotInGame then
		--    TUPPMLog.Log("mvars.mis_missionStateIsNotInGame: "..tostring(mvars.mis_missionStateIsNotInGame))
		return
	end

	--  if DemoDaemon.GetPlayingDemoId() or DemoDaemon.IsDemoPlaying() or DemoDaemon.IsDemoPaused() then
	--    TUPPMLog.Log("DemoDaemon.GetPlayingDemoId: "..tostring(DemoDaemon.GetPlayingDemoId))
	--    TUPPMLog.Log("DemoDaemon.IsDemoPlaying(): "..tostring(DemoDaemon.IsDemoPlaying()))
	--    TUPPMLog.Log("DemoDaemon.IsDemoPaused(): "..tostring(DemoDaemon.IsDemoPaused()))
	--    return
	--  end

	--r28 return when loading
	--maybe this will fix auto-marking related issue where soldiers don't change between free roam sorties
	--THIS IS NOT AN ISSUE
	if mvars.mis_loadRequest then
		--    TUPPMLog.Log("mvars.mis_loadRequest: "..tostring(mvars.mis_loadRequest))
		return
	end

	--r28 not having this check leads to data corruption sadly :/ Game boot up mission codes etc
	if
		vars.missionCode == 50050 or TppMission.IsFOBMission(vars.missionCode) or
		vars.missionCode == 40010
		or vars.missionCode == 40020
		or vars.missionCode == 40050
		or vars.missionCode == 40060
		or vars.missionCode == 1
		or vars.missionCode == 5
		or vars.missionCode == 6000
		--r40 Auto marking no longer works for the following missions
		or vars.missionCode == 10010 --Prologue
		or vars.missionCode == 10280 --M46
	--    or vars.missionCode == 30050 --30050 --rX46 no marking is not the reason outfits are not randomized on checkpoint reloads
	--    or vars.missionCode == 30250 --30250
	then
		return
	end

	--r55 Setting to auto mark irrespective of Intel Unit Scouting function S rank
	if not TUPPMSettings.game_ENABLE_autoMarkWithoutSRank
		and TppMotherBaseManagement.GetSectionFuncRank{sectionFuncId=TppMotherBaseManagementConst.SECTION_FUNC_ID_SPY_ENEMY_SEARCH}~=TppMotherBaseManagementConst.SECTION_FUNC_RANK_S then
		return
	end

	--  startCPMarkTime=0
	--  lastCPSolMarkTime=0

	--  local markingAnnounceTimer=2

	this.UpdateQuestCpIds()
	this.DisableAllSoldierMarkersOutOfRange()
	--r31 Get last marking time before function returns after successful execution
	--this.lastMarkTime=svars.scoreTime

	if mvars.ene_soldierDefine then
		--    this.lastMarkAnnounceTime=Time.GetRawElapsedTimeSinceStartUp()

		--    local function sleep(s)
		--      local ntime = os.clock() + s
		--      repeat until os.clock() > ntime
		--    end

		--      startCPMarkTime=os.clock()
		--      lastCPSolMarkTime=startCPMarkTime
		local markingRange=90601 --301m
		--    TUPPMLog.Log("DEBUG Marking soldiers ----------------------------------")
		for cpName, soldierNameList in pairs(mvars.ene_soldierDefine) do
			--      TUPPMLog.Log("cpName: "..tostring(cpName))
			--      for i=1,10 do
			--        --this is purely to get a non zero os.clock read; nope drop in fps
			--      end

			--      if string.sub(cpName,-2)=="cp" then
			--       markingRange=251001
			--      else
			--        markingRange=90601
			--      end

			--      for _, soldierName in pairs(mvars.ene_soldierDefine[cpName]) do
			for _, soldierName in pairs(soldierNameList) do
				--r37 BUG FIX - for auto marking breaking on fultoning an LRRP vehicle
				local gameObjectId = GameObject.GetGameObjectId("TppSoldier2", soldierName)
				if gameObjectId ~= GameObject.NULL_ID
					and not TppEnemy.IsEliminated(gameObjectId) --r28 shit! seems to make no difference; removes CP reinforce auto mark; for some reason is needed to mark free roam reinforcements that come from CP; r28 breaks the game on checkpoint/restart/abort once reinforcements' call is made, first reinforcemetns do not appear; r25 Do not mark eliminated soldiers
					--          and this.markedSoldiersInRange[gameObjectId]~=true --uncommenting removes MB marking, also the LRRPs in armored vehicles not being marked issue; Trade off is marked soldier count but that isn't very neat with an Update type script anyway so leave this out
					and this.importantMarkerObjects[gameObjectId]~=true --r22 do not mark quest CPs
					and this.CloseToPlayer(gameObjectId, markingRange) --r27 Boo yah!
				then
					--          sleep(0.0001)
					--          os.execute("sleep "..1) --rofl no please don't ever try this again

					this.MarkEm(gameObjectId)
					this.UpdateBOTHMarkingCountKeepers(gameObjectId)--r32 Increase mission/total marking count

					--          this.markedSoldiersInRange[gameObjectId]=true
					--          totalMarkCount=totalMarkCount+1
					--
					--          if string.sub(cpName,-2)=="cp" then
					--            markingAnnounceTimer=3
					--          end
					--
					--          this.lastMarkTime=Time.GetRawElapsedTimeSinceStartUp()
					--          this.lastMarkAnnounceTime=Time.GetRawElapsedTimeSinceStartUp()

					--          mvars.ene_lrrpVehicle[cpName]

					--
					--          lastCPSolMarkTime=os.clock()
					--          TUPPMLog.Log("startCPMarkTime: "..tostring(startCPMarkTime)..", lastCPSolMarkTime: "..tostring(lastCPSolMarkTime))
					--          TUPPMLog.Log("lastCPSolMarkTime: "..tostring(lastCPSolMarkTime))
					--          os.difftime(lastCPSolMarkTime,startCPMarkTime)
					--          this.lastMarkTime=Time.GetRawElapsedTimeSinceStartUp()
					--        else
					--          this.lastMarkTime=0
					--          lastMarkAnounceTime=0
				end
			end

			--the bloody code works too fast, i mean understandable. But even then relying on os.clock() would mean better CPUs would
			-- return a zero time diff
			-- my CPU is returning a zero time difference constantly
			-- Leave the marking count feature, can't be done

			--      if (lastCPSolMarkTime-startCPMarkTime)>0 then
			----      if (lastCPSolMarkTime-startCPMarkTime)>0 then
			----        TUPPMLog.Log("lastCPSolMarkTime-startCPMarkTime: "..tostring(lastCPSolMarkTime-startCPMarkTime))
			--        markingTimeBuffer=markingTimeBuffer+((lastCPSolMarkTime-startCPMarkTime))
			----        markingTimeBuffer=markingTimeBuffer+((lastCPSolMarkTime-startCPMarkTime))
			----        TUPPMLog.Log("markingTimeBuffer: "..tostring(markingTimeBuffer))
			--      end
		end
	end

	--  TUPPMLog.Log("DEBUG soldiers marked ----------------------------------")

	--  if vars.missionCode==30050 then --pre-emptive return for MB marking
	--    totalMarkCount=0
	--    return
	--  end
	--
	--  if
	--    totalMarkCount>0
	--    and (this.lastMarkAnnounceTime-this.lastMarkTime>markingAnnounceTimer)
	--  then --works after much thinking and wrong implementation
	--    TppUI.ShowAnnounceLog"updateMap" --r28 remove
	--    TppUiCommand.AnnounceLogViewLangId("announce_enemy_marked", totalMarkCount) --r24 Muahahahahaha!
	--    totalMarkCount=0
	----    this.lastMarkAnnounceTime=Time.GetRawElapsedTimeSinceStartUp()
	--  end

	--r28 breaks the game on checkpoint/restart/abort; REINFORCEMENTS Not Spawning; Only in missions with Vehicle reinforce
	--r28 Vehicles or drivers cannot be auto marked else game breaking
	--For first reinforcements; other reinforcements will be handled by above call
	--  if mvars.reinforce_lastReinforceInactiveToActive then --nope does not work, i think this variable is only set once and reset to false
	--  if GameObject.GetGameObjectId(TppReinforceBlock.REINFORCE_DRIVER_SOLDIER_NAME)~=GameObject.NULL_ID
	----    and not TppEnemy.IsEliminated(TppReinforceBlock.REINFORCE_DRIVER_SOLDIER_NAME)
	--    and this.CloseToPlayer(TppReinforceBlock.REINFORCE_DRIVER_SOLDIER_NAME)
	--  then
	--    this.MarkEm(TppReinforceBlock.REINFORCE_DRIVER_SOLDIER_NAME)
	--  end

	--r28 Vehicle doesn't spawn in M3/M35 without is alive check
	if GameObject.GetGameObjectId("TppVehicle2",TppReinforceBlock.REINFORCE_VEHICLE_NAME)~=GameObject.NULL_ID
		and TppEnemy.IsVehicleAlive(TppReinforceBlock.REINFORCE_VEHICLE_NAME)
		and this.CloseToPlayer(TppReinforceBlock.REINFORCE_VEHICLE_NAME)
	then
		this.MarkEm(TppReinforceBlock.REINFORCE_VEHICLE_NAME)
		this.UpdateTotalMarkingCountKeeper(TppReinforceBlock.REINFORCE_VEHICLE_NAME)--r32 Increase mission/total marking count
	end
	--
	--r28 breaks the game on checkpoint reload/restart/abort; REINFORCEMENTS Not Spawning; Only in missions with Vehicle reinforce
	--  if vars.missionCode~=10093 then
	for n,name in ipairs(TppReinforceBlock.REINFORCE_SOLDIER_NAMES)do
		if GameObject.GetGameObjectId("TppSoldier2", name)~=GameObject.NULL_ID
			and not TppEnemy.IsEliminated(name) ----r28 for some reason enabling this won't mark free roam reinforcements that come from CP; breaks game
			and this.CloseToPlayer(name)
		then
			this.MarkEm(name)
			this.UpdateBOTHMarkingCountKeepers(name)--r32 Increase mission/total marking count
		end
	end
	--  end --end vars.missionCode~=10093
	--  end --end for mvars.reinforce_lastReinforceInactiveToActive
	--REINFORCEMENTS Not Spawning
	--vehicles
	-- this | will work if mission table were available idiot
	--      V

	--  if missionTable.enemy then
	--    local enemyTable=missionTable.enemy
	--    local vehicleSpawnList = enemyTable.VEHICLE_SPAWN_LIST
	--
	--    if vehicleSpawnList then --important, some missions may not have vehicle spawn list like Lingua Franca
	--      for n,spawnInfo in pairs(vehicleSpawnList)do
	--        local gameObjectId = GameObject.GetGameObjectId( "TppVehicle2", spawnInfo.locator )
	--        TppMarker.Enable( gameObjectId, 0, "none", "map_and_world_only_icon", 0,false, false )
	--        --      TUPPMLog.Log("Marked vehicle "..tostring(gameObjectId))
	--      end
	--    end
	--  end

	--nope this is not it, don't know what the hell I was thinking

	--  if mvars.ene_vehicleSettings~=nil then
	--    for index, gameObjectId in pairs(mvars.ene_vehicleSettings) do
	--      if gameObjectId ~= GameObject.NULL_ID
	--        and not mvars.ene_eliminateVehicleList[gameObjectId]
	--        and this.CloseToPlayer(gameObjectId) --r27
	--      then
	--        this.MarkEm(gameObjectId)
	--      end
	--    end
	--  end

	--  TUPPMLog.Log("DEBUG reinforcements marked ----------------------------------")

	--TODO mark M45 Quiet Exit vehicles separately
	--using game sequence and CloseToPlayer checks do not work after 2nd wave :/
	--so just mark em all
	--but only for game sequences otherwise the Quiet choke cutscene breaks and maybe possibly others
	--r28 Better logic
	if vars.missionCode==10260
	--    and
	--    (
	--    --      TppSequence.GetCurrentSequenceIndex()==TppSequence.GetSequenceIndex("Seq_Demo_QuietChoked") or
	--    TppSequence.GetCurrentSequenceIndex()==TppSequence.GetSequenceIndex("Seq_Game_MainGame_02_Phase01") or
	--    TppSequence.GetCurrentSequenceIndex()==TppSequence.GetSequenceIndex("Seq_Game_MainGame_02_Phase02") or
	--    TppSequence.GetCurrentSequenceIndex()==TppSequence.GetSequenceIndex("Seq_Game_MainGame_02_Phase03") or
	--    TppSequence.GetCurrentSequenceIndex()==TppSequence.GetSequenceIndex("Seq_Game_MainGame_02_Phase04") or
	--    TppSequence.GetCurrentSequenceIndex()==TppSequence.GetSequenceIndex("Seq_Game_MainGame_03")
	--    )
	then

		local m45Vehicles={
			ENEMY_VEHICLE_0000 = "TppVehicleLocator0000",
			ENEMY_VEHICLE_0001 = "TppVehicleLocator0001",
			ENEMY_VEHICLE_0002 = "TppVehicleLocator0002",
			ENEMY_VEHICLE_0003 = "TppVehicleLocator0003",
			ENEMY_VEHICLE_0004 = "TppVehicleLocator0004",
			ENEMY_VEHICLE_0005 = "TppVehicleLocator0005",
			ENEMY_VEHICLE_0006 = "TppVehicleLocator0006",
			ENEMY_VEHICLE_0007 = "TppVehicleLocator0007",
			ENEMY_VEHICLE_0008 = "TppVehicleLocator0008",
			ENEMY_VEHICLE_0009 = "TppVehicleLocator0009",
			ENEMY_VEHICLE_0010 = "TppVehicleLocator0010",
			ENEMY_VEHICLE_0011 = "TppVehicleLocator0011",
			ENEMY_VEHICLE_0012 = "TppVehicleLocator0012",
			ENEMY_VEHICLE_0013 = "TppVehicleLocator0013"
		}

		for variable, vehicleName in pairs(m45Vehicles) do
			if GameObject.GetGameObjectId("TppVehicle2",vehicleName)~=GameObject.NULL_ID
				and TppEnemy.IsVehicleAlive(vehicleName)
				and this.CloseToPlayer(vehicleName)
			then
				this.MarkEm(vehicleName)
				this.UpdateTotalMarkingCountKeeper(vehicleName)--r32 Increase mission/total marking count
			end
		end

		--    this.MarkEm("TppVehicleLocator0000")
		--    this.MarkEm("TppVehicleLocator0001")
		--    this.MarkEm("TppVehicleLocator0002")
		--    this.MarkEm("TppVehicleLocator0003")
		--    this.MarkEm("TppVehicleLocator0004")
		--    this.MarkEm("TppVehicleLocator0005")
		--    this.MarkEm("TppVehicleLocator0006")
		--    this.MarkEm("TppVehicleLocator0007")
		--    this.MarkEm("TppVehicleLocator0008")
		--    this.MarkEm("TppVehicleLocator0009")
		--    this.MarkEm("TppVehicleLocator0010")
		--    this.MarkEm("TppVehicleLocator0011")
		--    this.MarkEm("TppVehicleLocator0012")
		--    this.MarkEm("TppVehicleLocator0013")
	end

	--marking Quiet
	if vars.missionCode==10050 or vars.missionCode==11050 then --Cloaked in Silence
		this.MarkEm("BossQuietGameObjectLocator")
		--r38 Total marked count correctly increases for sniper bosses
		local QuietID=GameObject.GetGameObjectId("BossQuietGameObjectLocator")
		--    TUPPMLog.Log("QuietID: "..tostring(QuietID))
		this.UpdateBOTHMarkingCountKeepers(QuietID)
		--r32 Increase mission/total marking count
		--In mission count is updated only once for Quiet
		--Total marking count is updated every time you mark her
	end

	--SKULLS have to be marked like this. Cheap but no other way. Their enemy list is never populated
	--Each mission has different skulls name, index based call does not work on GetGameObjectId for some reason

	--rX46 Nope doesn't work
	--  if vars.missionCode==30250 then --MBQF
	--    this.MarkEm("hos_volgin_0000")
	--    this.MarkEm("hos_wmu00_0000")
	--    this.MarkEm("hos_wmu00_0001")
	--    this.MarkEm("hos_wmu01_0000")
	--    this.MarkEm("hos_wmu01_0001")
	--    this.MarkEm("hos_wmu03_0000")
	--    this.MarkEm("hos_wmu03_0001")
	--  end
	---
	if vars.missionCode==10020 then --Phantom Limbs
		this.MarkEm("Parasite0")
		this.MarkEm("Parasite1")
		this.MarkEm("Parasite2")
		this.MarkEm("Parasite3")
		--r32 Increase mission/total marking count
		this.UpdateBOTHMarkingCountKeepers("Parasite0")
		this.UpdateBOTHMarkingCountKeepers("Parasite1")
		this.UpdateBOTHMarkingCountKeepers("Parasite2")
		this.UpdateBOTHMarkingCountKeepers("Parasite3")
	end
	---
	---
	if vars.missionCode==10040 then --Where Do the Bees Sleep
		this.MarkEm("wmu_s10040_0000")
		this.MarkEm("wmu_s10040_0001")
		this.MarkEm("wmu_s10040_0002")
		this.MarkEm("wmu_s10040_0003")
		--r32 Increase mission/total marking count
		this.UpdateBOTHMarkingCountKeepers("wmu_s10040_0000")
		this.UpdateBOTHMarkingCountKeepers("wmu_s10040_0001")
		this.UpdateBOTHMarkingCountKeepers("wmu_s10040_0002")
		this.UpdateBOTHMarkingCountKeepers("wmu_s10040_0003")
	end
	---
	---
	if vars.missionCode==10090 or vars.missionCode==11090 then --Traitors Caravan
		this.MarkEm("wmu_s10090_0000")
		this.MarkEm("wmu_s10090_0001")
		this.MarkEm("wmu_s10090_0002")
		this.MarkEm("wmu_s10090_0003")
		--r32 Increase mission/total marking count
		this.UpdateBOTHMarkingCountKeepers("wmu_s10090_0000")
		this.UpdateBOTHMarkingCountKeepers("wmu_s10090_0001")
		this.UpdateBOTHMarkingCountKeepers("wmu_s10090_0002")
		this.UpdateBOTHMarkingCountKeepers("wmu_s10090_0003")
	end
	---
	---
	if vars.missionCode==10130 or vars.missionCode==11130 then --Code Talker

		local wmu_lab_0000ID=GameObject.GetGameObjectId("wmu_lab_0000")
		local wmu_lab_0001ID=GameObject.GetGameObjectId("wmu_lab_0001")
		local wmu_lab_0002ID=GameObject.GetGameObjectId("wmu_lab_0002")
		local wmu_lab_0003ID=GameObject.GetGameObjectId("wmu_lab_0003")

		--    TUPPMLog.Log("wmu_lab_0000ID: "..tostring(wmu_lab_0000ID))
		--    TUPPMLog.Log("wmu_lab_0001ID: "..tostring(wmu_lab_0001ID))
		--    TUPPMLog.Log("wmu_lab_0002ID: "..tostring(wmu_lab_0002ID))
		--    TUPPMLog.Log("wmu_lab_0003ID: "..tostring(wmu_lab_0003ID))

		if wmu_lab_0000ID~=nil and wmu_lab_0000ID~=GameObject.NULL_ID and this.CloseToPlayer(wmu_lab_0000ID)
		then this.MarkEm(wmu_lab_0000ID) this.UpdateBOTHMarkingCountKeepers(wmu_lab_0000ID) end
		if wmu_lab_0001ID~=nil and wmu_lab_0000ID~=GameObject.NULL_ID and this.CloseToPlayer(wmu_lab_0001ID)
		then this.MarkEm(wmu_lab_0001ID) this.UpdateBOTHMarkingCountKeepers(wmu_lab_0001ID) end
		if wmu_lab_0002ID~=nil and wmu_lab_0000ID~=GameObject.NULL_ID and this.CloseToPlayer(wmu_lab_0002ID)
		then this.MarkEm(wmu_lab_0002ID) this.UpdateBOTHMarkingCountKeepers(wmu_lab_0002ID) end
		if wmu_lab_0003ID~=nil and wmu_lab_0000ID~=GameObject.NULL_ID and this.CloseToPlayer(wmu_lab_0003ID)
		then this.MarkEm(wmu_lab_0003ID) this.UpdateBOTHMarkingCountKeepers(wmu_lab_0003ID) end

		--    this.MarkEm(wmu_lab_0000ID)
		--    this.MarkEm(wmu_lab_0001ID)
		--    this.MarkEm(wmu_lab_0002ID)
		--    this.MarkEm(wmu_lab_0003ID)

		--r32 Increase mission/total marking count
		--    this.UpdateBOTHMarkingCountKeepers(wmu_lab_0000ID)
		--    this.UpdateBOTHMarkingCountKeepers(wmu_lab_0001ID)
		--    this.UpdateBOTHMarkingCountKeepers(wmu_lab_0002ID)
		--    this.UpdateBOTHMarkingCountKeepers(wmu_lab_0003ID)

	end
	---
	---
	if vars.missionCode==10140 or vars.missionCode==11140 then --Metallic Archaea
		this.MarkEm("wmu_s10140_0000")
		this.MarkEm("wmu_s10140_0001")
		this.MarkEm("wmu_s10140_0002")
		this.MarkEm("wmu_s10140_0003")
		--r32 Increase mission/total marking count
		this.UpdateBOTHMarkingCountKeepers("wmu_s10140_0000")
		this.UpdateBOTHMarkingCountKeepers("wmu_s10140_0001")
		this.UpdateBOTHMarkingCountKeepers("wmu_s10140_0002")
		this.UpdateBOTHMarkingCountKeepers("wmu_s10140_0003")
	end
	---


	--TODO test in other missions
	--does not work for a M45 Quiet Exit
	--  if mvars.ene_eliminateVehicleList~=nil then
	--    for gameObjectId, vehicleName in pairs(mvars.ene_eliminateVehicleList) do
	--      TUPPMLog.Log("vehicleName: "..tostring(vehicleName))
	--      if gameObjectId ~= GameObject.NULL_ID
	--        and this.CloseToPlayer(gameObjectId) --r27
	--      then
	--        this.MarkEm(gameObjectId)
	--      end
	--    end
	--  end

	--messes up Mission abort/completion when NOT marking mission objective walker gears; when marking it works fine
	--TODO only mission I saw issue with was M12, so need more testing and confirmation; no idea about cause of issue

	--r28 do not use coz some missions have walker gears as mission targets
	--messes up mission abort
	--r31 let's try walker gear marking --works
	local walkerGearsTable = TppEnemy.GetAllActiveEnemyWalkerGear()
	if walkerGearsTable~=nil then
		for index, gameObjectId in pairs(walkerGearsTable) do
			if gameObjectId ~= GameObject.NULL_ID
				and this.CloseToPlayer(gameObjectId) --r27
				and this.importantMarkerObjects[gameObjectId]~=true --r31
			--          and not mvars.ene_eliminateWalkerGearList[gameObjectId] --r28, do not use this, is fucked up, fucks up mission abort with a marked walker gear. avoid marking mission objective gears like in Footprints of Phantoms
			then
				this.MarkEm(gameObjectId)
				this.UpdateTotalMarkingCountKeeper(gameObjectId)--r32 Increase mission/total marking count
			end
		end
	end

	--    TUPPMLog.Log("DEBUG walker gears marked ----------------------------------")

	--r31
	--  local animalsTable = this.GetAllActiveAnimals()
	--  if animalsTable~=nil then
	--    for index, gameObjectId in pairs(animalsTable) do
	--      if gameObjectId ~= GameObject.NULL_ID
	--        and this.CloseToPlayer(gameObjectId) --r27
	--      then
	--        this.MarkEm(gameObjectId)
	--      end
	--    end
	--  end

	--r31 Animals can't be unmarked but the game does a better job of removing animal markers
	-- Can't be unmarked because distance based un/marking does not work
	--r45 Disabled animals auto marking till I figure out a better way to mark/unmark them
	--rX47 All animals(at least 5x6 goats) even disappear when a combat alert is triggered - the limit is on the players current view range - marker limit exists there - as well as the iDroid map, look at how markers break with forced 21:9 resolution patches for better understanding of the marker limit
	--  local animalScriptBlockId=ScriptBlock.GetScriptBlockId("animal_block")
	--	--rX47 Even these checks don't help, markers are removed when an animal block is not active but there is a limit to on screen markers, new markers take priority over old ones
	--  if
	--  	mvars.sbl_scriptBlockState[animalScriptBlockId]==TppDefine.SCRIPT_BLOCK_STATE.ACTIVATED
	--  	and svars.sbl_isActive[animalScriptBlockId]
	--  then
	--r51 Optimizing max counts
	local animalTypeList = {
		{"TppWolf",maxIndex=4},
		{"TppJackal",maxIndex=4},
		{"TppZebra",maxIndex=30},
		{"TppBear",maxIndex=2},
		{"TppGoat",maxIndex=24},
		{"TppNubian",maxIndex=24},
		{"TppRat",maxIndex=10},
		{"TppEagle",maxIndex=10},
		{"TppCritterBird",maxIndex=10},
		{"TppStork",maxIndex=10},
	}
	for i, animalTypeDetails in ipairs( animalTypeList ) do
		--Not a good approach but GetMaxInstanceCount doesn't work on animals
		for count=0,animalTypeDetails.maxIndex do
			local animalObjectId=GameObject.GetGameObjectIdByIndex(animalTypeDetails[1],count)
			if animalObjectId ~= nil
				and animalObjectId ~= GameObject.NULL_ID
				--          and this.CloseToPlayer(animalObjectId) --r27 DIstance based marking does not work on animals
				and this.importantMarkerObjects[animalObjectId]~=true --do not mark quest animals
			--          and GameObject.SendCommand(animalObjectId,{id="GetLifeStatus"})~=TppGameObject.NPC_LIFE_STATE_DEAD
			then
				--        TUPPMLog.Log("animalObjectId: "..tostring(animalObjectId).." for "..tostring(animalType))
				--        local animalLifeStatus=GameObject.SendCommand(animalObjectId,{id="GetLifeStatus"})
				--        local animalPosition=GameObject.SendCommand(animalObjectId,{id="GetPosition"})
				--        TUPPMLog.Log("animalObjectId: "..tostring(animalObjectId))
				--        TUPPMLog.Log("animalLifeStatus: "..tostring(animalLifeStatus))
				--        TUPPMLog.Log("animalPosition: "..tostring(animalPosition))
				this.MarkEm(animalObjectId)

				--        local animalLifeStatus=GameObject.SendCommand(animalObjectId,{id="GetLifeStatus"})
				--        local animalStatus=GameObject.SendCommand(animalObjectId,{id="GetStatus"})
				--        local animalStateFlag=GameObject.SendCommand(animalObjectId,{id="GetStateFlag"})
				--        TUPPMLog.Log(tostring(animalTypeDetails[1]).." animalObjectId: "..tostring(animalObjectId)
				----          ..", animalLifeStatus: "..tostring(animalLifeStatus)
				----          ..", animalStatus: "..tostring(animalStatus)
				--          ..", animalStateFlag: "..tostring(animalStateFlag)
				--          )
				--r32 Increase mission/total marking count - animals can't be marked based on position so don't increment mark count for them
				--        this.UpdateTotalMarkingCountKeeper(animalObjectId)
				--        TUPPMLog.Log("Marked: "..tostring(animalType))
			end
		end
	end
	--  end

	--  TUPPMLog.Log("DEBUG animals marked ----------------------------------")

	--  local vehiclesTable = this.GetAllActiveVehicles()
	--  if vehiclesTable~=nil then
	--    for index, gameObjectId in pairs(vehiclesTable) do
	--      if gameObjectId ~= GameObject.NULL_ID
	--        and this.CloseToPlayer(gameObjectId) --r27
	--      then
	--        this.MarkEm(gameObjectId)
	--      end
	--    end
	--  end

	--r31 Mark vehicles --works
	--Not a good approach but GetMaxInstanceCount doesn't work on vehicles
	-- max instance count is 24 in africa free roam; am using 25
	for count=0,24 do
		local vehicleObjectId=GameObject.GetGameObjectIdByIndex("TppVehicle2",count)
		if vehicleObjectId ~= GameObject.NULL_ID
			and TppEnemy.IsVehicleAlive(vehicleObjectId)
			and this.CloseToPlayer(vehicleObjectId) --r27
			and this.importantMarkerObjects[vehicleObjectId]~=true
		then
			this.MarkEm(vehicleObjectId)
			this.UpdateTotalMarkingCountKeeper(vehicleObjectId)--r32 Increase mission/total marking count
			--        TUPPMLog.Log("Marked: "..tostring(animalType))
		end
	end
	--  TUPPMLog.Log("DEBUG vehicles marked ----------------------------------")

	--TODO --rX6 auto mark mines and decoys on the map
	--  if mvars.rev_revengeMineList then
	--    for cpName,mineFields in pairs(mvars.rev_revengeMineList)do
	--      for i,mineField in ipairs(mineFields)do
	--        if mineField.mineLocatorList then
	--          for i,locatorName in ipairs(mineField.mineLocatorList)do
	--            local gameObjectId = GameObject.GetGameObjectId(locatorName)
	----            TUPPMLog.Log("locatorName: "..tostring(locatorName)..":: gameObjectId: "..tostring(gameObjectId))
	--            TppMarker.Enable( gameObjectId, 0, "none", "map_only_icon", 0, false, false )
	--          end
	--        end
	--      end
	--    end
	--  end

	--  if mvars.rev_mineBaseTable then
	--    local missionStartMineAreaVarsName=mvars.rev_missionStartMineAreaVarsName
	--
	--    if missionStartMineAreaVarsName then
	--      for cpName,cpIndex in pairs(mvars.rev_mineBaseTable)do
	--        local cpMineList=mvars.rev_revengeMineList[cpName]
	--        local locatorList=cpMineList.decoyLocatorList
	--
	--        for index,mineField in ipairs(cpMineList)do
	--          local mineLocatorList=mineField.mineLocatorList
	--          if mineLocatorList then
	--            for index,locatorName in ipairs(mineLocatorList)do
	--              ----
	--            end
	--          end
	--
	--          local decoyLocatorList=mineField.decoyLocatorList
	----          if locatorList then
	----            this._EnableDecoy(cpName,locatorList,addDecoys)
	----            if addDecoys then
	----              t=false
	----            end
	----          end
	----          if decoyLocatorList then
	----            local enable=addDecoys and (index==cpMineFieldIndex)
	----            this._EnableDecoy(cpName,decoyLocatorList,enable)
	----            if enable then
	----              t=false
	----            end
	----          end
	--        end
	--
	--      end
	--    end
	--  end

	--  mvars.ene_parasiteSquadList DOES NOT hold skulls info

	--  local doesMaleParasite1Exist=GameObject.DoesGameObjectExistWithTypeName("TppParasite2",0)
	--  local doesMaleParasite2Exist=GameObject.DoesGameObjectExistWithTypeName("TppParasite2",1)
	--  local doesMaleParasite3Exist=GameObject.DoesGameObjectExistWithTypeName("TppParasite2",2)
	--  local doesMaleParasite4Exist=GameObject.DoesGameObjectExistWithTypeName("TppParasite2",3)
	--
	--  if doesMaleParasite1Exist or doesMaleParasite2Exist or doesMaleParasite3Exist or doesMaleParasite4Exist then
	--    TUPPMLog.Log("doesMaleParasite1Exist: "..tostring(doesMaleParasite1Exist))
	--    TUPPMLog.Log("doesMaleParasite2Exist: "..tostring(doesMaleParasite2Exist))
	--    TUPPMLog.Log("doesMaleParasite3Exist: "..tostring(doesMaleParasite3Exist))
	--    TUPPMLog.Log("doesMaleParasite4Exist: "..tostring(doesMaleParasite4Exist))
	--  end
	--
	--
	--  local doesFemaleParasite1Exist=GameObject.DoesGameObjectExistWithTypeName("TppBossQuiet2",0)
	--  local doesFemaleParasite2Exist=GameObject.DoesGameObjectExistWithTypeName("TppBossQuiet2",1)
	--  local doesFemaleParasite3Exist=GameObject.DoesGameObjectExistWithTypeName("TppBossQuiet2",2)
	--  local doesFemaleParasite4Exist=GameObject.DoesGameObjectExistWithTypeName("TppBossQuiet2",3)
	--  if doesFemaleParasite1Exist or doesFemaleParasite2Exist or doesFemaleParasite3Exist or doesFemaleParasite4Exist then
	--    TUPPMLog.Log("doFemaleParasite1Exist: "..tostring(doesFemaleParasite1Exist))
	--    TUPPMLog.Log("doFemaleParasite2Exist: "..tostring(doesFemaleParasite2Exist))
	--    TUPPMLog.Log("doFemaleParasite3Exist: "..tostring(doesFemaleParasite3Exist))
	--    TUPPMLog.Log("doFemaleParasite4Exist: "..tostring(doesFemaleParasite4Exist))
	--  end

	--  TUPPMLog.Log("Parasites list present?: "..tostring(mvars.ene_parasiteSquadList))

	--  if false and doesMaleParasite1Exist and mvars.ene_parasiteSquadList~=nil then
	--    for index, objectName in pairs(mvars.ene_parasiteSquadList) do
	--      local gameObjectId=GameObject.GetGameObjectId("TppParasite2",objectName)
	--      TUPPMLog.Log("Parasite soldier: "..tostring(objectName)..", Parasite id: "..tostring(gameObjectId))
	--      if gameObjectId ~= GameObject.NULL_ID
	--        and this.CloseToPlayer(gameObjectId) --r27
	--      then
	----        this.MarkEm(gameObjectId)
	----        TppMarker.Enable( gameObjectId, 0, "moving", "map_and_world_only_icon", 0,true, false )
	----        TppMarker.Enable( gameObjectId, 0, "attack", "map_and_world_only_icon", 0,true, false )
	----        TppMarker.Enable( gameObjectId, 0, "defend", "map_and_world_only_icon", 0,true, false )
	--        TUPPMLog.Log("Parasite marked")
	--      end
	--    end
	--  end

	--  local para1=GameObject.GetGameObjectId("TppParasite2", "Parasite0")
	--  local para2=GameObject.GetGameObjectId("TppParasite2", "Parasite1")
	--  local para3=GameObject.GetGameObjectId("TppParasite2", "Parasite2")
	--  local para4=GameObject.GetGameObjectId("TppParasite2", "Parasite3")

	--  local para1=GameObject.GetGameObjectId("TppParasite2", 0)
	--  local para2=GameObject.GetGameObjectId("TppParasite2", 1)
	--  local para3=GameObject.GetGameObjectId("TppParasite2", 2)
	--  local para4=GameObject.GetGameObjectId("TppParasite2", 3)
	--
	--  TUPPMLog.Log("para1: "..tostring(para1))
	--  TUPPMLog.Log("para2: "..tostring(para2))
	--  TUPPMLog.Log("para3: "..tostring(para3))
	--  TUPPMLog.Log("para4: "..tostring(para4))

	--  this.MarkEm(para1)
	--  this.MarkEm(para2)
	--  this.MarkEm(para3)
	--  this.MarkEm(para4)

	--  if para1 ~= GameObject.NULL_ID
	--    and this.CloseToPlayer(para1) --r27
	--  then
	--    this.MarkEm(para1)
	--    TUPPMLog.Log("Marked para1")
	--  end
	--
	--  if para2 ~= GameObject.NULL_ID
	--    and this.CloseToPlayer(para2) --r27
	--  then
	--    this.MarkEm(para2)
	--    TUPPMLog.Log("Marked para2")
	--  end
	--
	--  if para3 ~= GameObject.NULL_ID
	--    and this.CloseToPlayer(para3) --r27
	--  then
	--    this.MarkEm(para3)
	--    TUPPMLog.Log("Marked para3")
	--  end
	--
	--  if para4 ~= GameObject.NULL_ID
	--    and this.CloseToPlayer(para4) --r27
	--  then
	--    this.MarkEm(para4)
	--    TUPPMLog.Log("Marked para4")
	--  end

	--  local femPara1=GameObject.GetGameObjectId("TppBossQuiet2", 0)
	--  local femPara2=GameObject.GetGameObjectId("TppBossQuiet2", 1)
	--  local femPara3=GameObject.GetGameObjectId("TppBossQuiet2", 2)
	--  local femPara4=GameObject.GetGameObjectId("TppBossQuiet2", 3)
	--
	--  TUPPMLog.Log("femPara1: "..tostring(femPara1))
	--  TUPPMLog.Log("femPara2: "..tostring(femPara2))
	--  TUPPMLog.Log("femPara3: "..tostring(femPara3))
	--  TUPPMLog.Log("femPara4: "..tostring(femPara4))

	--  if femPara1~=GameObject.NULL_ID then this.MarkEm(femPara1) end
	--  this.MarkEm(femPara2)
	--  this.MarkEm(femPara3)
	--  this.MarkEm(femPara4)

	--  TUPPMLog.Log("Auto Marking complete at: "..tostring(lastMarkTime))



end

--------------AutoMarkReinforcements
--r28 Seems like free roam reinforcements are not marked by the auto marking code so using this as well
--only explanation would be that ids other than in (soldierDefine and reinforce ids) are used
function this.AutoMarkReinforcements(soldierId)
	--r56 Setting to auto mark irrespective of Intel Unit Scouting function S rank
	if not TUPPMSettings.game_ENABLE_autoMarkWithoutSRank
		and TppMotherBaseManagement.GetSectionFuncRank{sectionFuncId=TppMotherBaseManagementConst.SECTION_FUNC_ID_SPY_ENEMY_SEARCH}~=TppMotherBaseManagementConst.SECTION_FUNC_RANK_S then
		return --r25
	end

	if
		soldierId~=GameObject.NULL_ID
		and soldierId ~= nil
		and this.CloseToPlayer(soldierId)
		and not TppEnemy.IsEliminated(soldierId)
	then
		this.MarkEm(soldierId)
		this.UpdateBOTHMarkingCountKeepers(soldierId)--r32 Increase mission/total marking count
	end
end


--r25 Increase MB Staff morale on visiting motherbase after a 30 minute play time
--r44 MB Morale Boost is now given based on actual game played time instead of in game time
--local timeOfLastMoraleBoost = 0
local timeOfLastMoraleBoost = os.time()
local minutesPlayedRequirement=1
local shouldRandomizeBaseTimeRequirement=true
local tipDisplayCount=1

--------------MBMoraleBoost
function this.MBMoraleBoost()
	--r51 Settings
	if not TUPPMSettings.game_ENABLE_mbMoraleBoost then return end

	--r26 available for all missions; in order to display tip to visit MB
	if vars.missionCode==1
		or vars.missionCode==5
		or vars.missionCode==60000
	then
		return
	end

	--r26 Randomize the play time requirement once
	--This little part makes the time be randomized properly
	if shouldRandomizeBaseTimeRequirement then
		TppMain.Randomize()
		--r26 randomize the time
		--r46 Adjusted random time
		minutesPlayedRequirement=math.random(15,25)
		shouldRandomizeBaseTimeRequirement=false
	end

	--r44 MB Morale Boost is now given based on actual game played time instead of in game time
	--  local currentPlayTime=Time.GetRawElapsedTimeSinceStartUp()
	local currentPlayTime=os.time()
	--  local currentPlayTime=vars.passageSecondsSinceOutMB
	local timePlayedSinceLastMoraleBoost=currentPlayTime-timeOfLastMoraleBoost
	TppMain.Randomize()
	--r26 Nerfed morale boost
	--r44 Increased MB morale boost MAX random amount
	local moraleUp=math.random(3)

	--don't want to use this, why bother
	--  TUPPMLog.Log("shouldRandomizeBaseTimeRequirement: "..tostring(shouldRandomizeBaseTimeRequirement))
	--  TUPPMLog.Log("elapsedTimeSinceLastPlay: "..tostring(gvars.elapsedTimeSinceLastPlay/60).." minutes")
	--
	--  if shouldRandomizeBaseTimeRequirement and (gvars.elapsedTimeSinceLastPlay < (60*5)) then --to avoid clever players; not 100% effective but still :) ;; can't mess with save file anyway
	--    minutesPlayedRequirement=minutesPlayedRequirement+15
	--    shouldRandomizeBaseTimeRequirement=false
	--    TUPPMLog.Log("Last played time less than 5 minutes so setting minutesPlayedRequirement to: "..tostring(minutesPlayedRequirement).." minutes")
	--  elseif shouldRandomizeBaseTimeRequirement then
	--    shouldRandomizeBaseTimeRequirement=false --to avoid it having constantly being 1 if last played time is over 5 minutes
	--    TUPPMLog.Log("Reset startup play flag")
	--  end

	--DEBUG
	--    TUPPMLog.Log("minutesPlayedRequirement: "..tostring(minutesPlayedRequirement).." minutes")
	--    TUPPMLog.Log("tipDisplayCount: "..tostring(tipDisplayCount))
	--    TUPPMLog.Log("currentPlayTime: "..tostring(currentPlayTime/60).." minutes")
	--    TUPPMLog.Log("timeOfLastMoraleBoost: "..tostring(timeOfLastMoraleBoost/60).." minutes")
	--    TUPPMLog.Log("timePlayedSinceLastMoraleBoost: "..tostring(timePlayedSinceLastMoraleBoost/60).." minutes")

	if timePlayedSinceLastMoraleBoost >= 60*minutesPlayedRequirement then
		--r46 Morale boost on visiting MBQF as well
		if vars.missionCode==30050 or vars.missionCode==30250  then
			timeOfLastMoraleBoost=currentPlayTime
			tipDisplayCount=1
			TppMain.Randomize()
			--r26 randomized time increment
			minutesPlayedRequirement=minutesPlayedRequirement+math.random(15)
			TppMotherBaseManagement.IncrementAllStaffMorale{morale=moraleUp}
			--TODO rX6
			TppMusicManager.PostJingleEvent("SingleShot","Play_bgm_training_jingle_clear")

			--      TppMusicManager.PostJingleEvent("SingleShot","Play_bgm_common_jingle_achieved") --Good :) - objectives achieved
			--      TppMusicManager.PostJingleEvent("SingleShot","Play_bgm_training_jingle_clear") --Mission Clear Jingle
			--      TppMusicManager.PostJingleEvent("SingleShot","Play_bgm_training_jingle_failed")
			--      TppMusicManager.PostJingleEvent( "SingleShot", "Play_bgm_mission_heli_descent_short" )
			--      TppMusicManager.PostJingleEvent( "SingleShot", "Stop_bgm_mission_clear_heli" )
			--      TppMusicManager.PostJingleEvent( "MissionEnd", "Stop_bgm_mission_clear_heli" )
			--      TppMusicManager.PostJingleEvent( 'SingleShot', 'Play_chapter_telop' )
			--      TppMusicManager.PostJingleEvent( "SingleShot", "Play_bgm_fob_jingle_matching" )
			--      TppMusicManager.PostJingleEvent( 'SingleShot', 'Play_bgm_fob_jingle_start' )
			--      TppMusicManager.PostJingleEvent( 'SuspendPhase', 'Play_bgm_fob_jingle_start' )
			--      TppMusicManager.PostJingleEvent( "SingleShot", "Play_bgm_fob_jingle_achieved" )
			--      TppMusicManager.PostJingleEvent( "SingleShot", "Play_bgm_fob_jingle_not_achieved" )
			--      TppMusicManager.PostJingleEvent( "SingleShot", "Play_bgm_fob_jingle_retreat" )
			--      TppMusicManager.PostJingleEvent( "MissionEnd", "Play_bgm_fob_jingle_achieved" )
			--      TppMusicManager.PostJingleEvent( "MissionEnd", "Play_bgm_fob_jingle_not_achieved" )
			--      TppMusicManager.PostJingleEvent( "MissionEnd", "Play_bgm_fob_jingle_retreat" )
			--      TppMusicManager.PostJingleEvent( "SingleShot", "Play_bgm_s10240_infected_piano" )
			--      TppMusicManager.PostJingleEvent( "SingleShot", "Play_bgm_s10240_infected_piano_end" )
			--      TppMusicManager.PostJingleEvent( "SingleShot", "Play_bgm_mission_heli_descent")
			--      TppMusicManager.PostJingleEvent("SingleShot","Play_bgm_common_jingle_clear")
			--      TppMusicManager.PostJingleEvent("SingleShot","Play_bgm_common_jingle_failed")

			--      TppMusicManager.PostJingleEvent("SingleShot","Play_bgm_common_jingle_op")
			--      TppMusicManager.PostJingleEvent("SingleShot","Play_bgm_afgh_jingle_op")
			--      TppMusicManager.PostJingleEvent("SingleShot","Play_bgm_mafr_jingle_op")
			--      TppMusicManager.PostJingleEvent("SingleShot","Play_bgm_s10151_jingle_ed")
			--      TppMusicManager.PostJingleEvent("SingleShot","Play_bgm_common_jingle_ed")
			--      TppMusicManager.PostJingleEvent("RegisterMissionStart","Play_bgm_common_jingle_op")
			--      TppMusicManager.PostJingleEvent("RegisterMissionStart","Play_bgm_afgh_jingle_op")
			--      TppMusicManager.PostJingleEvent("RegisterMissionStart","Play_bgm_mafr_jingle_op")
			--      TppMusicManager.PostJingleEvent("MissionEnd","Play_bgm_s10151_jingle_ed")
			--      TppMusicManager.PostJingleEvent("MissionEnd","Play_bgm_common_jingle_ed")

			--      TppMusicManager.PostJingleEvent("SingleShot","Set_Switch_bgm_jingle_result_kaz")
			--      TppMusicManager.PostJingleEvent("SingleShot","Stop_bgm_common_jingle_ed")

			--      e.ResultRankJingle={"Set_Switch_bgm_jingle_result_s","Set_Switch_bgm_jingle_result_ab","Set_Switch_bgm_jingle_result_ab","Set_Switch_bgm_jingle_result_cd","Set_Switch_bgm_jingle_result_cd","Set_Switch_bgm_jingle_result_e"}e.ResultRankJingle[TppDefine.MISSION_CLEAR_RANK.NOT_DEFINED]="Set_Switch_bgm_jingle_result_cd"e.afghCommonEsacapeBgm={bgm_escape={start="Play_bgm_afgh_mission_escape",finish="Stop_bgm_afgh_mission_escape"}}e.mafrCommonEsacapeBgm={bgm_escape={start="Play_bgm_mafr_mission_escape",finish="Stop_bgm_mafr_mission_escape"}}e.commonHeliStartBgm={bgm_heliStart={start="Play_bgm_mission_start",finish="Stop_bgm_mafr_mission_escape"}}

			--        TppSoundDaemon.PostEvent"sfx_s_rescue_pow" --hell no

			--      TppUiCommand.AnnounceLogViewLangId("announce_morale_boost")
			--r38 Since morale boost happens in-game now so new message is displayed
			TppUiCommand.AnnounceLogViewLangId("announce_morale_boost2")
		elseif tipDisplayCount <=3 then
			tipDisplayCount=tipDisplayCount+1
			TppUiCommand.AnnounceLogViewLangId("announce_morale_boost_visit_tip") --r26 Provide input to players to visit MB
		end
	end

end

--r29 This does not fix the emblems on Shields
--Only decides DD right arm patch
function this.SetupEmblemFixForMB()
	if not TppMission.IsMbFreeMissions(vars.missionCode) then return end

	--  local emblemType = 1 --Player emblem
	--  local emblemType = 2 --FOB emblem
	--  local gameObjectId = { type="TppSoldier2" }
	--  local command = { id = "SetEmblemType", type = emblemType }
	--  GameObject.SendCommand( gameObjectId, command )

	--	TppServerManager.SynchronizeEmblem() --nope

	--rX46 Tried new functions
	TppUiCommand.CreateEmblemToVisit() --resets emblem to default DD emblem on Snake and staff but not MB building nor support heli - used definitely for FOB emblems, did not test after FOB and going to MB
	TppUiCommand.CreateEmblem() --nope :(
	--Combination of above two does not work either

	TUPPMLog.Log("Reset MB shields emblem hopefully",3)
end

--r33 Strongest land mines
function this.ModifyMineTypes()
	--local mineFieldMineTypes={
	--  {TppEquip.EQP_SWP_DMine,3},--tex bias toward original minefield intentsion/anti personal mines
	--  TppEquip.EQP_SWP_SleepingGusMine, --Useless
	--  TppEquip.EQP_SWP_AntitankMine, --Useless enemies not alerted
	--  TppEquip.EQP_SWP_ElectromagneticNetMine, --why even bother testing
	--  TppEquip.EQP_SWP_DMine_G03,
	--}

	--r36 Changed mine type to one that DD can mark on the map
	--  local mineTypeBag=TppEquip.EQP_SWP_DMine_G03 --strongest, not marked by DD
	local mineTypeBag=TppEquip.EQP_SWP_DMine_G02 --second strongest, marked by DD
	--  local mineTypeBag=TppEquip.EQP_SWP_DMine_G01 --marked by DD
	--  local mineTypeBag=TppEquip.EQP_SWP_DMine --marked by DD

	if mvars.rev_revengeMineList then
		for cpName,mineFields in pairs(mvars.rev_revengeMineList)do
			for i,mineField in ipairs(mineFields)do
				if mineField.mineLocatorList then
					for i,locatorName in ipairs(mineField.mineLocatorList)do
						TppPlaced.ChangeEquipIdByLocatorName(locatorName,mineTypeBag)
					end
				end
			end
		end
	end
end

function this.AcquirePerishableCassetteTapes()

	--mvars.mis_missionStateIsNotInGame - this baby is true during ALL loading times :)
	--  if mvars.mis_missionStateIsNotInGame then
	--    --TUPPMLog.Log("Not in game returning from AcquirePerishableCassetteTapes")
	--    return
	--  end

	--no need
	--  if vars.missionCode == 50050
	--    or vars.missionCode == 40010
	--    or vars.missionCode == 40020
	--    or vars.missionCode == 40050
	--    or vars.missionCode == 40060
	--    -- The following three are not enough to prevent issues during game bootup
	--    or vars.missionCode == 1
	--    or vars.missionCode == 5
	--    or vars.missionCode == 6000
	--  then
	----    TUPPMLog.Log("Mission codes not in game, returning from AcquirePerishableCassetteTapes")
	--    return
	--  end

	--beat M31 to regain all usable tapes regularly
	if TppStory.IsMissionCleard( 10151 )  == false then
		return
	end

	local isShowAnnounceLog=true
	local pushReward=false

	local tapesList={
		"tp_sp_01_01", --"Afghan Lullaby"
		"tp_sp_01_02", --"African Lullaby"
		--    "tp_sp_01_03", --"Love Deterrence"
		--    "tp_sp_01_04", --"Quiet's Theme"
		"tp_sp_01_05", --"&quot;Enemy Eliminated&quot;"
		"tp_sp_01_06", --"&quot;Enemy Eliminated&quot;"
		"tp_sp_01_07", --"Recorded in the Toilet"

	--Not sure if the following even break and disappear
	--    "tp_sp_01_08", --"Bird Calls"
	--    "tp_sp_01_09", --"Goat Bleats"
	--    "tp_sp_01_10", --"Horse Neighs"
	--    "tp_sp_01_11", --"Wolf Howls"
	--    "tp_sp_01_12", --"Bear Growls"
	}

	if TppQuest.IsCleard("mtbs_q99060") then
		--    TUPPMLog.Log("Gained Paz's tape")
		table.insert(tapesList, "tp_sp_01_03")
	end

	if TppBuddyService.GetFriendlyPoint(BuddyFriendlyType.QUIET)>60 then
		--    TUPPMLog.Log("Gained Quiet's tape")
		table.insert(tapesList,"tp_sp_01_04")
	end

	local birdsTable={
		TppMotherBaseManagementConst.ANIMAL_1200, --"Bird"
		TppMotherBaseManagementConst.ANIMAL_1210, --"Bird"
		TppMotherBaseManagementConst.ANIMAL_1220, --"Bird"

		TppMotherBaseManagementConst.ANIMAL_2200, --"Bird"
		TppMotherBaseManagementConst.ANIMAL_2210, --"Bird"
		TppMotherBaseManagementConst.ANIMAL_2240, --"Bird"
		TppMotherBaseManagementConst.ANIMAL_2241, --"Bird"
		TppMotherBaseManagementConst.ANIMAL_2250, --"Bird"
	}

	local goatsTable={
		TppMotherBaseManagementConst.ANIMAL_1900, --"Goat"
		TppMotherBaseManagementConst.ANIMAL_1913, --"Goat"
		TppMotherBaseManagementConst.ANIMAL_1920, --"Goat"
		TppMotherBaseManagementConst.ANIMAL_1933, --"Goat"
	}

	local zebrasTable={
		TppMotherBaseManagementConst.ANIMAL_200, --"Zebra"
		TppMotherBaseManagementConst.ANIMAL_210, --"Zebra"
		TppMotherBaseManagementConst.ANIMAL_220, --"Zebra"

		TppMotherBaseManagementConst.ANIMAL_1940, --"Nubian"
		TppMotherBaseManagementConst.ANIMAL_1957, --"Nubian"
		TppMotherBaseManagementConst.ANIMAL_1960, --"Nubian"
		TppMotherBaseManagementConst.ANIMAL_1977, --"Nubian"
	}

	local wolfsTable={
		TppMotherBaseManagementConst.ANIMAL_100, --"Wolf"

		TppMotherBaseManagementConst.ANIMAL_110, --"Jackal"
		TppMotherBaseManagementConst.ANIMAL_120, --"Jackal"
		TppMotherBaseManagementConst.ANIMAL_130, --"Jackal"
	}

	local bearsTable={
		TppMotherBaseManagementConst.ANIMAL_600, --"Bear"
		TppMotherBaseManagementConst.ANIMAL_610, --"Bear"
	}

	--No tape - save memory
	--  local ratsTable={
	--    TppMotherBaseManagementConst.ANIMAL_1400, --"Rat"
	--    TppMotherBaseManagementConst.ANIMAL_1403, --"Rat"
	--    TppMotherBaseManagementConst.ANIMAL_1410, --"Rat"
	--    TppMotherBaseManagementConst.ANIMAL_1420, --"Rat"
	--    TppMotherBaseManagementConst.ANIMAL_1430, --"Rat"
	--  }

	local isBirdCassette=false
	local isGoatCassette=false
	local isZebraCassette=false
	local isWolfCassette=false
	local isBearCassette=false

	--lol booleans have to be set to tostring() before announce log will show them, else breaks game
	--now i realize this :p

	for i,j in pairs(birdsTable) do
		isBirdCassette=TppMotherBaseManagement.IsGotDataBase{ dataBaseId = j }
		if isBirdCassette then
			--      TUPPMLog.Log("Gained isBirdCassete tape: "..tostring(isBirdCassette))
			table.insert(tapesList, "tp_sp_01_08")
			break
		end
	end
	for i,j in pairs(goatsTable) do
		isGoatCassette=TppMotherBaseManagement.IsGotDataBase{ dataBaseId = j }
		if isGoatCassette then
			--      TUPPMLog.Log("Gained isGoatCassete tape: "..tostring(isGoatCassette))
			table.insert(tapesList, "tp_sp_01_09")
			break
		end
	end
	for i,j in pairs(zebrasTable) do
		isZebraCassette=TppMotherBaseManagement.IsGotDataBase{ dataBaseId = j }
		if isZebraCassette then
			--      TUPPMLog.Log("Gained isZebraCassete tape: "..tostring(isZebraCassette))
			table.insert(tapesList, "tp_sp_01_10")
			break
		end
	end
	for i,j in pairs(wolfsTable) do
		isWolfCassette=TppMotherBaseManagement.IsGotDataBase{ dataBaseId = j }
		if isWolfCassette then
			--      TUPPMLog.Log("Gained isWolfCassete tape: "..tostring(isWolfCassette))
			table.insert(tapesList, "tp_sp_01_11")
			break
		end
	end
	for i,j in pairs(bearsTable) do
		isBearCassette=TppMotherBaseManagement.IsGotDataBase{ dataBaseId = j }
		if isBearCassette then
			--      TUPPMLog.Log("Gained isBearCassete tape: "..tostring(isBearCassette))
			table.insert(tapesList, "tp_sp_01_12")
			break
		end
	end

	TppCassette.Acquire{cassetteList=tapesList, isShowAnnounceLog=isShowAnnounceLog, pushReward=pushReward}
end

--rX45 Testing for a command that may force salutes
function this.SetAllSoldiersToSalute()
	if mvars.ene_soldierDefine then
		for cpName, soldierNameList in pairs(mvars.ene_soldierDefine) do
			for _, soldierName in pairs(soldierNameList) do
				local gameObjectId = GameObject.GetGameObjectId( "TppSoldier2", soldierName )
				local command = { id="SetSaluteDisable", enabled = false }
				GameObject.SendCommand( gameObjectId, command )
			end
		end
	end
end

--rX45 Force salute for on foot MB drop
--Salute routes only exist for MB Command roof heli pad(2) and deck heli pad(4)
--If called from end of OnInitialize, the salute route is set correctly, however
-- the soldiers are then assigned to the 4th MB Command deck and not the first
--f30050_enemy.SetupSalutationEnemy() is called from Seq_Game_HeliStart in f30050_sequence
--Calling the same from Seq_Game_MainGame OnEnter will set salute routes and use the soldiers
-- from the 1st Command deck
--TODO Test demos
function this.SetSoldiersToSaluteForMBFakeHeliDrop()
	--  TUPPMLog.Log("SetSoldiersToSaluteForMBFakeHeliDrop")

	--  local startClusterId  = mtbs_helicopter.GetHeliStartClusterId()
	--  local startPlatformId = mtbs_helicopter.GetHeliStartPlatformId()
	--  local isHeliport    = mtbs_helicopter.IsHeliStartHeliport()
	--  TUPPMLog.Log("startClusterId:"..tostring(startClusterId).." startPlatformId:"..tostring(startPlatformId).." isHeliport:"..tostring(isHeliport))

	--  local file = InfInspect.Inspect(mtbs_enemy.GetSoldierForSalutation( "Command", "plnt0", 4 ))
	----  local file = InfInspect.Inspect(mvars.mbSoldier_funcGetAssetTable( 1 )["plnt0"])
	--  InfInspect.DebugPrint(file)

	if vars.missionCode==30050 and f30050_enemy and f30050_enemy.SetupSalutationEnemy then
		--      TUPPMLog.Log("BEFORE mvars.mbHelicopter_startPlatformId:"..tostring(mvars.mbHelicopter_startPlatformId))
		--      mvars.mbHelicopter_startPlatformId=4 -- to get soldiers from first platform itself, otherwise 4rth platform is picked
		f30050_enemy.SetupSalutationEnemy() --Breaks on ZOO and MBQF
		--      TUPPMLog.Log("AFTER mvars.mbHelicopter_startPlatformId:"..tostring(mvars.mbHelicopter_startPlatformId))
	end
	--  startClusterId  = mtbs_helicopter.GetHeliStartClusterId()
	--  startPlatformId = mtbs_helicopter.GetHeliStartPlatformId()
	--  isHeliport    = mtbs_helicopter.IsHeliStartHeliport()
	--  TUPPMLog.Log("startClusterId:"..tostring(startClusterId).." startPlatformId:"..tostring(startPlatformId).." isHeliport:"..tostring(isHeliport))

end

--r35 Fake create a heli at LZ position
this.firstFakeHeli=0
function this.ForceCreateHeli()
	if TppMission.IsFOBMission(vars.missionCode) then return end
	--r45 Updates to method for MB/Zoo/MBQF
	TUPPMLog.Log("ForceCreateHeli BEG",3)

	local gameObjectId = GameObject.GetGameObjectId("TppHeli2", "SupportHeli")
	TUPPMLog.Log("Heli gameObjectId is present:"..tostring(gameObjectId),3)

	if gameObjectId==GameObject.NULL_ID then
		return
	end

	--r51 Settings
	if
		TUPPMSettings.heli_ENABLE_forceSearchLightAlwaysOn
		and vars.missionCode ~= 40010
		and vars.missionCode ~= 40020
		and vars.missionCode ~= 40050
		and vars.missionCode ~= 40060
		and vars.missionCode ~= 1
		and vars.missionCode ~= 5
		and vars.missionCode ~= 6000
	then
		GameObject.SendCommand(gameObjectId, { id="SetSearchLightForcedType", type="On" } )
		--    TUPPMLog.Log(tostring(vars.missionCode).." SetSearchLightForcedType ON")
	else
	--		GameObject.SendCommand(gameObjectId, { id="SetSearchLightForcedType", type="Off" } )
	--    TUPPMLog.Log(tostring(vars.missionCode).." SetSearchLightForcedType OFF")
	end

	--DEBUG ONLY FOR TESTING AND SETTING POINTS
	--    this.isFakeHeliDropRequired=true

	--  TUPPMLog.Log("this.isFakeHeliDropRequired:"..tostring(this.isFakeHeliDropRequired))

	if not this.isFakeHeliDropRequired then return end
	TUPPMLog.Log("isFakeHeliDropRequired is true",3)

	this.isFakeHeliDropRequired=false

	if gvars.heli_missionStartRoute==nil then
		return
	end
	TUPPMLog.Log("gvars.heli_missionStartRoute present",3)

	local route = TppMain.GetUsingRouteDetails()

	if route==nil then
		return
	end
	TUPPMLog.Log("Route present in positions table",3)

	if vars.missionCode==30050 or vars.missionCode==30150 or vars.missionCode==30250 then
		TUPPMLog.Log("Setting MB heli behavior",3)

		--This is enough to spawn heli overhead!!! At least on MB
		--isTakeOff makes no diff
		--point makes no diff
		--leftDoor makes no diff
		--rightDoor makes no diff
		--enabled makes no diff
		--    GameObject.SendCommand(gameObjectId, { id="SendPlayerAtRoute", route=route.takeOffRt})
		--    GameObject.SendCommand(gameObjectId, { id="SendPlayerAtRoute", route=route.name, isTakeOff=false })
		--      GameObject.SendCommand(gameObjectId, { id="SendPlayerAtRoute", route="rt_heli_takeoff_opening" })
		--    TUPPMLog.Log("SendPlayerAtRoute takeoff false")



		--HAHAHAHAHAHAHA!
		--Readies heli at route start
		GameObject.SendCommand(gameObjectId, { id="SendPlayerAtRouteReady", route=route.takeOffRt})
		TUPPMLog.Log("SendPlayerAtRouteReady:"..tostring(route.takeOffRt),3)
		--GameObject.SendCommand( gameObjectId, { id = "SetEnabled", enabled = true} )

		--    GameObject.SendCommand(gameObjectId, { id="Realize" })
		--    GameObject.SendCommand(gameObjectId, { id="SetDemoToLandingZoneEnabled ", enabled=true } )
		--    GameObject.SendCommand(gameObjectId, { id="SetDemoToAfterDropEnabled", enabled=true, route=route.takeOffRt, isTakeOff=false } )
		--    GameObject.SendCommand(gameObjectId, { id="SetDemoToSendEnabled", enabled=true, route=route.takeOffRt } )
		--    GameObject.SendCommand(gameObjectId, { id="SendPlayerAtRoute", route=route.takeOffRt })


		--    GameObject.SendCommand(gameObjectId, { id="Realize" })
		--    GameObject.SendCommand(gameObjectId, {id="CallToLandingZoneAtName", name=route.lzname}) --does not fire during loading
		--    TUPPMLog.Log("CallToLandingZoneAtName: "..tostring(route.lzname),3)
		--    GameObject.SendCommand( gameObjectId, { id = "SetEnabled", enabled = true} )

		--    GameObject.SendCommand(gameObjectId, { id="SetDemoToAfterDropEnabled", enabled=true, route=route.lzname, isTakeOff=true })
		--    TUPPMLog.Log("SetDemoToAfterDropEnabled: "..tostring(route.lzname),3)

		--    GameObject.SendCommand(gameObjectId, { id="SetDemoToSendEnabled", enabled=true, route=route.lzname, warp=true })
		--    TUPPMLog.Log("SetDemoToSendEnabled: "..tostring(route.lzname),3)


		--    GameObject.SendCommand(gameObjectId, { id="SendPlayerAtRouteStart", route=route.takeOffRt})
		--    TppBuddy2BlockController.CallBuddy(vars.buddyType,Vector3(vars.playerPosX,vars.playerPosY,vars.playerPosZ),vars.playerRotY)

		--works too, with obvious issues and force pull out after disabling route
		--    GameObject.SendCommand(gameObjectId, { id="SetForceRoute", enabled=true, route=route.takeOffRt, point=0, warp=true, isRelaxed=true})

		--      TppHelicopter.SetEnableLandingZone{ landingZoneName = "lz_commfacility_0000" } --Seems to send heli off to some distant LZ, but only the first time the LZ is enabled!
		--      TUPPMLog.Log("lz_commfacility_0000")
		--      TppHelicopter.SetEnableLandingZone{ landingZoneName = "lz_commfacility_0002" }
		--      TUPPMLog.Log("lz_commfacility_0002")

		--SetLandingZnoeDoorFlag seems not to work at all -- logs not printing means error, LZ name has to be exactly correct and LZ has to be present!
		--      GameObject.SendCommand( gameObjectId, { id="SetLandingZnoeDoorFlag", name=string.sub(route.name, 1, -9), leftDoor="Open", rightDoor="Close" } )
		--      TUPPMLog.Log("SetLandingZnoeDoorFlag "..tostring(string.sub(route.name, 1, -9)))
		--      GameObject.SendCommand( gameObjectId, { id="SetLandingZnoeDoorFlag", name="lz_commfacility_0000", leftDoor="Open", rightDoor="Close" } )
		--      TUPPMLog.Log("SetLandingZnoeDoorFlag lz_commfacility_0000")
		----      GameObject.SendCommand( gameObjectId, { id="SetLandingZnoeDoorFlag", name="lz_commfacility_0002", leftDoor="Open", rightDoor="Close" } )
		--      TUPPMLog.Log("SetLandingZnoeDoorFlag lz_commfacility_0002")
		--
		--      I am convinced this triggers demo after heli drop, but is used from the demo at start of M30 Skull Face
		--      GameObject.SendCommand(gameObjectId,{id="SetDemoToAfterDropEnabled",enabled=true,route=route.name, isTakeOff=false})
		--      GameObject.SendCommand(gameObjectId, { id="SetDemoToAfterDropEnabled", enabled=true, route="rt_heli_takeoff_opening", isTakeOff=true } )
		--      GameObject.SendCommand(gameObjectId,{id="SetDemoToAfterDropEnabled",enabled=true,route="ly003_cl00_30050_heli0000|cl00pl0_mb_fndt_plnt_heli_30050|rt_tkof",isTakeOff=true})
		--      TUPPMLog.Log("SetDemoToAfterDropEnabled")
		--
		--  	GameObject.SendCommand(gameObjectId, { id="SetDemoToAfterDropEnabled", enabled=true, route=route.takeOffRt, isTakeOff=true } )

		--
		--    --rX45 Do not set here, detailed reason with function definition

		--r46 works correctly if ForceCreateHeli called from OnMissionCanStart
		--r55 Re removed cause on a new MB shit gets out of hand if soldiers from other plat arrive to salute on a single command cluster
		--this.SetSoldiersToSaluteForMBFakeHeliDrop()

		this.firstFakeHeli=1
		TUPPMLog.Log("Set MB heli behavior",3)
	else
		if route.hostile then
			return
		end

		if route.point==nil then
			return
		end

		TUPPMLog.Log("Setting non-MB heli behavior",3)

		--    TUPPMLog.Log("gvars.heli_missionStartRoute: "..tostring(gvars.heli_missionStartRoute))
		--    TUPPMLog.Log("LZRoute: "..tostring(route.name)..", Point: "..tostring(route.point))
		--    TUPPMLog.Log("X: "..tostring(route.pos[1])..", Y: "..tostring(route.pos[2])..", Z: "..tostring(route.pos[3]))

		--    GameObject.SendCommand(gameObjectId, {id="SetLandingZnoeDoorFlag", route=route.lzname, leftDoor="Open",rightDoor="Open"})
		--    TUPPMLog.Log("SetLandingZnoeDoorFlag")

		--RequestRoute enabled=false does not set route
		--RequestRoute leftDoor makes no diff
		--RequestRoute rightDoor makes no diff
		--r45 OBSOLETE method for heli positioning
		--    GameObject.SendCommand(gameObjectId, { id="RequestRoute", enabled=true, route=route.dropRt, point=route.point, warp=true, isRelaxed=true})
		--    TUPPMLog.Log("RequestRoute:"..tostring(route.dropRt).." point:"..tostring(route.point))

		--TODO r4X45 With the use of SendPlayerAtRouteReady for both MB and others, this method can be made much much simpler, and cleaned
		--r45 Better method to place heli at LZ
		GameObject.SendCommand(gameObjectId, { id="SendPlayerAtRouteReady", route=route.takeOffRt})
		TUPPMLog.Log("SendPlayerAtRouteReady:"..tostring(route.takeOffRt),3)

		--SetForceRoute enabled=false does not set route
		--    GameObject.SendCommand(gameObjectId, { id="SetForceRoute", enabled=true, route=route.dropRt, point=route.point, warp=true, isRelaxed=true})
		----    GameObject.SendCommand(gameObjectId, { id="SetForceRoute", enabled=false, route=route.name, point=route.point, warp=true, isRelaxed=true})
		--    TUPPMLog.Log("SetForceRoute:"..tostring(route.dropRt).." point:"..tostring(route.point))

		--    --NO such command as "Route"
		--    --enabled=false does not set route
		--    GameObject.SendCommand(gameObjectId, { id="Route", enabled=true, route=route.name, point=route.point, warp=true, isRelaxed=true})
		----    GameObject.SendCommand(gameObjectId, { id="Route", enabled=false, route=route.name, point=route.point, warp=true, isRelaxed=true})
		--    TUPPMLog.Log("Route")


		--Makes no diff if ForceRoute/RequestRoute is set above unless
		--    GameObject.SendCommand(gameObjectId, { id="SetForceRoute", enabled=false})
		--    GameObject.SendCommand(gameObjectId, { id="SendPlayerAtRouteFinish", route=route.dropRt, point=route.point, warp=true }) --NoSuchCommand
		--    GameObject.SendCommand(gameObjectId, { id="SendPlayerAtRouteEnd", route=route.dropRt, point=route.point, warp=true }) --NoSuchCommand
		--    GameObject.SendCommand(gameObjectId, { id="SendPlayerAtRoute", route=route.takeOffRt, point=route.point, warp=true }) --nope


		--    GameObject.SendCommand(gameObjectId, { id="SetLife", life=10000 })
		--    local life = GameObject.SendCommand(gameObjectId, { id="GetLife"})
		--    TUPPMLog.Log("life: "..tostring(life))
		--    GameObject.SendCommand(gameObjectId, { id="SetLandingZnoeDoorFlag", route=route.lzname, leftDoor="Open",rightDoor="Open" })
		--    GameObject.SendCommand(gameObjectId,{id="SetSendDoorOpenManually",enabled=true})

		--    GameObject.SendCommand(gameObjectId, { id="CallToLandingZoneAtName",name=route.lzname, point=28, warp=true })
		--    GameObject.SendCommand(gameObjectId, { id="SetLandingZnoeDoorFlag", route=route.name, leftDoor="Open",rightDoor="Open" })
		--    GameObject.SendCommand(gameObjectId, { id="SetRequestedLandingZoneToCurrent" } )
		--    GameObject.SendCommand(gameObjectId, { id="EnableDescentToLandingZone" } )

		--    mvars.seq_heliStartSequence="Seq_Game_HeliStart" --nope --desperate attemp :/
		TUPPMLog.Log("Set non-MB heli behavior",3)
		this.firstFakeHeli=1
	end

	--  GameObject.SendCommand(gameObjectId, {id="CallToLandingZoneAtName", name=route.lzname}) --If called from OnMissionCanStart then it calls the heli proper

	--nope
	--  GameObject.SendCommand(gameObjectId, {id="SetLandingZnoeDoorFlag", route=gvars.heli_missionStartRoute, leftDoor="Open",rightDoor="Open"})
	--nope
	--  GameObject.SendCommand(gameObjectId, {id="SetLandingZnoeDoorFlag", route=route.name, leftDoor="Open",rightDoor="Open"})
	--  GameObject.SendCommand(gameObjectId, { id="SetLandingZnoeDoorFlag", route=route.lzname, leftDoor="Open",rightDoor="Open" })
end

--TODO FORCE THAT FUCKING DOOR OPEN!
function this.ForceOpenHeliDoors()

	if TppMission.IsFOBMission(vars.missionCode) then return end

	if this.firstFakeHeli==0 then return end

	if gvars.heli_missionStartRoute then

		local route = TppMain.GetUsingRouteDetails()

		if route==nil then
			return
		end

		if route.hostile then
			return
		end

		if route.point==nil then
			return
		end

		local gameObjectId = GameObject.GetGameObjectId("TppHeli2", "SupportHeli")

		if gameObjectId==GameObject.NULL_ID then
			return
		end

		GameObject.SendCommand(gameObjectId, {id="CallToLandingZoneAtName", name=route.lzname})

		--works but sets the door state for LZs
		--    GameObject.SendCommand(gameObjectId, { id="SetLandingZnoeDoorFlag", name=route.lzname, leftDoor="Open", rightDoor="Close" })

		--nope, has to be fired on LZ
		--    GameObject.SendCommand(gameObjectId, { id="SetLandingZnoeDoorFlag", name=route.takeOffRt, leftDoor="Open", rightDoor="Close" })

		--    GameObject.SendCommand(gameObjectId,{id="SetSendDoorOpenManually",enabled=true}) --nope
		--    GameObject.SendCommand(gameObjectId,{id="SetSendDoorOpenManually",enabled=false}) --nope
		--    GameObject.SendCommand(gameObjectId, { id="SetLandingZnoeDoorFlag", route=route.lzname, leftDoor="Open",rightDoor="Open" })
		--    GameObject.SendCommand(gameObjectId, { id="SetLandingZnoeDoorFlag", route=route.name, leftDoor="Open",rightDoor="Open" })
		--    GameObject.SendCommand(gameObjectId, {id="SetLandingZnoeDoorFlag", route=gvars.heli_missionStartRoute, leftDoor="Open",rightDoor="Open"})
		--    GameObject.SendCommand(gameObjectId, {id="SetLandingZnoeDoorFlag", leftDoor="Open",rightDoor="Open"})

		--    GameObject.SendCommand({type="TppHeli2",index=0},{id="SetSendDoorOpenManually",enabled=false})
		----    GameObject.SendCommand({type="TppHeli2",index=0},{id="SetSendDoorOpenManually",enabled=true})
		--    GameObject.SendCommand({type="TppHeli2",index=0},{id="RequestSnedDoorOpen"})
		----    GameObject.SendCommand({type="TppHeli2",index=0}, { id="SetGettingOutEnabled", enabled=true })

		--rX46 No go
		--    mvars.mis_helicopterDoorOpenTimerTimeSec=1
		--    TppMission.StartHelicopterDoorOpenTimer()
		--    Player.RequestToHeliSideIdle()
		--    Player.HeliSideToFOBStartPos()
		TUPPMLog.Log("Heli doors opened! :D",3)
	end
end

--r35 All Gimmicks across both locations
this.resetGimmicksList={
	--It is possible to reset AACRs as well but they do not block LZs immediately
	--NOT SURE: Radio cassettes should not be reset using this as they break the normal reset command

	afghan={
		-- commFacility_antn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0000|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/commFacility/afgh_commFacility_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_commFacility", },
		-- commFacility_antn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0001|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/commFacility/afgh_commFacility_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_commFacility", },
		-- commFacility_antn003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0002|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/commFacility/afgh_commFacility_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_commFacility", },
		-- commFacility_mchn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0001|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/commFacility/afgh_commFacility_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_commFacility", },
		-- commFacility_mchn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0002|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/commFacility/afgh_commFacility_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_commFacility", },
		-- commFacility_mchn003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0000|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/commFacility/afgh_commFacility_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_commFacility", },
		-- commFacility_aacr001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn006_gim_n0000|srt_afgh_antn006", dataSetName = "/Assets/tpp/level/location/afgh/block_large/commFacility/afgh_commFacility_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.AACR, blockLarge ="afgh_commFacility", },
		-- commFacility_cmmn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn001_gim_n0000|srt_afgh_cmmn002_cmmn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/commFacility/afgh_commFacility_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="afgh_commFacility", },
		-- commFacility_cmmn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn002_gim_n0000|srt_afgh_cmmn002_cmmn002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/commFacility/afgh_commFacility_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="afgh_commFacility", },
		commFacility_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/commFacility/afgh_commFacility_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_commFacility", },
		commFacility_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0001|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/commFacility/afgh_commFacility_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_commFacility", },
		commFacility_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/commFacility/afgh_commFacility_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_commFacility", },
		commFacility_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/commFacility/afgh_commFacility_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_commFacility", },
		-- commFacility_gnrt001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_gnrt002_gim_n0000|srt_afgh_gnrt002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/commFacility/afgh_commFacility_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="afgh_commFacility", },
		commFacility_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0000|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/commFacility/afgh_commFacility_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_commFacility", },
		commFacility_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/commFacility/afgh_commFacility_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_commFacility", },
		-- commFacility_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/commFacility/afgh_commFacility_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="afgh_commFacility", },
		commFacility_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/commFacility/afgh_commFacility_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_commFacility", },
		commFacility_light002 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0001|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/commFacility/afgh_commFacility_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_commFacility", },
		-- village_antn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n_0001|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/village/afgh_village_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_village", },
		-- village_antn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n_0002|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/village/afgh_village_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_village", },
		-- village_mchn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0002|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/village/afgh_village_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_village", },
		-- village_mchn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0001|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/village/afgh_village_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_village", },
		-- village_cmmn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn002_gim_n_0000|srt_afgh_cmmn002_cmmn002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/village/afgh_village_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="afgh_village", },
		village_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0001|srt_hw03_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/village/afgh_village_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_village", },
		village_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0002|srt_hw03_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/village/afgh_village_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_village", },
		village_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n_0000|srt_hw00_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/village/afgh_village_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_village", },
		village_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n_0001|srt_hw00_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/village/afgh_village_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_village", },
		village_mortar003 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n_0002|srt_hw00_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/village/afgh_village_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_village", },
		-- village_gnrt001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_gnrt002_gim_n_0000|srt_afgh_gnrt002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/village/afgh_village_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="afgh_village", },
		village_antiair001 = { type = TppGameObject.GAME_OBJECT_TYPE_GATLINGGUN, locatorName = "sad0_main0_def_gim_n0000|srt_sad0_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/135/135_141/afgh_135_141_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTIAIR, blockSmall = {135,141} , },
		village_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n_0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/village/afgh_village_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_village", },
		-- village_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/village/afgh_village_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="afgh_village", },
		-- slopedTown_antn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0000|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/slopedTown/afgh_slopedTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_slopedTown", },
		-- slopedTown_antn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0001|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/slopedTown/afgh_slopedTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_slopedTown", },
		-- slopedTown_mchn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0001|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/slopedTown/afgh_slopedTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_slopedTown", },
		-- slopedTown_mchn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0002|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/slopedTown/afgh_slopedTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_slopedTown", },
		-- slopedTown_cmmn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn001_gim_n0000|srt_afgh_cmmn002_cmmn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/slopedTown/afgh_slopedTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="afgh_slopedTown", },
		slopedTown_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0001|srt_hw03_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/slopedTown/afgh_slopedTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_slopedTown", },
		slopedTown_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0002|srt_hw03_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/slopedTown/afgh_slopedTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_slopedTown", },
		slopedTown_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n_0000|srt_hw00_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/slopedTown/afgh_slopedTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_slopedTown", },
		slopedTown_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n_0001|srt_hw00_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/slopedTown/afgh_slopedTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_slopedTown", },
		slopedTown_mortar003 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n_0002|srt_hw00_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/slopedTown/afgh_slopedTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_slopedTown", },
		-- slopedTown_gnrt001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_gnrt002_gim_n0000|srt_afgh_gnrt002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/slopedTown/afgh_slopedTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="afgh_slopedTown", },
		slopedTown_antiair001 = { type = TppGameObject.GAME_OBJECT_TYPE_GATLINGGUN, locatorName = "nad0_main0_def_gim_n_0000|srt_nad0_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/slopedTown/afgh_slopedTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTIAIR, blockLarge ="afgh_slopedTown", },
		slopedTown_antiair002 = { type = TppGameObject.GAME_OBJECT_TYPE_GATLINGGUN, locatorName = "nad0_main0_def_gim_n_0001|srt_nad0_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/slopedTown/afgh_slopedTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTIAIR, blockLarge ="afgh_slopedTown", },
		-- slopedTown_aacr001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn006_gim_n0000|srt_afgh_antn006", dataSetName = "/Assets/tpp/level/location/afgh/block_large/slopedTown/afgh_slopedTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.AACR, blockLarge ="afgh_slopedTown", },
		slopedTown_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/slopedTown/afgh_slopedTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_slopedTown", },
		slopedTown_light002 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0001|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/slopedTown/afgh_slopedTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_slopedTown", },
		slopedTown_light003 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0002|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/slopedTown/afgh_slopedTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_slopedTown", },
		-- slopedTown_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/slopedTown/afgh_slopedTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="afgh_slopedTown", },
		-- enemyBase_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="afgh_enemyBase", },
		-- enemyBase_antn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0000|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_enemyBase", },
		-- enemyBase_antn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0001|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_enemyBase", },
		-- enemyBase_mchn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0000|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_enemyBase", },
		-- enemyBase_mchn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0001|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_enemyBase", },
		-- enemyBase_aacr001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn006_gim_n0000|srt_afgh_antn006", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.AACR, blockLarge ="afgh_enemyBase", },
		-- enemyBase_cmmn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn001_gim_n0000|srt_afgh_cmmn002_cmmn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="afgh_enemyBase", },
		enemyBase_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0001|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_enemyBase", },
		enemyBase_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0002|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_enemyBase", },
		enemyBase_gun003 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0003|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_enemyBase", },
		enemyBase_gun004 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0004|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_enemyBase", },
		enemyBase_gun005 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0005|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_enemyBase", },
		enemyBase_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_enemyBase", },
		enemyBase_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_enemyBase", },
		enemyBase_mortar003 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0002|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_enemyBase", },
		enemyBase_mortar004 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0003|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_enemyBase", },
		enemyBase_mortar005 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0004|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_enemyBase", },
		-- enemyBase_gnrt001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_gnrt002_gim_n0000|srt_afgh_gnrt002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="afgh_enemyBase", },
		-- enemyBase_gnrt002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_gnrt002_gim_n0001|srt_afgh_gnrt002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="afgh_enemyBase", },
		enemyBase_antiair001 = { type = TppGameObject.GAME_OBJECT_TYPE_GATLINGGUN, locatorName = "sad0_main0_def_gim_n0001|srt_sad0_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTIAIR, blockLarge ="afgh_enemyBase", },
		enemyBase_antiair002 = { type = TppGameObject.GAME_OBJECT_TYPE_GATLINGGUN, locatorName = "sad0_main0_def_gim_n0002|srt_sad0_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTIAIR, blockLarge ="afgh_enemyBase", },
		enemyBase_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0000|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_enemyBase", },
		enemyBase_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_enemyBase", },
		enemyBase_cntn003 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0002|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_enemyBase", },
		enemyBase_cntn004 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0003|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_enemyBase", },
		enemyBase_cntn005 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0004|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_enemyBase", },
		enemyBase_cntn006 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0005|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_enemyBase", },
		enemyBase_cntn007 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0006|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_enemyBase", },
		enemyBase_cntn008 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0008|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_enemyBase", },
		enemyBase_wtct001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_gim_n0000|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockLarge ="afgh_enemyBase", },
		enemyBase_wtct002 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_vrtn001_gim_n0000|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockLarge ="afgh_enemyBase", },
		enemyBase_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_enemyBase", },
		enemyBase_light002 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0001|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_enemyBase", },
		enemyBase_light003 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "afgh_wtct001_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/enemyBase/afgh_enemyBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_enemyBase", },
		-- field_antn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn005_gim_n0000|srt_afgh_antn001_fndt005", dataSetName = "/Assets/tpp/level/location/afgh/block_large/field/afgh_field_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_field", },
		-- field_antn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn005_gim_n0001|srt_afgh_antn001_fndt005", dataSetName = "/Assets/tpp/level/location/afgh/block_large/field/afgh_field_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_field", },
		-- field_antn003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn005_gim_n0002|srt_afgh_antn001_fndt005", dataSetName = "/Assets/tpp/level/location/afgh/block_large/field/afgh_field_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_field", },
		-- field_mchn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn002_gim_n0000|srt_mtbs_mchn025_vrtn002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/field/afgh_field_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_field", },
		-- field_mchn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn002_gim_n0001|srt_mtbs_mchn025_vrtn002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/field/afgh_field_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_field", },
		-- field_mchn003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn002_gim_n0002|srt_mtbs_mchn025_vrtn002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/field/afgh_field_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_field", },
		-- field_aacr001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn006_gim_n0000|srt_afgh_antn006", dataSetName = "/Assets/tpp/level/location/afgh/block_large/field/afgh_field_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.AACR, blockLarge ="afgh_field", },
		-- field_cmmn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn002_gim_n0000|srt_afgh_cmmn002_cmmn002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/field/afgh_field_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="afgh_field", },
		field_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/field/afgh_field_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_field", },
		field_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0001|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/field/afgh_field_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_field", },
		field_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/field/afgh_field_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_field", },
		field_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/field/afgh_field_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_field", },
		field_mortar003 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0002|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/field/afgh_field_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_field", },
		field_antiair001 = { type = TppGameObject.GAME_OBJECT_TYPE_GATLINGGUN, locatorName = "sad0_main0_def_gim_n0000|srt_sad0_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/field/afgh_field_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTIAIR, blockLarge ="afgh_field", },
		-- field_gnrt001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_gnrt002_gim_n0000|srt_afgh_gnrt002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/field/afgh_field_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="afgh_field", },
		field_wtct001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_vrtn001_gim_n0000|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/field/afgh_field_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockLarge ="afgh_field", },
		field_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/field/afgh_field_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_field", },
		field_light002 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0001|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/field/afgh_field_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_field", },
		field_light003 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0002|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/field/afgh_field_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_field", },
		field_light004 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0003|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/field/afgh_field_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_field", },
		-- field_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/field/afgh_field_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="afgh_field", },
		-- remnants_cmmn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn002_gim_n0000|srt_afgh_cmmn002_cmmn002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/remnants/afgh_remnants_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="afgh_remnants", },
		remnants_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/remnants/afgh_remnants_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_remnants", },
		remnants_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0001|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/remnants/afgh_remnants_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_remnants", },
		remnants_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/remnants/afgh_remnants_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_remnants", },
		remnants_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/remnants/afgh_remnants_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_remnants", },
		-- remnants_gnrt001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_gnrt002_gim_n0000|srt_afgh_gnrt002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/remnants/afgh_remnants_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="afgh_remnants", },
		remnants_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/remnants/afgh_remnants_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_remnants", },
		-- remnants_antn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0000|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/remnants/afgh_remnants_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_remnants", },
		-- remnants_mchn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0000|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/remnants/afgh_remnants_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_remnants", },
		remnants_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/remnants/afgh_remnants_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_remnants", },
		remnants_light002 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0001|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/remnants/afgh_remnants_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_remnants", },
		remnants_light003 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn001_gim_n0002|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/remnants/afgh_remnants_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_remnants", },
		remnants_light004 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/remnants/afgh_remnants_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_remnants", },
		-- remnants_aacr001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn006_gim_n0000|srt_afgh_antn006", dataSetName = "/Assets/tpp/level/location/afgh/block_large/remnants/afgh_remnants_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.AACR, blockLarge ="afgh_remnants", },
		-- remnants_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/remnants/afgh_remnants_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="afgh_remnants", },
		-- tent_cmmn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn001_gim_n0000|srt_afgh_cmmn002_cmmn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/tent/afgh_tent_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="afgh_tent", },
		-- tent_cmmn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn002_gim_n0000|srt_afgh_cmmn002_cmmn002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/tent/afgh_tent_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="afgh_tent", },
		tent_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/tent/afgh_tent_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_tent", },
		tent_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0001|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/tent/afgh_tent_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_tent", },
		tent_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/tent/afgh_tent_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_tent", },
		tent_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/tent/afgh_tent_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_tent", },
		-- tent_antn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0000|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/tent/afgh_tent_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_tent", },
		-- tent_antn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0001|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/tent/afgh_tent_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_tent", },
		-- tent_mchn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0000|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/tent/afgh_tent_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_tent", },
		-- tent_mchn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0001|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/tent/afgh_tent_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_tent", },
		tent_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "afgh_wtct001_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/tent/afgh_tent_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_tent", },
		tent_light002 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/tent/afgh_tent_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_tent", },
		tent_light003 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn001_gim_n0001|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/tent/afgh_tent_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_tent", },
		tent_wtct001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_vrtn001_gim_n0000|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/tent/afgh_tent_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockLarge ="afgh_tent", },
		-- tent_aacr001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn006_gim_n0001|srt_afgh_antn006", dataSetName = "/Assets/tpp/level/location/afgh/block_large/tent/afgh_tent_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.AACR, blockLarge ="afgh_tent", },
		-- tent_swtc001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "gntn_mchn001_swtc002_gim_n0000|srt_gntn_mchn001_swtc002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/tent/afgh_tent_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.SWTC, blockLarge ="afgh_tent", },
		-- tent_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/tent/afgh_tent_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="afgh_tent", },
		-- bridge_antn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn005_gim_n0000|srt_afgh_antn001_fndt005", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_bridge", },
		-- bridge_antn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn005_gim_n0001|srt_afgh_antn001_fndt005", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_bridge", },
		-- bridge_antn003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn005_gim_n0000|srt_afgh_antn001_fndt005", dataSetName = "/Assets/tpp/level/location/afgh/block_small/147/147_131/afgh_147_131_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_bridge", },
		-- bridge_mchn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn002_gim_n0000|srt_mtbs_mchn025_vrtn002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_bridge", },
		-- bridge_mchn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn002_gim_n0001|srt_mtbs_mchn025_vrtn002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_bridge", },
		-- bridge_mchn003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn002_gim_n0000|srt_mtbs_mchn025_vrtn002", dataSetName = "/Assets/tpp/level/location/afgh/block_small/147/147_131/afgh_147_131_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_bridge", },
		-- bridge_gnrt001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_gnrt002_gim_n0000|srt_afgh_gnrt002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="afgh_bridge", },
		bridge_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_bridge", },
		bridge_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0002|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_bridge", },
		bridge_cntn003 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0003|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_bridge", },
		bridge_cntn004 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0004|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_bridge", },
		bridge_cntn005 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0005|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_bridge", },
		bridge_cntn006 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0006|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_bridge", },
		bridge_cntn007 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0007|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_bridge", },
		-- bridge_cmmn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn001_gim_n0000|srt_afgh_cmmn002_cmmn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="afgh_bridge", },
		bridge_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_bridge", },
		bridge_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_bridge", },
		bridge_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_bridge", },
		bridge_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0001|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_bridge", },
		bridge_antiair001 = { type = TppGameObject.GAME_OBJECT_TYPE_GATLINGGUN, locatorName = "sad0_main0_def_gim_n0000|srt_sad0_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTIAIR, blockLarge ="afgh_bridge", },
		bridge_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "afgh_wtct001_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_bridge", },
		bridge_light002 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_bridge", },
		bridge_wtct001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_vrtn001_gim_n0000|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockLarge ="afgh_bridge", },
		-- bridge_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/bridge/afgh_bridge_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="afgh_bridge", },
		-- cliffTown_aacr001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn006_gim_n0000|srt_afgh_antn006", dataSetName = "/Assets/tpp/level/location/afgh/block_large/cliffTown/afgh_cliffTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.AACR, blockLarge ="afgh_cliffTown", },
		-- cliffTown_antn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0000|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/cliffTown/afgh_cliffTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_cliffTown", },
		-- cliffTown_antn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0001|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/cliffTown/afgh_cliffTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_cliffTown", },
		-- cliffTown_mchn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0000|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/cliffTown/afgh_cliffTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_cliffTown", },
		-- cliffTown_mchn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0001|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/cliffTown/afgh_cliffTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_cliffTown", },
		-- cliffTown_cmmn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn001_gim_n0000|srt_afgh_cmmn002_cmmn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/cliffTown/afgh_cliffTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="afgh_cliffTown", },
		-- cliffTown_gnrt001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_gnrt002_gim_n0000|srt_afgh_gnrt002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/cliffTown/afgh_cliffTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="afgh_cliffTown", },
		cliffTown_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/cliffTown/afgh_cliffTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_cliffTown", },
		cliffTown_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0001|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/cliffTown/afgh_cliffTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_cliffTown", },
		cliffTown_gun003 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0002|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/cliffTown/afgh_cliffTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_cliffTown", },
		cliffTown_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/cliffTown/afgh_cliffTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_cliffTown", },
		cliffTown_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/cliffTown/afgh_cliffTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_cliffTown", },
		cliffTown_mortar003 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0002|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/cliffTown/afgh_cliffTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_cliffTown", },
		cliffTown_mortar004 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0003|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/cliffTown/afgh_cliffTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_cliffTown", },
		cliffTown_mortar005 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0004|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/cliffTown/afgh_cliffTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_cliffTown", },
		cliffTown_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/cliffTown/afgh_cliffTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_cliffTown", },
		cliffTown_light002 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn001_gim_n0001|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/cliffTown/afgh_cliffTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_cliffTown", },
		cliffTown_light003 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn001_gim_n0002|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/cliffTown/afgh_cliffTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_cliffTown", },
		cliffTown_light004 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "afgh_wtct001_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/cliffTown/afgh_cliffTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_cliffTown", },
		cliffTown_wtct001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_vrtn001_gim_n0000|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/cliffTown/afgh_cliffTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockLarge ="afgh_cliffTown", },
		-- cliffTown_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/cliffTown/afgh_cliffTown_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="afgh_cliffTown", },
		-- fort_gnrt001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_gnrt002_gim_n0000|srt_afgh_gnrt002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/fort/afgn_fort_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="afgn_fort", },
		-- fort_aacr001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn006_gim_n0002|srt_afgh_antn006", dataSetName = "/Assets/tpp/level/location/afgh/block_large/fort/afgh_fort_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.AACR, blockLarge ="afgh_fort", },
		-- fort_antn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn005_gim_n0000|srt_afgh_antn001_fndt005", dataSetName = "/Assets/tpp/level/location/afgh/block_large/fort/afgn_fort_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgn_fort", },
		-- fort_antn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn005_gim_n0001|srt_afgh_antn001_fndt005", dataSetName = "/Assets/tpp/level/location/afgh/block_large/fort/afgn_fort_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgn_fort", },
		-- fort_antn003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn005_gim_n0002|srt_afgh_antn001_fndt005", dataSetName = "/Assets/tpp/level/location/afgh/block_large/fort/afgn_fort_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgn_fort", },
		-- fort_mchn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn002_gim_n0000|srt_mtbs_mchn025_vrtn002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/fort/afgn_fort_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgn_fort", },
		-- fort_mchn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn002_gim_n0001|srt_mtbs_mchn025_vrtn002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/fort/afgn_fort_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgn_fort", },
		-- fort_mchn003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn002_gim_n0002|srt_mtbs_mchn025_vrtn002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/fort/afgn_fort_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgn_fort", },
		fort_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/fort/afgn_fort_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgn_fort", },
		fort_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/fort/afgn_fort_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgn_fort", },
		fort_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/fort/afgn_fort_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgn_fort", },
		fort_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0001|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/fort/afgn_fort_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgn_fort", },
		fort_antiair001 = { type = TppGameObject.GAME_OBJECT_TYPE_GATLINGGUN, locatorName = "sad0_main0_def_gim_n0000|srt_sad0_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/fort/afgn_fort_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTIAIR, blockLarge ="afgn_fort", },
		fort_wtct001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_gim_n0000|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/fort/afgn_fort_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockLarge ="afgn_fort", },
		fort_wtct002 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_gim_n0001|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/fort/afgn_fort_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockLarge ="afgn_fort", },
		-- fort_cmmn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn001_gim_n0000|srt_afgh_cmmn002_cmmn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/fort/afgn_fort_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="afgn_fort", },
		-- fort_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/fort/afgn_fort_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="afgn_fort", },
		-- powerPlant_cmmn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn001_gim_n0000|srt_afgh_cmmn002_cmmn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/powerPlant/afgh_powerPlant_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="afgh_powerPlant", },
		-- powerPlant_cmmn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn002_gim_n0000|srt_afgh_cmmn002_cmmn002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/powerPlant/afgh_powerPlant_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="afgh_powerPlant", },
		powerPlant_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/powerPlant/afgh_powerPlant_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_powerPlant", },
		powerPlant_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/powerPlant/afgh_powerPlant_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_powerPlant", },
		-- powerPlant_antn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn005_gim_n0001|srt_afgh_antn001_fndt005", dataSetName = "/Assets/tpp/level/location/afgh/block_large/powerPlant/afgh_powerPlant_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_powerPlant", },
		-- powerPlant_antn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn005_gim_n0002|srt_afgh_antn001_fndt005", dataSetName = "/Assets/tpp/level/location/afgh/block_large/powerPlant/afgh_powerPlant_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_powerPlant", },
		-- powerPlant_antn003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn005_gim_n0003|srt_afgh_antn001_fndt005", dataSetName = "/Assets/tpp/level/location/afgh/block_large/powerPlant/afgh_powerPlant_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_powerPlant", },
		-- powerPlant_mchn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn002_gim_n0001|srt_mtbs_mchn025_vrtn002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/powerPlant/afgh_powerPlant_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_powerPlant", },
		-- powerPlant_mchn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn002_gim_n0002|srt_mtbs_mchn025_vrtn002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/powerPlant/afgh_powerPlant_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_powerPlant", },
		-- powerPlant_mchn003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn002_gim_n0003|srt_mtbs_mchn025_vrtn002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/powerPlant/afgh_powerPlant_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_powerPlant", },
		-- powerPlant_aacr001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn006_gim_n0000|srt_afgh_antn006", dataSetName = "/Assets/tpp/level/location/afgh/block_large/powerPlant/afgh_powerPlant_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.AACR, blockLarge ="afgh_powerPlant", },
		-- powerPlant_swtc001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "gntn_mchn001_swtc002_gim_n0000|srt_gntn_mchn001_swtc002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/powerPlant/afgh_powerPlant_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.SWTC, blockLarge ="afgh_powerPlant", },
		-- powerPlant_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/powerPlant/afgh_powerPlant_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="afgh_powerPlant", },
		powerPlant_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/powerPlant/afgh_powerPlant_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_powerPlant", },
		powerPlant_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0000|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/mission2/story/s10070/s10070_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="", },
		powerPlant_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/mission2/story/s10070/s10070_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="", },
		powerPlant_cntn003 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0002|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/mission2/story/s10070/s10070_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="", },
		powerPlant_cntn004 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0003|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/mission2/story/s10070/s10070_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="", },
		-- sovietBase_cmmn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn001_gim_n0000|srt_afgh_cmmn002_cmmn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="afgh_sovietBase", },
		sovietBase_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_sovietBase", },
		sovietBase_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0001|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_sovietBase", },
		sovietBase_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_sovietBase", },
		-- sovietBase_swtc001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "gntn_mchn001_swtc002_gim_n0000|srt_gntn_mchn001_swtc002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.SWTC, blockLarge ="afgh_sovietBase", },
		-- sovietBase_swtc002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "gntn_mchn001_swtc002_gim_n0001|srt_gntn_mchn001_swtc002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.SWTC, blockLarge ="afgh_sovietBase", },
		-- sovietBase_swtc003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "gntn_mchn001_swtc002_gim_n0002|srt_gntn_mchn001_swtc002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.SWTC, blockLarge ="afgh_sovietBase", },
		sovietBase_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0000|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_sovietBase", },
		sovietBase_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_sovietBase", },
		sovietBase_cntn003 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0002|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_sovietBase", },
		sovietBase_cntn004 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0003|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_sovietBase", },
		sovietBase_cntn005 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0005|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_sovietBase", },
		sovietBase_cntn006 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0006|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_sovietBase", },
		sovietBase_cntn007 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0007|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_sovietBase", },
		sovietBase_cntn008 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0008|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_sovietBase", },
		sovietBase_cntn009 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0009|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_sovietBase", },
		sovietBase_cntn010 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0010|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_sovietBase", },
		sovietBase_cntn011 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0011|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_sovietBase", },
		sovietBase_cntn012 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0012|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_sovietBase", },
		sovietBase_cntn013 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0013|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="afgh_sovietBase", },
		-- sovietBase_antn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0000|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_sovietBase", },
		-- sovietBase_antn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0001|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_sovietBase", },
		-- sovietBase_mchn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0000|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_sovietBase", },
		-- sovietBase_mchn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0001|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_sovietBase", },
		-- sovietBase_aacr001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn006_gim_n0000|srt_afgh_antn006", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.AACR, blockLarge ="afgh_sovietBase", },
		-- sovietBase_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/sovietBase/afgh_sovietBase_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="afgh_sovietBase", },
		sovietBase_wtct001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_gim_n0000|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/116/116_119/afgh_116_119_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {116,119} , },
		citadel_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/123/123_108/afgh_123_108_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {123,108} , },
		citadel_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0002|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/123/123_108/afgh_123_108_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {123,108} , },
		citadel_cntn003 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0003|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/123/123_108/afgh_123_108_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {123,108} , },
		citadel_cntn004 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0002|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/123/123_109/afgh_123_109_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {123,109} , },
		citadel_cntn005 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0003|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/123/123_109/afgh_123_109_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {123,109} , },
		citadel_cntn006 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0004|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/123/123_109/afgh_123_109_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {123,109} , },
		citadel_cntn007 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0005|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/123/123_109/afgh_123_109_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {123,109} , },
		citadel_cntn008 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0000|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/123/123_110/afgh_123_110_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {123,110} , },
		citadel_cntn009 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/123/123_110/afgh_123_110_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {123,110} , },
		citadel_cntn010 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0002|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/123/123_110/afgh_123_110_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {123,110} , },
		citadel_cntn011 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0003|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/123/123_110/afgh_123_110_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {123,110} , },
		-- citadel_antn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0000|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_citadel", },
		-- citadel_antn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0001|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_citadel", },
		-- citadel_antn003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0002|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="afgh_citadel", },
		-- citadel_mchn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0000|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_citadel", },
		-- citadel_mchn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0001|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_citadel", },
		-- citadel_mchn003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0002|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="afgh_citadel", },
		-- citadel_cmmn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn001_gim_n0000|srt_afgh_cmmn002_cmmn001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="afgh_citadel", },
		-- citadel_cmmn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn002_gim_n0000|srt_afgh_cmmn002_cmmn002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="afgh_citadel", },
		-- citadel_aacr001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn006_gim_n0000|srt_afgh_antn006", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.AACR, blockLarge ="afgh_citadel", },
		citadel_antiair001 = { type = TppGameObject.GAME_OBJECT_TYPE_GATLINGGUN, locatorName = "sad0_main0_def_gim_n0001|srt_sad0_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTIAIR, blockLarge ="afgh_citadel", },
		citadel_antiair002 = { type = TppGameObject.GAME_OBJECT_TYPE_GATLINGGUN, locatorName = "sad0_main0_def_gim_n0003|srt_sad0_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTIAIR, blockLarge ="afgh_citadel", },
		citadel_antiair003 = { type = TppGameObject.GAME_OBJECT_TYPE_GATLINGGUN, locatorName = "sad0_main0_def_gim_n0004|srt_sad0_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTIAIR, blockLarge ="afgh_citadel", },
		citadel_antiair004 = { type = TppGameObject.GAME_OBJECT_TYPE_GATLINGGUN, locatorName = "sad0_main0_def_gim_n0005|srt_sad0_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTIAIR, blockLarge ="afgh_citadel", },
		citadel_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_citadel", },
		citadel_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0001|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_citadel", },
		citadel_gun003 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0002|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_citadel", },
		citadel_gun004 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0003|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_citadel", },
		citadel_gun005 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0005|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_citadel", },
		citadel_gun006 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0006|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="afgh_citadel", },
		citadel_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_citadel", },
		citadel_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_citadel", },
		citadel_mortar003 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0002|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_citadel", },
		citadel_mortar004 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0003|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_citadel", },
		citadel_mortar005 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0004|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="afgh_citadel", },
		-- citadel_gnrt001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_gnrt002_gim_n0000|srt_afgh_gnrt002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="afgh_citadel", },
		-- citadel_gnrt002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_gnrt002_gim_n0001|srt_afgh_gnrt002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="afgh_citadel", },
		-- citadel_gnrt003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_gnrt002_gim_n0002|srt_afgh_gnrt002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="afgh_citadel", },
		citadel_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_citadel", },
		citadel_light002 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_citadel", },
		citadel_light003 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0002|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_citadel", },
		citadel_light004 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0003|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_citadel", },
		citadel_light005 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0004|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_citadel", },
		citadel_light006 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0005|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_citadel", },
		citadel_light007 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0006|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_large/citadel/afgh_citadel_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="afgh_citadel", },
		-- citadel_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/mission2/story/s10150/s10150_block01.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="", },
		-- waterway_tower001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_rins001_twer004_gim_n0001|srt_afgh_rins001_twer004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_tower001_link = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_twer002_gim_n0002|srt_afgh_rins001_twer002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_tower002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_rins001_twer004_gim_n0002|srt_afgh_rins001_twer004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_tower002_link = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_twer002_gim_n0001|srt_afgh_rins001_twer002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_tower003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_rins001_twer004_gim_n0003|srt_afgh_rins001_twer004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_tower003_link = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_twer002_gim_n0003|srt_afgh_rins001_twer002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst001_A = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_rins001_prst007_gim_n0000|srt_afgh_rins001_prst007", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst001_A_link = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst002_gim_n0000|srt_afgh_rins001_prst002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst001_B = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_rins001_prst007_gim_n0001|srt_afgh_rins001_prst007", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst001_B_link = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst003_gim_n0000|srt_afgh_rins001_prst003", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst001_C = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst001_gim_n0000|srt_afgh_rins001_prst001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst002_A = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_rins001_prst007_gim_n0004|srt_afgh_rins001_prst007", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst002_A_link = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst002_gim_n0001|srt_afgh_rins001_prst002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst002_B = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_rins001_prst007_gim_n0005|srt_afgh_rins001_prst007", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst002_B_link = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst003_gim_n0003|srt_afgh_rins001_prst003", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst002_C = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst001_gim_n0001|srt_afgh_rins001_prst001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst003_A = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_rins001_prst007_gim_n0002|srt_afgh_rins001_prst007", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst003_A_link = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst002_gim_n0002|srt_afgh_rins001_prst002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst003_B = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_rins001_prst007_gim_n0003|srt_afgh_rins001_prst007", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst003_B_link = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst003_gim_n0002|srt_afgh_rins001_prst003", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst003_C = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst001_gim_n0002|srt_afgh_rins001_prst001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst004_A = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_rins001_prst007_gim_n0006|srt_afgh_rins001_prst007", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst004_A_link = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst002_gim_n0003|srt_afgh_rins001_prst002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst004_B = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_rins001_prst007_gim_n0007|srt_afgh_rins001_prst007", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst004_B_link = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst003_gim_n0001|srt_afgh_rins001_prst003", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst004_C = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst001_gim_n0003|srt_afgh_rins001_prst001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst005_A = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_rins001_prst007_gim_n0008|srt_afgh_rins001_prst007", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst005_A_link = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst002_gim_n0004|srt_afgh_rins001_prst002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst005_B = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_rins001_prst007_gim_n0009|srt_afgh_rins001_prst007", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst005_B_link = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst003_gim_n0004|srt_afgh_rins001_prst003", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst005_C = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst001_gim_n0004|srt_afgh_rins001_prst001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst006_A = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_rins001_prst008_gim_n0001|srt_afgh_rins001_prst008", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst006_A_link = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst005_gim_n0001|srt_afgh_rins001_prst005", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst006_B = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_rins001_prst008_gim_n0002|srt_afgh_rins001_prst008", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst006_B_link = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst006_gim_n0001|srt_afgh_rins001_prst006", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst006_C = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst004_gim_n0001|srt_afgh_rins001_prst004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst007_A = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_rins001_prst008_gim_n0004|srt_afgh_rins001_prst008", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst007_A_link = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst005_gim_n0002|srt_afgh_rins001_prst005", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst007_B = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_rins001_prst008_gim_n0003|srt_afgh_rins001_prst008", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst007_B_link = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst006_gim_n0002|srt_afgh_rins001_prst006", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst007_C = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst004_gim_n0002|srt_afgh_rins001_prst004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst008_A = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_rins001_prst008_gim_n0005|srt_afgh_rins001_prst008", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst008_A_link = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst005_gim_n0003|srt_afgh_rins001_prst005", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst008_B = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_rins001_prst008_gim_n0006|srt_afgh_rins001_prst008", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst008_B_link = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst006_gim_n0003|srt_afgh_rins001_prst006", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_prst008_C = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_prst004_gim_n0003|srt_afgh_rins001_prst004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_arch001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_vrtn019_gim_n0000|srt_afgh_rins001_vrtn019", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_pillar001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_pllr001_gim_n0000|srt_afgh_rins001_pllr001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_pillar002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_pllr001_gim_n0001|srt_afgh_rins001_pllr001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_pillar003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_pllr001_gim_n0002|srt_afgh_rins001_pllr001", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_pillar004 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_pllr002_gim_n0000|srt_afgh_rins001_pllr002", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_pillar005 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_pllr003_gim_n0000|srt_afgh_rins001_pllr003", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_pillar006 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_pllr004_gim_n0000|srt_afgh_rins001_pllr004", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_pillar007 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_pllr005_gim_n0000|srt_afgh_rins001_pllr005", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		-- waterway_pillar008 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "afgh_rins001_pllr006_gim_n0001|srt_afgh_rins001_pllr006", dataSetName = "/Assets/tpp/level/location/afgh/block_large/waterway/afgh_waterway_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.NONE, blockLarge ="afgh_waterway", },
		bridgeNorth_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/151/151_128/afgh_151_128_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {151,128} , },
		bridgeNorth_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/151/151_129/afgh_151_129_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {151,129} , },
		bridgeWest_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/144/144_133/afgh_144_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {144,133} , },
		bridgeWest_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/146/146_133/afgh_146_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {146,133} , },
		bridgeWest_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0001|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/144/144_133/afgh_144_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {144,133} , },
		bridgeWest_wtct001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_gim_n0000|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/145/145_133/afgh_145_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {145,133} , },
		bridgeWest_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_small/145/145_133/afgh_145_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {145,133} , },
		bridgeWest_light002 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_small/145/145_133/afgh_145_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {145,133} , },
		slopedEast_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/140/140_131/afgh_140_131_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {140,131} , },
		slopedEast_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/140/140_131/afgh_140_131_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {140,131} , },
		slopedEast_wtct001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_gim_n0000|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/140/140_131/afgh_140_131_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {140,131} , },
		slopedWest_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/133/133_133/afgh_133_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {133,133} , },
		slopedWest_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/133/133_133/afgh_133_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {133,133} , },
		slopedWest_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/133/133_133/afgh_133_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {133,133} , },
		slopedWest_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/133/133_133/afgh_133_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {133,133} , },
		slopedWest_wtct001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_gim_n0000|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/133/133_133/afgh_133_133_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {133,133} , },
		enemyEast_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/130/130_133/afgh_130_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {130,133} , },
		enemyEast_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/130/130_134/afgh_130_134_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {130,134} , },
		citadelSouth_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0000|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/119/119_114/afgh_119_114_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {119,114} , },
		citadelSouth_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/119/119_114/afgh_119_114_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {119,114} , },
		citadelSouth_cntn003 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0002|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/119/119_114/afgh_119_114_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {119,114} , },
		citadelSouth_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/119/119_114/afgh_119_114_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {119,114} , },
		citadelSouth_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0001|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/119/119_114/afgh_119_114_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {119,114} , },
		citadelSouth_gun003 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/120/120_113/afgh_120_113_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {120,113} , },
		citadelSouth_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/119/119_114/afgh_119_114_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {119,114} , },
		enemyNorth_wtct001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_gim_n0000|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/131/131_129/afgh_131_129_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {131,129} , },
		enemyNorth_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/131/131_129/afgh_131_129_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {131,129} , },
		enemyNorth_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/131/131_129/afgh_131_129_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {131,129} , },
		-- fieldEast_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/141/141_147/afgh_141_147_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockSmall = {141,147} , },
		fieldEast_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/141/141_146/afgh_141_146_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {141,146} , },
		fieldEast_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0002|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/141/141_146/afgh_141_146_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {141,146} , },
		fieldWest_wtct001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_gim_n0000|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/133/133_148/afgh_133_148_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {133,148} , },
		fieldWest_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/133/133_148/afgh_133_148_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {133,148} , },
		fieldWest_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/afgh/block_small/133/133_148/afgh_133_148_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {133,148} , },
		fieldWest_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/133/133_148/afgh_133_148_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {133,148} , },
		fieldWest_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/133/133_148/afgh_133_148_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {133,148} , },
		ruinsNorth_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/145/145_141/afgh_145_141_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {145,141} , },
		commWest_wtct001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_gim_n0000|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/140/140_138/afgh_140_138_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {140,138} , },
		commWest_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/140/140_138/afgh_140_138_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {140,138} , },
		commWest_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/140/140_138/afgh_140_138_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {140,138} , },
		-- remnantsNorth_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/124/124_144/afgh_124_144_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockSmall = {124,144} , },
		remnantsNorth_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/124/124_144/afgh_124_144_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {124,144} , },
		-- cliffSouth_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/141/141_129/afgh_141_129_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockSmall = {141,129} , },
		cliffSouth_wtct001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_gim_n0000|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/140/140_128/afgh_140_128_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {140,128} , },
		cliffSouth_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/141/141_129/afgh_141_129_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {141,129} , },
		cliffSouth_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/141/141_129/afgh_141_129_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {141,129} , },
		cliffWest_wtct001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_gim_n0000|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/135/135_126/afgh_135_126_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {135,126} , },
		cliffWest_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/135/135_126/afgh_135_126_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {135,126} , },
		cliffWest_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/135/135_126/afgh_135_126_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {135,126} , },
		villageEast_wtct001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_gim_n0000|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/140/140_142/afgh_140_142_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {140,142} , },
		-- villageNorth_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/136/136_138/afgh_136_138_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockSmall = {136,138} , },
		villageNorth_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/136/136_138/afgh_136_138_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {136,138} , },
		villageNorth_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/137/137_138/afgh_137_138_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {137,138} , },
		villageNorth_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/136/136_138/afgh_136_138_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {136,138} , },
		villageNorth_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/137/137_138/afgh_137_138_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {137,138} , },
		-- fortWest_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/147/147_123/afgh_147_123_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockSmall = {147,123} , },
		fortWest_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/147/147_123/afgh_147_123_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {147,123} , },
		fortWest_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/147/147_123/afgh_147_123_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {147,123} , },
		fortWest_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/147/147_123/afgh_147_123_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {147,123} , },
		waterwayEast_wtct001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_gim_n0000|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/122/122_127/afgh_122_127_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {122,127} , },
		villageWest_wtct001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_gim_n0000|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/131/131_140/afgh_131_140_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {131,140} , },
		villageWest_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/131/131_140/afgh_131_140_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {131,140} , },
		villageWest_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/131/131_140/afgh_131_140_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {131,140} , },
		fortSouth_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/150/150_123/afgh_150_123_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {150,123} , },
		fortSouth_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/150/150_123/afgh_150_123_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {150,123} , },
		cliffEast_wtct001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_gim_n0000|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/142/142_122/afgh_142_122_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {142,122} , },
		cliffEast_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/143/143_122/afgh_143_122_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {143,122} , },
		plantWest_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/123/123_121/afgh_123_121_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {123,121} , },
		sovietSouth_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/120/120_123/afgh_120_123_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {120,123} , },
		tentNorth_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/119/119_134/afgh_119_134_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {119,134} , },
		tentNorth_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0001|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/119/119_134/afgh_119_134_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {119,134} , },
		tentEast_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/afgh/block_small/123/123_140/afgh_123_140_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {123,140} , },
		tentEast_wtct001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "afgh_wtct001_gim_n0000|srt_afgh_wtct001", dataSetName = "/Assets/tpp/level/location/afgh/block_small/123/123_140/afgh_123_140_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {123,140} , },
		tentEast_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw03_gim_n0000|srt_hw03_tpod0_def_v00", dataSetName = "/Assets/tpp/level/location/afgh/block_small/124/124_140/afgh_124_140_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {124,140} , },

	},

	africa={
		-- swamp_antn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0001|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="mafr_swamp", },
		-- swamp_antn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0002|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="mafr_swamp", },
		-- swamp_mchn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0000|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="mafr_swamp", },
		-- swamp_mchn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0001|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="mafr_swamp", },
		-- swamp_aacr001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn006_gim_n0000|srt_afgh_antn006", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.AACR, blockLarge ="mafr_swamp", },
		swamp_srlg001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0001|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_swamp", },
		swamp_srlg002 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0002|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_swamp", },
		swamp_srlg003 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_watchtower01a0001|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_swamp", },
		swamp_srlg004 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_watchtower01a0002|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_swamp", },
		swamp_srlg005 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/130/130_133/mafr_130_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {130,133} , },
		swamp_srlg006 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/131/131_132/mafr_131_132_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {131,132} , },
		swamp_srlg007 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/133/133_133/mafr_133_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {133,133} , },
		swamp_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/130/130_133/mafr_130_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {130,133} , },
		swamp_tower002 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/131/131_132/mafr_131_132_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {131,132} , },
		swamp_tower003 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/133/133_133/mafr_133_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {133,133} , },
		swamp_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_swamp", },
		swamp_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0001|srt_hw01_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_swamp", },
		swamp_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0002|srt_hw01_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_swamp", },
		swamp_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="mafr_swamp", },
		swamp_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="mafr_swamp", },
		swamp_mortar003 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0002|srt_hw00_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="mafr_swamp", },
		swamp_mortar004 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0003|srt_hw00_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="mafr_swamp", },
		swamp_antiair001 = { type = TppGameObject.GAME_OBJECT_TYPE_GATLINGGUN, locatorName = "nad0_main0_def_gim_n0000|srt_nad0_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTIAIR, blockLarge ="mafr_swamp", },
		-- swamp_gnrt001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_gnrt002_gim_n0000|srt_afgh_gnrt002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="mafr_swamp", },
		-- swamp_cmmn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn002_gim_n0000|srt_afgh_cmmn002_cmmn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="mafr_swamp", },
		swamp_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0000|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_swamp", },
		swamp_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_swamp", },
		swamp_cntn003 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/130/130_132/mafr_130_132_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {130,132} , },
		swamp_cntn004 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0002|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/130/130_132/mafr_130_132_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {130,132} , },
		-- swamp_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/swamp/mafr_swamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="mafr_swamp", },
		-- flowStation_tank005 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mafr_tank005_gim_n0001|srt_mafr_tank005", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FLOWSTATION_TANK001, blockLarge ="mafr_flowStation", },
		-- flowStation_tank003_00 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mafr_tank003_gim_n0000|srt_mafr_tank003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FLOWSTATION_TANK002, blockLarge ="mafr_flowStation", },
		-- flowStation_tank003_01 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mafr_tank003_gim_n0001|srt_mafr_tank003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FLOWSTATION_TANK002, blockLarge ="mafr_flowStation", },
		-- flowStation_tank003_02 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mafr_tank003_gim_n0002|srt_mafr_tank003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FLOWSTATION_TANK002, blockLarge ="mafr_flowStation", },
		-- flowStation_tank005_vrtn006 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_tank005_vrtn006_gim_n0001|srt_mafr_tank005_vrtn006", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FLOWSTATION_TANK003, blockLarge ="mafr_flowStation", },
		-- flowStation_pumpSwitch = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn015_vrtn002_gim_n0000|srt_mtbs_mchn015_vrtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FLOWSTATION_PUMP001, blockLarge ="mafr_flowStation", },
		--TODO Find these doors --r36 removed these from reset
		-- flowStation_pickingDoor_01 = { type = TppGameObject.GAME_OBJECT_TYPE_DOOR, locatorName = "mafr_fenc005_door001_gim_n0001|srt_mafr_fenc005_door001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FLOWSTATION_PDOR, blockLarge ="mafr_flowStation", },
		-- flowStation_pickingDoor_02 = { type = TppGameObject.GAME_OBJECT_TYPE_DOOR, locatorName = "mafr_fenc005_door001_gim_n0002|srt_mafr_fenc005_door001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FLOWSTATION_PDOR, blockLarge ="mafr_flowStation", },
		-- flowStation_aacr001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn006_gim_n0000|srt_afgh_antn006", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.AACR, blockLarge ="mafr_flowStation", },
		-- flowStation_swtc001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "gntn_mchn001_swtc002_gim_n0000|srt_gntn_mchn001_swtc002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="mafr_flowStation", },
		-- flowStation_swtc002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "gntn_mchn001_swtc002_gim_n0001|srt_gntn_mchn001_swtc002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="mafr_flowStation", },
		flowStation_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_flowStation", },
		flowStation_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="mafr_flowStation", },
		flowStation_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_flowStation", },
		flowStation_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0001|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_flowStation", },
		flowStation_antiair001 = { type = TppGameObject.GAME_OBJECT_TYPE_GATLINGGUN, locatorName = "nad0_main0_def_gim_n0000|srt_nad0_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTIAIR, blockLarge ="mafr_flowStation", },
		-- flowStation_cmmn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn001_gim_n0000|srt_afgh_cmmn002_cmmn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="mafr_flowStation", },
		-- flowStation_antn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn005_gim_n0001|srt_afgh_antn001_fndt005", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="mafr_flowStation", },
		-- flowStation_antn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn005_gim_n0002|srt_afgh_antn001_fndt005", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="mafr_flowStation", },
		-- flowStation_mchn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn002_gim_n0001|srt_mtbs_mchn025_vrtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="mafr_flowStation", },
		-- flowStation_mchn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn002_gim_n0002|srt_mtbs_mchn025_vrtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="mafr_flowStation", },
		-- flowStation_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="mafr_flowStation", },
		flowStation_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0000|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_flowStation", },
		flowStation_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_flowStation", },
		flowStation_cntn003 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0002|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_flowStation", },
		flowStation_cntn004 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0003|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_flowStation", },
		flowStation_cntn005 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0004|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_flowStation", },
		flowStation_cntn006 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0005|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/flowStation/mafr_flowStation_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_flowStation", },
		-- banana_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/banana/mafr_banana_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="mafr_banana", },
		-- banana_antn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0000|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/mafr/block_large/banana/mafr_banana_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="mafr_banana", },
		-- banana_antn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0001|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/mafr/block_large/banana/mafr_banana_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="mafr_banana", },
		-- banana_mchn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0000|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/banana/mafr_banana_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="mafr_banana", },
		-- banana_mchn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0001|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/banana/mafr_banana_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="mafr_banana", },
		-- banana_aacr001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn006_gim_n0000|srt_afgh_antn006", dataSetName = "/Assets/tpp/level/location/mafr/block_large/banana/mafr_banana_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.AACR, blockLarge ="mafr_banana", },
		-- banana_gnrt001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_gnrt002_vrtn001_gim_n0000|srt_afgh_gnrt002_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/banana/mafr_banana_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="mafr_banana", },
		-- banana_cmmn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn001_gim_n0000|srt_afgh_cmmn002_cmmn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/banana/mafr_banana_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="mafr_banana", },
		banana_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/banana/mafr_banana_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_banana", },
		banana_light002 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/banana/mafr_banana_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_banana", },
		banana_light003 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0001|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/banana/mafr_banana_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_banana", },
		banana_light004 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0002|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/banana/mafr_banana_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_banana", },
		banana_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/banana/mafr_banana_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="mafr_banana", },
		banana_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/banana/mafr_banana_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_banana", },
		banana_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0001|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/banana/mafr_banana_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_banana", },
		banana_gun003 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0002|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/banana/mafr_banana_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_banana", },
		banana_gun004 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0003|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/banana/mafr_banana_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_banana", },
		banana_gun005 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0004|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/banana/mafr_banana_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_banana", },
		banana_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/banana/mafr_banana_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockLarge ="mafr_banana", },
		banana_tower002 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0001|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/banana/mafr_banana_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockLarge ="mafr_banana", },
		banana_tower003 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0002|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/banana/mafr_banana_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockLarge ="mafr_banana", },
		-- diamond_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="mafr_diamond", },
		diamond_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockLarge ="mafr_diamond", },
		diamond_tower002 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0001|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockLarge ="mafr_diamond", },
		diamond_tower003 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0002|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockLarge ="mafr_diamond", },
		diamond_tower004 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0003|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockLarge ="mafr_diamond", },
		diamond_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_diamond", },
		diamond_light002 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0001|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_diamond", },
		diamond_light003 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0002|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_diamond", },
		diamond_light004 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0003|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_diamond", },
		-- diamond_antn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0000|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="mafr_diamond", },
		-- diamond_antn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0001|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="mafr_diamond", },
		-- diamond_antn003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0002|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="mafr_diamond", },
		-- diamond_mchn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0000|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="mafr_diamond", },
		-- diamond_mchn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0001|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="mafr_diamond", },
		-- diamond_mchn003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0002|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="mafr_diamond", },
		-- diamond_cmmn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn001_gim_n0001|srt_afgh_cmmn002_cmmn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="mafr_diamond", },
		-- diamond_cmmn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn002_gim_n0000|srt_afgh_cmmn002_cmmn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="mafr_diamond", },
		diamond_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_diamond", },
		diamond_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0001|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_diamond", },
		diamond_gun003 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0002|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_diamond", },
		diamond_gun004 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0003|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_diamond", },
		diamond_gun005 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/145/145_124/mafr_145_124_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {145,124} , },
		diamond_gun006 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0001|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/145/145_124/mafr_145_124_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {145,124} , },
		-- diamond_aacr001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn006_gim_n0000|srt_afgh_antn006", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.AACR, blockLarge ="mafr_diamond", },
		-- diamond_gnrt001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_gnrt002_vrtn001_gim_n0000|srt_afgh_gnrt002_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="mafr_diamond", },
		diamond_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0005|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_diamond", },
		diamond_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0009|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_diamond", },
		diamond_cntn003 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0010|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_diamond", },
		diamond_cntn004 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0007|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_diamond", },
		diamond_cntn005 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0006|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_diamond", },
		diamond_cntn006 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0008|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/diamond/mafr_diamond_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_diamond", },
		-- savannah_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/savannah/mafr_savannah_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="mafr_savannah", },
		savannah_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/savannah/mafr_savannah_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_savannah", },
		savannah_light002 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0001|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/savannah/mafr_savannah_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_savannah", },
		savannah_light003 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0002|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/savannah/mafr_savannah_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_savannah", },
		savannah_light004 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0003|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/savannah/mafr_savannah_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_savannah", },
		-- savannah_antn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0000|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/mafr/block_large/savannah/mafr_savannah_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="mafr_savannah", },
		-- savannah_antn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0001|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/mafr/block_large/savannah/mafr_savannah_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="mafr_savannah", },
		-- savannah_antn003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0002|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/mafr/block_large/savannah/mafr_savannah_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="mafr_savannah", },
		-- savannah_mchn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0000|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/savannah/mafr_savannah_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="mafr_savannah", },
		-- savannah_mchn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0001|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/savannah/mafr_savannah_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="mafr_savannah", },
		-- savannah_mchn003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0002|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/savannah/mafr_savannah_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="mafr_savannah", },
		-- savannah_cmmn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn002_gim_n0000|srt_afgh_cmmn002_cmmn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/savannah/mafr_savannah_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="mafr_savannah", },
		savannah_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/savannah/mafr_savannah_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_savannah", },
		savannah_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0001|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/savannah/mafr_savannah_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_savannah", },
		savannah_gun003 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0002|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/savannah/mafr_savannah_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_savannah", },
		savannah_gun004 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0003|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/savannah/mafr_savannah_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_savannah", },
		savannah_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/savannah/mafr_savannah_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="mafr_savannah", },
		savannah_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/savannah/mafr_savannah_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="mafr_savannah", },
		savannah_mortar003 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0002|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/savannah/mafr_savannah_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="mafr_savannah", },
		-- savannah_aacr001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn006_gim_n0000|srt_afgh_antn006", dataSetName = "/Assets/tpp/level/location/mafr/block_large/savannah/mafr_savannah_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.AACR, blockLarge ="mafr_savannah", },
		hill_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0000|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/hill/mafr_hill_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_hill", },
		hill_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/hill/mafr_hill_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_hill", },
		hill_cntn003 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0002|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/hill/mafr_hill_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_hill", },
		hill_cntn004 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0003|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/hill/mafr_hill_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_hill", },
		hill_cntn005 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0004|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/hill/mafr_hill_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_hill", },
		-- hill_aacr001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn006_gim_n0000|srt_afgh_antn006", dataSetName = "/Assets/tpp/level/location/mafr/block_large/hill/mafr_hill_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.AACR, blockLarge ="mafr_hill", },
		-- hill_antn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0000|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/mafr/block_large/hill/mafr_hill_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="mafr_hill", },
		-- hill_antn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0001|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/mafr/block_large/hill/mafr_hill_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="mafr_hill", },
		-- hill_mchn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0000|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/hill/mafr_hill_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="mafr_hill", },
		-- hill_mchn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0001|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/hill/mafr_hill_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="mafr_hill", },
		-- hill_gnrt001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_gnrt002_vrtn001_gim_n0000|srt_afgh_gnrt002_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/hill/mafr_hill_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="mafr_hill", },
		hill_gun000 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/hill/mafr_hill_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_hill", },
		hill_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0001|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/hill/mafr_hill_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_hill", },
		-- hill_cmmn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn002_gim_n0000|srt_afgh_cmmn002_cmmn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/hill/mafr_hill_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="mafr_hill", },
		hill_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/hill/mafr_hill_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_hill", },
		hill_light002 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn001_gim_n0001|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/hill/mafr_hill_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_hill", },
		-- hill_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/hill/mafr_hill_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="mafr_hill", },
		-- factory_wall = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mafr_fctr001_wall008_gim_n0001|srt_mafr_fctr001_wall008", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_WALL, blockLarge ="mafr_factory", },
		-- factory_tnnl = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mafr_tnnl001_gim_n0001|srt_mafr_tnnl001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_TNNL, blockLarge ="mafr_factory", },
		-- factory_stfr001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mafr_stfr001_gim_n0001|srt_mafr_stfr001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_FRAME, blockLarge ="mafr_factory", },
		-- factory_stfr002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mafr_stfr001_gim_n0002|srt_mafr_stfr001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_FRAME, blockLarge ="mafr_factory", },
		-- factory_wttr001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_WATER_TOWER, locatorName = "mafr_wttw003_gim_n0000|srt_mafr_wttw003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_WTTR, blockLarge ="mafr_factory", },
		-- factory_wttr002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_WATER_TOWER, locatorName = "mafr_wttw003_gim_n0001|srt_mafr_wttw003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_WTTR, blockLarge ="mafr_factory", },
		-- factory_tank001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "gntn_hydr001_gim_n0001|srt_gntn_hydr001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_TANK, blockLarge ="mafr_factory", },
		-- factory_tank002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "gntn_hydr001_gim_n0002|srt_gntn_hydr001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_TANK, blockLarge ="mafr_factory", },
		-- factory_tank003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "gntn_hydr001_gim_n0003|srt_gntn_hydr001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_TANK, blockLarge ="mafr_factory", },
		-- factory_wtnk001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_WATER_TOWER, locatorName = "mafr_wttw005_gim_n0001|srt_mafr_wttw005", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_WTNK, blockLarge ="mafr_factory", },
		-- factory_wtnk002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_WATER_TOWER, locatorName = "mafr_wttw005_gim_n0002|srt_mafr_wttw005", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_WTNK, blockLarge ="mafr_factory", },
		-- factory_wtnk003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_WATER_TOWER, locatorName = "mafr_wttw005_gim_n0003|srt_mafr_wttw005", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_WTNK, blockLarge ="mafr_factory", },
		-- factory_wsst001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_WATER_TOWER, locatorName = "mafr_wsst001_vrtn001_gim_n0001|srt_mafr_wsst001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_WSST, blockLarge ="mafr_factory", },
		-- factory_wsst002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_WATER_TOWER, locatorName = "mafr_wsst001_vrtn001_gim_n0002|srt_mafr_wsst001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_WSST, blockLarge ="mafr_factory", },
		-- factory_wsst003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_WATER_TOWER, locatorName = "mafr_wsst001_vrtn001_gim_n0003|srt_mafr_wsst001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_WSST, blockLarge ="mafr_factory", },
		-- factory_wsst004 = { .*type = TppGameObject.GAME_OBJECT_TYPE_WATER_TOWER, locatorName = "mafr_wsst001_vrtn001_gim_n0004|srt_mafr_wsst001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_WSST, blockLarge ="mafr_factory", },
		-- factory_crtn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_gim_n0001|srt_mafr_crtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_gim_n0002|srt_mafr_crtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_gim_n0003|srt_mafr_crtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn004 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_gim_n0004|srt_mafr_crtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn005 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_gim_n0005|srt_mafr_crtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn006 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_gim_n0006|srt_mafr_crtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn007 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_gim_n0007|srt_mafr_crtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn008 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_gim_n0008|srt_mafr_crtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn009 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_gim_n0009|srt_mafr_crtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn010 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_gim_n0010|srt_mafr_crtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn011 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_gim_n0011|srt_mafr_crtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn012 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_gim_n0012|srt_mafr_crtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn013 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_gim_n0013|srt_mafr_crtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn014 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_gim_n0014|srt_mafr_crtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn015 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_gim_n0015|srt_mafr_crtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn016 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_gim_n0016|srt_mafr_crtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn017 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_gim_n0017|srt_mafr_crtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn018 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn001_gim_n0001|srt_mafr_crtn002_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn019 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn001_gim_n0002|srt_mafr_crtn002_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn020 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn001_gim_n0003|srt_mafr_crtn002_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn021 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn001_gim_n0004|srt_mafr_crtn002_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn022 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn001_gim_n0005|srt_mafr_crtn002_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn023 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn001_gim_n0006|srt_mafr_crtn002_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn024 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn001_gim_n0008|srt_mafr_crtn002_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn025 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn002_gim_n0013|srt_mafr_crtn002_vrtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn026 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn002_gim_n0002|srt_mafr_crtn002_vrtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn027 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn002_gim_n0003|srt_mafr_crtn002_vrtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn028 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn002_gim_n0004|srt_mafr_crtn002_vrtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn029 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn002_gim_n0005|srt_mafr_crtn002_vrtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn030 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn002_gim_n0006|srt_mafr_crtn002_vrtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn031 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn002_gim_n0007|srt_mafr_crtn002_vrtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn032 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn002_gim_n0008|srt_mafr_crtn002_vrtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn033 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn002_gim_n0009|srt_mafr_crtn002_vrtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn034 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn002_gim_n0010|srt_mafr_crtn002_vrtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn035 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn002_gim_n0011|srt_mafr_crtn002_vrtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn036 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn002_gim_n0012|srt_mafr_crtn002_vrtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn037 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn003_gim_n0001|srt_mafr_crtn002_vrtn003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn038 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn003_gim_n0002|srt_mafr_crtn002_vrtn003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn039 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn003_gim_n0003|srt_mafr_crtn002_vrtn003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn040 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn003_gim_n0004|srt_mafr_crtn002_vrtn003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn041 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn003_gim_n0005|srt_mafr_crtn002_vrtn003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn042 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn003_gim_n0006|srt_mafr_crtn002_vrtn003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn043 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn003_gim_n0007|srt_mafr_crtn002_vrtn003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn044 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn003_gim_n0008|srt_mafr_crtn002_vrtn003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn045 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn003_gim_n0009|srt_mafr_crtn002_vrtn003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn046 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn003_gim_n0010|srt_mafr_crtn002_vrtn003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn047 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn003_gim_n0011|srt_mafr_crtn002_vrtn003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn048 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn003_gim_n0012|srt_mafr_crtn002_vrtn003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn049 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn003_gim_n0013|srt_mafr_crtn002_vrtn003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn050 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn003_gim_n0014|srt_mafr_crtn002_vrtn003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn051 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn003_gim_n0015|srt_mafr_crtn002_vrtn003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn052 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn003_gim_n0016|srt_mafr_crtn002_vrtn003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn053 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn003_gim_n0017|srt_mafr_crtn002_vrtn003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- factory_crtn054 = { .*type = TppGameObject.GAME_OBJECT_TYPE_EVENT_ANIMATION, locatorName = "mafr_crtn002_vrtn003_gim_n0018|srt_mafr_crtn002_vrtn003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/factory/mafr_factory_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.FACTORY_CRTN, blockLarge ="mafr_factory", },
		-- pfCamp_antn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn005_gim_n0000|srt_afgh_antn001_fndt005", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="mafr_pfCamp", },
		-- pfCamp_antn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn005_gim_n0001|srt_afgh_antn001_fndt005", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="mafr_pfCamp", },
		-- pfCamp_mchn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn002_gim_n0000|srt_mtbs_mchn025_vrtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="mafr_pfCamp", },
		-- pfCamp_mchn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn002_gim_n0001|srt_mtbs_mchn025_vrtn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="mafr_pfCamp", },
		-- pfCamp_cmmn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn002_gim_n0000|srt_afgh_cmmn002_cmmn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="mafr_pfCamp", },
		-- pfCamp_aacr001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn006_gim_n0000|srt_afgh_antn006", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.AACR, blockLarge ="mafr_pfCamp", },
		-- pfCamp_swtc001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "gntn_mchn001_swtc002_gim_n0000|srt_gntn_mchn001_swtc002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="mafr_pfCamp", },
		-- pfCamp_swtc002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "gntn_mchn001_swtc002_gim_n0001|srt_gntn_mchn001_swtc002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="mafr_pfCamp", },
		pfCamp_light0000 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_pfCamp", },
		pfCamp_light0001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn001_gim_n0002|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_pfCamp", },
		pfCamp_light0002 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_pfCamp", },
		pfCamp_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_pfCamp", },
		pfCamp_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0002|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_pfCamp", },
		pfCamp_cntn003 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0003|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_pfCamp", },
		pfCamp_cntn004 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0004|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_pfCamp", },
		pfCamp_cntn005 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0005|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_pfCamp", },
		pfCamp_cntn006 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0006|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_pfCamp", },
		pfCamp_cntn007 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0007|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_pfCamp", },
		pfCamp_cntn008 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0008|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_pfCamp", },
		pfCamp_cntn009 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0009|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_pfCamp", },
		pfCamp_cntn010 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0010|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_pfCamp", },
		pfCamp_cntn011 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0011|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_pfCamp", },
		pfCamp_cntn012 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0012|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_pfCamp", },
		pfCamp_cntn013 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0013|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_pfCamp", },
		pfCamp_cntn014 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0014|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_pfCamp", },
		pfCamp_cntn015 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0015|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_pfCamp", },
		pfCamp_antiair001 = { type = TppGameObject.GAME_OBJECT_TYPE_GATLINGGUN, locatorName = "nad0_main0_def_gim_n0000|srt_nad0_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTIAIR, blockLarge ="mafr_pfCamp", },
		pfCamp_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="mafr_pfCamp", },
		pfCamp_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="mafr_pfCamp", },
		pfCamp_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_pfCamp", },
		pfCamp_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0001|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_pfCamp", },
		-- pfCamp_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/pfCamp/mafr_pfCamp_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="mafr_pfCamp", },
		-- lab_gnrt001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_gnrt002_vrtn001_gim_n0000|srt_afgh_gnrt002_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="mafr_lab", },
		lab_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_lab", },
		-- lab_antn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0000|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="mafr_lab", },
		-- lab_antn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0001|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="mafr_lab", },
		-- lab_antn003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_antn001_vrtn004_gim_n0002|srt_afgh_antn001_fndt004", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTN, blockLarge ="mafr_lab", },
		-- lab_mchn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0000|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="mafr_lab", },
		-- lab_mchn002 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0001|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="mafr_lab", },
		-- lab_mchn003 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "mtbs_mchn025_vrtn001_gim_n0002|srt_mtbs_mchn025_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MCHN, blockLarge ="mafr_lab", },
		-- lab_cmmn001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_cmmn002_cmmn002_gim_n0000|srt_afgh_cmmn002_cmmn002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CMMN, blockLarge ="mafr_lab", },
		lab_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_lab", },
		lab_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0001|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_lab", },
		lab_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="mafr_lab", },
		lab_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="mafr_lab", },
		lab_antiair001 = { type = TppGameObject.GAME_OBJECT_TYPE_GATLINGGUN, locatorName = "nad0_main0_def_gim_n0000|srt_nad0_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.ANTIAIR, blockLarge ="mafr_lab", },
		lab_brdg001 = { type = TppGameObject.GAME_OBJECT_TYPE_BRIDGE, locatorName = "mafr_brdg007_vrtn001_gim_n0001|srt_mafr_brdg007_vrtn001_0001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LAB_BRDG, blockLarge ="mafr_lab", },
		lab_brdg002 = { type = TppGameObject.GAME_OBJECT_TYPE_BRIDGE, locatorName = "mafr_brdg007_vrtn001_gim_n0001|srt_mafr_brdg007_vrtn001_0002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LAB_BRDG, blockLarge ="mafr_lab", },
		lab_brdg003 = { type = TppGameObject.GAME_OBJECT_TYPE_BRIDGE, locatorName = "mafr_brdg007_vrtn001_gim_n0001|srt_mafr_brdg007_vrtn001_0003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LAB_BRDG, blockLarge ="mafr_lab", },
		lab_brdg004 = { type = TppGameObject.GAME_OBJECT_TYPE_BRIDGE, locatorName = "mafr_brdg007_vrtn001_gim_n0002|srt_mafr_brdg007_vrtn001_0001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LAB_BRDG, blockLarge ="mafr_lab", },
		lab_brdg005 = { type = TppGameObject.GAME_OBJECT_TYPE_BRIDGE, locatorName = "mafr_brdg007_vrtn001_gim_n0002|srt_mafr_brdg007_vrtn001_0002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LAB_BRDG, blockLarge ="mafr_lab", },
		lab_brdg006 = { type = TppGameObject.GAME_OBJECT_TYPE_BRIDGE, locatorName = "mafr_brdg007_vrtn001_gim_n0002|srt_mafr_brdg007_vrtn001_0003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LAB_BRDG, blockLarge ="mafr_lab", },
		lab_brdg007 = { type = TppGameObject.GAME_OBJECT_TYPE_BRIDGE, locatorName = "mafr_brdg007_vrtn001_gim_n0003|srt_mafr_brdg007_vrtn001_0001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LAB_BRDG, blockLarge ="mafr_lab", },
		lab_brdg008 = { type = TppGameObject.GAME_OBJECT_TYPE_BRIDGE, locatorName = "mafr_brdg007_vrtn001_gim_n0003|srt_mafr_brdg007_vrtn001_0002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LAB_BRDG, blockLarge ="mafr_lab", },
		lab_brdg009 = { type = TppGameObject.GAME_OBJECT_TYPE_BRIDGE, locatorName = "mafr_brdg007_vrtn001_gim_n0003|srt_mafr_brdg007_vrtn001_0003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LAB_BRDG, blockLarge ="mafr_lab", },
		lab_brdg010 = { type = TppGameObject.GAME_OBJECT_TYPE_BRIDGE, locatorName = "mafr_brdg007_vrtn001_gim_n0004|srt_mafr_brdg007_vrtn001_0001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LAB_BRDG, blockLarge ="mafr_lab", },
		lab_brdg011 = { type = TppGameObject.GAME_OBJECT_TYPE_BRIDGE, locatorName = "mafr_brdg007_vrtn001_gim_n0004|srt_mafr_brdg007_vrtn001_0002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LAB_BRDG, blockLarge ="mafr_lab", },
		lab_brdg012 = { type = TppGameObject.GAME_OBJECT_TYPE_BRIDGE, locatorName = "mafr_brdg007_vrtn001_gim_n0004|srt_mafr_brdg007_vrtn001_0003", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LAB_BRDG, blockLarge ="mafr_lab", },
		lab_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0000|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/mission2/story/s10093/s10093_item.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="", },
		lab_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/mission2/story/s10093/s10093_item.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="", },
		-- lab_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/lab/mafr_lab_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="mafr_lab", },
		-- outland_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/outland/mafr_outland_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockLarge ="mafr_outland", },
		outland_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/outland/mafr_outland_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_outland", },
		outland_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0001|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/outland/mafr_outland_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockLarge ="mafr_outland", },
		outland_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/outland/mafr_outland_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="mafr_outland", },
		outland_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_large/outland/mafr_outland_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockLarge ="mafr_outland", },
		outland_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/outland/mafr_outland_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="mafr_outland", },
		-- outland_gnrt001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_IMPORTANT_BREAKABLE, locatorName = "afgh_gnrt002_vrtn001_gim_n0001|srt_afgh_gnrt002_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_large/outland/mafr_outland_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GNRT, blockLarge ="mafr_outland", },
		outland_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/outland/mafr_outland_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockLarge ="mafr_outland", },
		outland_tower002 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0001|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_large/outland/mafr_outland_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockLarge ="mafr_outland", },
		outland_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/outland/mafr_outland_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_outland", },
		outland_light002 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0001|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_large/outland/mafr_outland_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockLarge ="mafr_outland", },
		bananaEast_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/137/137_124/mafr_137_124_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {137,124} , },
		bananaEast_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0001|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/137/137_124/mafr_137_124_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {137,124} , },
		bananaEast_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/137/137_124/mafr_137_124_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {137,124} , },
		bananaSouth_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0000|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/134/134_127/mafr_134_127_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {134,127} , },
		bananaSouth_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/134/134_127/mafr_134_127_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {134,127} , },
		bananaSouth_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/134/134_128/mafr_134_128_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {134,128} , },
		bananaSouth_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/134/134_127/mafr_134_127_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {134,127} , },
		bananaSouth_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/134/134_127/mafr_134_127_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {134,127} , },
		bananaSouth_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/134/134_127/mafr_134_127_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {134,127} , },
		savannahWest_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/138/138_128/mafr_138_128_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {138,128} , },
		savannahWest_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/138/138_128/mafr_138_128_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {138,128} , },
		savannahWest_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/138/138_128/mafr_138_128_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {138,128} , },
		savannahWest_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/138/138_128/mafr_138_128_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {138,128} , },
		savannahEast_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/142/142_133/mafr_142_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {142,133} , },
		savannahEast_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/142/142_134/mafr_142_134_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {142,134} , },
		savannahEast_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0000|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/142/142_133/mafr_142_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {142,133} , },
		savannahEast_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/142/142_133/mafr_142_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {142,133} , },
		savannahEast_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/142/142_133/mafr_142_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {142,133} , },
		savannahEast_tower002 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/142/142_134/mafr_142_134_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {142,134} , },
		savannahEast_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/142/142_133/mafr_142_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {142,133} , },
		savannahEast_light002 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/142/142_134/mafr_142_134_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {142,134} , },
		savannahNorth_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/138/138_125/mafr_138_125_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {138,125} , },
		savannahNorth_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0001|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/138/138_125/mafr_138_125_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {138,125} , },
		savannahNorth_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/138/138_125/mafr_138_125_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {138,125} , },
		savannahNorth_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/138/138_125/mafr_138_125_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {138,125} , },
		labWest_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/149/149_115/mafr_149_115_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {149,115} , },
		labWest_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/149/149_115/mafr_149_115_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {149,115} , },
		labWest_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/149/149_115/mafr_149_115_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {149,115} , },
		labWest_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0001|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/149/149_115/mafr_149_115_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {149,115} , },
		labWest_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/149/149_115/mafr_149_115_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {149,115} , },
		labWest_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/149/149_116/mafr_149_116_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {149,116} , },
		-- labWest_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/149/149_116/mafr_149_116_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockSmall = {149,116} , },
		diamondNorth_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0001|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/143/143_118/mafr_143_118_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {143,118} , },
		diamondNorth_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0002|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/143/143_118/mafr_143_118_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {143,118} , },
		diamondNorth_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/143/143_118/mafr_143_118_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {143,118} , },
		diamondNorth_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/143/143_118/mafr_143_118_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {143,118} , },
		diamondWest_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0000|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/141/141_123/mafr_141_123_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {141,123} , },
		diamondWest_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/141/141_123/mafr_141_123_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {141,123} , },
		diamondWest_cntn003 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0002|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/141/141_123/mafr_141_123_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {141,123} , },
		diamondWest_cntn004 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0003|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/141/141_123/mafr_141_123_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {141,123} , },
		diamondWest_cntn005 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0004|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/141/141_123/mafr_141_123_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {141,123} , },
		diamondWest_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/141/141_123/mafr_141_123_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {141,123} , },
		diamondWest_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/140/140_123/mafr_140_123_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {140,123} , },
		diamondWest_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/140/140_123/mafr_140_123_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {140,123} , },
		diamondSouth_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0000|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/144/144_127/mafr_144_127_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {144,127} , },
		diamondSouth_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/144/144_127/mafr_144_127_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {144,127} , },
		diamondSouth_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/143/143_127/mafr_143_127_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {143,127} , },
		diamondSouth_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/144/144_127/mafr_144_127_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {144,127} , },
		diamondSouth_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/143/143_127/mafr_143_127_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {143,127} , },
		diamondSouth_tower002 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/144/144_127/mafr_144_127_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {144,127} , },
		diamondSouth_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/143/143_127/mafr_143_127_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {143,127} , },
		diamondSouth_light002 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/144/144_127/mafr_144_127_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {144,127} , },
		-- diamondSouth_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/144/144_127/mafr_144_127_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockSmall = {144,127} , },
		swampEast_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/136/136_133/mafr_136_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {136,133} , },
		swampEast_light002 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn002_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/135/135_133/mafr_135_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {135,133} , },
		swampEast_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/136/136_133/mafr_136_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {136,133} , },
		swampEast_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/135/135_132/mafr_135_132_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {135,132} , },
		swampEast_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/135/135_132/mafr_135_132_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {135,132} , },
		swampEast_mortar003 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0002|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/135/135_132/mafr_135_132_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {135,132} , },
		swampEast_mortar004 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/135/135_133/mafr_135_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {135,133} , },
		swampEast_mortar005 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/135/135_133/mafr_135_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {135,133} , },
		swampEast_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/136/136_133/mafr_136_133_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {136,133} , },
		swampEast_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/135/135_132/mafr_135_132_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {135,132} , },
		swampSouth_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/135/135_135/mafr_135_135_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {135,135} , },
		swampSouth_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/135/135_135/mafr_135_135_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {135,135} , },
		swampWest_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/128/128_131/mafr_128_131_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {128,131} , },
		factorySouth_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/151/151_132/mafr_151_132_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {151,132} , },
		factorySouth_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/151/151_132/mafr_151_132_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {151,132} , },
		factorySouth_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0000|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/151/151_132/mafr_151_132_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {151,132} , },
		factorySouth_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/151/151_132/mafr_151_132_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {151,132} , },
		outlandNorth_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/126/126_138/mafr_126_138_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {126,138} , },
		outlandNorth_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/126/126_138/mafr_126_138_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {126,138} , },
		outlandNorth_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/126/126_138/mafr_126_138_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {126,138} , },
		outlandNorth_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/126/126_138/mafr_126_138_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {126,138} , },
		outlandEast_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/130/130_138/mafr_130_138_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {130,138} , },
		outlandEast_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/130/130_138/mafr_130_138_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {130,138} , },
		outlandEast_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/130/130_139/mafr_130_139_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {130,139} , },
		outlandEast_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/130/130_138/mafr_130_138_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {130,138} , },
		pfCampNorth_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/140/140_135/mafr_140_135_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {140,135} , },
		pfCampNorth_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/140/140_136/mafr_140_136_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {140,136} , },
		pfCampNorth_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/140/140_136/mafr_140_136_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {140,136} , },
		chicoVilWest_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/145/145_146/mafr_145_146_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {145,146} , },
		chicoVilWest_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/145/145_147/mafr_145_147_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {145,147} , },
		chicoVilWest_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/145/145_146/mafr_145_146_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {145,146} , },
		hillNorth_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0000|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/147/147_130/mafr_147_130_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {147,130} , },
		hillNorth_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/147/147_130/mafr_147_130_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {147,130} , },
		hillNorth_cntn003 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0000|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/148/148_131/mafr_148_131_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {148,131} , },
		hillNorth_cntn004 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/148/148_131/mafr_148_131_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {148,131} , },
		hillNorth_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0001|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/148/148_131/mafr_148_131_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {148,131} , },
		hillNorth_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/148/148_130/mafr_148_130_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {148,130} , },
		hillNorth_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/148/148_130/mafr_148_130_asset.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {148,130} , },
		hillNorth_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/148/148_130/mafr_148_130_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {148,130} , },
		hillNorth_tower002 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/148/148_131/mafr_148_131_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {148,131} , },
		hillSouth_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0000|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/148/148_143/mafr_148_143_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {148,143} , },
		hillSouth_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/148/148_143/mafr_148_143_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {148,143} , },
		hillSouth_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/148/148_143/mafr_148_143_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {148,143} , },
		hillWest_light001 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/145/145_134/mafr_145_134_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {145,134} , },
		hillWest_light002 = { type = TppGameObject.GAME_OBJECT_TYPE_SEARCHLIGHT, locatorName = "mafr_wtct002_vrtn001_gim_n0000|gntn_srlg001_vrtn001_gim_n0000|srt_gntn_srlg001_gm", dataSetName = "/Assets/tpp/level/location/mafr/block_small/146/146_134/mafr_146_134_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.LIGHT, blockSmall = {146,134} , },
		hillWest_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/145/145_134/mafr_145_134_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {145,134} , },
		hillWest_tower002 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_vrtn001_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/146/146_134/mafr_146_134_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {146,134} , },
		hillWest_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/145/145_134/mafr_145_134_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {145,134} , },
		hillWest_mortar002 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0001|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/145/145_134/mafr_145_134_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {145,134} , },
		hillWest_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/145/145_134/mafr_145_134_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {145,134} , },
		hillWest_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/146/146_134/mafr_146_134_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {146,134} , },
		hillWest_gun003 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0001|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/146/146_134/mafr_146_134_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {146,134} , },
		hillWest_gun004 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/146/146_135/mafr_146_135_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {146,135} , },
		hillWest_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0000|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/145/145_134/mafr_145_134_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {145,134} , },
		hillWest_cntn002 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/145/145_134/mafr_145_134_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {145,134} , },
		hillWest_cntn003 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0002|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/145/145_134/mafr_145_134_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {145,134} , },
		hillWest_cntn004 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0001|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/146/146_134/mafr_146_134_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockSmall = {146,134} , },
		hillWestNear_mortar001 = { type = TppGameObject.GAME_OBJECT_TYPE_MORTAR, locatorName = "hw00_gim_n0000|srt_hw00_main0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/147/147_138/mafr_147_138_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.MORTAR, blockSmall = {147,138} , },
		hillWestNear_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/147/147_138/mafr_147_138_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {147,138} , },
		-- hillWestNear_casset001 = { .*type = TppGameObject.GAME_OBJECT_TYPE_RADIO_CASSETTE, locatorName = "afgh_radi001_csst001_gim_n0000|srt_afgh_radi001_csst001", dataSetName = "/Assets/tpp/level/location/mafr/block_small/146/146_138/mafr_146_138_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CSET, blockSmall = {146,138} , },
		pfCampEast_tower001 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/142/142_137/mafr_142_137_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {142,137} , },
		pfCampEast_tower002 = { type = TppGameObject.GAME_OBJECT_TYPE_WATCH_TOWER, locatorName = "mafr_wtct002_gim_n0000|srt_mafr_wtct002", dataSetName = "/Assets/tpp/level/location/mafr/block_small/141/141_137/mafr_141_137_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.TOWER, blockSmall = {141,137} , },
		pfCampEast_gun001 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/142/142_137/mafr_142_137_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {142,137} , },
		pfCampEast_gun002 = { type = TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN, locatorName = "hw01_gim_n0000|srt_hw01_tpod0_def", dataSetName = "/Assets/tpp/level/location/mafr/block_small/141/141_137/mafr_141_137_gimmick.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.GUN, blockSmall = {141,137} , },
		q40010_cntn001 = { type = TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER, locatorName = "gntn_cntn001_vrtn001_gim_n0000|srt_gntn_cntn001_vrtn001", dataSetName = "/Assets/tpp/level/mission2/quest/mafr/outland/outland_q40010.fox2", gimmickType = TppGimmick.GIMMICK_TYPE.CNTN, blockLarge ="", },
	},

}
--r35 Reset useful gimmicks
function this.ResetAllGimmicks()

	if cannotResetGimmicksAsComingFromTitle  then
		cannotResetGimmicksAsComingFromTitle = false
		return
	end

	if gvars.sav_varRestoreForContinue then
		return
	end

	local resetGimmicksList

	if TppLocation.IsAfghan() then
		resetGimmicksList=this.resetGimmicksList.afghan
	elseif TppLocation.IsMiddleAfrica() then
		resetGimmicksList=this.resetGimmicksList.africa
	else
		return
	end

	for identifier, details in pairs(resetGimmicksList) do
		--    Gimmick.ResetGimmick( details.type ) --nope
		--    Gimmick.ResetGimmick( details.type, details.locatorName ) --nope
		Gimmick.ResetGimmick( details.type, details.locatorName, details.dataSetName )
	end

	--  for identifier, details in pairs(this.resetGimmicksList.afghan) do
	----    Gimmick.ResetGimmick( details.type ) --nope
	----    Gimmick.ResetGimmick( details.type, details.locatorName )
	--    Gimmick.ResetGimmick( details.type, details.locatorName, details.dataSetName )
	--  end
	--  for identifier, details in pairs(this.resetGimmicksList.africa) do
	----    Gimmick.ResetGimmick( details.type ) --nope
	----    Gimmick.ResetGimmick( details.type, details.locatorName )
	--    Gimmick.ResetGimmick( details.type, details.locatorName, details.dataSetName )
	--  end

end

--r48 Cause repeating randomization
function this.SetFixedRandomization()
	math.randomseed(gvars.rev_revengeRandomValue)
	this.Randomize()
end

--r48 Set truely random randomization
function this.UnsetFixedRandomization()
	math.randomseed(os.time())
	this.Randomize()
end

--r43 Randomize using this from now on
function this.Randomize()
	math.random()math.random()math.random()
	--  local useless = math.random()*math.random()*math.random()
	--  math.random()math.random()math.random()
end

--r43 Override vehicle spawn positions
-- while this works we are looking at complicated handling for all LZs
function this.OverrideVehiclePos(missionTable)
	if missionTable.sequence.NPC_ENTRY_POINT_SETTING then
		TUPPMLog.Log("NPC_ENTRY_POINT_SETTING found")
		--    TUPPMLog.Log("#missionTable.sequence.NPC_ENTRY_POINT_SETTING "..tostring(#missionTable.sequence.NPC_ENTRY_POINT_SETTING))
		local NPC_ENTRY_POINT_SETTING=missionTable.sequence.NPC_ENTRY_POINT_SETTING
		TUPPMLog.Log("#NPC_ENTRY_POINT_SETTING "..tostring(#NPC_ENTRY_POINT_SETTING))
		if #NPC_ENTRY_POINT_SETTING~=0 then
			TUPPMLog.Log("NPC_ENTRY_POINT_SETTING~=0")

			--      if #missionTable.sequence.NPC_ENTRY_POINT_SETTING[EntryBuddyType.VEHICLE]==0 then
			--        TUPPMLog.Log("NPC_ENTRY_POINT_SETTING[EntryBuddyType.VEHICLE]==0 so returning")
			--        return
			--      end
			return
		end
	end

	TUPPMLog.Log("OverrideVehiclePos")
	if gvars.heli_missionStartRoute~=0 then
		local groundStartPosition=this.LZPositions[gvars.heli_missionStartRoute]
		if groundStartPosition then
			local mbBuddyEntrySettings={}
			local positions={}
			local pos=Vector3(groundStartPosition.pos[1]+3,groundStartPosition.pos[2]-4,groundStartPosition.pos[3]+3)
			local entryEntry={}
			entryEntry[EntryBuddyType.VEHICLE]={pos,vars.playerRotY}
			mbBuddyEntrySettings[gvars.heli_missionStartRoute]=entryEntry
			TppEnemy.NPCEntryPointSetting(mbBuddyEntrySettings)
		end
	end
end

--r43 Override vehicle spawn positions
function this.OverrideVehiclePos2(missionTable)

	if TppMission.IsMbFreeMissions(vars.missionCode) then return end

	--r45 Use custom vehicle drop locations only in case when heli rides patch is not used
	if not this.isFakeHeliDropRequired then return end
	--  TUPPMLog.Log("OverrideVehiclePos2 isFakeHeliDropRequired is true")

	local route = nil

	if this.LZPositions[gvars.heli_missionStartRoute] then
		route = this.LZPositions[gvars.heli_missionStartRoute]
	end

	if route==nil then return end

	--> USELESS
	--  if gvars.heli_missionStartRoute~=0 then
	--    --Got from TppHelicopter
	--
	--    -- first positive value seems to move vehicle along heli route
	--    -- 6(default) is just over/near Snake in most cases
	--    -- The number means distance from heli in direction of heli
	--    -- 0(zero) spawns right inside heli
	--
	--    -- second positive value moves vehicle to the right of heli
	--    -- feel they are simply x,z co-ords
	--
	--    --biggest tank does not touch heli outside a 10x10 area
	--
	--		--West is negative degree positive radians
	--		--East is positive degree negative radians
	--		--providing 0 radians here is about 160 degrees in game so the rotation is off by 160 degrees
	--		-- 0 == 160
	--		-- 3.14 == -16
	--		-- 2.89725 == -31
	--		-- 45 == -140
	--
	--    --9x9 may drop on buddy
	--
	--
	----    TppBuddyService.AdjustFromDropPoint(gvars.heli_missionStartRoute,EntryBuddyType.BUDDY,12,3.14)
	--
	----    TppBuddyService.AdjustFromDropPoint(gvars.heli_missionStartRoute,EntryBuddyType.VEHICLE,-10,-10,-10) -XXX
	----    TppBuddyService.AdjustFromDropPoint(gvars.heli_missionStartRoute,EntryBuddyType.VEHICLE,6,-10,0) -XXX
	----		TppBuddyService.AdjustFromDropPoint(gvars.heli_missionStartRoute,EntryBuddyType.VEHICLE,distanceFromPlayer,rotationFromPlayerInRadians)
	----		rotationFromPlayerInRadians range [-3.14,3.14] equal to [-180, 180]
	--
	--
	--    --r45 INFO ***Figured it out***
	--    --Forget all the bullshit above
	--    --TppBuddyService.AdjustFromDropPoint(route,EntryBuddyType.VEHICLE,distanceFromPlayer,rotationRelativeToDirectionHeliIsPointingAt)
	--    --rotationRelativeToDirectionHeliIsPointingAt will be 0 in the direction of nose of heli i.e in direction of drop route AT drop point
	--    --rotationRelativeToDirectionHeliIsPointingAt is in radians
	--    --rotationRelativeToDirectionHeliIsPointingAt -ve decrease(-1 to -179) means circle right
	--    --rotationRelativeToDirectionHeliIsPointingAt +ve increase(1 to 179) means circle left
	--    --rotationRelativeToDirectionHeliIsPointingAt is reversed compared to normal player rotation
	--    --distanceFromPlayer is radius of circle formed
	--
	--		--Basically the rotation will define where the vehicle/buddy will be dropped relative to center of the circle formed, 0 being the
	--		-- direction of nose of heli
	--
	--
	--    --Since the heli nose may point in any direction (meaning any *map* based rotation) and since
	--    -- that direction is considered as 0 rotation for vehicle drop, it is impossible to "automize"
	--    -- vehicle drop location relative to player rotation
	--
	--		local vehicleStartRotDeg = 0
	--		if route.rotY then
	--			vehicleStartRotDeg = route.rotY
	--
	----			vehicleStartRotDeg=vehicleStartRotDeg+90
	--
	----			if vehicleStartRotDeg>0 then
	----				vehicleStartRotDeg = -90
	----			else
	----				vehicleStartRotDeg = 90
	----			end
	--		end
	--
	----		if vehicleStartRotDeg<0 then
	----			vehicleStartRotDeg = vehicleStartRotDeg + 360
	----		end
	--
	----		if vehicleStartRotDeg<=-180 then
	----			vehicleStartRotDeg = vehicleStartRotDeg + 360
	----		elseif vehicleStartRotDeg>=180 then
	----			vehicleStartRotDeg = vehicleStartRotDeg - 360
	----		end
	----
	----		vehicleStartRotDeg=-vehicleStartRotDeg
	--
	--		local vehicleSartRotRad = TppMath.DegreeToRadian(vehicleStartRotDeg)
	--
	--		vehicleSartRotRad=0 --set to def, it cannot be set to player relative rotation
	----		vehicleSartRotRad=-vehicleSartRotRad --lol, degree to radians is reversed on the game grid
	--
	--		--Third param not used here
	----		TppBuddyService.AdjustFromDropPoint(gvars.heli_missionStartRoute, EntryBuddyType.VEHICLE, 16, playerStartRotRad, TppMath.DegreeToRadian(route.rotY))
	--		TppBuddyService.AdjustFromDropPoint(gvars.heli_missionStartRoute, EntryBuddyType.VEHICLE, 16, vehicleSartRotRad)
	----		TppBuddyService.AdjustFromDropPoint(gvars.heli_missionStartRoute, EntryBuddyType.VEHICLE, 16, TppMath.DegreeToRadian(90))
	----		TppBuddyService.AdjustFromDropPoint(gvars.heli_missionStartRoute, EntryBuddyType.VEHICLE, 16, 0)
	--
	----		TUPPMLog.Log("vehicleStartRotDeg:"..tostring(vehicleStartRotDeg).." vehicleSartRotRad:"..tostring(vehicleSartRotRad))
	--  end
	--< USELESS

	--r45 Set custom vehicle locations when starting on foot
	-- Also set rotation of vehcile to rotation the player will be facing in
	if route.defHeliSide~="" then
		TppBuddyService.SetMissionEntryPosition(EntryBuddyType.VEHICLE, route.vehiclePos)
		TppBuddyService.SetMissionEntryRotationY(EntryBuddyType.VEHICLE, TppMath.DegreeToRadian(route.rotY))
	end

end

--r43 Set some soldiers as WildCards
function this.AddWildCards(soldierDefine, soldierPowerSettings, soldierPersonalAbilitySettings)

	local locationName=TppLocation.GetLocationName()
	local allFaceIdsTable=TppEneFova.GetAllFaceIds(TppEneFova.maleFaceIdsUncommon)
	local wildCardsBodiesTable=TppEneFova.wildCardBodyTable[locationName]

	if allFaceIdsTable==nil or wildCardsBodiesTable==nil or #allFaceIdsTable==0 or #wildCardsBodiesTable==0 then return end

	--  TUPPMLog.Log("#allFaceIdsTable: "..tostring(#allFaceIdsTable))
	--  TUPPMLog.Log("#wildCardsBodiesTable: "..tostring(#wildCardsBodiesTable))

	local numOfWildCardsAllowed=TppDefine.ENEMY_FOVA_UNIQUE_SETTING_COUNT
	--  local numOfWildCardsAllowed=100 --DEBUG AID --rX46 Nope
	local wildCardsAdded = 0
	local isWildCardSol={}

	while wildCardsAdded<numOfWildCardsAllowed do

		for cpName,cpDefine in pairs(soldierDefine)do
			if #cpDefine>0 then
				local cpId=GameObject.GetGameObjectId("TppCommandPost2",cpName)
				if cpId==GameObject.NULL_ID then
				else
					if cpName=="quest_cp" then
					else
						for i, soldierName in ipairs(cpDefine) do
							TppMain.Randomize()
							local chance = math.random(1,100)
							--                chance=0 --DEBUG AID --rX46 Nope
							if
								wildCardsAdded<numOfWildCardsAllowed and
								chance<=5 and
								isWildCardSol[soldierName]~=true
							then
								--                TUPPMLog.Log("i: "..tostring(i).."soldierName: "..tostring(soldierName),3)

								local faceIndex=math.random(1,#allFaceIdsTable)
								local wildFaceId=allFaceIdsTable[faceIndex]
								local bodyIndex=math.random(1,#wildCardsBodiesTable)
								local wildBodyId=wildCardsBodiesTable[bodyIndex]
								TppEneFova.RegisterUniqueSetting("enemy",soldierName,wildFaceId,wildBodyId)
								table.insert(isWildCardSol, soldierName)
								isWildCardSol[soldierName]=true

								wildCardsAdded=wildCardsAdded+1

								local soldierPowers={"WILDCARDED"}

								TppMain.Randomize()
								local randomVariable = math.random()
								if randomVariable <= 0.10 and (TppRevenge.IsIgnoreBlocked() or not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.SHIELD)) then
									table.insert(soldierPowers,"SHIELD")
									TppMain.Randomize()
								elseif randomVariable <= 0.15 and (TppRevenge.IsIgnoreBlocked() or not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.SNIPER)) then
									table.insert(soldierPowers,"SNIPER")
									TppMain.Randomize()
								elseif randomVariable <= 0.20 and (TppRevenge.IsIgnoreBlocked() or not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.MISSILE)) then
									table.insert(soldierPowers,"MISSILE")
									TppMain.Randomize()
								elseif randomVariable <= 0.50 and (TppRevenge.IsIgnoreBlocked() or not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.MG)) then
									table.insert(soldierPowers,"MG")
									TppMain.Randomize()
								elseif randomVariable <= 0.80 and (TppRevenge.IsIgnoreBlocked() or not TppRevenge.IsBlocked(TppRevenge.BLOCKED_TYPE.SHOTGUN)) then
									table.insert(soldierPowers,"SHOTGUN")
									TppMain.Randomize()
								else
									table.insert(soldierPowers,"ASSAULT")
									TppMain.Randomize()
								end

								soldierPowerSettings[soldierName]=soldierPowers

								TppMain.Randomize()
								--                    TUPPMLog.Log("wildCardsAdded: "..tostring(wildCardsAdded).." chance: "..tostring(chance).." Assigned WILD: "..tostring(soldierName).." wildFaceId: "..tostring(wildFaceId).." wildBodyId: "..tostring(wildBodyId), 3)
							end
						end
					end
				end
			end
		end
	end

end

--r48 More soldiers on MB platforms -tex
local function FillList(fillCount,sourceList,fillList)
	local addedSoldiers={}
	while fillCount>0 and #sourceList>0 do
		local soldierName=sourceList[#sourceList]
		if soldierName then
			sourceList[#sourceList]=nil--pop
			fillList[#fillList+1]=soldierName
			addedSoldiers[#addedSoldiers+1]=soldierName
			fillCount=fillCount-1
		end
	end
	return addedSoldiers
end

this.reserveSoldierNames={}
this.soldierPool={}

local solPrefix="sol_ih_"
local maxSoldiersOnPlat=9
local additionalSoldiersPerPlat=5

--r48 More soldiers on MB platforms -tex
function this.BuildReserveSoldierNames(numReserveSoldiers,reserveSoldierNames)
	reserveSoldierNames={}

	for i=0,numReserveSoldiers-1 do
		local name=string.format("%s%04d",solPrefix,i)
		reserveSoldierNames[#reserveSoldierNames+1]=name
	end
	return reserveSoldierNames
end

--r48 More soldiers on MB platforms -tex
function this.ResetPool(objectNames)
	local namePool={}
	for i=1,#objectNames do
		namePool[i]=objectNames[i]
	end
	return namePool
end

--r48 More soldiers on MB platforms -tex
function this.ModifyMBAssetTable()
	--r51 Settings
	if not TUPPMSettings.mtbs_ENABLE_extraSoldiersOnMB then return end

	if vars.missionCode~=30050 then
		return
	end
	--	TUPPMLog.Log(
	--  "-------------------ModifyEnemyAssetTable-------------------"
	--  ,3)

	this.reserveSoldierNames=this.BuildReserveSoldierNames(126,this.reserveSoldierNames)
	this.soldierPool=this.ResetPool(this.reserveSoldierNames)

	local GetMBEnemyAssetTable=TppEnemy.GetMBEnemyAssetTable or mvars.mbSoldier_funcGetAssetTable

	--	TUPPMLog.Log(
	--  "\n this.reserveSoldierNames: "..tostring(InfInspect.Inspect(this.reserveSoldierNames))
	--  .."\n this.soldierPool: "..tostring(InfInspect.Inspect(this.soldierPool))
	--  .."\n GetMBEnemyAssetTable: "..tostring(InfInspect.Inspect(GetMBEnemyAssetTable))
	--  ,1)

	local plntPrefix="plnt"
	for clusterId=1,#TppDefine.CLUSTER_NAME do
		local totalPlatsRouteCount=0--DEBUG
		local soldierCountFinal=0

		local grade=TppLocation.GetMbStageClusterGrade(clusterId)
		if grade>0 then
			for i=1,grade do
				local clusterAssetTable=GetMBEnemyAssetTable(clusterId)
				local platName=plntPrefix..(i-1)

				local platInfo=clusterAssetTable[platName]

				local soldierList=platInfo.soldierList

				local sneakRoutes=platInfo.soldierRouteList.Sneak[1].inPlnt
				local nightRoutes=platInfo.soldierRouteList.Night[1].inPlnt

				local addedRoutes=false
				for i=1,#sneakRoutes do
					if sneakRoutes[i]==nightRoutes[1] then
						addedRoutes=true
						break
					end
				end
				if not addedRoutes then
					for i=1,#nightRoutes do
						sneakRoutes[#sneakRoutes+1]=nightRoutes[i]
					end
					for i=1,#sneakRoutes do
						nightRoutes[#nightRoutes+1]=sneakRoutes[i]
					end
				end

				local minRouteCount=math.min(#sneakRoutes,#nightRoutes)

				local numToAdd=maxSoldiersOnPlat-#soldierList
				--        local numToAdd=math.min((minRouteCount-3)-#soldierList,additionalSoldiersPerPlat)--tex MAGIC this only really affects main plats which only have 12(-6soldiers) routes (with combined sneak/night). Rest have 15+

				if numToAdd>0 then
					FillList(numToAdd,this.soldierPool,soldierList)
				end
				soldierCountFinal=soldierCountFinal+#soldierList
			end
		end

		--		TUPPMLog.Log(
		--	  "ModifyMBAssetTable AFTER \n GetMBEnemyAssetTable("..tostring(clusterId).."): "..tostring(InfInspect.Inspect(GetMBEnemyAssetTable(clusterId)))
		--	  ,1)

	end
end

--rX51 Reset AA Radars
function this.ResetAARadars()
	--	TUPPMLog.Log("gvars.res_missionClearHistory:"..tostring(InfInspect.Inspect(gvars.res_missionClearHistory)),1,true)

	for index=0,35 do
		TUPPMLog.Log("gvars.res_missionClearHistory["..index.."]:"..tostring(gvars.res_missionClearHistory[index]),1)
	end
end



--r51 Settings
function this.ForceChangeWildWeather()
	--	if vars.missionCode==1 or vars.missionCode==5 or vars.missionCode==6000 then return end
	if TppMission.IsFOBMission(vars.missionCode) then return end
	if not (TUPPMSettings.weather_ENABLE_customSettings and TUPPMSettings.weather_ENABLE_wildWeatherMode and TUPPMSettings.weather_ENABLE_startMissionWithWildWeather) then return end
	local normalWeatherTypes=TppWeather.SetCustomWeatherProbabilities()

	local normalAreaWeather
	local isAfghan=TppLocation.IsAfghan()
	local isMiddleAfrica=TppLocation.IsMiddleAfrica()
	local isMotherBase=TppLocation.IsMotherBase()
	local isHeliSpace=TppMission.IsHelicopterSpace(vars.missionCode)

	TUPPMLog.Log("missionCode:"..tostring(vars.missionCode)
		.." ForceChangeWildWeather"
		.."\n vars.locationCode:"..tostring(vars.locationCode)
		.." IsAfghan:"..tostring(isAfghan)
		.." IsMiddleAfrica:"..tostring(isMiddleAfrica)
		.." IsMotherBase:"..tostring(isMotherBase)
		.." isHeliSpace:"..tostring(isHeliSpace)
		,3)

	if isAfghan then
		normalAreaWeather=normalWeatherTypes.AFGH
		if isHeliSpace then
			normalAreaWeather=normalWeatherTypes.AFGH_HELI
		end
	elseif isMiddleAfrica then
		normalAreaWeather=normalWeatherTypes.MAFR
		if isHeliSpace then
			normalAreaWeather=normalWeatherTypes.MAFR_HELI
		end
	elseif isMotherBase then
		normalAreaWeather=normalWeatherTypes.MTBS
		if isHeliSpace then
			normalAreaWeather=normalWeatherTypes.MTBS_HELI
		end
	end

	if normalAreaWeather then

		TUPPMLog.Log("missionCode:"..tostring(vars.missionCode)
			.." ForceChangeWildWeather"
			.."\n normalAreaWeather:"..tostring(InfInspect.Inspect(normalAreaWeather))
			,3)

		local weatherType
		local weatherTypeChance=-1
		for index, weatherTypeDetails in pairs(normalAreaWeather) do

			TUPPMLog.Log("missionCode:"..tostring(vars.missionCode)
				.." ForceChangeWildWeather"
				.."\n index:"..tostring(index)
				.."\n weatherTypeDetails:"..tostring(InfInspect.Inspect(weatherTypeDetails))
				,3)

			if weatherTypeChance<weatherTypeDetails[2] then
				weatherType=weatherTypeDetails[1]
				weatherTypeChance=weatherTypeDetails[2]
			end
		end

		TUPPMLog.Log("missionCode:"..tostring(vars.missionCode)
			.." ForceChangeWildWeather"
			.." weatherType:"..tostring(weatherType)
			.." weatherTypeChance:"..tostring(weatherTypeChance)
			,3)

		if weatherType then
			WeatherManager.RequestWeather{
				priority=WeatherManager.REQUEST_PRIORITY_NORMAL,
				userId="Script",
				weatherType=weatherType,
				interpTime=0,
				fogDensity=0.05,
				fogType=nil
			}

			--TODO rX51 come back to this --breaks SKULLS fog when loading checkpoint in M1, SKULLS will not be spawned
			--			TppWeather.ForceRequestWeather( weatherType, 0 )
		end
	end
end

return this
