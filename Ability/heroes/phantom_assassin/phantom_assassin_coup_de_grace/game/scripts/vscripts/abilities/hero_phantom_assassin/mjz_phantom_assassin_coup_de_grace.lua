
local modifier_crit = 'modifier_mjz_phantom_assassin_coup_de_grace_crit'

function OnOrbFire(event)
	-- print('OnOrbFire')
	local caster = event.caster
	local ability = event.ability

	if IsCrit(event) then
		PlayEffect(event)
	end

	caster:RemoveModifierByName(modifier_crit)

	OnRandomStart(event)
end

function OnOrbImpact(event)
	-- print('OnOrbImpact')
	local caster = event.caster
	local ability = event.ability
end

function OnAttackStart( event )
	-- print('OnAttackStart')
end

function OnAttackLanded( event )
	-- print('OnAttackLanded')
end

function IsCrit( event )
	local caster = event.caster
	local ability = event.ability
	return caster:HasModifier(modifier_crit) 
end

function OnRandomStart( event )
	local caster = event.caster
	local ability = event.ability
	local target = event.target

	local crit_chance = GetTalentSpecialValueFor(ability, 'crit_chance')

	-- "PseudoRandom"	"DOTA_PSEUDO_RANDOM_PHANTOMASSASSIN_CRIT"
	local random_value = RandomInt(1, 100)
    if random_value <= crit_chance  then
        OnRandomSuccess(event)
    end
end

function OnRandomSuccess( event )
	-- print('OnRandomSuccess')
	local caster = event.caster
	local ability = event.ability
	local attacker = event.attacker
	local target = event.target

	local c1 = ( target:IsBuilding() == false ) and ( target:IsOther() == false ) 
	local c2 = ( attacker:GetTeamNumber() ~= target:GetTeamNumber() )
	if c1 and c2 then
		ability:ApplyDataDrivenModifier(caster, caster, modifier_crit, {duration=-1})
	end
end

function PlayEffect( event )
	if not IsServer() then return nil end

	local caster = event.caster
	local target = event.target
	local ability = event.ability

	target:EmitSound('Hero_PhantomAssassin.CoupDeGrace')

	local effect_name = GetEffectName(caster, target)

	local nFXIndex = ParticleManager:CreateParticle( effect_name, PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControlEnt( nFXIndex, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true )
	ParticleManager:SetParticleControl( nFXIndex, 1, target:GetOrigin() )
	ParticleManager:SetParticleControlForward( nFXIndex, 1, -caster:GetForwardVector())
	ParticleManager:SetParticleControlEnt( nFXIndex, 10, target, PATTACH_ABSORIGIN_FOLLOW, nil, target:GetOrigin(), true )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
	
end

function GetEffectName( caster, target )
	local effect_crit_impact_dagger_mechanical = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact_dagger_mechanical.vpcf"
	local effect_crit_impact_dagger_mechanical_arcana = "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/phantom_assassin_crit_impact_dagger_mechanical_arcana.vpcf"

	local effect_desat = {
		crit_impact = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf",
		crit_impact_dagger = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact_dagger.vpcf",
		crit_impact_dagger_arcana = "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/phantom_assassin_crit_impact_dagger_arcana.vpcf",
	}

	local effect_self = {
		crit_impact = "particles/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf",
		crit_impact_dagger = "particles/hero_phantom_assassin/phantom_assassin_crit_impact_dagger.vpcf",
		crit_impact_dagger_arcana = "particles/hero_phantom_assassin/phantom_assassin_crit_impact_dagger_arcana.vpcf",
	}

	return effect_self.crit_impact
end





-- 获得天赋技能的数据值
function FindTalentValue(unit, talentName)
    if unit:HasAbility(talentName) then
        return unit:FindAbilityByName(talentName):GetSpecialValueFor("value")
    end
    return nil
end

-- 获得技能数据中的数据值，如果学习了连接的天赋技能，就返回相加结果
function GetTalentSpecialValueFor(ability, value)
    local base = ability:GetSpecialValueFor(value)
    local talentName
    local kv = ability:GetAbilityKeyValues()
    for k,v in pairs(kv) do -- trawl through keyvalues
        if k == "AbilitySpecial" then
            for l,m in pairs(v) do
                if m[value] then
                    talentName = m["LinkedSpecialBonus"]
                end
            end
        end
    end
    if talentName then 
        local talent = ability:GetCaster():FindAbilityByName(talentName)
        if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
    end
    return base
end