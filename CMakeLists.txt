CMAKE_MINIMUM_REQUIRED(VERSION 3.8)
PROJECT(OpenSpecFun LANGUAGES C CXX Fortran)
SET(VERSION 0.0.5)

set(CMAKE_BUILD_TYPE Release)
SET(CMAKE_Fortran_COMPILER gfortran)

SET(SRC_FADDEEVA ${CMAKE_SOURCE_DIR}/Faddeeva)
SET(FADDEEVA_src ${SRC_FADDEEVA}/Faddeeva.c)
SET(FADDEEVA_inc ${SRC_FADDEEVA}/Faddeeva.h)

SET(SRC_AMOS ${CMAKE_SOURCE_DIR}/amos)
SET(AMOS_src
    ${SRC_AMOS}/zabs.f
    ${SRC_AMOS}/zbesi.f
    ${SRC_AMOS}/zbknu.f
    ${SRC_AMOS}/zlog.f
    ${SRC_AMOS}/zshch.f
    ${SRC_AMOS}/zunik.f
    ${SRC_AMOS}/d1mach.f
    ${SRC_AMOS}/zacai.f
    ${SRC_AMOS}/zbesj.f
    ${SRC_AMOS}/zbuni.f
    ${SRC_AMOS}/zmlri.f
    ${SRC_AMOS}/zsqrt.f
    ${SRC_AMOS}/zunk1.f
    ${SRC_AMOS}/dgamln.f
    ${SRC_AMOS}/zacon.f
    ${SRC_AMOS}/zbesk.f
    ${SRC_AMOS}/zbunk.f
    ${SRC_AMOS}/zmlt.f
    ${SRC_AMOS}/zuchk.f
    ${SRC_AMOS}/zunk2.f
    ${SRC_AMOS}/i1mach.f
    ${SRC_AMOS}/zairy.f
    ${SRC_AMOS}/zbesy.f
    ${SRC_AMOS}/zdiv.f
    ${SRC_AMOS}/zrati.f
    ${SRC_AMOS}/zunhj.f
    ${SRC_AMOS}/zuoik.f
    ${SRC_AMOS}/zasyi.f
    ${SRC_AMOS}/zbinu.f
    ${SRC_AMOS}/zexp.f
    ${SRC_AMOS}/zs1s2.f
    ${SRC_AMOS}/zuni1.f
    ${SRC_AMOS}/zwrsk.f
    ${SRC_AMOS}/xerror.f
    ${SRC_AMOS}/zbesh.f
    ${SRC_AMOS}/zbiry.f
    ${SRC_AMOS}/zkscl.f
    ${SRC_AMOS}/zseri.f
    ${SRC_AMOS}/zuni2.f
    )

SET(CMAKE_Fortran_FLAGS -fno-optimize-sibling-calls)

if(CMAKE_C_COMPILER_ID MATCHES GNU)
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-gnu89-inline -std=c99")
elseif(CMAKE_C_COMPILER_ID MATCHES AppleClang
        OR
        CMAKE_C_COMPILER_ID MATCHES Clang)
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-builtin -std=c99")
endif()

# Make both static and shared library share same name
# Trick copied from https://cmake.org/pipermail/cmake/2006-May/009201.html
ADD_LIBRARY(openspecfun-shared SHARED ${AMOS_src} ${FADDEEVA_src})
SET_TARGET_PROPERTIES(openspecfun-shared PROPERTIES
   OUTPUT_NAME openspecfun CLEAN_DIRECT_OUTPUT 1
   PUBLIC_HEADER "${FADDEEVA_inc}")

ADD_LIBRARY(openspecfun-static STATIC ${AMOS_src} ${FADDEEVA_src})
SET_TARGET_PROPERTIES(openspecfun-static PROPERTIES
   OUTPUT_NAME openspecfun CLEAN_DIRECT_OUTPUT 1
   PUBLIC_HEADER "${FADDEEVA_inc}")

INSTALL(TARGETS openspecfun-shared openspecfun-static
    PUBLIC_HEADER)
