require("premake", ">=5.0.0-alpha10")

------
-- Prepare dependencies
------

cefDir = "../Libraries/TiltedUI/ThirdParty/CEF/";

if os.isdir(cefDir) == false and os.istarget("Windows") == true then
    print("Downloading CEF dependencies...")

    http.download("https://download.skyrim-together.com/ThirdParty.zip", "ThirdParty.zip")
   
    print("Extracting CEF dependencies...")
    zip.extract("ThirdParty.zip", "../Libraries/TiltedUI/")
    os.remove("ThirdParty.zip")
end

include "../Libraries/TiltedCore/Build/module.lua"
include "../Libraries/TiltedConnect/Build/module.lua"
include "../Libraries/TiltedScript/Build/module.lua"
include "../Libraries/DiscordGameSDK/Build/module.lua"

if (os.istarget("Windows") == true) then
    include "../Libraries/TiltedReverse/Build/module.lua"
    include "../Libraries/TiltedUI/Build/module.lua"
    include "../Libraries/TiltedHooks/Build/module.lua"
end

local coreBasePath = premake.extensions.core.path
local connectBasePath = premake.extensions.connect.path
local scriptBasePath = premake.extensions.script.path

workspace ("Tilted Online Framework")

    ------------------------------------------------------------------
    -- setup common settings
    ------------------------------------------------------------------
    configurations { "Skyrim", "Fallout4" }

    location ("projects")
    startproject ("Tests")
    
    staticruntime "On"
    vectorextensions "SSE2"
    warnings "Extra"
    
    flags { "MultiProcessorCompile" }
    
    cppdialect "C++17"

	platforms { "x64" }

    includedirs
    { 
        "../ThirdParty/", 
        "../Code/"
    }
    
    defines { "SPDLOG_COMPILED_LIB", "_CRT_SECURE_NO_WARNINGS", "SOL_NO_EXCEPTIONS" }
	
    filter { "action:vs*"}
        buildoptions { "/wd4512", "/wd4996",  "/wd4018", "/wd4100", "/wd4125", "/wd4214", "/wd4127", "/wd4005", "/wd4324", "/Zm500" }
        linkoptions { "/IGNORE:4099", "/IGNORE:4006" }
        defines { "WIN32" }
        
    filter { "action:gmake*", "language:C++" }
        buildoptions { "-g -fpermissive" }
        linkoptions ("-lm -lpthread -pthread -Wl,--no-as-needed -lrt -g -fPIC")

    filter { "configurations:Skyrim" }
        defines { "NDEBUG", "PUBLIC_BUILD", "TP_SKYRIM" }
        optimize ("On")
        
    filter { "configurations:Fallout4" }
        defines { "NDEBUG", "PUBLIC_BUILD", "TP_FALLOUT" }
        optimize ("On")

    filter { "architecture:*64" }
        libdirs { "lib/x64" }
        targetdir ("bin/x64")
        
    filter {}

    group ("Utilities")
        project ("_MakeProjects")
            kind ("Utility")
            
            postbuildcommands { 'cd "$(SolutionDir).." && MakeVS2019Projects.bat' }

    group ("Applications")
        project ("Tests")
            kind ("ConsoleApp")
            language ("C++")
            
            includedirs
            {
                "../Code/tests/include/",
                "../Code/encoding/include/",
                "../Libraries/entt/src/",
                coreBasePath .. "/Code/core/include/",
                coreBasePath .. "/ThirdParty"
            }

            files
            {
                "../Code/tests/include/**.h",
                "../Code/tests/src/**.cpp",
            }
			
            links
            {
                "Encoding",
                "Core",
                "mimalloc"
            }

        if (os.istarget("Windows") == true) then

            local uiBasePath = premake.extensions.ui.path

            project ("Client")
                kind ("SharedLib")
                language ("C++")
                
                filter { "configurations:Skyrim" }
                    targetname ("SkyrimTogether")
            
                filter { "configurations:Fallout4" }
                    targetname ("FalloutTogether")
                    
                filter {}
                
                includedirs
                {
                    "../Code/client/include/",
                    "../Code/script/include/",
                    "../Code/encoding/include/",
                    "../Libraries/entt/src/",
                    "../Libraries/",
                    coreBasePath .. "/Code/core/include/",
                    coreBasePath .. "/ThirdParty/mimalloc/include/",
                    "../Libraries/TiltedReverse/Code/reverse/include/",
                    "../Libraries/TiltedUI/Code/ui/include/",
                    "../Libraries/TiltedUI/ThirdParty/CEF/",
                    "../Libraries/TiltedHooks/Code/hooks/include/",
                    "../Libraries/TiltedReverse/ThirdParty/",
                    "../Libraries/DiscordGameSDK/Code/include/",
                    connectBasePath .. "/Code/connect/include/",
                    connectBasePath .. "/ThirdParty/GameNetworkingSockets/include/",
                    connectBasePath .. "/ThirdParty/protobuf/src/",
                    uiBasePath .. "/ThirdParty/imgui/",
                    scriptBasePath .. "/ThirdParty/lua/",
                    scriptBasePath .. "/Code/script/include/",
                }

                files
                {
                    "../Code/client/include/**.h",
                    "../Code/client/src/**.cpp",
                    "../Libraries/spdlog/spdlog.cpp"
                }
                
                pchheader ("stdafx.h")
                pchsource ("../Code/client/src/stdafx.cpp")
                forceincludes
                {
                    "stdafx.h"
                }
                
                links
                {
                    "Encoding",
                    "Core",
                    "Reverse",
                    "Hooks",
                    "mhook",
                    "UI",
                    "disasm",
                    "Connect",
                    "SteamNet",
                    "Lua",
                    "mimalloc",
                    "Script",
                    "sqlite3",
                    "imgui",
                    "Version",
                    "snappy",
                    "DiscordGameSDK"
                }

            
            project ("tp_process")
                kind ("WindowedApp")
                language ("C++")
                
                includedirs
                {
                    "../Code/tests/include/",
                    coreBasePath .. "/Code/core/include/",
                    "../Code/tp_process/include/",
                    "../Libraries/TiltedUI/Code/ui_process/include/",
                    "../Libraries/TiltedUI/ThirdParty/CEF/",
                }

                files
                {
                    "../Code/tp_process/include/**.h",
                    "../Code/tp_process/src/**.cpp",
                }
                
                links
                {
                    "Core",
                    "UIProcess"
                }
        end
            
        project ("Server")
            kind ("ConsoleApp")
            language ("C++")
            
            filter { "configurations:Skyrim" }
                targetname ("SkyrimTogetherServer")
        
            filter { "configurations:Fallout4" }
                targetname ("FalloutTogetherServer")
                
            filter {}
            
            
            includedirs
            {
                "../Code/server/include/",
                "../Code/script/include/",
                "../Code/encoding/include/",
                "../Libraries/entt/src/",
                "../Libraries/",
                coreBasePath .. "/Code/core/include/",
                connectBasePath .. "/Code/connect/include/",
                connectBasePath .. "/ThirdParty/GameNetworkingSockets/include/",
                connectBasePath .. "/ThirdParty/protobuf/src/",
                scriptBasePath .. "/ThirdParty/lua/",
                scriptBasePath .. "/Code/script/include/",
            }

            files
            {
                "../Code/server/include/**.h",
                "../Code/server/src/**.cpp",
                "../Libraries/spdlog/spdlog.cpp"
            }
            
            pchheader ("stdafx.h")
            pchsource ("../Code/server/src/stdafx.cpp")
            forceincludes
            {
                "stdafx.h"
            }
			
            links
            {
                "Encoding",
                "Connect",
                "snappy",
                "SteamNet",
                "Script",
                "Core",
                "mimalloc",
                "Lua",
                "sqlite3",
                "protobuf"
            }
            
            filter { "action:gmake*", "language:C++" }
                defines
                {
                    'POSIX',
                    'LINUX',
                    'GNUC',
                    'GNU_COMPILER',
                }
                
                links
                {
                    "stdc++fs",
                    "ssl",
                    "crypto"
                }

            filter ""

        project ("Encoding")
            kind ("StaticLib")
            language ("C++")
                
            filter {}
            
            includedirs
            {
                "../Code/encoding/include/",
                "../Libraries/",
                coreBasePath .. "/Code/core/include/",
            }

            files
            {
                "../Code/encoding/include/**.h",
                "../Code/encoding/src/**.cpp",
            }
			
            links
            {
                "Core",
                "mimalloc"
            }
            
            filter { "action:gmake*", "language:C++" }
                defines
                {
                    'POSIX',
                    'LINUX',
                    'GNUC',
                    'GNU_COMPILER',
                }
                
                links
                {
                    "stdc++fs",
                    "ssl",
                    "crypto"
                }

            filter ""

    premake.extensions.connect.generate()
    premake.extensions.script.generate()
    premake.extensions.core.generate()
    premake.extensions.discordgamesdk.generate()

    if (os.istarget("Windows") == true) then
        premake.extensions.ui.generate()
        premake.extensions.reverse.generate()
        premake.extensions.hooks.generate()
    end
    
