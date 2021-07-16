pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
function _init()
	counter = 0
	world_x = 0
	starting_x = 0
	drop_off_x = 32
	player_strt_y = 32
	player_strt_x = drop_off_x
	
	player = {
		["x"] = player_strt_x,
		["px"] = player_strt_x,
		["y"] = player_strt_y,
		["py"] = player_strt_y,
		["mv_speed"] = 1,
		["on_mission"] = false,
		["speed_x"] = 0,
		["speed_y"] = 0,
		["mvn_dir"] = false,
		["facing"] = "right",
		["vhc_front"] = 04,
		["civ_range"] = false,
		["civ_pkup"] = false,
		["water_cpct"] = 2,
		["rotor_health"] = 10,
		["top_speed_x"] = 4,
		["top_speed_y"] = 2,
		["ladder"] = 0,
		["ladder_empty"] = true,
		["dpl_ldd_pkup"] = false,
		["dpl_ldd_doof"] = false,
		["rescuing"] = false,
		["droping_off"] = false,
		["occ_limit"] = 2,
		["occ"] = 0,
		["fuel"] = 0.5,
		["rx1"] = 0,
		["ry1"] = 0,
		["rx2"] = 0,
		["ry2"] = 0,
	}

	screen = {
		1, -- start
		2, -- rotor
		3, -- human
		4, -- airplane
		5 -- game over
	}

	curr_screen = screen[1]
	fire_pcs_created = true
	civ_pcs_created = false

	btn_pressed = false
	mvn_y = false
	mvn_x = false
	left_btn = false
	right_btn = false
	down_btn = false
	up_btn = false

	water_drops = {}
	fire_pcs = {}
	ground_pcs = {}
	tree_pcs = {}
	civ_pcs = {}
	
	difficulty = rnd({"easy","normal","hard"})
	ranges = {
		["easy"] = {230,330,480},
		["normal"] = {250,350,500,700},
		["hard"] = {290,390,540,740,940}
	}
	
	mission_type = rnd({"sea","fire"})
	mission_ground = 20
	mission_p_front = 4
	mission_p_back = 3
	
	block_btns = false
	counter = 0	
end

function _draw()
	cls()
	
	if curr_screen == 1 then
		rectfill(0,0,127,127,8)
				
		for i=0, 15 do
			spr(25,0+i*8,0)
			spr(25,0+i*8,8)
			spr(24,0+i*8,16,1,1,false,true)
		end		
	
		print("pico rescue",42,50,0)
		print("pico rescue",41,49,7)
		
		print("press any key",37,80,7)
		
		for i=0, 15 do
			spr(24,0+i*8,104)
			spr(25,0+i*8,112)
			spr(25,0+i*8,120)
		end
		
	end
	
	if curr_screen == 5 then
		rectfill(0,0,127,127,0)
				
		for i=0, 15 do
			spr(41,0+i*8,0)
			spr(41,0+i*8,8)
			spr(40,0+i*8,16,1,1,false,true)
		end		
	
		print("game over",42,50,7)
				
		if (not block_btns) print("press any key",37,80,7)
		
		for i=0, 15 do
			spr(40,0+i*8,104)
			spr(41,0+i*8,112)
			spr(41,0+i*8,120)
		end
		
	end

	if curr_screen == 2 then
		rectfill(0,0,128,119,12)
		spr(6,drop_off_x,112)

		flip_spr = (player.facing == "right") and true or false
		tail_pos = (player.facing == "right") and player.x+8 or player.x-8

		spr(player.vhc_front,player.x,player.y,1,1,flip_spr)
		if (player.facing != false) spr(03,tail_pos,player.y,1,1,flip_spr)
		
		foreach(ground_pcs,draw_ground)
		foreach(civ_pcs,draw_civ)
		foreach(fire_pcs,draw_fire)
		foreach(fire_pcs,draw_smoke)
		foreach(fire_pcs,on_smoke)
		foreach(water_drops,draw_water)

		for i = 1, player.ladder do
			spr(1,player.x,player.y+i*8)
		end
	
	 for i = 0, player.rotor_health do
			rectfill(0,2,player.rotor_health,5,8)
		end
		
		for i = 0, player.fuel do
			rectfill(0,10,player.fuel,13, 11)
		end
		
		spr(32,0,15)
		print(player.occ,8,16,0)
		
		i=0
		for civ in all(civ_pcs) do
			spr(32,100,0+i*8)
			distance = (civ.on_board) and "on" or abs(flr(civ.x - player.x))
			arrow_flip = (civ.x > player.x) and true or false
			spr(37,107,0+i*8,1,1,arrow_flip,false)
			print(distance,116,1+i*8,5)
			i+=1
		end
	end
