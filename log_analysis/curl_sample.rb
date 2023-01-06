require 'uri'
require 'json'
require 'sparql'

base_uri = 'https://query.wikidata.org/sparql?query='

query = """
SELECT ?var1
WHERE 
{
  ?var1  <http://www.wikidata.org/prop/direct/P279>  ?var2 .
}
LIMIT 10000
OFFSET 20000
"""

query_uri = base_uri + URI.encode(query) 

#ヘッダーを指定して問い合わせ
response =  %x(curl  -H 'Accept: application/sparql-results+json' --globoff '#{query_uri}')

response_hash = JSON.parse(response)
pp response_hash.keys
response_array =  response_hash["results"]["bindings"]

p response_array.length

sparql_object = RDF::Query::Solutions.new(response_array)
p sparql_object.distinct.length