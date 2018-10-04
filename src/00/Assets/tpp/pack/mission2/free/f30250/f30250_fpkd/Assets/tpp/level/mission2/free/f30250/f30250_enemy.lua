--TUPPM Header

local this = {}
local StrCode32 = Fox.StrCode32
local StrCode32Table = Tpp.StrCode32Table
local IsTypeFunc = Tpp.IsTypeFunc
local IsTypeTable = Tpp.IsTypeTable
local IsTypeString = Tpp.IsTypeString
local GetGameObjectId = GameObject.GetGameObjectId
local NULL_ID = GameObject.NULL_ID

this.requires = {}






local UNIQUE_TYPE = Tpp.Enum{
	"VOLGIN",		
	"FOG",			
	"CAMOFLA",		
	"CURING",		
}


local UNIQUE_NAME_LIST = {
	VOLGIN					= "hos_volgin_0000",
	PARASITE_FOG_01			= "hos_wmu00_0000",
	PARASITE_FOG_02			= "hos_wmu00_0001",
	PARASITE_CAMOFLA_01		= "hos_wmu01_0000",
	PARASITE_CAMOFLA_02		= "hos_wmu01_0001",
	PARASITE_CURING_01		= "hos_wmu03_0000",
	PARASITE_CURING_02		= "hos_wmu03_0001",
}


local PARASITE_MOTION_LIST = {
	VOLGIN					= "/Assets/tpp/motion/SI_game/fani/bodies/vol0/vol0non/vol0non_s_ded_p.gani",		
	PARASITE_FOG			= "/Assets/tpp/motion/SI_game/fani/bodies/wmu0/wmu0/wmu0_s_idl_a.gani",				
	PARASITE_CAMOFLA		= "/Assets/tpp/motion/SI_game/fani/bodies/wmu1/wmu1/wmu1_s_prison_idl.gani",		
	PARASITE_CURING			= "/Assets/tpp/motion/SI_game/fani/bodies/wmu3/wmu3/wmu3_s_prison_idl.gani",		
}

local HOSTAGE_DATA_LIST = {
	
	{
		locatorName		= UNIQUE_NAME_LIST.VOLGIN,
		type			= UNIQUE_TYPE.VOLGIN,
		hostageType		= "TppHostageUnique",
		path			= PARASITE_MOTION_LIST.VOLGIN,
	},
	
	{
		locatorName		= UNIQUE_NAME_LIST.PARASITE_FOG_01,
		type			= UNIQUE_TYPE.FOG,
		hostageType		= "TppHostage2",
		path			= PARASITE_MOTION_LIST.PARASITE_FOG,
	},
	{
		locatorName		= UNIQUE_NAME_LIST.PARASITE_FOG_02,
		type			= UNIQUE_TYPE.FOG,
		hostageType		= "TppHostage2",
		path			= PARASITE_MOTION_LIST.PARASITE_FOG,
	},
	
	{
		locatorName		= UNIQUE_NAME_LIST.PARASITE_CAMOFLA_01,
		type			= UNIQUE_TYPE.CAMOFLA,
		hostageType		= "TppHostage2",
		path			= PARASITE_MOTION_LIST.PARASITE_CAMOFLA,
	},
	{
		locatorName		= UNIQUE_NAME_LIST.PARASITE_CAMOFLA_02,
		type			= UNIQUE_TYPE.CAMOFLA,
		hostageType		= "TppHostage2",
		path			= PARASITE_MOTION_LIST.PARASITE_CAMOFLA,
	},
	
	{
		locatorName		= UNIQUE_NAME_LIST.PARASITE_CURING_01,
		type			= UNIQUE_TYPE.CURING,
		hostageType		= "TppHostage2",
		path			= PARASITE_MOTION_LIST.PARASITE_CURING,
	},
	{
		locatorName 	= UNIQUE_NAME_LIST.PARASITE_CURING_02,
		type			= UNIQUE_TYPE.CURING,
		hostageType		= "TppHostage2",
		path			= PARASITE_MOTION_LIST.PARASITE_CURING,
	},
}




this.soldierDefine = {
	
	mbqf_mtbs_cp = {
		"sol_mtbs_0000",
		"sol_mtbs_0001",
		"sol_mtbs_0002",
		"sol_mtbs_0003",
		"sol_mtbs_0004",
		"sol_mtbs_0005",
		"sol_mtbs_0006",
		nil
	},
	nil
}

this.routeSets = {
	
	mbqf_mtbs_cp = {
		priority = {
			"groupA",
			nil
		},
		sneak_day = {
			groupA = {
				"rts_30250_d_0000",
				"rts_30250_d_0001",
				"rts_30250_d_0002",
				"rts_30250_d_0003",
				"rts_30250_d_0004",
				"rts_30250_d_0004",
				"rts_30250_d_0005",
			},
		},
		sneak_night= {
			groupA = {
				"rts_30250_d_0000",
				"rts_30250_d_0001",
				"rts_30250_d_0002",
				"rts_30250_d_0003",
				"rts_30250_d_0004",
				"rts_30250_d_0004",
				"rts_30250_d_0005",
			},
		},
	},
}





