
#if SERVER

    untyped

    // Global functions
        global function CustomZombie_Init


    // Server Init (all [servers] files are called here)
    void function CustomZombie_Init()
    {
        AddCallback_OnClientConnected( void function(entity player) { thread _OnPlayerConnected(player) } )
        AddCallback_OnClientDisconnected( OnClientDisconnected )

        AddCallback_EntitiesDidLoad( WeaponWall )
        AddCallback_EntitiesDidLoad( MysteryBox )

        CustomZombieEntity_Init()

        #if NIGHTMARE_DEV
            AddClientCommandCallback( ".", ClientCommand_CustomZombieDevCommand )
        #endif // NIGHTMARE_DEV

        /* // Cool things
        array < array > Array = 
        [
            [ $"mdl/dev/editor_ref.rmdl", < 0, 0, 0 >, < 0, 0, 0 > ],
            [ $"mdl/dev/editor_ref.rmdl", < 0, 80, 0 >, < 0, 90, 0 > ],
            [ $"mdl/dev/editor_ref.rmdl", < 0, 160, 0 >, < 0, 180, 0 > ],
            [ $"mdl/dev/editor_ref.rmdl", < 0, 240, 0 >, < 0, -90, 0 > ]
        ]

        foreach ( Arrays in Array )
        {
            CreatePropDynamic( expect asset( Arrays[0] ), expect vector( Arrays[1] ), expect vector( Arrays[2] ), SOLID_VPHYSICS, -1 )
        } */

    }


    // Create weapon walls on map
    void function WeaponWall()
    {
        float offsetY = 0
        float offsetZ = 0
        int totalWeapons = eWeaponZombieIdx.len() - 1
        int totalWeaponsMid = totalWeapons / 2

        for ( int i = 0 ; i < totalWeapons ; i++  )
        {
            CreateWeaponWall( i, < 4034.15479, 3945.68115 + offsetY, -4238.57861 + offsetZ >, < 0, -90, 0 > )
            offsetY += 100
            if ( i == totalWeaponsMid )
            {
                offsetZ += 40
                offsetY = 0
            }
        } 
    }


    // Create mystery box on map
    void function MysteryBox()
    {
        RegisterMysteryBoxLocation( < 4966.9502, 8444.75879, -4295.90625 >, < 0, 148.6, 0 > )
        RegisterMysteryBoxLocation( < 2100.60107, 5354.08203, -3207.96875 >, < 0, -90, 0 > )
        RegisterMysteryBoxLocation( < 6143.9292, 6060.78271, -3503.69702 >, < 0, -90, 0 > )
        RegisterMysteryBoxLocation( < 2049.49829, 11961.0732, -3336.95386 >, < 0, 90, 0 > )
        RegisterMysteryBoxLocation( <9651.8125, 5981.89258, -3695.96875>, < 0, -90, 0 > )
        MysteryBoxMapInit( 1 )
    }


    // Add callback on client connected
    void function _OnPlayerConnected( entity player )
    {
        wait 1.0
        
        if( !IsValid( player ) )
            return

        // UI Init
        Remote_CallFunction_NonReplay( player, "ServerCallback_RUIInit" )

        player.SetOrigin( < 3828, 4592, -4246 > )
        player.SetAngles( < 0, 0, 0 > )
        player.SetVelocity( < 0, 0, 0 > )

        // If NIGHTMARE_DEV is true
        // Add $ on start + Set player origin
        #if NIGHTMARE_DEV
            AddScoreToPlayer( player, 10000 )
        #else
            // Add $ on start
            AddScoreToPlayer( player, 500 )

            // Give P2020 on start
            GiveWeaponToPlayer( player, "mp_weapon_semipistol", WEAPON_INVENTORY_SLOT_PRIMARY_0 )
        #endif // NIGHTMARE_DEV
    }


    // Callback when a player is disconnected
    // Need to verify if that works
    void function OnClientDisconnected( entity player )
    {
        // Remove player from currency system
        if ( player in customZombieSystemGlobal.playerSystemGlobal )
    	delete customZombieSystemGlobal.playerSystemGlobal[ player ]
        Remote_CallFunction_NonReplay( player, "ServerCallback_OnClientDisconnected", player )
    }


    // Dev testing
    bool function ClientCommand_CustomZombieDevCommand( entity player, array < string > args )
    {
        /* CustomZombieSystemGlobal Syst = GetPlayerInSystemGlobal( player )

        foreach ( weapons in player.GetMainWeapons() )
        {
            float reloadTime = weapons.GetWeaponSettingFloat( eWeaponVar.reload_time )
            printt( reloadTime )
        } */

        printt( "Available locations: " + GetAvailablesLocations() )

        return true
    }
#endif // SERVER
