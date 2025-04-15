cmake_minimum_required(VERSION 3.10)

# set the project name
if(DEFINED PROJECT_NAME)
    project(${PROJECT_NAME})
else()
    project(ThreadX)
endif()


set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

enable_language(C ASM)
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

execute_process(
    COMMAND git log -1 --format=%h
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
    OUTPUT_VARIABLE GIT_SHA
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )

set(COMMON_INCLUDE

    Core/Inc
    Drivers/STM32F4xx_HAL_Driver/Inc
    Drivers/STM32F4xx_HAL_Driver/Inc/Legacy
    Drivers/CMSIS/Device/ST/STM32F4xx/Include
    Drivers/CMSIS/Include

    Library/Middleware/FreeRTOS
    Library/Middleware/FreeRTOS/include
    Library/Middleware/FreeRTOS/portable/GCC/ARM_CM4F
    
    )
    
set(COMMON_FILES

    Core/Src/main.c
    Core/Src/gpio.c
    Core/Src/stm32f4xx_it.c 
    Core/Src/stm32f4xx_hal_msp.c
    Core/Src/system_stm32f4xx.c
    Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_tim.c
    Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_tim_ex.c
    Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc.c
    Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc_ex.c
    Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash.c
    Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash_ex.c
    Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash_ramfunc.c
    Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_gpio.c
    Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma_ex.c
    Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma.c
    Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr.c
    Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr_ex.c
    Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_cortex.c
    Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal.c
    Drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_exti.c

    Library/Middleware/FreeRTOS/portable/GCC/ARM_CM4F/port.c
    Library/Middleware/FreeRTOS/portable/MemMang/heap_4.c
    Library/Middleware/FreeRTOS/croutine.c
    Library/Middleware/FreeRTOS/event_groups.c
    Library/Middleware/FreeRTOS/list.c
    Library/Middleware/FreeRTOS/queue.c
    Library/Middleware/FreeRTOS/tasks.c 
    Library/Middleware/FreeRTOS/timers.c
    Library/Middleware/FreeRTOS/stream_buffer.c

    
    startup_stm32f401xe.s
    )


set(EXECUTABLE_APP ${PROJECT_NAME}-app)

add_executable(${EXECUTABLE_APP}.elf ${COMMON_FILES})

target_include_directories(${EXECUTABLE_APP}.elf PRIVATE ${COMMON_INCLUDE})

target_compile_definitions(${EXECUTABLE_APP}.elf PRIVATE
    -DUSE_HAL_DRIVER
    -DSTM32F401xE
    -DGIT_SHA=\"${GIT_SHA}\"
    -DNDEBUG=${NDEBUG}
    )

target_compile_options(${EXECUTABLE_APP}.elf PRIVATE
    -mcpu=cortex-m4
    -mthumb
    -mfpu=fpv4-sp-d16
    -mfloat-abi=hard   # Since the STM32F401 supports hardware floating-point

    -fdata-sections
    -ffunction-sections
    -std=gnu99
    -Wall

    $<$<CONFIG:Debug>:-Og>
    )

target_link_options(${EXECUTABLE_APP}.elf PRIVATE
    "SHELL:-T ${CMAKE_SOURCE_DIR}/STM32F401RETx_FLASH.ld"
    -mcpu=cortex-m4
    -mthumb
    -mfpu=fpv4-sp-d16
    -mfloat-abi=hard   # Enable hardware floating-point support

    -specs=nano.specs
    -u _printf_float
    -lc
    -lm
    -lnosys
    -Wl,-Map=${EXECUTABLE_APP}.map,--cref
    -Wl,--gc-sections
    )

add_custom_command(TARGET ${EXECUTABLE_APP}.elf
    POST_BUILD
    COMMAND arm-none-eabi-size ${EXECUTABLE_APP}.elf
    )

add_custom_command(TARGET ${EXECUTABLE_APP}.elf
    POST_BUILD
    COMMAND arm-none-eabi-objcopy -O ihex ${EXECUTABLE_APP}.elf ${EXECUTABLE_APP}.hex
    COMMAND arm-none-eabi-objcopy -O binary ${EXECUTABLE_APP}.elf ${EXECUTABLE_APP}.bin
    )