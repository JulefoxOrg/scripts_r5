
#if SERVER || CLIENT
    untyped
#endif // SERVER || CLIENT

#if SERVER // Global
    global function CreateWeaponWall
#endif // SERVER

#if SERVER || CLIENT // Global
    global function ShZombieWeaponWall_Init
#endif // SERVER || CLIENT

#if CLIENT
    const asset WEAPON_WALL_DISPLAYRUI = $"ui/extended_use_hint.rpak"
#endif // CLIENT

#if SERVER || CLIENT // Const
    const float  WEAPON_WALL_ON_USE_DURATION = 0.0
    const string WEAPON_WALL_BUY_WEAPON      = "to buy %s"
    const string WEAPON_WALL_BUY_AMMO        = "to buy ammo for %s"
    const string WEAPON_WALL_SCRIPT_NAME     = "WeaponWallScriptName"
#endif // SERVER || CLIENT

#if SERVER || CLIENT // Const
    global enum eWeaponZombieInt
    {
        
    }

    enum eWeaponZombieModel
    {
        
    }

    enum eWeaponZombieName
    {
        
    }
#endif // SERVER || CLIENT


#if SERVER || CLIENT
    void function ShZombieWeaponWall_Init()
    {
        #if SERVER
            AddSpawnCallback( "prop_dynamic", usableWeaponWall )
        #endif // SERVER

        #if CLIENT
            AddCreateCallback( "prop_dynamic", usableWeaponWall )
        #endif // CLIENT
    }
#endif  // SERVER || CLIENT

#if SERVER || CLIENT
    void function usableWeaponWall( entity usableWeaponWall )
    {
        if ( !IsValidusableWeaponWallEnt( usableWeaponWall ) )
            return

        SetWeaponWallUsable( usableWeaponWall )
    }

    bool function IsValidusableWeaponWallEnt( entity ent )
    {
        if ( ent.GetScriptName() == WEAPON_WALL_SCRIPT_NAME )
            return true

        return false
    }

    bool function usableWeaponWall_CanUse( entity player, entity usableWeaponWall )
    {
        if ( !SURVIVAL_PlayerCanUse_AnimatedInteraction( player, usableWeaponWall ) )
            return false

        return true
    }

    void function SetWeaponWallUsable( entity usableWeaponWall )
    {
        #if SERVER
            usableWeaponWall.SetUsable()
            usableWeaponWall.SetUsableByGroup( "pilot" )
            usableWeaponWall.AddUsableValue( 60 )
            usableWeaponWall.SetUsableValue( USABLE_BY_ALL | USABLE_CUSTOM_HINTS )
            usableWeaponWall.SetUsablePriority( USABLE_PRIORITY_HIGH )
        #endif // SERVER

        SetCallback_CanUseEntityCallback( usableWeaponWall, usableWeaponWall_CanUse )
        AddCallback_OnUseEntity( usableWeaponWall, OnUseProcessingWeaponWall )

        #if CLIENT
	        AddEntityCallback_GetUseEntOverrideText( usableWeaponWall, WeaponWall_TextOverride )
	    #endif // CLIENT
    }

    void function OnUseProcessingWeaponWall( entity usableWeaponWall, entity playerUser, int useInputFlags )
    {	
        if ( !( useInputFlags & USE_INPUT_LONG ) )
            return

        ExtendedUseSettings settings
        settings.duration       = WEAPON_WALL_ON_USE_DURATION
        settings.useInputFlag   = IN_USE_LONG
        settings.successFunc    = WeaponWallUseSuccess

        #if CLIENT
            settings.hint               = "#HINT_VAULT_UNLOCKING"
            settings.displayRui         = WEAPON_WALL_DISPLAYRUI
            settings.displayRuiFunc     = WeaponWall_DisplayRui
        #endif // CLIENT

        thread ExtendedUse( usableWeaponWall, playerUser, settings )
    }

    string function GetWeaponName( entity usableWeaponWall )
    {
        string weaponName

        switch ( usableWeaponWall.GetModelName() )
        {
            case "mdl/weapons/rspn101/w_rspn101.rmdl":
                weaponName = "mp_weapon_rspn101"
                break
            case "mdl/weapons/vinson/w_vinson.rmdl":
                weaponName = "mp_weapon_vinson"
                break
            case "mdl/weapons/mastiff_stgn/w_mastiff.rmdl":
                weaponName = "mp_weapon_mastiff"
                break
            case "mdl/weapons/b3wing/w_b3wing.rmdl":
                weaponName = "mp_weapon_wingman"
                break
            case "mdl/weapons/p2011_auto/w_p2011_auto.rmdl":
                weaponName = "mp_weapon_autopistol"
                break
            default:
                weaponName = ""
            break
        }

        return weaponName
    }

    void function WeaponWallUseSuccess( entity usableWeaponWall, entity player, ExtendedUseSettings settings )
    {
        #if SERVER
            thread ServerWeaponWallUseSuccess( usableWeaponWall, player )
        #endif // SERVER
    }
