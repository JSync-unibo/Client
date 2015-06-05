
type xmlFileFormat: void { 

	.server*:void{

		.name:string
		.address:string
	}
}

interface clientInterface {
  	RequestResponse: 

  		getAll(void)(string),
  		save(xmlFileFormat)(string)
}

interface fileManager {

  	RequestResponse: 
  		readXmlFile(void)(xmlFileFormat),
  		writeXmlFile(xmlFileFormat)(void)
}