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

public class ExtractOptional {

	public static void main(String[] args) throws UnsupportedEncodingException, IOException {
		String OutputDirectoryName = "log_analysis/query/wikidata/Filtered/";
		// TreeSet<String> optQueries = new TreeSet<String>();
		TreeSet<String> OptionalPatternQueries = new TreeSet<String>();

		QueryIterator queryIter = new QueryIterator();
		for (String query : queryIter) {
			String encoded_query = query;
			query = URLDecoder.decode(query, "UTF-8").replaceAll("\n", " ");
			Op op = null;
			ExtractOptionalVisitor visitor = new ExtractOptionalVisitor();

			try {
				op = (new AlgebraGenerator()).compile(QueryFactory.create(query));
				op.visit(visitor);
			} catch (QueryParseException e) {
				continue;
			} catch (QueryException e) {
				continue;
			}
			if (!visitor.hasUnsuportedOp
				&& visitor.optionalNode.bgp.size() > 0
				&& visitor.optionalNode.optionalChildren.size() > 0)
			{
				String str = visitor.optionalNode.toString();

				visitor.optionalNode.toString(); // sets propertly visitor.optionalNode.crossProduct
				if (!visitor.optionalNode.crossProduct) {
					// optQueries.add(str);
					OptionalPatternQueries.add(encoded_query);
				}
			}
		}

		// Write queries into file
		try {
		    //   FileWriter optsFile = new FileWriter("opts.txt");
		    FileWriter OptionalFile = new FileWriter(OutputDirectoryName + "optional_queries.tsv");

		    //   int count = 0;
		    //   for (String query : optQueries) {
		    // 	  count++;
		    // 	  optsFile.write(Integer.toString(count));
		    // 	  optsFile.write(',');
		    // 	  optsFile.write(query);
		    // 	  optsFile.write('\n');
		    //   }
			int _count = 0;
			for (String query : OptionalPatternQueries) {
				_count++;
				OptionalFile.write(Integer.toString(_count));
				OptionalFile.write('\t');
				OptionalFile.write(query);
				OptionalFile.write('\n');
			}

		    OptionalFile.close();
	    } catch (IOException e) {
	    	System.out.println("An error occurred writing the output.");
	    	e.printStackTrace();
	    }
	}
}
