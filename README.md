# San Andreas Multiplayer Bank Robbery

[GTA San Andreas Multiplayer](https://www.sa-mp.com/) game mode in which two teams play versus each other:

* Bank Robbers: Steal the money from the bank and bring it to a specific location without dying.
* Government: Protect the money in the bank from being stolen by killing the bank robbers but never let them hurt any hostages.

The round is repeated and the scores per team are counted.

## How to host

Download and install the [SAMP server](https://www.sa-mp.com/download.php).

Place the file [BankRobbery.amx](./BankRobbery.amx) into your `gamemodes` folder for example `C:\Program Files (x86)\Steam\steamapps\common\Grand Theft Auto San Andreas\gamemodes`.

Adapt the `server.cfg` file:

```
echo Executing Server Config...
lanmode 0
rcon_password bla123
maxplayers 50
port 7777
hostname Bank Robbery
gamemode0 BankRobbery 1
filterscripts gl_actions gl_realtime gl_property gl_mapicon ls_elevator attachments skinchanger vspawner ls_mall ls_beachside
announce 0
chatlogging 0
weburl github.com/tdauth/thecity
onfoot_rate 40
incar_rate 40
weapon_rate 40
stream_distance 300.0
stream_rate 1000
maxnpc 0
logtimeformat [%H:%M:%S]
language German
```

The important part is only the game mode name `BankRobbery`.

Start the server (on Windows `samp-server.exe`).

## Classes

### Bank Robbery

Your goal is it to steal as much money in one round without being killed or killing a hostage.

### Police and SWAT

Your goal is it to prevent the bank robbers from stealing any money but also to keep the hostages alive.

### Bank Employees

Your goal is it to keep everyone calm and do whatever the bank robbers want you to do.
You have to survive the round.
The round ends immidately without any winner when a hostage is killed.

### Security Transport Side Mission

Your goal is it to as much additional money safely to the bank as possible.

## Development

* [Scripting Functions](https://team.sa-mp.com/wiki/Category_Scripting_Functions.html)
* [SAMP default commands](http://forum.sa-mp.im/viewtopic.php?t=472)