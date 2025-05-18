--Color information for button text (r,g,b, values of 0-1)
buttonFontColor = {0,0,0}
--Color information for button background
buttonColor = {1,1,1}
--Change scale of button (Avoid changing if possible)
buttonScale = {0.1,0.1,0.1}

disableSave = true

local defaultstate = {

    schemes = {"Assassinate","Breakthrough","ScouttheRooftops","Ensnare","DetonateCharges",
    "FrameJob","TaketheHighground","SearchtheArea","LighttheBeacons","HarnesstheLeyLine",
    "RunicBinding","MakeitLookLikeAnAccident","PublicDemonstration","LeaveYourMark","ReshapeTheLand"},
    strategies = {"Boundary Dispute","Informants","Collapsing Mines","Recover Evidence"},
    deployment = {"Corner","Standard","Wedge","Flank"},
    players = {"Blue","Red"},
    game_setup= true,
    button={
            pos = {0,0.1,-1.0},
            size = 1500,
            label = "Start"
            },
    checkbox={
        {
            pos = {1.0,0.1,0},
            size = 1000,
            state = false
        },
        {
            pos = {1.0,0.1,0.45},
            size = 1000,
            state = false
        },
        {
            pos = {1.0,0.1,0.9},
            size = 1000,
            state = false
        }
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
        --myDeck = getObjectFromGUID("697be6")f4ffc1
        myDeck = getObjectFromGUID("460c2e")
        bmanager = getObjectFromGUID("b1938a")
        rmanager = getObjectFromGUID("47995f")
        createCheckbox()
        createButton()
    end

    function createButton()
        data = state.button
        --Sets up reference function
        local buttonNumber = spawnedButtonCount
        local funcName = "setup"
        local func = function() setup_game() end
        self.setVar(funcName, func)
        
        --Creates button and counts it
        self.createButton({
            label=data.label, click_function=funcName, function_owner=self,
            position=data.pos, height=data.size, width=data.size*3,
            font_size=data.size, scale=buttonScale,
            color=buttonColor, font_color=buttonFontColor
        })
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

    function setup_game()
        math.randomseed(os.time())

        local copy = state.schemes

        for i = #copy, 2, -1 do
            local j = math.random(i)
            copy[i], copy[j] = copy[j], copy[i]
        end

        -- Pick the first 3
        local selected = {copy[1], copy[2], copy[3]}

        local deployment = state.deployment[math.random(4)]
        if state.checkbox[1].state == true then broadcastToAll("Deployment is: "..deployment) end
        
        local strategy = state.strategies[math.random(4)]
        if state.checkbox[2].state == true then broadcastToAll("Strategy is: "..strategy) end

        local attacker = state.players[math.random(2)]
        if state.checkbox[3].state == true then broadcastToAll("Attacker is: "..attacker) end

        bmanager.call("set_startingschemes", {selected})
        rmanager.call("set_startingschemes", {selected})

        deleteSelf()
        
    end

    function deleteSelf()
        Wait.frames(function() destroyObject(self) end, 1)
    end