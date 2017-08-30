!MODULE common
!=======================================================================
!
! [PURPOSE:] General constants and procedures
!
! [ATTENTION:] This module calls 'SFMT.f90'
!
! [HISTORY:]
!   07/20/2004 Takemasa MIYOSHI  created
!   01/23/2009 Takemasa MIYOSHI  modified for SFMT
!
!=======================================================================
!  IMPLICIT NONE
!  PUBLIC
!-----------------------------------------------------------------------
! Variable size definitions
!-----------------------------------------------------------------------
!  INTEGER,PARAMETER :: r_size=kind(0.0d0)
!  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
!-----------------------------------------------------------------------
! Constants
!-----------------------------------------------------------------------
!  REAL(r_size),PARAMETER :: pi=3.1415926535d0
!  REAL(r_size),PARAMETER :: gg=9.81d0
!  REAL(r_size),PARAMETER :: rd=287.0d0
!  REAL(r_size),PARAMETER :: cp=1005.7d0
!  REAL(r_size),PARAMETER :: re=6371.3d3
!  REAL(r_size),PARAMETER :: r_omega=7.292d-5
!  REAL(r_size),PARAMETER :: t0c=273.15d0
!  REAL(r_size),PARAMETER :: undef=-9.99d33

!CONTAINS
!-----------------------------------------------------------------------
! Mean
!-----------------------------------------------------------------------
MODULE common_data

  !This module keeps constants and large data sets. F2py hava a problem handling 
  !variables and routines in the same module, but they can be specified in different modules.
  !So I create one module for the data and one module for the routines that uses the data module.

  INTEGER,PARAMETER :: r_size=kind(0.0d0)
  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)

  REAL(r_sngl),ALLOCATABLE :: my_ensemble(:,:,:,:)

  LOGICAL     ,ALLOCATABLE :: my_undefmask(:,:,:)

END MODULE common_data



MODULE common_functions 

PUBLIC

contains


SUBROUTINE allocate_ensemble(nx,ny,nz,nbv)
use common_data
IMPLICIT NONE
INTEGER, INTENT(IN) :: nx,ny,nz,nbv

 ALLOCATE( my_ensemble(nx,ny,nz,nbv) , my_undefmask(nx,ny,nz) )

END SUBROUTINE allocate_ensemble

SUBROUTINE add_to_ensemble(nx,ny,nz,ibv,my_data)
use common_data
IMPLICIT NONE
INTEGER, INTENT(IN) :: ibv , nx,ny,nz
REAL(r_sngl) , INTENT(IN) :: my_data(nx,ny,nz)

  my_ensemble(:,:,:,ibv)=my_data(:,:,:)


END SUBROUTINE add_to_ensemble

SUBROUTINE com_mean(ndim,var,amean)
  use common_data
  IMPLICIT NONE
!  INTEGER,PARAMETER :: r_size=kind(0.0d0)
!  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
  INTEGER,INTENT(IN) :: ndim
  REAL(r_size),INTENT(IN) :: var(ndim)
  REAL(r_size),INTENT(OUT) :: amean

  INTEGER :: i

  amean = 0.0d0
  DO i=1,ndim
    amean = amean + var(i)
  END DO
  amean = amean / REAL(ndim,r_size)

  RETURN
END SUBROUTINE com_mean

SUBROUTINE com_mean_sngl(ndim,var,amean)
  use common_data
  IMPLICIT NONE
!  INTEGER,PARAMETER :: r_size=kind(0.0d0)
!  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
  INTEGER,INTENT(IN) :: ndim
  REAL(r_sngl),INTENT(IN) :: var(ndim)
  REAL(r_sngl),INTENT(OUT) :: amean

  INTEGER :: i

  amean = 0.0d0
  DO i=1,ndim
    amean = amean + var(i)
  END DO
  amean = amean / REAL(ndim,r_sngl)

  RETURN
END SUBROUTINE com_mean_sngl


!-----------------------------------------------------------------------
! Standard deviation
!-----------------------------------------------------------------------
SUBROUTINE com_stdev(ndim,var,aout)
  use common_data
  IMPLICIT NONE
!  INTEGER,PARAMETER :: r_size=kind(0.0d0)
!  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
  INTEGER,INTENT(IN) :: ndim
  REAL(r_size),INTENT(IN) :: var(ndim)
  REAL(r_size),INTENT(OUT) :: aout

  REAL(r_size) :: amean
  REAL(r_size) :: dev(ndim)

  CALL com_mean(ndim,var,amean)

  dev(:) = var(:) - amean

  aout = SQRT( SUM(dev*dev) / REAL(ndim-1,r_size) )

  RETURN
END SUBROUTINE com_stdev

SUBROUTINE com_stdev_sngl(ndim,var,aout)
  use common_data
  IMPLICIT NONE
!  INTEGER,PARAMETER :: r_size=kind(0.0d0)
!  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
  INTEGER,INTENT(IN) :: ndim
  REAL(r_sngl),INTENT(IN) :: var(ndim)
  REAL(r_sngl),INTENT(OUT) :: aout

  REAL(r_sngl) :: amean
  REAL(r_sngl) :: dev(ndim)

  CALL com_mean_sngl(ndim,var,amean)

  dev(:) = var(:) - amean

  aout = SQRT( SUM(dev*dev) / REAL(ndim-1,r_size) )

  RETURN
END SUBROUTINE com_stdev_sngl

!-----------------------------------------------------------------------
! Covariance
!-----------------------------------------------------------------------
SUBROUTINE com_covar(ndim,var1,var2,cov)
  use common_data
  IMPLICIT NONE
!  INTEGER,PARAMETER :: r_size=kind(0.0d0)
!  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
  INTEGER,INTENT(IN) :: ndim
  REAL(r_size),INTENT(IN) :: var1(ndim)
  REAL(r_size),INTENT(IN) :: var2(ndim)
  REAL(r_size),INTENT(OUT) :: cov

  REAL(r_size) :: amean1,amean2
  REAL(r_size) :: dev1(ndim),dev2(ndim)

  CALL com_mean(ndim,var1,amean1)
  CALL com_mean(ndim,var2,amean2)

  dev1(:) = var1(:) - amean1
  dev2(:) = var2(:) - amean2

  cov = SUM( dev1*dev2 ) / REAL(ndim-1,r_size)

  RETURN
END SUBROUTINE com_covar

SUBROUTINE com_covar_sngl(ndim,var1,var2,cov)
  use common_data
  IMPLICIT NONE
!  INTEGER,PARAMETER :: r_size=kind(0.0d0)
!  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
  INTEGER,INTENT(IN) :: ndim
  REAL(r_sngl),INTENT(IN) :: var1(ndim)
  REAL(r_sngl),INTENT(IN) :: var2(ndim)
  REAL(r_sngl),INTENT(OUT) :: cov

  REAL(r_sngl) :: amean1,amean2
  REAL(r_sngl) :: dev1(ndim),dev2(ndim)

  CALL com_mean_sngl(ndim,var1,amean1)
  CALL com_mean_sngl(ndim,var2,amean2)

  dev1(:) = var1(:) - amean1
  dev2(:) = var2(:) - amean2

  cov = SUM( dev1*dev2 ) / REAL(ndim-1,r_sngl)

  RETURN
