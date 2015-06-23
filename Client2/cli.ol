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
include "../client_utilities/interfaces/localInterface.iol"


init
{
  	
	registerForInput@Console()()
}

define help
{
  	println@Console( 
" JSync Unibo Vers 0.4.0
 Copyright LOBSTER 2015. All right reserved.

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
 - delete <name> <repo>                 Delete a repository in selected server
 - push <name> <repo>                   Push of selected repository
 - pull <name> <repo>                   Pull of selected repository


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
	 * - comando della lista -> viene splittato, inviato al client e poi aspetta una risposta
	 */

	/*
	root.command = "addRepository server1 Repo1 C:\\Users\\Gianmarco\\Desktop\\GianmarcoSpinaci";
	//root.command = "pull server1 repo1";

	root.command.regex = " ";
	split@StringUtils( root.command )( resultSplit );

	addRepos@ToClient( resultSplit )(result);
	//pull@ToClient( resultSplit )( result );

	println@Console( result )()
	*/
	

	
	while( root.command != "close" ){

		print@Console( ">>> " )();

		in( root.command );

		//root.command = "addRepository server1 repo1 C:\\Users\\Gianmarco\\Desktop\\cartella";

		if(root.command == "help") 

	  		help
	  	
	  	else {

  			root.command.regex = " ";

	  		split@StringUtils( root.command )( resultSplit );

	  		// Ritorna la lista di servers
	  		if(resultSplit.result[0] == "list" && resultSplit.result[1] == "servers") {

	  			listServers@ToClient( resultSplit )( result )
	  		}

	  		// Ritorna la lista delle repositories locali
	  		else if( resultSplit.result[0] == "list" && resultSplit.result[1] == "reg_repos" ) {

	  			listRegRepos@ToClient( resultSplit )( result )

	  		}
	  		
	  		// Aggiunge un server nella lista del file xml
	  		else if ( resultSplit.result[0] == "addServer" ) {
	  			
	  			addServer@ToClient( resultSplit )( result )
	  		  
	  		}

	  		// Rimuove un server nella lista del file xml
	  		else if ( resultSplit.result[0] == "removeServer" ) {
	  			
	  			removeServer@ToClient( resultSplit )( result )
	  		  
	  		}
			
			// Ritorna la lista delle repositories presenti nel server richiesto
			else if ( resultSplit.result[0] == "list" && resultSplit.result[1] == "new_repos") {
	  			
	  			listNewRepos@ToClient( resultSplit )( result )
	  		  
	  		}

	  		// Aggiunge una repository in locale e sul server, partendo da un path selezionato
	  		else if ( resultSplit.result[0] == "addRepository") {
	  			
	  			addRepos@ToClient( resultSplit )(result)
	  		}

	  		// Elimina una repository in locale e sul server
			else if ( resultSplit.result[0] == "delete") {
	  			delete@ToClient( resultSplit )(result)
	  		  
	  		}

	  		// Scrive l'ultima versione di una repo locale su quella del server
	  		else if( resultSplit.result[0] == "push") {

	  			push@ToClient( resultSplit )( result )
	  		}

	  		// Legge l'ultima versione della repo sul server, aggiornando la propria 
	  		else if( resultSplit.result[0] == "pull") {

	  			pull@ToClient( resultSplit )( result )
	  		}

	  		else {

	  			error@ToClient( resultSplit )( result )
	  		};

			println@Console( result )()
		}
	}
	
}