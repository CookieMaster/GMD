AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include("shared.lua")

function ENT:Initialize()


	self.Entity:SetModel( Model( "models/extras/info_speech.mdl" ) )
	self.Entity:SetCollisionGroup(COLLISION_GROUP_WORLD)
		
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableCollisions( false )		
	end

	self.Entity:SetNotSolid( true )
	

end

function ENT:Think()
	if self.npc && self.npc:IsValid() then
		self.Entity:SetAngles( self.npc:GetAngles() )
	end
end


