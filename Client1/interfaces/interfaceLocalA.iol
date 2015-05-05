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

  RequestResponse: listServers(CommandType)(string),
  				   listRepo(CommandType)(string),
  				   listRepoLocal(CommandType)(string),
  				   addServer(CommandType)(string),
  				   removeServer(CommandType)(string),
  				   addRepository(CommandType)(string),
  				   push(CommandType)(string),
  				   pull(CommandType)(string),
  				   delete(CommandType)(string)

}