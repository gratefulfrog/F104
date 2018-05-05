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

/*
translate([-20,-20,0]) BezCone(d=10,h=20,curve=-2);
translate([-20,0,0]) BezCone(d=10,h=20,curve=5);
translate([-20,20,0]) BezCone(d=10,h=20,curve=10);

translate([0,-20,0]) BezCone(d=10,h=20,curve=-2, curve2=0);
translate([0,0,0]) BezCone(d=10,h=20,curve=5, curve2=0);
translate([0,20,0]) BezCone(d=10,h=20,curve=10, curve2=20);

translate([20,-20,0]) BezCone(d=10,h=5,curve=-2);
translate([20,0,0]) BezCone(d=10,h=20,curve=-2);
translate([20,20,0]) BezCone(d=10,h=40,curve=-2);
*/
/*
difference(){
    BezCone(d=35,h=100,curve=2,curve2=100);
    translate([0,0,-2]){
        BezCone(d=35,h=100,curve=2,curve2=100);
    }
}
*/

$fn=100;
module C1(){
    BezCone(d=35,h=98,curve=2,curve2=98);
}

module C2(){
    BezCone(d=35,h=110,curve=1,curve2=85);
}
/*
difference(){
    C1();
    //translate([0,0,-5]){
      //  C1();
    //}
}
translate([0,0,-5]){
    difference(){
        cylinder(h=10,r1= 33/2.0,r2= 33/2.0,center=true);
        cylinder(h=9.5,r1= 31/2.0,r2= 31/2.0,center=true);
    }
}
*/

module Both(){
    translate([50,0,0]){
        C1();
        translate([0,0,-5]){
            cylinder(h=10,r1= 33/2.0,r2= 33/2.0,center=true);
        }  
    }
    C2();
    translate([0,0,-5]){
            cylinder(h=10,r1= 33/2.0,r2= 33/2.0,center=true);
    }
}
module FrontCone(){
    C1();
     translate([0,0,-5]){
            cylinder(h=10,r1= 33/2.0,r2= 33/2.0,center=true);
        }  
}
module RearCone(){
    C2();
    translate([0,0,-5]){
            cylinder(h=10,r1= 33/2.0,r2= 33/2.0,center=true);
    }
}

FrontCone();
//RearCone();