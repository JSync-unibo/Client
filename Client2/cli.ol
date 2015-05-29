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

 usage : [command] <parameters>

 command
 - list servers
 - addServer     <name> <address>
 - list reg_repos
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