/*---------------------------------------------------------------------------
HUD ConVars
---------------------------------------------------------------------------*/
local ConVars = {}
local HUDWidth
local HUDHeight

local Color = Color
local cvars = cvars
local draw = draw
local GetConVar = GetConVar
local Lerp = Lerp
local localplayer
local pairs = pairs
local SortedPairs = SortedPairs
local string = string
local surface = surface
local table = table
local tostring = tostring

CreateClientConVar("weaponhud", 0, true, false)

local function ReloadConVars()
	ConVars = {
		background = {0,0,0,100},
		Healthbackground = {0,0,0,200},
		Healthforeground = {140,0,0,180},
		HealthText = {255,255,255,200},
		Job1 = {0,0,150,200},
		Job2 = {0,0,0,255},
		salary1 = {0,150,0,200},
		salary2 = {0,0,0,255}
	}

	for name, Colour in pairs(ConVars) do
		ConVars[name] = {}
		for num, rgb in SortedPairs(Colour) do
			local CVar = GetConVar(name..num) or CreateClientConVar(name..num, rgb, true, false)
			table.insert(ConVars[name], CVar:GetInt())

			if not cvars.GetConVarCallbacks(name..num, false) then
				cvars.AddChangeCallback(name..num, function() timer.Simple(0,ReloadConVars) end)
			end
		end
		ConVars[name] = Color(unpack(ConVars[name]))
	end


	HUDWidth = (GetConVar("HudW") or  CreateClientConVar("HudW", 240, true, false)):GetInt()
	HUDHeight = (GetConVar("HudH") or CreateClientConVar("HudH", 115, true, false)):GetInt()

	if not cvars.GetConVarCallbacks("HudW", false) and not cvars.GetConVarCallbacks("HudH", false) then
		cvars.AddChangeCallback("HudW", function() timer.Simple(0,ReloadConVars) end)
		cvars.AddChangeCallback("HudH", function() timer.Simple(0,ReloadConVars) end)
	end
end
ReloadConVars()

local function formatNumber(n)
	if not n then return "" end
	if n >= 1e14 then return tostring(n) end
    n = tostring(n)
    local sep = sep or ","
    local dp = string.find(n, "%.") or #n+1
	for i=dp-4, 1, -3 do
		n = n:sub(1, i) .. sep .. n:sub(i+1)
    end
    return n
end

local GraMat = Material("gui/gradient")
local GraMat2 = Material("materials/rocketmania/darkrphud/grad_bg_4_1_white.png")


local Scrw, Scrh, RelativeX, RelativeY
/*---------------------------------------------------------------------------
HUD Seperate Elements
---------------------------------------------------------------------------*/
local Health = 0
local function DrawHealth() -- disabled
	Health = math.min(100, (Health == localplayer:Health() and Health) or Lerp(0.1, Health, localplayer:Health()))

	local DrawHealth = math.Min(Health / GAMEMODE.Config.startinghealth, 1)
	local Border = math.Min(6, math.pow(2, math.Round(3*DrawHealth)))
	draw.RoundedBox(Border, RelativeX + 4, RelativeY - 30, HUDWidth - 8, 20, ConVars.Healthbackground)
	draw.RoundedBox(Border, RelativeX + 5, RelativeY - 29, (HUDWidth - 9) * DrawHealth, 18, ConVars.Healthforeground)

	draw.DrawText(math.Max(0, math.Round(localplayer:Health())), "DarkRPHUD2", RelativeX + 4 + (HUDWidth - 8)/2, RelativeY - 32, ConVars.HealthText, 1)

	-- Armor
	local armor = localplayer:Armor()
	if armor ~= 0 then
		draw.RoundedBox(2, RelativeX + 4, RelativeY - 15, (HUDWidth - 8) * armor / 100, 5, Color(0, 0, 255, 255))
	end
end

