if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	SWEP.PrintName = "Tower Equipment"
	SWEP.Slot = 2
	SWEP.SlotPos = 1
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "Crap-Head" 
SWEP.Instructions = "To tow: Park your tow truck infront of victims car.\nThen left click on the back of your tow truck.\nDo the same to un-attach vehicle again.\nTo mark towed: Right click on the vehicle to open menu."

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false

SWEP.Spawnable = false
SWEP.AdminSpawnable = true
SWEP.UseHands = true
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.ViewModel = ""
SWEP.WorldModel = ""

function SWEP:Initialize()
	self:SetWeaponHoldType("melee")
end

function SWEP:CanPrimaryAttack() return true end

function SWEP:PrimaryAttack()	
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
	
	self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 )
	
	local tr = self.Owner:GetEyeTrace()
	
	if SERVER then
		if not tr.Entity:IsVehicle() then
			DarkRP.notify(self.Owner, 1, 5, "You must be looking at a tow truck!")
			return 
		end
		local Vehicle = tr.Entity
	
		if self.Owner:Team() == TEAM_TOWER and Vehicle:GetModel() == TOWTRUCK_VehicleModel then
			if !constraint.FindConstraints(Vehicle, "Rope")[1] and Vehicle.IsTowing then
				Vehicle.IsTowing = false
			end
			
			local pos = Vehicle:GetPos()
			local isClose = self.Owner:GetShootPos():Distance( pos + Vehicle:GetForward() * -133.3848 + Vehicle:GetUp() * 47.928 ) < 115
			
			if ( not Vehicle.LastUse or Vehicle.LastUse < CurTime() ) and isClose then
				Vehicle.LastUse = CurTime() + 2
				
				if not Vehicle.IsTowing then
					local trace = util.TraceLine( {start = pos + Vector(0, 0, 27), endpos = pos + Vehicle:GetForward() * -200 + Vector(0, 0, 27), filter = Vehicle} )
					local ent = trace.Entity
					
					if not ent:IsValid() then
						local cars = ents.FindInBox( pos + Vehicle:GetRight() * 35 + Vehicle:GetForward() * -200, pos + Vehicle:GetRight() * -35 + Vehicle:GetUp() * 100 )
						DarkRP.notify(self.Owner, 1, 5, "There is no vehicle behind the tow truck!")
						
						for i=1, #cars do
							if cars[i] != Vehicle and cars[i]:IsVehicle() then
								ent = cars[i]
								break
							end
						end
					end
					
					if ent:IsValid() and ent:IsVehicle() and ent:GetPhysicsObject():GetMass() < 8000 then
						local carfront = ent:NearestPoint( ent:GetPos() + Vector(0, 0, 12.5) + ent:GetForward() * 500 )
						if carfront:Distance( pos + Vehicle:GetForward() * -133.3848 + Vehicle:GetUp() * 73.928 ) < 75 then
							local constraint, rope = constraint.Rope( Vehicle, ent, 0, 0, Vector(0, -133.3848, 73.9280), ent:WorldToLocal(carfront), 60, 0, 17000, 1.5, "cable/cable2", false )
							Vehicle.IsTowing = true
							ent:Fire( "HandBrakeOff", "", 0.5 )
							DarkRP.notify(self.Owner, 1, 5, "Vehicle succesfully attached!")
						end
					end
				else
					local trace = util.TraceLine( {start = pos + Vector(0, 0, 27), endpos = pos + Vehicle:GetForward() * -200 + Vector(0, 0, 27), filter = Vehicle} )
					local ent = trace.Entity
					
					constraint.RemoveConstraints( Vehicle, "Rope" )
					Vehicle.IsTowing = false
					ent:Fire( "HandBrakeOn", "", 0.5 )
					DarkRP.notify(self.Owner, 1, 5, "Vehicle succesfully unattached!")
				end
			end
			if isClose then
				return
			end
		end
	end
end

function SWEP:SecondaryAttack()
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
	
	self.Weapon:SetNextSecondaryFire( CurTime() + 0.5 )
	
	if SERVER then
		local tr = self.Owner:GetEyeTrace()
		
		if tr.HitNonWorld then
			local doorData = tr.Entity:getDoorData()
			if not doorData then
				DarkRP.notify(self.Owner, 1, 5, "This vehicle has no owner!")
				return
			end
			
			umsg.Start("TOW_WarnOwner", self.Owner)
				umsg.String(doorData.owner:Nick())
				umsg.String(doorData.owner:SteamID())
				umsg.Entity(tr.Entity)
			umsg.End()
		end
	end
end