local tab_name = {}

---@class TabbyTabNameOption
---@field name_fallback fun(tabid:number):string

--TODO change the fallback to "fun(tab:TabbyTab)"

local api = require('tabby.module.api')
local buf_name = require('tabby.feature.buf_name')

---@type TabbyTabNameOption
local default_option = {
  name_fallback = function(tabid)
    local wins = api.get_tab_wins(tabid)
    local cur_win = api.get_tab_current_win(tabid)
    local name = ''
    if api.is_float_win(cur_win) then
      name = '[Floating]'
    else
      name = buf_name.get(cur_win)
    end
    if #wins > 1 then
      name = string.format('%s[%d+]', name, #wins - 1)
    end
    return name
  end,
}

---set tab option
---@param opt TabbyTabNameOption
function tab_name.set_default_option(opt)
  default_option = vim.tbl_deep_extend('force', default_option, opt)
end

local tab_name_var = 'tabby_tab_name'

---set tab name
---@param tabid number tab id, 0 for current tab
---@param name string
function tab_name.set(tabid, name)
  vim.api.nvim_tabpage_set_var(tabid, tab_name_var, name)
  vim.cmd('redrawtabline')
end

---get tab's name
---@param tabid number tab id, 0 for current tab
---@param opt? TabbyTabNameOption
---@return string
function tab_name.get(tabid, opt)
  local o = default_option
  if opt ~= nil then
    o = vim.tbl_deep_extend('force', default_option, opt)
  end
  local ok, result = pcall(vim.api.nvim_tabpage_get_var, tabid, tab_name_var)
  if ok then
    return result
  end
  return o.name_fallback(tabid)
end

---get tab's raw name
---@param tabid number
---@return string if no name for tab, return empty string
function tab_name.get_raw(tabid)
  local ok, result = pcall(vim.api.nvim_tabpage_get_var, tabid, tab_name_var)
  if not ok then
    return ''
  end
  return result
end

return tab_name
