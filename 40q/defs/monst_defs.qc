
/*
    Monster macro / adjustments for gameplay
*/
#define M_ai_assign_mark() if((self.spawnflags&&MARK_RAGE)){self.demon_mark = MARK_RAGE;}else if((self.spawnflags&&MARK_EXCESS)){self.demon_mark = MARK_EXCESS;}else if((self.spawnflags&&MARK_DESPAIR)){self.demon_mark = MARK_DESPAIR;}else if((self.spawnflags&&MARK_TWIST)){self.demon_mark = MARK_TWIST;}

#define M_dbg_assign_mark() float r;r=random();if(r<0.25){self.demon_mark = MARK_DESPAIR;}else if(r<0.51){self.demon_mark = MARK_EXCESS;}else if(r<0.76){self.demon_mark = MARK_RAGE;}else{self.demon_mark = MARK_TWIST;}

/*
    def = 1:1
    despair = -1
    rage = 1:1
    obsess = +3
    twist = 1:1

if(self.demon_mark==MARK_DESPAIR){
    if(w-1 > 0){
        ai_walk(w-1);
    }
    else{
        ai_walk(0.5);
    }
}
else if(self.demon_mark==MARK_EXCESS){
    ai_walk(w+3);
}
else if(self.demon_mark==MARK_RAGE){
    ai_walk(w+1);
}
else if(self.demon_mark==MARK_TWIST){
    ai_walk(w+3);
}
else{
    ai_walk(w);
}

*/
#define M_ai_mark_walk(w) if(w==0){ai_walk(0);}else{if(self.demon_mark==MARK_DESPAIR){if(w-1 > 0){ai_walk(w-1);}else{ai_walk(0.5);}}else if(self.demon_mark==MARK_EXCESS){ai_walk(w+3);}else if(self.demon_mark==MARK_RAGE){ai_walk(w+1);}else if(self.demon_mark==MARK_TWIST){ai_walk(w+3);}else{ai_walk(w);}}


/*
    def = 1:1
    despair = -2
    rage = +3
    obsess = +2
    twist = 1:1
*/
#define M_ai_mark_run(r) if(r==0){ai_run(0);}else{if(self.demon_mark==MARK_DESPAIR){if(r-2 > 0){ai_run(r-2);}else{ai_run(0.5);}}else if(self.demon_mark==MARK_EXCESS){ai_run(r+2);}else if(self.demon_mark==MARK_RAGE){ai_run(r+4);}else if(self.demon_mark==MARK_TWIST){ai_run(r+1);}else{ai_run(r);}}

/*
    def = 1:1
    despair = -3
    rage = +3
    obsess = +5
    twist = +1
*/
#define M_ai_mark_charge(c) if(c==0){ai_charge(0);}else{if(self.demon_mark==MARK_DESPAIR){if(c-3 > 0){ai_charge(c-3);}else{ai_charge(0.5);}}else if(self.demon_mark==MARK_EXCESS){ai_charge(c+5);}else if(self.demon_mark==MARK_RAGE){ai_charge(c+3);}else if(self.demon_mark==MARK_TWIST){ai_charge(c+1);}else{ai_charge(c);}}


/*
    def = 20 (quake)
    despair = -7
    rage = -4
    obsess = +10
    twist = +14
*/
#define M_ai_set_yaw(y) if(self.demon_mark==MARK_DESPAIR){self.yaw_speed=y-7;}else if(self.demon_mark==MARK_EXCESS){self.yaw_speed=y+10;}else if(self.demon_mark==MARK_RAGE){self.yaw_speed=y-4;}else if(self.demon_mark==MARK_TWIST){self.yaw_speed=y+14;}

/*

*/
#define M_ai_set_name(name, desp, obses, rage, twist) if(self.demon_mark==MARK_DESPAIR){self.netname = desp;}else if(self.demon_mark==MARK_EXCESS){self.netname = obses;}else if(self.demon_mark==MARK_RAGE){self.netname = rage;}else if(self.demon_mark==MARK_TWIST){self.netname = twist;}else{self.netname = name;}

/*
    SET MARK STATS
        Despair : health + 15%
        Rage: melee str + 1
        Excess: weapon DMG + 10%
        Twist : weapon str + 1
*/
#define M_ai_mark_stat() if(self.demon_mark==MARK_DESPAIR){self.health=self.health * 1.33;self.max_health=self.health;}else if(self.demon_mark==MARK_EXCESS){self.weapon_dmg = self.weapon_dmg * 1.15;self.colormod=MARK_EXCESS_CLR;}else if(self.demon_mark==MARK_RAGE){self.melee_str = self.melee_str + 1;self.colormod=MARK_RAGE_CLR;}else if(self.demon_mark==MARK_TWIST){self.weapon_str = self.weapon_str + 1;self.health=self.health * 0.8;self.max_health=self.health;self.melee_dmg=self.melee_dmg*0.67;self.colormod=MARK_TWIST_CLR;}

#define M_ai_mark_glow() if(self.demon_mark==MARK_DESPAIR){self.glow_color=MARK_DESPAIR_CLR_8;self.glow_size=30;self.glow_trail=TRUE;}else if(self.demon_mark==MARK_EXCESS){self.glow_color=MARK_EXCESS_CLR_8;self.glow_size=30;self.glow_trail=TRUE;}else if(self.demon_mark==MARK_RAGE){self.glow_color=MARK_RAGE_CLR_8;self.glow_size=30;self.glow_trail=TRUE;}else if(self.demon_mark==MARK_TWIST){self.glow_color=MARK_TWIST_CLR_8;self.glow_size=30;self.glow_trail=TRUE;}

#define M_ai_mark_color() if(self.demon_mark==MARK_DESPAIR){self.colormod=MARK_DESPAIR_CLR;}else if(self.demon_mark==MARK_EXCESS){self.colormod=MARK_EXCESS_CLR;}else if(self.demon_mark==MARK_RAGE){self.colormod=MARK_RAGE_CLR;}else if(self.demon_mark==MARK_TWIST){self.colormod=MARK_TWIST_CLR;}

void() mark_end={

    setmodel(self, "progs/s_empt.spr");
    setorigin(self, '0 0 0');
    self.frame = 0;
    self.nextthink = -1;
};

//DEBUG
void() mark_th={

	self.last_origin = self.origin;
	
	makevectors(self.look_mob.angles);

	self.origin = self.look_mob.origin + (v_up * self.view_ofs_y) + (v_forward * self.view_ofs_z) + (v_right * -8);

	setorigin(self, self.origin - self.last_origin * frametime);

	if(self.look_mob.health <= 0)
        self.think = mark_end;
    
    self.nextthink = time + 0.2;
};

