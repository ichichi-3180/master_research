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

subquery_result = sparql.query(query)

#SPARQLライブラリのimport
require 'sparql'


#SPARQLライブラリのオブジェクトして扱う
query_object = SPARQL::Grammar::Parser.new(query) 

#SPARQLクエリを解析
query_object_parsed = query_object.parse()

#解析したクエリをSPARQLクエリをsse形式のarrayに変換
query_sseArray = query_object_parsed.to_sxp_bin 

# pp query_sseArray

subquery_hybrid_result = subquery_hybrid(sparql, query_sseArray)
# p result.length

p subquery_hybrid_result.order(:auth)[0]
p subquery_result.order(:auth)[0]
p subquery_hybrid_result.length
p subquery_result.length