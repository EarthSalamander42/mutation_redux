-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function Mutation:_InitGameMode()
	if Mutation._reentrantCheck then
		return
	end

	-- Setup rules
	GameRules:SetHeroRespawnEnabled( ENABLE_HERO_RESPAWN )
	GameRules:SetUseUniversalShopMode( UNIVERSAL_SHOP_MODE )
	GameRules:SetSameHeroSelectionEnabled( ALLOW_SAME_HERO_SELECTION )
	GameRules:SetHeroSelectionTime( HERO_SELECTION_TIME )
	GameRules:SetPreGameTime( PRE_GAME_TIME)
	GameRules:SetPostGameTime( POST_GAME_TIME )
	GameRules:SetTreeRegrowTime( TREE_REGROW_TIME )
	GameRules:SetUseCustomHeroXPValues ( USE_CUSTOM_XP_VALUES )
	GameRules:SetGoldPerTick(GOLD_PER_TICK)
	GameRules:SetGoldTickTime(GOLD_TICK_TIME)
	GameRules:SetRuneSpawnTime(RUNE_SPAWN_TIME)
	GameRules:SetUseBaseGoldBountyOnHeroes(USE_STANDARD_HERO_GOLD_BOUNTY)
	GameRules:SetHeroMinimapIconScale( MINIMAP_ICON_SIZE )
	GameRules:SetCreepMinimapIconScale( MINIMAP_CREEP_ICON_SIZE )
	GameRules:SetRuneMinimapIconScale( MINIMAP_RUNE_ICON_SIZE )

	GameRules:SetFirstBloodActive( ENABLE_FIRST_BLOOD )
	GameRules:SetHideKillMessageHeaders( HIDE_KILL_BANNERS )

	GameRules:SetCustomGameEndDelay( GAME_END_DELAY )
	GameRules:SetCustomVictoryMessageDuration( VICTORY_MESSAGE_DURATION )
	GameRules:SetStartingGold( STARTING_GOLD )

	if SKIP_TEAM_SETUP then
		GameRules:SetCustomGameSetupAutoLaunchDelay( 0 )
		GameRules:LockCustomGameSetupTeamAssignment( true )
		GameRules:EnableCustomGameSetupAutoLaunch( true )
	else
		GameRules:SetCustomGameSetupAutoLaunchDelay( AUTO_LAUNCH_DELAY )
		GameRules:LockCustomGameSetupTeamAssignment( LOCK_TEAM_SETUP )
		GameRules:EnableCustomGameSetupAutoLaunch( ENABLE_AUTO_LAUNCH )
	end

	DebugPrint('[BAREBONES] GameRules set')

	--InitLogFile( "log/barebones.txt","")

	-- Event Hooks
	-- All of these events can potentially be fired by the game, though only the uncommented ones have had
	-- Functions supplied for them.  If you are interested in the other events, you can uncomment the
	-- ListenToGameEvent line and add a function to handle the event
	ListenToGameEvent('entity_killed', Dynamic_Wrap(Mutation, 'OnEntityKilled'), self)
	ListenToGameEvent('player_connect_full', Dynamic_Wrap(Mutation, 'OnConnectFull'), self)
	ListenToGameEvent('player_disconnect', Dynamic_Wrap(Mutation, 'OnDisconnect'), self)
	ListenToGameEvent('tree_cut', Dynamic_Wrap(Mutation, 'OnTreeCut'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(Mutation, 'OnGameRulesStateChange'), self)
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(Mutation, 'OnNPCSpawned'), self)
	ListenToGameEvent("player_reconnected", Dynamic_Wrap(Mutation, 'OnPlayerReconnect'), self)
	ListenToGameEvent("player_chat", Dynamic_Wrap(Mutation, 'OnPlayerChat'), self)

	local spew = 0
	if BAREBONES_DEBUG_SPEW then
		spew = 1
	end
	Convars:RegisterConvar('barebones_spew', tostring(spew), 'Set to 1 to start spewing barebones debug info.  Set to 0 to disable.', 0)

	-- Change random seed
	local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '^0+','')
	math.randomseed(tonumber(timeTxt))

	-- Initialized tables for tracking state
	self.bSeenWaitForPlayers = false
	self.vUserIds = {}

	DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')
	Mutation._reentrantCheck = true
	Mutation:InitGameMode()
	Mutation._reentrantCheck = false
end

mode = nil

-- This function is called as the first player loads and sets up the GameMode parameters
function Mutation:_CaptureGameMode()
	if mode == nil then
		-- Set GameMode parameters
		mode = GameRules:GetGameModeEntity()        
		mode:SetCameraDistanceOverride( CAMERA_DISTANCE_OVERRIDE )
		mode:SetCustomBuybackCostEnabled( CUSTOM_BUYBACK_COST_ENABLED )
		mode:SetCustomBuybackCooldownEnabled( CUSTOM_BUYBACK_COOLDOWN_ENABLED )
		mode:SetBuybackEnabled( BUYBACK_ENABLED )
		mode:SetTopBarTeamValuesVisible( TOP_BAR_VISIBLE )
		mode:SetUseCustomHeroLevels ( USE_CUSTOM_HERO_LEVELS )
		mode:SetCustomHeroMaxLevel ( MAX_LEVEL )
		mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )

		mode:SetBotThinkingEnabled( USE_STANDARD_DOTA_BOT_THINKING )
		mode:SetTowerBackdoorProtectionEnabled( ENABLE_TOWER_BACKDOOR_PROTECTION )

		mode:SetFogOfWarDisabled(DISABLE_FOG_OF_WAR_ENTIRELY)
		mode:SetGoldSoundDisabled( DISABLE_GOLD_SOUNDS )
		mode:SetRemoveIllusionsOnDeath( REMOVE_ILLUSIONS_ON_DEATH )

		mode:SetAlwaysShowPlayerInventory( SHOW_ONLY_PLAYER_INVENTORY )
		mode:SetAnnouncerDisabled( DISABLE_ANNOUNCER )
		if FORCE_PICKED_HERO ~= nil then
			mode:SetCustomGameForceHero( FORCE_PICKED_HERO )
		end
		mode:SetFixedRespawnTime( FIXED_RESPAWN_TIME ) 
		mode:SetFountainConstantManaRegen( FOUNTAIN_CONSTANT_MANA_REGEN )
		mode:SetFountainPercentageHealthRegen( FOUNTAIN_PERCENTAGE_HEALTH_REGEN )
		mode:SetFountainPercentageManaRegen( FOUNTAIN_PERCENTAGE_MANA_REGEN )
		mode:SetLoseGoldOnDeath( LOSE_GOLD_ON_DEATH )
		mode:SetMaximumAttackSpeed( MAXIMUM_ATTACK_SPEED )
		mode:SetMinimumAttackSpeed( MINIMUM_ATTACK_SPEED )
		mode:SetStashPurchasingDisabled ( DISABLE_STASH_PURCHASING )

		mode:SetUnseenFogOfWarEnabled( USE_UNSEEN_FOG_OF_WAR )

		mode:SetDaynightCycleDisabled( DISABLE_DAY_NIGHT_CYCLE )
		mode:SetKillingSpreeAnnouncerDisabled( DISABLE_KILLING_SPREE_ANNOUNCER )
		mode:SetStickyItemDisabled( DISABLE_STICKY_ITEM )

		self:OnFirstPlayerLoaded()
	end 
end
