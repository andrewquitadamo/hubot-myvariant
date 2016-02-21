request = require 'request'

getSearchLink = (searchTerm) ->
  if searchTerm == 'dbsnp ref'
    searchTerm = 'dbsnp.ref'
    link = (id) -> "#{id}"

  return [searchTerm, link]

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

  robot.respond /get (dbsnp ref) ([\w.+\-\*\:\>]+)/i, (res) ->
    searchTerm = res.match[1].toLowerCase()
    variantID = res.match[2]
    variantID=variantID.replace(/:/,"%3A")
    variantID=variantID.replace(/>/,"%3E")

    [searchTerm, link] = getSearchLink(searchTerm)
    myvariantquery = 'http://myvariant.info/v1/variant/' + variantID + '?fields=' + searchTerm
    request myvariantquery, (error, response, body) ->
      if error?
        res.send "Uh-oh. Something has gone wrong\n#{error}"
      if response.statusCode != 200
        res.send "Uh-oh. Something has gone wrong\nHTTP Code #{response.statusCode}"
      else
        id = JSON.parse(body)
        if searchTerm.indexOf('.') > -1
          searchTerms = searchTerm.split('.')
          for searchTerm in searchTerms
            id = id[searchTerm]
        res.send "#{id}"
