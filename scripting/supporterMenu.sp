#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <adminmenu>
#include <cstrike>

#pragma newdecls required

int g_SlapDamage[MAXPLAYERS+1];
int moveRoundEndAdmin[MAXPLAYERS + 1];
int moveRoundEndTarget[MAXPLAYERS + 1];
int moveDeathAdmin[MAXPLAYERS + 1];
int moveDeathTarget[MAXPLAYERS + 1];
bool isCSGO;

public Plugin myinfo = 
{
	name = "Supporter menu",
	author = "Luckiris",
	description = "Supporter menu with all their options",
	version = "1.0",
	url = "https://dream-community.de"
};

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("plugin.basecommands");
	LoadTranslations("playercommands.phrases");
	
	HookEvent("round_end", OnRoundEnd);
	HookEvent("player_death", OnDeath);
	
	RegAdminCmd("sm_supporter", CommandSupporter, ADMFLAG_SLAY, "Open the supporter menu");
	RegAdminCmd("sm_support", CommandSupporter, ADMFLAG_SLAY, "Open the supporter menu");
	RegAdminCmd("sm_sup", CommandSupporter, ADMFLAG_SLAY, "Open the supporter menu");
}

public void OnClientConnected(int client)
{
	moveRoundEndTarget[client] = 0;
	moveRoundEndAdmin[client] = 0;
	moveDeathTarget[client] = 0;
	moveDeathAdmin[client] = 0;
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "cstrike"))
	{
		isCSGO = true;
	}	
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "cstrike"))
	{
		isCSGO = false;
	}		
}

public Action OnRoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	for (int i = 0; i <= MAXPLAYERS; i++)
	{
		if (IsValidClient(i))
		{
			switch(moveRoundEndTarget[i])
			{
				case 1:
				{
					PerformMove(moveRoundEndAdmin[i], i, moveRoundEndTarget[i]);
					ShowActivity2(moveRoundEndAdmin[i], "[SM] ", "Moved %N to Spectators.", i);	
				}
				case 2:
				{
					PerformMove(moveRoundEndAdmin[i], i, moveRoundEndTarget[i]);
					ShowActivity2(moveRoundEndAdmin[i], "[SM] ", "Moved %N to T.", i);	
				}
				case 3:
				{
					PerformMove(moveRoundEndAdmin[i], i, moveRoundEndTarget[i]);
					ShowActivity2(moveRoundEndAdmin[i], "[SM] ", "Moved %N to CT.", i);	
				}					
			}
			moveRoundEndTarget[i] = 0;
			moveRoundEndAdmin[i] = 0;
		}
	}	
	return Plugin_Continue;
}

public Action OnDeath(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IsValidClient(client))
	{
		switch(moveDeathTarget[client])
		{
			case 1:
			{
				PerformMove(moveDeathAdmin[client], client, moveDeathTarget[client]);
				ShowActivity2(moveDeathAdmin[client], "[SM] ", "Moved %N to Spectators.", client);	
			}
			case 2:
			{
				PerformMove(moveDeathAdmin[client], client, moveDeathTarget[client]);
				ShowActivity2(moveDeathAdmin[client], "[SM] ", "Moved %N to T.", client);			
			}
			case 3:
			{
				PerformMove(moveDeathAdmin[client], client, moveDeathTarget[client]);
				ShowActivity2(moveDeathAdmin[client], "[SM] ", "Moved %N to CT.", client);			
			}					
		}
		moveDeathAdmin[client] = 0;
		moveDeathTarget[client] = 0;	
	}
	return Plugin_Continue;
}

public Action CommandSupporter(int client, int args)
{
	DisplaySupporterMenu(client);
	return Plugin_Handled;
}

