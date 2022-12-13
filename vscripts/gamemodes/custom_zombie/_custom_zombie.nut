
untyped

global function CustomZombie_Init


void function CustomZombie_Init()
{
    AddCallback_EntitiesDidLoad( WeaponWalls )
}


void function WeaponWalls()
{
    CreateWeaponWall( $"mdl/weapons/rspn101/w_rspn101.rmdl", < 1859.9375, 4381.93164, -3148.17285 >, < 0, -90, 0 > )
    CreateWeaponWall( $"mdl/weapons/vinson/w_vinson.rmdl", < 1859.9375, 4481.93164, -3148.17285 >, < 0, -90, 0 > )
    CreateWeaponWall( $"mdl/weapons/mastiff_stgn/w_mastiff.rmdl", < 1859.9375, 4581.93164, -3148.17285 >, < 0, -90, 0 > )
    CreateWeaponWall( $"mdl/weapons/b3wing/w_b3wing.rmdl", < 1859.9375, 4681.93164, -3148.17285 >, < 0, -90, 0 > )
    CreateWeaponWall( $"mdl/weapons/p2011_auto/w_p2011_auto.rmdl", < 1859.9375, 4781.93164, -3148.17285 >, < 0, -90, 0 > )
}
