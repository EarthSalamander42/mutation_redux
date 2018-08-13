-- This is the entry-point to your game mode and should be used primarily to precache models/particles/sounds/etc

require('internal/util')
require('gamemode')

function Precache( context )
	LinkLuaModifier("modifier_frantic", "modifiers/modifier_frantic.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_death_explosion", "modifiers/modifier_mutation_death_explosion.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_kill_streak_power", "modifiers/modifier_mutation_kill_streak_power.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_frantic", "modifiers/modifier_frantic.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_no_health_bar", "modifiers/modifier_no_health_bar.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_shadow_dance", "modifiers/modifier_mutation_shadow_dance.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_ants", "modifiers/modifier_mutation_ants.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_disable_healing", "modifiers/modifier_disable_healing.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_stay_frosty", "modifiers/modifier_mutation_stay_frosty.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_speed_freaks", "modifiers/modifier_mutation_speed_freaks.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_super_fervor", "modifiers/modifier_mutation_super_fervor.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_greed_is_good", "modifiers/modifier_mutation_greed_is_good.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_alien_incubation", "modifiers/modifier_mutation_alien_incubation.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_wormhole_cooldown", "modifiers/modifier_mutation_wormhole_cooldown.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_tug_of_war_golem", "modifiers/modifier_mutation_tug_of_war_golem.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_sun_strike", "modifiers/periodic_spellcast/modifier_mutation_sun_strike.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_call_down", "modifiers/modifier_mutation_call_down.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_thundergods_wrath", "modifiers/periodic_spellcast/modifier_mutation_thundergods_wrath.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_track", "modifiers/periodic_spellcast/modifier_mutation_track.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_rupture", "modifiers/periodic_spellcast/modifier_mutation_rupture.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_torrent", "modifiers/periodic_spellcast/modifier_mutation_torrent.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_cold_feet", "modifiers/periodic_spellcast/modifier_mutation_cold_feet.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_stampede", "modifiers/periodic_spellcast/modifier_mutation_stampede.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_bloodlust", "modifiers/periodic_spellcast/modifier_mutation_bloodlust.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_mutation_aphotic_shield", "modifiers/periodic_spellcast/modifier_mutation_aphotic_shield.lua", LUA_MODIFIER_MOTION_NONE )

	LinkLuaModifier("modifier_mutation_river_flows", "modifiers/modifier_mutation_river_flows.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_sticky_river", "modifiers/modifier_sticky_river.lua", LUA_MODIFIER_MOTION_NONE )
	LinkLuaModifier("modifier_ultimate_level", "modifiers/modifier_ultimate_level.lua", LUA_MODIFIER_MOTION_NONE )

	-- Killstreak Power
	PrecacheResource("particle", "particles/hw_fx/candy_carrying_stack.vpcf", context)

	-- Periodic Spellcast
	PrecacheResource("particle", "particles/econ/items/zeus/arcana_chariot/zeus_arcana_thundergods_wrath_start_bolt_parent.vpcf", context)

	-- Wormhole
	PrecacheResource("particle", "particles/ambient/wormhole_circle.vpcf", context)

	-- Tug of War
	PrecacheResource("particle", "particles/ambient/tug_of_war_team_dire.vpcf", context)
	PrecacheResource("particle", "particles/ambient/tug_of_war_team_radiant.vpcf", context)

	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_abaddon.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_ancient_apparition.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_bloodseeker.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_bounty_hunter.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_centaur.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_gyrocopter.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_kunkka.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_ogre_magi.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_pugna.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_techies.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_troll_warlord.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_warlock.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.Mutation = Mutation()
	GameRules.Mutation:_InitGameMode()
end