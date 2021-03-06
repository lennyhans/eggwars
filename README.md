# Eggwars

## What this is
This mod is inspired by the Minecraft mod of the same name and has similar features.

Each player's goal is to defend their egg and be the last person standing. If a player dies - either from being killed by another player or falling off - they will respawn if their egg is intact. If it is not intact, they will be put into spectator mode.

When there is one player left standing, they are declared the winner.

## Install
Extract the zip file to mods/ **or** use `git clone https://github.com/wilkgr76/eggwars` from within the mods directory.

* Do **NOT** use an existing world - this will overwrite the mapgen and cause destruction.
* Do not use a different mapgen mod. This will also cause issues

## Using custom structures
The structures are stored in the schems/ folder. The centre and island files are the centre island and player islands respectively. They are stored using Minetest's MTS files. These do not save metadata, so you cannot prefill chests. If you modify these, please update the offsets for the islands:
* Centre island: Lines `96-98`
* Player island: Lines `109-111`