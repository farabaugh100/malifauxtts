RSS_Class = 'Model';
TRH_Class ="mini"
------ CLASS VARIABLES ----------------------

	local ChildObjs = {
		aura_obj = nil
	};
	local Conditions = {}
	local originalData = nil;
	local state = {
		conditions={Abandoned = 0,Adaptable = 0,Adversary = 0,Analyzed = 0,AuraBinding = 0,AuraConcealment = 0,AuraFire = 0,AuraFumes = 0,AuraHazardous = 0,AuraNegligent = 0,AuraStaggered = 0,Backtrack = 0,BogSpirit = 0,Bolstered = 0,Brilliance = 0,Broodling = 0,Burning = 0,Challenged = 0,CoveredInBlood = 0,Craven = 0,CruelWhispers = 0,Distracted = 0,Drift = 0,Engorged = 0,Entranced = 0,Familia = 0,Fast = 0,Flicker = 0,Focused = 0,FragileEgo = 0,Fright = 0,Glowy = 0,Greedy = 0,Hastened = 0,Hunger = 0,Impact = 0,ImprovisedPart = 0,Injured = 0,Insight = 0,NewBlood = 0,Paranoia = 0,Parasite = 0,Perforated = 0,Poison = 0,Power = 0,Reload = 0,Shame = 0,Shielded = 0,Sin = 0,Slow = 0,SpiritualChains = 0,Staggered = 0,Stunned = 0,Summon = 0,Suppresed = 0,Adaptable = 0,Focused = 0,Shielded = 0,}		
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
	function UI_ModifyActivated(p,alt) UI_ModifyCondition("0","Activated") end
	function UI_ModifyMode(p,alt) UI_ModifyCondition("0","Mode") end
	function UI_ModifyHealth(p,alt) if alt ~= '-3' then ModifyHealth({amount= (alt == '-1' and 1 or (alt == '-2' and -1) or 0 ) }) end end

	function UI_ModifyAbandoned(p,alt) UI_ModifyCondition("0","Abandoned") end
	function UI_ModifyAdaptable(p,alt) UI_ModifyCondition("0","Adaptable") end
	function UI_ModifyAdversary(p,alt) UI_ModifyCondition("0","Adversary") end
	function UI_ModifyAnalyzed(p,alt) UI_ModifyCondition("0","Analyzed") end
	function UI_ModifyAuraBinding(p,alt) UI_ModifyCondition("0","AuraBinding") end
	function UI_ModifyAuraConcealment(p,alt) UI_ModifyCondition("0","AuraConcealment") end
	function UI_ModifyAuraFire(p,alt) UI_ModifyCondition("0","AuraFire") end
	function UI_ModifyAuraFumes(p,alt) UI_ModifyCondition("0","AuraFumes") end
	function UI_ModifyAuraHazardous(p,alt) UI_ModifyCondition("0","AuraHazardous") end
	function UI_ModifyAuraNegligent(p,alt) UI_ModifyCondition("0","AuraNegligent") end
	function UI_ModifyAuraStaggered(p,alt) UI_ModifyCondition("0","AuraStaggered") end
	function UI_ModifyBacktrack(p,alt) UI_ModifyCondition("0","Backtrack") end
	function UI_ModifyBogSpirit(p,alt) UI_ModifyCondition("0","BogSpirit") end
	function UI_ModifyBolstered(p,alt) UI_ModifyCondition("0","Bolstered") end
	function UI_ModifyBrilliance(p,alt) UI_ModifyCondition("0","Brilliance") end
	function UI_ModifyBroodling(p,alt) UI_ModifyCondition("0","Broodling") end
	function UI_ModifyBurning(p,alt) UI_ModifyCondition("0","Burning") end
	function UI_ModifyChallenged(p,alt) UI_ModifyCondition("0","Challenged") end
	function UI_ModifyCoveredInBlood(p,alt) UI_ModifyCondition("0","CoveredInBlood") end
	function UI_ModifyCraven(p,alt) UI_ModifyCondition("0","Craven") end
	function UI_ModifyCruelWhispers(p,alt) UI_ModifyCondition("0","CruelWhispers") end
	function UI_ModifyDistracted(p,alt) UI_ModifyCondition("0","Distracted") end
	function UI_ModifyDrift(p,alt) UI_ModifyCondition("0","Drift") end
	function UI_ModifyEngorged(p,alt) UI_ModifyCondition("0","Engorged") end
	function UI_ModifyEntranced(p,alt) UI_ModifyCondition("0","Entranced") end
	function UI_ModifyFamilia(p,alt) UI_ModifyCondition("0","Familia") end
	function UI_ModifyFast(p,alt) UI_ModifyCondition("0","Fast") end
	function UI_ModifyFlicker(p,alt) UI_ModifyCondition("0","Flicker") end
	function UI_ModifyFocused(p,alt) UI_ModifyCondition("0","Focused") end
	function UI_ModifyFragileEgo(p,alt) UI_ModifyCondition("0","FragileEgo") end
	function UI_ModifyFright(p,alt) UI_ModifyCondition("0","Fright") end
	function UI_ModifyGlowy(p,alt) UI_ModifyCondition("0","Glowy") end
	function UI_ModifyGreedy(p,alt) UI_ModifyCondition("0","Greedy") end
	function UI_ModifyHastened(p,alt) UI_ModifyCondition("0","Hastened") end
	function UI_ModifyHunger(p,alt) UI_ModifyCondition("0","Hunger") end
	function UI_ModifyImpact(p,alt) UI_ModifyCondition("0","Impact") end
	function UI_ModifyImprovisedPart(p,alt) UI_ModifyCondition("0","ImprovisedPart") end
	function UI_ModifyInjured(p,alt) UI_ModifyCondition("0","Injured") end
	function UI_ModifyInsight(p,alt) UI_ModifyCondition("0","Insight") end
	function UI_ModifyNewBlood(p,alt) UI_ModifyCondition("0","NewBlood") end
	function UI_ModifyParanoia(p,alt) UI_ModifyCondition("0","Paranoia") end
	function UI_ModifyParasite(p,alt) UI_ModifyCondition("0","Parasite") end
	function UI_ModifyPerforated(p,alt) UI_ModifyCondition("0","Perforated") end
	function UI_ModifyPoison(p,alt) UI_ModifyCondition("0","Poison") end
	function UI_ModifyPower(p,alt) UI_ModifyCondition("0","Power") end
	function UI_ModifyReload(p,alt) UI_ModifyCondition("0","Reload") end
	function UI_ModifyShame(p,alt) UI_ModifyCondition("0","Shame") end
	function UI_ModifyShielded(p,alt) UI_ModifyCondition("0","Shielded") end
	function UI_ModifySin(p,alt) UI_ModifyCondition("0","Sin") end
	function UI_ModifySlow(p,alt) UI_ModifyCondition("0","Slow") end
	function UI_ModifySpiritualChains(p,alt) UI_ModifyCondition("0","SpiritualChains") end
	function UI_ModifyStaggered(p,alt) UI_ModifyCondition("0","Staggered") end
	function UI_ModifyStunned(p,alt) UI_ModifyCondition("0","Stunned") end
	function UI_ModifySummon(p,alt) UI_ModifyCondition("0","Summon") end
	function UI_ModifySuppresed(p,alt) UI_ModifyCondition("0","Suppresed") end
	function UI_ModifyAdaptable(p,alt) UI_ModifyCondition("0","Adaptable") end
	function UI_ModifyFocused(p,alt) UI_ModifyCondition("0","Focused") end
	function UI_ModifyShielded(p,alt) UI_ModifyCondition("0","Shielded") end
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
		Aura = { url="https://raw.githubusercontent.com/RobMayer/TTSLibrary/master/ui/movenode.png", color="#99aa22", stacks=true },
		Activated  = { url="https://raw.githubusercontent.com/RobMayer/TTSLibrary/master/ui/flag.png", color="#bbbb22", stacks=false },
		Mode  = { url="https://raw.githubusercontent.com/RobMayer/TTSLibrary/master/ui/gear.png", color="#bbffbb", stacks=false, loop = 2 },
		
		Adaptable ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Adaptable.png", color="#FFFFFF",stacks=false},
		Adversary ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Adversary.png", color="#DF2020",stacks=false},
		Analyzed ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Analyzed.png", color="#FFFFFF",stacks=false},
		AuraBinding ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Aura%20(Binding).png", color="#FFFFFF",stacks=false},
		AuraConcealment ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Aura%20(Concealment).png", color="#FFFFFF",stacks=false},
		AuraFire ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Aura%20(Fire).png", color="#FFFFFF",stacks=false},
		AuraFumes ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Aura%20(Fumes).png", color="#FFFFFF",stacks=false},
		AuraHazardous ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Aura%20(Hazardous).png", color="#FFFFFF",stacks=false},
		AuraNegligent ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Aura%20(Negligent).png", color="#FFFFFF",stacks=false},
		AuraStaggered ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Aura%20(Staggered).png", color="#FFFFFF",stacks=false},
		Backtrack ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Backtrack.png", color="#FFFFFF",stacks=false},
		BogSpirit ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/refs/heads/main/assets/Tokens/Bog%20Spirit.png", color="#FFFFFF",stacks=false},
		Bolstered ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Bolstered.png", color="#F53423",stacks=false},
		Brilliance ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Brilliance.png", color="#FFFFFF",stacks=false},
		Broodling ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Broodling.png", color="#FFFFFF",stacks=false},
		Burning ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Burning.png", color="#DB8E47",stacks=false},
		Challenged ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Challenged.png", color="#FFFFFF",stacks=false},
		CoveredInBlood ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/refs/heads/main/assets/Tokens/Covered%20In%20Blood.png", color="#FFFFFF",stacks=false},
		Craven ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Craven.png", color="#FF87DC",stacks=false},
		CruelWhispers ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/refs/heads/main/assets/Tokens/Cruel%20Whispers.png", color="#FFFFFF",stacks=false},
		Distracted ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Distracted.png", color="#FF42CF",stacks=false},
		Drift ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Drift.png", color="#FFFFFF",stacks=false},
		Engorged ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Engorged.png", color="#FFFFFF",stacks=false},
		Entranced ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Entranced.png", color="#A020F0",stacks=false},
		Familia ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/refs/heads/main/assets/Tokens/Familia.png", color="#FFFFFF",stacks=false},
		Fast ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Fast.png", color="#E2D064",stacks=false},
		Flicker ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Flicker.png", color="#FFFFFF",stacks=false},
		Focused ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Focused.png", color="#9A37D3",stacks=false},
		FragileEgo ={ url="https://github.com/farabaugh100/malifauxtts/blob/main/assets/Tokens/Fragile%20Ego.png?raw=true", color="#FFFFFF",stacks=false},
		Fright ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Fright.png", color="#FFFFFF",stacks=false},
		Glowy ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Glowy.png", color="#FFFFFF",stacks=false},
		Greedy ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Greedy.png", color="#FFFFFF",stacks=false},
		Hastened ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Hastened.png", color="#FEE711",stacks=false},
		Hunger ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/refs/heads/main/assets/Tokens/Hunger.png", color="#FFFFFF",stacks=false},
		Impact ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Impact.png", color="#E9B175",stacks=false},
		ImprovisedPart ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/refs/heads/main/assets/img/Tokens/ImprovisedPart.png", color="#FFFFFF",stacks=false},
		Injured ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Injured.png", color="#920606",stacks=false},
		Insight ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Insight.png", color="#B7FFDF",stacks=false},
		NewBlood ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/refs/heads/main/assets/Tokens/NewBlood.png", color="#FFFFFF",stacks=false},
		Paranoia ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/refs/heads/main/assets/Tokens/Paranoia.png", color="#FFFFFF",stacks=false},
		Parasite ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Parasite.png", color="#FFFFFF",stacks=false},
		Perforated ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Perforated.png", color="#FFFFFF",stacks=false},
		Poison ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Poisoned.png", color="#83CD4D",stacks=false},
		Power ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Power.png", color="#FFFFFF",stacks=false},
		Reload ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/refs/heads/main/assets/Tokens/Reload.png", color="#FFFFFF",stacks=false},
		Shame ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Shame.png", color="#FFFFFF",stacks=false},
		Shielded ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Shielded.png", color="#6AC3FF",stacks=false},
		Sin ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Sin.png", color="#FFFFFF",stacks=false},
		Slow ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Slowed.png", color="#B8B8B8",stacks=false},
		SpiritualChains ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/SpiritualChains.png", color="#FFFFFF",stacks=false},
		Staggered ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Staggered.png", color="#138C01",stacks=false},
		Stunned ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Stunned.png", color="#FFFFFF",stacks=false},
		Summon ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Summon.png", color="#FFFFFF",stacks=false},
		Suppresed ={ url="https://raw.githubusercontent.com/farabaugh100/malifauxtts/main/assets/img/Tokens/Suppressed.png", color="#FFFFFF",stacks=false},
		
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