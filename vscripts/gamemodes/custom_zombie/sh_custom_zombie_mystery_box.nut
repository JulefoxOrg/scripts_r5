
#if SERVER || CLIENT
    untyped

#if SERVER // Global
    global function CreateMysteryBox
#endif // SERVER

    global function ShZombieMysteryBox_Init

    global function GetMysteryBox
    global function GetMysteryBoxFromEnt

#if CLIENT
    const asset MYSTERY_BOX_DISPLAYRUI = $"ui/extended_use_hint.rpak"
#endif // CLIENT

#if SERVER
    const asset MYSTERY_BOX_BEAM = $"P_ar_hot_zone_far"
#endif // SERVER

    const float  MYSTERY_BOX_ON_USE_DURATION        = 0.0
    const float  MYSTERY_BOX_WEAPON_MOVE_TIME       = 3
    const float  MYSTERY_BOX_WEAPON_ON_USE_DURATION = 0.0
    const int    MYSTERY_BOX_COST                   = 950
    const string MYSTERY_BOX_SCRIPT_NAME            = "MysteryBoxScriptName"
    const string MYSTERY_BOX_TAKE_WEAPON            = "to take %s"
    const string MYSTERY_BOX_USE                    = "to open Mystery Box\nCost: %i $"
    const string MYSTERY_BOX_WEAPON_SCRIPT_NAME     = "MysteryBoxWeaponScriptName"
    const string USE                                = "Press %use% "
    const vector MYSTERY_BOX_WEAPON_ANGLES_OFFSET   = < 0, 90, 0 >
    const vector MYSTERY_BOX_WEAPON_MOVE_TO         = < 0, 0, 30 >
    const vector MYSTERY_BOX_WEAPON_ORIGIN_OFFSET   = < 0, 0, 20 >

    global struct CustomZombieMysteryBox
    {
        array < entity > mysteryBoxArray
        bool execThread
        bool isUsable = false
        bool isUsableWeapon = false
        entity mysteryBoxEnt
        entity mysteryBoxFx
        entity mysteryBoxWeapon
        entity mysteryBoxWeaponScriptMover
        string targetName
        table < entity, CustomZombieMysteryBox > mysteryBox
    }
    global CustomZombieMysteryBox customZombieMysteryBox


    void function ShZombieMysteryBox_Init()
    {
        #if SERVER
            PrecacheParticleSystem( MYSTERY_BOX_BEAM )
        #endif // SERVER

        #if SERVER
            AddSpawnCallback( "prop_dynamic", MysteryBoxInit )
            AddSpawnCallback( "prop_dynamic", WeaponMysteryBoxInit )
        #endif // SERVER

        #if CLIENT
            AddCreateCallback( "prop_dynamic", MysteryBoxInit )
            AddCreateCallback( "prop_dynamic", WeaponMysteryBoxInit )
        #endif // CLIENT
    }

    void function MysteryBoxInit( entity mysteryBox )
    {
        if ( !IsValidMysteryBox( mysteryBox ) )
            return

        AddMysteryBox( mysteryBox )
        SetMysteryBoxUsable( mysteryBox )

        #if SERVER
            SetMysteryBoxFx( mysteryBox )
        #endif // SERVER
    }

    void function WeaponMysteryBoxInit( entity weaponMysteryBox )
    {
        if ( !IsValidWeaponMysteryBox( weaponMysteryBox ) )
            return

        GetMysteryBoxFromEnt( weaponMysteryBox ).mysteryBoxWeapon = weaponMysteryBox

        SetWeaponMysteryBoxUsable( weaponMysteryBox )
    }

    CustomZombieMysteryBox function AddMysteryBox( entity mysteryBox )
    {
        CustomZombieMysteryBox newMysteryBox

        customZombieMysteryBox.mysteryBox[ mysteryBox ] <- newMysteryBox
        customZombieMysteryBox.mysteryBoxArray.append( mysteryBox )

        newMysteryBox.mysteryBoxEnt = mysteryBox
        newMysteryBox.targetName = UniqueMysteryBoxString( "MysteryBox" )

        #if SERVER
            SetTargetName( mysteryBox, newMysteryBox.targetName )
        #endif // SERVER

        return customZombieMysteryBox.mysteryBox[ mysteryBox ]
    }

    CustomZombieMysteryBox function GetMysteryBox( entity mysteryBox )
    {
        return customZombieMysteryBox.mysteryBox[ mysteryBox ]
    }

    CustomZombieMysteryBox function GetMysteryBoxFromEnt( entity mysteryBoxEnt )
    {
        string targetName = mysteryBoxEnt.GetTargetName()
        entity MysteryBox

        foreach ( mysteryBox in GetAllMysteryBox() )
            if ( GetMysteryBox( mysteryBox ).targetName == targetName )
                MysteryBox = mysteryBox

    return customZombieMysteryBox.mysteryBox[ MysteryBox ] }

    entity function GetEntMysteryBoxFromEnt( entity mysteryBoxEnt )
    {
        string targetName = mysteryBoxEnt.GetTargetName()
        entity MysteryBox

        foreach ( mysteryBox in GetAllMysteryBox() )
            if ( GetMysteryBox( mysteryBox ).targetName == targetName )
                MysteryBox = mysteryBox

    return MysteryBox }

    array< entity > function GetAllMysteryBox()
    {
        return customZombieMysteryBox.mysteryBoxArray
    }

    bool function IsValidMysteryBox( entity ent )
    {
        if ( ent.GetScriptName() == MYSTERY_BOX_SCRIPT_NAME )
            return true

        return false
    }

    bool function IsValidWeaponMysteryBox( entity ent )
    {
        if ( ent.GetScriptName() == MYSTERY_BOX_WEAPON_SCRIPT_NAME )
            return true

        return false
    }

    bool function MysteryBox_CanUse( entity player, entity mysteryBox )
    {
        if ( !SURVIVAL_PlayerCanUse_AnimatedInteraction( player, mysteryBox ) )
            return false

        return true
    }

    int uniqueMysteryBoxIdx = 0
    string function UniqueMysteryBoxString( string str = "" )
    {
    	return str + "_idx" + uniqueMysteryBoxIdx++
    }

    void function SetMysteryBoxUsable( entity mysteryBox )
    {
        #if SERVER
            mysteryBox.SetUsable()
            mysteryBox.SetUsableByGroup( "pilot" )
            mysteryBox.SetUsableValue( USABLE_BY_ALL | USABLE_CUSTOM_HINTS )
            mysteryBox.SetUsablePriority( USABLE_PRIORITY_MEDIUM )
        #endif // SERVER

        GetMysteryBox( mysteryBox ).isUsable = true

        SetCallback_CanUseEntityCallback( mysteryBox, MysteryBox_CanUse )
        AddCallback_OnUseEntity( mysteryBox, OnUseProcessingMysteryBox )

        #if CLIENT
            AddEntityCallback_GetUseEntOverrideText( mysteryBox, MysteryBox_TextOverride )
        #endif // CLIENT
    }

    void function SetWeaponMysteryBoxUsable( entity weaponMysteryBox )
    {
        #if SERVER
            weaponMysteryBox.SetUsable()
            weaponMysteryBox.SetUsableByGroup( "pilot" )
            weaponMysteryBox.SetUsableValue( USABLE_BY_ALL | USABLE_CUSTOM_HINTS )
            weaponMysteryBox.SetUsablePriority( USABLE_PRIORITY_MEDIUM )
        #endif // SERVER

        SetCallback_CanUseEntityCallback( weaponMysteryBox, MysteryBox_CanUse )
        AddCallback_OnUseEntity( weaponMysteryBox, OnUseProcessingWeaponMysteryBox )

        #if CLIENT
            AddEntityCallback_GetUseEntOverrideText( weaponMysteryBox, WeaponMysteryBox_TextOverride )
        #endif // CLIENT
    }

    void function OnUseProcessingMysteryBox( entity mysteryBox, entity playerUser, int useInputFlags )
    {
        if ( !( useInputFlags & USE_INPUT_LONG ) )
            return

        ExtendedUseSettings settings
        settings.duration       = MYSTERY_BOX_ON_USE_DURATION
        settings.useInputFlag   = IN_USE_LONG
        settings.successFunc    = MysteryBoxUseSuccess

        #if CLIENT
            settings.hint               = "#HINT_VAULT_UNLOCKING"
            settings.displayRui         = MYSTERY_BOX_DISPLAYRUI
            settings.displayRuiFunc     = MysteryBox_DisplayRui
        #endif // CLIENT

        thread ExtendedUse( mysteryBox, playerUser, settings )
    }

    void function OnUseProcessingWeaponMysteryBox( entity weaponMysteryBox, entity playerUser, int useInputFlags )
    {
        if ( !( useInputFlags & USE_INPUT_LONG ) )
            return

        ExtendedUseSettings settings
        settings.duration       = MYSTERY_BOX_WEAPON_ON_USE_DURATION
        settings.useInputFlag   = IN_USE_LONG
        settings.successFunc    = WeaponMysteryBoxUseSuccess

        #if CLIENT
            settings.hint               = "#HINT_VAULT_UNLOCKING"
            settings.displayRui         = MYSTERY_BOX_DISPLAYRUI
            settings.displayRuiFunc     = MysteryBox_DisplayRui
        #endif // CLIENT

        thread ExtendedUse( weaponMysteryBox, playerUser, settings )
    }

    void function MysteryBoxUseSuccess( entity mysteryBox, entity player, ExtendedUseSettings settings )
    {
        CustomZombieMysteryBox mysteryBoxStruct = GetMysteryBox( mysteryBox )

        if ( !mysteryBoxStruct.isUsable )
            return
        
        if ( !PlayerHasEnoughScore( player, MYSTERY_BOX_COST ) )
            return

        mysteryBoxStruct.isUsable = false
        mysteryBoxStruct.isUsableWeapon = false
        mysteryBoxStruct.execThread = true

        RemoveScoreToPlayer( player, MYSTERY_BOX_COST )

        #if SERVER
            EmitSoundOnEntity( mysteryBox, SOUND_LOOT_BIN_OPEN )

            waitthread MysteryBox_PlayOpenSequence( mysteryBox, player )
            waitthread MysteryBox_Thread( mysteryBox, player )
            if ( mysteryBoxStruct.execThread ) thread DestroyWeaponByDeadline_Thread( player, mysteryBox )
        #endif
    }

    void function WeaponMysteryBoxUseSuccess( entity weaponMysteryBox, entity player, ExtendedUseSettings settings )
    {
        CustomZombieMysteryBox mysteryBoxStruct = GetMysteryBoxFromEnt( weaponMysteryBox )

        if ( !mysteryBoxStruct.isUsableWeapon )
            return
        
        #if SERVER
            ServerWeaponWallUseSuccess( weaponMysteryBox, player )

            mysteryBoxStruct.execThread = false
            thread DestroyWeaponByDeadline_Thread( player, mysteryBoxStruct.mysteryBoxEnt )
        #endif // SERVER
    }


