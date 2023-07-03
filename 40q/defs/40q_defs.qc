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

#define IT_SMALL 256
#define IT_AMMO_LT 512
#define IT_AMMO_HVY 1024
#define IT_CELLS 2048

#define AMMO_COST_HBOLT 4
#define AMMO_COST_STORMBOLT 3
#define AMMO_COST_BOLT 2
#define AMMO_COST_MISSILE 3
#define AMMO_COST_PLAS 5
#define AMMO_COST_MELT 10

#define DMG_BOLTGUN 
#define DMG_ASSHOTG 
#define DMG_TEMPEST 
#define DMG_HVYBOLT 
#define DMG_PLASMA 
#define DMG_ROCKET 
#define DMG_MELTA 

#define FL_DEMON 8192
#define FL_MOB 16384

#define MARK_RAGE 1
#define MARK_OBSESS 1
#define MARK_ROT 2
#define MARK_TWIST 3

//Mob base stats
.float health_max;
.float strength;
.float toughness;
.float armor_save;
.float invuln_save;
.float wounds;
.float demon_mark;


// Ranged weapon stats
.float weapon_str;
.float weapon_ap;
.float weapon_dmg;

// Augments Mob's base stats for melee attacks.
.float melee_str;
.float melee_ap;
.float melee_dmg;

// Assault waves
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
