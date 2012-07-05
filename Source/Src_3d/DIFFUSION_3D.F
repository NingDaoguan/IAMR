
#undef  BL_LANG_CC
#ifndef BL_LANG_FORT
#define BL_LANG_FORT
#endif

#include "REAL.H"
#include "CONSTANTS.H"
#include "BC_TYPES.H"
#include "DIFFUSION_F.H"
#include "ArrayLim.H"

#define SDIM 3

      subroutine FORT_VISCSYNCFLUX (ssync,DIMS(ssync),lo,hi,
     $                              xflux,DIMS(xf),yflux,DIMS(yf),
     $                              zflux,DIMS(zf),
     $                              xarea,DIMS(ax),yarea,DIMS(ay),
     $                              zarea,DIMS(az),dx,mult)

      implicit none
      integer lo(3), hi(3)
      integer DIMDEC(ssync)
      integer DIMDEC(xf)
      integer DIMDEC(yf)
      integer DIMDEC(zf)
      integer DIMDEC(ax)
      integer DIMDEC(ay)
      integer DIMDEC(az)
      REAL_T  ssync(DIMV(ssync))
      REAL_T  xflux(DIMV(xf))
      REAL_T  yflux(DIMV(yf))
      REAL_T  zflux(DIMV(zf))
      REAL_T  xarea(DIMV(ax))
      REAL_T  yarea(DIMV(ay))
      REAL_T  zarea(DIMV(az))
      REAL_T  dx(3)
      REAL_T  mult

      integer i, j, k, n
      REAL_T  sx, sy, sz

!$omp parallel private(i,j,k,sx,sy,sz)
c
c     ::::: compute X fluxes
c
!$omp do
      do k = lo(3), hi(3)
         do j = lo(2), hi(2)
            do i = lo(1), hi(1)+1
               sx = ssync(i,j,k) - ssync(i-1,j,k)
               xflux(i,j,k) = mult*sx*xarea(i,j,k)/dx(1)
            end do
         end do
      end do
!$omp end do nowait
c
c     ::::: compute Y fluxes
c
!$omp do
      do k = lo(3), hi(3)
         do j = lo(2), hi(2)+1
            do i = lo(1), hi(1)
               sy = ssync(i,j,k) - ssync(i,j-1,k)
               yflux(i,j,k) = mult*sy*yarea(i,j,k)/dx(2)
            end do
         end do
      end do
!$omp end do nowait
c
c     ::::: compute Z fluxes
c
!$omp do
      do k = lo(3), hi(3)+1
         do j = lo(2), hi(2)
            do i = lo(1), hi(1)
               sz = ssync(i,j,k) - ssync(i,j,k-1)
               zflux(i,j,k) = half*mult*sz*zarea(i,j,k)/dx(3)
            end do
         end do
      end do
!$omp end do nowait

!$omp end parallel
      
      end

c :: ----------------------------------------------------------
c :: SETALPHA
c ::             alpha(i,j,k) = vol*(1+b/(r(i)^2)) / density
c ::
c :: INPUTS / OUTPUTS:
c ::  fab       <=  array to be modified
c ::  DIMS(fab) => index limits of fab
c ::  lo,hi     => index limits of box
c ::  r         =>  1-d array of radius
c ::  DIMS(r)   => index limits of r
c ::  b         =>  viscous coefficient
c ::  vol       =>  volume array
c ::  DIMS(vol) => index limits of fab
c ::  denfab    => array of density at time n+1/2
c ::  DIMS(den) => index limits of fab
c ::  usehoop   => do we add hoop stress?   NOT IN 3-D
c ::  useden    => do we divide by density? (only if velocity component)
c :: ----------------------------------------------------------
c ::
       subroutine FORT_SETALPHA (fab, DIMS(fab), lo, hi, r, DIMS(r), b, 
     $                           vol, DIMS(vol), denfab, DIMS(den),
     &                           usehoop,useden)

       implicit none
       integer DIMDEC(fab)
       integer DIMDEC(r)
       integer DIMDEC(vol)
       integer DIMDEC(den)
       integer lo(SDIM), hi(SDIM)
       integer usehoop,useden
       REAL_T  fab(DIMV(fab))
       REAL_T  vol(DIMV(vol))
       REAL_T  denfab(DIMV(den))
       REAL_T  r(DIM1(r))
       REAL_T  b

       integer i, j, k

       if (useden .eq. 0) then
          do k = lo(3), hi(3)
             do j = lo(2), hi(2)
                do i = lo(1), hi(1)
                   fab(i,j,k) = vol(i,j,k)
                end do
             end do
          end do
       else 
!$omp parallel do private(i,j,k)
          do k = lo(3), hi(3)
             do j = lo(2), hi(2)
                do i = lo(1), hi(1)
                   fab(i,j,k) = vol(i,j,k) * denfab(i,j,k)
                end do
             end do
          end do
!$omp end parallel do
       end if

       end

