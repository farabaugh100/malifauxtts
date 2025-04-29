schemes = {"Assassinate","Breakthrough","ScouttheRooftops","Ensnare","DetonateCharges",
"FrameJob","TaketheHighground","SearchtheArea","LighttheBeacons","HarnesstheLeyLine",
"RunicBinding","MakeItLookLikeAnAccident"}

--Color information for button text (r,g,b, values of 0-1)
buttonFontColor = {0,0,0}
--Color information for button background
buttonColor = {1,1,1}
--Change scale of button (Avoid changing if possible)
buttonScale = {0.1,0.1,0.1}

disableSave = true

local defaultstate = {
    schemes={Assassinate={"HarnesstheLeyLine","RunicBinding","FrameJob"},
            Breakthrough={"Ensnare","LighttheBeacons","TaketheHighground"},
            ScouttheRooftops={"LighttheBeacons","Assassinate","Breakthrough"},
            Ensnare={"MakeItLookLikeAnAccident","ScouttheRooftops","FrameJob"},
            DetonateCharges={"Breakthrough","Ensnare","MakeItLookLikeAnAccident"},
            FrameJob={"SearchtheArea","DetonateCharges","HarnesstheLeyLine"},
            TaketheHighground={"SearchtheArea","Assassinate","FrameJob"},
            SearchtheArea={"DetonateCharges","Breakthrough","RunicBinding"},
            LighttheBeacons={"Assassinate","HarnesstheLeyLine","Ensnare"},
            HarnesstheLeyLine={"RunicBinding","MakeItLookLikeAnAccident","TaketheHighground"},
            RunicBinding={"ScouttheRooftops","LighttheBeacons","DetonateCharges"},
            MakeItLookLikeAnAccident={"TaketheHighground","ScouttheRooftops","SearchtheArea"}
        },
    currentscheme= "",
    currentoptions= {},
    startingschemes= {},
    buttons={
            {
                pos = {-1,0.1,-0.9},
                size = 1500,
                label = "Option 1"
            },
            {
                pos = {-1,0.1,-0.4},
                size = 1500,
                label = "Option 2"
            },
            {
                pos = {-1,0.1,0.1},
                size = 1500,
                label = "Option 3"
            }
        },
    checkbox={
            {
                pos = {1.5,0.1,-0.85},
                size = 1000,
                state = false
            },
            {
                pos = {1.5,0.1,-0.3},
                size = 1000,
                state = false
            }
        },
    textbox={
            pos       = {0,0.1,0.75},
            width     = 1100,
            height    = 200,
            font_size = 120,
            alignment = 3,
            label     = "Hidden Information",
            value     = "",
            color     = {1,1,1,0},
            font_color = {0,0,0,255}
        }
    
}


--Save function
function updateSave()
    saved_data = JSON.encode(state)
    if disableSave==true then saved_data="" end
    self.script_state = saved_data
end

--Startup procedure
function onload(saved_data)
    if disableSave==true then saved_data="" end
    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        state = loaded_data
    else
        state = defaultstate
    end

    spawnedButtonCount = 0
    myDeck = getObjectFromGUID("a1a893")
    tracker = getObjectFromGUID("a687eb")
    tablet = getObjectFromGUID("725c42")
    reveal = getObjectFromGUID("e2578a")
    createButtons()
    createCheckbox()
    createTextbox()
end

function createButtons()
    for i, data in ipairs(state.buttons) do
        --Sets up reference function
        local buttonNumber = spawnedButtonCount
        local funcName = "scheme"..i
        local func = function() click_scheme(i) end
        self.setVar(funcName, func)
        
        --Creates button and counts it
        self.createButton({
            label=data.label, click_function=funcName, function_owner=self,
            position=data.pos, height=data.size, width=data.size*3,
            font_size=data.size, scale=buttonScale,
            color=buttonColor, font_color=buttonFontColor
        })
        spawnedButtonCount = spawnedButtonCount + 1
    end
end

