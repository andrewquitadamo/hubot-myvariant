request = require 'request'

module.exports = (robot) ->
  robot.respond /find variant ([\w.+\-\*]+)/i, (res) ->
    query = res.match[1]
    myvariantquery = 'http://myvariant.info/v1/query?q=' + query
    request myvariantquery, (error, response, body) ->
      if error?
        res.send "Uh-oh. Something has gone wrong\n#{error}"
      if response.statusCode != 200
        res.send "Uh-oh. Something has gone wrong\nHTTP Code #{response.statusCode}"
      else
        hits = JSON.parse(body)['hits']
        response = ""
        for hit in hits
          response += "ID: #{hit._id}\n"
        res.send "#{response}"


