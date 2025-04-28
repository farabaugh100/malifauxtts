--- Configuration table.
CONSTANTS = {
  zones = {}, -- 
  bgColor = "#00000000", -- string: Panel background color.
  buttonColor = "#ffffff", -- string: Button background color.
  textFontColor = "#ffffff", -- string: Text color.
  buttonFontColor = "#000000", -- string: Button text color.
  fontSize = 75, -- number: Font size.
  spreadDistance = 3,
  playerColor = "Blue"
}
--- Zones configuration table.
CONSTANTS.zones = {
  deckZone = "d27d3c", -- string: GUID of a deck scripting zone.
  discardZone = "06c9e4", -- string: GUID of a discard scripting zone.
  flippingZone = "2c9942", -- string: GUID of a flipping scripting zone.
  conflictZone = "2899ec", -- string: GUID of a conflict scripting zone.
  removedZone = "5c7a15", -- string: GUID of a conflict scripting zone.
  empowermentZone = "ad7f68", -- string: GUID of a empowerment scripting zone.
}

--- Variables table.
-- Do not modify!
VARIABLES = {
  validation = true,
  zones = {},
  flipping = false, -- bool: Set true while flipping.
  number = 0,
  cardsInMotion = 0,
  cardsArrived = 0,
  modifier = 0,
  positionInFlippingZone = Vector({0,0,0}),
  finishedDiscard = false,
  finishedReshuffle = false, 
  finishedRemoved = false,
  stopLogging = false,
  log = "",
  visitingEmpowermentZone = nil,
  visitingDuelZone = nil,
  player = nil
}

--- Zones object table.
VARIABLES.zones = {
}

--- Loads saved data.
-- TTS API Called when an object is loaded or spawned.
-- resets panel.
-- @see onResetAll
function onLoad(_)
  createUI()
  validateZones()
end

--- Validated all zones from constants table.
-- @treturn bool Validation result.
function validateZones()
  VARIABLES.validation = true

  for k, v in pairs(CONSTANTS.zones) do
    local obj = getObjectFromGUID(v)
    if (obj ~= nil) then
      VARIABLES.zones[k] = obj 
      VARIABLES.validation = VARIABLES.validation and true
    else
      VARIABLES.validation = VARIABLES.validation and false
    end
  end
  if VARIABLES.validation == false then
    VARIABLES.log = "| Zones Validation Error! |"
    logAction()
    return validation
  end

  local flippingZonePosition = VARIABLES.zones.flippingZone.getPosition()
  local position = Vector(0,0,0)
  
  position = flippingZonePosition
  position.x = position.x + VARIABLES.zones.flippingZone.getScale().x/2 - 2
  position.z = position.z + VARIABLES.zones.flippingZone.getScale().z/2 - 1.75

  VARIABLES.positionInFlippingZone = position
  return validation
end

