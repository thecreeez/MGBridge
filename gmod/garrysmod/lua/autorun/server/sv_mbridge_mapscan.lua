---- Minecraft Bridge
---- Garry's mod map scan

if game.SinglePlayer()--[[ or not string.StartWith(game.GetMap(), "mb_")--]] then

	return
end

local MinecraftMaterialKeyWords = {
	["concrete"] = 1,
	["grass"] = 2,
	["brick"] = 3,
	["plaster"] = 4,
	["building"] = 5,
	["roof"] = 6,
	["wood"] = 7,
	["cliff"] = 8,
	["stone"] = 9
}

function GetMinecraftMaterialKeyWords()
	return MinecraftMaterialKeyWords
end

function GetMinecraftMaterialIndex(InTextureName)

	if InTextureName == "**displacement**" then
		return MinecraftMaterialKeyWords["grass"]
	end
	local LowercaseName = string.lower(InTextureName)

	local LastWordStart = 1
	local LastWordIndex = 0

	for SampleKeyWord, SampleIndex in pairs(MinecraftMaterialKeyWords) do

		local Start, End = string.find(LowercaseName, SampleKeyWord, LastWordStart)

		if Start ~= nil then

			LastWordStart = Start
			LastWordIndex = SampleIndex
		end
	end

	return LastWordIndex
end

local MapChunkBoundsMin = Vector(-4, -4, -2)
local MapChunkBoundsMax = Vector(4, 4, 4)

local MapChunkHalfSize = 16

local MapChunkSizeUnitsMin = Vector(-1.0, -1.0, -1.0)
local MapChunkSizeUnitsMax = Vector(1.0, 1.0, 1.0)

local TraceStartOffset = Vector(0.0, 0.0, 0.0)

function GetMinecraftTraceStartOffset()
	return TraceStartOffset
end

--timer.Create("TraceStartOffsetff", 1.0, 0, function() MsgN(TraceStartOffset) end)

function MinecraftUpdateMapScanData()
	local Size = MapChunkHalfSize * GetMinecraftBlockSize()
	MapChunkSizeUnitsMax = Vector(Size, Size, Size)
	MapChunkSizeUnitsMin = -MapChunkSizeUnitsMax
	TraceStartOffset = Vector(0.0, 0.55, 0.55) * GetMinecraftBlockSize()
	MsgN("TraceStartOffset = ", TraceStartOffset)
end

function MinecraftInitMapChunkBounds()

	local MapChunkBoundsSizeScaled = math.max(math.floor(64 / MapChunkHalfSize), 2)

	if GetMinecraftBlockSize() < 32 then
		MapChunkBoundsSizeScaled = MapChunkBoundsSizeScaled * 4
	elseif GetMinecraftBlockSize() < 64 then
		MapChunkBoundsSizeScaled = MapChunkBoundsSizeScaled * 2
	end

	local MapChunkBoundsSizeDownScaled = math.max(math.floor(64 / MapChunkHalfSize), 2)

	if GetMinecraftBlockSize() > 64 then
		MapChunkBoundsSizeDownScaled = 2
	end

	local MapBoundsMin, MapBoundsMax = game.GetWorld():GetModelBounds()
	local UnitsToChunksMul = GetMinecraftBlockSizeInv() / (MapChunkHalfSize * 2)

	local ChunksGlobalOffsetZ = math.floor(GetGlobalOffsetZ() * UnitsToChunksMul)

	local MapBoundsMin_Chunks = Vector(math.floor(MapBoundsMin.X * UnitsToChunksMul), math.floor(MapBoundsMin.Y * UnitsToChunksMul), math.floor(MapBoundsMin.Z * UnitsToChunksMul))
	local MapBoundsMax_Chunks = Vector(math.ceil(MapBoundsMax.X * UnitsToChunksMul), math.ceil(MapBoundsMax.Y * UnitsToChunksMul), math.ceil(MapBoundsMax.Z * UnitsToChunksMul))
	MsgN(Format("MinecraftInitChunkBounds() MapBoundsMin_Chunks = [%s], MapBoundsMax_Chunks = [%s]", MapBoundsMin_Chunks, MapBoundsMax_Chunks))

	MapChunkBoundsMin.X = math.max(MapBoundsMin_Chunks.X, -MapChunkBoundsSizeScaled)
	MapChunkBoundsMin.Y = math.max(MapBoundsMin_Chunks.Y, -MapChunkBoundsSizeScaled)
	MapChunkBoundsMin.Z = math.max(MapBoundsMin_Chunks.Z, -MapChunkBoundsSizeDownScaled + ChunksGlobalOffsetZ)

	MapChunkBoundsMax.X = math.min(MapBoundsMax_Chunks.X, MapChunkBoundsSizeScaled)
	MapChunkBoundsMax.Y = math.min(MapBoundsMax_Chunks.Y, MapChunkBoundsSizeScaled)
	MapChunkBoundsMax.Z = math.min(MapBoundsMax_Chunks.Z, MapChunkBoundsSizeScaled + ChunksGlobalOffsetZ)

	MsgN(Format("MinecraftInitChunkBounds() Ready: MapChunksMin = [%s], MapChunksMax = [%s]", MapChunkBoundsMin, MapChunkBoundsMax))
