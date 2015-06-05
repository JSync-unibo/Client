include "interfaceA.iol"
include "console.iol"
include "string_utils.iol"

outputPort ToClient {
	Interfaces: clientInterface
}

embedded {
	Jolie: "client.ol" in ToClient
}


main
{

	var.server[0].name = "server1";
	var.server[0].address = "socket://localhost:8000";

	save@ToClient(var)(res);
	
	getAll@ToClient()(response);
	valueToPrettyString@StringUtils(response)(stringa);
	
	println@Console( stringa )()
}
