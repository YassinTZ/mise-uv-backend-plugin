--- Lists available versions for a tool in this backend
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendlistversions
--- @param ctx {tool: string} Context (tool = the tool name requested)
--- @return {versions: string[]} Table containing list of available versions
function PLUGIN:BackendListVersions(ctx)
    local tool = ctx.tool

    -- Validate tool name
    if not tool or tool == "" then
        error("Tool name cannot be empty")
    end

    local http = require("http")
    local json = require("json")

    -- PyPI JSON API
    local api_url = "https://pypi.org/pypi/" .. tool .. "/json"

    local resp, err = http.get({ url = api_url })

    if err then
        error("Failed to fetch versions for " .. tool .. ": " .. err)
    end

    if resp.status_code ~= 200 then
        error("API returned status " .. resp.status_code .. " for " .. tool)
    end

    local data = json.decode(resp.body)
    local versions = {}

    -- PyPI API returns versions as keys of data.releases (not data.versions)
    if data.releases then
        for version, _ in pairs(data.releases) do
            table.insert(versions, version)
        end
    end

    if #versions == 0 then
        error("No versions found for " .. tool)
    end

    -- Sort versions in ascending semantic order (oldest to newest)
    -- Splits each version into numeric parts and compares them numerically
    local function version_parts(v)
        local parts = {}
        for part in (v .. "."):gmatch("([^.-]*)[-.]") do
            local n = tonumber(part)
            table.insert(parts, n ~= nil and n or part)
        end
        return parts
    end

    table.sort(versions, function(a, b)
        local pa = version_parts(a)
        local pb = version_parts(b)
        local len = math.max(#pa, #pb)
        for i = 1, len do
            local xv = pa[i] or 0
            local yv = pb[i] or 0
            if type(xv) == "number" and type(yv) == "number" then
                -- numeric comparison to avoid "10" < "9" string ordering
                local xn = xv --[[@as number]]
                local yn = yv --[[@as number]]
                if xn < yn then
                    return true
                end
                if xn > yn then
                    return false
                end
            else
                -- mixed types (e.g. 1 vs "b1"): compare as strings
                local xs = tostring(xv)
                local ys = tostring(yv)
                if xs < ys then
                    return true
                end
                if xs > ys then
                    return false
                end
            end
        end
        return false
    end)

    return { versions = versions }
end
