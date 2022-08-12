# sseArrayからDISTINCTを除いたsseArrayに分割するメソッド
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
    return return_result
end