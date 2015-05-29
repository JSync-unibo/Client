/**
*
* Author => Gruppo A: Valentina Tosto, Chiara Babina
* Data => 04/05/2015
* Parent => Client
*
**/

include "console.iol"

include "../client_utilities/interfaces/interfaceLocalA.iol"
//include "interfaces/interfaceLocalB.iol"
include "string_utils.iol"
include "types/Binding.iol"

//Porta che collega il client con il cli attraverso l'embedding
inputPort FromCli {

  	Location: "local"
  	Interfaces: CliInterface 
}

init
{
	serversList;
  	readFile
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

define readFile{
	
	scope( fileXml )
	{

		undef( file );

	  	//se non esiste il file xml ritorna una variabile vuote
		install( FileNotFound => serversList );//response.readed = false );

		//paramentri per la lettura del file
	  	file.filename = "config.xml";
		file.format = "binary";

		//lettura file xml di configurazione
		readFile@File(file)(configFile);

		//salva il file di configurazione nella variabile response
		xmlToValue@XmlUtils(configFile)(serversList)
	}
}

//execution{ sequential }
main
{


  	sendCommand(input)(response) {


  		valueToPrettyString@StringUtils(serversList)(response)

  		/*
  		input.regex = " ";

	  	split@StringUtils(input)(resultSplit);

	  	if( resultSplit.result[0] == "list" && resultSplit.result[1] == "servers") {

	  		tmp = "";

	  		//readFile@FileReader()(serversList);


	  		for(i=0, i< #serversList.server, i++) {
	  			
	  			tmp += serversList.server[i].nome+ " --> "+serversList.server[i].indirizzo+ "\n"
	  		};

	  		if(tmp==""){

	  			response = "Non esistono servers\n"
	  		}
	  		else
	  			response = tmp
	  	}

	  	else if(resultSplit.result[0] == "addServer"){

	  		size = #serversList.server;

	  		serversList.server[size].nome = resultSplit.result[1];
	  		serversList.server[size].indirizzo = resultSplit.result[2];

	  		writeFile@FileWriter(serversList)();

			response= "Server inserito\n"
	  	}

	  	else

	  		reponse = "comando errato\n"
		*/
	  	/*
	  	else if(input.command == "lista new_repos") {
	  		
	  		response= "non ho ricevuto il comando"
	  	}
	  	else if(input.command == "lista reg_repos") {
	  		response= "non ho ricevuto il comando"
	  	}

	  	else if(resultSplit.result[0] == "addServer") {
	  		
	  		//serversList.server[#serversList.server];

	  		size = #serversList.server;

	  		serversList.server[size].nome = resultSplit.result[1];
	  		serversList.server[size].indirizzo = resultSplit.result[2];

	  		writeFile@FileWriter(serversList)();

			response= "Server inserito\n"
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

		*/
  	}
}