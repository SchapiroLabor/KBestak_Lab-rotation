# Lab-rotation in Computational biomedicine - Denis Schapiro group
Figuring out how to use GitHub and start my lab rotation repository

I joined the group on February 1. 2022. and my rotation was at first said to be 2 months long.

When I started out, I had to get acquainted and do some catch up on ongoing projects. My first main challenge was setting up Nextflow and MCMICRO to work on my Windows machine. I managed to have Nextflow running on my computer by following the very detailed instructions from https://www.nextflow.io/blog/2021/setup-nextflow-on-windows.html. Going along with the instructions and recommendations from my supervisor, Florian, I decided that I would use VS Code as my main code editor for scripting in Python and interacting with terminals. 
With Nextflow running, running MCMICRO was easy since the instructions on their webpage are clear https://mcmicro.org/documentation/running-mcmicro.html.
It took some time getting used to command line interfaces, but running the MCMICRO on the examplar dataset exemplar-001 cleared things up, such as how to change options and parameter tuning.

After getting to know the basics of using MCMICRO, the next step would be to apply it on actual data. The first step was to segment an image from a colaborator (Christoph).
An example of a command running MCMICRO on the image withing the "raw" folder inside the folder "First_image_christoph" performing probability maps Unmicst and Ilastik, followed by a watershed segmentation with S3segmentor, or Mesmer to predict nuclei and segment them on the DAPI channel (0).
```
nextflow run labsyspharm/mcmicro \
--in First_image_christoph \
--sample-name 40XCaptured_4  \
--probability-maps unmicst,mesmer,ilastik \
--channel 0 \
--start-at registration \
--stop-at quantification
```

The raw images are that of myofibroblasts, however as can be seen below, the first image I tried to analyze had a low resolution, there were myofibroblasts without nuclei, but with markers, some were donut-shaped. All in all, difficult images to analyze.

![first_low_res_comprosite_whole](https://user-images.githubusercontent.com/86408271/159475017-b73015e9-2fdd-45f4-aa70-1da98550a7a2.jpg)
Below are layered segmentations where it can be seen that out-of-the-box Mesmer (blue) segments the nuclei the best, and unadjusted Unmicst (red) and untrained Ilastik  (green) struggle a lot. 
![first_image_layered_segmentations](https://user-images.githubusercontent.com/86408271/159475383-b5aebe36-5e30-4171-991f-066d09db5cbc.jpg)

Then we received a higher-resolution image on which we decided to perform spot counting. Unfortunately it turned out that whole-cell segmentation was not possible with this configuration of markers as there was a lack of a membrane marker. 
An idea I had regarding myofibroblast whole-cell segmentation was to use their autofluorescence to detect their cytoplasm. I decided to use the autofluorescence in the green channel as opposed to the autofluorescence in the DAPI channel beacuse I wouldn't have the nuclear signal from different cell types as on the image slide, only myofibroblasts autofluoresce. The biggest problem by far was the lack of uniform signal in the green channel which prevented nice background separation and segmentation. Since I think it would be possible to segment them by hand, I'm sure there is a way to make it work automatically, however we decided it wouldn't be a good use of time and turned the analysis in a different direction.

My next goal was to perform spot counting in QuPath while Florian would do it in Fiji. Before that I installed QuPath, CellProfiler and Napari and took a day getting to know how they work and what they should be used for.
In QuPath, because whole-cell segmentation was not possible, I opted for a pixel intensity thresholder in the three channels we were interested in quantifying. LINK_____ . In short, I ran ____insert functions___ as a result, I had the each "spot group" annotated separately which could be quantified and located on the original image. Big shortcomings of this method were the fact that thresholding was done manually, there were regions of high intensity with more spots which would only be counted as one, and of course, not all spots would be captured by the threshold.
In comparison, Florian's approach with a Fiji plugin called RS-FISH performed much better because the method used there is based on gradients a spot would form to calculate spot location.

Compare RS-FISH to my QuPath pixel thresholding approach with images and measurements.



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

