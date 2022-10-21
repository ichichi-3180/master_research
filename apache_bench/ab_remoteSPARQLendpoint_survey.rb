require './ab_methods'
require 'sparql/client'
require 'uri'
require 'csv'
require 'date'
require 'json'

endpoint_list = CSV.read("input/remote_SPARQLendpoint_list.csv").flatten
# p endpoint_list[0]
# p endpoint_list[1..-1]

endpoint_list[1..-1].each do |endpoint_url|
    p endpoint_url
    sparql = SPARQL::Client.new(endpoint_url, method: "get")
    query = """
    select (count(distinct ?class) AS ?class_num) 
    where{
        ?s a ?class.
    }
    """
    begin
        sparql.query(query)
    rescue => e
        p "実行エラー"
    end
end