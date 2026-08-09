# Laser Cutter

Parametric OpenSCAD models for a buildable, enclosed 50 W CO2 laser cutter. The design is based on an 800 mm × 50 mm tube, 2020/2040 aluminum extrusion, MGN12H linear guides, NEMA 17 motion, and a mechanically synchronized gantry.

The model is a work in progress. Dimensions for purchased optical hardware are currently based on product drawings and visual estimates; they should be replaced with caliper measurements before final fabrication.

## Files

- `laser_cutter.scad` — complete machine assembly and visibility/motion controls
- `laser_parts.scad` — reusable component library
- `laser_custom_parts.scad` — fabrication-only selector for printing/exporting one custom part at a time
- `laser_head_set.scad` — A1/A2/A3/A4 optical hardware preview
- `laser_tube.scad` — 800 mm, 50 W CO2 tube preview
- `aluminum_extrusions.scad` — 2020 and 2040 extrusion previews
- `mgn12_linear_guides.scad` — MGN12 rails and MGN12H carriages
- `stepper_motors.scad` — NEMA 17 motor preview
- `stepper_drivers.scad` — external microstep driver preview
- `laser_power_supply.scad` — 50 W laser power-supply preview
- `air_assist_pump.scad` — Active Aqua AAPA45L air-pump preview
- `water_cooler.scad` — CW-3000 water-cooler preview

## Opening the assembly

Open `laser_cutter.scad` in OpenSCAD and press F5 for a fast preview or F6 for a full render. All dimensions are millimetres.

Useful Customizer controls include:

- enclosure, individual panel, lid, and service-hatch visibility
- lid and access-panel opening angles
- X/Y carriage positions and animated travel
- beam path, belts, drag chains, electronics, and motion-clearance overlays
- leveling-foot adjustment

The coordinate system is X = machine width, Y = front-to-back, and Z = up.

## Exporting printable or fabricated parts

Open `laser_custom_parts.scad`, choose `custom_part`, and set `show_hardware=false`. Render with F6, then use **File → Export → Export as STL**.

Current selectable parts are:

- MGN12H-to-2040 gantry plate
- X-axis NEMA 17 motor mount
- enclosure hinge fixed and moving leaves
- enclosure cam-latch base, lever, and keeper

`part_quantity` and `part_spacing` can arrange multiple copies for inspection or nesting.

## Current mechanical concept

- one 800 mm MGN12H rail for X
- two 400 mm MGN12H rails for Y
- one X-axis NEMA 17 with a closed GT2 belt loop clamped at A4
- one Y-axis motor driving both sides through a cross-shaft to prevent racking
- removable externally mounted enclosure panels
- isolated electronics bay
- framed rear tube pocket and service hatch
- adjustable honeycomb cutting table
- four leveling feet mounted through 2020 corner plates

The planned Z system uses one motor and ANSI #25 roller chain to synchronize all table lead screws. That mechanism is not yet modeled.

## Safety

This repository is a mechanical design aid, not a certified machine plan. A CO2 laser contains lethal high voltage, invisible laser radiation, fire hazards, pressurized cooling plumbing, and hazardous fumes. A real build requires a light-tight enclosure, fail-safe lid interlocks, keyed enable, emergency stop, coolant flow and temperature protection, grounded metalwork, protected wiring, adequate exhaust, supervised operation, and suitable fire protection. Never operate the laser with panels or optical covers removed.

## Next fit-check session

- print the custom plates, hinges, and latch components
- measure the A1/A2/A3/A4 hardware with calipers
- verify MGN12H hole spacing and plate fastener access
- test the complete X belt path and clamp engagement
- sweep X/Y travel for motor, optics, drag-chain, panel, and tube-pocket clearance
- model the chain-synchronized Z lift and rear service bulkheads

