#using scripts\codescripts\struct;

#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\shared\weapons_shared;
#using scripts\shared\array_shared;
#using scripts\shared\hud_message_shared;
#using scripts\shared\hud_util_shared;

#insert scripts\shared\shared.gsh;

#precache("shader", "compass_empcore_white");
#precache("shader", "ui_host");

#namespace clientids;

REGISTER_SYSTEM( "clientids", &__init__, undefined )
	
function __init__()
{
	callback::on_start_gametype( &init );
	callback::on_connect( &on_player_connect );
	callback::on_spawned( &on_player_spawned ); 
}

function init()
{
	level.clientid = 0;
	level.ccmMember = 0;
}

function on_player_connect()
{
	self.clientid = matchRecordNewPlayer( self );
	if ( !isdefined( self.clientid ) || self.clientid == -1 )
	{
		self.clientid = level.clientid;
		level.clientid++;
	}

    self.explosiveBullets = false;
	self.EBRadius = 400;
	self.EBDamage = 100;
	self.EBMethod = "MOD_RIFLE_BULLET";
	self.EBTroughWalls = false;
	self.weapChosen = false;
}

function toggleEB()
{
	if(!isDefined(self.gamevars["expb"]))
	{
		self.gamevars["expb"] = true;
		self thread fakeShots();
		self iprintln("EB ^2ON");
	}
	else
	{
		self.gamevars["expb"] = undefined;
		self notify("nomore"); 
		self iprintln("EB ^1OFF");
	}
}

function fakeShots() 
{
	self endon("disconnect");
	self endon("nomore");

	for(;;)
	{
		self waittill ("weapon_fired");
		forward = self getTagOrigin("j_head");
		end = vectorScale(anglestoforward(self getPlayerAngles()), 1000000);
		ExpLocation = BulletTrace( forward, end, false, self )["position"];
		RadiusDamage(ExpLocation, self.EBRadius, self.EBRadius, self.EBDamage, self);
		wait 0.05;
	}
}

function RadiusEB() //Call this to change radius of the EB
{
if(self.EBRadius < 2000)
	{
		Radius = self.EBRadius;
		self.EBRadius = (Radius + 50);
	}
else
	{
		self.EBRadius = 100;
	}
	self iprintln("EB Radius set to: ^5"+self.EBRadius);
}

function DamageEB() //Call this to change damage of the EB
{
if(self.EBDamage < 200)
	{
		Damage = self.EBDamage;
		self.EBDamage = (Damage + 50);
	}
else
	{
		self.EBDamage = 50;
	}
	self iprintln("EB Damage set to: ^5"+self.EBDamage);
}

function saveandload()
{
	if(!isDefined(self.gamevars["snl"]))
	{
		self.gamevars["snl"] = true;
        self iprintln("^2Save and Load Enabled");
        self iprintln("Crouch and Press [{+actionslot 2}] To Save");
        self iprintln("Crouch and Press [{+actionslot 1}] To Load");
        self thread dosaveandload();
	}
	else
	{
		self.gamevars["snl"] = undefined;
        self iprintln("^1Save and Load Disabled");
        self notify("SaveandLoad");
	}
}

function dosaveandload()
{
    self endon("disconnect");
    self endon("SaveandLoad");
    self.gamevars["load"] = undefined;
    for(;;)
    {
    if (self actionslottwobuttonpressed() && self GetStance() == "crouch" && self.gamevars["snl"] == true)
    {
        self.o = self.origin;
        self.a = self.angles;
        self.gamevars["load"] = true;
        self iprintln("^2Position Saved");
        wait 2;
    }
    if (self actionslotonebuttonpressed() && self GetStance() == "crouch" && self.gamevars["load"] == true && self.gamevars["snl"] == true)
    {
        self setplayerangles(self.a);
        self setorigin(self.o);
    }
    wait 0.05;
}
}

 function ToggleWeapBind()
{
	if(!isDefined(self.gamevars["twb"]))
	{
		self.gamevars["twb"] = true;
        self iprintln("^2Weapon Binds Enabled");
		self iPrintLn("[{+actionslot 1}] to get DBSR");
		self iPrintLn("[{+actionslot 2}] to get SVG-100");
		self iPrintLn("[{+actionslot 3}] to get LOCUS");
		self iPrintLn("[{+actionslot 4}] to get RSA Interdiction");
        self thread MonitorWeapons();
	}
	else
	{
		self.gamevars["twb"] = undefined;
        self iprintln("^1Weapon Binds Disabled");
        self notify("DontMonitor");
	}
}


