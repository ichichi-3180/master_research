#読み込むファイルのパスを指定
# file_path = "../SPARQL50本ノック/SPARQL_013.sparql"
# input_file_path = "../SPARQL_query_sample/ndl_subquery.sparql"
# input_file_path = "../SPARQL50本ノック/SPARQL_034.sparql"
input_file_path = "../../SP2Bench/sp2b/queries/q9.sparql"
input_file = File.open(input_file_path, "r")
query = input_file.read


#SPARQLライブラリのimport
require 'sparql'

query = SPARQL::Grammar::Parser.new(query) #SPARQLライブラリのオブジェクトして扱う
p query.class
query = query.parse() #SPARQLクエリを解析
# p query.class.ancestors
# p query.class.method(:to_sxp_bin).owner
# p query.class.method(:to_sxp_bin).source_location
query_sse = query.to_sxp #SPARQL S-Expressions(SSE)
query_sseArray = query.to_sxp_bin #解析したクエリをSPARQLクエリをsse形式のarrayに変換

p query_sseArray.class
pp query_sseArray
#書き出すファイルの指定
output_file_name = "q9.sparql"
output_path = "query_output/"

#テキストとしてsseArrayを出力
File.open(output_path + 'txt/' +  output_file_name + '.txt', 'w'){|f|
    f.write(query_sseArray)
}

#SSEを出力
File.open(output_path + 'sse/' +  output_file_name + '.txt', 'w'){|f|
    f.write(query_sse)
}

#jsonとしてsseArrayを出力(vscodeの拡張機能で自動整形が可能なため可読性が上がるが、クラスなどが出力されない)
File.open(output_path + 'json/' +  output_file_name + '.json', 'w'){|f|
    f.write(query_sseArray.to_json)
}