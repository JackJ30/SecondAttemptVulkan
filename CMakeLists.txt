cmake_minimum_required(VERSION 3.16)

set(CMAKE_BUILD_TYPE Debug)
project(VulkanAttemptTwo)

find_package(glm REQUIRED)
find_package(glfw3 REQUIRED)
find_package(Vulkan REQUIRED)
find_program(glslc_executable NAMES glslc HINTS Vulkan::glslc)

# program
add_executable(${PROJECT_NAME} src/main.cpp src/stbImp.cpp)
target_include_directories(${PROJECT_NAME} PRIVATE ${Vulkan_INCLUDE_DIRS} ${GLM_INCLUDE_DIRS})
target_link_libraries(${PROJECT_NAME} PRIVATE ${Vulkan_LIBRARIES} glfw glm::glm)

# shaders
set(SHADER_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/shaders")
set(SHADER_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/shaders")

file(GLOB SHADERS_SOURCE
  "${SHADER_SOURCE_DIR}/*.vert"
  "${SHADER_SOURCE_DIR}/*.frag")

add_custom_target(make-shader-dir ALL
    COMMAND ${CMAKE_COMMAND} -E make_directory ${SHADER_BINARY_DIR})

foreach(source IN LISTS SHADERS_SOURCE)
  get_filename_component(FILENAME ${source} NAME)
  add_custom_command(
    COMMAND
      ${glslc_executable}
      #      -MD -MF ${SHADER_BINARY_DIR}/${FILENAME}.d
      -o ${SHADER_BINARY_DIR}/${FILENAME}.spv
      ${source}
    OUTPUT ${SHADER_BINARY_DIR}/${FILENAME}.spv
    DEPENDS ${source} ${SHADER_BINARY_DIR}
    COMMENT "Compiling ${FILENAME}"
  )
  list(APPEND SPV_SHADERS ${SHADER_BINARY_DIR}/${FILENAME}.spv)
endforeach()

add_custom_target(shaders ALL DEPENDS ${SPV_SHADERS} make-shader-dir)

# images
set(SRC_IMAGES_DIR "${CMAKE_SOURCE_DIR}/images")
set(BUILD_IMAGES_DIR "${CMAKE_BINARY_DIR}/images")

add_custom_target(copy_images ALL
    COMMAND ${CMAKE_COMMAND} -E copy_directory
    ${SRC_IMAGES_DIR}
    ${BUILD_IMAGES_DIR}
)

add_dependencies(${PROJECT_NAME} copy_images)
