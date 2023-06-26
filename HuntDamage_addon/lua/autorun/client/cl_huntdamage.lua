--[[
    Made by SweptThrone
    Website:  sweptthr.one
    Handle:  @sweptthrone on everything
             (except Xbox, which is SweptThr0ne)
]]--

surface.CreateFont( "HuntDebuffHUD", {
    font = "Arial",
    extended = false,
    size = 24,
    weight = 5000,
    antialias = false,
    outline = true
} )

hook.Add( "HUDPaint", "HuntDamageTest", function()
    if GetConVar( "cl_drawhud" ):GetBool() then
        surface.SetDrawColor( Color( 0, 0, 0 ) )
        surface.DrawRect( ScrW() / 2 - 150, ScrH() - 40, 300, 30 )
        surface.SetDrawColor( Color( ( LocalPlayer():IsPoisoned() or LocalPlayer():GetNWInt( "Freezing", 0 ) == 255 ) and 0 or 255, ( LocalPlayer():IsPoisoned() or LocalPlayer():GetNWInt( "Freezing", 0 ) == 255 ) and 255 or 0, LocalPlayer():GetNWInt( "Freezing", 0 ) == 255 and 255 or 0, LocalPlayer():IsBleeding() and TimedSin( 1, 128, 255, 0 ) or 255 ) )
        surface.DrawRect( ScrW() / 2 - 150, ScrH() - 40, LocalPlayer():Health() * 3, 30 )
        surface.SetDrawColor( LocalPlayer():GetNWInt( "BurningTier", 0 ) > 0 and Color( 255, 128, 0 ) or Color( 64, 64, 64 ) )
        surface.DrawRect( ( ScrW() / 2 - 150 ) + LocalPlayer():GetMaxHealth() * 3 - LocalPlayer():GetNWInt( "BurnedHealth", 0 ) * 3, ScrH() - 40, LocalPlayer():GetNWInt( "BurnedHealth", 0 ) * 3, 30 )
    end
end )

hook.Add( "HUDPaint", "HuntDamageStopDebuffs", function()
    if GetConVar( "cl_drawhud" ):GetBool() then
        if LocalPlayer():IsBleeding() or LocalPlayer():IsBurning() then
            local txt = ""
            if input.LookupBinding( "+alt1", false ) then
                txt = "Hold " .. input.LookupBinding( "+alt1", false ):upper() .. " to stop "
            else
                txt = "Bind a key to +alt1 to stop "
            end
            if LocalPlayer():IsBleeding() then
                if LocalPlayer():IsBurning() then
                    txt = txt .. "bleeding and burning."
                else
                    txt = txt .. "bleeding."
                end
            elseif LocalPlayer():IsBurning() then
                txt = txt .. "burning."
            end
            surface.SetFont( "HuntDebuffHUD" )
            surface.SetTextPos( ScrW() / 2 - surface.GetTextSize( txt ) / 2, ScrH() * 0.66 )
            surface.SetTextColor( 255, 0, 0, 255 )
            surface.DrawText( txt )

            if LocalPlayer():GetNWFloat( "DoneStoppingBleeding", 0 ) ~= 0 then
                surface.SetDrawColor( 255, 0, 0, 255 )
                local timeToPutOut = 1.5 * LocalPlayer():GetNWInt( "BleedingTier" ) + 1.5 * LocalPlayer():GetNWInt( "BurningTier" )
                surface.DrawRect( ScrW() / 2 - 150, ScrH() * 0.66 + 50, 300 - ( ( LocalPlayer():GetNWFloat( "DoneStoppingBleeding", 0 ) - CurTime() ) / timeToPutOut ) * 300, 20 )
            end
            surface.SetDrawColor( 0, 0, 0, 255 )
            surface.DrawOutlinedRect( ScrW() / 2 - 150, ScrH() * 0.66 + 50, 300, 20, 2 )
        end
    end
end )

local defR = 0
local defG = 0
local defBr = 0

hook.Add( "RenderScreenspaceEffects", "HuntDamagePoisonEffect", function()

    if LocalPlayer():IsPoisoned() then
        defR = 0.015
        defG = math.Approach( defG, LocalPlayer():GetNWInt( "PoisonTier", 0 ) * 0.02, 0.001 )
        defBr = math.Approach( defBr, LocalPlayer():GetNWInt( "PoisonTier", 0 ) * -0.05, 0.0025 )
        DrawMotionBlur( 0.02, 1, 0.01 )
        DrawSharpen( 1, 2.5 )
        DrawMaterialOverlay( "effects/water_warp01", 0.05 * LocalPlayer():GetNWInt( "PoisonTier", 0 ) )
    else
        defR = math.Approach( defR, 0, 0.0005 )
        defG = math.Approach( defG, 0, 0.001 )
        defBr = math.Approach( defBr, 0, 0.0025 )
    end

    if LocalPlayer():IsBleeding() then
        DrawColorModify( {
            [ "$pp_colour_addr" ] = TimedSin( 0.33 * LocalPlayer():GetNWInt( "BleedingTier" ), 0.1, 0.25, 0 ),
            [ "$pp_colour_addg" ] = 0,
            [ "$pp_colour_addb" ] = 0,
            [ "$pp_colour_brightness" ] = 0,
            [ "$pp_colour_contrast" ] = 1,
            [ "$pp_colour_colour" ] = 1,
            [ "$pp_colour_mulr" ] = 0,
            [ "$pp_colour_mulg" ] = 0,
            [ "$pp_colour_mulb" ] = 0
        } )
    end

    DrawColorModify( {
        [ "$pp_colour_addr" ] = defR,
        [ "$pp_colour_addg" ] = defG,
        [ "$pp_colour_addb" ] = 0,
        [ "$pp_colour_brightness" ] = defBr,
        [ "$pp_colour_contrast" ] = 1,
        [ "$pp_colour_colour" ] = 1,
        [ "$pp_colour_mulr" ] = 0,
        [ "$pp_colour_mulg" ] = 0,
        [ "$pp_colour_mulb" ] = 0
    } )
end )

local function st_warn( txt )
    chat.AddText( Color( 255, 0, 0, 255 ), "[!] ", Color( 255, 255, 255, 255 ), txt )
end

hook.Add( "KeyPress", "HuntDMGWarnAboutNoBind", function( ply, key )
    if ( key == IN_FORWARD or key == IN_BACK or key == IN_RIGHT or key == IN_LEFT ) then
        if not input.LookupBinding( "+alt1", false ) then
            surface.PlaySound( "buttons/blip1.wav" )
            st_warn( "Could not find a key bound to +alt1" )
            st_warn( "This bind is used by Hunt Damage to stop bleeding and burning" )
            st_warn( "It is highly recommended to bind a key to +alt1" )
        end
        hook.Remove( "KeyPress", "HuntDMGWarnAboutNoBind" )
    end

end )