c :: ----------------------------------------------------------
c :: SET_TENSOR_ALPHA
c ::             alpha(i,j) = vol*density
c ::
c :: INPUTS / OUTPUTS:
c ::  fab       <=  array to be modified
c ::  DIMS(fab) => index limits of fab
c ::  lo,hi     => index limits of box
c ::  r         =>  1-d array of radius
c ::  b         =>  theta*dt or -(1-theta)*dt
c ::  vol       =>  volume array
c ::  DIMS(vol) => index limits of fab
c ::  denfab    => array of density at time n+1/2
c ::  DIMS(den) => index limits of fab
c ::  usehoop   => do we add hoop stress?   (only if x-vel component)
c ::  useden    => do we divide by density? (only if velocity component)
c :: ----------------------------------------------------------
c ::
       subroutine FORT_SET_TENSOR_ALPHA (alpha, DIMS(alpha), lo, hi, r, DIMS(r),
     $                           b, vol, DIMS(vol),
     &                           denfab,DIMS(den),betax,DIMS(betax),
     &                           betay,DIMS(betay),betaz,DIMS(betaz),isrz)

       implicit none
       integer DIMDEC(alpha)
       integer lo(SDIM), hi(SDIM)
       integer DIMDEC(vol)
       integer DIMDEC(den)
       integer DIMDEC(betax)
       integer DIMDEC(betay)
       integer DIMDEC(betaz)
       integer DIMDEC(r)
       REAL_T  alpha(DIMV(alpha),1)
       REAL_T  vol(DIMV(vol))
       REAL_T  denfab(DIMV(den))
       REAL_T  betax(DIMV(betax))
       REAL_T  betay(DIMV(betay))
       REAL_T  betaz(DIMV(betaz))
       REAL_T  r(DIM1(r))
       REAL_T  b, betacen
       integer isrz

       integer i, j, k

!$omp parallel do private(i,j,k)
       do k = lo(3), hi(3)
          do j = lo(2), hi(2)
             do i = lo(1), hi(1)
                alpha(i,j,k,1) = vol(i,j,k) * denfab(i,j,k)
             end do
          end do
       end do
!$omp end parallel do

       end

      subroutine FORT_DIV_MU_SI(lo, hi, dx, mu, DIMS(divu), divu,
     &     DIMS(divmusi), divmusi)

      implicit none
c
c ... inputs
c
      integer lo(SDIM), hi(SDIM)
      REAL_T  dx(SDIM)
      integer DIMDEC(divu)
      REAL_T  divu(DIMV(divu))      
      REAL_T  mu
c
c ... outputs
c
      integer DIMDEC(divmusi)
      REAL_T  divmusi(DIMV(divmusi),SDIM)
c
c ... local 
c
      integer i,j,k
      REAL_T sleft, sright, stp, sbot, sfront, sback
c
c ... Note: the following IS correct for r-z. Terms from the hoop stress
c           cancel with terms from tau_rr to eliminate all r dependence.
c
!$omp parallel do private(i,j,k,sleft,sright,stp,sbot,sfront,sback)
      do k=lo(3),hi(3)
         do j=lo(2),hi(2)
            do i=lo(1),hi(1)
               sleft = half*(divu(i-1,j,k)+divu(i,j,k))
               sright = half*(divu(i+1,j,k)+divu(i,j,k))

               divmusi(i,j,k,1) = mu*(sright-sleft)/dx(1)

               stp  = half*(divu(i,j,k)+divu(i,j+1,k))
               sbot = half*(divu(i,j-1,k)+divu(i,j,k))

               divmusi(i,j,k,2) = mu*(stp-sbot)/dx(2)

               sfront = half*(divu(i,j,k)+divu(i,j,k+1))
               sback  = half*(divu(i,j,k-1)+divu(i,j,k))

               divmusi(i,j,k,3) = mu*(sfront-sback)/dx(2)
            end do
         end do
      end do
!$omp end parallel do

      end

      subroutine FORT_DIV_VARMU_SI(lo, hi, dx, DIMS(divu), divu,
     &     DIMS(betax), betax, DIMS(betay), betay,  DIMS(betaz), 
     &     betaz, DIMS(divmusi), divmusi)

      implicit none
c
c ... inputs
c
      integer lo(SDIM), hi(SDIM)
      REAL_T  dx(SDIM)
      integer DIMDEC(divu)
      REAL_T  divu(DIMV(divu))      
      integer DIMDEC(betax)
      REAL_T  betax(DIMV(betax))
      integer DIMDEC(betay)
      REAL_T  betay(DIMV(betay))
      integer DIMDEC(betaz)
      REAL_T  betaz(DIMV(betaz))
c
c ... outputs
c
      integer DIMDEC(divmusi)
      REAL_T  divmusi(DIMV(divmusi),SDIM)
c
c ... local 
c
      integer i,j,k
      REAL_T sleft, sright, stp, sbot, sfront, sback

!$omp parallel do private(i,j,k,sleft,sright,stp,sbot,sfront,sback)
      do k=lo(3),hi(3)
         do j=lo(2),hi(2)
            do i=lo(1),hi(1)
               sleft = half*(divu(i-1,j,k)+divu(i,j,k))
               sright = half*(divu(i+1,j,k)+divu(i,j,k))

               divmusi(i,j,k,1) = (betax(i+1,j,k)*sright-
     &              betax(i,j,k)*sleft)/dx(1)

               stp = half*(divu(i,j,k)+divu(i,j+1,k))
               sbot = half*(divu(i,j-1,k)+divu(i,j,k))

               divmusi(i,j,k,2) = (betay(i,j+1,k)*stp-
     &              betay(i,j,k)*sbot)/dx(2)

               sfront = half*(divu(i,j,k)+divu(i,j,k+1))
               sback  = half*(divu(i,j,k-1)+divu(i,j,k))

               divmusi(i,j,k,3) = (betaz(i,j,k+1)*sfront-
     &              betaz(i,j,k)*sback)/dx(3)

            end do
         end do
      end do
!$omp end parallel do

      end

