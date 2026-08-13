# Kaiju Lab Milestones â€” Retro Side-Scrolling Roadmap

This roadmap supersedes the original arena-based prototype plan.

The current repository already proves several reusable systems: modular `Sprite3D` anatomy, component health and failure, autonomous target scoring, melee and projectile attacks, mutations, encounter results, and automated tests. Those systems are a technical foundation, but the current playable structure does **not** yet satisfy the new product goal.

The target loop is now:

```text
GIANT KAIJU LAB
    â†“
inspect damage / regenerate / level up / change organs
    â†“
DEPLOY
    â†“
2.5D SIDE-SCROLLING AUTOBATTLE
    â†“
advance through waves for roughly 2â€“5 minutes
    â†“
FINAL BOSS
    â†“
battle report and persistent damage
    â†“
RETURN TO THE LAB
```

The visual target is deliberate retro pixel art: chunky authored pixels, fixed side-view composition, nearest-neighbor filtering, layered parallax, dark industrial scenery, and vivid toxic-green and mutation-purple accents. The images in `screenshots/` are composition, mood, scale, and UI references.

## Non-Negotiable Product Rules

- The game opens in the laboratory, not directly in combat.
- The kaiju is persistent across deployments.
- The kaiju starts near the left third of the battle viewport and faces forward along the level.
- Battles are autonomous; the player does not steer, aim, select targets continuously, or operate a normal combat hotbar.
- Ability panels shown during battle communicate autonomous organs, costs, cooldowns, and state. They are not manual attack buttons.
- The battle is a horizontal push through a map, not a free-roaming 3D arena.
- Standard levels culminate in a large boss encounter.
- Damage sustained in battle returns to the lab and remains visible until regenerated or repaired.
- The player can replace or upgrade an organ before redeploying.
- Gameplay remains true 3D logic with modular pixel-art `Sprite3D` / `AnimatedSprite3D` presentation.
- Visual nodes never own authoritative health, ability, attachment, or collision state.
- Pixel assets use nearest-neighbor filtering and consistent pivots, socket rules, scale, and side-view lighting.

## Existing Foundation

The following completed work should be retained and adapted rather than discarded:

- Godot 4 project entry point and project documentation.
- Modular kaiju root with explicit attachment sockets.
- Separate gameplay collision and sprite presentation.
- Data-driven `ComponentData`, `MutationData`, and `BrainData` resources.
- Component health, destruction signals, and functional shutdown.
- Utility-weighted autonomous target selection.
- Autonomous melee, projectile, and regeneration behavior.
- Melee soldier, ranged soldier, and tank gameplay archetypes.
- Encounter outcome, run state, combat telemetry, mutation application, and regression tests.

The following existing presentation is now considered temporary and must be replaced or reworked:

- Elevated/isometric arena composition.
- Smooth painted body-part art generated for the earlier direction.
- Short arena encounters and between-wave mutation-card loop.
- Immediate combat-first startup.
- Lab represented primarily as a mutation overlay.
- Two-encounter run structure that resets the specimen instead of supporting a persistent lab/deployment rhythm.

## Milestone 0: Pivot Baseline and Migration Safety

Status: **complete**

Goal: establish a safe transition from the completed arena prototype to the new side-scrolling product without losing reusable systems.

Deliverables:

- Add a migration note identifying reusable, replaceable, and obsolete scenes/scripts/assets.
- Capture automated baseline tests for component damage, autonomous attacks, mutation effects, and run state before restructuring scenes.
- Rename encounter-oriented concepts to battle-oriented concepts only where it improves ownership; avoid a broad mechanical rename with no gameplay value.
- Separate persistent specimen state from transient battle instances.
- Define the authoritative battle result payload, including:
  - victory or failure reason;
  - elapsed battle time;
  - map progress;
  - waves survived;
  - enemies defeated;
  - boss result;
  - XP and resource rewards;
  - per-component remaining health and damage causes.
