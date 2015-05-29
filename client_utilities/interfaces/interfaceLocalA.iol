/**
*
* Author => Gruppo A: Valentina Tosto, Chiara Babina
* Data => 04/05/2015
* Parent => Client
*
**/


/*
 * Tipo che si riferisce al comando inserito in console
 * con un sottotipo opzionale con i parametri richiesti
 * in input
*/
type CommandType: void {
	.command: string

    .parameters?: void {
    	.serverName: string
    	.serverAddress?: string
    	.repoName?: string
    	.localPath?: string
    	
    }
	
}

//Interfaccia fra il cli ed il client
interface CliInterface {

  RequestResponse: sendCommand(CommandType)(string) 

}

//Interfaccia fra il client ed il server
interface ClientInterface { 

  RequestResponse: listRepo(CommandType)(string),
  				         addRepository(CommandType)(string),
  				         push(CommandType)(string),
  				         pull(CommandType)(string),
  				         delete(CommandType)(string)

}