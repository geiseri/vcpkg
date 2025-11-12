vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO FreeRDP/FreeRDP
    REF "${VERSION}"
    SHA512 12b75a6a9af6f0cd115eeaf38f227598131404536f0bdbadca87740e289a3c6a298d474661e056391b442197a719ce92cbb14033b369fff0ad1f34fbcac95a05
    HEAD_REF master
    PATCHES
        dependencies.patch
        ffmpeg.diff
        install-layout.patch
        windows-linkage.patch
)
file(WRITE "${SOURCE_PATH}/.source_version" "${VERSION}-vcpkg")
file(WRITE "${SOURCE_PATH}/CMakeCPack.cmake" "")

if("x11" IN_LIST FEATURES)
    message(STATUS "${PORT} currently requires the following libraries from the system package manager:\n    libxfixes-dev\n")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ffmpeg      WITH_DSP_FFMPEG
        ffmpeg      WITH_FFMPEG
        ffmpeg      WITH_SWSCALE
        server      WITH_SERVER
        urbdrc      CHANNEL_URBDRC
        winpr-tools WITH_WINPR_TOOLS
        winpr-tools WITH_WINPR_TOOLS_CLI
        x11         WITH_X11
        x11         VCPKG_LOCK_FIND_PACKAGE_X11
        sdl3        WITH_CLIENT_SDL3
        sdl3        WITH_SDL_IMAGE_DIALOGS
        openh264    WITH_OPENH264
        fdk-aac     WITH_FDK_AAC
)

if("client" IN_LIST FEATURES)
    # Xcode dependency and untested installation paths
    if(VCPKG_TARGET_IS_IOS)
        message(STATUS "Not building native client components for iOS.")
        list(APPEND FEATURE_OPTIONS -DWITH_CLIENT_IOS=OFF)
    elseif(VCPKG_TARGET_IS_OSX)
        message(STATUS "Not building native client components for MacOS.")
        list(APPEND FEATURE_OPTIONS -DWITH_CLIENT_MAC=OFF)
    elseif(VCPKG_TARGET_IS_WINDOWS)
        message(STATUS "Not building native client components for Windows.")
        list(APPEND FEATURE_OPTIONS -DWITH_CLIENT_WINDOWS=OFF)
    endif()
endif()

set(HAS_SHADOW_SUBSYSTEM ON)

if("server" IN_LIST FEATURES)
    # actual shadow platform subsystem
    if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_WINDOWS # implementation unmaintained
       OR NOT WITH_X11) # dependency
        set(HAS_SHADOW_SUBSYSTEM OFF)
    endif()
    # actual platform server implementation
    if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_WINDOWS) # implementation unmaintained
        list(APPEND FEATURE_OPTIONS -DWITH_PLATFORM_SERVER=OFF)
    endif()
endif()

if (NOT HAS_SHADOW_SUBSYSTEM)
    list(APPEND FEATURE_OPTIONS -DWITH_SHADOW_SUBSYSTEM=OFF -DWITH_SERVER_SHADOW_CLI=OFF)
endif()

if (VCPKG_TARGET_IS_OSX)
    #Turned off in upstream config
    list(APPEND FEATURE_OPTIONS -DCHANNEL_RDPEAR=OFF)
    #Do not try to pull in homebrew packages
	#list(APPEND FEATURE_OPTIONS -DCMAKE_IGNORE_PATH="/opt/local;/usr/local;/opt/homebrew;/Library;~/Library")
	#list(APPEND FEATURE_OPTIONS -DCMAKE_IGNORE_PREFIX_PATH="/opt/local;/usr/local;/opt/homebrew;/Library;~/Library")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    if(WITH_CLIENT_SDL3)
        list(APPEND FEATURE_OPTIONS -DWITH_SDL_LINK_SHARED=OFF)
    endif()
    if(HAS_SHADOW_SUBSYSTEM)
        list(APPEND FEATURE_OPTIONS -DRDTK_FORCE_STATIC_BUILD=ON)
    endif()
    list(APPEND FEATURE_OPTIONS -DBUILD_SHARED_LIBS=OFF)
    list(APPEND FEATURE_OPTIONS -DENABLE_STATIC=ON)
endif()

#file(REMOVE
    #"${SOURCE_PATH}/cmake/Findlodepng.cmake"
    #"${SOURCE_PATH}/cmake/FindFFmpeg.cmake"
    #"${SOURCE_PATH}/cmake/FindFAAC.cmake"
