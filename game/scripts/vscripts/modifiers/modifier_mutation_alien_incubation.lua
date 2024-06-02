modifier_mutation_alien_incubation = modifier_mutation_alien_incubation or class({})

function modifier_mutation_alien_incubation:IsHidden() return true end

function modifier_mutation_alien_incubation:RemoveOnDeath() return false end

function modifier_mutation_alien_incubation:IsPurgable() return false end

function modifier_mutation_alien_incubation:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH
	}
end

function modifier_mutation_alien_incubation:OnCreated()
	if not IsServer() then return end

	-- print("Alien Incubation Mutation Loaded for " .. self:GetParent():GetUnitName() .. " with " .. self:GetParent():GetMaxHealth() .. " health.")
end

function modifier_mutation_alien_incubation:OnDeath(keys)
	if not IsServer() then return end

	if keys.unit == self:GetParent() then
		-- print("Alien Incubation")
		if keys.unit:GetMaxHealth() > 2000 and not (keys.unit:GetUnitName() == "npc_dota_mutation_spiderling_super_big") then
			-- print("Alien Incubation: Super Big Spider")
			local spider_count = RandomInt(1, math.floor(keys.unit:GetMaxHealth() / 2000))

			for i = 1, spider_count do
				local spider = CreateUnitByName("npc_dota_mutation_spiderling_super_big", keys.unit:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
				spider:AddNewModifier(spider, nil, "modifier_kill", { duration = 30 })
				FindClearSpaceForUnit(spider, spider:GetAbsOrigin(), true)
			end
		elseif keys.unit:GetMaxHealth() > 1000 and not (keys.unit:GetUnitName() == "npc_dota_mutation_spiderling_big") then
			-- print("Alien Incubation: Big Spider")
			local spider_count = RandomInt(1, 2)

			for i = 1, spider_count do
				local spider = CreateUnitByName("npc_dota_mutation_spiderling_big", keys.unit:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
				spider:AddNewModifier(spider, nil, "modifier_kill", { duration = 30 })
				FindClearSpaceForUnit(spider, spider:GetAbsOrigin(), true)
			end
		elseif keys.unit:GetMaxHealth() > 600 and not (keys.unit:GetUnitName() == "npc_dota_mutation_spiderling") then
			-- print("Alien Incubation: Spider")
			local spider_count = RandomInt(1, 2)

			for i = 1, spider_count do
				local spider = CreateUnitByName("npc_dota_mutation_spiderling", keys.unit:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
				spider:AddNewModifier(spider, nil, "modifier_kill", { duration = 30 })
				FindClearSpaceForUnit(spider, spider:GetAbsOrigin(), true)
			end
		elseif keys.unit:GetMaxHealth() > 200 and not (keys.unit:GetUnitName() == "npc_dota_mutation_spiderite") then
			-- print("Alien Incubation: Spiderite")
			local spider_count = RandomInt(2, 3)

			for i = 1, spider_count do
				local spider = CreateUnitByName("npc_dota_mutation_spiderite", keys.unit:GetAbsOrigin(), false, nil, nil, DOTA_TEAM_NEUTRALS)
				spider:AddNewModifier(spider, nil, "modifier_kill", { duration = 30 })
				FindClearSpaceForUnit(spider, spider:GetAbsOrigin(), true)
			end
		else
			-- print("Alien Incubation: Not enough health to spawn spiders.")
		end
	end
end
