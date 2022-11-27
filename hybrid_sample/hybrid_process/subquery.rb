#WebNDLauthoritiesでのサブクエリをハイブリッド化
# endpoint → Web NDL authorities

require 'sparql/client'
sparql = SPARQL::Client.new("https://id.ndl.go.jp/auth/ndla/sparql", method: "get") #Web NDL authoritiesへ問い合わせるときには第2引数にmethod: "get"を指定する

#サブクエリを読み込み
file_path = "../../SPARQL_query_sample/ndl_subquery.sparql"
file = File.open(file_path, "r")
query = file.read
result = sparql.query(query)
p result.order_by(:auth).class


#内側SPARQLクエリを読み込み
# file_path = "../../SPARQL_query_sample/ndl_subquery_in.sparql"
# file = File.open(file_path, "r")
# query_in = file.read
query_in = """
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
SELECT ?auth (count(?rel) as ?rcount) WHERE {
    ?auth skos:relatedMatch ?rel .
    FILTER (regex(?rel, \"^http://id.ndl.go.jp/class/ndc10/\"))
} GROUP BY ?auth HAVING(count(?rel) >= 4)
"""
result_in = sparql.query(query_in)

result_hybrid = RDF::Query::Solutions.new()

result_in.each{|r_in|
    #外側SPARQLクエリを読み込み
    # file_path = "../../SPARQL_query_sample/ndl_subquery_out.sparql"
    # file = File.open(file_path, "r")
    # query_out = file.read
    auth = r_in[:auth]
    rcount = r_in[:rcount]
    # query_out = """
    # PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
    # SELECT (<#{auth}> as ?auth) (#{rcount} as ?rcount) ?upper (count(?srel) as ?srcount) 
    # WHERE {
    #     <#{auth}> skos:broader ?upper.
    #     ?upper skos:relatedMatch ?srel .
    #     FILTER (regex(?srel, \"^http://id.ndl.go.jp/class/ndc10/\"))
    # }
    # """
    query_out = """
    PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
    SELECT ?auth ?rcount ?upper (count(?srel) as ?srcount) 
    WHERE 
    {
        BIND (<#{auth}> AS ?auth)
        BIND (<#{rcount}> AS ?rcount)
        ?auth skos:broader ?upper.
        ?upper skos:relatedMatch ?srel .
        FILTER (regex(?srel, \"^http://id.ndl.go.jp/class/ndc10/\"))
    }
    """
    require 'sparql'
    query_object = SPARQL::Grammar::Parser.new(query_out)
    query_object_parsed = query_object.parse()
    query_sseArray = query_object_parsed.to_sxp_bin  
    
    #queryの内容を一旦sseArrayに変換→SPARQLに戻して問い合わせ
    sseArray_Parsed = SPARQL::Algebra::Expression.new(query_sseArray) 
    puts sseArray_Parsed.to_sparql
    result_out = sparql.query(sseArray_Parsed.to_sparql)
    p result_out.length
    result_out.each{|r_out|
        result_hybrid.push(r_out)
    }
}
p result_hybrid.order(:auth)[0]
p result.order(:auth)[0]
p result_hybrid.length
p result.length


