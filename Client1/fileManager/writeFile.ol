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

//servizio embeddato da client.ol

inputPort FromClient {
  	Location: "local"
  	Interfaces: FileManagerInterface
}

main
{

  	/**
	 *
	 *	ri-scrive il file xml (se non lo trova non genera fault, ma lo crea per la prima volta)
  	 *
  	 *	input -> variabile "ConfigType"
  	 *	output -> boolean
  	 *
  	 *
  	 **/
  	writeFile(variable)(isCreated){

  		//crea la variabile che servirà come parametri per la conversione xml
  		stringXml.rootNodeName = "config";
		stringXml.root << variable;

  		//trasforma la variabile in una stringa in formato xml
		valueToXml@XmlUtils(stringXml)(fileXml);

		file.content = fileXml;
	  	file.filename = "config.xml";

		//crea il file xml partendo dalla stringa nello stesso formato 
		writeFile@File(fileXml)()
  		
  	}
}