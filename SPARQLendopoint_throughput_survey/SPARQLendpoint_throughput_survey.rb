require 'json'
require 'sparql/client'
require 'addressable/uri'

# --- 事前に問い合わせるべきクエリを読み込み --- #
# ファイルがあるディレクトリのパスを設定
ADVANCE_INFO_QUERY_PATH = "input/benchmark_query/advance_info/"
BENCHMARK_QUERY_PATH = "input/benchmark_query/"

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

def get_benchmark_query_result(query_type, query, endpoint, request_num_of_repetitions=1)
    return_info = {
        "query_type" => "#{query_type}",
        "response_time" => {
            "avg_all_session" => nil,
            "avg_not_nil_session" => nil,
            "time_per_session" => {}
        }
    }

    require 'uri'
    http_request = endpoint["url"].gsub('localhost', '127.0.0.1') + "?" #localhost→127.0.0.1に置き換えないとapache benchではエラーが起きる場合がある
    #グラフURIが指定されている場合
    if endpoint["graph_uri"] then
        # http_request += "default-graph-uri=" + URI.encode(endpoint["graph_uri"]) + "&"  #「warning: URI.escape is obsolete」が出る
        http_request += "default-graph-uri=" + Addressable::URI.encode(endpoint["graph_uri"]) + "&"
    end
    # http_request += "query=" + URI.encode(query) #「warning: URI.escape is obsolete」が出る
    http_request += "query=" + Addressable::URI.encode(query)

    #繰り返し回数分だけ問い合わせる
    (1..request_num_of_repetitions).each{|num|
        return_time = nil
        result = %x(ab -c 1 -n 1 "#{http_request}")
        result.each_line {|line|
            re = Regexp.new('^Time per request:')
            if /(^Time per request:)(.*)(\[ms\] \(mean\))/.match(line)
                return_time = /(^Time per request:)(.*)(\[ms\] \(mean\))/.match(line).to_a[2].to_f
            end
        }
        return_info["response_time"]["time_per_session"][num] = return_time
    }
    
    response_time_list = return_info["response_time"]["time_per_session"].values #hash内の応答時間を配列に書き出す
    if response_time_list.include?(nil) then #応答時間にnilが含まれる場合
        response_time_list = response_time_list.compact  #nilの要素を除く
        if response_time_list.length > 0 then  #1つでもnilが含まれていれば
            return_info["response_time"]["avg_not_nil_session"] = response_time_list.sum.fdiv(response_time_list.length)  
        else #全てnilの場合(reponse_time_listは空)
            return_info["response_time"]["avg_not_nil_session"] = nil
        end
    else
        return_info["response_time"]["avg_all_session"] = response_time_list.sum.fdiv(response_time_list.length) #応答時間の平均値を取得
    end

    return return_info
end

#SPARQLエンドポイントの情報を読み込み
File.open('input/SPARQLendpoint.json') {|f|
    endpoint_list = JSON.load(f)

    output = [] #出力用のArray
    endpoint_list.each do |endpoint| #エンドポイントごとに問い合わせる
        if endpoint["server_type"] == "local" && endpoint["rdf_store"] == "fuseki"  then #問い合わせるエンドポイントの条件を指定
            p "問い合わせ先のSPARQLendpoint:" + endpoint["label"]
            begin
                #SPARQL::Clientオブジェクトを作成
                sparql = SPARQL::Client.new(endpoint["url"], graph: endpoint["graph_uri"], method: "get")

                # --- 事前情報の取得(サブクエリ, UNION, OPTIONAL句で利用するため) ---
                #トリプル数を取得
                triple_num_result = sparql.query(get_triple_num_query)
                endpoint["triple_num"] = triple_num_result[0][:triple_num].to_f #トリプル数を格納
                #クラス間関係を取得
                class_relation_result = sparql.query(get_class_relation_query)

                #ドメイン・プロパティの組みを取得
                domain_property_result = sparql.query(get_domain_property_query)
                # --- --- #
                
                #endpointごとの問い合わせ結果を格納するarrayを宣言
                endpoint["benchmark_query_result"] = []
                #ベンチマーククエリごとに問い合わせを実行
                Dir.glob(BENCHMARK_QUERY_PATH + '*.*') do |input_file|
                    query_label = File.basename(input_file, ".*")
                    query = File.open(input_file, "r").read
                    
                    #サブクエリの場合とUNION, OPTIONALの場合は事前取得情報をクエリに埋め込む必要があるため、通常のクエリを読み込むことに加えて、変数に結果を割り当てる
                    if query_label == "subquery" then 
                        query = "\"#{query}\""
                        domain = class_relation_result[0][:domain]
                        range = class_relation_result[0][:range]
                        query = eval(query)
                    elsif query_label == "union" || query_label == "option" then 
                        query = "\"#{query}\""
                        domain = domain_property_result[0][:domain]
                        property = domain_property_result[0][:property]
                        query = eval(query)
                    else
                    end
                    query_response_time_info = get_benchmark_query_result(query_label, query, endpoint,10)
                    
                    endpoint["benchmark_query_result"].push(query_response_time_info)
                end
                output.push(endpoint)
            rescue => e
                p e
                next
            end
        end
    end

    #ファイル出力
    yyyymmddhhmmss = DateTime.now.strftime('%Y%m%d%H%M%S')
    File.open("output/response_time/#{DateTime.now.strftime('%Y%m%d%H%M%S')}.json", "w") do |file|
        str = JSON.dump(output, file)
    end
}
