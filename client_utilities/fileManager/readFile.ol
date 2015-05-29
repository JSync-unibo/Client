/**
 *
 *		Author	=> 	GruppoB{Gianmarco Spinaci, Michele Lorubio}
 *		Data	=>	04/05/2015
 *		Parent 	=> 	Client
 *
 **/

include "../interfaces/interfaceLocalB.iol"
include "xml_utils.iol"
include "file.iol"

inputPort FromClient {
  	Location: "local"
  	Interfaces: FileManagerInterface
}

main
{

	/** 
	 *	legge il file xml e ritorna tutti i dati contenuti, sottoforma di una variabile 
	 *	può generare FileNotFound, in quel caso si crea una variabile vuota
	 *
	 * 	input-> 	void
	 * 	output->	variabile creata dal file xml
	 *
	 *  fault->		FileNotFound [ eccezione che viene sollevata quando non esiste il file, in questo caso si crea una variabile vuota]
	 **/
  	readFile(clientName)(response){
  		
  		//utilizzo uno scope per non ritornare un fault con la RR
  		//ma per dare la possibilità di tornare lo stesso la variabile
		scope( fileXml )
		{
		  	//se non esiste il file xml ritorna una variabile vuote
			install( FileNotFound => response.readed = false );

			//paramentri per la lettura del file
		  	file.filename = "config.xml";
			file.format = "binary";

			//lettura file xml di configurazione
			readFile@File(file)(configFile);

			//salva il file di configurazione nella variabile response
			xmlToValue@XmlUtils(configFile)(response);

			response.readed = true
		}
  	}
}