function MonitorWeapons()
{
	self endon("disconnect");
    level endon("game_ended");
    self endon("DontMonitor");

    for(;;)
    {
	    	if(self ActionSlotOneButtonPressed())
	        {
	        	fakeweap = "baseweapon";
	        	currentWeap = self GetCurrentWeapon();
				weap = "sniper_double";

	        	if(weap == self GetCurrentWeapon())	
	        	{
					self TakeWeapon(weap);
					self GiveWeapon(GetWeapon(fakeweap));
					self TakeWeapon(GetWeapon(fakeweap));
					self giveWeapon(GetWeapon(weap));
					self switchtoweapon(getWeapon(weap));
				}
				else 
				{
					currentWeap = self GetCurrentWeapon();
					self TakeWeapon(currentWeap);
					self giveWeapon(getWeapon(weap));
					self switchtoweapon(getWeapon(weap));
				}

	        }
	        if(self ActionSlotTwoButtonPressed())
	        {
	        	weap = "sniper_powerbolt";
	        	fakeweap = "baseweapon";
	        	currentWeap = self GetCurrentWeapon();

	        	if(weap == self GetCurrentWeapon())	
	        	{
					self TakeWeapon(weap);
					self GiveWeapon(GetWeapon(fakeweap));
					self TakeWeapon(GetWeapon(fakeweap));
					self giveWeapon(GetWeapon(weap));
					self switchtoweapon(getWeapon(weap));
				}
				else
	       		{
					currentWeap = self GetCurrentWeapon();
		        	self TakeWeapon(currentWeap);
					self giveWeapon(getWeapon(weap));
					self switchtoweapon(getWeapon(weap));
	        	}
	        }
	        
	        if(self ActionSlotThreeButtonPressed())
	        {
	        	currentWeap = self GetCurrentWeapon();
	        	weap = "sniper_fastbolt";
	        	fakeweap = "baseweapon";

	        	if(weap == self GetCurrentWeapon())	
	        	{
					self TakeWeapon(weap);
					self GiveWeapon(GetWeapon(fakeweap));
					self TakeWeapon(GetWeapon(fakeweap));
					self giveWeapon(GetWeapon(weap));
					self switchtoweapon(getWeapon(weap));
				}
				else
				{	        	
		        	currentWeap = self GetCurrentWeapon();
					self takeWeapon(currentWeap);
					self giveWeapon(getWeapon(weap));
					self switchtoweapon(getWeapon(weap));
				}
	        }
	        
	        if(self ActionSlotFourButtonPressed())
	        {
	        	currentWeapon = self GetCurrentWeapon();
	        	weap = "sniper_quickscope";
	        	fakeweap = "baseweapon";

	        	if(weap == self GetCurrentWeapon())	
	        	{
					self TakeWeapon(weap);
					self GiveWeapon(GetWeapon(fakeweap));
					self TakeWeapon(GetWeapon(fakeweap));
					self giveWeapon(GetWeapon(weap));
					self switchtoweapon(getWeapon(weap));
				}
				else
				{
		        	self TakeWeapon(currentWeap);
					self giveWeapon(getWeapon(weap));
					self switchtoweapon(getWeapon(weap));
				}
        }
        wait 0.01;
    }
    wait 0.05;
}

function dropCan(gun)
{
	self GiveWeapon(getweapon(gun));
	wait 0.1;
	self DropItem(getWeapon(gun));
	self IPrintLn("^6Can Swap Dropped.");
}

