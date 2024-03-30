-- Author: Shush
-- Date: 2/5/2017

------------------------------
--     HELPER FUNCTIONS     --
------------------------------

local function RefreshElectroCharge(unit)
	local modifier_electrocharge = "modifier_imba_statis_trap_electrocharge"

	-- If the enemy has Electrocharge (from Stasis Trap), refresh it and add a stack
	local modifier_electrocharge_handler = unit:FindModifierByName(modifier_electrocharge)
	if modifier_electrocharge_handler then
		modifier_electrocharge_handler:IncrementStackCount()
		modifier_electrocharge_handler:ForceRefresh()
	end
end

local function PlantProximityMine(caster, ability, spawn_point)
	local mine_ability = "imba_techies_proximity_mine_trigger"

	-- Create the mine unit
	local mine_name = "npc_imba_techies_proximity_mine"
	local mine = CreateUnitByName(mine_name, spawn_point, true, caster, caster, caster:GetTeamNumber())

	mine:AddRangeIndicator(caster, nil, nil, ability:GetAOERadius(), 150, 22, 22, false, false, false)

	-- Set the mine's team to be the same as the caster
	local playerID = caster:GetPlayerID()
	mine:SetControllableByPlayer(playerID, true)

	-- Set the mine's ability to be the same level as the planting ability
	local mine_ability_handler = mine:FindAbilityByName(mine_ability)
	if mine_ability_handler then
		mine_ability_handler:SetLevel(ability:GetLevel())
	end

	-- Set the mine's owner to be the caster
	mine:SetOwner(caster)
end

------------------------------
--     PROXIMITY MINE       --
------------------------------
imba_techies_proximity_mine = imba_techies_proximity_mine or class({})
LinkLuaModifier("modifier_imba_proximity_mine_charges", "heroes/hero_techies.lua", LUA_MODIFIER_MOTION_NONE)

function imba_techies_proximity_mine:GetAbilityTextureName()
   return "techies_land_mines"
end

function imba_techies_proximity_mine:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end

function imba_techies_proximity_mine:IsHiddenWhenStolen()
	return false
end

function imba_techies_proximity_mine:IsNetherWardStealable()
	return false
end

function imba_techies_proximity_mine:GetIntrinsicModifierName()
	return "modifier_imba_proximity_mine_charges"
end

function imba_techies_proximity_mine:GetManaCost(level)
	-- Ability properties
	local caster = self:GetCaster()
	local initial_mana_cost = self.BaseClass.GetManaCost(self, level)
	local modifier_charges = "modifier_imba_proximity_mine_charges"

	-- Ability specials
	local mana_increase_per_stack = self:GetSpecialValueFor("mana_increase_per_stack")

	-- Find stack count
	stacks = caster:GetModifierStackCount(modifier_charges, caster)

	local mana_cost = initial_mana_cost + mana_increase_per_stack * stacks
	return mana_cost
end

function imba_techies_proximity_mine:CastFilterResultLocation(location)
	if IsServer() then
		-- Ability properties
		local caster = self:GetCaster()
		local ability = self

		-- Ability specials
		local mine_distance = ability:GetSpecialValueFor("mine_distance")
		local trigger_range = ability:GetSpecialValueFor("trigger_range")

		-- Radius
		local radius = mine_distance + trigger_range

		-- Look for nearby mines
		local friendly_units = FindUnitsInRadius(caster:GetTeamNumber(),
			location,
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_OTHER,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false
		)

		local mine_found = false

		-- Search and see if mines were found
		for _,unit in pairs(friendly_units) do
			local unitName = unit:GetUnitName()
			if unitName == "npc_imba_techies_proximity_mine" then
				mine_found = true
				break
			end
		end

		if mine_found then
			return UF_FAIL_CUSTOM
		else
			return UF_SUCCESS
		end
	end
end

function imba_techies_proximity_mine:GetCustomCastErrorLocation(location)
	return "Cannot place mine in range of other mines"
end

function imba_techies_proximity_mine:GetAOERadius()
	local caster = self:GetCaster()
	local ability = self

	local trigger_range = ability:GetSpecialValueFor("trigger_range")
	local mine_distance = ability:GetSpecialValueFor("mine_distance")

	return trigger_range + mine_distance
end

