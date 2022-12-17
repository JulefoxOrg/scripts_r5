
#if SERVER || CLIENT

    untyped

    // Global functions
        global function ShCustomZombie_Init

        global function GetPlayerInSystemGlobal
        global function GetPlayerScore


    // Consts
        // If true printt debugging info and other utilities for dev
        global const bool NIGHTMARE_DEV = true


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

        customZombieSystemGlobal.playerSystemGlobal[ player ] <- newPlayer

        return customZombieSystemGlobal.playerSystemGlobal[ player ]
    }


    // Find the instance where the player is
    CustomZombieSystemGlobal function GetPlayerInSystemGlobal( entity player )
    {
        return customZombieSystemGlobal.playerSystemGlobal[ player ]
    }


    // Get the score to a specified player
    int function GetPlayerScore( entity player )
    {
        return customZombieSystemGlobal.playerSystemGlobal[ player ].score
    }
#endif  // SERVER || CLIENT
