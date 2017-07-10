PROGRAM WRF_TO_RADAR
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
!=======================================================================

USE common
USE common_wrf
USE common_wrf_to_radar
USE common_radar_tools


implicit none

!------------------------------------------------------------------

call get_namelist_vars

IF ( .NOT. fake_radar )THEN   
  WRITE(6,*)'Interpolationg model data to a real radar location and geometry'
  CALL interp_to_real_radar
ELSE
  WRITE(6,*)'Interpolating model data to a fake radar location and geometry'
  CALL interp_to_fake_radar
ENDIF


END PROGRAM WRF_TO_RADAR

