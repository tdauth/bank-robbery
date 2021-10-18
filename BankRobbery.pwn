// This is a comment
// uncomment the line below if you want to write a filterscript
//#define FILTERSCRIPT

#include <a_samp>

main()
{
	print("\n----------------------------------");
	print(" Bank Robbery by Barade");
	print("----------------------------------\n");
}

#define COLOR_RED 0xFF0000FF
#define COLOR_GREEN 0x00FF00FF

new Text:classTextRobber;
new Text:classTextSecurity;
new Text:classTextBankEmployee;
new Text:classTextPolice;
new Text:classTextSwat;

new WinsGovernment;
new WinsBankRobbers;
new Draws;
new Rounds;

new transporterId;
new arrowId;

new EnterBankPickupId;
new ExitBankPickupId;
new SideExitPickupId;
new SideEntryPickupId;
new EnterDeskPickupId;
new ExitDeskPickupId;
new SniperPickupId;
new ArmourPickupId;

new ActorBankChef;
new ActorHostage;

new SafeId;
new OpenSafeId;

new TimeTimer;

new RoundTimer;
new RoundCheckTimer;
new RoundPauseTimer;
new RoundPauseTimerRemaining;
new RoundHasStarted;

new BankRobberyHasStarted;

new TransporterHasReachedTheBank;
new TransporterHasReachedTheHideout;

new BankDirectorTimer;
new BankDirectorIsIntimidated;
new BankDirectorIntimidationPlayer;
new BankDirectorIsIntimidatedDone;

new SafeRobberyTimer;
new SafeRobberyIsGoingOn;
new SafeRobberyIsDone;
new SafeRobberyPlayer;
new SafeMoneyPickupId;
new SafeMoney;

#define CLASS_BANK_ROBBER 0
#define CLASS_SECURITY 1
#define CLASS_BANK_EMPLOYEE 2
#define CLASS_POLICE 3
#define CLASS_SWAT 4

#define TEAM_BANK_ROBBERS 0
#define TEAM_GOVERNMENT 1
#define MAX_TEAMS 2

#define ROUND_PAUSE_TIME 30000
#define ROUND_TIME 900000
#define ROUND_CHECK_TIME 1000
#define TIMER_TICK_INTERVAL 1000

#define INTIMIDATION_TIME 60000
#define SAFE_ROBBERY_TIME 120000

#define START_MONEY 5000
#define TRANSPORT_SECURITY_REWARD 50000
#define TRANSPORT_ROBBERY_REWARD 2000000
#define SAFE_REWARD 8000000
#define SAFE_REWARD_AFTER_TRANSPORT 10000000
#define ROBBER_KILL_REWARD 5000

new PlayerClass[MAX_PLAYERS];
new PlayerText:PlayerTimerTextDraws[MAX_PLAYERS];
new PlayerTimerTextDrawExists[MAX_PLAYERS];

TimeTick() {
	// show the timers duration as text draw
	for (new i; i < GetMaxPlayers(); i++)
	{
	    if (!PlayerTimerTextDrawExists[i]) {
	    	// First, create the textdraw
    		PlayerTimerTextDraws[i] = CreatePlayerTextDraw(i, 320.0, 240.0, "0");
    		PlayerTimerTextDrawExists[i] = true;
    	}
    	
    	new tdstring[32], Float:vHealth;
    	
    	if (!RoundHasStarted) {
		    format(tdstring, sizeof(tdstring), "Pause: %d", RoundPauseTimerRemaining);
    		PlayerTextDrawSetString(i, PlayerTimerTextDraws[i], tdstring);
    	} else {
    	}

    	// Now show it
	    PlayerTextDrawShow(playerid, PlayerTimerTextDraws[i]);
    }
}

