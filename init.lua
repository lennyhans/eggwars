----------------------------------------------------
-- Eggwars by wilkgr
-- Licensed under the AGPL v3
-- You MUST make any changes you make open source
-- even if you just run it on your server without publishing it
-- Supports a maximum of 8 players currently
----------------------------------------------------

dofile(minetest.get_modpath("eggwars").."/egg2.lua")

minetest.set_mapgen_params({mgname = "singlenode"})
local i = 1;
local players_waiting = {};
local waiting_area = {x=0,y=150,z=0};
local islands = {{x=50,y=100,z=0},{x=-50,y=100,z=0},{x=0,y=100,z=50},{x=50,y=100,z=50},{x=-50,y=100,z=50},{x=-50,y=100,z=-50},{x=0,y=100,z=-50},{x=50,y=100,z=-50}}
local player_i = {};
local players_alive = {};

function StartsWith (String, Start)
    return string.sub (String, 1, string.len (Start)) == Start
end

function EndsWith (String, End)
    return End == '' or string.sub (String, -string.len (End)) == End
end

--[[minetest.register_privilege ("exterminate", {
    description = "Can use /exterminate" ,
    give_to_singleplayer = false
})
]]

--[[
chestrefill = function ()
  for i=1, #islands do
    local items = {"default:diamond","default:wood","default:wood","default:stick","default:wood","default:wood","default:mesecrystal","default:sword_diamond","default:sword_stone","default:sword_stone","default:sword_stone","default:sword_stone"}
    minetest.set_node(islands[i],{name = "default:chest"})
    math.randomseed(os.clock()*100000000000)
    math.random()
    local item_no = math.random(1, 4)
    local n = 0
    while n < item_no do
      math.randomseed(os.clock()*100000000000)
      math.random()
      local item = math.random(1, #items)
      local inv = minetest.get_inventory({type="node", pos=islands[i]})
      inv:add_item("main",items[item])
      n = n + 1;
    end
  end
end
]]


removeDrops = function ()
    local pos  = {x=0,y=1100,z=00}
    local ent  = nil
    local tnob = minetest.get_objects_inside_radius (pos, 60)
    local nnob = table.getn (tnob)

    if (nnob > 0) then
        for foo,obj in ipairs (tnob) do
            ent = obj:get_luaentity()
            if ent ~= nil and ent.name ~= nil then
                if StartsWith (ent.name, "__builtin:item") then
                    obj:remove()
                end
            end
        end
    end
end

reset = function ()
  removeDrops();
  minetest.delete_area({x=-80, y=50, z=-80}, {x=80,y=150, z=80})
  players_alive = {};
end


-- MTS place: y-7, z-7, x-7
islandspawn = function (n)
  --minetest.set_node(islands[n],{name = "eggwars:egg"})
  local schem_l = table.copy(islands[n]);
  schem_l.y = schem_l.y - 6
  schem_l.x = schem_l.x -7
  schem_l.z = schem_l.z -7
  local schempath = minetest.get_modpath("eggwars").."/schems";
  local name = "island"
  minetest.debug(minetest.pos_to_string(schem_l))
  minetest.place_schematic(schem_l, schempath.."/"..name..".mts")
end

minetest.register_node("eggwars:egg", {
	tiles = {
		"default_stone.png",
		"default_stone.png",
		"default_stone.png",
		"default_stone.png",
		"default_stone.png",
		"default_stone.png"
	},
  groups = {crumbly = 3},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.1875, -0.5, -0.1875, 0.1875, 0.5, 0.1875}, -- NodeBox1
			{-0.25, -0.4375, -0.25, 0.25, 0.4375, 0.25}, -- NodeBox2
			{-0.3125, -0.375, -0.3125, 0.3125, 0.3125, 0.3125}, -- NodeBox3
			{-0.375, -0.3125, -0.375, 0.375, 0.1875, 0.375}, -- NodeBox4
			{-0.4375, -0.25, -0.4375, 0.4375, 0.0625, 0.4375}, -- NodeBox5
			{-0.5, -0.125, -0.5, 0.5, -0.0625, 0.5}, -- NodeBox6
		}
	}
})

minetest.register_node("eggwars:goldspawn1", {
  tiles = {"default_gold_block.png"},
  groups = {crumbly = 3} --Temporary, should be unbreakable
})

minetest.register_node("eggwars:stickspawn", {
  tiles = {"default_wood.png"},
  groups = {crumbly = 3} --Temporary, should be unbreakable
})

