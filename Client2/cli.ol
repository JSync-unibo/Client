/**
*
* Author => Gruppo A: Valentina Tosto, Chiara Babina
* Data => 04/05/2015
* Parent => Client
* 
* Servizio che accetta in input dei comandi, che vengono inviati al client 
* attraverso l'embedding, ed aspetta una stringa di risposta.
**/

include "console.iol"
include "interfaces/interfaceLocalA.iol"


outputPort ToClient{
  Interfaces: CliInterface
}

embedded {
  Jolie: "client.ol" in ToClient
}

init
{
	registerForInput@Console()()
}


main
{
	while( root.command != "close" ){

	  	println@Console( "Insert new command" )();
	  	print@Console( ">>> " )();

	  	in( root.command );
	  	sendCommand@ToClient(root)(result);
	  	println@Console( result )()
	}
}