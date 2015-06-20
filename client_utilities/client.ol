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

  	name -> configList.server[i].name;
  	address -> configList.server[i].address;

  	for(i=0, i<#configList.server, i++) {
  		
  		if( name == message.serverName ) {

  			ServerConnection.location = address
  		  
  		}
  	} 
}

define visita
{
	 
    root.directory = abDirectory;

	list@File(root)(subDir);

	for(j = 0, j < #subDir.result, j++) {

		// Salva il percorso assoluto e relativo
		cartelle.sottocartelle[i].abNome = abDirectory + "/" + subDir.result[j];

		newRoot.directory = cartelle.sottocartelle[i].abNome;

		// Viene controllato se la cartella ha delle sottocartelle. Se non ha sottocartelle
		// Viene salvato tutto il percorso per arrivare in quella cartella
		list@File( newRoot )( last );

		if(#last.result == 0)  {

			len = #folderStructure.file;

			folderStructure.file[len].absolute = cartelle.sottocartelle[i].abNome
		};

		i++
    };

	i = 1;

	// Finchè una sottocartella è già stata visitata, si passa alla successiva
	while( cartelle.sottocartelle[i].mark == true && i < #cartelle.sottocartelle) {

		i++
	};

	// Se non si è arrivati alla fine dell'array cartelle, l'attributo mark della cartella viene
	// Settato a true, e si richiama il metodo visita
	if( is_defined( cartelle.sottocartelle[i].abNome )) {

		cartelle.sottocartelle[i].mark = true;

		abDirectory = cartelle.sottocartelle[i].abNome;

		i = #cartelle.sottocartelle;

		visita
	}
}

