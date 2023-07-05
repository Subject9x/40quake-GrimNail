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

#define AMMO_COST_HBOLT 2
#define AMMO_COST_STORMBOLT 2
#define AMMO_COST_BOLT 1
#define AMMO_COST_MISSILE 2
#define AMMO_COST_PLAS 3
#define AMMO_COST_MELT 7

/*
#define DMG_SHOTTGUN 6
#define DMG_SUPRSHOTG 14
#define DMG_NAILGUN 3
#define DMG_SUPER_NAIL 9
#define DMG_GRENADE 80
#define DMG_ROCKET 100
#define DMG_MELTA 100
*/

#define DMG_BOLTGUN 4
#define DMG_ASTSHOTG 1
#define DMG_TEMPEST 1
#define DMG_HVYBOLT 5
#define DMG_PLASMA 8
#define DMG_ROCKET 6
#define DMG_MELTA 12

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
