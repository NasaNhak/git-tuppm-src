--TUPPM Header

local this={}

local function LoadExternalModule(moduleName)

	-->Does not work
	--	package.loaded[moduleName]=nil
	--	local sucess,module=pcall(Script.LoadLibrary,"/TUPPMSettings11.lua")
	--	if sucess then
	--		TUPPMLog.DebugPrint("Script.LoadLibrary TUPPMSettings succeeded: "..(InfInspect.Inspect(sucess))..", module:"..(InfInspect.Inspect(module)),1)
	----		_G[moduleName]=module
	----		_G.TUPPMSettings._loadedUserSettings=true
	--	else
	--		TUPPMLog.DebugPrint("Script.LoadLibrary TUPPMSettings failed",1)
	--	end
	--<Does not work

	local sucess,module=pcall(require,moduleName)
	if sucess then
		package.loaded[moduleName]=nil
		_G[moduleName]=module
		_G.TUPPMSettings.__loadedUserSettings=true
	else
	--Do nothing, log file does not exist at this point, module crashes loading otherwise
	--		TUPPMLog.Log("require TUPPMSettings failed",1,TUPPMSettings._debug_ENABLE_forcePrintLogs)
	end
	
	return sucess,module
end

LoadExternalModule"TUPPMSettings"

---r63 Func to reload settings module
function this.ReloadExternalModule(moduleName)
	local result,error = LoadExternalModule(moduleName)
	--r64 Better result handling
	if result then
		TUPPMLog.Log("Loaded module "..tostring(moduleName).." Successfully!",3,true)
		TUPPMLog.Log("Current TUPPMLog:"..tostring(InfInspect.Inspect(TUPPMLog)),1,TUPPMSettings._debug_ENABLE_forcePrintLogs)
		TUPPMLog.Log("Reloaded TUPPMSettings:"..tostring(InfInspect.Inspect(TUPPMSettings)),1,TUPPMSettings._debug_ENABLE_forcePrintLogs)
	else
		TUPPMLog.Log("Error loading module "..tostring(moduleName).."!!! Make sure file is setup correctly.\nError message:\n"..tostring(error),3,true)
	end
end

--Direct log outputs during module load cannot be to iDroid console else game won't start meaning only print mode 1 is allowed
TUPPMLog.InitLogging() --check to see if log path can be initialized
--Logging cannot occur before this point since log path won't be intialized
--This means that the else condition for loading external module cannot be used when loading the settings file
--Revise if making settings reloadable

TUPPMLog.Log("Startup time:"..tostring(os.date("%Y-%m-%d %X")),1,TUPPMSettings._debug_ENABLE_forcePrintLogs)
TUPPMLog.Log("Game path:\""..tostring(TUPPMLog.gamePath).."\"",1,TUPPMSettings._debug_ENABLE_forcePrintLogs)
TUPPMLog.Log("Loaded custom user settings?:"..tostring(TUPPMSettings.__loadedUserSettings==true),1,TUPPMSettings._debug_ENABLE_forcePrintLogs)
TUPPMLog.Log("TUPPMLog:"..tostring(InfInspect.Inspect(TUPPMLog)),1,TUPPMSettings._debug_ENABLE_forcePrintLogs)
TUPPMLog.Log("TUPPMSettings:"..tostring(InfInspect.Inspect(TUPPMSettings)),1,TUPPMSettings._debug_ENABLE_forcePrintLogs)
--TUPPMLog.Log("package:"..tostring(InfInspect.Inspect(package)),1,TUPPMSettings._debug_ENABLE_forcePrintLogs)
return this
