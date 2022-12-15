
#if SERVER || CLIENT
    untyped
#endif // SERVER || CLIENT

#if SERVER // Global
    global function CreateWeaponWall
    global function GiveWeaponToPlayer
    global function ServerWeaponWallUseSuccess
#endif // SERVER

#if SERVER || CLIENT // Global
    global function ShZombieWeaponWall_Init

    global function GetWeaponIdx
#endif // SERVER || CLIENT

#if CLIENT
    const asset WEAPON_WALL_DISPLAYRUI = $"ui/extended_use_hint.rpak"
#endif // CLIENT

#if SERVER || CLIENT // Const
    const float  WEAPON_WALL_ON_USE_DURATION = 0.0
    const string USE                         = "Press %use% "
    const string WEAPON_WALL_BUY_WEAPON      = "to buy %s\nCost: %i $"
    const string WEAPON_WALL_BUY_AMMO        = "to buy ammo for %s\nCost: %i $"
    const string WEAPON_WALL_NO_SCORE_WEAPON = "Not enough score to buy %s\nCost: %i $"
    const string WEAPON_WALL_NO_SCORE_AMMO   = "Not enough score to buy %s ammo\nCost: %i $"
    const string WEAPON_WALL_SCRIPT_NAME     = "WeaponWallScriptName"
#endif // SERVER || CLIENT

