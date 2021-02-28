#if SOURCEMOD_V_MINOR<10
#error "Sourcemod need to update to version 1.10.6385"
#else
	#if SOURCEMOD_V_REV<6381
	#error "Sourcemod need to update to version 1.10.6385"
	#endif
#endif
#if defined _nc_rpg_included
	#endinput
#endif
#define _nc_rpg_included
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include "NCLiteIncs/NCLiteRPG_Constants"
#include "NCLiteIncs/NCLiteRPG_GameCheck"
#include "NCLiteIncs/NCLiteRPG_Effects"
#include "NCLiteIncs/NCLiteRPG_XP_Credits"
#include "NCLiteIncs/NCLiteRPG_Messages"
//#include "NCLiteIncs/NCLiteRPG_Messages_css"
//#include "NCLiteIncs/NCLiteRPG_Menu"
#include "NCLiteIncs/NCLiteRPG_Skills"
#include "NCLiteIncs/NCLiteRPG_Damage"
#include "NCLiteIncs/NCLiteRPG_Configs"
#include "NCLiteIncs/NCLiteRPG_PrecacheDownload"

forward NCLiteRPG_OnConnectedToDB(Handle hndl);

forward NCLiteRPG_OnClientLoaded(int client, int count);

forward void NCLiteRPG_OnRegisterSkills();

forward void NCLiteRPG_OnPlayerSpawn(int client);

forward void NCLiteRPG_OnPlayerSpawnedPost(int client);

native Handle NCLiteRPG_GetDbHandle();

stock bool IsValidPlayer(int client, bool alive = false) {
	if(client > 0 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client))
	{		
		if(alive && !IsPlayerAlive(client))
			return false;
		
		return true;
	}
	
	return false;
}

stock bool IsValidClient(int iClient) { return (iClient > 0 && iClient <= MaxClients && IsClientInGame(iClient) && !IsFakeClient(iClient)); }

stock bool GetClientSteamID(int client, String:auth[],int maxlen) 
{
	if(IsClientAuthorized(client))
		if(GetClientAuthId(client,AuthId_Steam2, auth, maxlen))
		{
			if(StrEqual(auth, "BOT", true))
				Format(auth, maxlen, "BOT_%N", client);
			else if(StrEqual(auth, "STEAM_ID_LAN", true))
				GetClientName(client, auth, maxlen);
			
			return true;
		}

	Format(auth, maxlen, "UNKNOWN");	
	return false;
}


stock float GetTeamRatio(int team) {
	return float(GetTeamClientCount((team == CS_TEAM_T)?CS_TEAM_CT:CS_TEAM_T))/float(GetTeamClientCount(team));
}


