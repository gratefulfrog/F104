/* FuelTankAndCones.scad
 * 2016 03 10
 * gratefulfrog
 * use this file to generate STLs for the F104 fuel tank parts
 * ---------------------
 * usage:
 * at the very end of the file, uncomment the generator that suits you:
 * AllParts();
 * BothCones();
 * HorizontalFuelTank();   // horizontal complete tank
 * FuelTank();     // vertical complete tank
 * FrontCone();
 * RearCone();
 * Center();
 */
 
// this is a library funtion from Internet, to help generate a bezier cone 
module BezConic(p0,p1,p2,steps=5) {
	/*
	http://www.thingiverse.com/thing:8931 
	Conic Bezier Curve
	also known as Quadratic Bezier Curve
	also known as Bezier Curve with 3 control points 
	
	Please see 
	http://www.thingiverse.com/thing:8443 by William A Adams
	http://en.wikipedia.org/wiki/File:Bezier_2_big.gif by Phil Tregoning
	http://en.wikipedia.org/wiki/B%C3%A9zier_curve by Wikipedia editors
	
	By Don B, 2011, released into the Public Domain
	*/

	stepsize1 = (p1-p0)/steps;
	stepsize2 = (p2-p1)/steps;

	for (i=[0:steps-1]) {
		point1 = p0+stepsize1*i; 
		point2 = p1+stepsize2*i; 
		point3 = p0+stepsize1*(i+1);
		point4 = p1+stepsize2*(i+1);  {
            bpoint1 = point1+(point2-point1)*(i/steps) ;
            bpoint2 = point3+(point4-point3)*((i+1)/steps) ; {
				polygon(points=[bpoint1,bpoint2,p1]);
			}
		}
	}
}


// this is a library funtion from Internet, to help generate a bezier cone 
module BezCone(r="Null", d=30, h=40, curve=-3, curve2="Null", steps=100) {
	/*
	Based on this Bezier function: http://www.thingiverse.com/thing:8931 
	r, d, h act as you would expect.
	curve sets the amount of curve (actually sets x value for control point):
		- negative value gives concave surface
		- positive value gives convex surface
	curve2 sets the height (y) of the curve control point:
		- defaults to h/2
		- set to 0 to make curve onto base smooth
		- set to same value as h when convex to make top smooth, not pointed
	Some errors are caught and echoed to console, some are not. 
	If it gives unexpected results, try fiddling with the values a little.

	AJC, August 2014, released into the Public Domain
	*/
	d = (r=="Null") ? d : r*2;
	curve2 = (curve2=="Null") ? h/2 : curve2;
	p0 = [d/2, 0];
	p1 = [d/4+curve, curve2];
	p2 = [0, h];
	if( p1[0] < d/4 ) { //concave
		rotate_extrude($fn=steps)  {
			union() {
				polygon(points=[[0,0],p0,p1,p2,[0,h]]);
				BezConic(p0,p1,p2,steps);
			}
		}
	}
	if( p1[0] > d/4) { //convex
		rotate_extrude($fn=steps) {
			difference() {
				polygon(points=[[0,0],p0,p1,p2,[0,h]]);
				BezConic(p0,p1,p2,steps);
			}
		}
	}
	if( p1[0] == d/4) {
		echo("ERROR, BezCone, this will produce a cone, use cylinder instead!");
	}
	if( p1[0] < 0) {
		echo("ERROR, BezCone, curve cannot be less than radius/2");
	}
}


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
module AllParts(){
    // make both cones and the center section and lay them out
    translate([shift,0,overlapLength])
        BothCones();
    Center();
}
module FuelTank(){
    // make an assembled fuel tank, just to see what it looks like
    rotate([0,180,0]){
        FrontCone();
    }
    translate([0,0,centerLength]){
        RearCone();
    }
    Center();
}

module HorizontalFuelTank(){
    // make an assembled fuel tank, oriented horizontally, just to see what it looks like
    translate([-centerLength/2.0,0,0]) 
        rotate([0,90,0])
            FuelTank();
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
    

/****  GENERATORS ***/
//NoseCone();

//CuttingGuide();  
//AllParts();
//BothCones();
//HorizontalFuelTank();   // horizontal complete tank
//FuelTank();     // vertical complete tank
//FrontCone();
RearCone();
//Center();