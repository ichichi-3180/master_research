require 'sparql/client'
require 'sparql'
# @uri = "http://localhost:3030/SP2Bench_10000/sparql"
@uri = "https://ja.dbpedia.org/sparql"
sparql = SPARQL::Client.new(@uri)
# sparql = SPARQL::Client.new("https://id.ndl.go.jp/auth/ndla/sparql", method: "get")

def sseArray_count(query_sseArray)
    query_sseParsed = SPARQL::Algebra::Expression.new(query_sseArray) #arrayを解析後のオブジェクトに戻す
    query_sparql = query_sseParsed.to_sparql
    sparql = SPARQL::Client.new(@uri)
    result = sparql.query(query_sparql)
    return result.length
end

def sseArray_distinct_count(query_sseArray)
    query_sseParsed = SPARQL::Algebra::Expression.new(query_sseArray) #arrayを解析後のオブジェクトに戻す
    query_sparql = query_sseParsed.to_sparql
    sparql = SPARQL::Client.new(@uri)
    result = sparql.query(query_sparql)
    return result.distinct.count
end

def sseArray_union(query_sseArray1, query_sseArray2)
    query1_sseParsed = SPARQL::Algebra::Expression.new(query_sseArray1) #arrayを解析後のオブジェクトに戻す
    query2_sseParsed = SPARQL::Algebra::Expression.new(query_sseArray2) #arrayを解析後のオブジェクトに戻す
    query1_sparql = query1_sseParsed.to_sparql
    query2_sparql = query2_sseParsed.to_sparql
    sparql = SPARQL::Client.new(@uri)
    result1 = sparql.query(query1_sparql)
    result2 = sparql.query(query2_sparql)
    return result1 + result2
end

def sseArray_filter_equal(query_sseArray, filter_condition)
    # p filter_condition
    # p query_sseArray
    query_sseParsed = SPARQL::Algebra::Expression.new(query_sseArray) #arrayを解析後のオブジェクトに戻す
    query_sparql = query_sseParsed.to_sparql
    sparql = SPARQL::Client.new(@uri)
    result = sparql.query(query_sparql)
    # p filter_condition.left_side.match(/\?(.+)/)[1] #変数の?以降を抽出
    p result.length #filter前
    # filter_conditionオブジェクトのleft_sideから?以降を抽出し、right_sideを値とするhashをRDF::Query::Solutionsのfilterメソッドに引数として渡す
    result = result.filter({filter_condition.left_side.match(/\?(.+)/)[1] => filter_condition.right_side})
    p result.length #filter後
    return result
end

def sseArray_order(query_sseArray, variable, order)
    query_sseParsed = SPARQL::Algebra::Expression.new(query_sseArray) #arrayを解析後のオブジェクトに戻す
    query_sparql = query_sseParsed.to_sparql
    sparql = SPARQL::Client.new(@uri)
    result = sparql.query(query_sparql)
    result = result.order_by(:yr, lambda{|a, b| b<=>a})
    return result
end