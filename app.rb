# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'
require 'time'

# cxo fiddlin' - pull data and slice up
data = File.read('/Users/josh.brown/Documents/DEV/cxo/cxo.json')
data_1 = JSON.parse(data)
cxo = data_1.map do |x|
  x.slice('username', 'email_address', 'manager', 'department')
end
depts = data_1.map do |x|
  x.slice('username', 'department')
end

# Sub in department IDs
depts.each do |x|
  x['department'] = [50000222717] if x['department'] == 'support'
  x['department'] = [50000222713] if x['department'] == 'tech'
  x['department'] = [50000222716] if x['department'] == 'csc'
  x['department'] = [50000222715] if x['department'] == 'inbound'
  x['department'] = [50000222714] if x['department'] == 'outbound'
  x['department'] = 'none' if x['department'].nil?
end

puts depts

# pull all user records from Fresh
page_no = 1
full = []
empty = []

# poorly paginate - need to break on 400/nil/zero results returned
until page_no == 25
  url1 = URI("https://simplybusiness.freshservice.com/itil/requesters.json?page=#{page_no}")
  https = Net::HTTP.new(url1.host, url1.port)
  https.use_ssl = true
  request = Net::HTTP::Get.new(url1)
  request['Authorization'] = 'Basic WVhiUTRybUJ2NXpPZzNpdGVzYTpYWFg='
  response = https.request(request)
  result = JSON.parse(response.body)

  result.map do |x|
    empty.push x['user']
  end

  full.concat(result)
  page_no += 1
end

xyz = empty.map do |x|
  x.slice('id', 'email')
end

fart = []

xyz.each do |x|
  ty = cxo.select { |g| g['email_address'] == x['email'] }
  ty.each do |t|
    tyuh = t.merge(x)
    fart.push tyuh
  end
end

# manager_lookup
un_id = fart.map do |x|
  x.slice('email', 'id')
end

puts un_id
# fresh_ids = JSON.generate(un_id)

# Create payload object to iterate through and update FS

payload =
  {
    "primary_email": 'test.requester@simplybusiness.co.uk',
    "department_ids": [
      123456
    ],
    "reporting_manager_id": 123456
  }
