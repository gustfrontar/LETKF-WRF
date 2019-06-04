PROGRAM WRF_TO_RADAR_ENS
!=======================================================================
!
! [PURPOSE:] Main program of WRF_TO_RADAR
! This program interpolates WRF model data to a radar grid.
! The output is reflectivity factor and doppler wind.
!
! [HISTORY:]
!   02/19/2014 Juan Ruiz created
!   03/17/2016 Juan Ruiz modified the code to add multiple radars and 
!                        and model files. A namelist file to control the
!                        interpolation process was also added.

! TODO LIST:
! -Incorporate a C-band observation operator.
! -Incorporate the computation of attenuation.
! -Incorporate the effect of anomalous propagation.
! -Incorporate beam broadening effect. 

! TODO Incorporate ensemble capabilities using MPI paralellization.
!=======================================================================

USE common
USE common_wrf
USE common_wrf_to_radar
USE common_radar_tools


implicit none

!------------------------------------------------------------------

call get_namelist_vars

!MPI Init


WRITE(6,*)'Interpolationg model data to a real radar location and geometry'
CALL interp_to_real_radar_ens( im , radar )


!MPI Finalize


END PROGRAM WRF_TO_RADAR

