# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/mp11
    REF boost-${VERSION}
    SHA512 acf09145539c89b9edf558de292367abb124fdf4ce65bbefd4ae01aa62c3cf3c4078014f0ce69f19857bf16fac3bb820fc2cbcbfc16ddcbbf08cac77053e480d
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
