#sseArrayの中身を再起的に取得してsseArrayに変換するメソッド
def array_to_array(a)
    if a.length == 1 then
        p a
        return a
    else
        array = []
        while a.length != 0 do
            e = a.shift
            if e.class == Symbol then
                array.push(e)
            elsif e.class == Array then
                array.push(array_to_array(e))
            else
                array.push(e)
            end
        end
        return array
    end
end
