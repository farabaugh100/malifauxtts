

local mini = nil
local config={}
local faction;
local cardFrontImage;
local cardBackImage;
local name;
local playerColor='green';
local factionColor= Color(.70,0.19,.17);
local config={}
local cloneTo ={ 11.388285, 0.96, -12.243199 }
function onLoad(save)
    --self.script_state=onSave()
    local data = JSON.decode(save)
    if data ~=nil then
        config=data
    end
    
end
function onSave()
    
    return JSON.encode(config)
end

function hello_world()
    log("Hello World")
end

function createRefrenceCard(params)
    config=params
    name = params["name"]
    playerColor =params["playerColor"]
    faction = params["faction"]
    cardFrontImage = params["cardFrontImage"]
    cardBackImage = params["cardBackImage"]
    factionColor=factionColorLookup(faction)
    self.script_state=JSON.encode(config)
    rebuildUI()
    self.setName(name)
    self.reload()
end

function fetched(color)
    config=JSON.decode(self.script_state)
    
    if config~=nil then
        if config["type"]=="crewCard" then
            local slot=1
            if config.tokens~="" then
                slot=fetchTokens("Adaptable,Focused,Shielded",color,slot)
                slot=fetchTokens(config.tokens,color,slot)
            end
            if config.markers~="" then
                slot=fetchMarkers(config.markers,color,slot)
            end
        end
    end
end
function fetchTokens(tokens,color,slot)
    local tokenSlot=slot
    local firstTokenPosition
    local bag=getObjectFromGUID("3ea749")
    for key,value in pairs(mySplit(tokens,",")) do
        if loopThroughBag(bag,firstToUpper(value),tokenSlot,color) then
            tokenSlot=tokenSlot+1
        end
    end
    return tokenSlot
end
function fetchMarkers(markers,color,slot)
    local markerSlot=slot
    local firstTokenPosition
    local bag=getObjectFromGUID("7abb2f")
    for key,value in pairs(mySplit(markers,",")) do
        if loopThroughBag(bag,firstToUpper(value),markerSlot,color) then
            markerSlot=markerSlot+1
        end
    end
end
function loopThroughBag(haystack,needle,tokenSlot,color)
    local found=false
    for key,containedObject in pairs(haystack.getObjects()) do
        if containedObject.name ==needle then
            found=true
            haystack.takeObject({
                index = containedObject.index,
                position = getTokenSlotPosition(tokenSlot,color),
                rotation = getSlotRotation(color),
                callback_function = function(spawnedObject)
                    spawnedObject.reload()
                    local pos=haystack.getPosition()
                    spawnedObject.clone({position={pos.x,5,pos.z},rotation={x=0,y=180,z=0}})
                end,
            })
            break
        end
    end
    return found
end
local basePositionBlue={x=-38.00, y=0.83,z= 11}
local basePositionRed={x=38.00, y=0.83,z= -11}
function getTokenSlotPosition(tokenSlot,color)
    local targetPos = tokenSlot

    if color == 'Red' then
        
        return Vector( basePositionRed.x,basePositionRed.y  ,basePositionRed.z + ((targetPos) * ( 1.5)))
    end
    if color == 'Blue' then
        return Vector( basePositionBlue.x,basePositionBlue.y  ,basePositionBlue.z + ((targetPos) * ( -1.5)))
    end
end
function getSlotRotation(color)
    if color == 'Red' then
        return {x=0,y=180,z=0}
    end
    if color == 'Blue' then
        return {x=0,y=0,z=0}
    end
end
function factionColorLookup(faction)
    if faction=="Guild" then
        return Color(.70,0.19,.17)
    elseif faction=="Outcast" then
        return Color(.70,0.55,.04)
    else
        return Color(.70,0.19,.17)
    end
end 

function rebuildUI()
    self.setCustomObject({
        image = cardFrontImage,
        image_secondary = cardBackImage,
    });
end

function mySplit(inputstr, sep)
    if sep == nil then
      sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
  end

  
function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end