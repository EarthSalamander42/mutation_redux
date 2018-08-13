-- In this file you can set up all the properties and settings for your game mode.


ENABLE_HERO_RESPAWN = true              -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = false             -- Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = false		-- Should we let people select the same hero as each other

HERO_SELECTION_TIME = 30.0              -- How long should we let people select their hero?
PRE_GAME_TIME = 90.0                    -- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 60.0                   -- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 60.0                 -- How long should it take individual trees to respawn after being cut down/destroyed?

GOLD_PER_TICK = 1						-- How much gold should players get per tick?
GOLD_TICK_TIME = 0.6					-- How long should we wait in seconds between gold ticks?

CAMERA_DISTANCE_OVERRIDE = -1           -- How far out should we allow the camera to go?  Use -1 for the default (1134) while still allowing for panorama camera distance changes

MINIMAP_ICON_SIZE = 1                   -- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1             -- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1              -- What icon size should we use for runes?

RUNE_SPAWN_TIME = 120                   -- How long in seconds should we wait between rune spawns?
CUSTOM_BUYBACK_COST_ENABLED = false		-- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = false	-- Should we use a custom buyback time?
BUYBACK_ENABLED = true					-- Should we allow people to buyback when they die?

DISABLE_FOG_OF_WAR_ENTIRELY = false     -- Should we disable fog of war entirely for both teams?
USE_UNSEEN_FOG_OF_WAR = false           -- Should we make unseen and fogged areas of the map completely black until uncovered by each team? 
                                            -- Note: DISABLE_FOG_OF_WAR_ENTIRELY must be false for USE_UNSEEN_FOG_OF_WAR to work
USE_STANDARD_DOTA_BOT_THINKING = false  -- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_STANDARD_HERO_GOLD_BOUNTY = true    -- Should we give gold for hero kills the same as in Dota, or allow those values to be changed?

TOP_BAR_VISIBLE = true                  -- Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = true             -- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals)  Requires USE_CUSTOM_TOP_BAR_VALUES

ENABLE_TOWER_BACKDOOR_PROTECTION = false-- Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = false       -- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false             -- Should we disable the gold sound when players get gold?

END_GAME_ON_KILLS = false				-- Should the game end after a certain number of kills?
KILLS_TO_END_GAME_FOR_TEAM = 50         -- How many kills for a team should signify an end of game?

USE_CUSTOM_HERO_LEVELS = false			-- Should we allow heroes to have custom levels?
MAX_LEVEL = 50                          -- What level should we let heroes get to?
USE_CUSTOM_XP_VALUES = false			-- Should we use custom XP values to level up heroes, or the default Dota numbers?

-- Fill this table up with the required XP per level if you want to change it
XP_PER_LEVEL_TABLE = {}
for i=1,MAX_LEVEL do
  XP_PER_LEVEL_TABLE[i] = (i-1) * 100
end

ENABLE_FIRST_BLOOD = true               -- Should we enable first blood for the first kill in this game?
HIDE_KILL_BANNERS = false               -- Should we hide the kill banners that show when a player is killed?
LOSE_GOLD_ON_DEATH = true               -- Should we have players lose the normal amount of dota gold on death?
SHOW_ONLY_PLAYER_INVENTORY = false      -- Should we only allow players to see their own inventory even when selecting other units?
DISABLE_STASH_PURCHASING = false        -- Should we prevent players from being able to buy items into their stash when not at a shop?
DISABLE_ANNOUNCER = false               -- Should we disable the announcer from working in the game?
FORCE_PICKED_HERO = nil                 -- What hero should we force all players to spawn as? (e.g. "npc_dota_hero_axe").  Use nil to allow players to pick their own hero.

FIXED_RESPAWN_TIME = -1                 -- What time should we use for a fixed respawn timer?  Use -1 to keep the default dota behavior.
FOUNTAIN_CONSTANT_MANA_REGEN = -1       -- What should we use for the constant fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_MANA_REGEN = -1     -- What should we use for the percentage fountain mana regen?  Use -1 to keep the default dota behavior.
FOUNTAIN_PERCENTAGE_HEALTH_REGEN = -1   -- What should we use for the percentage fountain health regen?  Use -1 to keep the default dota behavior.
MAXIMUM_ATTACK_SPEED = 600              -- What should we use for the maximum attack speed?
MINIMUM_ATTACK_SPEED = 20               -- What should we use for the minimum attack speed?

