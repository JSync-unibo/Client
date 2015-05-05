/**
*
* Author => Gruppo A: Valentina Tosto, Chiara Babina
* Data => 04/05/2015
* Parent => Client
*
**/

include "console.iol"
include "Interfaces/interfaceLocalA.iol"


//Porta che collega il client con il cli attraverso l'embedding
inputPort FromCli {
  Location: "local"
  Interfaces: CliInterface 
}


main
{
  sendCommand(input)(response) {
  	if( input.command == "list servers") {
  		
  		response="ho ricevuto il comando"
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
  }
}