#if CLIENT
    void function MysteryBox_DisplayRui( entity ent, entity player, var rui, ExtendedUseSettings settings )
    {
        RuiSetString( rui, "holdButtonHint", settings.holdHint )
        RuiSetString( rui, "hintText", settings.hint )
        RuiSetGameTime( rui, "startTime", Time() )
        RuiSetGameTime( rui, "endTime", Time() + settings.duration )
    }

    string function MysteryBox_TextOverride( entity mysteryBox )
    {
        if ( !GetMysteryBox( mysteryBox ).isUsable )
            return ""
        
        return USE + format( MYSTERY_BOX_USE, MYSTERY_BOX_COST )
    }

    string function WeaponMysteryBox_TextOverride( entity weaponMysteryBox )
    {
        if ( !GetMysteryBoxFromEnt( weaponMysteryBox ).isUsableWeapon )
            return ""
        
        int weaponIdx = GetWeaponIdx( weaponMysteryBox )
        string weaponName = eWeaponZombieName[ weaponIdx ][ 1 ]

        return USE + format( MYSTERY_BOX_TAKE_WEAPON, weaponName )
    }
#endif // CLIENT


#if SERVER
    void function MysteryBox_Thread( entity mysteryBox, entity player )
    {
        vector mysteryBoxOrigin = mysteryBox.GetOrigin()
        vector mysteryBoxAngles = mysteryBox.GetAngles()

        CustomZombieMysteryBox mysteryBoxStruct = GetMysteryBox( mysteryBox )

        entity weapon = mysteryBoxStruct.mysteryBoxWeapon
        entity script_mover = mysteryBoxStruct.mysteryBoxWeaponScriptMover

        weapon = CreateWeaponInMysteryBox( 0, mysteryBoxOrigin + MYSTERY_BOX_WEAPON_ORIGIN_OFFSET, mysteryBoxAngles + MYSTERY_BOX_WEAPON_ANGLES_OFFSET, mysteryBoxStruct.targetName )
        script_mover = CreateScriptMover( mysteryBoxOrigin + MYSTERY_BOX_WEAPON_ORIGIN_OFFSET, mysteryBoxAngles + MYSTERY_BOX_WEAPON_ANGLES_OFFSET )

        weapon.SetParent( script_mover )

        float currentTime = Time()
        float startTime = currentTime
        float endTime = startTime + MYSTERY_BOX_WEAPON_MOVE_TIME
        float waitVar = 0.01

        script_mover.NonPhysicsMoveTo( weapon.GetOrigin() + MYSTERY_BOX_WEAPON_MOVE_TO, MYSTERY_BOX_WEAPON_MOVE_TIME, 0, MYSTERY_BOX_WEAPON_MOVE_TIME )

        while ( endTime > currentTime )
        {
            weapon.SetModel( eWeaponZombieModel[ RandomIntRange( 0, eWeaponZombieIdx.len() - 1 ) ] )
            currentTime = Time()
            wait waitVar
        }

        MysteryBoxWeaponSetUsable( player, weapon, true )

        wait 3
    }

    void function DestroyWeaponByDeadline_Thread( entity player, entity mysteryBox )
    {
        CustomZombieMysteryBox mysteryBoxStruct = GetMysteryBox( mysteryBox )

        entity weapon = mysteryBoxStruct.mysteryBoxWeapon
        entity script_mover = mysteryBoxStruct.mysteryBoxWeaponScriptMover

        if ( IsValid( weapon ) ) weapon.Destroy()
        if ( IsValid( script_mover ) ) script_mover.Destroy()

            wait 0.2

        waitthread MysteryBox_PlayCloseSequence( mysteryBox )

            wait 0.1

        MysteryBoxSetUsable( player, mysteryBox, true )
    }

    void function SetMysteryBoxFx( entity mysteryBox )
    {
        GetMysteryBox( mysteryBox ).mysteryBoxFx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( MYSTERY_BOX_BEAM ), mysteryBox.GetOrigin(), < 90, 0, 0 > )
    }

    void function MysteryBoxSetUsable( entity player, entity mysteryBox, bool isUsable )
    {
        GetMysteryBox( mysteryBox ).isUsable = isUsable
        Remote_CallFunction_NonReplay( player, "ServerCallback_SetMysteryBoxUsable", mysteryBox, isUsable )
    }

    void function MysteryBoxWeaponSetUsable( entity player, entity weaponMysteryBox, bool isUsable )
    {
        GetMysteryBoxFromEnt( weaponMysteryBox ).isUsableWeapon = isUsable
        Remote_CallFunction_NonReplay( player, "ServerCallback_SetWeaponMysteryBoxUsable", weaponMysteryBox, isUsable )
    }

    entity function CreateMysteryBox( vector origin, vector angles )
    {
        entity mysteryBox = CreateEntity( "prop_dynamic" )
        mysteryBox.SetScriptName( MYSTERY_BOX_SCRIPT_NAME )
        mysteryBox.SetValueForModelKey( LOOT_BIN_MODEL )
        mysteryBox.SetOrigin( origin )
        mysteryBox.SetAngles( angles )
        mysteryBox.kv.solid = SOLID_VPHYSICS

        DispatchSpawn( mysteryBox )

        return mysteryBox
    }

    entity function CreateWeaponInMysteryBox( int index, vector pos, vector ang, string targetName )
    {
        entity weaponWall = CreateEntity( "prop_dynamic" )
        weaponWall.SetModel( eWeaponZombieModel[ index ] )
        weaponWall.SetModelScale( 1.2 )
        weaponWall.SetScriptName( MYSTERY_BOX_WEAPON_SCRIPT_NAME )
        weaponWall.NotSolid()
        weaponWall.SetFadeDistance( 20000 )
        weaponWall.SetOrigin( pos )
        weaponWall.SetAngles( ang )
        SetTargetName( weaponWall, targetName )

        DispatchSpawn( weaponWall )
        
        return weaponWall
    }

    void function MysteryBox_PlayOpenSequence( entity mysteryBox, entity player )
    {
        if ( !mysteryBox.e.hasBeenOpened )
        {
            mysteryBox.e.hasBeenOpened = true

            StopSoundOnEntity( mysteryBox, SOUND_LOOT_BIN_IDLE )
        }

        waitthread PlayAnim( mysteryBox, "loot_bin_01_open" )
    }

    void function MysteryBox_PlayCloseSequence( entity mysteryBox )
    {
        waitthread PlayAnim( mysteryBox, "loot_bin_01_close" )
    }
#endif // SERVER

#endif // SERVER || CLIENT
