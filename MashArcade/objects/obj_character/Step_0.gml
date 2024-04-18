/// @description Insert description here
// You can write your code in this editor


platformer_step();

if keyboard_check_pressed(vk_space)
{
	yspeed = -5;	
}

if mouse_check_button_pressed(mb_left)
{
	x = mouse_x;
	y = mouse_y;
}