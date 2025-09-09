-- Copyright (C) Anjia (anjia0532)

local json                = require('cjson')
local resty_rsa           = require("resty.rsa")
local str                 = require("resty.string")
local base64_encode       = ngx.encode_base64
local json_encode         = json.encode
local json_decode         = json.decode
json.encode_empty_table_as_object(false)

local _M                  = {}

local ASNKEY              = [[
-----BEGIN RSA PRIVATE KEY-----
MIIBOgIBAAJBALecq3BwAI4YJZwhJ+snnDFj3lF3DMqNPorV6y5ZKXCiCMqj8OeOmxk4YZW9aaV9
ckl/zlAOI0mpB3pDT+Xlj2sCAwEAAQJAW6/aVD05qbsZHMvZuS2Aa5FpNNj0BDlf38hOtkhDzz/h
kYb+EBYLLvldhgsD0OvRNy8yhz7EjaUqLCB0juIN4QIhAOeCQp+NXxfBmfdG/S+XbRUAdv8iHBl+
F6O2wr5fA2jzAiEAywlDfGIl6acnakPrmJE0IL8qvuO3FtsHBrpkUuOnXakCIQCqdr+XvADI/UTh
TuQepuErFayJMBSAsNe3NFsw0cUxAQIgGA5n7ZPfdBi3BdM4VeJWb87WrLlkVxPqeDSbcGrCyMkC
IFSs5JyXvFTreWt7IQjDssrKDRIPmALdNjvfETwlNJyY
-----END RSA PRIVATE KEY-----
]]
local PCKS8KEY            = [[
-----BEGIN PRIVATE KEY-----
MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAND3cI/pKMSd4OLMIXU/8xoEZ/nz
a+g00Vy7ygyGB1Nn83qpro7tckOvUVILJoN0pKw8J3E8rtjhSyr9849qzaQKBhxFL+J5uu08QVn/
tMt+Tf0cu5MSPOjT8I2+NWyBZ6H0FjOcVrEUMvHt8sqoJDrDU4pJyex2rCOlpfBeqK6XAgMBAAEC
gYBM5C+8FIxWxM1CRuCs1yop0aM82vBC0mSTXdo7/3lknGSAJz2/A+o+s50Vtlqmll4drkjJJw4j
acsR974OcLtXzQrZ0G1ohCM55lC3kehNEbgQdBpagOHbsFa4miKnlYys537Wp+Q61mhGM1weXzos
gCH/7e/FjJ5uS6DhQc0Y+QJBAP43hlSSEo1BbuanFfp55yK2Y503ti3Rgf1SbE+JbUvIIRsvB24x
Ha1/IZ+ttkAuIbOUomLN7fyyEYLWphIy9kUCQQDSbqmxZaJNRa1o4ozGRORxR2KBqVn3EVISXqNc
UH3gAP52U9LcnmA3NMSZs8tzXhUhYkWQ75Q6umXvvDm4XZ0rAkBoymyWGeyJy8oyS/fUW0G63mIr
oZZ4Rp+F098P3j9ueJ2k/frbImXwabJrhwjUZe/Afel+PxL2ElUDkQW+BMHdAkEAk/U7W4Aanjpf
s1+Xm9DUztFicciheRa0njXspvvxhY8tXAWUPYseG7L+iRPh+Twtn0t5nm7VynVFN0shSoCIAQJA
Ljo7A6bzsvfnJpV+lQiOqD/WCw3A2yPwe+1d0X/13fQkgzcbB3K0K81Euo/fkKKiBv0A7yR7wvrN
jzefE9sKUw==
-----END PRIVATE KEY-----
]]


_M._VERSION               = '0.0.3'

local mt                  = { __index = _M }

local priv1, err = resty_rsa:new({
  private_key  = ASNKEY,
  key_type = resty_rsa.KEY_TYPE.PKCS1,
  algorithm = "md5"
})

local priv8, err = resty_rsa:new({
  private_key = PCKS8KEY,
  key_type = resty_rsa.KEY_TYPE.PKCS8,
  algorithm = "SHA1"
})

function sign1(content)
  local sig, err = priv1:sign(content)
  if not sig then
      ngx.log(ngx.ERR,"failed to sign:", err)
      return nil,err
  end
  return str.to_hex(sig),nil
