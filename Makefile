# === Toolchain ===
CC       := arm-none-eabi-gcc
OBJCOPY  := arm-none-eabi-objcopy

# === Flags ===
CPUFLAGS := -mcpu=cortex-r5 -mthumb -mfpu=vfpv3-d16 -mfloat-abi=hard

CFLAGS   := $(CPUFLAGS) \
            -O0 -g3 -Wall -ffreestanding -nostartfiles \
            -Isource -Iinclude

LDFLAGS  := $(CPUFLAGS) -T source/HL_sys_link.ld -Wl,--gc-sections,-Map=build/output.map,--entry=_c_int00

# === Files ===
SRC_DIR   := source
BUILD_DIR := build

C_SRC     := $(filter-out $(SRC_DIR)/HL_sys_main.c, $(wildcard $(SRC_DIR)/*.c)) main.c
S_SRC     := $(wildcard $(SRC_DIR)/*.s)

C_OBJ     := $(patsubst %.c, $(BUILD_DIR)/%.o, $(notdir $(C_SRC)))
S_OBJ     := $(patsubst %.s, $(BUILD_DIR)/%.o, $(notdir $(S_SRC)))

TARGET_ELF := $(BUILD_DIR)/output.elf
TARGET_BIN := $(BUILD_DIR)/output.bin

# === Build Rules ===
all: $(TARGET_ELF)

$(TARGET_ELF): $(C_OBJ) $(S_OBJ)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ -lm

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/main.o: main.c
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -c $< -o $@

bin: $(TARGET_ELF)
	$(OBJCOPY) -O binary $(TARGET_ELF) $(TARGET_BIN)

clean:
	rm -rf $(BUILD_DIR)

flash: $(TARGET_ELF)
	openocd -f interface/stlink.cfg -f target/stellaris.cfg \
		-c "program $(TARGET_ELF) verify reset exit"
