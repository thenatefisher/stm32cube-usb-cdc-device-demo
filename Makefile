OUTPUT_ARM_FILENAME=usb-cdc-example


# # # # # # # # # # # # # # # # # # # # # 
# Build system config
# # # # # # # # # # # # # # # # # # # # #

## Initializing a few helper variables
ARM_DEPS=
ARM_LINK_FLAGS=
ARM_CC_INCLUDES=
ARM_CC_FLAGS=

BUILD_DIR=build
DIST_DIR=dist
SRC_DIR=src

ARM_GCC=arm-none-eabi-gcc

## Compiler options
ARM_CC_FLAGS+=-DSTM32F407xx -DUSE_FULL_ASSERT -DDEBUG --specs=nosys.specs -mthumb -march=armv7e-m -mfloat-abi=hard 
ARM_CC_FLAGS+=-mfpu=fpv4-sp-d16 -g -O2 -Wall -mcpu=cortex-m4 
ARM_CC_FLAGS+=-Wno-unused-variable -Wno-unused-function
SEMIHOSTING_FLAGS = --specs=rdimon.specs -lc -lrdimon 

## Linker options
ARM_LINK_FLAGS+=-lm -Tstm32_flash.ld  

## Project includes
ARM_CC_INCLUDES+=-Iinc 

## BSP
ARM_CC_INCLUDES+=-Ilib/BSP/STM32F4-Discovery 

## Middleware
ARM_CC_INCLUDES+=-Ilib/STM32_USB_Device_Library/Core/Inc 
ARM_CC_INCLUDES+=-Ilib/STM32_USB_Device_Library/Class/CDC/Inc 

## HAL libraries
ARM_CC_INCLUDES+=-Ilib/STM32F4xx_HAL_Driver/Inc 

## CMSIS libraries
ARM_CC_INCLUDES+=-Ilib/CMSIS/Include 
ARM_CC_INCLUDES+=-Ilib/CMSIS/Device/ST/STM32F4xx/Include 



# # # # # # # # # # # # # # # # # # # # # 
# Standard high-level directives
# # # # # # # # # # # # # # # # # # # # #  

all: build

DIST_ARM_FILE=${DIST_DIR}/${OUTPUT_ARM_FILENAME}
build: .build-pre
	make ${DIST_ARM_FILE}

.build-pre:

clean:
	${RM} -r ${BUILD_DIR}
	${RM} -r ${DIST_DIR}
	${RM} -r tests

# Start OpenOCD GDB server (supports semihosting)
openocd: 
	openocd -f board/stm32f4discovery.cfg 

# # # # # # # # # # # # # # # # # # # # #  
# BSP Code
# # # # # # # # # # # # # # # # # # # # #  


# # # # # # # # # # # # # # # # # # # # #  
# Compile application code
# # # # # # # # # # # # # # # # # # # # #  

ARM_DEPS+=${BUILD_DIR}/main.o 
${BUILD_DIR}/main.o: ${SRC_DIR}/main.c
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/main.o ${ARM_CC_INCLUDES} -c ${SRC_DIR}/main.c

ARM_DEPS+=${BUILD_DIR}/gpio.o 
${BUILD_DIR}/gpio.o: ${SRC_DIR}/gpio.c
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/gpio.o ${ARM_CC_INCLUDES} -c ${SRC_DIR}/gpio.c

## ISRs 
ARM_DEPS+=${BUILD_DIR}/stm32f4xx_it.o 
${BUILD_DIR}/stm32f4xx_it.o: ${SRC_DIR}/stm32f4xx_it.c
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/stm32f4xx_it.o ${ARM_CC_INCLUDES} -c ${SRC_DIR}/stm32f4xx_it.c

# # # # # # # # # # # # # # # # # # # # #  
# Compile USB Middleware code
# # # # # # # # # # # # # # # # # # # # #  

ARM_DEPS+=${BUILD_DIR}/usbd_cdc.o 
${BUILD_DIR}/usbd_cdc.o: lib/STM32_USB_Device_Library/Class/CDC/Src/usbd_cdc.c
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/usbd_cdc.o ${ARM_CC_INCLUDES} -c lib/STM32_USB_Device_Library/Class/CDC/Src/usbd_cdc.c

