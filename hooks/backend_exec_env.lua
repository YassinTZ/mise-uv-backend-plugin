--- Sets up environment variables for a tool installed via uv
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendexecenv
--- @param ctx {install_path: string, tool: string, version: string} Context
--- @return {env_vars: table[]} Table containing list of environment variable definitions
function PLUGIN:BackendExecEnv(ctx)
    local install_path = ctx.install_path
    local file = require("file")

    -- The venv's bin directory contains the installed tool's executables
    return {
        env_vars = {
            { key = "PATH", value = file.join_path(install_path, "bin") },
            { key = "VIRTUAL_ENV", value = install_path },
        },
    }
end
