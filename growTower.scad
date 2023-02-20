/* [Tower Size] */
//Diameter of Tower Column 
TC = 100;
//Pot size in inches
Pot = "2inch"; // [2inch, 3inch, 4inch]
//Angle of pot to column
AP = 50;
/* [Hidden] */
use<../libraries/Gears/gears.scad>
t = $t*360;
rAP = 90-AP;
radian = 180/PI;
$fn = 30;
PS = setPS(Pot); // array [rim diameter] [top diameter] [bottom diameter] [height]
GP = PS[0]+5; //3-inch needs +5,  
//variables to create twistlock
//echo(PS);
wt = 8;
wd = wt/3;
xs = [0, wd, wd*2, wt];
ys = [0, 3, 3+wd*sin(30), 3+wd*sin(30)+2, 3+wd*sin(30)+2+(wd*2)*cos(30)];
cutPoints = [[-xs[1]-.5,ys[0]],[-xs[1],ys[1]],[-xs[2],ys[2]],[-xs[2],ys[3]],[xs[0],ys[4]],[-xs[3],ys[4]],[-xs[3],ys[0]],[xs[0],ys[0]]]; //[4] last in split profile
mpoints = [for(i=[0:1:4])cutPoints[i],cutPoints[len(cutPoints)-1]];
fpoints = [for(i=[0:1:len(cutPoints)-2])cutPoints[i]];
//**********************************************************//
function aang(a,r) = (a/r)*radian; //returns angle in degress from arc length (a) and radius (r)
function rndown(num) = (num > round(num)) ? round(num):round(num)-1;
function rp_cords(r,t) = [
  r*cos(t),r*sin(t),0
];
function setPS(Pot) =
    (Pot=="2inch") ? [56,48,31,51]:t2(Pot); // [rim diameter, top diameter, bottom diameter, height]
function t2(pot) = (pot=="3inch") ? [85,74,56,66]:[108,101,83,89];
//arch and chord functions 
function cRad(e,h1) = (pow(e,2))/(8*h1)+(h1/2); //radius from e=chord length and h1=height of arch above chord 
function cAng(r,h) = 2*acos(1-h/r);// angle given the r=radius and h=height of arch above chord
function cArc(r,a) = r*a;// length of arc given r=radius and a=angle (a may need to be converted to radians)
function cChrd(r,h) = 2*sqrt(h*(2*r-h)); //length of chord given r=radius and h=height of arch above chord
function rotatePoints(x,y,cx,cy,ang,ccw=true) = (ccw) ? [((x-cx)*cos(ang) - (y-cy)*sin(ang)) + cx, ((y-cy)*cos(ang)) + ((x-cx)*sin(ang)) + cy]:
                                                        [((x-cx)*cos(ang) + (y-cy)*sin(ang)) + cx, ((y-cy)*cos(ang)) - ((x-cx)*sin(ang)) + cy];
//***********************************