local function DrawInfo() -- disabled
	local Salary = DarkRP.getPhrase("salary", GAMEMODE.Config.currency, (localplayer:getDarkRPVar("salary") or 0))

	local JobWallet = {
		DarkRP.getPhrase("job", localplayer:getDarkRPVar("job") or ""), "\n",
		DarkRP.getPhrase("wallet", GAMEMODE.Config.currency, formatNumber(localplayer:getDarkRPVar("money") or 0))
	}
	JobWallet = table.concat(JobWallet)

	local wep = localplayer:GetActiveWeapon()

	if IsValid(wep) and GAMEMODE.Config.weaponhud then
        local name = wep:GetPrintName();
		draw.DrawText(DarkRP.getPhrase("weapon", name), "UiBold", RelativeX + 5, RelativeY - HUDHeight - 18, Color(255, 255, 255, 255), 0)
	end

	draw.DrawText(Salary, "DarkRPHUD2", RelativeX + 5, RelativeY - HUDHeight + 6, ConVars.salary1, 0)
	draw.DrawText(Salary, "DarkRPHUD2", RelativeX + 4, RelativeY - HUDHeight + 5, ConVars.salary2, 0)

	surface.SetFont("DarkRPHUD2")
	local w, h = surface.GetTextSize(Salary)

	draw.DrawText(JobWallet, "DarkRPHUD2", RelativeX + 5, RelativeY - HUDHeight + h + 6, ConVars.Job1, 0)
	draw.DrawText(JobWallet, "DarkRPHUD2", RelativeX + 4, RelativeY - HUDHeight + h + 5, ConVars.Job2, 0)
end

local Page = Material("icon16/page_white_text.png")
local function GunLicense() -- disabled
	if localplayer:getDarkRPVar("HasGunlicense") then
		surface.SetMaterial(Page)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawTexturedRect(RelativeX + HUDWidth, ScrH() - 34, 32, 32)
	end
end

local function Agenda()
	local DrawAgenda, AgendaManager = DarkRPAgendas[localplayer:Team()], localplayer:Team()
	if not DrawAgenda then
		for k,v in pairs(DarkRPAgendas) do
			if table.HasValue(v.Listeners or {}, localplayer:Team()) then
				DrawAgenda, AgendaManager = DarkRPAgendas[k], k
				break
			end
		end
	end
	if DrawAgenda then
	
		if RXDRPHUD.UseGradientTexture then
			surface.SetMaterial(GraMat2)
			surface.SetDrawColor(0,0,0,240) 
			surface.DrawTexturedRect(-20,10,520, 110)

			surface.SetDrawColor(RXDRPHUD.Color.AgendaLineColor)
			surface.DrawTexturedRect(10,10,460, 2)
			surface.DrawTexturedRect(10,120,460, 2)
			
			surface.SetDrawColor(RXDRPHUD.Color.AgendaLineColor.r,RXDRPHUD.Color.AgendaLineColor.g,RXDRPHUD.Color.AgendaLineColor.b,100)
			surface.DrawTexturedRect(30,30,420, 1)
		else
			surface.SetMaterial(GraMat)
			surface.SetDrawColor(0,0,0,240) 
			surface.DrawTexturedRect(-20,10,520, 110)
			surface.DrawTexturedRect(-20,10,520, 110)

			surface.SetDrawColor(RXDRPHUD.Color.AgendaLineColor)
			surface.DrawTexturedRect(0,10,480, 2)
			surface.DrawTexturedRect(0,10,480, 2)
			surface.DrawTexturedRect(0,120,480, 2)
			surface.DrawTexturedRect(0,120,480, 2)
			
			surface.SetDrawColor(RXDRPHUD.Color.AgendaLineColor.r,RXDRPHUD.Color.AgendaLineColor.g,RXDRPHUD.Color.AgendaLineColor.b,100)
			surface.DrawTexturedRect(30,30,420, 1)
		end
		draw.DrawText(DrawAgenda.Title, "RXF_TrebOut_S20", 50, 10, RXDRPHUD.Color.AgendaTitle,0)

		local AgendaText = {}
		for k,v in pairs(team.GetPlayers(AgendaManager)) do
			if not v.DarkRPVars then continue end
			table.insert(AgendaText, v:getDarkRPVar("agenda"))
		end

		local text = table.concat(AgendaText, "\n")
		text = text:gsub("//", "\n"):gsub("\\n", "\n")
		text = DarkRP.textWrap(text, "RXF_TrebOut_S20", 440)
		draw.DrawText(text, "RXF_TrebOut_S20", 30, 35, RXDRPHUD.Color.AgendaText,0)
	end
