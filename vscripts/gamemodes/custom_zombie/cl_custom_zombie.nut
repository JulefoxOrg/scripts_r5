
#if CLIENT

    untyped

    // Global functions
        global function ClCustomZombie_Init

        global function ServerCallback_OnClientDisconnected
        global function ServerCallback_UpdateClientScoreToPlayer
        global function ServerCallback_RUIInit
        global function ServerCallback_SetMysteryBoxUsable
        global function ServerCallback_SetWeaponMysteryBoxUsable
        global function ServerCallback_MysteryBoxChangeLocation_DoAnnouncement

    // Consts
        const string SCORE = "%i $"


    // Client Init (all [client] files are called here)
    void function ClCustomZombie_Init()
    {

    }


    // Callback when a player is disconnected
    // Need to verify if that works
    void function ServerCallback_OnClientDisconnected( entity player )
    {
        if ( player in customZombieSystemGlobal.playerSystemGlobal )
    	delete customZombieSystemGlobal.playerSystemGlobal[ player ]
    }


    // Change the player score (client side)
    void function ServerCallback_UpdateClientScoreToPlayer( entity player, int score )
    {
        CustomZombieSystemGlobal totalScore = GetPlayerInSystemGlobal( player )
        totalScore.score = score

        ServerCallback_RUIUpdateCurrency()
    }


    // Update the player score UI
    void function ServerCallback_RUIUpdateCurrency()
    {
        CustomZombieSystemGlobal player = GetPlayerInSystemGlobal( GetLocalClientPlayer() )

        string playerScore = format( SCORE, player.score ) // TransformString()
        if(IsValid( player.playerScoreUI ))
        RuiSetString( player.playerScoreUI, "messageText", playerScore )
    }


    // Create the RUI for custom zombie
    void function ServerCallback_RUIInit()
    {
        CustomZombieSystemGlobal player = GetPlayerInSystemGlobal( GetLocalClientPlayer() )

        UISize screenSize = GetScreenSize()

        var screenAlignmentTopoScoreText = RuiTopology_CreatePlane( <(screenSize.width / 2) + 200, 0, 0>, <1000, 0, 0>, <0, 1720, 0>, false )

        if(!IsValid( player.playerScoreUI ))
        {
            string playerScore = format( SCORE, player.score ) // TransformString()
            player.playerScoreUI = RuiCreate( $"ui/announcement_quick_right.rpak", screenAlignmentTopoScoreText, RUI_DRAW_HUD, RUI_SORT_SCREENFADE + 1 )
            RuiSetGameTime( player.playerScoreUI, "startTime", Time() )
            RuiSetString( player.playerScoreUI, "messageText", playerScore )
            RuiSetFloat( player.playerScoreUI, "duration", 9999999 )
            RuiSetFloat3( player.playerScoreUI, "eventColor", SrgbToLinear( <128, 188, 255> ) )
        }
    }


    // Test
    string function TransformString()
    {
        CustomZombieSystemGlobal player = GetPlayerInSystemGlobal( GetLocalClientPlayer() )

        string newString = ""
        string score = string ( player.score )

        int scoreLen = score.len()
        int removeLast3Number = scoreLen - 3

        if ( scoreLen >= 4 )
        {
            newString += score.slice( 0, removeLast3Number )
            newString += " "
            newString += score.slice( removeLast3Number, scoreLen )
        }
        else newString += score

        newString += " $"

        return newString
    }


    // Set the mystery box usable
    void function ServerCallback_SetMysteryBoxUsable( entity mysteryBox, bool isUsable )
    {
        GetMysteryBox( mysteryBox ).mysteryBoxCanUse = isUsable
    }


    // Set the weapon mystery box usable
    void function ServerCallback_SetWeaponMysteryBoxUsable( entity weaponMysteryBox )
    {
        CustomZombieMysteryBox mysteryBoxStruct = GetMysteryBoxFromEnt( weaponMysteryBox )
        mysteryBoxStruct.playerAllowedToTakeWeapon.extend( mysteryBoxStruct.playerAllowedToTakeWeaponTemp )
        foreach ( player in mysteryBoxStruct.playerAllowedToTakeWeapon )
        printt( player )
    }


    void function ServerCallback_MysteryBoxChangeLocation_DoAnnouncement()
    {
        foreach( player in GetPlayerArray() )
        {
            AnnouncementData announcement = Announcement_Create( "" )
    	    Announcement_SetSoundAlias( announcement, "survival_circle_close_alarm_01" )
            AnnouncementFromClass( player, announcement )
        }
    }
#endif // CLIENT
