
untyped

global function ClCustomZombie_Init
global function ServerCallback_OnClientDisconnected
global function ServerCallback_AddCurrencyToSpecifiedPlayer
global function ServerCallback_RemoveCurrencyToSpecifiedPlayer
global function ServerCallback_RUIInit


void function ClCustomZombie_Init()
{
    
}

void function ServerCallback_OnClientDisconnected( entity player )
{
    if ( player in customZombieCurrency.playersWallets )
	delete customZombieCurrency.playersWallets[player]
}

void function ServerCallback_AddCurrencyToSpecifiedPlayer( entity player, int currency )
{
    CustomZombieCurrency wallet = GetPlayerStruct( player )
    wallet.wallet = wallet.wallet + currency

    ServerCallback_RUIUpdateCurrency()
}

void function ServerCallback_RemoveCurrencyToSpecifiedPlayer( entity player, int currency )
{
    CustomZombieCurrency wallet = GetPlayerStruct( player )
    wallet.wallet = wallet.wallet - currency

    if ( wallet.wallet < 0 ) wallet.wallet = 0

    ServerCallback_RUIUpdateCurrency()
}

void function ServerCallback_RUIInit()
{
    CustomZombieCurrency player = GetPlayerStruct( GetLocalClientPlayer() )

    UISize screenSize = GetScreenSize()

    var screenAlignmentTopoScoreText = RuiTopology_CreatePlane( <(screenSize.width / 2) + 200, 0, 0>, <1000, 0, 0>, <0, 1720, 0>, false )

    if(!IsValid( player.playerScore ))
    {
        string playerScore = format( "%s %s", string( player.wallet ), "$" )
        player.playerScore = RuiCreate( $"ui/announcement_quick_right.rpak", screenAlignmentTopoScoreText, RUI_DRAW_HUD, RUI_SORT_SCREENFADE + 1 )
        RuiSetGameTime( player.playerScore, "startTime", Time() )
        RuiSetString( player.playerScore, "messageText", playerScore )
        RuiSetFloat( player.playerScore, "duration", 9999999 )
        RuiSetFloat3( player.playerScore, "eventColor", SrgbToLinear( <128, 188, 255> ) )
    }
}

void function ServerCallback_RUIUpdateCurrency()
{
    CustomZombieCurrency player = GetPlayerStruct( GetLocalClientPlayer() )

    string playerScore = format( "%s %s", string( player.wallet ), "$" )
    if(IsValid( player.playerScore ))
    RuiSetString( player.playerScore, "messageText", playerScore )
}
