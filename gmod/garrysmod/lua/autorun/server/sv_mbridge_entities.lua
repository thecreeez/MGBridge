---- Minecraft Bridge
---- Entities

if game.SinglePlayer()--[[ or not string.StartWith(game.GetMap(), "mb_")--]] then

	return
end

local MinecraftSendEventList = {}

function MinecraftAddEventToList(InEventData)
	table.insert(MinecraftSendEventList, InEventData)
end

function MinecraftClearSendEventList()
	table.Empty(MinecraftSendEventList)
end

local VehicleDataList = {
	["prop_vehicle_jeep"] = {Class = "Jeep", LocalBias = Vector(-32.0, -8.0, 0.0)},
	["prop_vehicle_jeep_old"] = {Class = "Jeep", LocalBias = Vector(-32.0, -8.0, 0.0)},
	["prop_vehicle_airboat"] = {Class = "Airboat", LocalBias = Vector(0.0, -8.0, 0.0)},
	["prop_vehicle_prisoner_pod"] = {Class = "Chair", LocalBias = Vector(0.0, 0.0, 0.0)}
}

local ProjectileClassList = {
	["npc_satchel"] = "Slam",
	["npc_grenade_frag"] = "Grenade",
	["grenade_ar2"] = "Grenade",
	["rpg_missile"] = "Missile",
	["crossbow_bolt"] = "Bolt",
	["prop_combine_ball"] = "Ball",
	["npc_grenade_bugbait"] = "Bait",
	["hunter_flechette"] = "Flechette"
}

local UUIDEntityList = {}

function RegisterUUIDEntity(InUUID, InEntity)
	UUIDEntityList[InUUID] = InEntity
end

local MinecraftExplosiveClassList = {
	["npc_satchel"] = "Slam",
	["npc_grenade_frag"] = "Grenade",
	["grenade_ar2"] = "Grenade",
	["rpg_missile"] = "Missile",
	["prop_combine_ball"] = "Ball"
}

local MinecraftExplosiveModelList = {
	["models/props_c17/oildrum001_explosive.mdl"] = true,
	["models/props_phx/misc/potato_launcher_explosive.mdl"] = true,
	["models/props_phx/oildrum001_explosive.mdl"] = true
}

local MinecraftWaterLocationList = {}

function MinecraftGetWaterLocationList()

	return MinecraftWaterLocationList
end

local GlobalOffsetZ = 0.0

function GetGlobalOffsetZ()

	return GlobalOffsetZ
end

function SetGlobalOffsetZ(InOffset)

	MsgN(Format("SetGlobalOffsetZ: %i", InOffset))	
	GlobalOffsetZ = InOffset
end

function MinecraftCreateEntity(InEntityData)

	--MsgN("MinecraftCreateEntity()")
	--PrintTable(InEntityData)
	local UniqueID = InEntityData.uuid or "invalid"
	local EntityName = InEntityData.name or "no name for entity"

	if InEntityData.type == "Player" then
		UUIDEntityList[UniqueID] = player.CreateNextBot(EntityName)
		UUIDEntityList[UniqueID]:Spawn()
		UUIDEntityList[UniqueID]:SetPos(Vector(InEntityData.x, -InEntityData.z, InEntityData.y))
		--UUIDEntityList[UniqueID]:SetAngles(Angle(InEntityData.pitch, -InEntityData.yaw - 90.0, 0.0))
		UUIDEntityList[UniqueID]:SetEyeAngles(Angle(InEntityData.pitch, -InEntityData.yaw - 90.0, 0.0))
		UUIDEntityList[UniqueID]:SetActivity(ACT_RUN)
		UUIDEntityList[UniqueID]:EmitSound("Player.DrownContinue")
	end

	UUIDEntityList[UniqueID].uuid = UniqueID
	UUIDEntityList[UniqueID].bMinecraftEntity = true
end

