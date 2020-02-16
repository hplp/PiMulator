/*
 * Blockjob tests
 *
 * Copyright Igalia, S.L. 2016
 *
 * Authors:
 *  Alberto Garcia   <berto@igalia.com>
 *
 * This work is licensed under the terms of the GNU LGPL, version 2 or later.
 * See the COPYING.LIB file in the top-level directory.
 */

#include "qemu/osdep.h"
#include "qapi/error.h"
#include "qemu/main-loop.h"
#include "block/blockjob_int.h"
#include "sysemu/block-backend.h"

static const BlockJobDriver test_block_job_driver = {
    .instance_size = sizeof(BlockJob),
};

static void block_job_cb(void *opaque, int ret)
{
}

static BlockJob *mk_job(BlockBackend *blk, const char *id,
                        const BlockJobDriver *drv, bool should_succeed,
                        int flags)
{
    BlockJob *job;
    Error *errp = NULL;

    job = block_job_create(id, drv, NULL, blk_bs(blk),
                           0, BLK_PERM_ALL, 0, flags, block_job_cb,
                           NULL, &errp);
    if (should_succeed) {
        g_assert_null(errp);
        g_assert_nonnull(job);
        if (id) {
            g_assert_cmpstr(job->id, ==, id);
        } else {
            g_assert_cmpstr(job->id, ==, blk_name(blk));
        }
    } else {
        g_assert_nonnull(errp);
        g_assert_null(job);
        error_free(errp);
    }

    return job;
}

static BlockJob *do_test_id(BlockBackend *blk, const char *id,
                            bool should_succeed)
{
    return mk_job(blk, id, &test_block_job_driver,
                  should_succeed, BLOCK_JOB_DEFAULT);
}

/* This creates a BlockBackend (optionally with a name) with a
 * BlockDriverState inserted. */
static BlockBackend *create_blk(const char *name)
{
    /* No I/O is performed on this device */
    BlockBackend *blk = blk_new(0, BLK_PERM_ALL);
    BlockDriverState *bs;

    bs = bdrv_open("null-co://", NULL, NULL, 0, &error_abort);
    g_assert_nonnull(bs);

    blk_insert_bs(blk, bs, &error_abort);
    bdrv_unref(bs);

    if (name) {
        Error *errp = NULL;
        monitor_add_blk(blk, name, &errp);
        g_assert_null(errp);
    }

    return blk;
}

/* This destroys the backend */
static void destroy_blk(BlockBackend *blk)
{
    if (blk_name(blk)[0] != '\0') {
        monitor_remove_blk(blk);
    }

    blk_remove_bs(blk);
    blk_unref(blk);
}

static void test_job_ids(void)
{
    BlockBackend *blk[3];
    BlockJob *job[3];

    blk[0] = create_blk(NULL);
    blk[1] = create_blk("drive1");
    blk[2] = create_blk("drive2");

    /* No job ID provided and the block backend has no name */
    job[0] = do_test_id(blk[0], NULL, false);

    /* These are all invalid job IDs */
    job[0] = do_test_id(blk[0], "0id", false);
    job[0] = do_test_id(blk[0], "",    false);
    job[0] = do_test_id(blk[0], "   ", false);
    job[0] = do_test_id(blk[0], "123", false);
    job[0] = do_test_id(blk[0], "_id", false);
    job[0] = do_test_id(blk[0], "-id", false);
    job[0] = do_test_id(blk[0], ".id", false);
    job[0] = do_test_id(blk[0], "#id", false);

    /* This one is valid */
    job[0] = do_test_id(blk[0], "id0", true);

    /* We cannot have two jobs in the same BDS */
    do_test_id(blk[0], "id1", false);

    /* Duplicate job IDs are not allowed */
    job[1] = do_test_id(blk[1], "id0", false);

    /* But once job[0] finishes we can reuse its ID */
    block_job_early_fail(job[0]);
    job[1] = do_test_id(blk[1], "id0", true);

    /* No job ID specified, defaults to the backend name ('drive1') */
    block_job_early_fail(job[1]);
    job[1] = do_test_id(blk[1], NULL, true);

    /* Duplicate job ID */
    job[2] = do_test_id(blk[2], "drive1", false);

    /* The ID of job[2] would default to 'drive2' but it is already in use */
    job[0] = do_test_id(blk[0], "drive2", true);
    job[2] = do_test_id(blk[2], NULL, false);

    /* This one is valid */
    job[2] = do_test_id(blk[2], "id_2", true);

    block_job_early_fail(job[0]);
    block_job_early_fail(job[1]);
    block_job_early_fail(job[2]);

    destroy_blk(blk[0]);
    destroy_blk(blk[1]);
    destroy_blk(blk[2]);
}

typedef struct CancelJob {
    BlockJob common;
    BlockBackend *blk;
    bool should_converge;
    bool should_complete;
    bool completed;
} CancelJob;

static void cancel_job_completed(BlockJob *job, void *opaque)
{
    CancelJob *s = opaque;
    s->completed = true;
    block_job_completed(job, 0);
}

static void cancel_job_complete(BlockJob *job, Error **errp)
{
    CancelJob *s = container_of(job, CancelJob, common);
    s->should_complete = true;
}