#if SERVER || CLIENT
    global enum eWeaponZombieIdx
    {
        // Assault Rifles
        FLATLINE,
        SCOUT,
        HAVOC,
        HEMLOK,
        R101,

        // SMGs
        ALTERNATOR,
        PROWLER,
        R97,
        VOLT,

        //LMGs
        DEVOTION,
        LSTAR,
        SPITFIRE,

        // Snipers
        CHARGE,
        KRABER,
        DMR,
        TRIPLETAKE,
        SENTINEL,

        // Shotguns
        EVA,
        MASTIFF,
        MOZAMBIQUE,
        PEACEKEEPER,

        // Pistols
        P2020,
        RE45,
        WINGMAN,

        // Grenades
        ARCSTAR,
        FRAG,
        THERMITE,

        COUNT
    }

    global table< int, asset > eWeaponZombieModel =
    {
        [ eWeaponZombieIdx.FLATLINE ] = $"mdl/weapons/vinson/w_vinson.rmdl",
        [ eWeaponZombieIdx.SCOUT ] = $"mdl/weapons/g2/w_g2a4.rmdl",
        [ eWeaponZombieIdx.HAVOC ] = $"mdl/weapons/beam_ar/w_beam_ar.rmdl",
        [ eWeaponZombieIdx.HEMLOK ] = $"mdl/weapons/m1a1_hemlok/w_hemlok.rmdl",
        [ eWeaponZombieIdx.R101 ] = $"mdl/weapons/rspn101/w_rspn101.rmdl",
        [ eWeaponZombieIdx.ALTERNATOR ] = $"mdl/weapons/alternator_smg/w_alternator_smg.rmdl",
        [ eWeaponZombieIdx.PROWLER ] = $"mdl/weapons/prowler_smg/w_prowler_smg.rmdl",
        [ eWeaponZombieIdx.R97 ] = $"mdl/weapons/r97/w_r97.rmdl",
        [ eWeaponZombieIdx.VOLT ] = $"mdl/weapons/hemlok_smg/w_hemlok_smg.rmdl",
        [ eWeaponZombieIdx.DEVOTION ] = $"mdl/weapons/hemlock_br/w_hemlock_br.rmdl",
        [ eWeaponZombieIdx.LSTAR ] = $"mdl/weapons/lstar/w_lstar.rmdl",
        [ eWeaponZombieIdx.SPITFIRE ] = $"mdl/weapons/lmg_hemlok/w_lmg_hemlok.rmdl",
        [ eWeaponZombieIdx.CHARGE ] = $"mdl/weapons/defender/w_defender.rmdl",
        [ eWeaponZombieIdx.KRABER ] = $"mdl/weapons/at_rifle/w_at_rifle.rmdl",
        [ eWeaponZombieIdx.DMR ] = $"mdl/weapons/rspn101_dmr/w_rspn101_dmr.rmdl",
        [ eWeaponZombieIdx.TRIPLETAKE ] = $"mdl/weapons/doubletake/w_doubletake.rmdl",
        [ eWeaponZombieIdx.SENTINEL ] = $"mdl/Weapons/sentinel/w_sentinel.rmdl",
        [ eWeaponZombieIdx.EVA ] = $"mdl/weapons/w1128/w_w1128.rmdl",
        [ eWeaponZombieIdx.MASTIFF ] = $"mdl/weapons/mastiff_stgn/w_mastiff.rmdl",
        [ eWeaponZombieIdx.MOZAMBIQUE ] = $"mdl/weapons/pstl_sa3/w_pstl_sa3.rmdl",
        [ eWeaponZombieIdx.PEACEKEEPER ] = $"mdl/weapons/peacekeeper/w_peacekeeper.rmdl",
        [ eWeaponZombieIdx.P2020 ] = $"mdl/weapons/p2011/w_p2011.rmdl",
        [ eWeaponZombieIdx.RE45 ] = $"mdl/weapons/p2011_auto/w_p2011_auto.rmdl",
        [ eWeaponZombieIdx.WINGMAN ] = $"mdl/weapons/b3wing/w_b3wing.rmdl",
        [ eWeaponZombieIdx.ARCSTAR ] = $"mdl/weapons_r5/loot/w_loot_wep_iso_shuriken.rmdl",
        [ eWeaponZombieIdx.FRAG ] = $"mdl/weapons/grenades/w_loot_m20_f_grenade_projectile.rmdl",
        [ eWeaponZombieIdx.THERMITE ] = $"mdl/weapons/grenades/w_thermite_grenade.rmdl"
    }

    global table< int, array< string > > eWeaponZombieName =
    {
        [ eWeaponZombieIdx.FLATLINE ] = [ "mp_weapon_vinson", "Flatline" ],
        [ eWeaponZombieIdx.SCOUT ] = [ "mp_weapon_g2", "G7 Scout" ],
        [ eWeaponZombieIdx.HAVOC ] = [ "mp_weapon_energy_ar", "Havoc" ],
        [ eWeaponZombieIdx.HEMLOK ] = [ "mp_weapon_hemlok", "Hemlok" ],
        [ eWeaponZombieIdx.R101 ] = [ "mp_weapon_rspn101", "R-301" ],
        [ eWeaponZombieIdx.ALTERNATOR ] = [ "mp_weapon_alternator_smg", "Alternator" ],
        [ eWeaponZombieIdx.PROWLER ] = [ "mp_weapon_pdw", "Prowler" ],
        [ eWeaponZombieIdx.R97 ] = [ "mp_weapon_r97", "R-99" ],
        [ eWeaponZombieIdx.VOLT ] = [ "mp_weapon_volt_smg", "Volt" ],
        [ eWeaponZombieIdx.DEVOTION ] = [ "mp_weapon_esaw", "Devotion" ],
        [ eWeaponZombieIdx.LSTAR ] = [ "mp_weapon_lstar", "L-Star" ],
        [ eWeaponZombieIdx.SPITFIRE ] = [ "mp_weapon_lmg", "Spitfire" ],
        [ eWeaponZombieIdx.CHARGE ] = [ "mp_weapon_defender", "Charge Rifle" ],
        [ eWeaponZombieIdx.KRABER ] = [ "mp_weapon_sniper", "Kraber" ],
        [ eWeaponZombieIdx.DMR ] = [ "mp_weapon_dmr", "Longbow" ],
        [ eWeaponZombieIdx.TRIPLETAKE ] = [ "mp_weapon_doubletake", "Triple Take" ],
        [ eWeaponZombieIdx.SENTINEL ] = [ "mp_weapon_sentinel", "Sentinel" ],
        [ eWeaponZombieIdx.EVA ] = [ "mp_weapon_shotgun", "EVA-8" ],
        [ eWeaponZombieIdx.MASTIFF ] = [ "mp_weapon_mastiff", "Mastiff" ],
        [ eWeaponZombieIdx.MOZAMBIQUE ] = [ "mp_weapon_shotgun_pistol", "Mozambique" ],
        [ eWeaponZombieIdx.PEACEKEEPER ] = [ "mp_weapon_energy_shotgun", "Peacekeeper" ],
        [ eWeaponZombieIdx.P2020 ] = [ "mp_weapon_semipistol", "P2020" ],
        [ eWeaponZombieIdx.RE45 ] = [ "mp_weapon_autopistol", "RE-45" ],
        [ eWeaponZombieIdx.WINGMAN ] = [ "mp_weapon_wingman", "Wingman" ],
        [ eWeaponZombieIdx.ARCSTAR ] = [ "mp_weapon_grenade_emp", "Arc Star" ],
        [ eWeaponZombieIdx.FRAG ] = [ "mp_weapon_frag_grenade", "Frag Grenade" ],
        [ eWeaponZombieIdx.THERMITE ] = [ "mp_weapon_thermite_grenade", "Thermite Grenade" ]
    }

    global table< int, array< int > > eWeaponZombiePrice =
    {
        [ eWeaponZombieIdx.FLATLINE ] = [ 1250, 500 ],
        [ eWeaponZombieIdx.SCOUT ] = [ 750, 200 ],
        [ eWeaponZombieIdx.HAVOC ] = [ 750, 200 ],
        [ eWeaponZombieIdx.HEMLOK ] = [ 750, 200 ],
        [ eWeaponZombieIdx.R101 ] = [ 1250, 500 ],
        [ eWeaponZombieIdx.ALTERNATOR ] = [ 2000, 500 ],
        [ eWeaponZombieIdx.PROWLER ] = [ 500, 150 ],
        [ eWeaponZombieIdx.R97 ] = [ 750, 200 ],
        [ eWeaponZombieIdx.VOLT ] = [ 750, 200 ],
        [ eWeaponZombieIdx.DEVOTION ] = [ 750, 200 ],
        [ eWeaponZombieIdx.LSTAR ] = [ 750, 200 ],
        [ eWeaponZombieIdx.SPITFIRE ] = [ 1250, 200 ],
        [ eWeaponZombieIdx.CHARGE ] = [ 500, 150 ],
        [ eWeaponZombieIdx.KRABER ] = [ 750, 200 ],
        [ eWeaponZombieIdx.DMR ] = [ 750, 200 ],
        [ eWeaponZombieIdx.TRIPLETAKE ] = [ 500, 150 ],
        [ eWeaponZombieIdx.SENTINEL ] = [ 500, 150 ],
        [ eWeaponZombieIdx.EVA ] = [ 750, 200 ],
        [ eWeaponZombieIdx.MASTIFF ] = [ 750, 200 ],
        [ eWeaponZombieIdx.MOZAMBIQUE ] = [ 100, 50 ],
        [ eWeaponZombieIdx.PEACEKEEPER ] = [ 750, 200 ],
        [ eWeaponZombieIdx.P2020 ] = [ 100, 50 ],
        [ eWeaponZombieIdx.RE45 ] = [ 250, 100 ],
        [ eWeaponZombieIdx.WINGMAN ] = [ 750, 200 ],
        [ eWeaponZombieIdx.ARCSTAR ] = [ 200, 0 ],
        [ eWeaponZombieIdx.FRAG ] = [ 200, 0 ],
        [ eWeaponZombieIdx.THERMITE ] = [ 200, 0 ]
    }
