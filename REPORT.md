# JSync - Esame di Laboratorio Sistemi Operativi A.A. 2014-2015

## LOBSTER

Componenti:

- Gianmarco Spinaci 0000691241
- Michele Lorubio   0000693868
- Chiara Babina 	0000693799
- Valentina Tosto   0000692741

## Introduzione

Questo progetto tratta di una sincronizzazione di files tra clients e servers, implementando le funzionalit� che pu� avere un client per comunicare con il server.
L'utente pu� interagire con il client attraverso un'interfaccia, la CLI, che riceve i comandi in input. Il client poi, a seconda del comando ricevuto, esegue un'operazione gestendo le varie eccezioni che possono sollevarsi. Alcuni comandi sono in locale, e non richiedono l'intervento del server, mentre altri hanno bisogno del collegamento con il server scelto. 
Esiste un client unico, mentre esistono pi� cli e pi� server, per evitare ridondanza di codice. 
Inoltre abbiamo implementato un help per avere a disposizione i comandi possibili che l'utente pu� domandare al client. 
In seguito spiegheremo nel dettaglio tutte le funzionalit� del nostro progetto.


## Consegna

Il progetto deve essere avviato lanciando la/le cli ed i server a disposizione. Successivamente si scrive il comando in input che si vuole richiedere al client e si aspetta la risposta

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

6) Per visualizzare la lista delle repositories locali si inserisce il comando: �list reg_repos�, mentre per quelle sul Server:
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

13)  Dopo aver eseguito tutti i comandi, si pu� cancellare il Server   
     con il comando �removeServer� seguito dal nome del Server da   
     eliminare.
       

## Implementazione

### Struttura del Progetto

Il progetto � diviso in pi� Cli, Servers e un Client che fa da tramite. 
Il Client � collegato alla Cli attraverso l'embedding, cos� da essere connessi localmente, senza aver bisogno di un indirizzo. Per gestire la trasmissione dei messaggi fra di essi, ad ogni comando � associato un servizio diverso, che pu� essere eseguito localmente o attraverso una porta collegata a un Server. 
Nel Client definiamo inizialmente due metodi, uno per la lettura del file xml e l'altro per la scrittura, i quali sono richiamati nell'init all'avvio del programma, dove nello specifico il readFile legge il file esistente, mentre il writeFile lo crea se non esiste.
Ogni comando che il Client riceve viene splittato, cos� da esaminare ogni stringa inserita, e di seguito descriviamo i vari servizi implementati.

### LIST SERVERS & LIST REG_REPOS
Abbiamo creato uno scope poich� gestiamo delle eccezioni, nel caso in cui l'utente abbia inserito troppi parametri; invece se si scrive il giusto comando viene richiamato il metodo della lettura del file xml e si verificano due casi: se la lista � piena, allora per ogni server/repository del file xml, viene stampato il suo nome e indirizzo (server), oppure il suo nome, la versione e i files contenuti (repository); altrimenti se la lista � vuota viene stampato un messaggio di avviso.

### ADD SERVER
Abbiamo creato uno scope per gestire le eccezioni, in caso di parametri scritti in modo non corretto oppure se manca il nome e/o l'indirizzo. Quando si aggiunge un server si richiama il metodo readFile e si effettua un controllo se il nome del server esiste gi�, in tal caso viene stampato un messaggio, altrimenti tutti i dati vengono inseriti nel file xml, richiamando il metodo writeFile.

### REMOVE SERVER
Anche in questo caso si crea uno scope per gestire le solite eccezioni. Se la lista dei server � vuota allora viene sollevata un'eccezione, altrimenti per ogni server della lista si controlla il nome, e se corrisponde a quello da rimuovere viene eliminato dalla lista che in seguito viene riordinata. 

### ADD REPOSITORY
Questo � un comando nel quale � indispensabile l'intervento del server. Infatti si scrive in input il nome del server a cui vogliamo collegarci, il nome della rep che 
vogliamo creare ed il nome della directory locale del client che andremo a copiare; poi si richiama il registro, che ha il compito di ricercare nella lista dei server il nome di quello richiesto in input, ed in seguito prelevare il suo indirizzo, cos� da connettersi a questo server. 
Infine si connette il client con tale server, attraverso la porta creata, e si inviano i dati della repository da creare. Ci� che il client si aspetta di ricevere sar� un messaggio di successo (se la rep � stata aggiunta) oppure di errore. 

### LIST NEW_REPOS
Questo comando si collega al server, catturando un'eccezione nel caso in cui questo non sia disponibile, e invia la richiesta della stampa delle repositories. Viene inserito l'indirizzo a cui collegarsi al server, e poi viene richiamato il metodo registro per fare il collegamento. In seguito il server salva i nomi di tutte le repositories presenti in una stringa, che ritorna al client.

### DELETE
Si elimina una repository presente nel server selezionato ed anche la cartella locale del client. Si sollevano le varie eccezioni in caso di assenza di connessione con il server oppure se sono stati inseriti troppi dati oppure non corretti. In seguito si richiama il registro, per estrarre i dati necessari per collegarsi al server desiderato, e si inviano i dati attravero la porta. Nel server poi � presente la parte essenziale dell'operazione, infatti per ogni repository presente nel server si cerca quella il cui nome combacia con quello scritto in input ed in tal caso viene eseguito il metodo per l'eliminazione ricorsiva delle cartelle (quindi anche sottocartelle e file interni). Se l'eliminazione � avvenuta, allora dalla parte del client di conseguenza sar� eliminata la relativa cartella locale, altrimenti se la repository non � stata trovata, allora sar� stampato un messaggio di avviso.

### Sezione su `push`

Abbiamo implementato la funzione di `push` ...

### Altra sezione su una feature che si vuole discutere

File manager: inizialmente volevamo implementarlo come un servizio a parte, che gestiva la lettura e scrittura del file xml, e la visita ricorsiva delle cartelle; cos� da alleggerire il client. Ma sfortunatamente abbiamo rilevato un eccessivo consumo di Cpu, quindi non abbiamo potuto continuare con questa idea ed abbiamo dovuto spostare questo servizio all'interno del Client.

Add Repository / Push: abbiamo avuto dei problemi riguardo i percorsi delle cartelle, poich� la lettura del file accetta un percorso assoluto, mentre la scrittura del file accetta un percorso relativo.
