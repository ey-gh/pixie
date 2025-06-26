cmake_minimum_required(VERSION 3.20)
project(PixieBackend)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Automatically use vcpkg if available
if(NOT DEFINED CMAKE_TOOLCHAIN_FILE AND DEFINED ENV{VCPKG_ROOT})
  set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
      CACHE STRING "Vcpkg toolchain file")
endif()

# Find libraries provided by vcpkg
find_package(Crow CONFIG REQUIRED)
find_package(libpqxx CONFIG REQUIRED)
find_package(nlohmann_json CONFIG REQUIRED)

# Collect source files
file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS
  src/*.cpp
)

# Define executable
add_executable(PixieBackend ${SOURCES} "include/util/env_loader.h" "src/util/env_loader.cpp"   "include/routes/ping.h" "src/routes/ping.cpp" "include/routes/dbtest.h" "src/routes/dbtest.cpp" "include/routes/clients.h" "src/routes/clients.cpp" "include/core/pg_pool.h" "src/core/pg_pool.cpp" "include/core/logger.h" "src/core/logger.cpp" "include/core/app.h" "src/core/app.cpp" "include/validators/client_validator.h" "src/validators/client_validator.cpp" "include/services/client_service.h" "src/services/client_service.cpp" "src/validators/common_validation.cpp" "include/services/diagnostic_service.h" "src/services/diagnostic_service.cpp" "include/http/response_helpers.h" "src/http/response_helpers.cpp"  "include/error-handling/error.h" "src/error-handling/error.cpp")

# Include local headers
target_include_directories(PixieBackend
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Link libraries
target_link_libraries(PixieBackend
  PRIVATE
    Crow::Crow
    libpqxx::pqxx
    nlohmann_json::nlohmann_json
)

# Specify target version
add_definitions(-D_WIN32_WINNT=0x0A00) # Win 10