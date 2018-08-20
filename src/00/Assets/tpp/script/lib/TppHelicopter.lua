local this={}
local n=Fox.StrCode32
local t=Tpp.IsTypeTable
local i=Tpp.IsTypeString
local a=GameObject.SendCommand
local o=GameObject.GetGameObjectId
local n=GameObject.NULL_ID
function this.GetSupportHeliGameObjectId()
  if not mvars.hel_isExistSupportHelicopter then
    return
  end
  return GameObject.GetGameObjectId("TppHeli2","SupportHeli")
end
function this.SetNoSupportHelicopter()
  mvars.hel_isExistSupportHelicopter=false
end
function this.UnsetNoSupportHelicopter()
  mvars.hel_isExistSupportHelicopter=true
end
function this.ForceCallToLandingZone(a)
--  TppPlayer.TUPPMPrint("Calling HELI to LandInGz0n3 ForceCallToLandingZone")
  if not t(a)then
    return
  end
  local t=a.landingZoneName
  if not i(t)then
    return
  end
  if not mvars.hel_isExistSupportHelicopter then
    return
  end
  local e=this.GetSupportHeliGameObjectId()
  if e~=n then
    GameObject.SendCommand(e,{id="CallToLandingZoneAtName",name=t})
    GameObject.SendCommand(e,{id="DisablePullOut"})
    GameObject.SendCommand(e,{id="EnableDescentToLandingZone"})
  else
    return
  end
end
function this.CallToLandingZone(a)
--  TppPlayer.TUPPMPrint("Calling HELI to LandInGz0n3 CallToLandingZone")
  if not t(a)then
    return
  end
  local t=a.landingZoneName
  if not i(t)then
    return
  end
  if not mvars.hel_isExistSupportHelicopter then
    return
  end
  local e=this.GetSupportHeliGameObjectId()
  if e~=n then
--    TppPlayer.TUPPMPrint("Calling HELI to LandInGz0n3 "..tostring(t))
    GameObject.SendCommand(e,{id="CallToLandingZoneAtName",name=t})
    GameObject.SendCommand(e,{id="EnableDescentToLandingZone"})
  else
    return
  end
end
function this.SetEnableLandingZone(a)
  if not t(a)then
    return
  end
  local t=a.landingZoneName
  if not i(t)then
    return
  end
  if not mvars.hel_isExistSupportHelicopter then
    return
  end
  local e=this.GetSupportHeliGameObjectId()
  if e~=n then
    GameObject.SendCommand(e,{id="EnableLandingZone",name=t})
  else
    return
  end
end
function this.SetDisableLandingZone(a)
  if not t(a)then
    return
  end
  local t=a.landingZoneName
  if not i(t)then
    return
  end
  if not mvars.hel_isExistSupportHelicopter then
    return
  end
  local e=this.GetSupportHeliGameObjectId()
  if e~=n then
    GameObject.SendCommand(e,{id="DisableLandingZone",name=t})
  else
    return
  end
end
function this.GetLandingZoneExists(a)
  if not t(a)then
    return
  end
  local t=a.landingZoneName
  if not i(t)then
    return
  end
  if not mvars.hel_isExistSupportHelicopter then
    return
  end
  local e=this.GetSupportHeliGameObjectId()
  if e~=n then
    return GameObject.SendCommand(e,{id="DoesLandingZoneExists",name=t})
  else
    return false
  end
end
function this.SetNewestPassengerTable()
  if not mvars.hel_isExistSupportHelicopter then
    this.ClearPassengerTable()
    return
  end
  local i
  local e=this.GetSupportHeliGameObjectId()
  if e~=n then
    i=a(e,{id="GetPassengerIdsStaffOnly"})
    mvars.hel_passengerListGameObjectId=e
  else
    return
  end
  if not t(i)or next(i)==nil then
    return
  end
  mvars.hel_heliPassengerTable={}
  for n,e in ipairs(i)do
    mvars.hel_heliPassengerTable[e]=true
  end
  mvars.hel_heliPassengerList=i
  mvars.hel_passengerListGameObjectId=e
end
function this.GetPassengerlist()
  return mvars.hel_heliPassengerList
end
function this.ClearPassengerTable()
  if mvars.hel_passengerListGameObjectId then
    a(mvars.hel_passengerListGameObjectId,{id="InitializePassengers"})
  end
  mvars.hel_passengerListGameObjectId=nil
  mvars.hel_heliPassengerTable=nil
  mvars.hel_heliPassengerList=nil
end
function this.IsInHelicopter(n)
  if not t(mvars.hel_heliPassengerTable)then
    return
  end
  local e
  if Tpp.IsTypeString(n)then
    e=o(n)
  else
    e=n
  end
  return mvars.hel_heliPassengerTable[e]
end
function this.ForcePullOut()
  GameObject.SendCommand({type="TppHeli2",index=0},{id="PullOut",forced=true})
end
function this.AdjustBuddyDropPoint()
  if gvars.heli_missionStartRoute~=0 then
    TppBuddyService.AdjustFromDropPoint(gvars.heli_missionStartRoute,EntryBuddyType.BUDDY,6,3.14)
    TppBuddyService.AdjustFromDropPoint(gvars.heli_missionStartRoute,EntryBuddyType.VEHICLE,6,0)
  end
