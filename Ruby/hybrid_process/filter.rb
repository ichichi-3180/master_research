# q3a.sparqlを利用
# endpoint → SP2Bench

query = """
PREFIX rdf:   <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX bench: <http://localhost/vocabulary/bench/>
PREFIX swrc:  <http://swrc.ontoware.org/ontology#>

SELECT ?article ?property ?value
WHERE {
  ?article rdf:type bench:Article .
  ?article ?property ?value .
}
"""

require 'sparql'
#クエリを引数としてSPARQL::Grammar::Parserクラスのオブジェクト作成 → 解析 → SSE形式のArrayに変換
query = SPARQL::Grammar::Parser.new(query).parse().to_sxp_bin

# filterで指定する条件を指定
class Filter
    attr_accessor :left_side, :operator, :right_side
    def initialize(left_side,operator, right_side)
        @left_side = left_side
        @operator = operator
        @right_side = right_side
    end
end

# 変数
filter_condition = Filter.new("?property","=","http://swrc.ontoware.org/ontology#pages")
# left_side = "?property"
# right_side = "http://swrc.ontoware.org/ontology#pages"
# operator = "="

require './methods'
result = sseArray_filter_equal(query, filter_condition)
p result