require './hybrid_methods'
require 'sparql/client'

sparql = SPARQL::Client.new("https://id.ndl.go.jp/auth/ndla/sparql", method: "get") 


#読み込むファイルパスを指定(NDLに対するサブクエリの内側クエリ)
# input_file_path = "../../SPARQL_query_sample/ndl_subquery_in.sparql"

# input_file = File.open(input_file_path, "r")
# query = input_file.read

# result = ignore_limits(sparql, query)
# p result.length


#読み込むファイルパスを指定(NDLに対するサブクエリ)
input_file_path = "../../SPARQL_query_sample/ndl_subquery.sparql"
input_file = File.open(input_file_path, "r")
query = input_file.read

#SPARQLライブラリのimport
require 'sparql'


query_object = SPARQL::Grammar::Parser.new(query) #SPARQLライブラリのオブジェクトして扱う
# p query_object.class
query_object_parsed = query_object.parse() #SPARQLクエリを解析
# p query_object_parsed.class
query_sseArray = query_object_parsed.to_sxp_bin #解析したクエリをSPARQLクエリをsse形式のarrayに変換

# pp query_sseArray

result = subquery_hybrid(sparql, query_sseArray)
# p result.length