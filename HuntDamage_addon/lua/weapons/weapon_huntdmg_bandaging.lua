AddCSLuaFile()

SWEP.HoldType               = "duel"

if CLIENT then
   SWEP.PrintName           = "Bandaging"
   SWEP.Slot                = 5

   SWEP.ViewModelFOV        = 10
end

SWEP.Base                   = "weapon_base"

SWEP.ViewModel              = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel             = "models/weapons/w_crowbar.mdl"

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo           = "none"

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"

function SWEP:OnDrop()
   self:Remove()
end

function SWEP:ShouldDropOnDie()
   return false
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function SWEP:Deploy()
   if SERVER and IsValid(self:GetOwner()) then
      self:GetOwner():DrawViewModel(false)
   end
   self:SetHoldType( self.HoldType )

   self:DrawShadow(false)

   return true
end

function SWEP:Holster()
   return false
end

function SWEP:DrawWorldModel()
end

function SWEP:DrawWorldModelTranslucent()
end