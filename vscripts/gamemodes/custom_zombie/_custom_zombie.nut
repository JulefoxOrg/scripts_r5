
untyped

global function CustomZombie_Init


void function CustomZombie_Init()
{
    AddCallback_OnClientConnected( OnClientConnected )
    AddCallback_OnClientDisconnected( OnClientDisconnected )
    AddCallback_EntitiesDidLoad( WeaponWalls )
}

void function WeaponWalls()
{
    CreateWeaponWall( eWeaponZombieIdx.R101, < 1859.9375, 4381.93164, -3148.17285 >, < 0, -90, 0 > )
    CreateWeaponWall( eWeaponZombieIdx.FLATLINE, < 1859.9375, 4481.93164, -3148.17285 >, < 0, -90, 0 > )
    CreateWeaponWall( eWeaponZombieIdx.MASTIFF, < 1859.9375, 4581.93164, -3148.17285 >, < 0, -90, 0 > )
    CreateWeaponWall( eWeaponZombieIdx.WINGMAN, < 1859.9375, 4681.93164, -3148.17285 >, < 0, -90, 0 > )
    CreateWeaponWall( eWeaponZombieIdx.RE45, < 1859.9375, 4781.93164, -3148.17285 >, < 0, -90, 0 > )

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

    CreateMysteryBox( <3482.94702, 6998.60303, -4303.96875>, < 0, -90, 0 > )
}

void function OnClientConnected( entity player )
{
    // Add $ on start
    AddScoreToPlayer( player, 8000 )

    #if NIGHTMARE_DEV
        player.SetOrigin( < 3828, 4592, 4246 > )
        player.SetAngles( < 0, 0, 0 > )
        player.SetVelocity( < 0, 0, 0 > )
    #endif // NIGHTMARE_DEV

    // UI Init
    Remote_CallFunction_NonReplay( player, "ServerCallback_RUIInit" )

    // Give P2020 on start
    GiveWeaponToPlayer( player, "mp_weapon_semipistol", WEAPON_INVENTORY_SLOT_PRIMARY_0 )
}

void function OnClientDisconnected( entity player )
{
    // Remove player from currency system
    if ( player in customZombieSystemGlobal.playerSystemGlobal )
	delete customZombieSystemGlobal.playerSystemGlobal[ player ]
    Remote_CallFunction_NonReplay( player, "ServerCallback_OnClientDisconnected", player )
}
