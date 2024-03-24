local config = xmlLoadFile("config.xml")
local host = xmlNodeGetValue(xmlFindChild(config, "host", 0))
local user = xmlNodeGetValue(xmlFindChild(config, "user", 0))
local password = xmlNodeGetValue(xmlFindChild(config, "password", 0))
local database = xmlNodeGetValue(xmlFindChild(config, "database", 0))

addEvent('check:data', true) 

function connectToDB()
    local db = dbConnect('mysql', 'dbname=' .. database .. ';host=' .. host .. ';charset=utf8', user, password)

    if not db then 
        outputChatBox("Connection to the database could not be established.", root, 255, 0, 0)
        return false
    else 
        return db
    end
end

addEventHandler('check:data', root, function(serialNumber) 
    local db = connectToDB()

    if db then 
        local query = dbQuery(db, 'SELECT * FROM auth WHERE serial_number=? AND is_paired=?', serialNumber, true)
        local result = dbPoll(query, -1)

        if result and #result > 0 then
            triggerClientEvent(root, 'controller', root, result[1].discord_id)
            return
        else 
            outputChatBox("No previous pairing has been made.", root, 255, 204, 0, true)
            outputChatBox("To make a pairing, type #00FF00/auth #FF0000", root, 255, 0, 0, true)
        end        
    else
        outputChatBox("Connection to the database could not be established.", root, 255, 0, 0)
    end
end)

addEventHandler('onResourceStart', resourceRoot, function()
    local db = connectToDB()

    if db then 
        dbExec(db, 'CREATE TABLE IF NOT EXISTS auth (serial_number VARCHAR(255), discord_id VARCHAR(255), auth_code INT, is_paired TINYINT(1), paired_at BIGINT(255))')
    else 
        print("Connection to the database could not be established.")
    end
end)