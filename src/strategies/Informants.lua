
local diagonalDeployments={1,4}
local parallelDeployments={2,3}
local deploymentMode=0
local setupLibeary={
    one={
        zero={
            {x=0,y=0.9114265,z=0};
            {x=7.07,y=0.9114265,z=7.07};
            {x=-7.07,y=0.9114265,z=-7.07};
            {x=-9,y=0.9114265,z=9};
            {x=9,y=0.9114265,z=-9};
        };
        ninty={
            {x=0,y=0.9114265,z=0};
            {x=-7.07,y=0.9114265,z=7.07};
            {x=7.07,y=0.9114265,z=-7.07};
            {x=9,y=0.9114265,z=9};
            {x=-9,y=0.9114265,z=-9};
        };
        oneeighty={
            {x=0,y=0.9114265,z=0};
            {x=7.07,y=0.9114265,z=7.07};
            {x=-7.07,y=0.9114265,z=-7.07};
            {x=-9,y=0.9114265,z=9};
            {x=9,y=0.9114265,z=-9};
        };
        twoseventy={
            {x=0,y=0.9114265,z=0};
            {x=-7.07,y=0.9114265,z=7.07};
            {x=7.07,y=0.9114265,z=-7.07};
            {x=9,y=0.9114265,z=9};
            {x=-9,y=0.9114265,z=-9};
        };
    };
    two={
        zero={
            {x=0,y=0.9114265,z=0};
            {x=0,y=0.9114265,z=10};
            {x=0,y=0.9114265,z=-10};
            {x=-40,y=0.9114265,z=0};
            {x=40,y=0.9114265,z=0};
        };
        ninty={
            {x=0,y=0.9114265,z=0};
            {x=10,y=0.9114265,z=0};
            {x=-10,y=0.9114265,z=0};
            {x=-40,y=0.9114265,z=0};
            {x=40,y=0.9114265,z=0};
        };
        oneeighty={
            {x=0,y=0.9114265,z=0};
            {x=0,y=0.9114265,z=10};
            {x=0,y=0.9114265,z=-10};
            {x=-40,y=0.9114265,z=0};
            {x=40,y=0.9114265,z=0};
        };
        twoseventy={
            {x=0,y=0.9114265,z=0};
            {x=10,y=0.9114265,z=0};
            {x=-10,y=0.9114265,z=0};
            {x=-40,y=0.9114265,z=0};
            {x=40,y=0.9114265,z=0};
        };
    };
    three={
        zero={
            {x=0,y=0.9114265,z=0};
            {x=0,y=0.9114265,z=10};
            {x=0,y=0.9114265,z=-10};
            {x=-40,y=0.9114265,z=0};
            {x=40,y=0.9114265,z=0};
        };
        ninty={
            {x=0,y=0.9114265,z=0};
            {x=10,y=0.9114265,z=0};
            {x=-10,y=0.9114265,z=0};
            {x=-40,y=0.9114265,z=0};
            {x=40,y=0.9114265,z=0};
        };
        oneeighty={
            {x=0,y=0.9114265,z=0};
            {x=0,y=0.9114265,z=10};
            {x=0,y=0.9114265,z=-10};
            {x=-40,y=0.9114265,z=0};
            {x=40,y=0.9114265,z=0};
        };
        twoseventy={
            {x=0,y=0.9114265,z=0};
            {x=10,y=0.9114265,z=0};
            {x=-10,y=0.9114265,z=0};
            {x=-40,y=0.9114265,z=0};
            {x=40,y=0.9114265,z=0};
        };
    };
    four={
        zero={
            {x=0,y=0.9114265,z=0};
            {x=-7.07,y=0.9114265,z=7.07};
            {x=7.07,y=0.9114265,z=-7.07};
            {x=9,y=0.9114265,z=9};
            {x=-9,y=0.9114265,z=-9};
        };
        ninty={
            {x=0,y=0.9114265,z=0};
            {x=7.07,y=0.9114265,z=7.07};
            {x=-7.07,y=0.9114265,z=-7.07};
            {x=-9,y=0.9114265,z=9};
            {x=9,y=0.9114265,z=-9};
        };
        oneeighty={
            {x=0,y=0.9114265,z=0};
            {x=-7.07,y=0.9114265,z=7.07};
            {x=7.07,y=0.9114265,z=-7.07};
            {x=9,y=0.9114265,z=9};
            {x=-9,y=0.9114265,z=-9};
        };
        twoseventy={
            {x=0,y=0.9114265,z=0};
            {x=7.07,y=0.9114265,z=7.07};
            {x=-7.07,y=0.9114265,z=-7.07};
            {x=-9,y=0.9114265,z=9};
            {x=9,y=0.9114265,z=-9};
        };
    }
}
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
    if deploymentMode==0 then
        broadcastToAll("Please select a deployment", Color.red)
        return false
    end
    local DeploymentOverlay = getObjectFromGUID(FindDeploymentOverlay());
    local rot=DeploymentOverlay.getRotation().y
    local setup=setupLibeary[convertNumToString(deploymentMode)][convertNumToString(rot)]
    bagObject = getObjectFromGUID("b469ee")
    for index,value in pairs(setup) do
        local marker=bagObject.takeObject({position=value})
    end
end

function FindDeploymentOverlay()
    for key,guid in pairs {"c2c330" ,"3eed6c","57825b","02c08b"} do
        local DeploymentOverlay = getObjectFromGUID(guid);
        if DeploymentOverlay ~= nil then
            return guid;
        end
    end
end

function setDeployment(mode)
    log(mode)
    deploymentMode=mode
end
function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end
function convertNumToString(num)
    if num==1 then
        return "one"
    end
    if num==2 then
        return "two"
    end
    if num==3 then
        return "three"
    end
    if num==4 then
        return "four"
    end
    if num==0 then
        return "zero"
    end
    if num==90 then
        return "ninty"
    end
    if num==180 then
        return "oneeighty"
    end
    if num==270 then
        return "twoseventy"
    end
end