this.combatSetting = {
	nil
}






this.InitEnemy = function()
	Fox.Log("*** enemu.lua f30250 InitEnemy ***")
end



this.SetUpEnemy = function()
	Fox.Log("*** enemu.lua f30250 SetupEnemy ***")
	
	
	this.SetFriendlyCp()
	
	
	this.SetFriendlyEnemy()
	
	
	this.SetParasiteResourceCount()
	
	
	this.SetHostage()
	
	
	this.SetAllEnabled()

	
	this.SetupEmblem()
	
	
	TppEnemy.SetSaluteVoiceList()
end


this.OnLoad = function()
	Fox.Log("*** enemu.lua f30250 onload ***")
end





this.SetupEmblem = function()
	local gameObjectId = { type="TppSoldier2" } 
	local command = { id = "SetEmblemType", type = 1 }
    GameObject.SendCommand( gameObjectId, command ) 
end


this.SetFriendlyCp = function()
	local gameObjectId = { type="TppCommandPost2", index=0 }
	local command = { id = "SetFriendlyCp" }
	GameObject.SendCommand( gameObjectId, command )
end


this.SetFriendlyEnemy = function()
	
	local gameObjectId = { type="TppSoldier2" } 
	local command = { id="SetFriendly", enabled=true }
	GameObject.SendCommand( gameObjectId, command )
end


this.SetEnabled = function( gameObjectId, enabled )
	GameObject.SendCommand( gameObjectId, { id = "SetEnabled", enabled = false, } )
end


this.SetAllEnabled = function()
	
	--r46 Enable soldiers on MBQF --added 'or true' in case ur wondering
	--r51 Settings
	if this.IsHostage() == false or TUPPMSettings.mtbs_ENABLE_staffOnMBQFAfterCapture then
		
	--ORIG
	local mbStaffIds = TppMotherBaseManagement.GetOutOnMotherBaseStaffs{ sectionId = TppMotherBaseManagementConst.SECTION_SECURITY, }
		
		--rX46 contains all section staff in a fixed order
--		TUPPMLog.Log("f30250_enemy.SetAllEnabled mbStaffIds:"..tostring(InfInspect.Inspect(mbStaffIds)),3)

		--r51 Settings
		if TUPPMSettings.mtbs_ENABLE_mixedStaffForMBQF then
			--r46 Get randomized staff list from TppEneFova.fovaSetupFunctions.Mb
			mbStaffIds = TppEneFova.mbStaffIdsForMBQF
		end
		
		mvars.mbStaffCount = #mbStaffIds
		
		--ORIG
		local faceIdList = {}
		for index, staffId in pairs( mbStaffIds ) do
			local faceId = TppMotherBaseManagement.StaffIdToFaceId{ staffId = staffId }
			if faceIdList[index] == nil then
				faceIdList[index] = faceId
			end
			
			if index == 7 then
				break
			end
		end
		
		--r51 Settings
		if TUPPMSettings.mtbs_ENABLE_mixedStaffForMBQF then
			--r46 Get randomized face list from TppEneFova.fovaSetupFunctions.Mb
			faceIdList = TppEneFova.faceIdsListForMBQF
--			TUPPMLog.Log("f30250_enemy.SetAllEnabled *RANDOM* faceIdList:"..tostring(InfInspect.Inspect(faceIdList)),3)
		end
		
		for index, enemyId in ipairs( this.soldierDefine.mbqf_mtbs_cp ) do
			local gameObjectId = GetGameObjectId( enemyId )
			if index <= mvars.mbStaffCount then
				if faceIdList[index] then
					
					TppEneFova.ApplyMTBSUniqueSetting( gameObjectId, faceIdList[index] )
				end
				
				 --TODO rX46 Set salute morale to on
--				local command1 = { id="RemoveSaluteMoraleDisable" }
--				local command2 = { id="SetSaluteMoraleEnable", enabled=true  }
--				local command3 = { id="SetSaluteMoraleDisable", enabled=false }
--				GameObject.SendCommand( gameObjectId, command1 )
--				GameObject.SendCommand( gameObjectId, command2 )
--				GameObject.SendCommand( gameObjectId, command3 )
				
			else
				this.SetEnabled( gameObjectId, false )
			end
		end
	else
		for i, enemyId in ipairs( this.soldierDefine.mbqf_mtbs_cp ) do
			local gameObjectId = GetGameObjectId( enemyId )
			this.SetEnabled( gameObjectId, false )
		end
	end
end


