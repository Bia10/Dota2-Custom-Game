

function hex( keys )
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1
    local modifier_target = "modifier_mjz_luck_sheepstick_target"

    local duration = ability:GetLevelSpecialValueFor("sheep_duration", ability_level)
    local sheep_chance = ability:GetLevelSpecialValueFor("sheep_chance", ability_level)
    local chance_scepter = ability:GetLevelSpecialValueFor("chance_scepter", ability_level)
    
    if IsServer() then
		local ability_target = target
		if caster:HasScepter() then     -- 有神杖时，增加成功几率
			sheep_chance = sheep_chance + chance_scepter
		end
		if math.random(100) > sheep_chance then
			ability_target = caster
		end
		
        -- EmitSoundOn("Hero_Lion.Voodoo", ability_target)
        EmitSoundOn("DOTA_Item.Sheepstick.Activate", ability_target)
        -- EmitSoundOn("Hero_Lion.Hex.Target", ability_target)
        if ability_target:IsIllusion() then
            ability_target:ForceKill(true)
        else
            ability:ApplyDataDrivenModifier(caster, ability_target, modifier_target, {duration = duration})
            
            local model_name = RandomChooseModel()        
            ability_target:SetModel(model_name)
        end
    end
   
end

function RandomChooseModel()
    local model_list = {
        "models/props_gameplay/frog.vmdl",
        "models/props_gameplay/chicken.vmdl",
        "models/props_gameplay/pig.vmdl",
        "models/items/hex/sheep_hex/sheep_hex.vmdl",
        "models/items/hex/sheep_hex/sheep_hex_gold.vmdl",
        "models/courier/navi_courier/navi_courier.vmdl"
    }

    return model_list[ math.random( #model_list ) ] 
end