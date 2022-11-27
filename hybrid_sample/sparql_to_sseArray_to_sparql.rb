#読み込むファイルのパスを指定
file_path = "../SPARQL50本ノック/SPARQL_013.sparql"
# file_path = "../SPARQL_query_sample/SPARQL_014_filter.sparql"
# file_path = "./query_output/sparql/SPARQL_014_filter_1.sparql"

file = File.open(file_path, "r")
query = file.read

#SPARQLライブラリのimport
require 'sparql'
query = SPARQL::Grammar::Parser.new(query) #SPARQLライブラリのオブジェクトして扱う
p query.class
query = query.parse() #SPARQLクエリを解析
p query.class
query_sseArray = query.to_sxp_bin #解析したクエリをSPARQLクエリをsse形式のarrayに変換
p query_sseArray.class

query_Parsed = SPARQL::Algebra::Expression.new(query_sseArray) #sseArrayをinputとして、SPARQLライブラリのオブジェクトとして扱う
p query_Parsed.class
query_sparql = query_Parsed.to_sparql #to_sparqlメソッドを利用して、SPARQLライブラリのオブジェクトをSPARQLに変換

#書き出すファイルの指定
output_file_name = "SPARQL_013_1"
output_path = "query_output/"
File.open(output_path + 'sparql/' +  output_file_name + '.sparql', 'w'){|f|
    f.write(query_sparql)
}