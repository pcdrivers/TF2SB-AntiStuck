#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Battlefield Duck"
#define PLUGIN_VERSION "1.00"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <morecolors>
#include <build>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "[TF2] SandBox - AntiStuck",
	author = PLUGIN_AUTHOR,
	description = "Antistuck System for TF2SB",
	version = PLUGIN_VERSION,
	url = "http://steamcommunity.com/id/battlefieldduck/"
};

Handle g_hEnabled;
Handle g_hAutoUnstuck;

bool g_bIN_ATTACK[MAXPLAYERS + 1];

public void OnPluginStart()
{
	CreateConVar("sm_tf2sb_antistuck_version", PLUGIN_VERSION, "", FCVAR_SPONLY|FCVAR_NOTIFY);
	g_hEnabled = CreateConVar("sm_tf2sb_antistuck", "1", "Enable the AntiStuck System?", 0, true, 0.0, true, 1.0);
	g_hAutoUnstuck = CreateConVar("sm_tf2sb_unstuckmode", "1", "Mode 0 = Disable auto, Mode 1 = Enable Auto unstuck", 0, true, 0.0, true, 1.0);
}

public void OnMapStart()
{
	for(int i = 1; i < MAXPLAYERS; i++)
	{
		OnClientPutInServer(i);
	}
}

public void OnClientPutInServer(int client)
{
	g_bIN_ATTACK[client] = false;
	CreateTimer(1.0, Timer_AntiStuck, client);
}

public Action Timer_AntiStuck(Handle timer, int client)
{
	/*
	if(!IsValidClient(client))
		return;
	
	if(GetConVarBool(g_hEnabled))
	{
		for(int ent = 0; ent < MAX_HOOK_ENTITIES; ent++)
		{
			if(IsValidEntity(ent) && !IsValidClient(ent))
			{
				int EntityOwner = -1;
				EntityOwner = Build_ReturnEntityOwner(ent);
				
				if(IsValidClient(EntityOwner) && EntityOwner != -1)
				{
					if(IsValidClient(client) && IsPlayerAlive(client) && IsPlayerStuckInEnt(client, ent) && !g_bIN_ATTACK[EntityOwner])
					{
						if(GetConVarInt(g_hAutoUnstuck) == 1)
						{
							float iPosition[3]; 
							GetClientEyePosition(client, iPosition);
							
							iPosition[0] += 1.0;
							
							TeleportEntity(client, iPosition, NULL_VECTOR, NULL_VECTOR);
						}
							
						AcceptEntityInput(ent, "DisableCollision");
			
					}
					else if(!IsPlayerStuckInEnt(client, ent))
					{	
						AcceptEntityInput(ent, "EnableCollision");
					}
				}
			}
		}
	}
	if(IsPlayerAlive(client))
		CreateTimer(0.01, Timer_AntiStuck, client);
		*/
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{	
	if(!IsValidClient(client))
		return Plugin_Continue;
		
	if(buttons & IN_ATTACK)
		g_bIN_ATTACK[client] = true;
	else
		g_bIN_ATTACK[client] = false;
	
	if(GetConVarBool(g_hEnabled))
	{
		for(int ent = 0; ent < MAX_HOOK_ENTITIES; ent++)
		{
			if(IsValidEntity(ent) && !IsValidClient(ent))
			{
				int EntityOwner = -1;
				EntityOwner = Build_ReturnEntityOwner(ent);
				
				if(IsValidClient(EntityOwner) && EntityOwner != -1)
				{
					if(IsValidClient(client) && IsPlayerAlive(client) && IsPlayerStuckInEnt(client, ent))
					{
						if(!g_bIN_ATTACK[EntityOwner])
							if(GetConVarInt(g_hAutoUnstuck) == 1)
							{
								float iPosition[3]; 
								GetClientEyePosition(client, iPosition);
								
								iPosition[0] += 0.01;
								
								TeleportEntity(client, iPosition, NULL_VECTOR, NULL_VECTOR);
							}
							
						AcceptEntityInput(ent, "DisableCollision");
			
					}
					else if(!IsPlayerStuckInEnt(client, ent))
					{	
						AcceptEntityInput(ent, "EnableCollision");
					}
				}
			}
		}
	}
	return Plugin_Continue;
}	

//-------------[	Stock	]---------------------------------------------------
stock bool IsPlayerStuckInEnt(int client, int ent)
{
	float vecMin[3], vecMax[3], vecOrigin[3];
	
	GetClientMins(client, vecMin);
	GetClientMaxs(client, vecMax);
	
	GetClientAbsOrigin(client, vecOrigin);
	
	TR_TraceHullFilter(vecOrigin, vecOrigin, vecMin, vecMax, MASK_ALL, TraceRayHitOnlyEnt, ent);
	return TR_DidHit();
}

public bool TraceRayHitOnlyEnt(int entity, int contentsMask, any data) 
{
	return entity==data;
}

stock bool IsValidClient(int client) 
{ 
    if(client <= 0 ) return false; 
    if(client > MaxClients) return false; 
    if(!IsClientConnected(client)) return false; 
    return IsClientInGame(client); 
}