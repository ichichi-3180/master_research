require 'active_support' #deepcopyするため
require 'sparql'
require 'sparql/client'

#sseArrayからDISTINCTを除いたsseArrayに分割するメソッド
def get_except_distinct(a)
    if a.length == 1 then
        return a
    else
        array = []
        while a.length != 0 do
            e = a.shift
            if e.class == Symbol then
                if e == :distinct then
                    next
                else
                    array.push(e)
                end
            elsif e.class == Array then
                array.push(get_except_distinct(e))
            else
                array.push(e)
            end
        end
        return array
    end
end

# 内側のsseArrayを抽出するメソッド
def get_in_sseArray(a)
    project_count = 0
    while a.length != 0 do 
        top = a.shift
        if top == :project then
            project_count += 1
            if project_count == 2 then
                break a.unshift(top)
            end
        elsif top.class == Array then
            top.reverse.each{|e|
                a.unshift(e)
            }
        else
        end
    end
end

# 外側のsseArrayを抽出するメソッド
# def get_out_sseArray(a)
#     project_count = 0
#     return_array = []
#     while a.length != 0 do 
#         array = []
#         top = a.shift
#         # p "hello"
#         # p top
#         if top == :project then
#             project_count += 1
#             if project_count == 2 then
#                 break
#             else
#                 array.push(top)
#                 return_array.push(top)
#             end
#         elsif top.class == Array then
#             # p top.length
#             top.reverse.each{|e|
#                 a.unshift(e)
#             }
#         else
#             return_array.push(top)
#         end
#     end
#     return return_array
# end

def get_out_sseArray(a, project_count)
    array = []
    while a.length != 0 do
        e = a.shift
        if e.class == Symbol then
            if e == :project then
                project_count += 1
            end
            if project_count != 2 then
                array.push(e)
            else
                break
            end          
        elsif e.class == Array then
            array.push(get_out_sseArray(e, project_count))
        else
            array.push(e)
        end
    end
    return array
end

# prefix句のsseArrayを取得するメソッド
def get_prefix_sseArray(a)
    while a.length != 0 do 
        top = a.shift
        # p top
        # p "hello"
        if top == :prefix then
            break [top, a[0]]
        elsif top.class == Array then
            top.reverse.each{|e|
                a.unshift(e)
            }
        else
        end
    end
end

#サブクエリのsseArrayを入力して、内側クエリを問い合わせ→結果を外側のクエリの変数にバインドし繰り返し問い合わせ→結果をマージして出力　するメソッド
def subquery_hybrid(sparql, base_sseArray)
    pp base_sseArray
    prefix_sseArray = get_prefix_sseArray(base_sseArray.deep_dup) #prefixの情報を取得
    in_sseArray = get_in_sseArray(base_sseArray.deep_dup) #サブクエリの内側のsseArrayを取得するメソッド
    in_sseArray = prefix_sseArray.push(in_sseArray) #サブクエリの内側のsseArrayにPREFIXを追加
    # pp in_sseArray
    in_sseArray_Parsed = SPARQL::Algebra::Expression.new(in_sseArray) #内側sseArrayをinputとして、SPARQLライブラリのオブジェクトとして扱う
    in_sparql_query = in_sseArray_Parsed.to_sparql #SPARQLクエリに変換
    in_result = ignore_limits(sparql, in_sparql_query) #内側のSPARQLクエリの結果を取得
    in_result_variables = in_result.variable_names #内側SPARQL問い合わせ結果で取得できる変数名
    # p in_result_variables

    out_sseArray = get_out_sseArray(base_sseArray.deep_dup, project_count=0)
    pp out_sseArray
    out_sseArray_Parsed = SPARQL::Algebra::Expression.new(out_sseArray)
    print out_sseArray_Parsed.to_sparql
    out_result = sparql.query(out_sseArray_Parsed.to_sparql)
    p out_result.length
    # p in_result.class.ancestors
    # p in_result.length
    # p in_result.methods.grep(/variable_names/)
    # p in_result.variable_names
end

#エンドポイントの返り値の限界を取得するメソッド
def get_limit_num(sparql)
    get_all_triple_query = """
    select * where{
        ?s ?p ?o.
    }
    """
    result = sparql.query(get_all_triple_query)
    return result.length
end

#エンドポイントの返り値の上限を無視して、全てのパターンを取得するメソッド
def ignore_limits(sparql, query)
    limit = get_limit_num(sparql) #エンドポイントの返り値の限界値を取得
    p "取得可能な限界値：" + limit.to_s
    
    offset = 0
    return_result = sparql.query(query)
    while true do
        # p offset
        offset += limit
        new_query = query + "\nLIMIT " + limit.to_s + "\nOFFSET " + offset.to_s
        p new_query
        new_result = sparql.query(new_query)
        p new_result.length
        return_result += new_result
        if new_result.length < limit then
            break
        end
    end
    return RDF::Query::Solutions.new(return_result)
end