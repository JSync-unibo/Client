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
outputPort FileReader {
	Interfaces: FileManagerInterface
}
embedded {
	Jolie: "fileManager/readFile.ol" in FileReader
}

outputPort FileWriter {
	Interfaces: FileManagerInterface
}
embedded {
	Jolie: "fileManager/writeFile.ol" in FileWriter
}

init
{
	//legge il file xml e lo salva dentro alla variabile serverList

	//IMPORTANTE => il file di configurazione è da rinominare per trovarlo!
  	readFile@FileReader()(serversList)
}

main
{
	//fa il dump della variabile e la stampa
	

	len = #serversList.server;

	serversList.server[len].nome = "Server3";
	serversList.server[len].indirizzo = "localhost:8002";

	valueToPrettyString@StringUtils( serversList )( result );
	println@Console( result )();

	writeFile@FileWriter(serversList)(x);

	println@Console( x )()
}