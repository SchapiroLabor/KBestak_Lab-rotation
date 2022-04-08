import numpy as np
import palom


def run_palom_no_color_prestitched(
    img_paths,
    pixel_size,
    channel_names,
    output_path,
    level
):
    ref_reader = palom.reader.OmePyramidReader(img_paths[0])
    ref_thumbnail_level = ref_reader.get_thumbnail_level_of_size(2500)

    block_affines = []
    for idx, p in enumerate(img_paths[1:]):
        if p == img_paths[0]:
            block_affines.append(np.eye(3))
            continue
        moving_reader = palom.reader.OmePyramidReader(p)
        moving_thumbnail_level = moving_reader.get_thumbnail_level_of_size(2500)

        aligner = palom.align.Aligner(
            ref_reader.read_level_channels(level, 0),
            moving_reader.read_level_channels(level, 0),
            ref_reader.read_level_channels(ref_thumbnail_level, 0).compute(),
            moving_reader.read_level_channels(moving_thumbnail_level, 0).compute(),
            ref_reader.level_downsamples[ref_thumbnail_level] / ref_reader.level_downsamples[level],
            moving_reader.level_downsamples[moving_thumbnail_level] / moving_reader.level_downsamples[level]
        )

        aligner.coarse_register_affine()        
        aligner.compute_shifts()
        aligner.constrain_shifts()

        block_affines.append(aligner.block_affine_matrices_da)
    
    mosaics = []

    for p, mx in zip(img_paths[1:], block_affines):
        moving_reader = palom.reader.OmePyramidReader(p)
        m_moving = palom.align.block_affine_transformed_moving_img(
            ref_reader.read_level_channels(level, 0),
            moving_reader.pyramid[level],
            mx
        )
        mosaics.append(m_moving)

    if pixel_size is None:
        pixel_size = ref_reader.pixel_size

    palom.pyramid.write_pyramid(
        palom.pyramid.normalize_mosaics([
            ref_reader.read_level_channels(level, [0, 1, 2, 3]),
            mosaics[0],
            mosaics[1]
        ]),
        output_path,
        pixel_size=pixel_size,
        channel_names=channel_names
    )
    return 0