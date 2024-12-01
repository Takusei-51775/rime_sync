
func_translator = require("func_translator")

tex_translator = require("tex_translator")

commit_history = require("commit_history")

fix_freq_filter = require("fix_freq_filter")


function date_translator(input, seg)
  if (input == "date") then
    --- Candidate(type, start, end, text, comment)
    yield(Candidate("date", seg.start, seg._end, os.date("%Y年%m月%d日"), " 日期"))
  end
end

function single_char_first_filter(input)
  local l = {}
  for cand in input:iter() do
    if (utf8.len(cand.text) == 1) then
      yield(cand)
    else
      table.insert(l, cand)
    end
  end
  for i, cand in ipairs(l) do
    yield(cand)
  end
end