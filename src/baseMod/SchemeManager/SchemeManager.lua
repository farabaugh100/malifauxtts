schemes = {"Assassinate","Breakthrough","ScouttheRooftops","Ensnare","DetonateCharges",
"FrameJob","TaketheHighground","SearchtheArea","LighttheBeacons","HarnesstheLeyLine",
"RunicBinding","MakeitLookLikeAnAccident","PublicDemonstration","LeaveYourMark","ReshapeTheLand"}

--Color information for button text (r,g,b, values of 0-1)
buttonFontColor = {0,0,0}
--Color information for button background
buttonColor = {1,1,1}
--Change scale of button (Avoid changing if possible)
buttonScale = {0.1,0.1,0.1}

disableSave = false
local objLib={
    blueSchemeDeck="b4060e",
    blueSchemeManager="b1938a",
    blueSchemePanel="420546",
    blueSchemeReveal="61fe0d",
    blueSchemeTracker="a1873a",
    blueOptionsTag="b_option",
    blueRevealTag="b_reveal",
    redSchemeDeck="43c0dd",
    redSchemeManager="47995f",
    redSchemePanel="725c42",
    redSchemeReveal="e2578a",
    redSchemeTracker="a687eb",
    redOptionsTag="r_option",
    redRevealTag="r_reveal",
}
local defaultstate = {
    schemes={Assassinate={"ScouttheRooftops","DetonateCharges","RunicBinding"},
            Breakthrough={"Assassinate","PublicDemonstration","FrameJob"},
            ScouttheRooftops={"DetonateCharges","LighttheBeacons","LeaveYourMark"},
            Ensnare={"ReshapeTheLand","SearchtheArea","FrameJob"},
            DetonateCharges={"LighttheBeacons","RunicBinding","TaketheHighground"},        
            FrameJob={"PublicDemonstration","HarnesstheLeyLine","ScouttheRooftops"},            
            TaketheHighground={"MakeitLookLikeAnAccident","Ensnare","SearchtheArea"},            
            SearchtheArea={"Breakthrough","FrameJob","HarnesstheLeyLine"},            
            LighttheBeacons={"RunicBinding","LeaveYourMark","MakeitLookLikeAnAccident"},
            HarnesstheLeyLine={"Assassinate","ScouttheRooftops","LighttheBeacons"},
            RunicBinding={"LeaveYourMark","TaketheHighground","Ensnare"},
            MakeitLookLikeAnAccident={"Ensnare","ReshapeTheLand","Breakthrough"},
            PublicDemonstration={"HarnesstheLeyLine","Assassinate","DetonateCharges"},
            LeaveYourMark={"TaketheHighground","MakeitLookLikeAnAccident","ReshapeTheLand"},
            ReshapeTheLand={"SearchtheArea","Breakthrough","PublicDemonstration"},
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
        },
    reveal={
            pos = {1,0.1,0.1},
            size = 1500,
            label = "Reveal"
        }
    
}

local myDeck
local tracker
local tablet
local reveal
local optionTag
local revealTag
local thisColor
--Save function
function updateSave()
    saved_data = JSON.encode(state)
    if disableSave==true then saved_data="" end
    self.script_state = saved_data
end

--Startup procedure
function onload(saved_data)
    local selfName=self.getName()
    if disableSave==true then saved_data="" end
    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        state = loaded_data
    else
        state = defaultstate
    end

    spawnedButtonCount = 0
    if string.find(selfName, "Red") then
        myDeck = getObjectFromGUID(objLib.redSchemeDeck)
        tracker = getObjectFromGUID(objLib.redSchemeTracker)
        tablet = getObjectFromGUID(objLib.redSchemePanel)
        reveal = getObjectFromGUID(objLib.redSchemeReveal)
        optionTag=objLib.redOptionsTag
        revealTag=objLib.redRevealTag
        thisColor="red"
    elseif string.find(selfName, "Blue") then
        myDeck = getObjectFromGUID(objLib.blueSchemeDeck)
        tracker = getObjectFromGUID(objLib.blueSchemeTracker)
        tablet = getObjectFromGUID(objLib.blueSchemePanel)
        reveal = getObjectFromGUID(objLib.blueSchemeReveal)
        optionTag=objLib.blueOptionsTag
        revealTag=objLib.blueRevealTag
        thisColor="blue"
    end
    createButtons()
    createCheckbox()
    createTextbox()
    createReveal()
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

function createReveal()
    local data = state.reveal
    --Sets up reference function
    local funcName = "reveal"..1
    local func = function() click_reveal() end
    self.setVar(funcName, func)
    
    --Creates button and counts it
    self.createButton({
        label=data.label, click_function=funcName, function_owner=self,
        position=data.pos, height=data.size, width=data.size*3,
        font_size=data.size, scale=buttonScale,
        color=buttonColor, font_color=buttonFontColor
    })
end

function click_reveal()
    local score = 0

    if state.checkbox[1].state == true then score = score+1 end
    if state.checkbox[2].state == true then score = score+1 end

    cloneCardFromDeck(state.currentscheme, revealTag)

    if(state.textbox.value != "") then 
        broadcastToAll("Hidden Info: "..state.textbox.value, {31,136,255,255})
    end

    updateScore(score)
    updateSave()
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
        cloneCardFromDeck(scheme, optionTag..i)
    end

end

function click_scheme(buttonIndex)
    
    --log("Button: "..buttonIndex)
    --log(state.currentoptions)
    local new_scheme = state.currentoptions[buttonIndex]

    --log("Card: "..new_scheme)

    cloneCardFromDeck(new_scheme, "current_"..thisColor)

    state.currentoptions = state.schemes[new_scheme]

    for i, scheme in ipairs(state.currentoptions) do
        cloneCardFromDeck(scheme, optionTag..i)
    end

    state.currentscheme = new_scheme

    updateSave()
end


function updateScore(value)

    for i=1,value,1 do tracker.call("add_subtract", {obj, thisColor, false}) end

end

function cloneCardFromDeck(cardName, tag)
    
    local cards = myDeck.getObjects()
    local target = tablet
    
    if tag == revealTag then target = reveal end

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
    print("Card "..cardName.." not found in deck!")
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