function MinecraftCreateProjectile(InEntityData)

	--MsgN("CreateMinecraftProjectile()")
	--local ProjectileEffectData = EffectData()
	--ProjectileEffectData:SetOrigin(Vector(InEntityData.x, -InEntityData.z, InEntityData.y))
	--ProjectileEffectData:SetAngles(Angle(InEntityData.pitch, -InEntityData.yaw - 90.0, 0.0))
	--ProjectileEffectData:SetScale(10.0)
	--ProjectileEffectData:SetFlags(1)
	--ProjectileEffectData:SetStart(Vector(InEntityData.x + 16.0, -InEntityData.z, InEntityData.y))
	--local ProjectileEffectName = ""
	local EffectOrigin = Vector(InEntityData.x, -InEntityData.z, InEntityData.y)

	if InEntityData.class == "Arrow" then
		--ProjectileEffectName = "GunshipTracer"
		local EffectEndPos = Vector(GetMinecraftBlockSize(), 0.0, 0.0)
		EffectEndPos:Rotate(Angle(InEntityData.pitch, -InEntityData.yaw - 90.0, 0.0))
		effects.BubbleTrail(EffectOrigin, EffectOrigin + EffectEndPos, 16, EffectOrigin.z + GetMinecraftBlockSize() * 0.25, 0.1, 0.1)
		--util.Effect("Tracer", ProjectileEffectData)
	elseif InEntityData.class == "Potion" then
		--ProjectileEffectName = "VortDispel"
		effects.BubbleTrail(EffectOrigin, EffectOrigin, 4, EffectOrigin.z + GetMinecraftBlockSize() * 2.0, 0.1, 0.1)
	elseif InEntityData.class == "Trident" then
		local EffectEndPos = Vector(GetMinecraftBlockSize(), 0.0, 0.0)
		EffectEndPos:Rotate(Angle(InEntityData.pitch, -InEntityData.yaw - 90.0, 0.0))
		effects.BubbleTrail(EffectOrigin, EffectOrigin + EffectEndPos, 32, EffectOrigin.z + GetMinecraftBlockSize(), 0.1, 0.1)
	end
end

