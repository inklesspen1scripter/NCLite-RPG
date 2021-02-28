
Handle hFWD_OnConnectedToDB;
Handle hFWD_OnRegisterSkills;
Handle hFWD_OnClientLoaded;
Handle hFWD_OnPlayerSpawned;
Handle hFWD_OnPlayerSpawnedPost;
Handle hFWD_OnPlayerLevelUp;
Handle hFWD_OnPlayerGiveExpPre;
Handle hFWD_OnPlayerGiveExpPost;	
Handle hFWD_OnPlayerGiveCreditsPre;
Handle hFWD_OnPlayerGiveCreditsPost;
Handle hFWD_OnSkillActivatedPre;
Handle hFWD_OnSkillActivatedPost;

void API_OnConnectedToDB(Handle hndl) {
	Call_StartForward(hFWD_OnConnectedToDB);
	
	Call_PushCell(hndl);
	
	Call_Finish();
}

	
void API_OnRegisterSkills() {
	//NCLiteRPG_LogPrint(LogType_Debug, "Called OnRegisterSkills ...");
	ResetSkillCount();
	
	Call_StartForward(hFWD_OnRegisterSkills);
	Call_Finish();
}

void API_OnClientLoaded(int client,int count) {
	Call_StartForward(hFWD_OnClientLoaded);
	
	Call_PushCell(client);
	Call_PushCell(count);
	
	Call_Finish();
}

Action API_OnPlayerGiveExpPre(int client,int &Exp,char[] event_name) {
	Call_StartForward(hFWD_OnPlayerGiveExpPre);
	
	Call_PushCell(client);
	Call_PushCellRef(Exp);
	Call_PushString(event_name);
	Action result;
	Call_Finish(result);
	return result;
}

Action API_OnPlayerGiveCreditsPre(int client,int &Credits,char[] event_name) {
	Call_StartForward(hFWD_OnPlayerGiveCreditsPre);
	
	Call_PushCell(client);
	Call_PushCellRef(Credits);
	Call_PushString(event_name);
	Action result;
	Call_Finish(result);
	return result;
}

void API_OnPlayerGiveCreditsPost(int client,int Credits,char[] event_name) {
	Call_StartForward(hFWD_OnPlayerGiveCreditsPost);
	
	Call_PushCell(client);
	Call_PushCell(Credits);
	Call_PushString(event_name);
	Call_Finish();
}

void API_OnPlayerGiveExpPost(int client,int Exp,char[] event_name) {
	Call_StartForward(hFWD_OnPlayerGiveExpPost);
	
	Call_PushCell(client);
	Call_PushCell(Exp);
	Call_PushString(event_name);
	Call_Finish();
}

void API_OnPlayerSpawn(int client) {

	Call_StartForward(hFWD_OnPlayerSpawned);
	
	Call_PushCell(client);
	
	Call_Finish();
}

void API_OnPlayerLevelUp(int client,int level) {

	Call_StartForward(hFWD_OnPlayerLevelUp);
	
	Call_PushCell(client);
	Call_PushCell(level);
	Call_Finish();
}

void API_OnPlayerSpawnedPost(int client) {
	Call_StartForward(hFWD_OnPlayerSpawnedPost);
	
	Call_PushCell(client);
	
	Call_Finish();
}
public int Native_GetSkillCount(Handle plugin,int numParams) 
{
	return GetSkillCount();
}

public int Native_RegSkill(Handle plugin,int numParams) {
	char buffer[MAX_SHORTNAME_LENGTH];
	GetNativeString(1, buffer, sizeof buffer);
	//NCLiteRPG_LogMessage(LogType_Debug, "Called RegSkill: %s", buffer);
	return RegSkill(buffer, GetNativeCell(2), GetNativeCell(3), GetNativeCell(4), GetNativeCell(5));
}

public int Native_DisableSkill(Handle plugin, int numParams) {
	DisableSkill(GetNativeCell(1), GetNativeCell(2));
}

public int Native_FindSkillByShortname(Handle plugin, int numParams) {
	char shortname[MAX_SHORTNAME_LENGTH];
	GetNativeString(1, shortname, sizeof shortname);
	return FindSkillByShortname(shortname);
}

public int Native_SetSkillLevel(Handle plugin, int numParams) {
	return SetSkillLevel(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3));
}

