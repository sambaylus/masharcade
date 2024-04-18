// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

#macro GROUNDED grounded
#macro AIRBORNE !grounded
#macro JUMPING yspeed < 0
#macro FALLING yspeed > 0
#macro MOVING (round(xmove) != 0)
#macro FACE_DIRECTION facing

function platformer_create(){
	xspeed = 0;
	xmove = 0;
	xmove_max = 2;
	moved = false;
	
	xpush = 0;
	
	knockback_speed = 0;
	knockback_direction = 0;
	
	push_direction = 0;
	push_speed = 0;
	
	xfriction = 1;
	move_friction = .25;
	//xdrag = 1;
	
	move_speed = .1;

	ground_friction = .75;
	air_friction = .9;
	
	yspeed = 0;
	yspeed_gravity = .25;
	
	jump_speed = 5;
	facing = 1;
	
	grounded = true;
	
	right_button = false;
	left_button = false;
	
	platform_id = noone;
	
	invulnerable = 0;
	hitstop = 0;
	hitstun = 0;
	
	can_move = function(_move_speed = 1, _max = 1, _ground_friction = .75, _air_friction = 1, _facelock = false)
	{
		var _move = _move_speed;
		var _hinput = (input.right - input.left);
		moved = abs(_hinput);
		
		var _traction = 1;
		var _limit = 1;
		if instance_exists(platform_id)
		{
			_traction *= platform_id.xtraction;
			_limit = platform_id.xlimit;
		}
		
		xmove += _hinput*_move*_traction;
		
		if !_facelock
		{
			if _hinput != 0
			{
				if facing != _hinput
					on_face_effect();
				facing = _hinput;
			}
		}
		
		xmove = clamp(xmove, -xmove_max*_limit, xmove_max*_limit);
	}
	
	on_face_effect = function(){};
	
	can_jump = function(_jump)
	{
		if input.jump_pressed
		and GROUNDED
		{
			jump(_jump);
		}
	}
	
	jump = function(_jump = jump_speed)
	{
		yspeed = -_jump;
		on_jump_effect();
	}
	
	on_jump_effect = function(){}
	on_land_sound = function(){};

	on_land = function(_instance)
	{
		if grounded = false
			on_land_effect();
		grounded = true;
		platform_id = _instance;
		if yspeed > 0
			yspeed = 0;
	};
	
	on_land_effect = function(){

	};
	
	on_headstomp = function(_instance){
		//sprite.squish();
	}
	
	check_death = function()
	{
		if life <= 0
		{
			on_death()
		}
	}
	
	on_death = function()
	{
		on_death_effect();
		instance_destroy();
	}
	
	on_death_effect = function()
	{
		show_debug_message("ded");
	}
	
	on_recover = function(){};
	
	platform_check_material = function(_tags)
	{
		var _check = asset_has_any_tag(platform_id.object_index, _tags, asset_object);
		return _check;
	}
	
	launch = function(_speed, _direction)
	{
		xpush = lengthdir_x(_speed, _direction);
		yspeed = lengthdir_y(_speed, _direction);
	}
	
	hit = function(_life = 0, _hitstop = 0, _hitstun = 30, _speed= 0, _direction = 0)
	{
		//instance_create_depth(x,bbox_top-24,depth-1,obj_number_alert);
		
		life -= _life;
		hitstop = _hitstop;
		hitstun = _hitstun;
		
		sprite.shove(8,,.001,.5,10);
		knockback_speed = _speed;
		knockback_direction = _direction;

		launch(knockback_speed, knockback_direction);
		
		if hitstun > 0
		{
			state.change("hitstun");	
		}

		return id;
	}
	
	on_hit_effect = function()
	{
		sprite.squish();
		var _instance = instance_create_depth(x,y,depth, obj_effect_burst);
		_instance.target = id;
		return true;
	}
	
	hurt = function(_life = 1, _check_death = true)
	{
		instance_create_depth(x,bbox_top - 24, depth-1,obj_number_alert);

		life -= _life;

		if _check_death
			check_death();
			
		return id;
	}
	
	/*hitstun = function(_hitstop = 5)
	{
		hitstop = _hitstop;
		return id;
	}
	*/
	
	knockback = function(_speed = 5, _direction = 90)
	{
		if !instance_exists(self)
			return -1;
		knockback_speed = _speed;
		knockback_direction = _direction;
		return id;
	}
	
	on_knockback_effect = function(){};
}

function platformer_step(){

	if hitstop > 0
	{
		hitstop -= 1;
		return;
	}
	
	yspeed += yspeed_gravity;
	
	repeat(abs(yspeed))
	{
		var _collision = false;
		
		if yspeed > 0
		{
			with obj_platform
			{
				if !place_meeting(x, y, other)
				and place_meeting(x, y - 1, other)
				{
					other.yspeed = 0;
					_collision = true;
					break;
				}
			}
		}
		
		if _collision
			break;
			
		if place_meeting(x, y + sign(yspeed), obj_solid)
		{
			yspeed = 0;
			break;
		}
		else
		{
			y += sign(yspeed);	
		}
	}
	
	xspeed += xmove + xpush;
	
	var _collision = noone;
	
	repeat(abs(xspeed))
	{
		if !place_meeting(x + sign(xspeed), y + 1, obj_solid)
		and place_meeting(x + sign(xspeed), y + 2, obj_solid)
		{
			y += 1;
		}
			
		if place_meeting(x + sign(xspeed), y, obj_solid)
		{
			if !place_meeting(x + sign(xspeed), y - 1, obj_solid)
			{	
				y -= 1;
			}
		}
		
		if !place_meeting(x + sign(xspeed), y, obj_solid)
		{
			x += sign(xspeed);
			xspeed -= sign(xspeed);
		}
		else
		{
			xspeed = 0;
			break;
		}
	}
	
	if GROUNDED
	{
		var _drag = 1;
			
		var _hinput = 0//input.right - input.left;
		/*
		if _hinput = 0
		{
			if instance_exists(platform_id)
			{
				_drag = platform_id.xfriction;
			}
			xmove *= _drag;
		}
		*/
		xmove *= _drag*.9;
		xpush *= _drag*.9;
	}
	else
	{
		xmove *= air_friction;
		//xpush *= air_friction;
	}
			
	moved = false;
}