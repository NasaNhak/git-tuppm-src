--r16
--Sandstorms, Rain and Fog in Afghanistan and Africa
--Rain and Fog in Motherbase adjusted
local this={}
local secondsInMinute=60
local secondsInHour=60*60
local normalWeatherTypes={
	AFGH={{TppDefine.WEATHER.SUNNY,80},{TppDefine.WEATHER.CLOUDY,20}},
	MAFR={{TppDefine.WEATHER.SUNNY,70},{TppDefine.WEATHER.CLOUDY,30}},
	MTBS={{TppDefine.WEATHER.SUNNY,80},{TppDefine.WEATHER.CLOUDY,20}},
	AFGH_NO_SANDSTORM={{TppDefine.WEATHER.SUNNY,80},{TppDefine.WEATHER.CLOUDY,20}}
}
local weatherDurations={
	{TppDefine.WEATHER.SUNNY,5*secondsInHour,8*secondsInHour},
	{TppDefine.WEATHER.CLOUDY,3*secondsInHour,5*secondsInHour},
	{TppDefine.WEATHER.SANDSTORM,13*secondsInMinute,20*secondsInMinute},
	{TppDefine.WEATHER.RAINY,1*secondsInHour,2*secondsInHour},
	{TppDefine.WEATHER.FOGGY,13*secondsInMinute,20*secondsInMinute}
}
local specialWeatherTypes={
	AFGH={{TppDefine.WEATHER.SANDSTORM,100}},
	MAFR={{TppDefine.WEATHER.RAINY,100}},
	MTBS={{TppDefine.WEATHER.RAINY,50},{TppDefine.WEATHER.FOGGY,50}},
	AFGH_HELI={},
	MAFR_HELI={{TppDefine.WEATHER.RAINY,100}},
	MTBS_HELI={{TppDefine.WEATHER.RAINY,100}},
	AFGH_NO_SANDSTORM={}
}
local weatherTypesToChangeOnMissionStart={
	[TppDefine.WEATHER.SANDSTORM]=true,
	[TppDefine.WEATHER.FOGGY]=true
}
local stringScript="Script"
local stringWeatherSystem="WeatherSystem"
local interpTime=20
local extraPriority=255

function this.RequestWeather(weatherType,interpTime,fogDetailsTable)
--	--rX51 Settings
--	if (TUPPMSettings.weather_ENABLE_keepCurrentWeatherBetweenTransitions 
--		and not TppMission.IsFOBMission(vars.missionCode)) then
----			TUPPMLog.Log("TppWeather.RequestWeather early return",3,true)
--			return
--	end

	local interpTime,fogDetailsTable=this._GetRequestWeatherArgs(interpTime,fogDetailsTable)
	WeatherManager.PauseNewWeatherChangeRandom(true)
	if interpTime==nil then
		interpTime=interpTime
	end
	WeatherManager.RequestWeather{
		priority=WeatherManager.REQUEST_PRIORITY_NORMAL,
		userId=stringScript,
		weatherType=weatherType,
		interpTime=interpTime,
		fogDensity=fogDetailsTable.fogDensity,
		fogType=fogDetailsTable.fogType
	}
end

function this.CancelRequestWeather(t,r,i)
--	--rX51 Settings
--	if (TUPPMSettings.weather_ENABLE_keepCurrentWeatherBetweenTransitions 
--		and not TppMission.IsFOBMission(vars.missionCode)) then
----			TUPPMLog.Log("TppWeather.CancelRequestWeather early return",3,true)
--			return
--	end

	local e,r=this._GetRequestWeatherArgs(r,i)
	WeatherManager.PauseNewWeatherChangeRandom(false)
	if e==nil then
		e=interpTime
	end
	if t~=nil then
		WeatherManager.RequestWeather{priority=WeatherManager.REQUEST_PRIORITY_NORMAL,userId=stringScript,weatherType=t,interpTime=e,fogDensity=r.fogDensity,fogType=r.fogType}
	end
end

function this.ForceRequestWeather(weatherType,t,i)
	--This is called for sortie prep weather too!
	--The game's code is utter bullshit. Why bother creating Lua scripts when demos/mission events are HARDCODED else where to force weather effects? Ridiculous

