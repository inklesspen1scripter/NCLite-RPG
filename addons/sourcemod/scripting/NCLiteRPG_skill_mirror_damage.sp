#pragma semicolon 1
#include "NCLiteIncs/nc_rpg.inc"
#define VERSION		"1.3"
#define ThisSkillShortName "mirror"
int ThisSkillID;
float cfg_fChance;
float cfg_fPercent;

public Plugin myinfo = {
	name		= "NCLiteRPG Skill "...ThisSkillShortName,
	author		= "SenatoR",
	description	= "Skill "...ThisSkillShortName..." for NCLiteRPG",
	version		= VERSION,
	url			= ""
};

public void OnPluginStart() 
{ 
	if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) == -1) 
	{
		for(int i = 1; i <= MaxClients; ++i)
		if(IsValidPlayer(i))
		{
			OnClientPutInServer(i);
		}
		NCLiteRPG_OnRegisterSkills(); 
	}
}

public void OnPluginEnd() { if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) != -1) NCLiteRPG_DisableSkill(ThisSkillID, true); }

public void NCLiteRPG_OnRegisterSkills() { ThisSkillID = NCLiteRPG_RegSkill(ThisSkillShortName, 16, 10,5,true); }

public void OnMapStart() {
	NCLiteRPG_Configs RPG_Configs = NCLiteRPG_Configs(ThisSkillShortName,CONFIG_SKILL);
	cfg_fChance = RPG_Configs.GetFloat(ThisSkillShortName,"chance",2.0);
	cfg_fPercent = RPG_Configs.GetFloat(ThisSkillShortName,"percent",0.02);
	RPG_Configs.SaveConfigFile(ThisSkillShortName,CONFIG_SKILL);
}

public void OnClientPutInServer(int client) { SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage); }

public Action OnTakeDamage(int victim,int &attacker,int &inflictor,float &damage,int &damagetype) 
{
	if(!NCLiteRPG_IsValidSkill(ThisSkillID))  return Plugin_Continue;
	if(IsValidPlayer(victim) && IsValidPlayer(attacker) && GetClientTeam(victim)!= GetClientTeam(attacker))
	{	
		if(damagetype & DMG_BULLET > 0)
		{
			int level = NCLiteRPG_GetSkillLevel(victim, ThisSkillID);
			if(level>0 && GetRandomFloat(0.0,100.0) < level*cfg_fChance)
			{
				if(NCLiteRPG_SkillActivate(ThisSkillID,victim,attacker)>= Plugin_Handled)return Plugin_Handled;
				float amount = (damage*level*cfg_fPercent);
				if(amount>GetClientHealth(attacker)) amount = GetClientHealth(attacker)-amount-1;
				NCLiteRPG_DealDamage(attacker, RoundToNearest(amount), victim);
				NCLiteRPG_SkillActivated(ThisSkillID,victim);
			}
		}
	}
	return Plugin_Continue;
}
