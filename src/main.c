/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * LVGL entry point for the HMI gauge demo. Display setup lives in hmi_app.c,
 * the gauge UI in hmi_gauge.c; here we only wire them together.
 */

#include <lvgl.h>

#include "hmi_app.h"
#include "hmi_gauge.h"

int main(void)
{
    hmi_init();
    hmi_gauge_show_ui(lv_screen_active());
    hmi_show();

    return 0;
}
