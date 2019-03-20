

function OnSpellStart (keys)
	if not IsServer() then return nil end

	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() -1 
	local illusion_count = ability:GetLevelSpecialValueFor("illusion_count", ability_level)


	for i=1,illusion_count do
		local illusion = CreateIllusion(caster, ability)
		illusion._mjz_spectre_haunt_illusion = true
	end

end

function OnIllusionTakeDamage( keys )
	if not IsServer() then return nil end


	local unit = keys.unit
	local attacker = keys.attacker
	local attack_damage = keys.DamageTaken

	if unit._mjz_spectre_haunt_illusion then
		unit:Heal(attack_damage, nil)
		local hero = unit:GetOwnerEntity()
		hero:Heal(attack_damage, nil)
	end
	
end

function LevelUpReality (keys)
	local caster = keys.caster
	local ability_reality = caster:FindAbilityByName("spectre_reality")
	if ability_reality ~= nil then
		ability_reality:SetLevel(1)
	end

	caster.haunting = false
end


function CreateIllusion(caster, ability)
	local unit = caster:GetUnitName()
	local origin = caster:GetAbsOrigin() + RandomVector(100)
	local ability_level = ability:GetLevel() -1 
	local duration  = ability:GetLevelSpecialValueFor("illusion_duration", ability_level)
	local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_outgoing_damage", ability_level )
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage", ability_level )


	local illusion = CreateUnitByName(unit, origin, true, caster, nil, caster:GetTeamNumber())
	illusion:SetPlayerID(caster:GetPlayerID())
	illusion:SetOwner(caster)

	-- illusion:SetForwardVector(target:GetAbsOrigin() - illusion:GetAbsOrigin())

	-- Level Up the unit to the casters level
	local casterLevel = caster:GetLevel()
	for i=1,casterLevel-1 do
		illusion:HeroLevelUp(false)
	end

	-- Set the skill points to 0 and learn the skills of the caster
	illusion:SetAbilityPoints(0)
	for abilitySlot=0,15 do
		local ability = caster:GetAbilityByIndex(abilitySlot)
		if ability ~= nil then 
			local abilityLevel = ability:GetLevel()
			local abilityName = ability:GetAbilityName()
			local illusionAbility = illusion:FindAbilityByName(abilityName)
			illusionAbility:SetLevel(abilityLevel)
		end
	end

	-- Recreate the items of the caster
	for itemSlot=0,5 do
		local item = caster:GetItemInSlot(itemSlot)
		local item_illusion = illusion:GetItemInSlot(itemSlot)
		if item_illusion then
			item_illusion:RemoveSelf()
		end
		if item ~= nil then
			local itemName = item:GetName()
			local newItem = CreateItem(itemName, illusion, illusion)
			illusion:AddItem(newItem)
		end
	end

	-- Set the unit as an illusion
	illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
	
	-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
	illusion:MakeIllusion()

	-- illusion:AddNewModifier(caster, ability, "modifier_mjz_spectre_haunt_illusion_buff", {})
	ability:ApplyDataDrivenModifier(caster, illusion, "modifier_mjz_spectre_haunt_illusion_buff", {})

	return illusion
end

