# LeyLa
is a Matlab-based tool for analysing Raman spectra. The name is derived from two cities (Ljubljana and Leoben) where the idea for this program emerged.

## Features
- Fitting spectra with analytical functions including errorbar estimates (Curve Fitting Tool)
- Spline background correction
- Spectra subtraction, shift, normalization, binning, etc.
- Analytical functions used for fitting are defined in a separate file. This way new functions can be added easily.

## Recognized file formats
- Plain ASCII (two columns, no header)


## Documentation

Follow tutorial at https://antonpotocnik.com/?page_id=574


# What is new?

TODO in v0.9
- fit mode: ReFit, uncheck Update Fix column

v0.83 2014-07-05
- added export functions 
- spelling: substract -> subtract. In the subtract menu, loose subtract word in front of Data, Base Line, and Fit

v0.82 2014-05-29 
- bug when importing fit parameters corrected 

v0.81 2014-04-24
- removed bug when checking if the version is old or new. Now new versions are not beeing converter to new ;)
- conversion also removes obsoleete spc.results# fieldnames
- function "plot_fit_results.m" is renamed to "plot_sfi_results" not to get confused with eprFit functions

v0.8 2013-02-02
- added spline base correction 
- when after clicking add or remove point you click on the graph with right button, the action is canceled
- corrected substract base line
- corrected multiply, shift, bin, normalize to contain spectral range selection
- corrected Return Original Data

v0.7 2014-01-27
- Plot results is improved
- Save and load parameters added in the Fit menu
- description is corrected
- right click on graph copies Y value to clipboard, left click does X
- Fit modes are added in the menu

