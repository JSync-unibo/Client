include "console.iol"

main
{
  while( command != "close" ){
  	println@Console( "Insert new command" )();
  	print@Console( "> " )();
  	registerForInput@Console()();
  	in( command );
  	println@Console( "Received command: " + "\"" + command + "\"" )()
  }
}