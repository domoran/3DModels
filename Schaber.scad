// ******************* General Modules  **************************
$fn=400;

module leftcircle (r) {
    translate([r,0,0]) circle(r); 
}

module round_square(w,h) {
    hull() {
        translate([w/2,w/2,0]) circle(w/2); 
        translate([w/2,h-w/2,0]) circle(w/2); 
    }
}

module keil (x,y,z1,z2,o1) {
    hull() {
        cube([x,y,z1]);
        cube([o1,y,z2]);
    }
}

// !keil(2,2,1,2,0.5);

module centered_round_square(w,h) { translate([-w/2,-h/2,0]) round_square(w,h); }
module xcentered_round_square(w,h) { translate([-w/2,0,0]) round_square(w,h); }
module ycentered_round_square(w,h) { translate([0,-h/2,0]) round_square(w,h); }


module M3NutTrap () {
    translate([0, 5.5, 0])
    cylinder(r = 5.5 / 2 / cos(180 / 6) + 0.05, $fn=6);
}

tolerance=0.1;

// ******************** Blade ************************************

bladewidth=43; 
bladeheight=22;
bladethickness=0.2;
bladeholewidth=5.5;



module blade_hole_repeat(r) {
        translate([bladewidth/2-r-7.2,0,0]) children();
        translate([bladewidth/2    ,0,0]) children(); 
        translate([bladewidth/2+r+7.2,0,0]) children(); 
}

// The razor blade
module blade() {
    // the blade is a rectangle with three holes in it.
    // note that the holes are hardcoded here. 
    color("red")
    linear_extrude(bladethickness)
    difference()
    {
        square([bladewidth,bladeheight]);
        translate([0,bladeheight/2,0]) 
            blade_hole_repeat(r=bladeholewidth) 
                circle(bladeholewidth/2);
    }
}





// ******************* Blade Holder *********************************
bladeoverhangx = 2; 
bladeprotrusion = 3; 
// we make the holder pins a bit smaller radius than the blade holes



// and make them extend over the blade by 1mm
holderpinheight=bladethickness+0.5;

holderwidth = bladewidth+bladeoverhangx; 
holderheight = bladeheight + 10; 
groudplate_thickness = 2.5;
fastener_thickness = 1.2; 

nutposition = [holderwidth/2,(holderheight-bladeheight)/2-5.5/2,0];
holderpinsize=bladeholewidth-0.2; 
slideroffset = 5;

screwhole_extralength=1; 

            // ******************* Sliders *******************
            sliderwidth = 10;

            sliderlength=(holderheight-bladeheight);

            module slider () {
                square([sliderwidth, sliderlength]);
            }

            module mirrored_sliders () {
                // sliders
                 {
                        translate([slideroffset,2,0]) children();
                        
                        translate([holderwidth,0,0]) mirror([-1,0,0])
                            translate([slideroffset,2,0]) children();
                    }
            }


// the blade is positioned so there is a small overhang on the sides
bladeposition=[bladeoverhangx/2, holderheight-bladeheight+bladeprotrusion, groudplate_thickness]; 

