cb = "imCopy"  ss = ""  sb = ""  bb = nil  prs = ""  sid = nil  sod = {}  zz = 0  z2 = 0  uls = ""

function onLoad()
    self.setColorTint({0.803, 0.752, 0.678})
    local btn = {}  btn.function_owner = self
    btn.click_function = "btnBag"
    btn.position = {1.62, -0.05, 0.67}  btn.rotation = {0, 0, 0}
    btn.width = 285  btn.height = 370
    self.createButton(btn)
    btn.click_function = "btnTrash"
    btn.position = {-1.30, -0.05, 0.67}  btn.rotation = {0, 0, 0}
    btn.width = 320  btn.height = 370
    self.createButton(btn)
    btn.click_function = "btnGetSod"
    btn.position = {0, -0.05, -0.91}  btn.rotation = {0, 0, 0}
    btn.width = 300  btn.height = 300
    self.createButton(btn)
    btn.click_function = "btnUnlock"
    btn.position = {0, -0.05, 0.95}  btn.rotation = {0, 0, 0}
    btn.width = 300  btn.height = 300
    self.createButton(btn)
    Global.setVar("hld", 0)  benDare()
end

function update()  if cb then self.call(cb)  end  end

function benDare()
    local aoj = {}  aoj = getAllObjects()  local g = aoj[1]  local n = 1  local p
    while g do
        p = g.getPosition()
        if math.modf(p[1]) == 0 and math.modf(p[3]) == 0 and string.sub(g.getName(), 1, 4) == "SBx_" then  g.interactable = false  sid = g.getGUID() end
        if g.getName() == "tras_h" then bb = g.getGUID() end
        if g.getName() == "Ignore Me" then Global.setVar("im", g.getGUID()) end
        n = n+1  g = aoj[n]
    end
end

function imCopy()
    if zz > 5 then  cb = nil
        if self.guid != "2d647a" then
            broadcastToAll("Stage Copies will not work. Save the original Directly to your TTS Saved Objects Chest!", {0.943, 0.745, 0.14})
            self.destruct()
        end
    end  zz = zz+1
end

function btnBag()
    if cb or Global.getVar("hld") != 0 then broadcastToAll("The Current Set is Busy...", {0.943, 0.745, 0.14})  do return  end  end
    local n = 1  ss = ""  prs = ""  local f  local p  local u = "@649822@059864@3761d8@ff9bc3@2deca3@"
    if not getObjectFromGUID(Global.getVar("im")) then benDare() end
    local l = ""  if getObjectFromGUID(Global.getVar("im")) then l = getObjectFromGUID(Global.getVar("im")).getLuaScript() end
    Global.setVar("hld", 1)  local v = "FogOfWarTrigger@ScriptingTrigger@3DText"
    local aoj = {}  aoj = getAllObjects()  local g = aoj[1]  local a = string.char(13)..string.char(10)  local k = string.char(44)
    while g do
        p = g.getPosition()  f = g.getGUID()
        if math.abs(p[3]) < 18.5 and p[2] < 44 and p[2] > 0 and math.abs(p[1]) < 18.5 then
            if string.find(u, f) then Global.setVar("hld", 0)  do return  end  end
            if not string.find(v, g.name) and not string.find(l, g.guid) then
                local r = g.getRotation()  ss = ss..f  prs = prs.."--"..f..k..p[1]..k..p[2]..k..p[3]..k..r[1]..k..r[2]..k..r[3]..a
            end
        end
        n = n+1  g = aoj[n]
    end
    if ss != "" then
        local op = {} op.type = "Bag" op.callback_owner = self
        op.callback = "cbBag" op.position = {70, 67, 70}  local obj = spawnObject(op)
        if bb then getObjectFromGUID(bb).destruct()  bb = nil end
    else Global.setVar("hld", 0) end
end

function cbBag(o)
    o.setLuaScript(prs)  o.setName("SET_")
    if sid then
        if getObjectFromGUID(sid) then
            getObjectFromGUID(sid).setScale({0.3, 0.3, 0.3})
            getObjectFromGUID(sid).tooltip = true  getObjectFromGUID(sid).interactable = true
            o.setName("SET_"..string.sub(getObjectFromGUID(sid).getName(), 5))
        end sid = nil
    end
    o.lock()  o.setScale({15, 1, 15})  o.setRotation({0, 0, 0})  o.setPosition({70, 98, 70})  sb = o.getGUID()
    zz = 2  z2 = 0  prs = ""  cb = "cbStowAway"