function MinecraftBuildEntityUpdateTable()

	--MsgN("MinecraftBuildEntityUpdateTable()")

	local OutTable = {entities = {}, events = {}}

	--Players
	for SampleIndex, SamplePlayer in ipairs(player.GetHumans()) do

		local SamplePos = SamplePlayer:GetPos()
		local SampleAngles = SamplePlayer:EyeAngles()
		local SampleWeapon = SamplePlayer:GetActiveWeapon()
		local SampleWeaponClass = "none"
		local SampleHandColor = SamplePlayer:GetWeaponColor()

		if IsValid(SampleWeapon) then
			SampleWeaponClass = SampleWeapon:GetClass()
		end

		table.insert(OutTable.entities, {
			["type"] = "player",
			["name"] = SamplePlayer:Nick(),
			["health"] = SamplePlayer:Health(),
			["x"] = math.Round(SamplePos.x),
			["y"] = math.Round(SamplePos.z),
			["z"] = -math.Round(SamplePos.y),
			["pitch"] = math.Round(SampleAngles.pitch),
			["yaw"] = -math.Round(SampleAngles.yaw),
			["uuid"] = SamplePlayer.uuid,
			["isAlive"] = tostring(SamplePlayer:Alive()),
			["isSitting"] = tostring(SamplePlayer:Crouching() or ""),
			["hand"] = SampleWeaponClass,
			["hand_color_r"] = math.Round(SampleHandColor.x, 2),
			["hand_color_g"] = math.Round(SampleHandColor.y, 2),
			["hand_color_b"] = math.Round(SampleHandColor.z, 2),
			["isUsing"] = SamplePlayer:KeyDown(IN_ATTACK),
			["target"] = SamplePlayer.Target
		})
	end

	--NPCs
	for SampleIndex, SampleNPC in ipairs(ents.FindByClass("npc*")) do

		local SampleClass = SampleNPC:GetClass()

		if SampleClass ~= "npc_grenade_frag" and SampleClass ~= "npc_grenade_bugbait" and SampleClass ~= "npc_satchel" then

			local SamplePos = SampleNPC:GetPos()
			local SampleAngles = SampleNPC:EyeAngles()
			local SampleWeapon = SampleNPC:GetActiveWeapon()
			local SampleWeaponClass = "none"

			if IsValid(SampleWeapon) then
				SampleWeaponClass = SampleWeapon:GetClass()
			end

			table.insert(OutTable.entities, {
				["type"] = "npc",
				["class"] = SampleNPC:GetClass(),
				["health"] = SampleNPC:Health(),
				["x"] = math.Round(SamplePos.x),
				["y"] = math.Round(SamplePos.z),
				["z"] = -math.Round(SamplePos.y),
				["pitch"] = math.Round(SampleAngles.pitch),
				["yaw"] = -math.Round(SampleAngles.yaw),
				["uuid"] = SampleNPC.uuid,
				["hand"] = SampleWeaponClass
			})
		end
	end

	--Vehicles
	for SampleIndex, SampleVehicle in ipairs(ents.FindByClass("prop_vehicle*")) do

		local SamplePos = SampleVehicle:GetPos()
		local SampleAngles = SampleVehicle:EyeAngles()

		--MsgN(SampleVehicle)

		local SampleVehicleClass = "Default"
		local SampleLocalBias = Vector(0.0, 0.0, 0.0)

		if VehicleDataList[SampleVehicle:GetClass()] ~= nil then

			SampleVehicleClass = VehicleDataList[SampleVehicle:GetClass()].Class
			SampleLocalBias:Set(VehicleDataList[SampleVehicle:GetClass()].LocalBias)
			SampleLocalBias:Rotate(Angle(SampleAngles.pitch, -SampleAngles.yaw, SampleAngles.roll))
		end

		--MsgN(SampleVehicle:GetDriver())
		--MsgN(SampleVehicle:GetDriver().uuid)

		table.insert(OutTable.entities, {
			["type"] = "vehicle",
			["class"] = SampleVehicleClass,
			["x"] = tostring(math.Round(SamplePos.x + SampleLocalBias.x)),
			["y"] = tostring(math.Round(SamplePos.z + SampleLocalBias.z)),
			["z"] = tostring(-math.Round(SamplePos.y + SampleLocalBias.y)),
			["pitch"] = tostring(math.Round(SampleAngles.pitch)),
			["yaw"] = tostring(-math.Round(SampleAngles.yaw - 90.0)),
			["uuid"] = SampleVehicle.uuid,
			["driver"] = SampleVehicle:GetDriver().uuid or "none",
			["steering"] = SampleVehicle:GetSteering()
		})
	end

	--Physics props
	for SampleIndex, SampleProp in ipairs(ents.FindByClass("prop_physics*")) do

		local SamplePos = SampleProp:GetPos()
		local SampleAngles = SampleProp:EyeAngles()
		local BoundsMin, BoundsMax = SampleProp:GetModelBounds()

		table.insert(OutTable.entities, {
			["type"] = "prop",
			["name"] = SampleProp:GetName(),
			["x"] = tostring(math.Round(SamplePos.x)),
			["y"] = tostring(math.Round(SamplePos.z)),
			["z"] = tostring(-math.Round(SamplePos.y)),
			["pitch"] = tostring(math.Round(SampleAngles.pitch)),
			["yaw"] = tostring(-math.Round(SampleAngles.yaw)),
			["height"] = tostring(math.Round(BoundsMax.z - BoundsMin.z)),
			["uuid"] = SampleProp.uuid
		})
	end

	for SampleEntityClass, SampleProjectileClass in pairs(ProjectileClassList) do
		--MsgN(SampleEntityClass)
		for SampleIndex, SampleProjectile in ipairs(ents.FindByClass(SampleEntityClass)) do
			--MsgN(SampleProjectile)

			local SamplePos = SampleProjectile:GetPos()
			local SampleAngles = SampleProjectile:EyeAngles()

			table.insert(OutTable.entities, {
				["type"] = "projectile",
				["class"] = SampleProjectileClass,
				["x"] = tostring(math.Round(SamplePos.x)),
				["y"] = tostring(math.Round(SamplePos.z)),
				["z"] = tostring(-math.Round(SamplePos.y)),
				["pitch"] = tostring(math.Round(SampleAngles.pitch)),
				["yaw"] = tostring(-math.Round(SampleAngles.yaw - 90.0)),
				["uuid"] = SampleProjectile.uuid
			})
		end
	end
	table.CopyFromTo(MinecraftSendEventList, OutTable.events)
	table.Empty(MinecraftSendEventList)
	--PrintTable(OutTable)
	return OutTable
