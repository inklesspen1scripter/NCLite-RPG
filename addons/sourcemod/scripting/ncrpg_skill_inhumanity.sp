#pragma semicolon 1
#include "NCLiteIncs/nc_rpg.inc"
#define VERSION		"1.3"
#define ThisSkillShortName "inhumanity"
int ThisSkillID;
float cfg_fChance; float cfg_fRange; int cfg_iAmount;

public Plugin myinfo = {
	name		= "NCLiteRPG Skill "...ThisSkillShortName,
	author		= "SenatoR",
	description	= "Skill "...ThisSkillShortName..." for NCLiteRPG",
	version		= VERSION,
	url			= ""
};

public void OnPluginStart() {
	if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) == -1) NCLiteRPG_OnRegisterSkills();
	HookEvent("player_death",	OnPlayerDeath);
}

public void OnPluginEnd() { if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) != -1) NCLiteRPG_DisableSkill(ThisSkillID, true); }

public void NCLiteRPG_OnRegisterSkills() { ThisSkillID = NCLiteRPG_RegSkill(ThisSkillShortName, 30, 10,5); }

public void OnMapStart() {
	NCLiteRPG_Configs RPG_Configs = NCLiteRPG_Configs(ThisSkillShortName,CONFIG_SKILL);
	cfg_fChance = RPG_Configs.GetFloat(ThisSkillShortName,"chance",0.3);
	cfg_fRange = RPG_Configs.GetFloat(ThisSkillShortName,"range",130.0);
	cfg_iAmount = RPG_Configs.GetInt(ThisSkillShortName,"amount",1);
	RPG_Configs.SaveConfigFile(ThisSkillShortName,CONFIG_SKILL);
}


public Action OnPlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	if(!NCLiteRPG_IsValidSkill(ThisSkillID))  return Plugin_Continue;
	int victim = GetClientOfUserId(event.GetInt("userid"));
	float deathvec[3];float gainhpvec[3];
	for (int i = 1; i <= MaxClients; i++)
	{
		if(IsValidPlayer(victim) && IsValidPlayer(i,true))
		{
			int level = NCLiteRPG_GetSkillLevel(i, ThisSkillID);
			if(level > 0)
			{
				if(GetRandomFloat(0.0, 1.0) <= cfg_fChance*level)
				{
					int amount = cfg_iAmount*level;
					GetClientAbsOrigin(victim,deathvec); GetClientAbsOrigin(i,gainhpvec);
					if(GetVectorDistance(deathvec,gainhpvec)<=cfg_fRange*level)
					{
						if(NCLiteRPG_SkillActivate(ThisSkillID,i,victim)>= Plugin_Handled)return Plugin_Handled;
						NCLiteRPG_Buffs(i).HealToMaxHP(amount);
						NCLiteRPG_SkillActivated(ThisSkillID,i);
					}
				}
			}
		}
	}
	return Plugin_Continue;
}
