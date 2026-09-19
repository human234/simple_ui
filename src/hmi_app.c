#include <errno.h>
#include <zephyr/device.h>
#include <zephyr/devicetree.h>
#include <zephyr/drivers/display.h>
#include <zephyr/kernel.h>
#include <zephyr/logging/log.h>
#include <lvgl.h>

#include <hmi/hmi_app.h>

LOG_MODULE_REGISTER(hmi_app, LOG_LEVEL_INF);

static const struct device *display_dev = DEVICE_DT_GET(DT_CHOSEN(zephyr_display));

int hmi_init(void)
{
    if (!device_is_ready(display_dev)) {
        LOG_ERR("display device not ready");
        return -1;
    }
    LOG_INF("display %s ready", display_dev->name);

    return 0;
}

void hmi_show(void)
{
    int ret;

    ret = display_blanking_off(display_dev);
    if (ret < 0 && ret != -ENOSYS) {
        LOG_ERR("failed to turn blanking off (%d)", ret);
        return;
    }

    while (1) {
        uint32_t next;

        next = lv_timer_handler();
        if (next == LV_NO_TIMER_READY) {
            next = LV_DEF_REFR_PERIOD;
        }
        k_sleep(K_MSEC(next ? next : 1));
    }
}