# Kaiju Lab — Fresh Vertical Slice Roadmap

This roadmap starts from the reset project created on 2026-08-14. A milestone is complete only after its implementation is integrated into the real loop, its regression coverage passes, and its changes are committed.

## Milestone 0 — Native 2D Foundation

Status: **complete**

- Establish repository hygiene and exclude generated Godot state.
- Configure a 640×360 integer-scaled, nearest-filtered pixel canvas.
- Boot through a native `Node2D` main scene.
- Add a command-line regression harness that rejects active 3D nodes.

## Milestone 1 — Persistent Biological Specimen

Status: **complete**

- Define typed, data-driven organ, socket, mutation, and specimen models.
- Simulate energy, blood, oxygen, heat, biomass, dependencies, and failure reasons.
- Keep component health and installed anatomy serializable and independent from scenes.

## Milestone 2 — Functional Laboratory

Status: **complete**

- Inspect every organ and its dependencies.
- Repair damage for explicit biomass costs.
- Compare and install compatible alternatives.
- Select mutations and prepare a deployment.

## Milestone 3 — Autonomous Side-Scrolling Battle

Status: **complete**

- Implement `ADVANCE`, `ENGAGE`, `RECOVER`, `STAGGERED`, `BOSS_FIGHT`, and `DEAD` states.
- Add staggered targeting, data-driven waves, attacks, enemies, a boss, and live telemetry.
- Keep the kaiju near the left quarter of a following `Camera2D` view.
- Build seamless modern `Parallax2D` layers without active 3D nodes.

## Milestone 4 — Persistent Campaign Loop

Status: **complete**

- Transfer battle damage and rewards through a serializable battle result.
- Require one post-battle salvage choice.
- Add versioned save/load with validation and corrupt-save recovery.
- Provide a replayable two-map circuit with escalating threat.

## Milestone 5 — Authored Content and Release Validation

Status: **complete**

- Add original pixel-art presentation, two distinct biomes, organ alternatives, mutations, and enemy variants.
- Add concise onboarding, readable failure feedback, pause, speed, and accessibility options.
- Run full regression, accelerated soak, visual capture, and export validation.

Exit validation:

- 17 command-line regression scripts pass.
- The five-minute accelerated metabolism/deployment soak remains bounded.
- Lab, City Ruins, Toxic Swamp, and salvage GPU captures pass visual inspection.
- The Windows debug export builds and survives a launch smoke check.
- Every active scene passes the native-2D architecture audit.

## Deferred

- Multiplayer or online services.
- Manual combat hotbars or direct movement controls.
- 3D gameplay, freely rotating cameras, or skeletal 3D character rigs.
- Large procedural campaign generation.
