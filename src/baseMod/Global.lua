
local MenuManager = nil
local MenuManagerGUID = "15fc7f";
local RetryTime = 100;
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


--- Adds confirmation panel to Global UI
-- @tparam tab  params Parameter table.
-- Example parameter table:
--  {
--    question = question, -- text
--    description = description, -- text
--    source = self,  -- object
--    player = player,  player instance
--    confirmedFunction = functionName - text
--  }
function displayConfirmationPrompt(params)
  local idPrefix = params.source.getGUID()
  local height = 150
  local width = 500
  -- Gets global IU table
  local ui = Global.UI.getXmlTable()

  -- Creates confirmation panel 
  local panel = {
    tag = "Panel",
    attributes = {
      id = idPrefix.."ConfirmationPromptPanel",
      height = height,
      width = width,
      scale = "1 1 1",
      color = "rgba(1,1,1,1)",
      rectAlignment = "UpperRight",
      position = "0 0",
      offsetXY = width/2 .." ".. height/2,
      padding = "15",
      allowDragging = "true",
      returnToOriginalPositionWhenReleased = "false",
      visibility = params.player.color
    },
    children = {
      {
        tag = "VerticalLayout",
        attributes = {
          childForceExpandHeight = "true",
        },
        children={
          {
            tag = "Text",
            attributes = {
              minHeight = "30",
              fontStyle = "bold",
              fontSize = 20,
              text = params.question,
            },
          }, 
          {
            tag = "Text",
            attributes = {
              minHeight = "30",
              text = params.description,
            },
          },           
          {
            tag = "HorizontalLayout",
            attributes = {
              padding = "0 0 0 3",
              childForceExpandWidth = "false",
              childForceExpandHeight = "false",
              childAlignment = "LowerCenter",
            },
            children={ 
              {
                tag = "Button",
                attributes = {
                  id = idPrefix,
                  minHeight = 30,
                  minWidth = 60,
                  color = "blue", 
                  text= "YES",
                  onClick = "onCloseButtonClicked("..params.confirmedFunction..")",
                }
              },
              {
                tag = "Button",
                attributes = {
                  id = idPrefix,
                  minHeight = 30,
                  minWidth = 60,
                  color = "red",
                  text = "NO", 
                  onClick = "onCloseButtonClicked(close)",
                }
              },
            },
          },  
        },
      },
    },
  }

  -- Adds confirmation panel to the UI table and set new table.
  table.insert(ui,panel)
  Global.UI.setXmlTable(ui)
end

--- Removes confirmation panel from Global UI.
-- Call for action if confirmation was positive.
-- @tparam instance player Player Instance.
-- @tparam string text Button onClick value.
-- @tparam string id Button ID.
function onCloseButtonClicked(player,text,id)

  -- Check if close button was clicked
  if text ~= "close" then
    -- If not call confirmed function
    local source = getObjectFromGUID(id)
    if source then
      source.call(text,player)  
    end
  end

  -- Remove confirmation panel from Global UI in either situation
  -- Gets global IU table
  local ui = Global.UI.getXmlTable()
  -- Finds ConfirmationPromptPanel in UI table and removes it
  for k, v in pairs(ui) do
    if v.attributes.id == id.."ConfirmationPromptPanel" then
      table.remove(ui,k)
      break
    end
  end 

  if not ui[1] then
    -- IU table is empty after ConfirmationPromptPanel was removed so we need to create new table.
    Global.UI.setXmlTable({{}})
  else
    -- Sets new table without ConfirmationPromptPanel.
    Global.UI.setXmlTable(ui)
  end
end