///scr_proximety_grid(x_origin, y_origin, tile_size)

var x_origin = argument0 div argument2
var y_origin = argument1 div argument2
var tile_size = argument2
var r_width = room_width div tile_size
var r_height = room_height div tile_size
p_grid = ds_grid_create(r_width, r_height)

ds_grid_clear(p_grid, 0)

for(yy = 0; yy < r_height; yy++){
    for(xx = 0; xx < r_width; xx++){
        var distance = point_distance(x_origin, y_origin, xx, yy)
        ds_grid_set(p_grid, xx, yy, distance)
    }
}
return p_grid
