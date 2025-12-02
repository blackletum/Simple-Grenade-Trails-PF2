#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

Handle g_h_plugin_enabled = INVALID_HANDLE;
Handle g_h_trail_time = INVALID_HANDLE;
Handle g_h_trail_width_start = INVALID_HANDLE;
Handle g_h_trail_width_end = INVALID_HANDLE;

Handle g_h_caltrop_color = INVALID_HANDLE;
Handle g_h_concussion_color = INVALID_HANDLE;
Handle g_h_emp_color = INVALID_HANDLE;
Handle g_h_gas_color = INVALID_HANDLE;
Handle g_h_heal_color = INVALID_HANDLE;
Handle g_h_mirv_color = INVALID_HANDLE;
Handle g_h_mirvbomb_color = INVALID_HANDLE;
Handle g_h_nail_color = INVALID_HANDLE;
Handle g_h_napalm_color = INVALID_HANDLE;
Handle g_h_normal_color = INVALID_HANDLE;
Handle g_h_default_color = INVALID_HANDLE;

int g_laser_sprite;
int g_nade_color[4] = {255, 255, 255, 255};

char g_projectiles[10][64] = {
	"tf_weapon_grenade_caltrop_projectile",
	"tf_weapon_grenade_concussion_projectile",
	"tf_weapon_grenade_emp_projectile",
	"tf_weapon_grenade_gas_projectile",
	"tf_weapon_grenade_heal_projectile",
	"tf_weapon_grenade_mirv_projectile",
	"tf_weapon_grenade_mirv_bomb",
	"tf_weapon_grenade_nail_projectile",
	"tf_weapon_grenade_napalm_projectile",
	"tf_weapon_grenade_normal_projectile"
};

#define RED     {255, 000, 000, 255}
#define BLUE    {000, 000, 255, 255}
#define GREEN   {000, 255, 000, 255}
#define PURPLE  {145, 000, 255, 255}
#define WHITE   {255, 255, 255, 255}
#define ORANGE  {255, 175, 000, 255}
#define YELLOW  {255, 255, 000, 255}
#define TEAL    {000, 255, 255, 255}
#define GRAY    {180, 180, 180, 255}

public Plugin myinfo = {
	name = "Simple Grenade Trails - Pre-Fortress 2",
	author = "Gdk (original), SaintSoftware PF2 port",
	description = "Trails for Pre-Fortress 2 grenades",
	version = "0.3",
	url = "https://github.com/RavageCS/Simple-Grenade-Trails"
};

public void OnPluginStart() {
	g_h_plugin_enabled     = CreateConVar("sm_sgt_enabled", "1", "Enable plugin");
	g_h_trail_time          = CreateConVar("sm_sgt_trail_time", "0.8", "Trail lifetime (seconds)");
	g_h_trail_width_start   = CreateConVar("sm_sgt_trail_width_start", "4.0", "Trail start width");
	g_h_trail_width_end     = CreateConVar("sm_sgt_trail_width_end",   "25.0", "Trail end width");

	g_h_caltrop_color    = CreateConVar("sm_sgt_caltrop_color",    "Yellow",    "Caltrop trail");
	g_h_concussion_color = CreateConVar("sm_sgt_concussion_color", "Teal",      "Concussion trail");
	g_h_emp_color        = CreateConVar("sm_sgt_emp_color",        "Purple",    "EMP trail");
	g_h_gas_color        = CreateConVar("sm_sgt_gas_color",        "39 161 88",     "Gas trail");
	g_h_heal_color       = CreateConVar("sm_sgt_heal_color",       "Blue",     "Heal trail");
	g_h_mirv_color       = CreateConVar("sm_sgt_mirv_color",       "Red",       "MIRV trail");
	g_h_mirvbomb_color   = CreateConVar("sm_sgt_mirvbomb_color",   "Orange",    "MIRV bomb trail");
	g_h_nail_color       = CreateConVar("sm_sgt_nail_color",       "100 176 66",      "Nail trail");
	g_h_napalm_color     = CreateConVar("sm_sgt_napalm_color",     "255 150 0", "Napalm trail");
	g_h_normal_color     = CreateConVar("sm_sgt_normal_color",     "Green",       "Normal grenade trail");
	g_h_default_color    = CreateConVar("sm_sgt_default_color",    "Black",     "Default/fallback");

	AutoExecConfig(true, "simple_grenade_trails_pf2");

	g_laser_sprite = PrecacheModel("materials/sprites/laserbeam.vmt");
}

