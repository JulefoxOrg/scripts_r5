
untyped

global function ClCustomZombie_Init
global function ServerCallback_OnClientDisconnected
global function ServerCallback_AddCurrencyToSpecifiedPlayer
global function ServerCallback_RemoveCurrencyToSpecifiedPlayer


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
    CustomZombieCurrency wallet = customZombieCurrency.playersWallets[ player ]
    wallet.wallet = wallet.wallet + currency
}

void function ServerCallback_RemoveCurrencyToSpecifiedPlayer( entity player, int currency )
{
    CustomZombieCurrency wallet = customZombieCurrency.playersWallets[ player ]
    wallet.wallet = wallet.wallet - currency

    if ( wallet.wallet < 0 ) wallet.wallet = 0
}
