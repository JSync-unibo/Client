/*
 *
 * Author => Gruppo LOBSTER
 * Data => 04/05/2015
 * Parent => Client
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

type FileRequestType: void {

    .filename: string
    .content: string
    .folder?: string
}

/*
 * Tipo che si riferisce alla risposta che riceve il Client, 
 * che è composta da un errore, se presente, e da un messaggio 
 * che descrive l'errore
 */
type ResponseMessage: void {

    .error: bool
    .message?: string

    .folderStructure?:void{ 

        .file*:string
    }
}

type GlobalVar: void {

    .count1: string 
    .count2: string
    .operation: string
}


//Interfaccia fra il client ed il server
interface ToServerInterface { 

    RequestResponse: 

        listRepo(void)(string),

        addRepository(ToServerType)(ResponseMessage),
        push(FileRequestType)(ResponseMessage),
        increaseCountPull(GlobalVar)(ResponseMessage),
        increaseCountPush(GlobalVar)(ResponseMessage),
        pull(string)(ResponseMessage),
        delete(ToServerType)(ResponseMessage),

        requestFile(string)(FileRequestType)

    OneWay: sendFile( FileRequestType ),
            decreaseCountPull(string),
            decreaseCountPush(string)

}

// Porta che collega il client con il server
outputPort ServerConnection {
    Protocol: sodep
    Interfaces: ToServerInterface
}