public void OnMapStart() {
	g_laser_sprite = PrecacheModel("materials/sprites/laserbeam.vmt");
}

public void OnEntityCreated(int entity, const char[] classname) {
	if (IsValidEdict(entity) && GetConVarBool(g_h_plugin_enabled) && IsGrenadeProjectile(classname)) {
		SDKHook(entity, SDKHook_SpawnPost, OnGrenadeSpawnPost);
	}
}

void OnGrenadeSpawnPost(int entity) {
	if (!IsValidEntity(entity)) return;

	float trail_time       = GetConVarFloat(g_h_trail_time);
	int   trail_fade_time  = RoundToNearest(trail_time - 1.0);
	float trail_width_start = GetConVarFloat(g_h_trail_width_start);
	float trail_width_end   = GetConVarFloat(g_h_trail_width_end);

	char classname[64];
	GetEdictClassname(entity, classname, sizeof(classname));

	if (!GetConVarBool(g_h_plugin_enabled)) return;

	if (!IsModelPrecached("materials/sprites/laserbeam.vmt"))
		g_laser_sprite = PrecacheModel("materials/sprites/laserbeam.vmt");

	if (StrContains(classname, "caltrop") != -1)    SetColor(g_h_caltrop_color);
	else if (StrContains(classname, "concussion") != -1) SetColor(g_h_concussion_color);
	else if (StrContains(classname, "emp") != -1)         SetColor(g_h_emp_color);
	else if (StrContains(classname, "gas") != -1)         SetColor(g_h_gas_color);
	else if (StrContains(classname, "heal") != -1)        SetColor(g_h_heal_color);
	else if (StrContains(classname, "mirv_bomb") != -1)   SetColor(g_h_mirvbomb_color);
	else if (StrContains(classname, "mirv") != -1)        SetColor(g_h_mirv_color);
	else if (StrContains(classname, "nail") != -1)        SetColor(g_h_nail_color);
	else if (StrContains(classname, "napalm") != -1)      SetColor(g_h_napalm_color);
	else if (StrContains(classname, "normal") != -1)      SetColor(g_h_normal_color);
	else                                                  SetColor(g_h_default_color);

	TE_SetupBeamFollow(entity, g_laser_sprite, 0, trail_time, trail_width_start, trail_width_end, trail_fade_time, g_nade_color);
	TE_SendToAll();
}

bool IsGrenadeProjectile(const char[] classname) {
	for (int i = 0; i < sizeof(g_projectiles); i++)
		if (StrEqual(classname, g_projectiles[i]))
			return true;
	return false;
}

void SetColor(Handle cvar) {
	char buffer[32];
	GetConVarString(cvar, buffer, sizeof(buffer));

	// Support "255 150 0" RGB syntax
	if (StrContains(buffer, " ") != -1) {
		char parts[3][10];
		if (ExplodeString(buffer, " ", parts, sizeof(parts), sizeof(parts[])) == 3) {
			g_nade_color[0] = StringToInt(parts[0]);
			g_nade_color[1] = StringToInt(parts[1]);
			g_nade_color[2] = StringToInt(parts[2]);
			g_nade_color[3] = 255;
			return;
		}
	}

	if (StrEqual(buffer, "red", false))        g_nade_color = RED;
	else if (StrEqual(buffer, "blue", false))  g_nade_color = BLUE;
	else if (StrEqual(buffer, "green", false)) g_nade_color = GREEN;
	else if (StrEqual(buffer, "purple", false))g_nade_color = PURPLE;
	else if (StrEqual(buffer, "white", false)) g_nade_color = WHITE;
	else if (StrEqual(buffer, "orange", false))g_nade_color = ORANGE;
	else if (StrEqual(buffer, "yellow", false))g_nade_color = YELLOW;
	else if (StrEqual(buffer, "teal", false))  g_nade_color = TEAL;
	else if (StrEqual(buffer, "gray", false))  g_nade_color = GRAY;
	else                                        g_nade_color = WHITE;
}