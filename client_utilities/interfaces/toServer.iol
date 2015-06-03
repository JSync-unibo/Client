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


/*
 * Tipo che si riferisce alla risposta che riceve il Client, 
 * che è composta da un errore, se presente, e da un messaggio 
 * che descrive l'errore
 */
type ResponseMessage: void {

	.error: bool
	.message: string
}


//Interfaccia fra il client ed il server
interface ToServerInterface { 

  	RequestResponse: listRepo(void)(string),

		            addRepository(ToServerType)(ResponseMessage),
	                push(ToServerType)(ResponseMessage),
  				    pull(ToServerType)(ResponseMessage),
  				    delete(ToServerType)(ResponseMessage)
}

outputPort ServerConnection {
	Interfaces: ToServerInterface
}