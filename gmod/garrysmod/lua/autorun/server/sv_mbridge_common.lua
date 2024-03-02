---- Minecraft Bridge
---- Common

if game.SinglePlayer()--[[ or not string.StartWith(game.GetMap(), "mb_")--]] then

	return
end

hook.Add("InitPostEntity", "MinecraftBridgeInitPostEntity", function()
	MsgN("MinecraftBridgeInitPostEntity")
	MinecraftSetBlockSize(64.0)
end)

local bMinecraftBridgeEnabled = false

function MinecraftIsBridgeEnabled()
	return bMinecraftBridgeEnabled
end

function MinecraftSetBridgeEnabled(bInEnabled)
	bMinecraftBridgeEnabled = bInEnabled
end

local MinecraftBridgeIP = "26.221.65.181"
local MinecraftBridgePort = "1820"
local MinecraftBridgeRoomCode = -1

local MinecraftPostHandshake = ""
local MinecraftPostStatic = ""
local MinecraftPostDisconnect = ""
local MinecraftPostUpdate = ""

local MinecraftBridgeToken = ""
local MinecraftBridgeMaxTPS = ""

local bMinecraftUpdateScanHandled = false

function MinecraftGetMinecraftRoomCode()
	return MinecraftRoomCode
end

function MinecraftGeneratePostURL(InPath)
	return Format("http://%s:%s/%s", MinecraftBridgeIP, MinecraftBridgePort, InPath)
end

function MinecraftUpdatePostURL()
	MinecraftPostHandshake = MinecraftGeneratePostURL("handshake")
	MinecraftPostStatic = MinecraftGeneratePostURL("static")
	MinecraftPostDisconnect = MinecraftGeneratePostURL("disconnect")
	MinecraftPostUpdate = MinecraftGeneratePostURL("update")
	MinecraftGetRoomCode = MinecraftGeneratePostURL("create-room")
end

MinecraftUpdatePostURL()

function MinecraftSetBridgeIP(InIP)

	MsgN("MinecraftSetBridgeIP()")

	MinecraftBridgeIP = InIP
	MinecraftUpdatePostURL()
end

function MinecraftSetBridgePort(InPort)

	MsgN("MinecraftSetBridgePort()")

	MinecraftBridgePort = InPort
	MinecraftUpdatePostURL()
end

function MinecraftToggleBridge(InRoomCode)

	MsgN("MinecraftToggleBridge()")

	if MinecraftIsBridgeEnabled() then MinecraftStopBridge()
	else MinecraftStartBridge(InRoomCode) end
end

function MinecraftStartBridge(InRoomCode)

	if MinecraftIsBridgeEnabled() then return end
	MinecraftClearSendEventList()
	
	MinecraftBridgeRoomCode = InRoomCode
	MinecraftHandshake()
end

function MinecraftStopBridge()

	if not MinecraftIsBridgeEnabled() then return end
	MinecraftClearSendEventList()

	MinecraftSetBridgeEnabled(false)

	timer.Remove("MinecraftUpdate")
	MinecraftDisconnect()

	for SampleIndex, SamplePlayer in ipairs(player.GetAll()) do
		SamplePlayer:Spawn()
	end

	hook.Remove("SetupMove", "MinecraftUpdateMove")
	hook.Remove("StartCommand", "MinecraftCommand")

	PrintMessage(HUD_PRINTTALK, "Minecraft bridge disabled!")
end

function MinecraftHandshake()
	local OutTable = {
		type = "gmod",
		OffsetHeight = GetGlobalOffsetZ(),
		Materials = GetMinecraftMaterialKeyWords(),
		code = MinecraftBridgeRoomCode or "test"
	}
	local OutJSON = util.TableToJSON(OutTable)
	--print(OutJSON)

	local OutRequest = {
		url			= MinecraftPostHandshake,
		method		= "post",
		body		= OutJSON,
		type		= "application/json",
		success		= MinecraftOnHandshakeSuccess,
		failed		= MinecraftOnHandshakeFailure
	}
	HTTP(OutRequest)
end