#)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    ${GENERATOR_OPTION}
    OPTIONS
        ${FEATURE_OPTIONS}
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        -DUSE_VERSION_FROM_GIT_TAG=OFF
        -DWITH_AAD=ON
        -DWITH_CCACHE=OFF
        -DWITH_CLANG_FORMAT=OFF
        -DWITH_MANPAGES=OFF
        -DWITH_SAMPLE=OFF
        -DWITH_UNICODE_BUILTIN=ON
        "-DMSVC_RUNTIME=${VCPKG_CRT_LINKAGE}"
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        # Unmaintained
        -DWITH_CLIENT_WINDOWS=OFF
        -DWITH_WAYLAND=OFF
        # Uncontrolled dependencies w.r.t. vcpkg ports, system libs, or tools
        # Can be overriden in custom triplet file
        -DUSE_UNWIND=OFF
        -DWITH_ABSOLUTE_PLUGIN_LOAD_PATHS=OFF
        -DWITH_ALSA=OFF
        -DWITH_CAIRO=OFF
        -DWITH_CCACHE=OFF
        -DWITH_CLANG_FORMAT=OFF
        -DWITH_CLIENT_SDL2=OFF
        -DWITH_CUPS=OFF
        -DWITH_FUSE=OFF
        -DWITH_FAAD2=OFF
        -DWITH_FAAC=OFF
        -DFREERDP_UNIFIED_BUILD=ON
        -DWITH_JSONC_REQUIRED=ON
        -DWITH_KRB5=OFF
        -DWITH_LIBSYSTEMD=OFF
        -DWITH_LODEPNG=OFF
        -DWITH_MANPAGES=OFF
        -DWITH_OPENSSL=ON
        -DWITH_OPUS=OFF
        -DWITH_OSS=OFF
        -DWITH_PCSC=OFF
        -DWITH_PKCS11=OFF
        -DWITH_PROXY_MODULES=OFF
        -DWITH_PULSE=OFF
        # no v2l support
        -DRDPECAM_CLIENT_CHANNEL_STUB=ON
        -DWITH_SAMPLE=OFF
        -DWITH_SIMD=ON 
        -DWITH_UNICODE_BUILTIN=ON
        -DWITH_URIPARSER=ON
        -DWITH_WAYLAND=OFF
        -DWITH_WEBVIEW=OFF
        "-DMSVC_RUNTIME=${VCPKG_CRT_LINKAGE}"
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        "-DPKG_CONFIG_ARGN=-libs-only-L"
        # Uncontrolled dependencies w.r.t. vcpkg ports, system libs, or tools
        # Can be overriden in custom triplet file
        -DUSE_UNWIND=OFF
        -DCMAKE_BUILD_TYPE=Release
        -DWITH_SDL_LINK_SHARED=OFF
    OPTIONS_RELEASE
        -DWITH_VERBOSE_WINPR_ASSERT=OFF
    MAYBE_UNUSED_VARIABLES
        MSVC_RUNTIME
        USE_UNWIND
        VCPKG_LOCK_FIND_PACKAGE_X11
        WITH_CLIENT_WINDOWS
        VCPKG_LOCK_FIND_PACKAGE_X11
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_list(SET tools)
if("client" IN_LIST FEATURES AND "x11" IN_LIST FEATURES)
    list(APPEND tools xfreerdp)
endif()
if("server" IN_LIST FEATURES)
    list(APPEND tools freerdp-proxy)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FreeRDP-Proxy3 PACKAGE_NAME freerdp-Proxy3 DO_NOT_DELETE_PARENT_CONFIG_PATH)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FreeRDP-Server3 PACKAGE_NAME freerdp-server3 DO_NOT_DELETE_PARENT_CONFIG_PATH)
    if (HAS_SHADOW_SUBSYSTEM)
        vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FreeRDP-Shadow3 PACKAGE_NAME freerdp-shadow3 DO_NOT_DELETE_PARENT_CONFIG_PATH)
        list(APPEND tools freerdp-shadow-cli)
    endif()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/rdtk0 PACKAGE_NAME rdtk0 DO_NOT_DELETE_PARENT_CONFIG_PATH)
endif()
if("winpr-tools" IN_LIST FEATURES)
    list(APPEND tools winpr-hash winpr-makecert)
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/WinPR-tools3 PACKAGE_NAME winpr-tools3 DO_NOT_DELETE_PARENT_CONFIG_PATH)
endif()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FreeRDP-Client3 PACKAGE_NAME freerdp-client3 DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/WinPR3 PACKAGE_NAME winpr3 DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/FreeRDP3 PACKAGE_NAME freerdp)

if(tools)
    vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/winpr3/winpr/build-config.h" "\"${CURRENT_PACKAGES_DIR}" "/* vcpkg redacted */ \"")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # They build static with dllexport, so it must be used with dllexport. Proper fix needs invasive patching.
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/freerdp3/freerdp/api.h" "#ifdef FREERDP_EXPORTS" "#if 1")
    if(WITH_SERVER)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/rdtk0/rdtk/api.h" "#ifdef RDTK_EXPORTS" "#if 1")
    endif()
endif()

file(GLOB cmakefiles  "${CURRENT_PACKAGES_DIR}/include/*/CMakeFiles")
file(REMOVE_RECURSE
    ${cmakefiles}
    "${CURRENT_PACKAGES_DIR}/include/winpr3/config"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