END SUBROUTINE com_covar_sngl

SUBROUTINE com_covar_sngl_sample(ndim,var1,var2,sampleindex,cov)
  use common_data
  IMPLICIT NONE
!  INTEGER,PARAMETER :: r_size=kind(0.0d0)
!  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
  INTEGER,INTENT(IN) :: ndim
  REAL(r_sngl),INTENT(IN) :: var1(ndim)
  REAL(r_sngl),INTENT(IN) :: var2(ndim)
  INTEGER     ,INTENT(IN) :: sampleindex(ndim)
  REAL(r_sngl),INTENT(OUT) :: cov
  INTEGER  :: ii
  REAL(r_sngl) :: amean1,amean2
  REAL(r_sngl) :: dev1(ndim),dev2(ndim)

  !Reorder the sample
  DO ii=1,ndim
    dev1(ii) = var1(sampleindex(ii))
    dev2(ii) = var2(sampleindex(ii))
  ENDDO

  CALL com_mean_sngl(ndim,dev1,amean1)
  CALL com_mean_sngl(ndim,dev2,amean2)

  dev1=dev1-amean1
  dev2=dev2-amean2

  cov = SUM( dev1*dev2 ) / REAL(ndim-1,r_sngl)

  RETURN
END SUBROUTINE com_covar_sngl_sample


!-----------------------------------------------------------------------
! Correlation
!-----------------------------------------------------------------------
SUBROUTINE com_correl(ndim,var1,var2,cor)
  use common_data
  IMPLICIT NONE
!  INTEGER,PARAMETER :: r_size=kind(0.0d0)
!  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
  INTEGER,INTENT(IN) :: ndim
  REAL(r_size),INTENT(IN) :: var1(ndim)
  REAL(r_size),INTENT(IN) :: var2(ndim)
  REAL(r_size),INTENT(OUT) :: cor

  REAL(r_size) :: cov,stdev1,stdev2

  CALL com_stdev(ndim,var1,stdev1)
  CALL com_stdev(ndim,var2,stdev2)
  CALL com_covar(ndim,var1,var2,cov)

  cor = cov/stdev1/stdev2

  RETURN
END SUBROUTINE com_correl

SUBROUTINE com_correl_sngl(ndim,var1,var2,cor)
  use common_data
  IMPLICIT NONE
!  INTEGER,PARAMETER :: r_size=kind(0.0d0)
!  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
  INTEGER,INTENT(IN) :: ndim
  REAL(r_sngl),INTENT(IN) :: var1(ndim)
  REAL(r_sngl),INTENT(IN) :: var2(ndim)
  REAL(r_sngl),INTENT(OUT) :: cor

  REAL(r_sngl) :: cov,stdev1,stdev2

  CALL com_stdev_sngl(ndim,var1,stdev1)
  CALL com_stdev_sngl(ndim,var2,stdev2)
  CALL com_covar_sngl(ndim,var1,var2,cov)

  cor = cov/stdev1/stdev2

  RETURN
END SUBROUTINE com_correl_sngl


!-----------------------------------------------------------------------
! Anomaly Correlation
!-----------------------------------------------------------------------
SUBROUTINE com_anomcorrel(ndim,var1,var2,varmean,cor)
  use common_data
  IMPLICIT NONE
!  INTEGER,PARAMETER :: r_size=kind(0.0d0)
!  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
  INTEGER,INTENT(IN) :: ndim
  REAL(r_size),INTENT(IN) :: var1(ndim)
  REAL(r_size),INTENT(IN) :: var2(ndim)
  REAL(r_size),INTENT(IN) :: varmean(ndim)
  REAL(r_size),INTENT(OUT) :: cor

  REAL(r_size) :: dev1(ndim),dev2(ndim)

  dev1 = var1 - varmean
  dev2 = var2 - varmean

  cor = SUM( dev1*dev2 ) / SQRT( SUM(dev1*dev1) * SUM(dev2*dev2) )

  RETURN
END SUBROUTINE com_anomcorrel
!-----------------------------------------------------------------------
! L2 Norm
!-----------------------------------------------------------------------
SUBROUTINE com_l2norm(ndim,var,anorm)
  use common_data
  IMPLICIT NONE
!  INTEGER,PARAMETER :: r_size=kind(0.0d0)
!  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
  INTEGER,INTENT(IN) :: ndim
  REAL(r_size),INTENT(IN) :: var(ndim)
  REAL(r_size),INTENT(OUT) :: anorm

  anorm = SQRT( SUM(var*var) )

  RETURN
END SUBROUTINE com_l2norm
!-----------------------------------------------------------------------
! RMS (root mean square)
!-----------------------------------------------------------------------
SUBROUTINE com_rms(ndim,var,rmsv)
  use common_data
  IMPLICIT NONE
!  INTEGER,PARAMETER :: r_size=kind(0.0d0)
!  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
  INTEGER,INTENT(IN) :: ndim
  REAL(r_size),INTENT(IN) :: var(ndim)
  REAL(r_size),INTENT(OUT) :: rmsv

  rmsv = SQRT( SUM(var*var) / REAL(ndim,r_size) )

  RETURN
END SUBROUTINE com_rms
!-----------------------------------------------------------------------
! Lanczos Filter (Low-pass) with cyclic boundary
!-----------------------------------------------------------------------
SUBROUTINE com_filter_lanczos(ndim,fc,var)
  use common_data
  IMPLICIT NONE
!  INTEGER,PARAMETER :: r_size=kind(0.0d0)
!  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
  INTEGER,INTENT(IN) :: ndim
  REAL(r_size),PARAMETER :: pi=3.1415926535d0
  REAL(r_size),INTENT(IN) :: fc    ! critical frequency in [0,pi]
  REAL(r_size),INTENT(INOUT) :: var(ndim)

  INTEGER,PARAMETER :: lresol=10

  REAL(r_size) :: weight(-lresol:lresol)
  REAL(r_size) :: varwk(1-lresol:ndim+lresol)
  REAL(r_size) :: rl,rlresol
  INTEGER :: i,l
!
! Weight
!
  rlresol = REAL(lresol,r_size)
  DO l=-lresol,-1
    rl = REAL(l,r_size)
    weight(l) = SIN(fc*rl) * SIN(pi*rl/rlresol) &
      & * rlresol / pi / rl / pi / rl
  END DO
  DO l=1,lresol
    rl = REAL(l,r_size)
    weight(l) = SIN(fc*rl) * SIN(pi*rl/rlresol) &
      & * rlresol / pi / rl / pi / rl
  END DO
  weight(0) = fc / pi
!
! Cyclic boundary
!
  DO i=0,1-lresol,-1
    varwk(i) = var(ndim+i)
  END DO
  DO i=ndim+1,ndim+lresol
    varwk(i) = var(i-ndim)
  END DO
  varwk(1:ndim) = var(1:ndim)
