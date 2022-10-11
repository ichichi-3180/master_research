require './ab_methods'
require 'sparql/client'
require 'uri'
require 'csv'
require 'date'

# --- 事前に問い合わせるべきクエリを読み込み --- #
# ファイルがあるディレクトリのパスを設定
ADVANCE_INFO_QUERY_PATH = "../benchmark_query/advance_info/"
BENCHMARK_QUERY_PATH = "../benchmark_query/"

#トリプル数を取得するクエリ
input_file = File.open(ADVANCE_INFO_QUERY_PATH + "triple_num.rq", "r")
get_triple_num_query = input_file.read

#クラス間関係を取得するクエリ
input_file = File.open(ADVANCE_INFO_QUERY_PATH + "class_relation.rq", "r")
get_class_relation_query = input_file.read

#ドメインとプロパティのペアを取得するクエリ
input_file = File.open(ADVANCE_INFO_QUERY_PATH + "domain_property.rq", "r")
get_domain_property_query = input_file.read
# --- --- #

#SPARQLEndpointを指定
endpoint_list = [
    # "http://localhost:3030/SP2Bench_10000/sparql",
    # "http://localhost:3030/SP2Bench_100000/sparql",
    # "http://localhost:3030/SP2Bench_1000000/sparql",
    # "http://localhost:3030/SP2Bench_10000000/sparql",
    # "http://localhost:3030/SP2Bench_300000000/sparql" なぜかSPARQL::Cient経由だと404Not foundになる場合がある
    # "http://localhost:3030/onsen/sparql",
    # "http://localhost:3030/botanical/sparql",
    # "http://localhost:3030/textbook/sparql",
    "https://lov.linkeddata.es/dataset/lov/sparql",
    "https://id.ndl.go.jp/auth/ndla/sparql",
    "http://dbkwik.webdatacommons.org/sparql",
    "https://ja.dbpedia.org/sparql",
    "https://dbpedia.org/sparql",
    "https://jpsearch.go.jp/rdf/sparql"
]

#ファイルに書き込み
yyyymmddhhmmss = DateTime.now.strftime('%Y%m%d%H%M%S')
CSV.open("./output/return_time_from_SPARQLendpoint/#{DateTime.now.strftime('%Y%m%d%H%M%S')}.csv", 'a') do |csv|
    csv << ["endpoint_url","triple_num", "count", "distinct", "filter_rdf:type","filter_regex", "group_by_having", "union", "optional", "subquery"]
    #各エンドポイントごとに問い合わせ
    endpoint_list.each {|url|
        p url
        sparql = SPARQL::Client.new(url,method: "get")

        # --- 事前情報の取得(サブクエリ, UNION, OPTIONAL句で利用するため) ---
        #トリプル数を取得
        triple_num_result = sparql.query(get_triple_num_query)

        #クラス間関係を取得
        class_relation_result = sparql.query(get_class_relation_query)

        #ドメイン・プロパティの組みを取得
        domain_property_result = sparql.query(get_domain_property_query)
        # --- --- #
        
        #countのベンチマーククエリに関してapache benchを利用して取得までの時間を取得
        input_file = File.open(BENCHMARK_QUERY_PATH + "count.rq", "r")
        count_query = input_file.read
        count_ms = apache_bench_test(count_query, url)
        p "count:" + count_ms.to_s + "[ms]"

        #distinctのベンチマーククエリに関してapache benchを利用して取得までの時間を取得
        input_file = File.open(BENCHMARK_QUERY_PATH + "distinct.rq", "r")
        distinct_query = input_file.read
        distinct_ms = apache_bench_test(distinct_query, url)
        p "distinct:" + distinct_ms.to_s + "[ms]"

        #filter_rdf:typeのベンチマーククエリに関してapache benchを利用して取得までの時間を取得
        input_file = File.open(BENCHMARK_QUERY_PATH + "filter_rdf:type.rq", "r")
        filter_rdftype_query = input_file.read
        filter_rdftype_ms = apache_bench_test(filter_rdftype_query, url)
        p "filter_rdftype:" + filter_rdftype_ms.to_s + "[ms]"

        #filter_regexのベンチマーククエリに関してapache benchを利用して取得までの時間を取得
        input_file = File.open(BENCHMARK_QUERY_PATH + "filter_regex.rq", "r")
        filter_regex_query = input_file.read
        filter_regex_ms = apache_bench_test(filter_regex_query, url)
        p "filter_regex:" + filter_regex_ms.to_s + "[ms]"

        #group_by_havingのベンチマーククエリに関してapache benchを利用して取得までの時間を取得
        input_file = File.open(BENCHMARK_QUERY_PATH + "group_by_having.rq", "r")
        group_by_having_query = input_file.read
        group_by_having_ms = apache_bench_test(group_by_having_query, url)
        p "group_by_having:" + group_by_having_ms.to_s + "[ms]"

        #unionのベンチマーククエリに関してapache benchを利用して取得までの時間を取得
        input_file = File.open(BENCHMARK_QUERY_PATH + "union.txt", "r")
        union_query = input_file.read
        union_query = "\"#{union_query}\""
        # TO DO 動的に変数名に結果の変数を割り当てる
        domain = domain_property_result[0][:domain]
        property = domain_property_result[0][:property]
        union_query = eval(union_query)
        union_ms = apache_bench_test(union_query, url)
        p "union:" + union_ms.to_s + "[ms]"

        #optionalのベンチマーククエリに関してapache benchを利用して取得までの時間を取得
        input_file = File.open(BENCHMARK_QUERY_PATH + "optional.txt", "r")
        optional_query = input_file.read
        optional_query = "\"#{optional_query}\""
        # TO DO 動的に変数名に結果の変数を割り当てる
        domain = domain_property_result[0][:domain]
        property = domain_property_result[0][:property]
        optional_query = eval(optional_query)
        optional_ms = apache_bench_test(optional_query, url)
        p "optional:" + optional_ms.to_s + "[ms]"

        #サブクエリのベンチマーククエリに関してapache benchを利用して取得までの時間を取得
        input_file = File.open(BENCHMARK_QUERY_PATH + "subquery.txt", "r")
        subquery = input_file.read
        subquery = "\"#{subquery}\""
        # TO DO 動的に変数名に結果の変数を割り当てる
        domain = class_relation_result[0][:domain]
        range = class_relation_result[0][:range]
        subquery = eval(subquery)
        subquery_ms = apache_bench_test(subquery, url)
        p "subquery:" + subquery_ms.to_s + "[ms]"

        csv << [url, triple_num_result[0][:triple_num], count_ms, distinct_ms, filter_rdftype_ms,filter_regex_ms, group_by_having_ms, union_ms, optional_ms, subquery_ms]
    }
end