end

function _update()
	counter+=1
	
	if curr_screen == 1 then
		curr_screen = (btnp(1) or btnp(2) or btnp(0) or btnp(3) or btnp(4) or btnp(5)) and 2 or 1
	end
	
	if curr_screen == 5 then
		if counter % 150 == 0 then
			block_btns = false
		end
	
		if not block_btns then
			if
				btnp(1) or btnp(2) or
				btnp(0) or btnp(3) or
				btnp(4) or btnp(5)
			then
				_init()
			end
		end
	end
	
	if curr_screen == 2 then
	
		if (counter % 15 == 0) player.fuel -= 0.02
	
	 btn_pressed = (btn(1)) or (btn(2)) or (btn(0)) or (btn(3))
		mvn_y = btn(2) or btn(3)
		mvn_x = btn(0) or btn(1)
		right_btn = btn(0)
		left_btn = btn(1)
		up_btn = btn(2)
		down_btn = btn(3)
	
		create_ground()
		-- create_trees()
		if (not fire_pcs_created) create_fire()
		if (not civ_pcs_created) create_civ()
		if (not player.rescuing) move_rotor()
		upd_rotor_mvmt()
		upd_pkup_area()
		upd_ladder()
		move_dropoff()
		droping_off()
	
	 foreach(fire_pcs,update_fire)
		foreach(fire_pcs,move_fire)
		foreach(ground_pcs,move_ground)
		foreach(water_drops,move_water)
		foreach(civ_pcs,move_civ)
		foreach(civ_pcs,civ_on_range)
		foreach(civ_pcs,move_civ_on_range)
		foreach(civ_pcs,civ_climb_ladder)
	
		if
			player.fuel <= 0 or
			player.rotor_health <= 0
		then
			counter = 0
			curr_screen = 5
			block_btns = true
		end
	end
end
-->8
-- movement logic

function move_human()
	if (btn(1)) world_x+=player.mv_speed
	if (btn(0)) world_x-=player.mv_speed
	if (btn(3)) player.y+=player.mv_speed
	if (btn(2)) player.y-=player.mv_speed
end

function move_rotor()
	if right_btn then
		if player.px > world_x then
			if player.speed_x > 0 then
				player.speed_x -= 0.035
				player.facing = false
				player.vhc_front = 05
				world_x -= player.speed_x
			end
		else
			player.vhc_front = 04
			player.facing = "right"
			if (player.speed_x <= player.top_speed_x) player.speed_x += 0.025
			player.px = world_x
			world_x += player.speed_x
		end
	end

	if left_btn then
		if player.px < world_x then
			if player.speed_x > 0 then
				player.speed_x -= 0.035
				player.facing = false
				player.vhc_front = 05
				world_x += player.speed_x
			end
		else
			player.vhc_front = 04
			player.facing = "left"
			if (player.speed_x <= player.top_speed_x) player.speed_x += 0.025
			player.px = world_x
			world_x -= player.speed_x
		end
	end

	if up_btn	then
		if player.py < player.y then
			if player.speed_y > 0 then
				player.speed_y -= 0.035
				player.y += player.speed_y
			end
		else	
			player.mvn_dir = "up"
			if (player.speed_y <= player.top_speed_y) player.speed_y += 0.025
			player.py = player.y
			player.y -= player.speed_y
		end
	end

	if down_btn	and player.y < 120 then
		if player.py > player.y then
			if player.speed_y > 0 then
				player.speed_y -= 0.035
				player.y -= player.speed_y
			end
		else	
			player.mvn_dir = "down"
			if (player.speed_y <= player.top_speed_y) player.speed_y += 0.025
			player.py = player.y
			player.y += player.speed_y
		end
	end

	if (btnp(4)) drop_water()
end

