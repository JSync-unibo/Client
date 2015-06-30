/*
*
* Author => Gruppo LOBSTER
* Data => 26/06/2015
* 
* Cli
*
* Servizio che accetta in input un comando, inviato al servizio 
* di clientUtilities attraverso l'embedding, aspettando una 
* stringa di risposta.
*/

include "console.iol"
include "../client_utilities/interfaces/localInterface.iol"


init
{
  	
	registerForInput@Console()();

	// Si richiama il define help
	help
}

/*
 * Define del comando help, richiamato nell'init 
 * per stampare l'elenco dei comandi da poter inserire
 */
define help
{
  	println@Console( 
" JSync Unibo Vers 0.4.0
 Copyright LOBSTER 2015. All right reserved.

 Usage : [command] <parameters>

 Optional :
 - help                                 Show this help message
 - close                                Close the Cli

 List Command :
 - list servers                         Show list of registred servers
 - list reg_repos                       Show list of local repositories
 - list new_repos                       Show list of all online repositories

 Server Command : 
 - addServer     <name> <address>       Add selected server
 - removeServer  <name>                 Remove selected server

 Repositories Command :
 - addRepository <name> <repo> <path>   Add new repository in selected server, with <path> name
 - delete <name> <repo>                 Delete a repository in selected server
 - push <name> <repo>                   Push of selected repository
 - pull <name> <repo>                   Pull of selected repository


" 
)()
}

main
{

	/*
	 * Fino a quando il comando inserito non è uguale a close,
	 * accetta in input uno dei comandi: 
	 * - help -> sarà ristampata la lista dei comandi disponibili
	 * - comando della lista -> viene splittato, inviato al client e poi aspetta una risposta
	 */

	while( root.command != "close" ){

		print@Console( ">>> " )();

		in( root.command );

		if(root.command == "help") 

	  		help

	  	// Se il comando è "close" viene richiamata l'operazione per chiudere la sessione
	  	else if (root.command == "close") {

	  		close.token = "close";

	  		unsubscribeSessionListener@Console(close)()
	  	}	
	  	
	  	else {

  			root.command.regex = " ";

	  		split@StringUtils( root.command )( resultSplit );

	  		// Ritorna la lista di Servers
	  		if(resultSplit.result[0] == "list" && resultSplit.result[1] == "servers") {

	  			listServers@ToClient( resultSplit )( result );
	  			undef(root.command)
	  		}

	  		// Ritorna la lista delle repositories locali
	  		else if( resultSplit.result[0] == "list" && resultSplit.result[1] == "reg_repos" ) {

	  			listRegRepos@ToClient( resultSplit )( result )

	  		}
	  		
	  		// Aggiunge un Server nella lista presente sul file xml
	  		else if ( resultSplit.result[0] == "addServer" ) {
	  			
	  			addServer@ToClient( resultSplit )( result )
	  		  
	  		}

	  		// Rimuove un Server nella lista presente sul file xml
	  		else if ( resultSplit.result[0] == "removeServer" ) {
	  			
	  			removeServer@ToClient( resultSplit )( result )
	  		  
	  		}
			
			// Ritorna la lista delle repositories presenti sul Server richiesto
			else if ( resultSplit.result[0] == "list" && resultSplit.result[1] == "new_repos") {
	  			
	  			listNewRepos@ToClient( resultSplit )( result )
	  		  
	  		}

	  		// Aggiunge una repository sul Client e sul Server, prelevando i files da un path specifico
	  		else if ( resultSplit.result[0] == "addRepository") {
	  			
	  			addRepos@ToClient( resultSplit )(result)
	  		}

	  		// Elimina una repository sul Client e sul Server
			else if ( resultSplit.result[0] == "delete") {
	  			delete@ToClient( resultSplit )(result)
	  		  
	  		}

	  		// Scrive l'ultima versione di una repository locale su quella del Server
	  		else if( resultSplit.result[0] == "push") {

	  			push@ToClient( resultSplit )( result )
	  		}

	  		// Legge l'ultima versione della repository sul Server, aggiornando quella locale
	  		else if( resultSplit.result[0] == "pull") {

	  			pull@ToClient( resultSplit )( result )
	  		}

	  		// Se il comando non è riconosciuto, pulisce il risultato e stampa un messaggio di errore
	  		else {
	
	  			undef(result);
	  			println@Console( " Not a recognize command" )()

	  		};

			println@Console( result )()
		}
	}
	
}