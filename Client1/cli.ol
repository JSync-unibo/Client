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
include "../client_utilities/interfaces/interfaceLocalA.iol"

init
{
  	
	registerForInput@Console()()
}

define help
{
  	println@Console( 
" JSync Unibo Vers 0.2.0
 Copyright LOBESTER 2015. All right reserved.

 usage : [command] <parameters>

 List Command :
 - list servers
 - list reg_repos

 Server Command : 
 - addServer     <name> <address>
 - removeServer  <name> 
" 
)()
}

main
{

	help;

	while( root.command != "close" ){

	  	print@Console( ">>> " )();

	  	in( root.command );

	  	sendCommand@ToClient( root.command )( result );

	  	println@Console( result )()
	}
}