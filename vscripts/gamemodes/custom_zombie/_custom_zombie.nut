
untyped

global function CustomZombie_Init


void function CustomZombie_Init()
{
    AddCallback_EntitiesDidLoad( WeaponWalls )
}

void function WeaponWalls()
{
    CreateWeaponWall( eWeaponZombieIdx.R101, < 1859.9375, 4381.93164, -3148.17285 >, < 0, -90, 0 > )
    CreateWeaponWall( eWeaponZombieIdx.FLATLINE, < 1859.9375, 4481.93164, -3148.17285 >, < 0, -90, 0 > )
    CreateWeaponWall( eWeaponZombieIdx.MASTIFF, < 1859.9375, 4581.93164, -3148.17285 >, < 0, -90, 0 > )
    CreateWeaponWall( eWeaponZombieIdx.WINGMAN, < 1859.9375, 4681.93164, -3148.17285 >, < 0, -90, 0 > )
    CreateWeaponWall( eWeaponZombieIdx.RE45, < 1859.9375, 4781.93164, -3148.17285 >, < 0, -90, 0 > )

    float offset = 0

    for ( int i = 0 ; i < eWeaponZombieIdx.len() - 1 ; i++  )
    {
        CreateWeaponWall( i, < 3591.93848, 4244.01758 + offset, -4263.96191 >, < 0, -90, 0 > )
        offset += 100
    }
}
