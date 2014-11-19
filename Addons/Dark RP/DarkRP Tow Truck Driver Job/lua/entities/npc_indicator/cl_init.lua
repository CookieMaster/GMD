

include("shared.lua")


function ENT:Initialize()
	self.Spin=0
end

function ENT:Draw()

		local realPos=self.Entity:GetPos()
		self.Spin=self.Spin+1
		self.Entity:SetAngles(Angle(0,self.Spin,0))
		 
		self.Entity:SetColor(Color(255,255,255,255))
		self.Entity:DrawModel()

end