--	--rX51 Settings
--	if (TUPPMSettings.weather_ENABLE_keepCurrentWeatherBetweenTransitions 
--		and not TppMission.IsFOBMission(vars.missionCode)) then
--			TUPPMLog.Log("TppWeather.ForceRequestWeather early return",3,true)
--			return
--	end
	
	local interpTime,t=this._GetRequestWeatherArgs(t,i)
	if interpTime==nil then
		interpTime=interpTime
	end
	WeatherManager.RequestWeather{
		priority=WeatherManager.REQUEST_PRIORITY_FORCE,
		userId=stringScript,
		weatherType=weatherType,
		interpTime=interpTime,
		fogDensity=t.fogDensity,
		fogType=t.fogType
	}
end

function this.CancelForceRequestWeather(weatherType,t,i)
--	--rX51 Settings
--	if (TUPPMSettings.weather_ENABLE_keepCurrentWeatherBetweenTransitions 
--		and not TppMission.IsFOBMission(vars.missionCode)) then
--			TUPPMLog.Log("TppWeather.CancelForceRequestWeather early return",3,true)
--			return
--	end

	local interpTime,t=this._GetRequestWeatherArgs(t,i)
	if interpTime==nil then
		interpTime=interpTime
	end
	WeatherManager.CancelRequestWeather{
		priority=WeatherManager.REQUEST_PRIORITY_FORCE,
		userId=stringScript
	}
	if weatherType~=nil then
		WeatherManager.RequestWeather{
			priority=WeatherManager.REQUEST_PRIORITY_NORMAL,
			userId=stringScript,
			weatherType=weatherType,
			interpTime=interpTime,
			fogDensity=t.fogDensity,
			fogType=t.fogType
		}
	end
end


function this.SetDefaultWeatherDurations()
	--r33 Random weather durations
	local weatherDurations=weatherDurations
	
	--r51 Better handling
	TUPPMLog.Log("missionCode:"..tostring(vars.missionCode)
	.." SetDefaultWeatherDurations BEFORE weatherDurations:"
	..tostring(InfInspect.Inspect(weatherDurations)),3)
	weatherDurations=this.SetCustomWeatherDurations(weatherDurations)
	TUPPMLog.Log("missionCode:"..tostring(vars.missionCode)
	.." SetDefaultWeatherDurations AFTER weatherDurations:"
	..tostring(InfInspect.Inspect(weatherDurations)),3)

	WeatherManager.SetWeatherDurations(weatherDurations)
	if not WeatherManager.SetExtraWeatherInterval then
		return
	end

	--TODO rX7 Randomize interval as well
	WeatherManager.SetExtraWeatherInterval(5*secondsInHour,8*secondsInHour)
end

--r51 Better handling
function this.SetCustomWeatherDurations(weatherDurations)
	if not TUPPMSettings.weather_ENABLE_customSettings or TppMission.IsFOBMission(vars.missionCode) then
--		TUPPMLog.Log("SetCustomWeatherDurations Early return",3,true)
		return weatherDurations
	end
	
	local weatherDurations

	local weatherDur_sunnyMIN = math.max(TUPPMSettings.weatherDur_sunnyMIN or 5,0)
	local weatherDur_sunnyMAX = math.max(TUPPMSettings.weatherDur_sunnyMAX or 8,0)
	local weatherDur_cloudyMIN = math.max(TUPPMSettings.weatherDur_cloudyMIN or 3,0)
	local weatherDur_cloudyMAX = math.max(TUPPMSettings.weatherDur_cloudyMAX or 5,0)
	local weatherDur_sandstormMIN = math.max(TUPPMSettings.weatherDur_sandstormMIN or 13,0)
	local weatherDur_sandstormMAX = math.max(TUPPMSettings.weatherDur_sandstormMAX or 20,0)
	local weatherDur_rainyMIN = math.max(TUPPMSettings.weatherDur_rainyMIN or 1,0)
	local weatherDur_rainyMAX = math.max(TUPPMSettings.weatherDur_rainyMAX or 2,0)
	local weatherDur_foggyMIN = math.max(TUPPMSettings.weatherDur_foggyMIN or 13,0)
	local weatherDur_foggyMAX = math.max(TUPPMSettings.weatherDur_foggyMAX or 20,0)

	if not TUPPMSettings.weather_ENABLE_wildWeatherMode and TUPPMSettings.weather_ENABLE_randomDurations then
