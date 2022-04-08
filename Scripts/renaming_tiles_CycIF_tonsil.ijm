// an example of the renaming tiles macro which will need to be heavily modified to make it work in other cases
// the result will have appropriately renamed tiles: cycle_{i}_tile_{j}_channel_{k}.tif 

// Each cycle was in one folder within the 220325_CyCIF_Tonsil_TileExport folder
// write the folder which contains all cycle folders
folder = "//wsl$/Ubuntu-20.04/home/kreso/220325_CyCIF_Tonsil_TileExport/";
// write output folder path
output = "D:/Systems_Biology/Spatial_omics_lab_rotation/CycIF/renamed_tiles/";

// Since there were 6 cycles named from 1 to 6, i will be the cycle number
// Since there were 6 tiles each with 5 channels, there were 30 images in each cycle folder, however they were just named 0.tif, 2.tif, ... 29.tif
// which is why j starts at 0 and goes in steps of five
for (i = 1; i < 7; i++){
	for (j = 0; j < 30; j += 5){
		// the 220315_ABTest_cyc is the prefix used for all cycle folder names and should be changed accordingly for different images
		open(folder+"220315_ABTest_cyc"+i+"_pos01_roi01_frames/"+j+".tif");
		saveAs("Tiff", output+"cycle_0"+i+"_tile_0"+j/5+"_channel_1.tif");
		close();
		
		open(folder+"220315_ABTest_cyc"+i+"_pos01_roi01_frames/"+j+1+".tif");
		saveAs("Tiff", output+"cycle_0"+i+"_tile_0"+j/5+"_channel_2.tif");
		close();
		
		open(folder+"220315_ABTest_cyc"+i+"_pos01_roi01_frames/"+j+2+".tif");
		saveAs("Tiff", output+"cycle_0"+i+"_tile_0"+j/5+"_channel_3.tif");
		close();
		
		open(folder+"220315_ABTest_cyc"+i+"_pos01_roi01_frames/"+j+3+".tif");
		saveAs("Tiff", output+"cycle_0"+i+"_tile_0"+j/5+"_channel_4.tif");
		close();
		
		open(folder+"220315_ABTest_cyc"+i+"_pos01_roi01_frames/"+j+4+".tif");
		saveAs("Tiff", output+"cycle_0"+i+"_tile_0"+j/5+"_channel_5.tif");
		close();
	}
}
