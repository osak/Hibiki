require 'net/http'
require 'rexml/document'

class AOJ
  API_HOST = "judge.u-aizu.ac.jp"
  API_PORT = 80
  API = "http://#{API_HOST}/onlinejudge/webservice"
  USER_AGENT = "Hibiki (http://hibiki.osak.jp) Crawler. Contact: Osamu Koga<osak.63@gmail.com>"

  def parse(node)
    if node.has_elements?
      res = {}
      node.elements.each do |child|
        key = child.name.to_sym
        if res.has_key?(key)
          unless res[key].is_a?(Array)
            res[key] = [res[key]]
          end
          res[key] << parse(child)
        else
          res[key] = parse(child)
        end
      end
      res
    else
      node.text.strip
    end
  end

  def get(kind, *param)
    uri = URI("#{API}/#{kind}?#{param.first.map{|k,v| "#{k}=#{v}"}.join("&")}")
    req = Net::HTTP::Get.new(uri)
    req["User-Agent"] = USER_AGENT
    response = Net::HTTP.start(API_HOST, API_PORT) do |http|
      http.request(req)
    end
    doc = REXML::Document.new(response.body)
    parse(doc)
  end

  def solved_record(user_id, date_begin = 0)
    res = get("solved_record", user_id: user_id, date_begin: date_begin)
    l = res[:solved_record_list]
    if l.is_a?(Hash)
      unless l[:solved].is_a?(Array)
        l[:solved] = [l[:solved]]
      end
    end
    res
  end
end
