/*
*
* Author => Gruppo LOBSTER
* Data => 04/05/2015
* Parent => Client
*
*/

include "../client_utilities/interfaces/localInterface.iol"
include "file.iol"
include "xml_utils.iol"
include "string_utils.iol"


// Porta che collega il file manager con il client
inputPort FromClient {
	
	Location: "local"
	Interfaces: FileManager
}

execution{ concurrent }


// Metodo visita per stampare tutte le cartelle locali del client
define visita
{
	 
    root.directory = directory;


	list@File(root)(subDir);

	for(j = 0, j < #subDir.result, j++) {

		// Salva il percorso della cartella
		cartelle.sottocartelle[i].nome = directory + "/" + subDir.result[j];

		newRoot.directory = cartelle.sottocartelle[i].nome;

		// Viene controllato se la cartella ha delle sottocartelle. Se non ha sottocartelle
		// Viene salvato tutto il percorso per arrivare in quella cartella
		list@File( newRoot )( last );

		if(#last.result == 0)  {

			stampa.cartelle[#stampa.cartelle] = cartelle.sottocartelle[i].nome

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
	if( is_defined( cartelle.sottocartelle[i].nome )) {

		cartelle.sottocartelle[i].mark = true;

		directory = cartelle.sottocartelle[i].nome;

		i = #cartelle.sottocartelle;

		visita

	} 

	// Se si è arrivati alla fine dell'array vengono stampati i percorsi finali
	else {

		for(k = 0, k < #stampa.cartelle, k++) {
			
			folderList.folder += stampa.cartelle[k]+ "\n"
		}
		
	}

}

main
{

	/* 
	 *	Legge il file xml e ritorna tutti i dati contenuti, sottoforma di una variabile.
	 *	Può generare FileNotFound, in quel caso si segna che è vuota.
	 *
	 *  In seguito l'intero file è salvato nella variabile configList, convertendolo
	 */
  	[readXmlFile()(serverList){

  		scope( fileXml )
		{

		  	// Se non esiste il file xml setta la variabile come vuota
			install( FileNotFound => undef( serverList ) );

			// Paramentri per la lettura del file
		  	file.filename = "config.xml";
			file.format = "binary";

			// Lettura file xml di configurazione
			readFile@File(file)(readedFile);

			// Salva il file di configurazione nella variabile configList
			xmlToValue@XmlUtils(readedFile)(serverList)

		}
  	}]{ 
  		undef(serverList);
  		undef(file) 
  	}

	/*
	 *	Scrive il file xml (se non lo trova non genera fault, ma lo crea per la prima volta)
	 *  partendo dalla variabile configList  
	 */
  	[writeXmlFile(serverList)(){

  		stringXml.rootNodeName = "serverList";
		stringXml.root << serverList;
		stringXml.indent = true;

		// Trasforma la variabile in una stringa in formato xml
		valueToXml@XmlUtils(stringXml)(fileXml);

	    // Paramentri della scrittura file
		file.content = fileXml;
	  	file.filename = "config.xml";

		// Crea il file xml partendo dalla stringa nello stesso formato 
		writeFile@File(file)()
  	}]{ 
  		undef(serverList);
  		undef(file) 
	}


	/*
	 * Visita ricorsivamente le cartelle locali del client, passando
	 * la cartella iniziale del client e ritornando la stampa di tutte le sottocartelle
	 */
	[visitFolder(directory)(folderList){

		directory.regex = '/';
		split@StringUtils(directory)(directoryPath);

		numberPath = #directoryPath.result;

		// Nome della cartella iniziale "LocalRepo"
		radice.directory.name = directoryPath.result[numberPath];

		// Viene segnata con true, perchè già è stata visitata
		radice.directory.mark = true;

		i = 1; 

		// Richiamo del metodo (ricorsivo)
		visita
  		
  	}]{ nullProcess }

}