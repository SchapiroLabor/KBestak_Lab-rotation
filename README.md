# Lab-rotation in Computational biomedicine - image analysis with a focus on stitching and registration

I joined the group as a part of a mandatory student internship within the Working in Biosciences course as part of my Molecular Biosciences master with the major in Systems biology on February 1. 2022. and my rotation lasted until April 14. 2022.

## Nextflow and MCMICRO setup on a Windows machine
Detailed instructions: https://www.nextflow.io/blog/2021/setup-nextflow-on-windows.html
VS Code was setup as my main code editor for scripting in Python and interacting with terminals.
After Nextflow was successfully installed, running MCMICRO was easy from the clear instructions on the webpage: https://mcmicro.org/documentation/running-mcmicro.html
Running MCMICRO on the 'exemplar-001' dataset is very useful for getting used to a command line interface and MCMICRO. It should be noted that the `.ome.tiff` files from the exemplar-001 dataset contain metadata about the layout of tiles which helps ASHLAR, the registration and stitching module, to stitch the tiles.

## Image segmentation with MCMICRO modules

My first task was to use MCMICRO to segment nuclei in an image of cardiomyocytes from a colaborator where I explored the command format and parameter tuning.
The MCMICRO webpage contains details on parameter tuning: https://mcmicro.org/modules/
Below is an example of a command which runs MCMICRO on the image within the `raw` folder which is inside the folder `Example_image_1`. It should be noted that the current directory when running the command needs to be one level above `Example_image_1`, otherwise the path should be specified.
It calculates the probability maps with UnMICST and Ilastik which are followed by watershed segmentation with S3segmentor. Another module applied is Mesmer, a deep-learning-enabled segmentation algorithm which can segment the nuclei and cells itself, if provided the right markers. The channel for segmentation is set to 0, the DAPI channel because the main goal was to segment the nuclei.
```
nextflow run labsyspharm/mcmicro \
--in Example_image_1 \
--sample-name 40XCaptured_4  \
--probability-maps unmicst,mesmer,ilastik \
--channel 0 \
--start-at registration \
--stop-at quantification
```
It should be taken into account that the previous command runs the segmentation modules 'out-of-the-box' without further adjustments. Only Mesmer performs nearly perfectly 'out-of-the-box' whereas for UnMICST and Ilastik, additional parameters or training would be necessary.

## Whole-cell segmentation based on cytoplasmic autofluorescence and spot counting with QuPath

We received a higher-resolution images, however, unfortunately whole-cell segmentation was not possible on the images due to a lack of a membrane marker so we decided to perform spot counting.
The cytoplasm of cardiomyocytes shows autofluorescence in the DAPI and FITC channels which had previously been used for cell sorting (Larcher *et al*. 2018) and I had the idea to use their autofluorescence for whole-cell segmentation. The DAPI channel images also contained nuclei from fibroblasts which is why I decided to use the FITC channel for whole-cell segmentation. I decided to use the autofluorescence in the FITC channel as opposed to the autofluorescence in the DAPI channel beacuse I would not have the nuclear signal from different cell types as on the image slide because only cardiomyocytes show autofluorescence. The biggest problem by far was the lack of uniform signal in the FITC channel which prevented nice background separation and segmentation. Since I think it would be possible to segment them by hand, I'm sure there is a way to make it work automatically, however, we decided it wouldn't be a good use of time and turned the analysis in a different direction.

I performed the spot counting in QuPath. Since whole-cell segmentation was not possible, I opted for a pixel intensity thresholder in the three channels we were interested in quantifying. For each channel, I ran the functions: `Classify -> Pixel classification -> Create thresholder` where I manually set the threshold based on the channel. As a result, all pixel groups above the threshold would be counted as one spot, and its coordinates and quantification could be extracted. Big shortcomings of this method were the fact that thresholding was done manually, and that there were regions of high intensity with more spots. These regions would only be counted as one spot even though they contained many, therefore not all the spots would be captured with the classification, and not all spots would be above the threshold.
As a better approach, Florian has used the tool RS-FISH which calculates the probability of spot coordinates based on gradients the spot would form to calculate spot location. https://github.com/PreibischLab/RS-FISH
Another interesting approach to spot counting and annotation is deepBlink, a neural network-based method to detect and localize spots automatically. https://github.com/BBQuercus/deepBlink

