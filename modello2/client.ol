include "interfaceA.iol"
include "string_utils.iol"

inputPort LocalIn {
	Location: "local"
	Interfaces: clientInterface
}


outputPort FileManager {
	Interfaces: fileManager
}

embedded {
	Jolie: "fileManager.ol" in FileManager
}

execution{ concurrent }

main
{
	[save(fileXml)(response){

		writeXmlFile@FileManager(fileXml)();

		response = "yo"
	}]{
		undef( response );
		undef( fileXml )
	}


	[getAll()(response){

		readXmlFile@FileManager()(fileXml);
		valueToPrettyString@StringUtils(fileXml)(response)

	}]{
		undef( response );
		undef( fileXml )
	}
}