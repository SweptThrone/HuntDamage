# Hunt Damage
Various damage types and system used in Hunt: Showdown recreated in Garry's Mod.  
⚠️ This addon was never finished and was not tested enough.  I'm releasing it anyway with some notices.  

## What is this?
Hunt Damage recreates the damage types and effects (bleeding, poison, burning) from Hunt: Showdown in Garry's Mod.  It also provides functions for developers to make their own things that inflict these effects.  

## How do I use it?
Drop the HuntDamage_addon folder into your addons folder.  Connecting clients will need the 196 KB sound/huntdmg/bandageloop.wav file.  
This file is included in this Workshop addon: https://steamcommunity.com/sharedfiles/filedetails/?id=3001917957  

## Important notices
This addon was not tested enough, may be missing features, and may not be terribly efficient.  You're encouraged to contribute and/or report issues.  
If a player has armor and starts bleeding or burning, this addon will near-instantly shred all of their armor.  I didn't know how I wanted to handle this, so I didn't.  

## Brief documentation
void Player:Bleed( Entity attacker, number tier )  
- Makes the player start bleeding at tier `tier`, either 1, 2, or 3.  If the player dies from bleeding, `attacker` will get credit for the kill.  

void Player:StopBleeding()
- Stops the player's bleeding.  

boolean Player:IsBleeding()
- Returns whether the player is bleeding or not.  

void Player:Poison( number tier )
- Poisons the player at tier `tier`, either 1, 2, or 3.  Players cannot die from poison.  

boolean Player:IsPoisoned()
- Returns whether the player is poisoned or not.  

void Player:Burn( Entity attacker, number amount, number tier )
- Burns the player at tier `tier`, either 1, 2, or 3.  Instantly burn `amount` health.  If the player dies from burning, `attacker` will get credit for the kill.  

void Player:StopBurning()
- Stops the player's burning.  

boolean Player:IsBurning()
- Returns whether the player is burning or not.  

## Demo videos
https://www.youtube.com/watch?v=cjjqmGXGPR8  
https://www.youtube.com/watch?v=kPJ2CyDxjWs  
https://www.youtube.com/watch?v=0gfmHJMPH34  
