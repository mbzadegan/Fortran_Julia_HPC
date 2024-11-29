program call_julia_matrix_multiply
    use, intrinsic :: iso_c_binding
    implicit none

    ! Declare Julia API functions
    interface
        subroutine jl_init__c() bind(c, name="jl_init__threading")
        end subroutine jl_init__c

        subroutine jl_atexit_hook(status) bind(c, name="jl_atexit_hook")
            integer(c_int), value :: status
        end subroutine jl_atexit_hook

        type(c_ptr) function jl_eval_string(code) bind(c, name="jl_eval_string")
            character(c_char), dimension(*), intent(in) :: code
        end function jl_eval_string
    end interface

    ! Local variables
    integer :: n
    integer :: i, j
    real(c_double), allocatable :: A(:,:), B(:,:), C(:,:)
    character(len=1024) :: julia_code
    type(c_ptr) :: julia_result

    ! Prompt user for matrix size
    print *, "Enter the size of the matrices (n x n):"
    read(*,*) n

    ! Allocate matrices
    allocate(A(n, n), B(n, n), C(n, n))

    ! Initialize matrices with sample values
    do i = 1, n
        do j = 1, n
            A(i, j) = real(i + j, c_double)
            B(i, j) = real(i * j, c_double)
        end do
    end do

    ! Initialize Julia runtime
    call jl_init__c()

    ! Generate Julia code to define and multiply matrices
    julia_code = "A = reshape([" // &
                  trim(adjustl(generate_matrix_values(A, n))) // &
                  "], (" // trim(adjustl(int_to_str(n))) // ", " // &
                  trim(adjustl(int_to_str(n))) // ")); " // &
                  "B = reshape([" // &
                  trim(adjustl(generate_matrix_values(B, n))) // &
                  "], (" // trim(adjustl(int_to_str(n))) // ", " // &
                  trim(adjustl(int_to_str(n))) // ")); " // &
                  "using Threads; Threads.@threads begin C = A * B end; C"

    ! Call Julia code
    julia_result = jl_eval_string(trim(julia_code) // c_null_char)

    ! Process the result (optional: retrieve back to Fortran)
    print *, "Matrix multiplication completed in Julia for size:", n

    ! Finalize Julia runtime
    call jl_atexit_hook(0)

    ! Deallocate matrices
    deallocate(A, B, C)
end program call_julia_matrix_multiply

! Helper function: Generate matrix values as a comma-separated string for Julia
pure function generate_matrix_values(mat, n) result(values)
    real(c_double), intent(in) :: mat(:,:)
    integer, intent(in) :: n
    character(len=1024) :: values
    integer :: i, j
    character(len=20) :: temp

    values = ""
    do i = 1, n
        do j = 1, n
            write(temp, '(f10.5)') mat(i, j)
            values = trim(values) // trim(adjustl(temp)) // ","
        end do
    end do
    values = values(1:len(values)-1)  ! Remove the trailing comma
end function generate_matrix_values

! Helper function: Convert integer to string
pure function int_to_str(i) result(str)
    integer, intent(in) :: i
    character(len=20) :: str
    write(str, '(i0)') i
end function int_to_str

