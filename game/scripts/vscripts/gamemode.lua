-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode
BAREBONES_VERSION = "1.00"

-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false

if Mutation == nil then
	_G.Mutation = class({})

	MUTATION_LIST = {}
	MUTATION_LIST["positive"] = ""
	MUTATION_LIST["negative"] = ""
	MUTATION_LIST["terrain"] = ""
end

-- clientside KV loading
require('addon_init')

require('libraries/adv_log')
require('libraries/timers')
require('libraries/notifications')

require('mutation_list')
require('internal/gamemode')
require('settings')
require('events')

function Mutation:PostLoadPrecache()
	--PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

function Mutation:InitGameMode()
	-- GameRules:SetShowcaseTime(0.0)

	local mode = GameRules:GetGameModeEntity()
	mode:SetFreeCourierModeEnabled(USE_MULTIPLE_COURIERS)
	mode:SetUseDefaultDOTARuneSpawnLogic(true)
	mode:SetBotThinkingEnabled(true)

	if IsInToolsMode() then
		mode:SetDraftingBanningTimeOverride(0.0)
	end

	mode:SetItemAddedToInventoryFilter(Dynamic_Wrap(Mutation, "ItemAddedFilter"), self)
	mode:SetExecuteOrderFilter(Dynamic_Wrap(Mutation, "OrderFilter"), self)
	-- mode:SetModifyGoldFilter(Dynamic_Wrap(Mutation, "GoldFilter"), self)
	mode:SetModifyExperienceFilter(Dynamic_Wrap(Mutation, "ExperienceFilter"), self)

	CustomGameEventManager:RegisterListener("setting_vote", Dynamic_Wrap(Mutation, "OnSettingVote"))

	Mutation:ChooseMutation("positive", POSITIVE_MUTATION_LIST[1])
	Mutation:ChooseMutation("negative", NEGATIVE_MUTATION_LIST[1])
	Mutation:ChooseMutation("terrain", TERRAIN_MUTATION_LIST[1])

	CustomNetTables:SetTableValue("game_options", "mutations", MUTATION_LIST)

	--	"telekinesis",
	--	"glimpse",

	--	"shallow_grave",
	--	"false_promise",
	--	"bloodrage",
end

-- TODO: add a random choice in vote UI, if random is selected, then use this function to pick a random mutation
function Mutation:RandomMutation(mType, mList)
	local random_int = RandomInt(1, #mList)
	MUTATION_LIST[mType] = mList[random_int]
	--print("MUTATION_LIST["..mType.."] mutation picked: ", mList[random_int])
end

function Mutation:ChooseMutation(mType, mName)
	MUTATION_LIST[mType] = mName
	print("MUTATION_LIST[" .. mType .. "] mutation picked: " .. mName)
	CustomNetTables:SetTableValue("game_options", "mutations", MUTATION_LIST)
end

function Mutation:RevealAllMap(duration)
	GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)

	if duration then
		Timers:CreateTimer(duration, function()
			GameRules:GetGameModeEntity():SetFogOfWarDisabled(false)
		end)
	end
end

-- Currently only checks stuff for monkey king
function Mutation:IsEligibleHero(hero)
	if (hero:GetName() == "npc_dota_hero_monkey_king" or hero:GetName() == "npc_dota_hero_rubick") and hero:GetAbsOrigin() ~= Vector(0, 0, 0) then
		print("fake hero entered the game, ignoring mutation!", hero:GetEntityIndex(), hero:GetName())
		return false
	end

	return true
end

