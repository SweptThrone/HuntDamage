--[[
    Made by SweptThrone
    Website:  sweptthr.one
    Handle:  @sweptthrone on everything
             (except Xbox, which is SweptThr0ne)
]]--

local plyMeta = FindMetaTable( "Player" )

function plyMeta:Bleed( atk, tier )
    if not self:Alive() then return end
    tier = math.Clamp( tier, 1, 3 )
    if self:GetNWInt( "BleedingTier", 0 ) then
        tier = math.Clamp( self:GetNWInt( "BleedingTier", 0 ) + tier, 1, 3 )
    end
    self:SetNWInt( "BleedingTier", tier )
    --self:SetNWFloat( "NextBleedTime", CurTime() + 0.75 * ( ( 4 - self:GetNWInt( "BleedingTier", 0 ) ) / 3 ) )
    self:SetNWFloat( "NextBleedTime", CurTime() )
    self:SetNWEntity( "BleedingAttacker", atk )
end
function plyMeta:StopBleeding()
    self:SetNWInt( "BleedingTier", 0 )
    self:SetNWFloat( "NextBleedTime", nil )
    self:SetNWEntity( "BleedingAttacker", NULL )
end
function plyMeta:IsBleeding()
    return self:GetNWInt( "BleedingTier", 0 ) ~= 0
end

function plyMeta:Poison( tier )
    if not self:Alive() then return end
    tier = math.Clamp( tier, 1, 3 )
    if self:GetNWInt( "PoisonTier", 0 ) then
        tier = math.Clamp( self:GetNWInt( "PoisonTier", 0 ) + tier, 1, 3 )
    end
    self:SetNWInt( "PoisonTier", tier )
    self:SetNWFloat( "PoisonEndTime", CurTime() + 2.5 * tier )
end
function plyMeta:IsPoisoned()
    return self:GetNWInt( "PoisonTier", 0 ) ~= 0
end

function plyMeta:Burn( atk, amt, tier )
    if not self:Alive() then return end
    -- passed 1, 0
    amt = math.ceil( amt )
    tier = math.Clamp( tier, 0, 3 )
    if self:GetNWInt( "BurningTier", 0 ) ~= 0 then
        tier = math.Clamp( self:GetNWInt( "BurningTier", 0 ) + 1, 1, 3 )
    end
    self:SetNWInt( "BurningTier", tier )
    if self:GetNWInt( "BurnedHealth", 0 ) > 0 and self:GetNWInt( "BurningTier", 0 ) == 0 then
        self:SetNWInt( "BurningTier", 1 )
    end
    --self:SetNWFloat( "NextBurnTime", CurTime() + 0.75 * ( ( 4 - self:GetNWInt( "BurningTier", 0 ) ) / 3 ) )
    self:SetNWFloat( "NextBurnTime", CurTime() )
    self:SetNWFloat( "BurnTierUpTime", CurTime() + 5 )
    self:SetNWInt( "BurnedHealth", self:GetNWInt( "BurnedHealth", 0 ) + amt )
    self:SetNWFloat( "NextUnburnTime", CurTime() + 2 )
    self:SetNWEntity( "BurnAttacker", atk )
    if SERVER then self:EmitSound( "ambient/fire/mtov_flame2.wav" ) end
    -- tier 0, 1, 2, 3 burn
    -- amt is instant-burn chunk
end
function plyMeta:StopBurning()
    if self:IsBurning() then
        self:EmitSound( "ambient/levels/canals/toxic_slime_sizzle3.wav" )
    end
    self:SetNWInt( "BurningTier", 0 )
    self:SetNWFloat( "NextBurnTime", 0 )
    if self.BurnSound then
        self.BurnSound:Stop()
    end
end
function plyMeta:IsBurning()
    return self:GetNWInt( "BurningTier", 0 ) ~= 0
end

