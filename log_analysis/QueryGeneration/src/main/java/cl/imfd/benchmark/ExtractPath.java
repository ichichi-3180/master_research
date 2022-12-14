package cl.imfd.benchmark;

import java.io.FileWriter;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.TreeSet;

import org.apache.jena.query.QueryException;
import org.apache.jena.query.QueryFactory;
import org.apache.jena.query.QueryParseException;
import org.apache.jena.sparql.algebra.AlgebraGenerator;
import org.apache.jena.sparql.algebra.Op;

public class ExtractPath {

	public static void main(String[] args) throws UnsupportedEncodingException, IOException {
		String OutputDirectoryName = "log_analysis/query/wikidata/Filtered/";
		// TreeSet<String> pathQueries = new TreeSet<String>();
		TreeSet<String> PathPatternQueries = new TreeSet<String>();

		QueryIterator queryIter = new QueryIterator();

		for (String query : queryIter) {
			String encoded_query = query;
			query = URLDecoder.decode(query, "UTF-8").replaceAll("\n", " ");
			Op op = null;

			try {
				op = (new AlgebraGenerator()).compile(QueryFactory.create(query));
			} catch (QueryParseException e) {
				continue;
			} catch (QueryException e) {
				continue;
			}
			ExtractPathVisitor visitor = new ExtractPathVisitor();
			op.visit(visitor);

			if (!visitor.hasUnsuportedOp) {
				for (String path_str : visitor.pathsSet) {
					// pathQueries.add(path_str);
					PathPatternQueries.add(encoded_query);
				}
			}
		}

		// Write Paths into file
		try {
			FileWriter pathsFile = new FileWriter(OutputDirectoryName + "paths_queries.tsv");

			int count = 0;
			for (String query : PathPatternQueries) {
				count++;
				pathsFile.write(Integer.toString(count));
				pathsFile.write('\t');
				pathsFile.write(query);
				pathsFile.write('\n');
			}

			pathsFile.close();
	    } catch (IOException e) {
	    	System.out.println("An error occurred.");
	    	e.printStackTrace();
	    }
	}
}
