/*
*
* Author => Gruppo LOBSTER
* Data => 26/06/2015
* 
* Parent => Cli
*
* Servizio di utilities che, per mezzo delle input choices, accetta
* un comando dall'utente, esegue le operazioni richieste e ritorna
* una risposta.
*/

// Importazione delle interfacce 
include "../client_utilities/interfaces/localInterface.iol"
include "../client_utilities/interfaces/toServer.iol"


include "types/Binding.iol"
include "xml_utils.iol"
include "file.iol"
include "console.iol"

// Importazione del servizio contenente i "define" richiamati dalle operazioni
include "clientDefine.ol"


// Porta che collega il clientUtilities con il cli tramite l'embedding
inputPort FromCli {

  	Location: "local"
  	Interfaces: CliInterface 
}


execution { concurrent }

main
{


		/*
  		 * Ritorna la lista dei Servers,
  		 * se è vuota ritorna una stringa di errore
  		 */
  		[ listServers( resultSplit )( response ) {

	  		scope( dati ) {

	  			// Nel caso in cui i dati inseriti non siano corretti
	  			install( datiNonCorretti => response = " Not correct data.\n" );

	  			if(#resultSplit.result == 2) {

	  				// Lettura del file xml (richiamata dal servizio clientDefine), 
	  				// con risultato la variabile contenente i Servers
			  		readFile;

			  		// Se la lista non è vuota
					if(is_defined( configList.server )){

						// Crea l'output con il nome ed indirizzo dei Servers, prelevati dal file xml
				  		for(i = 0, i < #configList.server, i++) {
				  			
				  			response += " " + configList.server[i].name + " - "+ configList.server[i].address + "\n"
				  		}

				  	}

			  		// Messaggio di errore, se la lista è vuota
			  		else
						response = " There are no servers.\n"
			  	}

			  	else 
			  		throw( datiNonCorretti )
			}
			  	
		} ] { nullProcess }



		/* 
	  	 * Ritorna la lista delle repositories locali,
	  	 * se non sono presenti ritorna una stringa di errore
	  	 */
		[ listRegRepos( resultSplit )( response ) {

	  		scope( dati ) {
	  			 
	  			// Nel caso in cui i dati inseriti non siano corretti
	  			install( datiNonCorretti => response = " Not correct data.\n" );
				
	  			if(#resultSplit.result == 2) {

	  				// Directory dove cercare le repositories
	  				printRepo.directory = "localRepo";

	  				// Lista delle repo presenti dentro la directory principale
	  				list@File( printRepo )( repo );

	  				// Se esistono delle repositories, viene stampato il loro nome
	  				if(is_defined( repo.result )){

						for(i = 0, i < #repo.result, i++){
							
							response += " " + repo.result[i] + "\n"
						}
					}
					
					// Se la lista è vuota, ritorna un messaggio di errore
					else
			  			response = " There are no local repositories.\n"
			  	}

			  	else 
					throw( datiNonCorretti )
			}

		} ] { nullProcess }
	  


	  	/* 
	  	 * Aggiunge il nuovo Server, con i relativi controlli nel caso non si inseriscano
	  	 * i dati corretti oppure se il Server già esiste
	  	 */
	  	[ addServer( resultSplit )( response ) {
	  		
	  		scope( dati ) {
	  			
	  			// Nel caso in cui i dati inseriti non siano corretti
	  			install( datiNonCorretti => response = " Not correct data.\n");

	  			// Salta un eccezione anche se esiste già il Server con lo stesso nome
	  			install( serverDoppio => response = " "+ resultSplit.result[1] + " name is already in use.\n" );

	  			// Salta un eccezione anche se esiste il Server con lo stesso indirizzo
	  			install( serverDoppio2 => response = " "+ resultSplit.result[2] + " address is already in use.\n" );

	  			if(#resultSplit.result == 3) {

	  				// Lettura del file xml (richiamata dal servizio clientDefine), 
	  				// con risultato la variabile contenente i Servers
			  		readFile;

					for(i = 0, i < #configList.server, i++) {

						// Controllo se il Server da inserire è già presente nella lista
						if(resultSplit.result[1] == configList.server[i].name) {
							
							// Sollevata l'eccezione di Server doppio
							throw( serverDoppio )
						}

						else if(resultSplit.result[2] == configList.server[i].address) {

							throw( serverDoppio2 )
						}

					};

					// Inserisco il nuovo Server nel primo spazio libero, in coda
			  		size = #configList.server;

			  		// Assegnando al nuovo Server il nome ed indirizzo scritti in input
			  		configList.server[size].name = resultSplit.result[1];
			  		configList.server[size].address = resultSplit.result[2];

			  		// Scrittura del file xml (richiamata dal servizio clientDefine),
				  	// per salvare la modifica apportata
				  	writeFile;

					response= " Success, server added.\n"
				}

				else 
					throw(datiNonCorretti)
								
			}

	  	}] { nullProcess }



		/*
		 * Cancella il Server inserito, gestendo le eccezioni in caso esso non esista 
		 * oppure di dati inseriti non correttamente.
		 */
		[ removeServer( resultSplit )( response ){

			scope( dati ) {

				// L'eccezione "done" è sollevata quando si chiude l'operazione
				// ed è stato eliminato il Server
	  			install( done => nullProcess );

	  			// Nel caso in cui i dati inseriti non siano corretti
	  			install( datiNonCorretti => response = " Not correct data.\n");

	  			// Sollevata nel caso in cui non esiste il Server da cancellare
	  			install( serverNonEsiste => response = " " + resultSplit.result[1] + " does not exist.\n" );

	  			if(#resultSplit.result == 2) {

	  				// Lettura del file xml (richiamata dal servizio clientDefine), 
	  				// con risultato la variabile contenente i Servers
					readFile;
					
	  				scope( foundServer )
	  				{
	  					// Sollevata il Server richiesto viene eliminato
	  					install( foundServer => response = " Success, removed server.\n"; 

	  							 throw( done )

	  						    );

	  				  	for(i = 0, i < #configList.server, i++) {

				  			// Se trova il Server da eliminare, confrontando i loro nomi
				  			if(resultSplit.result[1] == configList.server[i].name){

				  				// Lo elimina (rendendolo indefinito)
				  				undef( configList.server[i] );
				  				
				  				// Scrittura del file xml (richiamata dal servizio clientDefine),
				  				// per salvare la modifica apportata
				  				writeFile;

				  				// Infine viene sollevata l'eccezione di Server trovato ed eliminato
				  				throw( foundServer )
			  				}
	  					}
	  				};

	  				// Sollevata se il Server non è presente 
	  				throw( serverNonEsiste )
	  			}

	  			else 
			  		throw( datiNonCorretti )
	  		}
	  	} ] { nullProcess }


		
	   /*
	  	* Stampa la lista delle repositories presenti in tutti i Servers.
	  	* Sono gestite le eccezioni di dati inseriti non correttamente e di mancata connessione, 
	  	* dentro il for, per evitare che se il primo Server non è connesso, salti tutta l'operazione
	  	*/
	  	[ listNewRepos( resultSplit )( response ){

	  		scope( dati ) {
	  			
		  		// Nel caso in cui i dati inseriti non siano corretti
	  			install( datiNonCorretti => response = " Not correct data.\n");

	  			if(#resultSplit.result == 2) {
	  				
	  				// Lettura del file xml (richiamata dal servizio clientDefine), 
		  			// con risultato la variabile contenente i Servers
		  			readFile;

		  			// Se la lista non è vuota
		  			if(is_defined( configList.server )) {

				  		for (i=0, i<#configList.server, i++) {
				  			
				  			scope( currentServer )
				  			{
				  				// Quando si tenta la connessione con i Servers,
				  				// può saltare l'eccezione nel caso in cui uno di essi non sia in ascolto
				  				install( IOException  => response += "       no reachable.\n" );

				  			  	// Inserito l'indirizzo per collegarsi al Server corrente
					  			ServerConnection.location = configList.server[i].address;

					  			// Formatta l'output
					  			response += "\n - "+configList.server[i].name +":\n";

					  			// Operazione con il Server, aspettando la lista di tutte le sue repositories.
					  			// Può sollevare IOException
					  			listRepo@ServerConnection()( responseMessage );

					  			// Si crea l'output con l'elenco dei nomi dei Servers e le relative repositories
					  			response += responseMessage+"\n"
				  			}
				  		}
				  	}

				  	else
						response = " There are no servers.\n"					
			  	}

			  	else 
					throw( datiNonCorretti )
			}

	  	} ] { nullProcess }
	  	


	  	/*
 		 * Aggiunge una repository sia sul Client sia sul Server in questione, prelevando i files da un path locale.
 		 * Sono gestite le eccezioni in caso di dati scritti non correttamente, se il Server non è in ascolto
 		 * o sull'impossibilità di creare la repository
	  	 */
	  	[ addRepos( resultSplit )( response ){

	  		scope( ConnectException )
	  		{

	  			// Sollevata se il Server selezionato non è raggiungibile
	  			install( IOException => response = " Connection error, the selected server not exist or is no reachable.\n" );

	  			// Nel caso in cui i dati inseriti non siano corretti
	  			install( datiNonCorretti => response = " Not correct data.\n" );

	  			// Se si presentano errori nella creazione della repository
	  			install( AddError => response = responseMessage.message );

	  			if(#resultSplit.result == 4) {
	  				
		  			// Splitta il comando per: nome del Server, nome della 
		  			// repository da creare e percorso della directory locale
			  		serverName = resultSplit.result[1];
			  		message.repoName = resultSplit.result[2];
			  		message.localPath = resultSplit.result[3];

			  		// Lettura del file xml (richiamata dal servizio clientDefine), 
	  				// con risultato la variabile contenente i Servers
	  				readFile;

			  		// Assegnazione della location al nome del Server selezionato
			  		// (richiamato dal servizio clientDefine)
			  		registro;

			  		// Controllo del . nel nome della repository
			  		repositoryName = message.repoName;
			  		repositoryName.substring = ".";

			  		contains@StringUtils( repositoryName )( containsDot );

			  		// Se nel nome della repository è contenuto un . viene catturata l'eccezione addError
			  		// e inviato un messaggio di errore per un carattere non permesso
			  		if( containsDot ) {

			  			responseMessage.message = " Character '.' not allowed for repository name";
			  			throw( AddError )
			  		};

			  		// Invia tutto al Server, il quale ritorna un errore (se presente) 
			  		// ed un messaggio che descrive l'errore
			  		addRepository@ServerConnection( message )( responseMessage );

			  		if( responseMessage.error ) 

			  			throw( AddError )

			  		// Se non ritorna nessun errore
			  		else{

			  			// Si visita il percorso "localPath"
			  			abDirectory = message.localPath;

			  			// Visita ricorsiva di tutte le cartelle contenute nella directory locale
			  			// (richiamata dal servizio clientDefine)
			  			initializeVisita;

			  			// Ogni file viene trasformato nella variabile currentFile
			  			currentFile -> folderStructure.file[i];
			  			
			  			for(i=0, i<#folderStructure.file, i++){

			  				// Assegnazione del nome al percorso assoluto di ogni file
			  				readedFile.filename = currentFile.absolute;

			  				// Lettura e ritorno del contenuto del file
			  				readFile@File( readedFile )( toSend.content );

			  				// Assegnazione di un nuovo nome composto da quello della repository + il percorso relativo del file
			  				toSend.filename = message.repoName + currentFile.relative;

			  				// Invio di ogni singolo file al Server
			  				sendFile@ServerConnection( toSend );

			  				// Impostazione del nome del file da scrivere sul Client 
			  				toSend.filename = "localRepo/" + toSend.filename;

			  				// Creazione delle cartelle che contengono i files prelevati dalla directory locale
			  				// (richiamata dal servizio clientDefine)
			  				writeFilePath
			  			};

			  			// Scrittura del file di versione sulla repository appena creata sul Client
			  			toSend.filename = "localRepo/" + message.repoName + "/vers.txt";
			  			
			  			toSend.content = "0";

			  			writeFile@File( toSend )()

					};

					response = responseMessage.message
				}

				else
					throw( datiNonCorretti )
	  		}

	  	// Pulizia della configList dei Servers
	  	} ] { undef( configList ) }


 
	  	/*
	  	 * Cancellazione della repository sul Server e sul Client, gestendo le eccezioni in caso di Server non in ascolto
	  	 * oppure di dati inseriti non correttamente.
	  	 */
	  	[ delete( resultSplit )( response ){

			scope( dati ) {

	  			// Sollevata in due casi: se la cartella locale viene rimossa (ma non è presente sul Server)
	  			// e se la cartella locale non esiste ed il Server non è in ascolto
	  			install( IOException => 

	  				if(deleted)

	  					response = " Success, removed only local repository.\n"

	  				else

	  					response = " Connection error, the selected server not exist or is no reachable.\n" 

	  			);

	  			// Nel caso in cui i dati inseriti non siano corretti
	  			install( datiNonCorretti => response = " Not correct data.\n" );

	  			if(#resultSplit.result == 3) {

	  				serverName = resultSplit.result[1];
			  		message.repoName = resultSplit.result[2];

			  		// Lettura del file xml (richiamata dal servizio clientDefine), 
	  				// con risultato la variabile contenente i Servers
	  				readFile;

			  		// Assegnazione della location al nome del Server selezionato
			  		// (richiamato dal servizio clientDefine)
			  		registro;
	  				
	  				// Eliminazione della cartella locale, se presente
			  		deleteDir@File( "localRepo/" + message.repoName )( deleted );

	  				// Invio dei dati al Server, per eliminare la repository su di esso
	  				// ed aspetta un messaggio di risposta	
	  				delete@ServerConnection( message )( responseMessage );	

	  				// Se non ci sono errori di cancellazione nel Server
	  				// e se la cartella locale è stata eliminata
	  				if(!responseMessage.error && deleted) 

	  					// Stampa del messaggio di cancellazione avvenuta su entrambi
			  			response = responseMessage.message
			  		

			  		// Se ci sono errori nell'eliminazione della cartella sul Server
			  		// ma la cartella locale è stata cancellata
			  		else if(responseMessage.error && deleted)

			  			response = " Success, removed only local repository.\n"
			  		
			  		// Nel caso in cui la cartella non sia presente nè sul Client nè sul Server
			  		else if(responseMessage.error)
			  			
			  			// Stampa del messaggio di cartella inesistente
			  			response = responseMessage.message
			  		
	  			}

	  			else 
			  		throw( datiNonCorretti )
	  		}

	  	// Pulizia della configList dei Servers
	  	}] { undef( configList ) }



	  	/*
	  	 * Invio della repository locale (aggiornata) al Server, sovrascrivendo
	  	 * quella presente online. 
	  	 * - Prima nel Server si confrontano le due versioni, se quella locale è
	  	 * maggiore o uguale a quella online si procede con l'operazione
	  	 * - I files della repository sono inviati uno per volta
	  	 * - Se la versione locale è minore di quella online, bisognerà prima effettuare una pull.
	  	 * Sono gestite le eccezioni in caso di mancata connessione al server, dati scritti non correttamente
	  	 * o di repository non esistente
	  	 */
	  	[ push( resultSplit )( response ) {

	  		scope( dati ) {

	  			// Sollevata se il Server selezionato non è raggiungibile
	  			install( IOException => response = " Connection error, the selected server not exist or is no reachable.\n" );

	  			// Nel caso in cui i dati inseriti non siano corretti
	  			install( datiNonCorretti => response = " Not correct data.\n" );

	  			// Sollevata se la repository da inviare non esiste
	  			install( FileNotFound => response = " "+ resultSplit.result[2] + " doesn't exists.\n");

	  			if(#resultSplit.result == 3) {

	  				
	  				serverName = resultSplit.result[1];
			  		repoName = resultSplit.result[2];

			  		// Lettura del file xml (richiamata dal servizio clientDefine), 
	  				// con risultato la variabile contenente i Servers
	  				readFile;

			  		// Assegnazione della location al nome del Server selezionato
			  		// (richiamato dal servizio clientDefine)
			  		registro;

			  		// Settate le variabili per l'operazione di increase:
			  		// - il paramentro "id" serve come riferimento delle variabili globali del Server,
			  		// per indicare, in questo caso, gli scrittori
			  		// - il parametro "operation" serve per indicare, in caso di errore, l'operazione
			  		// da eseguire, prima di effettuare la push
			  		globalVar.id = 0;

			  		globalVar.operation = "Pull";

			  		// Richiesta per l'accesso in sezione critica, inviando le variabili appena descritte
			  		increaseCount@ServerConnection( globalVar )( responseMessage );

			  		// Se l'operazione è negata, ritorna un messaggio di errore
			  		if(responseMessage.error) {

			  			response = responseMessage.message
			  		}

			  		// Altrimenti si procede con il trasferimento dei files
			  		else {

				  		// Lettura del file di versione, contenuta nella repo selezionata
				  		readedFile.filename = "localRepo/" + repoName + "/vers.txt";

						readFile@File( readedFile )( toSend.content );

						// Si modifica il nome del file di versione da spedire, sostituendo
						// il nome della repository del Client, con quella del Server 
						with( readedFile ){

						 	.filename.regex = "localRepo";
							.filename.replacement = "serverRepo";

							replaceAll@StringUtils( .filename )( toSend.filename );

							undef( .filename.regex );
							undef( .filename.replacement )

						};

				  		// Invio del file di versione al Server, aspettando un messaggio di risposta	
		  				push@ServerConnection( toSend )( responseMessage );	

		  				// Si può inviare la push
		  				if(!responseMessage.error) {

		  					// Visita ricorsiva della repository da inviare
		  					// (richiamata dal servizio clientDefine)
		  					abDirectory = "localRepo/" + repoName;

				  			initializeVisita;

				  			// Ogni file viene trasformato nella variabile currentFile
				  			currentFile -> folderStructure.file[i];

							for(i=0, i<#folderStructure.file, i++){

								// Assegnazione del nome al percorso assoluto di ogni file
							  	readedFile.filename = currentFile.absolute;

							  	// Valutare se il nome del file è quello della versione,
							  	// in tal caso non è da inviare al Server per la scrittura
							  	with( currentFile ){
							  	  
							  	  	.absolute.substring = "vers.txt";

									contains@StringUtils( .absolute )( contain );

									undef( .absolute.substring );

									// Se non è il file di versione
									if(!contain){

										// Lettura del file, che ritorna il contenuto
									  	readFile@File( readedFile )( toSend.content );

									  	// Si riscrive il percorso relativo per inviarlo al Server
									  	toSend.filename = repoName + .relative;

									  	// Trasferimento di ogni file al Server			
									  	sendFile@ServerConnection( toSend )
									}

									// Per gestire il file di versione
									else{

										// Viene salvato il percorso in cui 
										// dovrebbe essere sovrascritto il file di versione
										local.filename = .absolute;

										// Si cambia il percorso dalla repository del Client con quella del Server
									 	.absolute.regex = "localRepo";
										.absolute.replacement = "serverRepo";

										replaceAll@StringUtils( .absolute )( toSend.filename );

										// Si puliscono le variabili
										undef( .absolute.regex );
										undef( .absolute.replacement );

										// Si invia la richiesta del file di versione al Server
										requestFile@ServerConnection( toSend.filename )( toSend );

										// Scrittura del file di versione sulla repository locale
										local.content = toSend.content;

										writeFile@File( local )()
									}
							  	}
				  			}
		  				}
		  			};

		  			// Dopo aver finito la push, si decrementa il numero di writers
		  			decreaseCount@ServerConnection( globalVar.id );

		  			response = responseMessage.message
		  			
				}

	  			else 
			  		throw( datiNonCorretti )
	  		}

	  	// Pulizia della configList dei Servers e del messaggio di risposta
	  	}] { 

	  		undef( configList ); 
	  		undef( responseMessage ) 

	  		}



	  	/*
	  	 * Richiesta di una repository sul Server, per sovrasciverla
	  	 * a quella locale, nel caso in cui si abbia una versione meno
	  	 * recente.
	  	 * Sono gestite le eccezioni in caso di assenza di connessione al Server,
	  	 * dati non corretti e di repository non esistente
	  	 */
	  	[ pull( resultSplit )( response ) {

	  		scope( dati ) {

	  			// Sollevata se il Server selezionato non è raggiungibile
	  			install( IOException => response = " Connection error, the selected server not exist or is no reachable.\n" );

	  			// Nel caso in cui i dati inseriti non siano corretti
	  			install( datiNonCorretti => response = " Not correct data.\n" );

	  			// Sollevata se la repository da inviare non esiste
	  			install( FileNotFound => response = " "+ resultSplit.result[2] + " doesn't exists.\n");

	  			if(#resultSplit.result == 3) {


	  				serverName = resultSplit.result[1];
			  		message.repoName = resultSplit.result[2];

			  		// Lettura del file xml (richiamata dal servizio clientDefine), 
	  				// con risultato la variabile contenente i Servers
	  				readFile;

			  		// Assegnazione della location al nome del Server selezionato
			  		// (richiamato dal servizio clientDefine)
			  		registro;

			  		// Settate le variabili per l'operazione di increase:
			  		// - il paramentro "id" serve come riferimento delle variabili globali del Server,
			  		// per indicare, in questo caso, i lettori
			  		// - il parametro "operation" serve per indicare, in caso di errore, l'operazione
			  		// da eseguire, prima di effettuare la pull
			  		globalVar.id = 1;

			  		globalVar.operation = "Push";

			  		// Richiesta per l'accesso in sezione critica, inviando le variabili appena descritte
			  		increaseCount@ServerConnection( globalVar )( responseMessage );

			  		// Se l'operazione è negata, ritorna un messaggio di errore
			  		if(responseMessage.error) {

			  			response = responseMessage.message
			  		}

			  		// Altrimenti si procede con la richiesta dei files
			  		else {

				  		// Si richiede la totale struttura della repository del Server
		  				pull@ServerConnection( message.repoName )( responseMessage );

		  				// Ogni file viene trasformato nella variabile requestedFileNam
		  				requestedFileName -> responseMessage.folderStructure.file[i];

		  				// Si richiede il contenuto di ogni file
		  				for(i=0, i<#responseMessage.folderStructure.file, i++){

		  					// Viene inviata la richiesta dei files, che ritornano uno alla volta
		  					requestFile@ServerConnection( requestedFileName )( toSend );

		  					// Si cambia il nome della repo globale, con tutte le cartelle, da serverRepo a localRepo
		  					with( toSend.filename ){

		  						.replacement = "localRepo";
	  							.regex = "serverRepo";

	  							// Sostituzione del nome della repo globale per tutti i percorsi dei files
	  							replaceAll@StringUtils( toSend.filename )( toSend.filename );

	  							undef( .replacement );
	  							undef( .regex )
		  					};

		  					
			  				// Creazione delle cartelle che contengono i files prelevati dalla directory locale
			  				// (richiamata dal servizio clientDefine)
			  				writeFilePath
		  				};

		  				// Dopo aver concluso l'operazione si decrementa il numero di readers
		  				decreaseCount@ServerConnection( globalVar.id );

		  				response = responseMessage.message
		  			}		  			
			  	}

			  	else
			  		throw( datiNonCorretti )
			}

		// Pulizia della configList dei Servers e del messaggio di risposta
	  	}] { 

	  		undef( configList ); 
	  		undef( responseMessage ) 

	  		}
  	
}