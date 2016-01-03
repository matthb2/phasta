project(test_petsc_has_mat_subset_off_proc_entries)
cmake_minimum_required(VERSION 2.6)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../")

find_package(MPI)
find_package(PETSC)

include_directories(${MPI_C_INCLUDE_PATH} ${MPI_Fortran_INCLUDE_PATH})
link_directories(${PETSC_LIBRARY_DIRS})
include_directories(${PETSC_INCLUDE_DIRS})

add_executable(test_jed test_is_jeds_petsc_branch.c)
target_link_libraries(test_jed ${PETSC_LIBRARIES})
target_link_libraries(test_jed ${MPI_C_LIBRARIES} ${MPI_Fortran_LIBRARIES})