#pragma semicolon 1
#pragma dynamic 128000
#include "NCLiteIncs/nc_rpg.inc"
#include "NCLiteRPG/NCLiteRPG_Variables.inc"
#include "NCLiteRPG/NCLiteRPG_api.inc"
#include "NCLiteRPG/NCLiteRPG_Arrays.inc"
#include "NCLiteRPG/NCLiteRPG_Configs.inc"
#include "NCLiteRPG/NCLiteRPG_Databases.inc"
#include "NCLiteRPG/NCLiteRPG_Xp.inc"
#include "NCLiteRPG/NCLiteRPG_Events.inc"
#include "NCLiteRPG/NCLiteRPG_Logs.inc"

#define VERSION_NUM "1.3.8.6"

public Plugin myinfo =
{
	name = "NCLiteRPG",
	author = "SenatoR & inklesspen",
	description="New concept RPG in source",
	version=VERSION_NUM
};

public APLRes AskPluginLoad2(Handle myself,bool late,char[] error,int err_max)
{
	RegPluginLibrary("NCLiteRPG");
	CreateNative("NCLiteRPG_RegSkill", 			Native_RegSkill);
	CreateNative("NCLiteRPG_IsValidSkill",		Native_IsValidSkill);
	CreateNative("NCLiteRPG_IsValidSkillID",		Native_IsValidSkillID);
	CreateNative("NCLiteRPG_EnableSkill",			Native_EnableSkill);
	CreateNative("NCLiteRPG_DisableSkill", 		Native_DisableSkill);
	CreateNative("NCLiteRPG_IsSkillDisabled",		Native_IsSkillDisabled);
	CreateNative("NCLiteRPG_GetSkillMaxLevel",	Native_GetSkillMaxLevel);
	CreateNative("NCLiteRPG_GetSkillShortName",	Native_GetSkillShortName);
	CreateNative("NCLiteRPG_GetSkillName",		Native_GetSkillName);
	CreateNative("NCLiteRPG_GetSkillDesc",		Native_GetSkillDesc);
	CreateNative("NCLiteRPG_GetClientSkillCost",	Native_GetClientSkillCost);
	CreateNative("NCLiteRPG_GetSkillCost",		Native_GetSkillCost);
	CreateNative("NCLiteRPG_GetSkillCostSales",	Native_GetSkillCostSales);
	CreateNative("NCLiteRPG_GetSkillCount",		Native_GetSkillCount);
	CreateNative("NCLiteRPG_GetEmptySkills",		Native_GetEmptySkills);
	CreateNative("NCLiteRPG_FindSkillByShortname",Native_FindSkillByShortname);
	CreateNative("NCLiteRPG_SetSkillLevel", 		Native_SetSkillLevel);
	CreateNative("NCLiteRPG_GetSkillLevel", 		Native_GetSkillLevel);
	CreateNative("NCLiteRPG_SetXP",	 			Native_SetXP);
	CreateNative("NCLiteRPG_GetXP",	 			Native_GetXP);
	CreateNative("NCLiteRPG_SetReqXP",	 		Native_SetReqXP);
	CreateNative("NCLiteRPG_GetReqXP",	 		Native_GetReqXP);
	CreateNative("NCLiteRPG_SetLevel", 			Native_SetLevel);
	CreateNative("NCLiteRPG_GetLevel", 			Native_GetLevel);
	CreateNative("NCLiteRPG_SetCredits", 			Native_SetCredits);
	CreateNative("NCLiteRPG_GiveCredits", 		Native_GiveCredits);
	CreateNative("NCLiteRPG_GetCredits", 			Native_GetCredits);
	CreateNative("NCLiteRPG_GiveExp", 			Native_GiveExp);
	CreateNative("NCLiteRPG_SetExp", 				Native_SetExp);
	CreateNative("NCLiteRPG_TakeExp", 			Native_TakeExp);
	CreateNative("NCLiteRPG_ResetPlayer", 		Native_ResetPlayer);
	CreateNative("NCLiteRPG_ResetAllPlayers",	Native_ResetAllPlayers);
	CreateNative("NCLiteRPG_LogMessage", 			Native_LogMessage);
	CreateNative("NCLiteRPG_GetDbHandle", 		Native_GetDbHandle);	
	CreateNative("NCLiteRPG_SkillActivate", 		Native_OnSkillActivatedPre);
	CreateNative("NCLiteRPG_SkillActivated", 		Native_OnSkillActivatedPost);
	CreateNative("NCLiteRPG_GetParamStringBySteamID",	Native_GetParamStringBySteamID);
	CreateNative("NCLiteRPG_SetParamIntBySteamID",	Native_SetParamIntBySteamID);
	CreateNative("NCLiteRPG_GetParamIntBySteamID",	Native_GetParamIntBySteamID);
	CreateNative("NCLiteRPG_ChatMessage",	 		Native_ChatMessage);
	CreateNative("NCLiteRPG_GiveExpBySteamID",	Native_GiveExpBySteamID);
	CreateNative("NCLiteRPG_SetExpBySteamID",	 	Native_SetExpBySteamID);
	CreateNative("NCLiteRPG_TakeExpBySteamID",	Native_TakeExpBySteamID);
	hFWD_OnConnectedToDB 			= CreateGlobalForward("NCLiteRPG_OnConnectedToDB",	ET_Ignore, Param_Cell);
	hFWD_OnClientLoaded				= CreateGlobalForward("NCLiteRPG_OnClientLoaded",		ET_Ignore, Param_Cell, Param_Cell);
	hFWD_OnRegisterSkills			= CreateGlobalForward("NCLiteRPG_OnRegisterSkills",	ET_Ignore);
	hFWD_OnPlayerLevelUp				= CreateGlobalForward("NCLiteRPG_OnPlayerLevelUp",		ET_Ignore, Param_Cell,Param_Cell);
	hFWD_OnPlayerGiveExpPost			= CreateGlobalForward("NCLiteRPG_OnPlayerGiveExpPost",		ET_Hook, Param_Cell, Param_Cell,Param_String);	
	hFWD_OnPlayerGiveCreditsPre		= CreateGlobalForward("NCLiteRPG_OnPlayerGiveCreditsPre",		ET_Event, Param_Cell, Param_CellByRef,Param_String);
	hFWD_OnPlayerGiveCreditsPost	= CreateGlobalForward("NCLiteRPG_OnPlayerGiveCreditsPost",		ET_Hook, Param_Cell, Param_Cell,Param_String);
	hFWD_OnPlayerGiveExpPre			= CreateGlobalForward("NCRPG_OnPlayerGiveExpPre",		ET_Event, Param_Cell, Param_CellByRef,Param_String);
	hFWD_OnSkillActivatedPre			= CreateGlobalForward("NCLiteRPG_OnSkillActivatePre",		ET_Event, Param_Cell, Param_Cell,Param_Cell);
	hFWD_OnSkillActivatedPost		= CreateGlobalForward("NCLiteRPG_OnSkillActivatedPost",		ET_Hook, Param_Cell, Param_Cell);
	return APLRes_Success;
}



public void OnPluginStart()
{
	if(!CheckSMVersion(11006385)) NCLiteRPG_LogPrint(LogType_FailState,"[NCLiteRPG] Need to update SOURCEMOD minimal req version 1.10.6385");
	ConnectToDB();
	HookEvents();
	LoadTranslations("NCLiteRPG.phrases");
}

public void OnMapStart() {
	LoadAllConfigs();
	CreateSkillsArray();
	RegistrationSkills();
	CreatePlayersArray();
}

public void OnClientConnected(client) {
	ResetPlayerEx(client);
}

public void OnClientDisconnect(client) {
	SavePlayer(client);
	ResetPlayerEx(client);
}