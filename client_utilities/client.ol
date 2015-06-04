/*
*
* Author => Gruppo LOBSTER
* Data => 04/05/2015
* Parent => Client
*
*/

// Importazione delle interfacce
include "../client_utilities/interfaces/interfaceLocalA.iol"
include "../client_utilities/interfaces/toServer.iol"


include "types/Binding.iol"
include "string_utils.iol"
include "xml_utils.iol"
include "file.iol"
include "console.iol"

// Porta che collega il client con il cli attraverso l'embedding
inputPort FromCli {

  	Location: "local"
  	Interfaces: CliInterface 
}


/* 
 * Setta la location in base al nome ed indirizzo del server.
 * Per ogni server presente nella lista, se il nome è uguale
 * a quello scritto in input, allora setta la location del
 * server tramite il suo indirizzo preso dalla lista
 *
 */

define registro
{
	
  	ServerConnection.protocol = "sodep";

  	name -> configList.server[i].nome;
  	address -> configList.server[i].indirizzo;

  	for(i=0, i<#configList.server, i++) {
  		
  		if( name == message.serverName ) {
  			
  			ServerConnection.location = address
  		  
  		}
  	} 
}

/* 
 *	Legge il file xml e ritorna tutti i dati contenuti, sottoforma di una variabile.
 *	Può generare FileNotFound, in quel caso si segna che è vuota.
 *
 *  In seguito l'intero file è salvato nella variabile configList, convertendolo
 */
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

		// Salva il file di configurazione nella variabile configList
		xmlToValue@XmlUtils(configFile)(configList)
	}
}