ARM_DEPS+=${BUILD_DIR}/usbd_core.o 
${BUILD_DIR}/usbd_core.o: lib/STM32_USB_Device_Library/Core/Src/usbd_core.c
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/usbd_core.o ${ARM_CC_INCLUDES} -c lib/STM32_USB_Device_Library/Core/Src/usbd_core.c
	
ARM_DEPS+=${BUILD_DIR}/usbd_ctlreq.o 
${BUILD_DIR}/usbd_ctlreq.o: lib/STM32_USB_Device_Library/Core/Src/usbd_ctlreq.c
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/usbd_ctlreq.o ${ARM_CC_INCLUDES} -c lib/STM32_USB_Device_Library/Core/Src/usbd_ctlreq.c
	
ARM_DEPS+=${BUILD_DIR}/usbd_ioreq.o 
${BUILD_DIR}/usbd_ioreq.o: lib/STM32_USB_Device_Library/Core/Src/usbd_ioreq.c
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/usbd_ioreq.o ${ARM_CC_INCLUDES} -c lib/STM32_USB_Device_Library/Core/Src/usbd_ioreq.c
	
## USB stuff from cube
ARM_DEPS+=${BUILD_DIR}/usbd_desc.o 
${BUILD_DIR}/usbd_desc.o: ${SRC_DIR}/usbd_desc.c
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/usbd_desc.o ${ARM_CC_INCLUDES} -c ${SRC_DIR}/usbd_desc.c

ARM_DEPS+=${BUILD_DIR}/usbd_conf.o 
${BUILD_DIR}/usbd_conf.o: ${SRC_DIR}/usbd_conf.c
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/usbd_conf.o ${ARM_CC_INCLUDES} -c ${SRC_DIR}/usbd_conf.c

ARM_DEPS+=${BUILD_DIR}/usbd_cdc_if.o 
${BUILD_DIR}/usbd_cdc_if.o: ${SRC_DIR}/usbd_cdc_if.c
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/usbd_cdc_if.o ${ARM_CC_INCLUDES} -c ${SRC_DIR}/usbd_cdc_if.c

ARM_DEPS+=${BUILD_DIR}/usb_device.o 
${BUILD_DIR}/usb_device.o: ${SRC_DIR}/usb_device.c
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/usb_device.o ${ARM_CC_INCLUDES} -c ${SRC_DIR}/usb_device.c

# # # # # # # # # # # # # # # # # # # # #  
# Compile STM32F4xx HAL lib
# # # # # # # # # # # # # # # # # # # # #  

ARM_DEPS+=${BUILD_DIR}/stm32f4xx_hal.o 
${BUILD_DIR}/stm32f4xx_hal.o: lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal.c
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/stm32f4xx_hal.o ${ARM_CC_INCLUDES} -c lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal.c

ARM_DEPS+=${BUILD_DIR}/stm32f4xx_hal_dma.o 
${BUILD_DIR}/stm32f4xx_hal_dma.o: lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma.c 
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/stm32f4xx_hal_dma.o ${ARM_CC_INCLUDES} -c lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma.c

ARM_DEPS+=${BUILD_DIR}/stm32f4xx_hal_flash.o 
${BUILD_DIR}/stm32f4xx_hal_flash.o: lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash.c 
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/stm32f4xx_hal_flash.o ${ARM_CC_INCLUDES} -c lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash.c

ARM_DEPS+=${BUILD_DIR}/stm32f4xx_hal_flash_ex.o 
${BUILD_DIR}/stm32f4xx_hal_flash_ex.o: lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash_ex.c 
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/stm32f4xx_hal_flash_ex.o ${ARM_CC_INCLUDES} -c lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_flash_ex.c

ARM_DEPS+=${BUILD_DIR}/stm32f4xx_hal_rcc.o 
${BUILD_DIR}/stm32f4xx_hal_rcc.o: lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc.c 
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/stm32f4xx_hal_rcc.o ${ARM_CC_INCLUDES} -c lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc.c

ARM_DEPS+=${BUILD_DIR}/stm32f4xx_hal_rcc_ex.o 
${BUILD_DIR}/stm32f4xx_hal_rcc_ex.o: lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc_ex.c 
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/stm32f4xx_hal_rcc_ex.o ${ARM_CC_INCLUDES} -c lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc_ex.c

ARM_DEPS+=${BUILD_DIR}/stm32f4xx_hal_pwr.o 
${BUILD_DIR}/stm32f4xx_hal_pwr.o: lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr.c 
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/stm32f4xx_hal_pwr.o ${ARM_CC_INCLUDES} -c lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr.c

