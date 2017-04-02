local this={}
local MAX_REALIZED_COUNT=EnemyFova.MAX_REALIZED_COUNT
local UNKlang0=0
local UNKlang1=1
local UNKlang2=2
local UNKlang3=3
local UNKlang4=4
local UNKlang5=5
local UNKlang6=6
local prs2_main0_def_v00PartsAfghan="/Assets/tpp/parts/chara/prs/prs2_main0_def_v00.parts"
local prs5_main0_def_v00PartsAfrica="/Assets/tpp/parts/chara/prs/prs5_main0_def_v00.parts"
local prs3_main0_def_v00PartsAfghanFree="/Assets/tpp/parts/chara/prs/prs3_main0_def_v00.parts"
local prs6_main0_def_v00PartsAfricaFree="/Assets/tpp/parts/chara/prs/prs6_main0_def_v00.parts"
local dds5_main0_def_v00Parts="/Assets/tpp/parts/chara/dds/dds5_main0_def_v00.parts"
--RETAILPATCH 1.10>
local securitySwimSuitBodies={
	female={
		TppEnemyBodyId.dlf_enef0_def,
		TppEnemyBodyId.dlf_enef1_def,
		TppEnemyBodyId.dlf_enef2_def,
		TppEnemyBodyId.dlf_enef3_def,
		TppEnemyBodyId.dlf_enef4_def,
		TppEnemyBodyId.dlf_enef5_def,
		TppEnemyBodyId.dlf_enef6_def,
		TppEnemyBodyId.dlf_enef7_def,
		TppEnemyBodyId.dlf_enef8_def,
		TppEnemyBodyId.dlf_enef9_def,
		TppEnemyBodyId.dlf_enef10_def,
		TppEnemyBodyId.dlf_enef11_def,
	},
	male={
		TppEnemyBodyId.dlf_enem0_def,
		TppEnemyBodyId.dlf_enem1_def,
		TppEnemyBodyId.dlf_enem2_def,
		TppEnemyBodyId.dlf_enem3_def,
		TppEnemyBodyId.dlf_enem4_def,
		TppEnemyBodyId.dlf_enem5_def,
		TppEnemyBodyId.dlf_enem6_def,
		TppEnemyBodyId.dlf_enem7_def,
		TppEnemyBodyId.dlf_enem8_def,
		TppEnemyBodyId.dlf_enem9_def,
		TppEnemyBodyId.dlf_enem10_def,
		TppEnemyBodyId.dlf_enem11_def,
	}
}
--<

--r13 New code to randomize MB staff outfits
local maleSneakingSuit = false
local maleBattleDress = false
local maleTiger = false
local femaleSneakingSuit = false
local femaleBattleDress = false
local femaleTiger = false
local femaleOlive = false
--r42 Beach party mode - all MB staff in bikinis
local beachParty = false

--r51 Settings - Removed missions from table to use ARMOR
local armorUsableTableModded={
	[10010]=1, --Prologue - Awakening
	--  [10020]=1, --Mission 1 - Phantom Limbs
	[10030]=1, --Mission 2 - Flashback Diamond Dogs
	--  [10054]=1, --Mission 9 - Backup Back Down
	--  [11054]=1, --Mission 34 - [Extreme] Backup, Back Down
	--  [10070]=1, --Mission 12 - Hellbound
	--  [10080]=1, --Mission 13 - Pitch Dark
	--  [11080]=1, --Mission 44 - [Total Stealth] Pitch Dark
	--  [10100]=1, --Mission 18 - Blood Runs Deep
	--  [10110]=1, --Mission 20 - Voices
	[10120]=1, --Mission 23 - The White Mamba
	--  [10130]=1, --Mission 28 - Code Talker
	--  [11130]=1, --Mission 48 - [Extreme] Code Talker
	[10140]=1, --Mission 29 - Metallic Archaea
	[11140]=1, --Mission 42 - [Extreme] Metallic Archaea
	[10150]=1, --Mission 30 - Skull Face
	--  [10200]=1, --Mission 25 - Aim True Ye Vengeful
	[11200]=1, --???
	[10280]=1 --Mission 46 - Truth - The Man Who Sold the World
--  ,
--  --r15 Use ARMOR during Free play
--  [30010]=1, -- Afghan Free roam
--  [30020]=1 -- Africa Free roam
}

local armorUsableTable={
	[10010]=1,
	[10020]=1,
	[10030]=1,
	[10054]=1,
	[11054]=1,
	[10070]=1,
	[10080]=1,
	[11080]=1,
	[10100]=1,
	[10110]=1,
	[10120]=1,
	[10130]=1,
	[11130]=1,
	[10140]=1,
	[11140]=1,
	[10150]=1,
	[10200]=1,
	[11200]=1,
	[10280]=1,
	[30010]=1,
	[30020]=1
}

--K this table defines which Missions to use Africa related ARMOR on! You will find that Africa has three PFs with unique ARMOR. Also like Russian ARMOR, PF ARMOR does not appear during Free roam
local pfArmorTypeForMissionsTable={
	[10081]={TppDefine.AFR_ARMOR.TYPE_RC}, --Mission 27 - Root Cause
	[10082]={TppDefine.AFR_ARMOR.TYPE_CFA}, --Mission 15 - Footprints of Phantoms
	[11082]={TppDefine.AFR_ARMOR.TYPE_CFA}, --Mission 36 - [Total Stealth] Footprints of Phantoms
	[10085]={TppDefine.AFR_ARMOR.TYPE_RC}, --Mission 24 - Close Contact
	[11085]={TppDefine.AFR_ARMOR.TYPE_RC}, --Missing???
	[10086]={TppDefine.AFR_ARMOR.TYPE_CFA}, --Mission 14 - Lingua Franca
	[10090]={TppDefine.AFR_ARMOR.TYPE_CFA}, --Mission 16 - Traitors Caravan
	[11090]={TppDefine.AFR_ARMOR.TYPE_CFA}, --Mission 37 - [Extreme] Traitors Caravan
	[10091]={TppDefine.AFR_ARMOR.TYPE_CFA}, --Mission 17 - Rescue the Intel Agents
	[11091]={TppDefine.AFR_ARMOR.TYPE_CFA}, --???
	[10093]={TppDefine.AFR_ARMOR.TYPE_ZRS}, --Mission 35 - Cursed Legacy
	[10121]={TppDefine.AFR_ARMOR.TYPE_CFA}, --Mission 21 - The War Economy
	[11121]={TppDefine.AFR_ARMOR.TYPE_CFA}, --Mission 47 - [Total Stealth] The War Economy
	[10171]={TppDefine.AFR_ARMOR.TYPE_CFA}, --Mission 41 - Proxy War Without End
	[11171]={TppDefine.AFR_ARMOR.TYPE_CFA}, --???
	[10195]={TppDefine.AFR_ARMOR.TYPE_CFA}, --Mission 19 - On the Trail
	[11195]={TppDefine.AFR_ARMOR.TYPE_CFA}, --???
	[10211]={TppDefine.AFR_ARMOR.TYPE_CFA}, --Mission 26 - Hunting Down
	[11211]={TppDefine.AFR_ARMOR.TYPE_CFA} --???
}
local hostageCountForMissionsTable={
	[10020]={count=0},
	[10030]={count=0},
	[10033]={count=1,lang=UNKlang2},
	[11033]={count=1,lang=UNKlang2},
	[10036]={count=0},
	[11036]={count=0},
	[10040]={count=1,lang=UNKlang4},
	[10041]={count=2,lang=UNKlang2},
	[11041]={count=2,lang=UNKlang2},
	[10043]={count=2,lang=UNKlang4},
	[11043]={count=2,lang=UNKlang4},
	[10044]={count=1,lang=UNKlang2,overlap=true},
	[11044]={count=1,lang=UNKlang2,overlap=true},
	[10045]={count=2,lang=UNKlang2},
	[10050]={count=0},
	[11050]={count=0},
	[10052]={count=6,lang=UNKlang6,overlap=true,ignoreList={40,41,42,43,44,45,46,47,48,49},modelNum=5},
	[11052]={count=6,lang=UNKlang6,overlap=true,ignoreList={40,41,42,43,44,45,46,47,48,49},modelNum=5},
	[10054]={count=4,lang=UNKlang1,overlap=true},
	[11054]={count=4,lang=UNKlang1,overlap=true},
	[10070]={count=0},
	[10080]={count=0},
	[11080]={count=0},
	[10081]={count=0},
	[10082]={count=2,lang=UNKlang5,overlap=true},
	[11082]={count=2,lang=UNKlang5,overlap=true},
	[10085]={count=0},
	[11085]={count=0},
	[10086]={count=0},
	[10090]={count=0},
	[11090]={count=0},
	[10091]={count=1,lang=UNKlang1,useHair=true,overlap=true},
	[11091]={count=1,lang=UNKlang1,useHair=true,overlap=true},
	[10093]={count=0},
	[10100]={count=0},
	[10110]={count=0},
	[10115]={count=0},
	[11115]={count=0},
	[10120]={count=1,lang=UNKlang1,overlap=true},
	[10121]={count=0},
	[11121]={count=0},
	[10130]={count=0},
	[11130]={count=0},
	[10140]={count=0},
	[11140]={count=0},
	[10145]={count=0},
	[10150]={count=0},
	[10151]={count=0},
	[11151]={count=0},
	[10171]={count=0},
	[11171]={count=0},
	[10156]={count=1,lang=UNKlang2,overlap=true},
	[10195]={count=1,lang=UNKlang5},
	[11195]={count=1,lang=UNKlang5},
	[10200]={count=1,lang=UNKlang5},
	[11200]={count=1,lang=UNKlang5},
	[10240]={count=0},
	[10211]={count=4,lang=UNKlang3,overlap=true},
	[11211]={count=4,lang=UNKlang4,overlap=true},
	[10260]={count=0},
	[10280]={count=0}
}
this.S10030_FaceIdList={78,200,283,30,88,124,138,169,213,222,243,264,293,322,343}
this.S10030_useBalaclavaNum=3
this.S10240_FemaleFaceIdList={394,351,373,456,463,455,511,502}
this.S10240_MaleFaceIdList={195,144,214,6,217,83,273,60,87,71,256,201,290,178,102,255,293,165,85,18,228,12,65,134,31,132,161,342,107,274,184,226,153,247,344,242,56,183,54,126,223}

local fovaSetupFunctions={}
local function ApplyCaseOnPassedTable(anyTable)
	--rX46 Finally understood this crap

	--rX46 This is a switch case applied *on* the table passed to this function
	function anyTable:case(areaName,nextMissionCode)
		--self is like a pointer to the table anyTable
		-- so self[areaName] checks for anyTable.areaName and assigns the function 'anyTable.areaName' to selectedFuncOf_fovaSetupFunctions
		-- otherwise 'anyTable.default' function is assigned - obviously every case has to be custom written(I think)
		--selectedFuncOf_fovaSetupFunctions is called by passing areaName and nextMissionCode
		local selectedFuncOf_fovaSetupFunctions=self[areaName] or self.default
		if selectedFuncOf_fovaSetupFunctions then
			selectedFuncOf_fovaSetupFunctions(areaName,nextMissionCode)
		end
	end

	--SelectFovaSetupFunction simply returns the case(areaName,nextMissionCode) function added to the fovaFuncsTable
	--At this point the table has had the case applied to it, which can then be used to switch cases
	return anyTable
end

--r51 Settings
local function pickArmorUsableTable()
	if TUPPMSettings.rev_ENABLE_ARMORInExtraMissions then
			return armorUsableTableModded
		else
			return armorUsableTable
		end
end
function this.IsNotRequiredArmorSoldier(e)
	--r51 Settings
	local armorTableToUse = pickArmorUsableTable()
	if armorTableToUse[e]~=nil then
		return true
	end
	return false
end
function this.CanUseArmorType(missionCode,soldierSubType)
	local pfArmorTypes={PF_A=TppDefine.AFR_ARMOR.TYPE_CFA,PF_B=TppDefine.AFR_ARMOR.TYPE_ZRS,PF_C=TppDefine.AFR_ARMOR.TYPE_RC}
	local e=pfArmorTypes[soldierSubType]
	if e==nil then
		return true
	end
	local a=this.GetArmorTypeTable(missionCode)
	for n,a in ipairs(a)do
		if a==e then
			return true
		end
	end
	return false
