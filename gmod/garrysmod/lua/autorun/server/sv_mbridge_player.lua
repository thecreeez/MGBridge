---- Minecraft Bridge
---- Player

if game.SinglePlayer()--[[ or not string.StartWith(game.GetMap(), "mb_")--]] then

	return
end

local MinecraftPlayerHullMin, MinecraftPlayerHullMax = Vector(-12.0, -12.0, 0), Vector(12.0, 12.0, 60.0)
local MinecraftPlayerHullDuckMin, MinecraftPlayerHullDuckMax = Vector(-12.0, -12.0, 0.0), Vector(12.0, 12.0, 50.0)

local MinecraftPlayerViewOffset = Vector(0.0, 0.0, 64.0)
local MinecraftPlayerViewOffsetDuck = Vector(0.0, 0.0, 28.0)

local MinecraftPlayerModelScale = 1.0
local MinecraftPlayerJumpPower = 200

local MinecraftHandToWeaponTable = {
	["minecraft:iron_sword"] = "weapon_crowbar",
	["minecraft:crossbow"] = "weapon_crossbow",
	["minecraft:stick"] = "weapon_physgun",
	["minecraft:bow"] = "weapon_pistol",
	["minecraft:spyglass"] = "gmod_camera"
}

function MinecraftTryGetWeaponForHand(InHand)
	return MinecraftHandToWeaponTable[InHand]
end

local MinecraftDefaultWeaponTable = {
	"weapon_physgun",
	"weapon_physcannon",
	"weapon_crowbar",
	"weapon_pistol",
	"weapon_357",
	"weapon_smg1",
	"weapon_ar2",
	"weapon_shotgun",
	"weapon_crossbow",
	"weapon_rpg",
	"weapon_frag",
	"gmod_tool",
	"gmod_camera"
}

local InputFilter = {
	"Use"
}

function MinecraftPlayerInitialSpawn_Implementation(InPlayer, bInTransition)
	InitializeBridgePlayer(InPlayer)
end

function InitializeBridgePlayer(InPlayer)

	if not InPlayer:IsBot() then
		InPlayer.uuid = InPlayer:SteamID()
		InPlayer.Target = ""
		RegisterUUIDEntity(InPlayer.uuid, InPlayer)
	end
end

hook.Add("PlayerSpawn", "MinecraftPlayerSpawn", function(InPlayer, bInTransition)

	--MsgN("MinecraftPlayerSpawn()")

	--[[if not MinecraftIsBridgeEnabled() then

		return
	end--]]

	if InPlayer:IsNextBot() then

		timer.Simple(0.0, function()

			if MinecraftIsBridgeEnabled() then

				InPlayer:SetHull(MinecraftPlayerHullMin, MinecraftPlayerHullMax)
				InPlayer:SetHullDuck(MinecraftPlayerHullDuckMin, MinecraftPlayerHullDuckMax)
				InPlayer:SetViewOffset(MinecraftPlayerViewOffset)
				InPlayer:SetViewOffsetDucked(MinecraftPlayerViewOffsetDuck)
				InPlayer:SetModelScale(MinecraftPlayerModelScale)
				InPlayer:SetJumpPower(MinecraftPlayerJumpPower)
			else
				InPlayer:ResetHull()
				InPlayer:SetModelScale(1.0)
			end
		end)
	elseif GetGlobalOffsetZ() == 0.0 then
		SetGlobalOffsetZ(math.Round(InPlayer:GetPos().Z * GetMinecraftBlockSizeInv()) * GetMinecraftBlockSize())
	end
end)

function MinecraftPlayerLoadout_Implementation(InPlayer)

	--MsgN("MinecraftPlayerLoadout_Implementation()")

	if not InPlayer:IsNextBot() then

		InPlayer:StripWeapons()
		InPlayer:StripAmmo()

		for SampleIndex, SampleWeaponClass in ipairs(MinecraftDefaultWeaponTable) do

			local SampleWeapon = InPlayer:Give(SampleWeaponClass)
			--MsgN(SampleWeapon:GetPrimaryAmmoType())
			InPlayer:SetAmmo(9999, SampleWeapon:GetPrimaryAmmoType())
		end
		return true
	end
end

function MinecraftAllowPlayerPickup_Implementation(InPlayer, InEntity)

	--MsgN("MinecraftAllowPlayerPickup_Implementation()")

	if string.StartWith(InEntity:GetClass(), "item_") and InEntity:CreatedByMap() then

		return false
	end
end

