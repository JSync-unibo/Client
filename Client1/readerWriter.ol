include "console.iol"
include "semaphore_utils.iol"

init
{
  s = 2;
  readcount = 0;
  mutex.name = "sem1"
}

define acquireSemS
{

  while(s <= 0) {
  	
  	nullProcess

  };

  s--

}

define releaseSemS
{
  s++

}

main
{

	  acquire@SemaphoreUtils(mutex)(acquisito) |
	  
	  readcount++;
	  if(readcount == 1) {
	  		acquireSemS;
	  		println@Console( "no, non puo' entrare il write" )()
	  };

	  release@SemaphoreUtils(mutex)(rilasciato);
	  
	  println@Console( "posso leggere" )();

	  readcount--;

	  if(readcount == 0) {
	  		releaseSemS;
	  		println@Console( "si puo' entrare il write" )()
	  }

 
	
}