require 'csv'
require 'uri'
require 'json'

INPUT_DIRECTORY = "query_log"
OUTPUT_DIRECTORY = "query"
DATASET_NAME = "wikidata"
# FILENAME = "2017-06-12_2017-07-09_status_500"
# FILENAME = "2017-07-10_2017-08-06_status_500"
# FILENAME = "2017-08-07_2017-09-03_status_500"
# FILENAME = "2017-12-03_2017-12-30_status_500"
# FILENAME = "2018-01-01_2018-01-28_status_500"
# FILENAME = "2018-01-29_2018-02-25_status_500"
FILENAME = "2018-02-26_2018-03-25_status_500"
INPUT_FILE_EXTENSION = '.tsv'
OUTPUT_FILE_EXTENSION_1 = '.json'
OUTPUT_FILE_EXTENSION_2 = '.sparql'

tsv = CSV.read(INPUT_DIRECTORY+ "/" + DATASET_NAME + "/" + FILENAME + INPUT_FILE_EXTENSION, col_sep: "\t")

Dir.mkdir(OUTPUT_DIRECTORY + "/" + DATASET_NAME + "/" + FILENAME) unless Dir.exist?(OUTPUT_DIRECTORY + "/" + DATASET_NAME + "/" + FILENAME)

#各クエリをクエリログ単位でファイルに出力
File.open(OUTPUT_DIRECTORY + "/" + DATASET_NAME + "/" + FILENAME + OUTPUT_FILE_EXTENSION_1, "w") do |file|
    query_hash = {}
    tsv[1..-1].each_with_index do |query_log, index|
        query_hash[index.to_s] = URI.decode_www_form(query_log[0])[0][0]
        
        #各クエリをクエリ単位でファイルに出力
        File.open(OUTPUT_DIRECTORY + "/" + DATASET_NAME + "/" + FILENAME + "/" + index.to_s + OUTPUT_FILE_EXTENSION_2, "w") do |query|
            query.print(URI.decode_www_form(query_log[0])[0][0])
        end
    end
    str = JSON.dump(query_hash, file)
end
