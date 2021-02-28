#pragma semicolon 1
#include "NCLiteIncs/nc_rpg.inc"

#define VERSION				"1.3"
#define ThisSkillShortName "regenhp"
int ThisSkillID;
int cfg_iAmount;
float cfg_fInterval;
bool cfg_bLevelChange;
Handle hTimerRegenHP[MAXPLAYERS+1];

public Plugin myinfo = {
	name		= "NCLiteRPG Skill Regen HP",
	author		= "SenatoR",
	description	= "Skill Regen HP for NCLiteRPG",
	version		= VERSION
};

public void OnPluginStart() { if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) == -1) NCLiteRPG_OnRegisterSkills(); }

public void OnPluginEnd() { if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) != -1) NCLiteRPG_DisableSkill(ThisSkillID, true); }

public void NCLiteRPG_OnRegisterSkills() { ThisSkillID = NCLiteRPG_RegSkill(ThisSkillShortName, 16, 10,5,true); }

public void OnMapStart() {
	NCLiteRPG_Configs RPG_Configs = NCLiteRPG_Configs(ThisSkillShortName,CONFIG_SKILL);
	cfg_iAmount = RPG_Configs.GetInt(ThisSkillShortName,"amount",2);
	cfg_fInterval = RPG_Configs.GetFloat(ThisSkillShortName,"interval",1.0);
	cfg_bLevelChange = RPG_Configs.GetInt(ThisSkillShortName,"level_change",1)?true:false;
	RPG_Configs.SaveConfigFile(ThisSkillShortName,CONFIG_SKILL);
}

public Action NCLiteRPG_OnSkillLevelChange(int client, &skillid,int old_value, &new_value) {
	if(skillid != ThisSkillID || !NCLiteRPG_IsValidSkill(ThisSkillID)|| !cfg_bLevelChange) return;

	if(hTimerRegenHP[client] == INVALID_HANDLE)
	{
		if(NCLiteRPG_SkillActivate(ThisSkillID,client,client)>= Plugin_Handled)return;
		hTimerRegenHP[client] = CreateTimer(cfg_fInterval, Timer_RegenHP, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void OnClientConnected(int client) {	hTimerRegenHP[client] = INVALID_HANDLE; }

public void NCLiteRPG_OnPlayerSpawn(int client) {
	if(!NCLiteRPG_IsValidSkill(ThisSkillID)) return;
	if(hTimerRegenHP[client] != INVALID_HANDLE)
	{
		KillTimer(hTimerRegenHP[client]);
		hTimerRegenHP[client] = INVALID_HANDLE;
	}
	
	if(NCLiteRPG_GetSkillLevel(client, ThisSkillID) > 0){
		if(NCLiteRPG_SkillActivate(ThisSkillID,client,client)>= Plugin_Handled)return;
		hTimerRegenHP[client] = CreateTimer(cfg_fInterval, Timer_RegenHP, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Timer_RegenHP(Handle timer, int client) {
	if(IsValidPlayer(client, true))
	{
		int level = NCLiteRPG_GetSkillLevel(client, ThisSkillID);
		if(level > 0)
		{
			NCLiteRPG_Buffs(client).HealToMaxHP(level*cfg_iAmount);
			return Plugin_Continue;
		}
	}
	
	hTimerRegenHP[client] = INVALID_HANDLE;
	NCLiteRPG_SkillActivated(ThisSkillID, client);
	return Plugin_Stop;
}