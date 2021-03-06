/* FuelTankAndCones.scad
 * 2016 03 10
 * updated 2018 05 06
 * gratefulfrog
 * use this file to generate STLs for the F104 fuel tank parts
 * ---------------------
 * usage:
 * at the very end of the file, uncomment the generator that suits you:
 * HorizontalFuelTank(starboard);  // horizontal complete tank, 
                                   // boolean indicates if starboard
 * doFrontCone();
 * doRearCone(starboard);
 * doCenter();
 * then doit(starboard) does the work! This is where to set starboard!!!
 */
 
 include <TankFins.scad>
 include <Beziers.scad>

/*******  Beginning of F104 Fuel Tank Code  ******/

// CURA SHELL THICKNESS setting = 1.2mm

$fn=100;   // smoothness of shell, do not change this setting

diaExt = 36.0;           // measured external diameter of the paper cylinder
radiusExt = diaExt/2.0;  // just computation, do not change
centerLength = 180;     // length of center cylinder
centerSampleLength = 20;  // to make a little bit of the center for tests
frontLength = 93;       // length of front cone -5 from original
frontCurve = 2;         // curvature of front cone (for bezier function)
frontBez = frontLength; // bezier height of front cone (for bezier function)
rearLength = 100;      // length of rear cone -10 from original
rearCurve = 1;         // curvature of rear cone (for bezier function)
rearBez = 85;          // bezier height of rear cone (for bezier function)
overlapLength = 10;   // length of overlappin section of each cone
overlapRadius = 33.0/2.0;  // radius of overlapping section, do not modify

// mounting slot parameters
slotOffset = 32;              // distance from the tail of center section
slotLength = 54;  //75;       // length of wing slot in center part
slotWidth  = 5.5; //6;        // width of wing solt
wingTabLength = 32;        // length of tab in tank
slotEpsilon = 2;              // to ensure full piercing
slotDepth  = wingTabLength + slotEpsilon;  // depth of slot
slotAngle  = 2.0;             // angle of incidence of tank 
                              // positive => upwards at nose
module frontCyl(){
    // bezier generator for the front cone
    BezCone(d=diaExt-1,h=frontLength,curve=frontCurve,curve2=frontLength);
}

module rearCyl(){
    // bezier generator for the front cone
    BezCone(d=diaExt-1,h=rearLength,curve=rearCurve,curve2=rearBez);
}

module Center(center=false){
    // make the center section
    cylinder(h=centerLength,r1=radiusExt-0.5,r2=radiusExt-0.5,center=center);
}
module CenterSample(center=false){
    // make the center section
    cylinder(h=centerSampleLength,r1=radiusExt-0.5,r2=radiusExt-0.5,center=center);
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

module slotBlockHelper(sign){
  translate([centerLength/2.-slotOffset,-sign*slotWidth/2.,0])
    rotate([0,slotAngle,0])
      translate([-slotLength/2.0,0,0])
        rotate([90,0,0])
          cube([slotLength,slotWidth, slotDepth],center=true);
}
module slotBlock(starboard){
    if (starboard)
      slotBlockHelper(1);
    else
      slotBlockHelper(-1);
}
module doFrontCone(){
  translate([-centerLength/2.,0,0]){
    rotate([0,-90,0])
      FrontCone();
  }
}
module doRearCone(starboard){
  translate([centerLength/2.,0,0]){
    rotate([0,90,0])
      rearConeWithFins(starboard,true);
  }
}  
module doCenter(sample=false){
  rotate([0,90,0])
    if (sample) CenterSample();
    else Center(true);
}
module doit(starboard) {
    difference(){
      union(){
        /****  GENERATORS ***/
        HorizontalFuelTank(starboard);   // horizontal complete tank
        //doFrontCone();
        //doRearCone(starboard);
        //doCenter();
      }
      slotBlock(starboard);
    }
}
//doCenter(true); // makes a sample center piece
//doit(true);
//////////////////////////////////////////////////////////////////////////////
// start of new center version.
// first the slot should be a hollow cube with a supporting arch on the short
// end of the tbe, i.e. the straight part of the slot
//
// then the tube itself should be hollow.
//
// the wall width will be 2x the extruder dia, i.e. 2 perimeters, 
// 2 x 0.4

extruderDia         = 0.4;
hollowWallThickness = 2*extruderDia;
hollowRadiusInterior = radiusExt-hollowWallThickness;
hollowDiaInterior = 2*hollowRadiusInterior;
hollowLengthEpsilon = 5;

hollowSlotArchDia = (diaExt+hollowDiaInterior)/2.;

module hollowTube(){
  difference(){
    cylinder(h=centerLength, r=radiusExt);
    translate([0,0,-hollowLengthEpsilon/2.])
      cylinder(h=centerLength+hollowLengthEpsilon,r=hollowRadiusInterior);
  }
}


//translate([-hollowSlotArchDia/2.,-slotWidth/2.,0])
archColor = "red";
module archSupport(){
  zRotationCompensation = -0.1;
  color(archColor,1)
    translate([0,
               -(slotWidth+2*hollowWallThickness)/2.,
               -hollowSlotArchDia/2.+zRotationCompensation])
      difference(){
        cube([hollowSlotArchDia,
              slotWidth+2*hollowWallThickness,
              hollowWallThickness+hollowSlotArchDia/2.]);
        translate([hollowSlotArchDia/2.,-1.5*slotWidth,0])
          rotate([-90,0,0])
          cylinder(d=hollowSlotArchDia,h= 3*slotWidth);
      }
    }


module slotWithSupport(sign,solid=false){
// slot = cube - cutter
  smidgin = 0.4;
translate([smidgin,0,0])
//outter cube
  rotate([sign*slotAngle,0,0])
    difference(){
      // external cube
      translate([0,-(slotWidth+2*hollowWallThickness)/2.,0])
        cube([hollowSlotArchDia+hollowLengthEpsilon,
              slotWidth+2*hollowWallThickness,
              slotLength+2*hollowWallThickness]);
      // cutter cube
      if (!solid){
        translate([hollowWallThickness,
                   -slotWidth/2.,
                   hollowWallThickness])
          cube([hollowSlotArchDia+2*hollowLengthEpsilon,
                slotWidth,
                slotLength]);
      }
    }
}
module extCuttingCylinder(){
  translate([0,0,-hollowLengthEpsilon/2.])
    difference(){
     cylinder(h=centerLength+hollowLengthEpsilon, r=radiusExt+2*hollowLengthEpsilon); 
     cylinder(h=centerLength+hollowLengthEpsilon, r=radiusExt);
    }
}
module hollowCenter(starboard,arch){
  difference(){
    sign = starboard ? -1 : 1;
    union(){
      difference(){
        hollowTube();
        translate([-hollowSlotArchDia/2.,0,slotOffset-hollowWallThickness])
          slotWithSupport(sign,true);
      }
      translate([-hollowSlotArchDia/2.,0,slotOffset-hollowWallThickness])
          union(){
            slotWithSupport(sign);
            if (arch) archSupport();
          }
    }
    extCuttingCylinder();
  }
}
hollowCenter(true,true);
