
untyped

global function ClCustomZombie_Init
global function ServerCallback_OnClientDisconnected
global function ServerCallback_UpdateClientScoreToPlayer
global function ServerCallback_RUIInit
global function ServerCallback_SetMysteryBoxUsable

const string SCORE = "%i $"


void function ClCustomZombie_Init()
{
    
}

void function ServerCallback_OnClientDisconnected( entity player )
{
    if ( player in customZombieSystemGlobal.playerSystemGlobal )
	delete customZombieSystemGlobal.playerSystemGlobal[ player ]
}

void function ServerCallback_UpdateClientScoreToPlayer( entity player, int score )
{
    CustomZombieSystemGlobal totalScore = GetPlayerInSystemGlobal( player )
    totalScore.score = score

    ServerCallback_RUIUpdateCurrency()
}

void function ServerCallback_RUIInit()
{
    CustomZombieSystemGlobal player = GetPlayerInSystemGlobal( GetLocalClientPlayer() )

    UISize screenSize = GetScreenSize()

    var screenAlignmentTopoScoreText = RuiTopology_CreatePlane( <(screenSize.width / 2) + 200, 0, 0>, <1000, 0, 0>, <0, 1720, 0>, false )

    if(!IsValid( player.playerScoreUI ))
    {
        string playerScore = format( SCORE, player.score )
        player.playerScoreUI = RuiCreate( $"ui/announcement_quick_right.rpak", screenAlignmentTopoScoreText, RUI_DRAW_HUD, RUI_SORT_SCREENFADE + 1 )
        RuiSetGameTime( player.playerScoreUI, "startTime", Time() )
        RuiSetString( player.playerScoreUI, "messageText", playerScore )
        RuiSetFloat( player.playerScoreUI, "duration", 9999999 )
        RuiSetFloat3( player.playerScoreUI, "eventColor", SrgbToLinear( <128, 188, 255> ) )
    }
}

void function ServerCallback_RUIUpdateCurrency()
{
    CustomZombieSystemGlobal player = GetPlayerInSystemGlobal( GetLocalClientPlayer() )

    string playerScore = format( SCORE, player.score )
    if(IsValid( player.playerScoreUI ))
    RuiSetString( player.playerScoreUI, "messageText", playerScore )
}

void function ServerCallback_SetMysteryBoxUsable( entity usableMysteryBox, bool isUsable )
{
    GetMysteryBox( usableMysteryBox ).isUsable = isUsable
}
