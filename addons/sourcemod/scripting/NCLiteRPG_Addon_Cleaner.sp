#pragma semicolon 1
#include "NCLiteIncs/nc_rpg.inc"
#define VERSION	"1.2"

public Plugin myinfo = {
	name		= "NCLiteRPG DB Cleaner",
	author		= "SenatoR",
	description	= "New concept RPG in source",
	version		= VERSION
};

int cfg_iDeletePlayers;	// Квар удаления игроков через x дней
bool cfg_bDeleteLog=false;	// Логирование удаленных игроков
char cfg_sLogPath[PLATFORM_MAX_PATH]; // Путь к логам

public void OnMapStart()
{ 
	LoadAllConfigs();
	if(cfg_iDeletePlayers>0) CreateTimer( 2.0, OnMapStartPost);
	
}

void LoadAllConfigs() {
	NCLiteRPG_Configs RPG_Configs = NCLiteRPG_Configs(CONFIG_CORE);
	cfg_iDeletePlayers = RPG_Configs.GetInt("cleaner","days_time",0);
	if(cfg_iDeletePlayers>0) cfg_bDeleteLog = RPG_Configs.GetInt("logs","cleaner",1)?true:false;
	if(cfg_bDeleteLog)
	{
		RPG_Configs.GetString("logs","cleaner_path",cfg_sLogPath, sizeof cfg_sLogPath, "addons/sourcemod/logs/NCLiteRPG");
		Format(cfg_sLogPath, sizeof cfg_sLogPath, "%s/cleaner.log", cfg_sLogPath);
	}
	RPG_Configs.SaveConfigFile(CONFIG_CORE);
}

public Action OnMapStartPost( Handle timer, any data )
{
	char buffer[256];
	int deltime = cfg_iDeletePlayers*86400;
	if(cfg_bDeleteLog)FormatEx(buffer,sizeof buffer,"SELECT steamid,name,lastconnect FROM nc_rpg WHERE (%d-lastconnect)>%d", GetTime(),deltime);
	else FormatEx(buffer,sizeof buffer,"DELETE FROM nc_rpg WHERE (%d-lastconnect)>%d", GetTime(),deltime);
	Database db = view_as<Database>(NCLiteRPG_GetDbHandle());
	if ( db == null ) NCLiteRPG_LogMessage(LogType_FailState,"Couldn't retrieve database handle!" );
	db.Query(GetPlayersDeleteCallback, buffer, _, DBPrio_Low);
}

public void GetPlayersDeleteCallback(Database db, DBResultSet results, const char[] error, int client)
{
	if (results == null) { NCLiteRPG_LogMessage(LogType_Error, "Could not get cleaner info, reason: %s", error); return; }
	if(cfg_bDeleteLog)
	{
		char LogMsg[1024];char buffer[128];
		while (results.FetchRow())
		{
			results.FetchString(0, buffer, sizeof buffer);
			FormatEx(LogMsg,sizeof LogMsg,"Player [%s] ",buffer);
			results.FetchString(1, buffer, sizeof buffer);
			FormatEx(LogMsg,sizeof LogMsg,"%s%s ",LogMsg,buffer);
			results.FetchString(2, buffer, sizeof buffer);
			FormatTime(buffer,sizeof buffer,"%d.%m.%Y");
			FormatEx(LogMsg,sizeof LogMsg,"%s Last Active [%s].Removed from database.",LogMsg,buffer);
			NCLiteRPG_LogToFile(cfg_sLogPath,LogMsg);
		}
		int deltime = cfg_iDeletePlayers*86400;
		FormatEx(buffer,sizeof buffer,"DELETE FROM nc_rpg WHERE (%d-lastconnect)>%d", GetTime(),deltime);
		if(!SQL_FastQuery( NCLiteRPG_GetDbHandle(), buffer, sizeof buffer))
		{
			char err[255];
			SQL_GetError(NCLiteRPG_GetDbHandle(), err, sizeof err );
			NCLiteRPG_LogMessage(LogType_Error, "Could not remove players, reason: %s",err);
		}
	}
}