--		TUPPMLog.Log("SetCustomWeatherDurations Randomizing durations",3,true)
		--r36 Fixed weather probabilities/durations randomization
		TppMain.Randomize()
		--r44 Better weather randomness
		--r46 Longer durations
		weatherDur_sunnyMIN = math.random(5,8)
		TppMain.Randomize()
		weatherDur_sunnyMAX = math.random(5)+weatherDur_sunnyMIN
		TppMain.Randomize()
		weatherDur_cloudyMIN = math.random(3,5)
		TppMain.Randomize()
		weatherDur_cloudyMAX = math.random(3)+weatherDur_cloudyMIN
		TppMain.Randomize()
		weatherDur_sandstormMIN = math.random(13,20)
		TppMain.Randomize()
		weatherDur_sandstormMAX = math.random(20)+weatherDur_sandstormMIN
		TppMain.Randomize()
		weatherDur_rainyMIN = math.random(2,4)
		TppMain.Randomize()
		weatherDur_rainyMAX = math.random(4)+weatherDur_rainyMIN
		TppMain.Randomize()
		weatherDur_foggyMIN = math.random(13,20)
		TppMain.Randomize()
		weatherDur_foggyMAX = math.random(20)+weatherDur_foggyMIN
	end
	
	weatherDurations={
		{TppDefine.WEATHER.SUNNY,secondsInHour*weatherDur_sunnyMIN,secondsInHour*weatherDur_sunnyMAX},
		{TppDefine.WEATHER.CLOUDY,secondsInHour*weatherDur_cloudyMIN,secondsInHour*weatherDur_cloudyMAX},
		{TppDefine.WEATHER.SANDSTORM,secondsInMinute*weatherDur_sandstormMIN,secondsInMinute*weatherDur_sandstormMAX},
		{TppDefine.WEATHER.RAINY,secondsInHour*weatherDur_rainyMIN,secondsInHour*weatherDur_rainyMAX},
		{TppDefine.WEATHER.FOGGY,secondsInMinute*weatherDur_foggyMIN,secondsInMinute*weatherDur_foggyMAX}
	}
	
--	TUPPMLog.Log("SetCustomWeatherDurations custom weather durations:"..tostring(InfInspect.Inspect(weatherDurations)),3,true)
	
	return weatherDurations
end

--r51 Better handling
function this.SetCustomWeatherProbabilities(normalWeatherTypes, specialWeatherTypes)
	if not TUPPMSettings.weather_ENABLE_customSettings or TppMission.IsFOBMission(vars.missionCode) then