end

local bMinecraftShouldScanMap = false

function MinecraftGetShouldScanMap()
	return bMinecraftShouldScanMap
end

function MinecraftSetShouldScanMap(InValue)
	bMinecraftShouldScanMap = InValue
end

local bMinecraftMapScanInProgress = false

function MinecraftIsMapScanInProgress()
	return bMinecraftMapScanInProgress
end

local MinecraftChunkToSend = {}
local MinecraftChunkToSend_InProgress = {}

function MinecraftIsReadyToScanNextChunk()
	return table.IsEmpty(MinecraftChunkToSend_InProgress) and table.IsEmpty(MinecraftChunkToSend)
end

function MinecraftHasChunkToSend()
	return not table.IsEmpty(MinecraftChunkToSend)
end

function MinecraftConsumeMinecraftChunkToSend()
	local OutTable = MinecraftChunkToSend
	MinecraftChunkToSend = {}
	return OutTable
end

local MinecraftChunkSendCoroutine = nil

function MinecraftGetChunkSendCoroutine()
	return MinecraftChunkSendCoroutine
end

function MinecraftTestInitAndStartMapScan()

	MinecraftInitAndStartMapScan()
	timer.Create("MinecraftTestMapScan", 1.0 / 20.0, 0, MinecraftTestStartScanNextChunk)
end

function MinecraftTestStartScanNextChunk()

	if MinecraftChunkSendCoroutine == nil then
		timer.Remove("MinecraftTestMapScan")
	else
		MinecraftStartScanNextChunk()
	end
end

function MinecraftStartScanNextChunk()

	MinecraftMapScanChunkResume()
end

function MinecraftMapScanChunkResume()

	local bSuccess, Message = coroutine.resume(MinecraftChunkSendCoroutine)

	if not bSuccess then
		MsgN(Message)
	end

	--[[if MinecraftChunkSendCoroutine then 
		coroutine.resume(MinecraftChunkSendCoroutine)
	end--]]
end

function MinecraftInitAndStartMapScan()

	MinecraftInitMapChunkBounds()

	MinecraftChunkSendCoroutine = coroutine.create(function()

		bMinecraftMapScanInProgress = true
		local MaxChunks = (MapChunkBoundsMax.Z - MapChunkBoundsMin.Z + 1) * (MapChunkBoundsMax.Y - MapChunkBoundsMin.Y + 1) * (MapChunkBoundsMax.X - MapChunkBoundsMin.X + 1)
		local ChunkID = 0
		local CurrentPercentage = 0

		for z = MapChunkBoundsMin.Z, MapChunkBoundsMax.Z do
			for x = MapChunkBoundsMin.X, MapChunkBoundsMax.X do
				for y = MapChunkBoundsMin.Y, MapChunkBoundsMax.Y do

					MinecraftMapScanChunk(ChunkID--[[math.floor(SysTime() * 1000.0)]], x, y, z)
					ChunkID = ChunkID + 1
					CurrentPercentage = math.Round((ChunkID + 1) / MaxChunks * 100)

					--PrintTable(MinecraftChunkToSend_InProgress)
					if not table.IsEmpty(MinecraftChunkToSend_InProgress.points) then
						MinecraftChunkToSend_InProgress.scanP = CurrentPercentage
						table.CopyFromTo(MinecraftChunkToSend_InProgress, MinecraftChunkToSend)
					end
					--MsgN("Scan finished")
					table.Empty(MinecraftChunkToSend_InProgress)
					--PrintTable(MinecraftChunkToSend)
	            	coroutine.yield()
				end
			end
			PrintMessage(HUD_PRINTTALK, Format("Map scan progress: %i%%", CurrentPercentage))
		end

		MinecraftChunkSendCoroutine = nil
		MinecraftChunkToSend = {}

		bMinecraftMapScanInProgress = false
	end)
	--MsgN(MinecraftChunkSendCoroutine)
	MinecraftStartScanNextChunk()
