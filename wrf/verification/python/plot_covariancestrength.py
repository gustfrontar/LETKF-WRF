# -*- coding: utf-8 -*-
#Este script plotea perfiles verticales de la intensidad de las covarianzas.
"""
Created on Tue Nov  1 18:45:15 2016

@author:
"""

import numpy as np
import matplotlib.pyplot as plt
import datetime as dt
import binary_io as bio
import bred_vector_functions as bvf
import os
import numpy.ma as ma

basedir='/home/jruiz/share/EXPERIMENTS/experiments_large_ensemble/data/'

expname = '/OsakaPAR_1km_control1000m_smallrandompert_noda/'

plotbasedir=basedir + expname + '/plots/'

undef_in=1.0e20

buffer_zone_size=20  #Data close to the domain borders will be ignored.

tr_rain=5e-4      #QHYD above this tr means rainy grid point.
tr_norain=0.5e-4    #QHYD below this tr means no rain


undef_out=np.nan

filetype='analgp'   #analgp , analgz , guesgp , guesgz

qmeanlevs=[0.001,0.0050,0.05]   #Levels for vertically averaged condensate.


#The following will be used to extract a particlar variable from the original data.
#This variables should be especified according to the data that we have in the binary files.

ctl_vars='U','V','W','T','QV','QHYD'  #Complete list of variables in ctl file.
ctl_inirecord=[0,12,24,36,48,60]        #Starting record for each variable. From 0 to N
ctl_endrecord=[11,23,35,47,59,71]       #End record for each variable. From 0 to N.

#Which variables and levels are we going to plot?

plotlevels=np.array([2,7,9])   #Which levels will be plotted (this levels are equivalent to the BV plots)
plotvars='U','V','W','T','QV','QHYD'    #Which variables will be plotted.

#Covariance strength

base_vars='qhydro','u','v','tk'
cov_vars='qhydro','u','v'

#Create the plotbasedir
if not os.path.exists(plotbasedir):
   os.mkdir(plotbasedir)

#Defini initial and end times using datetime module.
itime = dt.datetime(2013,7,13,5,25,00)  #Initial time.
etime = dt.datetime(2013,7,13,5,39,00)  #End time.

#Define the delta.
delta=dt.timedelta(seconds=60)

nx=180
ny=180
nz=np.max(ctl_endrecord) + 1  #Total number of records in binary file.
nlev=12                       #Number of vertical levels for 3D variables.
ntimes=1 + np.around((etime-itime).seconds / delta.seconds)  #Total number of times.
levels=np.array([ 1000,950,900,850,800,700,600,500,400,300,200,150])
levels_str = np.empty([np.size(levels)], dtype="U10")

times=np.zeros((ntimes))

for ii in range(np.size(levels)):
    levels_str[ii]=np.char.mod('%d',levels[ii])

#Define regions


ens_mean=dict()

#Get lat lon.

lat=bio.read_data_direct(basedir + expname + '/latlon/lat.grd',nx,ny,1,'>f4')[:,:,0]
lon=bio.read_data_direct(basedir + expname + '/latlon/lon.grd',nx,ny,1,'>f4')[:,:,0]

for ib in 'u'  :
#for ib in base_vars :
  for ic in 'u'  :
#  for ic in cov_vars :

    
    ctime=itime

    it=0

    corrindex_profile=np.zeros([nlev,ntimes,2])
    covindex_profile=np.zeros([nlev,ntimes,2])
    corrdistindex_profile=np.zeros([nlev,ntimes,2])
    ndata=np.zeros([nlev,ntimes,2])

    print ( 'Reading the data ')

    while ( ctime <= etime ):
    
      times[it]=it

      print( ctime )

      var_comb= ib + '_' + ic 

      my_file=basedir + expname + ctime.strftime("%Y%m%d%H%M%S") + '/'+ filetype + '/' +  'corrindex_' + var_comb + '.grd'

      corrindex=bio.read_data_direct(my_file,nx,ny,nlev,'>f4',undef_in=undef_in,undef_out=undef_out)

      corrindex=ma.masked_where(np.isnan(corrindex),corrindex)
      corrindex.fill_value=0.0

      my_file=basedir + expname + ctime.strftime("%Y%m%d%H%M%S") + '/'+ filetype + '/' +  'covindex_' + var_comb + '.grd'

      covindex=bio.read_data_direct(my_file,nx,ny,nlev,'>f4',undef_in=undef_in,undef_out=undef_out)
 
      covindex=ma.masked_where(np.isnan(covindex),covindex)
      covindex.fill_value=0.0

      my_file=basedir + expname + ctime.strftime("%Y%m%d%H%M%S") + '/'+ filetype + '/' +  'corrdistindex_' + var_comb + '.grd'

      corrdistindex=bio.read_data_direct(my_file,nx,ny,nlev,'>f4',undef_in=undef_in,undef_out=undef_out)

      corrdistindex=ma.masked_where(np.isnan(corrdistindex),corrdistindex)
      corrdistindex.fill_value=0.0

      #Read the ensemble mean to get the information from the storm location.
      my_file=basedir + expname + ctime.strftime("%Y%m%d%H%M%S") + '/'+ filetype + '/' + '/moment0001.grd'

      ens_mean=bio.read_data_scale_2(my_file,nx,ny,nz,ctl_vars,ctl_inirecord,ctl_endrecord,dtypein='f4',undef_in=undef_in,undef_out=undef_out)

      #Compute total integrated liquid (we will use this to identify areas associated with clouds and convection)
      int_liquid = np.nanmean(ens_mean['QHYD'],2)

      #Add the profile depending if it is a rainy point or a no rainy point
      rain_mask = int_liquid > tr_rain      #Rain mask
      norain_mask = ( int_liquid < tr_norain ) & ( int_liquid >= 0.0 )  #No rain mask 

 
      my_plotdir= plotbasedir + '/time_independent_plots/'

      if not os.path.exists(my_plotdir) :
         os.makedirs(my_plotdir)


      print("Plotting the CORRINDEX ")

      #Plot moments.
      varname= 'corrindex_' + var_comb
      myrange='fixed'
      scale_max=0.4
      scale_min=0
      

      #Plot the moment.
      bvf.plot_var_levels(corrindex,lon,lat,plotlevels,plotbasedir,varname,varcontour=int_liquid,range=myrange,scale_max=scale_max,scale_min=scale_min,mycolorbar='seismic',clevels=qmeanlevs,date=ctime.strftime("%Y%m%d%H%M%S"))

      print("Plotting the CORRDISTINDEX ")

      #Plot moments.
      varname= 'corrdistindex_' + var_comb
      myrange='fixed'
      scale_max=np.nanmax(corrdistindex)
      scale_min=0


      #Plot the moment.
      bvf.plot_var_levels(corrindex,lon,lat,plotlevels,plotbasedir,varname,varcontour=int_liquid,range=myrange,scale_max=scale_max,scale_min=scale_min,mycolorbar='seismic',clevels=qmeanlevs,date=ctime.strftime("%Y%m%d%H%M%S"))

      print("Plotting the COVDISTINDEX ")

      #Plot moments.
      varname= 'covindex_' + var_comb
      myrange='fixed'
      scale_max=np.nanmax(covindex)
      scale_min=0


      #Plot the moment.
      bvf.plot_var_levels(covindex,lon,lat,plotlevels,plotbasedir,varname,varcontour=int_liquid,range=myrange,scale_max=scale_max,scale_min=scale_min,mycolorbar='seismic',clevels=qmeanlevs,date=ctime.strftime("%Y%m%d%H%M%S"))





print ( "Finish time loop" )

