RSS_Class = 'Model';
TRH_Class ="mini"
------ CLASS VARIABLES ----------------------

	local ChildObjs = {
		aura_obj = nil
	};
	local Conditions = {}
	local originalData = nil;
	local state = {
		conditions={Adaptable = 0,Adversary = 0,Bolstered = 0,Burning = 0,Craven = 0,Distracted = 0,Entranced = 0,Fast = 0,Focused = 0,Hastened = 0,Impact = 0,Injured = 0,Insight = 0,Poison = 0,Shielded = 0,Slow = 0,Staggered = 0,Stunned = 0,AuraHazardous = 0, AuraConcealment = 0,Summon=0,Flicker = 0,Backtrack = 0,AuraNegligent = 0,AuraBinding = 0,Analyzed = 0,AuraFire = 0,Greedy = 0,AuraFumes = 0,Engorged = 0,Broodling = 0,Suppresed = 0,Fright = 0,Challenged = 0,Power = 0,Glowy = 0,Perforated = 0,Brilliance = 0,Parasite = 0,Shame = 0,SpiritualChains = 0,AuraStaggered = 0},
		extras={Aura = 0,Activated = 0,Mode = 0},
		tokens={},
		health={current=-1,max= 9},
		base={size=30,color=Color(1,0.5,1)},
		imageScale=1.5,
		
		moveHistory={},
		

		referenceCard = { GUID = '', obj = nil},
	
	};

	local UIStatus = {
		Blue = {rotation = -2},
		Red = {rotation = -2},
		Black = {rotation = -2},
		Grey = {rotation = -2},
	};

	

------ LIFE CICLE EVENTS --------------------

	function onDestroy()
		if (ChildObjs.aura_obj ~= nil) then ChildObjs.aura_obj.destruct() end
	end

	function onLoad(save)
		--self.script_state=onSave()
		save = JSON.decode(save) or {}
		self.setDescription("RSS_Model");
		recoverState(save)

		rebuildAssets()
		self.UI.setXml(ui())
		RefreshModelShape()
		showAura()
		Wait.frames(function()resetPlayerRotation()end,60)
		
	end
	
	function onSave()
		local data={}
		data.state = state;
		data.originalData = originalData ~= nil and originalData or state;
		
		return JSON.encode(data)
	end


	function onUpdate()
		for _, player in ipairs(Player.getPlayers()) do
			if IsPlayerSuscribed(player.color) then
				HUDLookAtPlayer(player);
			end
		end
	end

	function recoverState(save)
        if save.state ~= nil then
            local defaults = state.conditions          -- your zero-defaults from the literal table
			local defaults2 = state.extras
            state = save.state
			if state.extras==nil then
                state.extras={Aura = 0,Activated = 0,Mode = 0}
            end
            -- re-apply any missing condition keys back to zero
            for name,_ in pairs(defaults) do
              state.conditions[name] = state.conditions[name] or 0
            end

			for name,_ in pairs(defaults2) do
				state.extras[name] = state.extras[name] or 0
			end
            -- ensure Mode is still defined
            state.extras.Mode = state.extras.Mode or 0
        else 
            
            originalData = save.originalData;
            state.health = originalData.health;
            state.base = originalData.base;
            state.imageScale = originalData.imageScale;
            state.base.color = Color(state.base.color); 
        end
		

		-- TODO Modify State With original Data
	end