## Cyclic immunofluorescence project

### CycIF introduction

Cyclic Immunofluorescene (CycIF) is a method of obtaining highly multiplexed immunofluorescence images. It uses sequential 4- to 6-channel imaging followed by fluorophore inactivation or washing. Repeating cycles preserve the cell morphology and the resulting images can have up to 30 channels (Lin *et al*. 2016). The main goal of CycIF image analysis is to obtain the registered image across cycles so that single-cell analysis can be performed.

The goal of this part of the rotation was to help our collaborator Johanna Wagner who is performing CycIF experiments with setup to be able to analyze her data with the MCMICRO pipeline.

The first images we received were pre-stitched images with each channel of each cycle being in a separate `.tif` file. Due to at-the-time-told-so limitations of the machine, it was thought there was no way to export the individual tiles. Also no illumination correction was done on the pre-stitched tiles. 
MCMICRO contains modules for different purposes in its pipeline. BaSiC is the illumination correction module which produces the `ffp` and `dfp` images (flat-field profile and dark field-profile, respectively). ASHLAR registers and stitches tiles and applies the illumination correction from BaSiC on the image to produce the whole image as a `.ome.tiff` file.


CYCIF - everything in detail

how does cycif work
how the data looked
What I tried out
what worked
what didn't work

ImageJ macro
StackRegJ and TurboReg plugins
Stitching plugin

Ashlar - preprocessing the data with Fiji to be able to feed it to Ashlar

Palom - works great, _CODE to get it working on the first image_
-modified function so that it runs on multiple channels

It would be great if I could have some comparison between the three approaches to registration.

Even though it is a very basic concept, I've never encountered the PATH before so I learnt how to and why it might be useful to add certain tools to the PATH. For example, I installed bftools to be able to convert images from the command line so instead of running the command from its filepath each time, I added it to the PATH.
Regarding BFTools, they can be downloaded from https://docs.openmicroscopy.org/bio-formats/5.7.1/users/comlinetools/index.html. The bfconvert tool was the most useful tool for my purposes as it allows for conversion between filetypes and cropping of selected regions. My plan was to use bfconvert to circumvent my need for the ImageJ macro so that I could run every step from a coding interface and not bother with opening the images in Fiji for preprocessing. Bfconvert works in powershell, not cmd.

Running MCMICRO on the registered images from Palom - good segmentation with Mesmer (example), but error in quantification - markers.csv not matching channels - I still need to look into it
Trying to do QC in Python - array too bign error




Setting up my account on the cluster



New data from Johanna - she could get the tiles out without stitching - test it out in MCMICRO
The new data we received related to the CycIF project has the tiles exported without being prestitched. There are 6 cycles with 5 channels per cycle and 6 tiles per cycle all as separate .tif files, meaning in total there are 30 .tif files per cycle. Running it in MCMICRO with the command below gives the following error. Currently I'm unsure how the input data should look like for BaSiC, or which options exactly to change for Ashlar, but currently it is not working.

```
nextflow run labsyspharm/mcmicro \
--in 220325_CyCIF_Tonsil_TileExport \
--sample-name extracted_tiles_stacked  \
--probability-maps unmicst, s3seg \
--unmicst-opts '--channel 1 --scalingFactor 0.5' \
--ashlar-opts '' \
--start-at illumination \
--stop-at quantification
```
```
ERROR: Wrong number of flat-field profiles. Must be 1, or 181 (number of input files)
```
I did manage to run Ashlar from a Docker container on the tiles and produce a well-registered image. 

