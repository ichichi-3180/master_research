# endpoint → 汎用
require 'sparql/client'
require 'sparql'

#リソースごとのプロパティ数を取得するクエリ
query = """
select ?s (COUNT(?p) AS ?p_num) where{
    ?s ?p ?o.
}
GROUP BY ?s
"""

#このクエリはendpointごとの返り値の上限の影響を受ける
base_query = """
select ?s where{
    ?s ?p ?o.
}
"""

base_query = SPARQL::Grammar::Parser.new(base_query).parse().to_sxp_bin #SPARQLをsse形式のArrayに変換(想定しているのは、Array形式のinputのため)
pp base_query
base_query_Parsed = SPARQL::Algebra::Expression.new(base_query) #sseArrayをinputして新たなオブジェクトとする
pp base_query_Parsed
base_query_sparql = base_query_Parsed.to_sparql #上記で作成したオブジェクトをSPARQL式にする
p base_query_sparql

sparql = SPARQL::Client.new("http://localhost:3030/onsen/sparql") #返り値の上限の影響を受けないようにローカルのエンドポイントを利用(空白ノードが含まれるエンドポイントだとエラー)
base_query_result = sparql.query(base_query_sparql)

#本来のgroup_byクエリの結果を取得
query_result = sparql.query(query)

base_query_result.variable_names = ["s","p_num"] #出力要素を追加(更新)

#bgpの取得結果に対して、GROUP BYする変数を重複削除して取得
base_query_result.distinct.each {|solution|
    #取得した変数に対応する値ごとにプロパティを取得
    query = """
    select ?p where{
        <#{solution[:s]}> ?p ?o.
    }
    """
    p_result = sparql.query(query)   
    solution[:p_num] = RDF::Literal::Integer.new(p_result.length) #プロパティの数をカウントして結果の変数に代入
}

p base_query_result.order_by(:s).to_json == query_result.order_by(:s).to_json #groupbyを利用した場合と利用しなかった場合で結果を比較(変数内のIDは異なるため、値だけで比較)