end

local VoiceChatTexture = surface.GetTextureID("voice/icntlk_pl")
local function DrawVoiceChat()
	if localplayer.DRPIsTalking then
		local chbxX, chboxY = chat.GetChatBoxPos()

		local Rotating = math.sin(CurTime()*3)
		local backwards = 0
		if Rotating < 0 then
			Rotating = 1-(1+Rotating)
			backwards = 180
		end
		surface.SetTexture(VoiceChatTexture)
		surface.SetDrawColor(ConVars.Healthforeground)
		surface.DrawTexturedRectRotated(ScrW() - 100, chboxY, Rotating*96, 96, backwards)
	end
end

CreateConVar("DarkRP_LockDown", 0, {FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE})
local function LockDown()
	if !RXDRPHUD then return end
	
	local chbxX, chboxY = chat.GetChatBoxPos()
	if util.tobool(GetConVarNumber("DarkRP_LockDown")) then
		local cin = (math.sin(CurTime()) + 1) / 2
		local chatBoxSize = math.floor(ScrH() / 4)
		
		local Col = RXDRPHUD.Color.LD_Color
		
		
		draw.DrawText(DarkRP.getPhrase("lockdown_started"), "RXF_Treb_S25", ScrW()/2, ScrH()-70, Color( cin * Col.r, cin * Col.g,  cin * Col.b, Col.a), TEXT_ALIGN_CENTER)
	end
end

local Arrested = function() end

usermessage.Hook("GotArrested", function(msg)
	local StartArrested = CurTime()
	local ArrestedUntil = msg:ReadFloat()

	Arrested = function()
		if CurTime() - StartArrested <= ArrestedUntil and localplayer:getDarkRPVar("Arrested") then
		draw.DrawText(DarkRP.getPhrase("youre_arrested", math.ceil(ArrestedUntil - (CurTime() - StartArrested))), "DarkRPHUD1", ScrW()/2, ScrH() - ScrH()/12, Color(255,255,255,255), 1)
		elseif not localplayer:getDarkRPVar("Arrested") then
			Arrested = function() end
		end
	end
end)

local AdminTell = function() end

usermessage.Hook("AdminTell", function(msg)
	timer.Destroy("DarkRP_AdminTell")
	local Message = msg:ReadString()

	AdminTell = function()
		draw.RoundedBox(4, 10, 10, ScrW() - 20, 100, Color(0, 0, 0, 200))
		draw.DrawText(DarkRP.getPhrase("listen_up"), "GModToolName", ScrW() / 2 + 10, 10, Color(255, 255, 255, 255), 1)
		draw.DrawText(Message, "ChatFont", ScrW() / 2 + 10, 80, Color(200, 30, 30, 255), 1)
	end

	timer.Create("DarkRP_AdminTell", 10, 1, function()
		AdminTell = function() end
	end)
end)






