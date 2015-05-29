/**
*
* Author => Gruppo A: Valentina Tosto, Chiara Babina
* Data => 04/05/2015
* Parent => Client
<<<<<<< HEAD
* 
* Servizio che accetta in input dei comandi, che vengono inviati al client 
* attraverso l'embedding, ed aspetta una stringa di risposta.
=======
*
* Servizio che accetta in input dei comandi, che vengono inviati al client
* attraverso l'embedding ed aspetta una stringa di risposta
>>>>>>> origin/master
**/

include "console.iol"
include "interfaces/interfaceLocalA.iol"


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
	  	println@Console( result )();
<<<<<<< HEAD
	  	println@Console( "------------------------------------------" )()
=======
	  	println@Console( "---------------------------------------------------------" )()
>>>>>>> origin/master
	}

  	
}