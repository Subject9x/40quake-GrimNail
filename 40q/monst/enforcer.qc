/*  Copyright (C) 1996-1997  Id Software, Inc.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/
/*
==============================================================================

SOLDIER / PLAYER

==============================================================================
*/

$cd /raid/quake/id1/models/enforcer
$origin 0 -6 24
$base base
$skin skin

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame walk11 walk12 walk13 walk14 walk15 walk16

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame attack1 attack2 attack3 attack4 attack5 attack6
$frame attack7 attack8 attack9 attack10

$frame death1 death2 death3 death4 death5 death6 death7 death8
$frame death9 death10 death11 death12 death13 death14

$frame fdeath1 fdeath2 fdeath3 fdeath4 fdeath5 fdeath6 fdeath7 fdeath8
$frame fdeath9 fdeath10 fdeath11

$frame paina1 paina2 paina3 paina4

$frame painb1 painb2 painb3 painb4 painb5

$frame painc1 painc2 painc3 painc4 painc5 painc6 painc7 painc8

$frame paind1 paind2 paind3 paind4 paind5 paind6 paind7 paind8
$frame paind9 paind10 paind11 paind12 paind13 paind14 paind15 paind16
$frame paind17 paind18 paind19

//UNUSED ATM
void() Laser_Touch =
{
	vector org;

	if (other == self.owner)
		return; // don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	sound(self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	org = self.origin - 8*normalize(self.velocity);

	if (other.health)
	{
		SpawnBlood(org, self.velocity*0.2, 15);
		T_Damage(other, self, self.owner, 15);
	}
	else
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord(MSG_BROADCAST, org_x);
		WriteCoord(MSG_BROADCAST, org_y);
		WriteCoord(MSG_BROADCAST, org_z);
	}

	remove(self);
};

//UNUSED ATM
void(vector org, vector vec) LaunchPlasma =
{

	sound(self, CHAN_WEAPON, "enforcer/enfire.wav", 1, ATTN_NORM);

	vec = normalize(vec);

	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.modelflags = MF_TRACER3;
	newmis.effects = EF_FULLBRIGHT;

	setmodel(newmis, "progs/v_spike.mdl");
	setsize(newmis, '0 0 0', '0 0 0');

	setorigin(newmis, org);
	
	if(self.demon_mark == MARK_RAGE){
		newmis.velocity = vec * 700;
	}
	else{
		newmis.velocity = vec * 550;
	}

	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 3;
	newmis.think = SUB_Remove;
	newmis.touch = T_PlasmaTouch;

	newmis.weapon_str = self.weapon_str;
	newmis.weapon_ap = self.weapon_ap;
	newmis.weapon_dmg = self.weapon_dmg;
};
void(vector org, vector vec) LaunchLaser =
{
	if (self.classname == "monster_enforcer")
		sound(self, CHAN_WEAPON, "enforcer/enfire.wav", 1, ATTN_NORM);

	vec = normalize(vec);

	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;

	setmodel(newmis, "progs/laser.mdl");
	setsize(newmis, '0 0 0', '0 0 0');

	setorigin(newmis, org);
	
	if(self.demon_mark == MARK_RAGE){
		newmis.velocity = vec * 750;
	}
	else{
		newmis.velocity = vec * 600;
	}

	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 5;
	newmis.think = SUB_Remove;
	newmis.touch = Laser_Touch;

	newmis.weapon_str = self.weapon_str;
	newmis.weapon_ap = self.weapon_ap;
	newmis.weapon_dmg = self.weapon_dmg;
};