hook.Add( "PlayerTick", "HuntDamageEffect", function( ply )

    if SERVER and ply:IsOnFire() then
        ply:Extinguish()
        ply:Burn( ply, 1, 1 )
    end

    if ply:WaterLevel() >= 2 then
        ply:StopBurning()
    end

    if ply.lastFrameHealth and ply:Health() > ply.lastFrameHealth then
        if ply:IsPoisoned() then
            ply:SetHealth( ply.lastFrameHealth )
        end
        ply:StopBleeding()
    end

    if SERVER and IsValid( ply.FireParticle ) and CurTime() > ply.FireParticle.SpawnTime + 0.2 then
        ply.FireParticle:Remove()
    end

    if SERVER and ply:IsBurning() and not IsValid( ply.FireParticle ) then
        ply.FireParticle = ents.Create( "_firesmoke" )
        local min, max
        if ply:Crouching() then
            min, max = ply:GetHullDuck()
        else
            min, max = ply:GetHull()
        end
        --[[
        ply.FireParticle:SetPos( Vector( 
            math.random( ply:GetPos().x + min.x, ply:GetPos().x + max.x ),
            math.random( ply:GetPos().y + min.y, ply:GetPos().y + max.y ),
            math.random( ply:GetPos().z + min.z, ply:GetPos().z + max.z )
        ) )
        ]]
        ply.FireParticle:SetPos( ply:GetPos() + Vector( 0, 0, ply:Crouching() and 18 or 36 ) )
        ply.FireParticle.SpawnTime = CurTime()
        ply.FireParticle:Spawn()
    end
    

    if ply:Alive() --[[and IsValid( ply:GetNWEntity( "BleedingAttacker" ) )]] and ply:GetNWFloat( "NextBleedTime", nil ) ~= 0 and CurTime() >= ply:GetNWFloat( "NextBleedTime", 0 ) then
        if SERVER then
            local bDmgInfo = DamageInfo()
            bDmgInfo:SetDamageCustom( 3799 ) -- unique tag to identify this as progressive damage instead of inflicting damage (my Discord discrim)
            bDmgInfo:SetDamage( 1 )
            bDmgInfo:SetAttacker( IsValid( ply:GetNWEntity( "BleedingAttacker" ) ) and ply:GetNWEntity( "BleedingAttacker" ) or ply )
            bDmgInfo:SetInflictor( IsValid( ply:GetNWEntity( "BleedingAttacker" ) ) and ply:GetNWEntity( "BleedingAttacker" ) or ply )
            bDmgInfo:SetDamageType( bit.bor( DMG_SLASH, DMG_DIRECT ) )
            ply:TakeDamageInfo( bDmgInfo )
        end
        ply:SetNWFloat( "NextBleedTime", CurTime() + 0.75 * ( ( 4 - ( ply:GetNWInt( "BleedingTier" ) or 1 ) ) / 3 ) )
    end

    if ply:Alive() and not ply:IsBurning() and CurTime() >= ply:GetNWFloat( "NextUnburnTime", nil ) and ply:GetNWInt( "BurnedHealth", 0 ) > 0 then
        ply:SetNWInt( "BurnedHealth", ply:GetNWInt( "BurnedHealth" ) - 1 )
        ply:SetNWFloat( "NextUnburnTime", CurTime() + 2 )
    end

    if ply:Alive() and ply:GetNWInt( "BurnedHealth", 0 ) > 0 then
        if SERVER then
            if ply:Health() > ply:GetMaxHealth() - ply:GetNWInt( "BurnedHealth", 0 ) then
                local fDmgInfo = DamageInfo()
                fDmgInfo:SetDamageCustom( 3799 ) -- unique tag to identify this as progressive damage instead of inflicting damage (my Discord discrim)
                fDmgInfo:SetDamage( ply:Health() - ( ply:GetMaxHealth() - ply:GetNWInt( "BurnedHealth", 0 ) ) )
                fDmgInfo:SetAttacker( IsValid( ply:GetNWEntity( "BurnAttacker" ) ) and ply:GetNWEntity( "BurnAttacker" ) or ply )
                fDmgInfo:SetInflictor( IsValid( ply:GetNWEntity( "BurnAttacker" ) ) and ply:GetNWEntity( "BurnAttacker" ) or ply )
                fDmgInfo:SetDamageType( DMG_BURN )
                ply:TakeDamageInfo( fDmgInfo )
            end
        end
    end

    if ply:Alive() and IsValid( ply:GetNWEntity( "BurnAttacker" ) ) and ply:GetNWFloat( "NextBurnTime", nil ) ~= nil and CurTime() >= ply:GetNWFloat( "NextBurnTime" ) and ply:GetNWInt( "BurningTier", 0 ) > 0 then
        if SERVER and not ply.BurnSound:IsPlaying() then
            ply.BurnSound:Play()
            ply.BurnSound:ChangeVolume( 0.25 )
        end
        
        if SERVER then
            ply:SetNWInt( "BurnedHealth", ply:GetNWInt( "BurnedHealth" ) + 1 )
        end
        ply:SetNWFloat( "NextBurnTime", CurTime() + 0.75 * ( ( 4 - ply:GetNWInt( "BurningTier", 1 ) ) / 3 ) )
        if ply:GetNWFloat( "BurnTierUpTime", nil ) ~= nil and CurTime() >= ply:GetNWFloat( "BurnTierUpTime" ) and ply:GetNWInt( "BurningTier", 0 ) < 3 then
            ply:SetNWFloat( "BurnTierUpTime", CurTime() + 5 )
            ply:SetNWInt( "BurningTier", math.Clamp( ply:GetNWInt( "BurningTier", 1 ) + 1, 1, 3 ) )
            ply:EmitSound( "ambient/fire/gascan_ignite1.wav" )
        end
    end

    if ply:Alive() and ply:IsPoisoned() and ply:GetNWFloat( "PoisonEndTime", 0 ) ~= 0 then
        if CurTime() >= ply:GetNWFloat( "PoisonEndTime" ) then
            ply:SetNWInt( "PoisonTier", ply:GetNWInt( "PoisonTier" ) - 1 )
            ply:SetNWFloat( "PoisonEndTime", CurTime() + 5 * ply:GetNWInt( "PoisonTier" ) )
        end
    end

    ply.lastFrameHealth = ply:Health()
end )

