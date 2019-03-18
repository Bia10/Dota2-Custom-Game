
function OnSpellStart( event )
	if not IsServer() then return nil end

	local caster = event.caster
	local ability = event.ability
	
	local unit = caster
	local modifier_health_name = 'modifier_mjz_dragon_knight_elder_dragon_relieve_health'

	local modifier_dragon_form = unit:FindModifierByName('modifier_dragon_knight_dragon_form')
	local modifier_corrosive_breath = unit:FindModifierByName('modifier_dragon_knight_corrosive_breath')
	local modifier_splash_attack = unit:FindModifierByName('modifier_dragon_knight_splash_attack')
	local modifier_frost_breath = unit:FindModifierByName('modifier_dragon_knight_frost_breath')

	if  modifier_dragon_form then
		modifier_dragon_form:SetDuration(0.1, false)
		if modifier_corrosive_breath then
			modifier_corrosive_breath:SetDuration(0.1, false)
		end
		if modifier_splash_attack then
			modifier_splash_attack:SetDuration(0.1, false)
		end
		if modifier_frost_breath then
			modifier_frost_breath:SetDuration(0.1, false)
		end

		if unit:HasModifier(modifier_health_name) then
			unit:RemoveModifierByName(modifier_health_name)	
		end
	end
end

function OnCreated( event )
	if not IsServer() then return nil end

	local caster = event.caster
	local ability = event.ability

end

function OnIntervalThink( event )
	if not IsServer() then return nil end

	local caster = event.caster
	local ability = event.ability
	
	local unit = caster
	local modifier_health_name = 'modifier_mjz_dragon_knight_elder_dragon_relieve_health'

	local modifier_dragon_form = unit:FindModifierByName('modifier_dragon_knight_dragon_form')
	local modifier_corrosive_breath = unit:FindModifierByName('modifier_dragon_knight_corrosive_breath')
	local modifier_splash_attack = unit:FindModifierByName('modifier_dragon_knight_splash_attack')
	local modifier_frost_breath = unit:FindModifierByName('modifier_dragon_knight_frost_breath')

	if unit:HasScepter() and modifier_dragon_form then
		modifier_dragon_form:SetDuration(60.0, false)
		if modifier_corrosive_breath then
			modifier_corrosive_breath:SetDuration(60.0, false)
		end
		if modifier_splash_attack then
			modifier_splash_attack:SetDuration(60.0, false)
		end
		if modifier_frost_breath then
			modifier_frost_breath:SetDuration(60.0, false)
		end

		if not unit:HasModifier(modifier_health_name) then
			unit:AddNewModifier(unit, ability, modifier_health_name, {})
			-- ability:ApplyDataDrivenModifier(ability, unit, modifier_health_name, {})
		end
	else
		unit:RemoveModifierByName(modifier_health_name)	
	end
end

--------------------------------------------------------------------------------------------

LinkLuaModifier("modifier_mjz_dragon_knight_elder_dragon_relieve_health", "abilities/hero_dragon_knight/mjz_dragon_knight_elder_dragon_relieve.lua", LUA_MODIFIER_MOTION_NONE)

modifier_mjz_dragon_knight_elder_dragon_relieve_health = class({})
function modifier_mjz_dragon_knight_elder_dragon_relieve_health:IsHidden()
    return true
end
function modifier_mjz_dragon_knight_elder_dragon_relieve_health:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE
    }
    return funcs
end
function modifier_mjz_dragon_knight_elder_dragon_relieve_health:GetModifierHealthRegenPercentage( params )
	return -1.0
end


