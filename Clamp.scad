$fn=100;

module chained_hull()
{
  union() { 
      for(i=[0:$children-2])
   hull()
   {
     children(i);
     children(i+1);
    }
   }
}

module cut_circle(r=1) {
    difference() {
        circle(r);
        translate([0,-2*r/sqrt(2),0]) square([2*r,2*r/sqrt(2)],center=true);
        
        translate([-2*r/sqrt(2),0,0]) square([2*r/sqrt(2),2*r],center=true);
        translate([2*r/sqrt(2),0,0]) square([2*r/sqrt(2),2*r],center=true);
    }
}

// The radius of the hook circle
hook_radius = 20;

// The thickness of the hook
thickness = 10; 

// The angle of the rotation of the hook
hook_angle = 197;

// The thickness of the plate the hook is going to attach to
plate_thickness=18;

// How long the hook will extend into the board on the lower part
lower_width=50;

// How long the hook will extend into the board on the upper part
upper_width=40;

// how much the end of the lower bracket will be raised to clamp harder onto the board
chamfer=2; 

// how much the width of the lower bracket will be increased beyond the thickness of the hook.
strength=0.5; 

module rotp(p,r) {
    translate(-p) rotate(r) translate(p) children(); 
}

function range(rmin, var, rmax) = min(max(var,rmin),rmax); 

let(thickness=thickness/sqrt(2))
mirror([-1,-1,0]) translate([hook_radius,thickness*sqrt(2),0]) {
    // hook
    rotate([0,0,180]) rotate_extrude(angle=-hook_angle) 
        translate([hook_radius,0,0]) 
            rotate([0,0,90]) 
                cut_circle(thickness);


    // hook connector
    hull()
    {
         translate([-hook_radius
    ,0,0]) 
            rotate([90,90,0]) 
                linear_extrude(.1) cut_circle(thickness);
        
         translate([-hook_radius,-thickness/sqrt(2),0]) 
                cube(thickness*sqrt(2),center=true);        
    }
}


translate([0,-thickness/2,-thickness/2]) { 
    cube([plate_thickness+2*thickness,thickness,thickness]);
    
    hull() {
        rotate([0,0,0]) 
            translate([0,thickness,0]) 
                rotp([thickness,0,0],[0,0,-atan(chamfer/(lower_width+thickness))]) 
                    cube([thickness,lower_width+thickness,thickness]);
    
    
        translate([-thickness*range(0,strength,1),thickness,0]) cube([0.1,0.1,thickness]); 
    }
    
    translate([plate_thickness+thickness,0,0]) 
        cube([thickness,upper_width+thickness,thickness]);
}




