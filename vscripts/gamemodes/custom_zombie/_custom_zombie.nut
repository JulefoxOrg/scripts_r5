
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

        #if NIGHTMARE_DEV
            AddClientCommandCallback( ".", ClientCommand_CustomZombieDevCommand )
        #endif // NIGHTMARE_DEV
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
        CreateMysteryBox( < 3910.18848, 5499.14404, -4295.94385 >, < 0, -140, 0 > )
        CreateMysteryBox( < 3615.48462, 5575.7124, -4303.90625 >, < 0, -140, 0 > )
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

        return true
    }
#endif // SERVER
