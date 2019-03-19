LinkLuaModifier("modifier_mjz_templar_assassin_proficiency_debuff", "modifiers/hero_templar_assassin/modifier_mjz_templar_assassin_proficiency_debuff.lua", LUA_MODIFIER_MOTION_NONE)

function OnAttack( event )
	if not IsServer() then return nil end

	local caster = event.caster
	local ability = event.ability
end

function OnProjectileHitUnit( event )
	if not IsServer() then return nil end

	local caster = event.caster
	local target = event.target
	local ability = event.ability

	if IsInToolsMode() then
		print("mjz_templar_assassin_proficiency : OnProjectileHitUnit")
		for k,v in pairs(event) do
			print("    ",k,v)
		end
	end

	local armor_reduction_duration = ability:GetLevelSpecialValueFor("armor_reduction_duration", ability:GetLevel() - 1)
	local armor_reduction_percent = ability:GetLevelSpecialValueFor("armor_reduction_percent", ability:GetLevel() - 1)
	local modifier_name = "modifier_mjz_templar_assassin_proficiency_debuff"
	

	if ability:GetToggleState() then
		EmitSoundOn('Hero_TemplarAssassin.Meld.Attack', target)
	end
	

	local modifier = target:FindModifierByName(modifier_name)
	if modifier then -- target:HasModifier(modifier_name)
		-- target:RemoveModifierByName(modifier_name)
		-- modifier:SetDuration(armor_reduction_duration, false)
		modifier:ForceRefresh()
	else
		local modifier_table = { 
			duration = armor_reduction_duration,
			armor_reduction_percent = armor_reduction_percent,
		} 
		ability:ApplyDataDrivenModifier(caster, target, modifier_name, modifier_table)
	end
	
end