# sseArrayの中身を再帰的に取得してHashに変換するメソッド
def array_to_hash(a)
    array = []
    while a.length != 0 do
        # 配列の最初の要素がSymbolだった場合(ex. :extend, :tripleなど)、残りの要素をsampleメソッドに渡す
        e = a.shift
        # p e
        if e.class == Symbol then
            # p "symbol"
            dict = {}
            dict[e] = array_to_hash(a)
            array.push(dict)
        elsif e.class == Array then
            # p "array"
            array.push(array_to_hash(e))
        else
            array.push(e)
        end
    end
    return array
end
