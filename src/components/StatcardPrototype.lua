

local mini = nil
local faction;
local baseScale;
local cardFrontImage;
local cardBackImage;
local health;
local imageScale;
local modelImage;
local name;
local characteristics;
local crewCard;
local playerColor='green';
local factionColor= Color(.70,0.19,.17);
local cloneTo ={ 11.388285, 0.96, -12.243199 }

local prototypes = {
    base = '000000',
}
function destruct()
    if mini ~= nil then
mini.destruct()    
    end
end
function getCharacteristics()
    return characteristics
end
function getCrewCard()
    return crewCard
end
function rt_createModel(params)
    local faction = params.faction;
    local color = Color(params.r,params.g,params.b);
    local isReference = params.isReference;
    factionColor = color;
    if isReference ~= true then
        createModel(self.getPosition(),color);
    end
end

function ui_createModel()
    createModel(self.getPosition())
end

function hello_world()
    log("Hello World")
end
function createStatCard(params)
    --log(params)
    health = params["health"]
    imageScale = params["imageScale"]
    modelImage = params["modelImage"]
    name = params["name"]
    playerColor =params["playerColor"]
    faction = params["faction"]
    cardFrontImage = params["cardFrontImage"]
    cardBackImage = params["cardBackImage"]
    baseScale = params["baseScale"]
    characteristics=params["characteristics"]
    crewCard=params["crewCard"]
    factionColor=factionColorLookup(params["faction"])
    self.setDescription("DF: "..params.df.." WP: "..params.wp.."\nSP: "..params.sp.." SZ: "..params.sz)
    
    --log(params["faction"])
    --createModel(self.getPosition());
    rebuildUI()
    self.setName(name)
    self.script_state=onSave()
    self.reload()
end
function createCrewCard(params)
    name = params["name"]
    playerColor =params["playerColor"]
    faction = params["faction"]
    cardFrontImage = params["cardFrontImage"]
    cardBackImage = params["cardBackImage"]
    factionColor=factionColorLookup(faction)
    rebuildUI()
    self.setName(name)
    self.onSave()
    self.reload()
end
function factionColorLookup(faction)
    --log(faction.."faction")
    if faction=="Guild" then
        --log("guild")
        return Color(.70,0.19,.17)
    elseif faction=="Arcanists" then
        --log("Arcanists")
        return Color(0/255, 90/255, 154/255);
    elseif faction=="Arcanist" then
        --log("Arcanist")
        return Color(0/255, 90/255, 154/255);
    elseif faction=="Resurrectionists" then
        --log("Resurrectionists")
        return Color(37/255, 136/255, 69/255);
    elseif faction=="Resurrectionist" then
        --log("Resurrectionist")
        return Color(37/255, 136/255, 69/255);
    elseif faction=="Neverborn" then
        --log("Neverborn")
        return Color(95/255, 53/255, 129/255);
    elseif faction=="Ten Thunders" then
        --log("Thunders")
        return Color(208/255, 95/255, 36/255);
    elseif faction=="Outcast" then
        --log("Outcast")
        return Color(181/255, 143/255, 18/255)
    elseif faction=="Explorer's Society" then
        --log("Explorer's Society")
        return Color(0/255, 114/255, 111/255)
    elseif faction=="Explorers Society" then
        --log("Explorers Society")
        return Color(0/255, 114/255, 111/255)
    else
        --log("else")
        return Color(.70,0.19,.17)
    end
end 

function createModel(position)
    local pos = position:add(Vector(0,2,0))

    objectData =  self.getData()

    modelPrototype = getObjectFromGUID(prototypes.base)
    local rot = self.getRotation()
    model = modelPrototype.clone({position=pos,rotation=rot})

    model.setScale({x=baseScale, y=1, z=baseScale})
    attachments = model.getAttachments()
    for key,value in pairs(attachments) do
        modelElement = model.removeAttachment(0)
        modelElement.setCustomObject({
            image = modelImage,
            image_secondary = modelImage,
            image_scalar = imageScale
        })
        modelElement.setScale(Vector(0.40 * baseScale, 0.40 * baseScale, 0.2 ));
        model.addAttachment(modelElement)
    end
    model.setDescription(objectData.Description)
    model.setName(name)
    --log(faction)
    --log(factionColor)
    model.script_state = "{\"originalData\":{\"base\":{\"color\":{\"a\":1,\"b\":".. factionColor.b ..",\"g\":".. factionColor.g ..",\"r\":".. factionColor.r .."},\"size\":".. baseScale * 25 .."},\"health\":{\"current\":" ..health ..",\"max\":" ..health .."},\"imageScale\":" .. imageScale  .."}}";



    mini = model
    -- end
