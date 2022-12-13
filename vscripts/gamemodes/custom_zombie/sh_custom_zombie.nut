
#if SERVER || CLIENT
    untyped
#endif // SERVER || CLIENT

#if SERVER || CLIENT
    global function ShCustomZombie_Init
#endif // SERVER || CLIENT


#if SERVER || CLIENT
    void function ShCustomZombie_Init()
    {
        ShZombieWeaponWall_Init()
    }
#endif  // SERVER || CLIENT
