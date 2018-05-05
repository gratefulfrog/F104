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


// CURA SHELL THICKNESS 1.2mm
$fn=100;
diaExt = 36.0;
radiusExt = diaExt/2.0;
wallThickness = 2.0;
centerLength = 180;
frontLength = 98;
frontCurve = 2;
frontBez = frontLength;
rearLength = 110;
rearCurve = 1;
rearBez = 85;
overlapLength = 10;
overlapRadius = 33.0/2.0;
shift = 50;

module frontCyl(){
    BezCone(d=diaExt-1,h=frontLength,curve=frontCurve,curve2=frontLength);
}

module rearCyl(){
    BezCone(d=diaExt-1,h=rearLength,curve=rearCurve,curve2=rearBez);
}

module Center(){
    cylinder(h=centerLength,r1=radiusExt-0.5,r2=radiusExt-0.5,center=false);
}
module Overlap(){
    translate([0,0,-overlapLength/2.0]){
            cylinder(h=overlapLength,r1= overlapRadius,r2= overlapRadius,center=true);
    }
}

module FrontCone(){
    frontCyl();
    Overlap();
}
module RearCone(){
    rearCyl();
    Overlap();
}
module BothCones(){
    translate([shift,0,0]){
        FrontCone();
    }
    RearCone();
}
module AllParts(){
    translate([shift,0,overlapLength])
        BothCones();
    Center();
}
module FuelTank(){
    rotate([0,180,0]){
        FrontCone();
    }
    translate([0,0,centerLength]){
        RearCone();
    }
    Center();
}

module PrettyTank(){
    translate([-centerLength/2.0,0,0]) 
        rotate([0,90,0])
            FuelTank();
}

module Cutoff(){
    translate([0,0,15]){
        cylinder(200,20,20);
    }
}


//AllParts();
//BothCones();
PrettyTank();
//FuelTank();
//difference(){
//FrontCone();
//RearCone();
//Center();
//Cutoff();
//}