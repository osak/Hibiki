require 'net/http'
require 'rexml/document'

class AOJ
  API = "http://judge.u-aizu.ac.jp/onlinejudge/webservice"

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
    response = Net::HTTP.get(uri)
    doc = REXML::Document.new(response)
    parse(doc)
  end

  def solved_record(user_id)
    get("solved_record", user_id: user_id, date_begin: 0)
  end
end