--- Creates UI on the panel.
function createUI()
  local scale = self.getScale()  
  local thickness = self.getCustomObject().thickness
  local validation = ""
  local flipSection = {}
  local modifier = ""

  if VARIABLES.validation then
    if VARIABLES.modifier > 0 then
      modifier = "+" .. VARIABLES.modifier
    else
      modifier = VARIABLES.modifier
    end
    local buttonHeight = 200

    flipSection = {
      tag = "VerticalLayout",
      attributes = {
        childForceExpandHeight = "false",
        childForceExpandWidth = "true",
        childAlignment = "MiddleCenter",
      },
      children = {        
        {
          tag = "HorizontalLayout",
          attributes = {
            childForceExpandHeight = "false",
            childForceExpandWidth = "true",
            padding = "0 0 30 0",
            childAlignment = "MiddleCenter",
          },   
          children = {
            {
              tag = "Button",
              attributes = {
                id = "flipButton-3" .. self.getGUID(),
                text = "---",
                onClick = "onFlip",
                fontSize = math.floor(CONSTANTS.fontSize+15),
                fontColor = CONSTANTS.buttonFontColor,
                color = CONSTANTS.buttonColor,
                fontStyle = "bold",
                
                minHeight = buttonHeight,
                --minWidth = 260,
              },
            },
            {
              tag = "Button",
              attributes = {
                id = "flipButton-2" .. self.getGUID(),
                text = "--",
                onClick = "onFlip",
                fontSize = math.floor(CONSTANTS.fontSize+15),
                fontColor = CONSTANTS.buttonFontColor,
                color = CONSTANTS.buttonColor,
                fontStyle = "bold",
                
                minHeight = buttonHeight,
                --minWidth = 260,
              },
            },
            {
              tag = "Button",
              attributes = {
                id = "flipButton-1" .. self.getGUID(),
                text = "-",
                onClick = "onFlip",
                fontSize = math.floor(CONSTANTS.fontSize+15),
                fontColor = CONSTANTS.buttonFontColor,
                color = CONSTANTS.buttonColor,
                fontStyle = "bold",
                
                minHeight = buttonHeight,
                --minWidth = 260,
              },
            },
            {
              tag = "Button",
              attributes = {
                id = "flipButton0" .. self.getGUID(),
                text = "FLIP",
                onClick = "onFlip",
                fontSize = math.floor(CONSTANTS.fontSize+15),
                fontColor = CONSTANTS.buttonFontColor,
                color = CONSTANTS.buttonColor,
                fontStyle = "bold",
                
                minHeight = buttonHeight,
                --minWidth = 520,
              },
            },
            {
              tag = "Button",
              attributes = {
                id = "flipButton1" .. self.getGUID(),
                text = "+",
                onClick = "onFlip",
                fontSize = math.floor(CONSTANTS.fontSize+15),
                fontColor = CONSTANTS.buttonFontColor,
                color = CONSTANTS.buttonColor,
                fontStyle = "bold",
                
                minHeight = buttonHeight,
                --minWidth = 260,
              },
            },
            {
              tag = "Button",
              attributes = {
                id = "flipButton2" .. self.getGUID(),
                text = "++",
                onClick = "onFlip",
                fontSize = math.floor(CONSTANTS.fontSize+15),
                fontColor = CONSTANTS.buttonFontColor,
                color = CONSTANTS.buttonColor,
                fontStyle = "bold",
                
                minHeight = buttonHeight,
                --minWidth = 260,
              },
            },
            {
              tag = "Button",
              attributes = {
                id = "flipButton3" .. self.getGUID(),
                text = "+++",
                onClick = "onFlip",
                fontSize = math.floor(CONSTANTS.fontSize+15),
                fontColor = CONSTANTS.buttonFontColor,
                color = CONSTANTS.buttonColor,
                fontStyle = "bold",
                
                minHeight = buttonHeight,
                --minWidth = 260,
              },
            },          
          },       
        },
        {
          tag = "HorizontalLayout",
          attributes = {
            childForceExpandHeight = "false",
            childForceExpandWidth = "true",
            padding = "0 0 30 0",
            childAlignment = "MiddleCenter",
          },   
          children = {
            {
              tag = "Button",
              attributes = {
                id = "discardButton" .. self.getGUID(),
                text = "DISCARD",
                onClick = "onDiscard",
                fontSize = math.floor(CONSTANTS.fontSize+15),
                fontColor = CONSTANTS.buttonFontColor,
                color = CONSTANTS.buttonColor,
                fontStyle = "bold",
                minHeight = buttonHeight,
                minWidth = 650,
              },
            }, 
            {
              tag = "Button",
              attributes = {
                id = "reshuffleButton" .. self.getGUID(),
                text = "RESHUFFLE",
                onClick = "onReshuffle",
                fontSize = math.floor(CONSTANTS.fontSize+15),
                fontColor = CONSTANTS.buttonFontColor,
                color = CONSTANTS.buttonColor,
                fontStyle = "bold",
                minHeight = buttonHeight,
                minWidth = 650,
              },
            },
            {
              tag = "Button",
              attributes = {
                id = "swapButton" .. self.getGUID(),
                text = "SWAP",
                onClick = "onSwap",
                fontSize = math.floor(CONSTANTS.fontSize+15),
                fontColor = CONSTANTS.buttonFontColor,
                color = CONSTANTS.buttonColor,
                fontStyle = "bold",
                minHeight = buttonHeight,
                minWidth = 650,
              },
            },           
          }       
        },
      },
    }
    
  else 
    validation = "Scripting Zones Error!"
  end

  local panelWidth = 2406
  local scale = Vector(0,0,0)
  scale.x = 0.5/1.94
  scale.z = 0.5/1.94
  -- Set table for xml UI panel
  local ui = {
    {
      tag = "Panel",
      attributes = {
        id = "MainPanel" .. self.getGUID(),
        position = "0 0 " .. -50*thickness-0.5,
        rotation = "0 0 0",
        scale = scale.x .." ".. scale.z .." 1",
        color = "#00000000",
        width = panelWidth,
        height = 744,
        allowDragging = "false",
      }, 
      children = {
        {
          tag = "Panel",
          attributes = {
            rotation = "0 0 0",
            color = CONSTANTS.bgColor,
            width = panelWidth,
            height = 530,
            allowDragging = "false",
            rectAlignment = "UpperCenter",
            childAlignment = "UpperLeft",
          }, 
          children = {
            {
              tag = "VerticalLayout",
              attributes = {
                childForceExpandHeight = "false",
                childAlignment = "UpperCenter",
                padding = "0 0 10 0",
              },
              children = {
                {
                  tag = "Text",
                  attributes = {
                    color = CONSTANTS.textFontColor,
                    fontSize = math.floor(CONSTANTS.fontSize),
                    fontStyle = "bold", 
                    text = validation,
                  },
                },
              },
            },
          },     
        },
        {
          tag = "Panel",
          attributes = {
            rotation = "0 0 0",
            color = CONSTANTS.bgColor,
            width = panelWidth,
            height = 170,
            allowDragging = "false",
            childAlignment = "LowerRight",
            childForceExpandHeight = "false",
            childForceExpandWidth = "false",
            rectAlignment = "LowerCenter",
          }, 
          children = {
            {
              tag = "Button",
              attributes = {
                id = "resetButton" .. self.getGUID(),
                text = "RESET",
                onClick = "onResetCards",
                fontSize = math.floor(CONSTANTS.fontSize),
                fontColor = CONSTANTS.buttonFontColor,
                color = CONSTANTS.buttonColor,
                fontStyle = "bold",
                rectAlignment = "Center",
                height = 100,
                width = 350,
              },
            },
          },
        },
      },
    },
  }

  table.insert(ui[1].children[1].children[1].children,flipSection)
  self.UI.setXmlTable(ui)
