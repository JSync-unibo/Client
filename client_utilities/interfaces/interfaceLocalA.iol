/**
*
* Author => Gruppo A: Valentina Tosto, Chiara Babina
* Data => 04/05/2015
* Parent => Client
*
**/

//Interfaccia fra il cli ed il client
interface CliInterface {

  RequestResponse: sendCommand(string)(string) 

}

outputPort ToClient{
  Interfaces: CliInterface
}

embedded {
  Jolie: "../client_utilities/client.ol" in ToClient
}