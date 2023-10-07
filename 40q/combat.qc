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

void() T_MissileTouch;
void() info_player_start;
void(entity targ, entity attacker) ClientObituary;

void() monster_death_use;

void(entity t) sfx_armor_save={

	float r;

	r = random();
	if(r < 0.34)
		sound(t, CHAN_AUTO, "weapons/ric1.wav", 1, ATTN_NORM);
	else if(r < 0.68)
		sound(t, CHAN_AUTO, "weapons/ric2.wav", 1, ATTN_NORM);
	else
		sound(t, CHAN_AUTO, "weapons/ric3.wav", 1, ATTN_NORM);
};
//============================================================================

/*
============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============
*/
float(entity targ, entity inflictor) CanDamage =
{
// bmodels need special checking because their origin is 0,0,0
	if (targ.movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), TRUE, self);
		if (trace_fraction == 1)
			return TRUE;
		if (trace_ent == targ)
			return TRUE;
		return FALSE;
	}

	traceline(inflictor.origin, targ.origin, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;

	return FALSE;
};


/*
============
Killed
============
*/
void(entity targ, entity attacker) Killed =
{
	entity oself;

	oself = self;
	self = targ;

	if (self.health < -99)
		self.health = -99; // don't let sbar look bad if a player

	if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE)
	{ // doors, triggers, etc
		self.th_die();
		self = oself;
		return;
	}

	self.enemy = attacker;

// bump the monster counter
	if (self.flags & FL_MONSTER)
	{
		if (self.glow_trail)
		{
			self.glow_trail = FALSE;
		}
		if (self.axhitme)
		{
			self.health = -99;
		}
		killed_monsters = killed_monsters + 1;
		WriteByte(MSG_ALL, SVC_KILLEDMONSTER);
	}

	ClientObituary(self, attacker);

	self.takedamage = DAMAGE_NO;
	self.touch = SUB_Null;

	monster_death_use();
	self.th_die();

	self = oself;
};

float(entity t, entity inflict, float dmg) tabletop_damage={

	float wepStr;
	float wepAp;
	float wepDmg;

	float roll;
	float toWound;
	float hits;
	float armorSv;
	float calcDmg;

	wepStr = inflict.weapon_str;
	wepAp = inflict.weapon_ap;
	wepDmg = inflict.weapon_dmg;

	toWound = 4;
	if(wepStr > t.toughness)
	{
		toWound = 3;
		if(wepStr >= t.toughness * 2){
			toWound = 2;
		}
	}
	else
	{
		toWound = 5;
		if(wepStr <= t.toughness / 2){
			toWound = 6;
		}
	}
	roll = ceil(1.0 + (random() * 5.0));

	if(roll >= toWound){
		if(t.armor_save || t.invuln_save){
			roll = ceil(1.0 + (random() * 5.0));
			armorSv = roll + wepAp;

			if(armorSv >= t.armor_save){
				//successful armor save.
				sfx_armor_save(t);
				return 0.0;
			}
			else{
				if(t.invuln_save && roll >= t.invuln_save){
					//successful armor save.
					sfx_armor_save(t);
					return 0.0;
				}
				else{
					//take wounds from weapon dmg
					t.wounds = t.wounds - wepDmg;
					if(t.wounds <= 0 ){
						return t.max_health * (1.0 + random() * 0.5);
					}
					else{
						return  wepDmg * 50;
					}
				}
			}
		}
		else{
			//no armor save, take pure damage
			return wepDmg * 50;

		}
	}
	else{
		//failed to wound, do chip damage.
		sfx_armor_save(t);
		return 0.0;
	}
};