end

function MinecraftMapScanChunk(InID, InOffsetX, InOffsetY, InOffsetZ)

	--MsgN(Format("MinecraftMapScanChunk() %s, [%s, %s, %s]", InID, InOffsetX, InOffsetY, InOffsetZ))
	MinecraftChunkToSend_InProgress = { --[[ID = InID, ]]points = {} }
	local OccludedCoords = {}

	local BoundsCenter = Vector(InOffsetX, InOffsetY, InOffsetZ) * (MapChunkHalfSize * 2)
	local BoundsDelta = Vector(MapChunkHalfSize, MapChunkHalfSize, MapChunkHalfSize)

	local BoundsStart = BoundsCenter - BoundsDelta
	local BoundsEnd = BoundsCenter + BoundsDelta

	--MsgN(BoundsStart, BoundsEnd)

	--Seems to not work because there's no overlap until we leave solid area
	--[[if MinecraftMapScanChunkEarlyOutCheck(BoundsStart, BoundsEnd) then
		return
	end--]]

	local StartTime = SysTime()

	for x = BoundsStart.x, BoundsEnd.x do
		for y = BoundsStart.y, BoundsEnd.y do
			for z = BoundsStart.z, BoundsEnd.z do
				MinecraftMapTraceOnCoords(OccludedCoords, x, y, z)
			end
		end
		timer.Create("MinecraftMapScanChunkPause", 0.012, 0, MinecraftMapScanChunkResume)
		coroutine.yield()
	end

	timer.Remove("MinecraftMapScanChunkPause")

	local BoundsCenterLocation = BoundsCenter * GetMinecraftBlockSize() + GetMinecraftBlockCenterOffset()
	debugoverlay.Box(BoundsCenterLocation, MapChunkSizeUnitsMin, MapChunkSizeUnitsMax, 1.0, Color(255, 255, 255, 50))

	--MsgN("Finished traces for ", InID, timer.TimeLeft("MinecraftMapScanChunkPause"))

	--local TraceTime = SysTime()
	--MsgN("Trace time: ", TraceTime - StartTime)
	
	--PrintTable(OccludedCoords)
	for x = BoundsStart.x, BoundsEnd.x do
		for y = BoundsStart.y, BoundsEnd.y do
			for z = BoundsStart.z, BoundsEnd.z do
				if OccludedCoords[x] and OccludedCoords[x][y] and OccludedCoords[x][y][z] then

					if OccludedCoords[x + 1] and OccludedCoords[x + 1][y] and OccludedCoords[x + 1][y][z]
				and OccludedCoords[x - 1] and OccludedCoords[x - 1][y] and OccludedCoords[x - 1][y][z]
				and OccludedCoords[x] and OccludedCoords[x][y + 1] and OccludedCoords[x][y + 1][z]
				--[[and OccludedCoords[x] --]]and OccludedCoords[x][y - 1] and OccludedCoords[x][y - 1][z]
				--[[and OccludedCoords[x] --]]and OccludedCoords[x][y] and OccludedCoords[x][y][z + 1]
				--[[and OccludedCoords[x] and OccludedCoords[x][y] --]]and OccludedCoords[x][y][z - 1] then
					else
						local BlockLocation = Vector(x, y, z) * GetMinecraftBlockSize()
						--debugoverlay.Box(BlockLocation, Vector(1,1,1) * -GetMinecraftBlockSize(), Vector(1,1,1) * GetMinecraftBlockSize(), 1.0)

						table.insert(MinecraftChunkToSend_InProgress.points, BlockLocation.X)
						table.insert(MinecraftChunkToSend_InProgress.points, BlockLocation.Z)
						table.insert(MinecraftChunkToSend_InProgress.points, -BlockLocation.Y)
						table.insert(MinecraftChunkToSend_InProgress.points, OccludedCoords[x][y][z])
						--MsgN(Format("Material: %i", OccludedCoords[x][y][z]))
					end
				end
			end
		end
	end
	--MsgN("Optimisation time: ", SysTime() - TraceTime)	
	--PrintTable(MinecraftChunkToSend_InProgress)
