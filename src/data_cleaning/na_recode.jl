"""
For each pixel, NOAA produces monthly estimates of radiance using the mean of radiance measured on days considered free of clouds. Radiance on months with no cloud-free observations are marked as zero, these should be marked as missing or or not available. The na_recode function uses the radiance and the cloud-free observations image to marks missing wherever there no 0 cloud-free observations. 
```julia
radiance = rand(1:10.0, 10, 10)
cloud = rand(0:5, 10, 10)
na_recode(radiance, cloud)
```
"""
function na_recode_img(radiance, clouds; replacement = missing)
    for i in 1:size(clouds)[1]
        for j in 1:size(clouds)[2]
            if clouds[i,j] == 0
                radiance[i,j]= replacement
            end
        end
    end
    return radiance
end

"""
The na_recode function also works on datacubes.  
```julia
radiance = rand(1:10.0, 10, 10, 10)
cloud = rand(0:5, 10, 10, 10)
na_recode(radiance, cloud)
```
Wherever the number of cloud-free observations is 0, radiance will be marked as missing. 
"""
function na_recode(radiance_datacube, clouds_datacube; replacement = missing) 
    radiance_datacube = rebuild(radiance_datacube; missingval = nothing)
    radiance_datacube = replace_missing(radiance_datacube, missing)
    r_dc = convert(Array{Union{Missing, Float16}}, view(radiance_datacube, Band(1)))
    cf_dc = convert(Array{UInt8, 3}, view(clouds_datacube, Band(1)))
    for i in 1:size(cf_dc)[3]
        r_dc[:, :, i] = na_recode_img(r_dc[:, :, i], cf_dc[:, :, i]; replacement = replacement)
    end
    cf_dc = 0 
    GC.gc()
    return Raster(add_dim(r_dc), dims(radiance_datacube))
end
    