#include <amxmodx>
#include <cstrike>

new mode, syncObject;
new bool:showmoney=true

public plugin_init()
{
	register_plugin("Show TeamMates Money", "1.3", "DiGiTaL")
	register_event("HLTV", "NewRoundFreeze", "a", "1=0", "2=0")
	register_logevent("newRound", 2, "1=Round_Start")
	register_event("StatusValue", "EventStatusValue", "be", "1=2", "2!0")
	mode = register_cvar("showMoney", "1")

	syncObject = CreateHudSyncObj()  
}

public newRound(){
	show_menu(0, 0, "^n", 1);
	showmoney = false;
}

public NewRoundFreeze()	set_task(1.0, "showMenu")

public showMenu()
{
	showmoney = true;
	new players[32], count, pid
	get_players(players, count, "a")
	for(new i;i<count;i++){
		pid = players[i]
		showMoneyMenu(pid)
	}
}
public EventStatusValue(id)
{
	if(get_pcvar_num(mode) == 2)
	{
		if(is_user_connected(id) && !is_user_bot(id)) 
		{
			new targetName[32], targetid = read_data(2)
			get_user_name(targetid, targetName, 31)   
			new playerTeam = get_user_team(id), targetTeam = get_user_team(targetid), money = cs_get_user_money(targetid)
                
			if (playerTeam == targetTeam && showmoney ) 
			{
				set_hudmessage(255, 255, 255, -1.0, 0.42, 1, 0.01, 0.9, 0.01, 0.01, -1)
				ShowSyncHudMsg(id, syncObject, "%s : $%d", targetName, money)
			}
		}
	}
	return PLUGIN_CONTINUE
}

public showMoneyMenu(pid)
{
	if(get_pcvar_num(mode) == 1)
	{
		new menu = menu_create("\rTeam Mates \R Money", "handleMenu")
		new players[32], num, x, szTeam[15], teamMates[32], menuItem[128]
		get_user_team(pid, szTeam, charsmax(szTeam))
		get_players(players, num, "ae", szTeam)
		for(new i=0;i<num;i++)
		{
			if(x <= 1) return PLUGIN_CONTINUE;
			x = players[i]
			get_user_name(x, teamMates, charsmax(teamMates))
			formatex(menuItem, charsmax(menuItem), "\y%s\R\r$\w%i", teamMates, cs_get_user_money(x))
			menu_additem(menu, menuItem)
		}
		menu_setprop(menu, MPROP_EXIT, MEXIT_NEVER)
		menu_display(pid, menu)	
	}
	return PLUGIN_CONTINUE
}

public handleMenu(id, menu, item) {
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_CONTINUE
	}
	showMoneyMenu(id)
	return PLUGIN_HANDLED
}
