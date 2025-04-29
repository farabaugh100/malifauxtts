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
                "RunicBinding","MakeItLookLikeAnAccident"},
    strategies = {"Boundary Dispute","Informants","Collapsing Mines","Recover Evidence"},
    players = {"Blue","Red"},
    game_setup= true,
    button={
            pos = {0,0.1,-1.8},
            size = 1500,
            label = "Start"
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

        myDeck = getObjectFromGUID("697be6")
        bmanager = getObjectFromGUID("b1938a")
        rmanager = getObjectFromGUID("47995f")
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

    function setup_game()
        math.randomseed(os.time())

        local copy = state.schemes

        for i = #copy, 2, -1 do
            local j = math.random(i)
            copy[i], copy[j] = copy[j], copy[i]
        end

        -- Pick the first 3
        local selected = {copy[1], copy[2], copy[3]}

        local strategy = state.strategies[math.random(3)]

        local attacker = state.players[math.random(2)]

        bmanager.call("set_startingschemes", {selected})
        rmanager.call("set_startingschemes", {selected})

        broadcastToAll("Attacker is: "..attacker)

        cloneCardFromDeck(strategy,"strategy")
        
    end

    function cloneCardFromDeck(cardName, tag)  
        local cards = myDeck.getObjects()
    
        local snapPoints = self.getSnapPoints()
    
        local current_snap = findSnapPointByTag(snapPoints, tag)
    
        for _, card in ipairs(cards) do
            if card.name == cardName then
                local params = {
                    index = card.index,
                    position = getWorldPositionFromSnap(self, current_snap.position),
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