local function RXHUD_Main()
	if !RXDRPHUD then return end
	
	surface.SetDrawColor( 0, 0, 0, 245 )
	surface.DrawRect(0,ScrH()-39,ScrW(),39)
	surface.SetDrawColor(RXDRPHUD.Color.BB_LineColor)
	surface.DrawRect(0,ScrH()-40,ScrW(),2)
	
	draw.DrawText(os.date( "%p %I:%M" ), "RXF_TrebOut_S20", ScrW()-80,ScrH()-38, RXDRPHUD.Color.BB_CL_TextColor, TEXT_ALIGN_CENTER)
	draw.DrawText(os.date( "20%y-%m-%d" ), "RXF_TrebOut_S20", ScrW()-80,ScrH()-18, RXDRPHUD.Color.BB_CL_TextColor, TEXT_ALIGN_CENTER )

	-- PlayerInfo
	if RXDRPHUD.UseGradientTexture then
		surface.SetMaterial(GraMat2)
		surface.SetDrawColor(0,0,0,240) 
		surface.DrawTexturedRect(0,ScrH()-125,260, 80)
		
		surface.SetDrawColor(RXDRPHUD.Color.PI_LineColor) 
		surface.DrawTexturedRect(10,ScrH()-125,240, 1)
		surface.DrawTexturedRect(10,ScrH()-45,240, 1)
		
		surface.SetDrawColor(RXDRPHUD.Color.PI_LineColor.r,RXDRPHUD.Color.PI_LineColor.g,RXDRPHUD.Color.PI_LineColor.b,RXDRPHUD.Color.PI_LineColor.a/2) 
		surface.DrawTexturedRect(20,ScrH()-105,220, 1)
	else
		surface.SetMaterial(GraMat)
		surface.SetDrawColor(0,0,0,240) 
		surface.DrawTexturedRect(0,ScrH()-125,350, 80)
		surface.DrawTexturedRect(0,ScrH()-125,350, 80)
		
		surface.SetDrawColor(RXDRPHUD.Color.PI_LineColor) 
		surface.DrawTexturedRect(0,ScrH()-125,350, 1)
		surface.DrawTexturedRect(0,ScrH()-45,350, 1)
		
		surface.SetDrawColor(RXDRPHUD.Color.PI_LineColor.r,RXDRPHUD.Color.PI_LineColor.g,RXDRPHUD.Color.PI_LineColor.b,RXDRPHUD.Color.PI_LineColor.a/2) 
		surface.DrawTexturedRect(10,ScrH()-105,280, 1)
		surface.DrawTexturedRect(10,ScrH()-105,280, 1)

	end
	draw.DrawText(LocalPlayer():Nick(), "RXF_TrebOut_S20", 120, ScrH()-125, RXDRPHUD.Color.PI_NameColor, TEXT_ALIGN_CENTER)
	draw.DrawText("Job : " .. (LocalPlayer():getDarkRPVar("job") or ""), "RXF_TrebOut_S20", 40, ScrH()-105, RXDRPHUD.Color.PI_InfoColor)
	draw.DrawText("Salary : " .. GAMEMODE.Config.currency ..  (LocalPlayer():getDarkRPVar("salary") or 0), "RXF_TrebOut_S20", 40, ScrH()-85, RXDRPHUD.Color.PI_InfoColor)
	draw.DrawText("Wallet : " .. (LocalPlayer():getDarkRPVar("money") or 0), "RXF_TrebOut_S20", 40, ScrH()-65, RXDRPHUD.Color.PI_InfoColor)
	-- PlayerInfo
	
	
	-- PBAR : HP
	local VA,VM = LocalPlayer():Health(),100
	local PX,PY,SY = 90,ScrH()-30,20
	local Percent = math.min(100,(VA/VM)*100)
	
	local Count = 50
	local Width = 3
	
	draw.DrawText("Health", "RXF_TrebOut_S30", 15, ScrH()-35, RXDRPHUD.Color.BB_HP_TextColor)

	for k=1,Count do
		local X1 = PX+((Width+1)*k)
		if k*2 <= Percent then
			surface.SetDrawColor( RXDRPHUD.Color.BB_HP_BarColor )
			surface.DrawRect(X1,PY,Width,SY)
			surface.SetDrawColor( RXDRPHUD.Color.BB_HP_BarColor.r/2,RXDRPHUD.Color.BB_HP_BarColor.g/2,RXDRPHUD.Color.BB_HP_BarColor.b/2,RXDRPHUD.Color.BB_HP_BarColor.a )
			surface.DrawRect(X1,math.Round(PY + SY/3*2)+1,Width,SY/3)
		else
			surface.SetDrawColor( 50, 50, 50, 255 )
			surface.DrawRect(X1,PY,Width,SY)
			surface.SetDrawColor( 20, 20, 20, 255 )
			surface.DrawRect(X1,math.Round(PY + SY/3*2)+1,Width,SY/3)
		end
	end
	
	draw.DrawText(VA .. "/" .. VM, "RXF_TrebOut_S20", PX+100, ScrH()-32, RXDRPHUD.Color.BB_HP_TextColor,TEXT_ALIGN_CENTER)

	-- PBAR : ARMOR
	if RXDRPHUD.ShowArmorBar then
		local VA,VM = LocalPlayer():Armor(),100
		local PX,PY,SY = 400,ScrH()-30,20
		local Percent = math.min(100,(VA/VM)*100)
		
		local Count = 50
		local Width = 3
		
		draw.DrawText("Armor", "RXF_TrebOut_S30", 320, ScrH()-35, RXDRPHUD.Color.BB_AR_TextColor)

		for k=1,Count do
			local X1 = PX+((Width+1)*k)
			if k*2 <= Percent then
				surface.SetDrawColor( RXDRPHUD.Color.BB_AR_BarColor )
				surface.DrawRect(X1,PY,Width,SY)
				surface.SetDrawColor( RXDRPHUD.Color.BB_AR_BarColor.r/2,RXDRPHUD.Color.BB_AR_BarColor.g/2,RXDRPHUD.Color.BB_AR_BarColor.b/2,RXDRPHUD.Color.BB_AR_BarColor.a )
				surface.DrawRect(X1,math.Round(PY + SY/3*2)+1,Width,SY/3)
			else
				surface.SetDrawColor( 50, 50, 50, 255 )
				surface.DrawRect(X1,PY,Width,SY)
				surface.SetDrawColor( 20, 20, 20, 255 )
				surface.DrawRect(X1,math.Round(PY + SY/3*2)+1,Width,SY/3)
			end
		end

		draw.DrawText(VA .. "/" .. VM, "RXF_TrebOut_S20", PX+100, ScrH()-32, RXDRPHUD.Color.BB_AR_TextColor,TEXT_ALIGN_CENTER)
	end
	
	-- PBAR : HUNGER
	if RXDRPHUD.ShowHungerModBar then
		local VA,VM = (LocalPlayer():getDarkRPVar("Energy") or 0),100
		local PX,PY,SY = 710,ScrH()-30,20
		local Percent = math.min(100,(VA/VM)*100)
		
		local Count = 50
		local Width = 3
		
		draw.DrawText("Hunger", "RXF_TrebOut_S30", 625, ScrH()-35, RXDRPHUD.Color.BB_HG_TextColor)

		for k=1,Count do
			local X1 = PX+((Width+1)*k)
			if k*2 <= Percent then
				surface.SetDrawColor( RXDRPHUD.Color.BB_HG_BarColor )
				surface.DrawRect(X1,PY,Width,SY)
				surface.SetDrawColor( RXDRPHUD.Color.BB_HG_BarColor.r/2,RXDRPHUD.Color.BB_HG_BarColor.g/2,RXDRPHUD.Color.BB_HG_BarColor.b/2,RXDRPHUD.Color.BB_HG_BarColor.a )
				surface.DrawRect(X1,math.Round(PY + SY/3*2)+1,Width,SY/3)
			else
				surface.SetDrawColor( 50, 50, 50, 255 )
				surface.DrawRect(X1,PY,Width,SY)
				surface.SetDrawColor( 20, 20, 20, 255 )
				surface.DrawRect(X1,math.Round(PY + SY/3*2)+1,Width,SY/3)
			end
		end

		draw.DrawText(VA .. "/" .. VM, "RXF_TrebOut_S20", PX+100, ScrH()-32, RXDRPHUD.Color.BB_HG_TextColor,TEXT_ALIGN_CENTER)
	end
	
