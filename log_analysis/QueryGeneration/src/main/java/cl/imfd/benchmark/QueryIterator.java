package cl.imfd.benchmark;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.net.URLDecoder;
import java.util.Iterator;
import java.util.ArrayList;

public class QueryIterator implements Iterable<String> {

	// static String INPUT_FOLDER = "data/";
	static String INPUT_FOLDER = "log_analysis/query_log/wikidata/";

	static String[] INPUT_FILES = {
			// INPUT_FOLDER + "I1_status500_Joined.tsv",
			// INPUT_FOLDER + "I2_status500_Joined.tsv",
			// INPUT_FOLDER + "I3_status500_Joined.tsv",
			// INPUT_FOLDER + "I4_status500_Joined.tsv",
			// INPUT_FOLDER + "I5_status500_Joined.tsv",
			// INPUT_FOLDER + "I6_status500_Joined.tsv",
			// INPUT_FOLDER + "I7_status500_Joined.tsv",
			INPUT_FOLDER + "2018-02-26_2018-03-25_status_500.tsv",
	};

	@Override
	public Iterator<String> iterator() {
		Iterator<String> it = new Iterator<String>() {
			private BufferedReader br = null;

			private int currentInput = 0;

            private String currentLine;

            private String currentQuery;

			// private String encoded_query;

            @Override
            public boolean hasNext() {
            	try {
            		while (currentInput < INPUT_FILES.length) {
            			if (br == null) {
            				br = new BufferedReader(new FileReader(INPUT_FILES[currentInput]));
            				currentLine = br.readLine(); // skip header
            			}
            			if ((currentLine = br.readLine()) != null) {
            				String[] cols = currentLine.trim().split("\t");
            				if (cols.length != 4) {
            					throw new UnsupportedOperationException();
            				}
        					// currentQuery = URLDecoder.decode(cols[0], "UTF-8").replaceAll("\n", " ");
							currentQuery = cols[0];
            				return true;
            			} else {
            				currentInput++;
            				br = null;
            			}
            		}
            		return false;
				} catch (IOException e) {
					e.printStackTrace();
					return false;
				}
            }

            @Override
            public String next() {
                return currentQuery;
            }

			// @Override
			// public ArrayList<String> next(){
			// 	ArrayList<String> returnString = new ArrayList<String>();
			// 	returnString.add(currentQuery);
			// 	returnString.add(encoded_query);
			// 	return returnString;
			// }

            @Override
            public void remove() {
                throw new UnsupportedOperationException();
            }
        };
        return it;
	}
}
