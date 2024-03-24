local config = xmlLoadFile("config.xml")
local host = xmlNodeGetValue(xmlFindChild(config, "host", 0))
local user = xmlNodeGetValue(xmlFindChild(config, "user", 0))
local password = xmlNodeGetValue(xmlFindChild(config, "password", 0))
local database = xmlNodeGetValue(xmlFindChild(config, "database", 0))
local token = xmlNodeGetValue(xmlFindChild(config, "token", 0))

addEvent('data:save', true)

function connectToDB()
    local db = dbConnect('mysql', 'dbname=' .. database .. ';host=' .. host .. ';charset=utf8', user, password)

    if not db then 
        outputChatBox("Connection to the database could not be established.", root, 255, 0, 0)
        return false
    else 
        return db
    end
end

addEventHandler('data:save', root, function(serialNumber, discordId, authCode, isPaired)
    local db = connectToDB()

    if db then 
        local query = dbQuery(db, 'SELECT * FROM auth WHERE serial_number=? AND is_paired=?', serialNumber, true)
        local result = dbPoll(query, -1)

        if result and #result > 0 then
            local function onResponse(responseData, errno)
                local data = fromJSON(responseData)

                if data and data.username then 
                    outputChatBox("Matching has been previously done with the #FFFFFF" .. data.username .. " #FFCC00account.", root, 255, 204, 0, true)
                else
                    outputChatBox("Matching has been previously done with the #FFFFFF" .. result[1].discord_id .. " #FFCC00account.", root, 255, 204, 0, true)
                end
            end

            local url = "https://discord.com/api/v10/users/" .. result[1].discord_id
    
            fetchRemote(url, {headers = {Authorization = "Bot " .. token }}, onResponse)
            
            outputChatBox("To unauth the pairing, type #00FF00/unauth #FF0000", root, 255, 0, 0, true)
            return
        else 
            local query = dbQuery(db, 'SELECT * FROM auth WHERE serial_number=?', serialNumber)
            local result = dbPoll(query, -1)

            if result and #result > 0 then
                query = dbQuery(db, 'UPDATE auth SET serial_number=?, discord_id=?, auth_code=?, is_paired=?', serialNumber, discordId, authCode, isPaired)
            else
                query = dbQuery(db, 'INSERT INTO auth (serial_number, discord_id, auth_code, is_paired) VALUES (?, ?, ?, ?)', serialNumber, discordId, authCode, isPaired)
            end

            dbFree(query)

            triggerClientEvent(root, 'open:authPanel', root, authCode)
        end        
    else
        outputChatBox("Connection to the database could not be established.", root, 255, 0, 0)
    end
end)