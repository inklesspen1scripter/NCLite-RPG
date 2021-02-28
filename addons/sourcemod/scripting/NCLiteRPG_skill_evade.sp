#pragma semicolon 1
#include "NCLiteIncs/nc_rpg.inc"
#define VERSION		"1.3"
#define ThisSkillShortName "evade"
int ThisSkillID;
float cfg_fPercent;
int cfg_bEffects;
char Damage_Effect[][] = {"text_minicrit","text_crit","text_miss"};

public Plugin myinfo = {
	name		= "NCLiteRPG Evansion",
	author		= "SenatoR",
	description	= "Skill Evansion for NCLiteRPG",
	version		= VERSION,
	url			= ""
};

public void OnPluginStart() { if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) == -1) NCLiteRPG_OnRegisterSkills(); }

public void OnPluginEnd() { if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) != -1) NCLiteRPG_DisableSkill(ThisSkillID, true); }

public void NCLiteRPG_OnRegisterSkills() { ThisSkillID = NCLiteRPG_RegSkill(ThisSkillShortName, 16, 3,2,true); }

public void OnMapStart() {
	NCLiteRPG_Configs RPG_Configs = NCLiteRPG_Configs(ThisSkillShortName,CONFIG_SKILL);
	cfg_fPercent = RPG_Configs.GetFloat(ThisSkillShortName,"percent",0.05);
	cfg_bEffects = RPG_Configs.GetInt(ThisSkillShortName,"effects",0)?true:false;
	RPG_Configs.SaveConfigFile(ThisSkillShortName,CONFIG_SKILL);
	if(cfg_bEffects)
	{
		AddFileToDownloadsTable("particles/NCLiteRPG_crit.pcf");
		AddFileToDownloadsTable("materials/effects/crit.vmt");
		AddFileToDownloadsTable("materials/effects/crit.vtf");
		AddFileToDownloadsTable("materials/effects/miss.vmt");
		AddFileToDownloadsTable("materials/effects/miss.vtf");
		AddFileToDownloadsTable("materials/effects/minicrit.vmt");
		AddFileToDownloadsTable("materials/effects/minicrit.vtf");
		PrecacheParticle("particles/NCLiteRPG_crit.pcf");
		for(int i = 0; i<=2;i++) PrecacheParticleEffect(Damage_Effect[i]);
	}
}


public void OnClientPutInServer(int client) { SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage); }

public Action OnTakeDamage(int victim,int &attacker,int &inflictor,float &damage,int &damagetype) 
{
	if(!NCLiteRPG_IsValidSkill(ThisSkillID))  return Plugin_Continue;
	if(IsValidPlayer(victim) && IsValidPlayer(attacker) && victim != attacker)
	{
		if(GetClientTeam(victim) == GetClientTeam(attacker)) return Plugin_Continue;
		if(damagetype & DMG_BULLET > 0)
		{	
			int level = NCLiteRPG_GetSkillLevel(victim, ThisSkillID);
			
			if(level>0 && damage>=1.0)
			{
				if(GetRandomFloat(0.0, 1.0) <= cfg_fPercent*level)
				{
					if(NCLiteRPG_SkillActivate(ThisSkillID,victim,attacker)>= Plugin_Handled) return Plugin_Handled;
					if(cfg_bEffects)
					{
						float pos[3];
						GetClientAbsOrigin(victim, pos);
						pos[2] += 65.0;
						AttachThrowAwayParticle(victim,Damage_Effect[2],pos,_,1.0);
					}
					damage*= 0.0;
					NCLiteRPG_SkillActivated(ThisSkillID,victim);
					return Plugin_Changed;
				}
			}
		}
	}
	return Plugin_Continue;
}