end
function this.GetHostageCountAtMissionId(e)
	local a=0
	if hostageCountForMissionsTable[e]~=nil then
		local e=hostageCountForMissionsTable[e]
		if e~=nil then
			if e.count~=nil then
				return e.count
			else
				return a
			end
		else
			return a
		end
	end
	return a
end
function this.GetHostageLangAtMissionId(e)
	local a=UNKlang1
	if hostageCountForMissionsTable[e]~=nil then
		local e=hostageCountForMissionsTable[e]
		if e~=nil then
			if e.lang~=nil then
				return e.lang
			end
		end
	end
	return a
end
function this.GetHostageUseHairAtMissionId(e)
	local a=false
	if hostageCountForMissionsTable[e]~=nil then
		local e=hostageCountForMissionsTable[e]
		if e~=nil then
			if e.useHair~=nil then
				return e.useHair
			end
		end
	end
	return a
end
function this.GetHostageIsFaceModelOverlap(e)
	local a=false
	if hostageCountForMissionsTable[e]~=nil then
		local e=hostageCountForMissionsTable[e]
		if e~=nil then
			if e.overlap~=nil then
				return e.overlap
			end
		end
	end
	return a
end
function this.GetHostageFaceModelCount(e)
	local a=2
	if hostageCountForMissionsTable[e]~=nil then
		local e=hostageCountForMissionsTable[e]
		if e~=nil then
			if e.modelNum~=nil then
				return e.modelNum
			end
		end
	end
	return a
end
function this.GetHostageIgnoreFaceList(e)
	local a={}
	if hostageCountForMissionsTable[e]~=nil then
		local e=hostageCountForMissionsTable[e]
		if e~=nil then
			if e.ignoreList~=nil then
				return e.ignoreList
			end
		end
	end
	return a
end
function this.GetArmorTypeTable(e)
	if this.IsNotRequiredArmorSoldier(e)then
		return{}
	end
	if not TppLocation.IsMiddleAfrica()then
		return{}
	end
	local a={TppDefine.AFR_ARMOR.TYPE_ZRS} --r28 update 1090
	--r28 update 1090
	--r51 Settings
	if TUPPMSettings.rev_ENABLE_ARMORInExtraMissions then
		a={
			TppDefine.AFR_ARMOR.TYPE_CFA,
			TppDefine.AFR_ARMOR.TYPE_ZRS,
			TppDefine.AFR_ARMOR.TYPE_RC
		}
	end
	if pfArmorTypeForMissionsTable[e]~=nil then
		local e=pfArmorTypeForMissionsTable[e]
		if e~=nil then
			return e
		end
	end
	return a
end
function this.SetHostageFaceTable(o)
	local s=this.GetHostageCountAtMissionId(o)
	local t=this.GetHostageLangAtMissionId(o)
	local c=0
	if s>0 then
		local n={}
		if t==UNKlang1 then
			table.insert(n,3)
			local e=bit.rshift(gvars.hosface_groupNumber,8)%100
			if e<40 then
				table.insert(n,0)
			end
		elseif t==UNKlang2 then
			table.insert(n,0)
		elseif t==UNKlang5 then
			table.insert(n,2)
			local e=bit.rshift(gvars.hosface_groupNumber,8)%100
			if e<10 then
				table.insert(n,0)
			end
		elseif t==UNKlang6 then
			table.insert(n,0)table.insert(n,1)c=1
		elseif t==UNKlang4 then
			table.insert(n,1)
		elseif t==UNKlang3 then
			table.insert(n,2)
		else
			if TppLocation.IsAfghan()then
				table.insert(n,0)
			elseif TppLocation.IsMiddleAfrica()then
				table.insert(n,2)
			elseif TppLocation.IsMotherBase()then
				table.insert(n,0)
			elseif TppLocation.IsMBQF()then
				table.insert(n,0)
			elseif TppLocation.IsCyprus()then
				table.insert(n,0)
			end
		end
		local _=this.GetHostageIsFaceModelOverlap(o)
		local r=this.GetHostageIgnoreFaceList(o)
		local T=this.GetHostageFaceModelCount(o)
		local r=TppSoldierFace.CreateFaceTable{race=n,needCount=s,maxUsedFovaCount=T,faceModelOverlap=_,ignoreFaceList=r,raceHalfMode=c}
		if r~=nil then
			local d={}
			local t={}
			local n=#r
			local a=MAX_REALIZED_COUNT
			if s<=n then
				a=1
			end
			if(n>0)and(n<s)then
				a=math.floor(s/n)+1
			end
			if a<=0 then
				a=MAX_REALIZED_COUNT
			end
			for n,e in ipairs(r)do
				table.insert(d,{e,0,0,a})table.insert(t,e)
			end
			local e=#t
			if e>0 then
				local e=gvars.hosface_groupNumber
				TppSoldierFace.SetPoolTable{hostageFace=t,randomSeed=e}
			end
			TppSoldierFace.OverwriteMissionFovaData{face=d}
		else
			local a={}
			local n=gvars.hosface_groupNumber%9
			if t==UNKlang1 then
				table.insert(a,{25+n,0,0,MAX_REALIZED_COUNT})
			elseif t==UNKlang2 then
				table.insert(a,{100+n,0,0,MAX_REALIZED_COUNT})
			elseif t==UNKlang5 then
				table.insert(a,{210+n,0,0,MAX_REALIZED_COUNT})
			elseif t==UNKlang4 then
				table.insert(a,{9+n,0,0,MAX_REALIZED_COUNT})
			elseif t==UNKlang3 then
				table.insert(a,{260+n,0,0,MAX_REALIZED_COUNT})
			else
				table.insert(a,{55+n,0,0,MAX_REALIZED_COUNT})
			end
			TppSoldierFace.OverwriteMissionFovaData{face=a}
		end
		local e=this.GetHostageUseHairAtMissionId(o)
		if e==true then
			TppSoldierFace.SetHostageUseHairFova(true)
		end
	end
end

function this.GetFaceGroupTableAtGroupType(e)
	local t=TppEnemyFaceGroup.GetFaceGroupTable(e)
	local e={}
	local a=EnemyFova.MAX_REALIZED_COUNT
	for t,n in pairs(t)do
		table.insert(e,{n,a,a,0})
	end

	--rX44 CHEAT All female faces at least to recruit females - broken faces but does its job well enough
	--  e={}
	--  local allFaceIdsTable={}
	--  allFaceIdsTable=this.GetAllFaceIds(this.femaleFaceIds)
	--  if #allFaceIdsTable~=0 then
	--    for i, faceId in pairs(allFaceIdsTable) do
	--      table.insert(e,{faceId,a,a,0})
	----      TUPPMLog.Log("Adding female face ID: "..tostring(faceId))
	--    end
	--  end

	return e
end
fovaSetupFunctions[10200]=function(d,t)
	this.SetHostageFaceTable(t)
	local e={{TppEnemyBodyId.chd0_v00,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v01,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v02,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v03,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v04,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v05,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v06,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v07,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v08,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v09,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v10,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v11,MAX_REALIZED_COUNT},{TppEnemyBodyId.prs5_main0_v00,MAX_REALIZED_COUNT}}
	TppSoldierFace.OverwriteMissionFovaData{body=e}
	TppSoldierFace.SetBodyFovaUserType{hostage={TppEnemyBodyId.prs5_main0_v00}}
	TppHostage2.SetDefaultBodyFovaId{parts=prs5_main0_def_v00PartsAfrica,bodyId=TppEnemyBodyId.prs5_main0_v00}
end
fovaSetupFunctions[11200]=fovaSetupFunctions[10200]
fovaSetupFunctions[10120]=function(d,t)
	this.SetHostageFaceTable(t)
	local e={{TppEnemyBodyId.chd0_v00,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v01,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v02,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v03,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v04,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v05,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v06,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v07,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v08,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v09,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v10,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v11,MAX_REALIZED_COUNT},{TppEnemyBodyId.prs5_main0_v00,MAX_REALIZED_COUNT}}
	TppSoldierFace.OverwriteMissionFovaData{body=e}
	TppSoldierFace.SetBodyFovaUserType{hostage={TppEnemyBodyId.prs5_main0_v00}}
	TppHostage2.SetDefaultBodyFovaId{parts=prs5_main0_def_v00PartsAfrica,bodyId=TppEnemyBodyId.prs5_main0_v00}
end
fovaSetupFunctions[10040]=function(e,a)
	local fovaSetupFunctionsWithCaseApplied=ApplyCaseOnPassedTable(fovaSetupFunctions)
	fovaSetupFunctionsWithCaseApplied:case("Afghan",a)
	TppSoldierFace.SetUseZombieFova{enabled=true}
end
fovaSetupFunctions[10045]=function(e,a)
	local fovaSetupFunctionsWithCaseApplied=ApplyCaseOnPassedTable(fovaSetupFunctions)
	fovaSetupFunctionsWithCaseApplied:case("Afghan",a)
	local e={}
	for a=0,9 do
		table.insert(e,a)
	end
	for a=20,39 do
		table.insert(e,a)
	end
	for a=50,81 do
		table.insert(e,a)
	end
	for a=93,199 do
		table.insert(e,a)
	end
	local a=#e
	local a=gvars.hosface_groupNumber%a
	local e=e[a]
	local a={{TppEnemyFaceId.svs_balaclava,1,1,0},{e,1,1,0}}
	TppSoldierFace.OverwriteMissionFovaData{face=a,additionalMode=true}
	local a=274
	TppSoldierFace.SetSpecialFovaId{face={e},body={a}}
	local e={{a,1}}
	TppSoldierFace.OverwriteMissionFovaData{body=e,additionalMode=true}
end
fovaSetupFunctions[10052]=function(a,e)
	local fovaSetupFunctionsWithCaseApplied=ApplyCaseOnPassedTable(fovaSetupFunctions)
	fovaSetupFunctionsWithCaseApplied:case("Afghan",e)
	TppSoldierFace.SetSplitRaceForHostageRandomFaceId{enabled=true}
end
fovaSetupFunctions[11052]=fovaSetupFunctions[10052]
fovaSetupFunctions[10090]=function(a,e)
	local fovaSetupFunctionsWithCaseApplied=ApplyCaseOnPassedTable(fovaSetupFunctions)
	fovaSetupFunctionsWithCaseApplied:case("Africa",e)
	TppSoldierFace.SetUseZombieFova{enabled=true}
end
fovaSetupFunctions[11090]=fovaSetupFunctions[10090]
fovaSetupFunctions[10091]=function(e,a)
	local fovaSetupFunctionsWithCaseApplied=ApplyCaseOnPassedTable(fovaSetupFunctions)
	fovaSetupFunctionsWithCaseApplied:case("Africa",a)
	local e={}
	for a=0,9 do
		table.insert(e,a)
	end
	for a=20,39 do
		table.insert(e,a)
	end
	for a=50,81 do
		table.insert(e,a)
	end
	for a=93,199 do
		table.insert(e,a)
	end
	local t=#e
	local d=gvars.solface_groupNumber%t
	local a=gvars.hosface_groupNumber%t
	if d==a then
		a=(a+1)%t
	end
	local t=e[d]
	local e=e[a]
	local a={{TppEnemyFaceId.pfs_balaclava,2,2,0},{t,1,1,0},{e,1,1,0}}
	TppSoldierFace.OverwriteMissionFovaData{face=a,additionalMode=true}
	local d=265
	local a=266
	TppSoldierFace.SetSpecialFovaId{face={t,e},body={d,a}}
	local e={{d,1},{a,1}}
	TppSoldierFace.OverwriteMissionFovaData{body=e,additionalMode=true}
