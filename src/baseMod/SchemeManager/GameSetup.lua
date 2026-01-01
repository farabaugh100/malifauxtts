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
    strategies = {"Boundary Dispute","Informants","Plant Explosives","Recover Evidence"},
    deployment = {"Corner","Wedge","Standard","Flank"},
    players = {"Blue","Red"},
    game_setup = true,
    deploy_state = false,
    strategy_selected = 1,
    schemes_selected = {1,2,3},
    deployment_selected = 1,
    start_button={
                pos = {0,0.1,-1.2},
                height = 1400,
                width = 1400*3,
                label = "Start"
            },
    deploy_button={
                pos = {0,0.1,1.45},
                height = 1400,
                width = 1400*5,
                label = "Rotate Deployment"
            },
    hide_deploy={
                pos = {1.25,0.1,1.45},
                height = 1400,
                width = 1400*3,
                label = "Hide/Reveal"
            },
    checkbox={
            {
                pos = {-0.10,0.1,-0.4},
                size = 600,
                state = false
            },
            {
                pos = {-0.10,0.1,-0.05},
                size = 600,
                state = false
            },
            {
                pos = {-0.10,0.1,0.85},
                size = 600,
                state = false
            }     
        },
    toggle_deploy={
            pos = {-1,0.1,1},
            size = 800
        },
    toggle_strat={
            pos = {-1,0.1,-0.25},
            size = 800
        },
    toggle_schemes={
            {
                pos = {-1,0.1,0.15},
                size = 800
            },
            {
                pos = {-1,0.1,0.40},
                size = 800
            },
            {
                pos = {-1,0.1,0.65},
                size = 800
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
        tablet = getObjectFromGUID("239ba9")
        myDeck = getObjectFromGUID("96bc1e")
        bmanager = getObjectFromGUID("b1938a")
        rmanager = getObjectFromGUID("47995f")
        menumanager = getObjectFromGUID("15fc7f")
        boundaryDispute = getObjectFromGUID("f26c14")
        informants = getObjectFromGUID("bdcaa6")
        plantExplosives = getObjectFromGUID("c1d250")
        recoverEvidence = getObjectFromGUID("8e625b")
        tag = "strategy"
        createCheckbox()
        createDeployToggle()
        createStrategyToggle()
        createSchemeToggle()
        createStartButton()
        createDeployButton()
        createHideDeployButton()
    end

    function createStartButton()
        data = state.start_button
        --Sets up reference function
        local funcName = "setup"
        local func = function() setup_game() end
        self.setVar(funcName, func)
        
        --Creates button and counts it
        self.createButton({
            label=data.label, click_function=funcName, function_owner=self,
            position=data.pos, height=data.height, width=data.width,
            font_size=data.height, scale=buttonScale,
            color=buttonColor, font_color=buttonFontColor
        })
    end

    function createDeployButton()
        data = state.deploy_button
        --Sets up reference function
        local funcName = "rotate"
        local func = function() rotate_deploy() end
        self.setVar(funcName, func)
        
        --Creates button and counts it
        self.createButton({
            label=data.label, click_function=funcName, function_owner=self,
            position=data.pos, height=data.height, width=data.width,
            font_size=data.height, scale=buttonScale,
            color=buttonColor, font_color=buttonFontColor
        })
    end
    
    function createHideDeployButton()
        data = state.hide_deploy
        --Sets up reference function
        local funcName = "hide"
        local func = function() hide_deploy() end
        self.setVar(funcName, func)
        
        --Creates button and counts it
        self.createButton({
            label=data.label, click_function=funcName, function_owner=self,
            position=data.pos, height=data.height, width=data.width,
            font_size=data.height, scale=buttonScale,
            color=buttonColor, font_color=buttonFontColor
        })
    end

    function createCheckbox()
        for i, data in pairs(state.checkbox) do 
            --Sets up reference function
            local buttonNumber = spawnedButtonCount
            local funcName = "checkbox"..i
            local func = function() click_checkbox(i, buttonNumber) end
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
            font_size=data.size*0.6, scale=buttonScale,
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
                font_size=data.size*0.6, scale=buttonScale,
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
            font_size=data.size*0.6, scale=buttonScale,
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

    function rotate_deploy()

        menumanager.call("RotateDeployment")
    
    end

    function hide_deploy()
        
        if state.deploy_state == true then
            menumanager.call("ChangeModeDeployment", 0)
            state.deploy_state = false
        else 
            menumanager.call("ChangeModeDeployment", state.deployment_selected)
            state.deploy_state = true
        end

    end

    function setup_game()

        math.randomseed(os.time())

        local selected = nil
        local deployment = nil
        local strategy = nil
        local attacker = state.players[math.random(2)]
        local copy = state.schemes

        --Parse form settings

        if state.checkbox[1].state == true then strategy = state.strategies[math.random(4)] 
        else strategy = state.strategies[state.strategy_selected]
        end

        if state.checkbox[2].state == true then 
            for i = #copy, 2, -1 do
                local j = math.random(i)
                copy[i], copy[j] = copy[j], copy[i]
            end
            selected = {copy[1], copy[2], copy[3]}
        else
            selected = {state.schemes[state.schemes_selected[1]], state.schemes[state.schemes_selected[2]], state.schemes[state.schemes_selected[3]]}
        end

        if state.checkbox[3].state == true then 
            value = math.random(4)
            deployment = state.deployment[value]
            state.deployment_selected = value
        else 
            deployment = state.deployment[state.deployment_selected]
        end

        --Setup Deployment 

        local deployIdx = getIndexOfItem(state.deployment, deployment)
        menumanager.call("ChangeModeDeployment", deployIdx)
        state.deploy_state = true

        --Setup Strategy

        setupStrategy(strategy)
        cloneCardFromDeck(strategy)

        --Setup Schemes

        bmanager.call("set_startingschemes", {selected})
        rmanager.call("set_startingschemes", {selected})

        --Broadcast Game Setup

        broadcastToAll("Deployment is: "..deployment) 
        broadcastToAll("Strategy is: "..strategy)
        broadcastToAll("Attacker is: "..attacker)
    end

    function setupStrategy(strat)

        if strat == "Boundary Dispute" then boundaryDispute.call("setUpStrat")
            elseif strat == "Informants" then informants.call("setUpStrat")
            elseif strat == "Plant Explosives" then plantExplosives.call("setUpStrat")
            elseif strat == "Recover Evidence" then recoverEvidence.call("setUpStrat")
            else print("Strategy "..strat.." not found!")
        end

    end


    function deleteSelf()
        Wait.frames(function() destroyObject(self) end, 1)
    end

    function getIndexOfItem(tbl, item)
        for idx, value in ipairs(tbl) do
            if value == item then
                return idx
            end
        end
        return nil  
    end

    function cloneCardFromDeck(cardName)

        local cards = myDeck.getObjects()
        local snapPoints = tablet.getSnapPoints()
        local current_snap = findSnapPointByTag(snapPoints, tag)

        for _, card in ipairs(cards) do
            if card.name == cardName then
                local params = {
                    index = card.index,
                    position = getWorldPositionFromSnap(tablet, current_snap.position),
                    smooth = false,
                    flip = true
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