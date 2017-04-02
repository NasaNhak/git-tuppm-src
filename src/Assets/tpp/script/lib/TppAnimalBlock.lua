local this={}
local GetCurrentScriptBlockId=ScriptBlock.GetCurrentScriptBlockId
local GetScriptBlockState=ScriptBlock.GetScriptBlockState
local NULL_ID=GameObject.NULL_ID
local IsTypeTable=Tpp.IsTypeTable
local IsTypeString=Tpp.IsTypeString
local animal_blockName="animal_block"
local CheckBlockArea=Tpp.CheckBlockArea
local animalDetailsParamsTable={
  Goat={
    type="TppGoat",
    locatorFormat="anml_goat_%02d",
    routeFormat="rt_anml_goat_%02d",
    nightRouteFormat="rt_anml_goat_n%02d",
    isHerd=true,
    isDead=false},
  Wolf={
    type="TppWolf",
    locatorFormat="anml_wolf_%02d",
    routeFormat="rt_anml_wolf_%02d",
    nightRouteFormat="rt_anml_wolf_n%02d",
    isHerd=true,
    isDead=false},
  Nubian={
    type="TppNubian",
    locatorFormat="anml_nubian_%02d",
    routeFormat="rt_anml_nubian_%02d",
    nightRouteFormat="rt_anml_nubian_n%02d",
    isHerd=true,
    isDead=false},
  Jackal={
    type="TppJackal",
    locatorFormat="anml_jackal_%02d",
    routeFormat="rt_anml_jackal_%02d",
    nightRouteFormat="rt_anml_jackal_n%02d",
    isHerd=true,
    isDead=false},
  Zebra={
    type="TppZebra",
    locatorFormat="anml_Zebra_%02d",
    routeFormat="rt_anml_Zebra_%02d",
    nightRouteFormat="rt_anml_Zebra_n%02d",
    isHerd=true,
    isDead=false},
  Bear={
    type="TppBear",
    locatorFormat="anml_bear_%02d",
    routeFormat="rt_anml_bear_%02d",
    nightRouteFormat="rt_anml_bear_n%02d",
    isHerd=false,
    isDead=false},
  BuddyPuppy={
    type="TppBuddyPuppy",
    locatorFormat="anml_BuddyPuppy_%02d",
    routeFormat="rt_anml_BuddyPuppy_%02d",
    nightRouteFormat="rt_anml_BuddyPuppy_%02d",
    isHerd=false,
    isDead=false},
  MotherDog={
    type="TppJackal",
    locatorFormat="anml_MotherDog_%02d",
    routeFormat="rt_anml_BuddyPuppy_%02d",
    nightRouteFormat="rt_anml_BuddyPuppy_%02d",
    isHerd=false,
    isDead=true},
  Rat={
    type="TppRat",
    locatorFormat="anml_rat_%02d",
    routeFormat="rt_anml_rat_%02d",
    nightRouteFormat="rt_anml_rat_%02d",
    isHerd=false,
    isDead=false},
  NoAnimal={
    type="NoAnimal",
    locatorFormat="anml_NoAnimal_%02d",
    routeFormat="rt_anml_BuddyPuppy_%02d",
    nightRouteFormat="rt_anml_BuddyPuppy_%02d",
    isHerd=false,
    isDead=false}}

local animalNightTimesTable={
  Goat={
    nightStartTime="18:00:00",
    nightEndTime="06:00:00",
    timeLag="00:10:00"},
  Wolf={
    nightStartTime="18:00:00",
    nightEndTime="06:00:00",
    timeLag="00:10:00"},
  Bear={
    nightStartTime="18:00:00",
    nightEndTime="06:00:00",
    timeLag="00:10:00"},
  Nubian={
    nightStartTime="18:00:00",
    nightEndTime="06:00:00",
    timeLag="00:10:00"},
  Jackal={
    nightStartTime="18:00:00",
    nightEndTime="06:00:00",
    timeLag="00:10:00"},
  Zebra={
    nightStartTime="18:00:00",
    nightEndTime="06:00:00",
    timeLag="00:10:00"},
  BuddyPuppy={
    nightStartTime="18:00:00",
    nightEndTime="06:00:00",
    timeLag="00:10:00"},
  MotherDog={
    nightStartTime="18:00:00",
    nightEndTime="06:00:00",
    timeLag="00:10:00"},
  Rat={
    nightStartTime="18:00:00",
    nightEndTime="06:00:00",
    timeLag="00:10:00"},
  NoAnimal={
    nightStartTime="18:00:00",
    nightEndTime="06:00:00",
    timeLag="00:10:00"}
}
local numberDef100=100
this.CLOCK_MESSAGE_AT_NIGHT_FORMAT="AnimalRouteChangeAtNight%02d"
this.CLOCK_MESSAGE_AT_MORNING_FORMAT="AnimalRouteChangeAtMorning%02d"
this.weatherTable={}
local number1Def0=0
local number2Def0=0

