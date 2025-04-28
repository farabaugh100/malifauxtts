

local mini = nil
local faction;
local cardFrontImage;
local cardBackImage;
local name;
local playerColor='green';
local factionColor= Color(.70,0.19,.17);
local config={}
local cloneTo ={ 11.388285, 0.96, -12.243199 }
function onLoad()
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
    rebuildUI()
    self.setName(name)
    self.reload()
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