
function get_script_directory()
  local info = debug.getinfo(1, "S")
  local script_path = info.source:sub(2)  -- 去掉 '@' 符号
  return script_path:match("(.*\\)")
end

local function log_to_file(message)
  local script_dir = get_script_directory()
  local log_file = io.open(script_dir .. "weasel_debug_log.txt", "a")
  log_file:write(os.date("%Y-%m-%d %H:%M:%S") .. " - " .. message .. "\n")
  log_file:close()
end

return {func = log_to_file}