public int Native_GetSkillLevel(Handle plugin, int numParams) {
	return GetSkillLevel(GetNativeCell(1), GetNativeCell(2));
}

public int Native_SetXP(Handle plugin, int numParams) {
	return SetXP(GetNativeCell(1), GetNativeCell(2));
}

public int Native_GetXP(Handle plugin, int numParams) {
	return GetXP(GetNativeCell(1));
}

public int Native_SetReqXP(Handle plugin, int numParams) {
	return SetReqXP(GetNativeCell(1), GetNativeCell(2));
}

public int Native_GetReqXP(Handle plugin, int numParams) {
	return GetReqXP(GetNativeCell(1));
}

public Native_GetSkillDesc(Handle plugin, int numParams) {
	int size = GetNativeCell(3);
	char[] buffer=new char[size];
	GetSkillDesc(GetNativeCell(1), buffer, GetNativeCell(3), GetNativeCell(4));
	SetNativeString(2, buffer,size);
}
// Не забыть проверить

public Native_GetSkillName(Handle plugin, int numParams) {
	int size = GetNativeCell(3);
	char[] buffer=new char[size];
	GetSkillName(GetNativeCell(1), buffer, size, GetNativeCell(4));
	SetNativeString(2, buffer, size);
}

public int Native_GetSkillShortName(Handle plugin, int numParams) {
	int size = GetNativeCell(3);
	char[] buffer=new char[size];
	bool ret = GetSkillShortname(GetNativeCell(1), buffer, size);
	SetNativeString(2, buffer, size);
	return ret;
}

public int Native_SetLevel(Handle plugin, int numParams) {
	return SetLevel(GetNativeCell(1), GetNativeCell(2));
}

public int Native_GetLevel(Handle plugin, int numParams) {
	return GetLevel(GetNativeCell(1));
}

public int Native_SetCredits(Handle plugin, int numParams) {
	return SetCredits(GetNativeCell(1), GetNativeCell(2));
}

public int Native_GiveCredits(Handle plugin, int numParams) {
	char event_name[64];
	GetNativeString(4,event_name,sizeof event_name);
	return GiveCreditsE(GetNativeCell(1), GetNativeCell(2), GetNativeCell(3),event_name);
}

public int Native_GetCredits(Handle plugin, int numParams) {
	return GetCredits(GetNativeCell(1));
}

public int Native_GiveExp(Handle plugin, int numParams) {
	char event_name[64];
	GetNativeString(4,event_name,sizeof event_name);
	return GiveExp(GetNativeCell(1), GetNativeCell(2),   GetNativeCell(3),   GetNativeCell(4),   GetNativeCell(5),   GetNativeCell(6),GetNativeCell(3),event_name);
}

public int Native_SetExp(Handle plugin, int numParams) {
	return SetExp(GetNativeCell(1), GetNativeCell(2),   GetNativeCell(3),   GetNativeCell(4),   GetNativeCell(5),   GetNativeCell(6),   GetNativeCell(7));
}

public int Native_TakeExp(Handle plugin, int numParams) {
	return TakeExp(GetNativeCell(1), GetNativeCell(2),   GetNativeCell(3),   GetNativeCell(4));
}

public int Native_ResetPlayer(Handle plugin, int numParams) {
	ResetPlayer(GetNativeCell(1));
}

public int Native_ResetAllPlayers(Handle plugin, int numParams) {
	ResetAllPlayers();
}

public int Native_EnableSkill(Handle plugin, int numParams) {
	EnableSkill(GetNativeCell(1));
}

public int Native_IsValidSkill(Handle plugin, int numParams) {
	return IsValidSkill(GetNativeCell(1), GetNativeCell(2));
}

public int Native_IsSkillDisabled(Handle plugin, int numParams) {
	return IsSkillDisabled(GetNativeCell(1));
}

public int Native_GetEmptySkills(Handle plugin, int numParams) {
	return GetEmptySkills(GetNativeCell(1));
}

public int Native_GetSkillMaxLevel(Handle plugin, int numParams) {
	return GetSkillMaxLevel(GetNativeCell(1));
}


public int Native_IsValidSkillID(Handle plugin, int numParams) {
	return IsValidSkillID(GetNativeCell(1));
}

