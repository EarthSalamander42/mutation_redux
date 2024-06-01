-- This file contains all barebones-registered events and has already set up the passed-in parameters for your use.

-- The overall game state has changed
function Mutation:OnGameRulesStateChange(keys)
	local newState = GameRules:State_Get()

	if newState == DOTA_GAMERULES_STATE_INIT then
		--Timers:RemoveTimer("alljointimer")
	elseif newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
		self.bSeenWaitForPlayers = true
	elseif newState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		Timers:CreateTimer(2.0, function()
			SendToServerConsole('sm_gmode 1')
			SendToServerConsole('dota_bot_populate')
		end)

		CustomGameEventManager:Send_ServerToAllClients("all_players_loaded", {})
	elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		self:PostLoadPrecache()
	elseif newState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
		self:ForceAssignHeroes()
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		if MUTATION_LIST["terrain"] == "no_trees" then
			GameRules:SetTreeRegrowTime(99999)
			GridNav:DestroyTreesAroundPoint(Vector(0, 0, 0), 50000, false)
			self:RevealAllMap(1.0)
		elseif MUTATION_LIST["terrain"] == "omni_vision" then
			self:RevealAllMap()
		elseif MUTATION_LIST["terrain"] == "fast_runes" then
			GameRules:GetGameModeEntity():SetPowerRuneSpawnInterval(FAST_RUNES_TIME)
			GameRules:GetGameModeEntity():SetBountyRuneSpawnInterval(FAST_RUNES_TIME)
		end

		Timers:CreateTimer(3.0, function()
			CustomGameEventManager:Send_ServerToAllClients("send_mutations", MUTATION_LIST)
		end)
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		if MUTATION_LIST["positive"] == "ultimate_level" then
			Mutation:UltimateLevel()
		end

		if MUTATION_LIST["negative"] == "periodic_spellcast" then
			local buildings = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), nil, 20000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
			local good_fountain = nil
			local bad_fountain = nil

			for _, building in pairs(buildings) do
				local building_name = building:GetName()
				if string.find(building_name, "ent_dota_fountain_bad") then
					bad_fountain = building
				elseif string.find(building_name, "ent_dota_fountain_good") then
					good_fountain = building
				end
			end

			local random_int
			local counter = 0 -- Used to alternate between negative and positive spellcasts, and increments after each timer call
			local varSwap -- Switches between 1 and 2 based on counter for negative and positive spellcasts

			local table
			Timers:CreateTimer(55.0, function()
				varSwap = (counter % 2) + 1
				if varSwap == 1 then
					table = MUTATION_LIST_NEGATIVE_PERIODIC_SPELLS
				else
					table = MUTATION_LIST_POSITIVE_PERIODIC_SPELLS
				end

				random_int = RandomInt(1, #table)
				Notifications:TopToAll({ text = table[random_int][2] .. " Mutation in 5 seconds...", duration = 5.0, style = { color = table[random_int][3] } })

				return 60.0
			end)

			Timers:CreateTimer(60.0, function()
				if bad_fountain == nil or good_fountain == nil then
					log.error("nao cucekd up!!! ")
					return 60.0
				end

				for _, hero in pairs(HeroList:GetAllHeroes()) do
					if (hero:GetTeamNumber() == 3 and table[random_int][3] == "Red") or (hero:GetTeamNumber() == 2 and table[random_int][3] == "Green") then
						caster = good_fountain
					end

					hero:AddNewModifier(caster, caster, "modifier_mutation_" .. table[random_int][1], { duration = table[random_int][4] })
				end
				counter = counter + 1

				return 60.0
			end)
		end

		if MUTATION_LIST["terrain"] == "gift_exchange" then
			for k, v in pairs(LoadKeyValues("scripts/npc/items.txt")) do -- Go through all the items in KeyValues.ItemKV and store valid items in validItems table
				varFlag = 0                                     -- Let's borrow this memory to suss out the forbidden items first...

				if k ~= "Version" and v["ItemCost"] and v["ItemCost"] >= minValue and v["ItemCost"] ~= 99999 and not string.find(k, "recipe") and not string.find(k, "cheese") then
					--					for _, item in pairs(self.restricted_items) do -- Make sure item isn't a restricted item
					--						if k == item then
					--							varFlag = 1
					--						end
					--					end

					if varFlag == 0 then -- If not a restricted item (while still meeting all the other criteria...)
						validItems[#validItems + 1] = { k = k, v = v["ItemCost"] }
					end
				end
			end

			table.sort(validItems, function(a, b) return a.v < b.v end) -- Sort by ascending item cost for easier retrieval later on

			--[[
			print("Table length: ", #validItems) -- # of valid items
						
			for a, b in pairs(validItems) do
				print(a)
				for key, value in pairs(b) do
					print('\t', key, value)
				end
			end	
			]]
			--

			varFlag = 0

			-- Create Tier 1 Table
			repeat
				if validItems[counter].v <= t1cap then
					tier1[#tier1 + 1] = { k = validItems[counter].k, v = validItems[counter].v }
					counter = counter + 1
				else
					varFlag = 1
				end
			until varFlag == 1

			varFlag = 0

			-- Create Tier 2 Table
			repeat
				if validItems[counter].v <= t2cap then
					tier2[#tier2 + 1] = { k = validItems[counter].k, v = validItems[counter].v }
					counter = counter + 1
				else
					varFlag = 1
				end
			until varFlag == 1

			varFlag = 0

			-- Create Tier 3 Table
			repeat
				if validItems[counter].v <= t3cap then
					tier3[#tier3 + 1] = { k = validItems[counter].k, v = validItems[counter].v }
					counter = counter + 1
				else
					varFlag = 1
				end
			until varFlag == 1

			varFlag = 0

			-- Create Tier 4 Table
			for num = counter, #validItems do
				tier4[#tier4 + 1] = { k = validItems[num].k, v = validItems[num].v }
			end

			varFlag = 0

			--[[
			print("TIER 1 LIST")
			
			for a, b in pairs(tier1) do
				print(a)
				for key, value in pairs(b) do
					print('\t', key, value)
				end
			end	
			
			print("TIER 2 LIST")
			
			for a, b in pairs(tier2) do
				print(a)
				for key, value in pairs(b) do
					print('\t', key, value)
				end
			end	
			
			print("TIER 3 LIST")
			
			for a, b in pairs(tier3) do
				print(a)
				for key, value in pairs(b) do
					print('\t', key, value)
				end
			end	
			
			print("TIER 4 LIST")
			
			for a, b in pairs(tier4) do
				print(a)
				for key, value in pairs(b) do
					print('\t', key, value)
				end
			end	
			]]
			--

			Timers:CreateTimer(110.0, function()
				Mutation:SpawnRandomItem()

				return 120.0
			end)
		elseif MUTATION_LIST["terrain"] == "call_down" then
			local dummy_unit = CreateUnitByName("npc_dummy_unit", Vector(0, 0, 0), true, nil, nil, DOTA_TEAM_NEUTRALS)
			dummy_unit:AddNewModifier(dummy_unit, nil, "modifier_mutation_call_down", {})
		elseif MUTATION_LIST["terrain"] == "wormhole" then
			-- Assign initial wormhole positions
			local current_wormholes = {}
			for i = 1, 12 do
				local random_int = RandomInt(1, #MUTATION_LIST_WORMHOLE_POSITIONS)
				current_wormholes[i] = MUTATION_LIST_WORMHOLE_POSITIONS[random_int]
				table.remove(MUTATION_LIST_WORMHOLE_POSITIONS, random_int)
			end

			-- Create wormhole particles (destroy and redraw every minute to accommodate for reconnecting players)
			local wormhole_particles = {}
			Timers:CreateTimer(0, function()
				for i = 1, 12 do
					if wormhole_particles[i] then
						ParticleManager:DestroyParticle(wormhole_particles[i], true)
						ParticleManager:ReleaseParticleIndex(wormhole_particles[i])
					end
					wormhole_particles[i] = ParticleManager:CreateParticle("particles/ambient/wormhole_circle.vpcf", PATTACH_CUSTOMORIGIN, nil)
					ParticleManager:SetParticleControl(wormhole_particles[i], 0, GetGroundPosition(current_wormholes[i], nil) + Vector(0, 0, 20))
					ParticleManager:SetParticleControl(wormhole_particles[i], 2, MUTATION_LIST_WORMHOLE_COLORS[i])
				end
				return 60
			end)

			-- Teleport loop
			Timers:CreateTimer(function()
				-- Find units to teleport
				for i = 1, 12 do
					local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, current_wormholes[i], nil, 150, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, FIND_ANY_ORDER, false)
					for _, unit in pairs(units) do
						if not unit:HasModifier("modifier_mutation_wormhole_cooldown") then
							if unit:IsHero() then
								unit:EmitSound("Wormhole.Disappear")
								Timers:CreateTimer(0.03, function()
									unit:EmitSound("Wormhole.Appear")
								end)
							else
								unit:EmitSound("Wormhole.CreepDisappear")
								Timers:CreateTimer(0.03, function()
									unit:EmitSound("Wormhole.CreepAppear")
								end)
							end
							unit:AddNewModifier(unit, nil, "modifier_mutation_wormhole_cooldown", { duration = MUTATION_LIST_WORMHOLE_PREVENT_DURATION })
							FindClearSpaceForUnit(unit, current_wormholes[13 - i], true)
							if unit.GetPlayerID and unit:GetPlayerID() then
								PlayerResource:SetCameraTarget(unit:GetPlayerID(), unit)
								Timers:CreateTimer(0.03, function()
									PlayerResource:SetCameraTarget(unit:GetPlayerID(), nil)
								end)
							end
						end
					end
				end

				return 0.5
			end)
		elseif MUTATION_LIST["terrain"] == "tug_of_war" then
			local golem
			-- Random a team for the initial golem spawn
			if RandomInt(1, 2) == 1 then
				golem = CreateUnitByName("npc_dota_mutation_golem", MUTATION_LIST_TUG_OF_WAR_START[DOTA_TEAM_GOODGUYS], false, nil, nil, DOTA_TEAM_GOODGUYS)
				golem.ambient_pfx = ParticleManager:CreateParticle("particles/ambient/tug_of_war_team_radiant.vpcf", PATTACH_ABSORIGIN_FOLLOW, golem)
				ParticleManager:SetParticleControl(golem.ambient_pfx, 0, golem:GetAbsOrigin())
				Timers:CreateTimer(0.1, function()
					golem:MoveToPositionAggressive(MUTATION_LIST_TUG_OF_WAR_TARGET[DOTA_TEAM_GOODGUYS])
				end)
			else
				golem = CreateUnitByName("npc_dota_mutation_golem", MUTATION_LIST_TUG_OF_WAR_START[DOTA_TEAM_BADGUYS], false, nil, nil, DOTA_TEAM_BADGUYS)
				golem.ambient_pfx = ParticleManager:CreateParticle("particles/ambient/tug_of_war_team_dire.vpcf", PATTACH_ABSORIGIN_FOLLOW, golem)
				ParticleManager:SetParticleControl(golem.ambient_pfx, 0, golem:GetAbsOrigin())
				Timers:CreateTimer(0.1, function()
					golem:MoveToPositionAggressive(MUTATION_LIST_TUG_OF_WAR_TARGET[DOTA_TEAM_BADGUYS])
				end)
			end

			-- Initial logic
			golem:AddNewModifier(golem, nil, "modifier_mutation_tug_of_war_golem", {}):SetStackCount(1)
			FindClearSpaceForUnit(golem, golem:GetAbsOrigin(), true)
			golem:SetDeathXP(50)
			golem:SetMinimumGoldBounty(50)
			golem:SetMaximumGoldBounty(50)
		end
	end
end

-- An NPC has spawned somewhere in game.  This includes heroes
function Mutation:OnNPCSpawned(keys)
	local npc = EntIndexToHScript(keys.entindex)

	if MUTATION_LIST["terrain"] == "speed_freaks" then
		if not npc:IsBuilding() then
			npc:AddNewModifier(npc, nil, "modifier_mutation_speed_freaks", { projectile_speed = SPEED_FREAKS_PROJECTILE_SPEED, movespeed_pct = SPEED_FREAKS_MOVESPEED_PCT, max_movespeed = SPEED_FREAKS_MAX_MOVESPEED })
		end
	end

	if npc:IsRealHero() then
		-- Check if we can add modifiers to hero
		if not Mutation:IsEligibleHero(npc) then return end

		if npc.first_spawn == nil then
			--			print("Mutation: On Hero First Spawn")

			if MUTATION_LIST["positive"] == "killstreak_power" then
				npc:AddNewModifier(npc, nil, "modifier_mutation_kill_streak_power", {})
			elseif MUTATION_LIST["positive"] == "frantic" then
				npc:AddNewModifier(npc, nil, "modifier_frantic", {})
			elseif MUTATION_LIST["positive"] == "jump_start" then
				npc:AddExperience(2300, DOTA_ModifyXP_CreepKill, false, true)
			elseif MUTATION_LIST["positive"] == "super_blink" then
				if npc:IsIllusion() then return end
				npc:AddItemByName("item_super_blink"):SetSellable(false)
			elseif MUTATION_LIST["positive"] == "pocket_tower" then
				npc:AddItemByName("item_pocket_tower")
			elseif MUTATION_LIST["positive"] == "super_fervor" then
				npc:AddNewModifier(npc, nil, "modifier_mutation_super_fervor", {})
			elseif MUTATION_LIST["positive"] == "teammate_resurrection" then
				npc.reincarnating = false
			end

			if MUTATION_LIST["negative"] == "death_explosion" then
				npc:AddNewModifier(npc, nil, "modifier_mutation_death_explosion", {})
			elseif MUTATION_LIST["negative"] == "no_health_bar" then
				npc:AddNewModifier(npc, nil, "modifier_no_health_bar", {})
			elseif MUTATION_LIST["negative"] == "defense_of_the_ants" then
				npc:AddNewModifier(npc, nil, "modifier_mutation_ants", {})
			elseif MUTATION_LIST["negative"] == "monkey_business" then
				npc:AddNewModifier(npc, nil, "modifier_mutation_monkey_business", {})
			end

			npc.first_spawn = true
		end

		self:OnHeroSpawn(npc)
		return
	end
end

-- An entity died
function Mutation:OnEntityKilled(keys)
	-- The Unit that was Killed
	local killedUnit = EntIndexToHScript(keys.entindex_killed)
	-- The Killing entity
	local killerEntity = nil

	if keys.entindex_attacker ~= nil then
		killerEntity = EntIndexToHScript(keys.entindex_attacker)
	end

	-- The ability/item used to kill, or nil if not killed by an item/ability
	local killerAbility = nil

	if keys.entindex_inflictor ~= nil then
		killerAbility = EntIndexToHScript(keys.entindex_inflictor)
	end

	local damagebits = keys.damagebits -- This might always be 0 and therefore useless

	-- Put code here to handle when an entity gets killed
	if killedUnit:IsRealHero() then
		self:OnHeroDeath(killedUnit)
		return
	end
end

function Mutation:OnHeroSpawn(hero)
	--	print("Mutation: On Hero Spawn")

	if MUTATION_LIST["positive"] == "damage_reduction" then
		hero:AddNewModifier(hero, nil, "modifier_mutation_damage_reduction", {})
	elseif MUTATION_LIST["positive"] == "slark_mode" then
		hero:AddNewModifier(hero, nil, "modifier_mutation_shadow_dance", {})
	end

	if MUTATION_LIST["terrain"] == "sleepy_river" then
		hero:AddNewModifier(hero, nil, "modifier_river", {})
	elseif MUTATION_LIST["terrain"] == "river_flows" then
		hero:AddNewModifier(hero, nil, "modifier_mutation_river_flows", {})
	elseif MUTATION_LIST["terrain"] == "sticky_river" then
		hero:AddNewModifier(hero, nil, "modifier_sticky_river", {})
	end

	if MUTATION_LIST["positive"] == "teammate_resurrection" then
		if hero.tombstone_fx then
			ParticleManager:DestroyParticle(hero.tombstone_fx, false)
			ParticleManager:ReleaseParticleIndex(hero.tombstone_fx)
			hero.tombstone_fx = nil
		end

		Timers:CreateTimer(FrameTime(), function()
			if IsNearFountain(hero:GetAbsOrigin(), 1200) == false and hero.reincarnating == false then
				hero:SetHealth(hero:GetHealth() / 2)
				hero:SetMana(hero:GetMana() / 2)
				hero:EmitSound("Ability.ReincarnationAlt")
			end

			hero.reincarnating = false
		end)
	end
end

function Mutation:OnHeroDeath(hero)
	if MUTATION_LIST["positive"] == "teammate_resurrection" then
		if hero:IsReincarnating() then
			hero.reincarnating = true
		else
			local newItem = CreateItem("item_tombstone", hero, hero)
			newItem:SetPurchaseTime(0)
			newItem:SetPurchaser(hero)

			local tombstone = SpawnEntityFromTableSynchronous("dota_item_tombstone_drop", {})
			tombstone:SetContainedItem(newItem)
			tombstone:SetAngles(0, RandomFloat(0, 360), 0)
			FindClearSpaceForUnit(tombstone, hero:GetAbsOrigin(), true)

			hero.tombstone_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_abaddon/holdout_borrowed_time_" .. hero:GetTeamNumber() .. ".vpcf", PATTACH_ABSORIGIN_FOLLOW, tombstone)
		end
	end

	if MUTATION_LIST["negative"] == "death_gold_drop" then
		if not hero:IsReincarnating() then
			local newItem = CreateItem("item_bag_of_gold", nil, nil)
			newItem:SetPurchaseTime(0)
			newItem:SetCurrentCharges((hero:GetGold() / 100 * DEATH_GOLD_DROP_PCT) + DEATH_GOLD_DROP_FLAT)

			local drop = CreateItemOnPositionSync(hero:GetAbsOrigin(), newItem)
			local dropTarget = hero:GetAbsOrigin() + RandomVector(RandomFloat(50, 150))
			newItem:LaunchLoot(true, 300, 0.75, dropTarget)
			EmitSoundOn("Dungeon.TreasureItemDrop", hero)
		end
	end
end

--[[
-- An item was picked up off the ground
function Mutation:OnItemPickedUp(keys)
	DebugPrint( '[BAREBONES] OnItemPickedUp' )
	DebugPrintTable(keys)

	local unitEntity = nil
	if keys.UnitEntitIndex then
		unitEntity = EntIndexToHScript(keys.UnitEntitIndex)
	elseif keys.HeroEntityIndex then
		unitEntity = EntIndexToHScript(keys.HeroEntityIndex)
	end

	local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local itemname = keys.itemname
end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function Mutation:OnPlayerReconnect(keys)
	DebugPrint( '[BAREBONES] OnPlayerReconnect' )
	DebugPrintTable(keys)
end

-- An item was purchased by a player
function Mutation:OnItemPurchased( keys )
	DebugPrint( '[BAREBONES] OnItemPurchased' )
	DebugPrintTable(keys)

	-- The playerID of the hero who is buying something
	local plyID = keys.PlayerID
	if not plyID then return end

	-- The name of the item purchased
	local itemName = keys.itemname
	
	-- The cost of the item purchased
	local itemcost = keys.itemcost
	
end

-- An ability was used by a player
function Mutation:OnAbilityUsed(keys)
	DebugPrint('[BAREBONES] AbilityUsed')
	DebugPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local abilityname = keys.abilityname
end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function Mutation:OnNonPlayerUsedAbility(keys)
	DebugPrint('[BAREBONES] OnNonPlayerUsedAbility')
	DebugPrintTable(keys)

	local abilityname=  keys.abilityname
end

-- A player changed their name
function Mutation:OnPlayerChangedName(keys)
	DebugPrint('[BAREBONES] OnPlayerChangedName')
	DebugPrintTable(keys)

	local newName = keys.newname
	local oldName = keys.oldName
end

-- A player leveled up an ability
function Mutation:OnPlayerLearnedAbility( keys)
	DebugPrint('[BAREBONES] OnPlayerLearnedAbility')
	DebugPrintTable(keys)

	local player = EntIndexToHScript(keys.player)
	local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function Mutation:OnAbilityChannelFinished(keys)
	DebugPrint('[BAREBONES] OnAbilityChannelFinished')
	DebugPrintTable(keys)

	local abilityname = keys.abilityname
	local interrupted = keys.interrupted == 1
end

-- A player leveled up
function Mutation:OnPlayerLevelUp(keys)
	DebugPrint('[BAREBONES] OnPlayerLevelUp')
	DebugPrintTable(keys)

	local player = EntIndexToHScript(keys.player)
	local level = keys.level
end

-- A player last hit a creep, a tower, or a hero
function Mutation:OnLastHit(keys)
	DebugPrint('[BAREBONES] OnLastHit')
	DebugPrintTable(keys)

	local isFirstBlood = keys.FirstBlood == 1
	local isHeroKill = keys.HeroKill == 1
	local isTowerKill = keys.TowerKill == 1
	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local killedEnt = EntIndexToHScript(keys.EntKilled)
end

-- A tree was cut down by tango, quelling blade, etc
function Mutation:OnTreeCut(keys)
	DebugPrint('[BAREBONES] OnTreeCut')
	DebugPrintTable(keys)

	local treeX = keys.tree_x
	local treeY = keys.tree_y
end

-- A rune was activated by a player
function Mutation:OnRuneActivated (keys)
	DebugPrint('[BAREBONES] OnRuneActivated')
	DebugPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local rune = keys.rune

	-- Rune Can be one of the following types
--	DOTA_RUNE_DOUBLEDAMAGE
--	DOTA_RUNE_HASTE
--	DOTA_RUNE_HAUNTED
--	DOTA_RUNE_ILLUSION
--	DOTA_RUNE_INVISIBILITY
--	DOTA_RUNE_BOUNTY
--	DOTA_RUNE_MYSTERY
--	DOTA_RUNE_RAPIER
--	DOTA_RUNE_REGENERATION
--	DOTA_RUNE_SPOOKY
--	DOTA_RUNE_TURBO
end

-- A player took damage from a tower
function Mutation:OnPlayerTakeTowerDamage(keys)
	DebugPrint('[BAREBONES] OnPlayerTakeTowerDamage')
	DebugPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local damage = keys.damage
end

-- A player picked a hero
function Mutation:OnPlayerPickHero(keys)
	DebugPrint('[BAREBONES] OnPlayerPickHero')
	DebugPrintTable(keys)

	local heroClass = keys.hero
	local heroEntity = EntIndexToHScript(keys.heroindex)
	local player = EntIndexToHScript(keys.player)
end

-- A player killed another player in a multi-team context
function Mutation:OnTeamKillCredit(keys)
	DebugPrint('[BAREBONES] OnTeamKillCredit')
	DebugPrintTable(keys)

	local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
	local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
	local numKills = keys.herokills
	local killerTeamNumber = keys.teamnumber
end

-- This function is called 1 to 2 times as the player connects initially but before they
-- have completely connected
function Mutation:PlayerConnect(keys)
	DebugPrint('[BAREBONES] PlayerConnect')
	DebugPrintTable(keys)
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function Mutation:OnConnectFull(keys)
	DebugPrint('[BAREBONES] OnConnectFull')
	DebugPrintTable(keys)
	
	local entIndex = keys.index+1
	-- The Player entity of the joining user
	local ply = EntIndexToHScript(entIndex)
	
	-- The Player ID of the joining player
	local playerID = ply:GetPlayerID()
end

-- This function is called whenever illusions are created and tells you which was/is the original entity
function Mutation:OnIllusionsCreated(keys)
	DebugPrint('[BAREBONES] OnIllusionsCreated')
	DebugPrintTable(keys)

	local originalEntity = EntIndexToHScript(keys.original_entindex)
end

-- This function is called whenever an item is combined to create a new item
function Mutation:OnItemCombined(keys)
	DebugPrint('[BAREBONES] OnItemCombined')
	DebugPrintTable(keys)

	-- The playerID of the hero who is buying something
	local plyID = keys.PlayerID
	if not plyID then return end
	local player = PlayerResource:GetPlayer(plyID)

	-- The name of the item purchased
	local itemName = keys.itemname
	
	-- The cost of the item purchased
	local itemcost = keys.itemcost
end

-- This function is called whenever an ability begins its PhaseStart phase (but before it is actually cast)
function Mutation:OnAbilityCastBegins(keys)
	DebugPrint('[BAREBONES] OnAbilityCastBegins')
	DebugPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.PlayerID)
	local abilityName = keys.abilityname
end

-- This function is called whenever a tower is killed
function Mutation:OnTowerKill(keys)
	DebugPrint('[BAREBONES] OnTowerKill')
	DebugPrintTable(keys)

	local gold = keys.gold
	local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
	local team = keys.teamnumber
end

-- This function is called whenever a player changes there custom team selection during Game Setup
function Mutation:OnPlayerSelectedCustomTeam(keys)
	DebugPrint('[BAREBONES] OnPlayerSelectedCustomTeam')
	DebugPrintTable(keys)

	local player = PlayerResource:GetPlayer(keys.player_id)
	local success = (keys.success == 1)
	local team = keys.team_id
end

-- This function is called whenever an NPC reaches its goal position/target
function Mutation:OnNPCGoalReached(keys)
	DebugPrint('[BAREBONES] OnNPCGoalReached')
	DebugPrintTable(keys)

	local goalEntity = EntIndexToHScript(keys.goal_entindex)
	local nextGoalEntity = EntIndexToHScript(keys.next_goal_entindex)
	local npc = EntIndexToHScript(keys.npc_entindex)
end

-- This function is called whenever any player sends a chat message to team or All
function Mutation:OnPlayerChat(keys)
	local teamonly = keys.teamonly
	local userID = keys.userid
--	local playerID = self.vUserIds[userID]:GetPlayerID()

	local text = keys.text
end

-- Cleanup a player when they leave
function Mutation:OnDisconnect(keys)
	DebugPrint('[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
	DebugPrintTable(keys)

	local name = keys.name
	local networkid = keys.networkid
	local reason = keys.reason
	local userid = keys.userid

end
--]]
