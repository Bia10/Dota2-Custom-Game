

function OnOrbImpact( keys )
    if not IsServer() then return nil end

	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local modifier_name = keys.modifier_name
    local modifier_counter_name = keys.modifier_counter_name
    
	local spear_aoe = ability:GetLevelSpecialValueFor( "spear_aoe" , ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor( "burn_duration" , ability:GetLevel() - 1 )
    
	local enemy_list = FindTargetEnemy(caster, target:GetAbsOrigin(), spear_aoe)
    for _,enemy in pairs(enemy_list) do

        IncreaseModifierStackCount({
            caster = caster, ability = ability, target = enemy,
            modifier_name = modifier_counter_name, duration = duration
        })

        ability:ApplyDataDrivenModifier(caster, enemy, modifier_name, {duration = duration})		
	end
end


--[[
    Removes HP for using Burning Spear
    This is called everytime the ability is used (manual left-click or via auto-cast right-click)
]]
function DoHealthCost( event )
    local caster = event.caster
    local ability = event.ability
    local health_cost = ability:GetLevelSpecialValueFor( "health_cost" , ability:GetLevel() - 1  )
    local health = caster:GetHealth()
    local new_health = (health - health_cost)

    -- "do damage"
    -- aka set the casters HP to the new value
    -- ModifyHealth's third parameter lets us decide if the healthcost should be lethal
    caster:ModifyHealth(new_health, ability, false, 0)
end

function IncreaseModifierStackCount( kv )
    local caster = kv.caster
    local ability = kv.ability
    local target = kv.target
    local modifier_name = kv.modifier_name
    local duration = kv.duration

    local modifier = target:FindModifierByName(modifier_name)
    local count = target:GetModifierStackCount(modifier_name, caster)

    if modifier then
        target:SetModifierStackCount(modifier_name, caster, count + 1)
        modifier:SetDuration(duration, true)
    else
        ability:ApplyDataDrivenModifier(caster, target, modifier_name, { duration = duration })
        target:SetModifierStackCount(modifier_name, caster, 1) 
    end
end


--[[
    Increases stack count on the visual modifier
    This is called everytime an enemy is hit by burning_spear
]]
function IncreaseStackCount( event )
    local caster = event.caster
    local target = event.target
    local ability = event.ability
    local modifier_name = event.modifier_counter_name
    local dur = ability:GetLevelSpecialValueFor( "burn_duration" , ability:GetLevel() - 1 )

    local modifier = target:FindModifierByName(modifier_name)
    local count = target:GetModifierStackCount(modifier_name, caster)

    -- if the unit does not already have the counter modifier we apply it with a stackcount of 1
    -- else we increase the stack and refresh the counters duration
    if not modifier then
        ability:ApplyDataDrivenModifier(caster, target, modifier_name, {duration=dur})
        target:SetModifierStackCount(modifier_name, caster, 1) 
    else
        target:SetModifierStackCount(modifier_name, caster, count+1)
        modifier:SetDuration(dur, true)
    end
end

--[[
    Decreases stack count on the visual modifier 
    This is called whenever the debuff modifier runs out
]]
function DecreaseStackCount(event)
    local caster = event.caster
    local target = event.target
    local modifier_name = event.modifier_counter_name
    local modifier = target:FindModifierByName(modifier_name)
    local count = target:GetModifierStackCount(modifier_name, caster)

    -- just some saftey checks -just in case
    if modifier then

        -- if there is something to reduce reduce
        -- else just remove the modifier
        if count and count > 1 then
            target:SetModifierStackCount(modifier_name, caster, count-1)
        else
            target:RemoveModifierByName(modifier_name)
        end
    end
end

-- 搜索目标位置所有的敌人单位
function FindTargetEnemy(unit, point, radius)
    local iTeamNumber = unit:GetTeamNumber()
    local vPosition = point   				-- 搜索中心点
    local hCacheUnit = nil                  -- 通常值
    local flRadius = radius                 -- 搜索范围
    local iTeamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY  -- 目标是敌人单位
    -- 目标单位类型
    local iTypeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC --DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP           
    local iFlagFilter = DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE     -- 忽视建筑物
    local iOrder = FIND_CLOSEST                         -- 寻找最近的
    local bCanGrowCache = false             -- 通常值
    return FindUnitsInRadius( iTeamNumber, vPosition, hCacheUnit, 
        flRadius, iTeamFilter, iTypeFilter, iFlagFilter, iOrder, bCanGrowCache )
end