ARM_DEPS+=${BUILD_DIR}/stm32f4xx_hal_pwr_ex.o 
${BUILD_DIR}/stm32f4xx_hal_pwr_ex.o: lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr_ex.c 
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/stm32f4xx_hal_pwr_ex.o ${ARM_CC_INCLUDES} -c lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr_ex.c

ARM_DEPS+=${BUILD_DIR}/stm32f4xx_hal_gpio.o 
${BUILD_DIR}/stm32f4xx_hal_gpio.o: lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_gpio.c 
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/stm32f4xx_hal_gpio.o ${ARM_CC_INCLUDES} -c lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_gpio.c

ARM_DEPS+=${BUILD_DIR}/stm32f4xx_hal_pcd.o 
${BUILD_DIR}/stm32f4xx_hal_pcd.o: lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pcd.c 
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/stm32f4xx_hal_pcd.o ${ARM_CC_INCLUDES} -c lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pcd.c

ARM_DEPS+=${BUILD_DIR}/stm32f4xx_ll_usb.o 
${BUILD_DIR}/stm32f4xx_ll_usb.o: lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_ll_usb.c 
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/stm32f4xx_ll_usb.o ${ARM_CC_INCLUDES} -c lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_ll_usb.c

ARM_DEPS+=${BUILD_DIR}/stm32f4xx_hal_cortex.o 
${BUILD_DIR}/stm32f4xx_hal_cortex.o: lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_cortex.c 
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/stm32f4xx_hal_cortex.o ${ARM_CC_INCLUDES} -c lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_cortex.c

ARM_DEPS+=${BUILD_DIR}/stm32f4xx_hal_tim.o 
${BUILD_DIR}/stm32f4xx_hal_tim.o: lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_tim.c 
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/stm32f4xx_hal_tim.o ${ARM_CC_INCLUDES} -c lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_tim.c

ARM_DEPS+=${BUILD_DIR}/stm32f4xx_hal_tim_ex.o 
${BUILD_DIR}/stm32f4xx_hal_tim_ex.o: lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_tim_ex.c 
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/stm32f4xx_hal_tim_ex.o ${ARM_CC_INCLUDES} -c lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_tim_ex.c

ARM_DEPS+=${BUILD_DIR}/stm32f4xx_hal_uart.o 
${BUILD_DIR}/stm32f4xx_hal_uart.o: lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_uart.c 
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/stm32f4xx_hal_uart.o ${ARM_CC_INCLUDES} -c lib/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_uart.c

# # # # # # # # # # # # # # # # # # # # #  
# Compile CMSIS
# # # # # # # # # # # # # # # # # # # # #  

ARM_DEPS+=${BUILD_DIR}/system_stm32f4xx.o 
${BUILD_DIR}/system_stm32f4xx.o: lib/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c
	mkdir -p ${BUILD_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} -o ${BUILD_DIR}/system_stm32f4xx.o ${ARM_CC_INCLUDES} -c lib/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c

# # # # # # # # # # # # # # # # # # # # #  
# Link it all up
# # # # # # # # # # # # # # # # # # # # # 


test: 
	@mkdir -p dist/test
	$(CC) -std=c99 -lcmocka tests/test.c -o dist/test/runner


# add in the linker script 
ARM_DEPS+=lib/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc/startup_stm32f407xx.s

${DIST_ARM_FILE}.elf: ${ARM_DEPS} stm32_flash.ld 
	mkdir -p ${DIST_DIR}
	${ARM_GCC} ${ARM_CC_FLAGS} ${SEMIHOSTING_FLAGS} -o ${DIST_ARM_FILE}.elf ${ARM_DEPS} ${ARM_LINK_FLAGS} 

${DIST_ARM_FILE}.hex: ${DIST_ARM_FILE}.elf
	arm-none-eabi-objcopy -O ihex ${DIST_ARM_FILE}.elf ${DIST_ARM_FILE}.hex

${DIST_ARM_FILE}.bin: ${DIST_ARM_FILE}.elf
	arm-none-eabi-objcopy -O binary ${DIST_ARM_FILE}.elf ${DIST_ARM_FILE}.bin

# render all flavors of binaries at once
${DIST_ARM_FILE}: 
	make ${DIST_ARM_FILE}.elf
	make ${DIST_ARM_FILE}.hex
	make ${DIST_ARM_FILE}.bin

