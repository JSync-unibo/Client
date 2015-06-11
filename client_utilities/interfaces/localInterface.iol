/**
*
* Author => Gruppo A: Valentina Tosto, Chiara Babina
* Data => 04/05/2015
* Parent => Client
*
**/

include "string_utils.iol"

// Interfaccia fra il cli ed il client, con i comandi possibili
interface CliInterface {

    RequestResponse: 

        listServers( SplitResult )( string ), 
        listRegRepos( SplitResult )( string ),
        addServer( SplitResult )( string ),
        removeServer( SplitResult )( string ),
        listNewRepos( SplitResult )( string ),
        addRepos( SplitResult )( string ),
        pull( SplitResult )( string ),
        push( SplitResult )( string ),
        delete( SplitResult )( string )

}

// Formato del file xml, che contiene un sottotipo server
// (che può anche non esserci) con i relativi dati
type xmlFileFormat: void { 

    .server*:void{

        .name:string
        .address:string
    }
}


// Tipo che stampa il percorso delle cartelle visitate
type fileStructureFormat: void {

    .folder*: string
}

// Interfaccia fra il client ed il file manager
interface FileManager {

    RequestResponse: 

        readXmlFile(void)(xmlFileFormat),
        writeXmlFile(xmlFileFormat)(void),
        visitFolder(string)(fileStructureFormat)
}

// Porta che collega il client con il cli, attraverso l'embedding
outputPort ToClient{
    
    Interfaces: CliInterface
}

embedded {
    Jolie: "../client_utilities/client.ol" in ToClient
}

// Porta che collega il client con il file manager da cui legge/scrive il file xml, sempre con l'embedding
outputPort FileManager{
    
    Interfaces: FileManager
}

embedded {
    Jolie: "../client_utilities/fileManager.ol" in FileManager
}