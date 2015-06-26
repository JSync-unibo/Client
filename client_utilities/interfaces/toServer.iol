/*
*
* Author => Gruppo LOBSTER
* Data => 26/06/2015
* 
* Parent => clientUtilities
*
*/



/*
 * Tipo che si riferisce al comando inserito in console
 * con un sottotipo opzionale con i parametri richiesti
 * in input
 */
type ToServerType: void{

    .repoName: string
    .localPath?: string
}


/*
 * Tipo che si riferisce ai parametri dei files
 * inviati durante la push: il nome, il contenuto
 * e la cartella se presente
 */
type FileRequestType: void {

    .filename: string
    .content: string
    .folder?: string
}


/*
 * Tipo che si riferisce alla risposta che riceve il Client, 
 * che è composta da un errore, se presente, da un messaggio 
 * che descrive l'errore e dalla struttura dei files, se viene richiesta
 */
type ResponseMessage: void {

    .error: bool
    .message?: string

    .folderStructure?:void{ 

        .file*:string
    }
}


/*
 * Tipo con i parametri delle variabili globali dei readers
 * e writers (il loro id e l'operazione da eseguire)
 */
type GlobalVar: void {

    .id: int
    .operation: string
}


// Interfaccia fra clientUtilities ed il Server
interface ToServerInterface { 

    RequestResponse: 

        listRepo(void)(string),
        addRepository(ToServerType)(ResponseMessage),
        push(FileRequestType)(ResponseMessage),
        increaseCount(GlobalVar)(ResponseMessage),
        pull(string)(ResponseMessage),
        delete(ToServerType)(ResponseMessage),
        requestFile(string)(FileRequestType)

    OneWay: sendFile( FileRequestType ),
            decreaseCount(int)

}

// Porta che collega il clientUtilities con il Server
// (la location è settata in base al Server scelto)
outputPort ServerConnection {
    
    Protocol: sodep
    Interfaces: ToServerInterface
}