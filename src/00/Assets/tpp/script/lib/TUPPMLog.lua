local this={}

local MAX_ANNOUNCE_STRING=255
local modLogFolderName="TUPPM"
local prev="_prev"
local ext=".txt"
local nl="\r\n"
local stringType="string"
local functionType="function"
local logFilePath=nil
local logFilePathPrev=nil

this.gamePath=nil
this.modPath="\\"..modLogFolderName
this.logFileName="tuppm_log_"..tostring(os.date("%Y.%m.%d"))

local function testflag(set, flag)
	return set % (2*flag) >= flag
end

--tex NMC from lua wiki
local function Split(str,delim,maxNb)
	-- Eliminate bad cases...
	if string.find(str,delim)==nil then
		return{str}
	end
	if maxNb==nil or maxNb<1 then
		maxNb=0--No limit
	end
	local result={}
	local pat="(.-)"..delim.."()"
	local nb=0
	local lastPos
	for part,pos in string.gfind(str,pat) do
		nb=nb+1
		result[nb]=part
		lastPos=pos
		if nb==maxNb then break end
	end
	-- Handle the last field
	if nb~=maxNb then
		result[nb+1]=string.sub(str,lastPos)
	end
	return result
end

local function GetCurrentLogPath(isGetLoggingPath)
	if Fox.GetPlatformName()~="Windows" then return end
	--r65 Improved check
	if not isGetLoggingPath then return end

	os.execute("mkdir "..modLogFolderName)

	local readHandle = Split(package.path,";")[2]:sub(1,-10)
	this.gamePath=readHandle
	logFilePath=this.gamePath..this.modPath.."\\"..this.logFileName..ext
	logFilePathPrev=this.gamePath..this.modPath.."\\"..this.logFileName..prev..ext
end

local function PrintToFileTex(message)
	if Fox.GetPlatformName()~="Windows" then return end

	--r65 If the log file path has not been initialized, then return
	--It will only be initialized during startup or when enabling logs in game via TUPPMLog.InitLogging()
	if logFilePath==nil then return end

	local filePath=logFilePath

	local logFile,error=io.open(filePath,"r")
	local logText=""
	if logFile then
		logText=logFile:read("*all")
		logFile:close()
	end

	local logFile,error=io.open(filePath,"w")
	if not logFile or error then
		--TppUiCommand.AnnounceLogView("IO Create log error: "..tostring(error))
		return
	end

	--	local elapsedTime=os.date("%H.%M.%S").."\t"
	local elapsedTime=os.date("%H.%M.%S")

	local line="["..elapsedTime.."] "..message
	logFile:write(logText..line,nl)
	logFile:close()

end

local function PrintLog(message,...)
	if not TppUiCommand and not TppUiCommand.AnnounceLogView then return end

	if message==nil then
		TppUiCommand.AnnounceLogView("nil")
		return
	elseif type(message)~="string" then
		message=tostring(message)
	end

	if ... then
	end

	while string.len(message)>MAX_ANNOUNCE_STRING do
		local printMessage=string.sub(message,0,MAX_ANNOUNCE_STRING)
		TppUiCommand.AnnounceLogView(printMessage)
		message=string.sub(message,MAX_ANNOUNCE_STRING+1)
	end

	TppUiCommand.AnnounceLogView(message)
end

function this.Log(message, debugPrintFlag, isForced, ...)

	--r64 Logical fix
	local isLogging=(isForced or TUPPMSettings._debug_ENABLE)

	if not isLogging then return end

	--	if not logFilePath then
	--		if not TUPPMSettings.forceCreateLogFile then return end
	--		GetCurrentLogPath(TUPPMSettings.forceCreateLogFile)
	--	end

	if not debugPrintFlag or type(debugPrintFlag)~="number" then return end

	debugPrintFlag=math.min(math.max(math.floor(debugPrintFlag),1),3)

	local printToFile=isLogging and testflag(debugPrintFlag, 1)
	local announceLog=isLogging and testflag(debugPrintFlag, 2)

	if not (printToFile or announceLog) then return end

	if printToFile then
		local stackInfo = debug.getinfo(2,"Snl")
		local caller = "["

		if stackInfo.source then
			caller=caller..stackInfo.source
		end
		if stackInfo.name then
			caller=caller..":"..stackInfo.name
		end
		if stackInfo.currentline then
			caller=caller..":"..stackInfo.currentline
		end

		PrintToFileTex(caller.."] "..message)
	end

	if announceLog then
		PrintLog(message,...)
	end

end

function this.InitLogging()
	GetCurrentLogPath(TUPPMSettings._debug_ENABLE or TUPPMSettings._debug_ENABLE_forcePrintLogs) --cannot call a func before it is declared
end

return this