--		TUPPMLog.Log("SetCustomWeatherDurations Early return",3,true)
		return normalWeatherTypes,specialWeatherTypes
	end
	
	local normalWeatherTypes,specialWeatherTypes
	
	local weatherProb_afghSunny = math.max(TUPPMSettings.weatherProb_afghSunny or 80,0)
	local weatherProb_afghCloudy = math.max(TUPPMSettings.weatherProb_afghCloudy or 20,0)
	local weatherProb_mafrSunny = math.max(TUPPMSettings.weatherProb_mafrSunny or 70,0)
	local weatherProb_mafrCloudy = math.max(TUPPMSettings.weatherProb_mafrCloudy or 30,0)
	local weatherProb_mtbsSunny = math.max(TUPPMSettings.weatherProb_mtbsSunny or 80,0)
	local weatherProb_mtbsCloudy = math.max(TUPPMSettings.weatherProb_mtbsCloudy or 20,0)
	
	local weatherProb_afghSandstorm = math.max(TUPPMSettings.weatherProb_afghSandstorm or 100,0)
	local weatherProb_afghRainy = math.max(TUPPMSettings.weatherProb_afghRainy or 0,0)
	local weatherProb_afghFoggy = math.max(TUPPMSettings.weatherProb_afghFoggy or 0,0)
	local weatherProb_mafrSandstorm = math.max(TUPPMSettings.weatherProb_mafrSandstorm or 0,0)
	local weatherProb_mafrRainy = math.max(TUPPMSettings.weatherProb_mafrRainy or 100,0)
	local weatherProb_mafrFoggy = math.max(TUPPMSettings.weatherProb_mafrFoggy or 0,0)
	local weatherProb_mtbsSandstorm = math.max(TUPPMSettings.weatherProb_mtbsSandstorm or 0,0)
	local weatherProb_mtbsRainy = math.max(TUPPMSettings.weatherProb_mtbsRainy or 50,0)
	local weatherProb_mtbsFoggy = math.max(TUPPMSettings.weatherProb_mtbsFoggy or 50,0)
	
	local weatherProb_afghHeliSandstorm = math.max(TUPPMSettings.weatherProb_afghHeliSandstorm or 0,0)
	local weatherProb_afghHeliRainy = math.max(TUPPMSettings.weatherProb_afghHeliRainy or 0,0)
	local weatherProb_afghHeliFoggy = math.max(TUPPMSettings.weatherProb_afghHeliFoggy or 0,0)
	local weatherProb_mafrHeliSandstorm = math.max(TUPPMSettings.weatherProb_mafrHeliSandstorm or 0,0)
	local weatherProb_mafrHeliRainy = math.max(TUPPMSettings.weatherProb_mafrHeliRainy or 100,0)
	local weatherProb_mafrHeliFoggy = math.max(TUPPMSettings.weatherProb_mafrHeliFoggy or 0,0)
	local weatherProb_mtbsHeliSandstorm = math.max(TUPPMSettings.weatherProb_mtbsHeliSandstorm or 0,0)
	local weatherProb_mtbsHeliRainy = math.max(TUPPMSettings.weatherProb_mtbsHeliRainy or 100,0)
	local weatherProb_mtbsHeliFoggy = math.max(TUPPMSettings.weatherProb_mtbsHeliFoggy or 0,0)
	
	local weatherProb_afghNOSANDSTORMSandstorm = math.max(TUPPMSettings.weatherProb_afghNOSANDSTORMSandstorm or 0,0)
	local weatherProb_afghNOSANDSTORMRainy = math.max(TUPPMSettings.weatherProb_afghNOSANDSTORMRainy or 0,0)
	local weatherProb_afghNOSANDSTORMFoggy = math.max(TUPPMSettings.weatherProb_afghNOSANDSTORMFoggy or 0,0)
	
	if not TUPPMSettings.weather_ENABLE_wildWeatherMode and TUPPMSettings.weather_ENABLE_randomProbabilities then
