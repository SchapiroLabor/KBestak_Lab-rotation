// insert input path to the images and the path to where registered tiles will be saved, 
input_path = "D:/Systems Biology/Denis Schapiro group/220204_CASSIS_Tumor_Exp001/Macro_basics/preprocessed/"
registered_path = "D:/Systems Biology/Denis Schapiro group/220204_CASSIS_Tumor_Exp001/Macro_basics/registered/"

// since all of the cyclel-channel combinations are in the same folder as individual .tif files, if they are named accordingly experiment_name_cycle_[cycle nr]_channel_[channel nr].tif
// or equivalent, it is important that they are in alphabetical order - the cycles and channels need to be specified to be sorted alphabetically.
// the function opens them as a Stack with the saved title.
run("Image Sequence...", "select=["+input_path+"] dir=["+input_path+"] sort");
title=getTitle();

//functions for getting the image width and height in pixels
x = getWidth();
y = getHeight();


// define the stepsize variable - it will determine how big the tile (without overlaps) will be in pixels
stepsize = 1100;
// define protrude in pixels, an if protrude = 100, then in the case of two neighboring tiles the base left tile will include 
// 100 pixels of the base right tile, and vice versa, therefore the total overlap will be 200 pixels in this example.
protrude = 100;

// after each tile is segmented, the next step will be positioned at the coordinates of stepsize-protrude because that is where the next tile comes when taking into account the overlap.
each_step_for = stepsize - protrude;
// each tile will have the size of stepsize + protrude when accounted for overlaps (total overlap 200 in the example code)
each_size = stepsize + protrude;
// set the initial tile_step
tile_step = 0;

// with two for loops, x_rec and y_rec will determine the coordinates of the upper left corner for each artificial tile
for (y_rec = 0; y_rec < y; y_rec += each_step_for){
	for(x_rec = 0; x_rec < x; x_rec += each_step_for){
		// no idea what stitch_step is
		if(x_rec == 0) stitch_step = "left";
		else stitch_step = "right";
		
		// x_rect and y_rect will be the actual coordinates of the tiles because if only x_rec and y_rec are used, the final tiles will always be out of bounds of the image
		// basically, if the final tile would go across the image edge with x_rec and y_rec, then x_rect and y_rect are selected to end at the image edge
		x_rect=minOf(x_rec, x - each_size);
		y_rect=minOf(y_rec, y - each_size);
		
		// select the base image stack
		selectImage(title);
		// produces a rectangle with the x coordinate x_rect, y coordinate y_rect, width each_size and height each_size and duplicates the stack
		makeRectangle(x_rect, y_rect, each_size, each_size);
		run("Duplicate...", "duplicate");
		// converts stack to hyperstack so that the registration can be performed. 
		run("Stack to Hyperstack...", "order=xyczt(default) channels=4 slices=2 frames=1 display=Grayscale");
		// StackRegJ requires a hyperstack where the first channel in each slice is used for registration, method of transformation used is Rigid Body.
		run("StackRegJ_", "transformation=[Rigid Body]");
		// to get around some errors, convert everything back to images and then back to a stack
		run("Hyperstack to Stack");
		run("Stack to Images");
		run("Images to Stack", "name=[tile_"+tile_step+"] title=[] use");
		// save the registered tiles
		saveAs("tiff", output_path+"tile_"+tile_step);
		// close the tile
		close();
		
		tile_step += 1;
		
	}
}
// close the initial stack
close();

// the width of the tile grid is gridx and the height of the tile grid is gridy
gridx = floor(x / stepsize);
gridy = floor(y / stepsize);

// total overlap as percentage is the following formula
overlap = each_size / (2*protrude);

// with the function Stitch Grid of Images from the Stitching plugin, hopefully the tiles will be stitched. It does not work on all images, especially when the registration has problems.
run("Stitch Grid of Images", "grid_size_x="+gridx+"grid_size_y="+gridy+"overlap="+overlap+" directory=["+registered_path+"] file_names=tile_{i}.tif rgb_order=bgr output_file_name=TileConfiguration.txt start_x=1 start_y=1 start_i=0 channels_for_registration=Blue fusion_alpha=5 regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 compute_overlap")


exit();