function TeleBots()
{ 
	foreach(player in level.players)
	{
		if(isDefined(player.pers["isBot"])&& player.pers["isBot"])
		player setorigin(bullettrace(self gettagorigin("j_head"), self gettagorigin("j_head") + anglesToForward(self getplayerangles()) * 1000000, 0, self)["position"]);
		self iPrintlnbold("Bots ^2Teleported!");
	}
}

function func_giveRandomWeapon()
{
    weaponsList_array = strTok("pistol_standard pistol_burst pistol_fullauto shotgun_semiauto ar_standard sniper_fastbolt sniper_powerbolt ar_marksman lmg_heavy "," "); // fill this with random weapons from the game, I tried to search a array whichs stores all weapons from the game but I didn't find one!
    for(;;)
    {
        weaponPick = array::random(weaponsList_array);
        weaponPick = getWeapon(weaponPick);
        if( self hasWeapon( weaponPick ) )
            continue;
        else if ( weapons::is_primary_weapon( weaponPick ) )
            break;
        else if ( weapons::is_side_arm( weaponPick ) )
            break;
        else
            continue;
    }
    self iprintln(weaponPick.displayName);
    self iprintln(weaponPick.name);
    self TakeWeapon(self GetCurrentWeapon());
    self giveWeapon(weaponPick);
    self GiveMaxAmmo(weaponPick);
    self SwitchToWeapon(weaponPick);
}


function on_player_spawned() //This function will get called on every spawn! :) /CabCon
{
	  self.MenuFirstRun = 0;
  	  isFirstSpawn = 1;

	  	if( !self.MenuFirstRun )
	  	{
	 		self.MenuFirstRun = 1;
	  		self thread ButtonMonitor();
	  	}
}

function drawText( text, font, fontScale, x, y, color, alpha, glowColor, glowAlpha, sort )
{
  hud = self hud::createFontString( font, fontScale );
  hud setText( text );
  hud hud::setPoint( "LEFT", "TOP", x, y );
  hud.color = color;
  hud.alpha = alpha;
  hud.glowColor = glowColor;
  hud.glowAlpha = glowAlpha;
  hud.sort = sort;
  hud.alpha = alpha;
  return hud;
}

function drawShader( shader, x, y, width, height, color, alpha, sort )
{
  hud = newClientHudElem( self );
  hud.elemtype = "icon";
  hud.color = color;
  hud.alpha = alpha;
  hud.sort = sort;
  hud.children = [];
  hud hud::setParent( level.uiParent );
  hud setShader( shader, width, height );
  hud.x = x;
  hud.y = y;
  return hud;
}
function verificationToColor( status )
{
  if ( status == "Host" )
  return "^2Host";
  if ( status == "Co-Host" )
  return "^5Co-Host";
  if ( status == "Admin" )
  return "^1Admin";
  if ( status == "Verified" )
  return "^3Verified";
  if ( status == "Unverified" )
  return "^1-";
}
function changeVerificationMenu( player, verlevel )
{
  if( player.status != verlevel && !player ishost())
  { 
  player.status = verlevel;

  if( player.status == "Unverified" )
  self thread destroyMenu( player );
  else
  player ButtonMonitor();
  }
  else
  {
  if( player ishost() )
  self iprintln( "You Cannot Change The Access Level Of The Host" );
  else
  self iprintln( "Access Level For " + player.name + " Is Already Set To " + player.status );
  }
}

function giveThatGun(weap, isSpecialist, message)
{
	currentWeap = self GetCurrentWeapon();
	if(!isDefined(isSpecialist))
	{
		self TakeWeapon(currentWeap);
	}
	self giveWeapon(getWeapon(weap));
	self switchtoweapon(getWeapon(weap));

	if(isdefined(message))
	{
		tellPlayer(message);
	}

	if(isSpecialist == true)
	{
		self iPrintln("You cant press [{+weapnext}] to use this weapon.\n You have to use default specialist controls.");
	}

	if(!isdefined(self.gamevars["yesfam"]))
	{
		self SetSpawnWeapon(getWeapon(currentWeap));
	}
}

