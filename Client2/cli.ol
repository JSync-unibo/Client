/**
*
* Author => Gruppo A: Valentina Tosto, Chiara Babina
* Data => 04/05/2015
* Parent => Client
*
**/

include "console.iol"
include "Interfaces/interfaceLocalA.iol"

outputPort ToClient{
  Interfaces: CliInterface
}

embedded {
  Jolie: "client.ol" in ToClient
}


main
{
	
	registerForInput@Console()();
	while( root.command != "close" ){

	  	println@Console( "Insert new command" )();
	  	print@Console( ">>> " )();
	  	in( root.command );
	  	sendCommand@ToClient(root)(result);
	  	println@Console( result )()
	  	//println@Console( "Received command: " + "\"" + command + "\"" )()
	}

  	
}