/*
*
* Author => Gruppo A: Valentina Tosto, Chiara Babina
* Data => 04/05/2015
* Parent => Client
* 
* Servizio che accetta in input dei comandi, inviati al client 
* attraverso l'embedding, ed aspetta una stringa di risposta.
*/

include "console.iol"
include "../client_utilities/interfaces/interfaceLocalA.iol"

init
{
  	
	registerForInput@Console()()
}


define help
{
  	println@Console( 
" JSync Unibo Vers 0.3.0
 Copyright LOBESTER 2015. All right reserved.

 Usage : [command] <parameters>

 Optional :
 - help                                 Show this help message

 List Command :
 - list servers                         Show list of registred servers
 - list reg_repos                       Show list of local repositories
 - list new_repos                       Show list of all online repositories

 Server Command : 
 - addServer     <name> <address>       Add selected server
 - removeServer  <name>                 Remove selected server

 Repositories Command :
 - addRepository <name> <repo> <path>   Add new repository in selected server, with <path> name
 - delete <name> <repo>					Delete a repository in selected server
" 
)()
}

main
{

	// Si richiama help, con tutti i comandi disponibili
	help;

	/*
	 * Fino a quando il comando inserito non è uguale a close,
	 * accetta in input uno dei comandi: 
	 * - help -> sarà ristampata la lista dei comandi disponibili
	 * - comando della lista -> è inviato al client ed il cli aspetta una risposta
	 */
	while( root.command != "close" ){

		print@Console( ">>> " )();

		in( root.command );

		if(root.command == "help") 

	  		help

	  	else {

			sendCommand@ToClient( root.command )( result );

			println@Console( result )()
		}
	}
}