//pumpMount();
module pumpMount(){
difference(){
cylinder(d=100,h=5);
translate([8,-4,0])
union(){
    translate([0,22,-.5])
        cylinder(d=4.2,h=6);
    translate([0,-22,-.5])
        cylinder(d=4.2,h=6);
}
}
}
//baseModule(); //rnd=true makes round base instead of rectangle, default is to fit most 5 gallon bucket lids, will make oval shape from x,y dementions
module baseModule(bx=264,by=264,dm=TC,rnd=true){
    pos = [0,-45,-135,180];
    difference(){
        union(){
            if(rnd) resize([bx,by,30]) cylinder();
            else translate([-bx/2,-by/2,0]) cube([bx,by,30]);
            translate([0,0,30-.01])
                cylinder(12,min(bx/2-10,by/2-10),dm/2+12);
            translate([90,0,15])
                rotate([0,30,0])
                    cylinder(d=56,h=35);
            for(i=[0:1:len(pos)-1])
                rotate([0,0,pos[i]])
                    translate([0,95,22])
                        cylinder(d=50,h=20);
            translate([0,0,30])
                controlSegment();
            
        }
        translate([0,0,-.1])
            cylinder(d=dm+4,h=50);
        translate([90,0,15])
            rotate([0,30,0])
                translate([0,0,35])
                    femaleCut(56);
        for(i=[0:1:len(pos)-1])
                rotate([0,0,pos[i]])
                    translate([0,95,42])
                        femaleCut(50);
        translate([-95,0,7.5])
            motorCut();
        translate([0,0,42.1])//gives 0.1mm clearance
            race(dm+14);
        translate([0,0,36])
            controlCutout();
        //for testing
        //translate([-133,0,-1])
            //cube([266,133,50]);
        rotate([0,0,30])
        translate([-120,-16,16])
            motorControlCut();
        rotate([0,0,50])
        translate([-125,0,11])
            switchCut();
        rotate([0,0,-35])
        translate([-122,0,16])
            powerCut();
        rotate([0,0,-35])
        translate([-92,0,4])
            union(){
            cylinder(d=48,h=19);
            translate([0,0,-7])
            cylinder(d=20,h=7.5);
}
    }
}
//columnBaseModule();
module columnBaseModule(dm=TC,ht=50){
    difference(){
        union(){
            cylinder(d=dm,h=ht+14);
            translate([0,0,42.2])
            cylinder(14,dm/2+12,dm/2);
        }
        translate([0,0,42.1])//gives 0.1mm clearance
            race(dm+14);
        translate([0,0,-.5])
            cylinder(d=dm-16,h=ht+15);
        translate([0,0,-.01])
            rotate([0,0,aang(25,dm/2+1)])
            maleCut(dm);
        translate([0,0,ht+14])
            femaleCut(dm,ht-6);
    }
    //botGrid(dm);
}
//translate([-95,0,7.5])
//motor();
module motor(){
    difference(){
    union(){
    color("Silver",.9)
    cylinder(d=37,h=31);
    translate([0,0,31-.001])
        color("PaleGoldenrod",.8)
        cylinder(d=36.2,h=33.3);
    translate([7,0,-5])
        color("Silver",1)
        cylinder(d=12,h=5.001);
    translate([7,0,-20])
        color("DarkGray",1)
        cylinder(d=6,h=15.001);

    }
    translate([9.5,-3.5,-20.001])
        color("DarkGray",1)
        cube([4,7,14]);
    }
}
//collar();
module collar(){
    intersection(){
        cylinder(5,19,13);
        linear_extrude(height=5,convexity=10)
        gear2d(10,20,3);
    }
}
//translate([-89,0,-12.5])
//rotate([0,0,t])
//driveGear();
module driveGear(){
    difference(){
        union(){
        linear_extrude(height=5.01,convexity=10)
        offset(r=-.5)
        gear2d(10,20,3);
        //translate([0,0,5])
        //collar();
        }
    translate([0,0,5]) 
    union(){
        cylinder(d=25.4,h=5.1);
        cylinder(d=12,h=9.2);
    }
    translate([0,0,-.05])
        cylinder(d=6.9,h=9.3);
    for(i=[30:60:359])
        translate([9.5*cos(i),9.5*sin(i),-5.05])
            cylinder(d=3.5,h=14.3);
    //translate([-12,0,7.5])
    //rotate([0,-90,0])
        //cylinder(d=3.2,h=3);
    }    
}
//hub();
module hub(){
    color("SlateGray",.9){
    difference(){
        union(){
            cylinder(d=25.4,h=5);
            cylinder(d=12,h=9.2);
            translate([0,0,-5])
                rotate([0,0,0])
                linear_extrude(height=5)
                gear2d(10,20,3);

        }
        translate([0,0,-.05])
            cylinder(d=6,h=9.3);
        for(i=[0:60:359])
            translate([9.5*cos(i),9.5*sin(i),-5.05])
                cylinder(d=3.5,h=14.3);
    }
    }
}
//translate([0,0,-12.5])
//baseGearModule();
module baseGearModule(dm=TC){
    difference(){
        union(){
            gearMount(dm);
            translate([0,0,-4.9])
                rotate([0,0,-t*10/48])
                color("SlateGray",.9)
                linear_extrude(height=5)
                    gear2d(48,20,3);
        }
        translate([0,0,-5])
            cylinder(18,dm/2-10,dm/2-4);
    }
}
//aeroPodModule();
module aeroPodModule(){
    difference(){
        cylinder(d=GP,h=14);
        translate([0,0,-.01])
        maleCut(GP);
        translate([0,0,10.01])
        cylinder(4,24,GP/2-2);
        translate([0,0,-.01])
        cylinder(11,16,18);
    }
}
//netPotModule();
module netPotModule(dm=GP){
    difference(){
    spaceModule(20,dm,false);
    translate([0,0,-PS[3]+11])
    union(){
    cylinder(PS[3],PS[2]/2,PS[1]/2);
    translate([0,0,PS[3]-.01])
        cylinder(d=PS[0],h=12);//25 to clear out entire top
    }
    //translate([0,0,20+6])
        //wTop(GP-4);
    }
}
netPotTopModule();
module netPotTopModule(dm=GP){
    difference(){
        cylinder(d=dm,h=12);
        translate([0,0,-.01]){
            rotate([0,0,0])
            maleCut(dm);
        }
        translate([0,0,-1])
            cylinder(d=dm-16,h=14);
    }
    translate([0,0,12-.01])
        butCap(dm);
}
//capModule(100);  //Send TC for column and GP for pot
module capModule(dm){
    ht = 16;
    spaceModule(ht,dm,false);
    translate([0,0,ht+3])
        handle(dm);
}

