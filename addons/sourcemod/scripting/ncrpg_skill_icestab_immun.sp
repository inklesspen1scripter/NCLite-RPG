#pragma semicolon 1
#include "NCLiteIncs/nc_rpg.inc"
#define VERSION		"1.0"
#define ThisSkillShortName "icestab_immun"
#define IceStabSkillShortName "icestab"
int ThisSkillID;
int IceStabSkillID;
float cfg_fChance;

public Plugin myinfo = {
	name		= "NCLiteRPG Skill "...ThisSkillShortName,
	author		= "SenatoR",
	description	= "Skill "...ThisSkillShortName..." for NCLiteRPG",
	version		= VERSION,
	url			= ""
};

public void OnPluginStart() { if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) == -1) NCLiteRPG_OnRegisterSkills(); }
public void NCLiteRPG_OnRegisterSkills() { ThisSkillID = NCLiteRPG_RegSkill(ThisSkillShortName, 30, 10,5,true); }
public void OnAllPluginsLoaded() { IceStabSkillID = NCLiteRPG_FindSkillByShortname(IceStabSkillShortName);}
public void OnPluginEnd() { if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) != -1) NCLiteRPG_DisableSkill(ThisSkillID, true); }


public void OnMapStart() {
	NCLiteRPG_Configs RPG_Configs = NCLiteRPG_Configs(ThisSkillShortName,CONFIG_SKILL);
	cfg_fChance = RPG_Configs.GetFloat(ThisSkillShortName,"chance",0.3);
	RPG_Configs.SaveConfigFile(ThisSkillShortName,CONFIG_SKILL);
}

public Action NCLiteRPG_OnSkillActivatePre(int skillid,int caller,int target)
{
	//IceStabSkillID = IceStabSkillID;
	if(skillid!=IceStabSkillID) return Plugin_Continue;
	if(!NCLiteRPG_IsValidSkill(ThisSkillID) || !NCLiteRPG_IsValidSkill(IceStabSkillID)) return Plugin_Continue;
	int level = NCLiteRPG_GetSkillLevel(target, ThisSkillID);
	if(level==0) return Plugin_Continue;
	if(GetRandomFloat(0.0,100.0) <= level*cfg_fChance) {
		if(NCLiteRPG_SkillActivate(ThisSkillID,target,caller)>= Plugin_Handled) return Plugin_Continue;
		NCLiteRPG_SkillActivated(ThisSkillID,target);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}