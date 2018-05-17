-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('mutation_list')
require('gamemode')

function Precache( context )
--[[
	This function is used to precache resources/units/items/abilities that will be needed
	for sure in your game and that will not be precached by hero selection.  When a hero
	is selected from the hero selection screen, the game will precache that hero's assets,
	any equipped cosmetics, and perform the data-driven precaching defined in that hero's
	precache{} block, as well as the precache{} block for any equipped abilities.

	See GameMode:PostLoadPrecache() in gamemode.lua for more information
	]]

	DebugPrint("[BAREBONES] Performing pre-load precache")

	PrecacheItemByNameSync( "item_bag_of_gold", context )
	PrecacheResource( "particle", "particles/items2_fx/veil_of_discord.vpcf", context )

	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_pugna.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_techies.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context)
	PrecacheResource("particle", "particles/hw_fx/candy_carrying_stack.vpcf", context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.Mutation = Mutation()
	GameRules.Mutation:_InitGameMode()
end