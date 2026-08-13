# Kaiju Lab Milestones

This plan assumes a fresh Godot 4 project. The first target is a small vertical slice that proves the full loop:

```text
Build kaiju -> autonomous battle -> choose mutation -> fight again -> observe the change
```

The project must preserve the core technical direction throughout: gameplay occurs in true 3D space, while the kaiju is assembled from modular 2D body-part sprites using `Sprite3D` or `AnimatedSprite3D` nodes.

## Working Principles

- Keep every milestone playable from the project entry point.
- Use typed GDScript and composition instead of large all-purpose scripts.
- Keep visuals separate from gameplay state, hitboxes, and collision.
- Define reusable gameplay content with Godot `Resource` objects where practical.
- Use explicit `Node3D` sockets for body-part attachment.
- Prefer placeholder art and simple geometry until the core loop is fun.
- Do not build meta progression, procedural generation, or a freely rotating camera during the vertical slice.

## Milestone 0: Project Foundation

Goal: establish a runnable project skeleton without overbuilding infrastructure.

Deliverables:

- Create a `main.tscn` project entry point.
- Add focused folders for `kaiju`, `enemies`, `combat`, `encounters`, `progression`, `ui`, `data`, `art`, and `tests` as they become necessary.
- Add a minimal main scene responsible for starting the prototype encounter.
- Add a lightweight debug overlay or logging path for important combat events.
- Document how to open and run the project.

Exit criteria:

- The project starts from the editor and command line without errors.
- The main scene loads consistently with no manual editor setup.
- Empty infrastructure not needed by the next milestone has not been added.

## Milestone 1: 2.5D Arena and Modular Kaiju

Goal: prove the visual and spatial foundation.

Deliverables:

- Build one small 3D test arena with floor, obstacles, lighting, and readable scale.
- Add a fixed elevated/isometric `Camera3D`.
- Create a `CharacterBody3D` kaiju root.
- Assemble the kaiju from separate placeholder body-part sprites: torso, head, and two weapon limbs.
- Attach parts through named `Node3D` sockets.
- Give gameplay objects independent 3D collision shapes.
- Establish shared sprite orientation, scale, pivot, and render-order conventions.

Exit criteria:

- The kaiju reads as one creature while each body part remains independently replaceable.
- Moving or replacing a visual does not alter gameplay state or collision ownership.
- The controlled camera does not expose the sprites as flat cutouts during normal play.

## Milestone 2: Autonomous Combat Seed

Goal: create the first watchable autonomous fight.

Deliverables:

- Add a simple utility-based brain with target acquisition and action scoring.
- Add autonomous 3D movement toward a selected target.
- Add a melee claw attack with a real 3D hit volume and cooldown.
- Add one melee soldier enemy that approaches and attacks the kaiju.
- Add basic health, damage, death, and target-loss handling.
- Show current target, health, and major combat events through minimal debug UI.

Exit criteria:

- Starting the scene requires no combat input from the player.
- The kaiju finds, approaches, attacks, and kills an enemy.
- The enemy can damage and kill the kaiju.
- The encounter reaches a clear win or loss state without script errors.

## Milestone 3: Component Anatomy and Visible Failure

Goal: make the kaiju behave like an organism rather than a single health bar.

Deliverables:

- Create data-driven `ComponentData` resources.
- Implement an `AnatomyController` that owns attached components and their relationships.
- Add component health and separate `Area3D` hitboxes for the torso, heart, and weapon limbs.
- Add the MVP internal components: one brain, one heart, and one stomach.
- Make destroyed components stop their owned function.
- Add visible healthy, damaged, and destroyed presentation states where useful.
- Emit signals for health changes, component destruction, and ability availability.

Exit criteria:

- A weapon limb can be destroyed and its attack becomes unavailable.
- Destroying a critical component has an understandable gameplay consequence.
- Component state survives visual replacement and is owned in one clear location.
- Important failures are readable without inspecting the scene tree.

## Milestone 4: Combat Variety

Goal: make a short encounter tactically legible and interesting to watch.

Deliverables:

- Add a ranged soldier and tank alongside the melee soldier.
- Add a projectile/spit attack using a real 3D projectile.
- Add regeneration that consumes a limited resource such as biomass or energy.
- Expand utility scoring so distance, health, cooldowns, target type, and brain weights affect decisions.
- Add simple encounter spawning and completion rules.
- Tune AI evaluation and target scans to run at sensible intervals rather than every frame.

Exit criteria:

- One encounter mixes all three enemy types.
- The kaiju selects valid actions and visibly switches between melee, ranged, and recovery behavior.
- Projectiles, melee attacks, deaths, and component failures are easy to distinguish.
- The fight completes reliably across repeated runs.

## Milestone 5: Mutation Choice

Goal: connect combat victory to organism design.

Deliverables:

- Pause combat after victory and show three random mutation choices.
- Let the player select exactly one mutation.
- Implement at least three mutations with distinct effects, including:
  - one visible component addition or replacement;
  - one new or modified combat behavior;
  - one biological tradeoff or resource interaction.
- Apply mutations through data and component APIs rather than encounter-specific code.
- Show a concise description of what changed.

Suggested first set:

- Acid Gland: adds a visible gland and enables periodic acid projectiles.
- Bone Plating: adds a visible armor overlay, reduces physical damage, and increases mass.
- Regeneration Tumor: adds a visible organ and spends biomass to repair nearby components.

Exit criteria:

- Three choices appear after a win and one can be selected without using the editor.
- The selected mutation visibly or behaviorally changes the assembled kaiju.
- Unselected mutations are not applied.
- Mutation state persists into the next encounter.

## Milestone 6: Complete Two-Encounter Vertical Slice

Goal: prove the entire prototype loop end to end.

Deliverables:

- Add run state that owns the current kaiju build, encounter index, and rewards.
- Start a run with a deterministic basic kaiju.
- Chain encounter one, mutation selection, and a harder encounter two.
- Scale or compose the second encounter so the mutation's effect can be observed.
- Add clear run victory and run defeat screens with restart controls.
- Preserve useful failure information, including the component or enemy responsible for death where practical.

Exit criteria:

- A player can launch the game and finish the entire loop without developer intervention.
- The chosen mutation is present and relevant in encounter two.
- Winning encounter two completes the prototype; dying at any point ends the run cleanly.
- Restarting produces a clean new run without stale state.

This milestone is the MVP vertical-slice gate. Do not begin broad content production until it is stable and fun enough to justify expansion.

## Milestone 7: Lab Phase

Goal: make organism modification feel like an intentional part of play rather than a reward popup.

Deliverables:

- Add a compact lab view between encounters.
- Display the assembled specimen and its attachment sockets.
- Allow inspection of component health, inputs, outputs, abilities, and tradeoffs.
- Preview the visible result of a mutation before confirming it.
- Improve comparison and combat-readiness summaries.

Exit criteria:

- Players can understand the kaiju's important systems before entering combat.
- Attachment and replacement rules are clear in the UI.
- The lab feeds directly back into the existing encounter loop.

## Milestone 8: MVP Content and Polish

Goal: turn the proven slice into a compact replayable MVP.

Deliverables:

- Add additional organs, limbs, weapons, and mutations that create system interactions.
- Add at least two brain archetypes using shared utility actions and different weights.
- Add several authored encounter compositions with rising adaptation pressure.
- Improve body-part sprites, animation states, damage overlays, VFX, audio cues, and combat UI.
- Add performance checks for enemy counts, physics queries, projectiles, and AI update rates.
- Add automated checks for deterministic component and mutation logic where practical.

Exit criteria:

- Runs create meaningfully different kaiju builds and silhouettes.
- Combat outcomes are understandable and invite a different build decision next time.
- The project meets its performance target on the intended baseline hardware.
- The full loop runs without errors and no feature requires undocumented manual setup.

## Vertical-Slice Test Checklist

Before declaring Milestone 6 complete, verify all of the following:

- The kaiju acquires a valid target.
- The kaiju moves and attacks autonomously.
- Each enemy type can damage the kaiju.
- A component can be damaged and destroyed.
- A destroyed component stops its corresponding function.
- Both encounter victory and kaiju death end combat correctly.
- Three mutation choices appear after the first victory.
- Exactly one mutation is applied.
- The mutation changes the following battle and persists for its duration.
- Restarting clears previous run state.
- The project launches without parser errors, missing resources, or manual scene setup.

## Deferred Until After the MVP

- Persistent research and meta progression.
- Large procedural encounter or arena generation systems.
- Freely rotating gameplay camera and multi-direction sprite sets.
- Full 3D character rigs for the kaiju or ordinary enemies.
- Large enemy factions, bosses, flying units, and advanced destruction.
- Run history and specimen archives.
- Online features or multiplayer.

## Immediate Next Step

Implement Milestone 0, then build Milestone 1 with placeholder assets. The first meaningful checkpoint should be a modular sprite-built kaiju standing in a readable 3D arena under the final MVP camera style.
