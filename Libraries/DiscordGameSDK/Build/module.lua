premake.extensions.discordgamesdk = {}

function discordgamesdk_parent_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    local dir =  str:match("(.*/)"):sub(0,-2)
    local index = string.find(dir, "/[^/]*$")
    return dir:sub(0, index)
end

function discordgamesdk_generate()
    if premake.extensions.discordgamesdk.generated == true then
        return
    end

    local basePath = premake.extensions.discordgamesdk.path

    group "ThirdParty"
        project ("DiscordGameSDK")
            kind ("StaticLib")
            language ("C++")

            includedirs
            {
                basePath .. "/Code/include/"
            }

            files
            {
                basePath .. "/Code/**.cpp"
            }

    
    premake.extensions.discordgamesdk.generated = true
end

premake.extensions.discordgamesdk.path = discordgamesdk_parent_path()
premake.extensions.discordgamesdk.generate = discordgamesdk_generate
