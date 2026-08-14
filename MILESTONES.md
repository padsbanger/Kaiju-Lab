# Kaiju Lab Milestones — Native 2D Roadmap

## Completed Foundation: Milestones 0–10

The first vertical slice is complete: persistent specimen state, pixel asset pipeline, laboratory entry, side-scrolling battle, autonomous engagement, data-driven waves, final boss, battle results, persistent damage/regeneration, XP and organ replacement, and presentation controls.

The subsequent architecture pivot is also complete: active gameplay now uses native 2D nodes and five camera-following City Ruins `Parallax2D` layers. The old 3D arena is inactive.

## Milestone 11: Native 2D Stabilization

Status: **complete**

Goal: make native 2D the unambiguous, regression-protected project architecture.

Deliverables:

- Replace stale 3D guidance in `AGENTS.md` and `README.md`.
- Mark the old `encounters/` arena as inactive legacy material.
- Keep active lab, battle, kaiju, enemy, projectile, camera, and parallax scenes free of 3D nodes.
- Use `Camera2D` with the kaiju around the left quarter of the viewport.
- Use five independent, seamlessly repeating `Parallax2D` layers.
- Preserve nearest filtering and pixel snapping.
- Retain a command-line regression suite and GPU render check.

Exit criteria:

- Active architecture test rejects 3D runtime nodes.
- City Ruins renders without repeat gaps over multiple screens.
- The complete automated suite passes.

## Milestone 12: Biological Resource and Dependency Simulation

Status: **complete**

Goal: make organs form a living machine whose upstream failures change combat behavior.

Deliverables:

- Simulate energy, blood, oxygen, heat, and biomass.
- Give components explicit required functions and supply demands.
- Make circulation affect blood/oxygen supply and movement.
- Make digestion generate energy only when supplied.
- Make attacks and regeneration consume energy and produce heat.
- Record useful per-component damage causes.
- Display live metabolic telemetry in battle and dependency status in the lab.
- Add deterministic tests for resource use, recovery, and dependency failure.

Exit criteria:

- Destroying circulation substantially reduces movement and disables dependent organs.
- Energy-starved or overheated organs cannot activate.
- Battle and lab explain the failure rather than only changing hidden numbers.

## Milestone 13: Lab Buildcraft and Organ Comparison

Status: **complete**

Goal: turn organ replacement into an informed, consequential preparation decision.

Deliverables:

- Replace the cycle button with an inventory/selection panel.
- Show current-versus-candidate health, mass, energy, dependency, tags, and behavior.
- Provide at least three meaningful alternatives for one socket and two for another.
- Enforce compatibility and explicit costs.
- Preview visual and behavioral changes before confirmation.
- Persist the selected build into deployment.

Exit criteria:

- The player can explain the tradeoff before installing an organ.
- Different selections visibly and mechanically change the next battle.

## Milestone 14: Combat Readability, Animation, and Balance

Status: **complete**

Goal: make autonomous decisions and anatomy degradation readable without logs.

Deliverables:

- Improve component walk, attack, hurt, damaged, destroyed, and regeneration states.
- Add transparent pixel VFX for attacks, impacts, wounds, failures, and boss pressure.
- Add enemy health/status feedback and clearer telegraphs.
- Show why attacks are unavailable and why movement slows.
- Balance City Ruins to a representative 2–5 minute deployment.
- Add a multi-minute automated soak test with bounded projectiles/enemies.

## Milestone 15: Second Biome and Faction Proof

Status: **complete**

Goal: prove the battle and parallax systems are reusable beyond City Ruins.

Deliverables:

- Add a second biome with five independently configured `Parallax2D` layers.
- Add biome-specific waves, at least two enemy behaviors, a hazard, and a boss variation.
- Select map/biome through data rather than City Ruins-specific scripts.
- Reuse camera, scroll, combat, persistence, and parallax controller code.

## Milestone 16: Save/Load and Roguelite Progression

Status: **complete**

Goal: preserve meaningful specimen development across application sessions.

Deliverables:

- Versioned local save data with safe defaults and validation.
- Save specimen anatomy, health, inventory, mutations, resources, level, and unlocks.
- Add post-deployment reward choices and a small research/unlock path.
- Support continue and new specimen flows without duplicating rewards.
- Add round-trip and corrupt-save recovery tests.

## Milestone 17: Release Validation and Polish

Status: **complete**

Goal: produce a stable, understandable prototype build suitable for external playtesting.

Deliverables:

- Settings, audio balancing, pause/speed correctness, and accessibility basics.
- Performance budgets for AI scans, physics queries, projectiles, and parallax.
- Long-session scene-transition and deployment soak tests.
- Export/package validation and a concise player-facing control guide.
- Final visual inspection at supported window sizes.

Exit validation:

- 26 automated scripts pass, including a multi-minute accelerated deployment soak.
- City Ruins and Toxic Swamp both pass GPU viewport capture checks.
- Windows debug export produces `build/KaijuLab.exe` and launches successfully.
- The archived 3D arena is excluded from active export content.

## Milestone 18: Post-Battle Salvage Decisions

Status: **complete**

Goal: make every return to the laboratory include one consequential recovery choice.

Deliverables:

- Generate three data-driven salvage choices from each deployment result.
- Offer distinct biomass, DNA, and research/experience strategies.
- Require exactly one choice before the next deployment.
- Persist unclaimed choices so closing the application cannot reroll or lose them.
- Save immediately after a claim and prevent duplicate claims.
- Present the choice in a focused retro lab panel with clear consequences.

## Milestone 19: Multi-Socket Build Archetypes

Status: **complete**

Goal: make whole-specimen engineering support visibly different biological strategies.

Deliverables:

- Generalize the organ selector to the currently inspected component.
- Add compatible alternatives for brain, heart, stomach, and torso sockets.
- Give installations explicit biomass costs.
- Make alternative organs alter targeting, circulation, metabolism, resilience, or offense.
- Add a whole-build analysis that names the archetype, strengths, supply balance, mass, and liabilities.
- Preserve every installed organ through battle transitions and save/load.

## Milestone 20: Escalating Campaign Circuit

Status: **complete**

Goal: turn the two biome proof into a replayable progression structure.

Deliverables:

- Track per-biome victories, total deployments, total victories, circuit level, and threat tier.
- Drive biome unlock prerequisites from map resources.
- Complete a circuit after defeating both City Ruins and Toxic Swamp bosses.
- Award a circuit-completion research cache and advance the circuit.
- Scale enemy vitality, damage, and rewards by threat while preserving bounded entity counts.
- Show clears, circuit, and threat in the lab and battle HUD.
- Persist campaign state and add deterministic regression coverage.

Exit validation:

- 30 automated scripts pass, including salvage UI rendering, save round-trip, campaign scaling, and the accelerated deployment soak.
- Pending salvage survives save/load and cannot be claimed twice.
- Brain, circulation, digestion, frame, and arm alternatives alter the live specimen and remain persistent.
- Completing both maps advances the circuit and increases threat without increasing entity-count budgets.

## Deferred

- Large procedural generation systems.
- Multiple full campaigns or factions beyond the reuse proof.
- Online or multiplayer features.
- Freely rotating cameras or 3D character rigs.
- Manual combat hotbars or reflex-action controls.
