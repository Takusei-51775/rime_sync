function inspect(obj, obj_name)
  local result = {}

  local function add_line(line)
    table.insert(result, line)
  end

  -- Add header with the object name
  add_line("\n ----------INSPECT---------- [" .. (obj_name or "unknown") .. "]")

  -- Helper function to safely use tostring
  local function safe_tostring(value)
    local success, str = pcall(tostring, value)
    if success then
      return str
    else
      return "[tostring error]"
    end
  end

  -- Handle userdata
  if type(obj) == "userdata" then
    add_line("Type: userdata")
    add_line("String representation: " .. safe_tostring(obj))

    local mt = getmetatable(obj)
    if mt then
      add_line("Metatable found:")
      for key, value in pairs(mt) do
        add_line("  " .. safe_tostring(key) .. ": " .. safe_tostring(value))
      end

      -- Check __index
      if type(mt.__index) == "function" then
        add_line("  __index is a function")
        
        -- Try common fields like 'type' and 'text'
        local index_fields = {"type", "text", "iter", "Next", "Peek"}
        for _, field in ipairs(index_fields) do
          local success, field_value = pcall(function()
            return obj[field]
          end)
          if success then
            add_line("  Field [" .. field .. "]: " .. safe_tostring(field_value))
          else
            add_line("  Field [" .. field .. "] access failed")
          end
        end
      elseif type(mt.__index) == "table" then
        add_line("  __index is a table")
        for key, value in pairs(mt.__index) do
          add_line("    " .. safe_tostring(key) .. ": " .. safe_tostring(value))
        end
      end
    else
      add_line("No metatable found")
    end

  -- Handle table
  elseif type(obj) == "table" then
    add_line("Type: table")
    for key, value in pairs(obj) do
      add_line("  " .. safe_tostring(key) .. ": " .. safe_tostring(value))
    end

  -- Handle function
  elseif type(obj) == "function" then
    add_line("Type: function")
    local info = debug.getinfo(obj)
    add_line("  Function name: " .. (info.name or "[anonymous]"))
    add_line("  Defined at: " .. (info.short_src or "[unknown]") .. ":" .. (info.linedefined or "[unknown]"))
    add_line("  Number of parameters: " .. (info.nparams or "[unknown]"))

    -- Get upvalues (variables inside the function's closure)
    for i = 1, info.nups do
      local name, value = debug.getupvalue(obj, i)
      if name then
        add_line("  Upvalue: " .. name .. " = " .. safe_tostring(value))
      end
    end

  -- Handle built-in types (string, number, boolean, etc.)
  elseif type(obj) == "string" or type(obj) == "number" or type(obj) == "boolean" then
    add_line("Type: " .. type(obj))
    add_line("Value: " .. safe_tostring(obj))

  -- Handle thread and lightuserdata
  elseif type(obj) == "thread" then
    add_line("Type: thread")
    add_line("Thread status: " .. coroutine.status(obj))

  elseif type(obj) == "lightuserdata" then
    add_line("Type: lightuserdata")
    add_line("String representation: " .. safe_tostring(obj))

  -- Catch-all for any other unexpected types
  else
    add_line("Unknown type: " .. type(obj))
    add_line("String representation: " .. safe_tostring(obj))
  end

  return table.concat(result, "\n")
end
  
return {func = inspect}