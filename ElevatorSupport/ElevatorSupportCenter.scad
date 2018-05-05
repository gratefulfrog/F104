// Elevevator Support for RM F104
/* This makes a 3D model for a support for the elevator on the tail.
 * The parameters are given below in mm.
 * The construction method is:
 * 1. make a circular plate,
 * 2. put a circular insert on top of it
 * 3. put another circular plate on top of that.
 * 4. then from all that subtract:
 *    4a. a rod of correct diameter, correctly positioned,
 *    4b. 2 cubes that have been rotated to the proper angles and postioned correctly.
 * 5. the end result is produced by the call to 'support();'
 */

// all dimensions are millimeters
rodDia = 5.0;  // diameter of rod to be glued to support
foamThickness = 6.0;  // foam thickness so as to make it flush
plateThickness = 1.0;  // support plates sandwich walls
plateDia = 40.0;   // diameter of plate
insertThickness = foamThickness;// - 2.0*plateThickness;  // width of the inner piece
insertDia = (plateDia + rodDia)/2.0;  // diameter of inner piece
forAngle = -8.0;  // angle of forward slope
aftAngle = 0.0;  // angle of rearward slope

// do not change these!
epsilon = 10.0;  // used to ensure that there are no close misses
$fn = 100;  // curve resolution

module plate(dia, ht){
    cylinder(d=dia,h=ht);
}

module insert(d,t){
    cylinder(d=d,h=t);
}

module rod(d,ht){
    translate([0,0,0]){
        cylinder(d=d,h=ht,center=true);
    }
}

module cutter(d,h){
    translate([0,-(d+epsilon)/2.0,0]){
        union(){
            rotate(forAngle){
                cube(d+epsilon,+epsilon,h+epsilon,center=true);
            }
            rotate(aftAngle){
                cube(d+epsilon,+epsilon,h+epsilon,center=true);
            }
        }
    }
}
module support(){
    difference(){
        union(){
           // translate([0,0,plateThickness]){
                insert(insertDia,insertThickness);
            //}
            translate([0,0,insertThickness/2.0-plateThickness/2.0]){
                plate(plateDia,plateThickness);
            }
        }
        cutter(plateDia,foamThickness*2.0);
        rod(rodDia,foamThickness*3.0);
    }
}
support();
