local blue={
    {x= -38.10101, y= 0.9114264,z= 9},
    {x= -38.10101, y= 0.9114264,z= 10.5},
    {x= -38.10101, y= 0.9114264,z= 12}
}
local red={
    {x= 38.10101, y= 0.9114264,z= 9},
    {x= 38.10101, y= 0.9114264,z= 10.5},
    {x= 38.10101, y= 0.9114264,z= 12}
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
    local bag=getObjectFromGUID("b469ee")

    for index,value in pairs(blue) do
        local b=bag.takeObject({position=value})
        Wait.frames(function() b.setState(3) end,180)
        b.setRotation({0,-90,0})
    end

    for index,value in pairs(red) do
        local r=bag.takeObject({position=value})
        Wait.frames(function() r.setState(2) end,180)
        r.setRotation({0,90,0})
    end
end