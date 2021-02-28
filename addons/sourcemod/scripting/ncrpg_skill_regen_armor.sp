#pragma semicolon 1
#include "NCLiteIncs/nc_rpg.inc"

#define VERSION				"1.1"
#define ThisSkillShortName  "regenarm"
int ThisSkillID;
int cfg_iAmount; int cfg_iMaxArmor;
float cfg_fInterval;
bool cfg_bLevelChange;
Handle hTimerRegenArmor[MAXPLAYERS+1];

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
	cfg_iMaxArmor = RPG_Configs.GetInt(ThisSkillShortName,"max_armor",255);
	cfg_iAmount = RPG_Configs.GetInt(ThisSkillShortName,"amount",2);
	cfg_fInterval = RPG_Configs.GetFloat(ThisSkillShortName,"interval",1.0);
	cfg_bLevelChange = RPG_Configs.GetInt(ThisSkillShortName,"level_change",1)?true:false;
	RPG_Configs.SaveConfigFile(ThisSkillShortName,CONFIG_SKILL);
}


public Action NCLiteRPG_OnSkillLevelChange(int client, &skillid,int old_value, &new_value) {
	if(skillid != ThisSkillID || !NCLiteRPG_IsValidSkill(ThisSkillID)|| !cfg_bLevelChange) return;

	if(hTimerRegenArmor[client] == INVALID_HANDLE)
	{
		if(NCLiteRPG_SkillActivate(ThisSkillID,client,client)>= Plugin_Handled)return;
		hTimerRegenArmor[client] = CreateTimer(cfg_fInterval, Timer_RegenArmor, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}


public void OnClientConnected(int client) {	hTimerRegenArmor[client] = INVALID_HANDLE; }

public void NCLiteRPG_OnPlayerSpawn(int client) {
	if(!NCLiteRPG_IsValidSkill(ThisSkillID)) return;
	if(hTimerRegenArmor[client] != INVALID_HANDLE)
	{
		KillTimer(hTimerRegenArmor[client]);
		hTimerRegenArmor[client] = INVALID_HANDLE;
	}
	
	if(NCLiteRPG_GetSkillLevel(client, ThisSkillID) > 0){
		if(NCLiteRPG_SkillActivate(ThisSkillID,client,client)>= Plugin_Handled)return;
		hTimerRegenArmor[client] = CreateTimer(cfg_fInterval, Timer_RegenArmor, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Timer_RegenArmor(Handle timer, int client) {
	if(IsValidPlayer(client, true))
	{
		int level = NCLiteRPG_GetSkillLevel(client, ThisSkillID);
		if(level > 0)
		{
			int armor =  GetEntProp(client, Prop_Data, "m_ArmorValue");
			if(armor >= cfg_iMaxArmor)
				return Plugin_Continue;
			
			armor += level*cfg_iAmount;
			if(armor > cfg_iMaxArmor)
				armor = cfg_iMaxArmor;
			SetEntProp(client, Prop_Data, "m_ArmorValue", armor);
			return Plugin_Continue;
		}
	}
	
	hTimerRegenArmor[client] = INVALID_HANDLE;
	NCLiteRPG_SkillActivated(ThisSkillID, client);
	return Plugin_Stop;
}