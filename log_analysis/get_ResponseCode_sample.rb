require 'uri'
require 'net/http'

INPUT_FILE_PATH = "./query/wikidata/2018-01-29_2018-02-25_status_500/13793.sparql" #Wikidata Query Serviceだと取得できる
# INPUT_FILE_PATH = "./query/wikidata/2018-02-26_2018-03-25_status_500/95.sparql" #Wikidata Query Serviceだとタイムアウト
# INPUT_FILE_PATH = "./query/wikidata/2017-08-07_2017-09-03_status_500/510.sparql" #Wikidata Query Serviceだとタイムアウト
# INPUT_FILE_PATH = "./query/wikidata/2018-02-26_2018-03-25_status_500/25.sparql"　#Wikidata Query Serviceだとタイムアウト
file = File.open(INPUT_FILE_PATH, "r")
query = file.read

print query

encoded_query = URI.encode(query) #ruby2.7.2
# encoded_query =  URI.encode_www_form(query) #ruby3.1.2

print(URI.decode_www_form(encoded_query)[0][0])

base_uri = 'https://query.wikidata.org/sparql?query='
get_uri = base_uri + encoded_query

p get_uri

response =  %x(curl --head --globoff "#{get_uri}" | head -1).chomp.split
p response[1] == "200" #ステータスコードが格納されている
