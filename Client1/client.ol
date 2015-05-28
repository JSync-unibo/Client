/**
 *
 *		Author	=> 	GruppoB{Gianmarco Spinaci, Michele Lorubio}
 *		Data	=>	04/05/2015
 *		Parent 	=> 	Client
 *
 **/

include "console.iol"
include "../client_utilities/interfaces/interfaceLocalB.iol"
include "string_utils.iol"
include "types/Binding.iol"

init
{
    //legge il file xml e lo salva dentro alla variabile serverList

    //IMPORTANTE => il file di configurazione è da rinominare per trovarlo!
	readFile@FileReader()(serversList);

    
    serverName = "Server1"
}

//setta la location in base al nome e l'inidirizzo del server

define registro
{
	
    IndirizzoServer.protocol = "sodep";

    name -> serversList.server[i].nome;
    address -> serversList.server[i].indirizzo;

    for(i=0, i<#serversList.server, i++) {

        if( name == serverName ) {

            IndirizzoServer.location = "socket://" + address

        }
    } 
}


main
{
    //valueToPrettyString@StringUtils(serversList)(stringa);
    //println@Console( stringa )();

    registro;
    println@Console( IndirizzoServer.location )()
    //scrive il file
    //writeFile@FileWriter(serversList)()
}