minetest.register_node("eggwars:diamondspawn", {
  tiles = {"default_diamond_block.png"},
  groups = {crumbly = 3} --Temporary, should be unbreakable
})

minetest.register_node("eggwars:steelspawn1", { --Slower spawn rate; for player islands
  tiles = {"default_steel_block.png"},
  groups = {crumbly = 3} --Temporary, should be unbreakable
})

minetest.register_node("eggwars:steelspawn2", { --Faster spawn rate; for center island(s)
  tiles = {"default_diamond_block.png"},
  groups = {crumbly = 3} --Temporary, should be unbreakable
})

minetest.register_node("eggwars:cobblespawn", {
  tiles = {"default_cobble.png"},
  groups = {crumbly = 3} --Temporary, should be unbreakable
})

minetest.register_abm({
	nodenames = {"eggwars:diamondspawn"},
	interval = 8,
	chance = 1,
	action = function(pos)
		pos.y = pos.y + 1
		minetest.add_item(pos,"default:diamond")
	end,
})

minetest.register_abm({
	nodenames = {"eggwars:cobblespawn"},
	interval = 5,
	chance = 1,
	action = function(pos)
		pos.y = pos.y + 1
		minetest.add_item(pos,"default:cobble")
	end,
})

minetest.register_abm({
	nodenames = {"eggwars:steelspawn1"},
	interval = 10,
	chance = 1,
	action = function(pos)
		pos.y = pos.y + 1
		minetest.add_item(pos,"default:steel_ingot")
	end,
})

minetest.register_abm({
	nodenames = {"eggwars:steelspawn2"},
	interval = 5,
	chance = 1,
	action = function(pos)
		pos.y = pos.y + 1
		minetest.add_item(pos,"default:steel_ingot")
	end,
})

minetest.register_abm({
	nodenames = {"eggwars:stickspawn"},
	interval = 8,
	chance = 1,
	action = function(pos)
		pos.y = pos.y + 1
		minetest.add_item(pos,"default:stick")
	end,
})

minetest.register_on_dieplayer(function(player)
  local block = minetest.get_node(player_i[player:get_player_name()]).name
  minetest.chat_send_all(minetest.pos_to_string(player_i[player:get_player_name()]))
  minetest.chat_send_all(minetest.get_node(player_i[player:get_player_name()]).name)

  if minetest.get_node(player_i[player:get_player_name()]).name ~= "eggwars:egg" then
    minetest.chat_send_all("*** "..player:get_player_name().." is " .. minetest.colorize('red','OUT')..' and now a spectator.')
    --minetest.set_player_privs(player:get_player_name(),{fly=true,fast=true,noclip=true}) --Give player fly, fast and noclip. Revokes other privs.
    for j=1,#players_alive do
      if players_alive[j] == player:get_player_name() then
        table.remove(players_alive[j])
      end
    end
    if #players_alive == 1 then
      minetest.chat_send_all(minetest.colorize("green", "*** " .. players_alive[1] .. " has won!"))
    end
    player:set_nametag_attributes({color = {a = 255, r = 0, g = 0, b = 0}}) --Make nametag invisible
    player:set_properties({visual_size={x=0, y=0}}) --Make player invisible
  else
    minetest.chat_send_all("*** "..player:get_player_name().." paid Hades a visit.")
    --player:set_player_privs({interact=true,shout=true})
  end
end)

minetest.register_on_respawnplayer(function(player)
  local respawn_pos = table.copy(player_i[player:get_player_name()])
  respawn_pos.y = respawn_pos.y + 2
  minetest.after(0.1,function () player:setpos(respawn_pos) end)
end)

--[[
minetest.register_abm({
	nodenames = {"eggwars:goldspawn1"},
	interval = 10,
	chance = 1,
	action = function(pos)
		pos.y = pos.y + 1
		minetest.add_item(pos,"default:gold_ingot")
	end,
})
]]

minetest.register_on_joinplayer(function(player)

  local player_n = player:get_player_name()
  local privs = minetest.get_player_privs(player_n)
  privs.fly = true
  minetest.set_player_privs(player_n, privs)
  if i >= 8 then
    minetest.set_node(waiting_area, {name = "default:dirt_with_grass"})
    player:setpos(waiting_area)
    players_alive[i] = player_n;
  else
    player:setpos(islands[i])
    player_i[player_n] = islands[i];
    islandspawn(i)
    i = i + 1;
  end
end)

minetest.debug('James threw an egg at Mary. How did she respond?')
minetest.debug('"EGGWARS"')
minetest.debug('------------------------------------------------')
minetest.debug('Consider eggwars loaded.')