#endif // SERVER || CLIENT


#if SERVER || CLIENT
    void function ShZombieWeaponWall_Init()
    {
        #if SERVER
            AddSpawnCallback( "prop_dynamic", UsableWeaponWall )
        #endif // SERVER

        #if CLIENT
            AddCreateCallback( "prop_dynamic", UsableWeaponWall )
        #endif // CLIENT
    }
#endif  // SERVER || CLIENT

#if SERVER || CLIENT
    void function UsableWeaponWall( entity usableWeaponWall )
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

    bool function UsableWeaponWall_CanUse( entity player, entity usableWeaponWall )
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
            usableWeaponWall.SetUsableValue( USABLE_BY_ALL | USABLE_CUSTOM_HINTS )
            usableWeaponWall.SetUsablePriority( USABLE_PRIORITY_MEDIUM )
        #endif // SERVER

        SetCallback_CanUseEntityCallback( usableWeaponWall, UsableWeaponWall_CanUse )
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

    int function GetWeaponIdx( entity usableWeaponWall )
    {
        int weaponIdx ; asset modelName = usableWeaponWall.GetModelName()

        for ( int i = 0 ; i < eWeaponZombieModel.len() ; i++  )
        {
            if ( modelName == eWeaponZombieModel[ i ] )
                weaponIdx = i
        }

        return weaponIdx
    }

    void function WeaponWallUseSuccess( entity usableWeaponWall, entity player, ExtendedUseSettings settings )
    {
        int weaponIdx = GetWeaponIdx( usableWeaponWall )
        string weaponName = eWeaponZombieName[ weaponIdx ][ 0 ]


        if ( PlayerHasWeapon( player, weaponName ) )
        {
            if ( !PlayerHasEnoughScore( player, eWeaponZombiePrice[ weaponIdx ][ 1 ] ) )
                return

            entity weapon = player.GetNormalWeapon( SURVIVAL_GetActiveWeaponSlot( player ) )

            weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )

            RemoveScoreToPlayer( player, eWeaponZombiePrice[ weaponIdx ][ 1 ] )
            
            //SURVIVAL_AddToPlayerInventory( player, "bullet", 60 )

            //Survival_PickupItem( weapon, player )
        }
        else
        {
            if ( !PlayerHasEnoughScore( player, eWeaponZombiePrice[ weaponIdx ][ 0 ] ) )
                return

            RemoveScoreToPlayer( player, eWeaponZombiePrice[ weaponIdx ][ 0 ] )
        
            #if SERVER
                ServerWeaponWallUseSuccess( usableWeaponWall, player )
            #endif // SERVER

            //Survival_PickupItem( weapon, player )
        }
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
        int weaponIdx = GetWeaponIdx( usableWeaponWall )
        int weaponPrice = eWeaponZombiePrice[ weaponIdx ][ 0 ]
        int weaponPriceAmmo = eWeaponZombiePrice[ weaponIdx ][ 1 ]
        string weaponNameScript = eWeaponZombieName[ weaponIdx ][ 0 ]
        string weaponName = eWeaponZombieName[ weaponIdx ][ 1 ]

        if ( PlayerHasWeapon( GetLocalViewPlayer(), weaponNameScript ) )
        {
            //if ( !PlayerHasEnoughScore( GetLocalViewPlayer(), weaponPriceAmmo ) )
            //    return format( WEAPON_WALL_NO_SCORE_AMMO, weaponName, weaponPriceAmmo )

            return USE + format( WEAPON_WALL_BUY_AMMO, weaponName, weaponPriceAmmo )
        }

        //if ( !PlayerHasEnoughScore( GetLocalViewPlayer(), weaponPrice ) )
        //    return format( WEAPON_WALL_NO_SCORE_WEAPON, weaponName, weaponPrice )

        return USE + format( WEAPON_WALL_BUY_WEAPON, weaponName, weaponPrice )
    }