end

function hmBag()
    local s = self.getScale()  s = s[1]*2+1.5
    local r = self.getRotation()  r[2] = r[2]+270  if r[2] > 360 then r[2] = r[2]-360 end
    local x = math.sin(math.rad(r[2]))*s  local y = x/math.tan(math.rad(r[2]))
    getObjectFromGUID(sb).setRotation({0, r[2], 0})  getObjectFromGUID(sb).setScale({1, 1, 1})
    local p = self.getPosition()  getObjectFromGUID(sb).setPosition({p[1]-y, 0.823, p[3]+x})
    getObjectFromGUID(sb).unlock()  sb = ""
end

function cbStowAway()
    local g  zz = zz+1
    if zz > 1 then zz = 0
        g = string.sub(ss, 1, 6)  ss = string.sub(ss, 7)  prs = prs..g
        if getObjectFromGUID(g) then
            --getObjectFromGUID(g).unlock()  --getObjectFromGUID(g).interactable = true
            local s = getObjectFromGUID(g).getScale()  getObjectFromGUID(g).setScale({0.1, 0.2, 0.3})  getObjectFromGUID(g).setScale(s)
            getObjectFromGUID(g).setPosition({70, 100+z2*0, 70})
            getObjectFromGUID(sb).putObject(getObjectFromGUID(g))
            --getObjectFromGUID(g).setRotation({z2*40, z2*40, z2*40})
            --getObjectFromGUID(g).setPositionSmooth({70, 99.7+z2*0, 70}, false)
        end
        if ss == "" then  z2 = z2+1  if z2 > 3 and z2 < 9 then broadcastToAll("Pass "..z2-2, {0.943, 0.745, 0.14}) end
            if z2 > 8 then cb = nil  broadcastToAll("Manually add "..(string.len(prs)/6).." objects to Bag.", {0.943, 0.745, 0.14})
                for zz = 1, string.len(prs), 6 do
                    g = string.sub(prs, zz, zz+5)
                    getObjectFromGUID(g).setPosition({0, 2+zz/3, 0})  getObjectFromGUID(g).setPositionSmooth({0, 2.3+zz/3, 0})
                end  prs = ""  Global.setVar("hld", 0)  --hmBag()
                getObjectFromGUID(sb).setScale({1, 1, 1})  getObjectFromGUID(sb).setPosition({0, 0.823, 0})  getObjectFromGUID(sb).unlock()  sb = ""
            else zz = 0  cb = "endStowAway"
            end
        end
    end
end

function endStowAway()
    zz = zz+1  if zz > 48 then  ss = prs  prs = ""  cb = "cbStowAway"  do return  end  end
    local i
    for i = 1, string.len(prs), 6 do
        if not getObjectFromGUID(string.sub(prs, i, i+5)) then prs = string.sub(prs, 1, i-1)..string.sub(prs, i+6) end
    end
    if prs == "" then cb = nill  Global.setVar("hld", 0)  hmBag()  end
end

function btnTrash()
    if cb or Global.getVar("hld") != 0 then broadcastToAll("The Current Set is Busy...", {0.943, 0.745, 0.14})  do return  end  end
    if bb then
        local p  local s = getObjectFromGUID(bb).getLuaScript()
        if string.sub(s, string.len(s)-1) != string.char(13)..string.char(10) then s = s..string.char(13)..string.char(10) end
        while s != "" do
            if getObjectFromGUID(string.sub(s, 3, 8)) then
                p = getObjectFromGUID(string.sub(s, 3, 8)).getPosition()
                if math.abs(p[3]) < 26 and math.abs(p[1]) < 44 and math.abs(p[2]) < 26 then
                    if getObjectFromGUID("649822") then getObjectFromGUID("649822").call("noSMX", {string.sub(s, 3, 8)}) end
                    getObjectFromGUID(string.sub(s, 3, 8)).destruct()  end
            end
            s = string.sub(s, string.find(s, string.char(13)..string.char(10))+2)
        end
        getObjectFromGUID(bb).destruct()  bb = nil  btnGetSod()
    end
end

