// 1. APPLY GRAVITY
vsp += grv;

// 2. VERTICAL COLLISION (Prevents falling or sticking)
if (place_meeting(x, y + vsp, oPlatform)) 
{
    while (!place_meeting(x, y + sign(vsp), oPlatform)) 
    {
        y += sign(vsp);
    }
    vsp = 0;
}
y += vsp;

// 3. HORIZONTAL MOVEMENT
hsp = dir * walk_speed;

// WALL DETECTION: We check y-4 so the floor doesn't count as a wall
if (place_meeting(x + hsp, y - 4, oPlatform)) 
{
    dir *= -1;
}

// LEDGE DETECTION: Turn around before walking off
// If there is no platform 5 pixels ahead and 2 pixels down, turn around
if (!position_meeting(x + (dir * 5), y + 2, oPlatform)) 
{
    dir *= -1;
}

x += hsp;

// 4. PLAYER COLLISION
if (place_meeting(x, y, oPlayer)) 
{
    room_restart(); 
}

// 5. VISUALS (Fixed Scaling)
// This keeps the 5% size but flips the head left or right
image_xscale = dir * 0.05;
image_yscale = 0.05;