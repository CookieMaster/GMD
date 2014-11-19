-- For RocketMania's DarkRP HUD.
local Fonts = {}
	Fonts["RXF_CoolV"] = "coolvetica"
	Fonts["RXF_Treb"] = "Trebuchet MS"
	
	
for a,b in pairs(Fonts) do
	for k=10,40 do
		surface.CreateFont( a .. "_S"..k,{font = b,size = k,weight = 700})
		surface.CreateFont( a .. "Out_S"..k,{font = b,size = k,weight = 700,outline = true})
	end
end