# JSync - Esame di Laboratorio Sistemi Operativi A.A. 2014-2015
>*Build software better, together.*


## LOBSTER

Componenti:

- **Gianmarco Spinaci** 0000691241
- **Michele Lorubio**   0000693868
- **Chiara Babina**	  0000693799
- **Valentina Tosto**   0000692741

## Introduzione
<p style="text-align:justify;font-size:12px">
<b>JSync-Lobster</b> � un servizio di condivisione di repositories tra Clients.<br>
Grazie ad una semplice ed intuitiva <b>UI</b> in modalit� command line (Cli), l'utente pu� interagire con i Servers registrati, che mantengono le informazioni sulle repositories.<br>
Con pochi comandi l'utente pu� gestire i diversi Servers e richiedere o creare una repository su di essi, tenendo conto delle varie eccezioni che potrebbero sollevarsi durante l'esecuzione.<br>
L'utilit� di tale servizio � data attraverso una pratica gestione dei readers-writers, permettendo a tutti gli utenti di avere la possibilit� di gestire le repositories sul Server in comune, rispettando la concorrenza.<br>
La <b>UX</b> � agevolata anche grazie all'aggiunta di un comando per visualizzare tutte le funzionalit� offerte da JSync.<br>
In seguito spiegheremo nel dettaglio la struttura completa del nostro progetto.
</p>

## Consegna

Il progetto deve essere eseguito lanciando la/le cli ed i server a disposizione.<br>
Successivamente si scrive un comando in input sulla <b>UI</b>, il quale sar� inviato al Client, e si aspetter� una sua risposta.

### Demo

Le istruzioni per eseguire una demo di esecuzione, con almeno due Clients ed un Server, sono:

1) Lanciare il servizio �server.ol� nella cartella Server1 (o di altri Servers).

2) Avviare i Clients, entrando nella cartella Client1 (facendo partire il servizio �cli.ol�) e seguire la stessa procedura per gli altri Clients.

3) Da una delle due cli eseguire il comando �addServer� indicando il nome del server e l�indirizzo, ad esempio:
 
�addServer server1 socket://localhost:4000�

In questo modo nel file config.xml saranno aggiunte le informazioni del Server.

4) In seguito si pu� eseguire il comando �list servers�, per visualizzare il Server appena registrato.



5) Aggiungere una repository nuova da un percorso presente sul computer, inserendo il nome del Server, della repo da creare sia nel Client che nel Server e del percorso locale, come in questo esempio:

�addRepository server1 repo1 C:/Users/Prova1�
        
(naturalmente questo � un percorso preso da Windows)
Oltre alla repo con tutti i files, ne sar� creato anche uno di versione sia nella repo locale che in quella online.

6) Per visualizzare la lista delle repositories locali si inserisce il comando �list reg_repos�, mentre per quelle sul Server
�list new_repos�

7) Intanto il secondo Client aggiunge il Server alla lista e in seguito esegue una pull per scaricare la repository presente sul Server, che era stata caricata in precedenza ed attendere circa 10 secondi, prima che l�operazione sia completata.
Ad esempio si scrive il comando: 

			�pull server1 repo1�

8) Il secondo Client pu� aggiungere un nuovo file alla repo1
(manualmente), cos� da poter eseguire una push ed aggiornare il Server e la relativa versione, un esempio del comando da scrivere �:

				�push server1 repo1�

9) Il primo Client aggiunge un nuovo file alla repo1, ma se prova ad eseguire una push, un messaggio negher� l�operazione, perch� � necessario aggiornare la propria versione e fare la pull.

10) Quindi il primo Client aggiorna la propria repo, facendo una
pull, e successivamente pu� ri-aggiungere il nuovo file e fare    
la push.

11) Si pu� testare la concorrenza fra i due Clients, provando a far 
eseguire una pull dal Client1 e contemporaneamente (nell�arco    
dei 10 secondi di tempo) una push dal Client2, che sar� 
bloccata.

12) Infine per cancellare la repo1 sia dal Server che dal Client1,   
si esegue il comando: 

				�delete server1 repo1�

In questo modo la repository non sar� pi� presente n� sul Server n� sul Client1, per� � ancora disponibile sul Client2.

13) Dopo aver eseguito tutti i comandi, si pu� cancellare il Server   
con il comando �removeServer� seguito dal nome del Server da   
eliminare.
        





## Implementazione

### Struttura del Progetto

