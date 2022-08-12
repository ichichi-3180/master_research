#読み込むファイルのパスを指定
input_file_path = "../../SPARQL_query_sample/ndl_distinct.sparql"
input_file_path = "../../SPARQL50本ノック/SPARQL_034.sparql"

input_file = File.open(input_file_path, "r")
query = input_file.read

#SPARQLライブラリのimport
require 'sparql'


query_object = SPARQL::Grammar::Parser.new(query) #SPARQLライブラリのオブジェクトして扱う
p query_object.class
query_object_parsed = query_object.parse() #SPARQLクエリを解析
p query_object_parsed.class
query_sseArray = query_object_parsed.to_sxp_bin #解析したクエリをSPARQLクエリをsse形式のarrayに変換

pp query_sseArray
#リストの中身を再起的に取得して、キーワードごとの処理に分割する

# ハイブリッド化に利用するメソッドをimport
require './hybrid_methods'

splited = split_distinct(query_sseArray)
pp splited
query_Parsed = SPARQL::Algebra::Expression.new(splited) #sseArrayをinputとして、SPARQLライブラリのオブジェクトとして扱う
delete_distinct_query = query_Parsed.to_sparql

require 'sparql/client'
# sparql = SPARQL::Client.new("https://id.ndl.go.jp/auth/ndla/sparql", method: "get") 
sparql = SPARQL::Client.new("https://ja.dbpedia.org/sparql") 

p delete_distinct_query

result = ignore_limits(sparql, delete_distinct_query)


p "ハイブリッド後"
p delete_distinct_query
p result.uniq.length

p "ハイブリッド前"
p query
before_result = ignore_limits(sparql,query)
p before_result.length


output_file_name = "SPARQL_034_distinct_delete"
output_path = "../query_output/"
File.open(output_path + 'sparql/' +  output_file_name + '.sparql', 'w'){|f|
    f.write(query_Parsed.to_sparql)
}