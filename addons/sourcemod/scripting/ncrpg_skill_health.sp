#pragma semicolon 1
#include "NCLiteIncs/nc_rpg.inc"
#define ThisSkillShortName "health"
#define VERSION		"1.3"

int ThisSkillID;

int cfg_iAmount; bool cfg_bLevelChange; bool cfg_bLevelChangeHealth;

public Plugin myinfo = {
	name		= "NCLiteRPG Skill "...ThisSkillShortName,
	author		= "SenatoR",
	description	= "Skill "...ThisSkillShortName..." for NCLiteRPG",
	version		= VERSION,
	url			= ""
};

public void OnPluginStart() { if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) == -1) NCLiteRPG_OnRegisterSkills(); }

public void OnPluginEnd() { if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) != -1) NCLiteRPG_DisableSkill(ThisSkillID, true); }

public void NCLiteRPG_OnRegisterSkills() { ThisSkillID = NCLiteRPG_RegSkill(ThisSkillShortName, 16, 10,5,true); }

public void OnMapStart() {
	NCLiteRPG_Configs RPG_Configs = NCLiteRPG_Configs(ThisSkillShortName,CONFIG_SKILL);
	cfg_iAmount = RPG_Configs.GetInt(ThisSkillShortName,"amount",25);
	cfg_bLevelChange = RPG_Configs.GetInt(ThisSkillShortName,"level_change",1)?true:false;
	cfg_bLevelChangeHealth = RPG_Configs.GetInt(ThisSkillShortName,"level_change_health",0)?true:false;
	RPG_Configs.SaveConfigFile(ThisSkillShortName,CONFIG_SKILL);
}



public Action NCLiteRPG_OnSkillLevelChange(int client, &skillid,int old_value, &new_value) {
	if(skillid != ThisSkillID || !NCLiteRPG_IsValidSkill(ThisSkillID)|| !cfg_bLevelChange)
		return;
	
	if(IsValidPlayer(client, true) && new_value> old_value)
	{
		if(NCLiteRPG_SkillActivate(ThisSkillID,client,client)>= Plugin_Handled)return;
		int level = (new_value-old_value)*cfg_iAmount;
		NCLiteRPG_Buffs RPG_Player = NCLiteRPG_Buffs(client);
		RPG_Player.MaxHP = RPG_Player.MaxHP+level;
		if(cfg_bLevelChangeHealth){
			RPG_Player.HealToMaxHP(level);
			if(GetClientHealth(client) <= 0)
				SetEntityHealth(client, 1);
		}
		NCLiteRPG_SkillActivated(ThisSkillID,client);
	}
}


public void NCLiteRPG_OnPlayerSpawn(int client) {
	if(!NCLiteRPG_IsValidSkill(ThisSkillID)) return;
	int level = NCLiteRPG_GetSkillLevel(client, ThisSkillID);
	if(level > 0)
	{
		if(NCLiteRPG_SkillActivate(ThisSkillID,client,client)>= Plugin_Handled)return;
		level = cfg_iAmount*level;
		NCLiteRPG_Buffs RPG_Player = NCLiteRPG_Buffs(client);
		RPG_Player.MaxHP = RPG_Player.MaxHP+level;
		RPG_Player.HealToMaxHP(level);
		NCLiteRPG_SkillActivated(ThisSkillID,client);
	}
}