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
	GameRules:GetGameModeEntity():SetItemAddedToInventoryFilter(Dynamic_Wrap(self, "ItemAddedFilter"), self)
	GameRules:LockCustomGameSetupTeamAssignment(true)
	GameRules:SetCustomGameSetupAutoLaunchDelay(5.0)
	GameRules:SetShowcaseTime(0.0)

	-- Selecting Mutations (Take out if statement for IsInToolsMode if you want to test randomized)
	if IsInToolsMode() then
		MUTATION_LIST["positive"] = POSITIVE_MUTATION_LIST[9]
		MUTATION_LIST["negative"] = NEGATIVE_MUTATION_LIST[3]
		MUTATION_LIST["terrain"] = TERRAIN_MUTATION_LIST[7]
	else
		Mutation:ChooseMutation("positive", POSITIVE_MUTATION_LIST)
		Mutation:ChooseMutation("negative", NEGATIVE_MUTATION_LIST)
		Mutation:ChooseMutation("terrain", TERRAIN_MUTATION_LIST)
	end

	CustomNetTables:SetTableValue("game_options", "mutations", MUTATION_LIST)

--	"telekinesis",
--	"glimpse",

--	"shallow_grave",
--	"false_promise",
--	"bloodrage",
end

function Mutation:ChooseMutation(mType, mList)
	local random_int = RandomInt(1, #mList)
	MUTATION_LIST[mType] = mList[random_int]
	--print("MUTATION_LIST["..mType.."] mutation picked: ", mList[random_int])
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
	if(hero:GetName() == "npc_dota_hero_monkey_king" or hero:GetName() == "npc_dota_hero_rubick") and hero:GetAbsOrigin() ~= Vector(0,0,0) then 
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

		CustomGameEventManager:Send_ServerToAllClients("item_has_spawned", {spawn_location = pos})
		EmitGlobalSound( "powerup_05" )

		ParticleManager:DestroyParticle(particle_arena_fx, false)
		ParticleManager:ReleaseParticleIndex(particle_arena_fx)

		particle_dummy:ForceKill(false)
	end)

	CustomGameEventManager:Send_ServerToAllClients("item_will_spawn", {spawn_location = pos})
	EmitGlobalSound("powerup_03")
end

-- Item added to inventory filter
function Mutation:ItemAddedFilter( keys )

	-- Typical keys:
	-- inventory_parent_entindex_const: 852
	-- item_entindex_const: 1519
	-- item_parent_entindex_const: -1
	-- suggested_slot: -1
	local unit = EntIndexToHScript(keys.inventory_parent_entindex_const)
	local item = EntIndexToHScript(keys.item_entindex_const)
	local item_name = 0
	if item:GetName() then
		item_name = item:GetName()
	end

	if item.airdrop then
		local overthrow_item_drop =
		{
			hero_id = unit:GetClassname(),
			dropped_item = item:GetName()
		}
		CustomGameEventManager:Send_ServerToAllClients("overthrow_item_drop", overthrow_item_drop)
		EmitGlobalSound("powerup_04")
	end

	return true
end

function Mutation:UltimateLevel()
	local XP_PER_LEVEL_TABLE = {}
	-- Vanilla
	XP_PER_LEVEL_TABLE[1] =		0		-- +0
	XP_PER_LEVEL_TABLE[2] =		200		-- +200
	XP_PER_LEVEL_TABLE[3] =		600		-- +400
	XP_PER_LEVEL_TABLE[4] =		1080	-- +480
	XP_PER_LEVEL_TABLE[5] =		1680	-- +600
	XP_PER_LEVEL_TABLE[6] =		2300	-- +620
	XP_PER_LEVEL_TABLE[7] =		2940	-- +640
	XP_PER_LEVEL_TABLE[8] =		3600	-- +660
	XP_PER_LEVEL_TABLE[9] =		4280	-- +680
	XP_PER_LEVEL_TABLE[10] =	5080	-- +800
	XP_PER_LEVEL_TABLE[11] =	5900	-- +820
	XP_PER_LEVEL_TABLE[12] =	6740	-- +840
	XP_PER_LEVEL_TABLE[13] =	7640	-- +900
	XP_PER_LEVEL_TABLE[14] =	8865	-- +1225
	XP_PER_LEVEL_TABLE[15] =	10115	-- +1250
	XP_PER_LEVEL_TABLE[16] =	11390	-- +1275
	XP_PER_LEVEL_TABLE[17] =	12690	-- +1300
	XP_PER_LEVEL_TABLE[18] =	14015	-- +1325
	XP_PER_LEVEL_TABLE[19] =	15415	-- +1400
	XP_PER_LEVEL_TABLE[20] =	16905	-- +1490
	XP_PER_LEVEL_TABLE[21] =	18405	-- +1500
	XP_PER_LEVEL_TABLE[22] =	20155	-- +1750
	XP_PER_LEVEL_TABLE[23] =	22155	-- +2000
	XP_PER_LEVEL_TABLE[24] =	24405	-- +2250
	XP_PER_LEVEL_TABLE[25] =	26905	-- +2500

	GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE)

	if ULTIMATE_LEVEL and ULTIMATE_LEVEL > 25 then
		local j = 26
		Timers:CreateTimer(function()
			if j >= ULTIMATE_LEVEL then return end
			print(j)
			for i = j, j + 2 do
				XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i-1] + 2500
				GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE)
			end
			j = j + 2
			return 1.0
		end)
	end
end