local config = xmlLoadFile("config.xml")
local host = xmlNodeGetValue(xmlFindChild(config, "host", 0))
local user = xmlNodeGetValue(xmlFindChild(config, "user", 0))
local password = xmlNodeGetValue(xmlFindChild(config, "password", 0))
local database = xmlNodeGetValue(xmlFindChild(config, "database", 0))


addEvent('discord:unauth', true)

function connectToDB()
    local db = dbConnect('mysql', 'dbname=' .. database .. ';host=' .. host .. ';charset=utf8', user, password)

    if not db then 
        outputChatBox("Connection to the database could not be established.", root, 255, 0, 0)
        return false
    else 
        return db
    end
end


addEventHandler('discord:unauth', root, function(serialNumber)
    local db = connectToDB()

    if db then 
        local query = dbQuery(db, 'SELECT * FROM auth WHERE serial_number=? AND is_paired=?', serialNumber, true)
        local result = dbPoll(query, -1)

        if result and #result > 0 then
            local query = dbQuery(db, 'SELECT * FROM auth WHERE serial_number=?', serialNumber)
            local result = dbPoll(query, -1)

            if result and #result > 0 then
                query = dbQuery(db, 'UPDATE auth SET serial_number=?, discord_id=?, auth_code=?, is_paired=?', serialNumber, nil, nil, false)
            else
                query = dbQuery(db, 'INSERT INTO auth (serial_number, discord_id, auth_code, is_paired) VALUES (?, ?, ?, ?)', serialNumber, nil, nil, 0)
            end

            dbFree(query)

            outputChatBox("The pairing has been successfully canceled.", root, 0, 255, 0, true)

            return
        else 
                outputChatBox("No previous pairing has been made.", root, 255, 204, 0, true)
                outputChatBox("To make a pairing, type #00FF00/auth #FF0000", root, 255, 0, 0, true)
        end        
    else
        outputChatBox("Connection to the database could not be established.", root, 255, 0, 0)
    end
end)