------ STATE ACTIONS ------------------------

	function SetInitialState(newState) --Tobe called from the reference card
		state.state = newState.state;
		state.health = newState.health;
		state.base = newState.base;
		state.imageScale = newState.imageScale;
		state.referenceCard = newState.referenceCard;
		--state.name = state.name;
	end

	function ModifyHealth(params)
		state.health.current =math.max(0, math.min(state.health.max, state.health.current + params.amount));	
		SyncHealth()
	end

	function ModifyAura(params)
		state.extras.Aura = math.max(0,state.extras.Aura + params.amount);
		local newScale = 0;
		if state.extras.Aura > 0 then
			newScale = state.extras.Aura+(state.base.size/50);
		end

		ChildObjs.aura_obj.setScale(Vector(newScale,1,newScale));
		SyncExtra("Aura")
	end

	function ModifyCondition(params)
		local extrasKeys = { Mode = true, Aura = true, Activated = true }

		local previousValue = 0;

		if extrasKeys[params.name] then 
			local previousValue = state.extras[params.name]
			if params.amount == 0 then -- toggle
				state.extras[params.name] = math.max(0, 1 - state.extras[params.name])	
			else
				if Conditions[params.name].loop ~= nil then
					state.extras[params.name] = math.max(0, (state.extras[params.name] + params.amount + Conditions[params.name].loop) % Conditions[params.name].loop)
				else
					state.extras[params.name] = math.max(0, state.extras[params.name] + params.amount)
				end
			end
		else 
			local previousValue = state.conditions[params.name]
			if params.amount == 0 then -- toggle
                
				state.conditions[params.name] = math.max(0, 1 - state.conditions[params.name])
			else
				if Conditions[params.name].loop ~= nil then
					state.conditions[params.name] = math.max(0, (state.conditions[params.name] + params.amount + Conditions[params.name].loop) % Conditions[params.name].loop)
				else
					state.conditions[params.name] = math.max(0, state.conditions[params.name] + params.amount)
				end
			end
		end
		
		local states  = self.getData();

		Sync()
	
		if extrasKeys[params.name] then
			print(self.getData().Nickname .. [[: ']] .. params.name .. [[' ]] .. previousValue .. [[->]] .. state.extras[params.name])
			SyncExtra(params.name)
		else
            
			print(self.getData().Nickname .. [[: ']] .. params.name .. [[' ]] .. previousValue .. [[->]] .. state.conditions[params.name])
			SyncCondition(params.name)
		end


	end

	function ModifyMoveRange(params)
		state.move.moveRange = math.max(0, state.move.moveRange + params.amount);
	end

------ MODEL MANIPULATION -------------------
	
	function AuraFollowObject(params)
		if ChildObjs.aura_obj ~= nil then
			ChildObjs.aura_obj.setVar('parent',params.obj);
		end
	end

	function AuraResetFollow()
		if ChildObjs.aura_obj ~= nil then
			ChildObjs.aura_obj.setVar('parent',self);
		end
	end

	function RefreshModelShape()
		local attachments = self.getAttachments()
		for key,value in pairs(attachments) do
			modelElement = self.removeAttachment(0)
			modelElement.setCustomObject({
				image_scalar = tonumber(state.imageScale * 1.2)
			});
			-- modelElement.getComponent('MeshCollider').set('enabled',false)
			self.addAttachment(modelElement)
		end 
		local baseScale = state.base.size / 25;
		self.setScale(Vector(baseScale,1,baseScale))
		RefreshBaseColor()
	end
	
	function RefreshBaseColor()
		if state.extras.Activated == 0 then
			self.setColorTint(state.base.color)
		else
			self.setColorTint( Color(state.base.color):lerp(Color.white, 0.45) )
		end
	end
