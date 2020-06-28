SCHEDULER.every '5s' do
  require 'net/http'
  require 'json'
  require 'uri'

  uri = URI.parse('http://piholeserver/admin/api.php')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = false
  request = Net::HTTP::Get.new(uri.request_uri)
  response = http.request(request)
  json_response = JSON.parse(response.body)
  queries_count = json_response['dns_queries_today'].to_s.chars.to_a.reverse.each_slice(3).map(&:join).join(",").reverse
  blocked_count = json_response['ads_blocked_today'].to_s.chars.to_a.reverse.each_slice(3).map(&:join).join(",").reverse
  forwarded_count = json_response['queries_forwarded'].to_s.chars.to_a.reverse.each_slice(3).map(&:join).join(",").reverse
  clients = "Pi-Hole (" + ('%.2g' % json_response['clients_ever_seen']) + " Clients)"
  ads_percent = '%.2g' % json_response['ads_percentage_today']

  send_event('pihole', { queries: queries_count, blocked: blocked_count, forwarded: forwarded_count, queries_label: "Queries Today", forwarded_label: "Queries Forwarded", blocked_label: "Ad Blocked", title: clients })
  send_event('pihole-meter', {value: ads_percent})

end
