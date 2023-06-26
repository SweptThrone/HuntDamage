--[[
    Made by SweptThrone
    Website:  sweptthr.one
    Handle:  @sweptthrone on everything
             (except Xbox, which is SweptThr0ne)
]]--

hook.Add( "PlayerSpawn", "AssignBurnSound", function( ply )
    ply.BurnSound = CreateSound( ply, "player/general/flesh_burn.wav" )
    ply.BandageSound = CreateSound( ply, "huntdmg/bandageloop.wav" )
end )

local healingItems = {
    [ "item_healthkit" ] = true,
    [ "item_healthvial" ] = true,
    [ "item_grubnugget" ] = true
}
hook.Add( "PlayerCanPickupItem", "HuntDamageNoHealth", function( ply, item )
    if healingItems[ item:GetClass() ] and ply:IsPoisoned() then
        return false
    end
end )

hook.Add( "PlayerDeath", "STResetHuntDamageStats", function( vic )
    vic:StopBleeding()
    vic:StopBurning()
    vic:SetNWInt( "BurnedHealth", 0 )
    vic:SetNWInt( "PoisonTier", 0 )
    vic:SetNWFloat( "PoisonEndTime", 0 )
    vic:SetNWFloat( "DoneStoppingBleeding", 0 )
    vic.BandageSound:Stop()
end )

hook.Add( "PlayerUse", "StopBleedingFirst", function( ply, ent )
    if ply:GetNWFloat( "DoneStoppingBleeding", 0 ) ~= 0 then
        return false
    end
end )

hook.Add( "EntityTakeDamage", "BurnFromNormalFire", function( ent, dmg )
    if ent:IsPlayer() and ent:Alive() and bit.band( dmg:GetDamageType(), DMG_BURN ) == DMG_BURN and dmg:GetDamageCustom() ~= 3799 then -- unique tag to identify this as progressive damage instead of inflicting damage (my Discord discrim)
        ent:Burn( dmg:GetAttacker(), dmg:GetDamage() / 3, 0 )
    end

    if ent:IsPlayer() and ent:Alive() and bit.band( dmg:GetDamageType(), DMG_SLASH ) == DMG_SLASH and dmg:GetDamageCustom() ~= 3799 then -- unique tag to identify this as progressive damage instead of inflicting damage (my Discord discrim)
        ent:Bleed( dmg:GetAttacker(), 1 )
    end

    if ent:IsPlayer() and ent:Alive() and ( bit.band( dmg:GetDamageType(), DMG_ACID ) == DMG_ACID or bit.band( dmg:GetDamageType(), DMG_POISON ) == DMG_POISON ) then
        ent:Poison( 1 )
    end
end )