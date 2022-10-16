require './ab_methods'
require 'sparql/client'
require 'uri'
require 'csv'
require 'date'
require 'json'

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

#SPARQLエンドポイントの情報を読み込み
File = open("input/SPARQLendpoint.json") do |file|
    endpoint_list = JSON.load(file)

    #ファイルに書き込み
    yyyymmddhhmmss = DateTime.now.strftime('%Y%m%d%H%M%S')
    CSV.open("./output/return_time_from_SPARQLendpoint/#{DateTime.now.strftime('%Y%m%d%H%M%S')}.csv", 'a') do |csv|
        csv << ["server_type", "label", "rdf_store", "url", "graph_uri", "triple_num", "count", "distinct","filter_regex", "group_by_having_count_distinct","order_by", "union", "optional", "subquery"]
        endpoint_list.each do |endpoint|
            #if文の条件で調査の対象を絞り込み可能
            if endpoint["server_type"] == "local" && endpoint["rdf_store"] == "virtuoso" then
                sparql = SPARQL::Client.new(endpoint["url"], graph: endpoint["graph_uri"], method: "get")

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
                count_ms = apache_bench_test(count_query, endpoint)
                p "count:" + count_ms.to_s + "[ms]"

                #distinctのベンチマーククエリに関してapache benchを利用して取得までの時間を取得
                input_file = File.open(BENCHMARK_QUERY_PATH + "distinct.rq", "r")
                distinct_query = input_file.read
                distinct_ms = apache_bench_test(distinct_query, endpoint)
                p "distinct:" + distinct_ms.to_s + "[ms]"

                #filter_rdf:typeのベンチマーククエリに関してapache benchを利用して取得までの時間を取得
                # input_file = File.open(BENCHMARK_QUERY_PATH + "filter_rdf:type.rq", "r")
                # filter_rdftype_query = input_file.read
                # filter_rdftype_ms = apache_bench_test(filter_rdftype_query, endpoint)
                # p "filter_rdftype:" + filter_rdftype_ms.to_s + "[ms]"

                #filter_regexのベンチマーククエリに関してapache benchを利用して取得までの時間を取得
                input_file = File.open(BENCHMARK_QUERY_PATH + "filter_regex.rq", "r")
                filter_regex_query = input_file.read
                filter_regex_ms = apache_bench_test(filter_regex_query, endpoint)
                p "filter_regex:" + filter_regex_ms.to_s + "[ms]"

                #group_by_having_count_distinctのベンチマーククエリに関してapache benchを利用して取得までの時間を取得
                input_file = File.open(BENCHMARK_QUERY_PATH + "group_by_having_count_distinct.rq", "r")
                group_by_having_count_distinct_query = input_file.read
                group_by_having_count_distinct_ms = apache_bench_test(group_by_having_count_distinct_query, endpoint)
                p "group_by_having_count_distinct:" + group_by_having_count_distinct_ms.to_s + "[ms]"
                
                #order_byのベンチマーククエリに関してapache benchを利用して取得までの時間を取得
                input_file = File.open(BENCHMARK_QUERY_PATH + "order_by.rq", "r")
                order_by_query = input_file.read
                order_by_ms = apache_bench_test(order_by_query, endpoint)
                p "order_by:" + order_by_ms.to_s + "[ms]"

                #unionのベンチマーククエリに関してapache benchを利用して取得までの時間を取得
                input_file = File.open(BENCHMARK_QUERY_PATH + "union.txt", "r")
                union_query = input_file.read
                union_query = "\"#{union_query}\""
                # TO DO 動的に変数名に結果の変数を割り当てる
                domain = domain_property_result[0][:domain]
                property = domain_property_result[0][:property]
                union_query = eval(union_query)
                union_ms = apache_bench_test(union_query, endpoint)
                p "union:" + union_ms.to_s + "[ms]"

                #optionalのベンチマーククエリに関してapache benchを利用して取得までの時間を取得
                input_file = File.open(BENCHMARK_QUERY_PATH + "optional.txt", "r")
                optional_query = input_file.read
                optional_query = "\"#{optional_query}\""
                # TO DO 動的に変数名に結果の変数を割り当てる
                domain = domain_property_result[0][:domain]
                property = domain_property_result[0][:property]
                optional_query = eval(optional_query)
                optional_ms = apache_bench_test(optional_query, endpoint)
                p "optional:" + optional_ms.to_s + "[ms]"

                #サブクエリのベンチマーククエリに関してapache benchを利用して取得までの時間を取得
                input_file = File.open(BENCHMARK_QUERY_PATH + "subquery.txt", "r")
                subquery = input_file.read
                subquery = "\"#{subquery}\""
                # TO DO 動的に変数名に結果の変数を割り当てる
                domain = class_relation_result[0][:domain]
                range = class_relation_result[0][:range]
                subquery = eval(subquery)
                subquery_ms = apache_bench_test(subquery, endpoint)
                p "subquery:" + subquery_ms.to_s + "[ms]"
                
                csv << [endpoint["server_type"],endpoint["label"], endpoint["rdf_store"],endpoint["url"],endpoint["graph_uri"], triple_num_result[0][:triple_num], count_ms, distinct_ms, filter_regex_ms, group_by_having_count_distinct_ms, order_by_ms, union_ms, optional_ms, subquery_ms]
            end
        end
    end
end


