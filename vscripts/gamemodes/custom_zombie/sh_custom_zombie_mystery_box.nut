
#if SERVER || CLIENT
    untyped
#endif // SERVER || CLIENT

#if SERVER // Global
    global function CreateMysteryBox
#endif // SERVER

#if SERVER || CLIENT // Global
    global function ShZombieMysteryBox_Init
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

struct
{
    entity mysteryBox
    entity mysteryBoxFx
    entity mysteryBoxScriptMover
    bool isUsable = false
}
mysteryBoxStruct

#if SERVER || CLIENT
    void function ShZombieMysteryBox_Init()
    {
        #if SERVER
            AddSpawnCallback( "prop_dynamic", usableMysteryBox )
        #endif // SERVER

        #if CLIENT
            AddCreateCallback( "prop_dynamic", usableMysteryBox )
        #endif // CLIENT
    }
#endif  // SERVER || CLIENT

#if SERVER || CLIENT
    void function usableMysteryBox( entity usableMysteryBox )
    {
        if ( !IsValidusableMysteryBoxEnt( usableMysteryBox ) )
            return

        SetMysteryBoxUsable( usableMysteryBox )

        #if SERVER
            SetMysteryBoxFx( usableMysteryBox )
        #endif // SERVER
    }

    bool function IsValidusableMysteryBoxEnt( entity ent )
    {
        if ( ent.GetScriptName() == MYSTERY_BOX_SCRIPT_NAME )
            return true

        return false
    }

    bool function usableMysteryBox_CanUse( entity player, entity usableMysteryBox )
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
            mysteryBoxStruct.isUsable = true
        #endif // SERVER

        SetCallback_CanUseEntityCallback( usableMysteryBox, usableMysteryBox_CanUse )
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
        #if SERVER
            if ( !PlayerHasEnoughScore( player, MYSTERY_BOX_COST ) )
                return

	        EmitSoundOnEntity( usableMysteryBox, SOUND_LOOT_BIN_OPEN )

            RemoveScoreToPlayer( player, MYSTERY_BOX_COST )

            waitthread MysteryBox_PlayOpenSequence( usableMysteryBox, player )
            thread MysteryBox_Thread( usableMysteryBox, player )
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
        if ( !mysteryBoxStruct.isUsable )
            return ""

        return USE + " " + format( MYSTERY_BOX_USE, MYSTERY_BOX_COST )
    }
#endif // CLIENT


#if SERVER
    void function SetMysteryBoxFx( entity usableMysteryBox )
    {
        PrecacheParticleSystem( MYSTERY_BOX_BEAM )
        mysteryBoxStruct.mysteryBoxFx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( MYSTERY_BOX_BEAM ), usableMysteryBox.GetOrigin(), < 90, 0, 0 > )
    }

    void function MysteryBox_Thread( entity usableMysteryBox, entity player )
    {
        mysteryBoxStruct.isUsable = false
        usableMysteryBox.SetParent( mysteryBoxStruct.mysteryBoxScriptMover )
        usableMysteryBox.UnsetUsable()
        mysteryBoxStruct.mysteryBoxScriptMover.NonPhysicsMoveTo( usableMysteryBox.GetOrigin() + < 0, 0, 1000 >, 20, 10, 10)
        wait 20
        usableMysteryBox.ClearParent()
        usableMysteryBox.SetUsable()
        mysteryBoxStruct.isUsable = true
    }

    void function ServerMysteryBoxUseSuccess( entity usableMysteryBox, entity player )
    {

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

        // Script Mover
        entity scriptMover = CreateScriptMover( origin, angles )
        mysteryBoxStruct.mysteryBoxScriptMover = scriptMover

	    return mysteryBox
    }

    void function MysteryBox_PlayOpenSequence( entity mysteryBox, entity player )
    {
        GradeFlagsSet( mysteryBox, eGradeFlags.IS_BUSY )

        if ( !mysteryBox.e.hasBeenOpened )
        {
        	mysteryBox.e.hasBeenOpened = true

        	StopSoundOnEntity( mysteryBox, SOUND_LOOT_BIN_IDLE )
        }

        GradeFlagsSet( mysteryBox, eGradeFlags.IS_OPEN )

	    waitthread PlayAnim( mysteryBox, "loot_bin_01_open" )

	    GradeFlagsClear( mysteryBox, eGradeFlags.IS_BUSY )
    }
#endif
