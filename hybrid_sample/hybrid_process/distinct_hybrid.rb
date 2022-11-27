#読み込むファイルのパスを指定
# input_file_path = "../../SPARQL_query_sample/ndl_distinct.sparql"
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

splited = get_except_distinct(query_sseArray) #sseArrayからDistinct句を除いたのsseArrayを抽出
pp splited
query_Parsed = SPARQL::Algebra::Expression.new(splited) #sseArrayをinputとして、SPARQLライブラリのオブジェクトとして扱う
delete_distinct_query = query_Parsed.to_sparql

require 'sparql/client'
# sparql = SPARQL::Client.new("https://id.ndl.go.jp/auth/ndla/sparql", method: "get") 
sparql = SPARQL::Client.new("https://ja.dbpedia.org/sparql") 


result = ignore_limits(sparql, delete_distinct_query) #元のクエリからdistinct句を除いたクエリに関して、エンドポイントの取得限界値を超えて取得


#ハイブリッド化後
before_hybrid_element_num = result.uniq.length #distinct句を除いたクエリに関して重複を削除した要素の個数を取得

#ハイブリッド化前
before_result = ignore_limits(sparql,query) #元のクエリに関して、エンドポイントの取得限界値を超えて取得
after_hybrid_element_num = before_result.length #元のクエリの問い合わせ結果の要素数を取得

#ハイブリッド化前とハイブリッド化後で結果となった要素数を比較
p "ハイブリッド化前の取得要素数：" + before_hybrid_element_num.to_s
p "ハイブリッド化後の取得要素数：" + after_hybrid_element_num.to_s


output_file_name = "SPARQL_034_distinct_delete"
output_path = "../query_output/"
File.open(output_path + 'sparql/' +  output_file_name + '.sparql', 'w'){|f|
    f.write(delete_distinct_query)
}