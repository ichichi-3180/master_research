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



# def get_out_sseArray(a, project_count)
#     array = []
#     while a.length != 0 do
#         e = a.shift
#         if e.class == Symbol then
#             if e == :project then
#                 project_count += 1
#             end
#             if project_count != 2 then
#                 array.push(e)
#             else
#                 break
#             end          
#         elsif e.class == Array then
#             array.push(get_out_sseArray(e, project_count))
#         else
#             array.push(e)
#         end
#     end
#     return array
# end

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

def get_out_sseArray(a, project_count)
    operator = ""
    return_array = []
    a.length.times do |i|
        if i == 0 && a[i].class == Symbol then
            if a[i] == :project then
                project_count += 1
            end
            if project_count == 2 then
                break
            else
                return_array.push(a[i])
            end
        elsif a[i].class == Array then
            # p a[i]
            add_flag = get_out_sseArray(a[i], project_count)
            if add_flag then
                return_array.push(add_flag)
            else
                return_array.push([])
            end
        else
            return_array.push(a[i])
        end
    end
    # p project_count
    # p return_array
    if project_count == 2 then
        return false
    else
        return return_array
    end
end

#base_sseArray内のoperatorに対して、次の引数に指定したadd_sseArrayを追加する(operator内の配列の要素は2つまでなので、末尾の要素を削除する)
def add_operator_next_array(base_sseArray, operator, add_sseArray)
    if base_sseArray.length == 1 then
        return base_sseArray
    else
        array = []
        while base_sseArray.length != 0 do
            e = base_sseArray.shift
            if e.class == Symbol then
                if e == operator then
                    array.push(operator, add_sseArray)
                    base_sseArray.pop #末尾の削除
                else
                    array.push(e)
                end
            elsif e.class == Array then
                array.push(add_operator_next_array(e, operator, add_sseArray))
            else
                array.push(e)
            end
        end
        return array
    end
end

def get_out_sseArray_in_result_bind(in_result, out_sseArray) 

    #外側sseArrayをSPARQLライブラリのオブジェクトとして扱う
    out_sseArray_Parsed = SPARQL::Algebra::Expression.new(out_sseArray) 

    #外側sseArrayからbindする変数オブジェクトを格納するsseArrayを用意
    bind_sseArray = [:extend,[],[:bgp]]

    in_result.each_variable{|in_r_v|
        #外側SPARQLで利用されている変数オブジェクトを取得(out_sseArray_Parsed.vars.uniq)し、内側SPARQLの結果の変数と一致するものをbind_sseArrayに追加
        add_variable =  out_sseArray_Parsed.vars.uniq.select{|v| v.name == in_r_v.name} 
        if add_variable.length > 1 then
            p "error: too many bind variables"
        else
            add_variable.push(in_r_v.value)
            bind_sseArray[1].push(add_variable)
        end
    }

    #外側sseArrayにbind_sseArrayをバインドする
    #bind_sseArrayの内容を:joinがあれば:joinが最初の要素になっている配列内の2番目の要素に格納
    #:joinがない場合は[:bgp,~]と同じ階層に追加し、[:join, bind_sseArray, [:bgp,~]]のように変更

    #1. :joinを含んでいるかをチェック
    join_flag = out_sseArray.flatten.include?(:join)

    #2.　含んでいるか含んでいないかで処理を変える
    if join_flag then #joinがある場合
        return add_operator_next_array(out_sseArray, :join, bind_sseArray)
    else
        #TO DO joinがない場合の処理を追加
    end
end

#サブクエリのsseArrayを入力して、内側クエリを問い合わせ→結果を外側のクエリの変数にバインドし繰り返し問い合わせ→結果をマージして出力　するメソッド
def subquery_hybrid(sparql, base_sseArray)

    #prefixの情報を取得
    prefix_sseArray = get_prefix_sseArray(base_sseArray.deep_dup) 

    #サブクエリの内側のsseArrayを取得するメソッド
    in_sseArray = get_in_sseArray(base_sseArray.deep_dup) 

    #サブクエリの内側のsseArrayにPREFIXを追加
    in_sseArray = prefix_sseArray.push(in_sseArray) 


    #内側sseArrayをinputとして、SPARQLライブラリのオブジェクトとして扱う
    in_sseArray_Parsed = SPARQL::Algebra::Expression.new(in_sseArray) 

    #SPARQLクエリに変換
    in_sparql_query = in_sseArray_Parsed.to_sparql 

    #内側のSPARQLクエリの結果を取得
    in_result = ignore_limits(sparql, in_sparql_query) 

    #内側SPARQL問い合わせ結果で取得できる変数名
    in_result_variables = in_result.variable_names 

    #サブクエリの外側sseArrayを取得するメソッド
    out_sseArray = get_out_sseArray(base_sseArray,  project_count=0) #外側sseArrayを取得(ベースのクエリ内で利用される変数オブジェクトを同じIDで取得する必要があるため、deepdupは使わない)
    
    hybrid_subquery_result = RDF::Query::Solutions.new() #サブクエリをハイブリッド化して問い合わせた結果を格納する

    #内側SPARQLクエリの結果を外側SPARQLに当てはめて問い合わせ
    in_result.each_with_index{|r_in, index|
        #内側SPARQLクエリの結果を外側sseArrayにバインド
        out_sseArray_bind = get_out_sseArray_in_result_bind(r_in, out_sseArray.deep_dup)
        # pp out_sseArray
        # 内側SPARQLクエリの結果を外側sseArrayにバインドしたsseArrayをSPARQLに変換し、問い合わせ
        out_sseArray_bind_Parsed = SPARQL::Algebra::Expression.new(out_sseArray_bind) 
        
        out_result = ignore_limits(sparql, out_sseArray_bind_Parsed.to_sparql)
        
        out_result.each{|r_out|
            hybrid_subquery_result.push(r_out)
        }
    }
    return hybrid_subquery_result
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