function upd_rotor_mvmt()
 if player.px < world_x and mvn_x == false then
  player.px = world_x
  player.speed_x -= 0.025
  world_x += player.speed_x
 end

 if player.px > world_x and mvn_x == false then
  player.px = world_x
  player.speed_x -= 0.025
  world_x -= player.speed_x
 end

 if player.py < player.y and mvn_y == false then
  player.py = player.y
  player.speed_y -= 0.025
  player.y += player.speed_y
 end

 if player.py > player.y and mvn_y == false then
  player.py = player.y
  player.speed_y -= 0.025
  player.y -= player.speed_y
 end

	if (player.px > world_x) player.mvn_dir = "right"
	if (player.px < world_x) player.mvn_dir = "left"
	if (player.px == world_x) player.mvn_dir = false

	if player.speed_x < 0 then
		player.speed_x = 0
		player.px = world_x
	end

	if player.speed_y < 0 then
		player.speed_y = 0
		player.py = player.y
	end

	if (player.y < 0) then
		player.y = 0
		player.speed_y = 0
	end

	if (player.y > 88) then
		player.y = 88
		player.speed_y = 0
	end
end

function upd_pkup_area()
	player.px1 = player.x-8
	player.py1 = 112
	player.px2 = player.x+16
	player.py2 = 120
end
-->8
-- civilian logic

function create_civ()
	for k,v in pairs(ranges) do
		if k == difficulty then
			for value in all(v) do
				local civ = {}
				civ.x = value
				civ.y = 112
				civ.spr = 33
				civ.health = 10
				civ.on_range = false
				civ.rdy_to_climb_up = false
				civ.rdy_to_climb_down = false
				civ.on_board = false
				add(civ_pcs, civ)
			end
		end
	end	
	
	civ_pcs_created = true
end

function draw_civ(civ)
	if civ.on_board == false then
		spr(civ.spr,civ.x,civ.y)
	end
end

function move_civ(civ)
	if civ.on_board == false then
		if (player.mvn_dir == "left") civ.x += player.speed_x
		if (player.mvn_dir == "right") civ.x -= player.speed_x
	end
end

function civ_on_range(civ)
	if civ.on_board == false then
		if
			civ.x >= player.px1-2 and
			civ.x <= player.px2 and
			civ.y >= 112 and
			civ.y <= 120
		then
			civ.on_range = true
		else
			civ.on_range = false
		end
	end
end

function move_civ_on_range(civ)
	if civ.on_board == false then
		if civ.on_range then
			civ.spr = 34
			--if (player.x < civ.x) civ.x -= 0.15
			--if (player.x > civ.x) civ.x += 0.15
			
			if
				civ.x+4 >= player.x and
				civ.x+4 <= player.x+8 and
				player.y >= 88
			then
				civ.rdy_to_climb_up = true
				player.dpl_ldd_pkup = true
			else
				civ.rdy_to_climb_up = false
				player.dpl_ldd_pkup = false
			end
		else
			civ.spr = 33
		end
	end
end

function upd_ladder()
	if counter%30 == 0 then
		if player.dpl_ldd_pkup  or  player.dpl_ldd_doof then
			if (player.ladder<3) player.ladder += 1
		end
		if not player.dpl_ldd_pkup and not player.dpl_ldd_doof and counter%30 == 0 then
			if (player.ladder>0) player.ladder -= 1
		end
	end
end

function civ_climb_ladder(civ)
	if civ.on_board == false then
		if
			player.ladder == 3 and
			civ.rdy_to_climb_up and
			player.occ < player.occ_limit
		then
			if (civ.y > player.y) civ.y -= 0.25
			player.rescuing = true

			if civ.y == player.y then
				civ.on_board = true
				civ.rdy_to_climb_up = false
				player.dpl_ldd_pkup = false
				player.rescuing = false
				player.occ += 1
			end
		end
	end
end

function droping_off()
	if
		player.x >= drop_off_x and
		player.x < drop_off_x+8 and
		player.y >= 88
	then
		player.dpl_ldd_doof = true
	else
		player.dpl_ldd_doof = false
	end

	for civ in all(civ_pcs) do
		if civ.on_board  then
			if
				player.ladder == 3 and
				civ.on_board and
				player.dpl_ldd_doof and
				player.ladder_empty == true
			then
				civ.rdy_to_climb_down = true
				civ.on_board = false
				player.rescuing = true
				player.ladder_empty = false
			end
		end
		if
			civ.rdy_to_climb_down and
			not civ.on_board 			
		then
			if (civ.y < 112) civ.y += 0.25

			if civ.y >= 112 then
				del(civ_pcs,civ)
				player.rescuing = false
				player.occ -= 1
				player.ladder_empty = true
			end
		end
	end
end


-->8
-- scenery logic

function create_trees()
	if player.speed_x > 1 then
		if counter%30==0 and flr(rnd(2)) == 1 then
			if (player.facing == "right") x = -8
			if (player.facing == "left") x = 128
			
			local tree = {}
			tree.x = x
			tree.y = 112
			add(tree_pcs, tree)
		end
	end
