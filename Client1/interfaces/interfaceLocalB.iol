include "types/Binding.iol"
/**
 *
 * Author => GruppoB{Gianmarco Spinaci, Michele Lorubio}
 * Data => 04/05/2015
 * Parent => Client
 *
 **/

//ConfingType prende i tipi del file config.xml
type ConfingType: void
{

	.readed:bool

	.server*: void
	{
		.nome: string
		.indirizzo: string
	}

	.localRepo*: void
	{
		.nome: string
		.versione: string
		.file*: void {?}
	}
}


//Interfaccia tra Cli e Client
interface FileManagerInterface {
 
  	RequestResponse: 	readFile (void)(ConfingType),
  						writeFile (ConfingType)(void)
}