--		TUPPMLog.Log("SetCustomWeatherDurations Randomizing probabilities",3,true)
		--r36 Fixed weather probabilities/durations randomization
		TppMain.Randomize()
		--r44 Better weather randomness
		--r46 Minimum weather randomness adjusted
		weatherProb_afghCloudy = math.random(15,30)
		weatherProb_afghSunny=100-weatherProb_afghCloudy
		TppMain.Randomize()
		
		weatherProb_mafrCloudy = math.random(15,35)
		weatherProb_mafrSunny=100-weatherProb_mafrCloudy
		TppMain.Randomize()
		
		weatherProb_mtbsCloudy = math.random(15,30)
		weatherProb_mtbsSunny=100-weatherProb_mtbsCloudy
		TppMain.Randomize()
		
		TppMain.Randomize()
		--r44 Better weather randomness
		--r46 Minimum weather randomness adjusted
		weatherProb_afghRainy = math.random(10,20)
		TppMain.Randomize()
		weatherProb_afghFoggy= math.random(5, 10)
		weatherProb_afghSandstorm=100-weatherProb_afghRainy-weatherProb_afghFoggy
		TppMain.Randomize()
		
		weatherProb_mafrSandstorm = math.random(5,10)
		TppMain.Randomize()
		weatherProb_mafrFoggy= math.random(10,20)
		weatherProb_mafrRainy=100-weatherProb_mafrSandstorm-weatherProb_mafrFoggy
		TppMain.Randomize()
		
		weatherProb_mtbsSandstorm = 0
		weatherProb_mtbsRainy = math.random(75,100)
		weatherProb_mtbsFoggy=100-weatherProb_mtbsRainy
		TppMain.Randomize()
		
		weatherProb_afghHeliSandstorm = 0
		weatherProb_afghHeliRainy = math.random(30,50)
		weatherProb_afghHeliFoggy=60-weatherProb_afghHeliRainy
		TppMain.Randomize()
		
		weatherProb_mafrHeliSandstorm = 0
		weatherProb_mafrHeliRainy = math.random(90,100)
		weatherProb_mafrHeliFoggy=100-weatherProb_mafrHeliRainy
		TppMain.Randomize()
		
		weatherProb_mtbsHeliSandstorm = 0
		weatherProb_mtbsHeliRainy = math.random(75,100)
		weatherProb_mtbsHeliFoggy=100-weatherProb_mtbsHeliRainy
		TppMain.Randomize()
		
		weatherProb_afghNOSANDSTORMRainy = math.random(10,20)
		TppMain.Randomize()
		weatherProb_afghNOSANDSTORMFoggy= math.random(5, 10)
		weatherProb_afghNOSANDSTORMSandstorm=100-weatherProb_afghNOSANDSTORMRainy-weatherProb_afghNOSANDSTORMFoggy
	end
	
	--TODO --rX51 It seems when the game starts up normalWeatherTypes are set. I think adding specialWeatherTypes to this might allow them to activate as well
	if not TUPPMSettings.weather_ENABLE_wildWeatherMode then
		normalWeatherTypes={
			AFGH={{TppDefine.WEATHER.SUNNY,weatherProb_afghSunny},{TppDefine.WEATHER.CLOUDY,weatherProb_afghCloudy}},
			MAFR={{TppDefine.WEATHER.SUNNY,weatherProb_mafrSunny},{TppDefine.WEATHER.CLOUDY,weatherProb_mafrCloudy}},
			MTBS={{TppDefine.WEATHER.SUNNY,weatherProb_mtbsSunny},{TppDefine.WEATHER.CLOUDY,weatherProb_mtbsCloudy}},
			AFGH_NO_SANDSTORM={{TppDefine.WEATHER.SUNNY,weatherProb_afghSunny},{TppDefine.WEATHER.CLOUDY,weatherProb_afghCloudy}}
		}
	else
		--TUPPMLog.Log("TUPPMSettings.weather_ENABLE_wildWeatherMode is true",3,true)
		normalWeatherTypes={
			AFGH={{TppDefine.WEATHER.SUNNY,weatherProb_afghSunny},{TppDefine.WEATHER.CLOUDY,weatherProb_afghCloudy},{TppDefine.WEATHER.SANDSTORM,weatherProb_afghSandstorm},{TppDefine.WEATHER.RAINY,weatherProb_afghRainy},{TppDefine.WEATHER.FOGGY,weatherProb_afghFoggy}},
			MAFR={{TppDefine.WEATHER.SUNNY,weatherProb_mafrSunny},{TppDefine.WEATHER.CLOUDY,weatherProb_mafrCloudy},{TppDefine.WEATHER.SANDSTORM,weatherProb_mafrSandstorm},{TppDefine.WEATHER.RAINY,weatherProb_mafrRainy},{TppDefine.WEATHER.FOGGY,weatherProb_mafrFoggy}},
			MTBS={{TppDefine.WEATHER.SUNNY,weatherProb_mtbsSunny},{TppDefine.WEATHER.CLOUDY,weatherProb_mtbsCloudy},{TppDefine.WEATHER.SANDSTORM,weatherProb_mtbsSandstorm},{TppDefine.WEATHER.RAINY,weatherProb_mtbsRainy},{TppDefine.WEATHER.FOGGY,weatherProb_mtbsFoggy}},
			AFGH_NO_SANDSTORM={{TppDefine.WEATHER.SUNNY,weatherProb_afghSunny},{TppDefine.WEATHER.CLOUDY,weatherProb_afghCloudy},{TppDefine.WEATHER.SANDSTORM,weatherProb_afghNOSANDSTORMSandstorm},{TppDefine.WEATHER.RAINY,weatherProb_afghNOSANDSTORMRainy},{TppDefine.WEATHER.FOGGY,weatherProb_afghNOSANDSTORMFoggy}},
			AFGH_HELI={{TppDefine.WEATHER.SANDSTORM,weatherProb_afghHeliSandstorm},{TppDefine.WEATHER.RAINY,weatherProb_afghHeliRainy},{TppDefine.WEATHER.FOGGY,weatherProb_afghHeliFoggy}},
			MAFR_HELI={{TppDefine.WEATHER.SANDSTORM,weatherProb_mafrHeliSandstorm},{TppDefine.WEATHER.RAINY,weatherProb_mafrHeliRainy},{TppDefine.WEATHER.FOGGY,weatherProb_mafrHeliFoggy}},
			MTBS_HELI={{TppDefine.WEATHER.SANDSTORM,weatherProb_mtbsHeliSandstorm},{TppDefine.WEATHER.RAINY,weatherProb_mtbsHeliRainy},{TppDefine.WEATHER.FOGGY,weatherProb_mtbsHeliFoggy}},
		}
	end
	specialWeatherTypes={
		AFGH={{TppDefine.WEATHER.SANDSTORM,weatherProb_afghSandstorm},{TppDefine.WEATHER.RAINY,weatherProb_afghRainy},{TppDefine.WEATHER.FOGGY,weatherProb_afghFoggy}},
		MAFR={{TppDefine.WEATHER.SANDSTORM,weatherProb_mafrSandstorm},{TppDefine.WEATHER.RAINY,weatherProb_mafrRainy},{TppDefine.WEATHER.FOGGY,weatherProb_mafrFoggy}},
		MTBS={{TppDefine.WEATHER.SANDSTORM,weatherProb_mtbsSandstorm},{TppDefine.WEATHER.RAINY,weatherProb_mtbsRainy},{TppDefine.WEATHER.FOGGY,weatherProb_mtbsFoggy}},
		AFGH_NO_SANDSTORM={{TppDefine.WEATHER.SANDSTORM,weatherProb_afghNOSANDSTORMSandstorm},{TppDefine.WEATHER.RAINY,weatherProb_afghNOSANDSTORMRainy},{TppDefine.WEATHER.FOGGY,weatherProb_afghNOSANDSTORMFoggy}},
		AFGH_HELI={{TppDefine.WEATHER.SANDSTORM,weatherProb_afghHeliSandstorm},{TppDefine.WEATHER.RAINY,weatherProb_afghHeliRainy},{TppDefine.WEATHER.FOGGY,weatherProb_afghHeliFoggy}},
		MAFR_HELI={{TppDefine.WEATHER.SANDSTORM,weatherProb_mafrHeliSandstorm},{TppDefine.WEATHER.RAINY,weatherProb_mafrHeliRainy},{TppDefine.WEATHER.FOGGY,weatherProb_mafrHeliFoggy}},
		MTBS_HELI={{TppDefine.WEATHER.SANDSTORM,weatherProb_mtbsHeliSandstorm},{TppDefine.WEATHER.RAINY,weatherProb_mtbsHeliRainy},{TppDefine.WEATHER.FOGGY,weatherProb_mtbsHeliFoggy}},
	}
	
		
	--    TUPPMLog.Log("Randomized weather probabilities")
