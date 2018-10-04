--TUPPM Header

local this={}
local StrCode32=Fox.StrCode32
local type=type
local GetGameObjectId=GameObject.GetGameObjectId
local GetTypeIndex=GameObject.GetTypeIndex
local GAME_OBJECT_TYPE_PLAYER2=TppGameObject.GAME_OBJECT_TYPE_PLAYER2
local GAME_OBJECT_TYPE_SOLDIER2=TppGameObject.GAME_OBJECT_TYPE_SOLDIER2
local GAME_OBJECT_TYPE_COMMAND_POST2=TppGameObject.GAME_OBJECT_TYPE_COMMAND_POST2
local GAME_OBJECT_TYPE_HOSTAGE2=TppGameObject.GAME_OBJECT_TYPE_HOSTAGE2
local GAME_OBJECT_TYPE_HOSTAGE_UNIQUE=TppGameObject.GAME_OBJECT_TYPE_HOSTAGE_UNIQUE
local GAME_OBJECT_TYPE_HOSTAGE_UNIQUE2=TppGameObject.GAME_OBJECT_TYPE_HOSTAGE_UNIQUE2
local GAME_OBJECT_TYPE_HELI2=TppGameObject.GAME_OBJECT_TYPE_HELI2
local GAME_OBJECT_TYPE_ENEMY_HELI=TppGameObject.GAME_OBJECT_TYPE_ENEMY_HELI
local GAME_OBJECT_TYPE_HORSE2=TppGameObject.GAME_OBJECT_TYPE_HORSE2
local GAME_OBJECT_TYPE_VEHICLE=TppGameObject.GAME_OBJECT_TYPE_VEHICLE
local GAME_OBJECT_TYPE_WALKERGEAR2=TppGameObject.GAME_OBJECT_TYPE_WALKERGEAR2
local GAME_OBJECT_TYPE_COMMON_WALKERGEAR2=TppGameObject.GAME_OBJECT_TYPE_COMMON_WALKERGEAR2
local GAME_OBJECT_TYPE_VOLGIN2=TppGameObject.GAME_OBJECT_TYPE_VOLGIN2
local GAME_OBJECT_TYPE_MARKER2_LOCATOR=TppGameObject.GAME_OBJECT_TYPE_MARKER2_LOCATOR
local GAME_OBJECT_TYPE_BOSSQUIET2=TppGameObject.GAME_OBJECT_TYPE_BOSSQUIET2
local GAME_OBJECT_TYPE_PARASITE2=TppGameObject.GAME_OBJECT_TYPE_PARASITE2
local GAME_OBJECT_TYPE_SECURITYCAMERA2=TppGameObject.GAME_OBJECT_TYPE_SECURITYCAMERA2
local GAME_OBJECT_TYPE_UAV=TppGameObject.GAME_OBJECT_TYPE_UAV
local GetUserModeTppGameModeFunc=TppGameMode.GetUserMode
local U_KONAMI_LOGINTppGameModeID=TppGameMode.U_KONAMI_LOGIN
local GetOnlineChallengeTaskVersion=TppNetworkUtil.GetOnlineChallengeTaskVersion
local PHASE_ALERT=TppGameObject.PHASE_ALERT
local NULL_ID=GameObject.NULL_ID
local bitBnot=bit.bnot
local bitBand,bitBor,bitBxor=bit.band,bit.bor,bit.bxor
this.requires={
	"/Assets/tpp/script/lib/TppDefine.lua",
	"/Assets/tpp/script/lib/TppMath.lua",
	"/Assets/tpp/script/lib/TppSave.lua",
	"/Assets/tpp/script/lib/TppLocation.lua",
	"/Assets/tpp/script/lib/TppSequence.lua",
	"/Assets/tpp/script/lib/TppWeather.lua",
	"/Assets/tpp/script/lib/TppDbgStr32.lua",
	"/Assets/tpp/script/lib/TppDebug.lua",
	"/Assets/tpp/script/lib/TppClock.lua",
	"/Assets/tpp/script/lib/TppUI.lua",
	"/Assets/tpp/script/lib/TppResult.lua",
	"/Assets/tpp/script/lib/TppSound.lua",
	"/Assets/tpp/script/lib/TppTerminal.lua",
	"/Assets/tpp/script/lib/TppMarker.lua",
	"/Assets/tpp/script/lib/TppRadio.lua",
	"/Assets/tpp/script/lib/TppPlayer.lua",
	"/Assets/tpp/script/lib/TppHelicopter.lua",
	"/Assets/tpp/script/lib/TppScriptBlock.lua",
	"/Assets/tpp/script/lib/TppMission.lua",
	"/Assets/tpp/script/lib/TppStory.lua",
	"/Assets/tpp/script/lib/TppDemo.lua",
	"/Assets/tpp/script/lib/TppEnemy.lua",
	"/Assets/tpp/script/lib/TppGeneInter.lua",
	"/Assets/tpp/script/lib/TppInterrogation.lua",
	"/Assets/tpp/script/lib/TppGimmick.lua",
	"/Assets/tpp/script/lib/TppMain.lua",
	"/Assets/tpp/script/lib/TppDemoBlock.lua",
	"/Assets/tpp/script/lib/TppAnimalBlock.lua",
	"/Assets/tpp/script/lib/TppCheckPoint.lua",
	"/Assets/tpp/script/lib/TppPackList.lua",
	"/Assets/tpp/script/lib/TppQuest.lua",
	"/Assets/tpp/script/lib/TppTrap.lua",
	"/Assets/tpp/script/lib/TppReward.lua",
	"/Assets/tpp/script/lib/TppRevenge.lua",
	"/Assets/tpp/script/lib/TppReinforceBlock.lua",
	"/Assets/tpp/script/lib/TppEneFova.lua",
	"/Assets/tpp/script/lib/TppFreeHeliRadio.lua",
	"/Assets/tpp/script/lib/TppHero.lua",
	"/Assets/tpp/script/lib/TppTelop.lua",
	"/Assets/tpp/script/lib/TppRatBird.lua",
	"/Assets/tpp/script/lib/TppMovie.lua",
	"/Assets/tpp/script/lib/TppAnimal.lua",
	"/Assets/tpp/script/lib/TppException.lua",
	"/Assets/tpp/script/lib/TppTutorial.lua",
	"/Assets/tpp/script/lib/TppLandingZone.lua",
	"/Assets/tpp/script/lib/TppCassette.lua",
	"/Assets/tpp/script/lib/TppEmblem.lua",
	"/Assets/tpp/script/lib/TppDevelopFile.lua",
	"/Assets/tpp/script/lib/TppPaz.lua",
	"/Assets/tpp/script/lib/TppRanking.lua",
	"/Assets/tpp/script/lib/TppTrophy.lua",
	"/Assets/tpp/script/lib/TppMbFreeDemo.lua",
	"/Assets/tpp/script/lib/TUPPM.lua",
}
function this.IsTypeFunc(e)
	return type(e)=="function"end