------ UI GENERATION ------------------------
	function calculatePlayerRotation()
		for _, player in ipairs(Player.getPlayers()) do
			UIStatus[player.color].rotation = player.getPointerRotation() - self.getRotation().y + 180;
		end
	end
	function Sync()
        resetPlayerRotation()
		self.UI.setXml(ui())
		--propagateToReferenceCard()
	end
	
	function SyncCondition(name)
		local secondary = Conditions[name].secondary;
		local imageName = (secondary == nil and name or (state.conditions[name] > 1 and name or secondary));
	
		for k,color in pairs({'Red', 'Blue','Grey','Black'}) do
			self.UI.setAttributes(color.."_ConditionImage_".. name, {
				color= Conditions[imageName].color .. (state.conditions[name] > 0  and 'ff' or '22'),
				image= imageName,
			});
			self.UI.setAttributes(color.."_ConditionText_".. name, {
				active= (Conditions[name].stacks and state.conditions[name] > 0 and 'true' or 'false'),
				text= state.conditions[name] 
			});
		end
	end	

	function SyncExtra(name)
		local secondary = Conditions[name].secondary;
		local imageName = (secondary == nil and name or (state.extras[name] > 1 and name or secondary));
	
		for k,color in pairs({'Red', 'Blue','Grey','Black'}) do
			self.UI.setAttributes(color.."_ConditionImage_".. name, {
				color= Conditions[imageName].color .. (state.extras[name] > 0  and 'ff' or '22'),
				image= imageName,
			});
			self.UI.setAttributes(color.."_ConditionText_".. name, {
				active= (Conditions[name].stacks and state.extras[name] > 0 and 'true' or 'false'),
				text= state.extras[name] 
			});
		end

		if name == "Activated" then
			RefreshBaseColor()
		end
	end	
	
	function SyncHealth()
		for k,color in pairs({'Red', 'Blue','Grey','Black'}) do
			self.UI.setAttributes( color .. "_HealthBar_Text", {
				text = state.health.current.. [[/]] .. state.health.max
			});
			self.UI.setAttributes(color .. "_HealthBar", {
				percentage= (state.health.current / state.health.max * 100)
			});
		end
	end	

	function IsPlayerSuscribed(color)
		-- print(color .. " -> " ..  ((UIStatus[color] ~= nil) and 'true' or 'false') )
		return UIStatus[color] ~= nil;
	end
	function resetPlayerRotation()
		for index,player in pairs(UIStatus) do
			UIStatus[index].rotation=-2
		end
	end
	function HUDLookAtPlayer(player)
        --if true then
        --    return false
        --end
		local playerRotation  = player.getPointerRotation();
        --log("playerRotation"..playerRotation)
		if playerRotation == nil then playerRotation = 0 end;
		local pointerRotation = playerRotation - self.getRotation().y +180;
		pointerRotation = math.floor((pointerRotation+15) / 30)
		if pointerRotation ~= UIStatus[player.color].rotation then
			self.UI.setAttribute(player.color .. '_PlayerHUDPivot','rotation','0 0 '.. -30 * pointerRotation  )
			UIStatus[player.color].rotation = pointerRotation;
		end
	end

	function ui() 
		return [[
			<Panel color="#FFFFFFff" height="0" width="0" rectAlignment="MiddleCenter" childForceExpandWidth="true" >]]..
			PlayerHUDPivot('Blue')..
			PlayerHUDPivot('Red')..
			PlayerHUDPivot('Grey')..
			PlayerHUDPivot('Black')..
			[[</Panel>
		]];
	end

	function rebuildAssets()
		local assets = {};
		for conditionName, value in pairs(Conditions) do
			assets[#assets+1]={name=conditionName , url = value.url};
		end

		self.UI.setCustomAssets(assets)
	end

	function PlayerHUDPivot(color)
		return [[
			<Panel id=']]..color..[[_PlayerHUDPivot' visibility=']]..color..[[' height="160" width="100" position='0 0 -240' rotation='0 0 ]] .. - UIStatus[color].rotation .. [[' rectAlignment="MiddleCenter" childForceExpandWidth="false">
		
			]]..(state.extras.Mode == 0 and PlayerHUDContainer(color) or Compact_PlayerHUD(color))..[[
		</Panel>
		]]
	end

	
	function Compact_PlayerHUD(color)
		return [[
			<Panel id='PlayerHUD_Container' active='true' height="80" width="60" rectAlignment="MiddleCenter"  rotation='-35 0 0' position='0 0 0' childForceExpandWidth="false">]]..
			Compact_HUDConditions(color) ..
				[[<ProgressBar width="100%" height="20" id="]] .. color .. [[_HealthBar" color='#00000080' fillImageColor="#44AA22FF" percentage="]] ..(state.health.current / state.health.max * 100) .. [[" textColor="#00000000"/>  ]] ..
				[[<Text id=']] .. color .. [[_HealthBar_Text' fontSize='18' height="20" onClick='UI_ModifyHealth' text=']] .. state.health.current.. [[/]] .. state.health.max.. [[' color='#ffffff' fontStyle='Bold' outline='#000000' outlineSize='1 1' />]] ..
			[[</Panel>
		]]
	end


	function PlayerHUDContainer(color)
		return [[
			<Panel id='PlayerHUD_Container' active='true' height="80" width="128" rectAlignment="MiddleCenter"  rotation='-35 0 0' position='0 50 0' childForceExpandWidth="false">]]..
				HUDConditions(color) ..
				[[<ProgressBar width="100%" height="30" id="]] .. color .. [[_HealthBar" color='#00000080' fillImageColor="#44AA22FF" percentage="]] ..(state.health.current / state.health.max * 100) .. [[" textColor="#00000000"/>  ]] ..
				[[<Text id=']] .. color .. [[_HealthBar_Text' fontSize='25' height="30" onClick='UI_ModifyHealth' text=']] .. state.health.current.. [[/]] .. state.health.max.. [[' color='#ffffff' fontStyle='Bold' outline='#000000' outlineSize='1 1' />]] ..
			[[</Panel>
		]]
	end

	function Compact_HUDConditions(color)
		local size = 18
		local size2 = 10
		local row1 = 0
		local row2 = 0
		local output = [[<Panel width="100%" rectAlignment="MiddleLeft" position='0 0 0' > ]]
	
		for key, value in pairs(state.conditions) do
			if value ~= 0 then
				if row1 < 6 then
					output = output .. HUDSingleCondition(color, key, 0.5 + row1, 1.5, size2)
					row1 = row1 + 1
				else
					output = output .. HUDSingleCondition(color, key, 0.5 + row2, 2.5, size2)
					row2 = row2 + 1
				end
			end
		end
	
		output = output .. HUDSingleCondition(color, "Aura", 1.5, -1, size)
		output = output .. HUDSingleCondition(color, "Activated", 0.5, -1, size)
		output = output .. HUDSingleCondition(color, "Mode", 2.5, -1, size)
		output = output .. [[</Panel>]]
	
		return output
	end

	function HUDConditions(color)
		local size = 30;
		local row1 = 0;
		local row2 = 0;
		local output =  [[<Panel width="100%" rectAlignment="MiddleLeft" position='0 0 0' > ]]

		for key, value in pairs(state.conditions) do
			if value ~= 0 then
				if row1 < 4 then
					output = output .. HUDSingleCondition(color, key, row1, 1, size)
					row1 = row1 + 1
				else
					output = output .. HUDSingleCondition(color, key, row2, -1, size)
					row2 = row2 + 1
				end
			end
		end

		output = output .. HUDSingleCondition(color,"Aura", 4 ,1,size) 
		output = output .. HUDSingleCondition(color,"Activated", 4 ,0,size) 
		output = output .. HUDSingleCondition(color,"Mode", 4 ,-1,size) 
		output = output .. [[</Panel>]]

		return output
	end

    --Extras
	function UI_ModifyCondition(alt,name) if alt ~= '-3' then ModifyCondition({name=name,amount= (alt == '-1' and 1 or (alt == '-2' and -1) or 0 ) }) end end
	function UI_ModifyAura(p,alt) if alt ~= '-3' then ModifyAura({amount= (alt == '-1' and 1 or (alt == '-2' and -1) or 0 ) }) end end
	function UI_ModifyHealth(p,alt) if alt ~= '-3' then ModifyHealth({amount= (alt == '-1' and 1 or (alt == '-2' and -1) or 0 ) }) end end
	--Generic Tokens
	function UI_ModifyBurning(p,alt) UI_ModifyCondition("0","Burning") end
	function UI_ModifyPoison(p,alt) UI_ModifyCondition("0","Poison") end
	function UI_ModifyInjured(p,alt) UI_ModifyCondition("0","Injured") end
	function UI_ModifyBolstered(p,alt) UI_ModifyCondition("0","Bolstered") end
	function UI_ModifyDistracted(p,alt) UI_ModifyCondition("0","Distracted") end
	function UI_ModifyImpact(p,alt) UI_ModifyCondition("0","Impact") end
	function UI_ModifyEntranced(p,alt) UI_ModifyCondition("0","Entranced") end
	function UI_ModifyFast(p,alt) UI_ModifyCondition("0","Fast") end
	function UI_ModifySlow(p,alt) UI_ModifyCondition("0","Slow") end
	function UI_ModifyStunned(p,alt) UI_ModifyCondition("0","Stunned") end
	function UI_ModifyStaggered(p,alt) UI_ModifyCondition("0","Staggered") end
	function UI_ModifyHastened(p,alt) UI_ModifyCondition("0","Hastened") end
	function UI_ModifyAdversary(p,alt) UI_ModifyCondition("0","Adversary") end
	function UI_ModifyActivated(p,alt) UI_ModifyCondition("0","Activated") end
	function UI_ModifyMode(p,alt)  UI_ModifyCondition("0","Mode") end
	function UI_ModifyInsight(p,alt) UI_ModifyCondition("0","Insight") end
	function UI_ModifyFocused(p,alt) UI_ModifyCondition("0","Focused") end
	function UI_ModifyShielded(p,alt) UI_ModifyCondition("0","Shielded") end
    function UI_ModifyCraven(p,alt) UI_ModifyCondition("0","Craven") end
	function UI_ModifyAdaptable(p,alt) UI_ModifyCondition("0","Adaptable") end
    function UI_ModifySummon(p,alt) UI_ModifyCondition("0","Summon") end
    function UI_ModifyAuraHazardous(p,alt) UI_ModifyCondition("0","AuraHazardous") end
    function UI_ModifyAuraConcealment(p,alt) UI_ModifyCondition("0","AuraConcealment") end
    --SpecialTokens
    function UI_ModifyFlicker(p,alt) UI_ModifyCondition("0","Flicker") end
    function UI_ModifyBacktrack(p,alt) UI_ModifyCondition("0","Backtrack") end
    function UI_ModifyAuraNegligent(p,alt) UI_ModifyCondition("0","AuraNegligent") end
    function UI_ModifyAuraBinding(p,alt) UI_ModifyCondition("0","AuraBinding") end
    function UI_ModifyAnalyzed(p,alt) UI_ModifyCondition("0","Analyzed") end
    function UI_ModifyAuraFire(p,alt) UI_ModifyCondition("0","AuraFire") end
    function UI_ModifyGreedy(p,alt) UI_ModifyCondition("0","Greedy") end
    function UI_ModifyAuraFumes(p,alt) UI_ModifyCondition("0","AuraFumes") end
    function UI_ModifyEngorged(p,alt) UI_ModifyCondition("0","Engorged") end
    function UI_ModifyBroodling(p,alt) UI_ModifyCondition("0","Broodling") end
    function UI_ModifySuppresed(p,alt) UI_ModifyCondition("0","Suppresed") end
    function UI_ModifyFright(p,alt) UI_ModifyCondition("0","Fright") end
    function UI_ModifyChallenged(p,alt) UI_ModifyCondition("0","Challenged") end
    function UI_ModifyPower(p,alt) UI_ModifyCondition("0","Power") end
    function UI_ModifyGlowy(p,alt) UI_ModifyCondition("0","Glowy") end
    function UI_ModifyPerforated(p,alt) UI_ModifyCondition("0","Perforated") end
    function UI_ModifyBrilliance(p,alt) UI_ModifyCondition("0","Brilliance") end
    function UI_ModifyParasite(p,alt) UI_ModifyCondition("0","Parasite") end
    function UI_ModifyShame(p,alt) UI_ModifyCondition("0","Shame") end
    function UI_ModifySpiritualChains(p,alt) UI_ModifyCondition("0","SpiritualChains") end
    function UI_ModifyAuraStaggered(p,alt) UI_ModifyCondition("0","AuraStaggered") end
	function HUDSingleCondition(color,name,x,y,size)
	
		local id = "ConditionFrame_" .. name ;

		return [[<Panel id="]] .. id ..[[" width="]] ..size..[[" height="]] ..size..[[" alignment='LowerLeft' position=']] ..((x* (size +2)) - (1.5*size + 2)).. [[ ]] .. y*( (size +2)) .. [[ 0' ]] .. 
		[[onClick='UI_Modify]] .. name ..[[()'>]] ..
			HUDSingleConditionBody(color,name,size)..
		[[</Panel>]];
	end

	function HUDSingleConditionBody(color,name,size)
		local extrasKeys = { Mode = true, Aura = true, Activated = true }
		local secondary = Conditions[name].secondary;

		if extrasKeys[name] then
			local imageName = (secondary == nil and name or (state.extras[name] > 1 and name or secondary));
			local colorBlock = Conditions[imageName].color .. (state.extras[name] > 0  and 'ff' or '22'); --.. [[|]] .. Conditions[imageName].color .. [[ff|#00000000|#00000000]];
			return [[
				<Image id="]]..color ..[[_ConditionImage_]]..name ..[[" image="]] .. imageName .. [[" color="]] .. colorBlock .. [[" rectAlignment='LowerLeft' width=']] ..size..[[' height=']] ..size..[['/>
				<Text  id="]]..color ..[[_ConditionText_]]..name ..[[" active=']] .. (Conditions[name].stacks and state.extras[name] > 0 and 'true' or 'false')  ..[['  fontSize=']] ..math.floor(size*0.85)..[[' text=']] .. state.extras[name] .. [[' color='#ffffff' fontStyle='Bold'  rectAlignment='LowerLeft' outline='#000000' outlineSize='1 1' />
			]]
		end

		local imageName = (secondary == nil and name or (state.conditions[name] > 1 and name or secondary));
		local colorBlock = Conditions[imageName].color .. (state.conditions[name] > 0  and 'ff' or '22'); --.. [[|]] .. Conditions[imageName].color .. [[ff|#00000000|#00000000]];
		return [[
			<Image id="]]..color ..[[_ConditionImage_]]..name ..[[" image="]] .. imageName .. [[" color="]] .. colorBlock .. [[" rectAlignment='LowerLeft' width=']] ..size..[[' height=']] ..size..[['/>
			<Text  id="]]..color ..[[_ConditionText_]]..name ..[[" active=']] .. (Conditions[name].stacks and state.conditions[name] > 0 and 'true' or 'false')  ..[['  fontSize=']] ..math.floor(size*0.85)..[[' text=']] .. state.conditions[name] .. [[' color='#ffffff' fontStyle='Bold'  rectAlignment='LowerLeft' outline='#000000' outlineSize='1 1' />
		]]
	
	end


	Conditions = {
		Fast = { url="https://steamusercontent-a.akamaihd.net/ugc/1019447087554385209/698B13597E185E6ACA0AB19C13A118A3C1BEEB4D/", color="#E2D064", stacks=false },
		Slow = { url="https://steamusercontent-a.akamaihd.net/ugc/1019447087554366701/F479B20690BB037348F53B802F99B9B68ACFCCEA/", color="#B8B8B8", stacks=false },
		Adversary = { url="https://steamusercontent-a.akamaihd.net/ugc/1019447087554346517/81BCB3804E00F22B1E40D6A84C85C26F04F3C5CC/", color="#DF2020", stacks=false },
		Poison = { url="https://steamusercontent-a.akamaihd.net/ugc/1019447087554095214/37B3943D3C71EE6BFD13027145BDE00D0D56ED3B/", color="#83CD4D", stacks=false },
		Burning = { url="https://steamusercontent-a.akamaihd.net/ugc/1019447087554318009/A00031DC30FDC7D6EB7AEA3DFCF8AAD0754CD4CB/", color="#DB8E47", stacks=false },
		Focused = { url="https://steamusercontent-a.akamaihd.net/ugc/1019447087554725833/7B52C3AD5915BFC06B7E68025F5448C2862E0789/", color="#9A37D3", stacks=false },
		Distracted = { url="https://steamusercontent-a.akamaihd.net/ugc/1019447087554407310/DA85F94D429B073CEB18B2AB4F24FC0041F1CF30/", color="#FF42CF", stacks=false },
		Injured = { url="https://steamusercontent-a.akamaihd.net/ugc/1019447087554292969/5474B842DEC8F08CB249F3B24683FE95D58332FC/", color="#920606", stacks=false },
		Staggered = { url="https://steamusercontent-a.akamaihd.net/ugc/1019447087554150868/60F4FB8B23A6586775CB50311E1F7DD6BC0C1620/", color="#138C01", stacks=false },
		Stunned = { url="https://steamusercontent-a.akamaihd.net/ugc/1019447087554191671/98EB8191C3884783E74F6FF8066097D2D7296CBF/", color="#FFFFFF", stacks=false },
		Shielded = { url="https://steamusercontent-a.akamaihd.net/ugc/1019447087554495459/45E41E4CF603049EEF4B3EAB39DC0B3DC93DFE78/", color="#6AC3FF", stacks=false },
        Craven = { url="https://steamusercontent-a.akamaihd.net/ugc/28819418391028798/3AB3D764F98CEE306B56A7E6FE17AFFEFDBC2687/", color="#FF87DC", stacks=false },
		Impact = { url="https://steamusercontent-a.akamaihd.net/ugc/28819418391028913/081086FABAFA8AFAAFF52C72C72EDAA32F55AFD0/", color="#E9B175", stacks=false },
		Adaptable = { url="https://steamusercontent-a.akamaihd.net/ugc/28819418391028626/826E0ECCF3752137A1989CE47F8A7E1DF6FE4CCD/", color="#FFFFFF", stacks=false },
		Insight = { url="https://steamusercontent-a.akamaihd.net/ugc/28819418390300435/EED601E8B8F12D7360DFEA2B57A2B8AEBEE2174C/", color="#B7FFDF", stacks=false},
		Hastened = { url="https://steamusercontent-a.akamaihd.net/ugc/28819418390300292/CFDFBE1D760E16AA10E6E854866DA25F2D67CCF9/", color="#FEE711", stacks=false},
		Entranced = { url="https://steamusercontent-a.akamaihd.net/ugc/28819418390300201/69E94F23A27A360B496D5AC6F814AE0D29C03D17/", color="#A020F0", stacks=false},
		Bolstered = { url="https://steamusercontent-a.akamaihd.net/ugc/28819418390300000/32313584E40B0E1BCF00631370C61EBAF785F3C4/", color="#F53423", stacks=false},
        Summon={ url="https://steamusercontent-a.akamaihd.net/ugc/55841016162692762/7B070A76AD85B4DED02C679C0FC2D3DFC8CA3CBA/", color="#FFFFFF", stacks=false},
        AuraHazardous={ url="https://steamusercontent-a.akamaihd.net/ugc/55841016162692694/F49028E0DA3FB690A11582D1774A2370C955E86E/", color="#FFFFFF", stacks=false},
        AuraConcealment={ url="https://steamusercontent-a.akamaihd.net/ugc/55841016162692558/0B7B096736227AADEC0CBC8081E95057A375C6E3/", color="#FFFFFF", stacks=false},
        Flicker ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/Flicker.png?raw=true", color="#FFFFFF",stacks=false},
        Backtrack ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/Backtrack.png?raw=true", color="#FFFFFF",stacks=false},
        AuraNegligent ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/Aura%20(Negligent).png?raw=true", color="#FFFFFF",stacks=false},
        AuraBinding ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/Aura%20(Binding).png?raw=true", color="#FFFFFF",stacks=false},
        Analyzed ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/Analyzed.png?raw=true", color="#FFFFFF",stacks=false},
        AuraFire ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/Aura%20(Fire).png?raw=true", color="#FFFFFF",stacks=false},
        Greedy ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/Greedy.png?raw=true", color="#FFFFFF",stacks=false},
        AuraFumes ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/Aura%20(Fumes).png?raw=true", color="#FFFFFF",stacks=false},
        Engorged ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/Engorged.png?raw=true", color="#FFFFFF",stacks=false},
        Broodling ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/Broodling.png?raw=true", color="#FFFFFF",stacks=false},
        Suppresed ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/Suppressed.png?raw=true", color="#FFFFFF",stacks=false},
        Fright ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/Fright.png?raw=true", color="#FFFFFF",stacks=false},
        Challenged ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/Challenged.png?raw=true", color="#FFFFFF",stacks=false},
        Power ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/Power.png?raw=true", color="#FFFFFF",stacks=false},
        Glowy ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/Glowy.png?raw=true", color="#FFFFFF",stacks=false},
        Perforated ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/Perforated.png?raw=true", color="#FFFFFF",stacks=false},
        Brilliance ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/Brilliance.png?raw=true", color="#FFFFFF",stacks=false},
        Parasite ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/Parasite.png?raw=true", color="#FFFFFF",stacks=false},
        Shame ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/Shame.png?raw=true", color="#FFFFFF",stacks=false},
        SpiritualChains ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/SpiritualChains.png?raw=true", color="#FFFFFF",stacks=false},
        AuraStaggered ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/Aura%20(Staggered).png?raw=true", color="#FFFFFF",stacks=false},
		Aura = { url="https://raw.githubusercontent.com/RobMayer/TTSLibrary/master/ui/movenode.png", color="#99aa22", stacks=true },
		Activated  = { url="https://raw.githubusercontent.com/RobMayer/TTSLibrary/master/ui/flag.png", color="#bbbb22", stacks=false },
		Mode  = { url="https://raw.githubusercontent.com/RobMayer/TTSLibrary/master/ui/gear.png", color="#bbffbb", stacks=false, loop = 2 }
		
	}

------ Object SPAWMERS ----------------------

	function showAura()

		local a=(state.extras.Aura > 0) and (state.extras.Aura+(state.base.size/50)) or 0; --based on model base size
	
		local me = self
		local clr = self.getColorTint()
			ChildObjs.aura_obj=spawnObject({
			type='custom_model',
			position=self.getPosition(),
			rotation=self.getRotation(),
			scale={a,1,a},
			mass=0,
			use_gravity=false,
			sound=false,
			snap_to_grid=false,
			callback_function=function(b)
				b.setColorTint(clr)
				b.setVar('parent',self)
				b.setLuaScript([[
					local lastParent = nil
					local clock = 2
					function onLoad() 
						(self.getComponent('BoxCollider') or self.getComponent('MeshCollider')).set('enabled',false)
						Wait.condition(
							function() 
								(self.getComponent('BoxCollider') or self.getComponent('MeshCollider')).set('enabled',false) 
							end, 
							function() 
								return not(self.loading_custom) 
							end
						) 
					end 
					function onUpdate() 
						if (parent ~= nil) then 
							if clock < 0 then
								clock = 2;
								if self.getPosition():distance(parent.getPosition()) > 0.01 then
									self.setPosition(parent.getPosition())
									self.setRotation(parent.getRotation()) 
								end
							else
								clock = clock - 1
							end
						else 
							self.destruct() 
						end 
					end
				]])
				b.getComponent('MeshRenderer').set('receiveShadows',false)
				b.mass=0
				b.bounciness=0
				b.drag=0
				b.use_snap_points=false
				b.use_grid=false
				b.use_gravity=false
				b.auto_raise=false
				b.auto_raise=false
				b.sticky=false
				b.interactable=false
			end
		})
		ChildObjs.aura_obj.setCustomObject({
			mesh='https://raw.githubusercontent.com/RobMayer/TTSLibrary/master/components/arcs/round0.obj',
			collider='https://raw.githubusercontent.com/RobMayer/TTSLibrary/master/utility/null_COL.obj',
			material=3,
			specularIntensity=0,
			cast_shadows=false
		})
	end
------ Wip ----------------------------------
	function addMarker(config)
		
        local name=config.name:gsub("%(",""):gsub("%)",""):gsub("%s+","")
		if Conditions[name] then
			if state.conditions[name]==0 then
				ModifyCondition({name=name,amount= 1 })
			else
				ModifyCondition({name=name,amount= -1 })
			end --[[
			if name=="Fast" then
				if state.conditions["Fast"]==1 then
					ModifyCondition({name="Fast",amount= 2 })
				else
					state.conditions["Fast"]=0
					ModifyCondition({name="Fast",amount= 2 })    
				end
			elseif name=="Slow" then
				if state.conditions["Fast"]==2 then
					ModifyCondition({name="Fast",amount= 1 })
				else
					state.conditions["Fast"]=0
					ModifyCondition({name="Fast",amount= 1 })    
				end
			else
				
				       
			end
			]]
			return true

		else
			return false
		end
	end

	function end_round() 
		ModifyCondition({name="Activated",amount= -1 })
		if state.conditions["Poison"]>0 then
			ModifyCondition({name="Poison",amount= -1 })
			ModifyHealth({amount=-1})
			extra_damage = math.floor(state.conditions["Poison"]/3)
			ModifyHealth({amount=extra_damage*-1})
		end
		if state.conditions["Burning"]>0 then
			ModifyHealth({amount=-1})
			extra_damage = math.floor(state.condition["Burning"]/3)
			ModifyHealth({amount=extra_damage*-1})
		end
		ModifyCondition({name="Injured",amount= -1 })
		ModifyCondition({name="Adversary",amount= -1 })
	end
------ END ----------------------------------