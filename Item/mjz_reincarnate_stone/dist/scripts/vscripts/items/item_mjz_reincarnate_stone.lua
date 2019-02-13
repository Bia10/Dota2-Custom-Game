
require("lib.timers")

function Ressurection(keys)
	local killedUnit = EntIndexToHScript( keys.caster_entindex )
    local Item = keys.ability
	local cast_time = keys.cast_time
	local respawn_origin = keys.respawn_origin
	local position = killedUnit:GetAbsOrigin()
	
	if killedUnit:IsIllusion() then return end

	if not killedUnit:IsAlive() and Item:IsCooldownReady() then
		killedUnit.resurrectionStoned = true
		if not killedUnit:WillReincarnate() then

			-- 显示复活时间
			killedUnit:SetTimeUntilRespawn(cast_time + 0.5)

			-- 在复活前3秒，播放声音
			local sound_time = 0
			if cast_time > 3 then 
				sound_time = cast_time - 3 
			end
			Timers:CreateTimer(sound_time, function ()
				killedUnit:EmitSound("DOTAMusic_Hero.Reincarnate")	
				-- killedUnit:EmitSound("Ability.ReincarnationAlt")
			end)

			Timers:CreateTimer(cast_time, function()
				ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, killedUnit)

				if respawn_origin > 0 then
					killedUnit:SetRespawnPosition(position)
				end
				killedUnit:RespawnHero(false, false)
				killedUnit.resurrectionStoned = false
				Item:StartCooldown(1)
				if Item:GetCurrentCharges() > 1 then
					Item:SetCurrentCharges(Item:GetCurrentCharges()-1)
				else
					killedUnit:RemoveItem(Item)
				end
			end)
		end
	end
end


