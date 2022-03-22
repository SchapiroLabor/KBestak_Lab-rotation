# Lab-rotation in 
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
An idea I had regarding myofibroblast whole-cell segmentation was to use their autofluorescence to detect their cytoplasm. I tried out---








