cmake_minimum_required(VERSION 3.1.3)

project(serv_test)

find_package(verilator HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})
if (NOT verilator_FOUND)
    message(FATAL_ERROR "Could not find Verilator. Install or set $VERILATOR_ROOT")
endif()

set(SERV_SOURCES
    ${PROJECT_SOURCE_DIR}/serv/serv_ctrl.v
    ${PROJECT_SOURCE_DIR}/serv/serv_bufreg2.v
    ${PROJECT_SOURCE_DIR}/serv/serv_bufreg.v
    ${PROJECT_SOURCE_DIR}/serv/serv_rf_top.v
    ${PROJECT_SOURCE_DIR}/serv/serv_rf_ram_if.v
    ${PROJECT_SOURCE_DIR}/serv/serv_alu.v
    ${PROJECT_SOURCE_DIR}/serv/serv_decode.v
    ${PROJECT_SOURCE_DIR}/serv/serv_mem_if.v
    ${PROJECT_SOURCE_DIR}/serv/serv_rf_ram.v
    ${PROJECT_SOURCE_DIR}/serv/serv_rf_if.v
    ${PROJECT_SOURCE_DIR}/serv/serv_csr.v
    ${PROJECT_SOURCE_DIR}/serv/serv_top.v
    ${PROJECT_SOURCE_DIR}/serv/serv_immdec.v
    ${PROJECT_SOURCE_DIR}/serv/serv_state.v
)


# Locate the riscv toolchain components
set(RISCV_PREFIX riscv32-unknown-elf)
find_program(RISCV_CXX ${RISCV_PREFIX}-g++)
find_program(RISCV_CC ${RISCV_PREFIX}-gcc)
find_program(RISCV_LD ${RISCV_PREFIX}-ld)
find_program(RISCV_OBJCOPY ${RISCV_PREFIX}-objcopy)
find_program(RISCV_SIZE ${RISCV_PREFIX}-size)

# Find the bin -> reversed hex tool
find_program(MAKEHEX_PY makehex.py ${PROJECT_SOURCE_DIR})

set(FW_SOURCES ${PROJECT_SOURCE_DIR}/main.cpp)

set(FW_LDSCRIPT ${PROJECT_SOURCE_DIR}/sections.ld)
set(FW_CFLAGS -march=rv32i --static -nostartfiles -ffreestanding -g -O0)
set(FW_LDFLAGS -Wl,-Bstatic,-T,${FW_LDSCRIPT})

set(ELF_FILE ${PROJECT_NAME}.elf)
set(BIN_FILE ${PROJECT_NAME}.bin)
set(HEX_FILE ${PROJECT_NAME}.hex)

add_custom_command(
    OUTPUT ${ELF_FILE}
    DEPENDS ${FW_SOURCES}
    COMMAND ${RISCV_CC} ${FW_CFLAGS} ${FW_LDFLAGS} ${FW_SOURCES} -o ${ELF_FILE}
)

add_custom_command(
    OUTPUT ${BIN_FILE}
    DEPENDS ${ELF_FILE}
    COMMAND ${RISCV_OBJCOPY} ARGS -O binary ${ELF_FILE} ${BIN_FILE}
)

add_custom_command(
    OUTPUT ${HEX_FILE}
    DEPENDS ${BIN_FILE}
    COMMAND ${MAKEHEX_PY} ARGS ${BIN_FILE} > ${HEX_FILE}
)

add_custom_target(${PROJECT_NAME}_fw
    DEPENDS ${HEX_FILE}
)

add_executable(${PROJECT_NAME}_sim sim.cpp)
add_dependencies(${PROJECT_NAME}_sim ${PROJECT_NAME}_fw)
verilate(${PROJECT_NAME}_sim COVERAGE TRACE
        INCLUDE_DIRS "${PROJECT_SOURCE_DIR}"
        VERILATOR_ARGS -O2 -x-assign 0 +define+RISCV_FORMAL
        SOURCES ${PROJECT_SOURCE_DIR}/test_top.v
                ${SERV_SOURCES}
        )
target_compile_features(${PROJECT_NAME}_sim PRIVATE cxx_std_14)
