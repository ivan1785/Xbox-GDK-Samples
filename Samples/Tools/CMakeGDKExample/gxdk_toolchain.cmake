#
# grdk_toolchain.cmake : CMake Toolchain file for Gaming.Xbox.XboxOne.x64
#
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

mark_as_advanced(CMAKE_TOOLCHAIN_FILE)

if(_GXDK_TOOLCHAIN_)
  return()
endif()

# Microsoft Game Development Kit
set(XdkEditionTarget "220300" CACHE STRING "Microsoft GDK Edition")

message("XdkEditionTarget = ${XdkEditionTarget}")

set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES XdkEditionTarget)

set(CMAKE_SYSTEM_NAME WINDOWS)
set(CMAKE_SYSTEM_VERSION 10.0)

set(CMAKE_GENERATOR_PLATFORM "Gaming.Xbox.XboxOne.x64" CACHE STRING "" FORCE)
set(CMAKE_VS_PLATFORM_NAME "Gaming.Xbox.XboxOne.x64" CACHE STRING "" FORCE)

# Ensure our platform toolset is x64
set(CMAKE_VS_PLATFORM_TOOLSET_HOST_ARCHITECTURE "x64" CACHE STRING "" FORCE)

# Let the GDK MSBuild rules decide the WindowsTargetPlatformVersion
set(CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION "" CACHE STRING "" FORCE)

# Sets platform defines
set(CMAKE_CXX_FLAGS_INIT "$ENV{CFLAGS} ${CMAKE_CXX_FLAGS_INIT} -D_GAMING_XBOX -D_GAMING_XBOX_ONE -DWINAPI_FAMILY=WINAPI_FAMILY_GAMES -D_ATL_NO_DEFAULT_LIBS -D__WRL_NO_DEFAULT_LIB__ -D_CRT_USE_WINAPI_PARTITION_APP -D_UITHREADCTXT_SUPPORT=0 -D__WRL_CLASSIC_COM_STRICT__ /arch:AVX /favor:AMD64" CACHE STRING "" FORCE)

# Set platform libraries
set(CMAKE_CXX_STANDARD_LIBRARIES_INIT "xgameplatform.lib" CACHE STRING "" FORCE)
set(CMAKE_CXX_STANDARD_LIBRARIES ${CMAKE_CXX_STANDARD_LIBRARIES_INIT} CACHE STRING "" FORCE)

 foreach(t EXE SHARED MODULE)
    # Prevent accidental use of libraries that are not supported by Game Core on Xbox
    string(APPEND CMAKE_${t}_LINKER_FLAGS_INIT " /NODEFAULTLIB:advapi32.lib /NODEFAULTLIB:comctl32.lib /NODEFAULTLIB:comsupp.lib /NODEFAULTLIB:dbghelp.lib /NODEFAULTLIB:gdi32.lib /NODEFAULTLIB:gdiplus.lib /NODEFAULTLIB:guardcfw.lib /NODEFAULTLIB:kernel32.lib /NODEFAULTLIB:mmc.lib /NODEFAULTLIB:msimg32.lib /NODEFAULTLIB:msvcole.lib /NODEFAULTLIB:msvcoled.lib /NODEFAULTLIB:mswsock.lib /NODEFAULTLIB:ntstrsafe.lib /NODEFAULTLIB:ole2.lib /NODEFAULTLIB:ole2autd.lib /NODEFAULTLIB:ole2auto.lib /NODEFAULTLIB:ole2d.lib /NODEFAULTLIB:ole2ui.lib /NODEFAULTLIB:ole2uid.lib /NODEFAULTLIB:ole32.lib /NODEFAULTLIB:oleacc.lib /NODEFAULTLIB:oleaut32.lib /NODEFAULTLIB:oledlg.lib /NODEFAULTLIB:oledlgd.lib /NODEFAULTLIB:oldnames.lib /NODEFAULTLIB:runtimeobject.lib /NODEFAULTLIB:shell32.lib /NODEFAULTLIB:shlwapi.lib /NODEFAULTLIB:strsafe.lib /NODEFAULTLIB:urlmon.lib /NODEFAULTLIB:user32.lib /NODEFAULTLIB:userenv.lib /NODEFAULTLIB:wlmole.lib /NODEFAULTLIB:wlmoled.lib /NODEFAULTLIB:onecore.lib")
 endforeach()

# Add GDK props file
file(GENERATE OUTPUT gdk_build.props INPUT ${CMAKE_CURRENT_LIST_DIR}/gdk_build.props)

function(add_executable target_name)
  _add_executable(${target_name} ${ARGN})
  set_target_properties(${target_name} PROPERTIES VS_USER_PROPS ${CMAKE_CURRENT_LIST_DIR}/gdk_build.props)
endfunction()

function(add_library target_name)
  _add_library(${target_name} ${ARGN})
  set_target_properties(${target_name} PROPERTIES VS_USER_PROPS ${CMAKE_CURRENT_LIST_DIR}/gdk_build.props)
endfunction()

# Find DXC compiler
if(NOT GDK_DXCTool)
  GET_FILENAME_COMPONENT(Console_SdkRoot "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\GDK;InstallPath]" ABSOLUTE CACHE)

  find_program(
        GDK_DXCTool
        NAMES dxc
        PATHS "${Console_SdkRoot}/${XdkEditionTarget}/GXDK/bin/XboxOne"
        )

  mark_as_advanced(GDK_DXCTool)
endif()

set(_GXDK_TOOLCHAIN_ ON)
