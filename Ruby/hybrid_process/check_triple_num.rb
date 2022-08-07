# SPARQLエンドポイントのトリプル数を取得する
require 'sparql/client'
endpoint_url = "https://id.ndl.go.jp/auth/ndla/sparql"

sparql = SPARQL::Client.new(endpoint_url, method: "get") #Web NDL authoritiesは、method:"get"を指定しないとエラーが起きる

query = """
select (count(?s) AS ?triple_num) where{
    ?s ?p ?o.
}
"""

result = sparql.query(query)

var_list = result.variable_names
var_count = var_list[0] #トリプル数を取得するクエリでは、返り値は1つの変数のみ(?triple_numが格納)
p result[0][var_count].object #クエリ結果の配列(RDF::Query::Solutions)の最初の要素にトリプル数が格納されたオブジェクトがある
