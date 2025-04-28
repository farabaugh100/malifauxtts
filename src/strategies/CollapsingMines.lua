local center={x= 0, y= 0.9114264,z= 0}
local topLeft={x= 9, y= 0.91143,z= 9}
local topRight={x= 9, y= 0.91143,z= -9}
local bottomLeft={x= -9, y= 0.91143,z= 9}
local bottomRight={x= -9, y= 0.91143,z= -9}
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
    bagObject = getObjectFromGUID("b469ee")
    bagObject.takeObject({position=center}).setLock(true)
    bagObject.takeObject({position=topLeft}).setLock(true)
    bagObject.takeObject({position=topRight}).setLock(true)
    bagObject.takeObject({position=bottomLeft}).setLock(true)
    bagObject.takeObject({position=bottomRight}).setLock(true)

    
end