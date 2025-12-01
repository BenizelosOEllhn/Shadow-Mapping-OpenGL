cmake_minimum_required(VERSION 3.15)
project(VVR_OGL_LABORATORY)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# ---------------------------------------------------------
# 1. Setup
# ---------------------------------------------------------
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Needed on macOS for GLFW / Cocoa stuff
enable_language(OBJC)

if(APPLE)
    add_definitions(-Wno-deprecated-declarations)
endif()

find_package(OpenGL REQUIRED)

# Optional: postfixes (kept from original, in case external/ uses them)
set(CMAKE_RELEASE_POSTFIX "_r" CACHE STRING "Release postfix")
set(CMAKE_DEBUG_POSTFIX "_d" CACHE STRING "Debug postfix")
set(CMAKE_RELWITHDEBINFO_POSTFIX "_rd" CACHE STRING "Release with debug info postfix")
set(CMAKE_MINSIZEREL_POSTFIX "_mr" CACHE STRING "Minimum size release postfix")
mark_as_advanced(CMAKE_RELEASE_POSTFIX)
mark_as_advanced(CMAKE_DEBUG_POSTFIX)
mark_as_advanced(CMAKE_RELWITHDEBINFO_POSTFIX)
mark_as_advanced(CMAKE_MINSIZEREL_POSTFIX)

# ctest
include(CTest)
enable_testing()

# For grouping into folders in IDEs
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Sanity checks (kept from original)
if(CMAKE_BINARY_DIR STREQUAL CMAKE_SOURCE_DIR)
    message(FATAL_ERROR "Please select another Build Directory! (e.g. bin_Visual2012_64bits/)")
endif()
if(CMAKE_SOURCE_DIR MATCHES " ")
    message("Your Source Directory contains spaces. If you experience problems when compiling, this can be the cause.")
endif()
if(CMAKE_BINARY_DIR MATCHES " ")
    message("Your Build Directory contains spaces. If you experience problems when compiling, this can be the cause.")
endif()

# ---------------------------------------------------------
# 2. Directories
# ---------------------------------------------------------
set(EXT_DIR   "${CMAKE_CURRENT_SOURCE_DIR}/external")
set(COMMON_DIR "${CMAKE_CURRENT_SOURCE_DIR}/common")
set(LAB06_DIR "${CMAKE_CURRENT_SOURCE_DIR}/lab06")

# For rpavlik launchers, etc.
list(APPEND CMAKE_MODULE_PATH "${EXT_DIR}/rpavlik-cmake-modules-fe2273")
include(CreateLaunchers)
include(MSVCMultipleProcessCompile) # /MP on MSVC

# ---------------------------------------------------------
# 3. External dependencies
# ---------------------------------------------------------
# This assumes your external/CMakeLists.txt defines:
#   glfw
#   GLEW_1130
#   SOIL
#   TINYXML2
add_subdirectory(${EXT_DIR})

# ---------------------------------------------------------
# 4. Global include dirs (for convenience)
# ---------------------------------------------------------
include_directories(
    "${EXT_DIR}/glfw-3.4/include/GLFW"
    "${EXT_DIR}/glm-0.9.7.1"
    "${EXT_DIR}/glew-1.13.0/include"
    "${EXT_DIR}/Simple-OpenGL-Image-Library/include"
    "${EXT_DIR}/tinyxml2/include"
    "${EXT_DIR}/tinyobjloader/include"
    "${COMMON_DIR}"
    "${LAB06_DIR}"
)

# ---------------------------------------------------------
# 5. Libraries and compile definitions
# ---------------------------------------------------------
set(ALL_LIBS
    OpenGL::GL
    glfw
    GLEW_1130
    SOIL
    TINYXML2
)

add_definitions(
    -DTW_STATIC
    -DTW_NO_LIB_PRAGMA
    -DTW_NO_DIRECT3D
    -DGLEW_STATIC
    -D_CRT_SECURE_NO_WARNINGS
)

# ---------------------------------------------------------
# 6. Executable lab06
# ---------------------------------------------------------
add_executable(lab06
    # Sources
    "${LAB06_DIR}/lab.cpp"

    "${COMMON_DIR}/util.cpp"
    "${COMMON_DIR}/util.h"
    "${COMMON_DIR}/shader.cpp"
    "${COMMON_DIR}/shader.h"
    "${COMMON_DIR}/camera.cpp"
    "${COMMON_DIR}/camera.h"
    "${COMMON_DIR}/model.cpp"
    "${COMMON_DIR}/model.h"
    "${COMMON_DIR}/texture.cpp"
    "${COMMON_DIR}/texture.h"
    "${COMMON_DIR}/light.cpp"
    "${COMMON_DIR}/light.h"

    # Shaders as resources (so IDEs show them)
    "${LAB06_DIR}/ShadowMapping.fragmentshader"
    "${LAB06_DIR}/ShadowMapping.vertexshader"
    "${LAB06_DIR}/Depth.fragmentshader"
    "${LAB06_DIR}/Depth.vertexshader"
    "${LAB06_DIR}/MiniMap.fragmentshader"
    "${LAB06_DIR}/MiniMap.vertexshader"
)

target_include_directories(lab06 PUBLIC
    "${EXT_DIR}/glfw-3.4/include/GLFW"
    "${EXT_DIR}/glm-0.9.7.1"
    "${EXT_DIR}/glew-1.13.0/include"
    "${EXT_DIR}/Simple-OpenGL-Image-Library/include"
    "${EXT_DIR}/tinyxml2/include"
    "${EXT_DIR}/tinyobjloader/include"
    "${COMMON_DIR}"
    "${LAB06_DIR}"
)

target_link_libraries(lab06
    PRIVATE
        ${ALL_LIBS}
)

# ---------------------------------------------------------
# 7. IDE Properties & launchers
# ---------------------------------------------------------
set_target_properties(lab06 PROPERTIES
    XCODE_ATTRIBUTE_CONFIGURATION_BUILD_DIR "${LAB06_DIR}/"
    PROJECT_LABEL "Lab 06 - Shadow Mapping"
    FOLDER "Exercise"
)

create_target_launcher(
    lab06
    WORKING_DIRECTORY "${LAB06_DIR}/"
)
create_default_target_launcher(
    lab06
    WORKING_DIRECTORY "${LAB06_DIR}/"
)

# ---------------------------------------------------------
# 8. Post-build copy (non-Xcode)
# ---------------------------------------------------------
if(NOT ${CMAKE_GENERATOR} MATCHES "Xcode")
    add_custom_command(
        TARGET lab06 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
                "$<TARGET_FILE:lab06>"
                "${LAB06_DIR}/"
    )
endif()

# ---------------------------------------------------------
# 9. Source groups (for Visual Studio)
# ---------------------------------------------------------
source_group(common  REGULAR_EXPRESSION ".*/common/.*")
source_group(shaders REGULAR_EXPRESSION ".*/.*shader$")
source_group(obj     REGULAR_EXPRESSION ".*/.*obj$")