local f=this.IsTypeFunc
function this.IsTypeTable(e)
	return type(e)=="table"end
local IsTypeTable=this.IsTypeTable
function this.IsTypeString(e)
	return type(e)=="string"end
local n=this.IsTypeString
function this.IsTypeNumber(e)
	return type(e)=="number"end
local n=this.IsTypeNumber
function this.Enum(tableToEnumOver)
	if tableToEnumOver==nil then
		return
	end
	if#tableToEnumOver==0 then
		return tableToEnumOver
	end
	for index=1,#tableToEnumOver do
		tableToEnumOver[tableToEnumOver[index]]=index
	end
	return tableToEnumOver
end
function this.IsMaster()do
	return true
end
end
function this.IsQARelease()
	return(Fox.GetDebugLevel()==Fox.DEBUG_LEVEL_QA_RELEASE)
end
function this.SplitString(e,l)
	local t={}
	local n
	local e=e
	while true do
		n=string.find(e,l)
		if(n==nil)then
			table.insert(t,e)break
		else
			local l=string.sub(e,0,n-1)table.insert(t,l)e=string.sub(e,n+1)
		end
	end
	return t
end
function this.StrCode32Table(n)
	local r={}
	for n,l in pairs(n)do
		local n=n
		if type(n)=="string"then
			n=StrCode32(n)
		end
		if type(l)=="table"then
			r[n]=this.StrCode32Table(l)
		else
			r[n]=l
		end
	end
	return r
