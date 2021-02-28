#pragma semicolon 1
#include "NCLiteIncs/nc_rpg.inc"
//Constants
#define VERSION		"1.0"
#define ThisSkillShortName "master"
//Variables
int ThisSkillID;
int cfg_iAmount;
ConVar hAirAcceleration; 
//Plugin Info
public Plugin myinfo = {
	name		= "NCLiteRPG Skill "...ThisSkillShortName,
	author		= "SenatoR",
	description	= "Skill "...ThisSkillShortName..." for NCLiteRPG",
	version		= VERSION,
	url			= ""
};

public void OnPluginStart() { 
	if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) == -1) 
	{
		for(int i = 1; i <= MaxClients; ++i)
		if(IsValidPlayer(i))
		{
			OnClientPutInServer(i);
		}
		NCLiteRPG_OnRegisterSkills(); 
	}
	hAirAcceleration = FindConVar("sv_airaccelerate");

	HookEvent("player_spawn", EventSpawn);
}

public void OnPluginEnd() { if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) != -1) NCLiteRPG_DisableSkill(ThisSkillID, true); }

public void NCLiteRPG_OnRegisterSkills() { ThisSkillID = NCLiteRPG_RegSkill(ThisSkillShortName, 20, 10,5,true); }

public void OnMapStart() {
	NCLiteRPG_Configs RPG_Configs = NCLiteRPG_Configs(ThisSkillShortName,CONFIG_SKILL);
	cfg_iAmount = RPG_Configs.GetInt(ThisSkillShortName,"amount",100);
	RPG_Configs.SaveConfigFile(ThisSkillShortName,CONFIG_SKILL);
}

public void OnClientPutInServer(int client) 
{
	if(!NCLiteRPG_IsValidSkill(ThisSkillID)) return;
	if(IsValidPlayer(client)) SDKHook(client, SDKHook_PreThinkPost, Hook_PreThink); 
}


public void Hook_PreThink(int client)
{
	if(!IsValidPlayer(client)) return;
	SetConVarInt(hAirAcceleration, hAirAcceleration.IntValue); 
}

public void EventSpawn(Event event, const char[] name, bool dbc)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(!client)	return;

	if(!NCLiteRPG_IsValidSkill(ThisSkillID)) return;
	int level = NCLiteRPG_GetSkillLevel(client, ThisSkillID);
	if(level > 0)
	{
		if(NCLiteRPG_SkillActivate(ThisSkillID,client,client)>= Plugin_Handled)return;
		int amount = hAirAcceleration.IntValue+(cfg_iAmount*level);
		char sAirAcc[16]; IntToString(amount, sAirAcc, sizeof sAirAcc); 
		SendConVarValue(client, hAirAcceleration, sAirAcc);  
		NCLiteRPG_SkillActivated(ThisSkillID, client);
	}
}