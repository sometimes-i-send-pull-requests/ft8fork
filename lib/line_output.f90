module line_output
  ! Decoded output lines are normally written to standard output.  A caller in
  ! the same process may instead install a handler that receives each line as a
  ! C string; when no handler is installed lines fall back to standard output.
  use, intrinsic :: iso_c_binding, only: c_char, c_null_char, c_funptr,        &
       c_associated, c_f_procpointer

  implicit none

  private
  public :: emit_line, set_line_output, clear_line_output

  abstract interface
     subroutine line_handler(text) bind(C)
       import :: c_char
       character(kind=c_char), intent(in) :: text(*)
     end subroutine line_handler
  end interface

  procedure(line_handler), pointer, save :: handler => null()

contains

  subroutine emit_line(text)
    character(len=*), intent(in) :: text

    character(kind=c_char, len=1024) :: buffer
    integer :: n

    if (associated(handler)) then
       n = min(len_trim(text), len(buffer) - 1)
       buffer = ' '
       if (n > 0) buffer(1:n) = text(1:n)
       buffer(n+1:n+1) = c_null_char
       call handler(buffer)
    else
       write(*,'(a)') trim(text)
    end if
  end subroutine emit_line

  subroutine set_line_output(fn) bind(C, name="set_line_output")
    type(c_funptr), value, intent(in) :: fn

    if (c_associated(fn)) then
       call c_f_procpointer(fn, handler)
    else
       nullify(handler)
    end if
  end subroutine set_line_output

  subroutine clear_line_output() bind(C, name="clear_line_output")
    nullify(handler)
  end subroutine clear_line_output

end module line_output
