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
tubeDia = 4.2;          // diameter of tube to be glued to support
foamThickness = 6.0;   // foam thickness so as to make it flush
plateThickness = 1.0;  // support plates sandwich walls
plateDia = 40.0;       // diameter of plate
insertThickness = foamThickness; // width of the inner piece 
                                 // (not used in spherical version.)
insertDia = 9.5;   // diameter of insert piece
forAngle = 30.0;  // angle of forward slope insert for fin leading edge
aftAngle = -8.0;  // angle of rearward slope
scaleFactor = 2.0; // to make the oval shape of the insert
// do not change these!
epsilon = 50.0;  // used to ensure that there are no close misses
$fn = 100;  // curve resolution

module plate(dia, ht){
    cylinder(d=dia,h=ht);
}


module insertCutter(d,h){
    linear_extrude(height = h*10,center=true,convexity=10,twist=0){
        polygon(points = [[0,0],
                          [sin(forAngle)*(d+epsilon),-cos(forAngle)*(d+epsilon)],
                          [-cos(forAngle)*(d+epsilon),-cos(forAngle)*(d+epsilon)]], 
                convexity=10);
    }
}


module insert(d,t){
    difference(){
        scale([scaleFactor,1,scaleFactor]){
            sphere(d=d); 
        }
        insertCutter(d,t);
    }
}

module rod(d,ht){
    translate([0,0,0]){
        cylinder(d=d,h=ht+epsilon,center=true);
    }
}


module cutter(d,h){
    linear_extrude(height = h*10,center=true,convexity=10,twist=0){
        polygon(points = [[0,0],
                          [0,-(d+epsilon)],
                          [-(d+epsilon),-(d+epsilon)],
                          [-cos(aftAngle)*(d+epsilon), 
                           -sin(aftAngle)*(d+epsilon)]], 
                convexity=10);
    }
}


module support(){
    difference(){
        union(){
            //outerPlate(plateDia,plateThickness);
            //translate([0,0,plateThickness]){
                insert(insertDia,insertThickness);
            //}
            translate([0,0,-plateThickness/2.0]){
                plate(plateDia,plateThickness);
            }
        }
        cutter(plateDia,foamThickness*2.0);
        insertCutter(plateDia,foamThickness*2.0);
        rod(tubeDia,foamThickness*3.0);
    }
}
support();
/*
scale([scaleFactor,1,scaleFactor]){
            sphere(d=foamThickness); 
}
rod(tubeDia,foamThickness*3.0);
*/
