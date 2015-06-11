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

		cartelle.sottocartelle[i].nome = directory + "/" + subDir.result[j];

		tmp += subDir.result[j] + "  ";

		i++
    };

	i = 1;

	while( cartelle.sottocartelle[i].mark == true && i < #cartelle.sottocartelle) {

		i++

	};

	if( is_defined( cartelle.sottocartelle[i].nome )) {

		cartelle.sottocartelle[i].mark = true;

		directory = cartelle.sottocartelle[i].nome;

		i = #cartelle.sottocartelle;

		visita

	} 

	else {

		println@Console( tmp )()

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