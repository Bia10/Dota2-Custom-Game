
function ReturnDamage( event )
	if not IsServer() then return nil end

	local caster = event.caster
	local attacker = event.attacker
	local ability = event.ability
	local caster_str = caster:GetStrength()
	local str_return = ability:GetLevelSpecialValueFor( "strength_pct" , ability:GetLevel() - 1  ) * 0.01
	local damage = ability:GetLevelSpecialValueFor( "return_damage" , ability:GetLevel() - 1  )
	local damageType = ability:GetAbilityDamageType()
	local return_damage = damage + ( caster_str * str_return )

	-- Damage
	if attacker:GetTeamNumber() ~= caster:GetTeamNumber() then
		ApplyDamage({ 
			victim = attacker, attacker = caster, 
			damage = return_damage, damage_type = damageType 
		})
	end

end