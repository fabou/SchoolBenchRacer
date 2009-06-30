package ex6;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

/**Gibt eine zufallsgenerierte Rennstrecke für unser Autorennen aus. 
 * Kreise innerhalb der Strecke sind noch möglich. 
 * Aufruf mit java -jar RennstreckenGenerator Streckenbreite
 * 
 * @author Daniela
 * @version 1.2 
 */
public class RennstreckenGenerator {
	int [][] map;
	private int width; 
	private int height;
	private int nrCars;
	
	/** Konstruktor 
	 * 
	 * @param nrCars int. minimale Breite der Rennstrecke.
	 */
	public RennstreckenGenerator(int nrCars){
		this.nrCars=nrCars;
		this.height=nrCars*10;
		this.width=nrCars*10;
		map=new int[height][width];
		
		this.buildMap(nrCars);
		this.writeFile();
	}
	
	/** Baut die Rennstrecke auf. Start wird zufällig am unteren Ende der Karte gewählt.
	 * Der Streckenverlauf ist zufällig, 
	 * 
	 * @param nrCars
	 */
	private void buildMap(int nrCars){
		int x;
		int y=height-1;
		
		int start = (int)Math.round(Math.random()*(width-2-nrCars))+1;
		x=start;
		//System.out.println("start"+x);
		fill(x,y);
		y--;
		fill(x,y);
		
		
		
	
			while(y-nrCars>=0){
				int direction = (int)Math.round(Math.random()*3); //0: unten, 1: links, 2: oben, 3: rechts
				//System.out.println(direction);
				int distance = (int)Math.round(Math.random()*(nrCars-2));
				
				for (int i=0; i<=distance; i++){
					
				
				if (direction == 0){//unten
					if ((y+2)<height){//unterer Rand erreicht?
						if (map[y+1][x]==0){//Feld bereits befahren?
							y++;
							this.fill(x, y);
							//System.out.println("unten");
							//this.drawMap();
						}
							
					}else{
						if (x<start){
							direction=1;
						}else if (x>start){
							direction=3;
						}else{
							direction=2;
						}
					}
					
					
					
				}
				if (direction == 1){//links
					if (x-1>0){ //linker rand erreicht?
						if (map[y][x-1]==0&&map[y+1][x-1]==0){ //feld (und feld darunter bereits befahren?
							x--;
							this.fill(x,y);
							//System.out.println("links");
							//this.drawMap();
						}else{//geht nach unten wenn noch ein zug über ist 
							direction=0;
						}
					}else{ //geht nach oben wenn linker Rand erreicht wird
						direction=2;
					}

					
				}
				
				if (direction == 3){//rechts
					if (x+nrCars<width-1){//rechter rand erreicht?
						if (map[y][x+nrCars]==0&&map[y+1][x+nrCars]==0){//feld (+breite) (und feld darunter bereits befahren?
							x++;
							this.fill(x,y);
							//System.out.println("rechts");
							//this.drawMap();
						}else{//geht nach unten falls noch ein zug über ist
							direction=0;
						}
					}else{
						direction=2;
					}
					
				}
				
				
			
				}
				if (direction == 2){//oben
					y--;
					this.fill(x,y);
					//System.out.println("oben");
					//this.drawMap();
				}
			}

	}
	/**füllt die Karte am gegebenen Punkt auf (je Mindestbreite nach rechts und oben)
	 * 
	 * @param x (x Koordinate des Punktes)
	 * @param y (y Koordinate des Punktes)
	 */
	private void fill(int x, int y){
		for (int i=y;i>y-nrCars;i--){
			for (int j=x; j<x+nrCars; j++){
				map[i][j]=1;
			}
			
		}
	}
	
	/**Gibt die Karte auf der Kommandline aus
	 * 
	 */
	private void drawMap(){
		for (int i=0;i<height;i++){
			for (int j=0; j<width; j++){
				
				System.out.print(map[i][j]+" ");
			}
			System.out.println();
		}
		System.out.println();
		System.out.println();
	}
	
	/**Speichert die Karte als Racetrack.txt
	 * 
	 */
	private void writeFile(){
		BufferedWriter out;
		try {
			out = new BufferedWriter(new FileWriter("Racetrack.txt", false));
			//System.out.println("# Race Track");
			out.write("# Race Track");
			out.newLine();
			
			
			for (int i=0;i<height;i++){
				for (int j=0; j<width; j++){
					out.write(map[i][j]+" ");
					System.out.print(map[i][j]+" ");
				}
				out.newLine();
				System.out.println();
			}
			
			out.close();
			
		} catch (IOException e) {
			e.printStackTrace();
			System.out.println("Fehler beim Schreiben des Rennstreckenfiles in RennstreckenGenerator.java");
		}
	}
	
	/**
	 * @param args Anzahl der Autos (minimale Streckenbreite)
	 */
	public static void main(String[] args) {

		RennstreckenGenerator strecke = new RennstreckenGenerator(Integer.parseInt(args[0]));
		

	}

}