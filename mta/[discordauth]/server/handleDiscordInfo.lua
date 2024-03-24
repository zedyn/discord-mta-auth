local config = xmlLoadFile("config.xml")
local host = xmlNodeGetValue(xmlFindChild(config, "host", 0))
local user = xmlNodeGetValue(xmlFindChild(config, "user", 0))
local password = xmlNodeGetValue(xmlFindChild(config, "password", 0))
local database = xmlNodeGetValue(xmlFindChild(config, "database", 0))
local token = xmlNodeGetValue(xmlFindChild(config, "token", 0))

addEvent('discord:info', true)

function connectToDB()
    local db = dbConnect('mysql', 'dbname=' .. database .. ';host=' .. host .. ';charset=utf8', user, password)

    if not db then 
        outputChatBox("Connection to the database could not be established.", root, 255, 0, 0)
        return false
    else 
        return db
    end
end


addEventHandler('discord:info', root, function(serialNumber, id)
    local function onResponse(responseData, errno)
        local db = connectToDB()

        if db then 
            local query = dbQuery(db, 'SELECT * FROM auth WHERE serial_number=? AND is_paired=?', serialNumber, true)
            local result = dbPoll(query, -1)

            if result and #result > 0 then
                local data = fromJSON(responseData)

                if data and data.username then 
                    triggerClientEvent(root, 'open:unauthPanel', root, data.username, id)
                else
                    triggerClientEvent(root, 'open:unauthPanel', root, "undefined", id)
                end

                return
            else 
                outputChatBox("No previous pairing has been made.", root, 255, 204, 0, true)
                outputChatBox("To make a pairing, type #00FF00/auth #FF0000", root, 255, 0, 0, true)
            end        
        else
           outputChatBox("Connection to the database could not be established.", root, 255, 0, 0)
        end        
    end

    local url = "https://discord.com/api/v10/users/" .. id
    
    fetchRemote(url, {headers = {Authorization = "Bot " .. token }}, onResponse)
end)