end


hook.Add("HUDShouldDraw","HideWeapon",function(name)
	if name == "CHudAmmo" then return false end
end)


local function RXHUD_Weapon()
	local wep = LocalPlayer():GetActiveWeapon()
	if !wep or !wep:IsValid() then return end
	
	if RXDRPHUD.UseGradientTexture then
		surface.SetMaterial(GraMat2)

		surface.SetDrawColor(0,0,0,240) 
		surface.DrawTexturedRect(ScrW()-230,ScrH()-125,220, 80)
		
		surface.SetDrawColor(RXDRPHUD.Color.GI_LineColor) 
		surface.DrawTexturedRect(ScrW()-220,ScrH()-125,200, 1)
		surface.DrawTexturedRect(ScrW()-220,ScrH()-45,200, 1)
		
		surface.SetDrawColor(RXDRPHUD.Color.GI_LineColor.r,RXDRPHUD.Color.GI_LineColor.g,RXDRPHUD.Color.GI_LineColor.b,RXDRPHUD.Color.GI_LineColor.a/2) 
		surface.DrawTexturedRect(ScrW()-210,ScrH()-105,180, 1)
	else
		surface.SetMaterial(GraMat)

		surface.SetDrawColor(0,0,0,240) 
		surface.DrawTexturedRectRotated(ScrW()-150,ScrH()-85,300, 80,180)
		surface.DrawTexturedRectRotated(ScrW()-150,ScrH()-85,300, 80,180)
		
		surface.SetDrawColor(RXDRPHUD.Color.GI_LineColor) 
		surface.DrawTexturedRectRotated(ScrW()-150,ScrH()-125,300, 1,180)
		surface.DrawTexturedRectRotated(ScrW()-150,ScrH()-125,300, 1,180)
		surface.DrawTexturedRectRotated(ScrW()-150,ScrH()-45,300, 1,180)
		surface.DrawTexturedRectRotated(ScrW()-150,ScrH()-45,300, 1,180)
		
		surface.SetDrawColor(RXDRPHUD.Color.GI_LineColor.r,RXDRPHUD.Color.GI_LineColor.g,RXDRPHUD.Color.GI_LineColor.b,RXDRPHUD.Color.GI_LineColor.a/2) 
		surface.DrawTexturedRectRotated(ScrW()-150,ScrH()-105,300, 1,180)
	end
    local name = wep:GetClass()
	if wep.GetPrintName and wep:GetPrintName() then
		name = wep:GetPrintName()	end

	draw.DrawText(name, "RXF_TrebOut_S20", ScrW()-120, ScrH()-125,RXDRPHUD.Color.GI_GunNameColor, TEXT_ALIGN_CENTER)
	---- Weapon Name
	
    local mag_left = wep:Clip1()
    local mag_extra = LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType())
	local smag_left = wep:Clip2()
	
	mag_left = math.min(mag_left,999)
	mag_extra = math.min(mag_extra,999)
	smag_left = math.min(smag_left,999)

	draw.DrawText("Clip 1", "RXF_TrebOut_S25", ScrW()-160, ScrH()-100, RXDRPHUD.Color.GI_ClipNameColor, TEXT_ALIGN_CENTER)
	if mag_left == -1 then
		draw.DrawText("Unlimited", "RXF_TrebOut_S23", ScrW()-160, ScrH()-76, RXDRPHUD.Color.GI_ClipAmountColor, TEXT_ALIGN_CENTER)
	else
		draw.DrawText(mag_left .. " / " .. mag_extra, "RXF_TrebOut_S25", ScrW()-160, ScrH()-76, RXDRPHUD.Color.GI_ClipAmountColor, TEXT_ALIGN_CENTER)
	end
	
	draw.DrawText("Clip 2", "RXF_TrebOut_S25", ScrW()-70, ScrH()-100, RXDRPHUD.Color.GI_ClipNameColor, TEXT_ALIGN_CENTER)
	if smag_left == -1 then
		draw.DrawText("Unlimited", "RXF_TrebOut_S23", ScrW()-70, ScrH()-76, RXDRPHUD.Color.GI_ClipAmountColor, TEXT_ALIGN_CENTER)
	else
		draw.DrawText(smag_left, "RXF_TrebOut_S25", ScrW()-70, ScrH()-76, RXDRPHUD.Color.GI_ClipAmountColor, TEXT_ALIGN_CENTER)
	end
	
	