/*
 *	Scrive il file xml (se non lo trova non genera fault, ma lo crea per la prima volta)
 *  partendo dalla variabile configList  
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
  		 * Ritorna la lista dei server,
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
	  	 * Ritorna la lista delle repositories locali,
	  	 * se non sono presenti ritorna una stringa di avviso
	  	 */
	  	else if( resultSplit.result[0] == "list" && resultSplit.result[1] == "reg_repos") {

	  		scope(dati) {
	  			
	  			install( datiNonCorretti => response = " I dati inseriti non sono corretti\n" );
				
				if(#resultSplit.result == 2) {
	  				
	  				tmp = "";

	  				printRepo.directory = "LocalRepo";

	  				list@File(printRepo)(repo);

					for(i = 0, i < #repo.result, i++){
						
						tmp += " " + repo.result[i] +"\n"
					
					};
					
					if(tmp==""){

			  			response = " Non esisto repositories locali\n"
			  		}
			  		else {
			  			response = tmp
			  		}
			  	
			  	}
			  	else {
					throw(datiNonCorretti)
				}
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
		 * Cancella il server inserito, con un ulteriore ciclo riordina l'array di sottonodi, e si
		 * gestiscono le eccezioni in caso il server non esista oppure di dati inseriti non correttamente
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

			  			// Il caso in cui trova il server da eliminare
			  			if(resultSplit.result[1] == configList.server[i].nome){

			  				// Lo elimina e riordina l'array
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
	  	* Stampa la lista delle repositories(e relative sottocartelle) presenti in tutti i servers,
	  	* gestendo le eccezioni di mancata connessione oppure di dati inseriti non correttamente
	  	*/
	  	else if(resultSplit.result[0] == "list" && resultSplit.result[1] == "new_repos" ){

	  		scope( ConnectException )
	  		{
	  			
	  			install( IOException => response = " Errore di connessione, il server e' inesistente o non raggiungibile\n" );
	  			install( datiNonCorretti => response = " I dati inseriti non sono corretti \n");

	  			if(#resultSplit.result == 2) {
	  				
		  			tmp = "";

			  		for (i=0, i< #configList.server, i++) {
			  			
			  			// Inserito l'indirizzo per collegarsi al server
			  			ServerConnection.location = configList.server[i].indirizzo;

			  			tmp += " - "+configList.server[i].nome +":\n";
			  			
			  			registro;
			  			listRepo@ServerConnection()(responseMessage);

			  			tmp += responseMessage  + " "			
			  		};

			  		response = tmp

			  	}
			  	else {

			  		throw( datiNonCorretti )
			  	}
	  		}
	  	}


	  	/*
 		 * Aggiunge una repository al server in questione, gestendo le eccezioni riguardo l'assenza del server 
 		 * o sull'impossibilità di creare la repository
	  	 */
	  	else if(resultSplit.result[0] == "addRepository"){

	  		scope( ConnectException )
	  		{

	  			install( IOException => response = " Errore di connessione, il server e' inesistente o non raggiungibile\n" );
	  			install( datiNonCorretti => response = " I dati inseriti non sono corretti\n" );
	  			install( AddError => response = " Impossibile creare la repository scelta\n" );

	  			if(#resultSplit.result == 4) {
	  				
		  			// Splitta il comando per: nome del server, nome della repository e nome della cartella locale
			  		message.serverName = resultSplit.result[1];
			  		message.repoName = resultSplit.result[2];
			  		message.localPath = resultSplit.result[3];

			  		// Richiama il registro definito all'inizio
			  		registro;

			  		// Invia tutto al server, il quale ritorna un errore (se presente) 
			  		// ed un messaggio che descrive l'errore
			  		addRepository@ServerConnection(message)(responseMessage);

			  		if(responseMessage.error) throw( AddError )

			  		// Altrimenti si prendono tutti i file della cartella richiesta
			  		// ed ognuno di essi viene convertito in binario per leggere il contenuto,
			  		// in seguito si rinomina secondo il nome scritto in input e si invia al server
			  		else{

			  			//creo la repository locale
			  			mkdir@File("localRepo/"+message.repoName)(success);

			  			//cerco tutti i file nella cartella locale da caricare
			  			toSearch.directory = message.localPath;
			  			list@File(toSearch)(listaFile);

			  			//controllo tutti i file nella cartella locale
			  			for(i=0, i<#listaFile.result, i++){

			  				//preparo il file per la lettura
			  				readedFile.filename = message.localPath+"/"+listaFile.result[i];
			  				readedFile.format ="binary";

			  				//preparo il file per la scrittura
			  				readFile@File(readedFile)(toSend.content);
			  				toSend.filename = message.repoName+"/"+listaFile.result[i];

			  				//invio il singolo file per la scrittura sul server
			  				sendFile@ServerConnection( toSend );

			  				//scrivo il singolo file nella repo locale
			  				toSend.filename = "localRepo/"+toSend.filename;
			  				writeFile@File(toSend)()
			  			}
					};

					response = responseMessage.message
				}

				else
					throw( datiNonCorretti )
	  		}
	  	}


	  	/*
	  	 * Cancellazione della repository nel server e nel client, gestendo le eccezioni in caso di server irraggiungibile
	  	 * oppure di dati inseriti non correttamente.
	  	 */
	  	else if(resultSplit.result[0] == "delete"){

			scope(dati) {

	  			install( IOException => response = " Errore di connessione, il server e' inesistente o non raggiungibile\n" );
	  			install( datiNonCorretti => response = " I dati inseriti non sono corretti\n" );

	  			if(#resultSplit.result == 3) {

	  				message.serverName = resultSplit.result[1];
			  		message.repoName = resultSplit.result[2];

			  		// Si richiama il registro per prelevare i dati del server
			  		registro;
	  				
	  				// Invio dei dati al server, aspettando un messaggio di risposta	
	  				delete@ServerConnection(message)(responseMessage);	

	  				// Se si è verificato un errore, viene stampato il messaggio relativo
	  				if(responseMessage.error) {

			  			response = responseMessage.message
			  		}

			  		// Altrimenti viene richiamato il metodo per eliminare la cartella locale
			  		else {

			  			deleteDir@File("LocalRepo/"+message.repoName)(deleted);

			  			response = responseMessage.message
			  		}
	  			}

	  			else 
			  		throw( datiNonCorretti )
	  		}
	  	}

	  	// Messaggio di avviso di comando scritto non correttamente
	  	else
	  		response = " Comando non riconosciuto\n"
  	}
}