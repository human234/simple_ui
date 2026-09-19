# HMI

Zephyr module providing gauge-style HMI widgets and the display lifecycle
(`hmi_init` / `hmi_show`) on top of LVGL as a reusable library.

## Layout

```
zephyr/module.yml        module declaration (name: hmi)
CMakeLists.txt           zephyr_library_named(hmi)
Kconfig                  CONFIG_HMI gate + required LVGL selects
include/hmi/             public headers (single entry point: <hmi/hmi.h>)
src/                     library sources
samples/gauge_demo/      runnable example app (nucleo_g474re + ILI9488)
```

## Public API

```c
#include <hmi/hmi.h>

int hmi_init(void);                 /* 0 / negative; display ready check */
void hmi_show(void);                /* blanking off + LVGL timer loop, never returns */

lv_obj_t *hmi_ui_gauge_create(lv_obj_t *parent, int size,
                              const char *title, const char *unit);
void hmi_ui_widget_set_pos(lv_obj_t *widget, int x, int y);
void hmi_ui_gauge_set_range(lv_obj_t *gauge, int32_t min, int32_t max);
void hmi_ui_gauge_bind_value(lv_obj_t *gauge, float *value);
void hmi_gauge_show_ui(lv_obj_t *parent);
extern uint32_t colorscheme[];
```

## Consuming the module

1. Make the module visible to your build:

   `apps/HMI` in this workspace. From any app add this **before**
   `find_package(Zephyr REQUIRED)`:

   ```cmake
   set(ZEPHYR_EXTRA_MODULES <path-to-apps/HMI>)
   ```

   or pass it on the command line:

   ```sh
   west build -b nucleo_g474re <app> -- -DZEPHYR_EXTRA_MODULES=<path-to-apps/HMI>
   ```

   (A west manifest project is the alternative once this is a git repo.)

2. Enable it in your `prj.conf`:

   ```ini
   CONFIG_HMI=y
   ```

   `CONFIG_HMI` selects the LVGL widgets, fonts, and LVGL itself. You still
   own the display-specific settings (e.g. `CONFIG_LV_COLOR_DEPTH_24`,
   `CONFIG_LV_Z_MEM_POOL_SIZE`, `CONFIG_LV_Z_VDB_SIZE`) and a `zephyr,display`
   chosen node; the module reads it out of your devicetree.

3. Use it:

   ```c
   #include <hmi/hmi.h>

   int main(void)
   {
       if (hmi_init() < 0) {
           return 0;
       }
       hmi_gauge_show_ui(lv_screen_active());
       hmi_show();
       return 0;   /* unreachable */
   }
   ```

## Build the bundled sample

```sh
west build -p always -b nucleo_g474re samples/gauge_demo
west flash -d build
```

## Notes

- Requires the LVGL module in the workspace (its Kconfig symbols are
  `select`ed by `CONFIG_HMI`).
- CPU-load / LVGL perf overlay is intentionally NOT selected by the module.
  If you enable `CONFIG_LV_USE_SYSMON`, also set
  `CONFIG_CPU_LOAD_BACKEND_RUNTIME_STATS=y` — the default idle-hook backend
  caused a boot-time fault on this board.