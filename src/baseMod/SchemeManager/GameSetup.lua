--Color information for button text (r,g,b, values of 0-1)
buttonFontColor = {0,0,0}
--Color information for button background
buttonColor = {1,1,1}
--Change scale of button (Avoid changing if possible)
buttonScale = {0.1,0.1,0.1}

disableSave = true

local defaultstate = {

    scheme_names = {"Assassinate","Breakthrough","Scout the Rooftops","Ensnare","Detonate Charges",
    "Frame Job","Take the Highground","Search the Area","Light the Beacons","Harness the LeyLine",
    "Runic Binding","Make it Look Like An Accident","Public Demonstration","Leave Your Mark","Reshape the Land"},
    schemes = {"Assassinate","Breakthrough","ScouttheRooftops","Ensnare","DetonateCharges",
    "FrameJob","TaketheHighground","SearchtheArea","LighttheBeacons","HarnesstheLeyLine",
    "RunicBinding","MakeitLookLikeAnAccident","PublicDemonstration","LeaveYourMark","ReshapeTheLand"},
    strategies = {"Boundary Dispute","Informants","Collapsing Mines","Recover Evidence"},
    deployment = {"Corner","Standard","Wedge","Flank"},
    players = {"Blue","Red"},
    game_setup= true,
    strategy_selected = 1,
    schemes_selected = {1,2,3},
    deployment_selected = 1,
    button={
            pos = {0,0.1,-1.5},
            size = 1400,
            label = "Start"
        },
    checkbox={
            pos = {0.92,0.1,-1},
            size = 1000,
            state = false
        },
    toggle_deploy={
            pos = {0,0.1,1.45},
            size = 1400
        },
    toggle_strat={
            pos = {0,0.1,-0.05},
            size = 1400
        },
    toggle_schemes={
            {
                pos = {0,0.1,0.45},
                size = 1400
            },
            {
                pos = {0,0.1,0.70},
                size = 1400
            },
            {
                pos = {0,0.1,0.95},
                size = 1400
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
        myDeck = getObjectFromGUID("bb6c9e")
        bmanager = getObjectFromGUID("b1938a")
        rmanager = getObjectFromGUID("47995f")
        createCheckbox()
        createButton()
        createDeployToggle()
        createStrategyToggle()
        createSchemeToggle()
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
        spawnedButtonCount = spawnedButtonCount + 1
    end

    function createCheckbox()
        data = state.checkbox 
        --Sets up reference function
        local buttonNumber = spawnedButtonCount
        local funcName = "checkbox"
        local func = function() click_checkbox(buttonNumber) end
        self.setVar(funcName, func)
        --Sets up labels
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

    function click_checkbox(buttonIndex)
        if state.checkbox.state == true then
            state.checkbox.state = false
            self.editButton({index=buttonIndex, label=""})
        else
            state.checkbox.state = true
            self.editButton({index=buttonIndex, label=string.char(10008)})
        end
        updateSave()
    end

    function createStrategyToggle()
        data = state.toggle_strat
        --Sets up reference function
        local buttonNumber = spawnedButtonCount
        local funcName = "toggle_strat"
        local func = function() toggle_strategy(buttonNumber) end
        self.setVar(funcName, func)
        --Sets up label
        local label = state.strategies[state.strategy_selected]
        --Creates button and counts it
        self.createButton({
            label=label, click_function=funcName, function_owner=self,
            position=data.pos, height=data.size, width=data.size*7,
            font_size=data.size, scale=buttonScale,
            color=buttonColor, font_color=buttonFontColor
        })
        spawnedButtonCount = spawnedButtonCount + 1
    end

    function toggle_strategy(buttonIndex)
        local index = state.strategy_selected + 1
        if index > # (state.strategies) then state.strategy_selected = 1
        else state.strategy_selected = index end

        self.editButton({index=buttonIndex, label=state.strategies[state.strategy_selected]})
        updateSave()
    end

    function createSchemeToggle()
        for i, data in pairs(state.toggle_schemes) do
             --Sets up reference function
            local buttonNumber = spawnedButtonCount
            local funcName = "toggle"..i
            local func = function() toggle_scheme(i, buttonNumber) end
            self.setVar(funcName, func)
            --Sets up label
            local label = state.scheme_names[state.schemes_selected[i]]
            --Creates button and counts it
            self.createButton({
                label=label, click_function=funcName, function_owner=self,
                position=data.pos, height=data.size, width=data.size*7,
                font_size=data.size, scale=buttonScale,
                color=buttonColor, font_color=buttonFontColor
            })
            spawnedButtonCount = spawnedButtonCount + 1
        end
    end

    function toggle_scheme(table_index, buttonIndex)
        local index = state.schemes_selected[table_index]  + 1
        if index > # (state.scheme_names) then state.schemes_selected[table_index]  = 1
        else state.schemes_selected[table_index]  = index end
        
        self.editButton({index=buttonIndex, label=state.scheme_names[state.schemes_selected[table_index]]})
        updateSave()
    end

    function createDeployToggle()
        data = state.toggle_deploy
        --Sets up reference function
        local buttonNumber = spawnedButtonCount
        local funcName = "toggle_de"
        local func = function() toggle_deploy(buttonNumber) end
        self.setVar(funcName, func)
        --Sets up label
        local label = state.deployment[state.deployment_selected]
        --Creates button and counts it
        self.createButton({
            label=label, click_function=funcName, function_owner=self,
            position=data.pos, height=data.size, width=data.size*7,
            font_size=data.size, scale=buttonScale,
            color=buttonColor, font_color=buttonFontColor
        })
        spawnedButtonCount = spawnedButtonCount + 1
    end

    function toggle_deploy(buttonIndex)
        local index = state.deployment_selected + 1
        if index > # (state.deployment) then state.deployment_selected = 1
        else state.deployment_selected = index end

        self.editButton({index=buttonIndex, label=state.deployment[state.deployment_selected]})
        updateSave()
    end

    function setup_game()

        if state.checkbox.state == true then

            math.randomseed(os.time())

            local copy = state.schemes

            for i = #copy, 2, -1 do
                local j = math.random(i)
                copy[i], copy[j] = copy[j], copy[i]
            end

            -- Pick the first 3
            local selected = {copy[1], copy[2], copy[3]}

            local deployment = state.deployment[math.random(4)]
            broadcastToAll("Deployment is: "..deployment) 
            
            local strategy = state.strategies[math.random(4)]
            broadcastToAll("Strategy is: "..strategy) 

            local attacker = state.players[math.random(2)]
            broadcastToAll("Attacker is: "..attacker)

            bmanager.call("set_startingschemes", {selected})
            rmanager.call("set_startingschemes", {selected})

        else 

            local selected = {state.schemes[state.schemes_selected[1]], state.schemes[state.schemes_selected[2]], state.schemes[state.schemes_selected[3]]}
            
            local deployment = state.deployment[state.deployment_selected]
            broadcastToAll("Deployment is: "..deployment) 

            local strategy = state.strategies[state.strategy_selected]
            broadcastToAll("Strategy is: "..strategy)

            local attacker = state.players[math.random(2)]
            broadcastToAll("Attacker is: "..attacker)

            bmanager.call("set_startingschemes", {selected})
            rmanager.call("set_startingschemes", {selected})
        end
    end

    function deleteSelf()
        Wait.frames(function() destroyObject(self) end, 1)
    end