function onCollisionEnter(c)
    log("in stage on collision enter")
    if cb == "imCopy" then do return  end  end
    if cb or Global.getVar("hld") != 0 then broadcastToAll("The Current Set is Busy...", {0.943, 0.745, 0.14})  do return  end  end
    if  string.sub(c.collision_object.getName(), 1, 4) == "SET_" and c.collision_object.name == "Bag" then
        local v = {}  v = c.collision_object.getObjects()
        local x  local y  local z  local ct = 1  local n  local p  ss = ""
        if getObjectFromGUID("649822") then getObjectFromGUID("649822").setVar("ulk", nil) end
        prs = c.collision_object.getLuaScript()  btnTrash()  btnGetSod()  Global.setVar("hld", 1)  p = self.getPosition()
        while v[ct] do
            if getObjectFromGUID(v[ct].guid) and zz != 0.02 then  zz = 0.02  Global.setVar("hld", 0)
                c.collision_object.setPosition({p[1], p[2]+0.6, p[3]})  c.collision_object.setPositionSmooth({p[1], p[2]+0.3, p[3]})
                do return  end
            end  ct = ct+1
        end  ct = 1
        while v[ct] do
            if getObjectFromGUID(v[ct].guid) then 	broadcastToAll("Duplicate Object: "..v[ct].guid, {0.943, 0.745, 0.14})
                Global.setVar("hld", 0)  upWeGo(v[ct].guid)
                do return  end
            end  ct = ct+1
        end  ct = 1  zz = 0
        bb = c.collision_object.getGUID()  c.collision_object.lock()  c.collision_object.setName("tras_h")
        c.collision_object.setScale({0, 0, 0})  c.collision_object.setPosition({90, 90, 90})
        prs = string.gsub(prs, string.char(13)..string.char(10), string.char(44))
        if string.sub(prs, string.len(prs)) != "," then prs = prs.."," end
        while v[ct] do
            local t = {}  t.guid = v[ct].guid  t.position = {0, ct*2, 0}
            n = string.find(prs, "-"..v[ct].guid)
            if n then  n = n+8  zz = zz+1
                x, n = snipIt({n})  y, n = snipIt({n})  z, n = snipIt({n})  t.position = {x-70, y+70, z-70}
                x, n = snipIt({n})  y, n = snipIt({n})  z, n = snipIt({n})  t.rotation = {x, y, z}
                t.callback = "setStage"  t.callback_owner = self
            end  t.smooth = false  c.collision_object.takeObject(t)  ct = ct+1
        end
    elseif string.sub(c.collision_object.getName(), 1, 4) == "SBx_" and c.collision_object.name == "Custom_Token" then
        if sid == c.collision_object.guid then do return  end  end
        btnGetSod()  c.collision_object.lock()  sid = c.collision_object.getGUID()
        c.collision_object.tooltip = false  c.collision_object.interactable = false  sod = c.collision_object.getRotation()
        sod = {math.modf(sod[1]/180+0.5)*180, math.modf(sod[2]/180+0.5)*180, math.modf(sod[3]/180+0.5)*180}
        c.collision_object.setPosition(sod)  c.collision_object.setScale({18.07, 1, 18.07})
        zz = 0  cb = "setSod"
    end
end

function snipIt(a)
    local e = string.find(prs, string.char(44), a[1])
    return string.sub(prs, a[1], e-1), e+1
end

function setSod()
    if getObjectFromGUID(sid) then
        local p = getObjectFromGUID(sid).getPosition()  local r = getObjectFromGUID(sid).getRotation()
        getObjectFromGUID(sid).setPosition({0, 0.91, 0})  getObjectFromGUID(sid).setRotation(sod)
        if math.abs(p[1]) < 0.0005 and math.abs(p[2]-0.91) < 0.0005 and math.abs(p[3]) < 0.0005 and math.abs(sod[1]-r[1]) < 0.0005
        and math.abs(sod[2]-r[2]) < 0.0005 and math.abs(sod[3]-r[3]) < 0.0005 and getObjectFromGUID(sid).resting then
            cb = nil  else zz = zz+1  if zz > 20 then cb = nil  print("Failed Alignment.")  end
        end
    else sid = nil  cb = nil  end
end

function setStage(a)
    a.resting = true  a.lock()  local n = string.find(prs, "-"..a.guid)+8  zz = zz-1
    y, n = snipIt({n})  z, n = snipIt({n})  x, n = snipIt({n})  a.setPosition({y, z, x})
    y, n = snipIt({n})  z, n = snipIt({n})  x, n = snipIt({n})  a.setRotation({y, z, x})
    if string.sub(a.getName(), 1, 4) == "SBx_" then a.setScale({18.07, 1, 18.07})
        sid = a.getGUID()  sod = {y, z, x}  a.tooltip = false  a.interactable = false  end
    ss = ss..(a.guid)  if zz == 0 then cb = "popSetQ" end
