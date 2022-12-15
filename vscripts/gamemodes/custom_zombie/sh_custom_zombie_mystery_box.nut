
#if SERVER || CLIENT
    untyped
#endif // SERVER || CLIENT

#if SERVER // Global
    global function CreateMysteryBox
#endif // SERVER

#if SERVER || CLIENT // Global
    global function ShZombieMysteryBox_Init

    global function GetMysteryBox
#endif // SERVER || CLIENT

#if CLIENT
    const asset MYSTERY_BOX_DISPLAYRUI = $"ui/extended_use_hint.rpak"
#endif // CLIENT

#if SERVER
    const asset MYSTERY_BOX_BEAM = $"P_ar_hot_zone_far"
#endif // SERVER

#if SERVER || CLIENT // Const
    const int    MYSTERY_BOX_COST            = 950
    const float  MYSTERY_BOX_ON_USE_DURATION = 0.0
    const string USE                         = "%use%"
    const string MYSTERY_BOX_USE             = "to open Mystery Box\nCost: %i $"
    const string MYSTERY_BOX_SCRIPT_NAME     = "MysteryBoxScriptName"
#endif // SERVER || CLIENT

global struct CustomZombieMysteryBox
{
    entity mysteryBoxFx
    entity mysteryBoxScriptMover
    bool isUsable = false
    array < entity > mysteryBoxArray
    table < entity, CustomZombieMysteryBox > mysteryBox
}
global CustomZombieMysteryBox customZombieMysteryBox


#if SERVER || CLIENT
    void function ShZombieMysteryBox_Init()
    {
        #if SERVER
            AddSpawnCallback( "prop_dynamic", UsableMysteryBox )
        #endif // SERVER

        #if CLIENT
            AddCreateCallback( "prop_dynamic", UsableMysteryBox )
        #endif // CLIENT
    }
#endif  // SERVER || CLIENT

#if SERVER || CLIENT
    void function UsableMysteryBox( entity usableMysteryBox )
    {
        if ( !IsValidusableMysteryBoxEnt( usableMysteryBox ) )
            return

        AddMysteryBox( usableMysteryBox )
        SetMysteryBoxUsable( usableMysteryBox )

        #if SERVER
            SetMysteryBoxFx( usableMysteryBox )
        #endif // SERVER
    }

    CustomZombieMysteryBox function AddMysteryBox( entity usableMysteryBox )
    {
        CustomZombieMysteryBox newMysteryBox

        customZombieMysteryBox.mysteryBox[ usableMysteryBox ] <- newMysteryBox
        customZombieMysteryBox.mysteryBoxArray.append( usableMysteryBox )

        return customZombieMysteryBox.mysteryBox[ usableMysteryBox ]
    }

    CustomZombieMysteryBox function GetMysteryBox( entity usableMysteryBox )
    {
        return customZombieMysteryBox.mysteryBox[ usableMysteryBox ]
    }

    bool function IsValidusableMysteryBoxEnt( entity ent )
    {
        if ( ent.GetScriptName() == MYSTERY_BOX_SCRIPT_NAME )
            return true

        return false
    }

    bool function UsableMysteryBox_CanUse( entity player, entity usableMysteryBox )
    {
        if ( !SURVIVAL_PlayerCanUse_AnimatedInteraction( player, usableMysteryBox ) )
            return false

        return true
    }

    void function SetMysteryBoxUsable( entity usableMysteryBox )
    {
        #if SERVER
            usableMysteryBox.SetUsable()
            usableMysteryBox.SetUsableByGroup( "pilot" )
            usableMysteryBox.SetUsableValue( USABLE_BY_ALL | USABLE_CUSTOM_HINTS )
            usableMysteryBox.SetUsablePriority( USABLE_PRIORITY_MEDIUM )
        #endif // SERVER

        GetMysteryBox( usableMysteryBox ).isUsable = true

        SetCallback_CanUseEntityCallback( usableMysteryBox, UsableMysteryBox_CanUse )
        AddCallback_OnUseEntity( usableMysteryBox, OnUseProcessingMysteryBox )

        #if CLIENT
            AddEntityCallback_GetUseEntOverrideText( usableMysteryBox, MysteryBox_TextOverride )
        #endif // CLIENT
    }

    void function OnUseProcessingMysteryBox( entity usableMysteryBox, entity playerUser, int useInputFlags )
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

        thread ExtendedUse( usableMysteryBox, playerUser, settings )
    }

    void function MysteryBoxUseSuccess( entity usableMysteryBox, entity player, ExtendedUseSettings settings )
    {
        if ( !GetMysteryBox( usableMysteryBox ).isUsable )
            return
        
        if ( !PlayerHasEnoughScore( player, MYSTERY_BOX_COST ) )
            return

        GetMysteryBox( usableMysteryBox ).isUsable = false
        #if SERVER
            EmitSoundOnEntity( usableMysteryBox, SOUND_LOOT_BIN_OPEN )

            RemoveScoreToPlayer( player, MYSTERY_BOX_COST )

            waitthread MysteryBox_PlayOpenSequence( usableMysteryBox, player )
            waitthread MysteryBox_Thread( usableMysteryBox, player )
            waitthread MysteryBox_PlayCloseSequence( usableMysteryBox )
            GetMysteryBox( usableMysteryBox ).isUsable = true
            Remote_CallFunction_NonReplay( player, "ServerCallback_SetMysteryBoxUsable", usableMysteryBox, true )
        #endif
    }
#endif // SERVER || CLIENT


#if CLIENT
    void function MysteryBox_DisplayRui( entity ent, entity player, var rui, ExtendedUseSettings settings )
    {
        RuiSetString( rui, "holdButtonHint", settings.holdHint )
        RuiSetString( rui, "hintText", settings.hint )
        RuiSetGameTime( rui, "startTime", Time() )
        RuiSetGameTime( rui, "endTime", Time() + settings.duration )
    }

    string function MysteryBox_TextOverride( entity usableMysteryBox )
    {
        if ( !GetMysteryBox( usableMysteryBox ).isUsable )
            return ""
        
        return USE + " " + format( MYSTERY_BOX_USE, MYSTERY_BOX_COST )
    }
#endif // CLIENT


#if SERVER
    void function SetMysteryBoxFx( entity usableMysteryBox )
    {
        PrecacheParticleSystem( MYSTERY_BOX_BEAM )
        GetMysteryBox( usableMysteryBox ).mysteryBoxFx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( MYSTERY_BOX_BEAM ), usableMysteryBox.GetOrigin(), < 90, 0, 0 > )
    }

    void function MysteryBox_Thread( entity usableMysteryBox, entity player )
    {
        entity weapon = CreateWeaponWall( 0, usableMysteryBox.GetOrigin() + < 0, 0, 20 >, usableMysteryBox.GetAngles() + < 0, 90, 0 >, false )
        entity script_mover = CreateScriptMover( usableMysteryBox.GetOrigin() + < 0, 0, 10 >, usableMysteryBox.GetAngles() )
        weapon.SetParent( script_mover )
        weapon.SetModelScale( 1.2 )

        float currentTime = Time()
        float startTime = currentTime
        float endTime = startTime + 5

        script_mover.NonPhysicsMoveTo( usableMysteryBox.GetOrigin() + < 0, 0, 45 >, 3, 0, 3 )

        while ( endTime > currentTime )
        {
            weapon.SetModel( eWeaponZombieModel[ RandomIntRange( 0, eWeaponZombieIdx.len() - 1 ) ] )
            wait 0.1
            currentTime = Time()
        }

        wait 3
        weapon.Destroy()
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
#endif
