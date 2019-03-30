LinkLuaModifier( "modifier_mjz_slark_essence_shift_heap", "modifiers/hero_slark/modifier_mjz_slark_essence_shift_heap.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mjz_slark_essence_shift_heap_aura", "modifiers/hero_slark/modifier_mjz_slark_essence_shift_heap.lua" ,LUA_MODIFIER_MOTION_NONE )

mjz_slark_essence_shift = class({})
local ability_class = mjz_slark_essence_shift
local modifier_stack_name = "modifier_mjz_slark_essence_shift_heap"

function ability_class:GetIntrinsicModifierName()
	return modifier_stack_name
end

function ability_class:OnEnemyDiedNearby( hVictim, hKiller, kv )
	if hVictim == nil or hKiller == nil or hVictim:IsIllusion()  then
		return
	end

	local caster = self:GetCaster()
	local heap_range = self:GetSpecialValueFor( "heap_range" )

	if hVictim:GetTeamNumber() ~= caster:GetTeamNumber() and caster:IsAlive() then
		local vToCaster = caster:GetOrigin() - hVictim:GetOrigin()
		local flDistance = vToCaster:Length2D()

		if hKiller == caster or heap_range >= flDistance then
			if self.nKills == nil then
				self.nKills = 0
			end

			self.nKills = self.nKills + 1

			local hBuff = caster:FindModifierByName(modifier_stack_name)
			if hBuff ~= nil then
				hBuff:SetStackCount( self.nKills )
				caster:CalculateStatBonus()
			end

			local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, caster )
			ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 1, 0, 0 ) )
			ParticleManager:ReleaseParticleIndex( nFXIndex )
		end
	end
end

function ability_class:GetHeapKills()
	if self.nKills == nil then
		self.nKills = 0
	end
	return self.nKills
end

