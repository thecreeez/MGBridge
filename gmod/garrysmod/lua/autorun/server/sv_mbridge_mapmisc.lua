---- Minecraft Bridge
---- Map common

if game.SinglePlayer()--[[ or not string.StartWith(game.GetMap(), "mb_")--]] then

	return
end

local MinecraftBlockSize = 0.0

function GetMinecraftBlockSize()
	return MinecraftBlockSize
end

local MinecraftBlockSizeInv = 0.0

function GetMinecraftBlockSizeInv()
	return MinecraftBlockSizeInv
end

local MinecraftBlockCenterOffset = Vector(0.0, 0.0, 0.0)

function GetMinecraftBlockCenterOffset()
	return MinecraftBlockCenterOffset
end

function MinecraftSetBlockSize(InValue)
	MsgN(Format("MinecraftSetBlockSize: %i", InValue))
	MinecraftBlockSize = InValue
	MinecraftBlockSizeInv = 1.0 / MinecraftBlockSize
	MinecraftBlockCenterOffset = Vector(0.5, -0.5, 0.5) * MinecraftBlockSize
	MinecraftUpdateMapScanData()
end

local MinecraftBlockIDToColorList = {
	["minecraft:stone"] = Color(128, 128, 128),
	["minecraft:grass_block"] = Color(0, 128, 0),
	["minecraft:dirt"] = Color(128, 60, 15),
	["minecraft:oak_planks"] = Color(255, 150, 120),
	["minecraft:oak_log"] = Color(200, 128, 75),
	["minecraft:white_wool"] = Color(255, 255, 255),
	["minecraft:orange_wool"] = Color(255, 128, 0),
	["minecraft:magenta_wool"] = Color(200, 60, 128),
	["minecraft:light_blue_wool"] = Color(0, 255, 255),
	["minecraft:yellow_wool"] = Color(255, 255, 0),
	["minecraft:lime_wool"] = Color(0, 255, 0),
	["minecraft:pink_wool"] = Color(255, 128, 128),
	["minecraft:gray_wool"] = Color(190, 190, 190),
	["minecraft:light_gray_wool"] = Color(225, 225, 225),
	["minecraft:cyan_wool"] = Color(0, 200, 200),
	["minecraft:purple_wool"] = Color(255, 70, 255),
	["minecraft:blue_wool"] = Color(0, 0, 255),
	["minecraft:brown_wool"] = Color(128, 60, 60),
	["minecraft:green_wool"] = Color(0, 255, 0),
	["minecraft:red_wool"] = Color(255, 0, 0),
	["minecraft:black_wool"] = Color(0, 0, 0)
}

function MinecraftTryGetBlockColorByID(InID)
	return MinecraftBlockIDToColorList[InID]
end

local StaticEntityFilter = {
	"func_button"
}

function MinecraftInitStaticEntities()

	local OutTable = {}

	for SampleIndex, SampleEntity in ipairs(ents.GetAll()) do

		if IsValid(SampleEntity) then

			local EntityClass = SampleEntity:GetClass()

			if table.HasValue(StaticEntityFilter, EntityClass) then

				local EntityIndex = SampleEntity:EntIndex()

				local EntityPos = SampleEntity:GetPos()

				table.insert(OutTable, {class = EntityClass, index = EntityIndex, x = EntityPos.x, y = EntityPos.z, z = -EntityPos.y})
			end
		end
	end

	local OutJSON = util.TableToJSON(OutTable)

	--print(OutJSON)

	local OutRequest = {
		url			= MinecraftPostStatic,
		method		= "post",
		body		= OutJSON,
		type		= "application/json",
		success		= MinecraftOnInitStaticEntitiesSuccess,
		failed		= MinecraftOnInitStaticEntitiesFailure
	}
	HTTP(OutRequest)
end

function MinecraftOnInitStaticEntitiesSuccess(InCode, InBody, InHeaders)

	MsgN(Format("MinecraftOnInitStaticEntitiesSuccess() body: %s", InBody))


end

function MinecraftOnInitStaticEntitiesFailure(InError)

	MsgN(Format("MinecraftOnInitStaticEntitiesFailure() error: %s", InError))


end