module blade_holder_downside () {
    // The flat square of the holder
    //cube([holderwidth, holderheight, groudplate_thickness]);    
    intersect([ 
    translate([0,0,groudplate_thickness]) rotate([0,0,90]) mirror([0,-1,0]) mirror([0,0,-1]) keil(holderheight,holderwidth,groudplate_thickness,groudplate_thickness+5,2);
}


module holder_pin() {
    cylinder(h=holderpinheight,d=holderpinsize);
}

module holder_pins () {
    // we put the blade on those
    translate([0,bladeheight/2,0]) 
        blade_hole_repeat(r=holderpinsize)
            holder_pin();
}


module blade_holder (hole_movement=0) {
    difference() {
        // ground plate 
        blade_holder_downside();  
    
        // slider holes
        mirrored_sliders()  translate([0,-5,fastener_thickness])
            cube([sliderwidth+tolerance, sliderlength+10, 10]);
    
        punch_hole_length=hole_movement;
        
        // screw punch through
        translate(nutposition + [0,5.5/2+screwhole_extralength,0]) 
                linear_extrude(20) 
                    centered_round_square(3, -punch_hole_length);
    }
    
    translate(bladeposition) {  
      holder_pins();   
    }
}

// *************************** Cover *********************************

cover_overhang = bladeprotrusion+1; 

plate_height = fastener_thickness;

fastener_pin_height=holderpinheight-bladethickness;

fastener_height = plate_height + fastener_pin_height;

pinposition = bladeposition + [0,bladeheight/2,0]; 

module repeat_fasteners () {
    fastener_thickness=0.3; 
    fastener_middle = bladeoverhangx/2+bladewidth/2-2; 
    fy = holderheight-bladeheight+bladeprotrusion;   
    translate([fastener_middle-13-bladeholewidth,fy,fastener_thickness]) children(); 
    translate([fastener_middle+13+bladeholewidth,fy,fastener_thickness]) children(); 
    translate([fastener_middle- 7               ,fy,fastener_thickness]) children(); 
    translate([fastener_middle+ 7               ,fy,fastener_thickness]) children(); 
}

module blade_fasterner_without_hole () {   
     { 
    // ground plate ... make sure we are 1mm larger than the protruded blade
    difference() {
    linear_extrude (plate_height) 
        square([holderwidth, holderheight+cover_overhang]);
        translate(nutposition) {
            M3NutTrap();
        }
        
    }
    
    translate(nutposition) 
        translate([0,0,plate_height]) 
            scale([1.5,1.5,1]) M3NutTrap();
    
    // fasteners for holding the blade
    translate([0,0,plate_height]) {
        linear_extrude(fastener_pin_height)
            repeat_fasteners() round_square(4,20); 
        
        // sliders: their height is equal to the height of the fastener pins+
        //          the height of the blade + the cutout height        
        cutout = groudplate_thickness-fastener_thickness;
        sliderheight = fastener_pin_height+bladethickness+cutout-tolerance;
        
        linear_extrude(sliderheight) 
            mirrored_sliders()
                slider(); 
        
    }
    
    // hole for moving the fastener         
    }
}




module nutpunch() {
    translate(nutposition+[0,5.5,0]) cylinder(h=5,r=1.5);
}

module blade_fastener () {
    difference () {
        blade_fasterner_without_hole();
        nutpunch();
    }
}

// blade_fastener();

// ************************************ Assembly *****************************

module assemble_fastener (moveBack = 0) {
        translate([0,-moveBack,+bladethickness+bladeposition.z]) 
            mirror([0,0,-1]) translate([0,0,-1*fastener_height])  
                children(); 
}

module blade_with_holder () {
    // move the blade into the holder into the right position
    translate(bladeposition) {
        children();
    }
    
    blade_holder(bladeprotrusion); 
}

module assembled (open) {
    %assemble_fastener(open*cover_overhang)  blade_fastener ();
    blade_with_holder() 
    blade ();
}

assembled(0);



/*








module parts () {
    mirror([-1,0,0]) translate([5,0,0]) punched_blade_fastener ();
    mirror([0,-1,0]) translate([-holderwidth-5,5,0]) blade_with_holder ();
    translate([-holderwidth-5,holderheight+10,0]) blade();
}

module present (open) {
    mirror([0,-1,0]) assembled(open); 
    color("red")  translate([0,20,0])  linear_extrude(1) text("assembled");


    parts(); 
    color("red")  translate([-45,70,0])  linear_extrude(1) text("inside");

    translate([-holderwidth-5,0,0]) mirror([0,0,-1]) parts();
    color("red")  translate([-100,70,0])  linear_extrude(1) text("outside");
}


// parts();


// punched_blade_fastener ();
*/


