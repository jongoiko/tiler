RGBASM := rgbasm
RGBFIX := rgbfix
RGBLINK := rgblink

ASM_FLAGS := -l
FIX_FLAGS := -v -p 0

NAME := tiler.gb

SRC_DIR := src
BUILD_DIR := build
INC_DIR := $(SRC_DIR)/include

FINAL_TARGET := $(BUILD_DIR)/$(NAME)

SRC_FILES := $(wildcard $(SRC_DIR)/*.asm)

OBJECTS_INPUT := $(SRC_FILES:.asm=.o)
OBJECTS_OUTPUT := $(addprefix $(BUILD_DIR)/, $(notdir $(SRC_FILES:%.asm=%.o)))

all: $(BUILD_DIR) $(FINAL_TARGET)

$(BUILD_DIR):
	mkdir -p $@

$(FINAL_TARGET): $(OBJECTS_INPUT)
	@$(RGBLINK) $(LINK_FLAGS) -o $@ $(OBJECTS_OUTPUT)
	@$(RGBFIX) $(FIX_FLAGS) $(FINAL_TARGET)

%.o: %.asm
	$(RGBASM) $(ASM_FLAGS) -I $(INC_DIR) $< -o $(BUILD_DIR)/$(notdir $@)
 
.PHONY: clean, all
clean:
	$(RM) -rf $(BUILD_DIR)
