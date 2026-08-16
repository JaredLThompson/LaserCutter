#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "$0")" && pwd)"
preview_dir="$project_dir/preview"
mkdir -p "$preview_dir"

if command -v openscad >/dev/null 2>&1; then
    openscad_cmd=(openscad)
elif [[ -x /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD ]]; then
    # The currently installed macOS build is Intel; Rosetta avoids the native
    # architecture crash seen when rendering this assembly.
    openscad_cmd=(arch -x86_64 /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD)
else
    echo "OpenSCAD was not found." >&2
    exit 1
fi

render_preview() {
    local source="$1"
    local output="$2"
    echo "Rendering $output"
    "${openscad_cmd[@]}" \
        --imgsize=1400,900 \
        --viewall \
        --autocenter \
        -o "$preview_dir/$output" \
        "$project_dir/$source"
}

render_preview laser_cutter.scad laser_cutter_preview.png
render_preview laser_head_set.scad laser_head_set_preview.png
render_preview laser_tube.scad laser_tube_preview.png
render_preview aluminum_extrusions.scad aluminum_extrusions_preview.png
render_preview extrusion_profile_preview.scad extrusion_profile_preview.png
render_preview mgn12_linear_guides.scad mgn12_linear_guides_preview.png
render_preview stepper_motors.scad stepper_motors_preview.png
render_preview stepper_drivers.scad stepper_drivers_preview.png
render_preview laser_power_supply.scad laser_power_supply_preview.png
render_preview air_assist_pump.scad air_assist_pump_preview.png
render_preview air_control_solenoid.scad air_control_solenoid_preview.png
render_preview water_cooler.scad water_cooler_preview.png

echo "Previews written to $preview_dir"
