
#if SERVER || CLIENT

    untyped

    // Global functions
        global function ShZombieMysteryBoxWeapon_Init

    #if SERVER
        global function CreateWeaponInMysteryBox
    #endif // SERVER

    #if CLIENT
    #endif // CLIENT

    // Consts
        const asset  NESSY_MODEL                          = $"mdl/domestic/nessy_doll.rmdl"
        const float  MYSTERY_BOX_WEAPON_ON_USE_DURATION   = 0.0
        const string MYSTERY_BOX_TAKE_WEAPON              = "to take %s"
        const string MYSTERY_BOX_WEAPON_SCRIPT_NAME       = "MysteryBoxWeaponScriptName"
        const string USE                                  = "Press %use% "

    #if SERVER
    #endif // SERVER

    #if CLIENT
        const asset MYSTERY_BOX_DISPLAYRUI = $"ui/extended_use_hint.rpak"
    #endif // CLIENT


    // Init
    void function ShZombieMysteryBoxWeapon_Init()
    {
        #if SERVER
            PrecacheModel( NESSY_MODEL )
        #endif // SERVER

        #if SERVER
            AddSpawnCallback( "prop_dynamic", WeaponMysteryBoxInit )
        #endif // SERVER

        #if CLIENT
            AddCreateCallback( "prop_dynamic", WeaponMysteryBoxInit )
        #endif // CLIENT
    }


    // SERVER && CLIENT Callback
    void function WeaponMysteryBoxInit( entity weaponMysteryBox )
    {
        if ( !IsValidWeaponMysteryBox( weaponMysteryBox ) )
            return

        GetMysteryBoxFromEnt( weaponMysteryBox ).mysteryBoxWeapon = weaponMysteryBox

        SetWeaponMysteryBoxUsable( weaponMysteryBox )
    }


    // Check by script name if it is a weapon in a mystery box
    bool function IsValidWeaponMysteryBox( entity ent )
    {
        if ( ent.GetScriptName() == MYSTERY_BOX_WEAPON_SCRIPT_NAME )
            return true

        return false
    }


    // Set weapon usable
    void function SetWeaponMysteryBoxUsable( entity weaponMysteryBox )
    {
        #if SERVER
            weaponMysteryBox.SetUsable()
            weaponMysteryBox.SetUsableByGroup( "pilot" )
            weaponMysteryBox.SetUsableValue( USABLE_BY_ALL | USABLE_CUSTOM_HINTS )
            weaponMysteryBox.SetUsablePriority( USABLE_PRIORITY_MEDIUM )
        #endif // SERVER

        SetCallback_CanUseEntityCallback( weaponMysteryBox, WeaponMysteryBox_CanUse )
        AddCallback_OnUseEntity( weaponMysteryBox, OnUseProcessingWeaponMysteryBox )

        #if CLIENT
            AddEntityCallback_GetUseEntOverrideText( weaponMysteryBox, WeaponMysteryBox_TextOverride )
        #endif // CLIENT
    }


    // If is usable
    bool function WeaponMysteryBox_CanUse( entity player, entity weaponMysteryBox )
    {
        if ( !SURVIVAL_PlayerCanUse_AnimatedInteraction( player, weaponMysteryBox ) )
            return false

        if ( !GradeFlagsHas( player, GetMysteryBoxFromEnt( weaponMysteryBox ).uniqueGradeIdx ) )
            return false

        return true
    }


    // Callback if the weapon is used
    void function OnUseProcessingWeaponMysteryBox( entity weaponMysteryBox, entity playerUser, int useInputFlags )
    {
        if ( !( useInputFlags & USE_INPUT_LONG ) )
            return

        ExtendedUseSettings settings
        settings.duration             = MYSTERY_BOX_WEAPON_ON_USE_DURATION
        settings.useInputFlag         = IN_USE_LONG
        settings.successFunc          = WeaponMysteryBoxUseSuccess

        #if CLIENT
            settings.hint             = "#HINT_VAULT_UNLOCKING"
            settings.displayRui       = MYSTERY_BOX_DISPLAYRUI
            settings.displayRuiFunc   = MysteryBox_DisplayRui
        #endif // CLIENT

        thread ExtendedUse( weaponMysteryBox, playerUser, settings )
    }


    // If the callback is a success
    void function WeaponMysteryBoxUseSuccess( entity weaponMysteryBox, entity player, ExtendedUseSettings settings )
    {
        CustomZombieMysteryBox mysteryBoxStruct = GetMysteryBoxFromEnt( weaponMysteryBox )
        
        #if SERVER
            ServerWeaponWallUseSuccess( weaponMysteryBox, player )

            if ( IsValid( weaponMysteryBox ) ) thread DestroyWeaponByDeadline_Thread( player, mysteryBoxStruct.mysteryBoxEnt )
        #endif // SERVER
    }


    #if CLIENT
        // Text override
        string function WeaponMysteryBox_TextOverride( entity weaponMysteryBox )
        {
            int weaponIdx       = GetWeaponIdx( weaponMysteryBox )
            string weaponName   = eWeaponZombieName[ weaponIdx ][ 1 ]
            
            return USE + format( MYSTERY_BOX_TAKE_WEAPON, weaponName )
        }
    #endif // CLIENT


    #if SERVER
        // Create weapon in mystery box
        entity function CreateWeaponInMysteryBox( int index, vector pos, vector ang, string targetName )
        {
            entity weapon = CreateEntity( "prop_dynamic" )
            weapon.SetModel( eWeaponZombieModel[ index ] )
            weapon.SetModelScale( 1 )
            weapon.SetScriptName( MYSTERY_BOX_WEAPON_SCRIPT_NAME )
            weapon.NotSolid()
            weapon.SetFadeDistance( 20000 )
            weapon.SetOrigin( pos )
            weapon.SetAngles( ang )
            SetTargetName( weapon, targetName )

            DispatchSpawn( weapon )

            return weapon
        }
    #endif // SERVER


#endif // SERVER || CLIENT
