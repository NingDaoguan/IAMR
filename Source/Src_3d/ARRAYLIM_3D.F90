
! ::: -----------------------------------------------------------
! ::: This routine sets the values for the lo() and hi() arrays
! ::: from the ARG_L1, ARG_H1, ... macros.  This is done since
! ::: it is more convenient to use the lo() and hi() arrays.
! :::
! ::: INPUTS/OUTPUTS:
! :::
! ::: holder_l1,holder_l2,holder_l3,holder_h1,holder_h2,holder_h3=> index extent of place holder array
! ::: lo(3)    <= lower index limits
! ::: hi(3)    <= upper index limits
! ::: -----------------------------------------------------------

      subroutine SET_LOHI(holder_l1,holder_l2,holder_l3,holder_h1,holder_h2,holder_h3, lo, hi)

      implicit none

!     :::: Passed Variables ::::

      integer holder_l1,holder_l2,holder_l3,holder_h1,holder_h2,holder_h3
      integer lo(3), hi(3)

!     --------------------------------------
!     :::: Set Values for lo() and hi() ::::
!     --------------------------------------

      lo(1) = holder_l1
      hi(1) = holder_h1
      lo(2) = holder_l2
      hi(2) = holder_h2
      lo(3) = holder_l3
      hi(3) = holder_h3

    end subroutine SET_LOHI


! ::: -----------------------------------------------------------
! ::: This routine sets the values for the ARG_L1, ARG_H1, ... macros
! ::: from the lo() and hi() arrays.  This is done since
! ::: it is more convenient to use the macros to dimension arrays.
! :::
! ::: INPUTS/OUTPUTS:
! :::
! ::: FF_holder_l1,holder_l2,holder_l3,holder_h1,holder_h2,holder_h3 <=  index extent of place holder array
! ::: lo(3)         => lower index limits
! ::: hi(3)         => upper index limits
! ::: -----------------------------------------------------------

    subroutine SET_ARGS(holder_l1,holder_l2,holder_l3,holder_h1,holder_h2,holder_h3, lo, hi)

      implicit none

!     :::: Passed Variables ::::

      integer holder_l1,holder_l2,holder_l3,holder_h1,holder_h2,holder_h3
      integer lo(3), hi(3)

!     --------------------------------------
!     :::: Set Values for lo() and hi() ::::
!     --------------------------------------

      holder_l1 = lo(1)
      holder_h1 = hi(1)
      holder_l2 = lo(2)
      holder_h2 = hi(2)
      holder_l3 = lo(3)
      holder_h3 = hi(3)

    end subroutine SET_ARGS

