local resourceName = GetCurrentResourceName()
local currentLine = "SRVR>UTILS #"

SS_Utils = {
    ComplexDebug = function(resource, table)
        if resource == nil then
            resource = "ss_lib"
        end
        TriggerEvent('ss_lib:server:ComplexDebug', resource, table)
    end,

    VersionCheck = function(resource,repository, paid)
        local currentVersion = GetResourceMetadata(resource, 'version', 0)
        if not currentVersion then
            print("^4Please contact ^0[^5Sky's Scripts^0]^4 for support and reference this error:^0 ".."^3SS_Util.VersionCheck^0, ^1Can't find current resource version for '%s'^0[^3"..resource.."^0]")
            return
        end

        SetTimeout(1000, function()
            PerformHttpRequest(('https://api.github.com/repos/%s/releases/latest'):format(repository), function(status, response)
                if status ~= 200 then
                    if status == 403 or status == 429 then
                        print("[^5Sky's Scripts^0] ^1Update check for ^0[^3"..resource.."^0] ^1failed. ^0[^3Git API Limitations^0]\n^4You may still get this error for a while when restarting the script or server.^0")
                    else
                        print("^4Please contact ^0[^5Sky's Scripts^0]^4 for support and reference this error:^0 ".." [^3SS_Util.VersionCheck^0]\n^1Check repos and current releases for ^0[^3"..resource.."^0] ^4Status code:^0 [^3"..status.."^0]")
                    end
                return end

                response = json.decode(response)
                if response.prerelease then return end

                local latestVersion = response.tag_name:match('%d+%.%d+%.%d+') or response.tag_name:match('%d+%.%d+')
                if not latestVersion then
                    return
                elseif latestVersion == currentVersion then
                    print("[^5Sky's Scripts^0] [^3"..string.upper(string.match(resource, "ss%-(.+)")).."^0] ^2is up to date^0 - ^4Your Version:^0 [^3"..currentVersion.."^0]")
                else
                    local cv = { string.strsplit('.', currentVersion) }
                    local lv = { string.strsplit('.', latestVersion) }

                    local maxParts = math.min(#cv, #lv)
                    for i = 1, maxParts do
                        local current, minimum = tonumber(cv[i] or 0), tonumber(lv[i] or 0)
                        if i == maxParts then
                            if (#cv > i and current == minimum and tonumber(cv[i+1] or 0) > tonumber(lv[i+1] or 0)) or (#cv >= i and current > minimum) then
                                if not paid then
                                    print("[^5Sky's Scripts^0] [^3"..string.upper(string.match(resource, "ss%-(.+)")).."^0] ^4is newer than expected. Your Version:^0 [^3"..currentVersion.."^0] ^4Latest Version:^0 [^3"..latestVersion.."^0]\n^1Please downgrade to latest release through the github or keymaster for ^0[^3"..resource.."^0]\n[^5https://github.com/"..repository.."/releases^0]")
                                elseif paid then
                                    print("[^5Sky's Scripts^0] [^3"..string.upper(string.match(resource, "ss%-(.+)")).."^0] ^4is newer than expected. Your Version:^0 [^3"..currentVersion.."^0] ^4Latest Version:^0 [^3"..latestVersion.."^0]\n^1Please downgrade to latest release for ^0[^3"..resource.."^0] through the keymaster.")
                                end
                            end
                        end
                        if current ~= minimum then
                            if current < minimum then
                                if not paid then
                                    print("[^5Sky's Scripts^0] [^3"..string.upper(string.match(resource, "ss%-(.+)")).."^0] ^4is outdated. Your Version:^0 [^3"..currentVersion.."^0] ^4Latest Version:^0 [^3"..latestVersion.."^0]\n^1Please update ^0[^3"..resource.."^0]^4 through the github or keymaster.^0\n[^5https://github.com/"..repository.."/releases^0]")
                                else
                                    print("[^5Sky's Scripts^0] [^3"..string.upper(string.match(resource, "ss%-(.+)")).."^0] ^4is outdated. Your Version:^0 [^3"..currentVersion.."^0] ^4Latest Version:^0 [^3"..latestVersion.."^0]\n^1Please update ^0[^3"..resource.."^0]^4 through keymaster.^0")
                                end
                            end
                        end
                    end
                end
            end, 'GET')
        end)
    end,

    TableToString = function(tbl, indent)
        indent = indent or ""
        local str = ""
        for k, v in pairs(tbl) do
            if type(v) == "table" then
                str = str..indent..tostring(k).." = {\n"
                str = str..SS_Utils.TableToString(v, indent.."  ")
                str = str..indent.."},\n"
            else
                if type(v) == "string" then
                    if v:sub(1, 4) == "vec4" or v:sub(1, 7) == "vector4" then
                        str = str..indent..tostring(k).." = "..v..",\n"
                    else
                        str = str..indent..tostring(k).." = \""..v.."\",\n"
                    end
                else
                    str = str..indent..tostring(k).." = "..tostring(v)..",\n"
                end
            end
        end
        return str
    end
}

RegisterNetEvent("ss_lib:server:createNewOutput", function(data, fileName)
    local DataAsString = nil
    if not type(data) == ("table" or "string") then
        print("^4Please contact ^0[^5Sky's Scripts^0]^4 for support and reference this ^0[^1EVENT^0]^4 error:^0 [^3ss_lib:server:updateTable^0]\n [^3data variable type isn't table^0]")
        return
    end
    if not type(fileName) == "string" then
        print("^4Please contact ^0[^5Sky's Scripts^0]^4 for support and reference this ^0[^1EVENT^0]^4 error:^0 [^3ss_lib:server:updateTable^0]\n [^3fileName variable type isn't string^0]")
    end
    local path = GetResourcePath(resourceName)
    local file = io.open(path .. "/" .. fileName, "r")
    if not file then
        SS_Log("warn", "^0[^3"..fileName.."^0] ^1not found in current directory.^0", resourceName, false)
        file = io.open(path.."/" .. fileName, "w")
        SS_Log("success", "^2File^0 [^3"..fileName.."^0] ^2created and written to successfully.^0", resourceName, false)
    else
        SS_Log("success", "^2File^0 [^3"..fileName.."^0] ^2already exists.^0", resourceName, false)
    end
    if type(data) == "table" then
        DataAsString = SS_Utils.TableToString(data)
    elseif type(data) == "string" then
        DataAsString = string.format(data, ",")
    end
    file = io.open(path.."/"..fileName, "w")
    file:write(DataAsString)
    file:close()
end)

RegisterServerEvent("ss_lib:server:sendMail", function(data)
    local phoneNumber = exports["lb-phone"]:GetEquippedPhoneNumber(source) -- phonenumber from source

    local playerMail = exports["lb-phone"]:GetEmailAddress(phoneNumber) -- mail from phonenumber
    -- data: table
    -- data.to: string, the email address to send the mail to, or "all" to send to all players
    -- data.sender: string, the email address of the sender
    -- data.subject: string, the subject of the email
    -- data.message: string, the message of the email
    -- data.attachments: table, the attachments of the email (optional)
    -- data.actions: table, buttons to add to the email (optional)
    -- returns: boolean (true if mail was sent, false if mail was not sent) and string (the id of the mail or the error message)
    local success, id = exports["lb-phone"]:SendMail({
        to = playerMail,
        subject = data.subject,
        message = data.message,
        attachments = {
        },
        actions = {
        }
    })
end)

local function TablePrint(tbl, indent)
    indent = indent or 0
    if type(tbl) == 'table' then
        for k, v in pairs(tbl) do
            local tblType = type(v)
            local formatting = ("%s ^3%s:^0"):format(string.rep("  ", indent), k)

            if tblType == "table" then
                print(formatting)
                TablePrint(v, indent + 1)
            elseif tblType == 'boolean' then
                print(("%s^1 %s ^0"):format(formatting, v))
            elseif tblType == "function" then
                print(("%s^9 %s ^0"):format(formatting, v))
            elseif tblType == 'number' then
                print(("%s^2 %s ^0"):format(formatting, v))
            elseif tblType == 'string' then
                print(("%s ^5 '%s' ^0"):format(formatting, v))
            else
                print(("%s^7 %s ^0"):format(formatting, v))
            end
        end
    else
        print(("%s ^0%s"):format(string.rep("  ", indent), tbl))
    end
end

RegisterNetEvent('ss_lib:server:ComplexDebug', function(resource, tbl)
    print(('\x1b[4m\x1b[38;5;160m[ %s : DEBUG]\x1b[0m'):format(string.upper(resource)))
    TablePrint(tbl, 0)
    print(('\x1b[4m\x1b[38;5;79m[ %s : END DEBUG]\x1b[0m'):format(string.upper(resource)))
end)