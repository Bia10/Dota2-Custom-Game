

function Precache( context )
	PrecacheItemByNameSync( "item_tombstone", context )
end


function CAddonTemplateGameMode:InitGameMode()

	-- 不能自动重生，死亡墓碑上显示玩家名字
	-- GameRules:SetHeroRespawnEnabled( false )

	
	--监听单位死亡
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( CAddonTemplateGameMode, 'OnEntityKilled' ), self )
	
end


function CAddonTemplateGameMode:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	if killedUnit and killedUnit:IsRealHero() then
		local newItem = CreateItem( "item_tombstone", killedUnit, killedUnit )
		newItem:SetPurchaseTime( 0 )
		newItem:SetPurchaser( killedUnit )
		local tombstone = SpawnEntityFromTableSynchronous( "dota_item_tombstone_drop", {} )
		tombstone:SetContainedItem( newItem )
		tombstone:SetAngles( 0, RandomFloat( 0, 360 ), 0 )
		FindClearSpaceForUnit( tombstone, killedUnit:GetAbsOrigin(), true )	
	end
end