function MinecraftOnHandshakeSuccess(InCode, InBody, InHeaders)

	MsgN(Format("MinecraftOnHandshakeSuccess() body: %s", InBody))

	local SampleTable = util.JSONToTable(InBody) or {}

	if SampleTable.code == -1 then
		MsgN(Format("MinecraftOnHandshakeSuccess() Error: %s", SampleTable.message))
		return
	end

	local SampleToken = SampleTable.data.token
	local SampleSettings = SampleTable.data.settings

	if SampleToken ~= nil then
		MinecraftBridgeToken = SampleToken
	end

	--PrintTable(SampleTable)

	if SampleSettings ~= nil then
		if SampleSettings.gmodUnitsPerBlock ~= nil and isnumber(SampleSettings.gmodUnitsPerBlock) then
			MinecraftSetBlockSize(SampleSettings.gmodUnitsPerBlock)
		else
			MinecraftSetBlockSize(64.0)
		end

		if SampleSettings.allowedGeneratingMap ~= nil then
			MinecraftSetShouldScanMap(SampleSettings.allowedGeneratingMap == true)
		end
	else
		MinecraftSetBlockSize(64.0)
	end
	--MinecraftInitStaticEntities()

	bMinecraftShouldScanMap = (SampleSettings.forcedGenerateMap == 1)
	MinecraftSetBridgeEnabled(true)

	for SampleIndex, SamplePlayer in ipairs(player.GetAll()) do
		InitializeBridgePlayer(SamplePlayer)
		SamplePlayer:Spawn()
	end

	hook.Add("SetupMove", "MinecraftUpdateMove", MinecraftUpdateMove_Implementation)
	hook.Add("StartCommand", "MinecraftCommand", MinecraftCommand_Implementation)

	MinecraftBridgeMaxTPS = tonumber(SampleTable.maxTPS) or 10.0
	bMinecraftUpdateScanHandled = true
	timer.Create("MinecraftUpdate", 1.0 / MinecraftBridgeMaxTPS, 0, MinecraftUpdate)

	PrintMessage(HUD_PRINTTALK, "Minecraft bridge enabled!")

	if MinecraftGetShouldScanMap() then
		MsgN("MinecraftOnHandshakeSuccess() Starting map scan...")
		MinecraftInitAndStartMapScan()
	else
		MsgN("MinecraftOnHandshakeSuccess() No map scan.")
	end
end

function MinecraftOnHandshakeFailure(InError)

	MsgN(Format("MinecraftOnHandshakeFailure() error: %s", InError))

	if InError.message ~= nil then
		PrintMessage(HUD_PRINTTALK, Format("Error! %s", InError.message))
	end
end

function MinecraftUpdate()

	--MsgN("Request MinecraftUpdate()")

	if MinecraftIsMapScanInProgress() then
		if bMinecraftUpdateScanHandled then
			bMinecraftUpdateScanHandled = false
		else
			return
		end
	end

	--MsgN("MinecraftUpdate()")
	local OutTable = MinecraftBuildEntityUpdateTable()

	if MinecraftHasChunkToSend() then
		OutTable.chunk = MinecraftConsumeMinecraftChunkToSend()
		--MsgN(OutTable.chunk.ID)
		--MsgN(OutTable.chunk.scanP)
	end

	OutTable.token = MinecraftBridgeToken

	local OutJSON = util.TableToJSON(OutTable)
	--print(OutJSON)

	local OutRequest = {
		url			= MinecraftPostUpdate,
		method		= "post",
		body		= OutJSON,
		type		= "application/json",
		success		= MinecraftOnUpdateSuccess,
		failed		= MinecraftOnUpdateFailure
	}
	HTTP(OutRequest)
end

local bSlowerUpdates = false

function MinecraftOnUpdateSuccess(InCode, InBody, InHeaders)

	--MsgN(Format("MinecraftOnUpdateSuccess() body: %s", InBody))
	--MsgN("MinecraftOnUpdateSuccess()")

	local SampleTable = util.JSONToTable(InBody) or {}

	if SampleTable.code == -1 then
		MsgN(Format("MinecraftOnUpdateSuccess() Error: %s", SampleTable.message))
		
		if not bSlowerUpdates then
			timer.Adjust("MinecraftUpdate", 1.0 / MinecraftBridgeMaxTPS * 5.0)
			bSlowerUpdates = true
		end
		return
	end

	if bSlowerUpdates then
		timer.Adjust("MinecraftUpdate", 1.0 / MinecraftBridgeMaxTPS)
		bSlowerUpdates = false
	end

	MinecraftReceiveEntityUpdateData(SampleTable.data)

	if MinecraftIsMapScanInProgress() then		
		bMinecraftUpdateScanHandled = true

		if MinecraftIsReadyToScanNextChunk() then
			MinecraftStartScanNextChunk()
		end
	end
end

function MinecraftOnUpdateFailure(InError)

	MsgN(Format("MinecraftOnUpdateFailure() error: %s", InError))

	if not bSlowerUpdates then
		timer.Adjust("MinecraftUpdate", 1.0 / MinecraftBridgeMaxTPS * 5.0)
		bSlowerUpdates = true
	end
end

hook.Add("ShutDown", "MinecraftShutDown", function()
	--MsgN("MinecraftShutDown()")
	if MinecraftIsBridgeEnabled() then
		MinecraftDisconnect()
	end
end)

function MinecraftDisconnect()

	RemoveAllUUIDEntities()

	local OutJSON = util.TableToJSON({ token = MinecraftBridgeToken })
	--print(OutJSON)

	local OutRequest = {
		url			= MinecraftPostDisconnect,
		method		= "post",
		body		= OutJSON,
		type		= "application/json",
		success		= MinecraftOnDisconnectSuccess,
		failed		= MinecraftOnDisconnectFailure
	}
	HTTP(OutRequest)
end

function MinecraftOnDisconnectSuccess(InCode, InBody, InHeaders)
	MsgN(Format("MinecraftOnDisconnectSuccess() body: %s", InBody))
end

function MinecraftOnDisconnectFailure(InError)
	MsgN(Format("MinecraftOnDisconnectFailure() error: %s", InError))
end
