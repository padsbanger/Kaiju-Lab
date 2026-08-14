# Runtime Budgets

- Target scans: one staggered scan per kaiju every 0.28 seconds; never per frame.
- Active enemies: authored waves remain below 12 simultaneous enemies.
- Projectiles: three-second lifetime; soak validation requires fewer than 40 live instances.
- Parallax: five `Parallax2D` layers, each repeating a 640-pixel strip with no manual camera scroll.
- Physics: actors use fixed collision shapes and no full-tree search outside staggered target scans.
- Viewport: 640×360 logical canvas, nearest filtering, integer window scaling.

