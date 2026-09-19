/*
 * SPDX-License-Identifier: Apache-2.0
 *
 * Gauge demo using the HMI library. The module provides the display
 * lifecycle (hmi_init/hmi_show) and the gauge widgets; this app only
 * wires them together.
 */

#include <lvgl.h>

#include <hmi/hmi.h>

int main(void)
{
    if (hmi_init() < 0) {
        return 0;
    }

    hmi_gauge_show_ui(lv_screen_active());
    hmi_show();

    return 0;   /* unreachable: hmi_show() loops forever */
}