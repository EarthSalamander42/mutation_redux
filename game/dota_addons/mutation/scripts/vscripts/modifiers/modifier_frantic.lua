modifier_frantic = modifier_frantic or class({})

----------------------------------------------------------------------
-- Frantic handler
----------------------------------------------------------------------

modifier_frantic = modifier_frantic or class({})

function modifier_frantic:IsDebuff() return false end
function modifier_frantic:RemoveOnDeath() return false end
function modifier_frantic:IsPurgable() return false end
function modifier_frantic:IsPurgeException() return false end

function modifier_frantic:GetTexture()
	return "custom/frantic"
end

function modifier_frantic:GetEffectName()
	return "particles/generic_gameplay/frantic.vpcf"
end

function modifier_frantic:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_frantic:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
--		MODIFIER_PROPERTY_MANA_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_RESPAWNTIME_PERCENTAGE,
	}

	return funcs
end

function modifier_frantic:OnCreated()
	self:SetStackCount(50)
end
--[[ -- not working for reasons
function modifier_frantic:GetModifierPercentageManaRegen()
	return 200
end
]]
function modifier_frantic:GetModifierPercentageCooldown()
	return self:GetStackCount()
end

function modifier_frantic:GetModifierStatusResistanceStacking()
	return self:GetStackCount()
end

function modifier_frantic:GetModifierPercentageRespawnTime()
    return self:GetStackCount()
end