--	TUPPMLog.Log("SetCustomWeatherProbabilities custom weather probabilities normal:"
--	..tostring(InfInspect.Inspect(normalWeatherTypes)).."\n specialWeatherTypes:"
--	..tostring(InfInspect.Inspect(specialWeatherTypes)),3,true)
	
	return normalWeatherTypes,specialWeatherTypes
end

function this.SetDefaultWeatherProbabilities()
	--r33 Random weather probabilities
	local normalWeatherTypes=normalWeatherTypes
	local specialWeatherTypes=specialWeatherTypes
	
	TUPPMLog.Log("missionCode:"..tostring(vars.missionCode)
	.." SetDefaultWeatherProbabilities BEFORE normalWeatherTypes:"
	..tostring(InfInspect.Inspect(normalWeatherTypes))
	.."\n specialWeatherTypes:"
	..tostring(InfInspect.Inspect(specialWeatherTypes)),3)
	--r51 Better handling
	normalWeatherTypes,specialWeatherTypes=this.SetCustomWeatherProbabilities(normalWeatherTypes, specialWeatherTypes)
	TUPPMLog.Log("missionCode:"..tostring(vars.missionCode)
	.." SetDefaultWeatherProbabilities AFTER normalWeatherTypes:"
	..tostring(InfInspect.Inspect(normalWeatherTypes))
	.."\n specialWeatherTypes:"
	..tostring(InfInspect.Inspect(specialWeatherTypes)),3)
	
	local normal
	local special
	local isHeliSpace=TppMission.IsHelicopterSpace(vars.missionCode)
	
	TUPPMLog.Log("missionCode:"..tostring(vars.missionCode)
	.." SetDefaultWeatherProbabilities"
	.."\n vars.locationCode:"..tostring(vars.locationCode)
	.." IsAfghan:"..tostring(TppLocation.IsAfghan())
	.." IsMiddleAfrica:"..tostring(TppLocation.IsMiddleAfrica())
	.." IsMotherBase:"..tostring(TppLocation.IsMotherBase())
	.." isHeliSpace:"..tostring(isHeliSpace)
	,3)
	
	if TppLocation.IsAfghan()then
		normal=normalWeatherTypes.AFGH
		if isHeliSpace then
			special=specialWeatherTypes.AFGH_HELI
		else
			special=specialWeatherTypes.AFGH
		end
	elseif TppLocation.IsMiddleAfrica()then
		normal=normalWeatherTypes.MAFR
		if isHeliSpace then
			special=specialWeatherTypes.MAFR_HELI
		else
			special=specialWeatherTypes.MAFR
		end
	elseif TppLocation.IsMotherBase()then
		normal=normalWeatherTypes.MTBS
		if isHeliSpace then
			special=specialWeatherTypes.MTBS_HELI
		else
			special=specialWeatherTypes.MTBS
		end
	end
	if normal then
		WeatherManager.SetNewWeatherProbabilities("default",normal)
	end
	if special then
		WeatherManager.SetExtraWeatherProbabilities(special)
	end
