local obj = {}
obj.__index = obj
obj.__name = "seal_yd"

function obj:bare()
  return nil
end

function obj:commands()
  return {yd = {
      cmd="yd",
      fn = obj.youdaoInstantTrans,
      name = "Youdao Dict",
      description = "Translate with youdao dict",
      plugin = obj.__name
    }
  }
end


function obj:youdaoInstantTrans(querystr)
    local youdao_keyfrom = 'hsearch'
    local youdao_apikey = '1199732752'
    local youdao_baseurl = 'http://fanyi.youdao.com/openapi.do?keyfrom=' .. youdao_keyfrom .. '&key=' .. youdao_apikey .. '&type=data&doctype=json&version=1.1&q='
  if query == nil or query == "" or query == ".*" then
      local chooser_data = {
          {text="Youdao Dictionary", subText="Type something to get it translated …"}
      }
      return chooser_data
  else
        local encoded_query = hs.http.encodeForQuery(querystr)
        local query_url = youdao_baseurl .. encoded_query

        status, data = hs.http.get(query_url, "")
        if status == 200 then
            if pcall(function() hs.json.decode(data) end) then
                local decoded_data = hs.json.decode(data)
                if decoded_data.errorCode == 0 then
                    local basictrans = basic_extract(decoded_data.basic)
                    local webtrans = web_extract(decoded_data.web)
                    local dictpool = hs.fnutils.concat(basictrans, webtrans)
                    if #dictpool > 0 then
                        local chooser_data = hs.fnutils.imap(dictpool, function(item)
                            return {text=item, output="clipboard", arg=item}
                        end)
                        return chooser_data
                    end
                end
            end
        end
    end
end

return obj
