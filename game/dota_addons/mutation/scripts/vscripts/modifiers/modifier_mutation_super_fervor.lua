modifier_mutation_super_fervor = class({})

function modifier_mutation_super_fervor:IsHidden() return true end
function modifier_mutation_super_fervor:RemoveOnDeath() return false end
function modifier_mutation_super_fervor:IsPurgable() return false end

function modifier_mutation_super_fervor:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

function modifier_mutation_super_fervor:OnDeath(keys)
	if IsServer() then
		if keys.attacker == self:GetParent() then
			if keys.unit:IsRealHero() then
				self:GetParent():EmitSound("Hero_TrollWarlord.BattleTrance.Cast")
				self.stacks = 200
				self.cdr = 10.0
			else
				self.stacks = 100
				self.cdr = 1.0
			end

			self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_mutation_super_fervor_buff", {duration = 3.0}):SetStackCount(self.stacks)

			for i = 0, 23 do
				local ability = self:GetParent():GetAbilityByIndex(i)
				if ability then
					local remaining_cooldown = ability:GetCooldownTimeRemaining()
					ability:EndCooldown()
					if remaining_cooldown > 1 then
						ability:StartCooldown(remaining_cooldown - self.cdr)
					end
				end
			end
		end
	end
end

-----

LinkLuaModifier("modifier_mutation_super_fervor_buff", "modifiers/modifier_mutation_super_fervor.lua", LUA_MODIFIER_MOTION_NONE )
modifier_mutation_super_fervor_buff = class({})

function modifier_mutation_super_fervor_buff:IsHidden() return false end
function modifier_mutation_super_fervor_buff:RemoveOnDeath() return false end
function modifier_mutation_super_fervor_buff:GetTexture() return "troll_warlord_battle_trance" end

function modifier_mutation_super_fervor_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function modifier_mutation_super_fervor_buff:GetModifierAttackSpeedBonus_Constant()
	return 200
end