define initializeVisita{

	//trovo la cartella iniziale del percorso relativo
	abDirectory.regex = "/";

	split@StringUtils(abDirectory)(resultSplit);

	rlDirectory = resultSplit.result[#resultSplit.result-1];

	undef( abDirectory.regex );

	//predispongo la visita
	i = 1;
	visita;

	// get relative path
	for(i=0, i<#folderStructure.file, i++){

		folderStructure.file[i].absolute.regex = "/";

		split@StringUtils(folderStructure.file[i].absolute)(resultSplit);

		for(j=0, j<#resultSplit.result, j++){

			if( resultSplit.result[j] == rlDirectory ){

				while( j<#resultSplit.result-1 ){

					folderStructure.file[i].relative += "/" + resultSplit.result[j+1];

					j++
				}
			}
		};

		undef( folderStructure.file[i].absolute.regex )
	}
}

define readFile
{
	scope( fileXml )
	{
		undef(configList);
		undef(file);
	  	// Se non esiste il file xml setta la variabile come vuota
		install( FileNotFound => configList.vuoto = true  );

		// Paramentri per la lettura del file
	  	file.filename = "config.xml";
		file.format = "binary";

		// Lettura file xml di configurazione
		readFile@File(file)(configFile);

		// Salva il file di configurazione nella variabile configList
		xmlToValue@XmlUtils(configFile)(configList)
		
	}
 }
  
 define writeFile		
 {
   		
	stringXml.rootNodeName = "configList";
	stringXml.root << configList;
	
	//stringXml.indent = true;

	// Trasforma la variabile in una stringa in formato xml
	valueToXml@XmlUtils(stringXml)(fileXml);

    // Paramentri della scrittura file
	file.content = fileXml;
  	file.filename = "config.xml";

	// Crea il file xml partendo dalla stringa nello stesso formato 
	writeFile@File(file)();
	undef( configList );
	undef(file)
		
 }

 	/*
	 * Visita ricorsivamente le cartelle locali del client, passando
	 * la cartella iniziale del client e ritornando la stampa di tutte le sottocartelle
	 
define visitFolder
	{

		directory.regex = "/";
		split@StringUtils(directory)(directoryPath);

		numberPath = #directoryPath.result;

		// Nome della cartella iniziale "LocalRepo"
		radice.directory.name = directoryPath.result[numberPath];

		// Viene segnata con true, perchè già è stata visitata
		radice.directory.mark = true;

		i = 1; 

		// Richiamo del metodo (ricorsivo)
		visita
  		
  	}*/
  	
  	/*
init
{
	// Legge il file xml
  	readFile;

  	// Se non esiste allora lo scrive
	if(!configList)

		writeFile
}
*/

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

				/*if(#resultSplit.result == 2) {

					// Si richiama l'operazione del File manager per visitare tutte le cartelle in LocalRepo
					visitFolder@FileManager("LocalRepo")(folderList);

					// Se non ritorna alcuna cartella viene stampato un messaggio di avviso
					if(#folderList.folder == 0) {

						response = " There aren't folders. \n"
					}

					// Altrimenti si stampano tutte le cartelle e sottocartelle
					else {

						for(i = 0, i< #folderList, i++) {

							response = folderList.folder
						}
					}

			  	}*/
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
					readFile;
			
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
	  					
	  					writeFile;

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
		  			readFile;

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

			  			abDirectory = message.localPath;

			  			initializeVisita;

			  			//valueToPrettyString@StringUtils(folderStructure)(response);

			  			for(i=0, i<#folderStructure.file, i++){

			  				//mi preparo per leggere il file
			  				readedFile.filename = folderStructure.file[i].absolute;
			  				readedFile.format = "binary";
			  				readFile@File( readedFile )(toSend.content);

			  				//il nome del file è formato dal nome della repository create + il percorso relativo del file
			  				toSend.filename = message.repoName + folderStructure.file[i].relative;

			  				//invio il file 
			  				sendFile@ServerConnection( toSend )
			  			}

			  			//qui fare la pull

			  			/*
			  			// Creo la repository locale
			  			mkdir@File("LocalRepo/"+message.repoName)(success);

			  			directory = message.localPath;

			  			// Visita ricorsivamente la cartella locale, crea due percorsi
			  			initializeVisita;

			  			// Controllo tutti i file nella cartella locale
			  			for(i=0, i<#folderList.folder, i++){

			  				readedFile.filename = folderList.folder[i].absolute;

			  				readedFile.format ="binary";

			  				// Preparo il file per la scrittura
			  				readFile@File( readedFile )(toSend.content);

			  				//toSend.filename = folderList.folder[i].relative;
			  				//aggiunta del parametro folder
			  				toSend.folder = message.repoName;
			  				
			  				// Invio il singolo file per la scrittura sul server
			  				// perchè funzioni la copia bisogna commentare la riga
			  				sendFile@ServerConnection( toSend );

			  				// Scrivo il singolo file nella repo locale
			  				toSend.filename = "LocalRepo/"+message.repoName+"/"+toSend.filename;

			  				//rimozione paramentro folder per il writeFile
			  				undef( toSend.folder );

			  				writeFile@File(toSend)()
			  				*/
			  				
			  			//};
			  			
			  			/*
			  			//creazione file di versione locale
			  			toSend.filename = "LocalRepo/"+message.repoName+"/vers.txt";
			  			toSend.content = 0;

			  			writeFile@File(toSend)()
			  			*/
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


	  	[ push (resultSplit)(response) {

	  		scope(dati) {

	  			install( IOException => response = " Connection error, the selected server not exist or is no reachable.\n" );
	  			install( datiNonCorretti => response = " Not correct data.\n" );

	  			if(#resultSplit.result == 3) {

	  				message.serverName = resultSplit.result[1];
			  		message.repoName = resultSplit.result[2];

			  		readFile;
			  		// Si richiama il registro per prelevare i dati del server
			  		registro;
	  				
	  				
	  				// Se si è verificato un errore, viene stampato il messaggio relativo
	  				/*if(responseMessage.error) {

			  			response = responseMessage.message
			  		}

			  		else{*/
			  			directory = "LocalRepo/"+message.repoName;

			  			i = 1;

			  			visita;
			  			//visitFolder@FileManager("LocalRepo/"+message.repoName)(listaFile);

			  			// Controllo tutti i file nella cartella locale
			  			for(i=0, i<#folderList.folder, i++){

			  				readedFile.filename = folderList.folder[i].absolute;
			  				
			  				readedFile.format ="binary";

			  				// Preparo il file per la scrittura
			  				readFile@File( readedFile )(toSend.content);

			  				toSend.filename = folderList.folder[i].relative;
			  				//aggiunta del parametro folder
			  				toSend.folder = message.repoName;

			  				if(toSend.filename == "vers.txt") {

			  					// Invio dei dati al server, aspettando un messaggio di risposta	
	  							push@ServerConnection(toSend)(responseMessage);	

	  							if(responseMessage.error) {

	  								response = responseMessage.message
	  							}

	  							else {

	  								// Controllo tutti i file nella cartella locale
						  			for(i=0, i<#folderList.folder, i++){

						  				readedFile.filename = folderList.folder[i].absolute;

						  				readedFile.format ="binary";

						  				// Preparo il file per la scrittura
						  				readFile@File( readedFile )(toSend.content);

						  				toSend.filename = folderList.folder[i].relative;
						  				//aggiunta del parametro folder
						  				toSend.folder = message.repoName;
						  				
						  				// Invio il singolo file per la scrittura sul server
						  				// perchè funzioni la copia bisogna commentare la riga
						  				sendFile@ServerConnection( toSend );

						  				// Scrivo il singolo file nella repo locale
						  				toSend.filename = "LocalRepo/"+message.repoName+"/"+toSend.filename;

						  				//rimozione paramentro folder per il writeFile
						  				undef( toSend.folder );

						  				writeFile@File(toSend)()
			  				
			  						}

	  							}
			  				}
			  				
			  			};
			  			
			  			//creazione file di versione locale
			  			//toSend.filename = "LocalRepo/"+message.repoName+"/vers.txt";
			  			//toSend.content = "0.1";

			  			//writeFile@File(toSend)()
					//};

					response = responseMessage.message
				}

	  			else 
			  		throw( datiNonCorretti )
	  		}



	  	}] { undef( configList )}


	  	[ pull(resultSplit)(response) {

	  		scope(dati) {

	  			install( IOException => response = " Connection error, the selected server not exist or is no reachable.\n" );
	  			install( datiNonCorretti => response = " Not correct data.\n" );

	  			if(#resultSplit.result == 3) {

	  				message.serverName = resultSplit.result[1];
			  		message.repoName = resultSplit.result[2];

			  		readFile;
			  		// Si richiama il registro per prelevare i dati del server
			  		registro;

			  		while(responseMessage.message == null) {

			  			pull@ServerConnection(message.repoName)(responseMessage)

			  		};

			  		response = "Success"
			  	}

			  	else
			  		throw( datiNonCorretti )
			}


	  	}]{ undef(configList) }



	  	[ error( resultSplit )( response ) {

	  		response = " Not a recognized command. \n"

	  	}] { nullProcess }
	  	// Messaggio di avviso di comando scritto non correttamente
	  	/*
	  	else{
	  		response = " "+resultSplit.result[0]+" is not a recognized command. \n"
	  	}
  	*/
}