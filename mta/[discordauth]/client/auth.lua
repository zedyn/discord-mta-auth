panelStatus = false

function linkPanel(authCode)
    local screenW, screenH = guiGetScreenSize()
        
    local window = guiCreateWindow((screenW - 461) / 2, (screenH - 457) / 2, 461, 457, "Discord Auth", false)
    guiWindowSetSizable(window, false)

    local label = guiCreateLabel((461 - 283) / 2, (457 - 124) / 2, 283, 124, authCode, false, window)
    guiSetFont(label, "sa-header")
    guiLabelSetHorizontalAlign(label, "center", false)  
    guiLabelSetVerticalAlign(label, "center")

    local infoLabel = guiCreateLabel(33, 15, 395, 147, "Send the verification code below as a DM on the Discord bot.", false, window)
    guiLabelSetColor(infoLabel, 254, 254, 254)
    guiLabelSetHorizontalAlign(infoLabel, "center", false)
    guiLabelSetVerticalAlign(infoLabel, "center")

    local closeButton = guiCreateButton(173, 311, 115, 46, "Exit", false, window)

    guiSetVisible(window, true)
    showCursor(true)

    addEventHandler("onClientGUIClick", closeButton, function()
        guiSetVisible(window, false)
        showCursor(false)
        panelStatus = false
    end, false)
end 

addEvent('open:authPanel', true)

addEventHandler('open:authPanel', resourceRoot, function(authCode)
    if not panelStatus then 
        linkPanel(authCode)
        panelStatus = true
    end
end)

addCommandHandler("auth", function()
   triggerServerEvent('data:save', resourceRoot, getPlayerSerial(sourcePlayer), nil, math.random(100000, 999999), false)
end)

