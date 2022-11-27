# Query1_3.sparqlを利用
# endpoint → 汎用

query1_3 = """
SELECT ?sub 
WHERE{
    ?sub ?pred ?obj.
}  
"""

require 'sparql'
#クエリを引数としてSPARQL::Grammar::Parserクラスのオブジェクト作成 → 解析 → SSE形式のArrayに変換
query1_3 = SPARQL::Grammar::Parser.new(query1_3).parse().to_sxp_bin

require './methods'
result = sseArray_distinct_count(query1_3)
p result