require 'csv'
require 'uri'
require 'json'
require 'date'
require 'fileutils'

DATE = DateTime.now.strftime('%Y%m%d%H%M%S')
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
base_uri = 'https://query.wikidata.org/sparql?query='

# FileUtils.mkdir_p(OUTPUT_DIRECTORY + "/" + DATASET_NAME + "/StatusCode/" + DATE + "/" + FILENAME + "/200") unless Dir.exist?(OUTPUT_DIRECTORY + "/" + DATASET_NAME + "/" + FILENAME + "/200")
# FileUtils.mkdir_p(OUTPUT_DIRECTORY + "/" + DATASET_NAME + "/StatusCode/" + DATE + "/" + FILENAME + "/500") unless Dir.exist?(OUTPUT_DIRECTORY + "/" + DATASET_NAME + "/" + FILENAME + "/500")
# FileUtils.mkdir_p(OUTPUT_DIRECTORY + "/" + DATASET_NAME + "/StatusCode/" + DATE + "/" + FILENAME + "/other") unless Dir.exist?(OUTPUT_DIRECTORY + "/" + DATASET_NAME + "/" + FILENAME + "/other")
FileUtils.mkdir_p(OUTPUT_DIRECTORY + "/" + DATASET_NAME + "/StatusCode/" + DATE + "/" + FILENAME) unless Dir.exist?(OUTPUT_DIRECTORY + "/" + DATASET_NAME + "/StatusCode/" + DATE + "/" + FILENAME)

File.open(OUTPUT_DIRECTORY + "/" + DATASET_NAME + "/StatusCode/" + DATE + "/" + FILENAME + OUTPUT_FILE_EXTENSION_1, "w") do |file|
    query_hash = {}
    tsv[1..100].each_with_index do |query_log, index|
        get_uri = base_uri + query_log[0]
        response =  %x(curl --head --globoff "#{get_uri}" | head -1).chomp.split
        response_status_code = response[1]
        query_hash[index.to_s] = {
            "query_log": query_log,
            "status code": response_status_code
        }
        
        Dir.mkdir(OUTPUT_DIRECTORY + "/" + DATASET_NAME + "/StatusCode/" + DATE + "/" + FILENAME + "/" + response_status_code) unless Dir.exist?(OUTPUT_DIRECTORY + "/" + DATASET_NAME + "/StatusCode/" + DATE + "/" + FILENAME + "/" + response_status_code)
        File.open(OUTPUT_DIRECTORY + "/" + DATASET_NAME + "/StatusCode/" + DATE + "/" + FILENAME + "/" + response_status_code + "/" + index.to_s + OUTPUT_FILE_EXTENSION_2, "w") do |query|
            query.print(URI.decode_www_form(query_log[0])[0][0])
        end

    end
    str = JSON.dump(query_hash,file)
end