end

function popSetQ()
    zz = zz+1
    if zz > 5 then zz = 0  z2 = 0  uls = ""  cb = "popSet"  end
end

function popSet()
    if ss == "" then cb = nil  popSetZ()  do return  end  end
    local x  local y  local z  local a  local b  local c  local n  local g  local p  local r
    g = string.sub(ss, 1, 6)  n = string.find(prs, "-"..g)+8
    if not getObjectFromGUID(g) then ss = string.sub(ss, 7)
        	broadcastToAll("Missing Object: "..g, {0.943, 0.745, 0.14})  do return  end  end
    y, n = snipIt({n})  z, n = snipIt({n})  x, n = snipIt({n})  p = getObjectFromGUID(g).getPosition()
    a, n = snipIt({n})  b, n = snipIt({n})  c, n = snipIt({n})  r = getObjectFromGUID(g).getRotation()
    if getObjectFromGUID(g).resting then
        if math.abs(p[1]-y) < 0.0005 and math.abs(p[2]-z) < 0.0005 and math.abs(p[3]-x) < 0.0005 and
            math.abs(r[1]-a) < 0.0005 and math.abs(r[2]-b) < 0.0005 and math.abs(r[3]-c) < 0.0005 then
            z2 = z2+1  if z2 > 9 then zz = 0 end
        else zz = zz+1
            getObjectFromGUID(g).setRotation({a, b, c})  getObjectFromGUID(g).setPosition({y, z, x})  getObjectFromGUID(g).resting = true
        end
    else getObjectFromGUID(g).resting = true  zz = zz+1
    end
    if zz > 99 then print("Failed Alignment.")  zz = 0  end
    if zz == 0 then ss = string.sub(ss, 7)  z2 = 0
        if getObjectFromGUID(g).getName() != "" and string.sub(getObjectFromGUID(g).getName(), 1, 4) != "SBx_" then uls = uls..g  end
    end
end

function popSetZ()
    if getObjectFromGUID("649822") then
        local p = getObjectFromGUID("649822").getPosition()
        if math.abs(p[3]) < 28 and math.abs(p[1]) < 46 then getObjectFromGUID("649822").setPosition({p[1], p[2]+5, p[3]})  end
        --if math.abs(p[3]) < 28 and math.abs(p[1]) < 46 then getObjectFromGUID("649822").call("isFrame")  end
    end  Global.setVar("hld", 0)  	broadcastToAll("Done...", {0.943, 0.745, 0.14})
end

function btnGetSod()
    if sid then
        if getObjectFromGUID(sid) then
            local s = self.getScale()  s = s[1]*2+2
            local p = self.getPosition()  local r = self.getRotation()  if r[2] == 0 then r[2] = 360 end
            local x = math.sin(math.rad(r[2]))*s  local y = x/math.tan(math.rad(r[2]))  r[2] = r[2]+90
            getObjectFromGUID(sid).setScale({0.3, 0.3, 0.3})
            getObjectFromGUID(sid).setRotation({0, r[2], 0})
            getObjectFromGUID(sid).tooltip = true  getObjectFromGUID(sid).interactable = true  getObjectFromGUID(sid).unlock()
            getObjectFromGUID(sid).setPosition({p[1]-y, 2.2, p[3]+x})
            getObjectFromGUID(sid).setPositionSmooth({p[1]-y, 2.5, p[3]+x})
        end
        sid = nil
    end
end

function btnUnlock()
    if cb or Global.getVar("hld") != 0 then broadcastToAll("The Current Set is Busy...", {0.943, 0.745, 0.14})  do return  end  end
    local g  local i  print("Unlocking Named Set Objects...")
    if getObjectFromGUID("649822") then
        getObjectFromGUID("649822").setVar("ulk", 1)
        local p = getObjectFromGUID("649822").getPosition()
        if math.abs(p[3]) <= 28 and math.abs(p[1]) <= 46 then do return end  end
    end
    for i = 1, string.len(uls), 6 do
        g = string.sub(uls, i, i+5)
        if getObjectFromGUID(g) then getObjectFromGUID(g).unlock() end
    end
end

function upWeGo(a)
    local p = getObjectFromGUID(a).getPosition()
    getObjectFromGUID(a).setPositionSmooth({p[1], p[2]+3, p[3]})
end















--tt