module jt9a_mod

contains

subroutine jt9a()
  use, intrinsic :: iso_c_binding, only: c_f_pointer, c_null_char, c_bool
  use prog_args
  use timer_module, only: timer
  use timer_impl, only: init_timer !, limtrace
  use shmem

  use jt9com
  use jt9_session_mod, only: jt9_decode_once

  implicit none

! Multiple instances:
  type(dec_data), pointer, volatile :: shared_data !also makes target volatile
  type(dec_data), pointer :: work_data
  logical(c_bool) :: ok
  integer :: nbytes, msdelay

  call init_timer (trim(data_dir)//'/timer.out')
!  open(23,file=trim(data_dir)//'/CALL3.TXT',status='unknown')

!  limtrace=-1                            !Disable all calls to timer()

! Multiple instances: set the shared memory key before attaching
  call shmem_setkey(trim(shm_key)//c_null_char)
  ok=shmem_attach()
  if(.not.ok) call abort
  msdelay=10
  call c_f_pointer(shmem_address(),shared_data)
  call c_f_pointer(shmem_address(),work_data)

main_loop: do
  ! Wait until the GUI sets ipc(2) to 1, unless it sets ipc(2) to 999 to terminate
  do
     ok=shmem_lock()
     if(.not.ok) call abort
     if(shared_data%ipc(2).eq.999.0) then
        ok=shmem_unlock()
        ok=shmem_detach()
        exit main_loop
     endif
     if(shared_data%ipc(2).eq.1) exit
     ok=shmem_unlock()
     if(.not.ok) call abort
     call sleep_msec(msdelay)
  end do
  shared_data%ipc(2)=0
  nbytes=shmem_size()
  if(nbytes.le.0) then
     ok=shmem_unlock()
     ok=shmem_detach()
     print*,'jt9a: Shared memory does not exist.'
     print*,"Must start 'jt9 -s <thekey>' from within WSJT-X."
     exit main_loop
  endif
  ok=shmem_unlock()
  if(.not.ok) call abort
  call flush(6)
  call timer('decoder ',0)
  call jt9_decode_once(work_data, 12000)
  call timer('decoder ',1)

!print*,time, ' jt9a before final loop which waits for ipc(3) ==1' !ft8md
! Wait here until GUI routine decodeDone() has set ipc(3) to 1
  do
     ok=shmem_lock()
     if(.not.ok) call abort
     if(shared_data%ipc(3).eq.1) exit
     ok=shmem_unlock()
     if(.not.ok) call abort
     call sleep_msec(msdelay)
  end do
  shared_data%ipc(3)=0
  ok=shmem_unlock()
  if(.not.ok) call abort
end do main_loop

call timer('decoder ',101)

  return
end subroutine jt9a

end module jt9a_mod
