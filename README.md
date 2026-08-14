# Kaiju Lab

Kaiju Lab is a Godot 4 retro pixel-art side-scrolling autobattler. Engineer a persistent modular kaiju in the lab, deploy it into autonomous battles, study its biological failures, then repair and rebuild the same specimen.

The fresh vertical slice includes six anatomy sockets, twelve organ definitions, three mechanical mutations, City Ruins and Toxic Swamp campaigns, mandatory post-battle salvage, versioned saves, and escalating two-map circuits.

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

## Controls

- Lab: click an anatomy socket to inspect, repair, or compare compatible organs.
- Guide: opens the concise preparation and telemetry reference.
- Deploy Specimen: starts the selected unlocked map; combat itself is autonomous.
- `P`: pause or resume battle.
- `F`: toggle battle speed between 1× and 2×.

After battle, claim exactly one salvage strategy before deploying again. Saves are written automatically to the Godot user-data directory.

## Export

```powershell
godot --headless --path . --export-debug "Windows Desktop" "build\KaijuLab.exe"
```

The included preset creates a self-contained Windows debug build.
