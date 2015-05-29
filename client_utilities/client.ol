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

// Porta che collega il client con il cli attraverso l'embedding
inputPort FromCli {

  	Location: "local"
  	Interfaces: CliInterface 
}

/** 
 *	legge il file xml e ritorna tutti i dati contenuti, sottoforma di una variabile 
 *	Può generare FileNotFound, in quel caso si segna che è vuota
 *
 *  l'intero file è salvato quindi nella variabile configList
 *
 *  fault->	FileNotFound [ eccezione che viene sollevata quando non esiste il file, in questo caso si scrive il file]
 **/
define readFile
{
	
	scope( fileXml )
	{
		undef( file );

	  	// Se non esiste il file xml setta la variabile come vuota
		install( FileNotFound => configList.vuoto = true );

		// Paramentri per la lettura del file
	  	file.filename = "config.xml";
		file.format = "binary";

		// Lettura file xml di configurazione
		readFile@File(file)(configFile);

		// Salva il file di configurazione nella variabile response
		xmlToValue@XmlUtils(configFile)(configList)
	}
}

/**
 *
 *	Scrive il file xml (se non lo trova non genera fault, ma lo crea per la prima volta)
 *  partendo dalla variabile configList 
 *  
 *
 */
define writeFile
{
	undef( file );

	stringXml.rootNodeName = "configList";
	stringXml.root << configList;

	// Trasforma la variabile in una stringa in formato xml
	valueToXml@XmlUtils(stringXml)(fileXml);

    // Paramentri della scrittura file
	file.content = fileXml;
  	file.filename = "config.xml";

	// Crea il file xml partendo dalla stringa nello stesso formato 
	writeFile@File(file)()
}

init
{
	// Legge il file xml
  	readFile;

  	// Se non esiste allora lo scrive
	if(!configList)

		writeFile
}

execution{ sequential }

main
{

	// Accetta una stringa e ritorna il risultato sempre sotto forma di stringa
  	sendCommand(input)(response) {

  		
  		input.regex = " ";

	  	split@StringUtils(input)(resultSplit);

 
  		// Ritorna la lista dei server e se non esiste ritorna una stringa di errore
	  	if( resultSplit.result[0] == "list" && resultSplit.result[1] == "servers") {

	  		// Refresh della variabile
	  		readFile;

			tmp = "";

			// Crea l'output
	  		for(i=0, i< #configList.server, i++) {
	  			
	  			tmp += configList.server[i].nome+ " --> "+configList.server[i].indirizzo+ "\n"
	  		};

	  		// Prepara la variabile response, cioè l'output che sarà visualizzato
	  		if(tmp==""){

	  			response = "Non esistono servers\n"
	  		}
	  		else
	  			response = tmp

	  	}

	  	// Aggiunge il nuovo server, con i relativi controlli nel caso non si inserisca nome ed indirizzo
	  	else if(resultSplit.result[0] == "addServer") {
	  		
	  		if(!is_defined( resultSplit.result[1] )) {

	  			response = "Si prega di inserire nome ed indirizzo del server\n"
	  		}

	  		else if(!is_defined( resultSplit.result[2] )) {

	  			response = "Si prega di inserire l'indirizzo del server\n"
	  		}

	  		else {

				readFile;

		  		size = #configList.server;

		  		configList.server[size].nome = resultSplit.result[1];
		  		configList.server[size].indirizzo = resultSplit.result[2];

		  		writeFile;

				response= "Server aggiunto\n"
			}
	  	}

	  	// Ritorna la lista delle repositories locali e se non sono presenti ritorna una stringa di avviso
	  	else if(resultSplit.result[0] == "list" && resultSplit.result[1] == "reg_repos") {

	  		readFile;
	  		temp ="";

	  		for(j = 0, j < #configList.localRepo, j++) {

	  			temp += configList.localRepo[i].nome + " " + configList.localRepo[i].versione + " " + configList.localRepo[i].file + "\n"
	  		};

	  		if(temp == "") {

	  			response = "Non sono presenti repositories locali\n"
	  		} 
	  		else
	  			response = temp
	  	}

	  	// Se il comando non è riconosciuto
	  	else
	  		response = "Not recognized command.\n"
	  	

  	}
}