# Laser Cutter Belt Schedule

All timing belts in the current model are **GT2 (2 mm pitch), 6 mm wide**.
The main X and Y belts are open-ended belts clamped to their moving assemblies;
the model renders them as loops only because the belt visualizer does not model
open ends. Only the two motor-reduction belts are closed loops.

## Required belts

| Qty. | Location | Pulley pairing | Calculated pitch length | Recommended belt | Teeth | Notes |
|---:|---|---|---:|---:|---:|---|
| 1 | Main X-axis drive | Open belt routed around the X endpoints | About 1710 mm routed | **Cut approximately 1810 mm** | N/A | Includes about 100 mm total allowance for clamping, trimming, and installation. |
| 2 | Left and right Y-axis drives | Open belts routed around the Y endpoints | About 949 mm routed each | **Cut approximately 1050 mm each** | N/A | Includes about 100 mm allowance per belt. Cut both from the same stock and keep their usable lengths equal. |
| 1 | X-axis motor reduction | 60T to 16T | 158.00 mm at minimum tension | **158 mm** | 79 | Uses `x_motor_min_x = 38.21`; 4 mm of slot travel remains available toward +X, providing about 7.5 mm of belt-length adjustment. |
| 1 | Y-axis motor reduction | 60T to 20T | 200.00 mm | **200 mm** | 100 | Uses `y_motor_z_adjustment = 11.43` to match the stocked belt. |

## Purchase summary

- **Approximately 4 m of open-ended GT2-6 belting** for the main X and both Y axes
  - X initial cut: approximately 1810 mm
  - Y initial cuts: approximately 1050 mm each
- **1 × GT2-6, 158 mm closed loop**
- **1 × GT2-6, 200 mm closed loop**

The three open-belt cuts total approximately 3910 mm, so **4 m is the practical
minimum purchase**. Buying 5 m provides useful spare material.

## Adjustment ranges and cautions

### X-axis motor reduction

The modeled 60T-to-16T drive now starts at approximately **158.00 mm** with the
motor at `x_motor_min_x = 38.21`. The four motor slots and center-boss opening
extend 8 mm only toward +X, preserving the complete adjustment range for
tensioning and future belt stretch.

### Main X- and Y-axis open belts

The 1710 mm and 949 mm figures are modeled routed-path estimates, not closed-loop
purchase sizes. Do not cut open belting exactly to those values. The recommended
cuts add approximately 100 mm for the two clamped ends, final tensioning, and
trimming. Confirm the clamp insertion depth before making the final cuts.

### Main Y-axis belts

At the current `y_idler_tension = 7.5` setting, the calculated pitch length is
about 949 mm. Start with approximately 1050 mm per side, install both belts with
matching clamp engagement, then trim them after alignment. Always adjust the
left and right tensioners evenly.

### Y-axis motor reduction

The Y motor is raised 11.43 mm from its former position, reducing the pulley
center distance to approximately 58.61 mm. This matches the stocked **200 mm /
100-tooth** closed-loop belt while retaining the motor-height adjustment for
fine tensioning.

## Calculation basis

For equal-size pulley pairs, pitch length is:

`L = 2C + 2πR`

For unequal pulley pairs, the schedule uses the open-belt pitch geometry based
on pulley pitch radii and shaft-center distance. Pulley pitch diameter is:

`D = teeth × 2 mm / π`

Recheck this schedule if pulley tooth counts, shaft centers, idler positions,
or the modeled tensioning ranges change.