!
! Filter
!
  var = 0.0d0
  DO i=1,ndim
    DO l=-lresol,lresol
      var(i) = var(i) + weight(l) * varwk(i+l)
    END DO
  END DO

  RETURN
END SUBROUTINE com_filter_lanczos

!-----------------------------------------------------------------------
! DISTANCE BETWEEN TWO POINTS (LONa,LATa)-(LONb,LATb)
!-----------------------------------------------------------------------
SUBROUTINE com_distll(ndim,alon,alat,blon,blat,dist)
  use common_data
  IMPLICIT NONE
!  INTEGER,PARAMETER :: r_size=kind(0.0d0)
!  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
  REAL(r_size),PARAMETER :: pi=3.1415926535d0
  REAL(r_size),PARAMETER :: re=6371.3d3
  INTEGER,INTENT(IN) :: ndim
  REAL(r_size),INTENT(IN) :: alon(ndim)
  REAL(r_size),INTENT(IN) :: alat(ndim)
  REAL(r_size),INTENT(IN) :: blon(ndim)
  REAL(r_size),INTENT(IN) :: blat(ndim)
  REAL(r_size),INTENT(OUT) :: dist(ndim)
  REAL(r_size),PARAMETER :: r180=1.0d0/180.0d0
  REAL(r_size) :: lon1,lon2,lat1,lat2
  REAL(r_size) :: cosd(ndim)
  INTEGER :: i

  DO i=1,ndim
    lon1 = alon(i) * pi * r180
    lon2 = blon(i) * pi * r180
    lat1 = alat(i) * pi * r180
    lat2 = blat(i) * pi * r180

    cosd(i) = SIN(lat1)*SIN(lat2) + COS(lat1)*COS(lat2)*COS(lon2-lon1)
    cosd(i) = MIN( 1.d0,cosd(i))
    cosd(i) = MAX(-1.d0,cosd(i))

    dist(i) = ACOS( cosd(i) ) * re
  END DO

  RETURN
END SUBROUTINE com_distll
!-----------------------------------------------------------------------
! DISTANCE BETWEEN TWO POINTS (LONa,LATa)-(LONb,LATb)
!-----------------------------------------------------------------------
SUBROUTINE com_distll_1(alon,alat,blon,blat,dist)
  use common_data
  IMPLICIT NONE
!  INTEGER,PARAMETER :: r_size=kind(0.0d0)
!  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
  REAL(r_size),PARAMETER :: re=6371.3d3
  REAL(r_size),PARAMETER :: pi=3.1415926535d0
  REAL(r_size),INTENT(IN) :: alon
  REAL(r_size),INTENT(IN) :: alat
  REAL(r_size),INTENT(IN) :: blon
  REAL(r_size),INTENT(IN) :: blat
  REAL(r_size),INTENT(OUT) :: dist
  REAL(r_size),PARAMETER :: r180=1.0d0/180.0d0
  REAL(r_size) :: lon1,lon2,lat1,lat2
  REAL(r_size) :: cosd

  lon1 = alon * pi * r180
  lon2 = blon * pi * r180
  lat1 = alat * pi * r180
  lat2 = blat * pi * r180

  cosd = SIN(lat1)*SIN(lat2) + COS(lat1)*COS(lat2)*COS(lon2-lon1)
  cosd = MIN( 1.d0,cosd)
  cosd = MAX(-1.d0,cosd)

  dist = ACOS( cosd ) * re

  RETURN
END SUBROUTINE com_distll_1
!-----------------------------------------------------------------------
! Cubic spline interpolation
!   [Reference:] Akima, H., 1970: J. ACM, 17, 589-602.
!-----------------------------------------------------------------------
SUBROUTINE com_interp_spline(ndim,x,y,n,x5,y5)
  use common_data
  IMPLICIT NONE
!  INTEGER,PARAMETER :: r_size=kind(0.0d0)
!  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
  INTEGER,INTENT(IN) :: ndim         ! number of grid points
  REAL(r_size),INTENT(IN) :: x(ndim) ! coordinate
  REAL(r_size),INTENT(IN) :: y(ndim) ! variable
  INTEGER,INTENT(IN) :: n            ! number of targets
  REAL(r_size),INTENT(IN) :: x5(n)   ! target coordinates
  REAL(r_size),INTENT(OUT) :: y5(n)  ! target values
  INTEGER :: i,j,m
  REAL(r_size) :: dydx(5),ddydx(4),t(2),dx21,dx
  REAL(r_size) :: wk

  TGT: DO j=1,n
    DO i=1,ndim
      IF(x5(j) == x(i)) THEN
        y5(j) = y(i)
        CYCLE TGT
      END IF
      IF(x5(j) < x(i)) EXIT
    END DO
!       i-3   i-2   i-1    i    i+1   i+2
!     ---+-----+-----+---*-+-----+-----+---
!dydx       1     2     3     4     5
!ddydx         1     2     3     4
!t                   1     2
    IF(i==2) THEN
      DO m=3,5
        dydx(m) = (y(i-3+m)-y(i-4+m)) / (x(i-3+m)-x(i-4+m))
      END DO
      dydx(2) = 2.0d0*dydx(3) - dydx(4)
      dydx(1) = 2.0d0*dydx(2) - dydx(3)
    ELSE IF(i==3) THEN
      DO m=2,5
        dydx(m) = (y(i-3+m)-y(i-4+m)) / (x(i-3+m)-x(i-4+m))
      END DO
      dydx(1) = 2.0d0*dydx(2) - dydx(3)
    ELSE IF(i==ndim) THEN
      DO m=1,3
        dydx(m) = (y(i-3+m)-y(i-4+m)) / (x(i-3+m)-x(i-4+m))
      END DO
      dydx(4) = 2.0d0*dydx(3) - dydx(2)
      dydx(5) = 2.0d0*dydx(4) - dydx(3)
    ELSE IF(i==ndim-1) THEN
      DO m=1,4
        dydx(m) = (y(i-3+m)-y(i-4+m)) / (x(i-3+m)-x(i-4+m))
      END DO
      dydx(5) = 2.0d0*dydx(4) - dydx(3)
    ELSE
      DO m=1,5
        dydx(m) = (y(i-3+m)-y(i-4+m)) / (x(i-3+m)-x(i-4+m))
      END DO
    END IF
    DO m=1,4
      ddydx(m) = ABS(dydx(m+1) - dydx(m))
    END DO
    DO m=1,2
      wk = ddydx(m+2) + ddydx(m)
      IF(wk == 0) THEN
        t(m) = 0.0d0
      ELSE
        t(m) = (ddydx(m+2)*dydx(m+1)+ddydx(m)*dydx(m+2))/wk
      END IF
    END DO
    dx21 = x(i)-x(i-1)
    dx = x5(j) - x(i-1)
    y5(j) = y(i-1) &
        & + dx*t(1) &
        & + dx*dx*(3.0d0*dydx(3)-2.0d0*t(1)-t(2))/dx21 &
        & + dx*dx*dx*(t(1)+t(2)-2.0d0*dydx(3))/dx21/dx21
  END DO TGT

  RETURN
