--[[ Made by:
 ____ ___  _  __ _____  ___  _  __
|_  //   \| |/ /|_   _|/   \| |/ /
 / / | - ||   <   | |  | - ||   < 
/___||_|_||_|\_\  |_|  |_|_||_|\_\

--]]

--------------------------------------------------
ZKMedScanner = ZKMedScanner or {}
ZKMedScanner.Config = ZKMedScanner.Config or {}
--------------------------------------------------


-------------------------------------------- Start of Config: --------------------------------------------


ZKMedScanner.Config.ShouldUseBloodTypes = true
ZKMedScanner.Config.BloodTypes = { "A-", "B-", "AB-", "O-", "A+", "B+", "AB+", "O+" }

ZKMedScanner.Config.PossibleScanResults = { "High Blood Pressure", "Low Iron" }


-------------------------------------------- End of Config (DO NOT EDIT BELOW!) --------------------------------------------


if SERVER then
	util.AddNetworkString( "zk_med_scanner_is_active" )
	util.AddNetworkString( "zk_med_scanner_start_scan" )
	util.AddNetworkString( "zk_med_scanner_is_deactived" )
end


hook.Add("PlayerSpawn", "ZK MedScanner Handle InitSpawn", function(ply)
	timer.Simple( 1, function() end)
	if ( !ZKMedScanner.Config.ShouldUseBloodTypes ) then return end
	if ( ZKMedScanner.Config.BloodTypes == nil ) then return end


	if ( !sql.TableExists( "zk_medscanner_data" ) ) then
		sql.Query("CREATE TABLE zk_medscanner_data(SteamID TEXT, BloodType TEXT)")
	end

	local logs = sql.Query("SELECT * FROM zk_medscanner_data ")
	if ( logs ~= nil or istable(logs) ) then
		for k, v in pairs(logs) do
			if ( ply:SteamID() == v["SteamID"] ) then
				ply:SetNWString( "ZK_BloodType", v["BloodType"] )
				return
			end
		end
	end

	local bType = table.Random(ZKMedScanner.Config.BloodTypes)
	sql.Query( "INSERT INTO zk_medscanner_data(SteamID, BloodType) VALUES('"..ply:SteamID().."', '"..bType.."')" )
	ply:SetNWString( "ZK_BloodType", bType )
end)