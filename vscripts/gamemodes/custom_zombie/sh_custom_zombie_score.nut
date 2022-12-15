
untyped

global function ShZombieScore_Init

global function PlayerHasEnoughScore
global function AddScoreToPlayer
global function RemoveScoreToPlayer


void function ShZombieScore_Init()
{
    #if SERVER  
        AddClientCommandCallback( "$", ClientCommand_GetPlayerScore )
        AddClientCommandCallback( "wa", ClientCommand_AddScoreToPlayer )
        AddClientCommandCallback( "wr", ClientCommand_RemoveScoreToPlayer )
    #endif // SERVER
}

void function AddScoreToPlayer( entity player, int score )
{
    #if SERVER
        CustomZombieSystemGlobal totalScore = GetPlayerInSystemGlobal( player )
        totalScore.score = totalScore.score + score

        Remote_CallFunction_NonReplay( player, "ServerCallback_AddScoreToPlayer", player, totalScore.score )
    #endif // SERVER
}

void function RemoveScoreToPlayer( entity player, int score )
{
    #if SERVER
        CustomZombieSystemGlobal totalScore = GetPlayerInSystemGlobal( player )
        totalScore.score = totalScore.score - score

        if ( totalScore.score < 0 ) totalScore.score = 0

        Remote_CallFunction_NonReplay( player, "ServerCallback_RemoveScoreToPlayer", player, totalScore.score )
    #endif // SERVER
}

bool function PlayerHasEnoughScore( entity player, int weaponPrice )
{
    if ( GetPlayerScore( player ) >= weaponPrice )
        return true

    return false
}

#if SERVER
    bool function ClientCommand_GetPlayerScore( entity player, array<string> args )
    {
    	printt( format( "Player have: %i $", GetPlayerScore( player ) ) )
    
    	return true
    }

    bool function ClientCommand_AddScoreToPlayer( entity player, array<string> args )
    {
        if ( args.len() == 0 )
            return true

    	AddScoreToPlayer( player, int( args[0] ) )
    
    	return true
    }

    bool function ClientCommand_RemoveScoreToPlayer( entity player, array<string> args )
    {
    	if ( args.len() == 0 )
            return true

    	RemoveScoreToPlayer( player, int( args[0] ) )

    	return true
    }
#endif