/*
	Functions for showing menus
*/
void DisplaySupporterMenu(int client)
{
	Menu menu = new Menu(MenuSupporter);
	
	menu.SetTitle("Supporter Menu");

	menu.AddItem("MenuSlay", "Slay player");
	menu.AddItem("MenuRespawn", "Respawn player");
	menu.AddItem("MenuSlap", "Slap player");
	menu.AddItem("MenuMove", "Move player");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

void DisplaySlayMenu(int client)
{
	Menu menu = new Menu(MenuHandler_Slay);
	
	menu.SetTitle("Slay player");
	
	menu.ExitBackButton = true;	
	
	AddTargetsToMenu(menu, client, true, true);
	
	menu.Display(client, MENU_TIME_FOREVER);
}

void DisplayRespawnMenu(int client)
{
	Menu menu = new Menu(MenuHandler_Respawn);

	menu.SetTitle("Respawn player");
	
	menu.ExitBackButton = true;	
	
	AddTargetsToMenu2(menu, client, COMMAND_FILTER_DEAD);
	
	menu.Display(client, MENU_TIME_FOREVER);
}

void DisplaySlapDamageMenu(int client)
{
	Menu menu = new Menu(MenuHandler_SlapDamage);
	
	char title[100];
	Format(title, sizeof(title), "%T:", "Slap damage", client);
	menu.SetTitle(title);
	menu.ExitBackButton = true;
	
	menu.AddItem("0", "0");
	menu.AddItem("1", "1");
	menu.AddItem("5", "5");
	menu.AddItem("10", "10");
	menu.AddItem("20", "20");
	menu.AddItem("50", "50");
	menu.AddItem("99", "99");
	
	menu.Display(client, MENU_TIME_FOREVER);
}

void DisplaySlapTargetMenu(int client)
{
	Menu menu = new Menu(MenuHandler_Slap);
	
	char title[100];
	Format(title, sizeof(title), "%T: %d damage", "Slap player", client, g_SlapDamage[client]);
	menu.SetTitle(title);
	menu.ExitBackButton = true;
	
	AddTargetsToMenu(menu, client, true, true);
	
	menu.Display(client, MENU_TIME_FOREVER);
}

void DisplayMoveMenu(int client)
{
	Menu menu = new Menu(MenuHandler_Move);
	
	menu.SetTitle("Move player");
	
	menu.ExitBackButton = true;	

	menu.AddItem("MoveAllT", "Move all to T");
	menu.AddItem("MoveAllCT", "Move all to CT");
	menu.AddItem("MoveAllS", "Move all to Spectators");
	menu.AddItem("MoveOneT", "Move one to T");
	menu.AddItem("MoveOneCT", "Move one to CT");
	menu.AddItem("MoveOneS", "Move one to Spectators");
	menu.AddItem("MoveROneT", "Move one to T (Round end)");
	menu.AddItem("MoveROneCT", "Move one to CT (Round end)");
	menu.AddItem("MoveROneS", "Move one to Spec (Round end)");
	menu.AddItem("MoveDOneT", "Move one to T (Player death)");
	menu.AddItem("MoveDOneCT", "Move one to CT (Player death)");
	menu.AddItem("MoveDOneS", "Move one to Spec (Player death)");			
	
	menu.Display(client, MENU_TIME_FOREVER);
}

void DisplayMoveTMenu(int client)
{
	int userid = 0;
	char name[MAX_NAME_LENGTH];
	char suserid[10];
	char item[128];
	
	Menu menu = new Menu(MenuHandler_MoveT);
	
	menu.SetTitle("Move one T");
	
	menu.ExitBackButton = true;	
	
	for (int i = 1; i <= MAXPLAYERS; i++)
	{
		if (IsValidClient(i))	
		{
			userid = GetClientUserId(i);
			IntToString(userid, suserid, sizeof(suserid));
			GetClientName(i, name, sizeof(name));
			Format(item, sizeof(item), "%s (%s)", name, suserid);
		
			if ((GetClientTeam(i) != 2 && GetClientTeam(i) > 0))
			{
				menu.AddItem(suserid, item);
			} 
		}
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
}

void DisplayMoveCTMenu(int client)
{
	int userid = 0;
	char name[MAX_NAME_LENGTH];
	char suserid[10];
	char item[128];
	
	Menu menu = new Menu(MenuHandler_MoveCT);
	
	menu.SetTitle("Move one CT");
	
	menu.ExitBackButton = true;	
	
	for (int i = 1; i <= MAXPLAYERS; i++)
	{
		if (IsValidClient(i))
		{
			userid = GetClientUserId(i);
			IntToString(userid, suserid, sizeof(suserid));
			GetClientName(i, name, sizeof(name));
			Format(item, sizeof(item), "%s (%s)", name, suserid);
	
			if ((GetClientTeam(i) != 3 && GetClientTeam(i) > 0))
			{
				menu.AddItem(suserid, item);
			} 
		}
	}

	menu.Display(client, MENU_TIME_FOREVER);
}

void DisplayMoveSMenu(int client)
{
	int userid = 0;
	char name[MAX_NAME_LENGTH];
	char suserid[10];
	char item[128];
	
	Menu menu = new Menu(MenuHandler_MoveS);
	
	menu.SetTitle("Move one Spec");
	
	menu.ExitBackButton = true;
	
	for (int i = 1; i <= MAXPLAYERS; i++)
	{
		if (IsValidClient(i))
		{
			userid = GetClientUserId(i);
			IntToString(userid, suserid, sizeof(suserid));
			GetClientName(i, name, sizeof(name));
			Format(item, sizeof(item), "%s (%s)", name, suserid);
		
			if ((GetClientTeam(i) != 1 && GetClientTeam(i) > 0))
			{
				menu.AddItem(suserid, item);
			} 
		}
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
}

void DisplayRMoveTMenu(int client)
{
	int userid = 0;
	char name[MAX_NAME_LENGTH];
	char suserid[10];
	char item[128];
	
	Menu menu = new Menu(MenuHandler_RMoveT);
	
	menu.SetTitle("Move one T (Round end)");
	
	menu.ExitBackButton = true;
	
	for (int i = 1; i <= MAXPLAYERS; i++)
	{
		if (IsValidClient(i))
		{
			userid = GetClientUserId(i);
			IntToString(userid, suserid, sizeof(suserid));
			GetClientName(i, name, sizeof(name));
			Format(item, sizeof(item), "%s (%s)", name, suserid);
		
			if (GetClientTeam(i) != 2 && GetClientTeam(i) > 0 && moveRoundEndTarget[i] == 0)
			{
				menu.AddItem(suserid, item);
			} 
		}
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
}

void DisplayRMoveCTMenu(int client)
{
	int userid = 0;
	char name[MAX_NAME_LENGTH];
	char suserid[10];
	char item[128];
	
	Menu menu = new Menu(MenuHandler_RMoveCT);
	
	menu.SetTitle("Move one CT (Round end)");
	
	menu.ExitBackButton = true;
	
	for (int i = 1; i <= MAXPLAYERS; i++)
	{
		if (IsValidClient(i))
		{
			userid = GetClientUserId(i);
			IntToString(userid, suserid, sizeof(suserid));
			GetClientName(i, name, sizeof(name));
			Format(item, sizeof(item), "%s (%s)", name, suserid);
		
			if (GetClientTeam(i) != 3 && GetClientTeam(i) > 0 && moveRoundEndTarget[i] == 0)
			{
				menu.AddItem(suserid, item);
			} 
		}
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
}

void DisplayRMoveSMenu(int client)
{
	int userid = 0;
	char name[MAX_NAME_LENGTH];
	char suserid[10];
	char item[128];
	
	Menu menu = new Menu(MenuHandler_RMoveS);
	
	menu.SetTitle("Move one Spec (Round end)");
	
	menu.ExitBackButton = true;
	
	for (int i = 1; i <= MAXPLAYERS; i++)
	{
		if (IsValidClient(i))
		{
			userid = GetClientUserId(i);
			IntToString(userid, suserid, sizeof(suserid));
			GetClientName(i, name, sizeof(name));
			Format(item, sizeof(item), "%s (%s)", name, suserid);
		
			if (GetClientTeam(i) != 1 && GetClientTeam(i) > 0 && moveRoundEndTarget[i] == 0)
			{
				menu.AddItem(suserid, item);
			} 
		}
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
}

void DisplayDMoveTMenu(int client)
{
	int userid = 0;
	char name[MAX_NAME_LENGTH];
	char suserid[10];
	char item[128];
	
	Menu menu = new Menu(MenuHandler_DMoveT);
	
	menu.SetTitle("Move one T (Player death)");
	
	menu.ExitBackButton = true;
	
	for (int i = 1; i <= MAXPLAYERS; i++)
	{
		if (IsValidClient(i))
		{
			userid = GetClientUserId(i);
			IntToString(userid, suserid, sizeof(suserid));
			GetClientName(i, name, sizeof(name));
			Format(item, sizeof(item), "%s (%s)", name, suserid);
		
			if (GetClientTeam(i) != 2 && GetClientTeam(i) > 0 && moveDeathTarget[i] == 0)
			{
				menu.AddItem(suserid, item);
			} 
		}
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
}

void DisplayDMoveCTMenu(int client)
{
	int userid = 0;
	char name[MAX_NAME_LENGTH];
	char suserid[10];
	char item[128];
	
	Menu menu = new Menu(MenuHandler_DMoveCT);
	
	menu.SetTitle("Move one CT (Player death)");
	
	menu.ExitBackButton = true;
	
	for (int i = 1; i <= MAXPLAYERS; i++)
	{
		if (IsValidClient(i))
		{
			userid = GetClientUserId(i);
			IntToString(userid, suserid, sizeof(suserid));
			GetClientName(i, name, sizeof(name));
			Format(item, sizeof(item), "%s (%s)", name, suserid);
		
			if (GetClientTeam(i) != 3 && GetClientTeam(i) > 0 && moveDeathTarget[i] == 0)
			{
				menu.AddItem(suserid, item);
			} 
		}
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
}

void DisplayDMoveSMenu(int client)
{
	int userid = 0;
	char name[MAX_NAME_LENGTH];
	char suserid[10];
	char item[128];
	
	Menu menu = new Menu(MenuHandler_DMoveS);
	
	menu.SetTitle("Move one Spec (Player death)");
	
	menu.ExitBackButton = true;
	
	for (int i = 1; i <= MAXPLAYERS; i++)
	{
		if (IsValidClient(i))
		{
			userid = GetClientUserId(i);
			IntToString(userid, suserid, sizeof(suserid));
			GetClientName(i, name, sizeof(name));
			Format(item, sizeof(item), "%s (%s)", name, suserid);
		
			if (GetClientTeam(i) != 1 && GetClientTeam(i) > 0 && moveDeathTarget[i] == 0)
			{
				menu.AddItem(suserid, item);
			} 
		}
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
}

/*
	Functions for handling menus
*/
public int MenuSupporter(Menu menu, MenuAction action, int param1, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			menu.GetItem(param2, info, sizeof(info));
			if (StrEqual(info, "MenuSlay"))
			{
				DisplaySlayMenu(param1);
			}
			if (StrEqual(info, "MenuRespawn"))
			{
				DisplayRespawnMenu(param1);
			}
			if (StrEqual(info, "MenuSlap"))
			{
				DisplaySlapDamageMenu(param1);
			}
			if (StrEqual(info, "MenuMove"))
			{
				DisplayMoveMenu(param1);
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public int MenuHandler_Slay(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		DisplaySupporterMenu(param1);
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		
		menu.GetItem(param2, info, sizeof(info));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available.");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target.");
		}
		else if (!IsPlayerAlive(target))
		{
			ReplyToCommand(param1, "[SM] %t", "Player has since died.");
		}
		else
		{
			char name[MAX_NAME_LENGTH];
			GetClientName(target, name, sizeof(name));
			PerformSlay(param1, target);
			ShowActivity2(param1, "[SM] ", "%t", "Slayed target", "_s", name);
		}
		
		DisplaySlayMenu(param1);
	}
}

public int MenuHandler_Respawn(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		DisplaySupporterMenu(param1);
	}	
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		
		menu.GetItem(param2, info, sizeof(info));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available.");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target.");
		}
		else
		{
			char name[MAX_NAME_LENGTH];
			GetClientName(target, name, sizeof(name));
			PerformRespawn(param1, target);
			ShowActivity2(param1, "[SM] ", "Respawned %s.", name);
		}
		
		DisplayRespawnMenu(param1);
	}
}

public int MenuHandler_SlapDamage(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		DisplaySupporterMenu(param1);
	}	
	else if (action == MenuAction_Select)
	{
		char info[32];
		
		menu.GetItem(param2, info, sizeof(info));
		g_SlapDamage[param1] = StringToInt(info);
		
		DisplaySlapTargetMenu(param1);
	}
}

public int MenuHandler_Slap(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		DisplaySlapDamageMenu(param1);
	}	
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		
		menu.GetItem(param2, info, sizeof(info));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available.");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target.");
		}
		else if (!IsPlayerAlive(target))
		{
			ReplyToCommand(param1, "[SM] %t", "Player has since died.");
		}	
		else
		{
			char name[MAX_NAME_LENGTH];
			GetClientName(target, name, sizeof(name));
			PerformSlap(param1, target, g_SlapDamage[param1]);
			ShowActivity2(param1, "[SM] ", "%t", "Slapped target", "_s", name);
		}
		
		DisplaySlapTargetMenu(param1);
	}
}

