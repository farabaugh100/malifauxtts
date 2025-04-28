TRH_Class = "token"

local config = {
    --name: must be unique to your mod.
    --url: url of the asset used on the marker. Consider the design of the image and use this one as an example (white with a black outline seems to work best for contrast's sake)
    --color: valid hex color of the marker
    --stacks: true or false - can the mini receive this marker more than once.
    --name="Base", url="https://steamusercontent-a.akamaihd.net/ugc/1019447087554346517/81BCB3804E00F22B1E40D6A84C85C26F04F3C5CC/", color="#DF2020", stacks=false
}
--used to determin if the token already collided with a mini.  If the token is traveling fast enought it can colide multiple times before the self.destruct call is called
local colided=false

--I kinda hate how this is set up right now.  I should make it that each token calls a globle script so when i make changes it updates each token automaticall
--THis is probably what should happen on all generated assets with scripts.
--i wonder if lua has a extends functionallity.   Could create a sript that has this kind of function that every token inhearets.  I'll look into that later
function onCollisionEnter(col)
    if colided then
        return 0
    end
    config.count = math.max(1, self.getQuantity())
    if ((col.collision_object.getVar("TRH_Class") or "") == "mini") then
        colided=true
        if (col.collision_object.call("addMarker", config)) then self.destruct() end
    end
end
function setConfig(newConfig)
    config=newConfig
    self.setCustomObject({
        image = newConfig.image
    });
    self.setName(newConfig.name)
    --Converst bbcode to tts frendly floats
    local r=tonumber(string.sub(newConfig.color,2,3),16)/255
    local g=tonumber(string.sub(newConfig.color,4,5),16)/255
    local b=tonumber(string.sub(newConfig.color,6,7),16)/255
    self.setDescription(newConfig.rules)
    self.setColorTint({r,g,b})
    self.script_state=onSave()
    self.reload()
end

function onSave()
    miniguid = ''
    if mini ~= nil then
        miniguid = mini.getGUID()
    end
    local save = {
        config=config
    }
    return JSON.encode(save)
end


function onLoad(save)
    --self.script_state=onSave()
    local data = JSON.decode(save)
    if data ~=nil then
        config=data["config"]
    end
end