function MinecraftUpdateMove_Implementation(InPlayer, InMoveData, InCommandData)

	if InPlayer:IsBot() then
		if InPlayer.LerpPos ~= nil then
			--MsgN(Format("PlayerPos: %s, LerpPos: %s", InPlayer:GetPos(), InPlayer.LerpPos))
			--InPlayer:SetPos(LerpVector(FrameTime(), InPlayer:GetPos(), InPlayer.LerpPos))

			local MoveVelocity = InPlayer.LerpPos - InMoveData:GetOrigin()
			InMoveData:SetVelocity(MoveVelocity * 10.0)
			--InMoveData:SetMaxClientSpeed(MoveVelocity:LengthSqr())
			InMoveData:SetOrigin(LerpVector(FrameTime() * 4.0, InMoveData:GetOrigin(), InPlayer.LerpPos))
			InPlayer:SetEyeAngles(LerpAngle(FrameTime() * 4.0, InMoveData:GetAngles(), InPlayer.LerpAngles))
		end
	end
end

function MinecraftCommand_Implementation(InPlayer, InCommandData)

	--MsgN(Format("%s: %s, %s", InPlayer, InPlayer:IsNextBot(), InPlayer:Alive()))

	if InPlayer:IsBot() and InPlayer:Alive() then

		InCommandData:ClearMovement()
		InCommandData:ClearButtons()
		--MsgN(Format("Crouching: %s", InPlayer.bCrouching))

		if InPlayer.bCrouching then
			InCommandData:SetButtons(IN_DUCK)
		end

		if InPlayer.bUsePrimary then
			InCommandData:SetButtons(IN_ATTACK)
		end
	end
end

function MinecraftMapInput_Implementation(InEntity, InInput, InActivator, InCaller, InValue)

	--MsgN(MinecraftMapInput_Implementation)

	if table.HasValue(InputFilter, InInput) and InValue ~= "_bridge" then

		local EntityClass = InEntity:GetClass()

		if EntityClass == "func_button" then

			InEntity.LastTimeActivate = InEntity.LastTimeActivate or 0.0

			if InEntity.LastTimeActivate + 3.0 > CurTime() then
				return true
			else
				InEntity.LastTimeActivate = CurTime()
			end
		end

		MinecraftAddEventToList({
			type = InInput,
			index = InEntity:EntIndex(),
			activator = InActivator.uuid or "",
			value = tostring(InValue or "")
		})
	end
end

function MinecraftPhysgunTargetCanPickup_Implementation(InPlayer, InEntity)

	--MsgN("MinecraftPhysgunTargetCanPickup_Implementation")

	return InEntity:GetClass() ~= "player" and not InEntity.bMinecraftBlock
end

function MinecraftPhysgunTargetPickup_Implementation(InPlayer, InEntity)

	if InEntity.uuid then
		InPlayer.Target = InEntity.uuid
	end
end

function MinecraftPhysgunTargetRelease_Implementation(InPlayer, InEntity)

	InPlayer.Target = ""
end

function MinecraftPhysgunFreeze_Implementation(InWeapon, InPhysObj, InEntity, InPlayer)

	local WeaponColor = InPlayer:GetWeaponColor()

	MinecraftAddEventToList({
		type = "Freeze",
		targetUuid = InEntity.uuid,
		hand_color_r = math.Round(WeaponColor.x, 2),
		hand_color_g = math.Round(WeaponColor.y, 2),
		hand_color_b = math.Round(WeaponColor.z, 2)
	})
end

hook.Add("PlayerSay", "MinecraftChatEvent", function(InPlayer, InText, bTeamChat)

	if string.StartWith(InText, "/") and InPlayer:IsAdmin() then

		local CommandData = string.Split(InText, " ")

		--PrintTable(CommandData)

		if CommandData[1] == "/bridge" or CommandData[1] == "/mb" then

			if CommandData[2] == "toggle" then
				MinecraftToggleBridge(CommandData[3])
				return ""
			elseif CommandData[2] == "start" then
				MinecraftStartBridge(CommandData[3])
				return ""
			elseif CommandData[2] == "stop" then
				MinecraftStopBridge()
				return ""
			elseif CommandData[1] == "ip" then
				MinecraftSetBridgeIP(CommandData[3])
				return ""
			elseif CommandData[1] == "port" then
				MinecraftSetBridgePort(CommandData[3])
				return ""
			end
		end
		return
	end

	if not MinecraftIsBridgeEnabled() then return end
	
	if InPlayer.bMinecraftEntity then return end

	MinecraftAddEventToList({
		type = "ChatMessage",
		targetUuid = InPlayer.uuid,
		value = InText,
		team = tostring(bTeamChat)
	})
end)

function MinecraftSwitchFlashlight_Implementation(InPlayer, bInEnabled)

	--MsgN("MinecraftSwitchFlashlight_Implementation")

	if InPlayer.bMinecraftEntity then return end

	MinecraftAddEventToList({
		type = "Flashlight",
		targetUuid = InPlayer.uuid,
		value = tostring(bInEnabled)
	})
end
