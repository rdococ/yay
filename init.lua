local function walkable(pos)
	return minetest.registered_nodes[minetest.get_node(pos).name].walkable
end

minetest.register_entity("yay:blob", {
	hp_max = 1,
	physical = true,
	weight = 5,
	collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
	visual = "cube",
	visual_size = {x=1, y=1},
	mesh = "model",
	textures = {
		"yayblob_skin.png",
		"yayblob_skin.png",
		"yayblob_skin.png^yayblob_eye_open.png",
		"yayblob_skin.png^yayblob_eye_open.png",
		"yayblob_skin.png",
		"yayblob_skin.png^yayblob_mouth_closed.png"
	}, -- number of required textures depends on visual (+Y, -Y, +X, -X, +Z, -Z)
	colors = {}, -- number of required colors depends on visual
	spritediv = {x=1, y=1},
	initial_sprite_basepos = {x=0, y=0},
	is_visible = true,
	makes_footstep_sound = false,
	automatic_rotate = false,
	
	timer = 0,
	old_velocity = {x = 0, y = 0, z = 0},
	blob_size = 0,
	
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		
		local v = self.object:getvelocity()
		local pos = self.object:getpos()
		local t = {
			"yayblob_skin.png",
			"yayblob_skin.png",
			"yayblob_skin.png^yayblob_eye_open.png",
			"yayblob_skin.png^yayblob_eye_open.png",
			"yayblob_skin.png^yayblob_mouth_closed.png",
			"yayblob_skin.png"
		}
		
		local closeEyes = (self.timer % 5) < 0.2
		local openMouth = (self.timer % 3) < 0.7
		local bounce = (self.timer % 7) < 0.05
		
		local ov = self.old_velocity
		local difference = vector.subtract(v, ov)
		
		local vThreshold = 0.002
		local dThreshold = 0.01
		
		local xCollided, yCollided, zCollided = (math.abs(v.x) < vThreshold) and (math.abs(ov.x) > dThreshold),
			(math.abs(v.y) < vThreshold) and (math.abs(ov.y) > dThreshold),
			(math.abs(v.z) < vThreshold) and (math.abs(ov.z) > dThreshold)
		
		--[[local rounded = {x = math.floor(pos.x + 0.5), y = math.floor(pos.y + 0.5), z = math.floor(pos.z + 0.5)}
		local pxOffset, pzOffset, nxOffset, nzOffset =
			vector.add(rounded, {x = 1, y = 0, z = 0}),
			vector.add(rounded, {x = 0, y = 0, z = 1}),
			vector.add(rounded, {x = -1, y = 0, z = 0}),
			vector.add(rounded, {x = 0, y = 0, z = -1})
		
		local xCollided, yCollided, zCollided =
			(not walkable(pxOffset) and v.x > 0) and (not walkable(nxOffset) and v.x < 0),
			false,
			(not walkable(pzOffset) and v.z > 0) and (not walkable(nzOffset) and v.z < 0)]]
		
		if closeEyes then
			t[3] = "yayblob_skin.png^yayblob_eye_closed.png"
			t[4] = t[3]
		end
		if openMouth then
			t[5] = "yayblob_skin.png^yayblob_mouth_open.png"
		end
		
		local size = self.blob_size
		
		collisionbox = {
			-size / 2,
			-size / 2,
			-size / 2,
			size / 2,
			size / 2,
			size / 2
		}
			
		self.object:set_properties({
			collisionbox = collisionbox,
			visual_size = {x = size, y = size},
			textures = t
		})
		
		local v = {x = (xCollided and -ov.x or v.x), y = (yCollided and (ov.y < 0 and 5 or v.y) or v.y), z = (zCollided and -ov.z or v.z)}
		v = vector.subtract(v, {x = 0, y = dtime * 10, z = 0})
		self.object:setvelocity(v)
		
		self.object:setyaw(math.atan2(-v.x, v.z))
		self.old_velocity = self.object:getvelocity()
	end,
	
	get_staticdata = function (self)
		return minetest.serialize({
			timer = self.timer,
			old_velocity = self.old_velocity,
			blob_size = self.blob_size
		})
	end,
	on_activate = function (self, data)
		if data == "" then
			local angle = ((math.floor(math.random() * 4) + 0.5) / 4) * math.pi * 2
			local velocity = {
				x = math.cos(angle) * 3,
				y = 0,
				z = math.sin(angle) * 3
			}
			
			self.object:setyaw(angle + (math.pi / 2))
			self.object:setvelocity(velocity)
			
			self.old_velocity = velocity
			
			local size = (math.random() * 0.5) + 0.5
			self.blob_size = size
			
			collisionbox = {
				-size / 2,
				-size / 2,
				-size / 2,
				size / 2,
				size / 2,
				size / 2
			}
			
			self.object:set_properties({
				collisionbox = collisionbox,
				visual_size = {x = size, y = size}
			})
			
			self.object:setpos(vector.add(self.object:getpos(), {x = 0, y = size / 2, z = 0}))
		else
			local data = minetest.deserialize(data)
			
			self.timer = data.timer
			self.old_velocity = data.old_velocity
			self.blob_size = data.blob_size
		end
	end
})

minetest.register_node("yay:blob_block", {
	description = "Yay block",
	tiles = {
		"yayblob_skin.png",
		"yayblob_skin.png",
		"yayblob_skin.png^yayblob_eye_open.png",
		"yayblob_skin.png^yayblob_eye_open.png",
		--"yayblob_skin.png^yayblob_mouth_closed.png",
		"yayblob_skin.png",
		"yayblob_skin.png^yayblob_mouth_open.png"
	},
	paramtype2 = "facedir",
	groups = {oddly_breakable_by_hand = 1}
})

minetest.register_craftitem("yay:blob", {
	description = "Yay blob spawner",
	inventory_image = minetest.inventorycube("yayblob_skin.png", "yayblob_skin.png^yayblob_mouth_open.png", "yayblob_skin.png^yayblob_eye_open.png"),
	
	on_place = function(itemstack, placer, pointed_thing)
		itemstack:take_item(1)
		minetest.add_entity(pointed_thing.above, "yay:blob")
		
		return itemstack
	end
})
