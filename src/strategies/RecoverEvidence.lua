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
    redBagObject = getObjectFromGUID("cdd66c")
    blueBagObject= getObjectFromGUID("41fc3e")

    redBagObject.clone({position=red})
    blueBagObject.clone({position=blue})
end


function setDeployment(mode)
end