function createCheckbox()
    for i, data in ipairs(state.checkbox) do
        --Sets up reference function
        local buttonNumber = spawnedButtonCount
        local funcName = "checkbox"..i
        local func = function() click_checkbox(i, buttonNumber) end
        self.setVar(funcName, func)
        --Sets up label
        local label = ""
        if data.state==true then label=string.char(10008) end
        --Creates button and counts it
        self.createButton({
            label=label, click_function=funcName, function_owner=self,
            position=data.pos, height=data.size, width=data.size,
            font_size=data.size, scale=buttonScale,
            color=buttonColor, font_color=buttonFontColor
        })
        spawnedButtonCount = spawnedButtonCount + 1
    end
end

function createTextbox()
    data = state.textbox
    --Sets up reference function
    local funcName = "textbox"..1
    local func = function(_,_,val,sel) click_textbox(val,sel) end
    self.setVar(funcName, func)

    self.createInput({
        input_function = funcName,
        function_owner = self,
        alignment      = data.alignment,
        label          = data.label,
        position       = data.pos,
        width          = data.width,
        height         = data.height,
        font_size      = data.font_size,
        font_color     = data.font_color,
        color          = data.color,  
        value          = data.value,
    })
end

function click_textbox(value, selected)
    if selected == false then
        state.textbox.value = value
        updateSave()
    end
end

function click_checkbox(tableIndex, buttonIndex)
    if state.checkbox[tableIndex].state == true then
        state.checkbox[tableIndex].state = false
        self.editButton({index=buttonIndex, label=""})
    else
        state.checkbox[tableIndex].state = true
        self.editButton({index=buttonIndex, label=string.char(10008)})
    end
    updateSave()
end

function set_startingschemes(schemes)

    state.currentoptions = schemes[1]

    for i, scheme in ipairs(state.currentoptions) do
        cloneCardFromDeck(scheme, "r_option"..i)
    end

end

function click_scheme(buttonIndex)

    local score = 0

    if state.checkbox[1].state == true then score = score+1 end
    if state.checkbox[2].state == true then score = score+1 end
    
    log("Button: "..buttonIndex)
    log(state.currentoptions)
    local new_scheme = state.currentoptions[buttonIndex]

    log("Card: "..new_scheme)

    cloneCardFromDeck(new_scheme, "current_red")

    state.currentoptions = state.schemes[new_scheme]

    for i, scheme in ipairs(state.currentoptions) do
        cloneCardFromDeck(scheme, "r_option"..i)
    end

    if state.currentscheme == "" then
        state.currentscheme = new_scheme
    else
        cloneCardFromDeck(state.currentscheme, "r_reveal")
        state.currentscheme = new_scheme
    end

    if(state.textbox.value != "") then 
        broadcastToAll("Hidden Info: "..state.textbox.value, {31,136,255,255})
    end

    updateScore(score)
    updateSave()
end


function updateScore(value)

    log("Value: "..value)

    for i=1,value,1 do tracker.call("add_subtract", {obj, "Red", false}) end

end

function cloneCardFromDeck(cardName, tag)  
    local cards = myDeck.getObjects()
    local target = tablet
    
    if tag == "r_reveal" then target = reveal end

    local snapPoints = target.getSnapPoints()

    local current_snap = findSnapPointByTag(snapPoints, tag)

    for _, card in ipairs(cards) do
        if card.name == cardName then
            local params = {
                index = card.index,
                position = getWorldPositionFromSnap(target, current_snap.position),
                smooth = false,
                callback_function = function(pulledCard)
                    if pulledCard then
                        local cloneParams = {
                            position = pulledCard.getPosition() + Vector(0, 2, 0),
                            rotation = pulledCard.getRotation()
                        }
                        local clone = pulledCard.clone(cloneParams)
                        myDeck.putObject(pulledCard)
                    else
                        print("Error: Failed to pull card.")
                    end
                end
            }
            myDeck.takeObject(params)
            return
        end
    end
    print("Card not found in deck!")
end

function findSnapPointByTag(snapPoints, tag)
    for _, snap in ipairs(snapPoints) do
        if snap.tags then
            for _, snapTag in ipairs(snap.tags) do
                if snapTag == tag then
                    return snap
                end
            end
        end
    end
    return nil
end

function getWorldPositionFromSnap(snapObject, snapPoint)
    local worldPos = snapObject.positionToWorld(snapPoint)
    return worldPos
end