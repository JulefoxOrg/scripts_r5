
#if SERVER || CLIENT

    untyped

    // Global functions
        global function GetMysteryBox
        global function GetMysteryBoxFromEnt
        global function ShZombieMysteryBox_Init

    #if SERVER
        global function CreateMysteryBox
        global function DestroyWeaponByDeadline_Thread
    #endif // SERVER

    #if CLIENT
        global function MysteryBox_DisplayRui
    #endif // CLIENT

    // Consts
        const float  MYSTERY_BOX_ON_USE_DURATION        = 0.0
        const float  MYSTERY_BOX_WEAPON_MOVE_TIME       = 3
        const int    MYSTERY_BOX_COST                   = 950
        const int    MYSTERY_BOX_MAX_CAN_USE            = 15
        const int    MYSTERY_BOX_MIN_CAN_USE            = 6
        const string MYSTERY_BOX_SCRIPT_NAME            = "MysteryBoxScriptName"
        const string MYSTERY_BOX_USE                    = "to open Mystery Box\nCost: %i $"
        const string USE                                = "Press %use% "
        const vector MYSTERY_BOX_WEAPON_ANGLES_OFFSET   = < 0, 90, 0 >
        const vector MYSTERY_BOX_WEAPON_MOVE_TO         = < 0, 0, 30 >
        const vector MYSTERY_BOX_WEAPON_ORIGIN_OFFSET   = < 0, 0, 20 >

    #if SERVER
        const asset MYSTERY_BOX_BEAM                    = $"P_ar_hot_zone_far"
        const asset NESSY_MODEL                         = $"mdl/domestic/nessy_doll.rmdl"
    #endif // SERVER

    #if CLIENT
        const asset MYSTERY_BOX_DISPLAYRUI = $"ui/extended_use_hint.rpak"
    #endif // CLIENT

    // Mystery box locations
    array < vector > locationOrigin = [ < 3910.18848, 5499.14404, -4295.94385 >, < 3910.18848, 5499.14404, -4295.94385 > ]
    array < vector > locationAngles = [ < 0, -140, 0 >, < 0, -140, 0 > ]


    // Global struct for mystery box
    global struct CustomZombieMysteryBox
    {
        array < entity > mysteryBoxArray
        bool mysteryBoxCanUse       = false
        bool weaponCanUse   = false
        entity mysteryBoxEnt
        entity mysteryBoxFx
        entity mysteryBoxWeapon
        entity mysteryBoxWeaponScriptMover
        string targetName
        table < entity, CustomZombieMysteryBox > mysteryBox

        #if SERVER
            bool changeLocation
            int maxUseIdx
            int usedIdx
        #endif // SERVER
    }
    global CustomZombieMysteryBox customZombieMysteryBox


    // Init
    void function ShZombieMysteryBox_Init()
    {
        // Init weapon in mystery box file
        ShZombieMysteryBoxWeapon_Init()

        #if SERVER
            PrecacheParticleSystem( MYSTERY_BOX_BEAM )
        #endif // SERVER

        #if SERVER
            AddSpawnCallback( "prop_dynamic", MysteryBoxInit )
        #endif // SERVER

        #if CLIENT
            AddCreateCallback( "prop_dynamic", MysteryBoxInit )
        #endif // CLIENT
    }


    // SERVER && CLIENT Callback
    void function MysteryBoxInit( entity mysteryBox )
    {
        if ( !IsValidMysteryBox( mysteryBox ) )
            return

        AddMysteryBox( mysteryBox )
        SetMysteryBoxUsable( mysteryBox )
        SetMysteryBoxFx( mysteryBox )
    }


    // Check by script name if it is a mystery box.
    bool function IsValidMysteryBox( entity ent )
    {
        if ( ent.GetScriptName() == MYSTERY_BOX_SCRIPT_NAME )
            return true

        return false
    }


    // Create a new instance for a mystery box
    CustomZombieMysteryBox function AddMysteryBox( entity mysteryBox )
    {
        CustomZombieMysteryBox newMysteryBox

        newMysteryBox.mysteryBoxEnt = mysteryBox
        newMysteryBox.targetName = UniqueMysteryBoxString( "MysteryBox" )

        #if SERVER
            SetTargetName( mysteryBox, newMysteryBox.targetName )
            newMysteryBox.maxUseIdx = RandomIntRange( MYSTERY_BOX_MIN_CAN_USE, MYSTERY_BOX_MAX_CAN_USE )
        #endif // SERVER

        customZombieMysteryBox.mysteryBox[ mysteryBox ] <- newMysteryBox
        customZombieMysteryBox.mysteryBoxArray.append( mysteryBox )

        return customZombieMysteryBox.mysteryBox[ mysteryBox ]
    }


    // Set mystery box usable
    void function SetMysteryBoxUsable( entity mysteryBox )
    {
        #if SERVER
            mysteryBox.SetUsable()
            mysteryBox.SetUsableByGroup( "pilot" )
            mysteryBox.SetUsableValue( USABLE_BY_ALL | USABLE_CUSTOM_HINTS )
            mysteryBox.SetUsablePriority( USABLE_PRIORITY_MEDIUM )
        #endif // SERVER

        GetMysteryBox( mysteryBox ).mysteryBoxCanUse = true

        SetCallback_CanUseEntityCallback( mysteryBox, MysteryBox_CanUse )
        AddCallback_OnUseEntity( mysteryBox, OnUseProcessingMysteryBox )

        #if CLIENT
            AddEntityCallback_GetUseEntOverrideText( mysteryBox, MysteryBox_TextOverride )
        #endif // CLIENT
    }


    // Create a fx on the mystery box
    void function SetMysteryBoxFx( entity mysteryBox )
    {
        #if SERVER
            GetMysteryBox( mysteryBox ).mysteryBoxFx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( MYSTERY_BOX_BEAM ), mysteryBox.GetOrigin(), < 90, 0, 0 > )
        #endif // SERVER
    }


    // If is usable
    bool function MysteryBox_CanUse( entity player, entity mysteryBox )
    {
        if ( !SURVIVAL_PlayerCanUse_AnimatedInteraction( player, mysteryBox ) )
            return false
        
        if ( GetMysteryBox( mysteryBox ).mysteryBoxCanUse == false )
            return false

        return true
    }


    // Callback if the mystery box is used
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


    // If the callback is a success
    void function MysteryBoxUseSuccess( entity mysteryBox, entity player, ExtendedUseSettings settings )
    {
        CustomZombieMysteryBox mysteryBoxStruct = GetMysteryBox( mysteryBox )
        
        if ( !PlayerHasEnoughScore( player, MYSTERY_BOX_COST ) )
            return

        #if SERVER
            MysteryBoxSetUsable( player, mysteryBox, false )

            mysteryBoxStruct.changeLocation = false
            
                mysteryBoxStruct.usedIdx++

            if ( mysteryBoxStruct.usedIdx == mysteryBoxStruct.maxUseIdx ) mysteryBoxStruct.changeLocation = true
        #endif // SERVER

        RemoveScoreToPlayer( player, MYSTERY_BOX_COST )

        #if SERVER && NIGHTMARE_DEV
            printt( format( "Number of times used before swap: %i / %i", mysteryBoxStruct.usedIdx, mysteryBoxStruct.maxUseIdx ) )
        #endif // SERVER && NIGHTMARE_DEV

        #if SERVER
            thread MysteryBox_Init( mysteryBox, player )
        #endif // SERVER
    }


    #if CLIENT
        // Text override
        string function MysteryBox_TextOverride( entity mysteryBox )
        {
            return USE + format( MYSTERY_BOX_USE, MYSTERY_BOX_COST )
        }

        // RUI Function
        void function MysteryBox_DisplayRui( entity ent, entity player, var rui, ExtendedUseSettings settings )
        {
            RuiSetString( rui, "holdButtonHint", settings.holdHint )
            RuiSetString( rui, "hintText", settings.hint )
            RuiSetGameTime( rui, "startTime", Time() )
            RuiSetGameTime( rui, "endTime", Time() + settings.duration )
        }
    #endif // CLIENT

    //  _______ _    _ _____  ______          _____  
    // |__   __| |  | |  __ \|  ____|   /\   |  __ \ 
    //    | |  | |__| | |__) | |__     /  \  | |  | |
    //    | |  |  __  |  _  /|  __|   / /\ \ | |  | |
    //    | |  | |  | | | \ \| |____ / ____ \| |__| |
    //    |_|  |_|  |_|_|  \_\______/_/    \_\_____/ 

    #if SERVER            
        // Thread init
        void function MysteryBox_Init( entity mysteryBox, entity player )
        {
            waitthread MysteryBox_PlayOpenSequence( mysteryBox, player )
            waitthread MysteryBox_Thread( mysteryBox, player )
            if ( IsValid( GetMysteryBox( mysteryBox ).mysteryBoxWeapon ) ) thread DestroyWeaponByDeadline_Thread( player, mysteryBox )
        }


        // Thread mid
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

            if ( mysteryBoxStruct.changeLocation )
            {
                weapon.SetAngles( weapon.GetAngles() + < 0, 180, 0 > )
                weapon.SetModel( NESSY_MODEL )

                    wait 0.4

                Remote_CallFunction_NonReplay( player, "ServerCallback_MysteryBoxChangeLocation_DoAnnouncement" )

                MysteryBoxRefundPlayer( player )

                    wait 3

                DestroyMysteryBox_Thread( player, mysteryBox )

                    wait 10

                RespawnMysteryBox()
            }
            else
            {
                wait 0.1

                MysteryBoxWeaponSetUsable( player, weapon, true )

                wait 3
            }
        }


        // Thread end
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


        // Destroy mystery box
        void function DestroyMysteryBox_Thread( entity player, entity mysteryBox )
        {
            CustomZombieMysteryBox mysteryBoxStruct = GetMysteryBox( mysteryBox )

            entity weapon = mysteryBoxStruct.mysteryBoxWeapon
            entity script_mover = mysteryBoxStruct.mysteryBoxWeaponScriptMover
            entity mysteryBoxFx = mysteryBoxStruct.mysteryBoxFx
            entity toDissolve = mysteryBoxStruct.mysteryBoxEnt

            if ( IsValid( weapon ) ) weapon.Destroy()
            if ( IsValid( script_mover ) ) script_mover.Destroy()
            if ( IsValid( mysteryBoxFx ) ) mysteryBoxFx.Destroy()

                wait 0.2

            waitthread MysteryBox_PlayCloseSequence( mysteryBox )

                wait 0.1

            if ( IsValid( toDissolve ) ) toDissolve.Dissolve( ENTITY_DISSOLVE_CORE, < 0, 0, 0 >, 1000 )
        }


        // Set by true or false if the mystery box is usable
        void function MysteryBoxSetUsable( entity player, entity mysteryBox, bool isUsable )
        {
            GetMysteryBox( mysteryBox ).mysteryBoxCanUse = isUsable
            Remote_CallFunction_NonReplay( player, "ServerCallback_SetMysteryBoxUsable", mysteryBox, isUsable )
        }


        // Set by true or false if the weapon is usable
        void function MysteryBoxWeaponSetUsable( entity player, entity weaponMysteryBox, bool isUsable )
        {
            GetMysteryBoxFromEnt( weaponMysteryBox ).weaponCanUse = isUsable
            Remote_CallFunction_NonReplay( player, "ServerCallback_SetWeaponMysteryBoxUsable", weaponMysteryBox, isUsable )
        }


        // Refunds the player
        void function MysteryBoxRefundPlayer( entity player )
        {
            AddScoreToPlayer( player, MYSTERY_BOX_COST )
        }


        // Respawn a mystery box at a random position
        void function RespawnMysteryBox()
        {
            int locationsLen = locationOrigin.len() - 1
            int locations = RandomIntRange( 0, locationsLen )

            CreateMysteryBox( locationOrigin[ locations ], locationAngles[ locations ] )
        }

        
        // Open mystery box
        void function MysteryBox_PlayOpenSequence( entity mysteryBox, entity player )
        {
            if ( !mysteryBox.e.hasBeenOpened )
            {
                mysteryBox.e.hasBeenOpened = true

                StopSoundOnEntity( mysteryBox, SOUND_LOOT_BIN_IDLE )
            }

            EmitSoundOnEntity( mysteryBox, SOUND_LOOT_BIN_OPEN )

            waitthread PlayAnim( mysteryBox, "loot_bin_01_open" )
        }


        // Close mystery box
        void function MysteryBox_PlayCloseSequence( entity mysteryBox )
        {
            waitthread PlayAnim( mysteryBox, "loot_bin_01_close" )
        }


        // Create mystery box
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
    #endif // SERVER


    //    _    _ _______ _____ _      _____ _________     __
    //   | |  | |__   __|_   _| |    |_   _|__   __\ \   / /
    //   | |  | |  | |    | | | |      | |    | |   \ \_/ / 
    //   | |  | |  | |    | | | |      | |    | |    \   /  
    //   | |__| |  | |   _| |_| |____ _| |_   | |     | |   
    //    \____/   |_|  |_____|______|_____|  |_|     |_|   


    // Get a specific mystery box
    CustomZombieMysteryBox function GetMysteryBox( entity mysteryBox )
    {
        return customZombieMysteryBox.mysteryBox[ mysteryBox ]
    }


    // Get a specific mystery box with an other ent using the same target name
    CustomZombieMysteryBox function GetMysteryBoxFromEnt( entity ent )
    {
        string targetName = ent.GetTargetName() ; entity mysteryBox

        foreach ( mysteryBoxs in GetAllMysteryBox() )
        {   if ( GetMysteryBox( mysteryBoxs ).targetName == targetName )
            {   mysteryBox = mysteryBoxs }
        }
                
    return customZombieMysteryBox.mysteryBox[ mysteryBox ] }


    // Get all mystery boxes
    array< entity > function GetAllMysteryBox()
    {
        return customZombieMysteryBox.mysteryBoxArray
    }


    // Create a unique string foreach mystery boxes
    int uniqueMysteryBoxIdx = 0
    string function UniqueMysteryBoxString( string str = "" )
    {
    	return str + "_idx" + uniqueMysteryBoxIdx++
    }

#endif // SERVER || CLIENT
