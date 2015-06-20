/**
 * 
 * 
 * Gianmarco 
 * Spinaci
 * 0000691241
 * gianmarco.spinaci@studio.unibo.it
 * 
 * REPORT:
 * 
 * DATA -> 8/05/15
 * 
 * ho valutato un algoritmo di risoluzione che va con O(n^2)
 * 
 * creo una matrice NxN, che contiene le distanze tra tutte le città
 * essendo una matrice speculare mi basta lavorare su (N^2 - N)/2 elementi della matrice
 * 
 * creazione della matrice Θ( (N^2 - N)/2 )
 * 
 * Errato, devo lavorare su N^2 elementi 
 * 
 * ad ogni riga t aggiorno il corrispondente contatore, che indica le città adiacenti
 * e inserisco un identificatore formato da [identificativo città, numero città adiacenti] in una delle seguenti strutture:
 * 
 * 						inserimento		ricercaMaggiore		riordinamento
 * - max heap  			O(log n)		O(1)				O(log n)
 * - array ordinato 	O(1)			O(1)				O(n log n)
 * 
 * nota (per rendere competitivo l'uso di array ordinato, viene ordinato solo dopo aver inserito tutti gli elementi, con un quick sort)
 * 
 * 
 * elimino l'elemento massimo (con più città adiacenti non coperte) 
 * ne conosco le coordinate della matrice
 * 
 * ##########################REPORT FINALE###############################################
 * 
 * DATA -> 21/05/15
 * 
 * Cambiato l'utilizzo di strutture dati,
 * 
 * Lettura iniziale del file Θ( (N^2 - N)/2 ) poichè distanza(A,B) = distanza(B,A) 
 * allora si utilizza la matrice come una diagonale superiore
 * 
 * Salvo ogni Citta dentro un array, e ogni città adiacente dentro una LinkedList<Citta> nell'oggetto
 * 
 * L'algoritmo itera finchè non tutte le città sono coperte
 * Ad ogni giro prendo la città con più città adiacenti non coperte, chiamata U
 * 
 * controllo tutte le città adiacenti di primo grado ad U (compresa se stessa)
 * e controllo tutte le città adiacenti di secondo grado ad U
 * diminuiendo il suo contatore di città adiacenti solo se la città non era stata precedentemente coperta
 *
 * infine faccio un quick sort sull'array per ri-ottenere 
 * alla posizione 0 la citta con più città non coperte adiacenti
 * 
 * 
 */

import java.io.*;
import java.util.*;

/*
 * Class Citta
 * 
 * Usata per il metodo compareTo che ordina le città in base 
 * al numero di città adiacenti
 * 
 * La classe tiene conto di caratteristiche della città
 */
class Citta implements Comparable<Citta>{
	
	double x;
	double y;
	
	int indice;
	boolean coperto;
	int numeroAdiacenti;
	
	LinkedList<Citta> adiacenti;
	
	Citta(int index, String ... cord){
		
		this.x = Double.parseDouble(cord[0]);
		this.y = Double.parseDouble(cord[1]);
		
		adiacenti = new LinkedList<>();
		//numeroAdiacenti = 0;
		
		this.indice = index;
		this.coperto = false;
	}
	
	public int compareTo(Citta citta){
		
		if( Integer.compare(this.numeroAdiacenti, citta.numeroAdiacenti) == 0 )
			
			return Integer.compare(this.indice, citta.indice );
		
		
        return -Integer.compare(this.numeroAdiacenti, citta.numeroAdiacenti);
    }
}

class SoluzioneEsericizio4{
	
	BufferedReader reader;
	
	double raggio;
	int numeroCitta;
	Citta[] citta;
	/*
	 * Metodo costruttore
	 * 
	 * Accetta il nome del file
	 * e crea l'array 
	 */
	SoluzioneEsericizio4(String nomeFile){
		
		try{
			
			reader = new BufferedReader(new FileReader(new File(nomeFile)));
			
			raggio = Double.parseDouble(reader.readLine());
			numeroCitta = Integer.parseInt(reader.readLine());
			
			citta = new Citta[numeroCitta];
			
			//inizializzazione, O(n)
			for( int i = 0; i < numeroCitta; i++ ){
				
				String[] row = reader.readLine().split("\\s+");
				
				citta[i] = new Citta(i,row);
			}
			
			/*
			 * 
			 * Θ( (N^2 - N)/2 ) lettura di tutte le distanze
			 * 
			 * LinkedList
			 * O(1) inserimento
			 */
			for(int i=0; i<numeroCitta-1; i++){
				
				for(int j=i; j<numeroCitta; j++){
					
					double distanza = Math.sqrt( Math.pow(citta[i].x - citta[j].x,2) + Math.pow(citta[i].y - citta[j].y,2));
					
					//salvo la distanza solo se è minore del raggio
					if(distanza < raggio){
						
						citta[i].adiacenti.add(citta[j]);
						citta[i].numeroAdiacenti++;
						
						//e se la distanza non è data dalla distanza della stessa città
						//la aggiungo anche dall'altra parte
						if(distanza != 0){
							
							citta[j].adiacenti.add(citta[i]);
							citta[j].numeroAdiacenti++;
						}
					}
				}
			}
		}
		
		catch(IOException e){
			
			System.out.println(e);
		}
	}
	/*
	 * Algoritmo principale
	 * 
	 * Faccio un sorting sull'array
	 * Quick sort O(n log n)
	 * 
	 * continuo ad iterare finchè tutte le città non sono coperte
	 * 
	 * Ad ogni giro aggiorno il numero di città non ancora coperte
	 * sottraendo il numero di città adiacenti dalla città alla posizione 0
	 * 
	 * Setto a true ogni città adiacente alla città U
	 * 
	 * Stampo poi tutti i risultati
	 * 
	 */
	public void posizionaAntenne(){
		
		ArrayList<Integer> risultati = new ArrayList<>();
						
		while(numeroCitta > 0){
			
			//esegue un quick sort sull'array
			//O(n log n)
			Arrays.sort(citta);
			
			Citta u = citta[0];
			
			numeroCitta -= u.numeroAdiacenti;
			
			risultati.add(u.indice);
			
			//prendo tutte le città adiacenti di U
			for(Citta adiacentePrimoGrado : u.adiacenti){
				
				//prendo tutte le città adiacenti delle adiacenti di U
				for(Citta adiacenteSecondoGrado : adiacentePrimoGrado.adiacenti){
					
					//se la città adiacente ad U non era stata precedentemente coperta
					//allora diminuisco il numero di città adiacenti non coperte
					if(!adiacentePrimoGrado.coperto)
						
						adiacenteSecondoGrado.numeroAdiacenti--;
				}
				
				//setto la città adiacente ad U come coperta
				//la setto dopo così da poter entrare nell'if precedente
				adiacentePrimoGrado.coperto = true;
			}
		}
		
		for(Integer ris : risultati){
			
			System.out.println(ris);
		}
		
	}
}

public class Esercizio4 {

	public static void main(String[] args) {
		
		new SoluzioneEsericizio4(args[0]).posizionaAntenne();
	}
}