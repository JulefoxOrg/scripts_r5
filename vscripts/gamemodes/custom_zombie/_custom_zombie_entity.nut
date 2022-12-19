
#if SERVER

    untyped

    // Global functions
        global function CustomZombieEntity_Init


    // Server Init (all [servers] files are called here)
    void function CustomZombieEntity_Init()
    {
        AddCallback_EntitiesDidLoad( ZombieInit )
    }

    void function ZombieInit()
    {
        thread SpawnZombie()
    }

    void function SpawnZombie()
    {
        // Try later

        //thread SpawnZombie()
        //entity infected
        //for ( int i = 0 ; i < 24 ; i++ )
        //{
            //infected = CreateInfected( 99, <0,0,0>, <0,0,0> )
            //DispatchSpawn( infected )
        //}
    }

#endif // SERVER