public int MenuHandler_Move(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		DisplaySupporterMenu(param1);
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param2, info, sizeof(info));
	
		if (StrEqual(info, "MoveOneT"))
		{
			DisplayMoveTMenu(param1);
		}
		if (StrEqual(info, "MoveOneCT"))
		{
			DisplayMoveCTMenu(param1);
		}
		if (StrEqual(info, "MoveOneS"))
		{
			DisplayMoveSMenu(param1);
		}
		if (StrEqual(info, "MoveAllT"))
		{
			for (int i = 1; i < MAXPLAYERS; i++)
			{
				if (IsValidClient(i))
				{
					if ((GetClientTeam(i) != 2 && GetClientTeam(i) > 0))
					{
						PerformMove(param1, i, 2);
					}
				}
			}	
			ShowActivity2(param1, "[SM] ", "Moved all players to T.");			
		}
		if (StrEqual(info, "MoveAllCT"))
		{
			for (int i = 1; i < MAXPLAYERS; i++)
			{
				if (IsValidClient(i))
				{
					if ((GetClientTeam(i) != 3 && GetClientTeam(i) > 0))
					{
						PerformMove(param1, i, 3);
					}
				}
			}	
			ShowActivity2(param1, "[SM] ", "Moved all players to CT.");			
		}
		if (StrEqual(info, "MoveAllS"))
		{
			for (int i = 1; i < MAXPLAYERS; i++)
			{
				if (IsValidClient(i))
				{
					if ((GetClientTeam(i) != 1 && GetClientTeam(i) > 0))
					{
						PerformMove(param1, i, 1);
					}
				}
			}
			ShowActivity2(param1, "[SM] ", "Moved all players to Spectators.");			
		}
		if (StrEqual(info, "MoveROneT"))
		{
			DisplayRMoveTMenu(param1);
		}
		if (StrEqual(info, "MoveROneCT"))
		{
			DisplayRMoveCTMenu(param1);
		}
		if (StrEqual(info, "MoveROneS"))
		{
			DisplayRMoveSMenu(param1);
		}
		if (StrEqual(info, "MoveDOneT"))
		{
			DisplayDMoveTMenu(param1);
		}
		if (StrEqual(info, "MoveDOneCT"))
		{
			DisplayDMoveCTMenu(param1);
		}
		if (StrEqual(info, "MoveDOneS"))
		{
			DisplayDMoveSMenu(param1);
		}			
	}
}

