
//
// Simple script to make a stacked version of the basic input STL.
// Adjust params as needed
//

//The number of instances of the model to stack
num_to_stack=4;
//The layer height you plan to print at
layer_height=0.3;
//The size of gap between stacked copies of the model
//we recommend 1 * layer_height but this can vary by printer.
stack_gap=1*layer_height;
//The height of the model you'd like the stack
model_height=5;
//The path to the STL that you'd like to stack.
model_path="./Verk_NA_V5_BIGLOGO.stl";

for (i = [0 : num_to_stack]){
    translate([0, 0,(model_height+stack_gap) * i]){
        if(i > 0){
            for (i = [0 : 100]){
                intersection(){
                    translate([-100, 30+(-10*i),-stack_gap]){
                        color("red")
                        cube([200,.3,stack_gap]);
                    }
                    translate([0,0,-4])
                    import(model_path);
                }
            }
        }
        import(model_path);
    }
}
