package ex6;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

/**Gibt eine Rennstrecke für unser Autorennen aus. 
 * 
 * @author Daniela
 * @version 1.0 
 */
public class RennstreckenGenerator {
	int [][] map;
	int width; 
	int height;
	public RennstreckenGenerator(int height, int width){
		this.width=width;
		this.height=height;
		map=new int[height][width];
		
		this.buildMap();
		this.writeFile();
	}
	
	private void buildMap(){
		
	}
	
	
	
	private void writeFile(){
		BufferedWriter out;
		try {
			out = new BufferedWriter(new FileWriter("Racetrack.txt", false));
			out.write("# Race Track");
			out.newLine();
			
			/*
			for (int i=0;i<height;i++){
				for (int j=0; j<width; j++){
					out.write(map[i][j]);
				}
			}
			*/
			
			//testtrack
			out.write("0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 0 0 ");
			out.newLine();
			out.write("0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 0 0 0 ");
			out.newLine();
			out.write("0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 0 0 0 0 ");
			out.newLine();
			out.write("0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 ");
			out.newLine();
			out.write("0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 ");
			out.newLine();
			out.write("0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 ");
			out.newLine();
			out.write("0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 0 0 1 1 1 1 1 1 1 1 1 0 0 0 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 ");
			out.newLine();
			out.write("0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 ");
			out.newLine();
			out.write("0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 ");
			out.newLine();
			out.write("0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 ");
			out.newLine();
			out.write("0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ");
			out.newLine();
			out.write("0 0 0 0 0 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ");
			out.newLine();
			out.write("0 0 0 0 0 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ");
			out.newLine();
			out.write("0 0 0 0 0 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ");
			out.newLine();
			out.write("0 0 0 0 0 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ");
			out.newLine();
			out.write("0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ");
			out.newLine();
			
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

		RennstreckenGenerator strecke = new RennstreckenGenerator(16,51);
		

	}

}