end
fovaSetupFunctions[11091]=fovaSetupFunctions[10091]
fovaSetupFunctions[10080]=function(a,t)
	local fovaSetupFunctionsWithCaseApplied=ApplyCaseOnPassedTable(fovaSetupFunctions)
	fovaSetupFunctionsWithCaseApplied:case("Africa",t)
	if TppPackList.IsMissionPackLabel"afterPumpStopDemo"then
	else
		TppSoldier2.SetExtendPartsInfo{type=2,path="/Assets/tpp/parts/chara/chd/chd0_main0_def_v00.parts"}
		local e={{TppEnemyBodyId.chd0_v00,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v01,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v02,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v03,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v04,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v05,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v06,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v07,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v08,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v09,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v10,MAX_REALIZED_COUNT},{TppEnemyBodyId.chd0_v11,MAX_REALIZED_COUNT}}
		TppSoldierFace.OverwriteMissionFovaData{body=e}
	end
end
fovaSetupFunctions[11080]=fovaSetupFunctions[10080]
fovaSetupFunctions[10115]=function(a,a)
	local a={}
	for e=0,9 do
		table.insert(a,e)
	end
	for e=20,39 do
		table.insert(a,e)
	end
	for e=50,81 do
		table.insert(a,e)
	end
	for e=93,199 do
		table.insert(a,e)
	end
	local t=gvars.hosface_groupNumber
	TppSoldierFace.SetPoolTable{face=a,randomSeed=t}
	TppSoldierFace.SetSoldierNoFaceResourceMode(true)
	TppSoldierFace.SetUseFaceIdListMode{enabled=true,staffCheck=true}
	local e={{140,MAX_REALIZED_COUNT},{141,MAX_REALIZED_COUNT},{TppEnemyBodyId.dds5_main0_v00,MAX_REALIZED_COUNT}}
	TppSoldierFace.SetBodyFovaUserType{hostage={TppEnemyBodyId.dds5_main0_v00}}
	TppHostage2.SetDefaultBodyFovaId{parts=dds5_main0_def_v00Parts,bodyId=TppEnemyBodyId.dds5_main0_v00}
	TppSoldierFace.OverwriteMissionFovaData{body=e}
end
fovaSetupFunctions[11115]=fovaSetupFunctions[10115]
fovaSetupFunctions[10130]=function(e,a)
	local fovaSetupFunctionsWithCaseApplied=ApplyCaseOnPassedTable(fovaSetupFunctions)
	fovaSetupFunctionsWithCaseApplied:case("Africa",a)
	TppSoldierFace.SetUseZombieFova{enabled=true}
end
fovaSetupFunctions[11130]=fovaSetupFunctions[10130]
fovaSetupFunctions[10140]=function(a,e)
	local fovaSetupFunctionsWithCaseApplied=ApplyCaseOnPassedTable(fovaSetupFunctions)
	fovaSetupFunctionsWithCaseApplied:case("Africa",e)
	TppSoldierFace.SetUseZombieFova{enabled=true}
end
fovaSetupFunctions[11140]=fovaSetupFunctions[10140]
fovaSetupFunctions[10150]=function(a,a)
	local a={}
	for e=0,9 do
		table.insert(a,e)
	end
	for e=20,39 do
		table.insert(a,e)
	end
	for e=50,81 do
		table.insert(a,e)
	end
	for e=93,199 do
		table.insert(a,e)
	end
	local t=gvars.hosface_groupNumber
	TppSoldierFace.SetPoolTable{face=a,randomSeed=t}
	TppSoldierFace.SetSoldierNoFaceResourceMode(true)
	TppSoldierFace.SetUseFaceIdListMode{enabled=true,staffCheck=true}
	local e={{TppEnemyBodyId.wss4_main0_v00,MAX_REALIZED_COUNT}}
	TppSoldierFace.OverwriteMissionFovaData{body=e}
end
fovaSetupFunctions[10151]=function(e,e)
end
fovaSetupFunctions[11151]=fovaSetupFunctions[10151]
fovaSetupFunctions[30010]=function(a,t)
	local fovaSetupFunctionsWithCaseApplied=ApplyCaseOnPassedTable(fovaSetupFunctions)
	fovaSetupFunctionsWithCaseApplied:case("Afghan",t)
	TppSoldierFace.SetUseZombieFova{enabled=true}
	local e={{TppEnemyBodyId.prs3_main0_v00,MAX_REALIZED_COUNT}}
	TppSoldierFace.OverwriteMissionFovaData{body=e}
	TppSoldierFace.SetBodyFovaUserType{hostage={TppEnemyBodyId.prs3_main0_v00}}
	TppHostage2.SetDefaultBodyFovaId{parts=prs3_main0_def_v00PartsAfghanFree,bodyId=TppEnemyBodyId.prs3_main0_v00}
end
fovaSetupFunctions[30020]=function(a,t)
	local fovaSetupFunctionsWithCaseApplied=ApplyCaseOnPassedTable(fovaSetupFunctions)
	fovaSetupFunctionsWithCaseApplied:case("Africa",t)
	TppSoldierFace.SetUseZombieFova{enabled=true}
	local e={{TppEnemyBodyId.prs6_main0_v00,MAX_REALIZED_COUNT}}
	TppSoldierFace.OverwriteMissionFovaData{body=e}
	TppSoldierFace.SetBodyFovaUserType{hostage={TppEnemyBodyId.prs6_main0_v00}}
	TppHostage2.SetDefaultBodyFovaId{parts=prs6_main0_def_v00PartsAfricaFree,bodyId=TppEnemyBodyId.prs6_main0_v00}
end
function fovaSetupFunctions.Afghan(areaName,nextMissionCode)
	if nextMissionCode==10010 then
		return
	end
	local d=0
	if TppSoldierFace.IsMoreVariationMode~=nil then
		d=TppSoldierFace.IsMoreVariationMode()
	end
	local o=15
	local n=gvars.solface_groupNumber%o
	local l=TppEnemyFaceGroupId.AFGAN_GRP_00+n
	local l=this.GetFaceGroupTableAtGroupType(l)
	TppSoldierFace.OverwriteMissionFovaData{face=l}
	if d>0 then
		for e=1,2 do
			n=n+2
			local e=(n%o)*2
			local e=TppEnemyFaceGroupId.AFGAN_GRP_00+(e)
			local e=this.GetFaceGroupTableAtGroupType(e)
			TppSoldierFace.OverwriteMissionFovaData{face=e}
		end
	end
	TppSoldierFace.SetUseFaceIdListMode{enabled=true,staffCheck=true}this.SetHostageFaceTable(nextMissionCode)
	local bodies={{0,MAX_REALIZED_COUNT},{1,MAX_REALIZED_COUNT},{2,MAX_REALIZED_COUNT},{5,MAX_REALIZED_COUNT},{6,MAX_REALIZED_COUNT},{7,MAX_REALIZED_COUNT},{10,MAX_REALIZED_COUNT},{11,MAX_REALIZED_COUNT},{20,MAX_REALIZED_COUNT},{21,MAX_REALIZED_COUNT},{22,MAX_REALIZED_COUNT},{25,MAX_REALIZED_COUNT},{26,MAX_REALIZED_COUNT},{27,MAX_REALIZED_COUNT},{30,MAX_REALIZED_COUNT},{31,MAX_REALIZED_COUNT},{TppEnemyBodyId.prs2_main0_v00,MAX_REALIZED_COUNT}}
	if not this.IsNotRequiredArmorSoldier(nextMissionCode)then
		local e={TppEnemyBodyId.sva0_v00_a,MAX_REALIZED_COUNT}table.insert(bodies,e)
	end
	--r43 Adding wildcard soldiers
	this.UseWildcardSoldiers(bodies)
	TppSoldierFace.OverwriteMissionFovaData{body=bodies}
	TppSoldierFace.SetBodyFovaUserType{hostage={TppEnemyBodyId.prs2_main0_v00}}
	TppHostage2.SetDefaultBodyFovaId{parts=prs2_main0_def_v00PartsAfghan,bodyId=TppEnemyBodyId.prs2_main0_v00}
end
function fovaSetupFunctions.Africa(areaName,nextMissionCode)
	local o=0
	if TppSoldierFace.IsMoreVariationMode~=nil then
		o=TppSoldierFace.IsMoreVariationMode()
	end
	local t=30
	local n=gvars.solface_groupNumber
	local d=(n%t)*2
	local l=TppEnemyFaceGroupId.AFRICA_GRP000_B+(d)
	local i=this.GetFaceGroupTableAtGroupType(l)
	TppSoldierFace.OverwriteMissionFovaData{face=i}
	if o>0 then
		for e=1,2 do
			n=n+2
			local e=(n%t)*2
			local e=TppEnemyFaceGroupId.AFRICA_GRP000_B+(e)
			local e=this.GetFaceGroupTableAtGroupType(e)
			TppSoldierFace.OverwriteMissionFovaData{face=e}
		end
	end
	t=30
	n=gvars.solface_groupNumber
	d=(n%t)*2
	l=TppEnemyFaceGroupId.AFRICA_GRP000_W+(d)
	local d=this.GetFaceGroupTableAtGroupType(l)
	TppSoldierFace.OverwriteMissionFovaData{face=d}
	if o>0 then
		for e=1,2 do
			n=n+2
			local e=(n%t)*2
			local e=TppEnemyFaceGroupId.AFRICA_GRP000_W+(e)
			local e=this.GetFaceGroupTableAtGroupType(e)
			TppSoldierFace.OverwriteMissionFovaData{face=e}
		end
	end
	this.SetHostageFaceTable(nextMissionCode)
	TppSoldierFace.SetUseFaceIdListMode{enabled=true,staffCheck=true,raceSplit=60}
	local bodies={{50,MAX_REALIZED_COUNT},{51,MAX_REALIZED_COUNT},{55,MAX_REALIZED_COUNT},{60,MAX_REALIZED_COUNT},{61,MAX_REALIZED_COUNT},{70,MAX_REALIZED_COUNT},{71,MAX_REALIZED_COUNT},{75,MAX_REALIZED_COUNT},{80,MAX_REALIZED_COUNT},{81,MAX_REALIZED_COUNT},{90,MAX_REALIZED_COUNT},{91,MAX_REALIZED_COUNT},{95,MAX_REALIZED_COUNT},{100,MAX_REALIZED_COUNT},{101,MAX_REALIZED_COUNT},{TppEnemyBodyId.prs5_main0_v00,MAX_REALIZED_COUNT}}
	local a=this.GetArmorTypeTable(nextMissionCode)
	if a~=nil then
		local t=#a
		if t>0 then
			for t,a in ipairs(a)do
				if a==TppDefine.AFR_ARMOR.TYPE_ZRS then
					table.insert(bodies,{TppEnemyBodyId.pfa0_v00_a,MAX_REALIZED_COUNT})
				elseif a==TppDefine.AFR_ARMOR.TYPE_CFA then
					table.insert(bodies,{TppEnemyBodyId.pfa0_v00_b,MAX_REALIZED_COUNT})
				elseif a==TppDefine.AFR_ARMOR.TYPE_RC then
					table.insert(bodies,{TppEnemyBodyId.pfa0_v00_c,MAX_REALIZED_COUNT})
				else
					table.insert(bodies,{TppEnemyBodyId.pfa0_v00_a,MAX_REALIZED_COUNT})
				end
			end
		end
	end
	--r43 Adding wildcard soldiers
	this.UseWildcardSoldiers(bodies)
	TppSoldierFace.OverwriteMissionFovaData{body=bodies}
	TppSoldierFace.SetBodyFovaUserType{hostage={TppEnemyBodyId.prs5_main0_v00}}
	TppHostage2.SetDefaultBodyFovaId{parts=prs5_main0_def_v00PartsAfrica,bodyId=TppEnemyBodyId.prs5_main0_v00}