end

function ui_pingmini(player)
    if (mini ~= nil) then
        if (player.pingTable ~= nil) then
            player.pingTable(mini.getPosition())
        end
    end
end

function rebuildAssets()
    local root = 'https://raw.githubusercontent.com/RobMayer/TTSLibrary/master/ui/';
    local assets = {
        {name='ui_power', url=root..'power.png'},
        {name='ui_gear', url=root..'gear.png'},
        {name='ui_close', url=root..'close.png'},
        {name='ui_plus', url=root..'plus.png'},
        {name='ui_minus', url=root..'minus.png'},
        {name='ui_reload', url=root..'reload.png'},
        {name='ui_location', url=root..'location.png'},
        {name='ui_bars_new', url=root..'bars_new.png'},
        {name='ui_arrow_u', url=root..'arrow_u.png'},
        {name='ui_arrow_d', url=root..'arrow_d.png'},
        {name='ui_arrow_l', url=root..'arrow_l.png'},
        {name='ui_arrow_r', url=root..'arrow_r.png'},
    }

    assetBuffer = {}
    local bufLen = 0
    for idx,guid in pairs(mapI2G) do
        local mini = getObjectFromGUID(guid)
        if (mini ~= nil) then
            for i,marker in pairs(mini.call('getMarkers', {})) do
                if (assetBuffer[marker.url] == nil) then
                    bufLen = bufLen + 1
                    assetBuffer[marker.url] = self.guid..'_mk_'..bufLen
                    table.insert(assets, {name=self.guid..'_mk_'..bufLen, url=marker.url})
                end
            end
        end
    end
    self.UI.setCustomAssets(assets)
end

function rebuildUI()
    self.setCustomObject({
        image = cardFrontImage,
        image_secondary = cardBackImage,
    });

    local ui = {
        {tag='Defaults', children={
            {tag='Text', attributes={color='#cccccc', fontSize='18', alignment='MiddleLeft'}},
            {tag='InputField', attributes={fontSize='24', preferredHeight='40'}},
            {tag='ToggleButton', attributes={fontSize='18', preferredHeight='40', colors='#ffcc33|#ffffff|#808080|#606060', selectedBackgroundColor='#dddddd', deselectedBackgroundColor='#999999'}},
            {tag='Button', attributes={fontSize='12',textColor='#111111', preferredHeight='40', colors='#dddddd|#ffffff|#808080|#f6f6f6'}},
            {tag='Toggle', attributes={textColor='#cccccc'}},
        }},
        
        {tag='button', attributes={onClick='ui_pingmini', image='ui_location',  colors='#ccccccff|#ffffffff|#404040ff|#808080ff', width='20', height='20', position='-40 -110 -5', rotation='0 0 180' }},
        {tag='button', attributes={onClick='ui_createModel',text='Spawn Model',  colors='#ccccccff|#ffffffff|#404040ff|#808080ff', width='120', height='20', position='0 110 -5', rotation='0 0 180' }} 
    }
    
    self.UI.setXmlTable(ui)
    
end

function onSave()
    miniguid = ''
    if mini ~= nil then
        miniguid = mini.getGUID()
    end
    local save = {
        mini = miniguid,
        baseScale = baseScale,
        health = health,
        imageScale = imageScale,
        modelImage = modelImage,
        name = name,
        playerColor = playerColor, 
        faction = faction,
        cardFrontImage = cardFrontImage,
        cardBackImage = cardBackImage,
        characteristics=characteristics,
        crewCard=crewCard,
    }
    return JSON.encode(save)
end


function onLoad(save)
    local data = JSON.decode(save)
    mini = getObjectFromGUID(data.mini)
    baseScale = data.baseScale;
    health = data.health;
    imageScale = data.imageScale;
    modelImage = data.modelImage;
    characteristics=data.characteristics;
    crewCard=crewCard;
    factionColor=factionColorLookup(data["faction"])
    --cardFrontImage = data.cardFrontImage;
    --cardBackImage =data.cardBackImage;
    name = data.name;
    faction = data.faction or 'Arcanist';
    playerColor = data.playerColor or 'Blue';

    rebuildUI()
end