void() enforcer_fire =
{
	vector org;
	vector dir;
	vector spread;

	if (self.subType == ENFORCE_TYPE_PLAS)
	{
		self.effects = self.effects | EF_MUZZLEFLASH;
		makevectors(self.angles);
	
		org = self.origin + v_forward * 30 + v_right * 8.5 + '0 0 16';
		dir = self.enemy.origin;

		spread = '10.0 10.0  0';
		if(self.demon_mark == MARK_EXCESS){
			dir = dir + self.enemy.velocity * 0.3;
		}
		if(self.demon_mark == MARK_RAGE){
			spread = '25.0 25.0 0.0';
		}
		if(self.demon_mark == MARK_TWIST){
			spread = '5.0 5.0 0.0';
		}
		
		dir = dir - self.origin;
		dir = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;

		LaunchPlasma(org, dir);
	}
	else
	{
		W_FireHvyStub();
	}
};

//============================================================================

void() enf_stand1 = [ $stand1, enf_stand2 ] { ai_stand(); };
void() enf_stand2 = [ $stand2, enf_stand3 ] { ai_stand(); };
void() enf_stand3 = [ $stand3, enf_stand4 ] { ai_stand(); };
void() enf_stand4 = [ $stand4, enf_stand5 ] { ai_stand(); };
void() enf_stand5 = [ $stand5, enf_stand6 ] { ai_stand(); };
void() enf_stand6 = [ $stand6, enf_stand7 ] { ai_stand(); };
void() enf_stand7 = [ $stand7, enf_stand1 ] { ai_stand(); };

void() enf_walk1 = [ $walk1 , enf_walk2 ]
{
	if (random() < 0.2)
		sound(self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);
	M_ai_mark_walk(2)
};
void() enf_walk2 = [ $walk2 , enf_walk3 ] { M_ai_mark_walk(4) };
void() enf_walk3 = [ $walk3 , enf_walk4 ] { M_ai_mark_walk(4) };
void() enf_walk4 = [ $walk4 , enf_walk5 ] { M_ai_mark_walk(3) };
void() enf_walk5 = [ $walk5 , enf_walk6 ] { M_ai_mark_walk(1) };
void() enf_walk6 = [ $walk6 , enf_walk7 ] { M_ai_mark_walk(2) };
void() enf_walk7 = [ $walk7 , enf_walk8 ] { M_ai_mark_walk(2) };
void() enf_walk8 = [ $walk8 , enf_walk9 ] { M_ai_mark_walk(1) };
void() enf_walk9 = [ $walk9 , enf_walk10 ] { M_ai_mark_walk(2) };
void() enf_walk10 = [ $walk10, enf_walk11 ] { M_ai_mark_walk(4) };
void() enf_walk11 = [ $walk11, enf_walk12 ] { M_ai_mark_walk(4) };
void() enf_walk12 = [ $walk12, enf_walk13 ] { M_ai_mark_walk(1) };
void() enf_walk13 = [ $walk13, enf_walk14 ] { M_ai_mark_walk(2) };
void() enf_walk14 = [ $walk14, enf_walk15 ] { M_ai_mark_walk(3) };
void() enf_walk15 = [ $walk15, enf_walk16 ] { M_ai_mark_walk(4) };
void() enf_walk16 = [ $walk16, enf_walk1 ] { M_ai_mark_walk(2) };

void() enf_run1 = [ $run1  , enf_run2 ]
{
	if (random() < 0.2)
		sound(self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE);
	M_ai_mark_run(18)
};
void() enf_run2 = [ $run2  , enf_run3 ] { M_ai_mark_run(14) };
void() enf_run3 = [ $run3  , enf_run4 ] { M_ai_mark_run(7) };
void() enf_run4 = [ $run4  , enf_run5 ] { M_ai_mark_run(12) };
void() enf_run5 = [ $run5  , enf_run6 ] { M_ai_mark_run(14) };
void() enf_run6 = [ $run6  , enf_run7 ] { M_ai_mark_run(14) };
void() enf_run7 = [ $run7  , enf_run8 ] { M_ai_mark_run(7) };
void() enf_run8 = [ $run8  , enf_run1 ] { M_ai_mark_run(11) };

