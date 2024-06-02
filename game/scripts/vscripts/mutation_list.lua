-- Editors:
--     Earth Salamander #42

-- Positive Mutations
POSITIVE_MUTATION_LIST = {}
POSITIVE_MUTATION_LIST[1] = "frantic"
POSITIVE_MUTATION_LIST[2] = "jump_start"
POSITIVE_MUTATION_LIST[3] = "killstreak_power"
-- POSITIVE_MUTATION_LIST[4] = "pocket_tower"
POSITIVE_MUTATION_LIST[4] = "super_fervor"
-- POSITIVE_MUTATION_LIST[5] = "super_blink"
POSITIVE_MUTATION_LIST[5] = "slark_mode"
POSITIVE_MUTATION_LIST[6] = "teammate_resurrection"
POSITIVE_MUTATION_LIST[7] = "ultimate_level"

-- POSITIVE_MUTATION_LIST["greed_is_good"] = false

-- Negative Mutations
NEGATIVE_MUTATION_LIST = {}
NEGATIVE_MUTATION_LIST[1] = "alien_incubation"
NEGATIVE_MUTATION_LIST[2] = "death_explosion"
NEGATIVE_MUTATION_LIST[3] = "death_gold_drop"
-- NEGATIVE_MUTATION_LIST[4] = "defense_of_the_ants"
NEGATIVE_MUTATION_LIST[4] = "monkey_business"
NEGATIVE_MUTATION_LIST[5] = "no_health_bar"
NEGATIVE_MUTATION_LIST[6] = "periodic_spellcast"
NEGATIVE_MUTATION_LIST[7] = "stay_frosty"

-- Terrain Mutations
TERRAIN_MUTATION_LIST = {}
TERRAIN_MUTATION_LIST[1] = "gift_exchange" -- Airdrop
TERRAIN_MUTATION_LIST[2] = "call_down"
TERRAIN_MUTATION_LIST[3] = "fast_runes"
TERRAIN_MUTATION_LIST[4] = "minefield"
TERRAIN_MUTATION_LIST[5] = "river_flows"
-- TERRAIN_MUTATION_LIST[5] = "sleepy_river"
TERRAIN_MUTATION_LIST[6] = "speed_freaks"
-- TERRAIN_MUTATION_LIST[7] = "tug_of_war"
TERRAIN_MUTATION_LIST[7] = "wormhole"

MUTATION_LIST = {}
MUTATION_LIST["positive"] = POSITIVE_MUTATION_LIST
MUTATION_LIST["negative"] = NEGATIVE_MUTATION_LIST
MUTATION_LIST["terrain"] = TERRAIN_MUTATION_LIST
CustomNetTables:SetTableValue("game_options", "mutation_list", MUTATION_LIST)

--TERRAIN_MUTATION_LIST["sleepy_river"] = false
-- TERRAIN_MUTATION_LIST["no_trees"] = false
-- TERRAIN_MUTATION_LIST["omni_vision"] = false
-- TERRAIN_MUTATION_LIST["sticky_river"] = false

-- Mutations Not coded/approved yet

-- POSITIVE_MUTATION_LIST["damage_reduction"] = false
-- POSITIVE_MUTATION_LIST["stationary_damage_reduction"] = false
-- POSITIVE_MUTATION_LIST["super_runes"] = false
-- POSITIVE_MUTATION_LIST["greedisgood"] = false
-- POSITIVE_MUTATION_LIST["angel_arena"] = false

-- NEGATIVE_MUTATION_LIST["monkey_business"] = false
-- NEGATIVE_MUTATION_LIST["the_walking_dead"] = false

-- TERRAIN_MUTATION_LIST["danger_zone"] = false -- add archer's music danger zone
-- TERRAIN_MUTATION_LIST["river_fag"] = false
-- TERRAIN_MUTATION_LIST["diretide"] = false
-- TERRAIN_MUTATION_LIST["void_path"] = false
-- TERRAIN_MUTATION_LIST["reality_rift"] = false
-- TERRAIN_MUTATION_LIST["blizzard"] = false
-- TERRAIN_MUTATION_LIST["twister"] = false
