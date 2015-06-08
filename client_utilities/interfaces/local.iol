/**
*
* Author => Gruppo A: Valentina Tosto, Chiara Babina
* Data => 04/05/2015
* Parent => Client
*
**/

include "string_utils.iol"

//Interfaccia fra il cli ed il client
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

type xmlFileFormat: void { 

    .server*:void{

        .name:string
        .address:string
    }
}

interface fileManager {

    RequestResponse: 

        readXmlFile(void)(xmlFileFormat),
        writeXmlFile(xmlFileFormat)(void)
}

outputPort ToClient{
    Interfaces: CliInterface
}

embedded {
    Jolie: "../client_utilities/client.ol" in ToClient
}