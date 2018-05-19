/*
 *  linux/drivers/devfreq/governor_microfreq.c
 *
 *  Copyright (C) 2018 Draco
 *	Tyler Nijmeh <tylernij@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 */

#include <linux/devfreq.h>
#include <linux/module.h>
#include <linux/input.h>
#include <linux/slab.h>
#include <linux/jiffies.h>
#include "governor.h"

#define RAMP_MULTIPLIER		80
#define DERAMP_MULTIPLIER	20

static bool gpu_boost_pending = false;

static __always_inline void mf_input_event(struct input_handle *handle,
		unsigned int type,
		unsigned int code, int value)
{
	if ((type == EV_SYN || type == EV_ABS || type == EV_KEY) && (code == SYN_REPORT || code == SYN_MT_REPORT)) {
		gpu_boost_pending = true;
	}
}

static int mf_input_connect(struct input_handler *handler,
		struct input_dev *dev, const struct input_device_id *id)
{
	struct input_handle *handle;
	int error;

	handle = kzalloc(sizeof(struct input_handle), GFP_KERNEL);
	if (!handle)
		return -ENOMEM;

	handle->dev = dev;
	handle->handler = handler;
	handle->name = "cpufreq";

	error = input_register_handle(handle);
	if (error)
		goto err2;

	error = input_open_device(handle);
	if (error)
		goto err1;

	return 0;
err1:
	input_unregister_handle(handle);
err2:
	kfree(handle);
	return error;
}

static __always_inline void mf_input_disconnect(struct input_handle *handle)
{
	input_close_device(handle);
	input_unregister_handle(handle);
	kfree(handle);
}

static const struct input_device_id mf_ids[] = {
	/* multi-touch touchscreen */
	{
		.flags = INPUT_DEVICE_ID_MATCH_EVBIT |
			INPUT_DEVICE_ID_MATCH_ABSBIT,
		.evbit = { BIT_MASK(EV_ABS) },
		.absbit = { [BIT_WORD(ABS_MT_POSITION_X)] =
			BIT_MASK(ABS_MT_POSITION_X) |
			BIT_MASK(ABS_MT_POSITION_Y) },
	},
	/* touchpad */
	{
		.flags = INPUT_DEVICE_ID_MATCH_KEYBIT |
			INPUT_DEVICE_ID_MATCH_ABSBIT,
		.keybit = { [BIT_WORD(BTN_TOUCH)] = BIT_MASK(BTN_TOUCH) },
		.absbit = { [BIT_WORD(ABS_X)] =
			BIT_MASK(ABS_X) | BIT_MASK(ABS_Y) },
	},
	/* Keypad */
	{
		.flags = INPUT_DEVICE_ID_MATCH_EVBIT,
		.evbit = { BIT_MASK(EV_KEY) },
	},
	{ },
};

static struct input_handler mf_input_handler = {
	.event		= mf_input_event,
	.connect	= mf_input_connect,
	.disconnect	= mf_input_disconnect,
	.name		= "microfreq",
	.id_table	= mf_ids,
};

static int devfreq_microfreq_func(struct devfreq *df,
				    unsigned long *freq,
				u32 *flag)
{
	struct devfreq_dev_status stat;
	int result = df->profile->get_dev_status(df->dev.parent, &stat);
	unsigned long long a, b;

	/* keeps stats.private_data == NULL   */
	if (result) {
		return result;
	}

	/* Prevent overflow */
	if (stat.busy_time >= (1 << 24) || stat.total_time >= (1 << 24)) {
		stat.busy_time >>= 7;
		stat.total_time >>= 7;
	}

	/* Set the desired frequency based on the load */
	a = stat.busy_time;
	a *= stat.current_frequency;
	b = div_u64(a, stat.total_time);
	b *= 100;
	/* If input, ramp */
	if (gpu_boost_pending) {	
		gpu_boost_pending = false;
		b = div_u64(b, (RAMP_MULTIPLIER - DERAMP_MULTIPLIER / 3));
	} else {
		b = div_u64(b, (RAMP_MULTIPLIER - DERAMP_MULTIPLIER / 2));
	}
	*freq = (unsigned long) b;

	if (df->min_freq && *freq < df->min_freq)
		*freq = df->min_freq;
	if (df->max_freq && *freq > df->max_freq)
		*freq = df->max_freq;

	return 0;
}

static int devfreq_microfreq_handler(struct devfreq *devfreq,
				unsigned int event, void *data)
{
	int ret = 0;
	unsigned long freq;

	mutex_lock(&devfreq->lock);
	freq = devfreq->previous_freq;
	switch (event) {
		case DEVFREQ_GOV_START:
			devfreq->profile->target(devfreq->dev.parent,
					&freq,
					DEVFREQ_FLAG_WAKEUP_MAXFREQ);
		case DEVFREQ_GOV_RESUME:
			ret = update_devfreq(devfreq);
			break;
		case DEVFREQ_GOV_SUSPEND:
			devfreq->profile->target(devfreq->dev.parent,
					&freq,
					DEVFREQ_FLAG_WAKEUP_MAXFREQ);
			break;
	}
	mutex_unlock(&devfreq->lock);
	return ret;
}

static struct devfreq_governor devfreq_microfreq = {
	.name = "microfreq",
	.get_target_freq = devfreq_microfreq_func,
	.event_handler = devfreq_microfreq_handler,
};

static __always_inline int __init devfreq_microfreq_init(void)
{
	input_register_handler(&mf_input_handler);

	return devfreq_add_governor(&devfreq_microfreq);
}
subsys_initcall(devfreq_microfreq_init);

static __always_inline void __exit devfreq_microfreq_exit(void)
{
	int ret;

	input_unregister_handler(&mf_input_handler);

	ret = devfreq_remove_governor(&devfreq_microfreq);
	if (ret)
		pr_err("%s: failed remove governor %d\n", __func__, ret);

	return;
}
module_exit(devfreq_microfreq_exit);

MODULE_AUTHOR("Draco");
MODULE_LICENSE("GPLv2");