public int Native_GetClientSkillCost(Handle plugin, int numParams) {
	return GetClientSkillCost(GetNativeCell(1),GetNativeCell(2));
}

public int Native_GetSkillCostSales(Handle plugin, int numParams) {
	return GetSkillCostSales(GetNativeCell(1), GetNativeCell(2));
}

public int Native_GetSkillCost(Handle plugin, int numParams) {
	return GetSkillCost(GetNativeCell(1),GetNativeCell(2));
}


public int Native_LogMessage(Handle plugin, int numParams) {
	char sMessage[1024];
	FormatNativeString(0, 2, 3, sizeof(sMessage), _, sMessage);
	NCLiteRPG_LogPrint(GetNativeCell(1), sMessage);
}

public int Native_GetDbHandle(Handle plugin, int numParams) {
	//return view_as<int>CloneHandle(GetSQLHandle(),plugin);
	return view_as<int>(GetSQLHandle());
}

public int Native_OnSkillActivatedPre(Handle plugin, int numParams) {
	Call_StartForward(hFWD_OnSkillActivatedPre);
	
	Call_PushCell(GetNativeCell(1));
	Call_PushCell(GetNativeCell(2));
	Call_PushCell(GetNativeCell(3));
	Action result;
	Call_Finish(result);
	return view_as<int>(result);
}

public int Native_OnSkillActivatedPost(Handle plugin, int numParams) {
	Call_StartForward(hFWD_OnSkillActivatedPost);
	Call_PushCell(GetNativeCell(1));
	Call_PushCell(GetNativeCell(2));
	Call_Finish();
}

public Native_GetParamStringBySteamID(Handle plugin, int numParams) {
	int size = GetNativeCell(3);
	char[] buffer=new char[size]; char steamid[MAX_STEAMID_LENGTH];char param[32];
	GetNativeString(1,steamid,sizeof steamid);
	GetNativeString(2,param,sizeof param);
	bool ret = GetParamStringBySteamID(steamid,param, buffer, size);
	SetNativeString(3, buffer, size);
	return ret;
}


public int Native_SetParamIntBySteamID(Handle plugin, int numParams) {
	char steamid[MAX_STEAMID_LENGTH];char param[32];
	GetNativeString(1,steamid,sizeof steamid);
	GetNativeString(2,param,sizeof param);
	return SetParamIntBySteamID(steamid,param, GetNativeCell(3));
}

public int Native_GetParamIntBySteamID(Handle plugin, int numParams) {
	char steamid[MAX_STEAMID_LENGTH];char param[32];
	GetNativeString(1,steamid,sizeof steamid);
	GetNativeString(2,param,sizeof param);
	return GetParamIntBySteamID(steamid,param);
}

public Native_GiveExpBySteamID(Handle plugin, int numParams) {
	char steamid[MAX_STEAMID_LENGTH];
	GetNativeString(1,steamid,sizeof steamid);
	return GiveExpBySteamID(steamid,GetNativeCell(2),GetNativeCell(3), GetNativeCell(4));
}


public int Native_SetExpBySteamID(Handle plugin, int numParams) {
	char steamid[MAX_STEAMID_LENGTH];
	GetNativeString(1,steamid,sizeof steamid);
	return SetExpBySteamID(steamid, GetNativeCell(2),   GetNativeCell(3),   GetNativeCell(4),   GetNativeCell(5));
}

public int Native_TakeExpBySteamID(Handle plugin, int numParams) {
	char steamid[MAX_STEAMID_LENGTH];
	GetNativeString(1,steamid,sizeof steamid);
	return TakeExpBySteamID(steamid, GetNativeCell(2));
}

public int Native_ChatMessage(Handle plugin, int numParams) {
	char sMessage[256];
	FormatNativeString(0, 2,3, sizeof(sMessage), _, sMessage);
	int client = GetNativeCell(1);
	if (client == 0)
	{
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && !IsFakeClient(i))
			{
				Format(sMessage, sizeof(sMessage), "%T %s", "NCLiteRPG",i, sMessage);
				CPrintToChat(i, sMessage);
			}
		}
	}
	else
	{
		SetGlobalTransTarget(LANG_SERVER);
		Format(sMessage, sizeof(sMessage), "%t %s", "NCLiteRPG", sMessage);
		CPrintToChat(client, sMessage);
	}
}
