require 'csv'
require 'uri'
require 'json'
require 'date'
require 'fileutils'

DATE = DateTime.now.strftime('%Y%m%d%H%M%S')
INPUT_DIRECTORY = "query/wikidata/Filtered/"
base_uri = 'https://query.wikidata.org/sparql?query='
OUTPUT_DIRECTORY_BASE = "query/wikidata/StatusCode/"

Dir.foreach(INPUT_DIRECTORY) do |file|
    next if file == '.' or file == '..'
    p file
    tsv = CSV.read(INPUT_DIRECTORY + file, col_sep: "\t")
    p tsv.length
    # f = File.open(INPUT_DIRECTORY+file)
    # input = f.read
    # f.close
    # query_log_array =  input.split("\n")
    # p query_log_array.length
    
    query_hash = {}
    for query_log in tsv do 
        index = query_log[0]
        encoded_query = query_log[1]
        get_uri = base_uri + encoded_query
        response =  %x(curl --head --globoff "#{get_uri}" | head -1).chomp.split
        response_status_code = response[1]
        re = Regexp.new('(.*)\.tsv')
        query_type = re.match(file)
        OUTPUT_DIRECTORY = OUTPUT_DIRECTORY_BASE + DATE + "/" + query_type[1] + "/" + response_status_code
        FileUtils.mkdir_p(OUTPUT_DIRECTORY) unless Dir.exist?(OUTPUT_DIRECTORY)
        File.open(OUTPUT_DIRECTORY + "/" + index.to_s + '.sparql', "w") do |file|
            file.print(URI.decode_www_form(encoded_query)[0][0])
        end
    end
end