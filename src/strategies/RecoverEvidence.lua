local blue={x=-40,y=0.9114265,z=0};
local red ={x=40,y=0.9114265,z=0};
function onLoad()
    self.createButton({
        label=tostring(val),
        click_function="setUpStrat",
        tooltip=ttText,
        function_owner=self,
        position={0,0.05,-0.2},
        height=600,
        width=1000,
        alignment = 3,
        scale={x=1.5, y=1.5, z=1.5},
        font_size=600,
        font_color=f_color,
        color={0,0,0,0}
        })

end

function setUpStrat()
    local bag=getObjectFromGUID("b469ee")
    local y=0
    for i = 5, 1, -1 do
        local b=bag.takeObject({position={blue.x,blue.y+y,blue.z}})
        b.setRotation({0,-90,0})
        Wait.frames(function() b.setState(3) end,180)
        y=y+1
    end
    local y=0
    for i = 5, 1, -1 do
        local r=bag.takeObject({position={red.x,red.y+y,red.z}})
        Wait.frames(function() r.setState(2) end,180)
        r.setRotation({0,90,0})
        y=y+1
    end
end


function setDeployment(mode)
end