end

function sign8(content)
  local sig, err = priv8:sign(content)
  if not sig then
      ngx.log(ngx.ERR,"failed to sign:", err)
      return nil,err
  end
  return base64_encode(sig),nil
end

-- fct to simulate a switch
local function switch(t)
  t.case = function (self,x)
    local f=self[x] or self.default
    if f then
      if type(f)=="function" then
        return f(x,self)
      else
        error("case "..tostring(x).." not a function")
      end
    end
  end
  return t
end

local route = switch {
  ["/"] = function() return indexHandler() end,
  -- jrebel
  ["/jrebel/leases"] =  function() return jrebelLeasesHandler() end,
  ["/jrebel/leases/1"] = function() return jrebelLeases1Handler() end,
  ["/agent/leases"] = function()  return jrebelLeasesHandler() end,
  ["/agent/leases/1"] = function() return jrebelLeases1Handler() end,
  ["/jrebel/validate-connection"] = function() return jrebelValidateHandler() end,
  -- idea
  ["/rpc/ping.action"] = function() return pingHandler() end,
  ["/rpc/obtainTicket.action"] = function() return obtainTicketHandler() end,
  ["/rpc/releaseTicket.action"] = function() return releaseTicketHandler() end,
  default = function () ngx.exit(ngx.HTTP_FORBIDDEN) end
}
-- UUID4生成函数
function uuid4()
  local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  return string.gsub(template, '[xy]', function(c)
    local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format('%x', v)
  end)
end

function indexHandler()
  ngx.header.content_type   = "text/html; charset=utf-8"
  local req = ngx.var.scheme .. "://" .. ngx.var.host
  -- .. ":" .. ngx.var.server_port
  if not (( ngx.var.scheme == 'https' and ngx.var.server_port == '443' ) or (ngx.var.scheme == 'http' and ngx.var.server_port == '80')) then
   req = req .. ":" .. ngx.var.server_port
  end
  req = req .. "/"

  ngx.print("<h3>JetBrains Activation address was: " .. req .. "</h3>")
  ngx.print("<h3>JRebel 7.1 and earlier version Activation address was: ".. req .."{tokenname}, with any email.</h3>")
  ngx.print("<h3>JRebel 2018.1 and later version Activation address was:".. req .."{guid}(eg:" .. req .. uuid4() .. "), with any email.</h3>")
end

-- ngx.req.read_body()
-- local args, err = ngx.req.get_post_args()
-- local args, err = ngx.req.get_uri_args()
function jrebelLeasesHandler()
  ngx.header.content_type = "application/json; charset=utf-8"
  ngx.req.read_body()
  local args, err = ngx.req.get_post_args()

  local username = args["username"]
  local offline = args["offline"] or false
  local product = args["product"]
  if product == "XRebel" then
      offline = false
  end
  local guid = args["guid"]
  local offlineDays = args["offlineDays"]
  local validFrom = "null"
  local validUntil = "null"
  if offline then
    local clientTime = args["clientTime"] or 0
    -- 86400000 = 24 * 60 * 60 * 1000 = 1 days
    validFrom = clientTime
    validUntil = clientTime + (offlineDays or 180) * 86400000
  end
  local clientRandomness = args["randomness"]
  local resp = [[
    {
      "serverVersion":"3.2.4",
      "serverProtocolVersion":"1.1",
      "serverGuid":"a1b4aea8-b031-4302-b602-670a990272cb",
      "groupType":"managed",
      "id":1,
      "licenseType":1,
      "evaluationLicense":false,
      "signature":"OJE9wGg2xncSb+VgnYT+9HGCFaLOk28tneMFhCbpVMKoC/Iq4LuaDKPirBjG4o394/UjCDGgTBpIrzcXNPdVxVr8PnQzpy7ZSToGO8wv/KIWZT9/ba7bDbA8/RZ4B37YkCeXhjaixpmoyz/CIZMnei4q7oWR7DYUOlOcEWDQhiY=",
      "serverRandomness":"H2ulzLlh7E0=",
      "seatPoolType":"standalone",
      "statusCode":"SUCCESS",
      "offline":%s,
      "validFrom":%s,
      "validUntil":%s,
      "company":"Administrator",
      "orderId":"",
      "zeroIds":[],
      "licenseValidFrom":1490544001000,
      "licenseValidUntil":1691839999000
    }
  ]]

  if not clientRandomness or not username or not guid then
    ngx.exit(ngx.HTTP_FORBIDDEN)
  end
  resp = string.format(resp,offline,validFrom,validUntil)
  local jsonObj = json_decode(resp)
  local signature =  toLeaseCreateJson(clientRandomness, guid, offline, validFrom, validUntil)
  jsonObj["signature"] = signature
  jsonObj["company"] =  username
  return json_encode(jsonObj)