this.IsDD = function( gameObjectId )
	if IsTypeString( enemyName ) then
		gameObjectId = GetGameObjectId( gameObjectId )
	end
	local type = GameObject.SendCommand( gameObjectId, { id = "GetSoldier2Type" } )
	
	if type == EnemyType.TYPE_DD then
		return true
	end
	return false
end








function this.SetParasiteResourceCount()
	
	local isFog					= TppMotherBaseManagement.IsGotResource{ resource="ParasiteFog" }
	local isCamofla				= TppMotherBaseManagement.IsGotResource{ resource="ParasiteCamofla" }
	local isCuring				= TppMotherBaseManagement.IsGotResource{ resource="ParasiteCuring" }
	
	mvars.parasiteFogCount		= TppMotherBaseManagement.GetResourceUsableCount{ resourceId = TppMotherBaseManagementConst.RESOURCE_ID_PARASITE_FOG		}
	mvars.parasiteCamoflaCount	= TppMotherBaseManagement.GetResourceUsableCount{ resourceId = TppMotherBaseManagementConst.RESOURCE_ID_PARASITE_CAMOFLA	}
	mvars.parasiteCuringCount	= TppMotherBaseManagement.GetResourceUsableCount{ resourceId = TppMotherBaseManagementConst.RESOURCE_ID_PARASITE_CURING		}
	
	if isFog == true then
		mvars.parasiteFogCount		= mvars.parasiteFogCount + 1
	end
	if isCamofla == true then
		mvars.parasiteCamoflaCount	= mvars.parasiteCamoflaCount + 1
	end
	if isCuring == true then
		mvars.parasiteCuringCount	= mvars.parasiteCuringCount + 1
	end
	if mvars.parasiteFogCount > 0 or mvars.parasiteCamoflaCount > 0 or mvars.parasiteCuringCount > 0 then
		mvars.IsSetParasite = true
	end
end








function this.IsCleardVolgin()
	if TppQuest.IsCleard("tent_q99040") or f30250_sequence.isRecoverVolginDemoPlay() then
		mvars.IsSetVolgin = true
		return true
	end
	return false
end








function this.IsHostage()
	if mvars.IsSetVolgin == true or mvars.IsSetParasite == true then
		return true
	end
	return false
end






function this.SetHostage()
	
	local fogCount		= 0
	local camoflaCount	= 0
	local curingCount	= 0
	
	
	for i, params in pairs( HOSTAGE_DATA_LIST ) do
		local gameObjectId	= GetGameObjectId( params.locatorName )
		local isAllEnable	= false
		
		if DEBUG then
			if svars.isAllHostageEnable == true then
				isAllEnable = true
				
				if params.path then
					this.SpecialAction( gameObjectId, nil, params.path, true )
				end
			end
		end
		
		if isAllEnable == false then
			
			if params.type == UNIQUE_TYPE.VOLGIN then
				
				if this.IsCleardVolgin() == false then
					this.SpecialAction( gameObjectId, false )
				else
					this.SpecialAction( gameObjectId, nil, params.path, nil )
				end
			
			elseif params.type == UNIQUE_TYPE.FOG then
				if mvars.IsSetParasite == true then
					if fogCount < mvars.parasiteFogCount then
						fogCount = fogCount + 1
						this.SpecialAction( gameObjectId, nil, params.path, true )
					else
						this.SpecialAction( gameObjectId, false )
					end
				else
					this.SpecialAction( gameObjectId, false )
				end
			
			elseif params.type == UNIQUE_TYPE.CAMOFLA then
				if mvars.IsSetParasite == true then
					if camoflaCount < mvars.parasiteCamoflaCount then
						camoflaCount = camoflaCount + 1
						this.SpecialAction( gameObjectId, nil, params.path, true )
					else
						this.SpecialAction( gameObjectId, false )
					end
				else
					this.SpecialAction( gameObjectId, false )
				end
			
			elseif params.type == UNIQUE_TYPE.CURING then
				if mvars.IsSetParasite == true then
					if curingCount < mvars.parasiteCuringCount then
						curingCount = curingCount + 1
						this.SpecialAction( gameObjectId, nil, params.path, true )
					else
						this.SpecialAction( gameObjectId, false )
					end
				else
					this.SpecialAction( gameObjectId, false )
				end
			end
		end
	end
end




function this.SpecialAction( gameObjectId, enabled, path, enableDelayMotion )
	
	if enabled ~= nil then
		GameObject.SendCommand( gameObjectId, { id = "SetEnabled", enabled = enabled } )
	end
	
	if path ~= nil then
		GameObject.SendCommand( gameObjectId,
			 {
				id				= "SpecialAction",
				action			= "PlayMotion",
				path			= path,
				autoFinish		= false,
				enableMessage	= true,
				commandId		= Fox.StrCode32("CommandA"),
				enableGravity	= false,
				enableCollision	= false, --rX46 Collision enabled -- nope makes no diff
				enableGroupRate = enableDelayMotion,
			}
		)
	end
end





return this
