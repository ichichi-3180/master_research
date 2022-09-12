#クエリを読み込み
input_file_path = "../SPARQL_query_sample/Query1_1.sparql"
input_file = File.open(input_file_path, "r")
query = input_file.read


#SPARQLエンドポイント
# url = "https://id.ndl.go.jp/auth/ndla/sparql"
# url = "https://dbpedia.org/sparql"
# url = "http://localhost:3030/SP2Bench_10000/sparql"
# url = "http://localhost:3030/SP2Bench_100000/sparql"
# url = "http://localhost:3030/SP2Bench_1000000/sparql"
# url = "http://localhost:3030/SP2Bench_10000000/sparql"
url = "http://localhost:3030/SP2Bench_300000000/sparql"


require 'uri'
query_encoded = URI.encode(query)
p query
http_request = url + '?query=' + query_encoded

result = %x(ab -c 1 -n 1 "#{http_request}")
puts result