//waterDispensorModule(); //Defaults to TC for top of column
module waterDispensorModule(dm=TC){
    spaceModule(25,dm,false);
    topGrid(dm);
}
//waterLevelModule();
module waterLevelModule(){
    difference(){
        cylinder(d=50,h=12,$fn=8);
        translate([0,0,-.01])
        maleCut(50);
        translate([0,0,-1])
        cylinder(d=19,h=14);
    }
}
//spaceModule(19,50,false); //Send height of spacer, diameter defaults to column, bot=false will leave out grid in bottom
module spaceModule(ht,dm=TC,bot=true){
    difference(){
        cylinder(d=dm,h=ht+14);
        translate([0,0,-.5])
            cylinder(d=dm-16,h=ht+15);
        translate([0,0,-.01])
            rotate([0,0,aang(25,dm/2+1)])
            maleCut(dm);
        translate([0,0,ht+14])
            femaleCut(dm,ht-6);
    }
    if(bot){
    botGrid(dm);}
}
//growModule(); //Defaults to customizer settings
module growModule(tc=TC,gp=GP){
    hh = (gp*tan(rAP))/sin(rAP)+15+15;
    ph = gp*tan(rAP);
    xadj = (tc/2)-(gp/2*cos(AP));
    yadj = gp/2 * sin(AP) + 15;
    difference(){
        growShell(tc,gp);
        growGut(tc,gp);
        translate([0,0,-.01])
            rotate([0,0,60+aang(25,tc/2+1)])
                maleCut(tc);
        translate([0,0,hh])
            femaleCut(tc,hh-30);
        for(i=[0:120:350])
            rotate([0,0,i])
                translate([xadj,0,yadj])
                    rotate([0,AP,0])
                        translate([0,0,ph+15])
                            femaleCut(gp,ph);
    }
    botGrid(tc);
}
//topCapModule();
module topCapModule(){
    r = 10;
    ht=45;
    difference(){
    union(){
    translate([0,0,0])
        linear_extrude(height=ht,convexity=10)
        offset(r=-.6)
        topSegment();
    rotate([0,0,180-6])
    rotate_extrude(angle=12)
    translate([119.4,1.5,0])
        circle(1.5);
    rotate([0,0,132])
    rotate_extrude(angle=12)
    translate([119.4,1.5,0])
        circle(1.5);
    rotate([0,0,240-24])
    rotate_extrude(angle=12)
    translate([119.4,1.5,0])
        circle(1.5);
    rotate([0,0,180-6])
    rotate_extrude(angle=12)
    translate([65.6,1.5,0])
        circle(1.5);
    rotate([0,0,132])
    rotate_extrude(angle=12)
    translate([65.6,1.5,0])
        circle(1.5);
    rotate([0,0,240-24])
    rotate_extrude(angle=12)
    translate([65.6,1.5,0])
        circle(1.5); 
    }
    translate([0,0,-1]) 
    linear_extrude(height=ht-3)
        offset(r=-4.6)
        topSegment();
    translate([0,0,35]){
        reout(240,10);
        reout(130,10,false);
    }
    rotate([0,0,30])
    translate([0,64,35])
        cut();
    rotate([0,0,-30])
    translate([0,-120,35])
        cut();
    }  
}
//**************************Utility modules to creates grow tower parts**************************//
//growShell(TC,GP);
module growShell(cd,pd){
    minH = pd*tan(rAP);
    cH = minH/sin(rAP)+15;
    xadj = (cd/2)-(pd/2*cos(AP));
    yadj = pd/2 * sin(AP) + 15;
    hull(){
    translate([0,0,15])
        cylinder(d=cd,h=cH);
    for(i=[0:120:350])
        rotate([0,0,i])
            translate([xadj,0,yadj])
                rotate([0,AP,0])
                    cylinder(d=pd,h=minH+15);
    }
    cylinder(d=cd,h=15.01);
}
//growGut(TC,GP);
module growGut(cd,pd){
    minH = pd*tan(rAP);
    cH = minH/sin(rAP)+15+15;
    xadj = (cd/2)-(pd/2*cos(AP));
    yadj = pd/2 * sin(AP) + 15;
    translate([0,0,-1])
        cylinder(d=cd-16,h=cH+2);
    for(i=[0:120:350])
        rotate([0,0,i])
            translate([xadj,0,yadj])
                rotate([0,AP,0])
                    translate([0,0,-10])
                        cylinder(d=pd-16,h=minH+15+12);
}
//topGrid(TC);
module topGrid(dm){
    dm = dm-15.9;
    difference(){
        cylinder(d=dm,h=3);
        translate([0,0,-.5]){
            cylinder(d=16,h=6);
        }
        rotate_extrude()
            translate([dm/2,0,0])
                offset(delta=.01)
                polygon([[0,1],[-(dm/2-8),3],[0,3]]);
        holes(dm);
    }
    waterIn(dm+15.9);
}
//holes(TC);
module holes(dm){
    hs = (dm - ((dm+15.9)/3))/2;
    rows = rndown(hs/7);
    rowInc = [for(i=[0:1:rows-1]) hs/rows/2 + i*hs/(rows+1)];
    perimeters = [for(i=[0:1:rows-1]) ((dm-rowInc[i]*2)*PI)];
    inc = [for(i=[0:1:rows-1]) aang(perimeters[i]/(rndown(perimeters[i]/15)), perimeters[i]/2)];//perimeter = (dm-rowInc[i]*2*PI)  -- numfit = (rndown(perimeter/7))  -- arc = perimeter/numfit
    echo(str("hs= ",perimeters));
    for(i=[0:1:len(rowInc)-1])
        for(j=[inc[i]/2:inc[i]:359])
            rotate([0,0,j])
                translate([dm/2-rowInc[i],0,-1])
                    cylinder(d=3,h=5);
}
//botGrid();
module botGrid(d=100){
    d = d-15.9;
    oarc = (((d-4)*PI)-32)/4;
    ang = aang(oarc,(d-4)/2);
    l = (d-22)/2;
    points = [[0,0],[l,0],[l,6],[0,6]];
    echo(oarc);
    echo(ang);
    difference(){
        cylinder(d=d,h=5);
        translate([0,0,-.5]){
            cylinder(d=18,h=6);
            segments(d+15.9);
        }
    }
}
//segments();
module segments(d=100){
    h = 6;
    inc = 360/7;
    difference(){
        cylinder(d=d-16-3,h=h);
        translate([0,0,-.5]){
            cylinder(d=26,h=h+1);
            for(i=[0:inc:359])
                rotate([0,0,i])
                    translate([d/4,0,(h+1)/2])
                    cube([d/2,4,h+1],center=true);
        }
    }
}
//femaleCut();
//d=outside cylinder demension
module femaleCut(d=100,h=100,gut=true){
    offs = .1;
    ffpoints = [[-xs[1],ys[1]-.1],[-xs[2],ys[1]-.1],[-xs[2],ys[4]-.1],[-xs[1],ys[4]-.1]];
    an = 120-aang(16,d/2+1);
    translate([0,0,-ys[4]])
        union(){
            translate([0,0,0])
            rotate_extrude()
                translate([d/2,0,0])
                    offset(delta=offs){
                        polygon(fpoints);
                    }
            for(i=[aang(19,d/2+7)-1:120:355]){
                rotate([0,0,i])
                    difference(){
                        rotate_extrude(angle=an)
                            translate([d/2,0,0])
                                offset(delta=offs){
                                    polygon(ffpoints);
                                }
                        translate([d/2-xs[2],0,0])//d/2-5-3.1*sin(40)
                            rotate([0,0,-55])
                                translate([0,-1,0])
                                    cube([4,6,11]);
                    }
            }
            if(gut){
                translate([0,0,-h])
                    cylinder(d1=d-xs[3]*2,d2=d-xs[2],h=h+.01);    
                cylinder(d=(d-xs[3]*2)+6.5,h=ys[4]+offs);
            }
        }
}
//maleCut();
module maleCut(d=100){
        offs = .2;
        strt = aang(2,d/2);//angle for 2mm arc
        strt2 = aang(19+2+2,d/2);
        difference(){
            union(){
                rotate_extrude()
                    translate([d/2,0,0])
                        offset(delta=offs){
                            polygon(mpoints);
                        }
                for(i=[0:120:300]){
                    rotate([0,0,i])
                        insertPoint(d);
                }
            }
            for(i=[-strt:120:359])
                rotate([0,0,i])
                    insertPoint(d,true);
            for(i=[-strt2:120:300])
                rotate([0,0,i])
                    lock(d);
        }
}
//insertPoint();
//insertPoint(slot=true);
module insertPoint(d=100,slot=false){
    l = (slot) ? 2:25;
    x1 = (slot) ? xs[1]+.25:xs[1]-.5;
    x2 = (slot) ? xs[2]+.5:xs[2];
    y = (slot) ? 20:ys[3];
    points = [[-x1,0],[-x1,y],[-x2,y],[-x2,0]];
    rad = d/2+1;
    ang = aang(l,rad);
    rotate_extrude(angle=ang)
        translate([d/2,0,0])
            polygon(points);
}
//lock();
module lock(d=100){
    points = [[-xs[2]+.5,0],[-xs[2]+.5,ys[4]],[-xs[2]-.5,ys[4]],[-xs[2]-.5,0]];
    rad = d/2;
    ang = aang(19,rad);
    difference(){
        rotate_extrude(angle=ang)
            translate([d/2,0,0])
                polygon(points);
        translate([d/2-xs[2],0,0])
            rotate([0,0,-50])
                translate([0,-1,-.5])
                    cube([2,6,ys[4]+1]);
    }
}
//barbedEnd(12.7);
module barbedEnd(dm){
    ht=dm*2;
    difference(){
        union(){
            cylinder(d=dm,h=ht);
            for(i=[3:5:ht*.6])
                translate([0,0,i])
                    barb(dm);
        }
        translate([0,0,-.5])
            cylinder(d=dm-2.5,h=ht+1);
        translate([0,0,0])
            chmfer(dm-2.5);
    }    
}
//barb(12);
module barb(dm){
    points = [[0,0],[.8,2],[0,1.8]];
    rotate_extrude()
        translate([dm/2,0,0])
            polygon(points);
}
//chmfer(12.7);
module chmfer(dm){
    offs = .01;
    ang = 50;
    hyp = 20/sin(ang);//makes fillet large enough for 10mm
    points = [[0,0],[hyp*sin(ang),0],[hyp*sin(ang),hyp*cos(ang)]];
    rotate_extrude()
        translate([dm/2,0,0])
            offset(delta=offs){
                polygon(points);
            }
}
//waterIn(TC);
module waterIn(tc){
    difference(){
        union(){
            difference(){
                cylinder(20,tc/6+5,tc/6);
                translate([0,0,20])
                    sphere(tc/6-2);
            }
            translate([0,0,5])
                sphere(tc/8);
        }
        translate([0,0,-tc/4])
            cube(tc/2,center=true);
        translate([0,0,-1])
            cylinder(d=16,h=tc/4);
        translate([0,0,13])
            wTop(tc/3-2);
    }
}
//wTop(TC/3-1);
module wTop(dm){
    difference(){
        rotate_extrude()
            translate([dm/2-4,0,0])
                square(8);
        rotate_extrude()
            translate([dm/2,0,0])
                hull() {
                    translate([0,4,0])
                        circle(d=4);
                    translate([0,0,0])
                        square(size=[6, .5], center=true);
                }
    }
}
//handle(TC);
module handle(dm){
    th = 25;
    r = (dm+30)/2;
    nd = dm*.6;
    nr = r+nd/2-6.5;
    np = [for(i=[0:360/8:359]) rp_cords(nr,i)];
    echo(np);
    difference(){
        cylinder(r=r,h=13);
        roundEdge(r*2);
        for(i=[0:1:len(np)-1])
            translate([np[i][0],np[i][1],0])
            roundNotch(nd);
    }
}
//roundEdge(GP);
module roundEdge(dm){
    rotate_extrude()
    translate([dm/2,0,0])
        difference(){
            translate([-6.5,-.5,0])
                square([13,14]);
            translate([-6.5,6.5,0])
                circle(d=13);
        }
}
//roundNotch(30);
module roundNotch(dm){
    rotate_extrude()
    translate([dm/2,0,0])
        difference(){
            translate([-6.5,-.5,0])
                square([13,14]);
            translate([6.5,6.5,0])
                circle(d=13);
        }
}
//rcyl(48);
module rcyl(s){
    ir = s/2;
    or = ir+4;
    difference(){
        cylinder(r=or,h=35);
        translate([0,0,-.5])
            cylinder(r=ir,h=36);
        translate([0,0,28])
            wTop((ir+2)*2);
    }
    cylinder(r=ir+.1,h=14);
}
//butCap();
module butCap(dm=GP){
    r=cRad(dm,12);
    r2=cRad(dm-16,8);
    difference(){
        intersection(){
            translate([0,0,-(r-12)])
                sphere(r);
            translate([-((dm+10)/2),-((dm+10)/2),0])
                cube([dm+10,dm+10,15]);
        }
        translate([0,0,-(r2-8)])
            sphere(r2);
        cylinder(d=25,h=20);
    }
}
//race();
module race(d=24,bd=6.2){
  rotate_extrude()
    translate([d/2,0,0])
      circle(d=bd);  
}
//gearMount(TC);
module gearMount(dm){
    union(){
        difference(){
            cylinder(d=dm,h=24);
            translate([0,0,24])
                femaleCut(dm);
        }
        translate([0,0,0])
            cylinder(d1=dm+20,d2=dm+6,12);
    }
        
}
//motorCut();
module motorCut(){
    cylinder(d=40,h=70);
    for(i=[0:360/6:359])
        rotate([0,0,i])
        translate([0,15.5,-9.9])
            cylinder(d=4,h=10);
    translate([7,0,-9.9])
        cylinder(d=14,h=10);
}
//reout(264,10);
module reout(d,r,out=true){
    offs = (out) ? d/2-r:-d/2-r;
    rotate_extrude()
    translate([offs,0,0])
    difference(){
        offset(delta=1){
        square(r+1);}
        circle(r);
    }
}
//controlSegment();
module controlSegment(){
    difference(){
    intersection(){
        cylinder(d=264,h=10);
        rotate([0,0,120])
        union(){
        translate([0,0,-.5]){
            for(i=[0:15:30])
            rotate([0,0,30-i])
            cube([135,135,11]);
        }
        rotate([-90,0,30])
            cylinder(d=20,h=135);
        rotate([-90,0,-90])
            cylinder(d=20,h=135);
        }
    }
    translate([0,0,-.5])
        cylinder(d=127,h=11);
    reout(264,10);
    //reout(127,10,false);
    }
}
//cut();
module cut(){
translate([-10,-5,0])
difference(){
    cube([12,65,12]);
    translate([0,15,0])
    union(){
        rotate([-90,0,0])
        cylinder(r=10,h=36);
        translate([0,36,0])
        sphere(10);
        sphere(10);
    }
}
}
//topSegment();
module topSegment(){
    r1 = 120;
    r2 = 65;
    rc = 10;
    sta = 120;
    staSw = (asin(rc/(r1-rc)));
    staIn = sta+staSw;
    staSws = asin(rc/(r2+rc));
    stf = 240;
    stp = (stf-staIn)/50;
    points = [
            for(i=[0:staSw/20:90-staSw])
                rotatePoints((r1-rc)*cos(sta), (r1-rc)*sin(sta), (r1-rc)*cos(staIn), (r1-rc)*sin(staIn), i),
            for(i=[staIn+stp:stp:240-staSw]) 
                [r1*cos(i),r1*sin(i)],
            for(i=[staSw/20:staSw/20:90-staSw])
                rotatePoints((r1)*cos(stf-staSw), (r1)*sin(stf-staSw), (r1-rc)*cos(stf-staSw), (r1-rc)*sin(stf-staSw), i),
            for(i=[0:staSws/20:90-staSws])
                rotatePoints((r2+rc)*cos(stf), (r2+rc)*sin(stf), (r2+rc)*cos(stf-staSws), (r2+rc)*sin(stf-staSws), i),    
            for(i=[stp:stp:120-staSws*2])
                [r2*cos(240-staSws-i),r2*sin(240-staSws-i)],
            for(i=[staSws/20:staSws/20:90-staSws])
                rotatePoints((r2)*cos(sta+staSws), (r2)*sin(sta+staSws), (r2+rc)*cos(sta+staSws), (r2+rc)*sin(sta+staSws), i),
    ];
    //offset(r=-5)
    //offset(r=5)
    polygon(points);
    echo(staIn);
    echo(staSw);
    echo(staSws);
}
//controlCutout();
module controlCutout(){
    ht=8;
    dp=26;
    translate([0,0,-.001])
        linear_extrude(height=ht)
        offset(r=-.5)
        topSegment();
        translate([0,0,-dp])
        linear_extrude(height=dp)
        offset(r=-2.5)
        topSegment();
    rotate([0,0,180-6])
    rotate_extrude(angle=12)
    translate([119.5,1.5,0])
        circle(1.5);
    rotate([0,0,132])
    rotate_extrude(angle=12)
    translate([119.5,1.5,0])
        circle(1.5);
    rotate([0,0,240-24])
    rotate_extrude(angle=12)
    translate([119.5,1.5,0])
        circle(1.5);
    rotate([0,0,180-6])
    rotate_extrude(angle=12)
    translate([65.5,1.5,0])
        circle(1.5);
    rotate([0,0,132])
    rotate_extrude(angle=12)
    translate([65.5,1.5,0])
        circle(1.5);
    rotate([0,0,240-24])
    rotate_extrude(angle=12)
    translate([65.5,1.5,0])
        circle(1.5);
}

