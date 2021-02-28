#pragma semicolon 1

#include "NCLiteIncs/nc_rpg.inc"

#define VERSION				"1.3"
#define MAX_WEAPON_LENGTH	32
#define ThisSkillShortName "attackspd"
int ThisSkillID;

float cfg_fPercent; bool cfg_bRestrict;

Handle hArrayPermittedWpn;
int m_OffsetNextPrimaryAttack;
int g_iWeaponRateQueue[MAXPLAYERS+1][2];
int g_iWeaponRateQueueLength;

public Plugin myinfo = {
	name		= "NCLiteRPG Skill Attack Speed",
	author		= "SenatoR",
	description	= "Skill Attack Speed for NCLiteRPG",
	version		= VERSION
};


public void OnPluginStart() 
{
	if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) == -1) NCLiteRPG_OnRegisterSkills();
	m_OffsetNextPrimaryAttack = FindSendPropInfo("CBaseCombatWeapon","m_flNextPrimaryAttack");
	if(m_OffsetNextPrimaryAttack==-1) { LogError("[NCLiteRPG] Error finding next primary attack offset."); }
	HookEvent("weapon_fire", Event_WeaponFire, EventHookMode_Pre);
}

public void OnPluginEnd() { if((ThisSkillID = NCLiteRPG_FindSkillByShortname(ThisSkillShortName)) != -1) NCLiteRPG_DisableSkill(ThisSkillID, true); }

public void NCLiteRPG_OnRegisterSkills() { ThisSkillID = NCLiteRPG_RegSkill(ThisSkillShortName, 10, 10,5,true); }

public void OnMapStart() {
	if(hArrayPermittedWpn == INVALID_HANDLE) hArrayPermittedWpn = CreateArray(ByteCountToCells(MAX_WEAPON_LENGTH));
	ClearArray(hArrayPermittedWpn);
	
	NCLiteRPG_Configs RPG_Configs = NCLiteRPG_Configs(ThisSkillShortName,CONFIG_SKILL);
	cfg_fPercent = RPG_Configs.GetFloat(ThisSkillShortName,"percent",0.5);
	cfg_bRestrict = RPG_Configs.GetInt(ThisSkillShortName,"restrict",1)?true:false;
	if(cfg_bRestrict)
	{
		char source[512];char tmp[64][MAX_WEAPON_LENGTH];
		RPG_Configs.GetString(ThisSkillShortName,"weapons",source, sizeof source, "weapon_nova,weapon_mag7,weapon_sawedoff,weapon_xm1014");
		int count = ExplodeString(source, ",", tmp, 64, sizeof tmp); for(int i = 0; i < count; ++i) PushArrayString(hArrayPermittedWpn, tmp[i]);
	}
	RPG_Configs.SaveConfigFile(ThisSkillShortName,CONFIG_SKILL);
}

public Action Event_WeaponFire(Event event, const char[] name, bool dontBroadcast) 
{
	if(!NCLiteRPG_IsValidSkill(ThisSkillID))  return Plugin_Continue;
	int client = GetClientOfUserId(event.GetInt("userid"));
	int level = NCLiteRPG_GetSkillLevel(client, ThisSkillID);
	if (level > 0)
	{
		char buffer[PLATFORM_MAX_PATH*2];
		GetClientWeapon(client, buffer, sizeof buffer);
		bool wpn = IsPermittedWeapon(buffer);
		if(!cfg_bRestrict) wpn =false;
		if(!wpn)
		{
			if(NCLiteRPG_SkillActivate(ThisSkillID,client,client)>= Plugin_Handled)return Plugin_Handled;
			int weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
			if(weapon != -1)
			{
				g_iWeaponRateQueue[g_iWeaponRateQueueLength][0] = weapon;
				g_iWeaponRateQueue[g_iWeaponRateQueueLength++][1] = level;
				NCLiteRPG_SkillActivated(ThisSkillID,client);
			} 
		
		}
	}
	return Plugin_Continue;
}

public void OnGameFrame(){
    if(g_iWeaponRateQueueLength>0)
    {
        int ent;  float time; float gametime = GetGameTime();
        for(int i = 0; i < g_iWeaponRateQueueLength; i++) {
            ent = g_iWeaponRateQueue[i][0];
            if(IsValidEntity(ent)) {  
                
                float multi = 1.0+(g_iWeaponRateQueue[i][1]*cfg_fPercent);
                if(multi!=1.0){
                    time = (GetEntDataFloat(ent,m_OffsetNextPrimaryAttack) - gametime) / multi;
                    SetEntDataFloat(ent,m_OffsetNextPrimaryAttack,time + gametime,true);
                }
            }
        }
        g_iWeaponRateQueueLength = 0; 
    }
}

bool IsPermittedWeapon(char[] weapon) {
	char buffer[MAX_WEAPON_LENGTH];
	for(int i = GetArraySize(hArrayPermittedWpn)-1; i >= 0; --i)
	{
		GetArrayString(hArrayPermittedWpn, i, buffer, sizeof buffer);
		if(StrEqual(weapon, buffer, false)) return true;
	}
	return false;
}