MACRO(NLCGLIB_SETUP_TARGET _target)
  target_link_libraries(
    ${_target} PUBLIC
    Kokkos::kokkos
    # ${LAPACK_LIBRARIES}
    MPI::MPI_CXX
    # $<TARGET_NAME_IF_EXISTS:OpenMP::OpenMP_CXX>
    $<TARGET_NAME_IF_EXISTS:nlcglib::cudalibs>
    $<TARGET_NAME_IF_EXISTS:nlcglib::rocmlibs>
    $<TARGET_NAME_IF_EXISTS:nlcglib::magma>
    $<TARGET_NAME_IF_EXISTS:roc::hipblas> # only required for magma
    $<TARGET_NAME_IF_EXISTS:roc::hipsparse> # only required for magma
    nlohmann_json::nlohmann_json
    )

  # get_target_property(LL roc::hipblas INTERFACE_COMPILE_DEFINITIONS)
  # message("roc::hibplas INTERFACE_COMPILE_DEFINITIONS: ${LL}")

  # get_target_property(LL roc::hipblas INTERFACE_LINK_LIBRARIES)
  # message("roc::hibplas INTERFACE_LINK_LIBRARIES: ${LL}")


  target_include_directories(${_target} PUBLIC
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_SOURCE_DIR}/include
    )

  if(LAPACK_VENDOR STREQUAL MKL)
    target_compile_definitions(${_target} PUBLIC __USE_MKL)
    # if(USE_OPENMP)
    target_link_libraries(${_target}  PUBLIC mkl::mkl_intel_32bit_omp_dyn)
    # else()
    #   target_link_libraries(${_target}  PUBLIC mkl::mkl_intel_32bit_seq_dyn)
    # endif()
  elseif(LAPACK_VENDOR STREQUAL MKLONEAPI)
    target_link_libraries(${_target}  PUBLIC MKL::MKL)
  else()
    target_link_libraries(${_target} PRIVATE my_lapack)
  endif()
  target_compile_definitions(${_target} PUBLIC $<$<BOOL:${USE_OPENMP}>:__USE_OPENMP>)
  target_compile_definitions(${_target} PUBLIC $<$<BOOL:${USE_CUDA}>:__NLCGLIB__CUDA>)
  target_compile_definitions(${_target} PUBLIC $<$<BOOL:${USE_ROCM}>:__NLCGLIB__ROCM>)
  target_compile_definitions(${_target} PUBLIC $<$<BOOL:${USE_MAGMA}>:__NLCGLIB__MAGMA>)
  target_include_directories(${_target} PUBLIC $<TARGET_PROPERTY:Kokkos::kokkoscore,INTERFACE_INCLUDE_DIRECTORIES>)

ENDMACRO()
