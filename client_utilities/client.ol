/**
*
* Author => Gruppo A: Valentina Tosto, Chiara Babina
* Data => 04/05/2015
* Parent => Client
*
**/

include "console.iol"

include "../client_utilities/interfaces/interfaceLocalA.iol"
include "interfaces/interfaceLocalB.iol"
include "string_utils.iol"
include "types/Binding.iol"

//Porta che collega il client con il cli attraverso l'embedding
inputPort FromCli {

  	Location: "local"
  	Interfaces: CliInterface 
}

init
{
  	readFile@FileReader()(serversList);

  	if(!serversList.readed){

  		//undef( serversList.readed );

  		writeFile@FileWriter(serversList)()
  	}
}

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

  	sendCommand(input)(response) {

  		input.command.regex = " ";

	  	split@StringUtils(input.command)(resultSplit);

  		/* 
  		 * ritorna la lista dei server
  		 * se non esiste ritorna una stringa di errore
  		 */
	  	if( resultSplit.result[0] == "list_servers") {

	  		tmp = "";

	  		for(i=0, i< #serversList.server, i++) {
	  			
	  			tmp += serversList.server[i].nome+ " ----> "+serversList.server[i].indirizzo+ "\n"
	  		};

	  		if(!tmp){

	  			response = "Non esistono servers"
	  		}
	  		else
	  			response = tmp
	  	}


	  	else if(input.command == "lista new_repos") {
	  		
	  		response= "non ho ricevuto il comando"
	  	}
	  	else if(input.command == "lista reg_repos") {
	  		response= "non ho ricevuto il comando"
	  	}

	  	else if(resultSplit.result[0] == "addServer") {
	  		
	  		serverList.server[#serversList.server].nome = resultSplit.result[1];
	  		serverList.server[#serversList.server].indirizzo = resultSplit.result[2];

	  		writeFile@FileWriter(serverList)();
	  		response= "Server inserito"
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