function func_godmode()
{
	if(!isDefined(self.gamevars["godmode"]))
	{
		self.gamevars["godmode"] = true;
		self enableInvulnerability(); 
		self iprintln("God Mode ^2ON");
	}
	else
	{
		self.gamevars["godmode"] = undefined;
		self disableInvulnerability(); 
		self iprintln("God Mode ^1OFF");
	}
}

function func_ufomode()
{
	if(!isDefined(self.gamevars["ufomode"]))
	{
		self thread func_activeUfo();
		self.gamevars["ufomode"] = true;
		self iPrintln("UFO Mode ^2ON");
		self iPrintln("Press [{+frag}] To Fly");
	}
	else
	{
		self notify("func_ufomode_stop");
		self.gamevars["ufomode"] = undefined;
		self iPrintln("UFO Mode ^1OFF");
	}
}
function func_activeUfo()
{
	self endon("func_ufomode_stop");
	self.Fly = 0;
	UFO = spawn("script_model",self.origin);
	for(;;)
	{
		if(self FragButtonPressed())
		{
			self playerLinkTo(UFO);
			self.Fly = 1;
		}
		else
		{
			self unlink();
			self.Fly = 0;
		}
		if(self.Fly == 1)
		{
			Fly = self.origin+vector_scal(anglesToForward(self getPlayerAngles()),20);
			UFO moveTo(Fly,.01);
		}
		wait .001;
	}
}

function vector_scal(vec, scale)
{
	vec = (vec[0] * scale, vec[1] * scale, vec[2] * scale);
	return vec;
}

function func_unlimitedAmmo()
{
	if(!isDefined(self.gamevars["ammo_weap"]))
	{
		self notify("stop_ammo");
		self thread func_ammo();
		self iPrintln("Unlimited Ammo ^2ON");
		self.gamevars["ammo_weap"] = true;
	}
	else
	{
		self notify("stop_ammo");
		self.gamevars["ammo_weap"] = undefined;
		self iPrintln("Unlimited Ammo ^1OFF");
	}
}

function func_ammo()
{
	self endon("stop_ammo");
	for(;;)
	{
			if(self.gamevars["ammo_weap"]==true)
			{	
				if ( self getcurrentweapon() != "none" )
				{
					self setweaponammostock( self getcurrentweapon(), 1337 );
					self setweaponammoclip( self getcurrentweapon(), 1337 );
				}
			}
		wait .1;
	}
}

function tellAll(message)
{
    foreach(player in level.players)
    player hud_message::hintMessage(message);
}

function tellPlayer(message)
{
    self hud_message::hintMessage(message);
}

function SpawnWithChosen()
{
	if(!isDefined(self.gamevars["yesfam"]))
	{
		self.gamevars["yesfam"] = true;
		self iprintln("Spawn with Weapon ^2ON");
	}
	else
	{
		self.gamevars["yesfam"] = undefined;
		self iprintln("Spawn with Weapon ^1OFF");
	}
}

