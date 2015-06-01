/**
*
* Author => Gruppo LOBSTER
* Data => 04/05/2015
* Parent => Client
*
**/

//interfacce
include "../client_utilities/interfaces/interfaceLocalA.iol"
include "../client_utilities/interfaces/toServer.iol"


include "types/Binding.iol"
include "string_utils.iol"
include "xml_utils.iol"
include "file.iol"

// Porta che collega il client con il cli attraverso l'embedding
inputPort FromCli {

  	Location: "local"
  	Interfaces: CliInterface 
}


//Setta la location in base al nome e l'inidirizzo del server

define registro
{
	
  	ServerConnection.protocol = "sodep";

  	name -> configList.server[i].nome;
  	address -> configList.server[i].indirizzo;

  	for(i=0, i<#configList.server, i++) {
  		
  		if( name == message.serverName ) {
  			
  			ServerConnection.location = "socket://" + address
  		  
  		}
  	} 
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

	/*
	 * Accetta una stringa e ritorna il risultato sempre sotto forma di stringa
	 */
  	sendCommand(input)(response) {

  		
  		input.regex = " ";

	  	split@StringUtils(input)(resultSplit);

 
  		/*
  		 * Ritorna la lista dei server 
  		 * se non esiste ritorna una stringa di errore
  		 */
	  	if( resultSplit.result[0] == "list" && resultSplit.result[1] == "servers") {

	  		scope(dati) {
	  			
	  			// Nel caso in cui i dati inseriti non siano corretti
	  			install( datiNonCorretti => response = " I dati inseriti non sono corretti\n" );

	  			if(#resultSplit.result == 2) {

			  		// Refresh della variabile
			  		readFile;

					tmp = "";

					// Crea l'output
			  		for(i = 0, i < #configList.server, i++) {
			  			
			  			tmp += " "+ configList.server[i].nome+ " - "+configList.server[i].indirizzo+ "\n"
			  		};

			  		// Prepara la variabile response, cioè l'output che sarà visualizzato
			  		if(tmp==""){

			  			response = " Non esistono servers\n"
			  		}
			  		else {
			  			response = tmp
			  		}
			  	}
			  	else 
			  		throw( datiNonCorretti )
			  	
			}
		}

		/* 
	  	 * Ritorna la lista delle repositories locali 
	  	 * se non sono presenti ritorna una stringa di avviso
	  	 */
	  	else if(resultSplit.result[0] == "list" && resultSplit.result[1] == "reg_repos") {

	  		scope(dati) {
	  			
	  			install( datiNonCorretti => response = " I dati inseriti non sono corretti\n" );

	  			if(#resultSplit.result == 2) {

			  		readFile;
			  		temp ="";

			  		for(j = 0, j < #configList.localRepo, j++) {

			  			temp += " "+configList.localRepo[i].nome + " " + configList.localRepo[i].versione + " " + configList.localRepo[i].file + "\n"
			  		};

			  		if(temp == "") {

			  			response = " Non sono presenti repositories locali\n"
			  		} 
			  		else {
			  			response = temp
			  		}
			  
			  	}
			  	else 
			  		throw( datiNonCorretti )
			}
		}

	  	/* 
	  	 * Aggiunge il nuovo server, con i relativi controlli nel caso non si inseriscano
	  	 * i dati corretti oppure se il server già esiste
	  	 */
	  	else if(resultSplit.result[0] == "addServer") {
	  		
	  		scope(dati) {
	  			
	  			// Salta un eccezione anche se esiste già il server con lo stesso nome
	  			install( datiNonCorretti => response = " I dati inseriti non sono corretti\n");
	  			install( serverDoppio => response = " Il nome del server inserito gia' esiste\n" );

	  			if(#resultSplit.result == 3) {

					readFile;

					// Controllo in tutti i server salvati se esiste già lo stesso nome
					// Se esiste salta il fault e rompe l'intero scope
					// Non avviene nessun inserimento
					for(i = 0, i < #configList.server, i++) {

						if(resultSplit.result[1] == configList.server[i].nome) {
							throw( serverDoppio )
						}
					};

					// Inserisco il nuovo server nel primo spazio libero
			  		size = #configList.server;

			  		configList.server[size].nome = resultSplit.result[1];
			  		configList.server[size].indirizzo = resultSplit.result[2];

			  		writeFile;

					response= " Server aggiunto\n"
				}

				else {
					throw(datiNonCorretti)
				}
				
			}
	  	}

		/*
		 * Cancella il server inserito
		 * con un ulteriore ciclo riordina l'array di sottonodi
		 */
		else if(resultSplit.result[0] == "removeServer"){

			scope(dati) {
	  			
	  			install( datiNonCorretti => response = " I dati inseriti non sono corretti\n" );
	  			install( serverNonEsiste => response = " Il server inserito non esiste\n" );

	  			if(#resultSplit.result == 2) {
					
					readFile;

	  				if( !is_defined( configList.server ) )

	  					throw( serverNonEsiste );

	  				trovato = false;

			  		for(i = 0, i < #configList.server, i++) {

			  			//il caso in cui trova il server da eliminare
			  			if(resultSplit.result[1] == configList.server[i].nome){

			  				//lo elimina e riordina l'array
			  				undef(configList.server[i]);

			  				for(j = i, j < #configList.server, j++){

			  					configList.server[i] = configList.server[j]
			  				};

							writeFile;

			  				trovato = true
			  			}
	  				};

	  				if(trovato)			
	  					response = " Server eliminato\n"
	  				
	  				else
	  					throw(serverNonEsiste)
	  			}
	  			else 
			  		throw( datiNonCorretti )
	  		}
	  	}

	  	/*
	  	else if(resultSplit.result[0] == "list" && resultSplit.result[1] == "new_repos" ){

	  		//nomeServer = resultSplit.result[2];

	  		//registro;

	  		//println@Console( string )(ServerConnection.location)
	  	}*/

	  	else if(resultSplit.result[0] == "addRepository"){

	  		scope( ConnectException )
	  		{
	  			// Salta questa eccezione quando non esiste il server 
	  			install( IOException => response = " Errore di connessione, server non raggiungibile o inesistente\n" );

	  			//undef( message.serverName );

		  		message.serverName = resultSplit.result[1];
		  		message.repoName = resultSplit.result[2];
		  		message.localPath = resultSplit.result[3];

		  		registro;

		  		addRepository@ServerConnection(message)(response)
	  		}
	  	}


	  	else
	  		response = " Comando non riconosciuto\n"
  	}
}