#endif // CLIENT


#if SERVER
    void function ServerWeaponWallUseSuccess( entity usableWeaponWall, entity player )
    {
        entity weapon ; int weaponIdx = GetWeaponIdx( usableWeaponWall ) ; string weaponName = eWeaponZombieName[ weaponIdx ][ 0 ]

        if ( PlayerHasWeapon( player, weaponName ) )
        {
            
        }
        else
        {
            entity primary = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_0 )
            entity secondary = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_1 )
            int activeWeaponInt = SURVIVAL_GetActiveWeaponSlot( player )
            entity activeWeapon = player.GetNormalWeapon( activeWeaponInt )

            if  ( primary == null ) weapon = GiveWeaponToPlayer( player, weaponName, WEAPON_INVENTORY_SLOT_PRIMARY_0 )
            else if ( secondary == null ) weapon = GiveWeaponToPlayer( player, weaponName, WEAPON_INVENTORY_SLOT_PRIMARY_1 )
            else if ( IsValid( activeWeapon ) ) weapon = SwapWeaponToPlayer( player, activeWeapon, weaponName, activeWeaponInt )
            else printt( "void" )

            if ( weapon != null ) weapon.AddMod( "survival_finite_ammo" )

            if ( PlayerHasWeapon( player, weaponName ) ) player.SetActiveWeaponByName( eActiveInventorySlot.mainHand, weaponName )
        }
    }

    entity function GiveWeaponToPlayer( entity player, string weaponName, int inventorySlot )
    {
        entity weapon

        if ( weaponName == "mp_weapon_grenade_emp" || weaponName == "mp_weapon_frag_grenade" || weaponName == "mp_weapon_thermite_grenade" )
        {
            SURVIVAL_AddToPlayerInventory( player, weaponName, 1, false )

            weapon = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_ANTI_TITAN )

            printt(weapon)

            //if ( IsValid( weapon ) )
		    //{
                weapon = player.SetActiveWeaponByName( eActiveInventorySlot.mainHand, weaponName )
            //}

        }
        else weapon = player.GiveWeapon( weaponName, inventorySlot )

        return weapon
    }

    entity function SwapWeaponToPlayer( entity player, entity weaponSwap, string weaponName, int inventorySlot )
    {
        entity weapon

        if ( weaponName == "mp_weapon_grenade_emp" || weaponName == "mp_weapon_frag_grenade" || weaponName == "mp_weapon_thermite_grenade" )
        {
            SURVIVAL_AddToPlayerInventory( player, weaponName, 1, false )

            weapon = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_ANTI_TITAN )

            if ( IsValid( weapon ) )
		    {
                weapon = player.SetActiveWeaponByName( eActiveInventorySlot.mainHand, weaponName )
            }
        }
        else
        {
            player.TakeWeaponByEntNow( weaponSwap )
            weapon = player.GiveWeapon( weaponName, inventorySlot )
        }

        return weapon
    }

    entity function CreateWeaponWall( int index, vector pos, vector ang, bool isHighlighted = true )
    {
        entity weaponWall = CreateEntity( "prop_dynamic" )
        weaponWall.SetModel( eWeaponZombieModel[ index ] )
        weaponWall.SetScriptName( WEAPON_WALL_SCRIPT_NAME )
        weaponWall.NotSolid()
        weaponWall.SetFadeDistance( 20000 )
        weaponWall.SetOrigin( pos )
        weaponWall.SetAngles( ang )

        if ( isHighlighted )
            SetSurvivalPropHighlight( weaponWall, "survival_item_weapon", false )

        DispatchSpawn( weaponWall )
        
        return weaponWall
    }
#endif