end

function create_ground()
	for i = count(ground_pcs), 16 do
		local ground = {}
		ground.x = starting_x*1
		ground.y = 120
		add(ground_pcs, ground)
		starting_x+=8
	end
end

function draw_ground(ground)
	spr(20,ground.x,ground.y)
end

function move_ground(ground)
	if (player.mvn_dir == "left") ground.x += player.speed_x
	if (player.mvn_dir == "right") ground.x -= player.speed_x

	if (ground.x < -8) ground.x += 136
	if (ground.x > 128) ground.x -= 136
end

function move_dropoff()
	if (player.mvn_dir == "left") drop_off_x += player.speed_x
	if (player.mvn_dir == "right") drop_off_x -= player.speed_x
end
-->8
-- fire and smoke logic

function create_fire()
	for i = count(fire_pcs), 0 do
		local fire = {}
		fire.x = 32
		fire.y = 112
		fire.smk_mh = 3
		fire.smk_h = 0
		fire.smk_mw = 3
		fire.smk_w = 0
		fire.smk_x1 = 0
		fire.smk_x2 = 0
		fire.smk_y1 = 0
		fire.smk_y2 = 0
		add(fire_pcs, fire)
	end
	fire_pcs_created = true
end

function draw_fire(fire)
	spr(17,fire.x,fire.y)
end

function update_fire(fire)
	if counter%15==0 
	and fire.smk_h < fire.smk_mh then
		fire.smk_h+=1
	end

	if fire.smk_h == fire.smk_mh then
		if counter%15==0 
		and fire.smk_w < fire.smk_mw then
			fire.smk_w+=1
		end
	end

	if fire.smk_w > 0 then
		fire.smk_x1 = fire.x-fire.smk_w*8
		fire.smk_y1 = fire.y-fire.smk_h*8-2
		fire.smk_x2 = fire.x+fire.smk_w*8+8
		fire.smk_y2 = fire.y-16
	end
end

function draw_smoke(fire)
	for i = 1, fire.smk_h do
		spr(18,fire.x,fire.y-i*8)
	end
	for i = 1, fire.smk_w do	
		spr(18,fire.x-i*8,fire.y-24)
		spr(18,fire.x+i*8,fire.y-24)
	end
end

function on_smoke(fire)
	if
		player.x >= fire.smk_x1 and
		player.x <= fire.smk_x2 and
		player.y >= fire.smk_y1 and
		player.y <= fire.smk_y2
	then
		player.rotor_health -= 0.015
	end
end

function move_fire(fire)
	if (player.mvn_dir == "left") fire.x += player.speed_x
	if (player.mvn_dir == "right") fire.x -= player.speed_x
end
-->8
-- water logic

function drop_water()
	local water = {}
	water.x = player.x
	water.y = player.y + 8
	water.speed = 0
	add(water_drops,water)
end

function draw_water(water)
	spr(19,water.x,water.y,1,1,false,true)
end

function move_water(water)
 if (water.speed < 2) water.speed += 0.15
 water.y += water.speed
	if (player.mvn_dir == "left") water.x += player.speed_x
	if (player.mvn_dir == "right") water.x -= player.speed_x

 for fire in all(fire_pcs) do
	 if
	 	water.x >= fire.x-2 and
	 	water.x <= fire.x+10 and
	 	water.y >= fire.y and
	 	water.y <= fire.y+8
		then
			del(fire_pcs,fire)
		end
 end

 if (water .y >= 116) del(water_drops,water)
