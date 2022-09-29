require './ab_methods'
require 'sparql/client'
require 'uri'

# --- 事前に問い合わせるべきクエリを読み込み --- #
# ファイルがあるディレクトリのパスを設定
ADVANCE_INFO_QUERY_PATH = "../benchmark_query/advance_info/"
BENCHMARK_QUERY_PATH = "../benchmark_query/"

#クラス間関係を取得するクエリ
input_file = File.open(ADVANCE_INFO_QUERY_PATH + "class_relation.rq", "r")
get_class_relation_query = input_file.read

#ドメインとプロパティのペアを取得するクエリ
input_file = File.open(ADVANCE_INFO_QUERY_PATH + "domain_property.rq", "r")
get_domain_property_query = input_file.read
# --- --- #

#SPARQLEndpointを指定
endpoint_list = [
    "http://localhost:3030/SP2Bench_10000/sparql",
    "http://localhost:3030/SP2Bench_100000/sparql",
    "http://localhost:3030/SP2Bench_1000000/sparql",
    "http://localhost:3030/SP2Bench_10000000/sparql"
    # "http://localhost:3030/SP2Bench_300000000/sparql" なぜかSPARQL::Cient経由だと404Not foundになる場合がある
]

#各エンドポイントごとに問い合わせ
endpoint_list.each {|url|
    p url
    sparql = SPARQL::Client.new(url)

    # --- 事前情報の取得(サブクエリ, UNION, OPTIONAL句で利用するため) ---
    #クラス間関係を取得
    class_relation_result = sparql.query(get_class_relation_query)

    #ドメイン・プロパティの組みを取得
    domain_property_result = sparql.query(get_domain_property_query)
    # --- --- #
     
    #countのベンチマーククエリに関してapache benchを利用して取得までの時間を取得
    input_file = File.open(BENCHMARK_QUERY_PATH + "count.rq", "r")
    count_query = input_file.read
    count_ms = apache_bench_test(count_query, url)
    p count_ms
}