END SUBROUTINE com_interp_spline
!-----------------------------------------------------------------------
! (LON,LAT) --> (i,j) conversion
!   [ORIGINAL AUTHOR:] Masaru Kunii
!-----------------------------------------------------------------------
SUBROUTINE com_pos2ij(msw,nx,ny,flon,flat,num_obs,olon,olat,oi,oj)
  use common_data
  IMPLICIT NONE
!  INTEGER,PARAMETER :: r_size=kind(0.0d0)
!  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
  ! --- inout variables
  INTEGER,INTENT(IN) :: msw   !MODE SWITCH: 1: fast, 2: accurate
  INTEGER,INTENT(IN) :: nx,ny !number of grid points
  REAL(r_size),INTENT(IN) :: flon(nx,ny),flat(nx,ny) !(lon,lat) at (i,j)
  INTEGER,INTENT(IN) :: num_obs !repetition number of conversion
  REAL(r_size),INTENT(IN) :: olon(num_obs),olat(num_obs) !target (lon,lat)
  REAL(r_size),INTENT(OUT) :: oi(num_obs),oj(num_obs) !target (i,j)
  ! --- local work variables
  LOGICAL,PARAMETER :: detailout = .FALSE.
  INTEGER,PARAMETER :: num_grid_ave = 4  ! fix
  INTEGER :: inum,ix,jy,ip,wk_maxp
  INTEGER :: iorder_we,iorder_sn
  INTEGER :: nxp,nyp
  REAL(r_size),PARAMETER :: miss = -32768 
  REAL(r_size),PARAMETER :: max_dist = 2.0e+6
  REAL(r_size) :: rlat_max, rlat_min, rlon_max, rlon_min   
  REAL(r_size) :: dist(num_grid_ave) 
  REAL(r_size) :: dist_min_x(num_obs, num_grid_ave)
  REAL(r_size) :: dist_min_y(num_obs, num_grid_ave) 
  REAL(r_size) :: wk_dist, sum_dist
  REAL(r_size) :: ratio(num_grid_ave)
  IF(detailout) THEN
    WRITE(6,'(A)') '====================================================='
    WRITE(6,'(A)') '      Detailed output of SUBROUTINE com_pos2ij       '
    WRITE(6,'(A)') '====================================================='    
  END IF
  ! ================================================================
  !   Check the Order of flon, flat
  ! ================================================================   
  iorder_we = 1
  iorder_sn = 1
  IF(flon(1,1) > flon(2,1)) THEN
    iorder_we = -1
  END IF
  IF(flat(1,1) > flat(1,2)) THEN
    iorder_sn = -1
  END IF
  IF(detailout) THEN  
    WRITE(6,'(3X,A,I5)') 'Obs Order (WE) :',iorder_we 
    WRITE(6,'(3X,A,I5)') 'Obs Order (SN) :',iorder_sn 
  END IF
  ! ================================================================
  !  FAST MODE
  ! ================================================================   
  IF(msw == 1) THEN
    ! ==============================================================
    !   Surrounding 4 Grid Points Interpolation
    ! ==============================================================   
    Obs_Loop_1 : DO inum=1,num_obs 
      IF(detailout) WRITE(6,'(A,I5,2F15.5)') '*** START OBS ',inum,olon(inum),olat(inum) 
      ! ------------------------------------------------------------
      !    Search Basic Point
      ! ------------------------------------------------------------ 
      nxp = miss
      nyp = miss
      DO jy=1,ny-1
        DO ix=1,nx-1
          rlon_max = MAXVAL(flon(ix:ix+1, jy:jy+1))
          rlon_min = MINVAL(flon(ix:ix+1, jy:jy+1))
          rlat_max = MAXVAL(flat(ix:ix+1, jy:jy+1))
          rlat_min = MINVAL(flat(ix:ix+1, jy:jy+1))
          IF(rlon_min <= olon(inum) .AND. rlon_max >= olon(inum) .AND. &
           & rlat_min <= olat(inum) .AND. rlat_max >= olat(inum)) THEN
            nxp = ix
            nyp = jy
            EXIT
          END IF
        END DO
      END DO
      IF(detailout) WRITE(6,'(3X,A,2I7)') 'nxp, nyp =',nxp,nyp
      IF(nxp == miss .OR. nyp == miss) THEN
        WRITE(6,'(A)') '!!WARNING(com_pos2ij): obs position cannot be detected'
        oi(inum) = miss
        oj(inum) = miss
        CYCLE Obs_Loop_1
      END IF
      ! ------------------------------------------------------------
      !    Interpolation
      ! ------------------------------------------------------------    
      CALL com_distll_1(flon(nxp  ,nyp  ),flat(nxp  ,nyp  ),&
                      & olon(inum),olat(inum),dist(1))
      CALL com_distll_1(flon(nxp+1,nyp  ),flat(nxp+1,nyp  ),&
                      & olon(inum),olat(inum),dist(2))
      CALL com_distll_1(flon(nxp  ,nyp+1),flat(nxp  ,nyp+1),&
                      & olon(inum),olat(inum),dist(3))      
      CALL com_distll_1(flon(nxp+1,nyp+1),flat(nxp+1,nyp+1),&
                      & olon(inum),olat(inum),dist(4))      
      dist(1:4) = dist(1:4) * 1.D-3  
      IF(detailout) WRITE(6,'(3X,A,4F15.5)') 'distance :',dist(1:4) 
      sum_dist = dist(1) * dist(1) * dist(2) * dist(2) * dist(3) * dist(3) &
             & + dist(2) * dist(2) * dist(3) * dist(3) * dist(4) * dist(4) &
             & + dist(3) * dist(3) * dist(4) * dist(4) * dist(1) * dist(1) &
             & + dist(4) * dist(4) * dist(1) * dist(1) * dist(2) * dist(2)
      ratio(1) = (dist(2)*dist(2)*dist(3)*dist(3)*dist(4)*dist(4))/sum_dist
      ratio(2) = (dist(3)*dist(3)*dist(4)*dist(4)*dist(1)*dist(1))/sum_dist
      ratio(3) = (dist(4)*dist(4)*dist(1)*dist(1)*dist(2)*dist(2))/sum_dist
      ratio(4) = (dist(1)*dist(1)*dist(2)*dist(2)*dist(3)*dist(3))/sum_dist
      IF(detailout) WRITE(6,'(3X,A,5F15.5)') 'ratio    :',ratio(1:4),SUM(ratio(1:4))
      oi(inum) = ratio(1) *  nxp    + ratio(2) * (nxp+1) &
             & + ratio(3) *  nxp    + ratio(4) * (nxp+1)
      oj(inum) = ratio(1) *  nyp    + ratio(2) *  nyp    &
             & + ratio(3) * (nyp+1) + ratio(4) * (nyp+1)    
      IF(detailout) WRITE(6,'(3X,A,2F15.5)') 'position :',oi(inum), oj(inum)
 
    END DO Obs_Loop_1
  ! ================================================================
  !  ACCURATE MODE
  ! ================================================================   
  ELSE IF(msw == 2) THEN
    ! ================================================================
    !   Nearest 4 Grid Points Interpolation
    ! ================================================================   
    Obs_Loop_2 : DO inum=1,num_obs
      IF(detailout) WRITE(6,'(A,I5,2F15.5)') '*** START OBS ',inum,olon(inum),olat(inum) 
      ! ------------------------------------------------------------
      !    Search 4-Grid Points
      ! ------------------------------------------------------------      
      dist(1:num_grid_ave) = 1.D+10
      wk_maxp = num_grid_ave    
      DO jy=1,ny
        DO ix=1,nx
          CALL com_distll_1(flon(ix,jy),flat(ix,jy),&
                          & olon(inum) ,olat(inum) ,wk_dist)
          IF(wk_dist > max_dist) CYCLE
          IF(wk_dist < dist(wk_maxp)) THEN
            dist(wk_maxp) = wk_dist
            dist_min_x(inum, wk_maxp) = ix
            dist_min_y(inum, wk_maxp) = jy
            DO ip = 1, num_grid_ave
              IF(dist(ip) == maxval(dist(1:num_grid_ave))) THEN
                wk_maxp = ip
                EXIT
              END IF
            END DO
          END IF
        END DO
      END DO
      IF(detailout) WRITE(6,'(A,4(A,I4,A,I4,A))')  '  Intp Grids : ', &
        & '(', INT(dist_min_x(inum, 1)), ',', INT(dist_min_y(inum, 1)), ') ', &
        & '(', INT(dist_min_x(inum, 2)), ',', INT(dist_min_y(inum, 2)), ') ', &
        & '(', INT(dist_min_x(inum, 3)), ',', INT(dist_min_y(inum, 3)), ') ', &
        & '(', INT(dist_min_x(inum, 4)), ',', INT(dist_min_y(inum, 4)), ') '
      ! ------------------------------------------------------------
      !    Interpolation
      ! ------------------------------------------------------------ 
      dist(1:num_grid_ave) =  dist(1:num_grid_ave) * 1.0D-3
      sum_dist = dist(1) * dist(1) * dist(2) * dist(2) * dist(3) * dist(3)  &
             & + dist(2) * dist(2) * dist(3) * dist(3) * dist(4) * dist(4)  &
             & + dist(3) * dist(3) * dist(4) * dist(4) * dist(1) * dist(1)  &
             & + dist(4) * dist(4) * dist(1) * dist(1) * dist(2) * dist(2)
      ratio(1) = (dist(2)*dist(2)*dist(3)*dist(3)*dist(4)*dist(4))/sum_dist
      ratio(2) = (dist(3)*dist(3)*dist(4)*dist(4)*dist(1)*dist(1))/sum_dist
      ratio(3) = (dist(4)*dist(4)*dist(1)*dist(1)*dist(2)*dist(2))/sum_dist
      ratio(4) = (dist(1)*dist(1)*dist(2)*dist(2)*dist(3)*dist(3))/sum_dist
      IF(detailout) WRITE(6,'(2X,A,5F15.5)') 'ratio      :',ratio(1:4),SUM(ratio(1:4))
      oi(inum) = SUM(ratio(1:num_grid_ave) * dist_min_x(inum, 1:num_grid_ave))
      oj(inum) = SUM(ratio(1:num_grid_ave) * dist_min_y(inum, 1:num_grid_ave))
      IF(detailout) WRITE(6,'(2X,A,2F15.5)') 'position   :',oi(inum),oj(inum)
    END DO Obs_Loop_2
  END IF

  RETURN