end

function MinecraftReceiveEntityUpdateData(InData)

	local ValidUUIDTable = {}

	--Get valid entities and update them
	for SampleIndex, SampleEntityData in ipairs(InData.entities or {}) do

		local UniqueID = SampleEntityData.uuid

		if SampleEntityData.type == "Projectile" then
			MinecraftCreateProjectile(SampleEntityData)
		else
			if not UUIDEntityList[UniqueID] then
				MinecraftCreateEntity(SampleEntityData)
			end
			MinecraftUpdateEntity(SampleEntityData)
			ValidUUIDTable[UniqueID] = true
		end
	end

	--PrintTable(UUIDEntityList)
	--PrintTable(ValidUUIDTable)

	--Remove invalid entities
	for SampleUUID, SampleEntity in pairs(UUIDEntityList) do
		if SampleEntity.bMinecraftEntity then

			--MsgN(ValidUUIDTable[SampleUUID])

			if ValidUUIDTable[SampleUUID] == nil then
				RemoveMinecraftEntity(SampleUUID)
			end
		end
	end

	--Process events
	for SampleIndex, SampleEventData in ipairs(InData.events) do
		if SampleEventData.type == "PlayerInteractButton" then

			local TargetEntity = Entity(SampleEventData.index)
			local ActivatorEntity = Entity(SampleEventData.activator or -1)
			TargetEntity:Input("Use", ActivatorEntity, TargetEntity, "_bridge")

		elseif SampleEventData.type == "Damage" then

			local TargetEntity = UUIDEntityList[SampleEventData.targetUuid]
			--PrintTable(SampleEventData)
			--local AttackerEntity = UUIDEntityList[SampleEventData.AttackerUUID]
			local DamageValue = tonumber(SampleEventData.value) * 5.0
			--MsgN(TargetEntity)

			if TargetEntity ~= nil and DamageValue ~= nil then

				if TargetEntity:IsPlayer() and TargetEntity:InVehicle() then
					TargetEntity = TargetEntity:GetVehicle()
				end

				timer.Simple(0.0, function()
					local TargetDamageInfo = DamageInfo()
					TargetDamageInfo:SetInflictor(TargetEntity)
					TargetDamageInfo:SetAttacker(TargetEntity)
					TargetDamageInfo:SetDamage(DamageValue)
					TargetDamageInfo:SetDamageType(228)
					TargetEntity:TakeDamageInfo(TargetDamageInfo)
				end)
			end
		elseif SampleEventData.type == "ChatMessage" then

			local TargetPlayer = UUIDEntityList[SampleEventData.targetUuid]

			if TargetPlayer ~= nil and IsValid(TargetPlayer) then
				TargetPlayer:Say(SampleEventData.value)
			end
		elseif SampleEventData.type == "BlockPlace" then
			MinecraftBlockPlace(Vector(SampleEventData.x, -SampleEventData.z, SampleEventData.y) + GetMinecraftBlockCenterOffset(), SampleEventData.id, SampleEventData.targetUuid)
		elseif SampleEventData.type == "BlockBreak" then
			MinecraftBlockBreak(Vector(SampleEventData.x, -SampleEventData.z, SampleEventData.y) + GetMinecraftBlockCenterOffset(), SampleEventData.targetUuid)
		elseif SampleEventData.type == "PlayerPlaceWater" then
			MinecraftWaterPlace(Vector(SampleEventData.x, -SampleEventData.z, SampleEventData.y) + GetMinecraftBlockCenterOffset(), SampleEventData.targetUuid)
		elseif SampleEventData.type == "PlayerRemoveWater" then
			MinecraftWaterRemove(Vector(SampleEventData.x, -SampleEventData.z, SampleEventData.y) + GetMinecraftBlockCenterOffset(), SampleEventData.targetUuid)
		end
	end
end

function OnMinecraftPostFailure(InError)

	--MsgN(Format("OnMinecraftPostFailure() error: %s", InError))

	PrintMessage(HUD_PRINTTALK, "Minecraft bridge error: "..InError)

	if MinecraftIsBridgeEnabled() then
		ToggleMinecraftBridge()
	end
end

