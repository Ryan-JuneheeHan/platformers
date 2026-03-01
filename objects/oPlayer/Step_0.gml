/// STEP EVENT - oPlayer

// ── Init ──────────────────────────────────────────────────
if (!variable_instance_exists(id, "flip_mode"))   flip_mode = 0;
if (!variable_instance_exists(id, "y_spd"))       y_spd = 0;
if (!variable_instance_exists(id, "flipping"))    flipping = false;
if (!variable_instance_exists(id, "flip_target")) flip_target = y;

// ── Horizontal movement ───────────────────────────────────
var x_spd = 0;
if (keyboard_check(vk_right)) { x_spd =  walk_speed; image_xscale = -1; }
if (keyboard_check(vk_left))  { x_spd = -walk_speed; image_xscale =  1; }

var hstep = sign(x_spd);
repeat(abs(x_spd)) {
    if (!place_meeting(x + hstep, y, oSolid)) x += hstep;
    else break;
}

// ── Flip trigger ──────────────────────────────────────────
if (keyboard_check_pressed(vk_space) && !flipping) {
    
    var ph = bbox_bottom - bbox_top;
    
    if (flip_mode == 0 && place_meeting(x, y + 1, oSolid)) {
        // On floor → flip to ceiling
        var sy = y;
        while (!place_meeting(x, sy - 1, oSolid) && sy > 0) sy--;
        flip_target  = sy + 1;          // sit just below ceiling
        flipping     = true;
        flip_mode    = 1;
        y_spd        = 0;
        image_yscale = -1;
    }
    else if (flip_mode == 1 && place_meeting(x, y - 1, oSolid)) {
        // On ceiling → flip to floor
        var sy = y;
        while (!place_meeting(x, sy + 1, oSolid) && sy < room_height) sy++;
        flip_target  = sy - 1;          // sit just above floor
        flipping     = true;
        flip_mode    = 0;
        y_spd        = 0;
        image_yscale = 1;
    }
}

// ── Smooth flip movement ──────────────────────────────────
if (flipping) {
    var dist = flip_target - y;
    var move = clamp(dist, -8, 8);
    
    if (!place_meeting(x, y + move, oSolid)) {
        y += move;
    }
    
    if (abs(y - flip_target) <= 1 || place_meeting(x, y + sign(dist), oSolid)) {
        y       = flip_target;
        flipping = false;
    }
}

// ── Gravity (only when not flipping) ─────────────────────
if (!flipping) {
    var grav_dir = (flip_mode == 0) ? 1 : -1;
    var on_surface = place_meeting(x, y + grav_dir, oSolid);
    
    if (on_surface) {
        y_spd = 0;
        // Push out of solid just in case
        while (place_meeting(x, y, oSolid)) y -= grav_dir;
    } else {
        y_spd += 0.4 * grav_dir;
        y_spd  = clamp(y_spd, -10, 10);
        
        var vstep = sign(y_spd);
        repeat(abs(round(y_spd))) {
            if (!place_meeting(x, y + vstep, oSolid)) y += vstep;
            else { y_spd = 0; break; }
        }
    }
}

// ── Hazards ───────────────────────────────────────────────
if (place_meeting(x, y, oSpike)) room_restart();
if (x < 0 || x > room_width || y < 0 || y > room_height) room_restart();