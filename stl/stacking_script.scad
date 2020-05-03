
//
// Simple script to make a stacked version of the basic input STL.
// Adjust params as needed
//

//The number of instances of the model to stack
num_to_stack=20;
//The layer height you plan to print at
layer_height=0.3;
//Nozzle size
nozzle_size=0.4;
//The size of gap between stacked copies of the model
//we recommend 1 * layer_height but this can vary by printer.
stack_gap=2*layer_height;
//The height of the model you'd like the stack
model_height=5;
//The path to the STL that you'd like to stack.
model_path="./Visor_Frame_NORTH_AMERICA_letter_6-hole_v5-1mm_front.stl";


rotate([180,0,0])
union(){
    for (i = [0 : num_to_stack]){
        translate([0, 0,(model_height+stack_gap) * i]){
            if(i > 0){
                
                    intersection(){
                        translate([0,0,-stack_gap])
                        import(model_path);
                for (i = [0 : 12]){
                        union(){
                            
                        if(i < 8){
                            translate([-100, 28+(-22*i),-stack_gap]){
                                color("blue")
                                cube([200,nozzle_size,stack_gap]);
                            }
                        }
                        
                        if(i >2 && i < 7){
                            translate([-35 -(i*7), -5,-stack_gap]){
                                color("green")
                               cube([nozzle_size,20,stack_gap]);
                            }
                            
                            translate([96 -(i*7), -5,-stack_gap]){
                                color("green")
                               cube([nozzle_size,20,stack_gap]);
                            }
                        }
                        
                        
                        translate([-100, -138,-stack_gap]){
                            color("red")
                            cube([200,nozzle_size,stack_gap]);
                        }
                        
                        translate([-100, -143,-stack_gap]){
                            color("red")
                            cube([200,nozzle_size,stack_gap]);
                        }
                        
                        if(i >2 && i < 7){
                            translate([110 -(i*25), 0,-stack_gap]){
                                color("purple")
                               cube([nozzle_size,35,stack_gap]);
                            }
                        }
                        
                        if(i >2 && i < 7){
                            translate([-70 -(i*2), -45,-stack_gap]){
                                color("yellow")
                               cube([nozzle_size,40,stack_gap]);
                            }
                            
                            translate([88 -(i*2), -45,-stack_gap]){
                                color("yellow")
                               cube([nozzle_size,40,stack_gap]);
                            }
                        }
                        
                           if(i < 7){
                            translate([32 -(i*16), -152,-stack_gap]){
                                color("red")
                               cube([nozzle_size,10,stack_gap]);
                            }
                        }
                    }
                    }
                }
            }
            import(model_path);
        }
    }
}
