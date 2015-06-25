include "semaphore_utils.iol"
include "console.iol"


init
{
  s.permits = 0;
  t.permits = 0;
  s.name = "sem1";
  t.name = "sem2"
}

define acquireSemS
{

  while(s.permits <= 0) {
  	nullProcess
  };

  s.permits--

}

define acquireSemT
{
  
  while(s.permits <= 0) {
  	nullProcess
  };

  t.permits--

}

define releaseSemS
{
  s.permits++

}

define releaseSemT
{
  t.permits++

}


main
{

	while(true) {
	  cont++;

	  if(cont <= 50) {
		  
		  acquire@SemaphoreUtils(t)(acquisito);
		  println@Console( "Sono la stampa A" )() |

		  release@SemaphoreUtils(s)(rilasciato) |
		 
		 
		  
		  println@Console("Sono la stampa B")() |

		  acquire@SemaphoreUtils(s)(acquisito);
		  release@SemaphoreUtils(t)(rilasciato)
		  
	   }

	   else
	   	nullProcess
	}

}