end
function this.Init(t)
  local i=o("TppHeli2","SupportHeli")
  if i==n then
    mvars.hel_isExistSupportHelicopter=false
    return
  end
  mvars.hel_isExistSupportHelicopter=true
  if TppMission.IsCanMissionClear()then
    this.SetNoTakeOffTime()
  else
    this.SetDefaultTakeOffTime()
  end
  if gvars.ply_initialPlayerState~=TppDefine.INITIAL_PLAYER_STATE.RIDEON_HELICOPTER then
    return
  end
  local e=nil
  if(t.sequence and t.sequence.missionStartPosition)and t.sequence.missionStartPosition.helicopterRouteList then
    if not Tpp.IsTypeFunc(t.sequence.missionStartPosition.IsUseRoute)or t.sequence.missionStartPosition.IsUseRoute()then
      e=t.sequence.missionStartPosition.helicopterRouteList
    end
  end
  if e==nil then
    return
  end
  if TppMission.IsHelicopterSpace(vars.missionCode)then
    GameObject.SendCommand(i,{id="Realize"})
  else
    if gvars.heli_missionStartRoute~=0 then
      if not svars.ply_isUsedPlayerInitialAction then
        GameObject.SendCommand(i,{id="SendPlayerAtRouteReady",route=gvars.heli_missionStartRoute})
      end
    end
  end
end
function this.SetDefaultTakeOffTime()
--  TppPlayer.TUPPMPrint("SetDefaultTakeOffTime()")
--  TppPlayer.TUPPMPrint("TppGameObject.PHASE_ALERT"..tostring(TppGameObject.PHASE_ALERT)) --PHASE_ALERT3
--  local currentPhase
--  local isCombatAlert = false
--  if mvars.ene_soldierIDList then
--    for cpId,soldierIds in pairs(mvars.ene_soldierIDList) do
--      currentPhase = TppEnemy.GetPhaseByCPID(cpId)
--      TppPlayer.TUPPMPrint("currentPhase"..tostring(currentPhase))
--      if currentPhase == TppGameObject.PHASE_ALERT then
--        isCombatAlert=true
--      end
--    end
--  end
--  if isCombatAlert then
--    TppPlayer.TUPPMPrint("is alert so pulling out instantly") --WIP
--    this.SetNoTakeOffTime()
--    return
--  end
  local e=this.GetSupportHeliGameObjectId()
  if(e==nil)then
    return
  end
  if e==n then
    return
  end
  GameObject.SendCommand(e,{id="SetTakeOffWaitTime",time=5})
end
function this.SetNoTakeOffTime()
  local e=this.GetSupportHeliGameObjectId()
  if(e==nil)then
    return
  end
  if e==n then
    return
  end
  GameObject.SendCommand(e,{id="SetTakeOffWaitTime",time=0})
end
function this.SetRouteToHelicopterOnStartMission()
  local e=this.GetSupportHeliGameObjectId()
  if(e==nil)then
    return
  end
  if e==n then
    return
  end
  if gvars.heli_missionStartRoute~=0 then
    --rX45 If this is skipped the heli can be set directly to LZ using SendPlayerAtRouteReady - however!
    -- The heli will be on a route, calls to LZ do not work and as a result cannot get out of the damned thing as far as I tested
    --Plus retries get fucked as the initial state is in heli and we are skipping the below condition
    --Even a TppMain.firstFakeHeli==0 fucks up cause then a retry would mean starting all the way from the correct heli LZ route
    --TODO rX45 look into short heli rides further
    --GameObject.SendCommand(e,{id="SendPlayerAtRouteStart",isAssault=TppLandingZone.IsAssaultDropLandingZone(gvars.heli_missionStartRoute)})
    
    --rX45 This is definitely to do with demos
--    GameObject.SendCommand(e,{id="SetDemoToAfterDropEnabled",enabled=true,route=gvars.heli_missionStartRoute, isTakeOff=false})
  end
end
function this.ResetMissionStartHelicopterRoute()
  gvars.heli_missionStartRoute=0
end
function this.GetMissionStartHelicopterRoute()
  return gvars.heli_missionStartRoute
end
local n={[TppDefine.ENEMY_HELI_COLORING_TYPE.DEFAULT]={pack="",fova=""},[TppDefine.ENEMY_HELI_COLORING_TYPE.BLACK]={pack="/Assets/tpp/pack/fova/mecha/sbh/sbh_ene_blk.fpk",fova="/Assets/tpp/fova/mecha/sbh/sbh_ene_blk.fv2"},[TppDefine.ENEMY_HELI_COLORING_TYPE.RED]={pack="/Assets/tpp/pack/fova/mecha/sbh/sbh_ene_red.fpk",fova="/Assets/tpp/fova/mecha/sbh/sbh_ene_red.fv2"}}
function this.GetEnemyColoringPack(e)
  return n[e].pack
end
function this.SetEnemyColoring(e)a({type="TppEnemyHeli",index=0},{id="SetColoring",coloringType=e,fova=n[e].fova})
end
return this
