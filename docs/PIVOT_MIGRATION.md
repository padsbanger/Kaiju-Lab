# Side-Scrolling Pivot Migration

The original prototype proved reusable gameplay systems in a compact isometric arena. The revised product is a persistent retro-pixel laboratory and side-scrolling deployment loop.

## Retain

- `kaiju/anatomy/`: component ownership, health, hitboxes, and functional shutdown.
- `kaiju/brain/`: utility-weighted autonomous decisions.
- `combat/`: melee, ranged projectiles, health, and feedback primitives.
- `data/`: resource-driven brains, components, and mutations.
- `enemies/`: melee, ranged, and tank gameplay behavior, adapted to a progression axis.
- `tests/`: deterministic regression coverage.

## Adapt

- `autoload/run_manager.gd`: becomes the persistent specimen and deployment coordinator.
- `encounters/combat_scene.*`: temporary arena implementation; its responsibilities move into `battle/` scenes and directors.
- `kaiju/movement/`: chase movement becomes explicit advance/engage movement.
- `ui/mutation_selection/`: mutation cards become one tool within the full laboratory.
- `ui/combat/`: telemetry is retained but redesigned for side-scrolling progress and autonomous organs.

## Replace

- Isometric arena composition and camera.
- Smooth painted body-part sprites.
- Combat-first startup.
- Two short encounters separated by a mutation overlay.
- Scene-local specimen health as the only source of truth.

## State Boundary

`SpecimenState` owns persistent identity, progression, resources, installed anatomy references, mutations, and component health. Battle scenes instantiate gameplay nodes from that state and return a self-contained `BattleResult`. The result remains valid after every battle node is freed.
