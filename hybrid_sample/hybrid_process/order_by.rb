# q2.sparqlを利用
# endpoint → SP2Bench

query = """
PREFIX rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs:    <http://www.w3.org/2000/01/rdf-schema#>
PREFIX swrc:    <http://swrc.ontoware.org/ontology#>
PREFIX foaf:    <http://xmlns.com/foaf/0.1/>
PREFIX bench:   <http://localhost/vocabulary/bench/>
PREFIX dc:      <http://purl.org/dc/elements/1.1/>
PREFIX dcterms: <http://purl.org/dc/terms/>
SELECT ?inproc ?author ?booktitle ?title 
       ?proc ?ee ?page ?url ?yr ?abstract
WHERE {
  ?inproc rdf:type bench:Inproceedings .
  ?inproc dc:creator ?author .
  ?inproc bench:booktitle ?booktitle .
  ?inproc dc:title ?title .
  ?inproc dcterms:partOf ?proc .
  ?inproc rdfs:seeAlso ?ee .
  ?inproc swrc:pages ?page .
  ?inproc foaf:homepage ?url .
  ?inproc dcterms:issued ?yr 
  OPTIONAL {
    ?inproc bench:abstract ?abstract
  }
}
"""

require 'sparql'
#クエリを引数としてSPARQL::Grammar::Parserクラスのオブジェクト作成 → 解析 → SSE形式のArrayに変換
query = SPARQL::Grammar::Parser.new(query).parse().to_sxp_bin

require './methods'
result = sseArray_order(query, "?yr", "ascending")
p result[0]