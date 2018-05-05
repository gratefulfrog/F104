hFinPoints = [[0,0],
              [11.58,28.86],
              [34.56,28.86],
              [44.66,0],
              [45.55,0],
              [34.56,-56.14],
              [11.58,-56.14]];
vFinPoints =  [[0,0],
               [2.82,0],
               [14.67,36.45],
               [43.75,36.45],
               [59.42,-8.1],
               [9.83,-18.49]];

finLeadingEdgeWidth =  4.0;
finTrailingEdgeWidth = 2.0;
$fn=100;


hShortLeadingEdgeLength = sqrt(pow((hFinPoints[1][0]-
                                    hFinPoints[0][0]),2) +
                               pow((hFinPoints[1][1]-
                                    hFinPoints[0][1]),2)); 
hShortTrailingEdgeLength = sqrt(pow((hFinPoints[3][0]-
                                     hFinPoints[2][0]),2) +
                                pow((hFinPoints[3][1]-
                                     hFinPoints[2][1]),2)); 
hLongLeadingEdgeLength =  sqrt(pow((hFinPoints[6][0]-
                                    hFinPoints[0][0]),2) +
                               pow((hFinPoints[6][1]-
                                    hFinPoints[0][1]),2)); 
hLongTrailingEdgeLength =  sqrt(pow((hFinPoints[5][0]-
                                     hFinPoints[4][0]),2) +
                                pow((hFinPoints[5][1]-
                                     hFinPoints[4][1]),2)); 
                                     
hShortLeadingEdgeAngle  = atan2(hFinPoints[1][1],hFinPoints[1][0]);
hShortTrailingEdgeAngle = atan2(hFinPoints[3][0]-hFinPoints[2][0],
                                hFinPoints[2][1]);
hLongLeadingEdgeAngle   = atan2(hFinPoints[6][1],hFinPoints[6][0]);
hLongTrailingEdgeAngle  = -90+atan2(hFinPoints[4][0]-hFinPoints[5][0],
                                    hFinPoints[5][1]);

v1stLeadingEdgeLength   = sqrt(pow((vFinPoints[2][0]-
                                    vFinPoints[1][0]),2) +
                               pow((vFinPoints[2][1]-
                                    vFinPoints[1][1]),2)); 
vTrailingEdgeLength     = sqrt(pow((vFinPoints[4][0]-
                                    vFinPoints[3][0]),2) +
                               pow((vFinPoints[4][1]-
                                    vFinPoints[3][1]),2)); 
v2ndLeadingEdgeLength   =  sqrt(pow((vFinPoints[5][0]-
                                     vFinPoints[0][0]),2) +
                                pow((vFinPoints[5][1]-
                                     vFinPoints[0][1]),2));                                      
v1stLeadingEdgeAngle  = atan2(vFinPoints[2][1],
                              vFinPoints[2][0]-vFinPoints[1][0]);
vTrailingEdgeAngle    = 180-atan2(vFinPoints[3][1]-vFinPoints[4][1],
                                  vFinPoints[4][0]-vFinPoints[3][0]);
v2ndLeadingEdgeAngle  = atan2(vFinPoints[5][1],vFinPoints[5][0]);

module leadingEdge(l,sign=-1){
    rotate([-90,0,0])
        translate([sign*finLeadingEdgeWidth/2.0,0,0])
            cylinder(h=l,d=finLeadingEdgeWidth);
}
module trailingEdge(pos,ang,l,sign=1,posy=0){
    translate([pos,posy,0])
       rotate([0,0,ang])
        rotate([-90,0,0])
                translate([sign*finTrailingEdgeWidth/2.0,0,0])
                    cylinder(h=l,d=finTrailingEdgeWidth);
}
module hFin(starboard=true){
    if (starboard)
        hFinHelper();
    else
        rotate([180,0,0])
            hFinHelper();
}
module hFinHelper(){
    hull(){
    rotate([0,0,hShortLeadingEdgeAngle-90])
        leadingEdge(hShortLeadingEdgeLength,1);

    rotate([0,0,hLongLeadingEdgeAngle-90])
        leadingEdge(hLongLeadingEdgeLength);

    trailingEdge(hFinPoints[3][0],
                 hShortTrailingEdgeAngle,
                 hShortTrailingEdgeLength,
                 -1);
    trailingEdge(hFinPoints[4][0],
                 90+hLongTrailingEdgeAngle,
                 hLongTrailingEdgeLength,
                 1);
    }
}

module vFin(){
    hull(){
        /*translate([finLeadingEdgeWidth/3.,0,0])
          rotate([90,0,90])
            cylinder(h=vFinPoints[1][0],d=finLeadingEdgeWidth);
        */
        translate([vFinPoints[1][0],0,0])
        rotate([0,0,v1stLeadingEdgeAngle-90])
            leadingEdge(v1stLeadingEdgeLength,1);
        
        rotate([0,0,v2ndLeadingEdgeAngle-90])
            leadingEdge(v2ndLeadingEdgeLength);
        
        trailingEdge(vFinPoints[4][0],
                     vTrailingEdgeAngle-90,
                     vTrailingEdgeLength,
                     -1,
                     vFinPoints[4][1]);
    }
}
module fin2D(h=true){
    if (h)
        polygon(hFinPoints);
    else
        polygon(vFinPoints);
}

module finAssembly(starboard){
    hFin(starboard);
    rotate([90,0,0])
    vFin();
}    
//fin2D(false);
//finAssembly(false);

/*
echo(hShortLeadingEdgeLength);
echo(hShortTrailingEdgeLength);
echo(hLongLeadingEdgeLength);
echo(hLongTrailingEdgeLength);
echo(hShortLeadingEdgeAngle);
echo(hShortTrailingEdgeAngle);
echo(hLongLeadingEdgeAngle);
echo(hLongTrailingEdgeAngle);

echo(v1stLeadingEdgeLength);
echo(vTrailingEdgeLength);
echo(v2ndLeadingEdgeLength);
echo(v1stLeadingEdgeAngle);
echo(vTrailingEdgeAngle);
echo(v2ndLeadingEdgeAngle);
*/