public int MenuHandler_MoveT(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		DisplayMoveMenu(param1);
	}	
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		
		menu.GetItem(param2, info, sizeof(info));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available.");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target.");
		}
		else
		{
			char name[MAX_NAME_LENGTH];
			GetClientName(target, name, sizeof(name));
			PerformMove(param1, target, 2);
			ShowActivity2(param1, "[SM] ", "Moved %s to T.", name);
		}
		
		DisplayMoveTMenu(param1);
	}
}

public int MenuHandler_MoveCT(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		DisplayMoveMenu(param1);
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		
		menu.GetItem(param2, info, sizeof(info));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available.");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target.");
		}
		else
		{
			char name[MAX_NAME_LENGTH];
			GetClientName(target, name, sizeof(name));
			PerformMove(param1, target, 3);
			ShowActivity2(param1, "[SM] ", "Moved %s to CT.", name);
		}
		
		DisplayMoveCTMenu(param1);
	}
}

public int MenuHandler_MoveS(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		DisplayMoveMenu(param1);
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		
		menu.GetItem(param2, info, sizeof(info));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available.");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target.");
		}
		else
		{
			char name[MAX_NAME_LENGTH];
			GetClientName(target, name, sizeof(name));
			PerformMove(param1, target, 1);
			ShowActivity2(param1, "[SM] ", "Moved %s to Spectators.", name);
		}
		
		DisplayMoveSMenu(param1);
	}
}

