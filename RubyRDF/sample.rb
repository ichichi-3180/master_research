require 'sparql/client'
require 'linkeddata'  # RDF::Repositoryクラスを利用するために必要
# require 'debug'
# 問い合わせ先を設定(ローカルにあるRDF)
repository = RDF::Repository.load("onsen_2021-10-11_12-28-26.nq")
sparql = SPARQL::Client.new(repository)

# SPARQLクエリの内容
# query = "SELECT distinct ?p WHERE {?s ?p ?o.}"
query = "SELECT distinct ?class WHERE{?s a ?class.}"
# query = """
# PREFIX skos: <http://www.w3.org/2004/02/skos/core#>

# SELECT ?auth ?rcount ?upper (count(?srel) as ?srcount) WHERE {
#     ?auth skos:broader ?upper.
#     ?upper skos:relatedMatch ?srel .
#     FILTER (regex(?srel, \"^http://id.ndl.go.jp/class/ndc10/\"))
#     {
#         SELECT ?auth (count(?rel) as ?rcount) WHERE {
#             ?auth skos:relatedMatch ?rel .
#             FILTER (regex(?rel, \"^http://id.ndl.go.jp/class/ndc10/\"))
#         } GROUP BY ?auth HAVING(count(?rel) >= 4)
#     }
# }
# """

# 問い合わせを実行
# p sparql.method(:query).source_location
result = sparql.query(query)

pp result.length