void() enf_atk1 = [ $attack1, enf_atk2 ] { ai_face(); };
void() enf_atk2 = [ $attack2, enf_atk3 ] { ai_face(); };
void() enf_atk3 = [ $attack3, enf_atk4 ] { 
	ai_face();
	if (self.subType != ENFORCE_TYPE_PLAS)
	{
		enforcer_fire();
	}
};
void() enf_atk4 = [ $attack4, enf_atk5 ] { 
	ai_face();
	if (self.subType != ENFORCE_TYPE_PLAS)
	{
		if (self.demon_mark != MARK_TWIST)
		{
			enforcer_fire();
		}
	}
};
void() enf_atk5 = [ $attack5, enf_atk6 ] { 
	ai_face();
};
void() enf_atk6 = [ $attack6, enf_atk7 ] { 
	if (self.subType != ENFORCE_TYPE_PLAS)
	{
		enforcer_fire();
	}
};
void() enf_atk7 = [ $attack7, enf_atk8 ] { 
	ai_face();
};
void() enf_atk8 = [ $attack8, enf_atk9 ] { 
	if (self.demon_mark != MARK_TWIST)
	{
		enforcer_fire();
	}
	if(cvar("skill") > 1){
	 	ai_face(); 
	}
};
void() enf_atk9 = [ $attack5, enf_atk10 ] { 
	ai_face();
 };
void() enf_atk10 = [ $attack6, enf_atk11 ] { 

	if (self.subType != ENFORCE_TYPE_PLAS)
	{
		enforcer_fire();
	}
};
void() enf_atk11 = [ $attack7, enf_atk12 ] { 
	ai_face();
 };
void() enf_atk12 = [ $attack8, enf_atk13 ] { 

	if (self.subType != ENFORCE_TYPE_PLAS)
	{
		if (self.demon_mark != MARK_TWIST)
		{
			enforcer_fire();
		}
	}
	if(cvar("skill") > 1){
	 	ai_face(); 
	}
};
void() enf_atk13 = [ $attack9, enf_atk14 ] { 
	ai_face();
 };
void() enf_atk14 = [ $attack10, enf_run1 ]
{
	ai_face();
	SUB_CheckRefire(enf_atk1);
};

void() enf_paina1 = [ $paina1, enf_paina2 ] {};
void() enf_paina2 = [ $paina2, enf_paina3 ] {};
void() enf_paina3 = [ $paina3, enf_paina4 ] {};
void() enf_paina4 = [ $paina4, enf_run1 ] {};

void() enf_painb1 = [ $painb1, enf_painb2 ] {};
void() enf_painb2 = [ $painb2, enf_painb3 ] {};
void() enf_painb3 = [ $painb3, enf_painb4 ] {};
void() enf_painb4 = [ $painb4, enf_painb5 ] {};
void() enf_painb5 = [ $painb5, enf_run1 ] {};

void() enf_painc1 = [ $painc1, enf_painc2 ] {};
void() enf_painc2 = [ $painc2, enf_painc3 ] {};
void() enf_painc3 = [ $painc3, enf_painc4 ] {};
void() enf_painc4 = [ $painc4, enf_painc5 ] {};
void() enf_painc5 = [ $painc5, enf_painc6 ] {};
void() enf_painc6 = [ $painc6, enf_painc7 ] {};
void() enf_painc7 = [ $painc7, enf_painc8 ] {};
void() enf_painc8 = [ $painc8, enf_run1 ] {};

