cmake_minimum_required(VERSION 2.8.3)
project(tue_hardware)
find_package(catkin REQUIRED)
catkin_metapackage()

catkin_add_env_hooks(${PROJECT_NAME} SHELLS sh DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/env-hooks)