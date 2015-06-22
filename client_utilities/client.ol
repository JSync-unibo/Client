/*
*
* Author => Gruppo LOBSTER
* Data => 04/05/2015
* 
* Client
*/

// Importazione delle interfacce e del servizio di utilities del client
include "../client_utilities/interfaces/localInterface.iol"
include "../client_utilities/interfaces/toServer.iol"


include "types/Binding.iol"
include "xml_utils.iol"
include "file.iol"
include "console.iol"

include "interfaces/utilities.ol"


// Porta che collega il client con il cli attraverso l'embedding
inputPort FromCli {

  	Location: "local"
  	Interfaces: CliInterface 
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
			  		readFile;

					if( is_defined( configList.server ) ){

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

	  				printRepo.directory = "localRepo";

	  				list@File(printRepo)(repo);

	  				if( is_defined( repo.result ) ){

						for(i = 0, i < #repo.result, i++){
							
							response += " " + repo.result[i] +"\n"
						}
					}
					
					else
			  			response = " There are no local repositories.\n"
			  	}

			  	else 
					throw(datiNonCorretti)
			}

		} ] { nullProcess }


		/*
	  	* Stampa la lista delle repositories(e relative sottocartelle) presenti in tutti i servers,
	  	* gestendo le eccezioni di dati inseriti non correttamente oppure di mancata connessione, 
	  	* dentro il for, per evitare che se il primo server non è connesso, salti tutta l'operazione
	  	*/
	  	[ listNewRepos (resultSplit)(response){

  			install( datiNonCorretti => response = " Not correct data.\n");

  			if(#resultSplit.result == 2) {
  				
	  			readFile;

	  			// Se sono presenti servers
	  			if( is_defined( configList.server ) ) {

			  		for (i=0, i<#configList.server, i++) {
			  			
			  			scope( currentServer )
			  			{
			  				//quando il client prova a connettersi al currentServer
			  				//può saltare l'eccezione nel caso in cui non ci sia nessun server in ascolto 
			  				//sulla stessa location
			  				install( IOException  => response += "       no reachable.\n" );

			  			  	// Inserito l'indirizzo per collegarsi al server
				  			ServerConnection.location = configList.server[i].address;

				  			//formatta l'output
				  			response += "\n - "+configList.server[i].name +":\n";
				  			
				  			// Ritorna al cli la lista di tutte le repo divise per ogni server
				  			// Può sollevare IOException
				  			listRepo@ServerConnection()(responseMessage);

				  			response += responseMessage+"\n"
			  			}
			  		}
			  	}
			  	else
					response = " There are no servers.\n"					
		  	}
		  	else 
				throw( datiNonCorretti )

	  	} ] { nullProcess }


		/*
		 * Cancella il server inserito, con un ulteriore ciclo riordina l'array di sottonodi, e si
		 * gestiscono le eccezioni in caso il server non esista oppure di dati inseriti non correttamente
		 */
		[ removeServer (resultSplit)(response){

			scope(dati) {

				//done fault, chiude l'operazione
				//viene chiamato quando è trovato un server
	  			install( done => nullProcess );

	  			install( datiNonCorretti => response = " Not correct data.\n");
	  			install( serverNonEsiste => response = " "+resultSplit.result[1]+" does not exist.\n" );

	  			if(#resultSplit.result == 2) {

	  				// Lettura del file xml, che ritorna la lista dei server
					readFile;
					
	  				scope( foundServer )
	  				{
	  					install( foundServer => response = " Success, removed server.\n"; throw( done ) );

	  				  	for(i = 0, i < #configList.server, i++) {

				  			// In caso trova il server da eliminare
				  			if(resultSplit.result[1] == configList.server[i].name){

				  				// Elimina il server selezionato
				  				undef(configList.server[i]);
				  				
				  				writeFile;

				  				//se trova il server chiama il fault che chiude tutta l'operazione
				  				throw( foundServer )
			  				}
	  					}
	  				};

	  				//nel caso in cui il server non esista
	  				throw(serverNonEsiste)
	  			}

	  			else 
			  		throw( datiNonCorretti )
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
			  		readFile;

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
			  		writeFile;

					response= " Success, server added.\n"
				}

				else 
					throw(datiNonCorretti)
								
			}

	  	}] { nullProcess }


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
			  		serverName = resultSplit.result[1];
			  		message.repoName = resultSplit.result[2];
			  		message.localPath = resultSplit.result[3];

			  		readFile;
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

			  			// Visita la cartella "localPath"
			  			abDirectory = message.localPath;
			  			initializeVisita;

			  			// Ogni file viene trasformato nella variabile currentFile
			  			currentFile -> folderStructure.file[i];
			  			
			  			for(i=0, i<#folderStructure.file, i++){

			  				// Mi preparo per leggere il file
			  				readedFile.filename = currentFile.absolute;

			  				readFile@File( readedFile )(toSend.content);

			  				// Il nome del file è formato dal nome della repository create + il percorso relativo del file
			  				toSend.filename = message.repoName + currentFile.relative;

			  				// Invio il file al server
			  				sendFile@ServerConnection( toSend );

			  				// Riscrivo il file in modo da poter essere scritto in locale

			  				toSend.filename = "localRepo/" + toSend.filename;

			  				// Richiamo del metodo nel servizio utilities per creare
			  				// cartelle, nel caso non siano presenti
			  				writeFilePath
			  			};

			  			//write vers.txt
			  			toSend.filename = "localRepo/"+message.repoName+"/vers.txt";
			  			toSend.content = "0";

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

	  				serverName = resultSplit.result[1];
			  		message.repoName = resultSplit.result[2];

			  		readFile;
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


	  	/*
	  	 * Invio della repo locale (aggiornata) al server, sovrascrivendo
	  	 * quella presente online. Prima nel server si confrontano le due versioni
	  	 * (quella locale e quella online), in seguito vengono inviati i file uno per volta.
	  	 * Gestione delle eccezioni di mancata connessione al server o dati scritti non correttamente
	  	 *
	  	 */
	  	[ push (resultSplit)(response) {

	  		scope(dati) {

	  			install( IOException => response = " Connection error, the selected server not exist or is no reachable.\n" );
	  			install( datiNonCorretti => response = " Not correct data.\n" );
	  			install( FileNotFound => response = " "+ resultSplit.result[2] + " doesn't exists.\n");

	  			if(#resultSplit.result == 3) {

	  				// Salvo il nome della repository
	  				serverName = resultSplit.result[1];
			  		repoName = resultSplit.result[2];

			  		readFile;
			  		registro;

			  		// leggo il file di versione
			  		readedFile.filename = "localRepo/"+ repoName + "/vers.txt";
					readFile@File( readedFile )( toSend.content );

					// preparo il percorso da spedire al server
					with( readedFile ){

						//println@Console( .filename )();

					 	.filename.regex = "localRepo";
						.filename.replacement = "serverRepo";

						replaceAll@StringUtils(.filename)(toSend.filename);

						undef( .filename.regex );
						undef( .filename.replacement )

						//println@Console( .filename )()
					};

			  		// Invio dei dati al server, aspettando un messaggio di risposta	
	  				push@ServerConnection( toSend )(responseMessage);	

	  				// Si può inviare la push
	  				if(!responseMessage.error) {

	  					//visito la cartella
	  					abDirectory = "localRepo/"+ repoName;
			  			initializeVisita;

			  			currentFile -> folderStructure.file[i];

	  					// Controllo tutti i file nella cartella locale
						for(i=0, i<#folderStructure.file, i++){

						  	readedFile.filename = currentFile.absolute;

						  	//valutare se contiene vers.txt nel nome
						  	//il file di versione non è da mandare in scrittura
						  	with( currentFile ){
						  	  
						  	  	.absolute.substring = "vers.txt";
								contains@StringUtils(.absolute)(contain);

								undef( .absolute.substring );

								//se non è il file di versione
								if(!contain){

									// Preparo il file per la scrittura
								  	readFile@File( readedFile )(toSend.content);

								  	// Riscrivo il percorso relativo per inviarlo al server
								  	toSend.filename = repoName + .relative;
								  				
								  	//println@Console( " - " + toSend.filename + "\n - " +toSend.content )();

								  	// Invio il singolo file per la scrittura sul server			
								  	sendFile@ServerConnection( toSend )
								}

								// handling del file di versione
								else{

									//salvo il percorso in cui dovrei sovrascrivere il file di versione
									local.filename = .absolute;

									// cambio il percorso e pulisco la variabile
								 	.absolute.regex = "localRepo";
									.absolute.replacement = "serverRepo";

									replaceAll@StringUtils(.absolute)(toSend.filename);
									undef( .absolute.regex );
									undef( .absolute.replacement );

									//richiedo il file di versione 
									requestFile@ServerConnection(toSend.filename)(toSend);

									//scrivo il file di versione in locale
									local.content = toSend.content;
									writeFile@File(local)()
								}
						  	}
			  			}
	  				};

	  				response = responseMessage.message
				}

	  			else 
			  		throw( datiNonCorretti )
	  		}

	  	}] { undef( configList )}


	  	/*
	  	 * Accetta repoName, ricerca la sua struttura online
	  	 * per ogni file che trova richiede il contenuto al server
	  	 * ritorna il contenuto e va a sovrascrivere i file locali
	  	 */
	  	[ pull(resultSplit)(response) {

	  		scope(dati) {

	  			install( IOException => response = " Connection error, the selected server not exist or is no reachable.\n" );
	  			install( datiNonCorretti => response = " Not correct data.\n" );
	  			install( FileNotFound => response = " "+ resultSplit.result[2] + " doesn't exists.\n");

	  			if(#resultSplit.result == 3) {

	  				// Salvo il nome della repository
	  				serverName = resultSplit.result[1];
	  				message.repoName = resultSplit.result[2];

	  				readFile;

			  		registro;

			  		// Richiedo la totale struttura della cartella
	  				pull@ServerConnection(message.repoName)(responseMessage);

	  				// Aliasing
	  				requestedFileName -> responseMessage.folderStructure.file[i];

	  				// Richiedo il contenuto di ogni file
	  				for(i=0, i<#responseMessage.folderStructure.file, i++){

	  					// Ricevo i file uno per volta dal server
	  					requestFile@ServerConnection(requestedFileName)(toSend);

	  					// Cambio il nome della repo globale, con tutte le cartelle, da serverRepo a localRepo
	  					with( toSend.filename ){

	  						.replacement = "localRepo";
  							.regex = "serverRepo";

  							// Sostituzione del nome della repo globale per tutti i percorsi dei files
  							replaceAll@StringUtils(toSend.filename)(toSend.filename);

  							undef( .replacement );
  							undef( .regex )
	  					};

	  					// Richiamo della scrittura delle cartelle
	  					// nel caso non siano presenti
	  					writeFilePath
	  				};

	  				response = responseMessage.message
			  	}

			  	else
			  		throw( datiNonCorretti )
			}

	  	}] { 

	  		undef(configList); 
	  		undef( responseMessage ) 

	  		}

	  	/*
	  	 * Errore de togliere...
	  	 */
	  	[ error( resultSplit )( response ) {

	  		response = " Not a recognized command. \n"

	  	}] { undef( variableName ) }
  	
}