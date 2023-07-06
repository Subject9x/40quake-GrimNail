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
*/
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void() player_run;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;
void(vector org, vector vel, float damage) SpawnBlood;
void() SuperDamageSound;


// called by worldspawn
void() W_Precache =
{
	precache_sound("weapons/r_exp3.wav"); // new rocket explosion
	precache_sound("weapons/rocket1i.wav"); // spike gun
	precache_sound("weapons/sgun1.wav");
	precache_sound("weapons/guncock.wav"); // player shotgun
	precache_sound("weapons/ric1.wav"); // ricochet (used in c code)
	precache_sound("weapons/ric2.wav"); // ricochet (used in c code)
	precache_sound("weapons/ric3.wav"); // ricochet (used in c code)
	precache_sound("weapons/spike2.wav"); // super spikes
	precache_sound("weapons/tink1.wav"); // spikes tink(used in c code)
	precache_sound("weapons/grenade.wav"); // grenade launcher
	precache_sound("weapons/bounce.wav"); // grenade bounce
	precache_sound("weapons/shotgn2.wav"); // super shotgun
};

float() crandom =
{
	return 2*(random() - 0.5);
};

/*
================
W_FireAxe
================
*/
void() W_FireAxe =
{
	vector source;
	vector org;
	vector oWep;
	entity this;

	source = self.origin + '0 0 16';
	traceline(source, source + v_forward*64, FALSE, self);
	if (trace_fraction == 1.0)
		return;

	org = trace_endpos - v_forward*4;

	if (trace_ent.takedamage)
	{
		if(trace_ent.axhitme == FALSE){
			trace_ent.axhitme = 1;
			SpawnBlood(org, '0 0 0', 20);
		}
		oWep = [self.weapon_str, self.weapon_ap, self.weapon_dmg];
		self.weapon_str = self.melee_str + self.strength;
		self.weapon_ap = self.melee_ap;
		self.weapon_dmg = self.melee_dmg;
	
		T_Damage(trace_ent, self, self, 20);
	
		self.weapon_str = oWep_x;
		self.weapon_ap = oWep_y;
		self.weapon_dmg = oWep_z;

		//TODO - 40Q pain lock
		/*if((trace_ent.flags &(FL_MOB) && !(trace_ent.flags & FL_DEMON))){
			this = self;
			self = trace_ent;
				self.th_pain(this, 20);
			self = this;
		}*/
	
	}
	else
	{ 
		if(trace_ent){// hit wall
			sound(self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
			WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte(MSG_BROADCAST, TE_GUNSHOT);
			WriteCoord(MSG_BROADCAST, org_x);
			WriteCoord(MSG_BROADCAST, org_y);
			WriteCoord(MSG_BROADCAST, org_z);
		}
	}
};


//============================================================================


vector() wall_velocity =
{
	vector vel;

	vel = normalize(self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	return vel;
};


/*
================
SpawnMeatSpray
================
*/
void(vector org, vector vel) SpawnMeatSpray =
{
	entity missile;

	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;

	makevectors(self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';

// set missile duration
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	setmodel(missile, "progs/zom_gib.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, org);
};

/*
================
SpawnBlood
================
*/
void(vector org, vector vel, float damage) SpawnBlood =
{
	particle(org, vel*0.1, 73, damage*2);
};

/*
================
spawn_touchblood
================
*/
void(float damage) spawn_touchblood =
{
	vector vel;

	vel = wall_velocity() * 0.2;
	SpawnBlood(self.origin + vel*0.01, vel, damage);
};


/*
================
SpawnChunk
================
*/
void(vector org, vector vel) SpawnChunk =
{
	particle(org, vel*0.02, 0, 10);
};

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

entity multi_ent;
float multi_damage;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
		return;
	T_Damage(multi_ent, self, self, multi_damage);
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
		return;

	if (hit != multi_ent)
	{
		ApplyMultiDamage();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

/*
==============================================================================

BULLETS

==============================================================================
*/

/*
================
TraceAttack
================
*/
void(float damage, vector dir) TraceAttack =
{
	vector vel, org;

	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	org = trace_endpos - dir*4;

	if (trace_ent.takedamage)
	{
		SpawnBlood(org, vel*0.2, damage);
		AddMultiDamage(trace_ent, damage);
	}
	else
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord(MSG_BROADCAST, org_x);
		WriteCoord(MSG_BROADCAST, org_y);
		WriteCoord(MSG_BROADCAST, org_z);
	}
};

/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void(float shotcount, vector dir, vector spread) FireBullets =
{
	vector direction;
	vector src;

	makevectors(self.v_angle);

	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage();
	while (shotcount > 0)
	{
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;

		traceline(src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceAttack(4, direction);

		shotcount = shotcount - 1;
	}
	ApplyMultiDamage();
};

/*
================
W_FireShotgun
================
*/
void() W_FireShotgun =
{
	vector dir;

	sound(self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	dir = aim(self, 100000);
	FireBullets(6, dir, '0.04 0.04 0');
};


/*
================
W_FireSuperShotgun
================
*/
void() W_FireSuperShotgun =
{
	vector dir;

	

	sound(self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	if (self.currentammo == 1)
	{
		self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	}
	else
	{
		self.currentammo = self.ammo_shells = self.ammo_shells - 2;
	}
	
	dir = aim(self, 100000);
	FireBullets(14, dir, '0.14 0.08 0');
};


/*
==============================================================================

ROCKETS

==============================================================================
*/

void() s_explode1 = [ 0, s_explode2 ] {};
void() s_explode2 = [ 1, s_explode3 ] {};
void() s_explode3 = [ 2, s_explode4 ] {};
void() s_explode4 = [ 3, s_explode5 ] {};
void() s_explode5 = [ 4, s_explode6 ] {};
void() s_explode6 = [ 5, SUB_Remove ] {};

void() BecomeExplosion =
{
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel(self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1();
};

void() T_MissileTouch =
{
	float damg;

	if (other == self.owner)
		return; // don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	damg = ROCKET_DMG + random()*20;

	if (other.health)
	{
		if (other.classname == "monster_shambler")
			damg = damg * 0.5; // mostly immune
		T_Damage(other, self, self.owner, damg );
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage(self, self.owner, 120, other);

//	sound(self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);

	BecomeExplosion();
};



/*
================
W_FireRocket
================
*/
void() W_FireRocket =
{
	entity missile;

	self.currentammo = self.ammo_rockets = self.ammo_rockets - ROCKET_AMMO_COST;

	sound(self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;

// set missile speed

	makevectors(self.v_angle);
	missile.velocity = aim(self, 1000);
	missile.velocity = missile.velocity * 1000;
	missile.angles = vectoangles(missile.velocity);

	missile.touch = T_MissileTouch;

// set missile duration
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;

	setmodel(missile, "progs/missile.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, self.origin + v_forward*8 + '0 0 16');

	missile.weapon_str = self.weapon_str;
	missile.weapon_ap = self.weapon_ap;
	missile.weapon_dmg = self.weapon_dmg;
};


void() T_PlasmaTouch =
{
	float damg;

	if (other == self.owner)
		return; // don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	//damg = 100 + random()*20;
	damg = PLASMA_DMG + random()*20;

	if (other.health)
	{
		T_Damage(other, self, self.owner, damg );
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage(self, self.owner, 120, other);

//	sound(self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);

	BecomeExplosion();
};

/*
================
W_FirePlasma
================
*/
void() W_FirePlasma =
{
	entity missile;

	self.currentammo = self.ammo_cells = self.ammo_cells - PLASMA_AMMO_COST;

	sound(self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	self.punchangle_x = -0.4;	//-2

	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;

// set missile speed

	makevectors(self.v_angle);
	missile.velocity = aim(self, 1000);
	missile.velocity = missile.velocity * 650;	// 1000
	//missile.angles = vectoangles(missile.velocity);
	missile.avelocity = '200 100 300';

	missile.touch = T_PlasmaTouch;

// set missile duration
	missile.nextthink = time + 3;
	missile.think = SUB_Remove;

	precache_model2("progs/v_spike.mdl");

	setmodel(missile, "progs/v_spike.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, self.origin + v_forward*8 + '0 0 16');

	missile.weapon_str = self.weapon_str;
	missile.weapon_ap = self.weapon_ap;
	missile.weapon_dmg = self.weapon_dmg;
};




/*
===============================================================================

LIGHTNING

===============================================================================
*/

/*
=================
LightningDamage
=================
*/
void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
	entity e1, e2;
	vector f;

	f = p2 - p1;
	normalize(f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	e1 = e2 = world;

	traceline(p1, p2, FALSE, self);
	if (trace_ent.takedamage)
	{
		particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from, damage);
		if (self.classname == "player")
		{
			if (other.classname == "player")
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	e1 = trace_ent;

	traceline(p1 + f, p2 + f, FALSE, self);
	if (trace_ent != e1 && trace_ent.takedamage)
	{
		particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from, damage);
	}
	e2 = trace_ent;

	traceline(p1 - f, p2 - f, FALSE, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from, damage);
	}
};


void() W_FireLightning =
{
	vector org;

	if (self.ammo_cells < 1)
	{
		self.weapon = W_BestWeapon();
		W_SetCurrentAmmo();
		return;
	}

// explode if under water
	if (self.waterlevel > 1)
	{
		T_RadiusDamage(self, self, 35*self.ammo_cells, world);
		self.ammo_cells = 0;
		W_SetCurrentAmmo();
		return;
	}

	if (self.t_width < time)
	{
		sound(self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
		self.t_width = time + 0.6;
	}
	self.punchangle_x = -2;

	self.currentammo = self.ammo_cells = self.ammo_cells - 1;

	org = self.origin + '0 0 16';

	traceline(org, org + v_forward*600, TRUE, self);

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity(MSG_BROADCAST, self);
	WriteCoord(MSG_BROADCAST, org_x);
	WriteCoord(MSG_BROADCAST, org_y);
	WriteCoord(MSG_BROADCAST, org_z);
	WriteCoord(MSG_BROADCAST, trace_endpos_x);
	WriteCoord(MSG_BROADCAST, trace_endpos_y);
	WriteCoord(MSG_BROADCAST, trace_endpos_z);

	LightningDamage(self.origin, trace_endpos + v_forward*4, self, 30);
};


/*
=================
Melta Gun
=================
*/
void(vector p1, vector p2, entity from, float damage) MeltaDamage =
{
	entity e1, e2;
	vector f;

	f = p2 - p1;
	normalize(f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	e1 = e2 = world;

	traceline(p1, p2, FALSE, self);
	if (trace_ent.takedamage)
	{
		particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from, damage);
		if (self.classname == "player")
		{
			if (other.classname == "player")
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	e1 = trace_ent;

	traceline(p1 + f, p2 + f, FALSE, self);
	if (trace_ent != e1 && trace_ent.takedamage)
	{
		particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from, damage);
	}
	e2 = trace_ent;

	traceline(p1 - f, p2 - f, FALSE, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		particle(trace_endpos, '0 0 100', 225, damage*4);
		T_Damage(trace_ent, from, from, damage);
	}
};

void() W_FireMeltaGun={
	vector org;

	if (time < self.attack_finished){
		return;
	}	

	if (self.ammo_cells < 1)
	{
		self.weapon = W_BestWeapon();
		W_SetCurrentAmmo();
		return;
	}

// explode if under water
	/*
	if (self.waterlevel > 1)
	{
		T_RadiusDamage(self, self, 35*self.ammo_cells, world);
		self.ammo_cells = 0;
		W_SetCurrentAmmo();
		return;
	}
	*/
	if (self.t_width < time)
	{
		sound(self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
		self.t_width = time + 0.6;
	}
	self.punchangle_x = -2;

	self.currentammo = self.ammo_cells = self.ammo_cells - MELTA_AMMO_COST;

	org = self.origin + '0 0 16';

	//traceline(org, org + v_forward*600, TRUE, self);
	traceline(org, org + v_forward*400, TRUE, self);

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity(MSG_BROADCAST, self);
	WriteCoord(MSG_BROADCAST, org_x);
	WriteCoord(MSG_BROADCAST, org_y);
	WriteCoord(MSG_BROADCAST, org_z);
	WriteCoord(MSG_BROADCAST, trace_endpos_x);
	WriteCoord(MSG_BROADCAST, trace_endpos_y);
	WriteCoord(MSG_BROADCAST, trace_endpos_z);

	MeltaDamage(self.origin, trace_endpos + v_forward*4, self, MELTA_DMG);

	self.attack_finished = time + 1.0;
};

//=============================================================================


void() GrenadeExplode =
{
	T_RadiusDamage(self, self.owner, 120, world);

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);

	BecomeExplosion();
};

void() GrenadeTouch =
{
	if (other == self.owner)
		return; // don't explode on owner
	if (other.takedamage == DAMAGE_AIM)
	{
		GrenadeExplode();
		return;
	}
	sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM); // bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

/*
================
W_FireGrenade
================
*/
void() W_FireGrenade =
{
	entity missile;

	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;

	sound(self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "grenade";

// set missile speed

	makevectors(self.v_angle);

	if (self.v_angle_x)
		missile.velocity = v_forward*600 + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		missile.velocity = aim(self, 10000);
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);

	missile.touch = GrenadeTouch;

// set missile duration
	missile.nextthink = time + 2.5;
	missile.think = GrenadeExplode;

	setmodel(missile, "progs/grenade.mdl");
	setsize(missile, '0 0 0', '0 0 0');
	setorigin(missile, self.origin);

	missile.weapon_str = self.weapon_str;
	missile.weapon_ap = self.weapon_ap;
	missile.weapon_dmg = self.weapon_dmg;
};


//=============================================================================

void() spike_touch;
void() superspike_touch;


/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
void(vector org, vector dir) launch_spike =
{
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);

	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel(newmis, "progs/spike.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(newmis, org);

	newmis.velocity = dir * 1000;
};

void() W_FireSuperSpikes =
{
	vector dir;

	sound(self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;
	self.currentammo = self.ammo_nails = self.ammo_nails - 2;
	dir = aim(self, 1000);
	launch_spike(self.origin + '0 0 16', dir);
	newmis.touch = superspike_touch;
	setmodel(newmis, "progs/s_spike.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	self.punchangle_x = -2;
};

void(float ox) W_FireSpikes =
{
	vector dir;

	makevectors(self.v_angle);

	if (self.ammo_nails >= 2 && self.weapon == IT_SUPER_NAILGUN)
	{
		W_FireSuperSpikes();
		return;
	}

	if (self.ammo_nails < 1)
	{
		self.weapon = W_BestWeapon();
		W_SetCurrentAmmo();
		return;
	}

	sound(self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;
	self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	dir = aim(self, 1000);
	launch_spike(self.origin + '0 0 16' + v_right*ox, dir);

	self.punchangle_x = -2;
};



.float hit_z;
void() spike_touch =
{
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return; // trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood(9);
		T_Damage(other, self, self.owner, 9);
	}
	else
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);

		if (self.classname == "wizspike")
			WriteByte(MSG_BROADCAST, TE_WIZSPIKE);
		else if (self.classname == "knightspike")
			WriteByte(MSG_BROADCAST, TE_KNIGHTSPIKE);
		else
			WriteByte(MSG_BROADCAST, TE_SPIKE);
		WriteCoord(MSG_BROADCAST, self.origin_x);
		WriteCoord(MSG_BROADCAST, self.origin_y);
		WriteCoord(MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};

void() superspike_touch =
{
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return; // trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood(18);
		T_Damage(other, self, self.owner, 18);
	}
	else
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord(MSG_BROADCAST, self.origin_x);
		WriteCoord(MSG_BROADCAST, self.origin_y);
		WriteCoord(MSG_BROADCAST, self.origin_z);
	}

	remove(self);
};

/*
===============
Autogun and Stubber
===============
*/
void() stub_touch =
{
	vector org;

	if (other == self.owner)
		return; // don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
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

void(vector org, vector vec, float hvy) launch_stub =
{
	if (self.classname == "monster_enforcer")
		sound(self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);

	vec = normalize(vec);

	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;

	setmodel(newmis, "progs/s_spike.mdl");
	setsize(newmis, '0 0 0', '0 0 0');

	setorigin(newmis, org);

	newmis.velocity = vec * 600;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 5;
	newmis.think = SUB_Remove;
	newmis.touch = stub_touch;

	newmis.weapon_str = self.weapon_str;
	newmis.weapon_ap = self.weapon_ap;
	newmis.weapon_dmg = self.weapon_dmg;
};



void() W_FireAutogun =
{
	vector org;

	self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors(self.angles);

	org = self.origin + v_forward * 30 + v_right * 8.5 + '0 0 16';

	launch_stub(org, self.enemy.origin - self.origin, FALSE);
};

void() W_FireHvyStub =
{
	vector org;

	self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors(self.angles);

	org = self.origin + v_forward * 30 + v_right * 8.5 + '0 0 16';

	launch_stub(org, self.enemy.origin - self.origin, TRUE);
};


void() bolt_touch;
void() heavy_bolter_touch;

/*
===============
launch_bolt_round

Used for both the player and the ogre
===============
*/
void(vector org, vector dir) launch_bolt_rnd =
{
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);

	newmis.touch = bolt_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel(newmis, "progs/missile.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(newmis, org);

	newmis.velocity = dir * 850;	//1000

	newmis.weapon_str = self.weapon_str;
	newmis.weapon_ap = self.weapon_ap;
	newmis.weapon_dmg = self.weapon_dmg;
};

void() W_FireHeavyBolter =
{
	vector dir;

	if (time < self.attack_finished)
	{
		return;
	}
	if (self.ammo_rockets < 1)
	{
		self.weapon = W_BestWeapon();
		W_SetCurrentAmmo();
		return;
	}

	sound(self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	self.attack_finished = time + HVYBOLT_ROF;

	self.currentammo = self.ammo_rockets = self.ammo_rockets - HVYBOLT_AMMO_COST;

	dir = aim(self, 1000);
	
	launch_bolt_rnd(self.origin + '0 0 16', dir);
	newmis.items = 0 | IT_HVY_BOLTER;
	
	newmis.touch = heavy_bolter_touch;

	setmodel(newmis, "progs/missile.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	self.punchangle_x = crandom() * 0.5;
	self.punchangle_y = crandom() * 0.5;
	self.punchangle_z = crandom() * 0.5;
};

void() W_FireBoltgun =
{

	vector dir;

	if (time < self.attack_finished)
	{
		return;
	}

	if (self.ammo_nails < 1)
	{
		self.weapon = W_BestWeapon();
		W_SetCurrentAmmo();
		return;
	}

	sound(self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	self.attack_finished = time + BOLTGUN_ROF;
	
	self.currentammo = self.ammo_nails = self.ammo_nails - BOLTGUN_AMMO_COST;

	dir = aim(self, 1000);
	
	launch_bolt_rnd(self.origin + '0 0 16', dir);
	
	newmis.items = 0 | IT_BOLTGUN;
	newmis.touch = bolt_touch;

	setmodel(newmis, "progs/missile.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	self.punchangle_x = -0.3;
};

void(float ox) W_FireBolt =
{
	vector dir;

	makevectors(self.v_angle);

	if ( self.weapon == IT_SUPER_NAILGUN && self.ammo_rockets > 0)
	{
		//W_FireSuperSpikes();
		W_FireHeavyBolter();
		return;
	}
	if (self.weapon == IT_SHOTGUN && self.ammo_nails > 0)
	{
		W_FireBoltgun();
		return;
	}

	if (time < self.attack_finished)
	{
		return;
	}
	if (self.ammo_nails < 1)
	{
		self.weapon = W_BestWeapon();
		W_SetCurrentAmmo();
		return;
	}

	sound(self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	self.attack_finished = time + TEMPEST_ROF;
	self.currentammo = self.ammo_nails = self.ammo_nails - TEMPEST_AMMO_COST;
	dir = aim(self, 1000);
	launch_bolt_rnd(self.origin + '0 0 16' + v_right*ox, dir);
	newmis.items = 0 | IT_TEMPEST_BOLTER;

	self.punchangle_x = -0.67;
	self.punchangle_y = ox * 0.05;
};


void() bolt_touch =
{
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return; // trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

// hit something that bleeds
	if (other.takedamage)
	{
		if((self.items & IT_BOLTGUN)){
			spawn_touchblood(9);
			T_Damage(other, self, self.owner, BOLTGUN_DMG);
		}
		else{
			spawn_touchblood(9);
			T_Damage(other, self, self.owner, TEMPEST_DMG);
		}
	}
	else
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_SPIKE);
		WriteCoord(MSG_BROADCAST, self.origin_x);
		WriteCoord(MSG_BROADCAST, self.origin_y);
		WriteCoord(MSG_BROADCAST, self.origin_z);
	}
	//remove(self);
	BecomeExplosion();
};

void() heavy_bolter_touch =
{
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return; // trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood(18);
		T_Damage(other, self, self.owner, HVYBOLT_DMG);
	}
	else
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord(MSG_BROADCAST, self.origin_x);
		WriteCoord(MSG_BROADCAST, self.origin_y);
		WriteCoord(MSG_BROADCAST, self.origin_z);
		//remove(self);
		BecomeExplosion();
	}
	//remove(self);
	BecomeExplosion();

};


/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void() W_SetCurrentAmmo =
{
	player_run(); // get out of any weapon firing states

	self.items = self.items - (self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS));

	if (self.weapon == IT_AXE)
	{
		self.currentammo = 0;
		self.weaponmodel = "progs/v_axe.mdl";
		self.weaponframe = 0;

		//weapon stats - CHAINAXE
		self.weapon_str = self.strength + CHAINAXE_STR;
		self.weapon_ap = CHAINAXE_AP;
		self.weapon_dmg = CHAINAXE_DMG;
		//------------------------------------

	}
	else if (self.weapon == IT_SHOTGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_shot.mdl";
		self.weaponframe = 0;
			
		// Ranged weapon stats - BOLT PISTOL
		self.items = self.items | IT_NAILS;
		self.weapon_str = BOLTGUN_STR;
		self.weapon_ap = BOLTGUN_AP;
		self.weapon_dmg = BOLTGUN_DMG;
		//------------------------------------

	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_SHELLS;
			
		// Ranged weapon stats - SPACE SHOTGUN
		self.weapon_str = ASTSHOTG_STR;
		self.weapon_ap = ASTSHOTG_AP;
		self.weapon_dmg = ASTSHOTG_DMG;
		//------------------------------------

	}
	else if (self.weapon == IT_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail.mdl";
		self.weaponframe = 0;

		// Ranged weapon stats - BOLTGUN
		self.items = self.items | IT_NAILS;
		self.weapon_str = TEMPEST_STR;
		self.weapon_ap = TEMPEST_AP;
		self.weapon_dmg = TEMPEST_DMG;
		//------------------------------------

	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_nail2.mdl";
		self.weaponframe = 0;

		// Ranged weapon stats - HEAVY BOLTER
		self.items = self.items | IT_ROCKETS;
		self.weapon_str = HVYBOLT_STR;
		self.weapon_ap = HVYBOLT_AP;
		self.weapon_dmg = HVYBOLT_DMG;
		//------------------------------------

	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_rock.mdl";
		self.weaponframe = 0;

		// Ranged weapon stats - IONIZED GUN
		self.items = self.items | IT_CELLS;
		self.weapon_str = PLASMA_STR;
		self.weapon_ap = PLASMA_AP;
		self.weapon_dmg = PLASMA_DMG;
		//------------------------------------

	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;

		// Ranged weapon stats - HE ROCKET
		self.weapon_str = ROCKET_STR;
		self.weapon_ap = ROCKET_AP;
		self.weapon_dmg = ROCKET_DMG;
		//------------------------------------

	}
	else if (self.weapon == IT_LIGHTNING)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_light.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_CELLS;

		// Ranged weapon stats - HEAT RAY
		self.weapon_str = MELTA_STR;
		self.weapon_ap = MELTA_AP;
		self.weapon_dmg = MELTA_DMG;
		//------------------------------------
	}
	else
	{
		self.currentammo = 0;
		self.weaponmodel = "";
		self.weaponframe = 0;

		// Ranged weapon stats 
		self.weapon_str = 1;
		self.weapon_ap = 0;
		self.weapon_dmg = 1;
		//------------------------------------

	}
};

float() W_BestWeapon =
{
	float it;

	it = self.items;

	if (self.ammo_cells >= 1 && (it & IT_LIGHTNING) && self.waterlevel > 1)
		return IT_LIGHTNING;
	else if (self.ammo_nails >= 2 && (it & IT_SUPER_NAILGUN))
		return IT_SUPER_NAILGUN;
	else if (self.ammo_shells >= 2 && (it & IT_SUPER_SHOTGUN))
		return IT_SUPER_SHOTGUN;
	else if (self.ammo_nails >= 1 && (it & IT_NAILGUN))
		return IT_NAILGUN;
	else if (self.ammo_shells >= 1 && (it & IT_SHOTGUN))
		return IT_SHOTGUN;

/*
	if (self.ammo_rockets >= 1 && (it & IT_ROCKET_LAUNCHER))
		return IT_ROCKET_LAUNCHER;
	else if (self.ammo_rockets >= 1 && (it & IT_GRENADE_LAUNCHER))
		return IT_GRENADE_LAUNCHER;

*/

	return IT_AXE;
};

float() W_CheckNoAmmo =
{
	if (self.currentammo > 0)
		return TRUE;

	if (self.weapon == IT_AXE)
		return TRUE;

	self.weapon = W_BestWeapon();

	W_SetCurrentAmmo();

// drop the weapon down
	return FALSE;
};

/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void() player_axe1;
void() player_axeb1;
void() player_axec1;
void() player_axed1;
void() player_shot1;
void() player_nail1;
void() player_light1;
void() player_rocket1;

void() W_Attack =
{
	float r;

	if (!W_CheckNoAmmo())
		return;

	makevectors(self.v_angle); // calculate forward angle for velocity
	self.show_hostile = time + 1; // wake monsters up

	if (self.weapon == IT_AXE)
	{
		//sound(self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
		precache_sound("ogre/ogsawatk.wav");
		sound(self, CHAN_WEAPON, "ogre/ogsawatk.wav", 1, ATTN_NORM);
		r = random();
		if (r < 0.25)
			player_axe1();
		else if (r<0.5)
			player_axeb1();
		else if (r<0.75)
			player_axec1();
		else
			player_axed1();
		self.attack_finished = time + CHAINAXE_ROF;
	}
	else if (self.weapon == IT_SHOTGUN)
	{
		//player_shot1();
		//W_FireShotgun();
		//self.attack_finished = time + 0.5;
		player_nail1();
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		player_shot1();
		W_FireSuperShotgun();
		self.attack_finished = time + ASTSHOTG_ROF;
	}
	else if (self.weapon == IT_NAILGUN)
	{
		player_nail1();
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		player_nail1();

	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		player_rocket1();
		W_FirePlasma();
		self.attack_finished = time + PLASMA_ROF;
		//W_FireGrenade();
		//self.attack_finished = time + 0.6;
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		player_rocket1();
		W_FireRocket();
		self.attack_finished = time + ROCKET_ROF;
	}
	else if (self.weapon == IT_LIGHTNING)
	{
		player_light1();
		sound(self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
		self.attack_finished = time + MELTA_ROF;
	}
};

/*
============
W_ChangeWeapon

============
*/
void() W_ChangeWeapon =
{
	float it, am, fl;

	it = self.items;
	am = 0;

	if (self.impulse == 1)
	{
		fl = IT_AXE;
	}
	else if (self.impulse == 2)
	{
		fl = IT_SHOTGUN;
		if (self.ammo_shells < 1)
			am = 1;
	}
	else if (self.impulse == 3)
	{
		fl = IT_SUPER_SHOTGUN;
		if (self.ammo_shells < 2)
			am = 1;
	}
	else if (self.impulse == 4)
	{
		fl = IT_NAILGUN;
		if (self.ammo_nails < 1)
			am = 1;
	}
	else if (self.impulse == 5)
	{
		fl = IT_SUPER_NAILGUN;
		if (self.ammo_nails < 2)
			am = 1;
	}
	else if (self.impulse == 6)
	{
		fl = IT_GRENADE_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (self.impulse == 7)
	{
		fl = IT_ROCKET_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (self.impulse == 8)
	{
		fl = IT_LIGHTNING;
		if (self.ammo_cells < 1)
			am = 1;
	}

	self.impulse = 0;

	if (!(self.items & fl))
	{ // don't have the weapon or the ammo
		sprint(self, "no weapon.\n");
		return;
	}

	if (am)
	{ // don't have the ammo
		sprint(self, "not enough ammo.\n");
		return;
	}

//
// set weapon, set ammo
//
	self.weapon = fl;
	W_SetCurrentAmmo();
};

/*
============
CheatCommand
============
*/
void() CheatCommand =
{
	if (deathmatch || coop)
		return;

	self.ammo_rockets = 100;
	self.ammo_nails = 200;
	self.ammo_shells = 100;
	self.items = self.items |
		IT_AXE |
		IT_SHOTGUN |
		IT_SUPER_SHOTGUN |
		IT_NAILGUN |
		IT_SUPER_NAILGUN |
		IT_GRENADE_LAUNCHER |
		IT_ROCKET_LAUNCHER |
		IT_KEY1 | IT_KEY2;

	self.ammo_cells = 200;
	self.items = self.items | IT_LIGHTNING;

	self.weapon = IT_ROCKET_LAUNCHER;
	self.impulse = 0;
	W_SetCurrentAmmo();
};

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
	float it, am;

	it = self.items;
	self.impulse = 0;

	while (1)
	{
		am = 0;

		if (self.weapon == IT_LIGHTNING)
		{
			self.weapon = IT_AXE;
		}
		else if (self.weapon == IT_AXE)
		{
			self.weapon = IT_SHOTGUN;
			if (self.ammo_shells < 1)
				am = 1;
		}
		else if (self.weapon == IT_SHOTGUN)
		{
			self.weapon = IT_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_SHOTGUN)
		{
			self.weapon = IT_NAILGUN;
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (self.weapon == IT_NAILGUN)
		{
			self.weapon = IT_SUPER_NAILGUN;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_NAILGUN)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			self.weapon = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			self.weapon = IT_LIGHTNING;
			if (self.ammo_cells < 1)
				am = 1;
		}

		if ((self.items & self.weapon) && am == 0)
		{
			W_SetCurrentAmmo();
			return;
		}
	}
};

void() CycleWeaponBack =
{
	float it, am;

	it = self.items;
	self.impulse = 0;

	while (1)
	{
		am = 0;

		if (self.weapon == IT_SHOTGUN)
		{
			self.weapon = IT_AXE;
		}
		else if (self.weapon == IT_SUPER_SHOTGUN)
		{
			self.weapon = IT_SHOTGUN;
			if (self.ammo_shells < 1)
				am = 1;
		}
		else if (self.weapon == IT_NAILGUN)
		{
			self.weapon = IT_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_NAILGUN)
		{
			self.weapon = IT_NAILGUN;
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			self.weapon = IT_SUPER_NAILGUN;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_LIGHTNING)
		{
			self.weapon = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_AXE)
		{
			self.weapon = IT_LIGHTNING;
			if (self.ammo_cells < 1)
				am = 1;
		}

		if ((self.items & self.weapon) && am == 0)
		{
			W_SetCurrentAmmo();
			return;
		}
	}

};

/*
============
ServerflagsCommand

Just for development
============
*/
void() ServerflagsCommand =
{
	serverflags = serverflags * 2 + 1;
};

void() QuadCheat =
{
	if (deathmatch || coop)
		return;
	self.super_time = 1;
	self.super_damage_finished = time + 30;
	self.items = self.items | IT_QUAD;
	dprint("quad cheat\n");
};

/*
============
ImpulseCommands

============
*/
void() ImpulseCommands =
{
	if (self.impulse >= 1 && self.impulse <= 8)
		W_ChangeWeapon();

	if (self.impulse == 9)
		CheatCommand();
	if (self.impulse == 10)
		CycleWeaponCommand();
	if (self.impulse == 11)
		ServerflagsCommand();
	if (self.impulse == 12)
		CycleWeaponBack();

	if (self.impulse == 255)
		QuadCheat();

	self.impulse = 0;
};

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{
	if (time < self.attack_finished)
		return;

	ImpulseCommands();

// check for attack
	if (self.button0)
	{
		SuperDamageSound();
		W_Attack();
	}
};

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void() SuperDamageSound =
{
	if (self.super_damage_finished > time)
	{
		if (self.super_sound < time)
		{
			self.super_sound = time + 1;
			sound(self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
	return;
};


