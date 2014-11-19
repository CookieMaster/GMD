function TOW_TowWarning(um)
local VehicleOwnerName = um:ReadString()
local VehicleOwner = um:ReadString()
local TheVehicle = um:ReadEntity()

	if GUI_TowWarn_Frame then 
		if GUI_TowWarn_Frame:IsValid() then 
			return false 
		end 
	end

	GUI_TowWarn_Frame = vgui.Create("DFrame")
	GUI_TowWarn_Frame:SetTitle("")
	GUI_TowWarn_Frame:SetSize(220,150)
	GUI_TowWarn_Frame:Center()
	GUI_TowWarn_Frame.Paint = function(CHPaint)
		-- Draw the menu background color.		
		draw.RoundedBox( 0, 0, 25, CHPaint:GetWide(), CHPaint:GetTall(), Color( 255, 255, 255, 150 ) )

		-- Draw the outline of the menu.
		surface.SetDrawColor(0,0,0,255)
		surface.DrawOutlinedRect(0, 0, CHPaint:GetWide(), CHPaint:GetTall())
		
		draw.RoundedBox( 0, 0, 0, CHPaint:GetWide(), 25, Color( 255, 255, 255, 200 ) )
			
		surface.SetDrawColor(0,0,0,255)
		surface.DrawOutlinedRect(0, 0, CHPaint:GetWide(), 25)

		-- Draw the top title.
		draw.SimpleText("Confirm Towed", "TowtruckFont", 57,12.5, Color(70,70,70,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	GUI_TowWarn_Frame:MakePopup()
	GUI_TowWarn_Frame:ShowCloseButton(false)

	local GUI_Main_Exit = vgui.Create("DButton")
	GUI_Main_Exit:SetParent(GUI_TowWarn_Frame)
	GUI_Main_Exit:SetSize(16,16)
	GUI_Main_Exit:SetPos(200,5)
	GUI_Main_Exit:SetText("")
	GUI_Main_Exit.Paint = function()
		surface.SetMaterial(Material("icon16/cross.png"))
		surface.SetDrawColor(200,200,0,200)
		surface.DrawTexturedRect(0,0,GUI_Main_Exit:GetWide(),GUI_Main_Exit:GetTall())
	end
	GUI_Main_Exit.DoClick = function()
		GUI_TowWarn_Frame:Remove()
	end

	local GUI_Sender_Label = vgui.Create("DLabel")
	GUI_Sender_Label:SetText("Vehicle Owner:")
	GUI_Sender_Label:SetFont("UiBold")
	GUI_Sender_Label:SetColor(Color(70,70,70,255))
	GUI_Sender_Label:SetParent(GUI_TowWarn_Frame)
	GUI_Sender_Label:SetPos(10,30)
	GUI_Sender_Label:SizeToContents()

	local GUI_Sender_Entry = vgui.Create("DTextEntry", GUI_TowWarn_Frame)
	GUI_Sender_Entry:SetText(VehicleOwnerName)
	GUI_Sender_Entry:SetEditable(false)
	GUI_Sender_Entry:SetFont("Trebuchet18")
	GUI_Sender_Entry:SetSize(200,25)
	GUI_Sender_Entry:SetPos(10,45)
	
	local GUI_Fine_Label = vgui.Create("DLabel")
	GUI_Fine_Label:SetText("Tow Fine:")
	GUI_Fine_Label:SetFont("UiBold")
	GUI_Fine_Label:SetColor(Color(70,70,70,255))
	GUI_Fine_Label:SetParent(GUI_TowWarn_Frame)
	GUI_Fine_Label:SetPos(10,75)
	GUI_Fine_Label:SizeToContents()

	local GUI_Fine_Entry = vgui.Create("DTextEntry", GUI_TowWarn_Frame)
	GUI_Fine_Entry:SetText("0")
	GUI_Fine_Entry:SetFont("Trebuchet18")
	GUI_Fine_Entry:SetNumeric( true )
	GUI_Fine_Entry:SetSize(200,25)
	GUI_Fine_Entry:SetPos(10,90)

	local GUI_ReplyButton = vgui.Create("DButton")
	GUI_ReplyButton:SetParent(GUI_TowWarn_Frame)
	GUI_ReplyButton:SetSize(200,25)
	GUI_ReplyButton:SetPos(10,120)
	GUI_ReplyButton:SetText("")
	GUI_ReplyButton.DoClick = function()
		if tonumber(GUI_Fine_Entry:GetValue()) < 0 then
			LocalPlayer():ChatPrint("Please enter positive value!")
			return
		end
		
		if GUI_Fine_Entry:GetValue() == "" then
			LocalPlayer():ChatPrint("Please enter a price for the fine!")
			return
		end
	
		net.Start("TOW_SubmitWarning")
			net.WriteString(VehicleOwner)
			net.WriteDouble(math.Clamp(tonumber(GUI_Fine_Entry:GetValue()),0,TOW_MaxFine))
			net.WriteEntity(TheVehicle)
		net.SendToServer()

		GUI_TowWarn_Frame:Remove()
	end
	GUI_ReplyButton.Paint = function()
		draw.RoundedBox(8,1,1,GUI_ReplyButton:GetWide()-2,GUI_ReplyButton:GetTall()-2,Color(0, 0, 0, 130))

		local struc = {}
		struc.pos = {}
		struc.pos[1] = 100 -- x pos
		struc.pos[2] = 12 -- y pos
		struc.color = Color(255,255,255,255) -- Red
		struc.text = "Confirm Towed" -- Text
		struc.font = "UiBold" -- Font
		struc.xalign = TEXT_ALIGN_CENTER-- Horizontal Alignment
		struc.yalign = TEXT_ALIGN_CENTER -- Vertical Alignment
		draw.Text( struc )
	end
end
usermessage.Hook("TOW_WarnOwner", TOW_TowWarning)

function Tow_PayFine(um)
local FinePrice = um:ReadString()
local TheVehicle = um:ReadEntity()

	if GUI_TowFine_Frame then 
		if GUI_TowFine_Frame:IsValid() then 
			return false 
		end 
	end

	GUI_TowFine_Frame = vgui.Create("DFrame")
	GUI_TowFine_Frame:SetTitle("")
	GUI_TowFine_Frame:SetSize(220,60)
	GUI_TowFine_Frame:Center()
	GUI_TowFine_Frame.Paint = function(CHPaint)
		-- Draw the menu background color.		
		draw.RoundedBox( 0, 0, 25, CHPaint:GetWide(), CHPaint:GetTall(), Color( 255, 255, 255, 150 ) )

		-- Draw the outline of the menu.
		surface.SetDrawColor(0,0,0,255)
		surface.DrawOutlinedRect(0, 0, CHPaint:GetWide(), CHPaint:GetTall())
		
		draw.RoundedBox( 0, 0, 0, CHPaint:GetWide(), 25, Color( 255, 255, 255, 200 ) )
			
		surface.SetDrawColor(0,0,0,255)
		surface.DrawOutlinedRect(0, 0, CHPaint:GetWide(), 25)

		-- Draw the top title.
		draw.SimpleText("Tow Fine", "TowtruckFont", 35,12.5, Color(70,70,70,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	GUI_TowFine_Frame:MakePopup()
	GUI_TowFine_Frame:ShowCloseButton(false)

	local GUI_Main_Exit = vgui.Create("DButton")
	GUI_Main_Exit:SetParent(GUI_TowFine_Frame)
	GUI_Main_Exit:SetSize(16,16)
	GUI_Main_Exit:SetPos(200,5)
	GUI_Main_Exit:SetText("")
	GUI_Main_Exit.Paint = function()
		surface.SetMaterial(Material("icon16/cross.png"))
		surface.SetDrawColor(200,200,0,200)
		surface.DrawTexturedRect(0,0,GUI_Main_Exit:GetWide(),GUI_Main_Exit:GetTall())
	end
	GUI_Main_Exit.DoClick = function()
		GUI_TowFine_Frame:Remove()
	end

	local GUI_AcceptButton = vgui.Create("DButton")
	GUI_AcceptButton:SetParent(GUI_TowFine_Frame)
	GUI_AcceptButton:SetSize(200,25)
	GUI_AcceptButton:SetPos(10,30)
	GUI_AcceptButton:SetText("")
	GUI_AcceptButton.DoClick = function()
		net.Start("TOW_PayTheFine")
			net.WriteEntity(TheVehicle)
		net.SendToServer()

		GUI_TowFine_Frame:Remove()
	end
	GUI_AcceptButton.Paint = function()
		draw.RoundedBox(8,1,1,GUI_AcceptButton:GetWide()-2,GUI_AcceptButton:GetTall()-2,Color(0, 0, 0, 130))

		local struc = {}
		struc.pos = {}
		struc.pos[1] = 100 -- x pos
		struc.pos[2] = 12 -- y pos
		struc.color = Color(255,255,255,255) -- Red
		if tonumber(FinePrice) == 0 then
			struc.text = "Unlock Vehicle (Free)" -- Text
		else
			struc.text = "Pay $"..FinePrice.." Fine" -- Text
		end
		struc.font = "UiBold" -- Font
		struc.xalign = TEXT_ALIGN_CENTER-- Horizontal Alignment
		struc.yalign = TEXT_ALIGN_CENTER -- Vertical Alignment
		draw.Text( struc )
	end
end
usermessage.Hook("TOW_PayTowFine", Tow_PayFine)

function TOWCL_TowFine(um)
	TheVehicle = um:ReadEntity()
	TheVehicle.TheOwner = um:ReadString()
	TheVehicle.TheFine = um:ReadString()
end
usermessage.Hook("TOWCL_PlaceFine", TOWCL_TowFine)

function TOW_DisplayTowedVehicle()
		for _, veh in pairs(ents.GetAll()) do
			if veh:GetClass() == "prop_vehicle_jeep" then
				if veh.TheOwner and veh.TheOwner == LocalPlayer():SteamID() then
				
					local pos = veh:GetPos():ToScreen()
					
					surface.SetFont("Trebuchet24")
					local x,y = surface.GetTextSize("Vehicle Towed")
					
					surface.SetTextPos(pos.x - x/2,pos.y - 40)
					surface.SetTextColor(Color(200,0,0,220))
					surface.DrawText("Vehicle Towed")
					
					surface.SetFont("UiBold")
					local x,y = surface.GetTextSize("Tow Fine: ".. veh.TheFine)
					
					surface.SetTextPos(pos.x - x/2,pos.y - 15)
					surface.SetTextColor(Color(0,200,0,220))
					surface.DrawText("Tow Fine: $".. veh.TheFine)
					
					surface.SetFont("UiBold")
					local x,y = surface.GetTextSize("Distance: ".. math.Round(veh:GetPos():Distance(LocalPlayer():GetPos())))
					
					surface.SetTextPos(pos.x - x/2,pos.y)
					surface.SetTextColor(Color(255,255,255,220))
					surface.DrawText("Distance: ".. math.Round(veh:GetPos():Distance(LocalPlayer():GetPos())))
				end
			end
		end
end
hook.Add("HUDDrawTargetID", "TOW_DisplayTowedVehicle", TOW_DisplayTowedVehicle)