//motorControlCut();
module motorControlCut(){
st = (51-43.3)/2;
sp = (32-25.8)/2;
union(){
    difference(){
        cube([51,32,3]);
        translate([0,0,1.5])
        rotate([0,45,0])
        translate([-5,-1,-1.5])
            cube([5,53,8]);
    }
translate([st,32-sp,-13.99])
cylinder(d=4,h=14);
translate([51-st,32-sp,-13.99])
cylinder(d=4,h=14);
translate([51-st,sp,-13.99])
cylinder(d=4,h=14);
translate([st,sp,-13.99])
cylinder(d=4,h=14);
translate([0,(32-12.5)/2,1.5])
cube([12.1,12.5,16]);
translate([.1,16,8])
rotate([0, -90, 0]) {
        cylinder(d=7,15.2);}
translate([-2,16,8])
rotate([0, -90, 0]) {
    cylinder(d=16.5,15.2);
}

}
}
//switchCut();
module switchCut(){
translate([0,-7,0])
union(){
rotate([0,-64,0])
translate([0,3.5,-3.5])
cube([4,7,3.5]);
translate([0,3.5,20])
rotate([0,64,0])
cube([4,7,3.5]);
cube([20,14,20]);
translate([-11.99,-(17-14)/2,-(23-20)/2])
cube([12,17,23]);
}
}
//powerCut();
module powerCut(){
translate([0,-31,0])
union(){
difference(){
cube([42,62,6]);//z=1.5
translate([0,0,1.5])
rotate([0,45,0])
translate([-5,-1,-1])
cube([5,64,10]);
}
translate([21-36/2,31-56/2,-13.99])
cylinder(d=3,h=14);
translate([21+36/2,31-56/2,-13.99])
cylinder(d=3,h=14);
translate([21-36/2,31+56/2,-13.99])
cylinder(d=3,h=14);
translate([21+36/2,31+56/2,-13.99])
cylinder(d=3,h=14);
translate([0,31-2.54-5,1.5])
cube([11,10,15]);
translate([-4.399,31-2.54-4.7,1])
cube([4.4,9.4,12]);
translate([-4.3,31-2.54,7.9])
rotate([0,-90,0])
cylinder(d=14,h=20);
}
}