public OnGameModeInit()
{
    print("\nInit Game Mode");
	SetGameModeText("Bank Robbery");
	ShowNameTags(true);
	ShowPlayerMarkers(true);
	AllowInteriorWeapons(true);
	SetDeathDropAmount(true);
	UsePlayerPedAnims();
	SetGravity(0.010200);
 	SetTeamCount(MAX_TEAMS);
 	
	WinsGovernment = 0;
	WinsBankRobbers = 0;
	Draws = 0;
	Rounds = 0;
	
	RoundTimer = -1;
	RoundCheckTimer = -1;
	RoundPauseTimer = -1;
	RoundPauseTimerRemaining = 0;
	BankDirectorTimer = -1;
	SafeRobberyTimer = -1;
	
	SafeMoneyPickupId = -1;
	
	print("\nAdding Classes");
	
	AddPlayerClass(127, 2359.4104,141.8937,27.5093,90.0000, 0, 0, 0, 0, 0, 0); // vmaff4 bank robber
	classTextRobber = TextDrawCreate(240.0,580.0,"Bank Robber");
	
	AddPlayerClass(253, 1370.7373,426.2137,19.5035,154.1247, 0, 0, 0, 0, 0, 0); // security
	classTextSecurity = TextDrawCreate(240.0,580.0,"Security");
	TextDrawColor(classTextSecurity, 0x000000FF);
	TextDrawAlignment(classTextSecurity, 2); // Align the textdraw text in the center
	
	AddPlayerClass(141, 2318.3076,-7.1613,26.7496, 90.0000, 0, 0, 0, 0, 0, 0); // sofybu Bank employee
	classTextBankEmployee = TextDrawCreate(240.0,580.0,"Bank Employee");
	TextDrawColor(classTextBankEmployee, 0x000000FF);
	TextDrawAlignment(classTextBankEmployee, 2); // Align the textdraw text in the center
		
	AddPlayerClass(280, 2305.6062,-14.0697,32.5313,90.5618, 0, 0, 0, 0, 0, 0); // police
	classTextPolice = TextDrawCreate(240.0,580.0,"Police");
	TextDrawColor(classTextPolice, 0x000000FF);
	TextDrawAlignment(classTextPolice, 2); // Align the textdraw text in the center
		
	AddPlayerClass(285, 2305.6062,-14.0697,32.5313,90.5618, 0, 0, 0, 0, 0, 0); // SWAT
	classTextSwat = TextDrawCreate(240.0,580.0,"SWAT");
	TextDrawColor(classTextSwat, 0x000000FF);
	TextDrawAlignment(classTextSwat, 2); // Align the textdraw text in the center
	
//AddPlayerClass(253,2315.3508,1.8007,26.4844,354.0542,0,0,0,0,0,0); // banksideentry
//AddPlayerClass(253,2318.6052,5.7739,26.4844,283.5303,0,0,0,0,0,0); // carbanktarget

	print("\nAdding Vehicles");
	
	AddStaticVehicle(487, 2309.8318, -9.4193, 32.5313, 182.0094, 0, 1); // Maverick on Bank
	AddStaticVehicle(487, 2327.9138,27.9844,31.4834,274.0489, 0, 1); // Maverick on Bank
	AddStaticVehicle(487, 2328.0342,49.7094,32.9884,1.1564, 0, 1); // Maverick on Bank
	
	AddStaticVehicle(581, 2324.0308,73.5808,26.4838,172.8647, 0, 1); // BF-400
	
	AddStaticVehicle(436, 2359.0366,146.2801, 27.3028, 272.2969, 0, 1); // robbercar Previon
//	AddStaticVehicle(428, 2047.4825,1318.3086,10.6719,19.7268, 0, 1); // Securicar at bank
//	AddStaticVehicle(428, 1366.3755,428.8545,19.5378,153.4980, 7, 7); // Securicar start

	AddStaticVehicle(445, 2264.6233,106.8751,27.3133,180.0113, 0, 1); // Admiral
	AddStaticVehicle(496, 2261.5166,105.8344,27.1447,356.1063, 0, 1); // Blista Compact
	AddStaticVehicle(422, 2231.4700,160.8719,27.1956,1.4096, 0, 1); // Bobcat
	
	AddStaticVehicle(596, 1274.3840,227.7226,19.5547,155.3698, 0, 1); //Police Car LSPD
	AddStaticVehicle(596, 2238.3386,23.2560,26.4577,355.2783, 0, 1); //Police Car LSPD
	AddStaticVehicle(427, 2244.9763,23.7546,26.4547,0.9184, 0, 1); //Enforcer
	AddStaticVehicle(427, 2251.6465,24.4374,26.4505,357.7850, 0, 1); //Enforcer
	AddStaticVehicle(596, 2264.1838,24.1644,26.4522,358.4117, 0, 1); //Police Car LSPD

 	AddStaticVehicle(421, 2279.3079,2.8140,27.4688,181.0278, 0, 1); // Washington

	print("\nAdding Pickups");
	
	EnterBankPickupId = CreatePickup(1274, 1, 2303.2041,-15.8398,26.4844, 0);
	ExitBankPickupId = CreatePickup(1272, 1, 2305.0540,-16.3442,26.7422, 0);
	
	SideExitPickupId = CreatePickup(1272, 1, 2315.6960,-0.0714,26.7422, 0);
	SideEntryPickupId = CreatePickup(1274, 1, 2315.3508,1.8007,26.4844, 0);
	
	EnterDeskPickupId = CreatePickup(1272, 1, 2316.2607,-16.3998,26.7422, 0);
	ExitDeskPickupId = CreatePickup(1272, 1, 2318.6289,-16.1330,26.7496, 0);
	
	SniperPickupId = CreatePickup(358, 3, 2306.3137,-0.1827,32.5313, -1); // Sniper
	ArmourPickupId = CreatePickup(1242, 3, 2305.7065,-15.9931,32.5313, -1); // Armor

	print("\nAdding Objects");
	
	SafeId = CreateObject(2332, 2306.3281,-4.9693,20.7422, 180.0, 0.0, 270.0000);
	OpenSafeId = CreateObject(1829, 2306.3281,-4.9693,200.0000, 180.0, 0.0, 270.0000);
	
	ActorBankChef = -1;
	ActorHostage = -1;
	
	print("\nEnding round from start");

	EndRound();
	
	for (new i = 0; i < MAX_PLAYERS; i++)
	{
		PlayerTimerTextDrawExists[i] = false;
	}
	
	TimeTimer = SetTimer("TimeTick", TIMER_TICK_INTERVAL, true);
	
	print("\nInit Game Mode Completed");
	
	return 1;
}