end

function this.SetWeatherProbabilitiesAfghNoSandStorm()

	--r33 Random weather probabilities
	local normalWeatherTypes=normalWeatherTypes
	local specialWeatherTypes=specialWeatherTypes
	
	TUPPMLog.Log("missionCode:"..tostring(vars.missionCode)
	.." SetWeatherProbabilitiesAfghNoSandStorm BEFORE normalWeatherTypes:"
	..tostring(InfInspect.Inspect(normalWeatherTypes))
	.."\n specialWeatherTypes:"
	..tostring(InfInspect.Inspect(specialWeatherTypes)),3)
	--r51 Better handling
	normalWeatherTypes,specialWeatherTypes=this.SetCustomWeatherProbabilities(normalWeatherTypes, specialWeatherTypes)
	TUPPMLog.Log("missionCode:"..tostring(vars.missionCode)
	.." SetWeatherProbabilitiesAfghNoSandStorm AFTER normalWeatherTypes:"
	..tostring(InfInspect.Inspect(normalWeatherTypes))
	.."\n specialWeatherTypes:"
	..tostring(InfInspect.Inspect(specialWeatherTypes)),3)

	WeatherManager.SetNewWeatherProbabilities("default",normalWeatherTypes.AFGH_NO_SANDSTORM)
	WeatherManager.SetExtraWeatherProbabilities(specialWeatherTypes.AFGH_NO_SANDSTORM)
end

function this.SetMissionStartWeather(e)
	--r51 Settings
--	if (not TUPPMSettings.weather_ENABLE_keepCurrentWeatherBetweenTransitions 
--		or TppMission.IsFOBMission(vars.missionCode)) then
			mvars.missionStartWeatherScript=e
--		TUPPMLog.Log("TppWeather.SetMissionStartWeather"
--		.."\n vars.missionCode:"..tostring(vars.missionCode)
--		.." mvars.missionStartWeatherScript:"..tostring(mvars.missionStartWeatherScript)
--		,3,true)
--	else
--		TUPPMLog.Log("TppWeather.SetMissionStartWeather weather script not set",3,true)
--	end
end

function this.SaveMissionStartWeather()
	gvars.missionStartWeather=vars.weather
	
--	TUPPMLog.Log("TppWeather.SaveMissionStartWeather"
--	.."\n vars.missionCode:"..tostring(vars.missionCode)
--	.." gvars.missionStartWeather:"..tostring(gvars.missionStartWeather)
--	.." vars.weatherNextTime:"..tostring(vars.weatherNextTime)
--	.." vars.extraWeatherInterval:"..tostring(vars.extraWeatherInterval)
--	,3,true)
	--r33 Weather no longer changes on mission start
	--r51 Settings
	if (not TUPPMSettings.weather_ENABLE_keepCurrentWeatherBetweenTransitions 
		or TppMission.IsFOBMission(vars.missionCode))
		and weatherTypesToChangeOnMissionStart[gvars.missionStartWeather] then
			gvars.missionStartWeather=TppDefine.WEATHER.SUNNY
--			TUPPMLog.Log("TppWeather.SaveMissionStartWeather Resetting mission start weather to Sunny",3,true)
--  else
--    TUPPMLog.Log("TppWeather.SaveMissionStartWeather did not reset current weather",3,true)
	end
	WeatherManager.StoreToSVars()
	gvars.missionStartWeatherNextTime=vars.weatherNextTime
	gvars.missionStartExtraWeatherInterval=vars.extraWeatherInterval