end



/*---------------------------------------------------------------------------
Drawing the HUD elements such as Health etc.
---------------------------------------------------------------------------*/
local function DrawHUD()
	localplayer = localplayer and IsValid(localplayer) and localplayer or LocalPlayer()
	if not IsValid(localplayer) then return end

	local shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_HUD")
	if shouldDraw == false then return end

	Scrw, Scrh = ScrW(), ScrH()
	RelativeX, RelativeY = 0, Scrh

	--DrawHealth()
	--DrawInfo()
	--GunLicense()
	
	Agenda()
	DrawVoiceChat()
	LockDown()

	Arrested()
	AdminTell()
	
	RXHUD_Main()
	RXHUD_Weapon()
end

/*---------------------------------------------------------------------------
Entity HUDPaint things
---------------------------------------------------------------------------*/
local function DrawPlayerInfo(ply)
	if !RXDRPHUD then return end
	if LocalPlayer():GetPos():Distance(ply:GetPos()) > RXDRPHUD.TargetInfoPanelMaxDistance then return end
	
	local pos = ply:EyePos()

	pos.z = pos.z + 10 -- The position we want is a bit above the position of the eyes
	pos = pos:ToScreen()
	pos.y = pos.y - 50 -- Move the text up a few pixels to compensate for the height of the text


	if RXDRPHUD.UseGradientTexture then
		surface.SetMaterial(GraMat2)
		surface.SetDrawColor(0,0,0,240) 
		surface.DrawTexturedRect(pos.x-130,pos.y,260, 70)
		
		surface.SetDrawColor(RXDRPHUD.Color.TPI_LineColor) 
		surface.DrawTexturedRect(pos.x-130,pos.y,260, 1)
		surface.DrawTexturedRect(pos.x-130,pos.y+70,260, 1)
		
		surface.SetDrawColor(RXDRPHUD.Color.TPI_LineColor.r,RXDRPHUD.Color.TPI_LineColor.g,RXDRPHUD.Color.TPI_LineColor.b,RXDRPHUD.Color.TPI_LineColor.a/2) 
		surface.DrawTexturedRect(pos.x-110,pos.y+20,220, 1)
	else
		surface.SetDrawColor(0,0,0,240) 
		surface.DrawRect(pos.x-130,pos.y,260, 70)
		
		surface.SetDrawColor(RXDRPHUD.Color.TPI_LineColor) 
		surface.DrawRect(pos.x-130,pos.y,260, 1)
		surface.DrawRect(pos.x-130,pos.y+70,260, 1)
		
		surface.SetDrawColor(RXDRPHUD.Color.TPI_LineColor.r,RXDRPHUD.Color.TPI_LineColor.g,RXDRPHUD.Color.TPI_LineColor.b,RXDRPHUD.Color.TPI_LineColor.a/2) 
		surface.DrawRect(pos.x-110,pos.y+20,220, 1)
	end
	
	if GAMEMODE.Config.showname and not ply:getDarkRPVar("wanted") then
		draw.DrawText(ply:Nick(), "RXF_TrebOut_S20", pos.x + 1, pos.y-1,RXDRPHUD.Color.TPI_NickColor, 1)
		draw.DrawText(DarkRP.getPhrase("health", ply:Health()) or ("Health : " .. ply:Health()), "RXF_TrebOut_S20", pos.x + 1, pos.y + 21, RXDRPHUD.Color.TPI_HealthColor, 1)
	end

	if GAMEMODE.Config.showjob then
		local teamname = team.GetName(ply:Team())
		draw.DrawText(ply:getDarkRPVar("job") or teamname, "RXF_TrebOut_S20", pos.x + 1, pos.y + 41, team.GetColor(ply:Team()), 1)
	end

	if ply:getDarkRPVar("HasGunlicense") then
		surface.SetMaterial(Page)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(pos.x+70, pos.y + 28, 32, 32)
	end
