rohr = 16.1; 
kappe = 18.5; 
kappenhoehe = 6; 
toleranz = 0.3;
aussen = 4; 

    da = (kappe + aussen)/2 + toleranz;
    di = kappe/2 + toleranz; 
    h = kappenhoehe + toleranz; 
    ofs = (kappe-rohr)/2;
    hkappe = 10; 

ringdicke=2;
ringhoehe=kappenhoehe;

$fn = 200; 

bodenplatte = 2; 
bodendurchmesser=kappe+4*toleranz+aussen+2*ringdicke;



module stuhl () {
     {
        color("black") cylinder(kappenhoehe, kappe/2, kappe/2);
        color ("darkgray") translate([0,0,kappenhoehe]) cylinder(20, rohr/2, rohr/2); 
    }
}



module kappe (m) {

    color("yellow") {
        if (m == 1) translate([0,0,-bodenplatte]) cylinder(bodenplatte, bodendurchmesser/2,bodendurchmesser/2);
        translate([0,0,0]) difference () {
             cylinder(h, da,da); 
             cylinder(h+1, di,di); 
        }
        // profile 
        translate([0,0,kappenhoehe+toleranz]) rotate_extrude(angle=360) {
            translate([rohr/2+toleranz,0,0]) polygon([ 
            [ofs,0],
            [0,ofs/cos(60)],
            [0,hkappe],
            [aussen/2,hkappe],
            [(kappe-rohr+aussen)/2,0],
        ]);
}
    }    
}

module stuhlkappe (m) {
    difference () {
        kappe(m);
         translate([0,-bodendurchmesser/2,-0]) mirror([m,0,0]) cube([bodendurchmesser,bodendurchmesser,kappenhoehe + hkappe + 10]);
    }
}

module aussenring() {
  color("red") rotate_extrude(angle=360) {
        polygon([ 
            [(kappe+aussen)/2+2*toleranz,0],
            [(kappe+aussen)/2+2*toleranz+ringdicke,0],
            [(kappe+aussen)/2+2*toleranz+ringdicke,kappenhoehe],
            [(kappe+aussen)/2+2*toleranz,kappenhoehe]
        ]);
  }
}

disassemble = 1;

offset = bodendurchmesser+5; 

if (!disassemble) stuhl (); 
stuhlkappe(0);


translate([disassemble*offset,0,0]) stuhlkappe(1);

translate([disassemble*2*offset,0,0]) aussenring(); 



