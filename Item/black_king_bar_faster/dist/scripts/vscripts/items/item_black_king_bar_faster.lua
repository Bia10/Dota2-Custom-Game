
function on_spell_start( keys )
	if IsServer() then	
		-- local caster = EntIndexToHScript(keys.caster_entindex)   --物品携带者
		local caster = keys.caster
		local ability = keys.ability
		local ability_level = ability:GetLevel() - 1

		local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
		-- scaleModel(caster, keys.PercentageOverModelScale, duration)
		caster:AddNewModifier(caster, ability, "modifier_black_king_bar_faster", {Duration = duration})

		updateLevel(keys)

		caster:Purge(false, true, false, true, false)
	end
end

function updateLevel( keys )
	local current_level = keys.ability:GetLevel()
	if current_level + 1 <= keys.MaxLevel then
		keys.ability:SetLevel(current_level + 1)
		keys.caster.BKBLevel = current_level + 1  --BKB's level is tied to the player, not the item, so store it here.
		
		for i=0, 11, 1 do  --Level up any other BKBs in the player's inventory or stash to match the new level.
			local current_item = keys.caster:GetItemInSlot(i)
			if current_item ~= nil then
				if current_item:GetName() == keys.ItemName and current_item:GetLevel() ~= keys.caster.BKBLevel then
					current_item:SetLevel(keys.caster.BKBLevel)
				end
			end
		end
	end
end


------------------------------------------------------------------------

LinkLuaModifier("modifier_black_king_bar_faster", "items/item_black_king_bar_faster.lua", LUA_MODIFIER_MOTION_NONE)

modifier_black_king_bar_faster = class({})

function modifier_black_king_bar_faster:IsHidden()
	return true
end

if IsServer() then
	function modifier_black_king_bar_faster:OnCreated()
		local parent = self:GetParent()

		if not parent then
			self:Destroy()
		end

		local ability = self:GetAbility()
		self.model_scale = ability:GetSpecialValueFor("model_scale")
	end

	function modifier_black_king_bar_faster:DeclareFunctions()
		return {
			MODIFIER_PROPERTY_MODEL_SCALE,
		}
	end

	function modifier_black_king_bar_faster:GetModifierModelScale()
		return self.model_scale
	end
end

-----------------------------------------------------------------------


function scaleModel(caster, PercentageOverModelScale, Duration)
	if not Timers then return end

    local final_model_scale = (PercentageOverModelScale / 100) + 1  --This will be something like 1.3.
	local model_scale_increase_per_interval = 100 / (final_model_scale - 1)

	--Scale the model up over time.
	for i=1,100 do
		Timers:CreateTimer(i/75, 
		function()
			caster:SetModelScale(1 + i/model_scale_increase_per_interval)
		end)
	end

	--Scale the model back down around the time the duration ends.
	for i=1,100 do
		Timers:CreateTimer(Duration - 1 + (i/50),
		function()
			caster:SetModelScale(final_model_scale - i/model_scale_increase_per_interval)
		end)
	end
end