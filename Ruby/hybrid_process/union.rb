# SP2Benchのq9.sparqlを分割した場合を想定
# endpoint → SP2Bench

query1 = """
PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>

SELECT DISTINCT ?predicate
WHERE
{
    ?person rdf:type foaf:Person.
    ?subject ?predicate ?person.
}
"""

query2 = """
PREFIX rdf:  <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>

SELECT DISTINCT ?predicate
WHERE
{
    ?person rdf:type foaf:Person .
    ?person ?predicate ?object
}
"""

require 'sparql'

#クエリを引数としてSPARQL::Grammar::Parserクラスのオブジェクト作成 → 解析 → SSE形式のArrayに変換
query1 = SPARQL::Grammar::Parser.new(query1).parse().to_sxp_bin
query2 = SPARQL::Grammar::Parser.new(query2).parse().to_sxp_bin

require './methods'
result = sseArray_union(query1, query2)
print(result)

