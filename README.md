# Kaiju Lab

Kaiju Lab is a Godot 4 retro pixel-art side-scrolling autobattler. Engineer a persistent modular kaiju in the lab, deploy it into autonomous battles, study its biological failures, then repair and rebuild the same specimen.

## Requirements

- Godot 4.7 or a compatible Godot 4 release
- PowerShell for the regression runner

## Run

```powershell
godot --path .
```

## Test

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\run_all_tests.ps1
```

The active runtime is native 2D. `MILESTONES.md` records the implementation plan and acceptance criteria.

