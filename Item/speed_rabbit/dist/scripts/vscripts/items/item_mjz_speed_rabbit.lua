
function item_consumable_used(keys)
	local used = consumable_used(keys.caster, keys.ability, keys.modifier, keys.max_count)
	if used then
		EmitSoundOn("Item.MoonShard.Consume", keys.caster)
	else
		-- 如果没有无效，就返还金钱	
		local playerID = keys.caster:GetPlayerID()	-- keys.PlayerID
		sendBackGold(playerID, keys.item_cost)
	end
end


function increase_modifier(caster, target, ability, modifier, max_count)
	local used = false;
	if target:HasModifier(modifier) then
		local newCount = target:GetModifierStackCount(modifier, caster) + 1
		if newCount <= max_count then
			target:SetModifierStackCount(modifier, caster, newCount)			
			used = true
		end
	else
		ability:ApplyDataDrivenModifier(caster, target, modifier, nil)
		target:SetModifierStackCount(modifier, caster, 1)
		used = true
	end
	return used
end

function consumable_used(caster, item, modifier, max_count)
	local used = increase_modifier(caster, caster, item, modifier, max_count)
	caster:RemoveItem(item)
	return used
end

function sendBackGold(playerID, gold)
	-- local player = PlayerResource:GetPlayer(playerID)
	-- local controlHero = PlayerResource:GetSelectedHeroEntity(playerID)
	local reliable = false
    PlayerResource:ModifyGold(playerID, gold, reliable, 10)
end