--[[ Made by:
 ____ ___  _  __ _____  ___  _  __
|_  //   \| |/ /|_   _|/   \| |/ /
 / / | - ||   <   | |  | - ||   < 
/___||_|_||_|\_\  |_|  |_|_||_|\_\

--]]

AddCSLuaFile()

ENT.Base 		= "base_gmodentity"
ENT.Type 		= "anim"
ENT.PrintName 	= "Med Scanner"
ENT.Category 	= "Zaktak's"
ENT.Author 		= "Zaktak"
ENT.Spawnable 	= true

local zk_color_transwhite = Color( 255, 255, 255, 0 )

--[[-------------------------------------------------------
Name: ENT:Initialize()
Desc: Called when the entity is created.
---------------------------------------------------------]]
function ENT:Initialize()
	if SERVER then
	    self:SetModel( "models/props/starwars/medical/medical_bed.mdl" )
	    self:PhysicsInit(SOLID_VPHYSICS)
	    self:SetCollisionGroup(COLLISION_GROUP_NONE)
	    self:SetSolid(SOLID_VPHYSICS)
	    self:SetPos( self:GetPos() + Vector( 0, 0, 20 ) )
	    self:SetTrigger( true )
	    self:SetUseType( SIMPLE_USE )
	    local phys = self:GetPhysicsObject()

	    if ( IsValid(phys) ) then
	        phys:Wake()
	        phys:EnableGravity(false)
	    end

	    self.PodEnt = ents.Create( "prop_vehicle_prisoner_pod" )
		self.PodEnt:SetModel("models/vehicles/prisoner_pod_inner.mdl")
		self.PodEnt:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		self.PodEnt:SetVehicleClass("Pod")
		self.PodEnt:SetPos( self:LocalToWorld(Vector( 35, 0, 23 )) )
		self.PodEnt:SetAngles( self:LocalToWorldAngles(Angle( -90, 0, 0 )) )
		self.PodEnt:Spawn()
		self.PodEnt:Activate()
		self.PodEnt:SetParent( self )
		self.PodEnt:SetMoveType( MOVETYPE_NONE  )
		self.PodEnt:SetRenderMode( RENDERMODE_TRANSALPHA )
		self.PodEnt:SetColor( zk_color_transwhite )
		self.PodEnt:SetOwner( self.Owner )
	end
	self.StartScanning = false
	self.UsedCounter = 0
	self.IsActive = false
	self.ID = math.random( 1, 10^6 ) + math.random( 1, 10^6 )
end


function ENT:OnButton(ply)
    local trace = ply:GetEyeTrace()

    local lp = self:WorldToLocal(trace.HitPos)

    if lp.x > 31.1 and lp.x < 51.1 and lp.y < -0.97 and lp.y > -8.7 and lp.z > 15 and lp.z < 16.8 then
        return 1
    else
        return false
    end
end
