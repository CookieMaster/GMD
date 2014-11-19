include("shared.lua")

timer.Simple(5, function()
	surface.CreateFont("TowtruckFont", {
		font = "Tahoma", 
		size = 15, 
		weight = 600
	})

	surface.CreateFont("Trebuchet20", {
		font = "Trebuchet MS", 
		size = 18, 
		weight = 900
	})

	surface.CreateFont("UiBold", {
		font = "Tahoma", 
		size = 14, 
		weight = 600
	}) 

	surface.CreateFont("Trebuchet24", {
		font = "Trebuchet MS", 
		size = 24, 
		weight = 900
	})
end)

function TowTruck_Menu()
	
	local GUI_Truck_Frame = vgui.Create("DFrame")
	GUI_Truck_Frame:SetTitle("")
	GUI_Truck_Frame:SetSize(450,220)
	GUI_Truck_Frame:Center()
	GUI_Truck_Frame.Paint = function(CHPaint)
		-- Draw the menu background color.		
		draw.RoundedBox( 0, 0, 25, CHPaint:GetWide(), CHPaint:GetTall(), Color( 255, 255, 255, 150 ) )

		-- Draw the outline of the menu.
		surface.SetDrawColor(0,0,0,255)
		surface.DrawOutlinedRect(0, 0, CHPaint:GetWide(), CHPaint:GetTall())
	
		draw.RoundedBox( 0, 0, 0, CHPaint:GetWide(), 25, Color( 255, 255, 255, 200 ) )
		
		surface.SetDrawColor(0,0,0,255)
		surface.DrawOutlinedRect(0, 0, CHPaint:GetWide(), 25)

		-- Draw the top title.
		draw.SimpleText("Tow Truck Station", "TowtruckFont", 64,12.5, Color(70,70,70,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	GUI_Truck_Frame:MakePopup()
	GUI_Truck_Frame:ShowCloseButton(false)
	
	local GUI_Main_Exit = vgui.Create("DButton")
	GUI_Main_Exit:SetParent(GUI_Truck_Frame)
	GUI_Main_Exit:SetSize(16,16)
	GUI_Main_Exit:SetPos(427,5)
	GUI_Main_Exit:SetText("")
	GUI_Main_Exit.Paint = function()
	surface.SetMaterial(Material("icon16/cross.png"))
	surface.SetDrawColor(200,200,0,200)
	surface.DrawTexturedRect(0,0,GUI_Main_Exit:GetWide(),GUI_Main_Exit:GetTall())
	end
	GUI_Main_Exit.DoClick = function()
		GUI_Truck_Frame:Remove()
	end
	
	local TruckDisplay = vgui.Create("DModelPanel", GUI_Truck_Frame)
	TruckDisplay:SetModel( TOWTRUCK_VehicleModel )
	TruckDisplay:SetPos( 50, -30 )
	TruckDisplay:SetSize( 350, 350 )
	TruckDisplay:GetEntity():SetAngles(Angle(255, 255, 255))
	TruckDisplay:SetCamPos( Vector( 255, 255, 80 ) )
	TruckDisplay:SetLookAt( Vector( 0, 0, 0 ) )
	
	local GUI_RemoveTruck = vgui.Create("DButton", GUI_Truck_Frame)	
	GUI_RemoveTruck:SetSize(250,20)
	GUI_RemoveTruck:SetPos(100,165)
	GUI_RemoveTruck:SetText("")
	GUI_RemoveTruck.Paint = function()
		draw.RoundedBox(8,1,1,GUI_RemoveTruck:GetWide()-2,GUI_RemoveTruck:GetTall()-2,Color(0, 0, 0, 130))

		local struc = {}
		struc.pos = {}
		struc.pos[1] = 125 -- x pos
		struc.pos[2] = 10 -- y pos
		struc.color = Color(255,255,255,255) -- Red
		struc.text = "Remove Current Tow Truck" -- Text
		struc.font = "UiBold" -- Font
		struc.xalign = TEXT_ALIGN_CENTER-- Horizontal Alignment
		struc.yalign = TEXT_ALIGN_CENTER -- Vertical Alignment
		draw.Text( struc )
	end
	
	GUI_RemoveTruck.DoClick = function()
		net.Start("TOWTRUCK_RemoveTowTruck")
		net.SendToServer()
		
		GUI_Truck_Frame:Remove()
	end
	
	local GUI_GetTruck = vgui.Create("DButton", GUI_Truck_Frame)	
	GUI_GetTruck:SetSize(200,25)
	GUI_GetTruck:SetPos(20,190)
	GUI_GetTruck:SetText("")
	GUI_GetTruck.Paint = function()
		draw.RoundedBox(8,1,1,GUI_GetTruck:GetWide()-2,GUI_GetTruck:GetTall()-2,Color(0, 0, 0, 130))

		local struc = {}
		struc.pos = {}
		struc.pos[1] = 100 -- x pos
		struc.pos[2] = 12.5 -- y pos
		struc.color = Color(255,255,255,255) -- Red
		struc.text = "Retrieve Tow Truck" -- Text
		struc.font = "UiBold" -- Font
		struc.xalign = TEXT_ALIGN_CENTER-- Horizontal Alignment
		struc.yalign = TEXT_ALIGN_CENTER -- Vertical Alignment
		draw.Text( struc )
	end
	
	GUI_GetTruck.DoClick = function()
		net.Start("TowTruck_CreateTowTruck")
		net.SendToServer()
		
		GUI_Truck_Frame:Remove()
	end
	
	local GUI_LeaveMenu = vgui.Create("DButton", GUI_Truck_Frame)	
	GUI_LeaveMenu:SetSize(200,25)
	GUI_LeaveMenu:SetPos(225,190)
	GUI_LeaveMenu:SetText("")
	GUI_LeaveMenu.Paint = function()
		draw.RoundedBox(8,1,1,GUI_LeaveMenu:GetWide()-2,GUI_LeaveMenu:GetTall()-2,Color(0, 0, 0, 130))

		local struc = {}
		struc.pos = {}
		struc.pos[1] = 100 -- x pos
		struc.pos[2] = 12.5 -- y pos
		struc.color = Color(255,255,255,255) -- Red
		struc.text = "Leave Station" -- Text
		struc.font = "UiBold" -- Font
		struc.xalign = TEXT_ALIGN_CENTER-- Horizontal Alignment
		struc.yalign = TEXT_ALIGN_CENTER -- Vertical Alignment
		draw.Text( struc )
	end
	
	GUI_LeaveMenu.DoClick = function()
		GUI_Truck_Frame:Remove()
	end
end
usermessage.Hook("TOW_TowTruck_Menu", TowTruck_Menu)