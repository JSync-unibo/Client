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

//Setta la location in base al nome e l'inidirizzo del server

define registro
{
	
  	IndirizzoServer.protocol = "sodep";
  	name -> serversList.server[i].nome;
  	address -> serverList.server[i].indirizzo;
  	for(i=0, i<#serversList.server, i++) {
  		
  		if( name == server.name ) {
  			
  			IndirizzoServer.location = "socket:// " + address
  		  
  		}
  	} 
}


main
{
	//scrive il file
	writeFile@FileWriter(serversList)()
}