GAME_END_DELAY = -1                     -- How long should we wait after the game winner is set to display the victory banner and End Screen?  Use -1 to keep the default (about 10 seconds)
VICTORY_MESSAGE_DURATION = 3            -- How long should we wait after the victory message displays to show the End Screen?  Use 
STARTING_GOLD = 625                     -- How much starting gold should we give to each player?
DISABLE_DAY_NIGHT_CYCLE = false         -- Should we disable the day night cycle from naturally occurring? (Manual adjustment still possible)
DISABLE_KILLING_SPREE_ANNOUNCER = false -- Shuold we disable the killing spree announcer?
DISABLE_STICKY_ITEM = false             -- Should we disable the sticky item button in the quick buy area?
SKIP_TEAM_SETUP = false                 -- Should we skip the team setup entirely?
ENABLE_AUTO_LAUNCH = true               -- Should we automatically have the game complete team setup after AUTO_LAUNCH_DELAY seconds?
AUTO_LAUNCH_DELAY = 10                  -- How long should the default team selection launch timer be?  The default for custom games is 30.  Setting to 0 will skip team selection.
LOCK_TEAM_SETUP = false                 -- Should we lock the teams initially?  Note that the host can still unlock the teams 

CUSTOM_TEAM_PLAYER_COUNT = {}           -- If we're not automatically setting the number of players per team, use this table
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_GOODGUYS] = 5
CUSTOM_TEAM_PLAYER_COUNT[DOTA_TEAM_BADGUYS]  = 5

-- Mutation Variables
MAP_SIZE = 7000
MAP_SIZE_AIRDROP = 5000
MUTATION_ITEM_SPAWN_DELAY = 10.0
MUTATION_ITEM_SPAWN_VISION_LINGER = 10.0
MUTATION_ITEM_SPAWN_RADIUS = 300
validItems = {} -- Empty table to fill with full list of valid airdrop items
minValue = 1000 -- Minimum cost of items that can spawn
tier1 = {} -- 1000 to 2000 gold cost up to 5 minutes
t1cap = 2000
t1time = 5 * 60
tier2 = {} -- 2000 to 3500 gold cost up to 10 minutes
t2cap = 3500
t2time = 10 * 60
tier3 = {} -- 3500 to 5000 gold cost up to 15 minutes
t3cap = 5000
t3time = 15 * 60
tier4 = {} -- 5000 to 99998 gold cost beyond 15 minutes
counter = 1 -- Slowly increments as time goes on to expand list of cost-valid items
varFlag = 0 -- Flag to stop the repeat until loop for tier iterations
SPEED_FREAKS_PROJECTILE_SPEED = 500
SPEED_FREAKS_MOVESPEED_PCT = 50
SPEED_FREAKS_MAX_MOVESPEED = 1000

-- PERIODIC SPELLCAST

-- Positive Spellcasts
MUTATION_LIST_POSITIVE_PERIODIC_SPELLS = {}
MUTATION_LIST_POSITIVE_PERIODIC_SPELLS[1] = {"stampede", "Stampede", "Green", 5.0}
MUTATION_LIST_POSITIVE_PERIODIC_SPELLS[2] = {"bloodlust", "Bloodlust", "Green", 30.0}
MUTATION_LIST_POSITIVE_PERIODIC_SPELLS[3] = {"aphotic_shield", "Aphotic Shield", "Green", 15.0}

-- Negative Spellcasts
MUTATION_LIST_NEGATIVE_PERIODIC_SPELLS = {}
MUTATION_LIST_NEGATIVE_PERIODIC_SPELLS[1] = {"sun_strike", "Sunstrike", "Red", -1}
MUTATION_LIST_NEGATIVE_PERIODIC_SPELLS[2] = {"thundergods_wrath", "Thundergod's Wrath", "Red", -1}
MUTATION_LIST_NEGATIVE_PERIODIC_SPELLS[3] = {"rupture", "Rupture", "Red", 10.0}
MUTATION_LIST_NEGATIVE_PERIODIC_SPELLS[4] = {"torrent", "Torrent", "Red", 45}
MUTATION_LIST_NEGATIVE_PERIODIC_SPELLS[5] = {"cold_feet", "Cold Feet", "Red", 4.0}
MUTATION_LIST_NEGATIVE_PERIODIC_SPELLS[6] = {"track", "Track", "Red", 20.0}

-- WORMHOLE
MUTATION_LIST_WORMHOLE_COLORS = {}
MUTATION_LIST_WORMHOLE_COLORS[1] = Vector(100, 0, 0)
MUTATION_LIST_WORMHOLE_COLORS[2] = Vector(0, 100, 0)
MUTATION_LIST_WORMHOLE_COLORS[3] = Vector(0, 0, 100)
MUTATION_LIST_WORMHOLE_COLORS[4] = Vector(100, 100, 0)
MUTATION_LIST_WORMHOLE_COLORS[5] = Vector(100, 0, 100)
MUTATION_LIST_WORMHOLE_COLORS[6] = Vector(0, 100, 100)
MUTATION_LIST_WORMHOLE_COLORS[7] = Vector(0, 100, 100)
MUTATION_LIST_WORMHOLE_COLORS[8] = Vector(100, 0, 100)
MUTATION_LIST_WORMHOLE_COLORS[9] = Vector(100, 100, 0)
MUTATION_LIST_WORMHOLE_COLORS[10] = Vector(0, 0, 100)
MUTATION_LIST_WORMHOLE_COLORS[11] = Vector(0, 100, 0)
MUTATION_LIST_WORMHOLE_COLORS[12] = Vector(100, 0, 0)

