
#if SERVER || CLIENT

    untyped

    // Global functions
        global function ShZombieScore_Init

        global function PlayerHasEnoughScore
        global function AddScoreToPlayer
        global function RemoveScoreToPlayer


    // Init
    void function ShZombieScore_Init()
    {
        #if SERVER && NIGHTMARE_DEV
            AddClientCommandCallback( "$", ClientCommand_GetPlayerScore )
            AddClientCommandCallback( "sa", ClientCommand_AddScoreToPlayer )
            AddClientCommandCallback( "sr", ClientCommand_RemoveScoreToPlayer )
        #endif // SERVER && NIGHTMARE_DEV
    }


    // Compare the price of an object with the player's score
    bool function PlayerHasEnoughScore( entity player, int weaponPrice )
    {
        if ( GetPlayerScore( player ) >= weaponPrice )
            return true

        return false
    }


    // Add score to a specific player
    void function AddScoreToPlayer( entity player, int score )
    {
        #if SERVER
            CustomZombieSystemGlobal totalScore = GetPlayerInSystemGlobal( player )
            totalScore.score = totalScore.score + score

            Remote_CallFunction_NonReplay( player, "ServerCallback_UpdateClientScoreToPlayer", player, totalScore.score )
        #endif // SERVER
    }


    // Remove score to a specific player
    void function RemoveScoreToPlayer( entity player, int score )
    {
        #if SERVER
            CustomZombieSystemGlobal totalScore = GetPlayerInSystemGlobal( player )
            totalScore.score = totalScore.score - score

            if ( totalScore.score < 0 ) totalScore.score = 0

            Remote_CallFunction_NonReplay( player, "ServerCallback_UpdateClientScoreToPlayer", player, totalScore.score )
        #endif // SERVER
    }


    #if SERVER
        // Get how many score player have by client command
        bool function ClientCommand_GetPlayerScore( entity player, array<string> args )
        {
        	printt( format( "Player have: %i $", GetPlayerScore( player ) ) )

        	return true
        }


        //  Add score to player by client command
        bool function ClientCommand_AddScoreToPlayer( entity player, array<string> args )
        {
            if ( args.len() == 0 )
                return true

        	AddScoreToPlayer( player, int( args[0] ) )

        	return true
        }


        // Remove score to player by client command
        bool function ClientCommand_RemoveScoreToPlayer( entity player, array<string> args )
        {
        	if ( args.len() == 0 )
                return true

        	RemoveScoreToPlayer( player, int( args[0] ) )

        	return true
        }
    #endif // SERVER
#endif // SERVER || CLIENT