public int MenuHandler_RMoveT(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		DisplayMoveMenu(param1);
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		
		menu.GetItem(param2, info, sizeof(info));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available.");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target.");
		}
		else
		{
			char name[MAX_NAME_LENGTH];
			GetClientName(target, name, sizeof(name));
			moveRoundEndTarget[target] = 2;
			moveRoundEndAdmin[target] = param1;
			PrintToChat(param1, "[SM] %N will be moved to T on round end.", target);
		}
		
		DisplayRMoveTMenu(param1);
	}
}

public int MenuHandler_RMoveCT(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		DisplayMoveMenu(param1);
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		
		menu.GetItem(param2, info, sizeof(info));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available.");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target.");
		}
		else
		{
			char name[MAX_NAME_LENGTH];
			GetClientName(target, name, sizeof(name));
			moveRoundEndTarget[target] = 3;
			moveRoundEndAdmin[target] = param1;
			PrintToChat(param1, "[SM] %N will be moved to CT on round end.", target);
		}
		
		DisplayRMoveCTMenu(param1);
	}
}

public int MenuHandler_RMoveS(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		DisplayMoveMenu(param1);
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		
		menu.GetItem(param2, info, sizeof(info));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available.");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target.");
		}
		else
		{
			char name[MAX_NAME_LENGTH];
			GetClientName(target, name, sizeof(name));
			moveRoundEndTarget[target] = 1;
			moveRoundEndAdmin[target] = param1;
			PrintToChat(param1, "[SM] %N will be moved to Spectators on round end.", target);			
		}
		
		DisplayRMoveSMenu(param1);
	}
}