static void coroutine_fn cancel_job_start(void *opaque)
{
    CancelJob *s = opaque;

    while (!s->should_complete) {
        if (block_job_is_cancelled(&s->common)) {
            goto defer;
        }

        if (!s->common.ready && s->should_converge) {
            block_job_event_ready(&s->common);
        }

        block_job_sleep_ns(&s->common, 100000);
    }

 defer:
    block_job_defer_to_main_loop(&s->common, cancel_job_completed, s);
}

static const BlockJobDriver test_cancel_driver = {
    .instance_size = sizeof(CancelJob),
    .start         = cancel_job_start,
    .complete      = cancel_job_complete,
};

static CancelJob *create_common(BlockJob **pjob)
{
    BlockBackend *blk;
    BlockJob *job;
    CancelJob *s;

    blk = create_blk(NULL);
    job = mk_job(blk, "Steve", &test_cancel_driver, true,
                 BLOCK_JOB_MANUAL_FINALIZE | BLOCK_JOB_MANUAL_DISMISS);
    block_job_ref(job);
    assert(job->status == BLOCK_JOB_STATUS_CREATED);
    s = container_of(job, CancelJob, common);
    s->blk = blk;

    *pjob = job;
    return s;
}

static void cancel_common(CancelJob *s)
{
    BlockJob *job = &s->common;
    BlockBackend *blk = s->blk;
    BlockJobStatus sts = job->status;

    block_job_cancel_sync(job);
    if ((sts != BLOCK_JOB_STATUS_CREATED) &&
        (sts != BLOCK_JOB_STATUS_CONCLUDED)) {
        BlockJob *dummy = job;
        block_job_dismiss(&dummy, &error_abort);
    }
    assert(job->status == BLOCK_JOB_STATUS_NULL);
    block_job_unref(job);
    destroy_blk(blk);
}

static void test_cancel_created(void)
{
    BlockJob *job;
    CancelJob *s;

    s = create_common(&job);
    cancel_common(s);
}

static void test_cancel_running(void)
{
    BlockJob *job;
    CancelJob *s;

    s = create_common(&job);

    block_job_start(job);
    assert(job->status == BLOCK_JOB_STATUS_RUNNING);

    cancel_common(s);
}

static void test_cancel_paused(void)
{
    BlockJob *job;
    CancelJob *s;

    s = create_common(&job);

    block_job_start(job);
    assert(job->status == BLOCK_JOB_STATUS_RUNNING);

    block_job_user_pause(job, &error_abort);
    block_job_enter(job);
    assert(job->status == BLOCK_JOB_STATUS_PAUSED);

    cancel_common(s);
}

static void test_cancel_ready(void)
{
    BlockJob *job;
    CancelJob *s;

    s = create_common(&job);

    block_job_start(job);
    assert(job->status == BLOCK_JOB_STATUS_RUNNING);

    s->should_converge = true;
    block_job_enter(job);
    assert(job->status == BLOCK_JOB_STATUS_READY);

    cancel_common(s);
}

static void test_cancel_standby(void)
{
    BlockJob *job;
    CancelJob *s;

    s = create_common(&job);

    block_job_start(job);
    assert(job->status == BLOCK_JOB_STATUS_RUNNING);

    s->should_converge = true;
    block_job_enter(job);
    assert(job->status == BLOCK_JOB_STATUS_READY);

    block_job_user_pause(job, &error_abort);
    block_job_enter(job);
    assert(job->status == BLOCK_JOB_STATUS_STANDBY);

    cancel_common(s);
}

static void test_cancel_pending(void)
{
    BlockJob *job;
    CancelJob *s;

    s = create_common(&job);

    block_job_start(job);
    assert(job->status == BLOCK_JOB_STATUS_RUNNING);

    s->should_converge = true;
    block_job_enter(job);
    assert(job->status == BLOCK_JOB_STATUS_READY);

    block_job_complete(job, &error_abort);
    block_job_enter(job);
    while (!s->completed) {
        aio_poll(qemu_get_aio_context(), true);
    }
    assert(job->status == BLOCK_JOB_STATUS_PENDING);

    cancel_common(s);
}

static void test_cancel_concluded(void)
{
    BlockJob *job;
    CancelJob *s;

    s = create_common(&job);

    block_job_start(job);
    assert(job->status == BLOCK_JOB_STATUS_RUNNING);

    s->should_converge = true;
    block_job_enter(job);
    assert(job->status == BLOCK_JOB_STATUS_READY);

    block_job_complete(job, &error_abort);
    block_job_enter(job);
    while (!s->completed) {
        aio_poll(qemu_get_aio_context(), true);
    }
    assert(job->status == BLOCK_JOB_STATUS_PENDING);

    block_job_finalize(job, &error_abort);
    assert(job->status == BLOCK_JOB_STATUS_CONCLUDED);

    cancel_common(s);
}

int main(int argc, char **argv)
{
    qemu_init_main_loop(&error_abort);
    bdrv_init();

    g_test_init(&argc, &argv, NULL);
    g_test_add_func("/blockjob/ids", test_job_ids);
    g_test_add_func("/blockjob/cancel/created", test_cancel_created);
    g_test_add_func("/blockjob/cancel/running", test_cancel_running);
    g_test_add_func("/blockjob/cancel/paused", test_cancel_paused);
    g_test_add_func("/blockjob/cancel/ready", test_cancel_ready);
    g_test_add_func("/blockjob/cancel/standby", test_cancel_standby);
    g_test_add_func("/blockjob/cancel/pending", test_cancel_pending);
    g_test_add_func("/blockjob/cancel/concluded", test_cancel_concluded);
    return g_test_run();
}
