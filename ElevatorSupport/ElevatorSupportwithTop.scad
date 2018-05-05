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
foamThickness = 4.8;  // foam thickness so as to make it flush
plateThickness = 1.0;  // support plates sandwich walls
plateDia = 20.0;   // diameter of plate
insertThickness = foamThickness - 2.0*plateThickness;  // width of the inner piece
insertDia = (plateDia + rodDia)/2.0;  // diameter of inner piece
forAngle = 0.0;  // angle of forward slope
aftAngle = -8.0;  // angle of rearward slope

// do not change these!
epsilon = 5.0;  // used to ensure that there are no close misses
$fn = 100;  // curve resolution
//$fn = 30;  // curve resolution

// top hook thing stuff
hookDia = 10.0;
elipseFact = 1.8;
hookAngle = -120.0;

module  hookCutOut(di,fc,ang,ht){    
    rotate(ang){
        translate([di*fc/2.0,0,0]){
            resize([di*fc,0,0]){
                cylinder(d=di,h=ht,center=true);
            }
        }
    }
}




module outerPlate(dia, ht){
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
    rotate(aftAngle){
        translate([-(d+epsilon),-d-epsilon,-epsilon]){
            cube(d+epsilon,d+epsilon,h+epsilon);
        }
    }
    rotate(0){
        translate([-(d+epsilon),-d-epsilon,-epsilon]){
            cube(d+epsilon,d+epsilon,h+epsilon);
        }
    }
}



module hookBoxCut(hookD,hookE,hookA,plateD,foamT){
    cutter(plateD,foamT);
    difference(){
        hookCutOut(hookDia,elipseFact,hookAngle,foamT*2.0);
        translate([-(plateD+epsilon)/2.0,0,0]){
            cube([plateD+epsilon,plateD*2+epsilon,foamT*2.0+epsilon],center=true);
        }
    }
}

module support(){
    difference(){
        union(){
            outerPlate(plateDia,plateThickness);
            translate([0,0,plateThickness]){
                insert(insertDia,insertThickness);
            }
            translate([0,0,plateThickness+insertThickness]){
                outerPlate(plateDia,plateThickness);
            }
        }
        hookBoxCut(hookDia,elipseFact,hookAngle,plateDia,foamThickness*2.0);
        //cutter(plateDia,foamThickness*2.0);
        rod(rodDia,foamThickness*3.0);
    }
}
support();



