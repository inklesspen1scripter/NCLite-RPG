#pragma semicolon 1
#include "NCLiteIncs/nc_rpg.inc"
#include "NCLiteIncs/NCLiteRPG_Menu.inc"
#define VERSION_NUM "1.3"

public Plugin:myinfo =
{
	name = "NCLiteRPG Menu",
	author = "SenatoR",
	description="New concept RPG in source",
	version=VERSION_NUM
};


bool cfg_bSellMenu; //Меню с продажей скиллов
bool cfg_bPlayerReset; //Меню обнуления игрока
bool cfg_bCmdsHide; //Скрытие сообщений в чат
int cfg_iPlayerinfo; //Просмотр статистики других игроков
Handle hFWD_OnSkillLevelChange;
char cfg_sCommandsRPG[MAX_RPG_CMDS*MAX_RPG_CMDS_LENGTH];
int cfg_iExpStart;int cfg_iExpInc;int cfg_iPlayerRestore;
public OnPluginStart()
{
	LoadAllConfigs();
	LoadTranslations("NCLiteRPG.phrases");
	RegConsoleCmd("say",RpgNC_SayCommand);
	RegConsoleCmd("say_team",RpgNC_SayCommand);
}

public APLRes:AskPluginLoad2(Handle:myself,bool:late,String:error[],err_max)
{
	RegPluginLibrary("NCLiteRPG");
	CreateNative("NCLiteRPG_OpenMenuMain", 				Native_OpenMenuMain);
	CreateNative("NCLiteRPG_OpenMenuHelp", 			Native_OpenMenuHelp);
	CreateNative("NCLiteRPG_OpenMenuStats", 			Native_OpenMenuStats);
	hFWD_OnSkillLevelChange	= CreateGlobalForward("NCLiteRPG_OnSkillLevelChange",	ET_Hook, Param_Cell, Param_CellByRef, Param_Cell, Param_CellByRef);
	return APLRes_Success;
}


public Native_OpenMenuHelp(Handle:plugin, numParams) {
	NCLiteRPG_ShowMainMenu(GetNativeCell(1));
}

public Native_OpenMenuMain(Handle:plugin, numParams) {
	DisplayMenu(BuildMenuHelp(GetNativeCell(1)), GetNativeCell(1), MENU_TIME_FOREVER);
}

public Native_OpenMenuStats(Handle:plugin, numParams) {
	DisplayMenu(BuildMenuStats(GetNativeCell(1)), GetNativeCell(1), MENU_TIME_FOREVER);
}


LoadAllConfigs() {
	NCLiteRPG_Configs RPG_Configs = NCLiteRPG_Configs(CONFIG_CORE);
	cfg_bSellMenu = RPG_Configs.GetInt("menu","menu_sell",1)?true:false;
	cfg_iPlayerinfo = RPG_Configs.GetInt("player","playerinfo",0);
	cfg_bCmdsHide = RPG_Configs.GetInt("other","cmds_hide",1)?true:false;
	cfg_iPlayerRestore = RPG_Configs.GetInt("player","restore",-1);
	cfg_bPlayerReset = RPG_Configs.GetInt("player","reset", 0)?true:false;
	cfg_iExpStart = RPG_Configs.GetInt("xp","exp_start", 100);
	cfg_iExpInc = RPG_Configs.GetInt("xp","exp_inc", 100);
	RPG_Configs.GetString("other","cmds",cfg_sCommandsRPG, sizeof cfg_sCommandsRPG, "rpg,rpgmenu,war3menu");
	RPG_Configs.SaveConfigFile(CONFIG_CORE);
}

