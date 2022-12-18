
#if SERVER || CLIENT

    untyped

    // Global functions
        global function ShCustomZombie_Init

        global function GetPlayerInSystemGlobal
        global function GetAllPlayerInSystemGlobal
        global function GetPlayerScore


    // Consts
        // If true printt debugging info and other utilities for dev
        global const bool NIGHTMARE_DEV                       = true
        global const bool SPAWN_MYSTERYBOX_ON_ALL_LOCATIONS   = false


    // Perks struct
    global struct CustomZombieSystemPerks
    {
        bool FastReload = true
    }


    // System global struct
    global struct CustomZombieSystemGlobal
    {

        int score = 0

        #if CLIENT
            var playerScoreUI
        #endif // CLIENT

        CustomZombieSystemPerks systemPerks

        array < entity > playerArraySystemGlobal
        table < entity, CustomZombieSystemGlobal > playerSystemGlobal
    }
    global CustomZombieSystemGlobal customZombieSystemGlobal


    // Server || CLIENT Init (all [servers || client] files are called here)
    void function ShCustomZombie_Init()
    {
        #if SERVER
            AddSpawnCallback( "player", PlayerCallback )
        #endif // SERVER

        #if CLIENT
            AddCreateCallback( "player", PlayerCallback )
        #endif // CLIENT

        ShZombieWeaponWall_Init()
        ShZombieScore_Init()
        ShZombieMysteryBox_Init()
        ShCustomZombiePerks_Init()
    }


    // Add player to callback
    void function PlayerCallback( entity player )
    {
        AddPlayerToSystemGlobal( player )
    }


    // Add the player to the custom zombie system
    CustomZombieSystemGlobal function AddPlayerToSystemGlobal( entity player )
    {
        CustomZombieSystemGlobal newPlayer

        customZombieSystemGlobal.playerArraySystemGlobal.append( player )
        customZombieSystemGlobal.playerSystemGlobal[ player ] <- newPlayer

        return customZombieSystemGlobal.playerSystemGlobal[ player ]
    }


    // Find the instance where the player is
    CustomZombieSystemGlobal function GetPlayerInSystemGlobal( entity player )
    {
        return customZombieSystemGlobal.playerSystemGlobal[ player ]
    }


    // Get all players
    array < entity > function GetAllPlayerInSystemGlobal()
    {
        return customZombieSystemGlobal.playerArraySystemGlobal
    }


    // Get the score to a specified player
    int function GetPlayerScore( entity player )
    {
        return customZombieSystemGlobal.playerSystemGlobal[ player ].score
    }
#endif  // SERVER || CLIENT
