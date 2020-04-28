# Stargate-Network on OpenComputer v0.2b

This program was created to use Stargate-Network with OpenComputer systems.

Originally made by thatParadox for ComputerCraft, this is a portage of his work, made with his permission.

## Credits

### Authors

thatParadox (Original Developer) : [Twitter](https://www.twitter.com/thatparadox) - [Facebook](https://www.facebook.com/thatparagame) - [Twitch](https://www.twitch.tv/thatparadox) - [Youtube](https://www.youtube.com/channel/UCTIRVHRXfcwQBFo6morWkZA)

Kirastaroth (Porting to OC, Maintaining, Adding features) : [Github](https://github.com/rperraudeau)

### Minecraft mods involved

Stargate-Network (Stargate minecraft mod) : [https://www.curseforge.com/minecraft/mc-mods/stargate-network](https://www.curseforge.com/minecraft/mc-mods/stargate-network)

OpenComputer (Computer minecraft mod) : [https://www.curseforge.com/minecraft/mc-mods/opencomputers](https://www.curseforge.com/minecraft/mc-mods/opencomputers)

## Presentation / How to use

You can find the original software presentation video at [https://www.youtube.com/watch?v=6bpzHJig8LM](https://www.youtube.com/watch?v=6bpzHJig8LM)

Video to present this software for OpenComputer will come later.

## Installation

### Manually:

On your OpenComputer interface:

`edit startup`

Copy/paste the "startup.lua" code found [here](https://raw.githubusercontent.com/rperraudeau/stargatenetwork-opencomputer/master/startup.lua)

ctrl+s to save

ctrl+w to quit

then run the program:

`startup`

ctrl+c to interrupt program

you can add "startup" at a new line in the ".shrc" file to run it automatically on computer startup (by following the steps above to edit the file)

Hint: you can use Maj+insert to paste code in OpenComputer (but it seems to be limited to a certain char length)

Hint2: You can directly paste the code in the file "startup" on your minecraft save in (by default) C:\Users\[YourUsername]\AppData\Roaming\.minecraft\saves\[YourWorldName]\opencomputers\[DiskDriveId]\home\startup

If you have many disk drives, find the one where you created the empty "startup" file ingame

You probably will have to restart your game (or minecraft) (depends on the config of OpenComputer "bufferChanges", set it to false to read from disk without reload game)) to get the change applied ingame

### Automatic:

Will come later via pastebin.

## Features planed

See Changelog

## Licence

This software is distributed under Common-Creative licence CC-BY-NC-SA
 
### This means you can:

- Share — copy and redistribute the material in any medium or format
- Adapt — remix, transform, and build upon the material

### Under certain conditions:
- Non Commercial Uses
  - This is free work, and we want it to be kept like this !
- Keeps Attributions, at least for Authors (But a link to involved mods is still appreciated, and nice for users)
  - This is free work, we just want our name somewhere in the credits  : )
- Share with same licence or compatible licence
  - see [https://creativecommons.org/share-your-work/licensing-considerations/compatible-licenses](https://creativecommons.org/share-your-work/licensing-considerations/compatible-licenses)

More details: [https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en](https://creativecommons.org/licenses/by-nc-sa/4.0/deed.en)

For additional information, see the full licence (on the root file: [LICENCE](https://raw.githubusercontent.com/rperraudeau/stargatenetwork-opencomputer/master/LICENCE))