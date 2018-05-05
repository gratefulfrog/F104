/* FuelTankAndCones.scad
 * 2016 03 10
 * gratefulfrog
 * use this file to generate STLs for the F104 fuel tank parts
 * ---------------------
 * usage:
 * at the very end of the file, uncomment the generator that suits you:
 * HorizontalFuelTank(starboard);  // horizontal complete tank, 
                                   // boolean indicates if starboard
 * FuelTank();     // vertical complete tank, boolean indicates if starboard
 * FrontCone();
 * RearCone();
 * rearConeWithFins(statboard,withFins);  // args are booleans, if not withFins, then slots
                                          // are left for the fins to mount!
 * Center();
 */
 
 include <TankFins.scad>
 include <Beziers.scad>

/*******  Beginning of F104 Fuel Tank Code  ******/

// CURA SHELL THICKNESS setting = 1.2mm

$fn=100;   // smoothness of shell, do not change this setting

shellThickness = 1.2;    // setting in Slic3r/Cura for the 3D printing
diaExt = 36.0;           // measured external diameter of the paper cylinder
radiusExt = diaExt/2.0;  // just computation, do not change
centerLength = 180;     // length of center cylinder
frontLength = 93;       // length of front cone -5 from original
frontCurve = 2;         // curvature of front cone (for bezier function)
frontBez = frontLength; // bezier height of front cone (for bezier function)
rearLength = 100;      // length of rear cone -10 from original
rearCurve = 1;         // curvature of rear cone (for bezier function)
rearBez = 85;          // bezier height of rear cone (for bezier function)
overlapLength = 10;   // length of overlappin section of each cone
overlapRadius = 33.0/2.0;  // radius of overlapping section, do not modify
shift = 50;              // distance to move parts when laying them out

module frontCyl(){
    // bezier generator for the front cone
    BezCone(d=diaExt-1,h=frontLength,curve=frontCurve,curve2=frontLength);
}

module rearCyl(){
    // bezier generator for the front cone
    BezCone(d=diaExt-1,h=rearLength,curve=rearCurve,curve2=rearBez);
}

module Center(){
    // make the center section
    cylinder(h=centerLength,r1=radiusExt-0.5,r2=radiusExt-0.5,center=false);
}
module Overlap(){
    // make the overlapping cylinder 
    translate([0,0,-overlapLength/2.0]){
            cylinder(h=overlapLength,r1= overlapRadius,r2= overlapRadius,center=true);
    }
}

module FrontCone(){
    // make the front cone, which is the bezier + overlap
    frontCyl();
    Overlap();
}
module RearCone(){
        // make the rear cone, which is the bezier + overlap
    rearCyl();
    Overlap();
}
module BothCones(){
    // make both cones and lay them out
    translate([shift,0,0]){
        FrontCone();
    }
    RearCone();
}
/*
module AllParts(){
    // make both cones and the center section and lay them out
    translate([shift,0,overlapLength])
        BothCones();
    Center();
}
*/
module FuelTank(starboard){
    // make an assembled fuel tank, just to see what it looks like
    rotate([0,180,0]){
        FrontCone();
    }
    translate([0,0,centerLength]){
        rearConeWithFins(starboard,true);
    }
    Center();
}

module HorizontalFuelTank(starboard){
    // make an assembled fuel tank, oriented horizontally, just to see what it looks like
    translate([-centerLength/2.0,0,0]) 
        rotate([0,90,0])
            FuelTank(starboard);
}

module CuttingGuide(){
    difference(){
        cylinder(h=20,r1=radiusExt+10,r2=radiusExt+10,center=false);
        translate([0,0,-1]){
            cylinder(h=25,r1=radiusExt-0.25,r2=radiusExt-0.5,center=false);
        }
    }
}
 
module  NoseCone(){
    rodDia = 3.0;
    rodRad = rodDia/2.0;
    rodLength=100;
    rodInsert=25;
    coneHeight = 15;
    coneBaseDia = 15;
    coneBaseRad = coneBaseDia/2.0;
    foamThickness = 5.5;
    cylinder(h=coneHeight,r2=rodRad,r1=coneBaseRad);
    translate([0,0,coneHeight-rodInsert]){
        cylinder(h=rodLength,r1=rodRad,r2=rodRad);
    }
    rectHeight=(rodInsert-coneHeight)*2;
    rotate([0,0,90]){
        translate([0,0,-rectHeight]/2.0){
            cube(size=[coneBaseDia,foamThickness,rectHeight],center=true);
        }   
    }
    translate([0,0,-rectHeight]/2.0){
       cube(size=[coneBaseDia,foamThickness,rectHeight],center=true);
    }
}

module rearConeWithFins(starboard,fins=false){
    rotate([0,-90,0]){
        difference(){
            rotate([0,90,0])
                RearCone();
            translate([rearLength-hFinPoints[4][0],0,0])
                finAssembly(starboard);
        }
        if (fins){            
            translate([rearLength-hFinPoints[4][0],0,0])
                finAssembly(starboard);
        }
    }
}

/****  GENERATORS ***/
//NoseCone();

//CuttingGuide();  
HorizontalFuelTank(true);   // horizontal complete tank
//FuelTank(true);     // vertical complete tank
//FrontCone();
//rearConeWithFins(true,true);
//Center();
//finAssembly(true);