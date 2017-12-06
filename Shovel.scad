shovel_length = 80; 
shovel_width  = 40; 
shovel_height = 20; 

cut_height = 2; 

thickness = 1;

$fn = 50; 

type="round";  // [round,cubic]
type="cubic";  // [round,cubic]

holes = 40; 
hole_width=1; 

    

module shovel_shape(type) {
   if (type=="cubic") {
            translate([-shovel_width/2,0,0]) {
                difference() {
                    cube([shovel_width, shovel_length, shovel_height]); 
                    translate([thickness,-1,thickness]) cube([shovel_width-2*thickness, shovel_length-thickness+1, shovel_height]); 
                }
            }
   }
   
   if (type == "round") {
    translate([0,0,shovel_height]) 
    difference() {
            rotate([-90,0,0]) 
                scale([shovel_width, shovel_height*2]) 
                    cylinder(shovel_length,d=1);
        
            translate([0,-1,thickness]) rotate([-90,0,0]) 
                scale([shovel_width-thickness, shovel_height*2]) 
                    cylinder(shovel_length-thickness+1,d=thickness);        
        
        translate([-shovel_width/2,-1,thickness]) cube([shovel_width+2, shovel_length+2, shovel_height]); 
    }
   }
}

module centercube(v) {
    translate([-v[0]/2,0,0]) cube(v);
}

module holes(type) {
        // start holes only when the material reached its thickness
    let(cutoffset       = shovel_length/shovel_height*thickness/2, 

        // how much y space there is for the holes, leave a margin of "tickness" at the start
        hole_space      = (shovel_length-cutoffset) - thickness,
    
        // reduce number of holes, if they wont fit, enforce at least 'thickness' space between them
        max_holes       = hole_space / (hole_width+thickness), 
        holecount       = min(holes, max_holes),
        // the offset of the holes
        hole_spacing    = hole_space / holecount,
    
        // how large the holes will be
        hole_span       = type=="cubic" ? shovel_width-4*thickness : 
                          type=="round" ? shovel_width-15*thickness : 0,
    
       // when we cut the cylinder, this is how large it is in x direction at the minimal point
       // circle equation => (x/w)² + (y/h)² = 1
       // w = shovel_with/2, h = shovel_height, y = shovel_height-cut_height
       min_width=  type=="round" ? shovel_width*sqrt(1- pow((shovel_height-cut_height)/shovel_height,2)) :
                   type=="cubic" ? shovel_width : 0
    
    ) {
    
    for (i = [1:holecount]) {
        // height / thickness = length / x -> x = length/height*thickness
        // color(i == 1 ? "red" : "blue")
        let(y = cutoffset + i * hole_spacing,
            round_width = (i-1)* (shovel_width*2-min_width)/hole_space+min_width,
            cutwidth = type == "round" ? round_width : 
                       type == "cubic" ? shovel_width-4*thickness : 0 
            )
            translate([0,y-hole_spacing,0]) 
                // centercube([cutwidth,hole_width,shovel_height]);
                rotate([90,0,0]) scale([cutwidth,cutwidth/shovel_width*shovel_height,1]) cylinder(hole_width,d=1);

    }
    

    }
}

handle_diameter = 20; 
handle_length = 20; 


module joint (tol = 0) {
     /*   let(h = handle_diameter/6,
            d = sqrt(2)*h,
            l = 3*d,
            w = 3*d) {
    
        difference() {
            translate([0,0,-h*3+h/2]) rotate([45,0,0]) rotate([0,-45,0]) {
                cube([h*2-tol,h*4-tol,h*2-tol]);
                translate([0,h*4,0]) cube([h*2-tol,h*3-tol,h*2-tol]);
            }
            translate([0,0,h*2+h/2]) centercube([handle_diameter/2+.2,handle_diameter,handle_diameter/2+.2]);    
            translate([0,0,h*2+h/2]) rotate([0,45,0]) centercube([handle_diameter/2*sqrt(2)+.2,50,handle_diameter/2+.2]);    
            mirror([1,0,0]) color("blue") translate([0,0,h*2+h/2-tol]) rotate([0,45,0]) centercube([handle_diameter/2*sqrt(2)+.2,50,handle_diameter/2+.2]); 

            translate([0,-d*2-.1,-handle_diameter/2]) centercube([handle_diameter+.1,2*d,handle_diameter+.1]);

       }
       
       } */
       
       let (h = handle_diameter/12, 
            d = h *sqrt(2)) {
            
            CubePoints = [
                  [  0   ,  0,  -5*h ],  // first square
                  [  4*h ,  0,  -h   ],  
                  [  0   ,  0,  3*h  ],  
                  [ -4*h ,  0,  -h   ],  

                  [  0   ,  5*h,    0 ],  // middle square
                  [  4*h ,  3*h,  2*h ],  
                  [  0   ,    h,  4*h ], 
                  [ -4*h ,  3*h,  2*h ], 
                                
                  [ 0, 9*h, 4*h]         // tip
 
            ];

  
            CubeFaces = [
                  //[0,1,2,3],  // bottom
                  [0,1,2], [0,2,3],
                  // [0,4,5,1], 
                  [0,4,5],[0,5,1],
                  
                  [4,8,5],
                  // [0,3,7,4],
                  [0,3,7], [0,7,4],
                  [4,7,8],
                  // [1,5,6,2],
                  [1,5,6],[1,6,2],
                  
                  // [3,7,6,2],  // bottom
                  [3,7,6],[3,6,2],
                  [5,6,8],
                  [7,6,8]
            ];
                
            polyhedron( CubePoints, CubeFaces );
       }           
}

module handle() {
    difference() {
        translate([0,.1,0]) rotate([-90,0,0]) cylinder(handle_length, d=handle_diameter); 
        color("red") joint();
    }
}

module shovel(type) {
    difference() {
        shovel_shape(type); 
        
   // tan(alpha) * shovel_length = shovel_height
        let (alpha=atan((shovel_height-cut_height)/(shovel_length-thickness)))
            translate([-shovel_width/2-1,-1,cut_height+thickness]) 
                rotate([alpha])
                    cube([shovel_width+2, shovel_length*2+2, shovel_height+1]);        
        
        holes(type);
    }
    
    // translate([-handle_diameter*2, shovel_length+20,0]) handle();
    
        

    
    
    

}

module handle_upper () {
    mirror([0,0,1]) 
    difference() {
        handle();
        translate([-.1,-.1,-.1])
        centercube([handle_diameter+.2,handle_length+.2,handle_diameter/2+.2]);
    }    
}

module handle_lower () {
    difference() {
        handle();
        translate([-.1,-.1,-.1-handle_diameter/2])
        centercube([handle_diameter+.2,handle_length+.2,handle_diameter/2+.2]);
    }
}

translate([0, shovel_length+20,0])  handle_upper();
translate([handle_diameter+5, shovel_length+20,0]) handle_lower();

translate([0,0,handle_diameter/2]) joint();
translate([0,-15,0]) centercube([20,15,20]);
// shovel("round"); 

// translate([0,0,max(50,shovel_height*2+5)]) shovel("cubic");

