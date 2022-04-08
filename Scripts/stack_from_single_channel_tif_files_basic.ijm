// this is a very rough sketch of how the code should look and is very manual for now
// will definitely explore other more accessible options to convert single .tif files to stacks later

// write path to folder with images you need in a stack
input = "D:/Systems_Biology/Spatial_omics_lab_rotation/220204_CASSIS_Tumor_Exp001/211209_CCS_H583617_04_ROI01_20x_02_cycle2/";
// write output path and wanted name
output = "D:/Systems_Biology/Spatial_omics_lab_rotation/220204_CASSIS_Tumor_Exp001/raw/";
name = "cycle_1";
run("Image Sequence...", "select=["+input+"] dir=["+input+"] sort");
saveAs("tiff", output+name+".tif");
close();
