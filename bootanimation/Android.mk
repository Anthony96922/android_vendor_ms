#
# Copyright (C) 2016 The CyanogenMod Project
#               2017-2024 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

TARGET_GENERATED_BOOTANIMATION := $(TARGET_OUT_INTERMEDIATES)/BOOTANIMATION/bootanimation.zip
$(TARGET_GENERATED_BOOTANIMATION): INTERMEDIATES := $(call intermediates-dir-for,BOOTANIMATION,bootanimation)
$(TARGET_GENERATED_BOOTANIMATION): $(SOONG_ZIP)
	@echo "Building Binbows bootanimation.zip"
	@rm -rf $(dir $@)
	@mkdir -p $(INTERMEDIATES)
	$(hide) tar xfp vendor/ms/bootanimation/bootanimation.tar -C $(INTERMEDIATES)
	$(hide) if [ $(TARGET_SCREEN_WIDTH) -gt $(TARGET_SCREEN_HEIGHT) ]; then \
	    IMAGEHEIGHT=$(TARGET_SCREEN_HEIGHT); \
	    IMAGEWIDTH=$$(expr 640 \* $(TARGET_SCREEN_HEIGHT) / 480); \
        else \
	    IMAGEHEIGHT=$$(expr 480 \* $(TARGET_SCREEN_WIDTH) / 640); \
	    IMAGEWIDTH=$(TARGET_SCREEN_WIDTH); \
	fi; \
	if [ "$(TARGET_BOOTANIMATION_HALF_RES)" = "true" ]; then \
	    IMAGEWIDTH=$$(expr $$IMAGEWIDTH / 2); \
	    IMAGEHEIGHT=$$(expr $$IMAGEHEIGHT / 2); \
	fi; \
	RESOLUTION="$$IMAGEWIDTH"x"$$IMAGEHEIGHT"; \
	prebuilts/tools-lineage/${HOST_OS}-x86/bin/mogrify -resize $$RESOLUTION -colors 256 $(INTERMEDIATES)/*/*.png; \
	echo "$$IMAGEWIDTH $$IMAGEHEIGHT 60" > $(INTERMEDIATES)/desc.txt; \
	cat vendor/ms/bootanimation/desc.txt >> $(INTERMEDIATES)/desc.txt
	$(hide) $(SOONG_ZIP) -L 0 -o $@ -C $(INTERMEDIATES) -D $(INTERMEDIATES)

ifeq ($(TARGET_BOOTANIMATION),)
    TARGET_BOOTANIMATION := $(TARGET_GENERATED_BOOTANIMATION)
endif

include $(CLEAR_VARS)
LOCAL_MODULE := bootanimation.zip
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_PRODUCT)/media

include $(BUILD_SYSTEM)/base_rules.mk

$(LOCAL_BUILT_MODULE): $(TARGET_BOOTANIMATION)
	@cp $(TARGET_BOOTANIMATION) $@

include $(CLEAR_VARS)

BOOTANIMATION_SYMLINK := $(TARGET_OUT_PRODUCT)/media/bootanimation-dark.zip
$(BOOTANIMATION_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@mkdir -p $(dir $@)
	$(hide) ln -sf bootanimation.zip $@

ALL_DEFAULT_INSTALLED_MODULES += $(BOOTANIMATION_SYMLINK)