- Update test runners so every later milestone can be verified from the command line.

Exit criteria:

- Existing reusable gameplay tests still pass.
- Persistent specimen data can exist without a loaded battle scene.
- Battle results can represent component damage without mutating unrelated UI state.
- Obsolete arena code is clearly identified and is not silently treated as final architecture.

## Milestone 1: Retro Pixel Rendering and Asset Pipeline

Status: **complete**

Goal: prove that the final pixel-art presentation works correctly inside the 3D scene before producing substantial content.

Deliverables:

- Configure a low-resolution logical viewport and integer-friendly stretch behavior.
- Use nearest-neighbor filtering for all gameplay pixel art.
- Establish a documented pixel-art body-part specification:
  - source canvas size;
  - pixels per world unit;
  - side-view angle;
  - light direction;
  - pivot convention;
  - socket type;
  - render priority;
  - animation frame size;
  - damaged and regenerating variants.
- Replace the current painted torso, head, and claw placeholders with genuinely authored pixel-cluster assets or purpose-built pixel placeholders.
- Build one modular side-facing kaiju from torso, head, limbs, core, and at least one optional organ sprite.
- Add limited but expressive independent animation states: idle, walk, attack, hurt, damaged, and regeneration pulse.
- Verify that restrained 3D lighting and particles do not blur or overpower sprites.

Exit criteria:

- No gameplay sprite uses smoothing or appears blurry at the target window sizes.
- The kaiju reads as one silhouette while every body part remains independently replaceable.
- Socket alignment is deterministic across idle, walk, and attack states.
- The assets look intentionally pixel-authored rather than like downscaled paintings.
- Damage overlays and biological glow remain readable against a dark environment.

## Milestone 2: Giant Laboratory Entry Scene

Status: **complete**

Goal: make the laboratory the real starting point and primary preparation phase.

Deliverables:

- Create a dedicated retro-pixel lab scene with a regeneration platform or containment bay.
- Spawn the persistent modular kaiju specimen in the lab.
- Add a fixed lab camera and layered industrial background inspired by `screenshots/2.png`.
- Add panels for:
  - specimen identity and level;
  - organ condition;
  - component regeneration status;
  - biomass, DNA, energy, and XP;
  - mutation slots;
  - deploy readiness.
- Allow the player to inspect each component and its health, function, inputs, outputs, abilities, and tradeoffs.
- Add a deploy action that transitions to battle while preserving the current build.
- Keep unavailable future actions visible only if clearly marked as unavailable; avoid nonfunctional controls that appear active.

Exit criteria:

- Launching the project opens the laboratory.
- The displayed specimen is assembled from the same persistent component data used by battle.
- The player can inspect every installed organ and understand whether it is healthy, damaged, regenerating, or offline.
- Deploy loads the side-scrolling battle without editor intervention.

## Milestone 3: Side-Scrolling World and Camera

Status: **complete**

Goal: prove the defining battle composition before adding wave complexity.

Deliverables:

- Build one horizontally authored city-ruins test level in true 3D space.
- Add foreground, gameplay, middle-distance, and background layers.
- Add parallax motion with pixel-readable ruined buildings, smoke, lights, and military silhouettes.
- Add a fixed orthographic or carefully justified perspective side-view camera.
- Anchor the kaiju near the left third of the viewport while level progress moves forward.
- Implement a scroll controller that makes the environment visibly move left as progress increases.
- Restrict ground gameplay primarily to the progression axis, with only limited depth lanes where they improve readability.
- Add level start, boss gate, and level end markers.
- Add a progress display from deployment to boss gate.

Exit criteria:

- The battle starts with the kaiju visibly on the left and facing the level.
- The kaiju advances automatically without player movement input.
- Camera/world scrolling produces clear leftward environmental movement.
- The player cannot mistake the scene for an unrestricted arena.
- Parallax layers preserve pixel edges and do not shimmer excessively during scrolling.

