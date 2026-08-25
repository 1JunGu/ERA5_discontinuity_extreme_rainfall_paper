# Code for ERA5 Assimilation-Window Discontinuities and Extreme-Rainfall Forecasts

This repository contains the analysis and plotting scripts used to produce the figures in:

> Gu, J., Zhao, C., Feng, J., Xu, M., Tang, Z., and Li, G. (2026). **The impact of ERA5 assimilation-window discontinuities on convection-permitting forecasts of extreme precipitation: a case study of the July 2023 North China heavy rainfall.** *Environmental Research Letters*. [https://doi.org/10.1088/1748-9326/ae9d97](https://doi.org/10.1088/1748-9326/ae9d97)

## Repository contents

The scripts are organized by figure number:

| Directory | Paper figure | Main contents |
| --- | --- | --- |
| [`figure01/`](figure01/) | Figure 1 | Temporal-discontinuity diagnostics for moist static energy (MSE) |
| [`figure02/`](figure02/) | Figure 2 | Three-day precipitation comparison |
| [`figure03/`](figure03/) | Figure 3 | Fractions Skill Score (FSS) and MODE verification |
| [`figure04/`](figure04/) | Figure 4 | Circulation and rainfall differences relative to ERA5 and CLDAS |
| [`figure05/`](figure05/) | Figure 5 | Evolution of 500 hPa geopotential height, 850 hPa moisture flux, and rainfall |
| [`figure06/`](figure06/) | Figure 6 | Precipitation comparison including the adjusted experiment |

Where available, a figure directory contains its own `README.md` with the mapping between scripts and manuscript panels (see [`figure01/README.md`](figure01/README.md), [`figure03/README.md`](figure03/README.md), and [`figure05/README.md`](figure05/README.md)).

## Requirements

- [NCAR Command Language (NCL)](https://www.ncl.ucar.edu/) version 6.6.2
- The ERA5, CLDAS, MPAS, and verification data used by the relevant script
- The locally maintained NCL helper files referenced by the scripts, including `plot.ncl` and, where required, `io.ncl`

## Usage

The scripts are intended to be run from their corresponding figure directories. For example:

```bash
cd figure01
ncl calc-plot_wavelet-dt-MSE_global_hourly_single-level.ncl
```

Before running a script:

1. Update the `load` statements so that they point to your local NCL helper files.
2. Replace the author-specific data, mesh, and output paths with paths available on your system.
3. Check that the input NetCDF/CSV files contain the variable names and dimensions expected by the script.
4. Create any required output directories.

Many paths are currently hard-coded for the computing environment used in the paper. The scripts therefore document the published workflow but require local configuration before they can be executed elsewhere.

## Data availability

This repository distributes the original scripts only. The simulation output and supporting reanalysis and observational datasets are not included because of their size. Users must obtain or generate the corresponding input data separately.

## Citation

If you use these scripts, please cite the associated paper:

```bibtex
@article{Gu2026ERA5Discontinuities,
  author  = {Gu, Jun and Zhao, Chun and Feng, Jiawang and Xu, Mingyue and Tang, Zhaojun and Li, Gudongze},
  title   = {The impact of {ERA5} assimilation-window discontinuities on convection-permitting forecasts of extreme precipitation: a case study of the July 2023 North China heavy rainfall},
  journal = {Environmental Research Letters},
  year    = {2026},
  doi     = {10.1088/1748-9326/ae9d97},
  url     = {https://doi.org/10.1088/1748-9326/ae9d97}
}
```

## License

The code is released under the [MIT License](LICENSE).