end

local function DrawWantedInfo(ply)
	if not ply:Alive() then return end

	local pos = ply:EyePos()
	if not pos:isInSight({localplayer, ply}) then return end

	pos.z = pos.z + 14
	pos = pos:ToScreen()

	local wantedText = DarkRP.getPhrase("wanted", tostring(ply:getDarkRPVar("wantedReason")))

	draw.DrawText(wantedText, "RXF_TrebOut_S25", pos.x, pos.y - 90, RXDRPHUD.Color.PW_TextColor, 1)
end

/*---------------------------------------------------------------------------
The Entity display: draw HUD information about entities
---------------------------------------------------------------------------*/
local function DrawEntityDisplay()
	local shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_EntityDisplay")
	if shouldDraw == false then return end

	local shootPos = localplayer:GetShootPos()
	local aimVec = localplayer:GetAimVector()

	for k, ply in pairs(player.GetAll()) do
		if not ply:Alive() then continue end
		local hisPos = ply:GetShootPos()
		if ply:getDarkRPVar("wanted") then DrawWantedInfo(ply) end

		if GAMEMODE.Config.globalshow and ply ~= localplayer then
			DrawPlayerInfo(ply)
		-- Draw when you're (almost) looking at him
		elseif not GAMEMODE.Config.globalshow and hisPos:Distance(shootPos) < 400 then
			local pos = ply:EyePos()
			if pos:isInSight({LocalPlayer(), ply}) then
				DrawPlayerInfo(ply)
			end
		end
	end

	local tr = localplayer:GetEyeTrace()

	if IsValid(tr.Entity) and tr.Entity:isKeysOwnable() and tr.Entity:GetPos():Distance(localplayer:GetPos()) < 200 then
		tr.Entity:drawOwnableInfo()
	end
