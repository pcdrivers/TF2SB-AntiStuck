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
	name = "[TF2] AntiStuck System for TF2SB",
	author = PLUGIN_AUTHOR,
	description = "Antistuck System for TF2SB",
	version = PLUGIN_VERSION,
	url = "http://steamcommunity.com/id/battlefieldduck/"
};

Handle g_hEnabled;
Handle g_hAutoUnstuck;

public void OnPluginStart()
{
	g_hEnabled = CreateConVar("sm_tf2sb_antistuck", "1", "Enable the AntiStuck System?", 0, true, 0.0, true, 1.0);
	g_hAutoUnstuck = CreateConVar("sm_tf2sb_unstuckmode", "2", "Mode 0 = Disable auto, Mode 1 = Smooth unstuck, Mode 2 = Instant unstuck", 0, true, 0.0, true, 2.0);
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{	
	if(GetConVarBool(g_hEnabled))
	{
		for(int ent = 0; ent < MAX_HOOK_ENTITIES; ent++)
		{
			if(IsValidEntity(ent))
			{
				if(IsValidClient(client) && IsPlayerAlive(client) && IsPlayerStuckInEnt(client, ent) && Build_ReturnEntityOwner(ent) != -1 && !(buttons & IN_ATTACK))
				{
					if(GetConVarInt(g_hAutoUnstuck) == 1)
					{
						vel[0] = 200.0;
					}
					else if(GetConVarInt(g_hAutoUnstuck) == 2)
					{
						float iPosition[3];
						GetClientEyePosition(client, iPosition);
						
						iPosition[0] += 10.0;
						
						TeleportEntity(client, iPosition, NULL_VECTOR, NULL_VECTOR);
					}
						
					PropDisableCollision(ent);
		
				}
				else
				{	
					PropEnableCollision(ent);
				}
			}
		}
	}
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

stock void PropDisableCollision(int ent)
{
	AcceptEntityInput(ent, "DisableCollision");
}

stock void PropEnableCollision(int ent)
{
	AcceptEntityInput(ent, "EnableCollision");
}

stock bool IsValidClient(int client) 
{ 
    if(client <= 0 ) return false; 
    if(client > MaxClients) return false; 
    if(!IsClientConnected(client)) return false; 
    return IsClientInGame(client); 
}