/**
 * @file lv_conf.h
 * LaneApp LVGL v9.5 configuration
 *
 * Target platforms: Linux ARM (embedded, /dev/fb0) and Linux X86/X64.
 */

#if 1   /* Set this to "1" to enable content */

#ifndef LV_CONF_H
#define LV_CONF_H

#include <stdint.h>

/*====================
   COLOR SETTINGS
 *====================*/

/** Color depth: 1 (1 byte per pixel), 8, 16, 24, or 32 */
#define LV_COLOR_DEPTH 32

/*====================
   MEMORY SETTINGS
 *====================*/

/** 1: Use custom malloc/free; 0: Use the built-in memory pool */
#define LV_MEM_CUSTOM 0
#if LV_MEM_CUSTOM == 0
    /*
     * GIF/video-heavy lanes can fragment the built-in LVGL heap quickly.
     * Keep a larger pool on desktop-class targets, while staying conservative
     * enough for the older ARM deployments that still share this config.
     */
    #if defined(__i386__) || defined(__x86_64__) || defined(__loongarch64__)
        #define LV_MEM_SIZE (64 * 1024 * 1024U)    /* 64 MB */
    #else
        #define LV_MEM_SIZE (32 * 1024 * 1024U)    /* 32 MB */
    #endif
    /** Size of the memory available for `lv_malloc()` in bytes (>=2kB) */
    /** Set an address for the memory pool instead of allocating it as a global array */
    #define LV_MEM_ADR 0
#else
    #include <stdlib.h>
    #define LV_MEM_CUSTOM_INCLUDE
    #define LV_MEM_CUSTOM_ALLOC   malloc
    #define LV_MEM_CUSTOM_FREE    free
    #define LV_MEM_CUSTOM_REALLOC realloc
#endif

/*====================
   HAL SETTINGS
 *====================*/

/** Default display refresh period in [ms] */
#define LV_DISP_DEF_REFR_PERIOD   33

/** Input device read period in [ms] */
#define LV_INDEV_DEF_READ_PERIOD  30

/** Default screen DPI */
#define LV_DPI_DEF 130

/*=================
   OS / THREADING
 *=================*/

/**
 * Select OS: LV_OS_NONE, LV_OS_FREERTOS, LV_OS_CMSIS_RTOS2,
 *            LV_OS_RTTHREAD, LV_OS_PTHREAD, LV_OS_WINDOWS, LV_OS_MQX
 * We use NONE and manage tick/task threads ourselves.
 */
#define LV_USE_OS LV_OS_NONE

/*====================
   RENDERING
 *====================*/

/** Enable the built-in software renderer */
#define LV_USE_DRAW_SW 1

#if LV_USE_DRAW_SW == 1
    /** Enable complex (non-linear) gradient support */
    #define LV_USE_DRAW_SW_COMPLEX_GRADIENTS 0
#endif

/** Disable GPU-accelerated backends not present on our targets */
#define LV_USE_DRAW_VGLITE  0
#define LV_USE_DRAW_PXP     0
#define LV_USE_DRAW_DAVE2D  0
#define LV_USE_GPU_STM32_DMA2D 0

/*====================
   LOGGING
 *====================*/

/** Enable/disable log module */
#define LV_USE_LOG 0

/*====================
   ASSERTIONS
 *====================*/

#define LV_USE_ASSERT_NULL          0
#define LV_USE_ASSERT_MALLOC        0
#define LV_USE_ASSERT_STYLE         0
#define LV_USE_ASSERT_MEM_INTEGRITY 0
#define LV_USE_ASSERT_OBJ           0

/*====================
   FONTS
 *====================*/

/** Montserrat fonts — enable the sizes we use */
#define LV_FONT_MONTSERRAT_12  0
#define LV_FONT_MONTSERRAT_14  1
#define LV_FONT_MONTSERRAT_16  1
#define LV_FONT_MONTSERRAT_20  1
#define LV_FONT_MONTSERRAT_24  0
#define LV_FONT_MONTSERRAT_28  0
#define LV_FONT_MONTSERRAT_36  0
#define LV_FONT_MONTSERRAT_48  0

/** Default font — must be enabled above */
#define LV_FONT_DEFAULT &lv_font_montserrat_14

/*====================
   TEXT
 *====================*/

/** Select a character encoding: LV_TXT_ENC_UTF8 or LV_TXT_ENC_ASCII */
#define LV_TXT_ENC LV_TXT_ENC_UTF8

/** Allowed line-break characters */
#define LV_TXT_BREAK_CHARS " ,.;:-_)]}"

/*====================
   WIDGETS
 *====================*/