void() enf_paind1 = [ $paind1, enf_paind2 ] {};
void() enf_paind2 = [ $paind2, enf_paind3 ] {};
void() enf_paind3 = [ $paind3, enf_paind4 ] {};
void() enf_paind4 = [ $paind4, enf_paind5 ] { ai_painforward(2); };
void() enf_paind5 = [ $paind5, enf_paind6 ] { ai_painforward(1); };
void() enf_paind6 = [ $paind6, enf_paind7 ] {};
void() enf_paind7 = [ $paind7, enf_paind8 ] {};
void() enf_paind8 = [ $paind8, enf_paind9 ] {};
void() enf_paind9 = [ $paind9, enf_paind10 ] {};
void() enf_paind10 = [ $paind10, enf_paind11 ] {};
void() enf_paind11 = [ $paind11, enf_paind12 ] { ai_painforward(1); };
void() enf_paind12 = [ $paind12, enf_paind13 ] { ai_painforward(1); };
void() enf_paind13 = [ $paind13, enf_paind14 ] { ai_painforward(1); };
void() enf_paind14 = [ $paind14, enf_paind15 ] {};
void() enf_paind15 = [ $paind15, enf_paind16 ] {};
void() enf_paind16 = [ $paind16, enf_paind17 ] { ai_pain(1); };
void() enf_paind17 = [ $paind17, enf_paind18 ] { ai_pain(1); };
void() enf_paind18 = [ $paind18, enf_paind19 ] {};
void() enf_paind19 = [ $paind19, enf_run1 ] {};

