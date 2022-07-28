# Query1_2.sparqlを利用

query1_2 = """
SELECT distinct ?sub 
WHERE{
    ?sub ?pred ?obj.
}
"""

require 'sparql'
#クエリを引数としてSPARQL::Grammar::Parserクラスのオブジェクト作成 → 解析 → SSE形式のArrayに変換
query1_2 = SPARQL::Grammar::Parser.new(query1_2).parse().to_sxp_bin

require './methods'
result = sseArray_count(query1_2)
p result