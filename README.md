# Kaiju Lab

Kaiju Lab is a Godot 4 single-player roguelite autobattler about engineering a modular biological monster and watching it fight autonomously.

The project uses a 2.5D presentation: combat, movement, collision, targeting, and projectiles run in 3D, while kaiju anatomy is displayed with modular `Sprite3D` or `AnimatedSprite3D` body parts.

## Requirements

- Godot 4.7 or a compatible Godot 4 release

## Run

Open `project.godot` in Godot and press **F6**, or launch it from a terminal:

```powershell
godot --path .
```

The project has a configured main scene and does not require manual editor setup.

Combat is fully autonomous. During the lab phase, hover mutation cards to preview their effect and click one to evolve the specimen. Use **Start New Experiment** after a completed or failed run.

## Development

- Project guidance: `AGENTS.md`
- Milestone roadmap: `MILESTONES.md`
- Visual direction references: `screenshots/`

Every milestone should remain runnable and should end in a dedicated Git commit.

## Tests

Run the complete prototype suite from PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\run_all_tests.ps1
```

The suite covers component failure, brain weights, performance budgets, mutations, lab inspection, run state, autonomous mixed combat, and the full two-encounter UI loop.