end

/*---------------------------------------------------------------------------
Drawing death notices
---------------------------------------------------------------------------*/
function GM:DrawDeathNotice(x, y)
	if not GAMEMODE.Config.showdeaths then return end
	self.BaseClass:DrawDeathNotice(x, y)
end

/*---------------------------------------------------------------------------
Display notifications
---------------------------------------------------------------------------*/
local function DisplayNotify(msg)
	local txt = msg:ReadString()
	GAMEMODE:AddNotify(txt, msg:ReadShort(), msg:ReadLong())
	surface.PlaySound("buttons/lightswitch2.wav")

	-- Log to client console
	print(txt)
end
usermessage.Hook("_Notify", DisplayNotify)

/*---------------------------------------------------------------------------
Remove some elements from the HUD in favour of the DarkRP HUD
---------------------------------------------------------------------------*/
function GM:HUDShouldDraw(name)
	if name == "CHudHealth" or
		name == "CHudBattery" or
		name == "CHudSuitPower" or
		(HelpToggled and name == "CHudChat") then
			return false
	else
		return true
	end
end

/*---------------------------------------------------------------------------
Disable players' names popping up when looking at them
---------------------------------------------------------------------------*/
function GM:HUDDrawTargetID()
    return false
end

/*---------------------------------------------------------------------------
Actual HUDPaint hook
---------------------------------------------------------------------------*/
function GM:HUDPaint()
	DrawHUD()
	DrawEntityDisplay()

	self.BaseClass:HUDPaint()
end
