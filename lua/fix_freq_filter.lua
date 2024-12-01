local inspect = require("inspect").func
local log_to_file = require("log_to_file").func

local fixed_characters = require("fixed_characters")


local function init(env)
  -- env.tag = 'abc'
  -- env.size = 9;
  -- env.input = 'z';
  -- env.quality = 1000;
  -- env.translator = Component.Translator(env.engine, "", "script_translator")

  -- local load = dofile("lua/fixed_characters.lua")
  -- log_to_file("**********")
  -- -- env.fixed_characters = dofile("fixed_characters.lua")
  -- log_to_file("******1111***** " .. tostring(#fixed_characters))
  
  -- local context = env.engine.context
  -- env.hists = {}
  -- env.connection = context.commit_notifier:connect
  -- (function(ctx)
  --       table.insert(env.hists, ctx:get_commit_text())
  -- end)
end


local function do_nothing(input)
  for cand in input:iter() do
    yield(cand)
  end
end

local function yield_all(candidates)
  for _, cand in ipairs(candidates) do
    yield(cand)
  end
end

local function lookup_fix_weight(candidate)
  if not fixed_characters[candidate.preedit] then
    return 0
  end
  
  if (fixed_characters[candidate.preedit].text == candidate.text) then
      return fixed_characters[candidate.preedit].weight
  end

  return 0
end

local function utf8_len(input)
  local len = 0
  local i = 1
  local byte_len = #input
  while i <= byte_len do
    local byte = string.byte(input, i)
    if byte < 0x80 then
      i = i + 1            -- 单字节字符 (ASCII)
    elseif byte < 0xE0 then
      i = i + 2            -- 两字节字符
    elseif byte < 0xF0 then
      i = i + 3            -- 三字节字符 (通常是中文)
    else
      i = i + 4            -- 四字节字符
    end
    len = len + 1
  end
  return len
end


local function fix_freq_filter(input, env)

  local context = env.engine.context
  -- log_to_file(inspect(context, "context"))
  -- -- 尝试过load translator的方式，适合放在lua translator里而不是filter里
  -- translator = Component.Translator(env.engine, "", "script_translator@ounei_test")
  -- log_to_file(inspect(translator, "translator"))
  -- log_to_file(inspect(translator.name_space, "translator.name_space"))
  -- log_to_file(inspect(input, "input"))

  local cand_count = 0
  local max_cands = 10
  
  local candidates = {}
  local other_candidates = {}
  local best_candidates = {}

  for candidate in input:iter() do
    -- table.insert(candidates, candidate)
    if (cand_count < max_cands) then
      table.insert(best_candidates, candidate)
      cand_count = cand_count + 1
    else
      table.insert(other_candidates, candidate)
    end
  end



  local index_map = {}

  for idx, cand in ipairs(best_candidates) do
      index_map[cand] = idx  -- 将 original_index 存储在辅助表中
  end
  -- for idx, cand in ipairs(candidates) do
  --     index_map[cand] = idx  -- 将 original_index 存储在辅助表中
  -- end


  -- for idx, cand in ipairs(candidates) do
  --   cand.original_index = idx -- failed，是userdata类型，无法添加属性
  --   -- log_to_file("cand: " .. cand.text .. " index: " .. idx)
  --   -- log_to_file(inspect(cand, "cand"))
  --   -- log_to_file("cand.original_index: " .. cand.original_index)
  --   -- cand.comment = cand.type .. ' ' .. cand.preedit .. "[" .. cand.comment
  -- end


  table.sort(best_candidates, function(a, b)
    local len_a, len_b = utf8_len(a.preedit), utf8_len(b.preedit) 
    if len_a ~= len_b then
      return len_a > len_b  -- 按照 text 长度降序排序
    else
      -- log_to_file("a: " .. a.text .. " b: " .. b.text)
      -- if lookup_fix_weight(a) > 0 then
      --   log_to_file("a: " .. a.text .. "lookup_fix_weight(a): " .. lookup_fix_weight(a))
      -- end
      -- if lookup_fix_weight(b) > 0 then
      --   log_to_file("b: " .. b.text .. "lookup_fix_weight(b): " .. lookup_fix_weight(b))
      -- end
      if lookup_fix_weight(a) ~= lookup_fix_weight(b) then
        return lookup_fix_weight(a) > lookup_fix_weight(b)  -- 按照权重降序排序
      else
        return index_map[a] < index_map[b]  -- 保持原始顺序
      end
    end
  end)

  yield_all(best_candidates)
  yield_all(other_candidates)
  
  return

  -- local nonfixed_chars = {}


  -- for _, cand in ipairs(candidates) do
  --   -- cand.comment = cand.comment .. ' ' .. cand.text .. ' ' .. tostring(#cand.text)
  --   -- if (utf8_len(cand.text) == 1) then
  --     -- log_to_file(inspect(cand, "cand"))
  --     -- local char = cand.text
  --     -- if (lookup(cand)) then
  --     --   cand.comment = cand.comment .. " FIXED ".. cand.preedit
  --     --   yield(cand)
  --     -- else
  --     --   table.insert(nonfixed_chars, cand)
  --     -- end
  --   -- else
  --   --   yield(cand)
  --   -- end
  -- end

  -- -- log_to_file(#nonfixed_chars)

  -- -- yield_all(nonfixed_chars)
  

  -- -- yield_all(candidates)



  -- -- local translation = env.translator:Query(input, seg)

  -- -- -- log_to_file(inspect(translation, "translation"))

  -- -- local candidate = translation:Peek()

  -- -- -- log_to_file(inspect(candidate, "candidate"))

  -- -- candidate.comment = "FromPeek"

  -- -- yield(candidate)

  -- -- local context = env.engine.context

  -- -- local history = context.commit_history:to_table()
  -- -- local last_commit = history[#history]

  -- -- local back = context.commit_history:back()

  -- -- log_to_file(inspect(back, "back"))
  -- -- log_to_file(inspect(last_commit, "last_commit"))

  -- -- log_to_file(inspect(last_commit.type, "last_commit.type"))
  -- -- log_to_file(inspect(back.type, "back.type"))
  -- -- log_to_file(inspect(back.text, "back.text"))

  -- -- yield(Candidate(last_commit.type, seg.start, seg._end, last_commit.text .. " LAST", 'last'))

  -- -- yield(Candidate(back.type, seg.start, seg._end, back.text .. " BACK", "Back"))

  -- -- -------------- ACTIVATE THIS TO SEE THE HISTORY --------------
  -- -- -- for i = #history, 1, -1 do
  -- -- --   local v = history[i]
  -- -- --   yield(Candidate(v.type, seg.start, seg._end, v.text, 'history'))
  -- -- -- end

  -- -- for cand in input:iter() do
  -- --   yield(cand)
  -- -- end

  -- return


end

return {init = init, func = fix_freq_filter}
