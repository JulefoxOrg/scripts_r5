
#if SERVER || CLIENT
    untyped

    global function ShCustomZombie_Init

    global function GetPlayerInSystemGlobal
    global function GetPlayerScore


    global const bool NIGHTMARE_DEV = true


    global struct CustomZombieSystemGlobal
    {

        int score = 0

        #if CLIENT
            var playerScoreUI
        #endif

        table < entity, CustomZombieSystemGlobal > playerSystemGlobal
    }
    global CustomZombieSystemGlobal customZombieSystemGlobal


    void function ShCustomZombie_Init()
    {
        #if SERVER
            AddSpawnCallback( "player", PlayerCustomZombieInit )
        #endif // SERVER

        #if CLIENT
            AddCreateCallback( "player", PlayerCustomZombieInit )
        #endif // CLIENT

        ShZombieWeaponWall_Init()
        ShZombieScore_Init()
        ShZombieMysteryBox_Init()
    }

    void function PlayerCustomZombieInit( entity player )
    {
        AddPlayerToSystemGlobal( player )
    }

    CustomZombieSystemGlobal function AddPlayerToSystemGlobal( entity player )
    {
        CustomZombieSystemGlobal newPlayer

        customZombieSystemGlobal.playerSystemGlobal[ player ] <- newPlayer

        return customZombieSystemGlobal.playerSystemGlobal[ player ]
    }

    CustomZombieSystemGlobal function GetPlayerInSystemGlobal( entity player )
    {
        return customZombieSystemGlobal.playerSystemGlobal[ player ]
    }

    int function GetPlayerScore( entity player )
    {
        return customZombieSystemGlobal.playerSystemGlobal[ player ].score
    }
#endif  // SERVER || CLIENT
