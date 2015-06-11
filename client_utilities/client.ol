/*
*
* Author => Gruppo LOBSTER
* Data => 04/05/2015
* Parent => Client
*
*/

// Importazione delle interfacce
include "../client_utilities/interfaces/localInterface.iol"
include "../client_utilities/interfaces/toServer.iol"


include "types/Binding.iol"
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

  	readXmlFile@FileManager()(configList);

  	name -> configList.server[i].name;
  	address -> configList.server[i].address;

  	for(i=0, i<#configList.server, i++) {
  		
  		if( name == message.serverName ) {

  			ServerConnection.location = address
  		  
  		}
  	} 
}

execution{ concurrent }

main
{
		/*
  		 * Ritorna la lista dei server,
  		 * se non esiste ritorna una stringa di errore
  		 */
  		[ listServers ( resultSplit )( response ) {

	  		scope(dati) {

	  			// Nel caso in cui i dati inseriti non siano corretti
	  			install( datiNonCorretti => response = " Not correct data.\n" );

	  			if(#resultSplit.result == 2) {

	  				// Lettura del file xml, con risultato la variabile contenente i server
			  		readXmlFile@FileManager()(configList);


					if( #configList.server>0 ){

						// Crea l'output
				  		for(i = 0, i < #configList.server, i++) {
				  			
				  			response += " "+ configList.server[i].name+ " - "+configList.server[i].address+ "\n"
				  		}

				  	}
			  		// Prepara la variabile response, cioè l'output che sarà visualizzato
			  		else
						response = " There are no servers.\n"
			  	}
			  	else 
			  		throw( datiNonCorretti )
			}
			  	
		} ] { nullProcess }


		/* 
	  	 * Ritorna la lista delle repositories locali,
	  	 * se non sono presenti ritorna una stringa di avviso
	  	 */
		[ listRegRepos ( resultSplit )( response ) {

	  		scope(dati) {
	  			
	  			install( datiNonCorretti => response = " Not correct data.\n" );
				
				if(#resultSplit.result == 2) {

	  				printRepo.directory = "LocalRepo";

	  				list@File(printRepo)(repo);

	  				if( #repo.result>0 ){

						for(i = 0, i < #repo.result, i++){
							
							response += " " + repo.result[i] +"\n"
						
						}
					}
					
					else
			  			response = " There are no local repositories.\n"
			  	}
			  	else {
					throw(datiNonCorretti)
				}
			}

		} ] { nullProcess }

		
	  	/* 
	  	 * Aggiunge il nuovo server, con i relativi controlli nel caso non si inseriscano
	  	 * i dati corretti oppure se il server già esiste
	  	 */
	  	[ addServer (resultSplit)(response) {
	  		
	  		scope(dati) {
	  			
	  			// Salta un eccezione anche se esiste già il server con lo stesso nome
	  			install( datiNonCorretti => response = " Not correct data.\n");
	  			install( serverDoppio => response = " "+resultSplit.result[1]+" name is already in use.\n" );

	  			//response = message.result[1] +"\n"+message.result[2]
	  			if(#resultSplit.result == 3) {

	  				// Lettura del file xml, con risultato la variabile contenente i server
			  		readXmlFile@FileManager()(configList);

					// Controllo in tutti i server salvati se esiste già lo stesso nome
					// Se esiste salta il fault e rompe l'intero scope
					// Non avviene nessun inserimento
					for(i = 0, i < #configList.server, i++) {

						if(resultSplit.result[1] == configList.server[i].name) {
							
							throw( serverDoppio )
						}
					};

					// Inserisco il nuovo server nel primo spazio libero
			  		size = #configList.server;

			  		configList.server[size].name = resultSplit.result[1];
			  		configList.server[size].address = resultSplit.result[2];

			  		// Scrittura del file xml per aggiungere il nuovo server
			  		writeXmlFile@FileManager(configList)();

					response= " Success, server added.\n"
				}

				
				else {

					throw(datiNonCorretti)
				}				
			}

	  	}] { nullProcess }


		/*
		 * Cancella il server inserito, con un ulteriore ciclo riordina l'array di sottonodi, e si
		 * gestiscono le eccezioni in caso il server non esista oppure di dati inseriti non correttamente
		 */
		[ removeServer (resultSplit)(response){

			scope(dati) {
	  			
	  			install( datiNonCorretti => response = " Not correct data.\n");
	  			install( serverNonEsiste => response = " "+resultSplit.result[1]+" does not exist.\n" );

	  			if(#resultSplit.result == 2) {

	  				// Lettura del file xml, che ritorna la lista dei server
					readXmlFile@FileManager()(configList);
			
					// Setta la variabile di server trovato a false
	  				trovato = false;

			  		for(i = 0, i < #configList.server, i++) {

			  			// In caso trova il server da eliminare
			  			if(resultSplit.result[1] == configList.server[i].name){

			  				// Lo elimina e riordina l'array
			  				undef(configList.server[i]);
			  				
			  				for(j = i, j < #configList.server, j++){

			  					configList.server[i] = configList.server[j]
			  				};
							
							// Setta la variabile a true, per segnalare che è stato trovato
			  				trovato = true
			  			}
	  				};

	  				// Se è stato trovato scrive nuovamente il file, con il server rimosso
	  				if(trovato){
	  					
	  					writeXmlFile@FileManager(configList)();

	  					response = " Success, removed server.\n"
	  				}
	  				
	  				else
	  					throw(serverNonEsiste)

	  			}
	  			else 
			  		throw( datiNonCorretti )
	  		}

	  	} ] { nullProcess }


	   /*
	  	* Stampa la lista delle repositories(e relative sottocartelle) presenti in tutti i servers,
	  	* gestendo le eccezioni di mancata connessione oppure di dati inseriti non correttamente
	  	*/
	  	[ listNewRepos (resultSplit)(response){

	  		scope( ConnectException )
	  		{
	  			
	  			install( IOException => response = " Connection error, the selected server not exist or is no reachable.\n" );
	  			install( datiNonCorretti => response = " Not correct data.\n");

	  			if(#resultSplit.result == 2) {
	  				
		  			tmp = "";

			  		for (i=0, i< #configList.server, i++) {
			  			
			  			// Inserito l'indirizzo per collegarsi al server
			  			ServerConnection.location = configList.server[i].address;

			  			tmp += " - "+configList.server[i].name +":\n";
			  			
			  			registro;
			  			listRepo@ServerConnection()(responseMessage);

			  			tmp += responseMessage  + " "			
			  		};

			  		if(tmp==""){

			  			response = " There are no servers.\n"
			  		}
			  		else {
			  			response = tmp
			  		}

			  	}
			  	else {

			  		throw( datiNonCorretti )
			  	}
	  		}
	  	} ] { nullProcess }


	  	/*
 		 * Aggiunge una repository al server in questione, gestendo le eccezioni riguardo l'assenza del server 
 		 * o sull'impossibilità di creare la repository
	  	 */
	  	[ addRepos (resultSplit)(response){

	  		scope( ConnectException )
	  		{

	  			install( IOException => response = " Connection error, the selected server not exist or is no reachable.\n" );
	  			install( datiNonCorretti => response = " Not correct data.\n" );
	  			install( AddError => response = responseMessage.message );

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

			  			// Creo la repository locale
			  			mkdir@File("LocalRepo/"+message.repoName)(success);

			  			// Cerco tutti i file nella cartella locale da caricare
			  			toSearch.directory = message.localPath;
			  			
			  			list@File(toSearch)(listaFile);

			  			// Controllo tutti i file nella cartella locale
			  			for(i=0, i<#listaFile.result, i++){

			  				// Preparo il file per la lettura
			  				readedFile.filename = message.localPath+"/"+listaFile.result[i];
			  				
			  				readedFile.format ="binary";

			  				// Preparo il file per la scrittura
			  				readFile@File(readedFile)(toSend.content);
			  				
			  				toSend.filename = message.repoName+"/"+listaFile.result[i];

			  				// Invio il singolo file per la scrittura sul server
			  				sendFile@ServerConnection( toSend );

			  				// Scrivo il singolo file nella repo locale
			  				toSend.filename = "LocalRepo/"+toSend.filename;
			  				
			  				writeFile@File(toSend)()
			  			};
			  			
			  			//creazione file di versione locale
			  			toSend.filename = "LocalRepo/"+message.repoName+"/vers.txt";
			  			toSend.content = "0.1";

			  			writeFile@File(toSend)()
					};

					response = responseMessage.message
				}

				else
					throw( datiNonCorretti )
	  		}
	  	} ] { undef( configList ) }


	  	/*
	  	 * Cancellazione della repository nel server e nel client, gestendo le eccezioni in caso di server irraggiungibile
	  	 * oppure di dati inseriti non correttamente.
	  	 */
	  	[ delete (resultSplit)(response){

			scope(dati) {

	  			install( IOException => response = " Connection error, the selected server not exist or is no reachable.\n" );
	  			install( datiNonCorretti => response = " Not correct data.\n" );

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

	  	}] { undef( configList ) }


	  	[ push (resultSplit)(response) {

	  		scope(dati) {

	  			install( IOException => response = " Connection error, the selected server not exist or is no reachable.\n" );
	  			install( datiNonCorretti => response = " Not correct data.\n" );

	  			if(#resultSplit.result == 3) {

	  				message.serverName = resultSplit.result[1];
			  		message.repoName = resultSplit.result[2];

			  		// Si richiama il registro per prelevare i dati del server
			  		registro;
	  				
	  				// Invio dei dati al server, aspettando un messaggio di risposta	
	  				push@ServerConnection(message)(responseMessage);	

	  				// Se si è verificato un errore, viene stampato il messaggio relativo
	  				if(responseMessage.error) {

			  			response = responseMessage.message
			  		}

			  		else{

			  			// Creo la repository locale
			  			//mkdir@File("LocalRepo/"+message.repoName)(success);

			  			// Cerco tutti i file nella cartella locale da caricare
			  			toSearch.directory = "LocalRepo/"+message.repoName;
			  			
			  			list@File(toSearch)(listaFile);

			  			println@Console( listaFile.result )();
			  			// Controllo tutti i file nella cartella locale
			  			for(i=0, i<#listaFile.result, i++){

			  				// Preparo il file per la lettura
			  				readedFile.filename = message.repoName+ "/"+listaFile.result[i];
			  				
			  				readedFile.format ="binary";

			  				// Preparo il file per la scrittura
			  				readFile@File(readedFile)(toSend.content);
			  				
			  				toSend.filename = message.repoName+"/"+listaFile.result[i];

			  				// Invio il singolo file per la scrittura sul server
			  				sendFile@ServerConnection( toSend )

			  				// Scrivo il singolo file nella repo locale
			  				//toSend.filename = "LocalRepo/"+toSend.filename;
			  				
			  				//writeFile@File(toSend)()
			  			}
			  			
			  			//creazione file di versione locale
			  			//toSend.filename = "LocalRepo/"+message.repoName+"/vers.txt";
			  			//toSend.content = "0.1";

			  			//writeFile@File(toSend)()
					};

					response = responseMessage.message
				}

	  			else 
			  		throw( datiNonCorretti )
	  		}



	  	}] { undef( configList )}

	  	// Messaggio di avviso di comando scritto non correttamente
	  	/*
	  	else{
	  		response = " "+resultSplit.result[0]+" is not a recognized command. \n"
	  	}
  	*/
}