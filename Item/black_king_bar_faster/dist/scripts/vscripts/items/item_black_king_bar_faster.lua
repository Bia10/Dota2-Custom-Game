
function on_spell_start( keys )
    local caster = keys.caster
    -- local caster = EntIndexToHScript(keys.caster_entindex)   --物品携带者

    updateLevel(keys)
    scaleModel(caster, keys.PercentageOverModelScale, keys.Duration)

    caster:Purge(false, true, false, true, false)
end

function on_created( keys )
	if keys.caster.BKBLevel ~= nil and keys.caster.BKBLevel ~= keys.ability:GetLevel() then
		keys.ability:SetLevel(keys.caster.BKBLevel)
	end
end

function updateLevel( keys )
    --Level up BKB so future casts will use an updated cooldown and duration.
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