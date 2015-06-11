include "console.iol"
include "file.iol"
include "string_utils.iol"

init
{
  	
	registerForInput@Console()()
}

define visita
{
	 
    root.directory = directory;

	list@File(root)(subDir);

	for(j = 0, j < #subDir.result, j++) {

		//salva il percorso della cartella
		cartelle.sottocartelle[i].nome = directory + "/" + subDir.result[j];

		newRoot.directory = cartelle.sottocartelle[i].nome;

		//viene controllato se la cartella ha delle sottocartelle. Se non ha sottocartelle
		//viene salvato tutto il percorso per arrivare in quella cartella
		list@File( newRoot )( last );

		if(#last.result == 0)  {

			stampa.cartelle[#stampa.cartelle] = cartelle.sottocartelle[i].nome

		};

		i++
    };

	i = 1;

	//finchè una sottocartella è già stata visitata, si passa alla successiva
	while( cartelle.sottocartelle[i].mark == true && i < #cartelle.sottocartelle) {

		i++

	};

	//se non si è arrivati alla fine dell'array cartelle, l'attributo mark della cartella viene
	//settato a true, e si richiama il metodo visita
	if( is_defined( cartelle.sottocartelle[i].nome )) {

		cartelle.sottocartelle[i].mark = true;

		directory = cartelle.sottocartelle[i].nome;

		i = #cartelle.sottocartelle;

		visita

	} 

	//se si è arrivati alla fine dell'array vengono stampati i percorsi finali
	else {

		for(k = 0, k < #stampa.cartelle, k++) {
			
			println@Console( stampa.cartelle[k] )()
		}
		
	}

}

main {

	in( command );

	directory = command;

	radice.directory.name = command;

	radice.directory.mark = true;

	i = 1; 

	visita

}