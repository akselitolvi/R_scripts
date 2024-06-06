## Creating Digital Terrain Models (DTM) from .las point clouds
## https://r-lidar.github.io/lidRbook/index.html
## Install required packages (only needed if not previously installed)
#install.packages('terra', 'lidR', 'future')
## Libraries
library(lidR)
library(terra)
library(future)
## Set work directory i.e. "C:/Users/[USERNAME]/Desktop/r_lidar"
setwd("C:/Users/Akseli Tolvi/Desktop/r_lidar")
## Parallel processing
plan(multisession)
## Read las files
las_cat <- readLAScatalog("lidar_in")
print(las_cat)
las_check(las_cat)

## Processing chunks
## Chunk size
opt_chunk_size(las_cat) <- 250
plot(las_cat, chunk_pattern = TRUE)
## Chunk buffer
opt_chunk_buffer(las_cat) <- 10
plot(las_cat, chunk_pattern = TRUE)
summary(las_cat)
## Write chunks to disk (in case of limited RAM)
#opt_output_files(las_cat) <- "lidar_out/chunks/dtm_{XLEFT}_{YBOTTOM}"

## Invert Distance Weighing (IDW)
## Compromise between TIN and Kriging
## Parameter 'res' controls spatial resolution of the output
dtm_idw <- rasterize_terrain(las_cat, res = 1, algorithm = knnidw(k = 10L, p = 2), pkg ="terra")
## Save DTM raster
writeRaster(dtm_idw, "lidar_out/dtm_idw.tif", overwrite=TRUE)

## Triangular Irregular Network (TIN)
## Most simple and fastest method
## Parameter 'res' controls spatial resolution of the output
dtm_tin <- rasterize_terrain(las_cat, res = 1, algorithm = tin(), pkg ="terra")
## Save DTM raster
writeRaster(dtm_tin, "lidar_out/dtm_tin.tif", overwrite=TRUE)

## Kriging
## OBS! The most advanced method but also SLOOOOWW..
## Parameter 'res' controls spatial resolution of the output
dtm_kriging <- rasterize_terrain(las_cat, res = 1, algorithm = kriging(k = 40))
## Save DTM raster
writeRaster(dtm_kriging, "lidar_out/dtm_kriging.tif", overwrite=TRUE)

## Hillshade from IDW raster
dtm_prod <- terrain(dtm_idw, v = c("slope", "aspect"), unit = "radians")
dtm_idw_hs <- shade(slope = dtm_prod$slope, aspect = dtm_prod$aspect)
plot(dtm_idw_hs, col =gray(0:30/30), legend = FALSE)
## Save IDW Hillshade raster
writeRaster(dtm_idw_hs, "lidar_out/dtm_idw_hs.tif", overwrite=TRUE)

## Hillshade from TIN raster
dtm_prod <- terrain(dtm_tin, v = c("slope", "aspect"), unit = "radians")
dtm_tin_hs <- shade(slope = dtm_prod$slope, aspect = dtm_prod$aspect)
plot(dtm_tin_hs, col =gray(0:30/30), legend = FALSE)
## Save TIN Hillshade raster
writeRaster(dtm_tin_hs, "lidar_out/dtm_tin_hs.tif", overwrite=TRUE)

## Hillshade from Kriging raster
dtm_prod <- terrain(dtm_kriging, v = c("slope", "aspect"), unit = "radians")
dtm_kriging_hs <- shade(slope = dtm_prod$slope, aspect = dtm_prod$aspect)
plot(dtm_kriging_hs, col =gray(0:30/30), legend = FALSE)
## Save IDW Hillshade raster
writeRaster(dtm_kriging_hs, "lidar_out/dtm_kriging_hs.tif", overwrite=TRUE)

