require 'sparql/client'

#問い合わせ先のSPARQLエンドポイントのURLを指定
endpoint_url = "https://ja.dbpedia.org/sparql"
sparql = SPARQL::Client.new(endpoint_url) 
# sparql = SPARQL::Client.new(endpoint_url, method: "get") #Web NDL authoritiesへ問い合わせるときには第2引数にmethod: "get"を指定する

#読み込むSPARQLクエリのファイルパスを指定
file_path = "../SPARQL50本ノック/SPARQL_045_in.sparql"
# file_path = "../SPARQL_query_sample/ndl_subquery_out.sparql"

file = File.open(file_path, "r")
query = file.read

#問い合わせを実行
result = sparql.query(query)

# p result