END SUBROUTINE com_pos2ij
!-----------------------------------------------------------------------
! UTC to TAI93
!-----------------------------------------------------------------------
SUBROUTINE com_utc2tai(iy,im,id,ih,imin,sec,tai93)
  use common_data
  IMPLICIT NONE
!  INTEGER,PARAMETER :: r_size=kind(0.0d0)
!  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
  INTEGER,INTENT(IN) :: iy,im,id,ih,imin
  REAL(r_size),INTENT(IN) :: sec
  REAL(r_size),INTENT(OUT) :: tai93
  REAL(r_size),PARAMETER :: mins = 60.0d0
  REAL(r_size),PARAMETER :: hour = 60.0d0*mins
  REAL(r_size),PARAMETER :: day = 24.0d0*hour
  REAL(r_size),PARAMETER :: year = 365.0d0*day
  INTEGER,PARAMETER :: mdays(12) = (/31,28,31,30,31,30,31,31,30,31,30,31/)
  INTEGER :: days,i

  tai93 = REAL(iy-1993,r_size)*year + FLOOR(REAL(iy-1993)/4.0,r_size)*day
  days = id -1
  DO i=1,12
    IF(im > i) days = days + mdays(i)
  END DO
  IF(MOD(iy,4) == 0 .AND. im > 2) days = days + 1 !leap year
  tai93 = tai93 + REAL(days,r_size)*day + REAL(ih,r_size)*hour &
              & + REAL(imin,r_size)*mins + sec
  IF(iy > 1993 .OR. (iy==1993 .AND. im > 6)) tai93 = tai93 + 1.0d0 !leap second
  IF(iy > 1994 .OR. (iy==1994 .AND. im > 6)) tai93 = tai93 + 1.0d0 !leap second
  IF(iy > 1995) tai93 = tai93 + 1.0d0 !leap second
  IF(iy > 1997 .OR. (iy==1997 .AND. im > 6)) tai93 = tai93 + 1.0d0 !leap second
  IF(iy > 1998) tai93 = tai93 + 1.0d0 !leap second
  IF(iy > 2005) tai93 = tai93 + 1.0d0 !leap second
  IF(iy > 2008) tai93 = tai93 + 1.0d0 !leap second
  IF(iy > 2012 .OR. (iy==2012 .AND. im > 6)) tai93 = tai93 + 1.0d0 !leap second

  RETURN
END SUBROUTINE com_utc2tai
!-----------------------------------------------------------------------
! TAI93 to UTC
!-----------------------------------------------------------------------
SUBROUTINE com_tai2utc(tai93,iy,im,id,ih,imin,sec)
  use common_data
  IMPLICIT NONE

