PROGRAM mpiio

implicit none
include "mpif.h"

integer, parameter :: nsize = 1000000
real, allocatable, dimension(:) :: data, fulldata
integer i, rank, size, ierror, tag, status(MPI_STATUS_SIZE)
real*8 times(10)

integer fh
integer(KIND=MPI_OFFSET_KIND)offset

!switch on MPI   
call MPI_INIT(ierror)

!get MPI rank and number of processes
call MPI_COMM_SIZE(MPI_COMM_WORLD, size, ierror)
call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierror)

!allocate main array
allocate(data(nsize))

!initialize array
do i=1,nsize
   data(i) = real(rank)
enddo

!write data (one file)

! 1 WRITE AT
times=0.0
call MPI_barrier(MPI_COMM_WORLD,ierror)
times(1) = MPI_Wtime()
offset = rank*4*nsize
call MPI_file_open(MPI_COMM_WORLD, 'writeat.bin', MPI_MODE_WRONLY + MPI_MODE_CREATE,&
                   MPI_INFO_NULL, fh, ierror)
call MPI_file_write_at(fh, offset, data, nsize, MPI_REAL, status, ierror)

call MPI_file_close(fh,ierror)
call MPI_barrier(MPI_COMM_WORLD,ierror)
times(2) = MPI_Wtime()
if(rank == 0)write(*,*)"Time for I/O - WRITE AT(sec) = ", times(2) - times(1)

! 2. SIMPLE VIEW

call MPI_barrier(MPI_COMM_WORLD,ierror)
times(1) = MPI_Wtime()
offset = rank*4*nsize
call MPI_file_open(MPI_COMM_WORLD, 'view.bin', MPI_MODE_WRONLY + MPI_MODE_CREATE,&
                   MPI_INFO_NULL, fh, ierror)
call MPI_file_set_view(fh, offset, MPI_REAL, MPI_REAL, 'native', MPI_INFO_NULL, ierror)

call MPI_file_write(fh, data, nsize, MPI_REAL, status, ierror)

call MPI_file_close(fh,ierror)
call MPI_barrier(MPI_COMM_WORLD,ierror)
times(2) = MPI_Wtime()
if(rank == 0)write(*,*)"Time for I/O - VIEW (sec) = ", times(2) - times(1)

! 3. COLLECTIVE

call MPI_barrier(MPI_COMM_WORLD,ierror)
times(1) = MPI_Wtime()
offset = rank*4*nsize
call MPI_file_open(MPI_COMM_WORLD, 'collective.bin', MPI_MODE_WRONLY + MPI_MODE_CREATE,&
                   MPI_INFO_NULL, fh, ierror)
call MPI_file_set_view(fh, offset, MPI_REAL, MPI_REAL, 'native', MPI_INFO_NULL, ierror)

call MPI_file_write_all(fh, data, nsize, MPI_REAL, status, ierror)

call MPI_file_close(fh,ierror)
call MPI_barrier(MPI_COMM_WORLD,ierror)
times(2) = MPI_Wtime()
if(rank == 0)write(*,*)"Time for I/O - COLLECTIVE (sec) = ", times(2) - times(1)


!switch off MPI
call MPI_FINALIZE(ierror)


END PROGRAM mpiio
