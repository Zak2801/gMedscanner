--[[ Made by:
 ____ ___  _  __ _____  ___  _  __
|_  //   \| |/ /|_   _|/   \| |/ /
 / / | - ||   <   | |  | - ||   < 
/___||_|_||_|\_\  |_|  |_|_||_|\_\

--]]

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


--[[-------------------------------------------------------
Name: ENT:SpawnFunction()
Desc: Called when a player spawns entity from spawnmenu.
---------------------------------------------------------]]
function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180
	
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAng )
	ent:Spawn()
	ent:Activate()

	ent.SpawnAngles = SpawnAng
	ent.Owner = ply

	return ent
end

--[[-------------------------------------------------------
Name: ENT:Use()
Desc: Called when an entity "uses" this entity.
---------------------------------------------------------]]
function ENT:Use(ply)
	if ( !IsValid(self) or !IsValid(ply) or !IsValid(self.PodEnt) ) then return end
	local button_id = self:OnButton( self.Owner )

	local patient = table.Random( player.GetAll() )
	--[[
	local patient = self.PodEnt:GetDriver()
	if ( !IsValid(patient) ) then 
		if DarkRP then
			DarkRP.notify( ply, {ply}, 5, "No Valid Patient." )
		else
			ply:ChatPrint( "[MED-SCANNER]: No Valid Patient.", self.Owner )
		end
		return 
	end
	--]]
	
	if ( patient:IsPlayer() and patient:Alive() and self.UsedCounter == 0 ) then 
		self:EmitSound("ambient/machines/keyboard7_clicks_enter.wav")
		self.IsActive = true
		net.Start( "zk_med_scanner_is_active" )
		net.WriteEntity(self)
		net.WriteEntity(patient)
		net.WriteEntity(self.Owner)
		net.WriteBool(true)
		net.Broadcast()
		self.UsedCounter = self.UsedCounter + 1
	elseif ( self.UsedCounter == 1 and button_id == 1 ) then
		self:EmitSound("HL1/fvox/activated.wav")
		self.StartScanning = true
		net.Start( "zk_med_scanner_start_scan" )
		net.WriteEntity(self)
		net.WriteBool(true)
		net.Broadcast()
		self.UsedCounter = self.UsedCounter + 1
	end
end


function ENT:Think()
	self:NextThink( CurTime() )

	local trace = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() + (-self:GetUp()*1000),
	})

	local distance = self:GetPos():DistToSqr( trace.HitPos )
	local phys = self:GetPhysicsObject()
	if ( !IsValid(phys) ) then return end

	phys:SetVelocityInstantaneous( self:GetVelocity() )
	phys:AddAngleVelocity( -phys:GetAngleVelocity() )
	local curAngles = phys:GetAngles()
	phys:SetAngles( Angle(self.SpawnAngles.x, curAngles.y, self.SpawnAngles.z) )

	if ( !IsValid(phys) ) then return end

	if ( distance > 500 ) then
		if ( distance > 600 ) then
			phys:SetVelocity( self:GetUp() * -40 )
		else
			phys:SetVelocity( self:GetUp() * -.1 )
		end
	elseif ( distance < 450 ) then
		if ( distance < 200 ) then
			phys:AddVelocity( self:GetUp() * 25 )
		else
			phys:AddVelocity( self:GetUp() * .1 )
		end
	end
end

net.Receive( "zk_med_scanner_is_deactived", function()
	local self = net.ReadEntity()
	self.UsedCounter = 0
	self.IsActive = false
end)