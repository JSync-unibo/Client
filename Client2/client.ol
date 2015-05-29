/**
*
* Author => Gruppo A: Valentina Tosto, Chiara Babina
* Data => 04/05/2015
* Parent => Client
*
**/

include "console.iol"
<<<<<<< HEAD
include "interfaces/interfaceLocalA.iol"
include "interfaces/interfaceLocalB.iol"
include "string_utils.iol"
include "types/Binding.iol"

=======
include "Interfaces/interfaceLocalA.iol"
include "interfaces/interfaceLocalB.iol"
include "string_utils.iol"
include "types/Binding.iol"
>>>>>>> origin/master

//Porta che collega il client con il cli attraverso l'embedding
inputPort FromCli {
  Location: "local"
  Interfaces: CliInterface 
}

//Embedding del servizio FileManager
<<<<<<< HEAD
<<<<<<< HEAD
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


execution{ concurrent }
=======
outputPort ToFileManager {
=======
outputPort FileReader {
>>>>>>> 3121e39388054fbf619d3ee295cf3a4cbd0ef216
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
execution{ concurrent }

init
{
	
	//legge il file xml e lo salva dentro alla variabile serverList

	//IMPORTANTE => il file di configurazione è da rinominare per trovarlo!
  	readFile@FileReader()(serversList)
}

>>>>>>> origin/master

main
{
  
<<<<<<< HEAD
    
    sendCommand(input)(response) {

      if( input.command == "list servers") {

        for (i=0, i<#serversList.server, i++) {
            response += serversList.server[i].nome + " " + serversList.server[i].indirizzo + "\n"
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
        response = "chiudi"
      }
      else {
        response = "non hai inserito un comando valido"
      }
  }
=======

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
>>>>>>> origin/master
}