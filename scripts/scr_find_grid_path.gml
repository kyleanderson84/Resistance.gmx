///scr_find_grid_path(id, target_x, target_y, diag, cell_size)


/*******************************************************/
/* Script made by Jonathan from www.naztail.com */
/*******************************************************/


/*
The instance with the id(argument0) will find a path on a grid from its position to target_x and target_y
Set diag to true if diagonal movement is allowed. False if not.
Cell_size is the size of your tile/grid. 32 for this example.
If a path is found, all coordinates will be kept on a ds_stack.
If no path is found, script will end.
That stack can be used by that instance to move or anything you could think of.
*/

var cell_size = argument4;
var grid_width = room_width/cell_size;
var grid_height = room_height/cell_size;

var fx = argument0.x div cell_size; //from x
var fy = argument0.y div cell_size; //from y
var tx = argument1 div cell_size; //to x
var ty = argument2 div cell_size;//to y

if(fx == tx && fy == ty)
{
exit; //We are already at destination!
}


var path_stack = ds_stack_create();
var tmp_grid = ds_grid_create(grid_width, grid_height);
ds_grid_clear(tmp_grid, 0);
//On that grid, a value of -1 will be a blocked cell. All other values will be the distance(step) they are from the calling starting cell.
var tmp_list;

tmp_list[0]= ds_list_create();
tmp_list[1]= ds_list_create();


/*
The next part is very important. You need to set which cells is blocked.
Here, we block the cell that the instance(argument0) is standing on and each cell that an obj_wall is on.
(Note that using objects to make walls is a bad idea but it's easier to understand for this example.)
Note that we are using 'div cell_size' because we want to convert real coordinates to our ds_grid coordinates.
*/
with(argument0)
{
ds_grid_set(tmp_grid, x div cell_size , y div cell_size , -1);
}

with(obj_blocked)
{
ds_grid_set(tmp_grid, x div cell_size , y div cell_size , -1);
}
with(obj_player)
{
ds_grid_set(tmp_grid, x div cell_size, y div cell_size, 0)
}
if(ds_grid_get(tmp_grid, tx, ty) == -1) //If we can't move on target cell, exit.
{
show_debug_message(" there!");
ds_list_destroy(tmp_list[0]);
ds_list_destroy(tmp_list[1]);
ds_grid_destroy(tmp_grid);
ds_stack_destroy(path_stack);
exit;
}


/*Feel free to add anything you want that could block the instance. (water, fire, doors, holes, enemies, etc...)


Now, let's start our pathfinding!
What we will do is to scan around cells listed on first list(tmp_list_[0]) and if a cell is not blocked, we add it to the second list(tmp_list[1])
and mark them with a value of of cv+1 (it's 1 step further from current cell).
Then we'll do the same with the second list and mark new cell around on the first list...and again, and again
Until the instance is blocked or has reached the target cell.
*/

var cv = 1; //current distance value
var cl = 0; //current tmp_list to use.
ds_list_add(tmp_list[cl], fx, fy); //This is the first cell that we will looking around.
var blocked = false; //If the path is block.
var reached = false; //If the target cell is reach.

var cx, cy, tc, sx, sy;