public Action:RpgNC_SayCommand(client, args) {
	if(IsValidPlayer(client))
	{
		decl String:sArgs[256], String:buffer[MAX_RPG_CMDS][MAX_RPG_CMDS_LENGTH];
		GetCmdArgString(sArgs, sizeof(sArgs));
		StripQuotes(sArgs);

		new count = ExplodeString(cfg_sCommandsRPG, ",", buffer, MAX_RPG_CMDS, MAX_RPG_CMDS_LENGTH);
		for(new i = 0; i < count; ++i)
		{
			if(CommandCheck(buffer[i], sArgs))
			{
				NCLiteRPG_ShowMainMenu(client);
				if(cfg_bCmdsHide)
					return Plugin_Handled;
				
				return Plugin_Continue;
			}
		}
		if(CommandCheck(sArgs, "upgrades")|| CommandCheck(sArgs, "умения"))
		{
			DisplayMenu(BuildMenuUpgrades(client), client, MENU_TIME_FOREVER);
			if(cfg_bCmdsHide)
					return Plugin_Handled;
					
			return Plugin_Continue;
		}
		if(CommandCheck(sArgs, "help")|| CommandCheck(sArgs, "помощь"))
		{
			DisplayMenu(BuildMenuHelp(client), client, MENU_TIME_FOREVER);
			if(cfg_bCmdsHide)
					return Plugin_Handled;
					
			return Plugin_Continue;
		}		
		if(CommandCheck(sArgs, "rules")|| CommandCheck(sArgs, "правила"))
		{
			DisplayMenu(BuildMenuHelpRules1(client), client, MENU_TIME_FOREVER);
			if(cfg_bCmdsHide)
					return Plugin_Handled;
					
			return Plugin_Continue;
		}
	}
	
	return Plugin_Continue;
}

