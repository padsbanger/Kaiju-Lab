# Kaiju Lab

Kaiju Lab is a Godot 4 retro pixel-art side-scrolling autobattler about engineering one persistent modular monster and watching its biological systems survive autonomous battles.

After each deployment, choose one salvage strategy: regeneration biomass, mutation DNA, or combat research. Defeating City Ruins unlocks Toxic Swamp; clearing both maps completes a campaign circuit, awards a research cache, and raises the next circuit's threat and rewards.

The active game uses native Godot 2D nodes: `CharacterBody2D`, `Area2D`, `Sprite2D`, `Camera2D`, and modern `Parallax2D`. Layered scenery provides the 2.5D visual depth.

## Requirements

- Godot 4.7 or a compatible Godot 4 release

## Run

```powershell
godot --path .
```

The project opens in the laboratory. Inspect any anatomy socket, compare and install compatible organs, deploy, observe autonomous waves and the boss, then return with damage and a mandatory salvage decision.

Defeating the City Ruins boss unlocks Toxic Swamp. Clearing both maps advances the campaign circuit and raises threat. Organs, pending salvage, clears, circuit progress, and specimen development are saved locally. **New Specimen / Erase Save** starts over.

## Tests

```powershell
powershell -ExecutionPolicy Bypass -File .\tests\run_all_tests.ps1
```

The suite covers native-2D architecture, pixel rendering, parallax repetition, anatomy, metabolism, mutations, salvage choices, persistence, multi-socket buildcraft, campaign circuits, autonomous combat, waves, boss resolution, and the complete lab-to-battle loop.

## Export

The included `Windows Desktop` preset writes a debug playtest build to `build/KaijuLab.exe`:

```powershell
godot --headless --path . --export-debug "Windows Desktop" "build\KaijuLab.exe"
```

## Project Guidance

- `AGENTS.md` — authoritative product and architecture rules
- `GOALS.md` — concise product goals
- `MILESTONES.md` — current roadmap and acceptance criteria
- `screenshots/` — visual direction references
- `encounters/` — inactive legacy 3D prototype retained only for reference

Git commits are currently paused by user request.
