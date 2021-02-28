#pragma semicolon 1
#include "NCLiteIncs/nc_rpg.inc"
#define ThisSkillShortName "gravity"
#define VERSION		"1.2"

int ThisSkillID;
float cfg_fPercent;
bool cfg_bLevelChange;

public Plugin myinfo = {
	name		= "NCLiteRPG Skill "...ThisSkillShortName,
	author		= "SenatoR",
	description	= "Skill "...ThisSkillShortName..." for NCLiteRPG",
	version		= VERSION,
	url			= ""
};

public void OnPluginStart() { if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) == -1) NCLiteRPG_OnRegisterSkills(); }

public void OnPluginEnd() { if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) != -1) NCLiteRPG_DisableSkill(ThisSkillID, true); }

public void NCLiteRPG_OnRegisterSkills() { ThisSkillID = NCLiteRPG_RegSkill(ThisSkillShortName, 20, 10,5,true); }

public void OnMapStart() {
	NCLiteRPG_Configs RPG_Configs = NCLiteRPG_Configs(ThisSkillShortName,CONFIG_SKILL);
	cfg_fPercent = RPG_Configs.GetFloat(ThisSkillShortName,"percent",0.05);
	cfg_bLevelChange = RPG_Configs.GetInt(ThisSkillShortName,"level_change",1)?true:false;
	RPG_Configs.SaveConfigFile(ThisSkillShortName,CONFIG_SKILL);
}

public Action NCLiteRPG_OnSkillLevelChange(int client,int &skillid,int old_value,int &new_value) {
	if(skillid != ThisSkillID || !NCLiteRPG_IsValidSkill(ThisSkillID)|| !cfg_bLevelChange)
		return;
	
	if(IsValidPlayer(client, true))
	{
		if(NCLiteRPG_SkillActivate(ThisSkillID,client,client)>= Plugin_Handled)return;
		NCLiteRPG_Buffs RPG_Player = NCLiteRPG_Buffs(client);
		RPG_Player.Gravity = 1.0-cfg_fPercent*new_value;
		NCLiteRPG_SkillActivated(ThisSkillID,client);
	}
}

public void NCLiteRPG_OnPlayerSpawnedPost(int client) {
	if(!NCLiteRPG_IsValidSkill(ThisSkillID)) return;
	int level = NCLiteRPG_GetSkillLevel(client, ThisSkillID);
	if(level > 0)
	{
		if(NCLiteRPG_SkillActivate(ThisSkillID,client,client)>= Plugin_Handled)return;
		NCLiteRPG_Buffs RPG_Player = NCLiteRPG_Buffs(client);
		RPG_Player.Gravity = 1.0-cfg_fPercent*level;
		NCLiteRPG_SkillActivated(ThisSkillID,client);
	}
}