/*
    GrimQuake?
*/

#define IT_BOLTGUN 1
#define IT_SPACE_SHOTG 2
#define IT_TEMPEST_BOLTER 4
#define IT_HVY_BOLTER 8
#define IT_PLASMA_GUN 16
#define IT_ROCKET_LAUNCH 32
#define IT_MELTAGUN 64

//#define IT_SMALL 256
//#define IT_AMMO_LT 512
//#define IT_AMMO_HVY 1024
//#define IT_CELLS 2048

#define IT_AMMO_SMALL 1
#define IT_AMMO_LT 2
#define IT_AMMO_HVY 3
#define IT_AMMO_CELLS 4

/*
#define DMG_SHOTTGUN 6
#define DMG_SUPRSHOTG 14
#define DMG_NAILGUN 3
#define DMG_SUPER_NAIL 9
#define DMG_GRENADE 80
#define DMG_ROCKET 100
#define DMG_MELTA 100
*/

#define FL_DEMON 8192
#define FL_MOB 16384

#define MARK_RAGE 4
#define MARK_EXCESS 8
#define MARK_DESPAIR 16
#define MARK_TWIST 32

#define MARK_RAGE_CLR '0.8 0.33 0.15'
#define MARK_EXCESS_CLR '0.8 0.15 0.7'
#define MARK_DESPAIR_CLR '0.05 0.8 0.15'
#define MARK_TWIST_CLR '0.15 0.33 0.8'

#define MARK_RAGE_CLR_8 108
#define MARK_EXCESS_CLR_8 128
#define MARK_DESPAIR_CLR_8 176
#define MARK_TWIST_CLR_8 47

#define WATERLEVEL_NOT 0
#define WATERLEVEL_LEGS 1
#define WATERLEVEL_WAIST 2
#define WATERLEVEL_HEAD 3

#define DMG_RESULT_V_LOW -2
#define DMG_RESULT_LOW -1
#define DMG_RESULT_HIGH 1
#define DMG_RESULT_V_HIGH 2


.vector last_origin;
.entity look_mob;	//The monster the player is looking at.
.float dmg_result;	//T_Damage feedback to projectiles to show hit hints
.float dmg_out;	//record inflictor dmg for effects.
.float subType;	// monster sub types

//Mob base stats
.float strength;
.float toughness;
.float armor_save;
.float invuln_save;
.float wounds;
.float demon_mark;
.float pain_time;	//pain_finished cooldown

.float axe_extra_dmg; //zombies, soldiers, fish, dogs are all EXTRA vulnerable to axe
.entity axe_ent;	//what has the axe struck?

.float ai_side_charge;
.float ai_side_charge_angle;

.float hinder_time;
.float hinder_slow;
.float hinder_cool;

.float armor_save_set;
.float toughness_set;
.float strength_set;

// Ranged weapon stats
.float weapon_str;
.float weapon_ap;
.float weapon_dmg;

// Augments Mob's base stats for melee attacks.
.float melee_str;
.float melee_ap;
.float melee_dmg;

// TIMERS
.float timer_axe_hit;	//stop player from completely axing down big targets
.float timer_look_mob;

// PLAYER STUFF
.float marks_despair;
.float marks_rage;
.float marks_twist;
.float marks_excess;



void(string msg, vector v) logVec={

	dprint("\n");
	dprint(msg);
	dprint(":");
	dprint(vtos(v));
	dprint("\n");

};

void(string msg, string val) logStr={
	
	dprint("\n");
	dprint(msg);
	dprint(":");
	dprint(val);
	dprint("\n");
};


void(string msg, float val) logFloat={
	
	dprint("\n");
	dprint(msg);
	dprint(":");
	dprint(ftos(val));
	dprint("\n");
};

entity WORLD_ENT;	//stand-in for World something something assignable fields.
entity MOB_MARK_ENT;
void() mark_th;
void() mark_frame1;
void() mark_frame2;
void() mark_frame3;


void() mark_frame =
{
	//self.frame = 0;
	//self.think = mark_frame1;
	self.think = mark_frame;
	mark_th();
};
//TODO - animated sigils
void() mark_frame1 = 
{
	self.frame = 1;
	self.think = mark_frame2;
	mark_th();
};
void() mark_frame2 =
{

	self.frame = 2;
	self.think = mark_frame3;
	mark_th();
};
void() mark_frame3 =
{
	self.frame = 3;
	self.think = mark_frame;
	mark_th();
};