end

--- Manage flipping.
function onFlip(player, _, id)
  VARIABLES.player = player
  VARIABLES.modifier = tonumber(id:match("flipButton([+-]?%d+)"..self.getGUID()))
  if VARIABLES.modifier == nil then
    VARIABLES.modifier = 0
  end

  VARIABLES.log = "flipped:"
  onDiscard()
  Wait.condition(
    function()
      VARIABLES.number = math.abs(VARIABLES.modifier) + 1
      local number = VARIABLES.number
      local flippingZone = VARIABLES.zones.flippingZone
      local conflictZone = VARIABLES.zones.conflictZone    
    
      -- Gets all objects in the deck zone. 
      local zoneOccupants = VARIABLES.zones.deckZone.getObjects()
      if zoneOccupants == nil then
        return nil
      end
    
      for i=1, #zoneOccupants, 1 do
        -- Checks if we found a deck, and get top card from it.
        if zoneOccupants[i].type == "Deck" then
          -- Checks if we got enough cards in deck.
          if #zoneOccupants[i].getObjects() >= number then
            startAction()
            VARIABLES.cardsInMotion = number
            local card
            for k=1, number, 1 do
              if number == 1 then
                position = conflictZone.getPosition()
              else
                position = VARIABLES.positionInFlippingZone
              end
              card = zoneOccupants[i].takeObject(
                {
                  position = position,
                  flip = true,
                }
              )
              addCardToLog(card)
              if k == number then
                logAction(player,nil," |")
              end
              if number == 1 then 
                stopAction()
              end

            end
            local arrivedDeck = nil
            Wait.condition(
              function()
                arrivedDeck.setLock(true)
                local arrivedDeckPosition = arrivedDeck.getPosition()
                VARIABLES.cardsInMotion = 0
                VARIABLES.cardsArrived = 0
                local cards = arrivedDeck.getObjects()
                local bj = ""
                local rj = ""
                local joker = false
                local takeTheLowest = false
                for j=1, #cards, 1 do
                  if cards[j].name == "0" then
                    bj = cards[j].guid
                    
                    joker = true
                  elseif cards[j].name == "14" then
                    rj = cards[j].guid
                    joker = true
                  end
                end  
                if bj ~= "" then
                  arrivedDeck.takeObject(
                    {
                      position = VARIABLES.zones.conflictZone.getPosition(),
                      flip = false,
                      guid = bj,
                    }
                  ) 
                elseif rj ~= "" then
                  arrivedDeck.takeObject(
                    {
                      position = VARIABLES.zones.conflictZone.getPosition(),
                      flip = false,
                      guid = rj,
                    }
                  ) 
                end
                cards = arrivedDeck.getObjects() 
                if #cards ~= 0 then
                  if VARIABLES.modifier > 0 then               
                    table.sort(cards, function (a, b) return tonumber(a.name) > tonumber(b.name) end)      
                  else
                    table.sort(cards, function (a, b) return tonumber(a.name) < tonumber(b.name) end)      
                    if cards[1].name ~= cards[2].name and not joker then
                      takeTheLowest = true 
                    end 
                  end 
                  
                  local conflictZonePosition = VARIABLES.zones.conflictZone.getPosition()
                  local cardsCount = #cards
                  local sortedCards = 0
                  for j=1, cardsCount-1, 1 do               
                    arrivedDeckPosition.y = arrivedDeckPosition.y+0.1
                    arrivedDeck.takeObject(
                      {
                        position = arrivedDeckPosition,
                        flip = false,
                        guid = cards[j].guid,
                        callback_function = function(spawned_object)
                          spawned_object.setLock(true)
                          sortedCards = sortedCards + 1
                        end,
                      }
                    )                       
                  end
                  arrivedDeckPosition.y = arrivedDeckPosition.y+0.1
                  getObjectFromGUID(cards[cardsCount].guid).setLock(true)
                  getObjectFromGUID(cards[cardsCount].guid).setPosition(arrivedDeckPosition)
                  sortedCards = sortedCards + 1
                  Wait.condition(
                    function() 
                      if takeTheLowest then
                        getObjectFromGUID(cards[1].guid).setPositionSmooth(conflictZonePosition)
                      end
                      for j=1, cardsCount, 1 do
                        getObjectFromGUID(cards[j].guid).setLock(false)
                      end
                      if takeTheLowest then 
                        cardsCount = cardsCount - 1
                      end
                      local tmpDeck = nil
                      if cardsCount ~= 1 then
                        Wait.condition(
                          function() 
                            tmpDeck.spread(CONSTANTS.spreadDistance)
                            stopAction()
                          end,
                          function()
                            local zoneOccupants = VARIABLES.zones.flippingZone.getObjects()
                            for j=1, #zoneOccupants, 1 do
                              if zoneOccupants[j].type == "Deck" then
                                if (#zoneOccupants[j].getObjects() == cardsCount) then
                                  tmpDeck = zoneOccupants[j]
                                  return true
                                end
                              end
                            end
                            return false          
                          end, 5
                        )   
                      else
                        stopAction()
                      end                     
                    end,
                    function() 
                      if sortedCards == cardsCount then
                        return true
                      else
                        return false
                      end
                    end,
                    5
                  )
                else
                  stopAction()
                end              
              end,
              function()
                local zoneOccupants = VARIABLES.zones.flippingZone.getObjects()    
                for i=1, #zoneOccupants, 1 do
                  -- Checks if we found a deck with appropriate number of cards.
                  if zoneOccupants[i].type == "Deck" then
                     if #zoneOccupants[i].getObjects() == VARIABLES.cardsInMotion then
                      arrivedDeck = zoneOccupants[i]
                      return true
                     end
                  end
                end
                return false
              end,
              5
            )            
            break
          else
            VARIABLES.log = "tried to flip with not enough cards."
            logAction(player)
            return
          end
        -- Checks if we found a single card instead.
        elseif zoneOccupants[i].type == "Card" then
          if number == 1 then
            startAction()
            VARIABLES.cardsInMotion = 1
            addCardToLog(zoneOccupants[i])
            zoneOccupants[i].setPositionSmooth(conflictZone.getPosition())
            local rotation = zoneOccupants[i].getRotation()
            rotation.z = 0
            zoneOccupants[i].setRotationSmooth(rotation)
            logAction(player)
            stopAction()
            break
          else
            VARIABLES.log = "tried to flip with not enough cards."
            logAction(player)
          end
        end
      end
    end,
    function()
      local conflictOccupants = VARIABLES.zones.conflictZone.getObjects()
      local flippingOccupants = VARIABLES.zones.flippingZone.getObjects()

      for i=1, #conflictOccupants, 1 do
        -- Checks if we found a deck, and get top card from it.
        if conflictOccupants[i].type == "Deck"  or conflictOccupants[i].type == "Card" then
          return false
        end
      end

      for i=1, #flippingOccupants, 1 do
        -- Checks if we found a deck, and get top card from it.
        if flippingOccupants[i].type == "Deck"  or flippingOccupants[i].type == "Card" then
          return false
        end
      end
      return true
    end
  )
end

--- Discard cards from the conflict and the flip zone.
function onDiscard(player, _, _)
  startAction()
  VARIABLES.finishedDiscard = false
  local discardPosition = VARIABLES.zones.discardZone.getPosition()
  local discardOccupants = VARIABLES.zones.discardZone.getObjects()
  local conflictOccupants = VARIABLES.zones.conflictZone.getObjects()
  local flippingOccupants = VARIABLES.zones.flippingZone.getObjects()
  local empowermentOccupants = VARIABLES.zones.empowermentZone.getObjects()
  local cardsCount = 0
  local cardUsedInDuelGUID = ""

  for i=1, #discardOccupants, 1 do
    -- Checks if we found a deck or a card
    if discardOccupants[i].type == "Deck" then
      cardsCount = cardsCount + #discardOccupants[i].getObjects()
    end

    if discardOccupants[i].type == "Card" then
      cardsCount = cardsCount + 1
    end
  end

  for i=1, #empowermentOccupants, 1 do
    -- Checks if we found a deck or a card
    if empowermentOccupants[i].type == "Deck" then
      cardsCount = cardsCount + #empowermentOccupants[i].getObjects()
      local rotation = empowermentOccupants[i].getRotation()
      rotation.z = 0
      empowermentOccupants[i].setLock(true)
      empowermentOccupants[i].setRotation(rotation)
      empowermentOccupants[i].setPosition(discardPosition)
    end

    if empowermentOccupants[i].type == "Card" then
      cardsCount = cardsCount + 1
      local rotation = empowermentOccupants[i].getRotation()
      rotation.z = 0
      empowermentOccupants[i].setLock(true)
      empowermentOccupants[i].setRotation(rotation)
      empowermentOccupants[i].setPosition(discardPosition)
    end
  end 

  discardPosition.y = discardPosition.y + 0.5
  for i=1, #conflictOccupants, 1 do
    -- Checks if we found a deck or a card
    if conflictOccupants[i].type == "Deck" then
      local cards = conflictOccupants[i].getObjects()
      local position = discardPosition

      cardsCount = cardsCount + #cards
      cardUsedInDuelGUID = cards[#cards].guid

      for j=1, #cards, 1 do
        conflictOccupants[i].takeObject(
          {
            position = discardPosition,
            top = false,
            smooth = false,
            callback_function = function(spawned_object)
              spawned_object.setLock(true)
              local rotation = spawned_object.getRotation()
              rotation.z = 0
              spawned_object.setRotation(rotation)               
            end,
          }
        )
        discardPosition.y = discardPosition.y + 0.1        
      end
      break
    elseif conflictOccupants[i].type == "Card" then
      cardUsedInDuelGUID = conflictOccupants[i].getGUID() 
      cardsCount = cardsCount + 1
      local rotation = conflictOccupants[i].getRotation()
      rotation.z = 0
      conflictOccupants[i].setLock(true)
      conflictOccupants[i].setRotation(rotation) 
      conflictOccupants[i].setPosition(discardPosition) 
      discardPosition.y = discardPosition.y + 0.1   
    end
  end
  discardPosition.y = discardPosition.y + 0.5
  for i=1, #flippingOccupants, 1 do
    -- Checks if we found a deck or a card
    if flippingOccupants[i].type == "Deck" then
      cardsCount = cardsCount + #flippingOccupants[i].getObjects()
      local rotation = flippingOccupants[i].getRotation()
      rotation.z = 0
      flippingOccupants[i].setLock(true)
      flippingOccupants[i].setRotation(rotation)
      flippingOccupants[i].setPosition(discardPosition)
    end

    if flippingOccupants[i].type == "Card" then
      cardsCount = cardsCount + 1
      local rotation = flippingOccupants[i].getRotation()
      rotation.z = 0
      flippingOccupants[i].setLock(true)
      flippingOccupants[i].setRotation(rotation)
      flippingOccupants[i].setPosition(discardPosition)
    end
  end

  discardPosition.y = discardPosition.y + 0.5
  cardUsedInDuel = getObjectFromGUID(cardUsedInDuelGUID)
  if cardUsedInDuel ~= nil then
    local rotation = cardUsedInDuel.getRotation()
    rotation.z = 0
    cardUsedInDuel.setLock(true)
    cardUsedInDuel.setRotation(rotation)
    cardUsedInDuel.setPosition(discardPosition)
  end
  if cardsCount ~= 0 then
    Wait.condition(
      function()
        local discardOccupants = VARIABLES.zones.discardZone.getObjects()
        for i=1, #discardOccupants, 1 do
          if discardOccupants[i].type == "Deck" or discardOccupants[i].type == "Card" then
            discardOccupants[i].setLock(false) 
          end  
        end 
        Wait.condition(
          function()
            VARIABLES.finishedDiscard = true
            stopAction()
          end,
          function()
            local discardOccupants = VARIABLES.zones.discardZone.getObjects()
            for i=1, #discardOccupants, 1 do
              if discardOccupants[i].type == "Deck" then
                if cardsCount == #discardOccupants[i].getObjects() then
                  return true
                else
                  return false
                end
              elseif discardOccupants[i].type == "Card" then
                if cardsCount == 1 then
                  return true
                else
                  return false
                end  
              end
            end 
            return false           
          end,
          5,function()
            VARIABLES.finishedDiscard = true
            stopAction()
          end
        )
      end,
      function()
        local discardOccupants = VARIABLES.zones.discardZone.getObjects()
        local cardsInDiscard = 0
        for i=1, #discardOccupants, 1 do
          if discardOccupants[i].type == "Deck" then
            
            cardsInDiscard = cardsInDiscard + #discardOccupants[i].getObjects()
            if cardsCount == cardsInDiscard then
              return true
            end
          end
          if discardOccupants[i].type == "Card" then
            cardsInDiscard = cardsInDiscard + 1
            if cardsCount == cardsInDiscard then
              return true
            end
          end
        end
        return false      
      end,
      5,
      function()
        VARIABLES.finishedDiscard = true
        stopAction()
      end
    )
  else 
    VARIABLES.finishedDiscard = true
    stopAction()
  end

end

--- Transfer cards from discard to deck and shuffles them. 
function onReshuffle(player, _, _)
  startAction()
  VARIABLES.log = "performed: Reshuffle"
  VARIABLES.finishedReshuffle = false
  local discardOccupants = VARIABLES.zones.discardZone.getObjects()
  local deckOccupants = VARIABLES.zones.deckZone.getObjects()
  local deckPosition = VARIABLES.zones.deckZone.getPosition() 
  local cardsCount = 0

  for i=1, #discardOccupants, 1 do
    -- Checks if we found a deck or a card
    if discardOccupants[i].type == "Deck" or discardOccupants[i].type == "Card" then
      if discardOccupants[i].type == "Deck" then
        cardsCount = cardsCount + #discardOccupants[i].getObjects()
      else
        cardsCount = cardsCount + 1
      end
      local rotation = discardOccupants[i].getRotation()
      rotation.z = 180
      discardOccupants[i].setRotation(rotation)
      discardOccupants[i].setPosition(deckPosition)
      discardOccupant = discardOccupants[i]
      break
    end
  end 

  for i=1, #deckOccupants, 1 do
    -- Checks if we found a deck or a card
    if deckOccupants[i].type == "Deck" or deckOccupants[i].type == "Card" then
      if deckOccupants[i].type == "Deck" then
        cardsCount = cardsCount + #deckOccupants[i].getObjects()
      else
        cardsCount = cardsCount + 1
      end
      break
    end
  end 

  Wait.condition(
    function()
      local deckOccupants = VARIABLES.zones.deckZone.getObjects()
      for i=1, #deckOccupants, 1 do
        -- Checks if we found a deck
        if deckOccupants[i].type == "Deck" then
          deckOccupants[i].randomize()
        end
      end
      VARIABLES.finishedReshuffle = true
      logAction(player)
      stopAction()
    end,
    function()
      if cardsCount == 0 then
        return true
      else
        local deckOccupants = VARIABLES.zones.deckZone.getObjects()
        for i=1, #deckOccupants, 1 do
          -- Checks if we found a deck or a card
          if deckOccupants[i].type == "Deck" then
            if cardsCount == #deckOccupants[i].getObjects() then              
              return true
            end 
          elseif deckOccupants[i].type == "Card" then
            if cardsCount == 1 then              
              return true
            end
          end
        end
        return false 
      end
      return false
    end,
    5,
    function()
      VARIABLES.finishedReshuffle = true
      logAction(player,nil," wrong")
      stopAction()
    end
  ) 
end

--- Swaps cards between deck and discard.
function onSwap(player, _, _)
  startAction()
  VARIABLES.log = "performed: Swap Deck with Discard"
  local discardOccupants = VARIABLES.zones.discardZone.getObjects()
  local discardPosition = VARIABLES.zones.discardZone.getPosition()
  local deckOccupants = VARIABLES.zones.deckZone.getObjects()
  local deckPosition = VARIABLES.zones.deckZone.getPosition()
  local discardOccupant = nil
  local deckOccupant = nil

  for i=1, #discardOccupants, 1 do
    -- Checks if we found a deck or a card
    if discardOccupants[i].type == "Deck" or discardOccupants[i].type == "Card" then
      discardOccupants[i].setLock(true)
      local rotation = discardOccupants[i].getRotation()
      rotation.z = 180
      discardOccupants[i].setRotationSmooth(rotation)
      discardOccupants[i].setPositionSmooth(deckPosition)
      discardOccupant = discardOccupants[i]     
      break
    end
  end  

  for i=1, #deckOccupants, 1 do
    -- Checks if we found a deck or a card
    if deckOccupants[i].type == "Deck" or deckOccupants[i].type == "Card" then
      deckOccupants[i].setLock(true)
      local rotation = deckOccupants[i].getRotation()
      rotation.z = 0
      deckOccupants[i].setRotationSmooth(rotation)
      deckOccupants[i].setPositionSmooth(discardPosition)
      deckOccupant = deckOccupants[i]
      break
    end
  end 
  
  Wait.condition(
    function()
      if discardOccupant then
        discardOccupant.setLock(false)
      end
      if deckOccupant then
        deckOccupant.setLock(false)
      end
      logAction(player)
      stopAction()
    end,
    function()
      local condition = true
      if discardOccupant ~= nil then
        condition = condition and discardOccupant.resting
      end
      if deckOccupant ~= nil then
        condition = condition and deckOccupant.resting
      end
      return condition
    end,
    5,
    function()
      logAction(player)
      stopAction()
    end
  )  

end

--- Transfer cards from discard to deck and shuffles them. 
function onRemoved(player, _, _)
  startAction()
  VARIABLES.finishedRemoved = false
  local removedOccupants = VARIABLES.zones.removedZone.getObjects()
  local deckOccupants = VARIABLES.zones.deckZone.getObjects()
  local deckPosition = VARIABLES.zones.deckZone.getPosition()
  local cardsCount = 0

  local handOccupants = getPlayer(CONSTANTS.playerColor).getHandObjects()

  for i=1, #handOccupants, 1 do
      cardsCount = cardsCount + 1
      local rotation = handOccupants[i].getRotation()
      rotation.z = 180
      handOccupants[i].setPosition(deckPosition)
      handOccupants[i].setRotation(rotation)      
  end  

  for i=1, #removedOccupants, 1 do
    -- Checks if we found a deck or a card
    if removedOccupants[i].type == "Deck" or removedOccupants[i].type == "Card" then
      if removedOccupants[i].type == "Deck" then
        cardsCount = cardsCount + #removedOccupants[i].getObjects()
      else
        cardsCount = cardsCount + 1
      end
      local rotation = removedOccupants[i].getRotation()
      rotation.z = 180
      removedOccupants[i].setRotation(rotation)
      removedOccupants[i].setPosition(deckPosition)
      break
    end
  end

  if cardsCount ~= 0 then
    for i=1, #deckOccupants, 1 do
      -- Checks if we found a deck or a card
      if deckOccupants[i].type == "Deck" or deckOccupants[i].type == "Card" then
        if deckOccupants[i].type == "Deck" then
          cardsCount = cardsCount + #deckOccupants[i].getObjects()
        else
          cardsCount = cardsCount + 1
        end
        break
      end
    end

    Wait.condition(
      function()
        VARIABLES.finishedRemoved = true
        stopAction()
      end,
      function()
        local deckOccupants = VARIABLES.zones.deckZone.getObjects()
        for i=1, #deckOccupants, 1 do
          -- Checks if we found a deck or a card
          if deckOccupants[i].type == "Deck" then
            if cardsCount == #deckOccupants[i].getObjects() then              
              return true
            end 
          elseif deckOccupants[i].type == "Card" then
            if cardsCount == 1 then              
              return true
            end
          end
        end
        return false          
      end,
      5,
      function()
        VARIABLES.finishedRemoved = true
        stopAction()
      end
    ) 
  else
    VARIABLES.finishedRemoved = true
    stopAction()
  end  
end

--- Gather all the cards in the deck zone and shuffles them.
function onResetCards(player, _, _)
  startAction()
  VARIABLES.stopLogging = true
  onDiscard()
  Wait.condition(
    function()
      onRemoved()
      Wait.condition(
        function()
          onReshuffle()
          Wait.condition(
            function()
              VARIABLES.log = "performed: Reset Deck"
              VARIABLES.stopLogging = false
              logAction(player)
              stopAction()        
            end,
            function()              
              return VARIABLES.finishedReshuffle
            end,
            5,
            function()
              VARIABLES.log = "performed: Reset Deck"
              VARIABLES.stopLogging = false
              logAction(player)
              stopAction()        
            end
          )                    
        end,
        function()
          return VARIABLES.finishedRemoved
        end,
        5,
        function()
          stopAction()        
        end
      )      
    end,
    function()
      return VARIABLES.finishedDiscard
    end,
    5,
    function()
      stopAction()        
    end
  )
end

function startAction()
  self.UI.setAttribute("resetButton" .. self.getGUID(), "color", "#555555")
  self.UI.setAttribute("resetButton" .. self.getGUID(), "onClick", "")

  self.UI.setAttribute("flipButton-3" .. self.getGUID(), "color", "#555555") 
  self.UI.setAttribute("flipButton-3" .. self.getGUID(), "onClick", "")
  self.UI.setAttribute("flipButton-2" .. self.getGUID(), "color", "#555555") 
  self.UI.setAttribute("flipButton-2" .. self.getGUID(), "onClick", "")
  self.UI.setAttribute("flipButton-1" .. self.getGUID(), "color", "#555555") 
  self.UI.setAttribute("flipButton-1" .. self.getGUID(), "onClick", "")
  self.UI.setAttribute("flipButton0" .. self.getGUID(), "color", "#555555") 
  self.UI.setAttribute("flipButton0" .. self.getGUID(), "onClick", "")
  self.UI.setAttribute("flipButton1" .. self.getGUID(), "color", "#555555") 
  self.UI.setAttribute("flipButton1" .. self.getGUID(), "onClick", "")
  self.UI.setAttribute("flipButton2" .. self.getGUID(), "color", "#555555") 
  self.UI.setAttribute("flipButton2" .. self.getGUID(), "onClick", "")
  self.UI.setAttribute("flipButton3" .. self.getGUID(), "color", "#555555") 
  self.UI.setAttribute("flipButton3" .. self.getGUID(), "onClick", "")
  
  self.UI.setAttribute("discardButton" .. self.getGUID(), "color", "#555555") 
  self.UI.setAttribute("discardButton" .. self.getGUID(), "onClick", "")
  self.UI.setAttribute("reshuffleButton" .. self.getGUID(), "color", "#555555") 
  self.UI.setAttribute("reshuffleButton" .. self.getGUID(), "onClick", "")
  self.UI.setAttribute("swapButton" .. self.getGUID(), "color", "#555555") 
  self.UI.setAttribute("swapButton" .. self.getGUID(), "onClick", "")
end

function stopAction()
  self.UI.setAttribute("resetButton" .. self.getGUID(), "color", CONSTANTS.buttonColor)
  self.UI.setAttribute("resetButton" .. self.getGUID(), "onClick", "onResetCards")

  self.UI.setAttribute("flipButton-3" .. self.getGUID(), "color", CONSTANTS.buttonColor) 
  self.UI.setAttribute("flipButton-3" .. self.getGUID(), "onClick", "onFlip")
  self.UI.setAttribute("flipButton-2" .. self.getGUID(), "color", CONSTANTS.buttonColor) 
  self.UI.setAttribute("flipButton-2" .. self.getGUID(), "onClick", "onFlip")
  self.UI.setAttribute("flipButton-1" .. self.getGUID(), "color", CONSTANTS.buttonColor) 
  self.UI.setAttribute("flipButton-1" .. self.getGUID(), "onClick", "onFlip")
  self.UI.setAttribute("flipButton0" .. self.getGUID(), "color", CONSTANTS.buttonColor) 
  self.UI.setAttribute("flipButton0" .. self.getGUID(), "onClick", "onFlip")
  self.UI.setAttribute("flipButton1" .. self.getGUID(), "color", CONSTANTS.buttonColor) 
  self.UI.setAttribute("flipButton1" .. self.getGUID(), "onClick", "onFlip")
  self.UI.setAttribute("flipButton2" .. self.getGUID(), "color", CONSTANTS.buttonColor) 
  self.UI.setAttribute("flipButton2" .. self.getGUID(), "onClick", "onFlip")
  self.UI.setAttribute("flipButton3" .. self.getGUID(), "color", CONSTANTS.buttonColor) 
  self.UI.setAttribute("flipButton3" .. self.getGUID(), "onClick", "onFlip")

  
  self.UI.setAttribute("discardButton" .. self.getGUID(), "color", CONSTANTS.buttonColor) 
  self.UI.setAttribute("discardButton" .. self.getGUID(), "onClick", "onDiscard")  
  self.UI.setAttribute("reshuffleButton" .. self.getGUID(), "color", CONSTANTS.buttonColor) 
  self.UI.setAttribute("reshuffleButton" .. self.getGUID(), "onClick", "onReshuffle")  
  self.UI.setAttribute("swapButton" .. self.getGUID(), "color", CONSTANTS.buttonColor) 
  self.UI.setAttribute("swapButton" .. self.getGUID(), "onClick", "onSwap")  
end

function logAction(player, prefix, suffix)
  if not VARIABLES.stopLogging then
    if prefix then
      VARIABLES.log = prefix .. VARIABLES.log
    end

    if suffix then
      VARIABLES.log = VARIABLES.log .. suffix
    end 

    local color = Color.white
    local name = "Unknown"
    if player then
      name = player.steam_name 
      color = player.color 
    end

    VARIABLES.log = name .. " " .. VARIABLES.log

    printToAll(VARIABLES.log, color)
    VARIABLES.log = ""
  end
end

function addCardToLog(card)
  local name = card.getName() 
  local description = card.getDescription() 

  if name == "0" or name == "14" then
    VARIABLES.log = VARIABLES.log .. " | " .. description 
  else
    VARIABLES.log = VARIABLES.log .. " | " .. name .. " of " .. description .. "s"
  end            
end

function onObjectEnterScriptingZone(zone, object)
  if object.type == "Card" then
    local objectGUID = object.getGUID()
    local objectCopy = object
    if zone == VARIABLES.zones.empowermentZone then
      local player = getPlayer(object.held_by_color)      
      if player == nil then
        player = VARIABLES.player
      end
      if VARIABLES.visitingEmpowermentZone == nil then
        VARIABLES.visitingEmpowermentZone = object

        Wait.condition(
          function()
            local cardStayed = false
            local card
            local zoneOccupants = zone.getObjects()
            for i=1, #zoneOccupants, 1 do
              -- Checks if we found a deck or a card
              if zoneOccupants[i].type == "Deck" then
                local deckOccupants = zoneOccupants[i].getObjects()
                for i=1, #deckOccupants, 1 do
                  if deckOccupants[i].guid == objectGUID then
                    cardStayed = true
                    break
                  end
                end
              elseif zoneOccupants[i].type == "Card" then
                if zoneOccupants[i] == object then              
                  cardStayed = true
                  break
                end
              end
            end
            if cardStayed then
              local value = tonumber(object.getName())
              if value ~= 0 and value <= 5 then
                addCardToLog(objectCopy)
                logAction(player,"empowered a duel with a", " |") 
              else
                logAction(player,"empowered a duel with an illegal card!")
              end
            end
            VARIABLES.visitingEmpowermentZone = nil
          end,
          function()
            return object.isDestroyed() or object.resting
          end,
          5
        )
      end        
    end
    
    if zone == VARIABLES.zones.conflictZone then
      local player = getPlayer(object.held_by_color)      
      if player == nil then
        player = VARIABLES.player
      end
      if VARIABLES.visitingDuelZone == nil then
        VARIABLES.visitingDuelZone = object      
        Wait.condition(
          function()
            local cardStayed = false
            local zoneOccupants = zone.getObjects()
            for i=1, #zoneOccupants, 1 do
              -- Checks if we found a deck or a card
              if zoneOccupants[i].type == "Deck" then
                local deckOccupants = zoneOccupants[i].getObjects()
                for i=1, #deckOccupants, 1 do
                  if deckOccupants[i].guid == objectGUID then
                    cardStayed = true
                    break
                  end
                end
              elseif zoneOccupants[i].type == "Card" then
                if zoneOccupants[i] == object then              
                  cardStayed = true
                  break
                end
              end
            end

            if cardStayed then
              local deckOccupants = zone.getObjects()
              for i=1, #deckOccupants, 1 do
                -- Checks if we found a deck or a card
                if deckOccupants[i].type == "Deck" or deckOccupants[i].type == "Card" and deckOccupants[i] ~= object then
                  addCardToLog(objectCopy)
                  logAction(player,"cheated fate with a", " |")
                  return true          
                end
              end
              addCardToLog(objectCopy)
              logAction(player,"chose a", " | for a duel")              
            end
            VARIABLES.visitingDuelZone = nil 
          end,
          function()
            return object.isDestroyed() or object.resting
          end,
          5
        ) 
      end              
    end
      
  end
end

--- Gets player by color.
function getPlayer(color)
  for _, player in ipairs(Player.getPlayers()) do
    if player.color == color then
      return player
    end
  end
  return nil
end

--- Print table (dev)
function printTable(obj,option)
  if type(obj) ~= 'table' then return obj end
  local res = {}
  for k, v in pairs(obj) do
    if option == "s" then
      print(k..": ",v)
    else
      print(k..": ",printTable(v))
    end
  end
  print("--")
  return res
end