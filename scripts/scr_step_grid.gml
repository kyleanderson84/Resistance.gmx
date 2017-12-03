///scr_step_grid(x_origin, y_origin, tile_size)

var x_origin = argument0 div argument2
var y_origin = argument1 div argument2
var tile_size = argument2
var r_width = room_width div tile_size
var r_height = room_height div tile_size
var x_hero = obj_hero.x div tile_size
var y_hero = obj_hero.y div tile_size

step_grid = ds_grid_create(r_width, r_height)

ds_grid_clear(step_grid, 0)
ds_grid_set(step_grid, x_origin, y_origin, -2)

step_stack = ds_priority_create()

ds_priority_add(step_stack, y_origin * r_width + x_origin, point_distance(x_origin, y_origin, x_hero, y_hero))


while(ds_priority_size(step_stack)){
    var temp_location = ds_priority_delete_min(step_stack)
    var temp_x = temp_location mod r_width
    var temp_y = temp_location div r_width
    if( ds_grid_get(step_grid, temp_x, temp_y) == -2){
        var count = 1
    } else {
        var count = ds_grid_get(step_grid, temp_x, temp_y) + 1
    }
    
    for(var yy = -1; yy < 2; yy++){
        for(var xx = -1; xx < 2; xx++){
            if(ds_grid_get(step_grid, xx + temp_x, yy + temp_y) == 0 and place_meeting((xx + temp_x) * tile_size, (yy + temp_y) * tile_size, obj_blocked)){
                ds_grid_set(step_grid, xx + temp_x, yy + temp_y, -1)
            } else if(ds_grid_get(step_grid, xx + temp_x, yy + temp_y) == 0){
                ds_grid_set(step_grid, xx + temp_x, yy + temp_y, count)
                ds_priority_add(step_stack, (temp_y + yy) * r_width + xx + temp_x, point_distance(xx + temp_x, yy + temp_y, x_hero, y_hero))
            }
        }
    }
}

return step_grid