end
function fovaSetupFunctions.Mbqf(areaName,nextMissionCode)
	--	TUPPMLog.Log("missionSpecailFova.Mbqf",3) --Used for M43 exclusively
	TppSoldierFace.SetSoldierOutsideFaceMode(false)
	TppSoldier2.SetDisableMarkerModelEffect{enabled=true}
	local t={}
	local n={}
	if TppStory.GetCurrentStorySequence()<TppDefine.STORY_SEQUENCE.CLEARD_MURDER_INFECTORS then
		local e,a=TppMotherBaseManagement.GetStaffsS10240()
		for a,e in pairs(e)do
			local e=TppMotherBaseManagement.StaffIdToFaceId{staffId=e}
			if n[e]==nil then
				n[e]=2
			else
				n[e]=n[e]+1
			end
		end
		for a,e in pairs(a)do
			local e=TppMotherBaseManagement.StaffIdToFaceId{staffId=e}
			if n[e]==nil then
				n[e]=2
			else
				n[e]=n[e]+1
			end
		end
	else
		for e,t in ipairs(this.S10240_MaleFaceIdList)do
			local e=this.S10240_MaleFaceIdList[e]
			if n[e]==nil then
				n[e]=2
			else
				n[e]=n[e]+1
			end
		end
		for e,t in ipairs(this.S10240_FemaleFaceIdList)do
			local e=this.S10240_FemaleFaceIdList[e]
			if n[e]==nil then
				n[e]=2
			else
				n[e]=n[e]+1
			end
		end
	end
	for a,e in pairs(n)do
		table.insert(t,{a,e,e,0})
	end
	table.insert(t,{623,1,1,0})table.insert(t,{TppEnemyFaceId.dds_balaclava2,10,10,0})table.insert(t,{TppEnemyFaceId.dds_balaclava6,2,2,0})table.insert(t,{TppEnemyFaceId.dds_balaclava7,2,2,0})
	local e={{146,MAX_REALIZED_COUNT},{147,MAX_REALIZED_COUNT},{148,MAX_REALIZED_COUNT},{149,MAX_REALIZED_COUNT},{150,MAX_REALIZED_COUNT},{151,1},{152,MAX_REALIZED_COUNT},{153,MAX_REALIZED_COUNT},{154,MAX_REALIZED_COUNT},{155,MAX_REALIZED_COUNT},{156,MAX_REALIZED_COUNT},{157,MAX_REALIZED_COUNT},{158,MAX_REALIZED_COUNT}}
	TppSoldier2.SetExtendPartsInfo{type=1,path="/Assets/tpp/parts/chara/dds/ddr1_main0_def_v00.parts"}
	TppSoldierFace.OverwriteMissionFovaData{face=t,body=e}
	TppSoldierFace.SetSoldierUseHairFova(true)
end

