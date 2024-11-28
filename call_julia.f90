program call_julia
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

        type(c_ptr) function jl_unbox_float64(ptr) bind(c, name="jl_unbox_float64")
            type(c_ptr), value :: ptr
        end function jl_unbox_float64
    end interface

    ! Local variables
    character(len=512) :: julia_code
    type(c_ptr) :: result_ptr
    real(c_double) :: result

    ! Initialize Julia runtime
    call jl_init__c()

    ! Define Julia code to call
    julia_code = "include(\"parallel_function.jl\"); multi_threaded_sum([1.0, 2.0, 3.0, 4.0])" // c_null_char

    ! Evaluate the Julia code
    result_ptr = jl_eval_string(julia_code)

    ! Retrieve the result as a Float64
    result = jl_unbox_float64(result_ptr)

    ! Print the result
    print *, "Result from Julia:", result

    ! Finalize Julia runtime
    call jl_atexit_hook(0)
end program call_julia