I discussed with the developers of MCMICRO about the option of running the single `.tif` files I have with the MCMICRO pipeline, however, there is no such option currently, as it would require metadata within the `.ome.tiff` file for tile localization and stitching. They suggested I run the images through BaSiC for illumination correction and ASHLAR for registration and stitching outside of MCMICRO so that is what I did.
BaSiC is a module used by MCMICRO for illumination correction, the first step of the pipeline. I was able to run my data through BaSiC with the following command:
```
docker run -it \
-v '/mnt/d/Systems Biology/Denis Schapiro group/CycIF/renamed_tiles':/data \
-v '/mnt/d/Systems Biology/Denis Schapiro group/CycIF/illumination':/output \
labsyspharm/basic-illumination \
ImageJ-linux64 --ij2 \
--headless \
--run imagej_basic_ashlar_filepattern.py \
"pattern='/data/cycle_{series}_tile_{tile}_channel_{channel}.tif',output_dir='/output',experiment_name='CycIF_tonsil'"
```
with the command `-v` I mount the input folder with the renamed tiles in a `cycle_{ii}_channel_{jj}_tile_{kk}.tif` format, and the output folder. Within the container, I use ImageJ-linux64 to run the python script which can handle this data format, and give it the pattern. The resulting ffp and dfp `.tif` files are saved in my `illumination` folder.
Then I pass the images and ffp and dfp `.tif` files to ASHLAR for registration and stitching with the following command:
```
docker run \
-v "/mnt/d/Systems Biology/Denis Schapiro group/CycIF/renamed_tiles":/input \
-v "/mnt/d/Systems Biology/Denis Schapiro group/CycIF/illumination":/illumination \
-v "/mnt/d/Systems Biology/Denis Schapiro group/CycIF/tonsil/registered":/output \
-it labsyspharm/ashlar:1.14.0 ashlar \
-o /output \
--align-channel 0 \
"fileseries|/input|pattern=cycle_01_tile_{series:2}_channel_{channel:1}.tif|width=3|height=2|overlap=0.4|pixel_size=0.65|layout=snake" \
"fileseries|/input|pattern=cycle_02_tile_{series:2}_channel_{channel:1}.tif|width=3|height=2|overlap=0.4|pixel_size=0.65|layout=snake" \
"fileseries|/input|pattern=cycle_03_tile_{series:2}_channel_{channel:1}.tif|width=3|height=2|overlap=0.4|pixel_size=0.65|layout=snake" \
"fileseries|/input|pattern=cycle_04_tile_{series:2}_channel_{channel:1}.tif|width=3|height=2|overlap=0.4|pixel_size=0.65|layout=snake" \
"fileseries|/input|pattern=cycle_05_tile_{series:2}_channel_{channel:1}.tif|width=3|height=2|overlap=0.4|pixel_size=0.65|layout=snake" \
"fileseries|/input|pattern=cycle_06_tile_{series:2}_channel_{channel:1}.tif|width=3|height=2|overlap=0.4|pixel_size=0.65|layout=snake" \
--ffp '/illumination/CycIF_tonsil-ffp.tif' \
--dfp '/illumination/CycIF_tonsil-dfp.tif' \
--filter-sigma 0 \
--maximum-shift 500 \
--tile-size 512 \
--pyramid \
-f cycif-corrected_whole_0_65.ome.tif
```
The command mounts the `renamed_tiles` folder as input, `illumination` as illumination and `registered` folder as output. I use the Hoechst channel for alignment. I did try out the alignment with different channels, and all but channel 1 were comparable, with channel 1 being the least reliable. With the currently undocumented function `fileseries` I was able to match the pattern for each channel, set the width (number of tiles in x axis) and height (number of tiles in y axis), the overlap which I had to estimate myself, set the pixel size and layout. the `--ffp` and `--dfp` parameters are given their appropriate illumination correction file from BaSiC. The `--pyramid` option tells ASHLAR to produce a pyramidal tiff as a result.

load imagej macros and py files


