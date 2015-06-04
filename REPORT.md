# JSync - Esame di Laboratorio Sistemi Operativi A.A. 2014-2015

## LOBSTER

Componenti:

- Gianmarco Spinaci 0000691241
- Michele Lorubio   0000693868
- Chiara Babina 	0000693799
- Valentina Tosto   0000692741

## Introduzione

Questo progetto tratta di una sincronizzazione di files tra clients e servers, implementando le funzionalità che può avere un client per comunicare con il server.
L'utente può interagire con il client attraverso un'interfaccia, la CLI, che riceve i comandi in input. Il client poi, a seconda del comando ricevuto, esegue un'operazione gestendo le varie eccezioni che possono sollevarsi. Alcuni comandi sono in locale, e non richiedono l'intervento del server, mentre altri hanno bisogno del collegamento con il server scelto. 
Esiste un client unico, mentre esistono più cli e più server, per evitare ridondanza di codice. 
Abbiamo implementato un help per avere a disposizione i comandi possibili che l'utente può domandare al client. 
In seguito spiegheremo nel dettaglio tutte le funzionalità del nostro progetto.




## Consegna

Il progetto deve essere avviato lanciando la cli ed i server a disposizione. Successivamente si scrive il comando in input che si vuole richiedere al client e si aspetta il responso.

### Demo

Le istruzioni per eseguire una demo di esecuzione. La demo deve contenere almeno 2 Clients ed un Server. Il Server parte, uno dei due Clients (Client1) aggiunge il Server, crea un repository (Repo) e invia (push) il contenuto locale del repository (file, vuoto). Il secondo Client (Client2) aggiunge il Server, richiede i files contenuti in Repo (pull), aggiunge un nuovo file (new_file, vuoto) e aggiorna il Server (push).



## Implementazione

### Struttura del Progetto

Il progetto è diviso in più Cli, Servers e un Client che fa da tramite. 
Il Client è collegato alla Cli attraverso l'embedding, così da essere connessi localmente, senza aver bisogno di un indirizzo. Per gestire la trasmissione dei messaggi fra di essi, ad ogni comando è associato un servizio diverso, che può essere eseguito localmente o attraverso una porta collegata a un Server. 
Nel Client definiamo inizialmente due metodi, uno per la lettura del file xml e l'altro per la scrittura, i quali sono richiamati nell'init all'avvio del programma, dove nello specifico il readFile legge il file esistente, mentre il writeFile lo crea se non esiste.
Ogni comando che il Client riceve viene splittato, così da esaminare ogni stringa inserita, e di seguito descriviamo i vari servizi implementati.

### LIST SERVERS & LIST REG_REPOS
Abbiamo creato uno scope poichè gestiamo delle eccezioni, nel caso in cui l'utente abbia inserito troppi parametri; invece se si scrive il giusto comando viene richiamato il metodo della lettura del file xml e si verificano due casi: se la lista è piena, allora per ogni server/repository del file xml, viene stampato il suo nome e indirizzo (server), oppure il suo nome, la versione e i files contenuti (repository); altrimenti se la lista è vuota viene stampato un messaggio di avviso.

### ADD SERVER
Abbiamo creato uno scope per gestire le eccezioni, in caso di parametri scritti in modo non corretto oppure se manca il nome e/o l'indirizzo. Quando si aggiunge un server si richiama il metodo readFile e si effettua un controllo se il nome del server esiste già, in tal caso viene stampato un messaggio, altrimenti tutti i dati vengono inseriti nel file xml, richiamando il metodo writeFile.

### REMOVE SERVER
Anche in questo caso si crea uno scope per gestire le solite eccezioni. Se la lista dei server è vuota allora viene sollevata un'eccezione, altrimenti per ogni server della lista si controlla il nome, e se corrisponde a quello da rimuovere viene eliminato dalla lista che in seguito viene riordinata. 

### ADD REPOSITORY
Questo è un comando nel quale è indispensabile l'intervento del server. Infatti scriviamo in input il nome del server a cui vogliamo collegarci, il nome della rep che 
vogliamo creare ed il nome della directory locale del client che andremo a copiare; poi richiamiamo il registro, che ha il compito di ricercare nella lista dei server il nome di quello richiesto in input, ed in seguito prelevare il suo indirizzo, così da connettersi a questo server. 
Infine si connette il client con tale server, attraverso la porta creata, e si inviano i dati della repository da creare. Ciò che il client si aspetta di ricevere sarà un messaggio di successo (se la rep è stata aggiunta) oppure di errore. 

### LIST NEW_REPOS
Questo comando si collega al server, catturando un'eccezione nel caso in cui questo non sia disponibile, e invia la richiesta della stampa delle repositories. Viene inserito l'indirizzo a cui collegarsi al server, e poi viene richiamato il metodo registro per fare il collegamento. In seguito il server salva i nomi di tutte le repositories presenti in una stringa, che ritorna al client.

### Sezione su `push`

Abbiamo implementato la funzione di `push` ...

### Altra sezione su una feature che si vuole discutere

...
