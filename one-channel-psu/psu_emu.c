#include <assert.h>
#include <math.h>

#include "psu_emu.h"
#include "psu_errno.h"

typedef struct {
    float min, max;
} limits_t;

static struct {
    bool output;
    bool is_cv_mode;
    bool fuse, fuse_tripped;
    float target_voltage, max_current;
    float meas_voltage, meas_current;
    float load;
    const limits_t voltage_limits, current_limits;
    const limits_t load_limits;
} m = { .target_voltage = 1.0, .max_current = 1.0, .load = 100.0,
    .voltage_limits = { 0.0, 32.0 }, .current_limits = { 1e-3, 5.0 }, .load_limits = { 10e-3, 1e6 } };

float rand_norm(void);

static float add_voltage_noise(float v) {
    const float level = 1e-3 + v * 0.5e-3;
    return v + rand_norm() * level;
}

static float add_current_noise(float v) {
    const float level = 50e-6 + v * 100e-6;
    return v + rand_norm() * level;
}

static inline float clamp(float v, limits_t l) {
    return v < l.min ? l.min : v > l.max ? l.max : v;
}

static int check_range(float v, limits_t l) {
    if (!(v >= l.min && v <= l.max)) {
        errno = PSU_ERR_OUT_OF_RANGE;
        return -1;
    }
    return 0;
}

void psu_emu_step(void) {
    if (!m.output)
        return;

    // noise only fakes ADC inaccuracy and is irrelevant for CV/CC mode
    m.is_cv_mode = m.target_voltage <= m.max_current * m.load;
    if (m.is_cv_mode) {
        m.meas_voltage = add_voltage_noise(m.target_voltage);
        m.meas_current = add_current_noise(m.target_voltage / m.load);
    } else {
        m.meas_current = add_current_noise(m.max_current);
        m.meas_voltage = add_voltage_noise(m.max_current * m.load);
    }

    if (m.fuse && m.meas_current > m.max_current) {
        psu_set_output(false);
        m.fuse_tripped = true;
    }
}

float psu_emu_load(void) {
    return m.load;
}

int psu_set_emu_load(float v) {
    m.load = clamp(v, m.load_limits);
    return check_range(v, m.load_limits);
}

bool psu_is_output_on(void) {
    return m.output;
}

void psu_set_output(bool state) {
    m.output = state;
}

float psu_fetch_voltage(void) {
    return m.output ? m.meas_voltage : NAN;
}

float psu_fetch_current(void) {
    return m.output ? m.meas_current : NAN;
}

bool psu_is_cv_mode(void) {
    return m.is_cv_mode;
}

float psu_target_voltage(void) {
    return m.target_voltage;
}

int psu_set_voltage(float v) {
    assert(!isnan(v));
    m.target_voltage = clamp(v, m.voltage_limits);
    return check_range(v, m.voltage_limits);
}

float psu_max_current(void) {
    return m.max_current;
}

int psu_set_max_current(float v) {
    assert(!isnan(v));
    m.max_current = clamp(v, m.current_limits);
    return check_range(v, m.current_limits);
}

void psu_set_fuse(bool state) {
    m.fuse = state;
}

bool psu_is_fuse_on(void) {
    return m.fuse;
}

bool psu_is_fuse_tripped(void) {
    return m.fuse_tripped;
}

void psu_clear_fuse_tripped(void) {
    m.fuse_tripped = false;
}