function this.GetDefaultTimeTable(animalName)
  if animalName=="Goat"then
    return animalNightTimesTable.Goat
  elseif animalName=="Wolf"then
    return animalNightTimesTable.Wolf
  elseif animalName=="Bear"then
    return animalNightTimesTable.Bear
  elseif animalName=="Nubian"then
    return animalNightTimesTable.Nubian
  elseif animalName=="Jackal"then
    return animalNightTimesTable.Jackal
  elseif animalName=="Zebra"then
    return animalNightTimesTable.Zebra
  elseif animalName=="BuddyPuppy"then
    return animalNightTimesTable.BuddyPuppy
  elseif animalName=="MotherDog"then
    return animalNightTimesTable.MotherDog
  elseif animalName=="Rat"then
    return animalNightTimesTable.Rat
  elseif animalName=="NoAnimal"then
    return animalNightTimesTable.NoAnimal
  else
    return nil
  end
end

function this.StopAnimalBlockLoad()
  mvars.anm_stopAnimalBlockLoad=true
end

function this.UpdateLoadAnimalBlock(i,o)
  if mvars.anm_stopAnimalBlockLoad then
    return
  end
  local mvars=mvars
  local loc_locationAnimalSettingTable=mvars.loc_locationAnimalSettingTable
  local animalAreaSetting=loc_locationAnimalSettingTable.animalAreaSetting
  loc_locationAnimalSettingTable.MAX_AREA_NUM=loc_locationAnimalSettingTable.MAX_AREA_NUM*3
  local MAX_AREA_NUM=loc_locationAnimalSettingTable.MAX_AREA_NUM
  if not MAX_AREA_NUM then
    return
  end
  local animalBlockKeyName,animalBlockAreaName=this._GetAnimalBlockAreaName(animalAreaSetting,MAX_AREA_NUM,"loadArea",i,o)
  if animalBlockKeyName~=nil then
    mvars.animalBlockAreaName=animalBlockAreaName
    mvars.animalBlockKeyName=animalBlockKeyName
    TppScriptBlock.Load(animal_blockName,animalBlockKeyName)
  else
    mvars.animalBlockAreaName=nil
    mvars.animalBlockKeyName=nil
    TppScriptBlock.Unload(animal_blockName)
  end
end

function this.GetCurrentAnimalBlockAreaName()
  local animalBlockAreaName=mvars.animalBlockAreaName
  if animalBlockAreaName==nil then
  end
  return animalBlockAreaName
end

function this._UpdateActiveAnimalBlock(a,o)
  local loc_locationAnimalSettingTable=mvars.loc_locationAnimalSettingTable
  local animalAreaSetting=loc_locationAnimalSettingTable.animalAreaSetting
  loc_locationAnimalSettingTable.MAX_AREA_NUM=loc_locationAnimalSettingTable.MAX_AREA_NUM*3
  local MAX_AREA_NUM=loc_locationAnimalSettingTable.MAX_AREA_NUM
  if not MAX_AREA_NUM then
    return
  end
  local animalBlockKeyName,animalBlockAreaName=this._GetAnimalBlockAreaName(animalAreaSetting,MAX_AREA_NUM,"activeArea",a,o)
  if animalBlockAreaName~=nil then
    local e=ScriptBlock.GetScriptBlockId(animal_blockName)
    TppScriptBlock.ActivateScriptBlockState(e)
  else
    local e=ScriptBlock.GetScriptBlockId(animal_blockName)
    TppScriptBlock.DeactivateScriptBlockState(e)
  end
end

