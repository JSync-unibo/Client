/**
 *
 *		Author	=> 	GruppoB{Gianmarco Spinaci, Michele Lorubio}
 *		Data	=>	04/05/2015
 *		Parent 	=> 	Client
 *
 **/

include "interfaces/interfaceLocalB.iol"
include "xml_utils.iol"
include "console.iol"
include "file.iol"


//servizio embeddato da client.ol

inputPort FromClient {
  	Location: "local"
  	Interfaces: FileManagerInterface
}

main
{

	filename = "config.xml";

	/** 
	 *	legge il file xml e ritorna tutti i dati contenuti, sottoforma di una variabile 
	 *	può generare FileNotFound, in quel caso si crea una variabile vuota
	 *
	 * 	input-> 	void
	 * 	output->	variabile creata dal file xml
	 *
	 *  fault->		FileNotFound [ eccezione che viene sollevata quando non esiste il file, in questo caso si crea una variabile vuota]
	 **/
  	[readFile()(response){

  		undef( file );

  		//utilizzo uno scope per non ritornare un fault con la RR
  		//ma per dare la possibilità di tornare lo stesso la variabile
		scope( fileXml )
		{
		  	//se non esiste il file xml ritorna una variabile vuote
			install( FileNotFound => response.readed = false );

			//paramentri per la lettura del file
		  	file.filename = filename;
			file.format = "binary";

			//lettura file xml di configurazione
			readFile@File(file)(configFile);

			//salva il file di configurazione nella variabile response
			xmlToValue@XmlUtils(configFile)(response);

			response.readed = true
		}
  	}]
  	{nullProcess}


  	/**
	 *
	 *	ri-scrive il file xml (se non lo trova non genera fault, ma lo crea per la prima volta)
  	 *
  	 *	input -> variabile "ConfigType"
  	 *	output -> boolean
  	 *
  	 *
  	 **/
  	[writeFile(variable)(isCreated){

  		undef( file );

  		//crea la variabile che servirà come parametri per la conversione xml
  		stringXml.rootNodeName = "config";
		stringXml.root << variable;

  		//trasforma la variabile in una stringa in formato xml
		valueToXml@XmlUtils(stringXml)(fileXml);

		file.content = fileXml;
	  	file.filename = filename;

		//crea il file xml partendo dalla stringa nello stesso formato 
		writeFile@File(fileXml)()
  		
  	}]
  	{nullProcess}
}