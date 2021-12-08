--[[ Made by:
 ____ ___  _  __ _____  ___  _  __
|_  //   \| |/ /|_   _|/   \| |/ /
 / / | - ||   <   | |  | - ||   < 
/___||_|_||_|\_\  |_|  |_|_||_|\_\

--]]

include("shared.lua")

local width = 225
local height = 150

local color_zk_01 = Color(255, 0, 0, 255)
local color_zk_frameout = Color( 0, 75, 255, 255 )

surface.CreateFont( "zk_med_scanner_01", {
	font = "Roboto lt",
	extended = false,
	size = 35,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "zk_med_scanner_02", {
	font = "Roboto lt",
	extended = false,
	size = 30,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "zk_med_scanner_03", {
	font = "Roboto lt",
	extended = false,
	size = 125,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "zk_med_scanner_04", {
	font = "Roboto lt",
	extended = false,
	size = 18,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )


local function DrawButton(txt, hovered, x, y)
	if hovered then
        draw.SimpleText(txt, "zk_med_scanner_03", x, y, color_zk_01, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText(txt, "zk_med_scanner_03", x, y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end


--[[-------------------------------------------------------
Name: ENT:OnRemove()
Desc: Called when the entity is about to be removed.
---------------------------------------------------------]]
function ENT:OnRemove()
end


--[[-------------------------------------------------------
Name: ENT:Draw()
Desc: Called if and when the entity should be drawn opaquely.
---------------------------------------------------------]]
function ENT:Draw()
    self:DrawModel()

    if ( self.IsActive and IsValid(self) ) then
    	cam.Start3D2D(self:LocalToWorld( Vector(45, -4.9, 19) ), self:LocalToWorldAngles( Angle( 0, 90, 80 ) ), .1)
    		surface.SetDrawColor(0,75,255,255)
		    surface.DrawRect(-width/2, -height/2, width, height)
		    surface.SetDrawColor(0,0,0,255)
		    surface.DrawRect(-width/2 + 2.5, -height/2 + 2.5, width - 5, height - 5)
		    if ( !self.StartScanning and self.IdleCounter < 1200 ) then
		    	self.IdleCounter = self.IdleCounter + 1
		    	draw.SimpleText("Begin Scan:", "zk_med_scanner_02", 0, -40, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		    	local button_id = self:OnButton( self.Owner )
            	DrawButton("►", button_id == 1, 0, 10)
            elseif ( !self.StartScanning and self.IdleCounter >= 1200 ) then
            	self.IsActive = false
            	net.Start("zk_med_scanner_is_deactived")
            	net.WriteEntity(self)
            	net.SendToServer()
            end
            
		    if ( self.DCounter < self.ScanTime and self.StartScanning ) then
				draw.SimpleText("Scanning..", "zk_med_scanner_01", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				self.DCounter = self.DCounter + 1 
			elseif ( self.DCounter >= self.ScanTime and self.StartScanning and self.DCounter < self.ScanTime*3.5 ) then
				draw.SimpleText("Patient: "..tostring(self.Patient:Nick()), "zk_med_scanner_02", 0, -50, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("Blood Type: "..tostring(self.PatientsBloodType), "zk_med_scanner_02", 0, -15, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText("Results: "..tostring(self.PatientsResult), "zk_med_scanner_04", 0, 20, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				self.DCounter = self.DCounter + 1 
			elseif ( self.DCounter >= self.ScanTime*3.5 ) then
				self.IsActive = false
				self:EmitSound("HL1/fvox/deactivated.wav")
				net.Start("zk_med_scanner_is_deactived")
				net.WriteEntity(self)
            	net.SendToServer()
			end
		cam.End3D2D()
    end
end


net.Receive( "zk_med_scanner_is_active", function()
	local self = net.ReadEntity()
	if ( !IsValid(self) ) then return end
	self.Patient = net.ReadEntity()
	if ( !IsValid(self.Patient) ) then return end
	self.Owner = net.ReadEntity()
	if ( !IsValid(self.Owner) ) then return end
	self.PatientsBloodType = self.Patient:GetNWString( "ZK_BloodType" )
	self.PatientsResult = table.Random( ZKMedScanner.Config.PossibleScanResults )

	self.IsActive = net.ReadBool()
	if ( self.IsActive ) then
		self.DCounter = 0
		self.IdleCounter = 0
		self.ScanTime = math.random( 500, 750 )
		self.StartScanning = false
	end
end)

net.Receive( "zk_med_scanner_start_scan", function()
	local self = net.ReadEntity()
	if ( !IsValid(self) ) then return end
	self.StartScanning = net.ReadBool()
end)