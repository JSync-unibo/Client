/*
*
* Author => Gruppo LOBSTER
* Data => 21/06/2015
* Parent => Client
* 
*/


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

  	for(k=0, k<#configList.server, k++) {
  		
  		if( name == serverName ) {

  			ServerConnection.location = address
  		}
  	} 
}


/* 
 * Definizione della visita ricorsiva di tutte le cartelle
 */
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


/*
 * Inizializzazione della visita e chiamata ricorsiva
 */ 
define initializeVisita
{

	// Trovo la cartella iniziale del percorso relativo
	abDirectory.regex = "/";

	split@StringUtils(abDirectory)(resultSplit);

	rlDirectory = resultSplit.result[#resultSplit.result-1];

	undef( abDirectory.regex );

	// Predispongo la visita
	i = 1;
	visita;

	// Per ogni file prendo il percorso assoluto e lo splitto
	for(i=0, i<#folderStructure.file, i++){

		folderStructure.file[i].absolute.regex = "/";

		split@StringUtils(folderStructure.file[i].absolute)(resultSplit);

		// Per ogni elemento splittato, costruisco il suo percorso relativo
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


/*
 * Lettura del file Xml con la lista dei servers 
 */
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


/*
 * Scrittura del file Xml per inserire la lista dei servers 
 */  
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
 * Creazione delle cartelle, durante l'invio dei files,
 * nel caso non siano presenti
 */
define writeFilePath
{
	toSplit = toSend.filename;
	toSplit.regex = "/";

	split@StringUtils(toSplit)(splitResult);

	// Per ogni cartella nel percorso
	// Tranne per il file
	for(j=0, j<#splitResult.result-1, j++){

		dir += splitResult.result[j] + "/";

		mkdir@File(dir)()
	};

	writeFile@File(toSend)();

	undef( dir )
}