!  INTEGER,PARAMETER :: r_size=kind(0.0d0)
!  INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
  INTEGER,PARAMETER :: n=8 ! number of leap seconds after Jan. 1, 1993
  INTEGER,PARAMETER :: leapsec(n) = (/  15638399,  47174400,  94608001,&
                                  &    141868802, 189302403, 410227204,&
                                  &    504921605, 615254406/)
  REAL(r_size),INTENT(IN) :: tai93
  INTEGER,INTENT(OUT) :: iy,im,id,ih,imin
  REAL(r_size),INTENT(OUT) :: sec
  REAL(r_size),PARAMETER :: mins = 60.0d0
  REAL(r_size),PARAMETER :: hour = 60.0d0*mins
  REAL(r_size),PARAMETER :: day = 24.0d0*hour
  REAL(r_size),PARAMETER :: year = 365.0d0*day
  INTEGER,PARAMETER :: mdays(12) = (/31,28,31,30,31,30,31,31,30,31,30,31/)
  REAL(r_size) :: wk,tai
  INTEGER :: days,i,leap

  tai = tai93
  sec = 0.0d0
  DO i=1,n
    IF(FLOOR(tai93) == leapsec(i)+1) sec = 60.0d0 + tai93-FLOOR(tai93,r_size)
    IF(FLOOR(tai93) > leapsec(i)) tai = tai -1.0d0
  END DO
  iy = 1993 + FLOOR(tai /year)
  wk = tai - REAL(iy-1993,r_size)*year - FLOOR(REAL(iy-1993)/4.0,r_size)*day
  IF(wk < 0.0d0) THEN
    iy = iy -1
    wk = tai - REAL(iy-1993,r_size)*year - FLOOR(REAL(iy-1993)/4.0,r_size)*day
  END IF
  days = FLOOR(wk/day)
  wk = wk - REAL(days,r_size)*day
  im = 1
  DO i=1,12
    leap = 0
    IF(im == 2 .AND. MOD(iy,4)==0) leap=1
    IF(im == i .AND. days >= mdays(i)+leap) THEN
      im = im + 1
      days = days - mdays(i)-leap
    END IF
  END DO
  id = days +1

  ih = FLOOR(wk/hour)
  wk = wk - REAL(ih,r_size)*hour
  imin = FLOOR(wk/mins)
  IF(sec < 60.0d0) sec = wk - REAL(imin,r_size)*mins

  RETURN
END SUBROUTINE com_tai2utc

!compute the kld distance
SUBROUTINE getmask(nx,ny,nz,nbv,undef)
use common_data
IMPLICIT NONE
!INTEGER,PARAMETER :: r_size=kind(0.0d0)
!INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
REAL(r_sngl) , INTENT(IN) :: undef
!REAL(r_sngl),INTENT(IN)  :: ensemble(nx,ny,nz,nbv) , undef
INTEGER     ,INTENT(IN)  :: nx,ny,nz,nbv
INTEGER                  :: ii,jj,kk,im

my_undefmask=.false.

DO  ii = 1,nx
  DO jj = 1,ny
    DO kk = 1,nz
      DO im = 1,nbv
         if( abs(my_ensemble(ii,jj,kk,im)) == undef )then
           my_undefmask(ii,jj,kk)=.true.
           exit
         endif
      ENDDO 
    ENDDO
  ENDDO
ENDDO


END SUBROUTINE getmask

!compute the kld distance
SUBROUTINE compute_kld(nx,ny,nz,nbv,nbins,kld,undef)
use common_data
IMPLICIT NONE  
!INTEGER,PARAMETER :: r_size=kind(0.0d0)
!INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
REAL(r_sngl),PARAMETER :: pi=3.1415926535e0
INTEGER, INTENT(IN)       :: nbins
INTEGER, INTENT(IN)       :: nx,ny,nz,nbv !Ensemble dimensions.
!REAL(r_sngl), INTENT(IN)  :: ensemble(nx,ny,nz,nbv) !Ensemble data.
REAL(r_sngl), INTENT(IN)  :: undef        !Missing data code.
!LOGICAL, INTENT(IN)       :: undefmask(nx,ny,nz) !Valid grids.
REAL(r_sngl), INTENT(OUT) :: kld(nx,ny,nz)
REAL(r_sngl)              :: tmp(nbv)
INTEGER                   :: ii , jj , kk , ib 
INTEGER*2                 :: histogram(nx,ny,nz,nbins)
REAL(r_sngl)              :: varmin(nx,ny,nz) , varmax(nx,ny,nz)
REAL(r_sngl)              :: moments(nx,ny,nz,2)

REAL(r_sngl)              :: p(nbins) , q(nbins) , dvar , gconst , gconst2 , x

kld=0.0e0

 !Compute the histogram.
 !write(*,*)"Computing histogram"
 CALL compute_histogram(nx,ny,nz,nbv,nbins,undef,varmin,varmax,histogram) 

 !write(*,*)"Computing moments"
 !Compute the mean and standard deviation.
 CALL compute_moments(nx,ny,nz,nbv,2,moments,undef)

 !write(*,*)"Computing kl distance"
!$OMP PARALLEL DO PRIVATE(ii,jj,kk,ib,x,dvar,p,q,gconst,gconst2)
  DO ii=1,nx
    DO jj=1,ny
     DO kk=1,nz
      if( .not. my_undefmask(ii,jj,kk) )then
       dvar=( varmax(ii,jj,kk)-varmin(ii,jj,kk) )/real(nbins,r_sngl) 
       gconst=sqrt(1./(pi*2*moments(ii,jj,kk,2)))
       gconst2=(1./(2*moments(ii,jj,kk,2)))
       kld(ii,jj,kk)=0.0e0
       DO ib=1,nbins
         x=varmin(ii,jj,kk)+(ib-0.5)*dvar
         p(ib)=real(histogram(ii,jj,kk,ib),r_sngl)/real(nbv,r_sngl)            !Ensemble pdf
         q(ib)=dvar*gconst*exp(-((x-moments(ii,jj,kk,1))**2)*gconst2)          !Gaussian pdf.

         if( p(ib) > 0 )then
           !write(*,*)p(ib),q(ib),log(p(ib)),log(q(ib))
           kld(ii,jj,kk)=kld(ii,jj,kk)+p(ib)*( log(p(ib)) - log(q(ib) ) )
         endif
       ENDDO
       !stop
       !if( kld(ii,jj,kk) < 0 )kld(ii,jj,kk)=0.0e0
      else
       kld(ii,jj,kk)=undef
      endif
     ENDDO
    ENDDO
  ENDDO
!$OMP END PARALLEL DO

END SUBROUTINE compute_kld

!compute the firtst N moments of the PDF centered around the mean.
SUBROUTINE compute_moments(nx,ny,nz,nbv,nmoments,moments,undef)
use common_data
IMPLICIT NONE  
!INTEGER,PARAMETER :: r_size=kind(0.0d0)
!INTEGER,PARAMETER :: r_sngl=kind(0.0e0)
INTEGER, INTENT(IN)       :: nx,ny,nz,nbv !Ensemble dimensions.
!REAL(r_sngl), INTENT(IN)  :: ensemble(nx,ny,nz,nbv) !Ensemble data.
REAL(r_sngl), INTENT(IN)  :: undef        !Missing data code.
INTEGER, INTENT(IN)       :: nmoments     !Number of moments to be computed.
!LOGICAL, INTENT(IN)       :: undefmask(nx,ny,nz) !Valid grids.
REAL(r_sngl), INTENT(OUT) :: moments(nx,ny,nz,nmoments)
REAL(r_sngl)              :: tmp(nbv)
INTEGER                   :: ii , jj , kk , im


moments=0.0e0

!$OMP PARALLEL DO PRIVATE(ii,jj,kk,im,tmp)
  DO ii=1,nx
   DO im=1,nmoments
    DO jj=1,ny
     DO kk=1,nz
      if( .not. my_undefmask(ii,jj,kk) )then
       tmp=( ( my_ensemble(ii,jj,kk,:)-moments(ii,jj,kk,1) ) )**im
       CALL com_mean_sngl(nbv,tmp,moments(ii,jj,kk,im))
      else
       moments(ii,jj,kk,im)=undef
      endif
     ENDDO
    ENDDO
   ENDDO
  ENDDO