function MinecraftUpdateEntity(InEntityData)

	--MsgN("MinecraftUpdateEntity()")
	--PrintTable(InEntityData)

	local MinecraftEntity = UUIDEntityList[InEntityData.uuid]

	if MinecraftEntity:IsPlayer() then
		if InEntityData.health > 0 and not MinecraftEntity:Alive() then
			MinecraftEntity:Spawn()
		elseif InEntityData.health <= 0 and MinecraftEntity:Alive() then
			MinecraftEntity:Kill()
		end

		local WeaponClass = MinecraftTryGetWeaponForHand(InEntityData.hand)

		if MinecraftTryGetBlockColorByID(InEntityData.hand) ~= nil then --If players holds valid block
			WeaponClass = "weapon_crowbar"
		end

		if WeaponClass ~= nil then
			MinecraftEntity:Give(WeaponClass)
			MinecraftEntity:SetActiveWeapon(MinecraftEntity:GetWeapon(WeaponClass))
		else
			MinecraftEntity:StripWeapons()
		end
		--local bFlaslightOn = InEntityData.bFlashlight == "true"
		--MsgN(bFlaslightOn)

		if InEntityData.bFlashlight ~= MinecraftEntity:FlashlightIsOn() then
			--MsgN(InEntityData.bFlashlight)
			MinecraftEntity:Flashlight(InEntityData.bFlashlight)
		end
	end

	MinecraftEntity:SetHealth(InEntityData.health * 5.0)
	MinecraftEntity.LerpPos = Vector(InEntityData.x, -InEntityData.z, InEntityData.y)
	MinecraftEntity.LerpAngles = Angle(InEntityData.pitch, -InEntityData.yaw - 90.0, 0.0)
	MinecraftEntity.bCrouching = (InEntityData.isSitting == 1)
	--MsgN(MinecraftEntity.bCrouching)
end

function RemoveAllUUIDEntities()
	
	for SampleUUID, SampleEntity in pairs(UUIDEntityList) do
		if SampleEntity.bMinecraftEntity then
			RemoveMinecraftEntity(SampleUUID)
		end
	end
end

function RemoveMinecraftEntity(InUUID)

	--MsgN("RemoveMinecraftEntity()")

	local MinecraftEntity = UUIDEntityList[InUUID]

	if MinecraftEntity:IsPlayer() then
		MinecraftEntity:EmitSound("Player.FallGib")
		MinecraftEntity:Kick("Minecraft Disconnect")
	else
		MinecraftEntity:EmitSound("Bounce.Metal")
		MinecraftEntity:Remove()
	end
	UUIDEntityList[InUUID] = nil
end

function MinecraftBlockPlace(InBlockOrigin, InBlockID, InTargetUUID)

	MinecraftBlockBreak(InBlockOrigin, InTargetUUID)

	local BlockEntity = ents.Create("prop_dynamic")
	BlockEntity:SetModel("models/props_junk/wood_crate001a.mdl")

	local BlockCenterOffset = GetMinecraftBlockCenterOffset()
	BlockEntity:PhysicsInitBox(-BlockCenterOffset, BlockCenterOffset)

	--BlockEntity:SetModelScale(0.5)

	BlockEntity:SetModelScale(1.61 / 64.0 * GetMinecraftBlockSize(), 0.5)
	BlockEntity:SetPos(InBlockOrigin)
	BlockEntity:PrecacheGibs()

	local BlockColor = MinecraftTryGetBlockColorByID(InBlockID)

	if BlockColor ~= nil then
		BlockEntity:SetColor(BlockColor)
	end

	BlockEntity:Spawn()
	BlockEntity.bMinecraftBlock = true

	local SamplePlayer = UUIDEntityList[InTargetUUID]

	if SamplePlayer ~= nil then
		SamplePlayer:DoAttackEvent()
	end
end