public OnGameModeExit()
{
	new tdstring[255];
	format(tdstring, sizeof(tdstring), "Ending game mode with %d government wins, %d bank robber wins, %d draws and %d rounds", WinsGovernment, WinsBankRobbers, Draws, Rounds);
	print(tdstring);
	
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    PlayerClass[playerid] = classid;

    TextDrawHideForPlayer(playerid, classTextRobber);
    TextDrawHideForPlayer(playerid, classTextSecurity);
    TextDrawHideForPlayer(playerid, classTextBankEmployee);
    TextDrawHideForPlayer(playerid, classTextPolice);
    TextDrawHideForPlayer(playerid, classTextSwat);

	if (classid == CLASS_BANK_ROBBER) {
		TextDrawShowForPlayer(playerid, classTextRobber);
	}
	
	if (classid == CLASS_SECURITY) {
		TextDrawShowForPlayer(playerid, classTextSecurity);
	}

	if (classid == CLASS_BANK_EMPLOYEE) {
		TextDrawShowForPlayer(playerid, classTextBankEmployee);
	}
	
	if (classid == CLASS_POLICE) {
		TextDrawShowForPlayer(playerid, classTextPolice);
	}
	
	if (classid == CLASS_SWAT) {
		TextDrawShowForPlayer(playerid, classTextSwat);
	}
	
//    if (classid == 3) {
	SetPlayerPos(playerid, 2302.7339,-12.5260,26.4844); // swat
	SetPlayerFacingAngle(playerid, 90.0000);
//	}
	SetPlayerCameraPos(playerid, 2291.7461,-12.5899,26.3371);
	SetPlayerCameraLookAt(playerid,2302.7339,-12.5260,26.4844);
	
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnPlayerConnect(playerid)
{
	new name[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, name, sizeof(name));

    new string[MAX_PLAYER_NAME + 23 + 1];
    format(string, sizeof(string), "%s has joined the server.", name);
    SendClientMessageToAll(0xC4C4C4FF, string);
    
    SetPlayerMapIcon(playerid, 12, 2303.2041, -15.8398, 26.4844, 52, 0, MAPICON_GLOBAL); // bank entry

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	DropSafeMoney(playerid);
	
	if (PlayerTimerTextDrawExists[playerid]) {
		PlayerTextDrawDestroy(playerid, PlayerTimerTextDraws[playerid]);
		PlayerTimerTextDrawExists[playerid] = false;
	}

	return 1;
}

GivePlayerStartItems(playerid, classid) {
	ResetPlayerMoney(playerid);
	ResetPlayerWeapons(playerid);
	GivePlayerMoney(playerid, START_MONEY);

	if (classid == CLASS_BANK_ROBBER) {
		GivePlayerWeapon(playerid, WEAPON_KNIFE, 1);
		GivePlayerWeapon(playerid, WEAPON_DEAGLE, 60);
		GivePlayerWeapon(playerid, WEAPON_SHOTGSPA, 60);
		GivePlayerWeapon(playerid, WEAPON_UZI, 60);
		GivePlayerWeapon(playerid, WEAPON_AK47, 60);
		GivePlayerWeapon(playerid, WEAPON_ROCKETLAUNCHER, 2);
		GivePlayerWeapon(playerid, WEAPON_SATCHEL, 2);
		GivePlayerWeapon(playerid, 44, 1);
		GivePlayerWeapon(playerid, 45, 1);
		GivePlayerWeapon(playerid, WEAPON_PARACHUTE, 1);
	}

	if (classid == CLASS_SECURITY) {
		GivePlayerWeapon(playerid, WEAPON_NITESTICK, 1);
		GivePlayerWeapon(playerid, WEAPON_COLT45, 60);
		GivePlayerWeapon(playerid, WEAPON_SHOTGUN, 60);
		SetPlayerArmour(playerid, 100.0);
	}

	if (classid == CLASS_BANK_EMPLOYEE) {
		GivePlayerWeapon(playerid, WEAPON_DILDO, 1);
		GivePlayerWeapon(playerid, WEAPON_DILDO2, 1);
		GivePlayerWeapon(playerid, WEAPON_VIBRATOR, 1);
		GivePlayerWeapon(playerid, WEAPON_VIBRATOR2, 1);
		GivePlayerWeapon(playerid, WEAPON_FLOWER, 1);
		GivePlayerWeapon(playerid, WEAPON_CAMERA, 1);
	}

	if (classid == CLASS_POLICE) {
		GivePlayerWeapon(playerid, WEAPON_NITESTICK, 1);
		GivePlayerWeapon(playerid, WEAPON_COLT45, 35);
		GivePlayerWeapon(playerid, WEAPON_SHOTGUN, 60);
	}

	if (classid == CLASS_SWAT) {
		GivePlayerWeapon(playerid, WEAPON_NITESTICK, 1);
		GivePlayerWeapon(playerid, WEAPON_COLT45, 35);
		GivePlayerWeapon(playerid, WEAPON_MP5, 60);
		GivePlayerWeapon(playerid, WEAPON_SNIPER, 30);
		GivePlayerWeapon(playerid, WEAPON_TEARGAS, 10);
		GivePlayerWeapon(playerid, 44, 1);
		GivePlayerWeapon(playerid, 45, 1);
		SetPlayerArmour(playerid, 100.0);
	}
}

public OnPlayerSpawn(playerid)
{
    TextDrawHideForPlayer(playerid, classTextRobber);
    TextDrawHideForPlayer(playerid, classTextSecurity);
    TextDrawHideForPlayer(playerid, classTextBankEmployee);
    TextDrawHideForPlayer(playerid, classTextPolice);
    TextDrawHideForPlayer(playerid, classTextSwat);

	//SetPlayerWorldBounds(playerid, 2535.9102, 1080.0216, 584.8155, -10.5734);
	
	if (PlayerClass[playerid] == CLASS_BANK_ROBBER) {
	    SetPlayerTeam(playerid, TEAM_BANK_ROBBERS);
	}
	
	if (PlayerClass[playerid] == CLASS_SECURITY) {
		SetPlayerTeam(playerid, TEAM_GOVERNMENT);
	}
	
	if (PlayerClass[playerid] == CLASS_BANK_EMPLOYEE) {
		SetPlayerTeam(playerid, TEAM_GOVERNMENT);
	}
	
	if (PlayerClass[playerid] == CLASS_POLICE) {
		SetPlayerTeam(playerid, TEAM_GOVERNMENT);
	}
	
	if (PlayerClass[playerid] == CLASS_SWAT) {
		SetPlayerTeam(playerid, TEAM_GOVERNMENT);
	}
	
	GivePlayerStartItems(playerid, PlayerClass[playerid]);

	return 1;
}

DropSafeMoney(playerid) {
	if (playerid == SafeRobberyPlayer) {
		GivePlayerMoney(SafeRobberyPlayer, -1 * SafeMoney);
		new Float:x, Float:y, Float:z;
		// Use GetPlayerPos, passing the 3 float variables we just created
		GetPlayerPos(playerid, x, y, z);
		SafeMoneyPickupId = CreatePickup(1212, 4, x, y, z, -1);
		SafeRobberyPlayer = -1;
	}
}

PlayerKillsRobber(playerid, killerid, reason) {
	if (RoundHasStarted && GetPlayerTeam(playerid) == TEAM_BANK_ROBBERS && BankRobberyHasStarted && killerid != -1 && GetPlayerTeam(killerid) == TEAM_GOVERNMENT) {
    	GivePlayerMoney(killerid, ROBBER_KILL_REWARD);
    	SendClientMessage(killerid, -1, "You got money for killing a robber!");
    	SendClientMessage(playerid, -1, "You have been killed!");
    }
}

public OnPlayerDeath(playerid, killerid, reason)
{
	DropSafeMoney(playerid);
	PlayerKillsOtherPlayerEarly(playerid, killerid, reason);
	PlayerKillsHostage(playerid, killerid, reason);
	PlayerKillsRobber(playerid, killerid, reason);

	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

GovernmentWins() {
	WinsGovernment++;
    SendClientMessageToAll(-1, "Government has won!");
    EndRound();
}

BankRobbersWin() {
	WinsBankRobbers++;
    SendClientMessageToAll(-1, "Bank robbers have won!");
    EndRound();
}

NobodyWins() {
	Draws++;
    SendClientMessageToAll(-1, "Draw!");
    EndRound();
}

CleanupRound() {
	if (RoundTimer != -1) {
		KillTimer(RoundTimer);
		RoundTimer = -1;
	}
	
	if (RoundCheckTimer != -1) {
		KillTimer(RoundCheckTimer);
		RoundCheckTimer = -1;
	}
	
	if (BankDirectorTimer != -1) {
		KillTimer(BankDirectorTimer);
		BankDirectorTimer = -1;
	}
	
	if (SafeRobberyTimer != -1) {
		KillTimer(SafeRobberyTimer);
		SafeRobberyTimer = -1;
  	}

    BankRobberyHasStarted = false;
    RoundHasStarted = false;
    TransporterHasReachedTheBank = false;
    TransporterHasReachedTheHideout = false;
    BankDirectorIsIntimidated = false;
    BankDirectorIsIntimidatedDone = false;
    BankDirectorIntimidationPlayer = -1;
	SafeRobberyIsGoingOn = false;
	SafeRobberyIsDone = false;
	SafeRobberyPlayer = -1;
	SafeMoney = 0;
	
	SetObjectPos(SafeId, 2306.3281,-4.9693,20.7422);
	SetObjectPos(OpenSafeId, 2306.3281,-4.9693,200.0000);
	
	if (SafeMoneyPickupId != -1) {
		DestroyPickup(SafeMoneyPickupId);
	}
	
	SafeMoneyPickupId = -1;

	if (IsValidActor(ActorBankChef))
    {
        DestroyActor(ActorBankChef);
    }
    
    if (IsValidActor(ActorHostage))
    {
        DestroyActor(ActorHostage);
    }
    
    for (new i; i < GetMaxPlayers(); i++)
	{
    	GivePlayerStartItems(i, PlayerClass[i]);
    }
}

EndRound() {
	Rounds++;

	CleanupRound();
    
	RoundPauseTimerRemaining = ROUND_PAUSE_TIME;
    RoundPauseTimer = SetTimer("StartRound", ROUND_PAUSE_TIME, false);
    
    SendClientMessageToAll(-1, "Round is ending and pause is starting!");
}

EndRoundTimerFunction() {
	GovernmentWins();
	EndRound();
}

PeriodicCheckDuringRound() {
	new Float:actorHealth;
	GetActorHealth(ActorBankChef, actorHealth);
	
	if (actorHealth < 0.0) {
		SendClientMessageToAll(COLOR_RED, "Round ends, the bank director has been killed!");

	    EndRound();
	}
	
	new Float:actorHealth;
	GetActorHealth(ActorHostage, actorHealth);

	if (actorHealth < 0.0) {
	   SendClientMessageToAll(COLOR_RED, "Round ends, the hostage has been killed!");

	   EndRound();
	}
}

StartRound() {
	if (RoundPauseTimer != -1) {
		KillTimer(RoundPauseTimer);
	    RoundPauseTimer = -1;
	    RoundPauseTimerRemaining = 0;
	}

    CleanupRound();

 	transporterId = CreateVehicle(428, 2047.4825,1318.3086,10.6719,19.7268, -1, -1, 60); // security car
	arrowId = CreateObject(1318, 2001.195679, 1547.113892, 14.283400, 0.0, 0.0, 96.0);
 	AttachObjectToVehicle(arrowId, transporterId, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0);
 	
	ActorBankChef = CreateActor(147, 2306.5354,-1.3431,26.7422,268.0494); // wmybu business man
	//SetActorInvulnerable(ActorBankChef, true);

	ActorHostage = CreateActor(219, 2316.3577,-9.8172,26.7422,269.3027); // sbfyri Rich Woman
	//SetActorInvulnerable(ActorHostage, true);
	
	RoundTimer = SetTimer("EndRoundTimerFunction", ROUND_TIME, false);
	
	SendClientMessageToAll(-1, "Starting a new round!");
	
	RoundCheckTimer = SetTimer("PeriodicCheckDuringRound", ROUND_CHECK_TIME, false);
	
	RoundHasStarted = true;
}

StartRobberyIfPossible(playerid) {
	if (RoundHasStarted && GetPlayerTeam(playerid) == TEAM_BANK_ROBBERS && !BankRobberyHasStarted) {
	    BankRobberyHasStarted = true;
	    
	    for (new i; i < GetMaxPlayers(); i++)
		{
		    if (GetPlayerTeam(i) == TEAM_BANK_ROBBERS) {
				SetPlayerWantedLevel(i, 6);
			    SendClientMessage(i, COLOR_RED, "Wanted Level: 6");
			    
			    for (new j; j < GetMaxPlayers(); j++)
				{
			    	PlayCrimeReportForPlayer(j, i, 17);
			    }
			    
			 	SetPlayerCheckpoint(playerid, 2308.9536,-1.2083,26.7422, 3.0); // get the director's keys
			}
			
			PlayerPlaySound(i, 3401, 2306.5354,-1.3431,26.7422); // alarm sound
		}
		
		ApplyActorAnimation(ActorBankChef, "ped", "handsup", 4.1, 0, 0, 0, 0, 0); // Pay anim
		ApplyActorAnimation(ActorHostage, "ped", "handsup", 4.1, 0, 0, 0, 0, 0); // Pay anim
	}
}

BankDirectorIntimidationDone() {
	BankDirectorIsIntimidatedDone = true;
	
	SetObjectPos(SafeId, 2306.3281,-4.9693,200.0000);
	SetObjectPos(OpenSafeId, 2306.3281,-4.9693,20.7422);

	for (new i; i < GetMaxPlayers(); i++)
	{
		if (GetPlayerTeam(i) == TEAM_BANK_ROBBERS) {
			SendClientMessage(i, COLOR_GREEN, "We got the key from the bank director!");
			SetPlayerCheckpoint(playerid, 2308.1958,-5.5114,26.7422, 3.0);
		} else {
			SendClientMessage(i, COLOR_RED, "They got the key from the bank director!");
		}
	}
}

StartBankDirectorIntimidation(playerid) {
    if (RoundHasStarted && GetPlayerTeam(playerid) == TEAM_BANK_ROBBERS && BankRobberyHasStarted && !BankDirectorIsIntimidated) {
    	BankDirectorTimer = SetTimer("BankDirectorIntimidationDone", INTIMIDATION_TIME, false);
    	BankDirectorIsIntimidated = true;
    	BankDirectorIntimidationPlayer = playerid;
    	SendClientMessage(playerid, COLOR_GREEN, "Started intimidating the bank director, do not leave until finished!");
    }
}

CancelBankDirectorIntimidation(playerid) {
    if (RoundHasStarted && GetPlayerTeam(playerid) == TEAM_BANK_ROBBERS && BankDirectorIsIntimidated && !BankDirectorIsIntimidatedDone && BankDirectorIntimidationPlayer == playerid) {
		KillTimer(BankDirectorTimer);
		BankDirectorTimer = -1;
    	BankDirectorIsIntimidated = false;
    	BankDirectorIntimidationPlayer = -1;
    	SendClientMessage(playerid, COLOR_RED, "You stopped intimidating the bank director!");
    }
}

RobberGetsSafeMoney(playerid) {
	SafeRobberyPlayer = playerid;

	if (!TransporterHasReachedTheBank) {
	    SafeMoney = SAFE_REWARD;
	} else {
		SafeMoney = SAFE_REWARD_AFTER_TRANSPORT;
	}
	
	GivePlayerMoney(SafeRobberyPlayer, SafeMoney);
}

SafeRobberyDone() {
    SafeRobberyIsDone = true;
    
    for (new i; i < GetMaxPlayers(); i++)
	{
		if (GetPlayerTeam(i) == TEAM_BANK_ROBBERS) {
			SendClientMessage(i, COLOR_GREEN, "We got all the money from the safe, bring it to our hideout!");
			SetPlayerCheckpoint(playerid, 1919.9584,175.5450,37.2752, 3.0);
			RobberGetsSafeMoney(SafeRobberyPlayer);
		} else {
			SendClientMessage(i, COLOR_RED, "They got all the money from the safe, prepare to catch them!");
		}
	}
}

StartSafeRobberyIfPossible(playerid) {
	if (RoundHasStarted && GetPlayerTeam(playerid) == TEAM_BANK_ROBBERS && BankRobberyHasStarted && BankDirectorIsIntimidatedDone && !SafeRobberyIsGoingOn) {
	    SafeRobberyTimer = SetTimer("SafeRobberyDone", SAFE_ROBBERY_TIME, false);
    	SafeRobberyIsGoingOn = true;
    	SafeRobberyPlayer = playerid;
    	SendClientMessage(playerid, COLOR_GREEN, "Started robbing the safe, do not leave until finished!");
	}
}

CancelSafeRobberyIfPossible(playerid) {
    if (RoundHasStarted && GetPlayerTeam(playerid) == TEAM_BANK_ROBBERS && SafeRobberyIsGoingOn && !SafeRobberyIsDone && SafeRobberyPlayer == playerid) {
		KillTimer(SafeRobberyTimer);
		SafeRobberyTimer = -1;
    	SafeRobberyIsGoingOn = false;
    	SafeRobberyPlayer = -1;
    	SendClientMessage(playerid, COLOR_RED, "You stopped robbing the safe!");
    }
}

PlayerKillsOtherPlayerEarly(playerid, killerid, reason) {
	if (RoundHasStarted && !BankRobberyHasStarted) {
		SendClientMessageToAll(COLOR_RED, "Do not kill anyone before the bank robbery has started!!!");
	
	    if (GetPlayerTeam(killerid) == TEAM_BANK_ROBBERS) {
	        GovernmentWins();
	    } else if (GetPlayerTeam(killerid) == TEAM_GOVERNMENT) {
			 BankRobbersWin();
	    }
	}
}

PlayerKillsHostage(playerid, killerid, reason) {
	if (PlayerClass[playerid] == CLASS_BANK_EMPLOYEE && killerid != -1 && PlayerClass[killerid] != CLASS_BANK_EMPLOYEE) {
		SendClientMessageToAll(COLOR_RED, "Do not kill any hostages!!!");

	    NobodyWins();
	}
}

PlayerEntersBank(playerid) {
	SetPlayerPos(playerid, 2306.3584,-15.6320,26.7496);
	SetPlayerFacingAngle(playerid, 263.5024);
	
	StartRobberyIfPossible(playerid);
}

PlayerLeavesBank(playerid) {
	SetPlayerPos(playerid, 2301.1355,-16.7282,26.4844);
	SetPlayerFacingAngle(playerid, 90.0000);
}

PlayerEntersBankSide(playerid) {
    SetPlayerPos(playerid, 2315.5505,-1.5802,26.7422);
	SetPlayerFacingAngle(playerid, 177.8141);
	
	StartRobberyIfPossible(playerid);
}

PlayerLeavesBankSide(playerid) {
	SetPlayerPos(playerid, 2315.6084,4.8385,26.4844);
	SetPlayerFacingAngle(playerid, 0.0000);
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/hydra", cmdtext, true, 10) == 0 && IsPlayerAdmin(playerid))
	{
		new Float:x, Float:y, Float:z;
	    // Use GetPlayerPos, passing the 3 float variables we just created
    	GetPlayerPos(playerid, x, y, z);
    	new Float:Angle;
		GetPlayerFacingAngle(playerid, Angle);
        CreateVehicle(520, x, y, z, Angle, -1, -1, 60); // Hydra
        return 1;
	}
	
	if (strcmp("/start", cmdtext, true, 10) == 0 && IsPlayerAdmin(playerid))
	{
		StartRound();
        return 1;
	}

	if (strcmp("/help", cmdtext, true, 10) == 0)
	{
		// Do something here
		return 1;
	}
	
	if (strcmp("/bank", cmdtext, true, 10) == 0 && IsPlayerAdmin(playerid))
	{
		SetPlayerPosFindZ(playerid, 2315.952880,-1.618174,26.742187);
		return 1;
	}
	
	if (strcmp("/bankenter", cmdtext, true, 10) == 0 && IsPlayerAdmin(playerid))
	{
		PlayerEntersBank(playerid);

		return 1;
	}
	
	if (strcmp("/bankdesk", cmdtext, true, 10) == 0 && IsPlayerAdmin(playerid))
	{
		SetPlayerPosFindZ(playerid, 2319.714843,-14.838361,26.749565);
		
		return 1;
	}
	
	if (strcmp("/kill", cmdtext, true, 10) == 0)
    {
        SetPlayerHealth(playerid, 0.0);
        return 1;
    }
	
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if (transporterId != -1 && vehicleid == transporterId && !TransporterHasReachedTheBank && !TransporterHasReachedTheHideout) {
	    if (GetPlayerTeam(playerid) == TEAM_GOVERNMENT) {
			SetPlayerCheckpoint(playerid, 2315.6084,4.8385,26.4844, 3.0);
			SendClientMessage(playerid, COLOR_GREEN, "Move the security car to the checkpoint to bring the money to the bank.");
		} else {
			SetPlayerCheckpoint(playerid, 1919.9584,175.5450,37.2752, 3.0);
			SendClientMessage(playerid, COLOR_GREEN, "Move the security car to your hideout to steal the money.");
		}
	}

	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	DisablePlayerCheckpoint(playerid);
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if (!TransporterHasReachedTheBank && !TransporterHasReachedTheHideout && newstate == PLAYER_STATE_DRIVER && GetPlayerVehicleID(playerid) == transporterId)
    {
        if (GetPlayerTeam(playerid) == TEAM_GOVERNMENT && PlayerClass[playerid] != CLASS_SECURITY) {
	       	SendClientMessage(playerid, COLOR_RED, "Only security can drive this car.");
    	    RemovePlayerFromVehicle(playerid);
    	}
    }
    
    if (newstate == PLAYER_STATE_DRIVER && (GetVehicleModel(GetPlayerVehicleID(playerid)) == 596 || GetVehicleModel(GetPlayerVehicleID(playerid)) == 427) && PlayerClass[playerid] != CLASS_POLICE && PlayerClass[playerid] != CLASS_SWAT) {
		SendClientMessage(playerid, COLOR_RED, "Only police or SWAT can drive this car.");
    	RemovePlayerFromVehicle(playerid);
	}

	return 1;
}

TransporterReachesBankOrHideout(playerid) {
    if (!TransporterHasReachedTheBank && !TransporterHasReachedTheHideout && GetPlayerVehicleID(playerid) == transporterId && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
		if (GetPlayerTeam(playerid) == TEAM_GOVERNMENT) {
		    TransporterHasReachedTheBank = true;

			for (new i; i < GetMaxPlayers(); i++)
			{
			    if (PlayerClass[playerid] == CLASS_SECURITY) {
					SendClientMessage(playerid, COLOR_GREEN, "The security car has delivered money to the bank!");
					DisablePlayerCheckpoint(playerid);
					GivePlayerMoney(playerid, TRANSPORT_SECURITY_REWARD);
				}
			}
		} else {
		    TransporterHasReachedTheHideout = true;

		    for (new i; i < GetMaxPlayers(); i++)
			{
				SendClientMessage(playerid, COLOR_GREEN, "The security car has been robbed!");
				DisablePlayerCheckpoint(playerid);

				if (GetPlayerTeam(i) == TEAM_BANK_ROBBERS) {
					GivePlayerMoney(i, TRANSPORT_ROBBERY_REWARD);
				}
			}
		}
 	}
}

public OnPlayerEnterCheckpoint(playerid)
{
	TransporterReachesBankOrHideout(playerid);
 	
 	if (GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && GetPlayerTeam(playerid) == TEAM_BANK_ROBBERS) {
 	    if (BankDirectorIsIntimidatedDone && !SafeRobberyIsGoingOn) {
 	    	StartSafeRobberyIfPossible(playerid);
 	    } else if (!BankDirectorIsIntimidated && !SafeRobberyIsGoingOn && !SafeRobberyIsDone) {
	 	    StartBankDirectorIntimidation(playerid);
 	    } else if (SafeRobberyIsDone && playerid == SafeRobberyPlayer) {
			BankRobbersWin();
 	    }
 	}
 	
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	if (BankDirectorIntimidationPlayer == playerid) {
		CancelBankDirectorIntimidation(playerid);
	}

	if (SafeRobberyPlayer == playerid) {
	    CancelSafeRobberyIfPossible(playerid);
	}

	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

EnterDesk(playerid) {
	SetPlayerPos(playerid, 2319.1719,-13.5945,26.7496);
	SetPlayerFacingAngle(playerid, 346.0078);
}

LeaveDesk(playerid) {
	SetPlayerPos(playerid, 315.9468,-13.2144,26.7422);
	SetPlayerFacingAngle(playerid, 90.0000);
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	if (pickupid == EnterBankPickupId) {
	    PlayerEntersBank(playerid);
 	}
 	else if (pickupid == ExitBankPickupId) {
	 	PlayerLeavesBank(playerid);
 	}
 	else if (pickupid == SideEntryPickupId) {
 	    PlayerEntersBankSide(playerid);
 	}
 	else if (pickupid == SideExitPickupId) {
		PlayerLeavesBankSide(playerid);
 	}
 	else if (pickupid == SafeMoneyPickupId) {
 	    if (GetPlayerTeam(playerid) == TEAM_GOVERNMENT) {
 	        GovernmentWins();
 	    } else {
 	  		RobberGetsSafeMoney(playerid);
 	    }
 	}
 	else if (pickupid == EnterDeskPickupId) {
		EnterDesk(playerid);
 	}
 	else if (pickupid == ExitDeskPickupId) {
		LeaveDesk(playerid);
 	}
 	else if (pickupid == SniperPickupId) {
	 	GivePlayerWeapon(playerid, WEAPON_SNIPER, 5);
 	}
 	else if (pickupid == ArmourPickupId) {
	 	SetPlayerArmour(playerid, 100.0);
 	}

	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	if (IsPlayerAdmin(playerid)) {
		SetPlayerPosFindZ(playerid, fX, fY, fZ);
	}

	return 1;
}
