
# 40Quake:Nailgun edition

In the dark grimness of the retro-fps, 1...void...ranger must purge our dimension of a hostile invasion.

## features?
### Weapons
+ Axe -> Chain Axe
+ Shotgun -> Boltgun
+ Super Shot -> Scattergun
+ Nailgun -> Tempest Bolter
+ Super Nail -> Heavy Bolter
+ Grenade Launcher -> Plasma Gun
+ Lightning -> Meltagun

### Damage mechanics
+ Tabletop-based stats for monsters and weapons.
+ T_Damage does rules-based check with dice rolls for damage, heh.

### Mobs
+ Mobs re-done to fit mechanics and themes, rebalanced too.

### Items
+ Armor I - +1 Toughness for player armor saves.
+ Armor II - +1 Armor save, improving odds of ignoring damage.
+ Armor III - +1 Invuln save, better survive heavy attacks.
+ Health - regain lost wounds.
+ Ammo - 4 types:
  + Small - bolt rounds and shells.
  + Bolter - bolt rounds.
  + Heavy - ammo for Hvy Bolter and Rocket launcher.
  + Cells - Plasma and Melta gun ammo.

### Credit
+ Source code based on the great https://github.com/shpuld/id1-quakec-cleaned

### Cleaned up Quake id1 v1.01 QuakeC source

This is just the QuakeC source for vanilla Quake for modders to use.

Because of vagueness with licensing, Quake 1.06 source isn't necessarily a good place to start from, it did not come with any license attached. Meanwhile 1.01 is more explicitely released under GPL in the Quake-Tools source release by id software: https://github.com/id-Software/Quake-Tools

Anyone who has done QuakeC programming knows how messy the codebase is, and that there's some known bugs there too. While I've avoided changing the code behavior, I've done a lot of very basic clean up and fixed more harmless bugs (Rotfish monster count anyone?). The major changes from v1.06 have been redone here, but there's a few multiplayer specific things in v1.06 that are not in this release (mostly killmessages). 

My changes done to the codebase compared to 1.01:
- Eliminate all warnings that FTEQCC gives it
- Fix parm7 not being set to 0 properly in SetNewParms (cells) (like in v1.06)
- Remove DumpScore (like in v1.06)
- Prioritize other kill messages over liquid deaths(so monster killing you in water doesn't print drowning message) (like in v1.06)
- Add prev weapon command (like in v1.06)
- Fix fish monster count
- Remove all of the "local" keywords that are not used by any relevant compiler (if your compiler refuses to compile without it, use a newer compiler)
- Lots of automatic and manual syntax cleanup
  - Consistent spacing for frame macros
  - Consistent use of whitespace
  - Consistent spacing around and inside () and {}
  - Try to eliminate mixed indentation (using 4-size tabs as suggested by original sources)
