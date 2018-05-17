-- This file contains all barebones-registered events and has already set up the passed-in parameters for your use.

-- Cleanup a player when they leave
function Mutation:OnDisconnect(keys)
	DebugPrint('[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
	DebugPrintTable(keys)

	local name = keys.name
	local networkid = keys.networkid
	local reason = keys.reason
	local userid = keys.userid

end
-- The overall game state has changed
function Mutation:OnGameRulesStateChange(keys)
	DebugPrint("[BAREBONES] GameRules State Changed")
	DebugPrintTable(keys)

	local newState = GameRules:State_Get()

	if newState == DOTA_GAMERULES_STATE_INIT then
		--Timers:RemoveTimer("alljointimer")
	elseif newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
		self.bSeenWaitForPlayers = true
	elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
		Mutation:PostLoadPrecache()
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		if IMBA_MUTATION["terrain"] == "no_trees" then
			GameRules:SetTreeRegrowTime(99999)
			GridNav:DestroyTreesAroundPoint(Vector(0, 0, 0), 50000, false)
			Mutation:RevealAllMap(1.0)
		elseif IMBA_MUTATION["terrain"] == "omni_vision" then
			Mutation:RevealAllMap()
		elseif IMBA_MUTATION["terrain"] == "fast_runes" then
			RUNE_SPAWN_TIME = 30.0
			BOUNTY_RUNE_SPAWN_TIME = 60.0
		end

		Timers:CreateTimer(3.0, function()
			CustomGameEventManager:Send_ServerToAllClients("send_mutations", IMBA_MUTATION)
		end)
	elseif GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		if IMBA_MUTATION["negative"] == "periodic_spellcast" then
			local random_int = RandomInt(1, #IMBA_MUTATION_PERIODIC_SPELLS)
			local caster = Entities:FindByName(nil, "dota_goodguys_fort")

			Timers:CreateTimer(55.0, function()
				random_int = RandomInt(1, #IMBA_MUTATION_PERIODIC_SPELLS)
				Notifications:TopToAll({text = IMBA_MUTATION_PERIODIC_SPELLS[random_int][2].." Mutation in 5 seconds...", duration = 5.0, {color = IMBA_MUTATION_PERIODIC_SPELLS[random_int][3]}})

				return 60.0
			end)

			Timers:CreateTimer(function()
				for _, hero in pairs(HeroList:GetAllHeroes()) do
					if hero:GetTeamNumber() == 3 then
						caster = Entities:FindByName(nil, "dota_badguys_fort")
					end

					if IMBA_MUTATION_PERIODIC_SPELLS[random_int][1] == "sun_strike" then
						hero:AddNewModifier(caster, nil, "modifier_mutation_sun_strike", {duration=3.0})
					elseif IMBA_MUTATION_PERIODIC_SPELLS[random_int][1] == "thundergods_wrath" then
						hero:AddNewModifier(caster, nil, "modifier_mutation_thundergods_wrath", {duration=1.0})
					elseif IMBA_MUTATION_PERIODIC_SPELLS[random_int][1] == "track" then
						hero:AddNewModifier(caster, nil, "modifier_mutation_track", {duration=20.0})
					elseif IMBA_MUTATION_PERIODIC_SPELLS[random_int][1] == "rupture" then
						hero:AddNewModifier(caster, nil, "modifier_mutation_rupture", {duration=10.0})
					end
				end

				return 60.0
			end)
		end

		if IMBA_MUTATION["terrain"] == "minefield" then
			local mines = {
				"npc_dota_techies_land_mine",
				"npc_dota_techies_stasis_trap",
			}

			Timers:CreateTimer(function()
				local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)		
				local mine_count = 0
				local max_mine_count = 90

				for _, unit in pairs(units) do
					if unit:GetUnitName() == "npc_dota_techies_land_mine" or unit:GetUnitName() == "npc_dota_techies_stasis_trap" then			
						if unit:GetUnitName() == "npc_dota_techies_land_mine" then
							unit:AddAbility("imba_techies_proximity_mine_trigger"):SetLevel(RandomInt(1, 4))
						elseif unit:GetUnitName() == "npc_dota_techies_stasis_trap" then
							unit:AddAbility("imba_techies_stasis_trap_trigger"):SetLevel(RandomInt(1, 4))
						end

						mine_count = mine_count + 1
					end
				end

				if mine_count < max_mine_count then
					for i = 1, 10 do
						local mine = CreateUnitByName(mines[RandomInt(1, #mines)], Vector(0, 0, 0) + RandomVector(RandomInt(1000, 15000)), true, nil, nil, DOTA_TEAM_NEUTRALS)
						mine:AddNewModifier(mine, nil, "modifier_invulnerable", {})
					end
				end

--				print("Mine count:", mine_count)
				return 10.0
			end)
		end
	end
end

-- An NPC has spawned somewhere in game.  This includes heroes
function Mutation:OnNPCSpawned(keys)
	DebugPrint("[BAREBONES] NPC Spawned")
	DebugPrintTable(keys)

	local npc = EntIndexToHScript(keys.entindex)

	if npc:IsRealHero() then
		if npc.first_spawn == nil then
--			print("Mutation: On Hero First Spawn")

			if IMBA_MUTATION["positive"] == "killstreak_power" then
				npc:AddNewModifier(npc, nil, "modifier_mutation_kill_streak_power", {})
			elseif IMBA_MUTATION["positive"] == "frantic" then
				npc:AddNewModifier(npc, nil, "modifier_frantic", {})
			elseif IMBA_MUTATION["positive"] == "jump_start" then
				npc:AddExperience(2300, DOTA_ModifyXP_CreepKill, false, true)
			end

			if IMBA_MUTATION["negative"] == "death_explosion" then
				npc:AddNewModifier(npc, nil, "modifier_mutation_death_explosion", {})
			elseif IMBA_MUTATION["negative"] == "no_health_bar" then
				npc:AddNewModifier(npc, nil, "modifier_no_health_bar", {})
			elseif IMBA_MUTATION["negative"] == "defense_of_the_ants" then
				npc:AddNewModifier(npc, nil, "modifier_mutation_ants", {})
			end

			npc.first_spawn = true
		end

		Mutation:OnHeroSpawn(npc)
	end
end

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

	--[[ Rune Can be one of the following types
	DOTA_RUNE_DOUBLEDAMAGE
	DOTA_RUNE_HASTE
	DOTA_RUNE_HAUNTED
	DOTA_RUNE_ILLUSION
	DOTA_RUNE_INVISIBILITY
	DOTA_RUNE_BOUNTY
	DOTA_RUNE_MYSTERY
	DOTA_RUNE_RAPIER
	DOTA_RUNE_REGENERATION
	DOTA_RUNE_SPOOKY
	DOTA_RUNE_TURBO
	]]
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

-- An entity died
function Mutation:OnEntityKilled( keys )
	DebugPrint( '[BAREBONES] OnEntityKilled Called' )
	DebugPrintTable( keys )
	

	-- The Unit that was Killed
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	-- The Killing entity
	local killerEntity = nil

	if keys.entindex_attacker ~= nil then
		killerEntity = EntIndexToHScript( keys.entindex_attacker )
	end

	-- The ability/item used to kill, or nil if not killed by an item/ability
	local killerAbility = nil

	if keys.entindex_inflictor ~= nil then
		killerAbility = EntIndexToHScript( keys.entindex_inflictor )
	end

	local damagebits = keys.damagebits -- This might always be 0 and therefore useless

	-- Put code here to handle when an entity gets killed
	if killedUnit:IsRealHero() then
		Mutation:OnHeroDeath(killedUnit)
	end
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

function Mutation:OnHeroSpawn(hero)
--	print("Mutation: On Hero Spawn")

	if IMBA_MUTATION["positive"] == "damage_reduction" then
		hero:AddNewModifier(hero, nil, "modifier_mutation_damage_reduction", {})
	elseif IMBA_MUTATION["positive"] == "slark_mode" then
		hero:AddNewModifier(hero, nil, "modifier_mutation_shadow_dance", {})
	end

	if IMBA_MUTATION["terrain"] == "sleepy_river" then
		hero:AddNewModifier(hero, nil, "modifier_river", {})
	end
end

function Mutation:OnHeroDeath(hero)
--	print("Mutation: On Hero Dead")

	if IMBA_MUTATION["positive"] == "teammate_resurrection" then
		local newItem = CreateItem("item_tombstone", hero, hero)
		newItem:SetPurchaseTime(0)
		newItem:SetPurchaser(hero)

		local tombstone = SpawnEntityFromTableSynchronous("dota_item_tombstone_drop", {})
		tombstone:SetContainedItem(newItem)
		tombstone:SetAngles(0, RandomFloat(0, 360), 0)
		FindClearSpaceForUnit(tombstone, hero:GetAbsOrigin(), true)
	end

	if IMBA_MUTATION["negative"] == "death_gold_drop" then
		local game_time = math.min(GameRules:GetDOTATime(false, false) / 60, 30)
		local random_int = RandomInt(30, 60)
		local newItem = CreateItem("item_bag_of_gold", nil, nil)
		newItem:SetPurchaseTime(0)
		print("Bag of Gold:", game_time, random_int, random_int * game_time)
		newItem:SetCurrentCharges(random_int * game_time + 100)

		local drop = CreateItemOnPositionSync(hero:GetAbsOrigin(), newItem)
		local dropTarget = hero:GetAbsOrigin() + RandomVector(RandomFloat( 50, 150 ))
		newItem:LaunchLoot(true, 300, 0.75, dropTarget)
		EmitSoundOn("Dungeon.TreasureItemDrop", hero)
	end
end
