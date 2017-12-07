///scr_find_path_stack(x_origin, y_origin, x_target, y_target, tile_size)

var x_origin = argument0 div argument4
var y_origin = argument1 div argument4
var tile_size = argument4
var r_width = room_width div tile_size
var r_height = room_height div tile_size
var x_target = argument2 div tile_size
var y_target = argument3 div tile_size

path_stack = ds_stack_create()

var step_grid = scr_step_grid(argument0, argument1, argument2, argument3, argument4)
var x_step = x_target
var y_step = y_target
var step_count = 99999
do{
    for(var yy = -1; yy < 2; yy++){
        for(var xx = -1; xx < 2; xx++){
            if(ds_grid_get(step_grid, x_step + xx, y_step + yy) > 0 and 
                ds_grid_get(step_grid, x_step + xx, y_step + yy) < step_count){
                    step_count = ds_grid_get(step_grid, x_step + xx, y_step + yy)
                    temp_x_step = x_step + xx
                    temp_y_step = y_step + yy
                    
            }
        }
    }
    ds_stack_push(path_stack, temp_y_step * ds_grid_width(step_grid) + temp_x_step)
    x_step = temp_x_step
    y_step = temp_y_step
} until(step_count == 1)

return path_stack
