# pixie/CMakeLists.txt

cmake_minimum_required(VERSION 3.20)
project(pixie)

# Set C++ standard globally
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add the backend subdirectory
add_subdirectory(backend)