--[[
local function PreventIt( wep )
    if wep:GetOwner():GetNWFloat( "DoneStoppingBleeding", 0 ) ~= 0 then
        return false
    end
end

hook.Add( "TFA_CanPrimaryAttack", "DisallowShootingIfBandaging", PreventIt )
hook.Add( "TFA_CanBash", "DisallowBashingIfBandaging", PreventIt )
]]--

hook.Add( "SetupMove", "StopDebuffsUse", function( ply, mv, cmd )
    local isTrueUsing = bit.band( cmd:GetButtons(), IN_ALT1 ) == IN_ALT1

    if isTrueUsing then
        if SERVER and ( ply:IsBurning() or ply:IsBleeding() ) and not ply:HasWeapon( "weapon_huntdmg_bandaging" ) then
            ply:Give( "weapon_huntdmg_bandaging" )
        end
        if CLIENT and ( ply:IsBurning() or ply:IsBleeding() ) and IsValid( ply:GetWeapon( "weapon_huntdmg_bandaging" ) ) then
            input.SelectWeapon( ply:GetWeapon( "weapon_huntdmg_bandaging" ) )
        end
        --[[
        if ply:GetNWFloat( "DoneStoppingBleeding", 0 ) ~= 0 then
            mv:SetButtons( bit.band( mv:GetButtons(), bit.bnot( IN_ATTACK2 ) ) )
            mv:SetButtons( bit.band( mv:GetButtons(), bit.bnot( IN_ATTACK ) ) )
        end
        ]]--

        if ply:GetNWFloat( "DoneStoppingBleeding", 0 ) == 0 and ( ply:IsBleeding() or ply:IsBurning() ) then
            ply:SetNWFloat( "DoneStoppingBleeding", CurTime() + 1.5 * ply:GetNWInt( "BleedingTier" ) + 1.5 * ply:GetNWInt( "BurningTier" ) )
            if SERVER then ply.BandageSound:Play() end
        end

        if ply:GetNWFloat( "NextBleedTime", 0 ) ~= 0 and ply:GetNWFloat( "DoneStoppingBleeding", 0 ) ~= 0 then
            --ply:SetNWFloat( "NextBleedTime", CurTime() + 0.75 * ( ( 4 - ( ply:GetNWInt( "BleedingTier" ) or 1 ) ) / 3 ) )
            ply:SetNWFloat( "NextBleedTime", CurTime() + FrameTime() )
        end
        if ply:GetNWFloat( "NextBurnTime", 0 ) ~= 0 and ply:GetNWFloat( "DoneStoppingBleeding", 0 ) ~= 0 then
            --ply:SetNWFloat( "NextBurnTime", CurTime() + 0.75 * ( ( 4 - ( ply:GetNWInt( "BurningTier" ) or 1 ) ) / 3 ) )
            ply:SetNWFloat( "NextBurnTime", CurTime() + FrameTime() )
        end

        if ply:GetNWFloat( "DoneStoppingBleeding", 0 ) ~= 0 and CurTime() >= ply:GetNWFloat( "DoneStoppingBleeding", 0 ) and ( ply:GetNWFloat( "NextBleedTime", 0 ) ~= 0 or ply:GetNWFloat( "NextBurnTime", 0 ) ~= 0 ) then
            ply:StopBleeding()
            ply:StopBurning()
            ply:SetNWFloat( "DoneStoppingBleeding", 0 )
            if SERVER then ply:StripWeapon( "weapon_huntdmg_bandaging" ) end
            if CLIENT then input.SelectWeapon( ply:GetPreviousWeapon() ) end
            if SERVER then ply.BandageSound:Stop() end
        end
    end

    if mv:KeyReleased( IN_ALT1 ) and ( ply:IsBleeding() or ply:IsBurning() ) then
        if SERVER then ply.BandageSound:Stop() end
        ply:SetNWFloat( "DoneStoppingBleeding", 0 )
        if SERVER then ply:StripWeapon( "weapon_huntdmg_bandaging" ) end
        if CLIENT then input.SelectWeapon( ply:GetPreviousWeapon() ) end
    end

    if ply:GetNWFloat( "DoneStoppingBleeding", 0 ) ~= 0 and isTrueUsing then
        mv:SetMaxClientSpeed( mv:GetMaxClientSpeed() * 0.4 )
        mv:SetMaxSpeed( mv:GetMaxClientSpeed() * 0.4 )
        cmd:SetForwardMove( cmd:GetForwardMove() * 0.4 )
        cmd:SetSideMove( cmd:GetSideMove() * 0.4 )
    end
end )