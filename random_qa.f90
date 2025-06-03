! This program is used to assess the randomness of a binary file from the input line
! This program is using multi-threading processing to achieve the result in a timely manner.
! 
! 1- Reads a binary file from the command line.
! 2- Spawns threads to analyze portions of the file.
! 3- Computes byte frequency distribution.
! 4- Calculates Shannon entropy as a randomness measure.
!
! gfortran13 -fopenmp random_qa.f90 -o random_qa
! ./random_qa <Your_data_file>


program randomness_quality
    use iso_c_binding
    use omp_lib
    implicit none

    character(len=256) :: filename
    integer :: unit, ios, stat, i
    integer(1), allocatable :: buffer(:)
    integer(1) :: byte
    integer :: freq(0:255)
    integer(8) :: total_bytes, current_pos, alloc_step

    real(8) :: entropy, prob

    ! Get filename from command-line
    call get_command_argument(1, filename)
    if (len_trim(filename) == 0) then
        print *, 'Usage: ./random_qa <binary_file>'
        stop 1
    end if

    ! Open binary file in stream mode
    open(newunit=unit, file=trim(filename), access='stream', &
         form='unformatted', status='old', action='read', iostat=ios)
    if (ios /= 0) then
        print *, 'Failed to open file: ', trim(filename)
        stop 1
    end if

    ! Allocate initial buffer
    alloc_step = 1000000_8
    allocate(buffer(alloc_step), stat=stat)
    if (stat /= 0) then
        print *, 'Memory allocation failed'
        stop 1
    end if

    ! Read file byte-by-byte safely
    total_bytes = 0
    current_pos = 1_8

    do
        read(unit, pos=current_pos, iostat=ios) byte
        if (ios /= 0) exit

        total_bytes = total_bytes + 1
        if (total_bytes > size(buffer)) then
            call grow_buffer(buffer, alloc_step)
        end if
        buffer(total_bytes) = byte
        current_pos = current_pos + 1
    end do

    close(unit)
    freq = 0

    ! Parallel frequency count (safe mapping to 0–255)
    !$omp parallel do default(shared) private(i) reduction(+:freq)
    do i = 1, total_bytes
        freq(iachar(char(buffer(i)))) = freq(iachar(char(buffer(i)))) + 1
    end do
    !$omp end parallel do

    ! Compute entropy
    entropy = 0.0d0
    do i = 0, 255
        if (freq(i) > 0) then
            prob = real(freq(i)) / real(total_bytes)
            entropy = entropy - prob * log2(prob)
        end if
    end do

    ! Output results
    print *, 'File: ', trim(filename)
    print *, 'Size: ', total_bytes, ' bytes'
    print *, 'Entropy (max=8): ', entropy

contains

    subroutine grow_buffer(buf, step)
        integer(1), allocatable, intent(inout) :: buf(:)
        integer(8), intent(in) :: step
        integer(1), allocatable :: newbuf(:)
        integer(8) :: old_size
        integer :: stat

        old_size = size(buf)
        allocate(newbuf(old_size + step), stat=stat)
        if (stat /= 0) then
            print *, 'Memory reallocation failed'
            stop 1
        end if
        newbuf(1:old_size) = buf
        call move_alloc(newbuf, buf)
    end subroutine grow_buffer

    function log2(x) result(res)
        real(8), intent(in) :: x
        real(8) :: res
        res = log(x) / log(2.0d0)
    end function log2

end program randomness_quality
