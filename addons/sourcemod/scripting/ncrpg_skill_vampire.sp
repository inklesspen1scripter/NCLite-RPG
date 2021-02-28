#pragma semicolon 1
#include "NCLiteIncs/nc_rpg.inc"

#define VERSION				"1.2"
#define ThisSkillShortName "vampire"
int ThisSkillID;

float cfg_fAmount;float cfg_fChance;bool cfg_bUnlim; bool cfg_bEffect;
char Vampire_Effect[][] ={"merasmus_zap","merasmus_zap_beam02","merasmus_zap_beam03","merasmus_zap_beam_bits","merasmus_zap_flash"};

public Plugin myinfo = {
	name		= "NCLiteRPG Skill "...ThisSkillShortName,
	author		= "SenatoR",
	description	= "Skill "...ThisSkillShortName..." for NCLiteRPG",
	version		= VERSION,
	url			= ""
};

public void OnPluginStart() { if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) == -1) NCLiteRPG_OnRegisterSkills(); }

public void OnPluginEnd() { if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) != -1) NCLiteRPG_DisableSkill(ThisSkillID, true); }

public void NCLiteRPG_OnRegisterSkills() { ThisSkillID = NCLiteRPG_RegSkill(ThisSkillShortName, 10, 5,3,true); }

public void OnMapStart() {
	NCLiteRPG_Configs RPG_Configs = NCLiteRPG_Configs(ThisSkillShortName,CONFIG_SKILL);
	cfg_fAmount = RPG_Configs.GetFloat(ThisSkillShortName,"percent",0.07);
	cfg_fChance = RPG_Configs.GetFloat(ThisSkillShortName,"chance",0.07);
	cfg_bUnlim = RPG_Configs.GetInt(ThisSkillShortName,"unlimited",0)?true:false;
	cfg_bEffect = RPG_Configs.GetInt(ThisSkillShortName,"effects",0)?true:false;
	RPG_Configs.SaveConfigFile(ThisSkillShortName,CONFIG_SKILL);
	if(cfg_bEffect)
	{
		AddFileToDownloadsTable("particles/NCLiteRPG_vamp.pcf");
		AddFileToDownloadsTable("materials/effects/tp_sparkle2.vtf");
		AddFileToDownloadsTable("materials/effects/tp_sparkle2.vmt");
		AddFileToDownloadsTable("materials/effects/splash_ring1.vtf");
		AddFileToDownloadsTable("materials/effects/splash_ring1.vmt");
		AddFileToDownloadsTable("materials/effects/beam_generic01.vmt");
		AddFileToDownloadsTable("materials/effects/baseballtrail.vtf");
		AddFileToDownloadsTable("materials/effects/brightglow_y.vmt");
		AddFileToDownloadsTable("materials/effects/brightglow_y.vtf");
		PrecacheParticle("particles/NCLiteRPG_vamp.pcf");
		for(int i = 0; i<5;i++) PrecacheParticleEffect(Vampire_Effect[i]);
	}
}

public void OnClientPutInServer(int client) { SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage); }

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) {
	if(!NCLiteRPG_IsValidSkill(ThisSkillID))  return Plugin_Continue;
	if(IsValidPlayer(victim) && IsValidPlayer(attacker) && victim != attacker)
	{
		if(GetClientTeam(victim) == GetClientTeam(attacker)) return Plugin_Continue;
		
		int level = NCLiteRPG_GetSkillLevel(attacker, ThisSkillID);
		if(level > 0)
		{
			if(GetRandomFloat(0.0, 1.0) <= cfg_fChance*level)
			{
				if(NCLiteRPG_SkillActivate(ThisSkillID,attacker,victim)>= Plugin_Handled) return Plugin_Handled;
				NCLiteRPG_Buffs RPG_Player = NCLiteRPG_Buffs(attacker);
				int val = GetClientHealth(attacker);
				if(val >= RPG_Player.MaxHP) return Plugin_Continue;
				val += RoundToNearest(level*damage*cfg_fAmount);
				if(!cfg_bUnlim){ if(val > RPG_Player.MaxHP) val = RPG_Player.MaxHP;} 
				SetEntityHealth(attacker, val);
				if(cfg_bEffect) AttachParticlePlayer(victim,Vampire_Effect[0],attacker,1.0);
				NCLiteRPG_SkillActivated(ThisSkillID, attacker);
			}
		}
	}
	return Plugin_Continue;
}