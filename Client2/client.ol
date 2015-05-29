/**
*
* Author => Gruppo A: Valentina Tosto, Chiara Babina
* Data => 04/05/2015
* Parent => Client
*
**/

include "console.iol"

include "../client_utilities/interfaces/interfaceLocalA.iol"
include "../client_utilities/interfaces/interfaceLocalB.iol"
include "string_utils.iol"
include "types/Binding.iol"

//Porta che collega il client con il cli attraverso l'embedding
inputPort FromCli {
  Location: "local"
  Interfaces: CliInterface 
}

//Embedding del servizio FileManager

outputPort FileReader {
  Interfaces: FileManagerInterface
}

embedded {
  Jolie: "../client_utilities/fileManager/readFile.ol" in FileReader
}

outputPort FileWriter {
  Interfaces: FileManagerInterface
}

embedded {
  Jolie: "../client_utilities/fileManager/writeFile.ol" in FileWriter
}

init
{
  //legge il file xml e lo salva dentro alla variabile serverList

  //IMPORTANTE => il file di configurazione è da rinominare per trovarlo!
    readFile@FileReader()(serversList)
}

main
{
  
  sendCommand(input)(response) {

	  	if( input.command == "list servers") {
	  		for(i=0, i< #serversList.server, i++) {
	  			
	  			response += serversList.server[i].nome+ " ----> "+serversList.server[i].indirizzo+ "\n"
	  		}
	  	}
	  	else if(input.command == "lista new_repos") {
	  		
	  		response= "non ho ricevuto il comando"
	  	}
	  	else if(input.command == "lista reg_repos") {
	  		response= "non ho ricevuto il comando"
	  	}

	  	else if(input.command == "addServer") {
	  		response= "non ho ricevuto il comando"
	  	}

	  	else if(input.command == "removeServer") {
	  		response= "non ho ricevuto il comando"
	  	}

	  	else if(input.command == "addRepository") {
	  		response= "non ho ricevuto il comando"
	  	}

	  	else if(input.command == "push") {
	  		response= "non ho ricevuto il comando"
	  	}
	  	else if(input.command == "pull") {
	  		response= "non ho ricevuto il comando"
	  	}
	  	else if(input.command == "delete") {
	  		response= "non ho ricevuto il comando"
	  	}
	  	else if(input.command == "close") {
	  		response= "chiudi"
	  	}
	  	else
	  		response = "Non hai inserito un comando valido"
	  	}	

}