!$OMP END PARALLEL DO



END SUBROUTINE compute_moments

!Compute the firtst N moments of the PDF centered around the mean.
SUBROUTINE compute_histogram(nx,ny,nz,nbv,nbins,undef,varmin,varmax,histogram)
use common_data
IMPLICIT NONE
!INTEGER,PARAMETER         :: r_size=kind(0.0d0)
!INTEGER,PARAMETER         :: r_sngl=kind(0.0e0)
INTEGER, INTENT(IN)       :: nx,ny,nz,nbv           !Ensemble dimensions.
!REAL(r_sngl), INTENT(IN)  :: ensemble(nx,ny,nz,nbv) !Ensemble data.
INTEGER, INTENT(IN)       :: nbins                  !Number of moments to be computed.
!LOGICAL, INTENT(IN)       :: undefmask(nx,ny,nz)    !Valid grids.
LOGICAL                   :: tmpundefmask(nx,ny,nz)
REAL(r_sngl), INTENT(IN)  :: undef
INTEGER*2, INTENT(OUT)    :: histogram(nx,ny,nz,nbins) 
INTEGER                   :: tmpindex , reclength , iunit
REAL(r_sngl),INTENT(OUT)  :: varmin(nx,ny,nz),varmax(nx,ny,nz)
REAL(r_sngl)              :: tmp(nbv) , dvar
INTEGER                   :: ii , jj , kk , im , irec
!CHARACTER(20)             :: histogram_out='histogram.grd'
!CHARACTER(20)             :: minval_out='minval.grd'
!CHARACTER(20)             :: maxval_out='maxval.grd'

histogram=0

tmpundefmask=.true. !Do not mask output fields.

!$OMP PARALLEL DO PRIVATE(ii,jj,kk)
  DO ii=1,nx
   DO jj=1,ny
    DO kk=1,nz
       varmin(ii,jj,kk)=MINVAL( my_ensemble(ii,jj,kk,:) )
       varmax(ii,jj,kk)=MAXVAL( my_ensemble(ii,jj,kk,:) )
    ENDDO
   ENDDO
  ENDDO
!$OMP END PARALLEL DO

!$OMP PARALLEL DO PRIVATE(ii,jj,kk,im,tmp,dvar,tmpindex)
  DO ii=1,nx
   DO jj=1,ny
    DO kk=1,nz
      if( .not. my_undefmask(ii,jj,kk) ) then

       dvar=( varmax(ii,jj,kk)-varmin(ii,jj,kk) )/real(nbins,r_sngl)
  
       IF( dvar > 0 )THEN
         DO im=1,nbv
           tmpindex=floor( ( my_ensemble(ii,jj,kk,im) - varmin(ii,jj,kk) )/dvar ) + 1
           IF( tmpindex > nbins )tmpindex=nbins
           IF( tmpindex < 1     )tmpindex=1
           !WRITE(*,*)histogram(ii,jj,kk,tmpindex),tmpindex
           histogram(ii,jj,kk,tmpindex)=histogram(ii,jj,kk,tmpindex) + 1
         ENDDO
       ENDIF
      else
         histogram(ii,jj,kk,:)=undef
      endif
    ENDDO
   ENDDO
  ENDDO
!$OMP END PARALLEL DO


  !INQUIRE(IOLENGTH=reclength) reclength
  !reclength = nx * ny !* reclength
  !iunit=55
  !OPEN(iunit,FILE=histogram_out,FORM='unformatted',ACCESS='direct',RECL=reclength,CONVERT=outputendian)
  !OPEN(iunit,FILE=histogram_out,FORM='unformatted',ACCESS='sequential',CONVERT=outputendian)

  !irec=1
  !DO ii=1,nz
  ! DO jj=1,nbins 
  !  !WRITE(iunit,rec=irec)histogram(:,:,ii,jj) !,r_sngl)
  !  WRITE(iunit)histogram(:,:,ii,jj)
  ! ! irec=irec+1
  ! ENDDO
  !ENDDO

  !CLOSE(iunit)

  !CALL write_grd(minval_out,nx,ny,nz,tmpmin,tmpundefmask,undef)
  !CALL write_grd(maxval_out,nx,ny,nz,tmpmax,tmpundefmask,undef)



END SUBROUTINE compute_histogram

!Compute covariance strhength

SUBROUTINE covariance_strenght(covst,corrst,corrstdist,nx,ny,nz,nbv,delta,undef)
use common_data
IMPLICIT NONE
!INTEGER,PARAMETER         :: r_size=kind(0.0d0)
!INTEGER,PARAMETER         :: r_sngl=kind(0.0e0)
INTEGER,      INTENT(IN)  :: nx,ny,nz,nbv,delta
REAL(r_sngl), INTENT(IN)  :: undef
REAL(r_sngl), INTENT(OUT) :: covst(nx,ny,nz),corrst(nx,ny,nz),corrstdist(nx,ny,nz) !Covariance and correlation strhenght index.
REAL(r_sngl)              :: moments(nx,ny,nz,2)
INTEGER                   :: imin , imax , jmin , jmax , ii , jj , kk , iii , jjj , contador
REAL(r_sngl)              :: pensemble(nbv) , tmpcov , tmpcorr , tmpdist

covst=0.0e0
corrst=0.0e0
corrstdist=0.0e0

CALL compute_moments(nx,ny,nz,nbv,2,moments,undef)

moments(:,:,:,2)=sqrt(moments(:,:,:,2)) !Get standard deviation.

!$OMP PARALLEL DO
!PRIVATE(imin,imax,jmin,jmax,ii,jj,kk,iii,jjj,pensemble,tmpcov,tmpcorr,contador,tmpdist)
DO ii=1,nx
 !WRITE(*,*)ii
 DO jj=1,ny
  DO kk=1,nz
   IF( my_undefmask(ii,jj,kk) )THEN
 
    imin=ii-delta
    imax=ii+delta
    if( imin < 1 )imin=1
    if( imax > nx)imax=nx
    jmin=jj-delta
    jmax=jj+delta
    if( jmin < 1 )jmin=1
    if( jmax > ny)jmax=ny

    pensemble=my_ensemble(ii,jj,kk,:)

    contador=0

    DO iii=imin,imax
     DO jjj=jmin,jmax
      tmpdist= sqrt(real(iii-ii,r_sngl)**2 + real(jjj-jj,r_sngl)**2)/real(delta,r_sngl)
      IF( my_undefmask(iii,jjj,kk) .and. tmpdist < 1.0e0 )THEN
        CALL com_covar_sngl(nbv,my_ensemble(iii,jjj,kk,:),pensemble,tmpcov)
        tmpcorr=tmpcov/( moments(ii,jj,kk,2) * moments(iii,jjj,kk,2) )
        covst(ii,jj,kk)=covst(ii,jj,kk)+ABS(tmpcov)
        corrst(ii,jj,kk)=corrst(ii,jj,kk)+ABS(tmpcorr)
        corrstdist(ii,jj,kk)=corrstdist(ii,jj,kk)+ABS(tmpcorr)*tmpdist
  
        contador=contador+1
      ENDIF
       
     ENDDO
    ENDDO
   
    IF( contador >= 1 )THEN
      covst(ii,jj,kk)=covst(ii,jj,kk)/REAL(contador,r_sngl)
      corrst(ii,jj,kk)=corrst(ii,jj,kk)/REAL(contador,r_sngl)
      corrstdist(ii,jj,kk)=corrstdist(ii,jj,kk)/corrst(ii,jj,kk)
    ELSE
      covst(ii,jj,kk)=undef
      corrst(ii,jj,kk)=undef
      corrstdist(ii,jj,kk)=undef
    ENDIF

   ENDIF

  ENDDO
 ENDDO
