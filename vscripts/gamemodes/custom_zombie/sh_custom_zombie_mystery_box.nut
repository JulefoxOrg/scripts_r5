
#if SERVER || CLIENT
    untyped
#endif // SERVER || CLIENT

/* #if SERVER // Global
    global function CreateMysteryBox
#endif // SERVER

#if SERVER || CLIENT // Global
    global function ShZombieMysteryBox_Init
#endif // SERVER || CLIENT

#if CLIENT
    const asset MYSTERY_BOX_DISPLAYRUI = $"ui/extended_use_hint.rpak"
#endif // CLIENT

#if SERVER || CLIENT // Const
    const float  WEAPON_WALL_ON_USE_DURATION = 0.0
    const string USE                         = "%use%"
    const string WEAPON_WALL_BUY_WEAPON      = "to buy %s"
    const string WEAPON_WALL_BUY_AMMO        = "to buy ammo for %s"
    const string MYSTERY_BOX_SCRIPT_NAME     = "MysteryBoxScriptName"
#endif // SERVER || CLIENT

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
        settings.duration       = WEAPON_WALL_ON_USE_DURATION
        settings.useInputFlag   = IN_USE_LONG
        settings.successFunc    = MysteryBoxUseSuccess

        #if CLIENT
            settings.hint               = "#HINT_VAULT_UNLOCKING"
            settings.displayRui         = WEAPON_WALL_DISPLAYRUI
            settings.displayRuiFunc     = MysteryBox_DisplayRui
        #endif // CLIENT

        thread ExtendedUse( usableMysteryBox, playerUser, settings )
    }

    void function MysteryBoxUseSuccess( entity usableMysteryBox, entity player, ExtendedUseSettings settings )
    {
    
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
    	return ""
    }
#endif // CLIENT


#if SERVER
    void function ServerMysteryBoxUseSuccess( entity usableMysteryBox, entity player )
    {

    }

    entity function CreateMysteryBox( vector origin, vector angles )
    {
	    entity lootbin = CreateEntity( "prop_dynamic" )
	    lootbin.SetScriptName( MYSTERY_BOX_SCRIPT_NAME )
	    lootbin.SetValueForModelKey( LOOT_BIN_MODEL )
	    lootbin.SetOrigin( origin )
	    lootbin.SetAngles( angles )
	    lootbin.kv.solid = SOLID_VPHYSICS

	    DispatchSpawn( lootbin )

	    return lootbin
    }
#endif */