Illumination correction on the pre-stitched images.
BaSiC command
```
docker run -it \
-v '/mnt/d/Systems Biology/Denis Schapiro group/CycIF/Unstitched_illumination/raw':/data \
-v '/mnt/d/Systems Biology/Denis Schapiro group/CycIF/Unstitched_illumination/illumination':/output \
labsyspharm/basic-illumination \
ImageJ-linux64 --ij2 \
--headless \
--run imagej_basic_ashlar_filepattern.py \
"pattern='/data/cycle_{i}_tile_{tile}_channel_{channel}.tif',output_dir='/output',experiment_name='Cycif_prestitched'"
```

ASHLAR command
```
docker run \
-v "/mnt/d/Systems Biology/Denis Schapiro group/CycIF/Unstitched_illumination/raw":/input \
-v "/mnt/d/Systems Biology/Denis Schapiro group/CycIF/Unstitched_illumination/illumination":/illumination \
-v "/mnt/d/Systems Biology/Denis Schapiro group/CycIF/Unstitched_illumination/registered":/output \
-it labsyspharm/ashlar:1.14.0 ashlar \
-o /output \
--align-channel 0 \
"fileseries|/input|pattern=cycle_0_tile_{series:3}_channel_{channel:1}.tif|width=11|height=10|overlap=0.11|pixel_size=0.325" \
"fileseries|/input|pattern=cycle_1_tile_{series:3}_channel_{channel:1}.tif|width=11|height=10|overlap=0.11|pixel_size=0.325" \
--ffp '/illumination/Cycif_prestitched-ffp.tif' \
--dfp '/illumination/Cycif_prestitched-dfp.tif' \
--filter-sigma 0 \
--maximum-shift 500 \
--tile-size 512 \
--pyramid \
-f cycif_prestitched_corrected.ome.tif
```
I keep getting the following error when running ASHLAR on the prestitched images: 
```
ValueError: ('Contradictory paths found:', 'negative weights?')
```
As proof of concept, I've managed to run the first 2x2 tile area of the image with BaSiC and ASHLAR, however it looks like the result without illumination correction is better.
![composite_registered_2x2](https://user-images.githubusercontent.com/86408271/161274302-388f2f65-168f-4325-98af-62bc2d71fd74.jpg)

![composite_zoomed_2x2](https://user-images.githubusercontent.com/86408271/161274337-f27970eb-4d57-4ed9-8aae-c02dda0389e0.jpg)

![not_corrected_comparison_cycif_prestitched_corrected_not ome](https://user-images.githubusercontent.com/86408271/161274381-818eef3c-8508-4fea-aa90-b12e87290f72.jpg)
![cycif_prestitched_corrected_cycle1](https://user-images.githubusercontent.com/86408271/161274405-cc59b161-8086-4af9-a739-4e15fca4c3a1.jpg)
![not_corrected_comparison_2_cycif_prestitched_corrected_not ome](https://user-images.githubusercontent.com/86408271/161274443-606dccf5-f951-477b-a2d6-06a1c6412247.jpg)


![cycif_prestitched_corrected_cycle2](https://user-images.githubusercontent.com/86408271/161274457-0f150447-34a0-49cb-b482-fddbb8e31cad.jpg)



References:
Larcher, V., Kunderfranco, P., Vacchiano, M., Carullo, P., Erreni, M., Salamon, I., Colombo, F. S., Lugli, E., Mazzola, M., Anselmo, A., & Condorelli, G. (2018). An autofluorescence-based method for the isolation of highly purified ventricular cardiomyocytes. Cardiovascular research, 114(3), 409–416. https://doi.org/10.1093/cvr/cvx239
Lin, J. R., Fallahi-Sichani, M., Chen, J. Y., & Sorger, P. K. (2016). Cyclic Immunofluorescence (CycIF), A Highly Multiplexed Method for Single-cell Imaging. Current protocols in chemical biology, 8(4), 251–264. https://doi.org/10.1002/cpch.14