function fovaSetupFunctions.Mb(areaName,nextMissionCode)
	if TppMission.IsHelicopterSpace(nextMissionCode)then
		return
	end
	TppSoldierFace.SetSoldierOutsideFaceMode(false)
	local faces={} --r28 update 1090
	local ddSuit=TppEnemy.GetDDSuit() --r28 update 1090

	--r28 Outfits for MB staff
	--r51 Settings
	if TUPPMSettings.mtbs_ENABLE_randomMBStaffOutfits and (vars.missionCode==30050 or vars.missionCode==30250) then
		--IMP remember, this is not called again unless forced, so while loading checkpoints, soldier names do change on MB/MBQF but
		-- outfits do not!

		TUPPMLog.Log("missionSpecailFova.Mb Randomizing outfits",3)
		--r42 Random MB Staff outfits
		maleSneakingSuit = false
		maleBattleDress = false
		maleTiger = false

		femaleSneakingSuit = false
		femaleBattleDress = false
		femaleTiger = false
		femaleOlive = false

		--r42 Beach party mode
		beachParty = false

		local isSneakingSuitDeveloped = TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=19050}
		local isBattleDressDeveloped = TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=19053}

		TppMain.Randomize()

		--MALES
		local randomVariable = math.random()
		if isSneakingSuitDeveloped and randomVariable<0.333333 then
			maleSneakingSuit = true
			TppMain.Randomize()
		elseif isBattleDressDeveloped and randomVariable<0.666667 then
			maleBattleDress = true
			TppMain.Randomize()
		else
			maleTiger = true
			TppMain.Randomize()
		end

		math.randomseed(os.time())
		TppMain.Randomize()

		--FEMALES
		randomVariable = math.random()
		if isSneakingSuitDeveloped and randomVariable<0.25 then
			femaleSneakingSuit = true
			TppMain.Randomize()
		elseif isBattleDressDeveloped and randomVariable<0.5 then
			femaleBattleDress = true
			TppMain.Randomize()
		elseif randomVariable<0.75 then
			femaleTiger = true
			TppMain.Randomize()
		else
			femaleOlive = true
			TppMain.Randomize()
		end

		--r42 Beach party mode - Only if at least one Swimsuit has been developed
		--r57 Always use swimsuit on MB for Staff. mtbs_ENABLE_randomMBStaffOutfits has to be true
		if
			TUPPMSettings.mtbs_ENABLE_alwaysUseSwimsuitsOnMB or
			(
				(
					TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=19151} or
					TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=19152} or
					TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=19153} or
					TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=19154} or
					TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=19155} or
					TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=19156} or
					TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=19157} or
					TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=19158} or
					TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=19159} or
					TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=19160} or
					TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=19161} or
					TppMotherBaseManagement.IsEquipDevelopedFromDevelopID{equipDevelopID=19162}
				)
				and math.random()<0.15
			)
		then
			beachParty = true
			TppMain.Randomize()
		end

		math.randomseed(os.time())
		TppMain.Randomize()

		--rX43 DEBUG - straight forward combinations
		--    local setMale=0
		--    local setFemale=0
		--
		--    if setMale~=0 then
		--      maleSneakingSuit = false
		--      maleBattleDress = false
		--      maleTiger = false
		--
		--      if setMale==1 then
		--        maleSneakingSuit = true
		--      end
		--      if setMale==2 then
		--        maleBattleDress = true
		--      end
		--      if setMale==3 then
		--        maleTiger = true
		--      end
		--    end
		--
		--    if setFemale~=0 then
		--      femaleSneakingSuit = false
		--      femaleBattleDress = false
		--      femaleTiger = false
		--      femaleOlive = false
		--
		--      if setFemale==1 then
		--        femaleSneakingSuit = true
		--      end
		--      if setFemale==2 then
		--        femaleBattleDress = true
		--      end
		--      if setFemale==3 then
		--        femaleTiger = true
		--      end
		--      if setFemale==4 then
		--        femaleOlive = true
		--      end
		--    end

		--DEBUG rX42
		--    beachParty = true


	end


	if TppMission.IsFOBMission(nextMissionCode)then
		local l=TppMotherBaseManagement.GetStaffsFob()
		local d=36
		local i=100
		local n={}
		local p={}do
			for a,e in pairs(l)do
				local e=TppMotherBaseManagement.StaffIdToFaceId{staffId=e}
				if n[e]==nil then
					n[e]=1
				else
					n[e]=n[e]+1
				end
				if a==d then
					break
				end
			end
			if#l==0 then
				for e=1,d do
					n[e]=1
				end
			end
			for a,e in pairs(n)do
				table.insert(faces,{a,e,e,0})
			end
		end
		do
			for e=d+1,d+i do
				local a=l[e]
				if a==nil then
					break
				end
				local a=TppMotherBaseManagement.StaffIdToFaceId{staffId=a}
				if n[a]==nil then
					p[a]=1
				end
				if e==i then
					break
				end
			end
			for e,a in pairs(p)do
				table.insert(faces,{e,0,0,0})
			end
		end
		local n={}
		if ddSuit==TppEnemy.FOB_DD_SUIT_SNEAKING then
			TppSoldier2.SetDefaultPartsPath"/Assets/tpp/parts/chara/sna/sna4_enem0_def_v00.parts"table.insert(n,{TppEnemyFaceId.dds_balaclava0,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})table.insert(n,{TppEnemyFaceId.dds_balaclava1,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})table.insert(n,{TppEnemyFaceId.dds_balaclava12,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})table.insert(n,{TppEnemyFaceId.dds_balaclava3,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})table.insert(n,{TppEnemyFaceId.dds_balaclava4,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})table.insert(n,{TppEnemyFaceId.dds_balaclava14,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})
		elseif ddSuit==TppEnemy.FOB_DD_SUIT_BTRDRS then
			TppSoldier2.SetDefaultPartsPath"/Assets/tpp/parts/chara/sna/sna5_enem0_def_v00.parts"table.insert(n,{TppEnemyFaceId.dds_balaclava0,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})table.insert(n,{TppEnemyFaceId.dds_balaclava1,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})table.insert(n,{TppEnemyFaceId.dds_balaclava12,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})table.insert(n,{TppEnemyFaceId.dds_balaclava3,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})table.insert(n,{TppEnemyFaceId.dds_balaclava4,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})table.insert(n,{TppEnemyFaceId.dds_balaclava14,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})
		elseif ddSuit==TppEnemy.FOB_PF_SUIT_ARMOR then
			TppSoldier2.SetDefaultPartsPath"/Assets/tpp/parts/chara/pfs/pfs0_main0_def_v00.parts"else
			TppSoldier2.SetDefaultPartsPath"/Assets/tpp/parts/chara/dds/dds5_enem0_def_v00.parts"table.insert(n,{TppEnemyFaceId.dds_balaclava0,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})table.insert(n,{TppEnemyFaceId.dds_balaclava2,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})table.insert(n,{TppEnemyFaceId.dds_balaclava3,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})table.insert(n,{TppEnemyFaceId.dds_balaclava5,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})
		end
		if this.IsUseGasMaskInFOB()then
			n={{TppEnemyFaceId.dds_balaclava8,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0},{TppEnemyFaceId.dds_balaclava9,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0},{TppEnemyFaceId.dds_balaclava10,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0},{TppEnemyFaceId.dds_balaclava11,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0},{TppEnemyFaceId.dds_balaclava13,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0},{TppEnemyFaceId.dds_balaclava15,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0}}
		end
		--RETAILPATCH 1.10>
		if TppMotherBaseManagement.GetMbsClusterSecurityIsEquipSwimSuit()then
			TppSoldier2.SetDefaultPartsPath"/Assets/tpp/parts/chara/dlf/dlf1_enem0_def_v00.parts"
		end
		--<
		for a,e in ipairs(n)do
			table.insert(faces,e)
		end
	else
		if nextMissionCode==30050 then
			--r42 Random MB Staff outfits
			local faceIdsTable={}
			--Loading one single parts pack is enough for the game to decide male fovas - female fovas not loaded here
			if maleSneakingSuit then
				-- Balacalava fova parts path needs to be initialized but if the balacalava is not found, no face mask is loaded
				TppSoldier2.SetDefaultPartsPath"/Assets/tpp/parts/chara/sna/sna4_enem0_def_v00.parts"
			elseif maleBattleDress then
				TppSoldier2.SetDefaultPartsPath"/Assets/tpp/parts/chara/sna/sna5_enem0_def_v00.parts"
			elseif maleTiger then
				TppSoldier2.SetDefaultPartsPath"/Assets/tpp/parts/chara/dds/dds5_enem0_def_v00.parts"
			end

			--r42 Beach party mode
			if beachParty then
				TppSoldier2.SetDefaultPartsPath"/Assets/tpp/parts/chara/dlf/dlf1_enem0_def_v00.parts"
			end

			for a,e in ipairs(faceIdsTable)
			do
				table.insert(faces,e)
			end
			
		elseif nextMissionCode==30150 then
		elseif nextMissionCode==30250 then
			--r51 Settings
			if not TUPPMSettings.mtbs_ENABLE_mixedStaffForMBQF then
				--ORIG
				local mbStaffIds=TppMotherBaseManagement.GetOutOnMotherBaseStaffs{sectionId=TppMotherBaseManagementConst.SECTION_SECURITY}
				local numberOfMbStaffIds=#mbStaffIds
				local faceIdsList={}
				for index,staffId in pairs(mbStaffIds)do
					local faceId=TppMotherBaseManagement.StaffIdToFaceId{staffId=staffId}
					if faceIdsList[faceId]==nil then
						faceIdsList[faceId]=1
					else
						--If a faceId is present incremen the instance count
						faceIdsList[faceId]=faceIdsList[faceId]+1
					end
					if index==7 then
						break
					end
				end
				for a,e in pairs(faceIdsList)do
					table.insert(faces,{a,e,e,0})
				end
				table.insert(faces,{TppEnemyFaceId.dds_balaclava6,7,7,0})
			else
				--r51 Settings
				--TODO test with 0 staff
				--r46 Get random staff and faces here
				--This code ensures that faces are loaded here and synced with MBQF when applying unique settings in f30250_enemy.SetAllEnabled
				--MB faces are loaded during the sequence, MBQF faces path is set here but loaded by whatever happens
				-- in TppMissions.Load() function's Mission.LoadLocation({force=true}) call
				this.mbStaffIdsForMBQF = {}
				for i = TppMotherBaseManagementConst.SECTION_COMBAT, TppMotherBaseManagementConst.SECTION_SECURITY do
					local tmpList = TppMotherBaseManagement.GetOutOnMotherBaseStaffs{sectionId=i}
					while(#tmpList > 0)do
						local index = math.random(1,#tmpList)
						table.insert( this.mbStaffIdsForMBQF, tmpList[index] )
						table.remove( tmpList,index )
					end
				end

				local mbStaffIdsForMBQF=this.mbStaffIdsForMBQF --Copy for iterating, original should be used in f30250_enemy.SetAllEnabled
				this.faceIdsListForMBQF = {}
				local faceIdsList={} --this is slightly different than the one in f30250_enemy.SetAllEnabled, this is supposed to hold instance count - frankly the method of loading faceIds for MBQF is just crap compared to the rest of the code
				local tempFacesList={}

				local femaleStaffCount = TppMotherBaseManagement.GetFemaleStaffCount()
				local minFemalesAllowed = 0
				local femalesSet = 0

				--cause only 7 total soldiers allowed on MBQF
				--bias works well enough
				local femaleMinBias = math.min(math.random(7), math.random(7))

				if femaleStaffCount > 0 then
					minFemalesAllowed=math.min(math.random(femaleStaffCount), femaleMinBias)
				end
				--			TUPPMLog.Log("minFemalesAllowed:"..tostring(minFemalesAllowed),3)

				local function IsFemaleFace( faceId )
					local faceTypeList = TppSoldierFace.CheckFemale{ face={faceId}}
					return faceTypeList and faceTypeList[1] == 1
				end

				local function IsValidStaffId(faceId) --NMC check 30050 files
					local faceTypeList = TppSoldierFace.CheckFemale{ face={faceId} }
					if (faceTypeList == nil) or (faceTypeList[1] == 2) then
						return false
					end
					return true
				end

				while(#mbStaffIdsForMBQF > 0)do
					local index = math.random(1,#mbStaffIdsForMBQF)
					local faceId=TppMotherBaseManagement.StaffIdToFaceId{staffId=mbStaffIdsForMBQF[index]} --discovered that

					--r46 Force some staff to be female if allowed
					if minFemalesAllowed > 0 and femalesSet<minFemalesAllowed then
						--Not a very performance friendly approach but works
						while not IsFemaleFace(faceId) do
							index = math.random(1,#mbStaffIdsForMBQF)
							faceId=TppMotherBaseManagement.StaffIdToFaceId{staffId=mbStaffIdsForMBQF[index]}
						end
						femalesSet=femalesSet+1 --Will only come here if a female faceId is selected so increment femalesSet
					end


					if faceId and IsValidStaffId(faceId) then
						--TODO rX46 Find a solution
						--If faceId is 1, then it is not stored as faceIdsList={[1]=instanceCount} but rather as faceIdsList={instanceCount}
						--The same is true whenever any faceId forms a sequence effectively destroying the numeric indexing and also introducing nil into the table

						--r46 ALTERNATE FIX Use in combo with below
						--Solution? Use faceIds keys as strings
						--TODO rX46 Not tried yet but this should allow to load ALL faceIds(hopefully) and then getting a random face list in f30250_enemy.SetAllEnabled should work. Currently, forcing reload on checkpoint at TppMission.Load(nextMissionCode,currentMissionCode,options)
						--Keep this as it is since it's working anyway, plus it is a safeguard againt faceId 1 - if ever loaded
						--Have to convert tonumber before use!
						local faceIdString=tostring(faceId)

						if faceIdsList[faceIdString]==nil then
							faceIdsList[faceIdString]=1
						else
							--If a faceId is present incremen the instance count
							faceIdsList[faceIdString]=faceIdsList[faceIdString]+1
						end

						table.insert( tempFacesList, faceId )
						--					TUPPMLog.Log("faceId:"..tostring(faceId),3)
						--					TUPPMLog.Log("In process faceIdList:"..tostring(InfInspect.Inspect(faceIdsList)),3)
					end

					table.remove( mbStaffIdsForMBQF, index ) --remove staffId even if face is invalid - why keep it around

					--TODO rX46 Remove break on 7 and add every face
					--Will not work when used on faceIdsList and if faceIdsList has a nil entry before size 7
					if #tempFacesList >= 7 then
						break
					end
				end

				--			TUPPMLog.Log("femalesSet:"..tostring(femalesSet),3)

				--r46 Shuffle faces here, faces are assigned by linear traversal in f30250_enemy.SetAllEnabled
				while #tempFacesList>0 do
					local faceIdIndex = math.random(tempFacesList[#tempFacesList])
					table.insert( this.faceIdsListForMBQF, tempFacesList[faceIdIndex] )
					table.remove( tempFacesList, faceIdIndex )
				end

				TUPPMLog.Log("TppEneFova.fovaSetupFunctions.Mb *RANDOM* this.faceIdsListForMBQF:"..tostring(InfInspect.Inspect(this.faceIdsListForMBQF)),3)
				TUPPMLog.Log("TppEneFova.fovaSetupFunctions.Mb *RANDOM* faceIdList:"..tostring(InfInspect.Inspect(faceIdsList)),3)

				for faceId,instanceCount in pairs(faceIdsList)do
					--        table.insert(faces,{faceId,instanceCount,instanceCount,0})--ORIG
					--r46 ALTERNATE FIX Use in combo with above
					--TODO rX46 - with this, it should be possible to load ALL faces here and randomize the faces in f30250_enemy.SetAllEnabled - that should remove the 'Mission.LoadLocation({force=true})' dependency in TppMission.Load(nextMissionCode,currentMissionCode,options)
					table.insert(faces,{tonumber(faceId),instanceCount,instanceCount,0})
				end

				table.insert(faces,{TppEnemyFaceId.dds_balaclava6,7,7,0}) --causes problems where random faces end up having the balaclava applied, why? because of def parts parts face Id issues seen before but not understood completely

				--NOPE, gas mask is force loaded else where - invisi heads if not added
				--      if this.IsUseGasMaskInMBFree() then
				--      	TUPPMLog.Log("Added gas mask faceId",3)
				--      	table.insert(faces,{TppEnemyFaceId.dds_balaclava6,7,7,0}) --causes problems where random faces end up having the balaclava applied, why? because of def parts parts face Id issues seen before but not understood completely
				--     	else
				--     		TUPPMLog.Log("Did not add gas mask faceId",3)
				--      end

				--r46 INCORRECT This is an important step for random MBQF faces without having the balaclava showing up
				--Similar to how faces are empty for MB above
				--      faces={} --nope - invisi heads
				
				if maleSneakingSuit then
					TppSoldier2.SetDefaultPartsPath"/Assets/tpp/parts/chara/sna/sna4_enem0_def_v00.parts"
				elseif maleBattleDress then
					TppSoldier2.SetDefaultPartsPath"/Assets/tpp/parts/chara/sna/sna5_enem0_def_v00.parts"
				elseif maleTiger then
					TppSoldier2.SetDefaultPartsPath"/Assets/tpp/parts/chara/dds/dds5_enem0_def_v00.parts"
				end

				if beachParty then
					TppSoldier2.SetDefaultPartsPath"/Assets/tpp/parts/chara/dlf/dlf1_enem0_def_v00.parts"
				end
				
				--END of mtbs_ENABLE_randomMBStaffOutfits check
			end

		elseif nextMissionCode==10240 then
			faces={{1,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0},{2,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0},{3,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0},{4,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0},{5,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0},{6,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0},{7,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0},{8,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0},{9,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0},{14,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0},{15,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0},{16,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0},{17,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0},{18,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0}}
			table.insert(faces,{TppEnemyFaceId.dds_balaclava6,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})
		elseif nextMissionCode==10030 then
			for a,e in ipairs(this.S10030_FaceIdList)do
				table.insert(faces,{e,1,1,0})
			end
			table.insert(faces,{TppEnemyFaceId.dds_balaclava0,this.S10030_useBalaclavaNum,this.S10030_useBalaclavaNum,0})
		else
			for a=0,35 do
				table.insert(faces,{a,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})
			end
			table.insert(faces,{TppEnemyFaceId.dds_balaclava0,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})table.insert(faces,{TppEnemyFaceId.dds_balaclava1,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})table.insert(faces,{TppEnemyFaceId.dds_balaclava2,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})
		end
	end

	TppSoldierFace.OverwriteMissionFovaData{face=faces}
	--rX42 Attempted each random outfit on MB
	--  TppSoldierFace.OverwriteMissionFovaData{face=faces, additionalMode=true}

	local bodies={} --r28 update
	if TppMission.IsFOBMission(nextMissionCode)then
		if ddSuit==TppEnemy.FOB_DD_SUIT_SNEAKING then
			bodies={{TppEnemyBodyId.dds4_enem0_def,MAX_REALIZED_COUNT},{TppEnemyBodyId.dds4_enef0_def,MAX_REALIZED_COUNT}}
		elseif ddSuit==TppEnemy.FOB_DD_SUIT_BTRDRS then
			bodies={{TppEnemyBodyId.dds5_enem0_def,MAX_REALIZED_COUNT},{TppEnemyBodyId.dds5_enef0_def,MAX_REALIZED_COUNT}}
		elseif ddSuit==TppEnemy.FOB_PF_SUIT_ARMOR then
			bodies={{TppEnemyBodyId.pfa0_v00_a,MAX_REALIZED_COUNT}}
		else
			bodies={{TppEnemyBodyId.dds5_main0_v00,MAX_REALIZED_COUNT},{TppEnemyBodyId.dds6_main0_v00,MAX_REALIZED_COUNT}}
		end
		--RETAILPATCH 1.10>
		if TppMotherBaseManagement.GetMbsClusterSecurityIsEquipSwimSuit()then
			local securitySwimSuitGrade=TppMotherBaseManagement.GetMbsClusterSecuritySwimSuitGrade()
			bodies={{securitySwimSuitBodies.female[securitySwimSuitGrade],MAX_REALIZED_COUNT},{securitySwimSuitBodies.male[securitySwimSuitGrade],MAX_REALIZED_COUNT}}
		end
		--<
	elseif TUPPMSettings.mtbs_ENABLE_randomMBStaffOutfits and (vars.missionCode==30050 or vars.missionCode==30250) then
		--r51 Settings
		--r13 for 30050
		--Load body data
		--r42 Random MB Staff outfits
		--TUPPMLog.Log("Bodies for Motherbase")

		--Body selected here must have been loaded in the parts pack

		--MALES
		if maleSneakingSuit then
			table.insert(bodies,{TppEnemyBodyId.dds4_enem0_def,MAX_REALIZED_COUNT})
		end
		if maleBattleDress then
			table.insert(bodies,{TppEnemyBodyId.dds5_enem0_def,MAX_REALIZED_COUNT})
		end
		if maleTiger then
			table.insert(bodies,{TppEnemyBodyId.dds5_main0_v00,MAX_REALIZED_COUNT})

			--        --rX45 Works but missing hands and eyes for olive drab :(
			--        table.insert(bodies,{TppEnemyBodyId.dds3_main0_v00,MAX_REALIZED_COUNT})
		end

		--FEMALES
		if femaleSneakingSuit then
			table.insert(bodies,{TppEnemyBodyId.dds4_enef0_def,MAX_REALIZED_COUNT})
		end
		if femaleBattleDress then
			table.insert(bodies,{TppEnemyBodyId.dds5_enef0_def,MAX_REALIZED_COUNT})
		end
		if femaleTiger then
			table.insert(bodies,{TppEnemyBodyId.dds6_main0_v00,MAX_REALIZED_COUNT})
		end
		if femaleOlive then
			table.insert(bodies,{TppEnemyBodyId.dds8_main0_v00,MAX_REALIZED_COUNT})
		end

		--r42 Beach party
		if beachParty then
			bodies={}
			for sex, sexBodiesTable in pairs(securitySwimSuitBodies) do
				for index, body in pairs(sexBodiesTable) do
					table.insert(bodies,{sexBodiesTable[index],MAX_REALIZED_COUNT})
				end
			end
		end

	else
		bodies={{TppEnemyBodyId.dds3_main0_v00,MAX_REALIZED_COUNT},{TppEnemyBodyId.dds8_main0_v00,MAX_REALIZED_COUNT}}
	end

	TppSoldierFace.OverwriteMissionFovaData{body=bodies}
	--rX42 Attempted each random outfit on MB
	--  TppSoldierFace.OverwriteMissionFovaData{body=bodies, additionalMode=true}

	--r13 for 30050
	--Set path for female balaclava and body data
	if TUPPMSettings.mtbs_ENABLE_randomMBStaffOutfits and (vars.missionCode==30050 or vars.missionCode==30250) then
		--r51 Settings
		--r42 Random MB Staff outfits
		--TUPPMLog.Log("Extended female parts for Motherbase")

		--Female parts pack is loaded after bodies are decided - why? - this is very weird but may be a clue

		if femaleSneakingSuit then
			TppSoldier2.SetExtendPartsInfo{type=1,path="/Assets/tpp/parts/chara/sna/sna4_enef0_def_v00.parts"}
		end
		if femaleBattleDress then
			TppSoldier2.SetExtendPartsInfo{type=1,path="/Assets/tpp/parts/chara/sna/sna5_enef0_def_v00.parts"}
		end
		if femaleTiger then
			TppSoldier2.SetExtendPartsInfo{type=1,path="/Assets/tpp/parts/chara/dds/dds6_enef0_def_v00.parts"}
		end
		if femaleOlive then
			TppSoldier2.SetExtendPartsInfo{type=1,path="/Assets/tpp/parts/chara/dds/dds8_main0_def_v00.parts"}
		end

		--r42 Beach party
		if beachParty then
			TppSoldier2.SetExtendPartsInfo{type=1,path="/Assets/tpp/parts/chara/dlf/dlf0_enem0_def_f_v00.parts"}
		end

	elseif not(nextMissionCode==10030 or nextMissionCode==10240)then
		if TppMission.IsFOBMission(nextMissionCode)then
			if ddSuit==TppEnemy.FOB_DD_SUIT_SNEAKING then
				TppSoldier2.SetExtendPartsInfo{type=1,path="/Assets/tpp/parts/chara/sna/sna4_enef0_def_v00.parts"}
			elseif ddSuit==TppEnemy.FOB_DD_SUIT_BTRDRS then
				TppSoldier2.SetExtendPartsInfo{type=1,path="/Assets/tpp/parts/chara/sna/sna5_enef0_def_v00.parts"}
			elseif ddSuit==TppEnemy.FOB_PF_SUIT_ARMOR then
			else
				TppSoldier2.SetExtendPartsInfo{type=1,path="/Assets/tpp/parts/chara/dds/dds6_enef0_def_v00.parts"}
			end
			--RETAILPATCH 1.10>
			if TppMotherBaseManagement.GetMbsClusterSecurityIsEquipSwimSuit()then
				TppSoldier2.SetExtendPartsInfo{type=1,path="/Assets/tpp/parts/chara/dlf/dlf0_enem0_def_f_v00.parts"}
			end
			--<
		elseif nextMissionCode~=10115 and nextMissionCode~=11115 then
			TppSoldier2.SetExtendPartsInfo{type=1,path="/Assets/tpp/parts/chara/dds/dds8_main0_def_v00.parts"}
		end
	end
	TppSoldierFace.SetSoldierUseHairFova(true)
end
function fovaSetupFunctions.Cyprus(areaName,nextMissionCode)
	local a={}
	for e=0,5 do
		table.insert(a,e)
	end
	TppSoldierFace.SetPoolTable{face=a}
	TppSoldierFace.SetSoldierNoFaceResourceMode(true)
	local e={{TppEnemyBodyId.wss0_main0_v00,MAX_REALIZED_COUNT}}
	TppSoldierFace.OverwriteMissionFovaData{body=e}
end
function fovaSetupFunctions.default(areaName,nextMissionCode)
	TppSoldierFace.SetMissionFovaData{face={},body={}}
	if nextMissionCode>6e4 then
		local e={{30,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT}}
		TppSoldierFace.OverwriteMissionFovaData{face=e}
	end
end
function this.AddTakingOverHostagePack()
	local n={}
	for e,t in ipairs(TppEnemy.TAKING_OVER_HOSTAGE_LIST)do
		local e=e-1
		if e>=gvars.ene_takingOverHostageCount then
			break
		end
		local e={type="hostage",name=t,faceId=gvars.ene_takingOverHostageFaceIds[e]}table.insert(n,e)
	end
	this.AddUniqueSettingPackage(n)
end
function this.PreMissionLoad(nextMissionCode,currentMissionCode)
	TppSoldier2.SetEnglishVoiceIdTable{voice={}}
	TppSoldierFace.SetMissionFovaData{face={},body={}}
	TppSoldierFace.ResetForPreMissionLoad()
	TppSoldier2.SetDisableMarkerModelEffect{enabled=false}
	TppSoldier2.SetDefaultPartsPath()
	TppSoldier2.SetExtendPartsInfo{}
	TppHostage2.ClearDefaultBodyFovaId()
	if TppLocation.IsMotherBase()or TppLocation.IsMBQF()then
		local mbsClusterSecuritySoldierEquipGrade=TppMotherBaseManagement.GetMbsClusterSecuritySoldierEquipGrade{}
		local mbsClusterSecurityIsNoKillMode=TppMotherBaseManagement.GetMbsClusterSecurityIsNoKillMode()
		TppEnemy.PrepareDDParameter(mbsClusterSecuritySoldierEquipGrade,mbsClusterSecurityIsNoKillMode)
	end
	local fovaSetupFunctionsWithCaseApplied=ApplyCaseOnPassedTable(fovaSetupFunctions)
	--fovaSetupFunctionsWithCaseApplied has a switch case in it and thus can be used from here on
	if fovaSetupFunctions[nextMissionCode]==nil then
		if TppMission.IsHelicopterSpace(nextMissionCode)then
			fovaSetupFunctionsWithCaseApplied:case("default",nextMissionCode)
		elseif TppLocation.IsAfghan()then
			fovaSetupFunctionsWithCaseApplied:case("Afghan",nextMissionCode)
		elseif TppLocation.IsMiddleAfrica()then
			fovaSetupFunctionsWithCaseApplied:case("Africa",nextMissionCode)
		elseif TppLocation.IsMBQF()then
			fovaSetupFunctionsWithCaseApplied:case("Mbqf",nextMissionCode)
		elseif TppLocation.IsMotherBase()then
			fovaSetupFunctionsWithCaseApplied:case("Mb",nextMissionCode)
		elseif TppLocation.IsCyprus()then
			fovaSetupFunctionsWithCaseApplied:case("Cyprus",nextMissionCode)
		else
			fovaSetupFunctionsWithCaseApplied:case("default",nextMissionCode)
		end
	else
		--This is for mission codes and not area names :)
		fovaSetupFunctionsWithCaseApplied:case(nextMissionCode,nextMissionCode)
	end
end
local c={}
local o={}
local p={}
local t={}
local l=0
local d=0
local i=0
local s=0
local r=0
local m=15
local T=16
local _=32
local f=0
function this.InitializeUniqueSetting()c={}o={}p={}t={}l=0
	d=0
	i=0
	s=0
	r=0
	local n=GameObject.NULL_ID
	local a=EnemyFova.NOT_USED_FOVA_VALUE
	for e=0,TppDefine.ENEMY_FOVA_UNIQUE_SETTING_COUNT-1 do
		gvars.ene_fovaUniqueTargetIds[e]=n
		gvars.ene_fovaUniqueFaceIds[e]=a
		gvars.ene_fovaUniqueBodyIds[e]=a
		gvars.ene_fovaUniqueBodyIds[e]=a
		if gvars.ene_fovaUniqueFlags then
			gvars.ene_fovaUniqueFlags[e]=0
		end
	end
end
function this.GetStaffIdForDD(e,n)
	local a=f
	if e==10081 then
		a=TppMotherBaseManagement.GetStaffS10081()
	elseif e==10091 or e==11091 then
		local e=TppMotherBaseManagement.GetStaffsS10091()
		if e and n<#e then
			a=e[n+1]
		end
	elseif e==10115 or e==11115 then
		local e=TppMotherBaseManagement.GetStaffsS10115()
		if e and n<#e then
			a=e[n+1]
		end
	end
	return a
end
function this.GetFaceIdForDdHostage(e)
	local n=l
	l=l+1
	local a=this.GetStaffIdForDD(e,n)
	local t=bit.bor(T,n)
	if a~=f then
		local a=TppMotherBaseManagement.StaffIdToFaceId{staffId=a}
		if e==10081 then
			i=a
		elseif e==10091 or e==11091 then
			if n>0 then
				r=a
			else
				s=a
			end
		end
		return a,t
	end
	local a=(gvars.hosface_groupNumber+n)%30
	local a=50+a
	if TppSoldierFace.GetRandomFaceId~=nil then
		local e=gvars.solface_groupNumber+n
		a=TppSoldierFace.GetRandomFaceId{race={0,2,3},gender=0,useIndex=e}
	end
	if e==10081 then
		i=a
	elseif e==10091 or e==11091 then
		if n>0 then
			r=a
		else
			s=a
		end
	end
	return a,t
end
function this.GetFaceId_s10081()
	return i
end
function this.GetFaceId_s10091_0()
	return s
end
function this.GetFaceId_s10091_1()
	return r
end
function this.GetFaceIdForFemaleHostage(missionCode)
	local t=_
	if missionCode==10086 then
		return 613,t
	end
	local n=d
	d=d+1
	local a={}table.insert(a,0)
	if TppLocation.IsAfghan()then
		table.insert(a,3)
	elseif TppLocation.IsMiddleAfrica()then
		table.insert(a,2)table.insert(a,3)
	end
	local d=gvars.solface_groupNumber+n
	local e=EnemyFova.INVALID_FOVA_VALUE
	if TppSoldierFace.GetRandomFaceId~=nil then
		e=TppSoldierFace.GetRandomFaceId{race=a,gender=1,useIndex=d}
		if e~=EnemyFova.INVALID_FOVA_VALUE then
			return e,t
		else
			local a=(gvars.hosface_groupNumber+n)%50
			e=350+a
		end
	else
		local a=(gvars.hosface_groupNumber+n)%50
		e=350+a
	end
	return e,t
end
function this.GetFaceIdAndFlag(type,faceId)
	local t=EnemyFova.NOT_USED_FOVA_VALUE
	if faceId=="female"then
		if type=="hostage"then
			return this.GetFaceIdForFemaleHostage(vars.missionCode)
		else
			return t,0
		end
	elseif faceId=="dd"then
		if type=="hostage"then
			return this.GetFaceIdForDdHostage(vars.missionCode)
		else
			return t,0
		end
	end
	return faceId,0
end
function this.RegisterUniqueSetting(type,name,faceIdType,bodyId)
	local e=EnemyFova.NOT_USED_FOVA_VALUE
	local faceIDGot,UNKfaceInstanceCount=this.GetFaceIdAndFlag(type,faceIdType)
	if faceIDGot==nil then
		faceIDGot=e
	end
	if bodyId==nil then
		bodyId=e
	end
	table.insert(c,{name=name,faceId=faceIDGot,bodyId=bodyId,flag=UNKfaceInstanceCount})do
		local p=1
		local n=2
		local t=3
		local l=4
		local e=nil
		for t,n in ipairs(o)do
			if n[p]==faceIDGot then
				e=n
			end
		end
		if not e then
			e={faceIDGot,0,0,0}
			table.insert(o,e)
		end
		if type=="enemy"then
			e[n]=e[n]+1
			e[t]=e[t]+1
		elseif type=="hostage"then
			e[l]=e[l]+1
		end
	end
	do
		local l=1
		local o=2
		local e=nil
		for t,a in ipairs(p)do
			if a[l]==bodyId then
				e=a
			end
		end
		if not e then
			e={bodyId,0}
			table.insert(p,e)
		end
		e[o]=e[o]+1
		if type=="hostage"then
			local e=bodyId
			for t,a in ipairs(t)do
				if a==bodyId then
					e=nil
					break
				end
			end
			if e then
				table.insert(t,e)
			end
		end
	end
end
function this.AddUniqueSettingPackage(e)
	if e and type(e)=="table"then
		for n,e in ipairs(e)do
			this.RegisterUniqueSetting(e.type,e.name,e.faceId,e.bodyId,e.missionCode)
		end
	end
	TppSoldierFace.OverwriteMissionFovaData{face=o,body=p,additionalMode=true}if#t>0 then
		TppSoldierFace.SetBodyFovaUserType{hostage=t}
	end
end
function this.AddUniquePackage(e)
	TppSoldierFace.OverwriteMissionFovaData{face=e.face,body=e.body,additionalMode=true}
	if e.body and e.type=="hostage"then
		local a={}
		for n,e in ipairs(e.body)do
			table.insert(a,e[1])
		end
		if#a>0 then
			TppSoldierFace.SetBodyFovaUserType{hostage=a}
		end
	end
end
function this.ApplyUniqueSetting()
	local t=GameObject.NULL_ID
	local e=EnemyFova.NOT_USED_FOVA_VALUE
	if gvars.ene_fovaUniqueTargetIds[0]==t then
		local e=0
		for n,a in ipairs(c)do
			local n=GameObject.GetGameObjectId(a.name)
			if n~=t then
				if e<TppDefine.ENEMY_FOVA_UNIQUE_SETTING_COUNT then
					gvars.ene_fovaUniqueTargetIds[e]=n
					gvars.ene_fovaUniqueFaceIds[e]=a.faceId
					gvars.ene_fovaUniqueBodyIds[e]=a.bodyId
					if gvars.ene_fovaUniqueFlags then
						gvars.ene_fovaUniqueFlags[e]=a.flag
					end
				end
				e=e+1
			end
		end
	end
	local d=bit.band
	for n=0,TppDefine.ENEMY_FOVA_UNIQUE_SETTING_COUNT-1 do
		local e=gvars.ene_fovaUniqueTargetIds[n]
		if e==t then
			break
		end
		local t={id="ChangeFova",faceId=gvars.ene_fovaUniqueFaceIds[n],bodyId=gvars.ene_fovaUniqueBodyIds[n]}
		GameObject.SendCommand(e,t)
		local t=0
		if gvars.ene_fovaUniqueFlags then
			t=gvars.ene_fovaUniqueFlags[n]
		end
		if d(t,T)~=0 then
			local o=vars.missionCode
			local n=d(t,m)
			local a=this.GetStaffIdForDD(o,n)
			if a~=f then
				local a={id="SetStaffId",staffId=a}
				GameObject.SendCommand(e,a)
			end
			local a={id="SetHostage2Flag",flag="dd",on=true}
			GameObject.SendCommand(e,a)
		elseif d(t,_)~=0 then
			local a={id="SetHostage2Flag",flag="female",on=true}
			GameObject.SendCommand(e,a)
		end
	end
end
function this.ApplyMTBSUniqueSetting(soldierId,assignedFaceId,useBalaclava,forceNoBalaclava)
	local assignedBodyId=0
	local assignedBalaclavaFaceID=EnemyFova.INVALID_FOVA_VALUE
	local ddSuit=TppEnemy.GetDDSuit()
	local function IsFemale(e)
		local IsFemale=TppSoldierFace.CheckFemale{face={e}}
		return IsFemale and IsFemale[1]==1
	end
	if TppMission.IsFOBMission(vars.missionCode)then
		if ddSuit==TppEnemy.FOB_DD_SUIT_SNEAKING then
			if((TppEnemy.weaponIdTable.DD.NORMAL.SNEAKING_SUIT and TppEnemy.weaponIdTable.DD.NORMAL.SNEAKING_SUIT>=3)and TppMotherBaseManagement.GetMbsNvgSneakingLevel)and TppMotherBaseManagement.GetMbsNvgSneakingLevel()>0 then
				TppEnemy.AddPowerSetting(soldierId,{"NVG"})
			end
			if IsFemale(assignedFaceId)==true then
				assignedBodyId=TppEnemyBodyId.dds4_enef0_def
				local a={id="UseExtendParts",enabled=true}
				GameObject.SendCommand(soldierId,a)
				if TppEnemy.IsHelmet(soldierId)then
					if TppEnemy.IsNVG(soldierId)then
						assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava14
					else
						assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava3
					end
				else
					assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava4
				end
			else
				assignedBodyId=TppEnemyBodyId.dds4_enem0_def
				local a={id="UseExtendParts",enabled=false}
				GameObject.SendCommand(soldierId,a)
				if TppEnemy.IsHelmet(soldierId)then
					if TppEnemy.IsNVG(soldierId)then
						assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava12
					else
						assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava0
					end
				else
					assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava1
				end
			end
		elseif ddSuit==TppEnemy.FOB_DD_SUIT_BTRDRS then
			if((TppEnemy.weaponIdTable.DD.NORMAL.BATTLE_DRESS and TppEnemy.weaponIdTable.DD.NORMAL.BATTLE_DRESS>=3)and TppMotherBaseManagement.GetMbsNvgBattleLevel)and TppMotherBaseManagement.GetMbsNvgBattleLevel()>0 then
				TppEnemy.AddPowerSetting(soldierId,{"NVG"})
			end
			if IsFemale(assignedFaceId)==true then
				assignedBodyId=TppEnemyBodyId.dds5_enef0_def
				local a={id="UseExtendParts",enabled=true}
				GameObject.SendCommand(soldierId,a)
				if TppEnemy.IsHelmet(soldierId)then
					if TppEnemy.IsNVG(soldierId)then
						assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava14
					else
						assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava3
					end
				elseif useBalaclava then
					assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava4
				end
			else
				assignedBodyId=TppEnemyBodyId.dds5_enem0_def
				local a={id="UseExtendParts",enabled=false}
				GameObject.SendCommand(soldierId,a)
				if TppEnemy.IsHelmet(soldierId)then
					if TppEnemy.IsNVG(soldierId)then
						assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava12
					else
						assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava0
					end
				elseif useBalaclava then
					assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava1
				end
			end
		elseif ddSuit==TppEnemy.FOB_PF_SUIT_ARMOR then
			if not IsFemale(assignedFaceId)==true then
				assignedBodyId=TppEnemyBodyId.pfa0_v00_a
				local a={id="UseExtendParts",enabled=false}
				GameObject.SendCommand(soldierId,a)
				TppEnemy.AddPowerSetting(soldierId,{"ARMOR"})
			end
		else
			if IsFemale(assignedFaceId)==true then
				assignedBodyId=TppEnemyBodyId.dds6_main0_v00
				local a={id="UseExtendParts",enabled=true}
				GameObject.SendCommand(soldierId,a)
				if useBalaclava then
					if TppEnemy.IsHelmet(soldierId)then
						assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava3
					else
						assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava5
					end
				end
			else
				assignedBodyId=TppEnemyBodyId.dds5_main0_v00
				local a={id="UseExtendParts",enabled=false}
				GameObject.SendCommand(soldierId,a)
				if useBalaclava then
					if TppEnemy.IsHelmet(soldierId)then
						assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava0
					else
						assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava2
					end
				end
			end
		end
		--RETAILPATCH 1.10>
		if TppMotherBaseManagement.GetMbsClusterSecurityIsEquipSwimSuit()then
			local securitySwimsuitGrade=TppMotherBaseManagement.GetMbsClusterSecuritySwimSuitGrade()
			if IsFemale(assignedFaceId)then
				assignedBodyId=securitySwimSuitBodies.female[securitySwimsuitGrade]
			else
				assignedBodyId=securitySwimSuitBodies.male[securitySwimsuitGrade]
			end
		end
		--<
		if this.IsUseGasMaskInFOB()and ddSuit~=TppEnemy.FOB_PF_SUIT_ARMOR then
			if IsFemale(assignedFaceId)then
				if TppEnemy.IsHelmet(soldierId)then
					if TppEnemy.IsNVG(soldierId)then
						assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava15
					else
						assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava11
					end
				else
					assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava10
				end
			else
				if TppEnemy.IsHelmet(soldierId)then
					if TppEnemy.IsNVG(soldierId)then
						assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava13
					else
						assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava9
					end
				else
					assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava8
				end
			end
			TppEnemy.AddPowerSetting(soldierId,{"GAS_MASK"})
		end
	else

		--		TUPPMLog.Log(
		--		"ApplyMTBSUniqueSetting \n maleSneakingSuit:"..tostring(maleSneakingSuit)
		--		.."\n maleBattleDress:"..tostring(maleBattleDress)
		--		.."\n maleTiger:"..tostring(maleTiger)
		--		.."\n femaleSneakingSuit:"..tostring(femaleSneakingSuit)
		--		.."\n femaleBattleDress:"..tostring(femaleBattleDress)
		--		.."\n femaleTiger:"..tostring(femaleTiger)
		--		.."\n femaleOlive:"..tostring(femaleOlive)
		--		,true)

		--r51 Settings
		if TUPPMSettings.mtbs_ENABLE_randomMBStaffOutfits and (vars.missionCode==30050 or vars.missionCode==30250) then
			--r42 Random MB Staff outfits
			--r13 for 30050
			--Assign bodies and do not assign balaclavas
			--TUPPMLog.Log("Assigning bodies")

			if IsFemale(assignedFaceId)==true then
				--FEMALES
				if femaleSneakingSuit then
					assignedBodyId=TppEnemyBodyId.dds4_enef0_def
					local a={id="UseExtendParts",enabled=true}
					GameObject.SendCommand(soldierId,a)
				end
				if femaleBattleDress then
					assignedBodyId=TppEnemyBodyId.dds5_enef0_def
					local a={id="UseExtendParts",enabled=true}
					GameObject.SendCommand(soldierId,a)
				end
				if femaleTiger then
					assignedBodyId=TppEnemyBodyId.dds6_main0_v00
					local a={id="UseExtendParts",enabled=true}
					GameObject.SendCommand(soldierId,a)
				end
				if femaleOlive then
					assignedBodyId=TppEnemyBodyId.dds8_main0_v00
					local t={id="UseExtendParts",enabled=true}
					GameObject.SendCommand(soldierId,t)
				end

				--r42 Beach party
				if beachParty then
					local index = math.random(1,#securitySwimSuitBodies.female)
					assignedBodyId=securitySwimSuitBodies.female[index]
					local t={id="UseExtendParts",enabled=true}
					GameObject.SendCommand(soldierId,t)
				end

			else
				--MALES
				if maleSneakingSuit then
					assignedBodyId=TppEnemyBodyId.dds4_enem0_def
					local a={id="UseExtendParts",enabled=false}
					GameObject.SendCommand(soldierId,a)
				end
				if maleBattleDress then
					assignedBodyId=TppEnemyBodyId.dds5_enem0_def
					local a={id="UseExtendParts",enabled=false}
					GameObject.SendCommand(soldierId,a)
				end
				if maleTiger then
					assignedBodyId=TppEnemyBodyId.dds5_main0_v00

					--          --rX45 Use Olive Drab with Tiger Stripes
					--          --rX45 Works but missing hands and eyes for olive drab :(
					--          local oliveDrabChance = math.random(2)
					--          TUPPMLog.Log("MaleTiger oliveDrabChance:"..tostring(oliveDrabChance))
					--          if oliveDrabChance>1 then
					--            TUPPMLog.Log("Assigning olive drab body Id")
					--            assignedBodyId=TppEnemyBodyId.dds3_main0_v00
					--          end

					local a={id="UseExtendParts",enabled=false}
					GameObject.SendCommand(soldierId,a)
				end

				--r42 Beach party
				if beachParty then
					local index = math.random(1,#securitySwimSuitBodies.male)
					assignedBodyId=securitySwimSuitBodies.male[index]
					local t={id="UseExtendParts",enabled=false}
					GameObject.SendCommand(soldierId,t)
				end

			end

		else
			--r13 for 30050
			--TUPPMLog.Log("Boring old older code")

			if IsFemale(assignedFaceId)then
				assignedBodyId=TppEnemyBodyId.dds8_main0_v00
				local t={id="UseExtendParts",enabled=true}
				GameObject.SendCommand(soldierId,t)
				if useBalaclava then
					assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava5
				end
				if this.IsUseGasMaskInMBFree()then
					assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava7
					TppEnemy.AddPowerSetting(soldierId,{"GAS_MASK"})
				end
			else
				assignedBodyId=TppEnemyBodyId.dds3_main0_v00
				local t={id="UseExtendParts",enabled=false}
				GameObject.SendCommand(soldierId,t)
				if useBalaclava then
					assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava2
				end
				if this.IsUseGasMaskInMBFree()then
					assignedBalaclavaFaceID=TppEnemyFaceId.dds_balaclava6
					TppEnemy.AddPowerSetting(soldierId,{"GAS_MASK"})
				end
			end
		end
	end
	if forceNoBalaclava then
		assignedBalaclavaFaceID=EnemyFova.NOT_USED_FOVA_VALUE
	end

	--  TUPPMLog.Log("ApplyMTBSUniqueSetting"
	--	.." soldierId:"..tostring(soldierId)
	--	.." assignedFaceId:"..tostring(assignedFaceId)
	--	.." useBalaclava:"..tostring(useBalaclava)
	--	.." forceNoBalaclava:"..tostring(forceNoBalaclava)
	--	.." assignedBodyId:"..tostring(assignedBodyId)
	--	.." assignedBalaclavaFaceID:"..tostring(assignedBalaclavaFaceID)
	--	,3)

	local a={id="ChangeFova",faceId=assignedFaceId,bodyId=assignedBodyId,balaclavaFaceId=assignedBalaclavaFaceID}
	GameObject.SendCommand(soldierId,a)
end
function this.IsUseGasMaskInMBFree(e)
	local isPandemicEventMode=TppMotherBaseManagement.IsPandemicEventMode()
	local notCommandPlat=mvars.f30050_currentFovaClusterId~=TppDefine.CLUSTER_DEFINE.Command
	return isPandemicEventMode and notCommandPlat
end
function this.IsUseGasMaskInFOB()
	local a,a,e=this.GetUavSetting()
	return e
end
function this.GetUavSetting()
	local o=TppMotherBaseManagement.GetMbsUavLevel{}
	local i=TppMotherBaseManagement.GetMbsUavSmokeGrenadeLevel{}
	local _=TppMotherBaseManagement.GetMbsUavSleepingGusGrenadeLevel{}
	local n=TppMotherBaseManagement.GetMbsClusterSecuritySoldierEquipGrade{}
	local T=TppMotherBaseManagement.GetMbsClusterSecurityIsNoKillMode()
	local l=TppUav.DEVELOP_LEVEL_LMG_0
	local d=false
	local s=false
	local a=100
	local e=a
	local t=a
	local p=a
	local r=7
	local r=4
	local r=3
	local r=3
	local r=3
	local c=3
	local r=6
	local f=7
	if n<c then
		e=a
	elseif o>0 then
		if o==1 then
			e=TppUav.DEVELOP_LEVEL_LMG_0
		elseif o==2 then
			if n>=r then
				e=TppUav.DEVELOP_LEVEL_LMG_1
			else
				e=TppUav.DEVELOP_LEVEL_LMG_0
			end
		elseif o>=3 then
			if n>=f then
				e=TppUav.DEVELOP_LEVEL_LMG_2
			elseif n>=r then
				e=TppUav.DEVELOP_LEVEL_LMG_1
			else
				e=TppUav.DEVELOP_LEVEL_LMG_0
			end
		end
	end
	local c=4
	local r=6
	local f=7
	if n<c then
		t=a
	elseif o>0 then
		if i==1 then
			t=TppUav.DEVELOP_LEVEL_SMOKE_0
		elseif i==2 then
			if n>=r then
				t=TppUav.DEVELOP_LEVEL_SMOKE_1
			else
				t=TppUav.DEVELOP_LEVEL_SMOKE_0
			end
		elseif i==3 then
			if n>=f then
				t=TppUav.DEVELOP_LEVEL_SMOKE_2
			elseif n>=r then
				t=TppUav.DEVELOP_LEVEL_SMOKE_1
			else
				t=TppUav.DEVELOP_LEVEL_SMOKE_0
			end
		end
	end
	local i=8
	if n<i then
		p=a
	else
		if _>=1 then
			p=TppUav.DEVELOP_LEVEL_SLEEP_0
		end
	end
	if o==0 then
		d=false
	else
		if T==true then
			if p~=a then
				l=p
				d=true
				s=true
			elseif t~=a then
				l=t
				d=true
				s=true
			elseif e~=a then
				l=e
				d=true
			else
				d=false
			end
		else
			if e~=a then
				l=e
				d=true
			else
				d=false
			end
		end
	end
	--  return true,TppUav.DEVELOP_LEVEL_LMG_2,false
	return d,l,s
end
function this.GetUavCombatGradeAndEmpLevel(mbsClusterSecuritySoldierEquipGrade,mbsClusterSecurityIsNoKillMode,mbsUavLevel,mbsUavSleepingGusGrenadeLevel)
	if mbsClusterSecuritySoldierEquipGrade<9 then
		return nil,0
	end
	local uavDetailsTable={
		[9]={4,2},
		[10]={5,3},
		[11]={6,4}
	}
	local uavDefenseLevel,uavIsNoKillType2
	if mbsClusterSecurityIsNoKillMode then
		uavIsNoKillType2=2
		uavDefenseLevel=mbsUavSleepingGusGrenadeLevel
	else
		uavIsNoKillType2=1
		uavDefenseLevel=mbsUavLevel
	end
	local a
	for t,d in pairs(uavDetailsTable)do
		if d[uavIsNoKillType2]==uavDefenseLevel then
			a=t
		end
	end
	if not a then
		if uavDefenseLevel>uavDetailsTable[11][uavIsNoKillType2]then
		end
		return nil,0
	end
	local uavCombatGrade,empLevel
	if mbsClusterSecuritySoldierEquipGrade<=a then
		uavCombatGrade=mbsClusterSecuritySoldierEquipGrade
	else
		uavCombatGrade=a
	end
	empLevel=uavCombatGrade-8
	--  return 9,0
	return uavCombatGrade,empLevel
end

--rX44 All female faces at least to recruit females
--r44 Moved female faceIds here
this.femaleFaceIds={
	--TODO rX46 Check all faces one by one
	{min=350,max=399},--european
	{min=450,max=479},--r51 BUGFIX --african
	{min=500,max=519},--asian
	{613,643},
	{
		681,--female tatoo fox hound black
		682,--female tatoo whiteblack ddog red hair
		685,--female tatoo fox black
		686,--female tatoo skull white white hair
	},
}

--r43 Adding wildcard soldiers -tex
this.maleFaceIdsUncommon={
	--TODO rX46 Check all faces one by one
	{min=600,max=602},--mission dudes>
	{min=603,max=612},
	{min=614,max=620},
	{min=624,max=626},
	{635,},
	{min=637,max=642},
	{min=644,max=645},
	{min=647,max=649},
	{
		602,--glasses,
		621,--Tan
		--    622,--hideo, NOTE doesn't show if vars.playerFaceId
		627,--finger
		628,--eye
		646,--beardy mcbeard
		680,--fox hound tattoo
		683,--red hair, ddogs tattoo
		684,--fox tattoo
		687,--while skull tattoo
	},
}

--r43 Adding wildcard soldiers -tex
this.wildCardBodyTable={
	afgh={
		TppEnemyBodyId.svs0_unq_v010,
		TppEnemyBodyId.svs0_unq_v020,
		TppEnemyBodyId.svs0_unq_v070,
		TppEnemyBodyId.svs0_unq_v071,
		TppEnemyBodyId.svs0_unq_v072,
		TppEnemyBodyId.svs0_unq_v009,
		TppEnemyBodyId.svs0_unq_v060,
		TppEnemyBodyId.svs0_unq_v100,
		TppEnemyBodyId.svs0_unq_v420,
	},
	mafr={
		TppEnemyBodyId.pfs0_unq_v210,
		TppEnemyBodyId.pfs0_unq_v250,
		TppEnemyBodyId.pfs0_unq_v360,
		TppEnemyBodyId.pfs0_unq_v280,
		TppEnemyBodyId.pfs0_unq_v150,
		TppEnemyBodyId.pfs0_unq_v140,
		TppEnemyBodyId.pfs0_unq_v241,
		TppEnemyBodyId.pfs0_unq_v450,
		TppEnemyBodyId.pfs0_unq_v440,
	},
}

--r43 Adding wildcard soldiers - tex's function
function this.RandomFaceId(faceList)
	local rnd=math.random(#faceList)
	if rnd==#faceList then
		if math.random(100)>5 then
			rnd=rnd-1
		end
	end

	local type=faceList[rnd]
	if type.min then
		return math.random(type.min,type.max)
	else
		return type[math.random(1,#type)]
	end
end

--r43 Custom function to load all faces
function this.GetAllFaceIds(faceListTable)

	if not Tpp.IsTypeTable(faceListTable) then return end

	local returnTable = {}

	for index, details in pairs(faceListTable) do
		if details.min then
			local min=details.min
			while (min<=details.max) do
				table.insert(returnTable, min)
				min=min+1
			end
		else
			for i, faceId in ipairs(details) do
				table.insert(returnTable, faceId)
			end
		end
	end

	return returnTable

end

--r43 Adding wildcard soldiers - tex's function
function this.SetupBodies(bodyIds,bodies)--tex>
	if bodyIds==nil then return end

	if type(bodyIds)=="number"then
		local bodyEntry={bodyIds,MAX_REALIZED_COUNT}
		bodies[#bodies+1]=bodyEntry
	elseif type(bodyIds)=="table"then
		for n,bodyId in ipairs(bodyIds)do
			local bodyEntry={bodyId,MAX_REALIZED_COUNT}
			bodies[#bodies+1]=bodyEntry
		end
	end
end--<

--r43 Adding wildcard soldiers - from tex's function
--trimmed down and to the point
function this.UseWildcardSoldiers(bodies)
	--r51 Settings
	if not TUPPMSettings.wildcard_ENABLE then return end

	--r46 This is currently adding wildcard faces to missions as well - and working fine, saw some
	-- soldiers of color in M5. Don't know if should remove as it actually looks pretty cool.

	local faces={}
	--  for i=1,100 do--SYNC numwildcards
	----    local faceId=this.RandomFaceId(this.maleFaceIdsUncommon)
	----    table.insert(faces,{faceId,1,1,0})--0,0,MAX_REALIZED_COUNT})--rX46 seems to be instance count tex, hint is not in RegisterUniqueSetting rather in fovaSetupFunctions.Mb(areaName,nextMissionCode) faceIds load for 30250 --tex TODO figure this shit out, hint is in RegisterUniqueSetting since it builds one
	--  end

	local allFaceIdsTable={}
	allFaceIdsTable=this.GetAllFaceIds(this.maleFaceIdsUncommon)
	if #allFaceIdsTable~=0 then
		for i, faceId in pairs(allFaceIdsTable) do
			--r46 - Using MAX_REALIZED_COUNT - tbh doesn't make a diff, unique face instances are limited just like ARMOR in free roam
			table.insert(faces,{faceId,MAX_REALIZED_COUNT,MAX_REALIZED_COUNT,0})
			--      table.insert(faces,{faceId,1,1,0})
			--      TUPPMLog.Log("Adding face ID: "..tostring(faceId))
		end
	end
	TppSoldierFace.OverwriteMissionFovaData{face=faces,additionalMode=true} --additionalMode adds these faces instead of replacing previous ones, don't know what happens on multiple calls though

	local locationName=TppLocation.GetLocationName()

	local maleBodyTable=this.wildCardBodyTable[locationName]
	if maleBodyTable then
		TppEneFova.SetupBodies(maleBodyTable,bodies)
	end

end
return this