void(entity attacker, float damage) enf_pain =
{
	float r;

	r = random();
	if (self.pain_finished > time)
		return;


	if (r < 0.5)
		sound(self, CHAN_VOICE, "enforcer/pain1.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_VOICE, "enforcer/pain2.wav", 1, ATTN_NORM);

	if (r < 0.2)
	{
		self.pain_finished = time + 1;
		if(self.demon_mark == MARK_EXCESS)
			self.pain_finished = time + 0.5;
		
		enf_paina1();
	}
	else if (r < 0.4)
	{
		self.pain_finished = time + 1;
		if(self.demon_mark == MARK_EXCESS)
			self.pain_finished = time + 0.5;
		
		enf_painb1();
	}
	else if (r < 0.7)
	{
		self.pain_finished = time + 1;
		enf_painc1();
	}
	else
	{
		if(self.demon_mark != MARK_RAGE){
			self.pain_finished = time + 2;
			if(self.demon_mark == MARK_TWIST)
				self.pain_finished = time + 1;
			
			enf_paind1();
		}
	}
};

//============================================================================




void() enf_die1 = [ $death1, enf_die2 ] {};
void() enf_die2 = [ $death2, enf_die3 ] {};
void() enf_die3 = [ $death3, enf_die4 ]
{
	self.solid = SOLID_NOT;
	self.ammo_shells = ENFORCE_PACK_SMALL;
	self.ammo_nails = ENFORCE_PACK_LT;
	DropBackpack();
};
void() enf_die4 = [ $death4, enf_die5 ] { ai_forward(14); };
void() enf_die5 = [ $death5, enf_die6 ] { ai_forward(2); };
void() enf_die6 = [ $death6, enf_die7 ] {};
void() enf_die7 = [ $death7, enf_die8 ] {};
void() enf_die8 = [ $death8, enf_die9 ] {};
void() enf_die9 = [ $death9, enf_die10 ] { ai_forward(3); };
void() enf_die10 = [ $death10, enf_die11 ] { ai_forward(5); };
void() enf_die11 = [ $death11, enf_die12 ] { ai_forward(5); };
void() enf_die12 = [ $death12, enf_die13 ] { ai_forward(5); };
void() enf_die13 = [ $death13, enf_die14 ] {};
void() enf_die14 = [ $death14, enf_die14 ] {};

void() enf_fdie1 = [ $fdeath1, enf_fdie2 ] {};
void() enf_fdie2 = [ $fdeath2, enf_fdie3 ] {};
void() enf_fdie3 = [ $fdeath3, enf_fdie4 ]
{
	self.solid = SOLID_NOT;
	self.ammo_shells = ENFORCE_PACK_SMALL;
	self.ammo_nails = ENFORCE_PACK_LT;
	DropBackpack();
};
void() enf_fdie4 = [ $fdeath4, enf_fdie5 ] {};
void() enf_fdie5 = [ $fdeath5, enf_fdie6 ] {};
void() enf_fdie6 = [ $fdeath6, enf_fdie7 ] {};
void() enf_fdie7 = [ $fdeath7, enf_fdie8 ] {};
void() enf_fdie8 = [ $fdeath8, enf_fdie9 ] {};
void() enf_fdie9 = [ $fdeath9, enf_fdie10 ] {};
void() enf_fdie10 = [ $fdeath10, enf_fdie11 ] {};
void() enf_fdie11 = [ $fdeath11, enf_fdie11 ] {};


void() enf_die =
{
	if ((self.effects & EF_DIMLIGHT))
	{
		self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}
// check for gib
	if (self.health < -35)
	{
		sound(self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead("progs/h_mega.mdl", self.health);
		ThrowGib("progs/gib1.mdl", self.health);
		ThrowGib("progs/gib2.mdl", self.health);
		ThrowGib("progs/gib3.mdl", self.health);
		return;
	}

// regular death
	sound(self, CHAN_VOICE, "enforcer/death1.wav", 1, ATTN_NORM);
	if (random() > 0.5)
		enf_die1();
	else
		enf_fdie1();
};


/*QUAKED monster_enforcer (1 0 0) (-16 -16 -24) (16 16 40) Ambush

*/
void() monster_enforcer =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model2 ("progs/enforcer.mdl");
	precache_model2 ("progs/enforcer.md5");
	precache_model2 ("progs/h_mega.mdl");
	precache_model2 ("progs/laser.mdl");

	precache_sound2 ("enforcer/death1.wav");
	precache_sound2 ("enforcer/enfire.wav");
	precache_sound2 ("enforcer/enfstop.wav");
	precache_sound2 ("enforcer/idle1.wav");
	precache_sound2 ("enforcer/pain1.wav");
	precache_sound2 ("enforcer/pain2.wav");
	precache_sound2 ("enforcer/sight1.wav");
	precache_sound2 ("enforcer/sight2.wav");
	precache_sound2 ("enforcer/sight3.wav");
	precache_sound2 ("enforcer/sight4.wav");

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel(self, "progs/enforcer.mdl");

	setsize(self, '-16 -16 -24', '16 16 40');

	self.th_stand = enf_stand1;
	self.th_walk = enf_walk1;
	self.th_run = enf_run1;
	self.th_pain = enf_pain;
	self.th_die = enf_die;
	self.th_missile = enf_atk1;

	//40Q stats----------------
	if (!self.subType)
	{
		self.subType = ENFORCE_TYPE_STUB;
		if (random() < 0.3)
		{
			self.subType = ENFORCE_TYPE_PLAS;
			self.effects = self.effects | EF_DIMLIGHT;
		}
	}
	M_ai_assign_mark()

	M_dbg_assign_mark()	//DEBUG

	self.flags = self.flags | FL_MOB;
	self.health = ENFORCE_HP;
	self.strength = ENFORCE_STR;
	self.toughness = ENFORCE_TOUGH;
	self.armor_save = ENFORCE_ARMOR_SV;
	self.invuln_save = ENFORCE_INVULN;
	self.wounds = ENFORCE_WOUNDS;

	if (self.subType == ENFORCE_TYPE_PLAS)
	{
		self.weapon_str = PLASMA_STR;
		self.weapon_ap = PLASMA_AP;
		self.weapon_dmg = PLASMA_DMG;
	}
	else{
		self.weapon_str = HVYSTUB_STR;
		self.weapon_ap = HVYSTUB_AP;
		self.weapon_dmg = HVYSTUB_DMG;
	}
	
	M_ai_mark_stat()
	M_ai_set_name("Enforcer", "Infected Enforcer", "Hedonist Enforcer", "Anger Prophet", "Twisted Enforcer")
	M_ai_set_yaw(20)
	//------------------------

	walkmonster_start();
};
