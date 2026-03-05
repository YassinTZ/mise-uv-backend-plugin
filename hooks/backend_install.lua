--- Installs a specific version of a tool using uv
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendinstall
--- @param ctx {tool: string, version: string, install_path: string} Context
--- @return table Empty table on success
function PLUGIN:BackendInstall(ctx)
    local tool = ctx.tool
    local version = ctx.version
    local install_path = ctx.install_path

    if not tool or tool == "" then
        error("Tool name cannot be empty")
    end
    if not version or version == "" then
        error("Version cannot be empty")
    end
    if not install_path or install_path == "" then
        error("Install path cannot be empty")
    end

    local cmd = require("cmd")

    -- Create a virtual environment at install_path
    local venv_result = cmd.exec("uv venv " .. install_path)
    if venv_result:match("error") then
        error("Failed to create venv for " .. tool .. ": " .. venv_result)
    end

    -- Install the package into the venv
    local pkg = tool .. "==" .. version
    local install_result = cmd.exec("uv pip install --python " .. install_path .. " " .. pkg)
    if install_result:match("error") then
        error("Failed to install " .. pkg .. ": " .. install_result)
    end

    return {}
end
