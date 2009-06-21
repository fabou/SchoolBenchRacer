package ex6;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

/**Gibt eine zufallsgenerierte Rennstrecke für unser Autorennen aus. 
 * Aufruf mit Java -jar RennstreckenGenerator Streckenbreite
 * 
 * @author Daniela
 * @version 1.1 
 */
public class RennstreckenGenerator {
	int [][] map;
	private int width; 
	private int height;
	private int nrCars;
	
	public RennstreckenGenerator(int nrCars){
		this.nrCars=nrCars;
		this.height=nrCars*10;
		this.width=nrCars*10;
		map=new int[height][width];
		
		this.buildMap(nrCars);
		this.writeFile();
	}
	
	private void buildMap(int nrCars){
		int x;
		int y=height-1;
		
		int start = (int)Math.round(Math.random()*(width-2-nrCars))+1;
		x=start;
		//System.out.println("start"+x);
		fill(x,y);
		
		
		
	
			while(y-nrCars>=0){
				int direction = (int)Math.round(Math.random()*3); //0: unten, 1: links, 2: oben, 3: rechts
				//System.out.println(direction);
				if (direction == 0){//unten
					if (y+1<height){
						if (map[y+1][x]==0){
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
					if (x-1>0){
						if (map[y][x-1]==0){
							x--;
							this.fill(x,y);
							//System.out.println("links");
							//this.drawMap();
						}						
					}else{ //geht nach oben wenn linker Rand erreicht wird
						direction=2;
					}

					
				}
				
				if (direction == 3){//rechts
					if (x+nrCars<width-1){
						if (map[y][x+nrCars]==0){
							x++;
							this.fill(x,y);
							//System.out.println("rechts");
							//this.drawMap();
						}
					}else{
						direction=2;
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
	
	private void fill(int x, int y){
		for (int i=y;i>y-nrCars;i--){
			for (int j=x; j<x+nrCars; j++){
				map[i][j]=1;
			}
			
		}
	}
	
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
					//System.out.print(map[i][j]+" ");
				}
				out.newLine();
				//System.out.println();
			}
			
			out.close();
			
		} catch (IOException e) {
			e.printStackTrace();
			System.out.println("Fehler beim Schreiben des Rennstreckenfiles in RennstreckenGenerator.java");
		}
	}
	
	/**
	 * @param args
	 */
	public static void main(String[] args) {

		RennstreckenGenerator strecke = new RennstreckenGenerator(Integer.parseInt(args[0]));
		

	}

}