end

function this.RestoreMissionStartWeather()
--	TUPPMLog.Log("TppWeather.RestoreMissionStartWeather"
--	.."\n vars.missionCode:"..tostring(vars.missionCode)
--	.." mvars.missionStartWeatherScript:"..tostring(mvars.missionStartWeatherScript)
--	.." gvars.missionStartWeather:"..tostring(gvars.missionStartWeather)
--	.." gvars.missionStartWeatherNextTime:"..tostring(gvars.missionStartWeatherNextTime)
--	.." gvars.missionStartExtraWeatherInterval:"..tostring(gvars.missionStartExtraWeatherInterval)
--	,3,true)
	WeatherManager.InitializeWeather()
	local missionStartWeatherType=mvars.missionStartWeatherScript or gvars.missionStartWeather
	local sunnyType=TppDefine.WEATHER.SUNNY
	local rainOrSandstormType
	if missionStartWeatherType==TppDefine.WEATHER.SANDSTORM or missionStartWeatherType==TppDefine.WEATHER.RAINY then
		rainOrSandstormType=missionStartWeatherType
	else
		sunnyType=missionStartWeatherType
	end
	WeatherManager.RequestWeather{priority=WeatherManager.REQUEST_PRIORITY_NORMAL,userId=stringWeatherSystem,weatherType=sunnyType,interpTime=interpTime}
	if rainOrSandstormType~=nil then
		WeatherManager.RequestWeather{priority=WeatherManager.REQUEST_PRIORITY_EXTRA,userId=stringWeatherSystem,weatherType=rainOrSandstormType,interpTime=interpTime}
	end
	WeatherManager.StoreToSVars()
	vars.weatherNextTime=gvars.missionStartWeatherNextTime
	vars.extraWeatherInterval=gvars.missionStartExtraWeatherInterval
	WeatherManager.RestoreFromSVars()
end

function this.OverrideColorCorrectionLUT(e)
	TppColorCorrection.SetLUT(e)
end

function this.RestoreColorCorrectionLUT()
	TppColorCorrection.RemoveLUT()
end

function this.OverrideColorCorrectionParameter(t,e,r)
	TppColorCorrection.SetParameter(t,e,r)
end

function this.RestoreColorCorrectionParameter()
	TppColorCorrection.RemoveParameter()
end

function this.StoreToSVars()
	WeatherManager.StoreToSVars()
end

function this.RestoreFromSVars()
	local e=TppMission.IsFOBMission(vars.missionCode)
	if e then
	else
		local e=vars.requestWeatherType[WeatherManager.REQUEST_PRIORITY_NORMAL]
		if weatherTypesToChangeOnMissionStart[e]then
			vars.requestWeatherType[WeatherManager.REQUEST_PRIORITY_NORMAL]=TppDefine.WEATHER.SUNNY
			vars.weatherNextTime=0
		end
		local e=vars.requestWeatherType[WeatherManager.REQUEST_PRIORITY_EXTRA]
		if weatherTypesToChangeOnMissionStart[e]then
			vars.requestWeatherType[WeatherManager.REQUEST_PRIORITY_EXTRA]=extraPriority
			vars.weatherNextTime=0
		end
	end
	WeatherManager.RestoreFromSVars()
end

function this.Init()
	TppEffectUtility.RemoveColorCorrectionLut()
	TppEffectUtility.RemoveColorCorrectionParameter()
end

function this.OnMissionCanStart()
	if TppMission.IsHelicopterSpace(vars.missionCode)then
		TppEffectWeatherParameterMediator.SetParameters{addTppSkyOffsetY=1320,setTppSkyScale=.1,setTppSkyScrollSpeedRate=-20}
	else
		TppEffectWeatherParameterMediator.RestoreDefaultParameters()
	end
end

local t=WeatherManager.SetDefaultReflectionTexture or function()
	end

function this.OnEndMissionPrepareFunction()
	if WeatherManager.ClearTag then
		WeatherManager.ClearTag()
	else
		WeatherManager.RequestTag("default",0)
	end
	t()
end

function this._GetRequestWeatherArgs(interpTime,fogDetailsTable)
	if Tpp.IsTypeTable(interpTime)then
		return nil,interpTime
	elseif Tpp.IsTypeTable(fogDetailsTable)then
		return interpTime,fogDetailsTable
	else
		return interpTime,{}
	end
end

return this