end
function this.ApendArray(e,n)
	for t,n in pairs(n)do
		e[#e+1]=n
	end
end
function this.MergeTable(l,e,n)
	local n=l
	for e,t in pairs(e)do
		if l[e]==nil then
			n[e]=t
		else
			n[e]=t
		end
	end
	return n
end
function this.IsOnlineMode()
	return(GetUserModeTppGameModeFunc()==U_KONAMI_LOGINTppGameModeID)
end
function this.IsValidLocalOnlineChallengeTaskVersion()
	return(GetOnlineChallengeTaskVersion()==gvars.localOnlineChallengeTaskVersion)
end
function this.BfsPairs(r)
	local i,n,t={r},1,1
	local function o(l,e)
		local e,l=e,nil
		while true do
			e,l=next(i[n],e)
			if IsTypeTable(l)then
				t=t+1
				i[t]=l
			end
			if e then
				return e,l
			else
				n=n+1
				if n>t then
					return
				end
			end
		end
	end
	return o,r,nil
end
this._DEBUG_svars={}
this._DEBUG_gvars={}
function this.MakeMessageExecTable(n)
	if n==nil then
		return
	end
	if next(n)==nil then
		return
	end
	local e={}
	local T=StrCode32"msg"local d=StrCode32"func"local u=StrCode32"sender"local _=StrCode32"option"for n,l in pairs(n)do
		e[n]=e[n]or{}
		for l,r in pairs(l)do
			local l,s,c,o=l,nil,nil,nil
			if f(r)then
				c=r
			elseif IsTypeTable(r)and f(r[d])then
				l=StrCode32(r[T])
				local e={}
				if(type(r[u])=="string")or(type(r[u])=="number")then
					e[1]=r[u]
				elseif IsTypeTable(r[u])then
					e=r[u]
				end
				s={}
				for l,e in pairs(e)do
					if type(e)=="string"then
						if n==StrCode32"GameObject"then
							s[l]=GetGameObjectId(e)
							if msgSndr==NULL_ID then
							end
						else
							s[l]=StrCode32(e)
						end
					elseif type(e)=="number"then
						s[l]=e
					end
				end
				c=r[d]o=r[_]
			end
			if c then
				e[n][l]=e[n][l]or{}
				if next(s)~=nil then
					for r,t in pairs(s)do
						e[n][l].sender=e[n][l].sender or{}e[n][l].senderOption=e[n][l].senderOption or{}
						if e[n][l].sender[t]then
						end
						e[n][l].sender[t]=c
						if o and IsTypeTable(o)then
							e[n][l].senderOption[t]=o
						end
					end
				else
					if e[n][l].func then
					end
					e[n][l].func=c
					if o and IsTypeTable(o)then
						e[n][l].option=o
					end
				end
			end
		end
	end
	return e
end
function this.DoMessage(n,p,s,i,o,a,t,l,r)
	if not n then
		return
	end
	local n=n[s]
	if not n then
		return
	end
	local n=n[i]
	if not n then
		return
	end
	local i=true
	this.DoMessageAct(n,p,o,a,t,l,r,i)
end
function this.DoMessageAct(e,i,n,r,l,a,t)
	if e.func then
		if i(e.option)then
			e.func(n,r,l,a)
		end
	end
	local t=e.sender
	if t and t[n]then
		if i(e.senderOption[n])then
			t[n](n,r,l,a)
		end
	end
end
function this.GetRotationY(e)
	if not e then
		return
	end
	if(type(e.Rotate)=="function")then
		local e=e:Rotate(Vector3(0,0,1))
		local e=foxmath.Atan2(e:GetX(),e:GetZ())
		return TppMath.RadianToDegree(e)
	end
end
function this.GetLocator(n,t)
	local n,t=this.GetLocatorByTransform(n,t)
	if n~=nil then
		return TppMath.Vector3toTable(n),this.GetRotationY(t)
	else
		return nil
	end
end
function this.GetLocatorByTransform(t,n)
	local e=this.GetDataWithIdentifier(t,n,"TransformData")
	if e==nil then
		return
	end
	local e=e.worldTransform
	return e.translation,e.rotQuat
end
function this.GetDataWithIdentifier(n,e,t)
	local e=DataIdentifier.GetDataWithIdentifier(n,e)
	if e==NULL then
		return
	end
	if(e:IsKindOf(t)==false)then
		return
	end
	return e
end
function this.GetDataBodyWithIdentifier(e,t,n)
	local e=DataIdentifier.GetDataBodyWithIdentifier(e,t)
	if(e.data==nil)then
		return
	end
	if(e.data:IsKindOf(n)==false)then
		return
	end
	return e
end
function this.SetGameStatus(statusDetails)
	if not IsTypeTable(statusDetails)then
		return
	end
	local enable=statusDetails.enable
	local scriptName=statusDetails.scriptName
	local target=statusDetails.target
	local except=statusDetails.except
	if enable==nil then
		return
	end
	if target=="all"then
		target={}
		for statusType,value in pairs(TppDefine.UI_STATUS_TYPE_ALL)do
			target[statusType]=value
		end
		for statusType,value in pairs(TppDefine.GAME_STATUS_TYPE_ALL)do
			target[statusType]=value
		end
	elseif IsTypeTable(target)then
		target=target
	else
		return
	end
	if IsTypeTable(except)then
		for statusType,value in pairs(except)do
			target[statusType]=value
		end
	end
	if enable then
		for statusType,value in pairs(TppDefine.GAME_STATUS_TYPE_ALL)do
			if target[statusType]then
				TppGameStatus.Reset(scriptName,statusType)
			end
		end
		for statusType,value in pairs(TppDefine.UI_STATUS_TYPE_ALL)do
			local valueToSet=target[statusType]
			local ui_unsetUiSetting=mvars.ui_unsetUiSetting
			if IsTypeTable(ui_unsetUiSetting)and ui_unsetUiSetting[statusType]then
				TppUiStatusManager.UnsetStatus(statusType,ui_unsetUiSetting[statusType])
			else
				if valueToSet then
					TppUiStatusManager.ClearStatus(statusType)
				end
			end
		end
	else
		for statusType,value in pairs(TppDefine.UI_STATUS_TYPE_ALL)do
			local valueToSet=target[statusType]
			if valueToSet then
				TppUiStatusManager.SetStatus(statusType,valueToSet)
			else
				TppUiStatusManager.ClearStatus(statusType)
			end
		end
		for statusType,value in pairs(TppDefine.GAME_STATUS_TYPE_ALL)do
			local valueToSet=target[statusType]
			if valueToSet then
				TppGameStatus.Set(scriptName,statusType)
			end
		end
	end
	--r45 Show announce log during loading with Debug Mode On
	if TUPPMSettings._debug_ENABLE then
		TppUiStatusManager.ClearStatus("AnnounceLog") --rX44 DEBUG AID--
	end

	--r67 BUGIX: Demos were resetting marker and X-ray effect
	TUPPM.ChangeUIElementsForDemos()
end
function this.GetAllDisableGameStatusTable()
	local e={}
	for n,t in pairs(TppDefine.UI_STATUS_TYPE_ALL)do
		e[n]=false
	end
	for n,t in pairs(TppDefine.GAME_STATUS_TYPE_ALL)do
		e[n]=false
	end
	return e
end
function this.GetHelicopterStartExceptGameStatus()
	local e={}
	e.EquipPanel=false
	e.AnnounceLog=false
	e.HeadMarker=false
	e.WorldMarker=false
	return e
end
local function n(e,n)
	if e==nil then
		return
	end
	if e==NULL_ID then
		return
	end
	local e=GetTypeIndex(e)
	if e==n then
		return true
	else
		return false
	end
end
function this.IsPlayer(e)
	return n(e,GAME_OBJECT_TYPE_PLAYER2)
end
function this.IsLocalPlayer(e)
	if e==PlayerInfo.GetLocalPlayerIndex()then
		return true
	else
		return false
	end
end
function this.IsSoldier(e)
	return n(e,GAME_OBJECT_TYPE_SOLDIER2)
end
function this.IsCommandPost(e)
	return n(e,GAME_OBJECT_TYPE_COMMAND_POST2)
end
function this.IsHostage(e)
	if e==nil then
		return
	end
	if e==NULL_ID then
		return
	end
	local e=GetTypeIndex(e)
	return TppDefine.HOSTAGE_GM_TYPE[e]
end
function this.IsVolgin(e)
	return n(e,GAME_OBJECT_TYPE_VOLGIN2)
end
function this.IsHelicopter(e)
	return n(e,GAME_OBJECT_TYPE_HELI2)
end
function this.IsEnemyHelicopter(e)
	return n(e,GAME_OBJECT_TYPE_ENEMY_HELI)
end
function this.IsHorse(e)
	return n(e,GAME_OBJECT_TYPE_HORSE2)
end
function this.IsVehicle(e)
	return n(e,GAME_OBJECT_TYPE_VEHICLE)
end
function this.IsPlayerWalkerGear(e)
	return n(e,GAME_OBJECT_TYPE_WALKERGEAR2)
end
function this.IsEnemyWalkerGear(e)
	return n(e,GAME_OBJECT_TYPE_COMMON_WALKERGEAR2)
end
function this.IsUav(e)
	return n(e,GAME_OBJECT_TYPE_UAV)
end
function this.IsFultonContainer(e)
	return n(e,TppGameObject.GAME_OBJECT_TYPE_FULTONABLE_CONTAINER)
end
function this.IsMortar(e)
	return n(e,TppGameObject.GAME_OBJECT_TYPE_MORTAR)
end
function this.IsGatlingGun(e)
	return n(e,TppGameObject.GAME_OBJECT_TYPE_GATLINGGUN)
end
function this.IsMachineGun(e)
	return n(e,TppGameObject.GAME_OBJECT_TYPE_MACHINEGUN)
end
function this.IsFultonableGimmick(e)
	if e==nil then
		return
	end
	if e==NULL_ID then
		return
	end
	local e=GetTypeIndex(e)
	return TppDefine.FULTONABLE_GIMMICK_TYPE[e]
end
function this.GetBuddyTypeFromGameObjectId(e)
	if e==nil then
		return
	end
	if e==NULL_ID then
		return
	end
	local e=GetTypeIndex(e)
	return TppDefine.BUDDY_GM_TYPE_TO_BUDDY_TYPE[e]
end
function this.IsMarkerLocator(e)
	return n(e,GAME_OBJECT_TYPE_MARKER2_LOCATOR)
end
function this.IsAnimal(e)
	if e==nil then
		return
	end
	if e==NULL_ID then
		return
	end
	local e=GetTypeIndex(e)
	return TppDefine.ANIMAL_GAMEOBJECT_TYPE[e]
end
function this.IsBossQuiet(e)
	return n(e,GAME_OBJECT_TYPE_BOSSQUIET2)
end
function this.IsParasiteSquad(e)
	return n(e,GAME_OBJECT_TYPE_PARASITE2)
end
function this.IsSecurityCamera(e)
	return n(e,GAME_OBJECT_TYPE_SECURITYCAMERA2)
end
function this.IsGunCamera(e)
	if e==NULL_ID then
		return false
	end
	local t={id="IsGunCamera"}
	local n=false
	n=GameObject.SendCommand(e,t)
	return n
end
function this.IsUAV(e)
	return n(e,GAME_OBJECT_TYPE_UAV)
end
function this.IncrementPlayData(e)
	if gvars[e]==nil then
		return
	end
	if gvars[e]<TppDefine.MAX_32BIT_UINT then
		gvars[e]=gvars[e]+1
	end
end
function this.IsNotAlert()
	if vars.playerPhase<PHASE_ALERT then
		return true
	else
		return false
	end
end
function this.IsPlayerStatusNormal()
	local e=vars
	if e.playerLife>0 and e.playerStamina>0 then
		return true
	else
		return false
	end
end
function this.AreaToIndices(e)
	local n,r,l,t=e[1],e[2],e[3],e[4]
	local e={}
	for n=n,l do
		for t=r,t do
			table.insert(e,{n,t})
		end
	end
	return e
end
function this.CheckBlockArea(blockAreaValidTable,blockCoordX,blockCoordY)
	local block1,block2,block3,block4=blockAreaValidTable[1],blockAreaValidTable[2],blockAreaValidTable[3],blockAreaValidTable[4]
	if(((blockCoordX>=block1)and(blockCoordX<=block3))and(blockCoordY>=block2))and(blockCoordY<=block4)then
		return true
	end
	return false
end
function this.FillBlockArea(n,e,t,a,l,r)
	for e=e,a do
		n[e]=n[e]or{}
		for t=t,l do
			n[e][t]=r
		end
	end
end
function this.GetCurrentStageSmallBlockIndex()
	local e=2
	local n,t=StageBlock.GetCurrentMinimumSmallBlockIndex()
	return(n+e),(t+e)
end
function this.IsLoadedSmallBlock(l,t)
	local n=4
	local e,r=StageBlock.GetCurrentMinimumSmallBlockIndex()
	local a=e+n
	local n=e+n
	return((e<=l and a>=l)and r<=t)and n>=t
end
function this.IsLoadedLargeBlock(e)
	local n=StrCode32(e)
	local e=StageBlock.GetLoadedLargeBlocks(0)
	for t,e in pairs(e)do
		if e==n then
			return true
		end
	end
	return false
end
function this.GetLoadedLargeBlock()
	local e=StageBlock.GetLoadedLargeBlocks(0)
	for n,e in pairs(e)do
		return e
	end
	return nil
end
function this.GetChunkIndex(t,n)
	local e
	if n then
		e=Chunk.INDEX_MGO
	else
		e=TppDefine.LOCATION_CHUNK_INDEX_TABLE[t]
		if e==nil then
		end
		return e
	end
	return e
end
function this.StartWaitChunkInstallation(n)Chunk.PrefetchChunk(n)Chunk.SetChunkInstallSpeed(Chunk.INSTALL_SPEED_FAST)
	this.ClearChunkInstallPopupUpdateTime()
end
local l=1
local n=0
function this.ShowChunkInstallingPopup(t,r)
	local e=Time.GetFrameTime()n=n-e
	if n>0 then
		return
	end
	n=n+l
	if n<0 then
		n=0
	end
	local n=Fox.GetPlatformName()
	local e=Chunk.GetChunkInstallationEta(t)
	if e and n=="PS4"then
		if e>86400 then
			e=86400
		end
		TppUiCommand.SetErrorPopupParam(e)
	end
	local e=Chunk.GetChunkInstallationRate(t)
	if e and n=="XboxOne"then
		TppUiCommand.SetErrorPopupParam(e*1e4,"None",2)
	end
	local e
	if r then
		e=Popup.TYPE_ONE_CANCEL_BUTTON
	else
		TppUiCommand.SetPopupType"POPUP_TYPE_NO_BUTTON_NO_EFFECT"end
	TppUiCommand.ShowErrorPopup(TppDefine.ERROR_ID.NOW_INSTALLING,e)
end
function this.ClearChunkInstallPopupUpdateTime()n=0
end
function this.GetFormatedStorageSizePopupParam(e)
	local n=1024
	local t=1024*n
	local l=1024*t
	local a,r,l=e/l,e/t,e/n
	local n=0
	local t=""if a>=1 then
		n=a*100
		t="G"elseif r>=1 then
		n=r*100
		t="M"elseif l>=1 then
		n=l*100
		t="K"else
		return e,"",0
	end
	local e=math.ceil(n)
	return e,t,2
end
function this.PatchDlcCheckCoroutine(r,l,a,e)
	if e==nil then
		e=PatchDlc.PATCH_DLC_TYPE_MGO_DATA
	end
	local n={[PatchDlc.PATCH_DLC_TYPE_MGO_DATA]=true,[PatchDlc.PATCH_DLC_TYPE_TPP_COMPATIBILITY_DATA]=true}
	if not n[e]then
		Fox.Hungup"Invalid dlc type."return false
	end
	local function n(e)
	end
	local function t()
		if TppUiCommand.IsShowPopup()then
			TppUiCommand.ErasePopup()
			while TppUiCommand.IsShowPopup()do
				n"waiting popup closed..."coroutine.yield()
			end
		end
	end
	local function i()
		while TppSave.IsSaving()do
			n"waiting saving end..."coroutine.yield()
		end
	end
	i()PatchDlc.StartCheckingPatchDlc(e)
	if PatchDlc.IsCheckingPatchDlc()then
		if not a then
			t()
			local n={[PatchDlc.PATCH_DLC_TYPE_MGO_DATA]=5100,[PatchDlc.PATCH_DLC_TYPE_TPP_COMPATIBILITY_DATA]=5150}
			local e=n[e]
			TppUiCommand.SetPopupType"POPUP_TYPE_NO_BUTTON_NO_EFFECT"TppUiCommand.ShowErrorPopup(e)
		end
		while PatchDlc.IsCheckingPatchDlc()do
			n"waiting checking PatchDlc end..."coroutine.yield()
			TppUI.ShowAccessIconContinue()
		end
	end
	t()
	if PatchDlc.DoesExistPatchDlc(e)then
		if r then
			r()
		end
		return true
	else
		if l then
			l()
		end
		return false
	end
end
function this.IsPatchDlcValidPlatform(e)
	local n={[PatchDlc.PATCH_DLC_TYPE_MGO_DATA]={Xbox360=true,PS3=true,PS4=true},[PatchDlc.PATCH_DLC_TYPE_TPP_COMPATIBILITY_DATA]={Xbox360=true,PS3=true,PS4=true}}
	local e=n[e]
	if not e then
		Fox.Hungup"Invalid dlc type."return false
	end
	local n=Fox.GetPlatformName()
	if e[n]then
		return true
	else
		return false
	end
end
function this.ClearDidCancelPatchDlcDownloadRequest()
	if(vars.didCancelPatchDlcDownloadRequest==1)then
		vars.didCancelPatchDlcDownloadRequest=0
		vars.isPersonalDirty=1
		TppSave.CheckAndSavePersonalData()
	end
end
function this.DEBUG_DunmpBlockArea(t,l,e)
	local n="       "for e=1,e do
		n=n..string.format("%02d,",e)
	end
	for l=1,l do
		local n=""for e=1,e do
			n=n..string.format("%02d,",t[l][e])
		end
	end
end
function this.DEBUG_DumpTable(r,n)
	if n==nil then
	end
	if(type(r)~="table")then
		return
	end
	local l=""if n then
		for e=0,n do
			l=l.." "end
	end
	for r,l in pairs(r)do
		if type(l)=="table"then
			local n=n or 0
			n=n+1
			this.DEBUG_DumpTable(l,n)
		else
			if type(l)=="number"then
			end
		end
	end
end
function this.DEBUG_Where(e)
	local e=debug.getinfo(e+1)
	if e then
		return e.short_src..(":"..e.currentline)
	end
	return"(unknown)"end
function this.DEBUG_StrCode32ToString(e)
	if e~=nil then
		local n
		if(TppDbgStr32)then
			n=TppDbgStr32.DEBUG_StrCode32ToString(e)
		end
		if n then
			return n
		else
			if type(e)=="string"then
			end
			return tostring(e)
		end
	else
		return"nil"end
end
function this.DEBUG_Fatal(e,e)
end
function this.DEBUG_SetPreference(n,t,l)
	local n=Preference.GetPreferenceEntity(n)
	if(n==nil)then
		return
	end
	if(n[t]==nil)then
		return
	end
	Command.SetProperty{entity=n,property=t,value=l}
end
this._requireList={}do
	for t,n in ipairs(this.requires)do
		local n=this.SplitString(n,"/")
		local n=string.sub(n[#n],1,#n[#n]-4)
		local t={TppMain=true,TppDemoBlock=true,mafr_luxury_block_list=true}
		if not t[n]then
			this._requireList[#this._requireList+1]=n
		end
	end
end
return this