public SharedPlugin __pl_nc_rpg = 
{
	name = "NCLiteRPG",
	file = "NCLiteRPG.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_nc_rpg_SetNTVOptional()
{
	MarkNativeAsOptional("NCLiteRPG_RegSkill");
	MarkNativeAsOptional("NCLiteRPG_DisableSkill");
	MarkNativeAsOptional("NCLiteRPG_IsSkillDisabled");
	MarkNativeAsOptional("NCLiteRPG_IsValidSkill");
	MarkNativeAsOptional("NCLiteRPG_IsValidSkillID");
	MarkNativeAsOptional("NCLiteRPG_GetSkillMaxLevel");
	MarkNativeAsOptional("NCLiteRPG_GetSkillName");
	MarkNativeAsOptional("NCLiteRPG_GetSkillDesc");
	MarkNativeAsOptional("NCLiteRPG_GetClientSkillCost");
	MarkNativeAsOptional("NCLiteRPG_GetSkillCost");
	MarkNativeAsOptional("NCLiteRPG_GetSkillCostSales");
	MarkNativeAsOptional("NCLiteRPG_GetSkillCount");
	MarkNativeAsOptional("NCLiteRPG_GetEmptySkills");
	MarkNativeAsOptional("NCLiteRPG_FindSkillByShortname");
	MarkNativeAsOptional("NCLiteRPG_SetSkillLevel");
	MarkNativeAsOptional("NCLiteRPG_GetSkillLevel");
	MarkNativeAsOptional("NCLiteRPG_SetMaxHP");
	MarkNativeAsOptional("NCLiteRPG_GetMaxHP");
	MarkNativeAsOptional("NCLiteRPG_SetMaxArmor");
	MarkNativeAsOptional("NCLiteRPG_GetMaxArmor");
	MarkNativeAsOptional("NCLiteRPG_DealDamage");
	MarkNativeAsOptional("NCLiteRPG_FreezePlayer");
	MarkNativeAsOptional("NCLiteRPG_SetIsPlayerFrozen");
	MarkNativeAsOptional("NCLiteRPG_IsPlayerFrozen");
	MarkNativeAsOptional("NCLiteRPG_SlowPlayer");
	MarkNativeAsOptional("NCLiteRPG_SpeedPlayer");
	MarkNativeAsOptional("NCLiteRPG_SetSlow");
	MarkNativeAsOptional("NCLiteRPG_GetSlow");	
	MarkNativeAsOptional("NCLiteRPG_SetPlayerSpeed");
	MarkNativeAsOptional("NCLiteRPG_GetPlayerSpeed");
	MarkNativeAsOptional("NCLiteRPG_SetColor");
	MarkNativeAsOptional("NCLiteRPG_GetColor");	
	MarkNativeAsOptional("NCLiteRPG_SetSpeed");
	MarkNativeAsOptional("NCLiteRPG_GetSpeed");		
	MarkNativeAsOptional("NCLiteRPG_SetMaxSpeed");
	MarkNativeAsOptional("NCLiteRPG_GetMaxSpeed");	
	MarkNativeAsOptional("NCLiteRPG_SetGravity");
	MarkNativeAsOptional("NCLiteRPG_GetGravity");
	MarkNativeAsOptional("NCLiteRPG_SetReqXP");
	MarkNativeAsOptional("NCLiteRPG_GetReqXP");
	MarkNativeAsOptional("NCLiteRPG_GetXP");
	MarkNativeAsOptional("NCLiteRPG_SetXP");
	MarkNativeAsOptional("NCLiteRPG_GetLevel");
	MarkNativeAsOptional("NCLiteRPG_SetLevel");
	MarkNativeAsOptional("NCLiteRPG_SetCredits");
	MarkNativeAsOptional("NCLiteRPG_GetCredits");
	MarkNativeAsOptional("NCLiteRPG_GiveExp");
	MarkNativeAsOptional("NCLiteRPG_SetExp");
	MarkNativeAsOptional("NCLiteRPG_TakeExp");
	MarkNativeAsOptional("NCLiteRPG_ResetPlayer");
	MarkNativeAsOptional("NCLiteRPG_ResetAllPlayers");
	MarkNativeAsOptional("NCLiteRPG_OpenMenuMain");
	MarkNativeAsOptional("NCLiteRPG_OpenMenuHelp");
	MarkNativeAsOptional("NCLiteRPG_OpenMenuStats");
	MarkNativeAsOptional("NCLiteRPG_OpenMenuPlayersInfo");
	MarkNativeAsOptional("NCLiteRPG_LogMessage");
	MarkNativeAsOptional("NCLiteRPG_GetDbHandle");
	MarkNativeAsOptional("NCLiteRPG_GetGravity");
	MarkNativeAsOptional("NCLiteRPG_SetAlpha");
	MarkNativeAsOptional("NCLiteRPG_GetAlpha");	
	MarkNativeAsOptional("NCLiteRPG_SetMaxAlpha");
	MarkNativeAsOptional("NCLiteRPG_GetMaxAlpha");	
	MarkNativeAsOptional("NCLiteRPG_SkillActivate");
	MarkNativeAsOptional("NCLiteRPG_SkillActivated");	
	MarkNativeAsOptional("NCLiteRPG_GetSkillShortName");	
	MarkNativeAsOptional("NCLiteRPG_GetParamStringBySteamID");
	MarkNativeAsOptional("NCLiteRPG_GetParamIntBySteamID");	
	MarkNativeAsOptional("NCLiteRPG_SetParamIntBySteamID");	
	MarkNativeAsOptional("NCLiteRPG_GiveCredits");	
	MarkNativeAsOptional("NCLiteRPG_ChatMessage");	
	MarkNativeAsOptional("NCLiteRPG_GiveExpBySteamID");	
	MarkNativeAsOptional("NCLiteRPG_SetExpBySteamID");	
	MarkNativeAsOptional("NCLiteRPG_TakeExpBySteamID");	
}
#endif