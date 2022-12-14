
untyped

global function ShCustomZombieCurrency_Init
global function GetPlayerWallet
global function PlayerHasEnoughCurrency
global function AddCurrencyToPlayerWallet
global function RemoveCurrencyToPlayerWallet


global struct CustomZombieCurrency
{
    entity player
    int wallet = 0

    table < entity, CustomZombieCurrency > playersWallets
}
global CustomZombieCurrency customZombieCurrency


void function ShCustomZombieCurrency_Init()
{
    #if SERVER
        AddSpawnCallback( "player", WalletInit )
    #endif // SERVER

    #if CLIENT
        AddCreateCallback( "player", WalletInit )
    #endif // CLIENT

    #if SERVER
        AddCallback_OnClientConnected( OnClientConnected )
        AddClientCommandCallback( "$", ClientCommand_GetPlayerCurrency )
        AddClientCommandCallback( "wa", ClientCommand_AddPlayerCurrency )
        AddClientCommandCallback( "wr", ClientCommand_RemovePlayerCurrency )
        AddCallback_OnClientDisconnected( OnClientDisconnected )
    #endif // SERVER
}

void function WalletInit( entity player )
{
    PlayerWalletInit( player )
}

CustomZombieCurrency function PlayerWalletInit( entity player )
{
    CustomZombieCurrency walletInit

    customZombieCurrency.playersWallets[ player ] <- walletInit

    return customZombieCurrency.playersWallets[ player ]
}

void function AddCurrencyToPlayerWallet( entity player, int currency )
{
    CustomZombieCurrency wallet = customZombieCurrency.playersWallets[ player ]
    wallet.wallet = wallet.wallet + currency

    //#if !CLIENT
    //    Remote_CallFunction_NonReplay( player, "ServerCallback_AddCurrencyToSpecifiedPlayer", player, currency )
    //#endif

    printt( "Player now have: " + wallet.wallet + " $" )
}

void function RemoveCurrencyToPlayerWallet( entity player, int currency )
{
    CustomZombieCurrency wallet = customZombieCurrency.playersWallets[ player ]
    wallet.wallet = wallet.wallet - currency

    //#if !CLIENT
    //    Remote_CallFunction_NonReplay( player, "ServerCallback_RemoveCurrencyToSpecifiedPlayer", player, currency )
    //#endif

    if ( wallet.wallet < 0 ) wallet.wallet = 0

    printt( "Player now have: " + wallet.wallet + " $" )
}

int function GetPlayerWallet( entity player )
{
    return customZombieCurrency.playersWallets[ player ].wallet
}

bool function PlayerHasEnoughCurrency( entity player, int weaponPrice )
{
    if ( GetPlayerWallet( player ) >= weaponPrice )
        return true

    return false
}

#if SERVER
    void function OnClientConnected( entity player )
    {
        AddCurrencyToPlayerWallet( player, 900000 )
    }

    void function OnClientDisconnected( entity player )
    {
        if ( player in customZombieCurrency.playersWallets )
		delete customZombieCurrency.playersWallets[player]
    }

    bool function ClientCommand_GetPlayerCurrency( entity player, array<string> args )
    {
        CustomZombieCurrency wallet = customZombieCurrency.playersWallets[ player ]

    	printt( "Player have: " + wallet.wallet + " $" )
    
    	return true
    }

    bool function ClientCommand_AddPlayerCurrency( entity player, array<string> args )
    {
        if ( args.len() == 0 )
            return true

    	AddCurrencyToPlayerWallet( player, int( args[0] ) )
    
    	return true
    }

    bool function ClientCommand_RemovePlayerCurrency( entity player, array<string> args )
    {
    	if ( args.len() == 0 )
            return true

    	RemoveCurrencyToPlayerWallet( player, int( args[0] ) )

    	return true
    }
#endif