public NCLiteRPG_ShowMainMenu(client)
{
	if(IsValidPlayer(client))
	{
		new Handle:menu = CreateMenu(MainMenuHandler);
		decl String:display[128];
		SetMenuTitle(menu, "%T", "MainMenu", client);
		
		FormatEx(display, sizeof(display), "%T", "MainMenuAbility", client);
		AddMenuItem(menu, "ability", display);
		if(cfg_bSellMenu)
		{
			FormatEx(display, sizeof(display), "%T", "MainMenuAbilitySell", client);
			AddMenuItem(menu, "ability_sell", display);
		}
		
		FormatEx(display, sizeof(display), "%T", "MainMenuStatistics", client);
		AddMenuItem(menu, "statistics", display);
			
		
		FormatEx(display, sizeof(display), "%T", "MainMenuHelp", client);
		AddMenuItem(menu, "help", display);
		
	
		
		SetMenuExitButton(menu, true);
		
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
}

public MainMenuHandler(Handle:menu, MenuAction:action, client, param2)
{
	if(action==MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		if(IsValidPlayer(client))
		{
			if(StrEqual(info, "ability"))
			{
				DisplayMenu(BuildMenuUpgrades(client), client, MENU_TIME_FOREVER);
			}				
			else if(StrEqual(info, "ability_sell"))
			{
				DisplayMenu(BuildMenuSell(client), client, MENU_TIME_FOREVER);
			}	
			else if(StrEqual(info, "statistics"))
			{
				DisplayMenu(BuildMenuStats(client), client, MENU_TIME_FOREVER);
			}
			else if(StrEqual(info, "help"))
			{
				DisplayMenu(BuildMenuHelp(client), client, MENU_TIME_FOREVER);
			}	
		}
	}
	else if(action == MenuAction_End)
		CloseHandle(menu);
}

Handle:BuildMenuUpgrades(client) {
	new Handle:menu = CreateMenu(HandlerMenuUpgrades);
	SetMenuTitle(menu, "%T", "Upgrade title", client, NCLiteRPG_GetCredits(client));
	
	decl String:buffer[MAX_SKILL_LENGTH+64], String:buffer2[64], String:disabled[32];
	new level, maxlevel, disab, iSkillCount;
	iSkillCount = NCLiteRPG_GetSkillCount();
	for(new i = 0; i < iSkillCount; ++i)
	{
		if(!NCLiteRPG_IsValidSkill(i))
			continue;
			
		disab = NCLiteRPG_IsValidSkill(i);
		if(disab)
			FormatEx(disabled, sizeof disabled, "%T", "Skill Disabled", client);
		else
			disabled[0] = 0;
			
		level = NCLiteRPG_GetSkillLevel(client, i);
		maxlevel = NCLiteRPG_GetSkillMaxLevel(i);
		if(level >= maxlevel)
			FormatEx(buffer2, sizeof(buffer2), "%T", "Skill maximum lvl", client);
		else
			FormatEx(buffer2, sizeof(buffer2), "%T", "Skill cost", client, level, maxlevel, NCLiteRPG_GetClientSkillCost(client, i));
		
		NCLiteRPG_GetSkillName(i, buffer, sizeof(buffer), client);
		FormatEx(buffer, sizeof(buffer), "%T", "Skill upgrade", client, buffer, buffer2);
		
		IntToString(i, buffer2, sizeof(buffer2));
		AddMenuItem(menu, buffer2, buffer, (level >= maxlevel)?ITEMDRAW_DISABLED:ITEMDRAW_DEFAULT);
	}
	
	if(!GetMenuItemCount(menu))
	{
		FormatEx(buffer, sizeof(buffer), "%T", "Skills are not available", client);
		AddMenuItem(menu, "", buffer, ITEMDRAW_DISABLED);
	}
	
	SetMenuExitBackButton(menu, true);
	
	return menu;
}

public HandlerMenuUpgrades(Handle:menu, MenuAction:action, client, param2) {
	if(action == MenuAction_Select)
	{
		decl String:info[MAX_SKILL_LENGTH],index;
		GetMenuItem(menu, param2, info, sizeof(info));
		index = StringToInt(info);
		if(!NCLiteRPG_IsSkillDisabled(index))
		{
			new cost = NCLiteRPG_GetClientSkillCost(client, index);
			if(NCLiteRPG_GetCredits(client) >= cost)
			{
				new level = NCLiteRPG_GetSkillLevel(client, index);
				if(level < NCLiteRPG_GetSkillMaxLevel(index))
				{
					new new_level = level+1;
					if(API_OnSkillLevelChange(client, index, level, new_level) < Plugin_Handled)
					{
						NCLiteRPG_SetCredits(client, NCLiteRPG_GetCredits(client)-cost);
						NCLiteRPG_SetSkillLevel(client, index, new_level);				
						NCLiteRPG_GetSkillName(index, info, sizeof(info), client);
						NCLiteRPG_ChatMessage(client,"%T" ,"You have raised the level of skill!",client, info, level, NCLiteRPG_GetSkillLevel(client, index));
					}
				}
			}
			else
				NCLiteRPG_ChatMessage(client,"%T" , "Not enough credits!",client);
		}
		else
			NCLiteRPG_ChatMessage(client,"%T" , "Skill is disabled",client);
		DisplayMenuAtItem(BuildMenuUpgrades(client), client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param2 == MenuCancel_ExitBack)
			NCLiteRPG_ShowMainMenu(client);
	}
	else if(action == MenuAction_End)
		CloseHandle(menu);
}


Handle:BuildMenuSell(client) {
	new Handle:menu = CreateMenu(HandlerMenuSell);
	SetMenuTitle(menu, "%T", "Sell title", client, NCLiteRPG_GetCredits(client));
	
	decl String:buffer[MAX_SKILL_LENGTH+64], String:buffer2[8];
	new level,iSkillCount;
	iSkillCount = NCLiteRPG_GetSkillCount();
	for(new i = 0; i < iSkillCount; i++)
	{
		if(!NCLiteRPG_IsValidSkill(i, true))
			continue;
		
		level = NCLiteRPG_GetSkillLevel(client, i);
		if(level <= 0)
			continue;
		
		NCLiteRPG_GetSkillName(i, buffer, sizeof(buffer), client);
		Format(buffer, sizeof(buffer), "%T", "Sell skill", client, level, NCLiteRPG_GetSkillMaxLevel(i), buffer, NCLiteRPG_GetSkillCostSales(i, level-1), NCLiteRPG_GetSkillCost(i, level));
		IntToString(i, buffer2, sizeof(buffer2));
		AddMenuItem(menu, buffer2, buffer);
	}
	
	if(!GetMenuItemCount(menu))
	{
		FormatEx(buffer, sizeof(buffer), "%T", "Skills are not available", client);
		AddMenuItem(menu, "", buffer, ITEMDRAW_DISABLED);
	}
	
	SetMenuExitBackButton(menu, true);
	SetMenuExitButton(menu, true);
	
	return menu;
}

public HandlerMenuSell(Handle:menu, MenuAction:action, client, param2) {
	if(action == MenuAction_Select)
	{
		decl String:info[MAX_SKILL_LENGTH];
		GetMenuItem(menu, param2, info, sizeof(info));
		new index = StringToInt(info);
		new old_level = NCLiteRPG_GetSkillLevel(client, index);
		if(old_level > 0)
		{
			new new_level = old_level-1;
			if(API_OnSkillLevelChange(client, index, old_level, new_level) < Plugin_Handled)
			{
				new save = NCLiteRPG_GetSkillCostSales(index, old_level-1);
				NCLiteRPG_SetCredits(client, NCLiteRPG_GetCredits(client)+save);
				NCLiteRPG_SetSkillLevel(client, index, new_level);
				NCLiteRPG_GetSkillName(index, info, sizeof(info), client);
				NCLiteRPG_ChatMessage(client,"%T" , "You have sold the level of skill!", client, info, old_level, NCLiteRPG_GetSkillLevel(client, index));
			}
		}
		DisplayMenuAtItem(BuildMenuSell(client), client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param2 == MenuCancel_ExitBack)
			NCLiteRPG_ShowMainMenu(client);
	}
	else if(action == MenuAction_End)
		CloseHandle(menu);
}

Handle:BuildMenuStats(client) 
{
	new Handle:menu = CreateMenu(HandlerMenuStats);
	SetMenuTitle(menu, "%T", "Stats title", client, client);
	
	decl String:buffer[64];
	FormatEx(buffer, sizeof(buffer), "%T", "Your level", client, NCLiteRPG_GetLevel(client));
	AddMenuItem(menu, "", buffer, ITEMDRAW_DISABLED);
		
	FormatEx(buffer, sizeof(buffer), "%T", "Your XP", client, NCLiteRPG_GetXP(client),NCLiteRPG_GetReqXP(client));
	AddMenuItem(menu, "", buffer, ITEMDRAW_DISABLED);
	
	FormatEx(buffer, sizeof(buffer), "%T", "Your credits", client, NCLiteRPG_GetCredits(client));
	AddMenuItem(menu, "", buffer, ITEMDRAW_DISABLED);
	
	AddMenuItem(menu, "", "", ITEMDRAW_SPACER);
	
	if(cfg_bPlayerReset)
	{
		FormatEx(buffer, sizeof(buffer), "%T", "Reset stats", client);
		AddMenuItem(menu, "reset", buffer);
	}
	if(cfg_iPlayerRestore>0)
	{
		FormatEx(buffer, sizeof(buffer), "%T", "Restore stats", client);
		AddMenuItem(menu, "restore", buffer);
	}
	if(cfg_iPlayerinfo > 0)
	{
		FormatEx(buffer, sizeof(buffer), "%T", "Info about players", client);
		AddMenuItem(menu, "pinfo", buffer);
	}
	SetMenuExitBackButton(menu, true);
	
	return menu;
}

Handle:BuildMenuRestore(client) {
	new Handle:menu = CreateMenu(HandlerMenuRestore);
	
	if(cfg_iPlayerRestore >= 0)
	{
		decl String:buffer[1024];
		if(cfg_iPlayerRestore > 0)
			Format(buffer, sizeof(buffer), "%T", "You will lose: credits", client, cfg_iPlayerRestore);
		
		SetMenuTitle(menu, "%T", "Restore title", client, buffer);
		
		AddMenuItem(menu, "", " ", ITEMDRAW_SPACER);
	
		Format(buffer, sizeof(buffer), "%T", "Yes", client);
		AddMenuItem(menu, "yes", buffer);
		
		Format(buffer, sizeof(buffer), "%T", "No", client);
		AddMenuItem(menu, "no", buffer);
	}
	
	//SetMenuExitBackButton(menu, true);
	
	return menu;
}

public HandlerMenuRestore(Handle:menu, MenuAction:action, client, param2) {
	if(action == MenuAction_Select)
	{
		decl String:info[8];
		GetMenuItem(menu, param2, info, sizeof(info));
		if(StrEqual(info, "yes"))
		{
			new level  = NCLiteRPG_GetLevel(client);
			NCLiteRPG_ResetPlayer(client);
			NCLiteRPG_SetExp(client, LevelToExp(NCLiteRPG_GetLevel(client)+level-1), true, _, false, false, false);
			NCLiteRPG_ShowMainMenu(client);
		}
		else
			DisplayMenu(BuildMenuStats(client), client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param2 == MenuCancel_ExitBack)
			DisplayMenu(BuildMenuStats(client), client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_End)
		CloseHandle(menu);
}

LevelToExp(level) {
	new xp;
	for(new i = 0; i < level-1; ++i)
		xp += cfg_iExpStart+cfg_iExpInc*i;

	return xp;
}

public HandlerMenuStats(Handle:menu, MenuAction:action, client, param2) {
	if(action == MenuAction_Select)
	{
		decl String:info[8];
		GetMenuItem(menu, param2, info, sizeof(info));
		if(StrEqual(info, "reset"))
			DisplayMenu(BuildMenuReset(client), client, MENU_TIME_FOREVER);
		else if(StrEqual(info, "restore"))
			DisplayMenu(BuildMenuRestore(client), client, MENU_TIME_FOREVER);
		else if(StrEqual(info, "pinfo"))
		{
			NCLiteRPG_OpenMenuPlayersInfo(client);
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param2 == MenuCancel_ExitBack)
			NCLiteRPG_ShowMainMenu(client);
	}
	else if(action == MenuAction_End)
		CloseHandle(menu);
}

Handle:BuildMenuReset(client) {
	new Handle:menu = CreateMenu(HandlerMenuReset);
	SetMenuTitle(menu, "%T", "Reset title", client, client);
	
	decl String:buffer[16];
	AddMenuItem(menu, "", " ", ITEMDRAW_SPACER);
	
	FormatEx(buffer, sizeof(buffer), "%T", "Yes", client);
	AddMenuItem(menu, "yes", buffer);
	
	FormatEx(buffer, sizeof(buffer), "%T", "No", client);
	AddMenuItem(menu, "no", buffer);
	
	//SetMenuExitBackButton(menu, true);
	
	return menu;
}

public HandlerMenuReset(Handle:menu, MenuAction:action, client, param2) {
	if(action == MenuAction_Select)
	{
		decl String:info[8];
		GetMenuItem(menu, param2, info, sizeof(info));
		if(StrEqual(info, "yes"))
		{
			NCLiteRPG_ResetPlayer(client);
			
			NCLiteRPG_ShowMainMenu(client);
		}
		else
			DisplayMenu(BuildMenuStats(client), client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param2 == MenuCancel_ExitBack)
			DisplayMenu(BuildMenuStats(client), client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_End)
		CloseHandle(menu);
}

Handle:BuildMenuHelp(client) 
{
	new Handle:menu = CreateMenu(HandlerMenuHelp);
	SetMenuTitle(menu, "%T", "Help title", client, client);
	
	decl String:buffer[64];
	FormatEx(buffer, sizeof(buffer), "%T", "Description of skills", client);
	AddMenuItem(menu, "skill_desc", buffer);
		
	FormatEx(buffer, sizeof(buffer), "%T", "What is an RPG?", client);
	AddMenuItem(menu, "what_is_rpg", buffer);
	
	FormatEx(buffer, sizeof(buffer), "%T", "Rules", client);
	AddMenuItem(menu, "rpg_rules", buffer);
	FormatEx(buffer, sizeof(buffer), "%T", "Glide", client);
	AddMenuItem(menu, "glide", buffer);
	FormatEx(buffer, sizeof(buffer), "%T", "Admins", client);
	AddMenuItem(menu, "admins", buffer);
	
	SetMenuExitBackButton(menu, true);
	
	return menu;
}

public HandlerMenuHelp(Handle:menu, MenuAction:action, client, param2) 
{
	if(action==MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		if(IsValidPlayer(client))
		{
			if(StrEqual(info, "skill_desc"))
			{
				DisplayMenu(BuildMenuHelpSkillDesc(client), client, MENU_TIME_FOREVER);
			}	
			else if(StrEqual(info, "what_is_rpg"))
			{
				DisplayHelpMenu(client, "Help: What is an RPG?");
			}	
			else if(StrEqual(info, "rpg_rules"))
			{
				DisplayMenu(BuildMenuHelpRules1(client), client, MENU_TIME_FOREVER);
			}				
			else if(StrEqual(info, "glide"))
			{
				DisplayHelpMenu(client, "Help: Glide");
			}		
			else if(StrEqual(info, "admins"))
			{
				DisplayHelpMenu(client, "Help: Admins");
			}	
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param2 == MenuCancel_ExitBack)
			NCLiteRPG_ShowMainMenu(client);
	}
	else if(action == MenuAction_End)
		CloseHandle(menu);
}


Handle:BuildMenuHelpSkillDesc(client) {
	new Handle:menu = CreateMenu(HandlerMenuHelpSkillDesc);
	SetMenuTitle(menu, "%T", "Choose a skill:", client);
	
	decl String:buffer[MAX_SKILL_LENGTH], String:info[8],iSkillCount;
	iSkillCount = NCLiteRPG_GetSkillCount();
	for(new i = 0; i < iSkillCount; ++i)
	{
		if(!NCLiteRPG_IsValidSkill(i))
			continue;
		
		NCLiteRPG_GetSkillName(i, buffer, sizeof(buffer), client);
		IntToString(i, info, sizeof(info));
		AddMenuItem(menu, info, buffer);
	}
	
	if(!GetMenuItemCount(menu))
	{
		FormatEx(buffer, sizeof(buffer), "%T", "Skills are not available", client);
		AddMenuItem(menu, "", buffer, ITEMDRAW_DISABLED);
	}
	
	SetMenuExitBackButton(menu, true);
	
	return menu;
}

public HandlerMenuHelpSkillDesc(Handle:menu, MenuAction:action, client, param2) {
	if(action == MenuAction_Select)
	{
		decl String:info[8];
		GetMenuItem(menu, param2, info, sizeof(info));
		new skillid = StringToInt(info);
		if(NCLiteRPG_IsValidSkillID(skillid))
			DisplayMenu(BuildMenuDescSkill(client, skillid), client, MENU_TIME_FOREVER);
		else
		{
			NCLiteRPG_ChatMessage(client,"%T","Invalid skill",client);
			DisplayMenu(BuildMenuHelpSkillDesc(client), client, MENU_TIME_FOREVER);
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(param2 == MenuCancel_ExitBack)
			DisplayMenu(BuildMenuHelp(client), client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_End)
		CloseHandle(menu);
}

Handle:BuildMenuDescSkill(client, skillid) {
	new Handle:menu = CreateMenu(HandlerMenuDescSkill, MenuAction_Cancel|MenuAction_End);
	
	decl String:buffer[MAX_SKILL_DESC];
	NCLiteRPG_GetSkillDesc(skillid, buffer, sizeof(buffer), client);
	SetMenuTitle(menu, buffer);
	
	AddMenuItem(menu, "", "", ITEMDRAW_SPACER);
	
	FormatEx(buffer, sizeof(buffer), "%T", "Back", client);
	AddMenuItem(menu, "", buffer);
	
	//SetMenuExitBackButton(menu, true);
	//SetMenuExitButton(menu, true);
	
	return menu;
}

public HandlerMenuDescSkill(Handle:menu, MenuAction:action, client, param2) {
	if(action == MenuAction_Select)
	{
		DisplayMenu(BuildMenuHelpSkillDesc(client), client, MENU_TIME_FOREVER);
	}
	else if(action == MenuAction_End)
		CloseHandle(menu);
}

Handle:BuildMenuHelpRules1(client) 
{
	new Handle:menu = CreateMenu(HandlerMenuHelpRules1);
	decl String:buffer[64];
	
	SetMenuTitle(menu, "%T", "Rules page 1", client);
	
	AddMenuItem(menu, "", "", ITEMDRAW_SPACER);
	
	FormatEx(buffer, sizeof(buffer), "%T", "Next", client);
	AddMenuItem(menu, "next", buffer);
	FormatEx(buffer, sizeof(buffer), "%T", "Back", client);
	AddMenuItem(menu, "back", buffer);
	AddMenuItem(menu, "", "", ITEMDRAW_SPACER);
	AddMenuItem(menu, "", "", ITEMDRAW_SPACER);
	return menu;
}

public HandlerMenuHelpRules1(Handle:menu, MenuAction:action, client, param2) 
{
	if(action==MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		if(IsValidPlayer(client))
		{
			if(StrEqual(info, "back"))
			{
				DisplayMenu(BuildMenuHelp(client), client, MENU_TIME_FOREVER);
			}	
			else if(StrEqual(info, "next"))
			{
				DisplayMenu(BuildMenuHelpRules2(client), client, MENU_TIME_FOREVER);
			}
		}
	}
	else if(action == MenuAction_End)
		CloseHandle(menu);
}

Handle:BuildMenuHelpRules2(client) 
{
	new Handle:menu = CreateMenu(HandlerMenuHelpRules2);
	decl String:buffer[64];
	
	SetMenuTitle(menu, "%T", "Rules page 2", client);
	
	AddMenuItem(menu, "", "", ITEMDRAW_SPACER);
	AddMenuItem(menu, "", "", ITEMDRAW_SPACER);
	
	FormatEx(buffer, sizeof(buffer), "%T", "Back", client);
	AddMenuItem(menu, "back", buffer);
	AddMenuItem(menu, "", "", ITEMDRAW_SPACER);
	AddMenuItem(menu, "", "", ITEMDRAW_SPACER);
	return menu;
}

public HandlerMenuHelpRules2(Handle:menu, MenuAction:action, client, param2) 
{
	if(action==MenuAction_Select)
	{
		decl String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		if(IsValidPlayer(client))
		{
			if(StrEqual(info, "back"))
			{
				DisplayMenu(BuildMenuHelpRules1(client), client, MENU_TIME_FOREVER);
			}	
		}
	}
	else if(action == MenuAction_End)
		CloseHandle(menu);
}

Action:API_OnSkillLevelChange(client, &skillid, old_value, &new_value) {
	Call_StartForward(hFWD_OnSkillLevelChange);
	
	Call_PushCell(client);
	Call_PushCellRef(skillid);
	Call_PushCell(old_value);
	Call_PushCellRef(new_value);
	
	new Action:result;
	Call_Finish(result);
	return result;
}