#define LV_USE_ARC        1
#define LV_USE_BAR        1
#define LV_USE_BTN        1
#define LV_USE_BTNMATRIX  1
#define LV_USE_CANVAS     1
#define LV_USE_CHECKBOX   1
#define LV_USE_DROPDOWN   1
#define LV_USE_IMAGE      1   /* LVGL v9 image widget (lv_image_create) */
#define LV_USE_IMG        1   /* keep for any remaining v8 compat code */
#define LV_USE_IMGBTN     1
#define LV_USE_KEYBOARD   0
#define LV_USE_LABEL      1
#define LV_USE_LED        1
#define LV_USE_LINE       1
#define LV_USE_LIST       1
#define LV_USE_MENU       0
#define LV_USE_MSGBOX     0
#define LV_USE_ROLLER     0
#define LV_USE_SCALE      0
#define LV_USE_SLIDER     1
#define LV_USE_SPAN       0
#define LV_USE_SPINBOX    0
#define LV_USE_SPINNER    0
#define LV_USE_TABLE      1
#define LV_USE_TABVIEW    0
#define LV_USE_TEXTAREA   1
#define LV_USE_TILEVIEW   0
#define LV_USE_WIN        0

/*====================
   THEMES
 *====================*/

#define LV_USE_THEME_DEFAULT 1
#if LV_USE_THEME_DEFAULT
    #define LV_THEME_DEFAULT_DARK            0
    #define LV_THEME_DEFAULT_GROW            0
    #define LV_THEME_DEFAULT_TRANSITION_TIME 80
#endif

#define LV_USE_THEME_SIMPLE 0
#define LV_USE_THEME_MONO   0

/*====================
   LAYOUTS
 *====================*/

#define LV_USE_FLEX 1
#define LV_USE_GRID 1

/*====================
   THIRD PARTY LIBS
 *====================*/

#define LV_USE_LIBJPEG_TURBO 0   /* Use libjpeg directly in app code instead */
#define LV_USE_LIBPNG        0
#define LV_USE_GSTREAMER     0   /* Choose FFmpeg for video support on our Linux targets */
/*
 * Built-in GIF decoder (no external library needed).
 * Enables lv_gif_create() / lv_gif_set_src() for animated and static GIFs.
 */
#define LV_USE_GIF           1
#if LV_USE_GIF
    #define LV_GIF_CACHE_DECODE_DATA  0
#endif
#define LV_USE_QRCODE        1
#define LV_USE_BARCODE       0
#define LV_USE_RLOTTIE       0
#ifndef LANEAPP_ENABLE_LVGL_FFMPEG
    #define LANEAPP_ENABLE_LVGL_FFMPEG 0
#endif
#define LV_USE_FFMPEG        LANEAPP_ENABLE_LVGL_FFMPEG
#if LV_USE_FFMPEG
    #define LV_FFMPEG_DUMP_FORMAT     0
    #define LV_FFMPEG_PLAYER_USE_LV_FS 1
#endif

/*====================
   FREETYPE FONT
 *====================*/

/*
 * FreeType TTF font rendering.
 * Requires libfreetype-dev headers and -lfreetype at link time.
 * Enables lv_freetype_font_create() for loading .ttf/.otf fonts at runtime.
 */
#define LV_USE_FREETYPE  1
#if LV_USE_FREETYPE
    /* Maximum number of glyphs to cache across all fonts */
    #define LV_FREETYPE_CACHE_FT_GLYPH_CNT  256
#endif

/*====================
   FILESYSTEM DRIVERS
 *====================*/

/*
 * POSIX filesystem driver — maps drive letter 'A' to the native filesystem.
 * Required for lv_gif_set_src("A:./res/button/RSU.gif") and similar file
 * paths used by the GIF image widget.
 */
#define LV_USE_FS_POSIX  1
#if LV_USE_FS_POSIX
    #define LV_FS_POSIX_LETTER      'A'
    #define LV_FS_POSIX_PATH        ""   /* empty: use path as-is from CWD */
    #define LV_FS_POSIX_CACHE_SIZE  0
#endif

/*====================
   LINUX DRIVERS
 *====================*/

#define LV_USE_LINUX_FBDEV 1
#if LV_USE_LINUX_FBDEV
    #define LV_LINUX_FBDEV_BSD          0
    #define LV_LINUX_FBDEV_RENDER_MODE  LV_DISPLAY_RENDER_MODE_PARTIAL
    #define LV_LINUX_FBDEV_BUFFER_COUNT 2
#endif

#define LV_USE_EVDEV 0

/*====================
   MISC
 *====================*/

#define LV_USE_SNAPSHOT   0
#define LV_USE_SYSMON     0
#define LV_USE_MONKEY     0
#define LV_USE_GRIDNAV    0
#define LV_USE_FRAGMENT   0
#define LV_USE_OBSERVER   0
#define LV_USE_IME_PINYIN 0

#endif /* LV_CONF_H */

#endif /* End of "Content enable" */
