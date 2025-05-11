
local MenuManager = nil
local MenuManagerGUID = "15fc7f";
local RetryTime = 100;
local playerFactions
local playerFactionsBag={
    Guild="7c0835",
    Arcanist="edf269",
    Arcanists="edf269",
    Bayou="fe97e9",
    ExplorersSociety="898648",
    Neverborn="31f5d9",
    Outcasts="44e232",
    Resurrectionist="68a770",
    TenThunders="10de55"
}
function onObjectNumberTyped(object , color, number)
   
    local hoveredElement = GetPlayerFromColor(color).getHoverObject();
    local RSS_Class = hoveredElement and hoveredElement.getVar("RSS_Class") or 'no Hover';
    if RSS_Class == "Model" or RSS_Class == "Marker" then
        if number == 0 then number = 10; end
        MenuManager.call("onNumberInput",{number=number,color=color})
        return true;
    end
end

function onLoad()
    MenuManager = getObjectFromGUID(MenuManagerGUID);
    playerFactions={Blue="Guild",Red="Guild"}
end

function onUpdate()
    if MenuManager == nil then
        if RetryTime < 0 then
            MenuManager = getObjectFromGUID(MenuManagerGUID);
            RetryTime = 100;
        else
            RetryTime = RetryTime -1;        end
    end
end
-------------UTILS -------------

function GetPlayerFromColor(color)
    for _, player in pairs(Player.getPlayers()) do
        if player.color == color then
            return player;
        end
    end
end

function getPlayerFaction(params)
    return playerFactions[params.color]
end

function setPlayerFaction(params)
    playerFactions[params.color]=params.faction
end

function getPlayerFactionSchemeBag(params)
    return playerFactionsBag[getPlayerFaction(params)]
end