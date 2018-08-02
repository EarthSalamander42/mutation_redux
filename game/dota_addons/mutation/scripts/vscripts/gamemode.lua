-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode
BAREBONES_VERSION = "1.00"

-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false 

if Mutation == nil then
	DebugPrint( '[BAREBONES] creating barebones game mode' )
	_G.Mutation = class({})
end

-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
require('libraries/animations')
-- This library can be used for performing "Frankenstein" attachments on units
-- require('libraries/attachments')
-- This library can be used to synchronize client-server data via player/client-specific nettables
require('libraries/playertables')
-- This library can be used to create container inventories or container shops
require('libraries/containers')
-- This library provides a searchable, automatically updating lua API in the tools-mode via "modmaker_api" console command
-- require('libraries/modmaker')
-- This library provides an automatic graph construction of path_corner entities within the map
require('libraries/pathgraph')
-- This library (by Noya) provides player selection inspection and management from server lua
require('libraries/selection')

-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')

--require("examples/worldpanelsExample")

--[[
	This function should be used to set up Async precache calls at the beginning of the gameplay.

	In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
	after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
	be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
	precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
	defined on the unit.

	This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
	time, you can call the functions individually (for example if you want to precache units in a new wave of
	holdout).

	This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function Mutation:PostLoadPrecache()
	DebugPrint("[BAREBONES] Performing Post-Load precache")    
	--PrecacheItemByNameAsync("item_example_item", function(...) end)
	--PrecacheItemByNameAsync("example_ability", function(...) end)

	--PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
	--PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--[[
	This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
	It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function Mutation:OnFirstPlayerLoaded()
	DebugPrint("[BAREBONES] First Player has loaded")
end

--[[
	This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
	if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
	levels, changing the starting gold, removing/adding abilities, adding physics, etc.

	The hero parameter is the hero entity that just spawned in
]]
function Mutation:OnHeroFirstSpawn(hero)
	DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

	-- This line for example will set the starting gold of every hero to 500 unreliable gold
	--hero:SetGold(500, false)

	-- These lines will create an item and add it to the player, effectively ensuring they start with the item
--	local item = CreateItem("item_example_item", hero, hero)
--	hero:AddItem(item)

	--[[ --These lines if uncommented will replace the W ability of any hero that loads into the game
		--with the "example_ability" ability

	local abil = hero:GetAbilityByIndex(1)
	hero:RemoveAbility(abil:GetAbilityName())
	hero:AddAbility("example_ability")]]
end

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function Mutation:InitGameMode()
	DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')

	-- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
--	Convars:RegisterCommand("command_example", Dynamic_Wrap(self, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT)

--	print("Mutation: Initialize...")

	LinkLuaModifier("modifier_mutation_death_explosion", "modifiers/modifier_mutation_death_explosion.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_kill_streak_power", "modifiers/modifier_mutation_kill_streak_power.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_frantic", "modifiers/modifier_frantic.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_no_health_bar", "modifiers/modifier_no_health_bar.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_river", "modifiers/modifier_river.lua", LUA_MODIFIER_MOTION_NONE )

	LinkLuaModifier("modifier_mutation_sun_strike", "modifiers/periodic_spellcast/modifier_mutation_sun_strike.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_thundergods_wrath", "modifiers/periodic_spellcast/modifier_mutation_thundergods_wrath.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_track", "modifiers/periodic_spellcast/modifier_mutation_track.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_rupture", "modifiers/periodic_spellcast/modifier_mutation_rupture.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_shadow_dance", "modifiers/modifier_mutation_shadow_dance.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_ants", "modifiers/modifier_mutation_ants.lua", LUA_MODIFIER_MOTION_NONE )

	-- Selecting Mutations (Take out if statement for IsInToolsMode if you want to test randomized)
	if IsInToolsMode() then
		IMBA_MUTATION["positive"] = "frantic"
		IMBA_MUTATION["negative"] = "defense_of_the_ants"
		IMBA_MUTATION["terrain"] = "minefield"
	else
		Mutation:ChooseMutation("positive", POSITIVE_MUTATION_LIST)
		Mutation:ChooseMutation("negative", NEGATIVE_MUTATION_LIST)
		Mutation:ChooseMutation("terrain", TERRAIN_MUTATION_LIST)
	end

	IMBA_MUTATION_PERIODIC_SPELLS = {}
	IMBA_MUTATION_PERIODIC_SPELLS[1] = {"sun_strike", "Sunstrike", "Red"}
	IMBA_MUTATION_PERIODIC_SPELLS[2] = {"thundergods_wrath", "Thundergod's Wrath", "Red"}
	IMBA_MUTATION_PERIODIC_SPELLS[3] = {"track", "Track", "Red"}
	IMBA_MUTATION_PERIODIC_SPELLS[4] = {"rupture", "Rupture", "Red"}

--	"cold_feet",
--	"telekinesis",
--	"glimpse",
--	"torrent",

--	"shallow_grave",
--	"false_promise",
--	"bloodrage",
--	"bloodlust",

	-- loading screen mutation mode text
--[[
	font-family: 'Radiance-SemiBold';
	font-size: 36px;
	font-weight: normal;
	text-transform: uppercase;
	letter-spacing: 5.5px;
	color: #d2d0cf;
	text-shadow: 0px 2px 6px rgba(0, 0, 0, 1);
	padding-top: 12px;
	padding-bottom: 12px;
--]]

	DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')
end

function Mutation:ChooseMutation(mType, mList)
	-- Pick a random number within bounds of given mutation list	
	local random_int = RandomInt(1, #mList)
	-- Select a mutation from within that list and place it in the relevant IMBA_MUTATION field
	IMBA_MUTATION[mType] = mList[random_int]
	--print("IMBA_MUTATION["..mType.."] mutation picked: ", mList[random_int])
end

function Mutation:RevealAllMap(duration)
	GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)

	if duration then
		Timers:CreateTimer(duration, function()
			GameRules:GetGameModeEntity():SetFogOfWarDisabled(false)
		end)
	end
end
