//first open one image from first cycle, first channel - make the pseudotiles and save them in cycle_01_tile_{iii}_channel_1.tif format
//the tiles will be x/tileX wide and y/tileY high.
//with the canvas size function, the borders will be increased so that all the tiles can have the same area around them (to have border tiles the same size as inner tiles which has to be larger for overlaps).
//repeat for second channel
//repeat for second cycle
//overlap will be approximately 200/1800 = 11% = 0.11
//I'm expecting 110 tiles with this method!

//define output
output_path = "//wsl$/Ubuntu-20.04/home/kreso/Cycif/Unstitched_illumination/raw/"

//cycle is an array consisting of filepaths for folders with images with the first cycle (cycle2) and the second cycle (cycle3 in this case)
cycle = newArray(
	"D:/Systems Biology/Denis Schapiro group/220204_CASSIS_Tumor_Exp001/211209_CCS_H583617_04_ROI01_20x_02_cycle2/", 
	"D:/Systems Biology/Denis Schapiro group/220204_CASSIS_Tumor_Exp001/220125_CCS_H583617_04_ROI01_20x_02_cycle3/"
);

channel = newArray(
	"CH0-DAPI",
	"CH1-FITC",
	"CH2-Cy3",
	"CH3-Cy5"
);	

//tileX and tileY are the numbers of tiles in the x and y direction, respectively.
tileX = 11;
tileY = 10;



//first two for loops are for each channel-cycle combination
for(i=0;i<2;i++){
	for(j=0;j<4;j++){
		open(cycle[i]+substring(cycle[i], 67, 89)+substring(cycle[i], 92, 102)+channel[j]+".tif");
		
		x = getWidth();
		y = getHeight();
		x_steps = floor(x/tileX);
		y_steps = floor(y/tileY);
		
		run("Canvas Size...", "width="+x+200+" height="+y+200+" position=Center zero");
		x_new = getWidth();
		y_new = getHeight();
		
		//each step in x direction will have the width of x_steps and the number of tiles will be tileX HYPERLINK TO IMAGE!!!
		//each step in y direction will have the width of y_steps and the number of tiles will be tileY
		//each tile will have the dimensions of tileX+200 x tileY+200 (imagine each tile having a 100px wide edge around it)
		
		for(y_rec=0;y_rec<tileY;y_rec++){
			for(x_rec=0;x_rec<tileX;x_rec++){
				//for easier naming later on, expecting 110 tiles (tileX*tileY=110)
				tile_step = y_rec*tileX+x_rec;
				if(tile_step < 10){
					tile_step = "00"+tile_step;
				}
				else{
					if(tile_step < 100)tile_step = "0"+tile_step;
				}
				makeRectangle(x_rec*x_steps, y_rec*y_steps, x_steps+200, y_steps+200);
				run("Duplicate...", " ");
				saveAs("tiff", output_path+"cycle_"+i+"_tile_"+tile_step+"_channel_"+j+".tif");
				close();			
			}
		}
		close();		       
	}
}

exit();