Il progetto � diviso in pi� Cli, Servers ed un Client che fa da tramite.<br>
Il Client � collegato alla Cli attraverso l'embedding, cos� da essere connessi localmente, senza aver bisogno di un indirizzo. Per gestire la trasmissione dei messaggi fra di essi, ad ogni comando � associato un servizio diverso, che pu� essere eseguito localmente o attraverso una porta collegata ad un Server. 
Inoltre utilizziamo un servizio che includiamo nel Client per gestire diversi metodi, come la lettura e scrittura del file xml, ma anche la visita e creazione di cartelle, che ritroviamo anche in un servizio incluso nel Server.
Il comando viene prima splittato nella Cli, cos� da essere inviata ogni stringa inserita ed analizzarla singolarmente.
Di seguito elenchiamo i comandi, descrivendoli nello specifico e tenendo presente che in ogni comando abbiamo inserito uno scope per gestire diverse eccezioni che si presentano, tra le quali l�inserimento di dati non corretti, la connessione assente con il Server ed un file non trovato.
Inoltre il procedimento � eseguito se i risultati splittati nella Cli corrispondono alla lunghezza richiesta del comando (es: list(1) servers(2) -> il risultato dello split deve essere di dimensione 2).

### LIST SERVERS

Una volta controllato che i dati inseriti in input siano giusti, procediamo con la lettura del file xml (richiamato dal servizio �utilities.ol�) e se sono presenti Servers nella lista, per ognuno di essi vengono stampate le relative informazioni (nome ed indirizzo), altrimenti un messaggio di avviso che non sono presenti Servers registrati.

### LIST REG_REPOS

In questo comando per la lettura delle repositories locali, inizialmente poniamo come directory �localRepo�, che � il nome della cartella che abbiamo creato in ogni Cli con tutte le varie repo, poi cerchiamo ogni repository richiamando l�operazione List del servizio file.iol ed infine le stampiamo tutte, se sono presenti, altrimenti sar� visualizzato un messaggio di avviso.

### ADD SERVER

Quando si aggiunge un server si richiama il metodo per la lettura del file xml e si effettua prima un controllo se il nome del Server esiste gi� (confrontando il nome scritto in input con quelli nella lista), in tal caso viene stampato un messaggio, altrimenti inseriamo il nome ed indirizzo del Server desiderato nel file xml, richiamando il metodo writeFile, presente sempre nel servizio �utilities.ol�.

### REMOVE SERVER

Dopo la consueta lettura del file xml, inseriamo un ulteriore scope, che in caso di Server trovato (e rimosso) solleva l�eccezione di operazione avvenuta con successo. Se il nome inserito in input corrisponde ad uno di quelli registrati nella lista, allora si elimina (con il comando undef)e si richiama la scrittura del file xml per apportare le modifiche effettuate. 

### ADD REPOSITORY

Questo � il primo comando che ha bisogno dell�intervento del Server.

Client: 

1) Riceve dalla Cli il nome del Server a cui si deve connettere, e 
   si effettua il Binding, attraverso il richiamo del metodo 
   registro (in �utilities.ol�), scorrendo la lista dei Servers per 
   individuare l�indirizzo del Server a cui collegarsi ed 
   aggiungerlo alla porta di comunicazione.

2) Poi con l�operazione AddRepository si connette con il Server per 
   effettuare un controllo e se il messaggio che gli ritorna �
   positivo, allora prosegue analizzando il percorso della 
   directory locale inserito in input, per aggiungerlo sia nel 
   Client che nel Server.

3) Richiamiamo la visita delle cartelle (in �utilities.ol�) e per 
   ogni file trovato si legge il suo percorso assoluto (readFile)    
   per ottenere cos� il contenuto del file, in seguito viene 
   inviato al Server il suo percorso relativo, provvedendo ad   
   inserirlo nella repository appena creata.

4) Successivamente richiamiamo il metodo writeFilePath (in  
   �utilities.ol�) per creare la cartella �localRepo� ed inserire 
   tutti i file della directory locale nella repository   
         specificata in input.

5) Infine nella repository appena creata, si inserisce un file .txt  
   di versione, che sar� incrementato ogni volta che si esegue una 
   push.

Server:

1) Riceve dal Client il nome della repository da cercare nella   
   propria cartella, se esiste allora ritorna un messaggio di 
   errore, altrimenti crea la cartella �serverRepo�, se non � gi� 
   presente, che contiene tutte le cartelle del Server, e poi viene 
   creato il file di versione, il quale sar� aggiornato ogni volta 
   che riceve una push.

2) In seguito con un�altra operazione riceve il percorso relativo 
   di ogni singolo file, ricavato dal Client attraverso la visita 
   della directory locale, e lo splitta, per creare la cartella a 
   cui appartiene il file, ed infine scriverlo con il comando 
   writeFile












### LIST NEW_REPOS

Questo comando serve per far stampare tutte le repositories dei Server registrati.

Client:
	
1) Inizialmente, se la lista dei Servers nel file xml non � vuota    
   si collega ad ognuno di essi, e cattura un'eccezione nel caso in 
   cui uno o pi� Servers non siano in ascolto nella location 
   selezionata (Server non raggiungibile).

