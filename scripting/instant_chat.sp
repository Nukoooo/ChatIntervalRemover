#include <sourcemod>
#include <clientprefs>

int m_fLastPlayerTalkTime_Offset;

Handle g_InstantChatCookie;
bool g_bInstantChat[MAXPLAYERS + 1];

public Plugin myinfo =
{
    name = "Chat interval remover",
    author = "Nuko",
    version = "1.1",
}

public void OnPluginStart()
{
    GameData gamedata = new GameData("instant_chat.games");

    Address lastPlayerTalkTimeAddress = gamedata.GetAddress("CBasePlayer->m_fLastPlayerTalkTime");

    if (lastPlayerTalkTimeAddress == Address_Null)
    {
        SetFailState("Failed to find lastPlayerTalkTimeAddress address");
    }

    delete gamedata;

    m_fLastPlayerTalkTime_Offset = view_as<int>(lastPlayerTalkTimeAddress);

    g_InstantChatCookie = RegClientCookie("InstantChat", "InstantChat", CookieAccess_Protected);
    RegConsoleCmd("sm_instant_chat", Command_ToggleInstantChat, "Toggles instant chat");
}

public void OnClientCookiesCached(int client)
{
    if (IsFakeClient(client))
        return;

    char szBuffer[4];
    GetClientCookie(client, g_InstantChatCookie, szBuffer, sizeof(szBuffer));

    if (strlen(szBuffer) > 0)
    {
        g_bInstantChat[client] = view_as<bool>(StringToInt(szBuffer));
    }
    else
    {
        g_bInstantChat[client] = false;
    }

}

public Action Command_ToggleInstantChat(int client, int args)
{
    if (!client)
        return Plugin_Handled;

    g_bInstantChat[client] = !g_bInstantChat[client];
    SetClientCookie(client, g_InstantChatCookie, g_bInstantChat[client] ? "1" : "0");
    PrintToChat(client, "Instant chat is now %s.", g_bInstantChat[client] ? "enabled" : "disabled");

    return Plugin_Handled;
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
    if (1 <= client <= MaxClients)
    {
        if (!g_bInstantChat[client])
            return Plugin_Continue;

        /// For some reason, if I use the original value and subtract with the interval (which is 0.66) it won't work, so i just set this to 0
        SetEntDataFloat(client, m_fLastPlayerTalkTime_Offset, 0.0);
    }

    return Plugin_Continue;
}