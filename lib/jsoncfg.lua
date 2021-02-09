--[[
	JSONCFG FOR LUA MOONLOADER
	AUTHOR: PAVEL GARSON (PAKULICHEV)
	FUNCTIONS:
		- bool/table result = load(string path_to_json_file, table table_with_default_keys) [IF RESULT IS TRUE THEN RESULT HAS TABLE TYPE]
		- table result = save(string path_to_json_file, table table_to_save_to_file) [ONLY TRUE OR FALSE]
	VK: https://vk.com/pavel.akulichev
	E-MAIL: paveltalking@gmail.com

	LAST UPDATE:
		#1.0.0 - realeas of JSONCFG lib
		#1.1.0 - UTF8 fix for Moonloader v.027
]]

local module = {_VERSION = '1.1.2'}

local encoding = require("encoding")
encoding.default = "UTF-8"
local cyr = encoding.CP1251

local function updateTable(default_table, fJson)
	for k, v in pairs(default_table) do
		if type(v) == 'table' then
			if fJson[k] == nil then fJson[k] = {} end
			fJson[k] = updateTable(default_table[k], fJson[k])
		else if fJson[k] == nil then fJson[k] = v end end
	end
	return fJson
end

function module.load(json_file, default_table)
	if json_file then json_file = cyr(json_file) end
	if not default_table or type(default_table) ~= 'table' then default_table = {} end 
	if not json_file or not doesFileExist(json_file) then return false end
	local fHandle = io.open(json_file, 'r')
	if not fHandle then return false end
	local fText = fHandle:read('*all') 
	fHandle:close()
	if not fText then return false end
	local fRes, fJson = pcall(decodeJson, fText)
	if not fRes or not fJson or type(fJson) ~= 'table' then return false end
	fJson = updateTable(default_table, fJson)
	return fJson
end

function module.save(json_file, lua_table)
	if json_file then json_file = cyr(json_file) end
	if not json_file or not lua_table or type(lua_table) ~= 'table' then return false end
	if doesFileExist(json_file) then os.remove(json_file) end
	local fHandle = io.open(json_file, 'w+')
	if not fHandle then return false end
	fHandle:write(encodeJson(lua_table))
	fHandle:close()
	return true
end

return module
