def apache_bench_test(query, endpoint, timeout_ms=30000)
    require 'uri'
    # query_encoded = URI.encode(query)
    # http_request = endpoint["url"] + '?query=' + query_encoded
    
    http_request = endpoint["url"].gsub('localhost', '127.0.0.1') + "?" #localhost→127.0.0.1に置き換えないとapache benchではエラーが起きる場合がある
    #グラフURIが指定されている場合
    if endpoint["graph_uri"] then
        http_request += "default-graph-uri=" + URI.encode(endpoint["graph_uri"]) + "&"
    end
    http_request += "query=" + URI.encode(query)
    p http_request
    result = %x(ab -s #{timeout_ms/1000} -c 1 -n 10 "#{http_request}")

    result.each_line {|line|
        re = Regexp.new('^Time per request:')
        if /(^Time per request:)(.*)(\[ms\] \(mean\))/.match(line)
            return /(^Time per request:)(.*)(\[ms\] \(mean\))/.match(line).to_a[2].to_f
        end
    }
    return timeout_ms
end