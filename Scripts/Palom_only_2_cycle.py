## the code is based on the https://github.com/Yu-AnChen/palom#for-tiff-and-ome-tiff-files instructions with slight modifications

import palom

## reference image (usually first cycle)
c1r = palom.reader.OmePyramidReader(r"D:/Systems_Biology/Spatial_omics_lab_rotation/220204_CASSIS_Tumor_Exp001/Palom/input_2_cycle/211209_CCS_H583617_04_ROI01_20x_02_cycle2-1.tif")
## moving image
c2r = palom.reader.OmePyramidReader(r"D:/Systems_Biology/Spatial_omics_lab_rotation/220204_CASSIS_Tumor_Exp001/Palom/input_2_cycle/220125_CCS_H583617_04_ROI01_20x_02_cycle3-1.tif")

# use second-to-the-bottom pyramid level for a quick test; set `LEVEL = 0` for
# processing lowest level pyramid (full resolution)
LEVEL = 0
# choose thumbnail pyramid level for feature-based affine registration as
# initial coarse alignment
# `THUMBNAIL_LEVEL = c1r.get_thumbnail_level_of_size(2000)` might be a good
# starting point
THUMBNAIL_LEVEL = 3

c21l = palom.align.Aligner(
    # use the first channel (Hoechst staining) in the reference image as the registration reference
    c1r.read_level_channels(LEVEL, 0),
    # define which channel to use for the moving image, I again used the first channel (LEVEL, 0)
    # but in the example, it is stated that the green channel usually has better contrast - experiment specific?
    c2r.read_level_channels(LEVEL, 0),
    # select the same channels for the thumbnail images
    c1r.read_level_channels(THUMBNAIL_LEVEL, 0).compute(),
    c2r.read_level_channels(THUMBNAIL_LEVEL, 0).compute(),
    # specify the downsizing factors so that the affine matrix can be scaled to
    # match the registration reference
    c1r.level_downsamples[THUMBNAIL_LEVEL] / c1r.level_downsamples[LEVEL],
    c2r.level_downsamples[THUMBNAIL_LEVEL] / c2r.level_downsamples[LEVEL]
)

# run feature-based affine registration using thumbnails
c21l.coarse_register_affine(n_keypoints=4000)
# after coarsly affine registered, run phase correlation on each of the
# corresponding chunks (blocks/pieces) to refine translations
c21l.compute_shifts()
# discard incorrect shifts which is usually due to low contrast in the
# background regions; this is needed for WSI but maybe not for ROI images
c21l.constrain_shifts()

# configure the transformation of aligning the moving image to the registration reference
c2m = palom.align.block_affine_transformed_moving_img(
    ref_img=c1r.read_level_channels(LEVEL, 0),
    # select all the three channels (RGB) in moving image to transform
    moving_img=c2r.pyramid[LEVEL],
    mxs=c21l.block_affine_matrices_da
    
)

# write the registered images to a pyramidal ome-tiff
palom.pyramid.write_pyramid(
    mosaics=palom.pyramid.normalize_mosaics([
        # select channels to be written to the output ome-tiff
        # alternative to writing all four channels would be `c1r.pyramid[LEVEL]` instead
        c1r.read_level_channels(LEVEL, [0, 1, 2, 3]),
        c2m
    ]),
    r"D:/Systems_Biology/Spatial_omics_lab_rotation/220204_CASSIS_Tumor_Exp001/Palom/output_2_cycle/mosaic.ome.tiff",
    pixel_size=c1r.pixel_size*c1r.level_downsamples[LEVEL]

)