do
{
    do
    {
    tc = 1;
    cx = ds_list_find_value(tmp_list[cl], 0);
    cy = ds_list_find_value(tmp_list[cl], 1);
    
    repeat(2)
    {
    ds_list_delete(tmp_list[cl], 0);
    }
    
        repeat(2) //That part looks for cells: up, down, right, left
        {
        sx = cx+tc;
        sy = cy    ;        
        
            if(sx > -1 && sx < grid_width && ds_grid_get(tmp_grid, sx, sy) == 0)
            {
            ds_grid_set(tmp_grid, sx, sy, cv);
            ds_list_add(tmp_list[!cl], sx);
            ds_list_add(tmp_list[!cl], sy);
            }
            
            if(sx == tx && sy == ty)
            {
            reached = true;
            break;
            }
            
        sx = cx;
        sy = cy+tc;
        
            if(sy > -1 && sy < grid_height && ds_grid_get(tmp_grid, sx, sy) == 0)
            {
            ds_grid_set(tmp_grid, sx, sy, cv);
            ds_list_add(tmp_list[!cl], sx);
            ds_list_add(tmp_list[!cl], sy);
            }
            
            if(sx == tx && sy == ty)
            {
            reached = true;
            break;
            }
            
        tc = -1;
        }
        
        if(argument3) //That part handle diagonals the same way as above: (if allowed)
        {
        tc = 1;
        
            repeat(2)
            {
            sx = cx+tc;
            sy = cy+tc;
            
                if(sx > -1 && sx < grid_width && sy > -1 && sy < grid_height && ds_grid_get(tmp_grid, sx, sy) == 0)
                {
                ds_grid_set(tmp_grid, sx, sy, cv);
                ds_list_add(tmp_list[!cl], sx);
                ds_list_add(tmp_list[!cl], sy);
                }
                
                if(sx == tx && sy == ty)
                {
                reached = true;
                break;
                }
                
            sx = cx+tc;
            sy = cy-tc;
            
                if(sx > -1 && sx < grid_width && sy > -1 && sy < grid_height && ds_grid_get(tmp_grid, sx, sy) == 0)
                {
                ds_grid_set(tmp_grid, sx, sy, cv);
                ds_list_add(tmp_list[!cl], sx);
                ds_list_add(tmp_list[!cl], sy);
                }
                
                if(sx == tx && sy == ty)
                {
                reached = true;
                break;
                }
                
            tc = -1;
            }
        }
        
        if(reached)
        {        
        break;
        }
    }
    until(ds_list_empty(tmp_list[cl]))

    if(reached)
    {        
    break;
    }

    if(ds_list_empty(tmp_list[!cl]))
    {
    blocked = true;
    break;
    }

cv += 1;
cl = !cl;
}
until(blocked || reached)


//Are we block? If yes, you have to decide what to do. Simply exit the script or search for another cell around the target or anything you could think of. Your choice.
if(blocked)
{
show_message('No path found!');
ds_list_destroy(tmp_list[0]);
ds_list_destroy(tmp_list[1]);
ds_grid_destroy(tmp_grid);
ds_stack_destroy(path_stack);
exit;
}



//That part is only for debug purpose. It copies the tmp_grid to obj_player to clearly view the distance of each cells.(in square)
//with(obj_player)
//{
//ds_grid_copy(Debug_Grid, tmp_grid);
//}



/*
At this point, the value of cv is equal to the number of steps to our target.
What we need to do now is to backtrack from our target and decrease cv by 1 and add all coordinates of cells on the stack.
*/

cx = tx;
cy = ty;

var rnd_list, rnd_pos;
rnd_list = ds_list_create();
ds_stack_push(path_stack, ty, tx);//This will be our LAST step: the x and y of the target.

//We will scan around the current_cell and add all matching cell to a rnd_list, shuffle that list and pick a random cell to push it on our stack.

var xx, yy;

while(cv>1)
{
cv-=1;

for(yy=-1; yy<2; yy++)
{
    for(xx=-1; xx<2; xx++)
    {
    sx = cx+xx;
    sy = cy+yy;
        
        if(sx > -1 && sx < grid_width && sy > -1 && sy < grid_height && ds_grid_get(tmp_grid, sx, sy) == cv)
        {
        ds_list_add(rnd_list, sy<<16 | sx);//Nice trick to store x and y in 1 variable.
        }
    }
}

//Now we pick up a random coordinate around the current cell.
ds_list_shuffle(rnd_list);
rnd = ds_list_find_value(rnd_list, 0);

cx = rnd & $FFFF;
cy = rnd >> 16;

ds_stack_push(path_stack, cy, cx);
ds_list_clear(rnd_list);
}


/*
We now have a stack full of coordinates that corresponds to the shortest way to target cell.
What could you do with it? It's yours to decide.
In this example we will transfert that stack into the instance(argument0) coord_list.
*/

with(argument0)
{
Step = cell_size;
    
    do
    {
    ds_queue_enqueue(Coord_List, ds_stack_pop(path_stack));
    }
    until(ds_stack_empty(path_stack))
}



//Then, let's destroy the data_structures:

ds_list_destroy(rnd_list);
ds_list_destroy(tmp_list[0]);
ds_list_destroy(tmp_list[1]);
ds_grid_destroy(tmp_grid);
ds_stack_destroy(path_stack);
