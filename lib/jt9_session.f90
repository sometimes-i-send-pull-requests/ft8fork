module jt9_session_mod
  ! Performs one decode of the interval described by a dec_data structure.
  ! This is the work jt9 carries out for each decode request, separated from
  ! the shared memory and sub-process plumbing so that it can be called
  ! directly from within a process that has loaded the decoder.
  use, intrinsic :: iso_c_binding, only: c_ptr, c_int, c_f_pointer
  use jt9com

  implicit none

  private
  public :: jt9_decode_once, jt9_session_configure, jt9_session_init

contains

  subroutine jt9_decode_once(data, nfsample)
    use decoder_mod, only: multimode_decoder
    use decode_msk144_mod, only: decode_msk144
    use ft8_mod1, only: dd8
    use jt65_mod6, only: dd
    use prog_args, only: data_dir

    type(dec_data), intent(inout) :: data
    integer, intent(in) :: nfsample

    integer*2 id2a(180000)
    type(params_block) :: local_params
    integer :: nearly, npts1

    ! Work on a copy of the parameters so that the caller's copy is not
    ! disturbed by the adjustments made for the decode passes.
    local_params = data%params

    if (local_params%nmode .eq. 8 .and. local_params%ndiskdat .and. &
         .not. local_params%nagain .and. .not. local_params%lmultift8) then
       ! Early decoding passes, FT8 only, when the data comes from disk.
       nearly=41
       local_params%nzhsym=nearly
       id2a(1:nearly*3456)=data%id2(1:nearly*3456)
       id2a(nearly*3456+1:)=0
       call multimode_decoder(data%ss,id2a,local_params,nfsample)
       nearly=47
       local_params%nzhsym=nearly
       id2a(1:nearly*3456)=data%id2(1:nearly*3456)
       id2a(nearly*3456+1:)=0
       call multimode_decoder(data%ss,id2a,local_params,nfsample)
       local_params%nzhsym=50
    end if

    if (local_params%nmode .eq. 8 .and. local_params%lmultift8 .and. &
         .not. local_params%nagain .and. local_params%ndiskdat) then
       npts1=180000
       if (local_params%ndecoderstart .lt. 2) then
          nearly=41
          local_params%lmultift8=.false.
          local_params%nzhsym=nearly
          id2a(1:nearly*3456)=data%id2(1:nearly*3456)
          id2a(nearly*3456+1:)=0
          call multimode_decoder(data%ss,id2a,local_params,nfsample)
          nearly=46
          local_params%lmultift8=.false.
          local_params%nzhsym=nearly
          id2a(1:nearly*3456)=data%id2(1:nearly*3456)
          id2a(nearly*3456+1:)=0
          call multimode_decoder(data%ss,id2a,local_params,nfsample)
          if (local_params%ndecoderstart .eq. 0) nearly=49
          if (local_params%ndecoderstart .eq. 1) nearly=50
          local_params%lmultift8=.true.
          data%params%nzhsym=nearly
          id2a(1:nearly*3456)=data%id2(1:nearly*3456)
          id2a(nearly*3456+1:)=0
          dd(1:nearly*3456)=data%id2(1:nearly*3456)
          dd(nearly*3456+1:)=0
          dd8(1:nearly*3456)=data%id2(1:nearly*3456)
          dd8(nearly*3456+1:)=0
          if (local_params%ndecoderstart .eq. 0) data%params%nzhsym=49
          if (local_params%ndecoderstart .eq. 1) data%params%nzhsym=50
       else
          nearly=50
          if (local_params%ndecoderstart .eq. 2) nearly=48
          if (local_params%ndecoderstart .eq. 3) nearly=49
          if (local_params%ndecoderstart .eq. 4) nearly=50
          data%params%nzhsym=nearly
          id2a(1:nearly*3456)=data%id2(1:nearly*3456)
          id2a(nearly*3456+1:)=0
          dd(1:nearly*3456)=data%id2(1:nearly*3456)
          dd(nearly*3456+1:)=0
          dd8(1:nearly*3456)=data%id2(1:nearly*3456)
          dd8(nearly*3456+1:)=0
          if (local_params%ndecoderstart .eq. 2) data%params%nzhsym=48
          if (local_params%ndecoderstart .eq. 3) data%params%nzhsym=49
          if (local_params%ndecoderstart .eq. 4) data%params%nzhsym=50
       end if
    elseif (local_params%nmode .eq. 8 .and. local_params%lmultift8 .and. &
         .not. local_params%ndiskdat) then
       npts1=180000
       dd(1:npts1)=data%id2(1:npts1)
       dd8(1:npts1)=dd(1:npts1)
    end if

    if (local_params%nmode .eq. 144) then
       ! MSK144
       call decode_msk144(data%id2, data%params, data_dir)
    else
       ! Normal decoding pass
       call multimode_decoder(data%ss, data%id2, local_params, nfsample)
    end if
  end subroutine jt9_decode_once

  ! Set the data directories used by the decoder.  Each argument is a
  ! NUL-terminated C string.
  subroutine jt9_session_configure(c_exe_dir, c_data_dir, c_temp_dir, &
       c_share_dir) bind(C, name="jt9_session_configure")
    use iso_c_utilities, only: c_to_f_string
    use prog_args

    type(c_ptr), value, intent(in) :: c_exe_dir, c_data_dir, c_temp_dir, &
         c_share_dir

    exe_dir=c_to_f_string(c_exe_dir)
    data_dir=c_to_f_string(c_data_dir)
    temp_dir=c_to_f_string(c_temp_dir)
    share_dir=c_to_f_string(c_share_dir)
  end subroutine jt9_session_configure

  ! Initialise the FFTW threading machinery used by the decoder.
  subroutine jt9_session_init() bind(C, name="jt9_session_init")
    use FFTW3

    integer(c_int) :: iret

    iret=fftwf_init_threads()
    call fftwf_plan_with_nthreads(1)
  end subroutine jt9_session_init

  ! C entry point that takes a pointer to a dec_data structure.
  subroutine jt9_decode_once_c(data_ptr, nfsample) bind(C, name="jt9_decode_once")
    type(c_ptr), value, intent(in) :: data_ptr
    integer(c_int), value, intent(in) :: nfsample

    type(dec_data), pointer :: data

    call c_f_pointer(data_ptr, data)
    call jt9_decode_once(data, int(nfsample))
  end subroutine jt9_decode_once_c

end module jt9_session_mod