end

function MinecraftTestMapTraceFromView()

	local PlayerTrace = util.TraceLine(util.GetPlayerTrace(player.GetAll()[1]))
	local Coords = PlayerTrace.HitPos * GetMinecraftBlockSizeInv()
	MsgN(Format("Coords: %i, %i, %i", math.Round(Coords.X), math.Round(Coords.Y), math.Round(Coords.Z)))
	MinecraftMapTraceOnCoords({}, math.Round(Coords.X), math.Round(Coords.Y), math.Round(Coords.Z))
end

local EarlyOutTraceStartOffset = Vector(0.0, 0.0, 1.0)

function MinecraftMapScanChunkEarlyOutCheck(InBoundsStart, InBoundsEnd)
	--MsgN(MapChunkSizeUnitsMin, MapChunkSizeUnitsMax)
	local TraceStart = InBoundsStart + (InBoundsEnd - InBoundsStart) * 0.5

	local TraceResult = util.TraceLine({
		start = TraceStart - EarlyOutTraceStartOffset,
		endpos = TraceStart + EarlyOutTraceStartOffset,
		mins = MapChunkSizeUnitsMin,
		maxs = MapChunkSizeUnitsMax,
		mask = CONTENTS_SOLID})
	--PrintTable(TraceResult)
	--debugoverlay.Box(TraceStart, MapChunkSizeUnitsMin, MapChunkSizeUnitsMax, 5.0)
	if not TraceResult.HitWorld then
		MsgN("Discarded chunk")
		--debugoverlay.Box(TraceStart, MapChunkSizeUnitsMin, MapChunkSizeUnitsMax, 30.0)
		return true
	end
	return false
end

function MinecraftMapTraceOnCoords(InTable, x, y, z)

	local TraceEnd = Vector(x, y, z) * GetMinecraftBlockSize() + GetMinecraftBlockCenterOffset()

	local TraceResult = util.TraceLine({
		start = TraceEnd + TraceStartOffset,
		endpos = TraceEnd,
		mask = CONTENTS_SOLID})

	if TraceResult.HitTexture == "**empty**" then
		TraceResult = util.TraceLine({
		start = TraceEnd - TraceStartOffset,
		endpos = TraceEnd,
		mask = CONTENTS_SOLID})
	end
	--debugoverlay.Box(TraceEnd, Vector(0.5, 0.5, 0.5) * -GetMinecraftBlockSize(), Vector(0.5, 0.5, 0.5) * GetMinecraftBlockSize(), 1.0)

	--PrintTable(TraceResult)
	--MsgN("==============")

	if TraceResult.Fraction < 1 and TraceResult.HitWorld and TraceResult.MatType ~= MAT_DEFAULT then

		--debugoverlay.Box(TraceEnd, Vector(0.5, 0.5, 0.5) * -GetMinecraftBlockSize(), Vector(0.5, 0.5, 0.5) * GetMinecraftBlockSize(), 1.0)

		if InTable[x] == nil then
			InTable[x] = {}
		end

		if InTable[x][y] == nil then
			InTable[x][y] = {}
		end
		InTable[x][y][z] = GetMinecraftMaterialIndex(TraceResult.HitTexture)
		--MsgN(Format("Index: %s", InTable[x][y][z]))
		--MsgN(Format("HitTexture: %s", TraceResult.HitTexture))

		if InTable[x][y][z] > 0 then
			debugoverlay.Box(TraceEnd, Vector(0.5, 0.5, 0.5) * -GetMinecraftBlockSize(), Vector(0.5, 0.5, 0.5) * GetMinecraftBlockSize(), 1.0)
		end
	end
end
