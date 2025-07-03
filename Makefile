# -----------------------------------------------------------------------------
# Project Makefile for TMS570 (ARMv7‑R5) with TI CGT on WSL/Linux
# -----------------------------------------------------------------------------

# --- Toolchain & Architecture ---
TI_BASE   := $(PWD)/ti-cgt-arm_20.2.7.LTS
CC        := $(TI_BASE)/bin/armcl
ARMAS     := $(TI_BASE)/bin/armasm
HEX       := $(TI_BASE)/bin/armhex

# --- Directories ---
SRC_DIR   := source
OBJ_DIR   := build
INC_DIR   := include

# --- Libraries ---
TI_LIB    := $(TI_BASE)/lib
RTS_LIB   := $(TI_LIB)/rtsv7R4_T_be_v3D16_eabi.lib

# --- Source Files ---
C_SRCS    := $(wildcard $(SRC_DIR)/*.c)
ASM_SRCS  := $(wildcard $(SRC_DIR)/*.asm)

# --- Object Files (in build/) ---
C_OBJS    := $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.obj,$(C_SRCS))
ASM_OBJS  := $(patsubst $(SRC_DIR)/%.asm,$(OBJ_DIR)/%.obj,$(ASM_SRCS))
OBJS      := $(C_OBJS) $(ASM_OBJS)
ABS_OBJS  := $(patsubst %,$(abspath %),$(OBJS))

# --- Target Names ---
TARGET    := LED_BLINK
OUT_FILE  := $(OBJ_DIR)/$(TARGET).out
HEX_FILE  := $(OBJ_DIR)/$(TARGET).hex
MAP_FILE  := $(OBJ_DIR)/$(TARGET).map
LINK_CMD  := $(SRC_DIR)/HL_sys_link.cmd

# --- Flags ---
INCLUDES  := -I$(INC_DIR) -I$(SRC_DIR) -i$(TI_BASE)/include -i$(TI_LIB)
CFLAGS    := -mv7R5 --code_state=32 --float_support=VFPv3D16 \
             --enum_type=packed --abi=eabi -g \
             --diag_warning=225 --diag_wrap=off --display_error_number \
             $(INCLUDES)
LFLAGS    := -z --rom_model --be32 \
             --heap_size=0x800 --stack_size=0x800 \
             --warn_sections \
             --xml_link_info=$(OBJ_DIR)/$(TARGET)_linkInfo.xml \
             -m$(MAP_FILE) $(INCLUDES)

.PHONY: all clean

# --- Default build ---
all: $(OBJ_DIR) $(OBJS) $(OUT_FILE) $(HEX_FILE)

# --- Ensure build directory exists ---
$(OBJ_DIR):
	@mkdir -p $(OBJ_DIR)

# --- Compile C sources to OBJECTS ---
$(OBJ_DIR)/%.obj: $(SRC_DIR)/%.c | $(OBJ_DIR)
	@echo "[CC] $< → $@"
	$(CC) $(CFLAGS) --compile_only $< --output_file $@

# ASM sources → .obj (via armcl, not armasm)
$(OBJ_DIR)/%.obj: $(SRC_DIR)/%.asm | $(OBJ_DIR)
	@echo "[AS] $< → $@"
	$(CC) $(CFLAGS) --compile_only $< --output_file $@

# --- Link all OBJECTS + TI RTS into .out ---
$(OUT_FILE): $(ABS_OBJS) $(LINK_CMD)
	@echo "[LINK] $@"
	$(CC) $(CFLAGS) $(LFLAGS) \
	  --output_file $(abspath $@) \
	  $(ABS_OBJS) \
	  $(LINK_CMD) \
	  $(RTS_LIB)

# Generate HEX (use -o, not --output_file)
$(HEX_FILE): $(OUT_FILE)
	@echo "[HEX] $@"
	$(HEX) --diag_wrap=off -o $(abspath $@) $(abspath $<)
# Remove unwanted files
	@rm -f $(notdir $(basename $(HEX_FILE))).x1 \
	       $(notdir $(basename $(HEX_FILE))).x2 \
	       $(notdir $(basename $(HEX_FILE))).x3

# --- Clean everything ---
clean:
	@rm -rf $(OBJ_DIR)