## Milestone 4: Heavy Autonomous Advance and Engagement

Status: **complete**

Goal: convert the existing chase-based arena AI into deliberate side-scrolling battle behavior.

Deliverables:

- Implement explicit kaiju battle states:
  - `ADVANCE`;
  - `ENGAGE`;
  - `RECOVER`;
  - `STAGGERED`;
  - `BOSS_FIGHT`;
  - `DEAD`.
- Give the kaiju a slow desired forward velocity and heavy acceleration/deceleration.
- Detect important nearby threats and transition from `ADVANCE` to `ENGAGE`.
- Stop or substantially slow forward progression while fighting blocking threats.
- Resume progression after the threat is cleared.
- Adapt target scoring to side-scrolling considerations: horizontal distance, lane offset, line of sight, threat priority, component availability, and brain weights.
- Allow attacks against enemies entering from either side without reversing the entire level flow.
- Display the current autonomous state and target for debugging.

Exit criteria:

- With no threat nearby, the kaiju advances toward the boss gate.
- When an important threat enters range, the kaiju visibly slows or stops and fights it.
- After combat, the kaiju resumes advancing automatically.
- Movement feels massive and deliberate rather than twitchy.
- Brain evaluation and target scanning remain staggered and within the documented frequency budget.

## Milestone 5: Progression Triggers and Enemy Waves

Status: **complete**

Goal: turn the test level into a continuous multi-minute deployment.

Deliverables:

- Create data-driven battle-map and wave resources.
- Add encounter triggers based on map progress rather than hardcoded timers alone.
- Support configurable spawn rules, including left entry, right/ahead entry, fixed emplacements, air entry, and authored pre-placement.
- Adapt the existing melee soldier, ranged soldier, and tank to readable side-view pixel sprites.
- Add at least one flying or elevated threat to prove vertical targeting.
- Add wave start, wave clear, travel, and elite challenge phases.
- Track enemies remaining, current wave, deployment time, and map progress.
- Balance the prototype deployment toward a 2â€“5 minute duration.
- Prevent defeated or bypassed waves from leaving stale targets or blocking progress.

Exit criteria:

- Multiple waves trigger exactly once at authored progress points.
- Enemies can enter from configurable directions without AI rewrites.
- Ground, ranged, vehicle, and elevated threats remain visually distinct.
- The kaiju alternates between travel and combat several times in one deployment.
- A representative automated or accelerated test proves the complete pre-boss wave sequence.

## Milestone 6: Final Boss and Battle Resolution

Status: **complete**

Goal: give the side-scrolling deployment a clear climax and authoritative result.

Deliverables:

- Add a boss gate at the end of the map.
- Add one large boss with a dramatically readable pixel silhouette.
- Transition the kaiju into `BOSS_FIGHT` and suspend ordinary map scrolling as needed.
- Give the boss at least two autonomous pressures that test different anatomy systems.
- Support battle completion from:
  - kaiju death;
  - required-enemy completion where applicable;
  - boss defeat;
  - encounter-specific failure.
- Generate a complete battle result payload.
- Add a battle-result presentation showing progress, duration, enemies defeated, rewards, component damage, notable failures, and cause of defeat.
- Transition back to the persistent laboratory specimen rather than constructing a new unrelated kaiju.

Exit criteria:

- The boss triggers only after required progression conditions are met.
- Boss victory and kaiju death resolve exactly once.
- The resulting component condition matches the final battle state.
- The result reaches the lab without depending on battle nodes that have been freed.
- The complete battle is long enough to observe build strengths and degradation.

## Milestone 7: Persistent Damage and Regeneration

Status: **complete**

Goal: complete the first half of the return-to-lab fantasy: bring the same damaged organism home and restore it.

Deliverables:

- Apply the battle result to persistent component health.
- Display wounds, destroyed parts, and offline systems on the lab specimen.
- Add a regeneration system with explicit costs, rates, and readiness rules.
- Show per-organ and overall recovery progress.
- Allow regeneration to restore component function and visuals.
- Preserve meaningful consequences for destroyed or critically damaged organs.
- Add a battle damage report explaining what failed and why.
- Prevent deployment when the build violates clearly defined readiness rules, while avoiding arbitrary waiting with no gameplay choice.

Exit criteria:

- Battle damage remains visible after returning to the lab.
- Regeneration changes the authoritative persistent component state, not only the UI.
- Recovered organs return online and use restored sprite states.
- The player can understand the major causes of damage from the report.
- Reloading or changing scenes does not silently heal or duplicate the specimen.

## Milestone 8: XP, Level-Up, and Organ Replacement

Status: **complete**

Goal: complete the player decision loop before redeployment.

Deliverables:

- Award XP and resources from defeated enemies, wave completion, and boss results.
- Add specimen levels with data-driven unlock or capacity effects.
- Add an organ inventory containing at least two valid alternatives for one socket.
- Allow the player to replace or upgrade at least one organ in the lab.
- Preview health, mass, ability, resource, dependency, and visual changes before confirmation.
- Enforce socket compatibility and anatomy ownership rules.
- Visibly update the modular pixel sprite assembly after the change.
- Persist the changed build into the next deployment.
- Keep player-facing effects biological and behavioral rather than presenting only flat percentage bonuses.

Exit criteria:

- A completed deployment grants XP and at least one spendable resource.
- The specimen can level up through the lab UI.
- The player can replace or upgrade an organ without editor setup.
- The kaiju silhouette or visible anatomy changes.
- The new organ changes behavior in the following deployment.

## Milestone 9: Complete Lab â†’ Battle â†’ Boss â†’ Lab Vertical Slice

Status: **complete**

Goal: prove the revised current goal end to end with no developer intervention.

Deliverables:

- Start in the giant lab with a deterministic basic specimen.
- Inspect or change an organ.
- Deploy into the city-ruins side-scrolling level.
- Advance through multiple triggered enemy waves.
- Reach and defeat or lose to the final boss.
- Return to the lab with correct component damage and rewards.
- Regenerate damaged anatomy.
- Level up or replace/upgrade an organ.
- Redeploy the visibly changed persistent specimen.
- Add explicit victory, defeat, loading, and transition states.
- Add clean restart/new-specimen behavior without stale battle nodes or duplicated state.

Exit criteria:

- The complete loop runs from the configured project entry point.
- A normal deployment lasts approximately 2â€“5 minutes at standard speed.
- All combat remains autonomous.
- Damage, rewards, level, inventory, and build persist correctly across scene transitions.
- The second deployment contains the modified specimen and demonstrates its changed behavior.
- The project runs without parser errors, missing resources, manual scene setup, or state leaks.

This is the new vertical-slice gate. Do not expand into large procedural systems, multiple factions, or meta-progression until this milestone is stable and fun.

## Milestone 10: Retro Presentation, Readability, and Balance

Status: **complete**

Goal: bring the proven vertical slice close to the quality and clarity suggested by the new reference screenshots.

Deliverables:

- Replace remaining smooth placeholder visuals with consistent retro pixel assets.
- Add independent walk, attack, charge, hurt, damaged, destroyed, and regenerating animation where it improves readability.
- Add pixel-art muzzle flashes, smoke, acid, electricity, impacts, dust, explosions, and boss effects.
- Add audio cues for wave start, organ activation, component failure, boss gate, boss phase, victory, defeat, regeneration, level-up, and deployment.
- Polish battle HUD hierarchy:
  - map and boss progress;
  - specimen vitality;
  - wave and enemies remaining;
  - autonomous organ ability state;
  - component status;
  - battle timer;
  - pause and inspection controls.
- Polish laboratory HUD hierarchy:
  - battle summary;
  - organ condition;
  - regeneration;
  - rewards and XP;
  - specimen build;
  - level-up, change-organ, mutation, and deploy actions.
