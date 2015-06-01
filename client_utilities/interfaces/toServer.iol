/*
 * Tipo che si riferisce al comando inserito in console
 * con un sottotipo opzionale con i parametri richiesti
 * in input
 */
type ToServerType: void{

    .serverName: string
    .repoName: string
    .localPath?: string
}

//Interfaccia fra il client ed il server
interface ToServerInterface { 

  RequestResponse: listRepo(string)(string),

		            addRepository(ToServerType)(string),
	                push(ToServerType)(string),
  				    pull(ToServerType)(string),
  				    delete(ToServerType)(string)
}

outputPort ServerConnection {
	Interfaces: ToServerInterface
}