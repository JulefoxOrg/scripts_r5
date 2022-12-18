
#if SERVER || CLIENT

    untyped

    // Global functions
        global function ShZombieMysteryBox_Init
        
        global function GetMysteryBox
        global function GetMysteryBoxFromEnt

    #if SERVER
        global function CreateMysteryBox
        global function DestroyWeaponByDeadline_Thread
        global function MysteryBoxMapInit
        global function RegisterMysteryBoxLocation
        global function GetAvailablesLocations
    #endif // SERVER

    #if CLIENT
        global function MysteryBox_DisplayRui
    #endif // CLIENT

    int uniqueGradeIdx = 1000

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
        const asset MYSTERY_BOX_BEAM                    = $"P_ar_loot_drop_point_far"
        const asset NESSY_MODEL                         = $"mdl/domestic/nessy_doll.rmdl"
    #endif // SERVER

    #if CLIENT
        const asset MYSTERY_BOX_DISPLAYRUI = $"ui/extended_use_hint.rpak"
    #endif // CLIENT


    #if SERVER
        // Create new locations for mystery boxes
        global struct MisteryBoxLocationData
        {
            array < MisteryBoxLocationData > locationDataArray

            vector origin
            vector angles
            bool isUsed
            string targetName = ""
        }
        global MisteryBoxLocationData misteryBoxLocationData

        // You can know if an instance of "MisteryBoxLocationData" is valid or null
        typedef ornullMisteryBoxLocationData MisteryBoxLocationData ornull
    #endif // SERVER


    // Global struct for mystery box
    global struct CustomZombieMysteryBox
    {
        array < entity > mysteryBoxArray
        array < entity > entityCanUseMysteryBox = []
        bool mysteryBoxIsUsable = true
        entity mysteryBoxEnt
        entity mysteryBoxFx
        entity mysteryBoxWeapon
        entity mysteryBoxWeaponScriptMover
        int uniqueGradeIdx
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
        newMysteryBox.uniqueGradeIdx = uniqueGradeIdx++
        newMysteryBox.targetName = mysteryBox.GetTargetName()

        #if SERVER
            newMysteryBox.maxUseIdx = RandomIntRange( MYSTERY_BOX_MIN_CAN_USE, MYSTERY_BOX_MAX_CAN_USE )
        #endif // SERVER

        customZombieMysteryBox.mysteryBoxArray.append( mysteryBox )
        customZombieMysteryBox.mysteryBox[ mysteryBox ] <- newMysteryBox

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
            GetMysteryBox( mysteryBox ).mysteryBoxFx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( MYSTERY_BOX_BEAM ), mysteryBox.GetOrigin(), < 0, 0, 0 > )
        #endif // SERVER
    }


    // If is usable
    bool function MysteryBox_CanUse( entity player, entity mysteryBox )
    {
        if ( !SURVIVAL_PlayerCanUse_AnimatedInteraction( player, mysteryBox ) )
            return false

        if ( !GetMysteryBox( mysteryBox ).mysteryBoxIsUsable )
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
            settings.hint               = "Processing Mystery box..."
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

        mysteryBoxStruct.mysteryBoxIsUsable = false

        RemoveScoreToPlayer( player, MYSTERY_BOX_COST )

        #if SERVER
            mysteryBoxStruct.changeLocation = false
            mysteryBoxStruct.usedIdx++

            foreach ( players in GetAllPlayerInSystemGlobal() )
                Remote_CallFunction_NonReplay( players, "ServerCallback_MysteryBoxIsUsable", mysteryBox, false )

            if ( mysteryBoxStruct.usedIdx >= mysteryBoxStruct.maxUseIdx )
            {
                mysteryBoxStruct.changeLocation = true
            }

            thread MysteryBox_Init( mysteryBox, player )
        #endif // SERVER

        #if SERVER && NIGHTMARE_DEV
            printt( format( "Number of times used before swap: %i / %i", mysteryBoxStruct.usedIdx, mysteryBoxStruct.maxUseIdx ) )
        #endif // SERVER && NIGHTMARE_DEV
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


    //////////////////////////////////////////////
    //    _____ _                        _      //
    //   |_   _| |__  _ __ ___  __ _  __| |     //
    //     | | | '_ \| '__/ _ \/ _` |/ _` |     //
    //     | | | | | | | |  __/ (_| | (_| |     //
    //     |_| |_| |_|_|  \___|\__,_|\__,_|     //
    //////////////////////////////////////////////
                                   

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

            if ( IsValid( weapon ) ) weapon.SetParent( script_mover )

            float currentTime = Time()
            float startTime = currentTime
            float endTime = startTime + MYSTERY_BOX_WEAPON_MOVE_TIME
            float waitVar = 0.01

            if ( IsValid( script_mover ) ) script_mover.NonPhysicsMoveTo( weapon.GetOrigin() + MYSTERY_BOX_WEAPON_MOVE_TO, MYSTERY_BOX_WEAPON_MOVE_TIME, 0, MYSTERY_BOX_WEAPON_MOVE_TIME )

            while ( endTime > currentTime )
            {
                if ( IsValid( weapon ) ) weapon.SetModel( eWeaponZombieModel[ RandomIntRange( 0, eWeaponZombieIdx.len() - 1 ) ] )
                currentTime = Time()
                wait waitVar
            }

            if ( mysteryBoxStruct.changeLocation )
            {
                if ( IsValid( weapon ) ) weapon.SetAngles( weapon.GetAngles() + < 0, 180, 0 > )
                if ( IsValid( weapon ) ) weapon.SetModel( NESSY_MODEL )

                    wait 0.4

                Remote_CallFunction_NonReplay( player, "ServerCallback_MysteryBoxChangeLocation_DoAnnouncement" )

                MysteryBoxRefundPlayer( player )

                    wait 3

                DestroyMysteryBox_Thread( player, mysteryBox )

                    wait 10

                RespawnMysteryBox( mysteryBoxStruct.targetName )
            }
            else
            {
                wait 0.1

                    GradeFlagsSet( player, mysteryBoxStruct.uniqueGradeIdx )

                wait 3

                    if ( IsValid( script_mover ) && IsValid( weapon ) ) script_mover.NonPhysicsMoveTo( weapon.GetOrigin() - MYSTERY_BOX_WEAPON_MOVE_TO, ( MYSTERY_BOX_WEAPON_MOVE_TIME * 2 ), 0, ( MYSTERY_BOX_WEAPON_MOVE_TIME * 2 ) )

                wait ( MYSTERY_BOX_WEAPON_MOVE_TIME * 2 ) + 0.1
            }
        }


        // Thread end
        void function DestroyWeaponByDeadline_Thread( entity player, entity mysteryBox )
        {
            CustomZombieMysteryBox mysteryBoxStruct = GetMysteryBox( mysteryBox )

            foreach ( players in GetPlayerArrayOfTeam( player.GetTeam() ) )
            GradeFlagsClear( players, mysteryBoxStruct.uniqueGradeIdx )

            entity weapon = mysteryBoxStruct.mysteryBoxWeapon
            entity script_mover = mysteryBoxStruct.mysteryBoxWeaponScriptMover

            if ( IsValid( weapon ) ) weapon.Destroy()
            if ( IsValid( script_mover ) ) script_mover.Destroy()

                wait 0.2

            waitthread MysteryBox_PlayCloseSequence( mysteryBox )

                wait 0.1
            
            mysteryBoxStruct.mysteryBoxIsUsable = true

            foreach ( players in GetAllPlayerInSystemGlobal() )
                Remote_CallFunction_NonReplay( players, "ServerCallback_MysteryBoxIsUsable", mysteryBox, true )
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


        // Respawn a mystery box at a random position
        void function RespawnMysteryBox( string targetName )
        {

            ornullMisteryBoxLocationData ornullLocation = FindUsedMysteryBoxLocation( targetName )

                if ( ornullLocation == null )
                    return

                MisteryBoxLocationData location = expect MisteryBoxLocationData( ornullLocation )


            ornullMisteryBoxLocationData ornullNewLocation = FindUnusedMysteryBoxLocation()

                if ( ornullNewLocation == null )
                {
                    location.targetName = ""
                    location.isUsed = false
                    return
                }

                MisteryBoxLocationData newLocation = expect MisteryBoxLocationData( ornullNewLocation )

                entity mysteryBox = CreateMysteryBox( newLocation.origin, newLocation.angles )

                newLocation.targetName = mysteryBox.GetTargetName()
                newLocation.isUsed = true


            location.targetName = ""
            location.isUsed = false
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
    #endif // SERVER


    //////////////////////////////////////////////////////////////////////////////////////////////////
    //    __  __           _                  ____            __  __            ___       _ _       //
    //   |  \/  |_   _ ___| |_ ___ _ __ _   _| __ )  _____  _|  \/  | __ _ _ __|_ _|_ __ (_) |_     //
    //   | |\/| | | | / __| __/ _ \ '__| | | |  _ \ / _ \ \/ / |\/| |/ _` | '_ \| || '_ \| | __|    //
    //   | |  | | |_| \__ \ ||  __/ |  | |_| | |_) | (_) >  <| |  | | (_| | |_) | || | | | | |_     //
    //   |_|  |_|\__, |___/\__\___|_|   \__, |____/ \___/_/\_\_|  |_|\__,_| .__/___|_| |_|_|\__|    //
    //           |___/                  |___/                             |_|                       //
    //////////////////////////////////////////////////////////////////////////////////////////////////


    #if SERVER
        // Init the number of boxes you want in the game
        void function MysteryBoxMapInit( int num )
        {

            #if NIGHTMARE_DEV && SPAWN_MYSTERYBOX_ON_ALL_LOCATIONS
                num = GetAvailablesLocations()
            #endif // NIGHTMARE_DEV && SPAWN_MYSTERYBOX_ON_ALL_LOCATIONS

            for ( int i = 0 ; i < num ; i++ )
            {
                ornullMisteryBoxLocationData ornullLocation = FindUnusedMysteryBoxLocation()

                if ( ornullLocation == null )
                    return

                MisteryBoxLocationData location = expect MisteryBoxLocationData( ornullLocation )

                entity mysteryBox = CreateMysteryBox( location.origin, location.angles )

                location.targetName = mysteryBox.GetTargetName()

                location.isUsed = true

            }

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
            SetTargetName( mysteryBox, UniqueMysteryBoxString( "MysteryBox" ) )
    
            DispatchSpawn( mysteryBox )
    
            return mysteryBox
        }
    #endif // SERVER


    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //      __  __ _     _                  ____            _                    _   _             ____        _            //
    //     |  \/  (_)___| |_ ___ _ __ _   _| __ )  _____  _| |    ___   ___ __ _| |_(_) ___  _ __ |  _ \  __ _| |_ __ _     //
    //     | |\/| | / __| __/ _ \ '__| | | |  _ \ / _ \ \/ / |   / _ \ / __/ _` | __| |/ _ \| '_ \| | | |/ _` | __/ _` |    //
    //     | |  | | \__ \ ||  __/ |  | |_| | |_) | (_) >  <| |__| (_) | (_| (_| | |_| | (_) | | | | |_| | (_| | || (_| |    //
    //     |_|  |_|_|___/\__\___|_|   \__, |____/ \___/_/\_\_____\___/ \___\__,_|\__|_|\___/|_| |_|____/ \__,_|\__\__,_|    //
    //                                |___/                                                                                 //
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    #if SERVER
        // Register a new location for mystery boxes
        MisteryBoxLocationData function RegisterMysteryBoxLocation( vector origin, vector angles )
        {
            MisteryBoxLocationData location
            location.origin = origin
            location.angles = angles
            location.isUsed = false

            misteryBoxLocationData.locationDataArray.append( location )

            return location
        }


        // Return all mystery boxes locations
        array < MisteryBoxLocationData > function GetAllMysteryBoxLocations()
        {
            return misteryBoxLocationData.locationDataArray
        }


        // Try to find an unused location otherwise returns null
        MisteryBoxLocationData ornull function FindUnusedMysteryBoxLocation()
        {
            GetAllMysteryBoxLocations().randomize()

            foreach ( locations in GetAllMysteryBoxLocations() )
            {
                if ( locations.isUsed )
                    continue
                else
                    return locations
            }

            return null
        }


        // Tries to find a location via its "target name" otherwise returns null
        MisteryBoxLocationData ornull function FindUsedMysteryBoxLocation( string targetName )
        {
            foreach ( locations in GetAllMysteryBoxLocations() )
            {
                if ( locations.targetName == targetName )
                    return locations
            }

            return null
        }


        // Returns the number of available slots
        int function GetAvailablesLocations()
        {
            int i = 0
            foreach ( locations in GetAllMysteryBoxLocations() )
            {
                if ( !locations.isUsed )
                    i++
            }

            return i
        }
    #endif // SERVER


    //////////////////////////////////////
    //    _   _ _   _ _ _ _             //
    //   | | | | |_(_) (_) |_ _   _     //
    //   | | | | __| | | | __| | | |    //
    //   | |_| | |_| | | | |_| |_| |    //
    //    \___/ \__|_|_|_|\__|\__, |    //
    //                        |___/     //
    //////////////////////////////////////


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

    #if SERVER
        // Refunds the player
        void function MysteryBoxRefundPlayer( entity player )
        {
            AddScoreToPlayer( player, MYSTERY_BOX_COST )
        }
    #endif // SERVER

#endif // SERVER || CLIENT
