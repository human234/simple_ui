#ifndef HMI_GAUGE_H
#define HMI_GAUGE_H

#include <lvgl.h>
#include <stdint.h>

#define HMI_MAX_GAUGES 8

extern uint32_t colorscheme[];

lv_obj_t *hmi_ui_gauge_create(lv_obj_t *parent, int size, const char *title, const char *unit);
void hmi_ui_widget_set_pos(lv_obj_t *widget, int x, int y);
void hmi_ui_gauge_set_range(lv_obj_t *gauge, int32_t min, int32_t max);
void hmi_ui_gauge_bind_value(lv_obj_t *gauge, float *value);
void hmi_gauge_show_ui(lv_obj_t *parent);

#endif /* HMI_GAUGE_H */