/*
 * debugfs file to track time spent in suspend
 *
 * Copyright (c) 2011, Google, Inc.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 */

#include <linux/debugfs.h>
#include <linux/err.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/seq_file.h>
#include <linux/time.h>
#include <linux/suspend.h>

static struct timespec before;
static unsigned int time_in_suspend_bins[32];

#ifdef CONFIG_DEBUG_FS
static int suspend_time_debug_show(struct seq_file *s, void *data)
{
	int bin;
	seq_printf(s, "time (secs)  count\n");
	seq_printf(s, "------------------\n");
	for (bin = 0; bin < 32; bin++) {
		if (time_in_suspend_bins[bin] == 0)
			continue;
		seq_printf(s, "%4d - %4d %4u\n",
			bin ? 1 << (bin - 1) : 0, 1 << bin,
				time_in_suspend_bins[bin]);
	}
	return 0;
}

static int suspend_time_debug_open(struct inode *inode, struct file *file)
{
	return single_open(file, suspend_time_debug_show, NULL);
}

static const struct file_operations suspend_time_debug_fops = {
	.open		= suspend_time_debug_open,
	.read		= seq_read,
	.llseek		= seq_lseek,
	.release	= single_release,
};

static int __init suspend_time_debug_init(void)
{
	struct dentry *d;

	d = debugfs_create_file("suspend_time", 0755, NULL, NULL,
		&suspend_time_debug_fops);
	if (!d) {
		pr_err("Failed to create suspend_time debug file\n");
		return -ENOMEM;
	}

	return 0;
}

late_initcall(suspend_time_debug_init);
#endif

/* FIXME: should be declared in include/linux/timekeeping.h */
extern ktime_t ktime_get_update_offsets_tick(ktime_t *offs_real,
						ktime_t *offs_boot,
						ktime_t *offs_tai);

static int suspend_time_pm_event(struct notifier_block *notifier,
				unsigned long pm_event, void *unused)
{
	struct timespec after;
	ktime_t mono, real, boot, tail;

	switch (pm_event) {
	case PM_SUSPEND_PREPARE:
		mono = ktime_get_update_offsets_tick(&real, &boot, &tail);
		before = ktime_to_timespec(boot);
		break;
	case PM_POST_SUSPEND:
		mono = ktime_get_update_offsets_tick(&real, &boot, &tail);
		after = timespec_sub(ktime_to_timespec(boot), before);
		time_in_suspend_bins[fls(after.tv_sec)]++;
		pr_info("Suspended for %lu.%03lu seconds\n",
				after.tv_sec, after.tv_nsec / NSEC_PER_MSEC);
		break;
	default:
		break;
	}
	return NOTIFY_DONE;
}

static struct notifier_block suspend_time_pm_notifier_block = {
	.notifier_call = suspend_time_pm_event,
};

static int suspend_time_init(void)
{
	register_pm_notifier(&suspend_time_pm_notifier_block);
	return 0;
}

static void suspend_time_exit(void)
{
	unregister_pm_notifier(&suspend_time_pm_notifier_block);
}
module_init(suspend_time_init);
module_exit(suspend_time_exit);
