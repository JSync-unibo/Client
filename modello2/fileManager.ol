include "interfaceA.iol"
include "file.iol"
include "xml_utils.iol"

inputPort LocalIn {
	Location: "local"
	Interfaces: fileManager
}

execution{ concurrent }

main
{

	/*

	 */
  	[readXmlFile()(serverList){

  		scope( fileXml )
		{

		  	// Se non esiste il file xml setta la variabile come vuota
			install( FileNotFound => nullProcess );

			// Paramentri per la lettura del file
		  	file.filename = "config.xml";
			file.format = "binary";

			// Lettura file xml di configurazione
			readFile@File(file)(readedFile);

			// Salva il file di configurazione nella variabile configList
			xmlToValue@XmlUtils(readedFile)(response)

		}
  	}]{ 
  		undef(serverList);
  		undef(file) 
  	}

  	/*

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

}