MUTATION_LIST_WORMHOLE_POSITIONS = {}
MUTATION_LIST_WORMHOLE_POSITIONS[1] = Vector(-2471, -5025, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[2] = Vector(-576, -4320, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[3] = Vector(794, -3902, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[4] = Vector(2630, -3700, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[5] = Vector(3203, -6064, 0) -- Bot Lane Wormhole
MUTATION_LIST_WORMHOLE_POSITIONS[6] = Vector(1111, -5804, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[7] = Vector(4419, -5114, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[8] = Vector(6156, -4831, 0) -- Bot Lane Wormhole
MUTATION_LIST_WORMHOLE_POSITIONS[9] = Vector(6084, -3022, 0) -- Bone Lane Wormhole
MUTATION_LIST_WORMHOLE_POSITIONS[10] = Vector(4422, -1765, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[11] = Vector(6186, -654, 0) -- Bot Lane Wormhole
MUTATION_LIST_WORMHOLE_POSITIONS[12] = Vector(4754, -84, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[13] = Vector(3318, -58, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[14] = Vector(5008, 1799, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[15] = Vector(1534, -649, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[16] = Vector(2641, -2003, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[17] = Vector(3939, 2279, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[18] = Vector(2309, 4643, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[19] = Vector(843, 2300, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[20] = Vector(-544, -361, 0) -- Mid Lane Wormhole (Center)
MUTATION_LIST_WORMHOLE_POSITIONS[21] = Vector(354, -1349, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[22] = Vector(289, -2559, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[23] = Vector(-1534, -2893, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[24] = Vector(-5366, -2570, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[25] = Vector(-5238, -1727, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[26] = Vector(-3363, -1210, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[27] = Vector(-4535, 10, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[28] = Vector(-4420, 1351, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[29] = Vector(-6161, 440, 0) -- Top Lane Wormhole
MUTATION_LIST_WORMHOLE_POSITIONS[30] = Vector(-2110, 376, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[31] = Vector(-840, 1384, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[32] = Vector(-388, 2537, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[33] = Vector(-36, 4042, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[34] = Vector(-1389, 4325, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[35] = Vector(-2812, 3633, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[36] = Vector(-4574, 4804, 0)
MUTATION_LIST_WORMHOLE_POSITIONS[37] = Vector(-6339, 3841, 0) -- Top Lane Wormhole
MUTATION_LIST_WORMHOLE_POSITIONS[38] = Vector(-5971, 5455, 0) -- Top Lane Wormhole
MUTATION_LIST_WORMHOLE_POSITIONS[39] = Vector(-3099, 6112, 0) -- Top Lane Wormhole
MUTATION_LIST_WORMHOLE_POSITIONS[40] = Vector(-1606, 6103, 0) -- Top Lane Wormhole

--MUTATION_LIST_WORMHOLE_INTERVAL = 600
--MUTATION_LIST_WORMHOLE_DURATION = 600
MUTATION_LIST_WORMHOLE_PREVENT_DURATION = 3

-- TUG OF WAR
MUTATION_LIST_TUG_OF_WAR_START = {}
MUTATION_LIST_TUG_OF_WAR_START[DOTA_TEAM_BADGUYS] = Vector(4037, 3521, 0)
MUTATION_LIST_TUG_OF_WAR_START[DOTA_TEAM_GOODGUYS] = Vector(-4448, -3936, 0)
MUTATION_LIST_TUG_OF_WAR_TARGET = {}
MUTATION_LIST_TUG_OF_WAR_TARGET[DOTA_TEAM_BADGUYS] = Vector(-5864, -5340, 0)
MUTATION_LIST_TUG_OF_WAR_TARGET[DOTA_TEAM_GOODGUYS] = Vector(5654, 4939, 0)

-- DEATH GOLD DROP
DEATH_GOLD_DROP_PCT = 10		-- amount of gold given to the dropped gold coin (hero gold percentage)
DEATH_GOLD_DROP_FLAT = 300		-- amount of gold given to the dropped gold coin (final result: DEATH_GOLD_DROP_FLAT + DEATH_GOLD_DROP_PCT)

-- FRANTIC
_G.IMBA_FRANTIC_VALUE = 50

-- ULTIMATE LEVEL
ULTIMATE_LEVEL = 100

-- FAST RUNES
FAST_RUNES_TIME = 30.0