ENDDO
!$OMP END PARALLEL DO

END SUBROUTINE covariance_strenght


!Perform a 2D smoothing of the ensemble using a Lanczos filter.
SUBROUTINE smooth_2d(mydata,nx,ny,nz,dx,xfs)
use common_data
IMPLICIT NONE
!INTEGER,PARAMETER               :: r_size=kind(0.0d0)
!INTEGER,PARAMETER               :: r_sngl=kind(0.0e0)
INTEGER      , INTENT(IN)       :: nx,ny,nz               !Grid dimensions
REAL(r_sngl) , INTENT(INOUT)    :: mydata(nx,ny,nz)       !Model data
REAL(r_size) , INTENT(IN)       :: dx      !Grid resolution.
REAL(r_size) , INTENT(IN)       :: xfs     !Filter scale in x and y.
!LOGICAL      , INTENT(IN)       :: undefmask(nx,ny,nz)
INTEGER                         :: kk
INTEGER                         :: integermask(nx,ny,nz)
INTEGER                         :: filter_size_x
REAL(r_size)                    :: tmpdata(nx,ny,nz)

integermask=0
WHERE( my_undefmask )
  integermask=1
END WHERE

filter_size_x = NINT( xfs / dx )     

tmpdata=REAL(mydata,r_size)

!$OMP PARALLEL DO PRIVATE(kk)
DO kk=1,nz  
    CALL lanczos_2d(tmpdata(:,:,kk),tmpdata(:,:,kk),integermask(:,:,kk),filter_size_x,nx,ny)
ENDDO
!$OMP END PARALLEL DO

mydata=REAL(tmpdata,r_sngl)

END SUBROUTINE smooth_2d

SUBROUTINE lanczos_2d(inputvar2d,outputvar2d,mask,lambda,nx,ny)
!This is a single-routine lanczos filter. This routine has been prepared in
!order to be used
!with openmp (common_smooth_2d module shares variables among different routines
!and can not be
!safely used with openmp)
  use common_data
  IMPLICIT NONE
!  INTEGER,PARAMETER         :: r_size=kind(0.0d0)
!  INTEGER,PARAMETER         :: r_sngl=kind(0.0e0)
  INTEGER,INTENT(IN)        :: nx,ny 
  REAL(r_size) , INTENT(IN) :: inputvar2d(nx,ny) 
  REAL(r_size) , INTENT(OUT):: outputvar2d(nx,ny)
  INTEGER      , INTENT(IN) :: mask(nx,ny)
  INTEGER      , INTENT(IN) :: lambda
  REAL(r_size)                         :: fn, rspval        ! cutoff freq/wavelength, spval
  REAL(r_size), DIMENSION(0:2*lambda)  :: dec, de           ! weight in r8, starting index 0:nband
  INTEGER                              :: ji, jj, jmx, jkx, jk, jt, jvar ! dummy loop index
  INTEGER                              :: ik1x, ik2x, ikkx
  INTEGER                              :: ifrst=0
  INTEGER                              :: inxmin, inxmaxi
  INTEGER                              :: inymin, inymaxi
  REAL(r_size), DIMENSION(nx,ny)       :: dl_tmpx, dl_tmpy
  REAL(r_size)                         :: dl_yy, dl_den, dl_pi, dl_ey, dl_coef

  !   PRINT *,'        ncut     : number of grid step to be filtered'
  !  remark: for a spatial filter, fn=dx/lambda where dx is spatial step, lamda
  !  is cutting wavelength

  fn    = 1./lambda

  !Filter init -------------------------------------  
 
    dl_pi   = ACOS(-1.d0)
    dl_coef = 2.0d0*dl_pi*fn

    de(0) = 2.d0*fn
    DO  ji=1,2*lambda
       de(ji) = SIN(dl_coef*ji)/(dl_pi*ji)
    END DO
    !
    dec(0) = 2.d0*fn
    DO ji=1,2*lambda
       dl_ey   = dl_pi*ji/(2*lambda)
       dec(ji) = de(ji)*SIN(dl_ey)/dl_ey
    END DO

  !End of filter init --------------------------------
  
  !FILTER-----------------------------------------------

   IF ( lambda /= 0 )THEN

    inxmin   =  2*lambda
    inxmaxi  =  nx-2*lambda+1
    inymin   =  2*lambda
    inymaxi  =  ny-2*lambda+1


    DO jj=1,ny
       DO  jmx=1,nx
          ik1x = -2*lambda
          ik2x =  2*lambda
          !
          IF (jmx <= inxmin ) ik1x = 1-jmx
          IF (jmx >= inxmaxi) ik2x = nx-jmx
          !
          dl_yy  = 0.d0
          dl_den = 0.d0
          !
          DO jkx=ik1x,ik2x
             ikkx=ABS(jkx)
             IF (mask(jkx+jmx,jj)  ==  1) THEN
                dl_den = dl_den + dec(ikkx)
                dl_yy  = dl_yy  + dec(ikkx)*inputvar2d(jkx+jmx,jj)
             END IF
          END DO
          !
          dl_tmpx(jmx,jj)=dl_yy/dl_den
       END DO
    END DO

    DO ji=1,nx
       DO  jmx=1,ny
          ik1x = -2*lambda
          ik2x =  2*lambda
          !
          IF (jmx <= inymin ) ik1x = 1-jmx
          IF (jmx >= inymaxi) ik2x = ny-jmx
          !
          dl_yy  = 0.d0
          dl_den = 0.d0
          !
          DO jkx=ik1x,ik2x
             ikkx=ABS(jkx)
             IF (mask(ji,jkx+jmx)  ==  1) THEN
                dl_den = dl_den + dec(ikkx)
                dl_yy  = dl_yy  + dec(ikkx)*dl_tmpx(ji,jkx+jmx)
             END IF
          END DO
          outputvar2d(ji,jmx)=0.
          IF (dl_den /=  0.) outputvar2d(ji,jmx) = dl_yy/dl_den
       END DO
    END DO
    !


   ENDIF 

  !END OF FILTER-----------------------------------------


   IF ( lambda == 0 ) outputvar2d=inputvar2d

   WHERE( mask == 0 )outputvar2d = inputvar2d


  END SUBROUTINE lanczos_2d

 
END MODULE common_functions 
