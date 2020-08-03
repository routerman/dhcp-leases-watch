
function split(str, ts)
  if ts == nil then return {} end
  local t = {} ; 
  i=1
  for s in string.gmatch(str, "([^"..ts.."]+)") do
    t[i] = s
    i = i + 1
  end
  return t
end

-- 
test=true
slack_url = 'https://hooks.slack.com/services/xxxx/yyyy/zzzz'

if test then
  print('test mode')
  ignore_file = './test/ignore'
  old_file = './test/old_file'
  new_file = './test/new_file'
else
  print('prod mode')
  ignore_file = './ignore'
  old_file = './old_file'
  new_file = '/tmp/dhcp.leases'
end

ignore_devices = {}
old_devices = {}
new_devices = {}

-- file load -- 

igf = io.open(ignore_file, "r")
of = io.open(old_file, "r")
nf = io.open(new_file, "r")

for line in igf:lines() do
  table.insert(ignore_devices,line) 
end

for line in of:lines() do
  local entry = split(line, " ")  
  old_devices[entry[4]] = {ip=entry[3], time=entry[1]}
end

for line in nf:lines() do
  local entry = split(line, " ")
  new_devices[entry[4]] = {ip=entry[3], time=entry[1]}
end

igf:close()
of:close()
nf:close()

-- check diff --

result = ""

disconnected_devices = old_devices
connected_devices = new_devices

for i = 1, #ignore_devices do
  new_devices[ignore_devices[i]] = nil
  old_devices[ignore_devices[i]] = nil
end

-- list not in new_file (=disconnected)
for key, value in pairs(new_devices) do
  if old_devices[key] then
    new_devices[key] = nil
  end
  old_devices[key] = nil
end

-- list not in old_file (=connected)
for key, value in pairs(old_devices) do
  new_devices[key] = nil
end

result = result .. '-- disconnected devices -- \n'

for key, value in pairs(old_devices) do
  result = result .. key .. "(" .. value['ip'] .. ") connected at " .. os.date('%Y-%m-%d %H:%M:%S', value['time']) .. "\n"
end

result = result .. '-- connected devices -- \n'

for key, value in pairs(new_devices) do
  result = result .. key .. "(" .. value['ip'] .. ") connected at " .. os.date('%Y-%m-%d %H:%M:%S', value['time']) .. "\n"
end

-- output --

print(result)


if not test then
  print("cp " .. new_file .. " " .. old_file)
  --os.execute("cp " .. new_file .. " " .. old_file)
end

-- slack notify --
curl_command = "curl -X POST \'" .. slack_url .. "\' -d \'{\"text\": \"" .. result .. "\"}\'"
os.execute(curl_command)

