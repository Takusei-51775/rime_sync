local inspect = require("inspect").func
local log_to_file = require("log_to_file").func



local function init(env)
  env.tag = 'abc'
  env.size = 9;
  env.input = 'z';
  env.quality = 1000;
  env.history_translatior = Component.Translator(env.engine,"translator", "history_translator")
  
  local context = env.engine.context
  env.hists = {}
  env.connection = context.commit_notifier:connect
  (function(ctx)
        table.insert(env.hists, ctx:get_commit_text())
  end)
end


local function history(input, seg, env)
  if not (input == "history") then
    return
  end
  
  --   if not seg:has_tag(env.tag) or not input:match("^".. env.input .. "$") then
  --     return
  --   end

  local context = env.engine.context
  local count = env.size

  local history = context.commit_history:to_table()
  local last_commit = history[#history]

  local back = context.commit_history:back()

  log_to_file(inspect(back, "back"))
  log_to_file(inspect(last_commit, "last_commit"))

  log_to_file(inspect(last_commit.type, "last_commit.type"))
  log_to_file(inspect(back.type, "back.type"))
  log_to_file(inspect(back.text, "back.text"))

  yield(Candidate(last_commit.type, seg.start, seg._end, last_commit.text .. " LAST", 'last'))

  yield(Candidate(back.type, seg.start, seg._end, back.text .. " BACK", "Back"))

  
  -------------- ACTIVATE THIS TO SEE THE HISTORY --------------
  -- for i = #history, 1, -1 do
  --   local v = history[i]
  --   yield(Candidate(v.type, seg.start, seg._end, v.text, 'history'))
  -- end
  
  -- for _, v in ipairs(env.hists) do
  --   yield(Candidate("history", seg.start, seg._end, v, "History"))
  -- end


  for cand in context.commit_history:iter() do
    log_to_file(inspect(cand, "cand"))
    log_to_file(inspect(cand:get(), "cand:get()"))
  end

  yield(Candidate(back.type, seg.start, seg._end, back.text, "Back"))


    -- yield(Candidate(last_commit.type, seg.start, seg._end, "DEBUG", "DEBUG"))
    -- yield(Candidate(last_commit.type, seg.start, seg._end, "DEBUG", "DEBUG"))
    -- yield(Candidate(cand.type, seg.start, seg._end, cand.text, "History"))
    -- yield(cand) 
    -- count = count - 1
    -- if count <= 0 then break end

end

return {init = init, func = history}