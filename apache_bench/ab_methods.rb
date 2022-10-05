def apache_bench_test(query, uri)
    require 'uri'
    query_encoded = URI.encode(query)
    http_request = uri + '?query=' + query_encoded

    result = %x(ab -c 1 -n 10 "#{http_request}")

    result.each_line {|line|
        re = Regexp.new('^Time per request:')
        if /(^Time per request:)(.*)(\[ms\] \(mean\))/.match(line)
            return /(^Time per request:)(.*)(\[ms\] \(mean\))/.match(line).to_a[2].to_f
        end
    }
    return nil
end