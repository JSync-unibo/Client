/**
 *
 *		Author	=> 	GruppoB{Gianmarco Spinaci, Michele Lorubio}
 *		Data	=>	04/05/2015
 *		Parent 	=> 	Client
 *
 **/

include "console.iol"
include "interfaces/interfaceLocalB.iol"
include "string_utils.iol"
include "types/Binding.iol"

//Embedding del servizio FileManager
outputPort ToFileManager {
	Interfaces: FileManagerInterface
}
embedded {
	Jolie: "fileManager.ol" in ToFileManager
}

init
{
	//legge il file xml e lo salva dentro alla variabile serverList

	//IMPORTANTE => il file di configurazione è da rinominare per trovarlo!
  	readFile@ToFileManager()(serversList)
}

main
{
	//fa il dump della variabile e la stampa
	valueToPrettyString@StringUtils( serversList )( result );
	println@Console( result )();

	//creazione variazione della variabile 

	l = #serversList.server;
	serversList.server[l].nome = "Server3";
	serversList.server[l].indirizzo = "localhost:8002";

	valueToPrettyString@StringUtils( serversList )( result );
	println@Console( result )();

	writeFile@ToFileManager(serversList)(x)
}