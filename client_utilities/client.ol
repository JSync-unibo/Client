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

/** 
 *	legge il file xml e ritorna tutti i dati contenuti, sottoforma di una variabile 
 *	può generare FileNotFound, in quel caso si segna che è vuota
 *
 *  l'intero file è salvato quindi nella variabile configList
 *
 *  fault->		FileNotFound [ eccezione che viene sollevata quando non esiste il file, in questo caso si scrive il file]
 **/
define readFile
{
	
	scope( fileXml )
	{
		undef( file );

	  	//se non esiste il file xml setta la variabile come vuota
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

/**
 *
 *	scrive il file xml (se non lo trova non genera fault, ma lo crea per la prima volta)
 *  partendo dalla variabile configList 
 *  
 *
 */
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
	//legge il file xml
  	readFile;

  	//se non esiste allora lo scrive
	if(!configList)

		writeFile
}

execution{ sequential }

main
{

	//accetta una stringa e ritorna il risultato sempre sotto forma di stringa
  	sendCommand(input)(response) {

  		
  		input.regex = " ";

	  	split@StringUtils(input)(resultSplit);

  		/* 
  		 * ritorna la lista dei server
  		 * se non esiste ritorna una stringa di errore
  		 */
	  	if( resultSplit.result[0] == "list" && resultSplit.result[1] == "servers") {

	  		//refresh della variabile
	  		readFile;

			tmp = "";

			//crea l'output
	  		for(i=0, i< #configList.server, i++) {
	  			
	  			tmp += configList.server[i].nome+ " --> "+configList.server[i].indirizzo+ "\n"
	  		};

	  		//prepara la variabile response, che è l'output che verrà visualizzato
	  		if(tmp==""){

	  			response = "Non esistono servers\n"
	  		}
	  		else
	  			response = tmp

	  	}

	  	//aggiunge il nuovo server
	  	else if(resultSplit.result[0] == "addServer") {
	  		
			readFile;

	  		size = #configList.server;

	  		configList.server[size].nome = resultSplit.result[1];
	  		configList.server[size].indirizzo = resultSplit.result[2];

	  		writeFile;

			response= "server aggiunto\n"
	  	}

	  	//se il comando non è riuconosciuto
	  	else
	  		response = "Not recognized command.\n"
	  	

  	}
}