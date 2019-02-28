local obj = {}
obj.__index = obj
obj.__name = "seal_youdao"

function obj:bare()
  return nil
end

function obj:commands()
  return {yd= {
      cmd="yd",
      fn = obj.runYoudao,
      name = "Youdao Dict",
      description = "Translate with youdao dict",
      plugin = obj.__name
    }
  }
end

local function basic_extract(arg)
    if arg then return arg.explains else return {} end
end
local function web_extract(arg)
    if arg then
        local value = hs.fnutils.imap(arg, function(item)
            return item.key .. table.concat(item.value, ",")
        end)
        return value
    else
        return {}
    end
end

function obj.runYoudao(query)
  local youdao_keyfrom = 'hsearch'
  local youdao_apikey = '1199732752'
  local youdao_baseurl = 'http://fanyi.youdao.com/openapi.do?keyfrom=' .. youdao_keyfrom .. '&key=' .. youdao_apikey .. '&type=data&doctype=json&version=1.1&q='

  if query == nil or query == "" or query == ".*" then
    local chooser_data = {
        {text="Youdao Dictionary", subText="Type something to get it translated …"}
    }
    return chooser_data
  else
    local encoded_query = hs.http.encodeForQuery(query)
    local query_url = youdao_baseurl .. encoded_query

    status, data = hs.http.get(query_url, nil)
    if status == 200 then
      local decoded_data = hs.json.decode(data)
      if decoded_data.errorCode == 0 then
        local basictrans = basic_extract(decoded_data.basic)
        local webtrans = web_extract(decoded_data.web)
        local dictpool = hs.fnutils.concat(basictrans, webtrans)
        if #dictpool > 0 then
          local chooser_data = hs.fnutils.imap(dictpool, function(item)
            return {text=item, type="clipboard", arg=item}
          end)
          return chooser_data
        end
      end
    end
  end
end

function obj.completionCallback(rowInfo)
  if rowInfo["type"] == "clipboard" then
      hs.pasteboard.setContents(rowInfo["text"])
  end
end

return obj
