# Polar Bear Survival vs GHG Emissions 
Code and data for analysis in `Unlock the Endangered Species Act to address GHG emissions' by Amstrup and Bitz (2023)

This code is available on Zenodo at [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.8263597.svg)](https://doi.org/10.5281/zenodo.8263597)
                                                                                                       
The order to run these scriptps is as follows:                                                         
                                                                                                       
1) Compute regressions using bootsrapping to compute mean confidence intervals of the slopes.          
See Suplemental Materials and scripts for more details:                                                
                                                                                                       
Fit_Demographics_vs_FD.m                                                                               
Fit_CumCO2_vs_IFD_bootstrap_v5.m                                                                       
Combine_Fits_to_Demographics_vs_CumCO2.m                                                               
Compute_CIs.m                                                                                          
                                                                                                       
2) Using the analysis from step 1, plot figures and output tables that appear in the supplement ariticle. Note that Science created the figure in the main text using csv tables from step 3.          
                                                                                                       
Plot_combo_Fig1.m                                                                                      
Plot_FigS1_and_tables.m                                                                                
Plot_FigS3_and_tables.m                                                                                
Plot_FigS2a.m                                                                                          
                                                                                          
3) Make a set of csv tables for each panel for the figure in the main text                                                
Save_Fig1_data.m                                                                                       
                                                                                                 
Data needed for step 1:                                                                                
                                                                                                       
The subdirectory IceDates has all the code to compute the ice-free days (IFDs).                        
The results are also available in the subdirectory in a csv file, so the scripts                       
need not be run.                                                                                       
                                                                                                       
See script Fit_CumCO2_vs_IFD_bootstrap_v5.m to acquire the eCO2 data, published elsewhere              
                                                                                                       
See script Combine_Fits_to_Demographics_vs_CumCO2.m to acquire the demographic model data,             
described in Molnar et al (2020) and available by request from Dr. Molnar                         
                                                                                                       
The results from running the scripts will not be identical to the published results because random numbers are generated in the bootstrap step. The results should be consistent within the uncertainty range.

Subdirectories matfiles and figures are provided with examples of the possible output/figures that can be created from running these sripts. They are not meant to be complete, but rather for the user to verify they are on the right track.