function Mutation:SpawnRandomItem()
	local selectedItem

	if GameRules:GetDOTATime(false, false) > t3time then
		selectedItem = tier4[RandomInt(1, #tier4)].k
	elseif GameRules:GetDOTATime(false, false) > t2time then
		selectedItem = tier3[RandomInt(1, #tier3)].k
	elseif GameRules:GetDOTATime(false, false) > t1time then
		selectedItem = tier2[RandomInt(1, #tier2)].k
	else
		selectedItem = tier1[RandomInt(1, #tier1)].k
	end

	local pos = RandomVector(MAP_SIZE_AIRDROP)
	AddFOWViewer(2, pos, MUTATION_ITEM_SPAWN_RADIUS, MUTATION_ITEM_SPAWN_DELAY + MUTATION_ITEM_SPAWN_VISION_LINGER, false)
	AddFOWViewer(3, pos, MUTATION_ITEM_SPAWN_RADIUS, MUTATION_ITEM_SPAWN_DELAY + MUTATION_ITEM_SPAWN_VISION_LINGER, false)
	GridNav:DestroyTreesAroundPoint(pos, MUTATION_ITEM_SPAWN_RADIUS, false)

	local particle_dummy = CreateUnitByName("npc_dummy_unit", pos, true, nil, nil, 6)
	local particle_arena_fx = ParticleManager:CreateParticle("particles/hero/centaur/centaur_hoof_stomp_arena.vpcf", PATTACH_ABSORIGIN_FOLLOW, particle_dummy)
	ParticleManager:SetParticleControl(particle_arena_fx, 0, pos)
	ParticleManager:SetParticleControl(particle_arena_fx, 1, Vector(MUTATION_ITEM_SPAWN_RADIUS + 45, 1, 1))

	local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn_timer.vpcf", PATTACH_ABSORIGIN_FOLLOW, particle_dummy)
	ParticleManager:SetParticleControl(particle, 1, Vector(MUTATION_ITEM_SPAWN_DELAY, 0, 0))
	ParticleManager:SetParticleControl(particle, 3, pos)
	ParticleManager:ReleaseParticleIndex(particle)

	Timers:CreateTimer(MUTATION_ITEM_SPAWN_DELAY, function()
		local item = CreateItem(selectedItem, nil, nil)
		item.airdrop = true
		-- print("Item Name:", selectedItem, pos)

		local drop = CreateItemOnPositionSync(pos, item)

		CustomGameEventManager:Send_ServerToAllClients("item_has_spawned", { spawn_location = pos })
		EmitGlobalSound("powerup_05")

		ParticleManager:DestroyParticle(particle_arena_fx, false)
		ParticleManager:ReleaseParticleIndex(particle_arena_fx)

		particle_dummy:ForceKill(false)
	end)

	CustomGameEventManager:Send_ServerToAllClients("item_will_spawn", { spawn_location = pos })
	EmitGlobalSound("powerup_03")
end

function Mutation:UltimateLevel()
	local XP_PER_LEVEL_TABLE = {}
	-- Vanilla
	XP_PER_LEVEL_TABLE[1] = 0   -- +0
	XP_PER_LEVEL_TABLE[2] = 240 -- +240
	XP_PER_LEVEL_TABLE[3] = 640 -- +400
	XP_PER_LEVEL_TABLE[4] = 1160 -- +520
	XP_PER_LEVEL_TABLE[5] = 1760 -- +600
	XP_PER_LEVEL_TABLE[6] = 2440 -- +680
	XP_PER_LEVEL_TABLE[7] = 3200 -- +760
	XP_PER_LEVEL_TABLE[8] = 4000 -- +800
	XP_PER_LEVEL_TABLE[9] = 4900 -- +900
	XP_PER_LEVEL_TABLE[10] = 5900 -- +1000
	XP_PER_LEVEL_TABLE[11] = 7000 -- +1100
	XP_PER_LEVEL_TABLE[12] = 8200 -- +1200
	XP_PER_LEVEL_TABLE[13] = 9500 -- +1300
	XP_PER_LEVEL_TABLE[14] = 10900 -- +1400
	XP_PER_LEVEL_TABLE[15] = 12400 -- +1500
	XP_PER_LEVEL_TABLE[16] = 14000 -- +1600
	XP_PER_LEVEL_TABLE[17] = 15700 -- +1700
	XP_PER_LEVEL_TABLE[18] = 17500 -- +1800
	XP_PER_LEVEL_TABLE[19] = 19400 -- +1900
	XP_PER_LEVEL_TABLE[20] = 21400 -- +2000
	XP_PER_LEVEL_TABLE[21] = 23600 -- +2200
	XP_PER_LEVEL_TABLE[22] = 26000 -- +2400
	XP_PER_LEVEL_TABLE[23] = 28600 -- +2600
	XP_PER_LEVEL_TABLE[24] = 31400 -- +2800
	XP_PER_LEVEL_TABLE[25] = 34400 -- +3000
	XP_PER_LEVEL_TABLE[26] = 38400 -- +4000
	XP_PER_LEVEL_TABLE[27] = 43400 -- +5000
	XP_PER_LEVEL_TABLE[28] = 49400 -- +6000
	XP_PER_LEVEL_TABLE[29] = 56400 -- +7000
	XP_PER_LEVEL_TABLE[30] = 63900 -- +7500

	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE)

	if ULTIMATE_LEVEL and ULTIMATE_LEVEL > 30 then
		local j = 31
		Timers:CreateTimer(function()
			if j >= ULTIMATE_LEVEL then return end
			-- print(j)
			for i = j, j + 2 do
				XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i - 1] + 2500
				GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE)
			end
			j = j + 2
			return 1.0
		end)
	end

	-- Mutation.gold_filter = 200
	Mutation.experience_filter = 300 -- 300% experience
end

-- function Mutation:GoldFilter(keys)
-- 	-- print("[BAREBONES] GoldFilter")
-- 	-- PrintTable(keys)

-- 	-- keys["player_id_const"]
-- 	-- keys["gold"]
-- 	-- keys["reason_const"]

-- 	return true
-- end

function Mutation:ExperienceFilter(keys)
	-- print("[BAREBONES] ExperienceFilter")
	-- PrintTable(keys)

	-- keys["player_id_const"]
	-- keys["hero_entindex_const"]
	-- keys["experience"]
	-- keys["reason_const"]

	if MUTATION_LIST["positive"] == "ultimate_level" then
		if keys.experience > 0 then
			keys.experience = keys.experience * Mutation.experience_filter / 100
		end
	end

	return true
end

-- new system, double votes for donators
ListenToGameEvent('game_rules_state_change', function(keys)
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_HERO_SELECTION then
		if Mutation.VoteTable == nil then return end
		local votes = Mutation.VoteTable

		for category, pidVoteTable in pairs(votes) do
			-- Tally the votes into a new table
			local voteCounts = {}
			for pid, vote in pairs(pidVoteTable) do
				local gamemode = vote[1]
				local vote_count = vote[2]
				if not voteCounts[vote[1]] then voteCounts[vote[1]] = 0 end
				--				print(pid, vote[1], vote[2])
				voteCounts[vote[1]] = voteCounts[vote[1]] + vote[2]
			end

			-- Find the key that has the highest value (key=vote value, value=number of votes)
			local highest_vote = 0
			local highest_key = ""
			for k, v in pairs(voteCounts) do
				--				print(k, v)
				if v > highest_vote then
					highest_key = k
					highest_vote = v
				end
			end

			-- Check for a tie by counting how many values have the highest number of votes
			local tieTable = {}
			for k, v in pairs(voteCounts) do
				-- print(k, v)
				if v == highest_vote then
					table.insert(tieTable, tonumber(k))
				end
			end

			-- Resolve a tie by selecting a random value from those with the highest votes
			if table.getn(tieTable) > 1 then
				--				print("Vote System: TIE!")
				highest_key = tieTable[math.random(table.getn(tieTable))]
			end

			-- Act on the winning vote
			Mutation:ChooseMutation(category, highest_key)
			print(category .. ": " .. highest_key)
		end
	end
end, nil)

function Mutation:OnSettingVote(keys)
	local pid = keys.PlayerID
	print(keys)

	if not Mutation.VoteTable then Mutation.VoteTable = {} end
	if not Mutation.VoteTable[keys.category] then Mutation.VoteTable[keys.category] = {} end

	if pid >= 0 then
		if not Mutation.VoteTable[keys.category][pid] then Mutation.VoteTable[keys.category][pid] = {} end

		Mutation.VoteTable[keys.category][pid][1] = keys.vote
		Mutation.VoteTable[keys.category][pid][2] = 1
	end

	--	Say(nil, keys.category, false)
	--	Say(nil, tostring(keys.vote), false)

	-- TODO: Finish votes show up
	CustomGameEventManager:Send_ServerToAllClients("send_votes", { category = keys.category, vote = keys.vote, table = Mutation.VoteTable[keys.category] })
end

function Mutation:ForceAssignHeroes()
	for nPlayerID = 0, (DOTA_MAX_TEAM_PLAYERS - 1) do
		local hPlayer = PlayerResource:GetPlayer(nPlayerID)

		if hPlayer and not PlayerResource:HasSelectedHero(nPlayerID) then
			hPlayer:MakeRandomHeroSelection()
		end
	end
end

function Mutation:TugOfWar()
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

function Mutation:Minefield()
	local mines = {
		"npc_minefield_land_mines",
		"npc_minefield_land_mines_big_boom",
		"npc_minefield_stasis_trap",
	}

	Timers:CreateTimer(function()
		local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)
		local mine_count = 0
		local max_mine_count = 75

		for _, unit in pairs(units) do
			if unit:GetUnitName() == "npc_minefield_land_mines" or unit:GetUnitName() == "npc_minefield_land_mines_big_boom" or unit:GetUnitName() == "npc_minefield_stasis_trap" then
				if unit:GetUnitName() == "npc_minefield_land_mines" then
					unit:FindAbilityByName("minefield_land_mines_trigger"):SetLevel(RandomInt(1, 4))
				elseif unit:GetUnitName() == "npc_minefield_land_mines_big_boom" then
					unit:FindAbilityByName("minefield_land_mines_trigger"):SetLevel(RandomInt(1, 4))
				elseif unit:GetUnitName() == "npc_minefield_stasis_trap" then
					unit:FindAbilityByName("minefield_stasis_trap_trigger"):SetLevel(RandomInt(1, 4))
				end

				mine_count = mine_count + 1
			end
		end

		if mine_count < max_mine_count then
			for i = 1, 10 do
				local mine = CreateUnitByName(mines[RandomInt(1, #mines)], RandomVector(10000), true, nil, nil, DOTA_TEAM_NEUTRALS)
				mine:AddNewModifier(mine, nil, "modifier_invulnerable", {})
			end
		end

		--		print("Mine count:", mine_count)
		return 10.0
	end)
end
