# AGENTS.md — Kaiju Lab

## Product

Kaiju Lab is a Godot 4 single-player retro pixel-art side-scrolling autobattler. The player engineers one persistent modular kaiju in a laboratory, deploys it into multi-minute autonomous battles, observes anatomy and resource failures, returns with wounds and rewards, then rebuilds it.

The core loop is:

```text
LAB -> inspect / repair / replace / mutate -> DEPLOY
     -> autonomous side-scrolling waves -> boss -> RESULT
     -> same persistent specimen returns to LAB
```

Player decisions happen primarily before deployment. Normal combat has no direct movement, aiming, target selection, or ability hotbar.

## Authoritative Technical Direction

The active game is native 2D in Godot 4:

- `Node2D` scene roots;
- `CharacterBody2D` kaiju and enemies;
- `Area2D` attacks, components, and projectiles;
- `CollisionShape2D` gameplay collision;
- `Sprite2D` / `AnimatedSprite2D` pixel visuals;
- `Camera2D` side-view progression;
- modern `Parallax2D` environment layers.

Do not introduce `Node3D`, `Camera3D`, `Sprite3D`, `Area3D`, 3D physics, or deprecated `ParallaxBackground`/`ParallaxLayer` into active gameplay. The old `encounters/` arena is archived reference material and is not part of the active runtime or test suite.

The term “2.5D” describes the layered visual result, not a 3D runtime architecture.

## Battle Presentation

- Logical viewport: 640×360 with integer-friendly scaling.
- Nearest texture filtering and no mipmap blur for pixel art.
- Kaiju stays around 20–30% from the left edge.
- Camera advances right; the world and parallax visually move left.
- Ground combat stays on the horizontal progression axis; flying enemies may use vertical space.
- Battles should normally last 2–5 minutes.
- Enemies enter using data-driven rules: ahead/right, left, air, fixed emplacement, or preplaced.
- Every level ends in a boss encounter unless its data defines another resolution.

## Parallax Rules

Environment scenes use independent `Parallax2D` layers. Each layer derives `repeat_size.x` from the scaled texture width, repeats seamlessly, and follows `Camera2D` directly. Manual scrolling is optional and must never compete with camera following. Pixel snapping and nearest filtering remain enabled. Foreground layers may render ahead of combat but must not hide important action.

## Kaiju and Anatomy

The kaiju is a persistent modular biological machine, not an RPG character wearing stat items. Use composition and explicit sockets. Visual sprites are presentation only; component nodes own health, dependencies, function, and abilities.

Every `KaijuComponent` may define:

- identity, health, mass, tags, and socket type;
- biological function;
- required upstream functions;
- energy generation and consumption;
- blood and oxygen demand;
- attacks or passive behavior;
- visible healthy, damaged, offline, and destroyed states.

Prefer biological cause and effect over flat bonuses. A destroyed heart should reduce circulation and therefore movement and organ supply. A disabled stomach should stop useful energy generation. Weapon organs should require sufficient supply and energy.

Primary live resources are energy, blood, oxygen, heat, and biomass. Their state and failure reasons must be understandable in battle and in the lab.

## Autonomous Combat

The kaiju uses explicit states:

```text
ADVANCE, ENGAGE, RECOVER, STAGGERED, BOSS_FIGHT, DEAD
```

It advances heavily, slows or stops for important threats, chooses targets using its brain configuration, powers attacks through working anatomy, and resumes after combat. Target scans must remain staggered rather than running expensive selection every frame.

## Persistence and Lab

`SpecimenState` is authoritative between scenes. Battle nodes are disposable. `BattleResult` transfers component health, damage causes, progress, rewards, and outcome back to the specimen without retaining scene references.

The lab must allow the player to:

- inspect every component and its dependencies;
- understand damage and offline causes;
- regenerate wounded anatomy with explicit costs;
- compare compatible organ alternatives before installation;
- level up and mutate;
- deploy the same modified specimen again.

## Data-Driven Design

Use custom resources for component definitions, brain behavior, mutations, maps, waves, and biome/parallax configuration where appropriate. Avoid hardcoding content lists inside UI or AI scripts when they belong in resources. Keep scene scripts focused; do not create giant managers for unrelated systems.

## Code Rules

- Godot 4 typed GDScript.
- `snake_case` files/functions/variables, `PascalCase` classes/scenes, `SCREAMING_SNAKE_CASE` constants.
- Use signals for meaningful state changes and direct calls for clear ownership relationships.
- Separate simulation state from presentation.
- Avoid per-frame group scans, allocations, and full-tree searches in hot paths.
- Preserve user changes and unrelated dirty-worktree edits.
- Do not create git commits unless the user explicitly permits commits again.

## Testing and Completion

Run the suite with:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\run_all_tests.ps1
```

A feature is complete only when it is integrated into the real lab/battle loop, has relevant regression coverage, runs without parser/resource errors, and is visually checked when presentation changes. Active scene tests must continue proving that no 3D runtime nodes are present.

## Current Roadmap

The native-2D vertical slice, two biomes, biological simulation, post-battle salvage choice, multi-socket buildcraft, save system, and escalating two-map campaign circuit are complete. Future work should deepen authored content and usability while preserving the autonomous-combat identity and data-driven architecture.

See `MILESTONES.md` for deliverables and current status.
