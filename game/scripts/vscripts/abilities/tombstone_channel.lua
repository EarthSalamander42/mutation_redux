LinkLuaModifier("modifier_tombstone_invulnerable", "abilities/tombstone_channel.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tombstone_channelling", "abilities/tombstone_channel.lua", LUA_MODIFIER_MOTION_NONE)

tombstone_channel = tombstone_channel or class({})

-- function tombstone_channel:GetChannelTime()
-- 	return self:GetSpecialValueFor("channel_duration")
-- end

function tombstone_channel:OnSpellStart()
	if not IsServer() then return end

	print("Tombstone channel spell start, caster: ", self:GetCaster():GetUnitName())

	self.caster = self:GetCaster()

	-- Play the cast sound
	self.caster:EmitSound("Hero_Undying.Tombstone")
	-- self.caster:StartGesture(ACT_DOTA_GENERIC_CHANNEL_1)

	self.caster:AddNewModifier(self.caster, self, "modifier_tombstone_channelling", { duration = self:GetChannelTime() })
end

modifier_tombstone_channelling = modifier_tombstone_channelling or class({})

function modifier_tombstone_channelling:IsHidden() return true end

function modifier_tombstone_channelling:IsPurgable() return false end

function modifier_tombstone_channelling:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_EVENT_ON_ORDER,
	}

	return funcs
end

function modifier_tombstone_channelling:GetOverrideAnimation()
	return ACT_DOTA_GENERIC_CHANNEL_1
end

function modifier_tombstone_channelling:OnCreated()
	if not IsServer() then return end

	self.caster = self:GetCaster()
	self.channel_time = self:GetAbility():GetChannelTime()
	self.interrupted = true

	self:GetAbility():SetChanneling(true)

	self:StartIntervalThink(0.1)
end

function modifier_tombstone_channelling:OnIntervalThink()
	if not IsServer() then return end

	local channel_time_elapsed = self:GetElapsedTime()
	local channel_time_remaining = self.channel_time - channel_time_elapsed

	if self.caster:IsHexed() or self.caster:IsStunned() then
		print("Caster is hexed or stunned, cancelling channel")
		self:Destroy()
		self:StartIntervalThink(-1)
		return
	end

	if channel_time_remaining <= 0 then
		print("Tombstone channel finished by time limit")
		self.interrupted = false
		self:Destroy()
	end
end

function modifier_tombstone_channelling:OnOrder(keys)
	if not IsServer() then return end

	if keys.unit == self.caster then
		self:Destroy()
	end
end

function modifier_tombstone_channelling:OnDestroy()
	if not IsServer() then return end

	self:GetAbility():OnChannelFinish(self.interrupted)
end

function tombstone_channel:OnChannelFinish(bInterrupted)
	print("Tombstone channel finished, interrupted: ", bInterrupted)
	self:SetChanneling(false)
	if not IsServer() then return end
	if self.caster == nil then return end

	self.caster:RemoveGesture(ACT_DOTA_GENERIC_CHANNEL_1)

	if bInterrupted then
		self.caster:StopSound("Hero_Undying.Tombstone")
		return
	end

	print("1")
	local respawn_health_pct = self:GetSpecialValueFor("respawn_health_pct")
	local heroes = FindUnitsInRadius(self.caster:GetTeamNumber(), self.caster:GetAbsOrigin(), nil, 500, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_DEAD, FIND_CLOSEST, false)
	local dead_hero = heroes[1]
	print("2")

	if dead_hero and not dead_hero:IsNull() then
		-- Resurrect the dead hero
		print("Resurrecting hero: ", dead_hero:GetUnitName())
		dead_hero:RespawnHero(false, false)
		dead_hero:SetHealth(dead_hero:GetMaxHealth() * respawn_health_pct / 100)
		dead_hero:SetMana(dead_hero:GetMaxMana() * respawn_health_pct / 100)
		dead_hero:SetAbsOrigin(GetGroundPosition(self.caster:GetAbsOrigin() + RandomVector(100), dead_hero))

		print("3")
		-- dead_hero:AddNewModifier(self.caster, self, "modifier_tombstone_invulnerable", { duration = self:GetSpecialValueFor("invulnerability_duration") })

		-- Play the resurrection sound
		dead_hero:EmitSound("Hero_Undying.FleshGolem.Cast")
		print("4")
	end

	print("Tombstone channel finished")
end

modifier_tombstone_invulnerable = modifier_tombstone_invulnerable or class({})

function modifier_tombstone_invulnerable:IsHidden() return false end

function modifier_tombstone_invulnerable:IsPurgable() return false end

function modifier_tombstone_invulnerable:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_UNTARGETABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}

	return state
end

function modifier_tombstone_invulnerable:GetEffectName()
	return "particles/units/heroes/hero_undying/undying_fg_aura.vpcf"
end

function modifier_tombstone_invulnerable:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_tombstone_invulnerable:OnCreated()
	if not IsServer() then return end

	print("Tombstone invulnerability modifier created")
end