end
__gfx__
b000333000d00d000000300000b00000000000000000000000000000000000000004f000ff44f4ff000000000000000000000000000000000000000000000000
0b03000300dddd000000b0000b3b0000bbbbbb0000bbbb0000000000000000044444000005454450000000000000000000000000000000000000000000000000
0033333300d00d00000030000b3b000b3331c7b00b7777b0006ee000000000004cc700000c1c11c0000000000000000000000000000000000000000000000000
03bbbbb300dddd00000030000053bbb33331ccb00bccccb00068ee700000000041cc066777677677000000000000000000000000000000000000000000000000
03bbbbb300d00d000000b00000053333333311cbb311113b006888e0767000066555766776666567000000000000000000000000000000000000000000000000
03bbbbb300dddd000000300000005555555533300333333000688000066766656767666007676660000000000000000000000000000000000000000000000000
03bbbbb300d00d000000b00000000000006006000060060000600000005655555555555005655650000000000000000000000000000000000000000000000000
0033333000dddd000000d00000000000055555600050050000600000000515515115150000511500000000000000000000000000000000000000000000000000
08800880000000000600600000000000bbbbbbbb0004200000b3b300777777770000000099aaaaa9000000000000000000000000000000000000000000000000
8ee887780000000000600060000000003b333b3b0004200003b33b30c7ccc7c70000000099aaaaa9000000000000000000000000000000000000000000000000
8eeeee780a0a00a0060606060707007033333333000420003b3bb3331cc1c1cc0000000099aaaaa9000000000000000000000000000000000000000000000000
8eeeeee809aaa99060666060077c77c03939399300042000b3bb33b3111c1c110002900099aaaaa9000000000000000000000000000000000000000000000000
8eeeeee80aa9aaa0060606060cccccc099929293000420003b33b333c1c1c1cc0029990099aaaaa9000000000000000000000000000000000000000000000000
08eeee8009989990600060000cc1ccc022222222000440003b3b33b3111111110299a99099aaaaa9000000000000000000000000000000000000000000000000
008ee80009889890060606000c11c1c0222222220042420033b3b33311111111299aaa9999aaaaa9000000000000000000000000000000000000000000000000
000880000888888000606060011111102222222204222220033333301111111199aaaaa999aaaaa9000000000000000000000000000000000000000000000000
0000000000ffff0000ffff0000ffff0000ffff0000000000006d5076766635500000000066777776000000000000000000000000000000000000000000000000
0000000000fcec00f0fcec0ff0fcec0000fcec0f00009990067cc5bbbbbbb3350000000066777776000000000000000000000000000000000000000000000000
00ffff0000feef0050feef0550feef0000feef050099aa900dccc5bbbbbb33350000000066777776000000000000000000000000000000000000000000000000
00fcec00055dd550055dd550055dd550055dd55009aaa90066ddd6ddbbb333350005600066777776000000000000000000000000000000000000000000000000
00feef005055550500555500005555055055550009aaa90066666653333333350056660066777776000000000000000000000000000000000000000000000000
00ffff00f0f55f0f00f55f0000f55ffffff55f000099aa90d666d1533336d1310566766066777776000000000000000000000000000000000000000000000000
0000000000f00f0000f00f0000f000f00f000f0000009990055dd151155dd1505667776666777776000000000000000000000000000000000000000000000000
0000000000f00f0000f00f0000f0000000000f000000000000011100000111006677777666777776000000000000000000000000000000000000000000000000
__label__
bb00bbb0bbb00000b000b000bb00bbb00000b000bb000000bbb0bbb0bbb0bbb00000bbb00000bbb0000000000000000000000000000000000000000000000000
0b00b000b0b00000b000b0000b0000b00000b0000b000000b0b0b000b0b000b0000000b00000b0b0000000000000000000000000000000000000000000000000
0b00bbb0b0b00000bbb0bbb00b0000b00000bbb00b000000b0b0bbb0b0b000b00000bbb00000b0b0000000000000000000000000000000000000000000000000
0b0000b0b0b00000b0b0b0b00b0000b00000b0b00b000000b0b000b0b0b000b00000b0000000b0b0000000000000000000000000000000000000000000000000
bbb0bbb0bbb00b00bbb0bbb0bbb000b00000bbb0bbb00b00bbb0bbb0bbb000b00000bbb00000bbb0000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb00bb00bbb0b0000bb00000bbb0bbb0b0b0bbb000000000b0b0bbb00000000000000000bbb0bbb0b0b0bbb000000000bbb0bbb0b0b0bbb00000000000000000
b000b0b00b00b00000b000000b00b0b0b0b0b00000000000b0b0b0b000000000000000000b00b0b0b0b0b000000000000b00b0b0b0b0b0000000000000000000
b000b0b00b00b00000b000000b00bb00b0b0bb0000000000b0b0bbb000000000000000000b00bb00b0b0bb00000000000b00bb00b0b0bb000000000000000000
b000b0b00b00b00000b000000b00b0b0b0b0b00000000000b0b0b00000000000000000000b00b0b0b0b0b000000000000b00b0b0b0b0b0000000000000000000
bb00b0b0bbb0bbb00bb000000b00b0b00bb0bbb0000000000bb0b00000000000000000000b00b0b00bb0bbb0000000000b00b0b00bb0bbb00000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000000000000000000100000000000000000000000000010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