function CreateMenu()
{
  self.bkg = drawShader( "black", 700, -30, 200, 55, ( 0, 0, 0 ), 1, 1 );
  self.bg = drawShader( "black", 200, 25, 200, 0, ( .7, .7, .7 ), 0, 1 );
  self.scroller = drawShader( "black", 185, 65, 230, 25, ( .7, .7, .7 ), 0, 1 );
  self.scrollerEmblem = drawShader( "ui_host", 87, 67, 20, 20, ( 0, .45, .01 ), 0, 1 );
  self.scrollerEmblem.foreground = true;
  
  self addMenu( "Main Menu", undefined );

  self addOpt( "Main Menu", "Main Mods", &submenu, "MainModz", "Main Mods" );
  self addMenu( "MainModz", "Main Menu" );
  self addOpt( "MainModz", "Toggle God Mode", &func_godMode);
   self addOpt( "MainModz", "Toggle Unlimited Ammo", &func_unlimitedAmmo); 
    self addOpt( "MainModz", "Save and Load", &saveandload); 
     self addOpt( "MainModz", "Toggle UFO", &func_UFOmode); 

self addOpt( "Main Menu", "Miscellaneous", &submenu, "nacced", "Miscellaneous" );
self addMenu("nacced", "Main Menu");
	self addOpt("nacced", "Toggle Weapon Binds", &toggleWeapBind); 
	self addOpt("nacced", "Drop Canswap", &dropCan, "pistol_standard"); 

self addOpt( "Main Menu", "Bot Menu", &submenu, "bots", "Bot Menu" );
self addMenu("bots", "Main Menu");
	self addOpt("bots", "Teleport Bots to Crosshairs", &teleBots); 

self addOpt( "Main Menu", "EB Settings", &submenu, "ebsetts", "EB Settings" );
	self addMenu("ebsetts", "Main Menu");
	self addOpt("ebsetts", "Toggle EB", &toggleEB);
	self addOpt("ebsetts", "Change EB Radius", &RadiusEB);
	self addOpt("ebsetts", "Change EB Damage", &DamageEB);     
  
  self addOpt( "Main Menu", "Weapons", &submenu, "WeapMenu", "Weapons" );
  self addMenu("WeapMenu", "Main Menu");
	self addOpt("WeapMenu", "Snipers", &subMenu, "snipers", "Snipers");
	self addOpt("WeapMenu", "Shotguns",  &subMenu, "shottys");
	self addOpt("WeapMenu", "Secondaries", &subMenu, "secs");
	self addOpt("WeapMenu", "Melees", &subMenu, "melee");
	self addOpt("WeapMenu", "^1Specials.", &subMenu, "specials");
	self addOpt("WeapMenu", "^2Toggle Spawn With Chosen Gun", &SpawnWithChosen);
	self addOpt("WeapMenu", "^3Give Random Weapon", &func_giveRandomWeapon);

self addOpt( "WeapMenu", "Snipers", &submenu, "WeapMenu", "snipers" );
  self addMenu("snipers", "WeapMenu");
	self addOpt("snipers", "Drakon", &giveThatGun, "sniper_fastsemi");
	self addOpt("snipers", "Locus", &giveThatGun, "sniper_fastbolt");
	self addOpt("snipers", "SVG-100", &giveThatGun, "sniper_powerbolt");
	self addOpt("snipers", "P-06", &giveThatGun, "sniper_chargeshot");
	self addOpt("snipers", "^1RSA Interdiction", &giveThatGun, "sniper_quickscope");
	self addOpt("snipers", "^1DBSR-50", &giveThatGun, "sniper_double");

self addOpt( "WeapMenu", "Shotguns", &submenu, "WeapMenu", "shottys" );
  self addMenu("shottys", "WeapMenu");
	self addOpt("shottys", "KRM-262", &giveThatGun, "shotgun_pump");
	self addOpt("shottys", "Brecci", &giveThatGun, "shotgun_semiauto");
	self addOpt("shottys", "Haymaker 12", &giveThatGun, "shotgun_fullauto");
	self addOpt("shottys", "Argus", &giveThatGun, "shotgun_precision");
	self addOpt("shottys", "^1Banshii", &giveThatGun, "shotgun_energy");

self addOpt( "WeapMenu", "Secondaries", &submenu, "WeapMenu", "secs" );
  self addMenu("secs", "WeapMenu");
	self addOpt("secs", "MR6", &giveThatGun, "pistol_standard");
	self addOpt("secs", "RK5", &giveThatGun, "pistol_burst");
	self addOpt("secs", "LCAR9", &giveThatGun, "pistol_fullauto");
	self addOpt("secs", "^1Marshal 16", &giveThatGun, "pistol_shotgun");
	self addOpt("secs", "^1Rift E9", &giveThatGun, "pistol_energy");

self addOpt( "WeapMenu", "Melee", &submenu, "WeapMenu", "melee" );
  self addMenu("melee", "WeapMenu");
	self addOpt("melee", "Combat Knife", &giveThatGun, "melee_loadout");
	self addOpt("melee", "^1Butterfly Knife", &giveThatGun, "melee_butterfly");
	self addOpt("melee", "^1Wrench", &giveThatGun, "melee_wrench");
	self addOpt("melee", "^1Brass Knuckles", &giveThatGun, "melee_knuckles");
	self addOpt("melee", "^1Fury's Song", &giveThatGun, "melee_sword");
	self addOpt("melee", "^1Iron Jim", &giveThatGun, "melee_crowbar");	
	self addOpt("melee", "^1MVP", &giveThatGun, "melee_bat");	
	self addOpt("melee", "^1Carver", &giveThatGun, "melee_bowie");	
	self addOpt("melee", "^1Malice", &giveThatGun, "melee_dagger");	
	self addOpt("melee", "^1Skull Splitter", &giveThatGun, "melee_mace");	
	self addOpt("melee", "^1Slash N' Burn", &giveThatGun, "melee_fireaxe");
	self addOpt("melee", "^1Nightbreaker", &giveThatGun, "melee_boneglass");
	self addOpt("melee", "^1Buzz Cut", &giveThatGun, "melee_improvise");
	self addOpt("melee", "^1Nunchucks", &giveThatGun, "melee_nunchuks");
	self addOpt("melee", "^1Enforcer", &giveThatGun, "melee_shockbaton");

self addOpt( "WeapMenu", "Specials", &submenu, "WeapMenu", "specials" );
  self addMenu("specials", "WeapMenu");
	self addOpt("specials", "Annihilator Pistol", &giveThatGun, "hero_annihilator", true);
	self addOpt("specials", "Ripper Knife", &giveThatGun, "hero_armblade", true);
	self addOpt("specials", "Bow and Arrow", &giveThatGun, "hero_bowlauncher", true);
	self addOpt("specials", "Hive Gun", &giveThatGun, "hero_chemicalgelgun", true);
	self addOpt("specials", "Flamethrower", &giveThatGun, "hero_flamethrower", true);
	self addOpt("specials", "Gravity Spikes", &giveThatGun, "hero_gravityspikes", true);
	self addOpt("specials", "Electrogun", &giveThatGun, "hero_lightninggun", true);
	self addOpt("specials", "Scythe Minigun", &giveThatGun, "hero_minigun", true);
	self addOpt("specials", "War Machine", &giveThatGun, "hero_pineapplegun", true);
	self addOpt("specials", "Pink M27", &giveThatGun, "baseweapon");
	self addOpt("specials", "Finger Gun", &giveThatGun, "defaultweapon");
	self addOpt("specials", "Minigun", &giveThatGun, "minigun");
	self addOpt("specials", "Bowie Knife", &giveThatGun, "bowie_knife");
	self addOpt("specials", "Killstreak Remote", &giveThatGun, "killstreak_remote");
	self addOpt("specials", "Remote Missile", &giveThatGun, "remote_missile");
	self addOpt("specials", "NX ShadowClaw", &giveThatGun, "special_crossbow");
}

