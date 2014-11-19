-------------------------------- Dont Touch
RXDRPHUD = {}
RXDRPHUD.Color = {}
--------------------------------


RXDRPHUD.ShowArmorBar = true -- ' true ' or ' false '
RXDRPHUD.ShowHungerModBar = true -- ' true ' or ' false '

RXDRPHUD.TargetInfoPanelMaxDistance = 1200 -- when target went so far. info panel will be removed

RXDRPHUD.UseGradientTexture = false
-- if you set 'UseGradientTexture ' to false. system will use built in gmod gradient texture.
-- if you dont know how to setup FastDL, keep it ' false ' . ( if you didnt setup FastDL and set this ' true ' , you may see purple and black.
-- but if you know hot to setup FastDL and wants new Gradient Style. change it to ' true '




-- Color
	-- Target PlayerInfo
	RXDRPHUD.Color.TPI_LineColor = Color(0,150,255,255)
	RXDRPHUD.Color.TPI_NickColor = Color(0,150,255,255)
	RXDRPHUD.Color.TPI_HealthColor = Color(0,150,255,255)
	
	-- Player Wanted Info
	RXDRPHUD.Color.PW_TextColor = Color(255,0,0,255)
	
	
	-- ButtomBar
	RXDRPHUD.Color.BB_LineColor = Color(0,150,255,255)
		--HP
		RXDRPHUD.Color.BB_HP_TextColor = Color(0,220,255,255)
		RXDRPHUD.Color.BB_HP_BarColor = Color(0,150,255,255)
		--Armor
		RXDRPHUD.Color.BB_AR_TextColor = Color(0,220,255,255)
		RXDRPHUD.Color.BB_AR_BarColor = Color(255,100,0,255)
		--Hunger
		RXDRPHUD.Color.BB_HG_TextColor = Color(0,220,255,255)
		RXDRPHUD.Color.BB_HG_BarColor = Color(255,255,0,255)
		--Clock
		RXDRPHUD.Color.BB_CL_TextColor = Color(0,255,255,255)
	
	-- Agenda
	RXDRPHUD.Color.AgendaTitle = Color(0,150,255,255) -- title
	RXDRPHUD.Color.AgendaText = Color(0,150,255,255) -- body
	RXDRPHUD.Color.AgendaLineColor = Color(0,150,255,255)
	
	-- Player Info
	RXDRPHUD.Color.PI_LineColor = Color(0,150,255,255)
	RXDRPHUD.Color.PI_NameColor = Color(0,150,255,255)
	RXDRPHUD.Color.PI_InfoColor = Color(100,150,255,255)
	
	-- Gun Info
	RXDRPHUD.Color.GI_LineColor = Color(0,150,255,255)
	RXDRPHUD.Color.GI_GunNameColor = Color(0,150,255,255)
	RXDRPHUD.Color.GI_ClipNameColor = Color(0,220,255,255)
	RXDRPHUD.Color.GI_ClipAmountColor = Color(100,150,255,255)
	
	-- LockDown
	RXDRPHUD.Color.LD_Color = Color(0,0,255,255)
	