end

function toLeaseCreateJson(clientRandomness, guid, offline, validFrom, validUntil)
  serverRandomness =  "H2ulzLlh7E0="
  installationGuidString = guid
  local tab = {clientRandomness, serverRandomness, installationGuidString ,tostring(offline)}
  if offline then
    tab[ #tab+1 ] = validFrom
    tab[ #tab+1 ] = validUntil
  end
  local s2 = table.concat( tab, ";")
  return sign8(s2)
end

function jrebelLeases1Handler()
  ngx.header.content_type = "application/json; charset=utf-8"
  local args, err = ngx.req.get_uri_args()
  local username = args['username']
  local resp = {
    ["serverVersion"] = "3.2.4",
    ["serverProtocolVersion"] = "1.1",
    ["serverGuid"] = "a1b4aea8-b031-4302-b602-670a990272cb",
    ["groupType"] = "managed",
    ["statusCode"] = "SUCCESS",
    ["msg"] = "null",
    ["statusMessage"] = "null",
    ["signature"] = "dGVzdA=="
  }
  if username then
    resp["company"] = username
  end
  return json_encode(resp)
end

function jrebelValidateHandler()
  ngx.header.content_type = "application/json; charset=utf-8"
  local resp = [[{
      "serverVersion": "3.2.4",
      "serverProtocolVersion": "1.1",
      "serverGuid": "a1b4aea8-b031-4302-b602-670a990272cb",
      "groupType": "managed",
      "statusCode": "SUCCESS",
      "company": "Administrator",
      "canGetLease": true,
      "licenseType": 1,
      "evaluationLicense": false,
      "seatPoolType": "standalone"
  }]]
  return resp
end


function obtainTicketHandler()
  ngx.header.content_type = "text/html;charset=UTF-8"
  -- ngx.req.read_body()
  -- local args, err = ngx.req.get_post_args()
  local args, err = ngx.req.get_uri_args()
  local salt = args["salt"];
  local username = args["userName"];
  local prolongationPeriod = "607875500";
  if not username or not salt then
    ngx.exit(ngx.HTTP_FORBIDDEN)
  end
  local xmlContent = "<ObtainTicketResponse><message></message><prolongationPeriod>" .. prolongationPeriod .. "</prolongationPeriod><responseCode>OK</responseCode><salt>" .. salt .. "</salt><ticketId>1</ticketId><ticketProperties>licensee=" .. username .. "\tlicenseType=0\t</ticketProperties></ObtainTicketResponse>";

  local xmlSignature = sign1(xmlContent)
  return "<!-- " .. xmlSignature .. " -->\n" .. xmlContent
end

function pingHandler()
  return releaseAndPingHandler("PingResponse")
end
function releaseTicketHandler()
  return releaseAndPingHandler("ReleaseTicketResponse")
end
function releaseAndPingHandler(type)
  ngx.header.content_type = "text/html; charset=utf-8"
  ngx.log(ngx.ERR,type)
  local args, err = ngx.req.get_uri_args()
  local salt = args["salt"]
  if not salt then
    ngx.exit(ngx.HTTP_FORBIDDEN)
  end
  local xmlContent = "<"..type.."><message></message><responseCode>OK</responseCode><salt>" .. salt .. "</salt></"..type..">"
  local xmlSignature = sign1(xmlContent)
  return "<!-- " .. xmlSignature .. " -->\n" .. xmlContent
end

function _M.handler()
  return route:case(ngx.var.uri) or ''
end

return _M;