function imba_techies_proximity_mine:OnSpellStart()
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local target_point = self:GetCursorPosition()
	local cast_response = {"techies_tech_setmine_01", "techies_tech_setmine_02", "techies_tech_setmine_04", "techies_tech_setmine_08", "techies_tech_setmine_09", "techies_tech_setmine_10", "techies_tech_setmine_11", "techies_tech_setmine_13", "techies_tech_setmine_16", "techies_tech_setmine_17", "techies_tech_setmine_18", "techies_tech_setmine_19", "techies_tech_setmine_20", "techies_tech_setmine_30", "techies_tech_setmine_32", "techies_tech_setmine_33", "techies_tech_setmine_34", "techies_tech_setmine_38", "techies_tech_setmine_45", "techies_tech_setmine_46", "techies_tech_setmine_47", "techies_tech_setmine_48", "techies_tech_setmine_50", "techies_tech_setmine_51", "techies_tech_setmine_54", "techies_tech_cast_02", "techies_tech_cast_03", "techies_tech_setmine_05", "techies_tech_setmine_06", "techies_tech_setmine_07", "techies_tech_setmine_14", "techies_tech_setmine_21", "techies_tech_setmine_22", "techies_tech_setmine_23", "techies_tech_setmine_24", "techies_tech_setmine_25", "techies_tech_setmine_26", "techies_tech_setmine_28", "techies_tech_setmine_29", "techies_tech_setmine_35", "techies_tech_setmine_36", "techies_tech_setmine_37", "techies_tech_setmine_39", "techies_tech_setmine_41", "techies_tech_setmine_42", "techies_tech_setmine_43", "techies_tech_setmine_44", "techies_tech_setmine_52"}
	local sound_cast = "Hero_Techies.LandMine.Plant"
	local modifier_charges = "modifier_imba_proximity_mine_charges"

	-- Ability special
	local initial_mines = ability:GetSpecialValueFor("initial_mines")
	local mine_distance = ability:GetSpecialValueFor("mine_distance")

	-- Play cast response
	EmitSoundOn(cast_response[math.random(1, #cast_response)], caster)

	-- Play cast sound
	EmitSoundOn(sound_cast, caster)

	-- Get the amount of Proximity Mine charges, and consume all stacks
	local mine_placement_count = 0
	local modifier_charges_handler = caster:FindModifierByName(modifier_charges)
	if modifier_charges_handler then
		mine_placement_count = modifier_charges_handler:GetStackCount()

		-- If there are no charges, do nothing
		if modifier_charges_handler:GetStackCount() > 0 then
			modifier_charges_handler:SetStackCount(0)
		end
	end

	-- Determine mine locations, depending on mine count
	local direction = (target_point - caster:GetAbsOrigin()):Normalized()

	PlantProximityMine(caster, ability, target_point)

	-- Rotate the locations and find the additional mine spots
	if mine_placement_count > 0 then
		local degree = 360 / mine_placement_count

		-- Calculate location of the first mine, ahead of the target point
		local mine_spawn_point = target_point + direction * mine_distance

		for i = 1, mine_placement_count do
			-- Prepare the QAngle
			local qangle = QAngle(0, (i-1) * degree, 0)

			-- Rotate the mine point
			local mine_point = RotatePosition(target_point, qangle, mine_spawn_point)

			-- Plant a mine!
			PlantProximityMine(caster, ability, mine_point, false)
		end
	end
end


-- Charges modifier
modifier_imba_proximity_mine_charges = modifier_imba_proximity_mine_charges or class({})

function modifier_imba_proximity_mine_charges:OnCreated()
	local ability = self:GetAbility()

	-- Ability specials
	self.charge_replenish_duration = ability:GetSpecialValueFor("charge_replenish_duration")
	self.max_charges = ability:GetSpecialValueFor("max_charges")

	-- Set a bonus first mine immediatley when the ability is first learned
	if not self.repeated then
		self:SetStackCount(1)
		self:SetDuration(self.charge_replenish_duration, true)
		self.repeated = true
	end

	-- Start thinking
	self:StartIntervalThink(0.1)
end

function modifier_imba_proximity_mine_charges:OnRefresh()
	self:OnCreated()
end

function modifier_imba_proximity_mine_charges:OnIntervalThink()
	-- Check the current duration
	local duration = self:GetDuration()

	-- If the duration is fixed, do nothing
	if duration == -1 then
		return nil
	end

	-- If the amount of mines somehow got over the maximum, retain max charges
	if self:GetStackCount() > self.max_charges then
		self:SetStackCount(self.max_charges)
	end

	-- Otherwise, get the remaining duration. If it's 0 or below, grant a stack!
	local remaining_duration = self:GetRemainingTime()

	if remaining_duration <= 0 then
		self.restart = true
		self:IncrementStackCount()
	end
end

function modifier_imba_proximity_mine_charges:IsHidden() return false end
function modifier_imba_proximity_mine_charges:IsDebuff() return false end
function modifier_imba_proximity_mine_charges:IsPurgable() return false end
function modifier_imba_proximity_mine_charges:RemoveOnDeath() return false end
function modifier_imba_proximity_mine_charges:AllowIllusionDuplicate() return false end
function modifier_imba_proximity_mine_charges:DestroyOnExpire() return false end

function modifier_imba_proximity_mine_charges:OnStackCountChanged(old_count)
	-- Get current stack count
	local stacks = self:GetStackCount()

	-- If the stacks somehow surpassed max charges, reset to max
	-- This somehow happens when player is disconnected for some reason
	if stacks > self.max_charges then
		self:SetStackCount(self.max_charges)
	end

	-- If the stack is in the maximum, stop the duration
	if stacks == self.max_charges then
		self:SetDuration(-1, true)

	-- Otherwise, if it needs to be restared, do so
	elseif self.restart or old_count == self.max_charges then
		self:SetDuration(self.charge_replenish_duration, true)
	end

	self.restart = false
end


------------------------------
--     PROXIMITY MINE AI    --
------------------------------
imba_techies_proximity_mine_trigger = imba_techies_proximity_mine_trigger or class({})
LinkLuaModifier("modifier_imba_proximity_mine", "heroes/hero_techies.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_proximity_mine_building_res", "heroes/hero_techies.lua", LUA_MODIFIER_MOTION_NONE)

function imba_techies_proximity_mine_trigger:GetIntrinsicModifierName()
	return "modifier_imba_proximity_mine"
end

function imba_techies_proximity_mine_trigger:GetAbilityTextureName()
   return "rubick_empty1"
end

-- Proximity mine states modifier
modifier_imba_proximity_mine = modifier_imba_proximity_mine or class({})

function modifier_imba_proximity_mine:OnCreated()
	if IsServer() then
		-- Ability properties
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.owner = self.caster:GetOwner()

		-- Ability specials
		self.explosion_delay = self.ability:GetSpecialValueFor("explosion_delay")
		self.mine_damage = self.ability:GetSpecialValueFor("mine_damage")
		self.explosion_range = self.ability:GetSpecialValueFor("explosion_range")
		self.trigger_range = self.ability:GetSpecialValueFor("trigger_range")
		self.activation_delay = self.ability:GetSpecialValueFor("activation_delay")
		self.building_damage_pct = self.ability:GetSpecialValueFor("building_damage_pct")
		self.buidling_damage_duration = self.ability:GetSpecialValueFor("buidling_damage_duration")
		self.tick_interval = self.ability:GetSpecialValueFor("tick_interval")
		self.fow_radius = self.ability:GetSpecialValueFor("fow_radius")
		self.fow_duration = self.ability:GetSpecialValueFor("fow_duration")

		-- Add mine particle effect
		local particle_mine = "particles/units/heroes/hero_techies/techies_land_mine.vpcf"
		local particle_mine_fx = ParticleManager:CreateParticle(particle_mine, PATTACH_ABSORIGIN_FOLLOW, self.caster)
		ParticleManager:SetParticleControl(particle_mine_fx, 0, self.caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle_mine_fx, 3, self.caster:GetAbsOrigin())
		self:AddParticle(particle_mine_fx, false, false, -1, false, false)

		-- Set the mine as inactive
		self.active = false
		self.triggered = false
		self.trigger_time = 0

		if IsServer() then
			-- Wait for the mine to activate
			Timers:CreateTimer(self.activation_delay, function()
				-- Mark mine as active
				self.active = true

				-- Start looking around for enemies
				self:StartIntervalThink(self.tick_interval)
			end)
		end
	end
end

function modifier_imba_proximity_mine:IsHidden() return true end
function modifier_imba_proximity_mine:IsPurgable() return false end
function modifier_imba_proximity_mine:IsDebuff() return false end

function modifier_imba_proximity_mine:OnIntervalThink()
	if IsServer() then
		local caster = self.caster

		-- If the mine was killed, remove the modifier
		if not caster:IsAlive() then
			self:Destroy()
		end

		local modifier_sign = "modifier_imba_minefield_sign_detection"
		-- If the mine is under the sign effect, reset possible triggers and do nothing
		if caster:HasModifier(modifier_sign) then
			self.triggered = false
			self.trigger_time = 0
			self.hidden_by_sign = true
			return nil
		end

		-- Look for nearby enemies
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
										  caster:GetAbsOrigin(),
										  nil,
										  self.trigger_range,
										  DOTA_UNIT_TARGET_TEAM_ENEMY,
										  DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
										  DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
										  FIND_ANY_ORDER,
										  false)

		local enemy_found

		if #enemies > 0 then
			local non_flying_enemies = false

			-- Check if there is at least one enemy that isn't flying
			for _,enemy in pairs(enemies) do
				if not enemy:HasFlyMovementCapability() then
					non_flying_enemies = true
					break
				end
			end

			-- At least one non-flying enemy found - mark as found
			if non_flying_enemies then
				enemy_found = true
			else
				enemy_found = false
			end
		else
			enemy_found = false
		end

		-- If the mine is not triggered, check if it should be triggered
		if not self.triggered then
			if enemy_found then
				self.triggered = true
				self.trigger_time = 0

				-- Play prime sound
				local sound_prime = "Hero_Techies.LandMine.Priming"
				EmitSoundOn(sound_prime, caster)
			end

		-- If the mine was already triggered, check if it should stop or count time
		else
			if enemy_found then
				self.trigger_time = self.trigger_time + self.tick_interval

				-- Check if the mine should blow up
				if self.trigger_time >= self.explosion_delay then
					self:_Explode()
				end
			else
				self.triggered = false
				self.trigger_time = 0
			end
		end
	end
end

function modifier_imba_proximity_mine:_Explode()
	local enemy_killed
	local caster = self.caster
	local explosion_range = self.explosion_range

	-- BLOW UP TIME! Play explosion sound
	local sound_explosion = "Hero_Techies.LandMine.Detonate"
	EmitSoundOn(sound_explosion, caster)

	local casterAbsOrigin = caster:GetAbsOrigin()

	-- Add particle explosion effect
	local particle_explosion = "particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf"
	local particle_explosion_fx = ParticleManager:CreateParticle(particle_explosion, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle_explosion_fx, 0, casterAbsOrigin)
	ParticleManager:SetParticleControl(particle_explosion_fx, 1, casterAbsOrigin)
	ParticleManager:SetParticleControl(particle_explosion_fx, 2, Vector(explosion_range, 1, 1))
	ParticleManager:ReleaseParticleIndex(particle_explosion_fx)

	-- Look for nearby enemies
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
										casterAbsOrigin,
										nil,
										explosion_range,
										DOTA_UNIT_TARGET_TEAM_ENEMY,
										DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
										DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
										FIND_ANY_ORDER,
										false)

	-- Deal damage to nearby non-flying enemies
	for _,enemy in pairs(enemies) do
		-- If an enemy doesn't have flying movement, ignore it, otherwise continue
		if not enemy:HasFlyMovementCapability() then
			-- If this is a Big Boom, add damage to the blast!
			local damage = self.mine_damage

			-- If the enemy is a building, reduce damage to it
			if enemy:IsBuilding() then
				damage = damage * self.building_damage_pct * 0.01
			end

			-- Deal damage
			local damageTable = {victim = enemy,
									attacker = caster, 
--									damage = damage * ((1+(PlayerResource:GetSelectedHeroEntity(self.caster:GetPlayerOwnerID()):GetSpellPower() * 0.01))),
									damage = damage,
									damage_type = DAMAGE_TYPE_MAGICAL,
									ability = self.ability
									}

			ApplyDamage(damageTable)

			-- If the enemy was a building, give it magical protection
			if enemy:IsBuilding() and not enemy:HasModifier("modifier_imba_proximity_mine_building_res") then
				enemy:AddNewModifier(caster, self.ability, "modifier_imba_proximity_mine_building_res", {duration = self.buidling_damage_duration})
			end

			RefreshElectroCharge(enemy)

			-- See if the enemy died from the mine
			Timers:CreateTimer(FrameTime(), function()
				if not enemy:IsAlive() then
					enemy_killed = true
				end
			end)
		end
	end

	-- If an enemy was killed from a mine, play kill response
	if RollPercentage(25) then
		Timers:CreateTimer(FrameTime()*2, function()
			local kill_response = {"techies_tech_mineblowsup_01", "techies_tech_mineblowsup_02", "techies_tech_mineblowsup_03", "techies_tech_mineblowsup_04", "techies_tech_mineblowsup_05", "techies_tech_mineblowsup_06", "techies_tech_mineblowsup_08", "techies_tech_mineblowsup_09", "techies_tech_minekill_01", "techies_tech_minekill_02", "techies_tech_minekill_03"}

			if enemy_killed then
				EmitSoundOn(kill_response[math.random(1, #kill_response)], self.owner)
			end
		end)
	end

	-- Apply flying vision at detonation point
	AddFOWViewer(caster:GetTeamNumber(), casterAbsOrigin, self.fow_radius, self.fow_duration, false)

	-- Kill self and remove modifier
	caster:ForceKill(false)
	self:Destroy()
end

function modifier_imba_proximity_mine:CheckState()
	local state

	if self.active and not self.triggered then
		state = {[MODIFIER_STATE_INVISIBLE] = true,
				 [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	else
		state = {[MODIFIER_STATE_INVISIBLE] = false,
				 [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
	end

	return state
end

function modifier_imba_proximity_mine:DeclareFunctions()
	local decFuncs = {MODIFIER_EVENT_ON_TAKEDAMAGE,
					 MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}

	return decFuncs
end

function modifier_imba_proximity_mine:GetModifierIncomingDamage_Percentage()
	return -100
end

function modifier_imba_proximity_mine:OnTakeDamage(keys)
	local unit = keys.unit
	local attacker = keys.attacker

	-- Only apply if the unit taking damage is the mine
	if unit == self.caster then
		-- Reduce mines' life by 1, or kill it. This is only relevant for Big Boom mines
		local mine_health = self.caster:GetHealth()
		if mine_health > 1 then
			self.caster:SetHealth(mine_health - 1)
		else
			self.caster:Kill(self.ability, attacker)
		end
	end
end

function modifier_imba_proximity_mine:GetPriority()
	return MODIFIER_PRIORITY_NORMAL
end


-- Building fortification modifier
modifier_imba_proximity_mine_building_res = modifier_imba_proximity_mine_building_res or class({})

function modifier_imba_proximity_mine_building_res:OnCreated()
	-- Ability properties
	self.ability = self:GetAbility()

	-- Ability specials
	self.building_magic_resistance = self.ability:GetSpecialValueFor("building_magic_resistance")
end

function modifier_imba_proximity_mine_building_res:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}

	return decFuncs
end

function modifier_imba_proximity_mine_building_res:GetModifierMagicalResistanceBonus()
	return self.building_magic_resistance
end

function modifier_imba_proximity_mine_building_res:IsHidden() return true end
function modifier_imba_proximity_mine_building_res:IsPurgable() return false end
function modifier_imba_proximity_mine_building_res:IsDebuff() return false end

------------------------------
--       STASIS TRAP        --
------------------------------
imba_techies_stasis_trap = imba_techies_stasis_trap or class({})

function imba_techies_stasis_trap:GetAbilityTextureName()
   return "techies_stasis_trap"
end

function imba_techies_stasis_trap:IsHiddenWhenStolen()
	return false
end

function imba_techies_stasis_trap:IsNetherWardStealable()
	return false
end

function imba_techies_stasis_trap:GetAOERadius()
	local root_range = self:GetSpecialValueFor("root_range")
	return root_range
end

function imba_techies_stasis_trap:GetBehavior()
	local caster = self:GetCaster()

	-- #2 Talent: Stasis Traps can be placed within friendly creeps
	if caster:HasTalent("special_bonus_imba_techies_2") then
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
	end
end

function imba_techies_stasis_trap:CastFilterResultTarget(target)
	if IsServer() then
		local caster = self:GetCaster()

		-- #2 Talent: Stasis Trap can be inserted within creeps
		if caster:HasTalent("special_bonus_imba_techies_2") and target:IsCreep() and caster:GetTeamNumber() == target:GetTeamNumber() then
			return UF_SUCCESS
		end

		if target:GetTeamNumber() ~= caster:GetTeamNumber() then
			return UF_FAIL_ENEMY
		end

		if target:IsHero() then
			return UF_FAIL_HERO
		end

		if target:IsBuilding() then
			return UF_FAIL_BUILDING
		end

		local nResult = UnitFilter( target, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), self:GetCaster():GetTeamNumber() )
		return nResult
	end
end

function imba_techies_stasis_trap:OnAbilityPhaseStart()

	local target = self:GetCursorTarget()

	if target then
		-- If it was on a target, place effect in it
		local particle_creep = "particles/hero/techies/techies_stasis_trap_plant_creep.vpcf"
		local particle_creep_fx = ParticleManager:CreateParticle(particle_creep, PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(particle_creep_fx, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(particle_creep_fx, 1, target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(particle_creep_fx)

	-- If it was on a point in the ground, place effect
	else
		local caster = self:GetCaster()
		local target_point = self:GetCursorPosition()
		-- Add cast particle
		local particle_cast = "particles/units/heroes/hero_techies/techies_stasis_trap_plant.vpcf"
		local particle_cast_fx = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle_cast_fx, 0, target_point)
		ParticleManager:SetParticleControl(particle_cast_fx, 1, target_point)
		ParticleManager:ReleaseParticleIndex(particle_cast_fx)
	end

	return true
end

function imba_techies_stasis_trap:OnSpellStart()
	-- Ability properties
	local caster = self:GetCaster()
	local ability = self
	local target = self:GetCursorTarget()
	local target_point = self:GetCursorPosition()
	local particle_creep = "particles/hero/techies/techies_stasis_trap_plant_creep.vpcf"
	local cast_response = {"techies_tech_settrap_01", "techies_tech_settrap_02", "techies_tech_settrap_03", "techies_tech_settrap_04", "techies_tech_settrap_06", "techies_tech_settrap_07", "techies_tech_settrap_08", "techies_tech_settrap_09", "techies_tech_settrap_10", "techies_tech_settrap_11"}
	local sound_cast = "Hero_Techies.StasisTrap.Plant"

	-- Roll for a cast response
	if RollPercentage(75) then
		EmitSoundOn(cast_response[math.random(1,#cast_response)], caster)
	end

	-- Play cast sound
	EmitSoundOn(sound_cast, caster)

	-- Plant inside a creep (#2 Talent)
	if target then
		local modifier_stasis = target:AddNewModifier(target, ability, "modifier_imba_statis_trap", {})
		if modifier_stasis then
			modifier_stasis.owner = caster
		end

		Timers:CreateTimer(1, function()
			if target:IsAlive() then
				local particle_creep_fx = ParticleManager:CreateParticle(particle_creep, PATTACH_CUSTOMORIGIN_FOLLOW, target)
				ParticleManager:SetParticleControlEnt(particle_creep_fx, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(particle_creep_fx, 1, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ParticleManager:ReleaseParticleIndex(particle_creep_fx)

				return 1
			else

				return nil
			end
		end)

	else -- Plant on the ground
		-- Plant trap
		local trap = CreateUnitByName("npc_dota_techies_stasis_trap", target_point, true, caster, caster, caster:GetTeamNumber())
		local trap_ability = "imba_techies_stasis_trap_trigger"

		-- Set the mine's team to be the same as the caster
		local playerID = caster:GetPlayerID()
		trap:SetControllableByPlayer(playerID, true)

		-- Set the mine's ability to be the same level as the planting ability
		local trap_ability_handler = trap:FindAbilityByName(trap_ability)
		if trap_ability_handler then
			trap_ability_handler:SetLevel(ability:GetLevel())
		end

		-- Set the mine's owner to be the caster
		trap:SetOwner(caster)
	end
end



------------------------------
--      STATIS TRAP AI      --
------------------------------
imba_techies_stasis_trap_trigger = imba_techies_stasis_trap_trigger or class({})
LinkLuaModifier("modifier_imba_statis_trap", "heroes/hero_techies.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_statis_trap_root", "heroes/hero_techies.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_statis_trap_electrocharge", "heroes/hero_techies.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_imba_statis_trap_disarmed", "heroes/hero_techies.lua", LUA_MODIFIER_MOTION_NONE)

function imba_techies_stasis_trap_trigger:GetAbilityTextureName()
   return "techies_stasis_trap"
end

function imba_techies_stasis_trap_trigger:GetIntrinsicModifierName()
	return "modifier_imba_statis_trap"
end

-- Statis Trap thinker modifier
modifier_imba_statis_trap = modifier_imba_statis_trap or class({})


function modifier_imba_statis_trap:OnCreated()
	if IsServer() then
		-- Ability properties
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.owner = self.caster:GetOwner()

		-- Ability specials
		self.activate_delay = self.ability:GetSpecialValueFor("activate_delay")
		self.trigger_range = self.ability:GetSpecialValueFor("trigger_range")
		self.root_range = self.ability:GetSpecialValueFor("root_range")
		self.root_duration = self.ability:GetSpecialValueFor("root_duration")
		self.tick_rate = self.ability:GetSpecialValueFor("tick_rate")
		self.flying_vision_duration = self.ability:GetSpecialValueFor("flying_vision_duration")

		-- Set variables
		self.active = false

		-- Wait for activation
		Timers:CreateTimer(self.activate_delay, function()

			-- Mark trap as activated
			self.active = true

			-- Start thinking
			self:StartIntervalThink(self.tick_rate)
		end)
	end
end

function modifier_imba_statis_trap:IsHidden() return true end
function modifier_imba_statis_trap:IsPurgable() return false end
function modifier_imba_statis_trap:IsDebuff() return false end

function modifier_imba_statis_trap:OnIntervalThink()
	if IsServer() then
		local caster = self.caster

		-- If the caster has the sign modifier, do nothing
		local modifier_sign = "modifier_imba_minefield_sign_detection"
		if caster:HasModifier(modifier_sign) then
			return nil
		end

		-- If the Stasis trap is dead, do nothing and destroy
		if not caster:IsAlive() then
			self:Destroy()
			return nil
		end

		-- Look for nearby enemies
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
										  caster:GetAbsOrigin(),
										  nil,
										  self.trigger_range,
										  DOTA_UNIT_TARGET_TEAM_ENEMY,
										  DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
										  DOTA_UNIT_TARGET_FLAG_NO_INVIS,
										  FIND_ANY_ORDER,
										  false)

		if #enemies > 0 then
			self:_Explode()
		end
	end
end

function modifier_imba_statis_trap:_Explode()
	local caster = self.caster

	-- Springing the trap! Play root sound
	local sound_explosion = "Hero_Techies.StasisTrap.Stun"
	EmitSoundOn(sound_explosion, caster)

	-- Add explosion particle
	local particle_explode = "particles/units/heroes/hero_techies/techies_stasis_trap_explode.vpcf"
	local particle_explode_fx = ParticleManager:CreateParticle(particle_explode, PATTACH_WORLDORIGIN, caster)
	ParticleManager:SetParticleControl(particle_explode_fx, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(particle_explode_fx, 1, Vector(self.root_range, 1, 1))
	ParticleManager:SetParticleControl(particle_explode_fx, 3, caster:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(particle_explode_fx)

	-- Find all units in radius
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(),
								caster:GetAbsOrigin(),
								nil,
								self.root_range,
								DOTA_UNIT_TARGET_TEAM_ENEMY,
								DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
								DOTA_UNIT_TARGET_FLAG_NONE,
								FIND_ANY_ORDER,
								false)

	local modifier_root = "modifier_imba_statis_trap_root"
	local modifier_electrocharge = "modifier_imba_statis_trap_electrocharge"
	local modifier_disarmed = "modifier_imba_statis_trap_disarmed"

	-- Root enemies nearby if not disarmed, and apply a electrocharge
	for _,enemy in pairs(enemies) do
		if not caster:HasModifier(modifier_disarmed) then
			enemy:AddNewModifier(caster, self.ability, modifier_root, {duration = self.root_duration})
		end

		-- If the enemy is not yet afflicted with electrocharge, add it. Otherwise, add a stack
		if not enemy:HasModifier(modifier_electrocharge) then
			enemy:AddNewModifier(caster, self.ability, modifier_electrocharge, {duration = self.root_duration})
		else
			RefreshElectroCharge(enemy)
		end
	end

	-- Find nearby Statis Traps and mark them as disarmed
	local mines = FindUnitsInRadius(caster:GetTeamNumber(),
									caster:GetAbsOrigin(),
									nil,
									self.root_range,
									DOTA_UNIT_TARGET_TEAM_FRIENDLY,
									DOTA_UNIT_TARGET_OTHER,
									DOTA_UNIT_TARGET_FLAG_NONE,
									FIND_ANY_ORDER,
									false)

	for _,mine in pairs(mines) do
		if mine:GetUnitName() == "npc_dota_techies_stasis_trap" and mine ~= caster then
			mine:AddNewModifier(caster, self.ability, modifier_disarmed, {})
		end
	end

	-- Apply flying vision
	AddFOWViewer(caster:GetTeamNumber(), caster:GetAbsOrigin(), self.root_range, self.flying_vision_duration, false)

	-- Kill trap and destroy modifier
	caster:ForceKill(false)
	self:Destroy()
end

function modifier_imba_statis_trap:CheckState()
	if IsServer() then

		-- Planted inside a creep
		if self.caster:IsCreep() then
			return nil
		end

		local state

		-- Trap is invisible since activation
		if self.active then
			state = {[MODIFIER_STATE_INVISIBLE] = true,
					 [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
		else
			state = {[MODIFIER_STATE_INVISIBLE] = false,
					 [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
		end
		return state
	end
end


-- Root modifier
modifier_imba_statis_trap_root = modifier_imba_statis_trap_root or class({})

function modifier_imba_statis_trap_root:CheckState()
	local state = {[MODIFIER_STATE_ROOTED] = true}
	return state
end

function modifier_imba_statis_trap_root:IsHidden() return false end
function modifier_imba_statis_trap_root:IsPurgable() return true end
function modifier_imba_statis_trap_root:IsDebuff() return true end

function modifier_imba_statis_trap_root:GetStatusEffectName()
	return "particles/status_fx/status_effect_techies_stasis.vpcf"
end


-- Electrocharge modifier
modifier_imba_statis_trap_electrocharge = modifier_imba_statis_trap_electrocharge or class({})

function modifier_imba_statis_trap_electrocharge:OnCreated()
	if IsServer() then
		-- Ability properties
		self.caster = self:GetCaster()
		self.ability = self:GetAbility()
		self.parent = self:GetParent()
		self.owner = self.caster:GetOwner()
		self.teamnumber = self.caster:GetTeamNumber()
		self.parent_teamnumber = self.parent:GetTeamNumber()

		-- Ability specials
		self.base_magnetic_radius = self.ability:GetSpecialValueFor("base_magnetic_radius")
		self.base_magnetic_movespeed = self.ability:GetSpecialValueFor("base_magnetic_movespeed")
		self.magnetic_stack_radius = self.ability:GetSpecialValueFor("magnetic_stack_radius")
		self.magnetic_stack_movespeed = self.ability:GetSpecialValueFor("magnetic_stack_movespeed")        

		-- If this is not the Stasis Trap casting it, do nothing (hellblade/curseblade interactions)
		if self.caster:GetUnitName() ~= "npc_dota_techies_stasis_trap" then
			return nil
		end

		-- If the parent is in the same team as the caster, do nothing (don't pull mines towards it)         
		if self.teamnumber == self.parent_teamnumber then
			return nil
		end

		-- Start thinking
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_imba_statis_trap_electrocharge:IsHidden() return false end
function modifier_imba_statis_trap_electrocharge:IsPurgable() return true end
function modifier_imba_statis_trap_electrocharge:IsDebuff() return true end

function modifier_imba_statis_trap_electrocharge:OnIntervalThink()
	if IsServer() then
		-- Determine movespeed and radius for this tick
		local stacks = self:GetStackCount()
		local movespeed = self.base_magnetic_movespeed + self.magnetic_stack_movespeed * stacks
		local radius = self.base_magnetic_radius + self.magnetic_stack_radius * stacks

		local parentAbsOrigin = self.parent:GetAbsOrigin()

		-- Find all nearby mines
		local mines = FindUnitsInRadius(self.teamnumber,
			parentAbsOrigin,
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_OTHER,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false
		)

		-- Move each mine towards the parent of the debuff
		for _,mine in pairs(mines) do
			local mineUnitName = mine:GetUnitName()
			if mineUnitName == "npc_dota_techies_land_mine" or mineUnitName == "npc_dota_techies_stasis_trap" then
				local mineAbsOrigin = mine:GetAbsOrigin()

				-- Get mine's distance from enemy
				local distance = (parentAbsOrigin - mineAbsOrigin):Length2D()

				-- Minimum distance so game won't keep trying to put it closer in zero range
				if distance > 25 then
					-- Get mine's direction from enemy
					local direction = (parentAbsOrigin - mineAbsOrigin):Normalized()
					-- Set the mine's location closer to the enemy
					local mine_location = mineAbsOrigin + direction * movespeed * FrameTime()
					mine:SetAbsOrigin(mine_location)
				end
			end
		end
	end
end

function modifier_imba_statis_trap_electrocharge:GetTexture()
	return "techies_stasis_trap"
end

-- Disarmed Statis Traps modifier
modifier_imba_statis_trap_disarmed = modifier_imba_statis_trap_disarmed or class({})

function modifier_imba_statis_trap_disarmed:IsHidden() return false end
function modifier_imba_statis_trap_disarmed:IsPurgable() return false end
function modifier_imba_statis_trap_disarmed:IsDebuff() return false end