#endif // SERVER || CLIENT


#if CLIENT
    void function WeaponWall_DisplayRui( entity ent, entity player, var rui, ExtendedUseSettings settings )
    {
        RuiSetString( rui, "holdButtonHint", settings.holdHint )
        RuiSetString( rui, "hintText", settings.hint )
        RuiSetGameTime( rui, "startTime", Time() )
        RuiSetGameTime( rui, "endTime", Time() + settings.duration )
    }

    string function WeaponWall_TextOverride( entity usableWeaponWall )
    {
        string weaponName = GetWeaponName( usableWeaponWall )
    	if ( PlayerHasWeapon( GetLocalViewPlayer(), weaponName ) )
    		return "%use% " + format( WEAPON_WALL_BUY_AMMO, weaponName )
    	return "%use% " + format( WEAPON_WALL_BUY_WEAPON, weaponName )
    }
#endif // CLIENT


#if SERVER
    void function ServerWeaponWallUseSuccess( entity usableWeaponWall, entity player )
    {
        entity weapon ; string weaponName = GetWeaponName( usableWeaponWall )

        if ( PlayerHasWeapon( player, weaponName ) || weaponName == "" ) return

        entity primary = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_0 )
        entity secondary = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_1 )
        int activeWeaponInt = SURVIVAL_GetActiveWeaponSlot( player )
        entity activeWeapon = player.GetNormalWeapon( activeWeaponInt )

        if  ( primary == null )
        {
            weapon = player.GiveWeapon( weaponName, WEAPON_INVENTORY_SLOT_PRIMARY_0 )
        } 
        else if ( secondary == null )
        {
            weapon = player.GiveWeapon( weaponName, WEAPON_INVENTORY_SLOT_PRIMARY_1 )
        }
        else if ( IsValid( activeWeapon ) )
        {
            player.TakeWeaponByEntNow( activeWeapon )
            weapon = player.GiveWeapon( weaponName, activeWeaponInt )
        }
        else printt( "void" )

        if (weapon != null ) weapon.AddMod( "survival_finite_ammo" )

        if ( PlayerHasWeapon( player, weaponName ) ) player.SetActiveWeaponByName( eActiveInventorySlot.mainHand, weaponName )
    }

    entity function CreateWeaponWall( asset mdl, vector pos, vector ang )
    {
        entity weaponWall = CreateEntity( "prop_dynamic" )
        weaponWall.SetModel( mdl )
        weaponWall.SetScriptName( WEAPON_WALL_SCRIPT_NAME )
        weaponWall.NotSolid()
        weaponWall.SetFadeDistance( 20000 )
        weaponWall.SetOrigin( pos )
        weaponWall.SetAngles( ang )

        int contextId = 0
		weaponWall.Highlight_SetFunctions( contextId, 0, true, HIGHLIGHT_OUTLINE_INTERACT_BUTTON, 1, 0, false )
		weaponWall.Highlight_SetParam( contextId, 0, HIGHLIGHT_COLOR_INTERACT )
		weaponWall.Highlight_SetCurrentContext( contextId )
		weaponWall.Highlight_ShowInside( 0.0 )
		weaponWall.Highlight_ShowOutline( 0.0 )

        DispatchSpawn( weaponWall )
        
        return weaponWall
    }
#endif
