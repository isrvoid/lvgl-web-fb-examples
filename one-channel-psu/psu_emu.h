#pragma once

#include <stdbool.h>

// call periodically to update the fake acquisition
void psu_emu_step(void);
float psu_emu_load(void);
int psu_set_emu_load(float);

bool psu_is_output_on(void);
void psu_set_output(bool);

// fetch returns last acquisition value and doesn't trigger a new measurement
float psu_fetch_voltage(void);
float psu_fetch_current(void);
bool psu_is_cv_mode(void);

float psu_target_voltage(void);
int psu_set_voltage(float);

float psu_max_current(void);
int psu_set_max_current(float);

void psu_set_fuse(bool);
bool psu_is_fuse_on(void);
bool psu_is_fuse_tripped(void);
void psu_clear_fuse_tripped(void);
