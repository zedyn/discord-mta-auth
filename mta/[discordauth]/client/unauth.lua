panelStatus = false

function unLinkPanel(username, id)
    local screenW, screenH = guiGetScreenSize()
        
    local window = guiCreateWindow((screenW - 461) / 2, (screenH - 457) / 2, 461, 457, "Discord Auth", false)
    guiWindowSetSizable(window, false)

    local label = guiCreateLabel((461 - 283) / 2, (457 - 150) / 2, 283, 124, "To cancel the pairing, click the relevant button!", false, window)
    guiLabelSetHorizontalAlign(label, "center", false)
    guiLabelSetVerticalAlign(label, "center")

    local discordInfoLabel = guiCreateLabel(33, 15, 395, 147, "Discord Account Info \n\nUsername:\n" .. username .. "\n\nID: \n" .. id, false, window)
    guiLabelSetHorizontalAlign(discordInfoLabel, "center", false)
    guiLabelSetVerticalAlign(discordInfoLabel, "center")

    local processButton = guiCreateButton(193, 292, 115, 29, "Unauth", false, window)
    local closeButton = guiCreateButton(193, 344, 115, 29, "Exit", false, window)

    guiSetVisible(window, true)
    showCursor(true)

    function buttonHandler()
        if source == processButton then
            triggerServerEvent('discord:unauth', resourceRoot, getPlayerSerial(localPlayer))
            guiSetVisible(window, false)
            showCursor(false)
            panelStatus = false
            
        end

        if source == closeButton then
            guiSetVisible(window, false)
            showCursor(false)
            panelStatus = false
        end
    end

    addEventHandler("onClientGUIClick", resourceRoot, buttonHandler)
end

addEvent("open:unauthPanel", true)
addEvent("controller", true)

addEventHandler("open:unauthPanel", resourceRoot, function(username, id)
    if not panelStatus then 
        unLinkPanel(username, id)
        panelStatus = true
    end
end)

addEventHandler("controller", resourceRoot, function(id)
    triggerServerEvent('discord:info', resourceRoot, getPlayerSerial(localPlayer), id)
end)

addCommandHandler("unauth", function()
    triggerServerEvent('check:data', resourceRoot, getPlayerSerial(localPlayer))
end)



