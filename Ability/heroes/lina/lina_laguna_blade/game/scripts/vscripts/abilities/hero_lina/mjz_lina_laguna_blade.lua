LinkLuaModifier("modifier_mjz_lina_laguna_blade_bonus", "modifiers/hero_lina/modifier_mjz_lina_laguna_blade.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_lina_laguna_blade_creature", "modifiers/hero_lina/modifier_mjz_lina_laguna_blade.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mjz_lina_laguna_blade_death", "modifiers/hero_lina/modifier_mjz_lina_laguna_blade.lua", LUA_MODIFIER_MOTION_NONE)

mjz_lina_laguna_blade = class({})

function mjz_lina_laguna_blade:GetIntrinsicModifierName()
	return "modifier_mjz_lina_laguna_blade_bonus"
end

function mjz_lina_laguna_blade:GetAbilityTextureName()
    if self:GetCaster():HasScepter() then
        -- return "mjz_lina_laguna_blade"
        return "lina/lina_ti6_immortal/lina_laguna_blade"
    end
    return "lina_laguna_blade"
    -- return self.BaseClass.GetAbilityTextureName(self)
end

function mjz_lina_laguna_blade:GetAOERadius()
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("cast_range_scepter")
    end
    return self.BaseClass.GetAOERadius(self)
end
function mjz_lina_laguna_blade:GetCastRange(vLocation, hTarget)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("cast_range_scepter")
    end
    return self.BaseClass.GetCastRange(self, vLocation, hTarget)
end

function mjz_lina_laguna_blade:GetCooldown(iLevel)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("cooldown_scepter")
    end
    return self.BaseClass.GetCooldown(self, iLevel)
end
function mjz_lina_laguna_blade:GetManaCost(iLevel)
    if self:GetCaster():HasScepter() then
        return self:GetSpecialValueFor("mana_cost_scepter")
    end
    return self.BaseClass.GetManaCost(self, iLevel)
end

function mjz_lina_laguna_blade:GetDamageType()
    if self:GetCaster():HasScepter() then
        return DAMAGE_TYPE_PURE
    end
    return DAMAGE_TYPE_MAGICAL
end
function mjz_lina_laguna_blade:GetAbilityDamageType()
    return self:GetDamageType()
end
function mjz_lina_laguna_blade:GetUnitDamageType()
    return self:GetDamageType()
end


if IsServer() then

    function mjz_lina_laguna_blade:OnSpellStart( )
        if not IsServer() then return nil end

        local caster = self:GetCaster()
        local ability = self

        self.damage_per_use = self:GetSpecialValueFor("damage_per_use")
        self.damage_delay = self:GetSpecialValueFor("damage_delay")
        
        self.stack_modifier_name = "modifier_mjz_lina_laguna_blade_bonus"
        self.creature_enabled = self:GetSpecialValueFor("creature_enabled")
        self.creature_health = self:GetSpecialValueFor("creature_health")

        local base_damage = self:GetSpecialValueFor(value_if_scepter(caster, "damage_scepter", "damage"))
        local damage_per_kill = self:GetSpecialValueFor("damage_per_kill")
        local kill_grace_duration = self:GetSpecialValueFor("kill_grace_duration")

        local kill_count = self.kill_count or 0
        local damage = base_damage + damage_per_kill * kill_count

        if caster:HasScepter() then
            caster:EmitSound("Hero_Lina.LagunaBlade.Immortal")
        else
            caster:EmitSound("Ability.LagunaBlade")
        end

        local targets = self:_GetTargets()
        for _, target in ipairs(targets) do
            self:_LagunaBladeTarget(target, damage, kill_grace_duration)
        end
        
    end

    function mjz_lina_laguna_blade:_GetTargets()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        if caster:HasScepter() then
            return FindUnitsInRadius(
                caster:GetTeamNumber(),
                target:GetAbsOrigin(),
                nil,
                self:GetSpecialValueFor("splash_radius_scepter"),
                DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                0,
                FIND_ANY_ORDER,
                false
            )
        end

        local targets = {}
        table.insert(targets, target)

        return targets
    end

    function mjz_lina_laguna_blade:_LagunaBladeTarget(target, damage, kill_grace_duration)
        local caster = self:GetCaster()
        local ability = self

        local particle_name_normal = "particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf"
        local particle_name_ti6 = "particles/econ/items/lina/lina_ti6/lina_ti6_laguna_blade.vpcf"
        local particle_name = value_if_scepter(caster, particle_name_ti6, particle_name_normal)

        local particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle, 2, target:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle)

        if not target:IsMagicImmune() or caster:HasScepter() then

            local sound_name = value_if_scepter(caster, "Hero_Lina.LagunaBladeImpact.Immortal", "Ability.LagunaBladeImpact")
            target:EmitSound(sound_name)

            --添加死亡监听器
            local victim = target
            if not victim:IsIllusion() then
                if victim:IsRealHero() or victim:IsCreature() then
                    local modifier_death = 'modifier_mjz_lina_laguna_blade_death'
                    -- ability:ApplyDataDrivenModifier(caster, victim, modifier_death, {duration=kill_grace_duration})
                    victim:AddNewModifier(caster, ability, modifier_death, {duration=kill_grace_duration})
                end
            end

            ApplyDamage({
                ability = self,
                attacker = caster,
                damage = damage,
                damage_type = self:GetDamageType(),
                victim = target
            })
        end
        
    end

end

function value_if_scepter(npc, ifYes, ifNot)
	if npc:HasScepter() then
		return ifYes
	end
	return ifNot
end