- Add battle-speed and pause controls without adding manual combat actions.
- Profile sprite counts, physics queries, projectiles, particles, parallax layers, and AI updates.
- Balance the default deployment to the 2â€“5 minute target with meaningful degradation and recovery decisions.

Exit criteria:

- The battle and lab are immediately distinguishable but clearly belong to the same game.
- Pixel edges remain crisp during camera motion and at supported resolutions.
- Important attacks, target changes, organ activations, damage, and failures are understandable without reading logs.
- The boss is visually and mechanically recognizable as the deployment climax.
- A player can explain why the build succeeded or failed and identify a useful lab change for the next deployment.
- Performance meets the chosen baseline hardware target with documented budgets.

## Revised Vertical-Slice Test Checklist

Before declaring Milestone 9 complete, verify all of the following:

- The project opens in the giant laboratory.
- The persistent specimen and installed organs are visible and inspectable.
- At least one organ can be replaced or upgraded.
- Deploy transitions to the side-scrolling battle.
- The kaiju starts near the left third of the viewport.
- The kaiju advances automatically.
- The camera/world creates readable leftward scrolling and parallax.
- The kaiju slows or stops to engage important threats.
- Wave triggers fire once at the correct progress values.
- Enemy entry direction is configurable per wave.
- Ground, ranged, vehicle, and elevated enemies can attack.
- The kaiju autonomously chooses targets and abilities.
- Component damage changes component function during battle.
- Battle progress reaches a final boss gate.
- The boss encounter starts and ordinary scrolling changes appropriately.
- Kaiju death resolves the battle exactly once.
- Boss defeat resolves the battle exactly once.
- The battle result records duration, rewards, damage, and cause.
- The same damaged specimen returns to the lab.
- Damaged organs appear damaged or offline in the lab.
- Regeneration restores authoritative component state.
- Rewards can produce XP progression.
- A changed organ visibly and behaviorally affects the next deployment.
- Scene transitions do not duplicate enemies, projectiles, UI, rewards, or specimen state.
- The representative deployment lasts roughly 2â€“5 minutes at standard speed.

## Deferred Until After the Revised Vertical Slice

- Large procedural level generation systems.
- Multiple complete enemy factions.
- Large research trees and extensive meta progression.
- Multiple bosses or boss campaigns.
- Helicopter and air-combat complexity beyond one vertical-targeting proof.
- Destructible city simulation beyond authored set pieces.
- Freely rotating gameplay camera or multi-direction sprite sets.
- Full 3D character rigs for the kaiju or ordinary enemies.
- Manual combat hotbars or reflex-action controls.
- Online features or multiplayer.
- Specimen archives and detailed run-history systems.

## Immediate Next Step

Begin Milestone 0 by extracting persistent specimen state from the current combat-first flow and documenting which existing arena systems will be adapted. Then complete the pixel-rendering proof before building the new laboratory and side-scrolling map; producing more smooth art or expanding the old arena would increase migration cost without advancing the revised goal.

## Implementation Status

The earlier arena roadmap was completed through its Milestone 8 and remains available in Git history. Under this revised roadmap:

- Existing technical foundation: complete and reusable
- Milestone 0 â€” Pivot baseline and migration safety: complete
- Milestone 1 â€” Retro pixel rendering and asset pipeline: complete
- Milestone 2 â€” Giant laboratory entry scene: complete
- Milestone 3 â€” Side-scrolling world and camera: complete
- Milestone 4 â€” Heavy autonomous advance and engagement: not started
- Milestone 5 â€” Progression triggers and enemy waves: not started
- Milestone 6 â€” Final boss and battle resolution: not started
- Milestone 7 â€” Persistent damage and regeneration: not started
- Milestone 8 â€” XP, level-up, and organ replacement: not started
- Milestone 9 â€” Complete revised vertical slice: not started
- Milestone 10 â€” Retro presentation, readability, and balance: not started