function Pulser()
{
	self notify("stop_pulser");
	self endon("stop_pulser");
	self endon("menu_closed");
	self endon("death");
	
	self.Pulsing = true;
	while(true)
	{
		self fadeovertime( 0.3 );
		self.alpha = 0.3;
		wait 0.2;
		self fadeovertime( 0.3 );
		self.alpha = 1;
		wait 0.4;
		continue;
	}
}

function stopPulser()
{
	if(self.Pulsing)
	{
		self notify("stop_pulser");
		self.alpha = 0.7;
		self.pulsing = false;
	}
}

function Fontscaler(value, time)
{
	self changeFontScaleOverTime(time);
	self.fontScale = value;
}

function addMenu( Menu, prevmenu )
{
  self.menu.getmenu[Menu] = Menu;
  self.menu.scrollerpos[Menu] = 0;
  self.menu.curs[Menu] = 0;
  self.menu.menucount[Menu] = 0;
  self.menu.previousmenu[Menu] = prevmenu;
}
function addOpt( Menu, Text, Func, arg1, arg2 )
{
  Menu = self.menu.getmenu[Menu];
  Num = self.menu.menucount[Menu];
  self.menu.menuopt[Menu][Num] = Text;
  self.menu.menufunc[Menu][Num] = Func;
  self.menu.menuinput[Menu][Num] = arg1;
  self.menu.menuinput1[Menu][Num] = arg2;
  self.menu.menucount[Menu] += 1;
}
function openAnim()
{
	self.bkg.alpha = 1;
	self.bkg moveovertime(.4);
  	self.bkg.x = 200;
  	wait .4;
  	self.bg fadeovertime(.2);
  	self.bg.alpha = .55;
  	self.scroller fadeovertime(.2);
  	self.scroller.alpha = 1;
  	self.scrollerEmblem fadeovertime(.2);
  	self.scrollerEmblem.alpha = 1;
  	self.bg scaleOverTime(.1,200,((self.menu.menuopt[self.menu.currentmenu].size*21)+50));
}
function scrollAnim()
{
	self.scroller MoveOverTime(0.12);
	self.scrollerEmblem MoveOverTime(0.12);
	self.scroller.y = 65 + (21 * self.menu.curs[self.menu.currentmenu]);
	self.scrollerEmblem.y = 67 + (21 * self.menu.curs[self.menu.currentmenu]);
}
function openMenu()
{
  self notify("menu_opened");
  self freezeControls( 0 );
  self text( "Main Menu", "Main Menu" );
  self setClientUiVisibilityFlag( "hud_visible", 0 );
  self openAnim();
  self.menu.open = 1;
}
function closeMenu()
{
  self notify("menu_closed");
  self.bkg moveOvertime(.4);
  self.bkg.x = 650;
  self.text["current"] fadeovertime(.2);
  self.devText fadeovertime(.2);
  self.bg scaleovertime(.2, 200, 1);
  self.Menuname fadeovertime(.2);
  self.text["current"].alpha = 0;
  self.devText.alpha = 0;
  self.Menuname.alpha = 0;
  self.menu.open = 0;
  wait .4;
  for( i = 0; i < self.text["option"].size; i++ )
  {
  		self.text["option"][i].alpha = 0;
  		self.text["option"][i] destroy();
  }
  self setClientUiVisibilityFlag( "hud_visible", 1 );
 // self setblur( 0, .2 );
  self.scroller fadeovertime(.1);
  self.scroller.alpha = 0;
  self.scrollerEmblem fadeovertime(.1);
  self.scrollerEmblem.alpha = 0;
  self.bg fadeovertime(.1);
  self.bg.alpha = 0;
}
function destroyMenu( player )
{
  player closeMenu();
  wait 1;
  player.text["option"] destroy();
  player.text["current"] destroy();
  player.ran = 0;
  player notify( "menuDestroyed" );
}
function scroll()
{
  for( R = 0; R < self.menu.menuopt[self.menu.currentmenu].size; R++ )
  {
  if( self.menu.curs[self.menu.currentmenu] < 0 )
  self.menu.curs[self.menu.currentmenu] = self.menu.menuopt[self.menu.currentmenu].size - 1;
 
  if( self.menu.curs[self.menu.currentmenu] > self.menu.menuopt[self.menu.currentmenu].size - 1 )
  self.menu.curs[self.menu.currentmenu] = 0;
 
  if( R == self.menu.curs[self.menu.currentmenu] )
  {
  self.text["option"][R].glowcolor = (0, .45, .01);
  self.text["option"][R].glowalpha = 1;
  self.text["option"][R] Fontscaler(2, .12);
  self.text["option"][R] thread Pulser();
  }
  else
  {
  self.text["option"][R].glowalpha = 0;
  self.text["option"][R] Fontscaler(1.6, .07);
  self.text["option"][R] thread stopPulser();
  }
 	 self scrollAnim();
  }
}
function text( menu, title )
{
  self.menu.currentmenu = menu;
  glow = ( 1,0,1 );
  self.text["current"] destroy();
  self.devText destroy();
  self.Menuname destroy();
  self.text["current"] = drawText( title, "objective", 1.7, 115, 40, ( 1, 1, 1 ), 1, glow, 0, 2 );
  self.devText = drawText( "created by nebulah", "objective", 1.2, 115, 11, ( 1, 1, 0 ), 1, (0, 0, 0), 0, 2 );
  self.Menuname = drawText( "aesthetic.	", "objective", 2.1, 115, -6, ( 1, 1, 1 ), 1, (0, .45, .01), 0, 2 );
  self.Menuname.glowalpha = .3;
  self.Menuname.alpha = 1;
  self.Menuname fadeovertime( .05 );
 
  for( i = 0; i < self.menu.menuopt[menu].size; i++ )
  {
  self.text["option"][i] destroy();
  self.text["option"][i] = drawText( self.menu.menuopt[menu][i], "objective", 1.6, 115, 77 + ( i*21 ), ( 1, 1, 1 ), 0, ( 0, 0, 0 ), 0, 2 );
  self.text["option"][i] fadeovertime( .3 );
  self.text["option"][i].alpha = 1;
  self scroll();
  }
  self.bg scaleOverTime(.1,200,((self.menu.menuopt[self.menu.currentmenu].size*21)+50));// thx to Extinct
}
function ButtonMonitor()
{
  self endon ( "menuDestroyed" );
  self endon ( "disconnected" );
 
  self.menu = spawnstruct();
  self.menu.open = 0;

  self CreateMenu();
 
  for(;;)
  {
  if( self MeleeButtonPressed() && self adsbuttonpressed() && !self.menu.open )
  {
  	openMenu();
  	wait .2;
  }
  if( self.menu.open )
  {
  if( self MeleeButtonPressed() )
  {
  if( isDefined( self.menu.previousmenu[self.menu.currentmenu] ) )
  self submenu( self.menu.previousmenu[self.menu.currentmenu] );
  else
  closeMenu();
  wait .3;
  }
  if( self adsbuttonpressed() )
  {
  self.menu.curs[self.menu.currentmenu]--;
  self scroll();
  wait 0.123;
  }
  if( self attackbuttonpressed() )
  {
  self.menu.curs[self.menu.currentmenu]++;
  self scroll();
  wait 0.123;
  }
  if( self Usebuttonpressed() )
  {
  	  self.scrollerEmblem scaleovertime(.123, 10, 10);
  	  wait .1;
  	  self.scrollerEmblem scaleovertime(.123, 20, 20);
  	  self thread [[self.menu.menufunc[self.menu.currentmenu][self.menu.curs[self.menu.currentmenu]]]] (self.menu.menuinput[self.menu.currentmenu][self.menu.curs[self.menu.currentmenu]], self.menu.menuinput1[self.menu.currentmenu][self.menu.curs[self.menu.currentmenu]] );
 	  wait .15;
  }
  }
  wait .05;
  }
}
function submenu( input, title )
{
  for( i = 0; i < self.text["option"].size; i++ )
  { self.text["option"][i] destroy(); }
 
  if( input == "Main Menu" )
  self thread text( input, "Main Menu" );
  else if ( input == "PlayersMenu" )
  {
  //no
  }
  else
  self thread text( input, title );
 
  self.currenttitle = title;
 
  self.menu.scrollerpos[input] = self.menu.curs[input];
  self.menu.curs[input] = self.menu.scrollerpos[input];
}

function S(i)
{
	self iprintln(i);
}

function debugexit()
{
	self S("^1WARNING^7: Exiting Level...");
	wait 2;
	exitlevel(false);
}

function killAll()
{
	foreach(stoner in level.players)
	{
		if(!stoner isHost())
		{
			stoner suicide();
		}
	}
	self S("All Players ^2Killed");
}

function kickAll()
{
	foreach(stoner in level.players)
	{
		if(!stoner isHost())
		{
			kick(stoner getentitynumber());
		}
	}
	self iPrintLn("All Players ^2Kicked");
}
