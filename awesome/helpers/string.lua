local string = string


local M = {}

function M.trim(s)
    return s and s:gsub("^%s*(.-)%s*$", "%1") or nil
end

function M.trim_start(s)
    return s and s:gsub("^%s*(.-)", "%1") or nil
end

function M.trim_end(s)
    return s and s:gsub("(.-)%s*$", "%1") or nil
end

return M