/*
============
T_Damage

The damage is coming from inflictor, but get mad at attacker
This should be the only function that ever reduces health.
============
*/
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage=
{
	vector dir;
	entity oldself;
	float save;
	float take;

	float wepStr;
	float wepAp;
	float wepDmg;
	float trgTough;

	if (!targ.takedamage)
		return;

// used by buttons and triggers to set activator for target firing
	damage_attacker = attacker;
	wepStr = inflictor.weapon_str;
	wepAp = inflictor.weapon_ap;
	wepDmg = inflictor.weapon_dmg;
	trgTough = targ.toughness;

	//TODO - adjust quad to match new system
// check for quad damage powerup on the attacker
	if (attacker.super_damage_finished > time)
	{
		damage = damage * 2;
		wepStr = wepStr * 2;
		wepAp = wepAp - 1;
		wepDmg = wepDmg * 2;
	}

//40Q - MECHANICS CHECK:-------------------------------------------------
	//Player Axe-hitting protection time, balances being able to melee
	if((targ.flags & FL_CLIENT) && !(attacker.flags & FL_CLIENT)){
		if(time < targ.timer_axe_hit){
			damage = damage * 0.33;
			wepDmg = wepDmg * 0.33;
		}
	}
	if(targ.toughness && inflictor.weapon_str)
	{
		if(skill == 4)
		{
			take = tabletop_damage(targ, inflictor, damage); 
		}
		else
		{
			if(targ.axe_extra_dmg && targ.axhitme)
			{
				wepDmg = wepDmg * 2;
			}
			take = damage;
			if(wepStr > trgTough)
			{
				take = wepDmg * 1.33;
				inflictor.dmg_result = DMG_RESULT_HIGH;
				if(wepStr >= trgTough * 2)
				{
					take = wepDmg * 1.67;
					inflictor.dmg_result = DMG_RESULT_V_HIGH;
					if(wepStr >= trgTough * 3)
					{
						take = wepDmg * 2;
					}
				}
			}
			else
			{
				take = wepDmg * 0.67;
				inflictor.dmg_result = DMG_RESULT_LOW;
				if(wepStr <= trgTough / 2)
				{
					take = wepDmg * 0.33;
					inflictor.dmg_result = DMG_RESULT_V_LOW;
				}
			}
		}
	}
	else{
		take = damage;
	}

	//40Q ARMOR CALC
	if(targ.armortype != 0){
		if(skill > 2)
			save = ceil(damage * take/damage * 0.5);
		else
			save = ceil(damage * take/damage * 0.33);
		
		take = take - save;
		if(save){
			targ.armorvalue = targ.armorvalue - save;
			if(targ.armorvalue <= 0.0)
			{
				targ.armorvalue = 0;
				targ.armortype = 0;
				targ.toughness = targ.toughness_set;
				targ.items = targ.items - (targ.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
			}
			else
			{
				if((targ.items & IT_ARMOR3) && targ.armorvalue < 151)
				{
					targ.items = targ.items - (targ.items &  IT_ARMOR3);
					targ.toughness = targ.toughness - 1;
					targ.melee_str = targ.melee_str - 1;
				}
				else if((targ.items & IT_ARMOR2) && targ.armorvalue < 101)
				{
					targ.items = targ.items - (targ.items &  IT_ARMOR2);
					targ.toughness = targ.toughness - 1;
					targ.melee_str = targ.melee_str - 1;
				}
				else if((targ.items & IT_ARMOR1) && targ.armorvalue < 50)
				{
					targ.items = targ.items - (targ.items &  IT_ARMOR1);
					targ.toughness = targ.toughness - 1;
				}
			}
		}
	}
	inflictor.dmg_out = take;
//-----------------------------------------------------------------------


//DISABLED Q! armor checks
// save damage based on the target's armor level
/*
	save = ceil(targ.armortype*damage);
	if (save >= targ.armorvalue)
	{
		save = targ.armorvalue;
		targ.armortype = 0; // lost all armor
		targ.items = targ.items - (targ.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
	}

	targ.armorvalue = targ.armorvalue - save;
	take = ceil(damage-save);
*/
//-==================================================================================

// add to the damage total for clients, which will be sent as a single
// message at the end of the frame
// FIXME: remove after combining shotgun blasts?
	if (attacker.classname == "monster_shambler")
	{
		dprint(strcat("damage: ", ftos(damage), "\n"));	//debug)
		dprint(strcat("dmg: ", ftos(take), "\n"));	//debug)
	}
	if (targ.flags & FL_CLIENT)
	{
		targ.dmg_take = targ.dmg_take + take;
		targ.dmg_save = targ.dmg_save + save;
		targ.dmg_inflictor = inflictor;
	}

// figure momentum add
	if ((inflictor != world) && (targ.movetype == MOVETYPE_WALK))
	{
		dir = targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
		dir = normalize(dir);
		targ.velocity = targ.velocity + dir*take*8;
	}
	if((targ.flags & FL_MONSTER) && !(targ.flags & FL_DEMON)){
		if(time > targ.hinder_cool){
			targ.hinder_time = time + ((wepStr / 10) * 2);
			targ.hinder_cool = time + (4 - skill);
		}
	}

// check for godmode or invincibility
	if (targ.flags & FL_GODMODE)
		return;
	if (targ.invincible_finished >= time)
	{
		if (self.invincible_sound < time)
		{
			sound(targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
			self.invincible_sound = time + 2;
		}
		return;
	}

// team play damage avoidance
	if ((teamplay == 1) && (targ.team > 0)&&(targ.team == attacker.team))
		return;

// do the damage
	targ.health = targ.health - take;

	if (targ.health <= 0)
	{
		Killed(targ, attacker);
		return;
	}

// react to the damage
	oldself = self;
	self = targ;

	/*
	if ((self.flags & FL_MONSTER) && attacker != world)
	{
	// get mad unless of the same class(except for soldiers)
		if (self != attacker && attacker != self.enemy)
		{
			if ((self.classname != attacker.classname) || (self.classname == "monster_army" ))
			{
				if (self.enemy.classname == "player")
					self.oldenemy = self.enemy;
				self.enemy = attacker;
				FoundTarget();
			}
		}
	}
	*/
	//40Q - MONSTER INFIGHTING--------------------------------------------------
	if ((self.flags & FL_MONSTER) && attacker != world)
	{
		if ((self.flags & FL_DEMON))
		{
			if (self.alpha > 0.67)
			{
				self.alpha = self.health / self.max_health;
			}
		}
		if (self != attacker && attacker != self.enemy)
		{
			if( ((self.flags & FL_DEMON) && !(attacker.flags & FL_DEMON)) || (attacker.flags & FL_CLIENT))
			{
				self.oldenemy = self.enemy;
				self.enemy = attacker;
				FoundTarget();
			}
		}
	}
	//--------------------------------------------------------------------------
	if (self.th_pain)
	{
		if((self.flags & FL_MONSTER))
		{
			if(self.axhitme)
			{
				self.nextthink = time + 0.2;	
			}
		}
		else
		{
			self.th_pain(attacker, take);
			self.axhitme = FALSE;	
		// nightmare mode monsters don't go into pain frames often
			if (skill == 3)
				self.pain_finished = time + 5;
		}
	}

	self = oldself;
};

/*
============
T_RadiusDamage
============
*/
void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage =
{
	float points;
	entity head;
	vector org;

	head = findradius(inflictor.origin, damage+40);

	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage)
			{
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = 0.5*vlen(inflictor.origin - org);
				if (points < 0)
					points = 0;
				points = damage - points;
				if (head == attacker)
					points = points * 0.5;
				if (points > 0)
				{
					if (CanDamage(head, inflictor))
					{ // shambler takes half damage from all explosions
						//if (head.classname == "monster_shambler")
						//	T_Damage(head, inflictor, attacker, points*0.5);
						//else
						//	T_Damage(head, inflictor, attacker, points);
						if(head != inflictor.owner)
							T_Damage(head, inflictor, attacker, points);
					}
				}
			}
		}
		head = head.chain;
	}
};

/*
============
T_BeamDamage
============
*/
void(entity attacker, float damage) T_BeamDamage =
{
	float points;
	entity head;

	head = findradius(attacker.origin, damage+40);

	while (head)
	{
		if (head.takedamage)
		{
			points = 0.5*vlen(attacker.origin - head.origin);
			if (points < 0)
				points = 0;
			points = damage - points;
			if (head == attacker)
				points = points * 0.5;
			if (points > 0)
			{
				if (CanDamage(head, attacker))
				{
					if (head.classname == "monster_shambler")
						T_Damage(head, attacker, attacker, points*0.5);
					else
						T_Damage(head, attacker, attacker, points);
				}
			}
		}
		head = head.chain;
	}
};