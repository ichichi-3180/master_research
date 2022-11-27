# SPARQLエンドポイントのトリプル数を取得する
require 'sparql/client'
endpoint_url = "https://id.ndl.go.jp/auth/ndla/sparql"

sparql = SPARQL::Client.new(endpoint_url, method: "get") #Web NDL authoritiesは、method:"get"を指定しないとエラーが起きる

query = """
select ?s where{
    ?s ?p ?o.
}
"""

result = sparql.query(query)
p result.count