2) In seguito invia la richiesta delle repositories disponibili sui   
   Servers accesi, per poi stamparne l�elenco. 

Server:

   1) Riceve la richiesta dal Client di inviargli tutti i nomi delle 
      repositories presenti nella directory �serverRepo�. Richiama il 
      metodo listFile di file.iol per ottenere l�elenco, se sono 
      disponibili repo, e poi inviarlo al Client.


### DELETE

Comando per eliminare una repository sia sul Server sia sul Client.

Client:

   1) Si legge il file xml e si richiama il metodo registro, per avere 
	   le informazioni necessarie per collegarsi con il Server nel 
      quale eliminare la repository.

	2) Si invia la richiesta di eliminazione della repo al Server ed in
	   caso di cancellazione avvenuta oppure se la repo gi� era stata 
cancellata in precedenza, eseguiamo la stessa operazione per il Client, con il comando deleteDir di file.iol, eliminando l�intera cartella che era stata inserita in input.

Server:

	1) Riceve il messaggio dal Client della repository da eliminare,
	   scorre la lista di tutte quelle presenti in �serverRepo� e se il 
   nome corrisponde a quello ricevuto, elimina la cartella e 
   ritorna il messaggio di operazione effettuata.

### PUSH






### PULL







### GESTIONE READER-WRITER

Questa � stata una scelta abbastanza discussa, avevamo diverse alternative valide: l�uso dei semafori di Jolie, oppure dei controlli tramite il file di versione, o ancora l�utilizzo di una coda o un�esecuzione sequenziale (ovviamente scartata a priori), merging dei file (GitHub style).
Alla fine abbiamo optato per due implementazioni diverse:

PUSH � PUSH: 
Piu' push sono gestite tramite il controllo di versione, se il Client1 prova ad effettuare una push mentre il Client2 sta gi� eseguendo la sua sullo stesso Server, allora il Client1 dovr� prima aggiornare la sua versione, con una pull, e solo successivamente pu� caricare i suoi files. 
(Siamo consapevoli che questa scelta porta ad una perdita di dati da parte del Client1, che dovr� effettuare una pull, andando a cancellare tutte le sue modifiche locali)
Bisogna tenere presente che invece due push di due repositories diverse sono permesse, perch� una non va ad interferire con l�altra.

PUSH � PULL / PULL � PUSH:
Per questo tipo di gestione invece abbiamo utilizzato dei contatori (reader e writer) globali nel Server, che saranno condivise da tutti i Clients e possono verificarsi due casi:

- Il Client1 esegue una push, il writerCount sar� incrementato e se contemporaneamente il Client2 vuole eseguire una pull, controlla se il writerCount � uguale a 1, in questo caso sar� bloccato con un messaggio di avviso e solo in seguito, quando la push sar� completata, allora potr� richiamare la pull.

- Il Client1 esegue una pull, il readerCount sar� incrementato e se il Client2 vuole eseguire una push dovr� controllare se il readerCount sia maggiore o uguale a 1, nel caso i readers siano pi� di uno, il Client2 dovr� aspettare pi� del dovuto (problema di starvation). Solo quando readerCount sar� uguale a 0, allora potr� effettuare la push.

PULL � PULL:
Due (o pi�) readers invece sono permessi, quindi non abbiamo inserito nessun controllo, poich� tutti possono scaricare contemporaneamente il contenuto dello stesso Server.


### PROBLEMI RISCONTRATI & SOLUZIONI ADOTTATE

File manager: 
Inizialmente volevamo implementarlo come un servizio a parte, attraverso l�embedding, che gestiva la lettura e scrittura del file xml, e la visita ricorsiva delle cartelle, cos� da alleggerire il client. Ma sfortunatamente abbiamo rilevato un eccessivo consumo di Cpu, quindi non abbiamo potuto continuare con questa idea ed abbiamo deciso di creare un servizio senza embedding, da includere nel Client e nel Server.

Add Repository / Pull (gestione cartelle): 
Abbiamo avuto dei problemi riguardo i percorsi delle cartelle, perch� inizialmente non sapevamo come far visitare tutte le sotto-cartelle della cartella principale e non solo i files contenuti all�interno. Poi abbiamo deciso di implementare una visita ricorsiva di tutte le cartelle interne, gestendo anche la differenza tra la lettura del file, che accetta un percorso assoluto, e la scrittura, che accetta un percorso relativo. Inoltre se sono presenti cartelle vuote nella directory locale che si vuole aggiungere nel Client e Server, abbiamo deciso di non farle aggiungere, mentre nella Pull torna un messaggio di repository vuota, se nel Server � stato cancellato il contenuto di quella repo.

