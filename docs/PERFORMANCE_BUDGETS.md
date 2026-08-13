# Vertical Slice Performance Budgets

Baseline target: integrated graphics desktop at 1280×720, 60 FPS, using the 640×360 logical viewport.

- One persistent kaiju, no more than 8 ordinary active enemies, and one boss.
- Brain target scans occur at 0.30–0.50 second intervals, never every frame.
- No more than 24 live projectiles; ordinary ranged cooldown is at least 1 second.
- No more than 40 transient pixel VFX sprites and 6 active dynamic lights.
- Four parallax/world-depth layers; nearest-neighbor filtering on gameplay sprites.
- Physics is restricted to the progression axis and shallow readable lanes.
- Normal deployment target is 150 seconds, within the required 2–5 minute window.

Use the accelerated integration test for correctness and the running project profiler for device-specific frame timing.