function this._GetAnimalBlockAreaName(animalAreaSetting,MAX_AREA_NUM,areaLoadType,n,a)
  local localAnimalAreaSetting=animalAreaSetting
  for areaNumCount=1,MAX_AREA_NUM do
    local t=animalAreaSetting[areaNumCount]
    local e=t[areaLoadType]
    if CheckBlockArea(e,n,a)then
      for a,e in ipairs(t.defines)do
        if(not Tpp.IsTypeFunc(e.conditionFunc))or(e.conditionFunc())then
          local a=TppClock.GetTime"number"
          return e.keyList[a%#e.keyList+1],t.areaName
        end
      end
    end
  end
end

function this._GetSetupTable(animalName)
  if animalName=="Goat"then
    return animalDetailsParamsTable.Goat
  elseif animalName=="Wolf"then
    return animalDetailsParamsTable.Wolf
  elseif animalName=="Bear"then
    return animalDetailsParamsTable.Bear
  elseif animalName=="Nubian"then
    return animalDetailsParamsTable.Nubian
  elseif animalName=="Jackal"then
    return animalDetailsParamsTable.Jackal
  elseif animalName=="Zebra"then
    return animalDetailsParamsTable.Zebra
  elseif animalName=="BuddyPuppy"then
    return animalDetailsParamsTable.BuddyPuppy
  elseif animalName=="MotherDog"then
    return animalDetailsParamsTable.MotherDog
  elseif animalName=="Rat"then
    return animalDetailsParamsTable.Rat
  elseif animalName=="NoAnimal"then
    return animalDetailsParamsTable.NoAnimal
  else
    return nil
  end
end

function this._IsNight(currentTime,nightStartTimeNumber,nightEndTimeNumber)
  local isNight=(currentTime<nightEndTimeNumber)or(currentTime>=nightStartTimeNumber)
  return isNight
end

function this._IsNightForAnimalType(animalName,currentTime)
  local timeTable=this.GetDefaultTimeTable(animalName)
  local nightStartTime=timeTable.nightStartTime
  local nightStartTimeNumber=TppClock.ParseTimeString(nightStartTime,"number")
  local nightEndTime=timeTable.nightEndTime
  local nightEndTimeNumber=TppClock.ParseTimeString(nightEndTime,"number")
  return this._IsNight(currentTime,nightStartTimeNumber,nightEndTimeNumber)
end

function this._InitializeCommonAnimalSetting(animalType,animalDetails,animalSetupTable)
  local groupNumber=1
  if IsTypeTable(animalDetails)then
    groupNumber=animalDetails.groupNumber*3 or 0
  end
  local n=animalDetails.nightStartTime
  if n==nil then
    n=this.GetDefaultTimeTable(animalType).nightStartTime
  end
  local r=TppClock.ParseTimeString(n,"number")
  local n=animalDetails.nightEndTime
  if n==nil then
    n=this.GetDefaultTimeTable(animalType).nightEndTime
  end
  local c=TppClock.ParseTimeString(n,"number")
  local n=animalDetails.timeLag
  if n==nil then
    n=this.GetDefaultTimeTable(animalType).timeLag
  end
  local o=TppClock.ParseTimeString(n,"number")
  local i=TppClock.GetTime"number"local n=0
  if animalSetupTable.isDead==false then
    if animalSetupTable.isHerd==false then
      for a=0,(groupNumber-1)do
        n=o*a
        if this._IsNight(i,r+n,c+n)then
          this._SetRoute(animalSetupTable.type,animalSetupTable.locatorFormat,animalSetupTable.nightRouteFormat,a)
        else
          this._SetRoute(animalSetupTable.type,animalSetupTable.locatorFormat,animalSetupTable.routeFormat,a)
        end
      end
    else
      for a=0,(groupNumber-1)do
        n=o*a
        if this._IsNight(i,r+n,c+n)then
          this._SetHerdRoute(animalSetupTable.type,animalSetupTable.locatorFormat,animalSetupTable.nightRouteFormat,a)
        else
          this._SetHerdRoute(animalSetupTable.type,animalSetupTable.locatorFormat,animalSetupTable.routeFormat,a)
        end
      end
    end
  else
    this._ChangeDeadState(animalSetupTable.type,animalDetails.position,animalDetails.degRotationY)
  end
end

function this._SetHerdRoute(e,a,n,t)
  local e={type=e,index=0}
  if e==NULL_ID then
    return
  end
  local a=string.format(a,t)
  local t=string.format(n,t)
  local t={id="SetHerdEnabledCommand",type="Route",name=a,instanceIndex=0,route=t}
  GameObject.SendCommand(e,t)
end

function this._SetRoute(e,a,n,t)
  local e={type=e,index=0}
  if e==NULL_ID then
    return
  end
  local a=string.format(a,t)
  local t=string.format(n,t)
  local t={id="SetRoute",name=a,route=t}
  GameObject.SendCommand(e,t)
end

function this._ChangeDeadState(type,position,degRotation)
  local animalTypeId={type=type,index=0}
  if animalTypeId==NULL_ID then
    return
  end
  local position=position or Vector3(0,0,0)
  local degRotation=degRotation or 0
  local command={id="ChangeDeadState",position=position,degRotationY=degRotation}
  GameObject.SendCommand(animalTypeId,command)
end

function this._RegisterWeatherTable(t,a,n)
this.weatherTable[number1Def0]={msg="Clock",sender=t,func=
  function(l,a)
    if n then
      n(t,a)
    else
      this._ChangeRouteAtTime(t,a)
    end
  end}number1Def0=number1Def0+1
end

function this._RegisterClockMessage(t,i,o,n,a,l)
  local t=string.format(t,a)this._RegisterWeatherTable(t,n,l)
  local e=i+o*a
  local e=TppClock.FormalizeTime(e,"string")
  TppClock.RegisterClockMessage(t,e)
  return t
end

function this._AddClockMessage(n,animalDetails,a,r)
  local groupNumber=1
  if IsTypeTable(animalDetails)then
    groupNumber=animalDetails.groupNumber*3 or 0
  end
  if r+groupNumber>numberDef100 then
    return
  end
  local m=r+groupNumber
  local a=animalDetails.nightStartTime
  if a==nil then
    a=this.GetDefaultTimeTable(n).nightStartTime
  end
  local c=TppClock.ParseTimeString(a,"number")
  local a=animalDetails.nightEndTime
  if a==nil then
    a=this.GetDefaultTimeTable(n).nightEndTime
  end
  local i=TppClock.ParseTimeString(a,"number")
  local t=animalDetails.timeLag
  if t==nil then
    t=this.GetDefaultTimeTable(n).timeLag
  end
  local t=TppClock.ParseTimeString(t,"number")number1Def0=0
  for a=r,m-1 do
    this._RegisterClockMessage(this.CLOCK_MESSAGE_AT_NIGHT_FORMAT,c,t,true,a)
    this._RegisterClockMessage(this.CLOCK_MESSAGE_AT_MORNING_FORMAT,i,t,false,a)
    number2Def0=number2Def0+1
  end
end

function this._ChangeRouteAtTime(t,m)
  local locationAnimalSettingsTable=mvars.loc_locationAnimalSettingTable
  local areaAnimalSettingsTable=locationAnimalSettingsTable.animalTypeSetting[mvars.animalBlockKeyName]
  local a=-1
  for e in string.gmatch(t,"%d+")do
    a=tonumber(e)
  end
  if a==-1 then
    return
  end
  local l=0
  local n=nil
  local r=nil
  for animalType,animalTypeDetails in pairs(areaAnimalSettingsTable)do
    local o
    local animalDetails
    if IsTypeString(animalTypeDetails)then
      o=animalTypeDetails
    elseif IsTypeTable(animalTypeDetails)then
      o=animalType
      animalDetails=animalTypeDetails
    end
    local groupNumber=animalDetails.groupNumber*3 or 0
    if l<=a and a<l+groupNumber then
      n=o
      r=animalDetails
      break
    end
    l=l+groupNumber
  end
  if n==nil or r==nil then
    return
  end
  local animalSetupTable=this._GetSetupTable(n)
  if animalSetupTable==nil then
    return
  end
  local a=a-l
  local l=this._IsNightForAnimalType(n,m)
  if n=="Bear"then
    if l then
      this._SetRoute(animalSetupTable.type,animalSetupTable.locatorFormat,animalSetupTable.nightRouteFormat,a)
    else
      this._SetRoute(animalSetupTable.type,animalSetupTable.locatorFormat,animalSetupTable.routeFormat,a)
    end
  else
    if l then
      this._SetHerdRoute(animalSetupTable.type,animalSetupTable.locatorFormat,animalSetupTable.nightRouteFormat,a)
    else
      this._SetHerdRoute(animalSetupTable.type,animalSetupTable.locatorFormat,animalSetupTable.routeFormat,a)
    end
  end
end

function this._MakeMessageExecTable()
  mvars.animalBlockScript.messageExecTable=Tpp.MakeMessageExecTable(mvars.animalBlockScript.Messages)
end

function this._GetAnimalBlockState()
  local e=ScriptBlock.GetScriptBlockId(animal_blockName)
  if e==ScriptBlock.SCRIPT_BLOCK_ID_INVALID then
    return
  end
  return ScriptBlock.GetScriptBlockState(e)
end

function this.InitializeBlockStatus()
  local e=ScriptBlock.GetScriptBlockId(animal_blockName)
  if e==ScriptBlock.SCRIPT_BLOCK_ID_INVALID then
    return
  end
  TppScriptBlock.ClearSavedScriptBlockInfo(e)
end

function this.OnActivateAnimalBlock(e)
  for e,e in pairs(e)do
  end
end

function this.OnInitializeAnimalBlock()
  coroutine.yield()
  coroutine.yield()
  if not mvars.animalBlockKeyName then
    return
  end
  mvars.animalBlockScript.DidInitialized=true
  mvars.animalBlockScript.Messages=Tpp.StrCode32Table{
    Block=
    {
      {
        msg="StageBlockCurrentSmallBlockIndexUpdated",
        func=function(t,a)
          this._UpdateActiveAnimalBlock(t,a)
        end}
    }
  }
  number2Def0=0
  this.weatherTable={}
  local locationAnimalSettingsTable=mvars.loc_locationAnimalSettingTable
  local areaAnimalSettingsTable=locationAnimalSettingsTable.animalTypeSetting[mvars.animalBlockKeyName]
  local l=0
  for animalType,animalTypeDetails in pairs(areaAnimalSettingsTable)do
    local animalType
    local animalDetails
    if IsTypeString(animalTypeDetails)then
      animalType=animalTypeDetails
    elseif IsTypeTable(animalTypeDetails)then
      animalType=animalType
      animalDetails=animalTypeDetails
    end
    local animalSetupTable=this._GetSetupTable(animalType)
    if animalSetupTable~=nil and animalType~="NoAnimal"then
      this._InitializeCommonAnimalSetting(animalType,animalDetails,animalSetupTable)
      this._AddClockMessage(animalType,animalDetails,animalSetupTable,l)
      TppFreeHeliRadio.RegistAnimalOptionalRadio(animalType)
      local groupNumber=animalDetails.groupNumber*3 or 0
      l=l+groupNumber
    end
  end
  local t=Tpp.StrCode32Table{Weather=this.weatherTable}
  mvars.animalBlockScript.Messages=Tpp.MergeTable(mvars.animalBlockScript.Messages,t,false)
  mvars.animalBlockScript.OnReload=this.OnReload

  function mvars.animalBlockScript.OnMessage(a,n,t,l,i,r,o)
    Tpp.DoMessage(mvars.animalBlockScript.messageExecTable,TppMission.CheckMessageOption,a,n,t,l,i,r,o)
  end
  this._MakeMessageExecTable()
end

function this.OnReload()
  if not mvars.loc_locationAnimalSettingTable or not mvars.animalBlockKeyName then
    return
  end
  local t=mvars.loc_locationAnimalSettingTable
  local t=t.animalTypeSetting[mvars.animalBlockKeyName]
  local a=0
  for r,n in pairs(t)do
    local t
    local l
    if IsTypeString(n)then
      t=n
    elseif IsTypeTable(n)then
      t=r
      l=n
    end
    local animalSetupTable=this._GetSetupTable(t)
    if animalSetupTable~=nil and t~="NoAnimal"then
      local groupNumber=l.groupNumber*3 or 0
      if a+groupNumber>numberDef100 then
        break
      end
      a=a+groupNumber
    end
  end
  number2Def0=a
  this._MakeMessageExecTable()
end

function this.OnAllocate(a)
  local t=GetCurrentScriptBlockId()
  TppScriptBlock.InitScriptBlockState(t)
  mvars.animalBlockScript=a
  local t,a=Tpp.GetCurrentStageSmallBlockIndex()
  this._UpdateActiveAnimalBlock(t,a)
  function mvars.animalBlockScript.OnMessage(e,e,e,e,e,e,e)
  end
end

function this.OnTerminate()
  if mvars.animalBlockScript.DidInitialized then
    for a=0,number2Def0-1 do
      local t=string.format(this.CLOCK_MESSAGE_AT_NIGHT_FORMAT,a)
      TppClock.UnregisterClockMessage(t)t=string.format(this.CLOCK_MESSAGE_AT_MORNING_FORMAT,a)
      TppClock.UnregisterClockMessage(t)
    end
  end
  local e=GetCurrentScriptBlockId()
  TppScriptBlock.FinalizeScriptBlockState(e)
  TppFreeHeliRadio.UnregistAnimalOptionalRadio()
  mvars.animalBlockScript.DidInitialized=nil
  mvars.animalBlockScript.OnReload=nil
  mvars.animalBlockScript.OnMessage=nil
  mvars.animalBlockScript=nil
end
return this
