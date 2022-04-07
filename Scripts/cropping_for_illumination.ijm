// If each cycle has its own folder, write the input paths to the folders in the array
// cycle is an array consisting of filepaths for folders with images with the first cycle (cycle2) and the second cycle (cycle3 in this case)
cycle = newArray(
	"D:/Systems_Biology/Spatial_omics_lab_rotation/220204_CASSIS_Tumor_Exp001/211209_CCS_H583617_04_ROI01_20x_02_cycle2/", 
	"D:/Systems_Biology/Spatial_omics_lab_rotation/220204_CASSIS_Tumor_Exp001/220125_CCS_H583617_04_ROI01_20x_02_cycle3/"
);

// Add the channels as they are indicated in the names of the image files.
// As an example: 211209_CCS_H583617_04_01_20x_02_CH0-DAPI.tif is the image file for cycle 1 (it is in the first folder written in the cycle array) and it ends with CH0-DAPI indicating it is the first channel.
channel = newArray(
	"CH0-DAPI",
	"CH1-FITC",
	"CH2-Cy3",
	"CH3-Cy5"
);	

// Set the output path
output_path = "D:/Systems_Biology/Spatial_omics_lab_rotation/CycIF/Unstitched_illumination/raw2/"

// tileX and tileY are the numbers of tiles in the x and y direction, respectively and should be changed accordingly.
tileX = 11;
tileY = 10;
// number of digits in the expected number of tiles (tileX*tileY)
dig = lengthOf(d2s(tileX*tileY, 0)));

//first two for loops are for each channel-cycle combination
for(i = 0; i < cycle.length; i++){
	for(j = 0; j < channel.length; j++){
		
		// Opens the image with channel j and cycle i. The naming below is example-specific and should be changed accordingly. I just used the fact that the cycle name mostly coincided with the image name.
		open(cycle[i]+substring(cycle[i], 67, 89)+substring(cycle[i], 92, 102)+channel[j]+".tif");
		
		// get the dimensions of the image
		x = getWidth();
		y = getHeight();
		
		// get the width and height of each base tile (without overlap)
		x_steps = floor(x/tileX);
		y_steps = floor(y/tileY);
		
		// I used a total overlap of 200, each base tile would protrude 100px into the neighboring one. This should be enough for alignment in general.1
		// A border with the protrusion (100px) is added to keep tiling consistent.		
		run("Canvas Size...", "width="+x+200+" height="+y+200+" position=Center zero");
		// get new dimensions of the image
		x_new = getWidth();
		y_new = getHeight();
		
		// the base tile dimensions (without adding the overlap border) are used for each step
		// y_rec will go through all steps in the y direction and x_rec will go through all steps in the x direction

		//each tile will have the dimensions of tileX+200 x tileY+200 (imagine each tile having a 100px wide edge around it)
		
		for(y_rec = 0; y_rec < tileY; y_rec++){
			for(x_rec = 0; x_rec < tileX; x_rec++){
				// for easier naming later on, expecting 110 tiles (tileX*tileY=110), layout will be x0->, x1->, ... xn->
				tile_step = y_rec*tileX+x_rec;
				
				// adding the 0s if tile_step is single- or double-digit
				if(tile_step < 10){
					tile_step = "00"+tile_step;
				}
				else{
					if(tile_step < 100)tile_step = "0"+tile_step;
				}
				// select the region of interest, rectangle with the previously described dimensions and coordinates
				makeRectangle(x_rec*x_steps, y_rec*y_steps, x_steps+200, y_steps+200);
				// duplicate so it can be saved
				run("Duplicate...", " ");
				// saving the tile as a .tif file with the appropriate cycle-tile-channel combination
				saveAs("tiff", output_path+"cycle_"+i+"_tile_"+tile_step+"_channel_"+j+".tif");
				close();			
			}
		}
		close();		       
	}
}

exit();

// the expected overlap is ~ 200/x_steps




