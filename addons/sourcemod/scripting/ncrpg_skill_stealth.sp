#pragma semicolon 1
#include "NCLiteIncs/nc_rpg.inc"

#define VERSION				"1.3"
#define ThisSkillShortName "stealth"

int ThisSkillID;int cfg_iAmount; bool cfg_bLevelChange;

public Plugin myinfo = {
	name		= "NCLiteRPG Skill "...ThisSkillShortName,
	author		= "SenatoR",
	description	= "Skill "...ThisSkillShortName..." for NCLiteRPG",
	version		= VERSION,
	url			= ""
};

public void OnPluginStart() { if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) == -1) NCLiteRPG_OnRegisterSkills(); }

public void OnPluginEnd() { if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) != -1) NCLiteRPG_DisableSkill(ThisSkillID, true); }

public void NCLiteRPG_OnRegisterSkills() { ThisSkillID = NCLiteRPG_RegSkill(ThisSkillShortName, 5, 15, 10,true); }

public void OnMapStart() {	
	NCLiteRPG_Configs RPG_Configs = NCLiteRPG_Configs(ThisSkillShortName,CONFIG_SKILL);
	cfg_iAmount = RPG_Configs.GetInt(ThisSkillShortName,"amount",34);
	cfg_bLevelChange = RPG_Configs.GetInt(ThisSkillShortName,"level_change",1)?true:false;
	RPG_Configs.SaveConfigFile(ThisSkillShortName,CONFIG_SKILL);
}

public Action NCLiteRPG_OnSkillLevelChange(int client,int &skillid,int old_value,int &new_value) {
	if(skillid != ThisSkillID || !NCLiteRPG_IsValidSkill(ThisSkillID) || !cfg_bLevelChange) return;
		
	if(IsValidPlayer(client, true))
	{
		if(NCLiteRPG_SkillActivate(ThisSkillID,client,client)>= Plugin_Handled) return;
		NCLiteRPG_Buffs RPG_Player = NCLiteRPG_Buffs(client);
		int Value = 255-cfg_iAmount*new_value;
		RPG_Player.MaxAlpha = Value;
		RPG_Player.Alpha = Value;
		NCLiteRPG_SkillActivated(ThisSkillID, client);
	}
}

public void NCLiteRPG_OnPlayerSpawnedPost(int client) {
	if(!NCLiteRPG_IsValidSkill(ThisSkillID)) return;
	int level = NCLiteRPG_GetSkillLevel(client, ThisSkillID);
	if(level > 0)
	{
		if(NCLiteRPG_SkillActivate(ThisSkillID,client,client)>= Plugin_Handled) return;
		NCLiteRPG_Buffs RPG_Player = NCLiteRPG_Buffs(client);
		int Value = 255-cfg_iAmount*level;
		RPG_Player.MaxAlpha = Value;
		RPG_Player.Alpha = Value;
		NCLiteRPG_SkillActivated(ThisSkillID, client);
	}
}