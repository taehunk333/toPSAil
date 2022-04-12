# ---------------------------------------------------------------
# $Revision: 4516 $
# $Date: 2015-07-29 10:12:20 -0700 (Wed, 29 Jul 2015) $
# ---------------------------------------------------------------
# Programmer:  Steven Smith @ LLNL
# ---------------------------------------------------------------
# Copyright (c) 2013, The Regents of the University of California.
# Produced at the Lawrence Livermore National Laboratory.
# All rights reserved.
# For details, see the LICENSE file.
# ---------------------------------------------------------------
# Find KLU library.
# 

set(PRE "lib")
IF(WIN32)
  set(POST ".lib" ".dll")
else(WIN32)
  set(POST ".a" ".so")
endif(WIN32)

if (KLU_LIBRARY)
    get_filename_component(KLU_LIBRARY_DIR ${KLU_LIBRARY} PATH)
else (KLU_LIBRARY)
    # SGS TODO Assumption here that all of SparseSuite is in the same dir
    # SGS TODO Not sure why this is convoluted.
    set(KLU_LIBRARY_NAME klu)
    
    # find library path using potential names for static and/or shared libs
    set(temp_KLU_LIBRARY_DIR ${KLU_LIBRARY_DIR})
    unset(KLU_LIBRARY_DIR CACHE)  
    find_path(KLU_LIBRARY_DIR
        NAMES ${PRE}${KLU_LIBRARY_NAME}${POST}
        PATHS ${temp_KLU_LIBRARY_DIR}
        )

    mark_as_advanced(KLU_LIBRARY)

    FIND_LIBRARY( KLU_LIBRARY ${PRE}klu${POST} ${KLU_LIBRARY_DIR} NO_DEFAULT_PATH)
endif (KLU_LIBRARY)


if (AMD_LIBRARY)
    get_filename_component(AMD_LIBRARY_DIR ${AMD_LIBRARY} PATH)
else (AMD_LIBRARY)
    set(AMD_LIBRARY_NAME amd)

    # find library path using potential names for static and/or shared libs
    set(temp_AMD_LIBRARY_DIR ${KLU_LIBRARY_DIR})
    unset(AMD_LIBRARY_DIR CACHE)  
    find_path(AMD_LIBRARY_DIR
        NAMES ${PRE}${AMD_LIBRARY_NAME}${POST}
        PATHS ${temp_AMD_LIBRARY_DIR}
        )
    
    FIND_LIBRARY( AMD_LIBRARY ${PRE}amd${POST} ${AMD_LIBRARY_DIR} NO_DEFAULT_PATH)

    mark_as_advanced(AMD_LIBRARY)
    mark_as_advanced(AMD_LIBRARY_DIR)
endif (AMD_LIBRARY)

if (COLAMD_LIBRARY)
    get_filename_component(COLAMD_LIBRARY_DIR ${COLAMD_LIBRARY} PATH)
else (COLAMD_LIBRARY)
    set(COLAMD_LIBRARY_NAME colamd)
    
    # find library path using potential names for static and/or shared libs
    set(temp_COLAMD_LIBRARY_DIR ${KLU_LIBRARY_DIR})
    unset(COLAMD_LIBRARY_DIR CACHE)  
    find_path(COLAMD_LIBRARY_DIR
        NAMES ${PRE}${COLAMD_LIBRARY_NAME}${POST}
        PATHS ${temp_COLAMD_LIBRARY_DIR}
        )
    
    FIND_LIBRARY( COLAMD_LIBRARY ${PRE}colamd${POST} ${COLAMD_LIBRARY_DIR} NO_DEFAULT_PATH)

    mark_as_advanced(COLAMD_LIBRARY)
    mark_as_advanced(COLAMD_LIBRARY_DIR)
endif (COLAMD_LIBRARY)

if (BTF_LIBRARY)
    get_filename_component(BTF_LIBRARY_DIR ${BTF_LIBRARY} PATH)
else (BTF_LIBRARY)
    set(BTF_LIBRARY_NAME btf)
    
    # find library path using potential names for static and/or shared libs
    set(temp_BTF_LIBRARY_DIR ${KLU_LIBRARY_DIR})
    unset(BTF_LIBRARY_DIR CACHE)  
    find_path(BTF_LIBRARY_DIR
        NAMES ${PRE}${BTF_LIBRARY_NAME}${POST}
        PATHS ${temp_BTF_LIBRARY_DIR}
        )
    
    FIND_LIBRARY( BTF_LIBRARY ${PRE}btf${POST} ${BTF_LIBRARY_DIR} NO_DEFAULT_PATH)

    mark_as_advanced(BTF_LIBRARY)
    mark_as_advanced(BTF_LIBRARY_DIR)

endif (BTF_LIBRARY)

if (SUITESPARSECONFIG_LIBRARY)
    get_filename_component(SUITESPARSECONFIG_LIBRARY_DIR ${SUITESPARSECONFIG_LIBRARY} PATH)
else (SUITESPARSECONFIG_LIBRARY)
    set(SUITESPARSECONFIG_LIBRARY_NAME suitesparseconfig)
    
    # find library path using potential names for static and/or shared libs
    set(temp_SUITESPARSECONFIG_LIBRARY_DIR ${KLU_LIBRARY_DIR})
    unset(SUITESPARSECONFIG_LIBRARY_DIR CACHE)  
    find_path(SUITESPARSECONFIG_LIBRARY_DIR
        NAMES ${PRE}${SUITESPARSECONFIG_LIBRARY_NAME}${POST} ${SUITESPARSECONFIG_LIBRARY_NAME}${POST}
        PATHS ${temp_SUITESPARSECONFIG_LIBRARY_DIR}
        )
    # NOTE: no PRE for this one on windows
    if (WIN32)
        FIND_LIBRARY( SUITESPARSECONFIG_LIBRARY suitesparseconfig${POST} ${SUITESPARSECONFIG_LIBRARY_DIR} NO_DEFAULT_PATH)
    else (WIN32)
        FIND_LIBRARY( SUITESPARSECONFIG_LIBRARY ${PRE}suitesparseconfig${POST} ${SUITESPARSECONFIG_LIBRARY_DIR} NO_DEFAULT_PATH)
    endif(WIN32)

    mark_as_advanced(SUITESPARSECONFIG_LIBRARY)
    mark_as_advanced(SUITESPARSECONFIG_LIBRARY_DIR)

endif (SUITESPARSECONFIG_LIBRARY)



set(KLU_LIBRARIES ${KLU_LIBRARY} ${AMD_LIBRARY} ${COLAMD_LIBRARY} ${BTF_LIBRARY} ${SUITESPARSECONFIG_LIBRARY})