function MinecraftBlockBreak(InBlockOrigin, InTargetUUID)

	for SampleIndex, SampleEntity in ipairs(ents.FindInSphere(InBlockOrigin, GetMinecraftBlockSize() * 0.25)) do

		--MsgN(SampleEntity)

		if SampleEntity.bMinecraftBlock then
		
			local SampleBreakForce = Vector(0.0, 0.0, 0.0)
			local SamplePlayer = UUIDEntityList[InTargetUUID]

			if SamplePlayer ~= nil then
				SamplePlayer:DoAttackEvent()
				SampleBreakForce = SampleEntity:GetPos() - SamplePlayer:GetPos()
			end

			SampleEntity:GibBreakClient(SampleBreakForce)
			SampleEntity.bMinecraftBlock = false
			SampleEntity:Remove()
		end
	end
end

function MinecraftWaterPlace(InBlockOrigin, InTargetUUID)

	MinecraftWaterRemove(InBlockOrigin, InTargetUUID)
	table.insert(MinecraftWaterLocationList, InBlockOrigin)
	hook.Add("PostDrawOpaqueRenderables", "MinecraftDrawWaterTextHook", MinecraftDrawWaterText)

	local SamplePlayer = UUIDEntityList[InTargetUUID]

	if SamplePlayer ~= nil then
		SamplePlayer:DoAttackEvent()
	end
end

function MinecraftWaterRemove(InBlockOrigin, InTargetUUID)

	table.remove(MinecraftWaterLocationList, InBlockOrigin)

	if table.IsEmpty(MinecraftWaterLocationList) then
		hook.Remove("PostDrawOpaqueRenderables", "MinecraftDrawWaterTextHook", MinecraftDrawWaterText)
	end
end

function MinecraftDrawWaterText(bDepth, bSkybox)
	
end

hook.Add("OnEntityCreated", "MinecraftEntityCreated", function(InEntity)

	if IsValid(InEntity) then
		if not InEntity:IsPlayer() then

			InEntity.uuid = tostring(InEntity:EntIndex())

			if InEntity:GetName() == "" then
				InEntity:SetName(InEntity.uuid)
			end
		end

		if InEntity:IsNPC() then
			RegisterUUIDEntity(InEntity.uuid, InEntity)
		end
	end
end)

hook.Add("EntityRemoved", "MinecraftEntityRemoved", function(InEntity)

	if not MinecraftIsBridgeEnabled() then return end

	--MsgN("EntityRemoved()")

	if IsValid(InEntity) then
		if InEntity.bMinecraftBlock then
			local BlockCoordinates = (InEntity:GetPos() - GetMinecraftBlockCenterOffset())

			MinecraftAddEventToList({
				type = "gmodBlockBreak",
				x = math.Round(BlockCoordinates.x),
				y = math.Round(BlockCoordinates.z),
				z = -math.Round(BlockCoordinates.y)
			})
			return
		end

		if MinecraftExplosiveClassList[InEntity:GetClass()] then			
			HandleMinecraftEntityExplosionEvent(InEntity)
			return
		end
	end
end)

hook.Add("PropBreak", "MinecraftPropBreak", function(InAttacker, InProp)

	if not MinecraftIsBridgeEnabled() then return end

	--MsgN("PropBreak()")

	if IsValid(InProp) then
		if MinecraftExplosiveModelList[InProp:GetModel()] then
			HandleMinecraftEntityExplosionEvent(InProp)
		end
	end
end)

function HandleMinecraftEntityExplosionEvent(InEntity)

	local SamplePos = InEntity:GetPos()

	MinecraftAddEventToList({
		type = "Explosion",
		x = math.Round(SamplePos.x),
		y = math.Round(SamplePos.z),
		z = -math.Round(SamplePos.y)
	})
end

hook.Add("EntityTakeDamage", "MinecraftTakeDamage", function(InEntity, InDamageInfo)

	--MsgN("EntityTakeDamage")

	if not MinecraftIsBridgeEnabled() then return end	
	if InDamageInfo:GetDamageType() == 228 then return end
	if InEntity.bMinecraftBlock then return end
	if InEntity:IsPlayer() or InEntity:IsNPC() then
		MinecraftAddEventToList({
			type = "Damage",
			targetUuid = InEntity.uuid,
			attackerUuid = InDamageInfo:GetAttacker().uuid or "",
			dmgtype = InDamageInfo:GetDamageType(),
			value = math.Round(InDamageInfo:GetDamage())
		})
		--PrintTable(MinecraftSendEventList)
		return InEntity.bMinecraftEntity
	end
end)
