/**
*
* Author => Gruppo A: Valentina Tosto, Chiara Babina
* Data => 04/05/2015
* Parent => Client
*
**/

include "../client_utilities/interfaces/interfaceLocalA.iol"
include "types/Binding.iol"
include "string_utils.iol"
include "xml_utils.iol"
include "file.iol"

//Porta che collega il client con il cli attraverso l'embedding
inputPort FromCli {

  	Location: "local"
  	Interfaces: CliInterface 
}

define readFile
{
	scope( fileXml )
	{
		undef( file );

	  	//se non esiste il file xml ritorna una variabile vuote
		install( FileNotFound => configList.vuoto = true );

		//paramentri per la lettura del file
	  	file.filename = "config.xml";
		file.format = "binary";

		//lettura file xml di configurazione
		readFile@File(file)(configFile);

		//salva il file di configurazione nella variabile response
		xmlToValue@XmlUtils(configFile)(configList)
	}
}

define writeFile
{
	undef( file );

	stringXml.rootNodeName = "configList";
	stringXml.root << configList;

	//trasforma la variabile in una stringa in formato xml
	valueToXml@XmlUtils(stringXml)(fileXml);

    //paramentri della scrittura file
	file.content = fileXml;
  	file.filename = "config.xml";

	//crea il file xml partendo dalla stringa nello stesso formato 
	writeFile@File(file)()
}

init
{
  	readFile;

	if(!configList)

		writeFile
}

execution{ sequential }

main
{

  	sendCommand(input)(response) {

  		
  		input.regex = " ";

	  	split@StringUtils(input)(resultSplit);



  		/* 
  		 * ritorna la lista dei server
  		 * se non esiste ritorna una stringa di errore
  		 */
	  	if( resultSplit.result[0] == "list" && resultSplit.result[1] == "servers") {
<<<<<<< HEAD

	  		readFile;
=======
>>>>>>> origin/master

			tmp = "";

	  		for(i=0, i< #configList.server, i++) {
	  			
	  			tmp += configList.server[i].nome+ " --> "+configList.server[i].indirizzo+ "\n"
	  		};

	  		if(tmp==""){

	  			response = "Non esistono servers\n"
	  		}
	  		else
	  			response = tmp

	  	}

	  	else if(resultSplit.result[0] == "addServer") {
	  		
<<<<<<< HEAD
			readFile;
=======
<<<<<<< HEAD
	  		serversList.server[#serversList.server].nome = resultSplit.result[1];
	  		serversList.server[#serversList.server].indirizzo = resultSplit.result[2];
	  		
	  		writeFile@FileWriter(serversList)();
	  		response= "Server inserito"
=======
	  		//serversList.server[#serversList.server];
>>>>>>> origin/master

	  		size = #configList.server;


	  		configList.server[size].nome = resultSplit.result[1];
	  		configList.server[size].indirizzo = resultSplit.result[2];

<<<<<<< HEAD
	  		writeFile;
=======
			response= "Server inserito"
>>>>>>> origin/master
	  	}
>>>>>>> origin/master

			response= "server aggiunto\n"
	  	}

	  	else
	  		response = "Non hai inserito un comando valido\n"
	  	

  	}
}