public int MenuHandler_DMoveT(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		DisplayMoveMenu(param1);
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		
		menu.GetItem(param2, info, sizeof(info));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available.");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target.");
		}
		else
		{
			char name[MAX_NAME_LENGTH];
			GetClientName(target, name, sizeof(name));
			moveDeathTarget[target] = 2;
			moveDeathAdmin[target] = param1;
			PrintToChat(param1, "[SM] %N will be moved to T on player death.", target);			
		}
		
		DisplayDMoveTMenu(param1);
	}
}

public int MenuHandler_DMoveCT(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		DisplayMoveMenu(param1);
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		
		menu.GetItem(param2, info, sizeof(info));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available.");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target.");
		}
		else
		{
			char name[MAX_NAME_LENGTH];
			GetClientName(target, name, sizeof(name));
			moveDeathTarget[target] = 3;
			moveDeathAdmin[target] = param1;
			PrintToChat(param1, "[SM] %N will be moved to CT on player death.", target);
		}
		
		DisplayDMoveCTMenu(param1);
	}
}

public int MenuHandler_DMoveS(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		DisplayMoveMenu(param1);
	}
	else if (action == MenuAction_Select)
	{
		char info[32];
		int userid, target;
		
		menu.GetItem(param2, info, sizeof(info));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available.");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target.");
		}
		else
		{
			char name[MAX_NAME_LENGTH];
			GetClientName(target, name, sizeof(name));
			moveDeathTarget[target] = 1;
			moveDeathAdmin[target] = param1;
			PrintToChat(param1, "[SM] %N will be moved to Spectators on player death.", target);			
		}
		
		DisplayDMoveSMenu(param1);
	}
}

/*
	Functions for handling stuff
*/
void PerformSlay(int client, int target)
{
	LogAction(client, target, "\"%L\" slayed \"%L\"", client, target);
	ForcePlayerSuicide(target);
}

void PerformRespawn(int client, int target)
{
	LogAction(client, target, "\"%L\" respawned \"%L\"", client, target);
	CS_RespawnPlayer(target);
}

void PerformSlap(int client, int target, int damage)
{
	LogAction(client, target, "\"%L\" slapped \"%L\" (damage \"%d\")", client, target, damage);
	SlapPlayer(target, damage, true);
}

void PerformMove(int client, int target, int team)
{
	switch(team)
	{
		case 1:
		{
			LogAction(client, target, "\"%L\" moved \"%L\" to Spectator", client, target);
			ChangeClientTeam(target, team);				
		}
		case 2:
		{
			LogAction(client, target, "\"%L\" moved \"%L\" to T", client, target);
			if (isCSGO && IsPlayerAlive(target))
			{
				CS_SwitchTeam(target, team);
				CS_UpdateClientModel(target);
			}
			else
			{
				ChangeClientTeam(target, team);				
			}
		}
		case 3:
		{
			LogAction(client, target, "\"%L\" moved \"%L\" to CT", client, target);
			if (isCSGO && IsPlayerAlive(target))
			{
				CS_SwitchTeam(target, team);
				CS_UpdateClientModel(target);
			}
			else
			{
				ChangeClientTeam(target, team);				
			}
		}
	}
}

/*
	Functions utils
*/
stock bool IsValidClient(int client)
{
	bool result = false;
	if (client > 0 && client < MAXPLAYERS && IsClientConnected(client) && IsClientInGame(client))
	{
		result = true;
	}
	return result;
}