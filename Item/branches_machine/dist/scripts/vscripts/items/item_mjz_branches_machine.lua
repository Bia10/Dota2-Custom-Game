
function OnSpellStart( keys )
    local caster = keys.caster
    local target = keys.target
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	local duration = ability:GetLevelSpecialValueFor("tree_duration", (ability:GetLevel() -1))

 
    local tree = ability:GetCursorTarget()
    if tree then
        caster:EmitSound("Tree.CutDown")
        if tree.CutDown then
            -- print("Tree.CutDown")
            -- tree:CutDown(caster:GetTeamNumber())
            tree:CutDownRegrowAfter(20, caster:GetTeamNumber())
        else    
            -- print("not tree")
            GridNav:DestroyTreesAroundPoint(point, 10, false)
        end
    else
        local target_team = DOTA_UNIT_TARGET_TEAM_BOTH or DOTA_UNIT_TARGET_TEAM_NONE
        local target_type = DOTA_UNIT_TARGET_ALL
        local target_flags = DOTA_UNIT_TARGET_FLAG_NONE --ability:GetAbilityTargetFlags() 
        local units = FindUnitsInRadius(caster:GetTeam(), point, nil, 100, target_team, target_type, target_flags, FIND_CLOSEST, false)

        if table_is_empty(units) then
            CreateTempTree(point, duration)
        end
    end
    
end

function table_is_empty(t)
    return _G.next(t) == nil
end