# AGENTS.md — Kaiju Lab

## Project Overview

**Kaiju Lab** is a single-player roguelite **2.5D side-scrolling autobattler** built in **Godot 4**.

The player grows and engineers a giant biological monster by attaching organs, limbs, mutations, weapons, nervous systems, defensive structures, and symbiotic organisms.

The player does **not** directly control the kaiju during normal battles. The player prepares the organism in the lab, deploys it, then watches it autonomously advance through a scrolling battlefield.

The intended high-level loop is:

```text
GIANT KAIJU LAB
    ↓
repair / regenerate
    ↓
level up / change organs / mutate
    ↓
DEPLOY
    ↓
2.5D SIDE-SCROLLING AUTOBATTLE
    ↓
kaiju slowly advances through the map
    ↓
enemy waves attack
    ↓
boss encounter at the end
    ↓
battle result
    ↓
RETURN TO LAB
```

The central design principle is:

> **Build the organism. Deploy it. Watch it survive. Bring it home. Rebuild it stronger.**

The kaiju should feel like a living biological machine rather than a normal RPG character wearing equipment.

A battle should usually last **several minutes**, not a few seconds. The player should be able to watch the organism's build succeed, degrade, adapt, or fail over the course of a long push through the level.

# Visual and Technical Direction

**Kaiju Lab is a retro-pixel 2.5D side-scrolling game.**

The battlefield is built in 3D so it can have real depth, layered scenery, lighting, particles, projectile trajectories, foreground/background objects, and parallax. Characters and biological body parts are represented primarily with modular 2D pixel-art sprites placed into the 3D world using Godot `Sprite3D` / `AnimatedSprite3D`.

The intended presentation is:

```text
3D side-scrolling level
        +
retro pixel-art Sprite3D characters
        +
modular 2D kaiju body parts
        +
3D hitboxes / projectiles / effects
        +
side-view perspective camera
```

This hybrid architecture is a core project constraint.

## Side-Scrolling Battle Presentation

The battle should read visually like a classic side-scrolling game.

The kaiju:

- starts on the **left side of the screen**
- faces toward the level's forward direction
- advances slowly and automatically
- should usually remain around the left third of the viewport rather than walking all the way to the screen edge

The level:

- progresses horizontally
- visually scrolls **to the left** as the kaiju advances, similar to a classic Mario-style side scroller
- uses a fixed side-view / slightly elevated 2.5D camera
- may contain limited depth lanes, foreground/background objects, or slight Z-axis separation
- should not behave like a freely explorable 3D arena

The camera should follow level progress while preserving the composition of the kaiju on the left side of the frame.

Conceptually:

```text
SCREEN

[KAIJU]  → forward progression

        enemies / hazards / structures / objectives

<<<<<<<< environment scrolls left <<<<<<<<

                                      [BOSS]
```

Do not rotate the gameplay camera around the kaiju.

## Battle Flow

A standard battle is a continuous push through one authored or procedurally assembled map.

Typical sequence:

```text
DEPLOY
  ↓
Kaiju enters from left
  ↓
Slow automatic march
  ↓
Enemy wave
  ↓
Short travel section
  ↓
Enemy wave
  ↓
Elite / environmental challenge
  ↓
More enemy waves
  ↓
Boss gate
  ↓
Boss fight
  ↓
Battle result
  ↓
Return to lab
```

Battles may last several minutes.

A battle can end when:

- the kaiju dies
- all required enemies are dead
- the end-of-map boss is defeated
- an encounter-specific victory or failure condition is met

The default level should culminate in a **large boss enemy at the end of the map**.

## Enemy Entry Rules

Enemy encounters are controlled by map progression and encounter triggers.

Per the current design direction:

- enemy waves may appear from the **left side of the screen** and immediately pressure the kaiju
- authored enemies may also already exist farther along the map
- ranged enemies, vehicles, turrets, flying enemies, and bosses may attack from positions that improve readability
- spawn behavior must be data-driven so the exact entry side can be changed per encounter without rewriting enemy AI

Do not hardcode every enemy to one spawn edge.

## Autonomous Combat Rule

Kaiju combat is autonomous.

During a normal battle the player should **not** manually:

- steer the kaiju
- spam attacks
- aim projectiles
- activate a standard MMO-style ability hotbar
- choose individual targets every few seconds

The kaiju decides when to:

- walk forward
- stop to fight
- choose a target
- use an organ ability
- regenerate
- attack a boss
- respond to enemies attacking from different positions

Player agency should primarily come from the **lab build**, not reflex controls during combat.

Optional battle-speed controls, pause, inspect, or debug overlays are acceptable.

## Forward Movement Behavior

The kaiju has a desired forward velocity but should not blindly walk through combat.

Suggested states:

```text
ADVANCE
ENGAGE
RECOVER
STAGGERED
BOSS_FIGHT
DEAD
```

Typical behavior:

```text
No important threat nearby
→ ADVANCE

Enemy enters engagement range
→ ENGAGE
→ slow or stop
→ fight autonomously

Threat cleared
→ ADVANCE

Boss arena reached
→ stop automatic map scrolling as needed
→ BOSS_FIGHT
```

Movement should feel heavy and deliberate.

The kaiju is enormous. Avoid twitchy acceleration or rapid direction changes.

## Rendering Rules

For the MVP:

- use a fixed side-view or slightly elevated side-view camera
- use orthographic projection unless perspective clearly improves the pixel-art presentation
- use `Sprite3D` / `AnimatedSprite3D` for the kaiju and most enemies
- use transparent pixel-art textures
- keep body-part sprites at a consistent viewing angle
- use nearest-neighbor texture filtering for pixel-art assets
- avoid texture smoothing that blurs pixels
- use integer-friendly render scaling where practical
- keep consistent sprite scale / pixels-per-world-unit
- define intentional pivots for every body-part sprite
- attach parts through explicit sockets
- keep gameplay collision separate from sprite dimensions
- use restrained 3D lighting, particles, decals, smoke, explosions, and shadows without destroying pixel readability
- use parallax layers for city ruins, laboratories, wastelands, industrial zones, or other environments

Do not introduce a freely rotating camera.

## Retro Pixel Art Direction

The visual identity should feel deliberately retro rather than merely low resolution.

Prefer:

- chunky readable pixels
- strong silhouettes
- limited animation frames with expressive poses
- dark industrial palettes with vivid biological glow accents
- CRT-era / late-90s PC / 16-bit-to-32-bit inspired interface details
- pixel-art explosions, muzzle flashes, smoke, gore, electricity, acid, and organ effects
- layered parallax backgrounds
- dramatic giant-scale kaiju silhouettes
- readable tanks, soldiers, helicopters, turrets, drones, and bosses

Avoid:

- photorealistic rendering
- smooth modern vector-like characters
- blurry AI-art texture downscaling presented as pixel art
- high-poly realistic creature rigs as the main character solution

## Visual / Gameplay Separation

The visual sprite is never the authoritative gameplay object.

Example:

```text
KaijuComponent3D
├── Hitbox : Area3D
│   └── CollisionShape3D
├── AttachmentSocket : Node3D
├── VisualRoot : Node3D
│   └── AnimatedSprite3D
└── AbilityController
```

The component's 3D node owns:

- position
- attachment relationship
- health
- hit detection
- resource connections
- abilities
- gameplay state

The `Sprite3D` / `AnimatedSprite3D` owns only presentation.

## Sprite Body-Part System

Kaiju visuals are assembled like a modular animated biological paper doll.

Example:

```text
KaijuRoot
├── Torso
│   └── TorsoSprite
├── HeadSocket
│   └── HeadComponent
│       └── HeadSprite
├── LeftArmSocket
│   └── LeftArmComponent
│       └── ClawSprite
├── RightArmSocket
│   └── RightArmComponent
│       └── TentacleSprite
├── BackSocket
│   └── SporeGlandComponent
│       └── SporeGlandSprite
└── TailSocket
    └── TailComponent
        └── TailSprite
```

Mutations should visibly alter the sprite assembly by:

- replacing body-part sprites
- adding new component sprites
- adding overlays
- changing animations
- adding wounds or regeneration states
- changing silhouettes
- adding extra sockets when a mutation permits additional anatomy

A late-run kaiju should look increasingly bizarre and should visually communicate the player's build.

## Sprite Animation

Prefer independent component animation over one monolithic animation.

Useful states include:

```text
idle
walk
attack
charge
hurt
damaged
regenerating
destroyed
active
cooldown
```

Examples:

- legs drive the kaiju's slow walking cycle
- torso has a heavy breathing/bobbing animation
- heart pulses independently
- glands swell before firing
- tentacles animate independently
- claws play attack frames when their ability activates
- damaged organs use injured variants
- regenerating organs pulse or grow back in the lab

## Environment and Enemies

The environment should use 3D geometry and layered 2D/3D presentation to create depth while preserving side-scrolling readability.

For enemies:

- `Sprite3D` / `AnimatedSprite3D` is preferred
- enemies should have readable side silhouettes
- ground units should primarily operate along the progression axis
- flying enemies may use vertical space
- bosses may occupy much more of the screen than normal units
- enemy gameplay logic must remain independent of rendering choice

Do not require full 3D character rigs for ordinary units.

# Core Gameplay Loop

1. Kaiju returns to or begins in the giant laboratory.
2. Inspect battle damage and regeneration status.
3. Regenerate damaged organs and body parts.
4. Spend earned experience / resources to level up.
5. Install, replace, upgrade, or mutate organs.
6. Deploy the kaiju into a side-scrolling battle map.
7. Kaiju starts on the left side of the screen.
8. Kaiju autonomously marches forward while the environment scrolls left.
9. Enemy waves attack throughout the map.
10. Kaiju automatically stops or slows to fight important threats.
11. Reach the final boss encounter.
12. Battle ends when its victory/failure condition is reached.
13. Award XP, biomass, DNA, organs, research, or other rewards.
14. Return the same persistent kaiju to the laboratory.
15. Regenerate, rebuild, and deploy again.

The lab → battle → lab rhythm is the heart of the game.

Do not structure the default game as disposable five-second rounds separated by constant reward screens. The player should spend meaningful time watching a single deployment play out.

# Game Pillars

## 1. Biological Construction

The kaiju is assembled from interconnected biological systems.

Possible components include:

- brains
- hearts
- lungs
- stomachs
- muscles
- bones
- claws
- jaws
- tails
- wings
- tentacles
- glands
- armor plates
- sensory organs
- neural nodes
- parasite nests
- energy organs
- regeneration organs

Components should not simply provide flat stat bonuses.

Prefer components that change behavior or create interactions.

Good:

- Second Heart increases blood flow and attack speed but increases bleeding damage.
- Plasma Gland consumes stored energy and powers ranged attacks.
- Regeneration Organ consumes biomass to repair nearby tissue.
- Egg Sac periodically creates autonomous parasites.
- Bone Plating reduces damage but increases body mass.

Avoid:

- +10% damage
- +5 armor
- +8% movement speed

Flat modifiers may exist internally, but the player-facing design should emphasize biological cause and effect.

---

## 2. Autonomous Combat

The player does not directly move or attack during normal combat.

The kaiju chooses actions based on:

- brain type
- instincts
- target priorities
- available organs
- health
- energy
- enemy distance
- environmental threats
- internal damage
- mutation rules

Combat should be enjoyable to watch.

The player should frequently understand:

- why the kaiju chose a target
- why an ability activated
- why part of the organism failed
- what mutation helped
- what weakness caused the defeat

---

## 3. Emergent Organ Interactions

Components should interact through systems rather than isolated bonuses.

Primary biological resources may include:

- blood
- oxygen
- energy
- biomass
- neural capacity
- body heat
- toxins

Example:

```text
LUNGS
  ↓ oxygen
HEART
  ↓ circulation
MUSCLES
  ↓ movement
CLAW
```

Another example:

```text
STOMACH
  ↓ energy
ENERGY GLAND
  ↓ charge
PLASMA ORGAN
  ↓
MOUTH
```

Destroying one part of the chain should affect dependent systems.

---

## 4. Visible Damage

Body parts should be individually damageable where practical.

Examples:

- destroyed leg reduces movement
- damaged heart lowers circulation
- destroyed eye reduces detection
- severed weapon limb removes an attack
- damaged gland disables an ability
- destroyed parasite nest stops spawning minions

The kaiju should visibly degrade during combat.

Avoid treating health as only one global HP bar.

A global health state may exist, but local organ damage is a major gameplay feature.

---

# Kaiju Anatomy Model

The initial implementation should use a modular component graph.

Each biological component should conceptually support:

```text
KaijuComponent
├── identity
├── health
├── max_health
├── mass
├── attachment_points
├── inputs
├── outputs
├── resource_consumption
├── resource_generation
├── abilities
├── tags
└── status
```

Example tags:

```text
organ
limb
brain
weapon
circulatory
respiratory
digestive
defensive
sensory
neural
parasite
energy
mutation
```

Components should communicate using signals or explicit system managers rather than tightly coupling themselves to unrelated components.

---

# Recommended Scene Structure

Prefer composition over deep inheritance.

Example:

```text
Main
├── RunManager
├── LabManager
├── ProgressionManager
├── SceneManager
└── AudioManager

BattleScene
├── SideScrollWorld : Node3D
│   ├── LevelRoot
│   ├── ParallaxBackgroundRoot
│   ├── ForegroundRoot
│   ├── EncounterTriggerRoot
│   ├── EnemySpawnRoot
│   ├── BossGate
│   └── LevelEnd
├── BattleDirector
├── ScrollController
├── Kaiju : CharacterBody3D
│   ├── AnatomyController
│   ├── BrainController
│   ├── ForwardMovementController
│   ├── TargetingController
│   ├── ResourceController
│   ├── CollisionShape3D
│   └── ComponentRoot
│       ├── TorsoComponent
│       │   ├── Hitbox3D
│       │   └── AnimatedSprite3D
│       ├── HeadSocket
│       ├── LeftArmSocket
│       ├── RightArmSocket
│       ├── BackSocket
│       └── TailSocket
├── EnemyManager
├── ProjectileRoot3D
├── EffectsRoot3D
├── CameraRig3D
│   └── Camera3D
└── BattleUI

LabScene
├── GiantLabEnvironment
├── RegenerationChamber
│   └── KaijuPreview
├── LabCamera
├── LabController
└── LabUI
    ├── BattleReportPanel
    ├── OrganConditionPanel
    ├── AnatomyPanel
    ├── LevelUpPanel
    ├── MutationPanel
    └── DeployPanel
```

The battle camera and scroll controller must work together so the kaiju remains visually anchored near the left side while the world appears to move left.

Do not create huge scripts that manage unrelated systems.

# Suggested Project Structure

```text
res://
├── autoload/
│   ├── game_state.gd
│   ├── run_manager.gd
│   ├── lab_manager.gd
│   ├── progression_manager.gd
│   └── scene_manager.gd
│
├── kaiju/
│   ├── kaiju.tscn
│   ├── kaiju.gd
│   ├── anatomy/
│   ├── brain/
│   ├── movement/
│   │   └── forward_movement_controller.gd
│   ├── components/
│   ├── resources/
│   └── visuals/
│
├── battle/
│   ├── battle_scene.tscn
│   ├── battle_director.gd
│   ├── scroll_controller.gd
│   ├── battle_result.gd
│   ├── encounter_triggers/
│   ├── spawn_system/
│   ├── boss/
│   ├── damage/
│   ├── targeting/
│   ├── projectiles/
│   ├── effects/
│   └── status_effects/
│
├── levels/
│   ├── base/
│   ├── city_ruins/
│   └── test_level/
│
├── enemies/
│   ├── base/
│   ├── military/
│   ├── robots/
│   ├── kaiju/
│   └── aliens/
│
├── lab/
│   ├── lab_scene.tscn
│   ├── lab_controller.gd
│   ├── regeneration_system.gd
│   ├── organ_management/
│   └── specimen_preview/
│
├── progression/
│   ├── level_system.gd
│   ├── mutation_system.gd
│   ├── reward_system.gd
│   └── research_tree.gd
│
├── ui/
│   ├── lab/
│   ├── battle/
│   ├── battle_results/
│   ├── organ_management/
│   └── research/
│
├── data/
│   ├── components/
│   ├── enemies/
│   ├── levels/
│   ├── encounters/
│   ├── bosses/
│   └── mutations/
│
├── art/
│   ├── pixel/
│   │   ├── kaiju/
│   │   │   ├── bodies/
│   │   │   ├── heads/
│   │   │   ├── limbs/
│   │   │   ├── tails/
│   │   │   ├── glands/
│   │   │   ├── armor/
│   │   │   ├── parasites/
│   │   │   └── damage_states/
│   │   ├── enemies/
│   │   ├── bosses/
│   │   ├── ui/
│   │   └── vfx/
│   ├── environments_3d/
│   └── lab/
│
├── audio/
└── tests/
```

# Data-Driven Design

Gameplay content should be defined using Godot `Resource` objects whenever practical.

Avoid hardcoding organ definitions into gameplay scripts.

Example:

```gdscript
class_name ComponentData
extends Resource

@export var id: StringName
@export var display_name: String
@export_multiline var description: String

@export var max_health: float
@export var mass: float

@export var tags: Array[StringName]

@export var energy_generation: float
@export var energy_consumption: float

@export var attachment_type: StringName
@export var ability_scene: PackedScene

# 2.5D presentation data
@export var sprite_frames: SpriteFrames
@export var visual_scale: float = 1.0
@export var visual_offset: Vector3 = Vector3.ZERO
@export var visual_rotation_degrees: Vector3 = Vector3.ZERO
@export var render_priority: int = 0
```

Each component should preferably have a `.tres` definition.

Example:

```text
res://data/components/organs/heart_basic.tres
res://data/components/organs/heart_mutated.tres
res://data/components/weapons/acid_gland.tres
```

This makes balancing and procedural generation easier.

---

# Brain System

The kaiju brain controls high-level autonomous behavior.

Initial brain archetypes:

## Predator Brain

Behavior:

- prioritize weak targets
- chase enemies aggressively
- prefer isolated enemies
- pursue fleeing enemies

## Berserker Brain

Behavior:

- attack nearest target
- avoid retreat
- aggression increases when damaged
- favor melee abilities

## Siege Brain

Behavior:

- prioritize structures
- ignore weak infantry when possible
- favor slow powerful attacks

## Hive Brain

Behavior:

- remain near spawned creatures
- protect parasite nests
- prioritize enemies threatening minions

## Defensive Brain

Behavior:

- avoid dangerous zones
- retreat when heavily damaged
- favor regeneration
- remain near defensive structures

Brains should primarily influence decision weighting rather than contain entirely separate combat implementations.

---

# AI Architecture

Prefer utility-based AI for kaiju decision making.

Each action receives a score.

Example actions:

```text
AttackNearest
AttackWeakest
UseSpecialAbility
Retreat
ChargeEnemy
DestroyStructure
ProtectMinions
MoveToCover
Regenerate
```

Example utility calculation:

```gdscript
var score := base_score

score += target_priority
score += distance_score
score += brain_modifier
score += health_modifier
score += ability_modifier
```

Highest valid score wins.

Avoid large nested `if/elif` AI trees when a scoring system would be easier to extend.

---

# Component Connections

The long-term goal is for the kaiju anatomy to behave like a graph.

Example:

```text
Brain
  │
Neural Node
  ├── Left Arm
  ├── Right Arm
  └── Tail

Heart
  ├── Left Arm
  ├── Right Arm
  └── Regeneration Organ

Stomach
  └── Energy Gland
        └── Plasma Gland
              └── Mouth
```

Potential connection types:

```text
blood
oxygen
energy
neural
biomass
toxin
structural
```

Do not implement the entire biological simulation immediately.

Build the system incrementally.

---

# MVP Scope

The first playable prototype should prove the complete **lab → side-scrolling battle → boss → lab** loop.

## Kaiju

Implement:

- one `CharacterBody3D` kaiju root
- modular `AnimatedSprite3D` torso/head/arms/tail
- one brain
- one heart
- one stomach
- two weapon limbs
- explicit `Node3D` attachment sockets
- simple 3D hitboxes
- heavy automatic walk animation
- automatic forward movement
- automatic stopping/engagement behavior
- persistent health / organ damage results passed back to the lab

## Battle Map

Implement one short test level with:

- side-view 2.5D camera
- kaiju starting on the left side
- horizontal progression
- world scrolling left as the kaiju advances
- layered retro-pixel background
- 3-5 encounter trigger zones
- enemy spawn points
- one boss arena at the end
- one boss

The test battle should be long enough to observe the build rather than ending instantly.

Target prototype battle duration:

```text
roughly 2-5 minutes
```

Balance may change later.

## Enemies

Implement:

- melee soldier
- ranged soldier
- tank
- one larger boss enemy

## Combat

Implement:

- autonomous forward movement
- autonomous targeting
- automatic attacks
- enemies automatically attacking the kaiju
- real 3D projectile / hit-volume logic
- component damage
- visible pixel-sprite damage states
- battle progress tracking
- boss trigger
- kaiju death
- enemy death
- boss death

## Battle End Conditions

`BattleDirector` must support explicit result states.

Suggested result enum:

```text
VICTORY_BOSS_DEFEATED
VICTORY_ALL_REQUIRED_ENEMIES_DEFEATED
DEFEAT_KAIJU_DIED
DEFEAT_ENCOUNTER_FAILED
```

Do not rely on scene reloads to infer battle outcome.

The result must contain enough data for the lab to display:

- duration
- enemies defeated
- boss defeated
- damage taken
- organs damaged
- organs destroyed
- XP earned
- biomass earned
- DNA / research rewards
- discovered organs or mutations

## Lab

Implement a giant retro-pixel biotechnology lab.

After every battle:

1. transition back to the lab
2. show the kaiju inside a regeneration / containment chamber
3. show visible battle damage
4. regenerate or repair damaged body parts
5. award XP
6. allow level-up when requirements are met
7. allow organ changes
8. allow available mutations/upgrades
9. allow deployment into the next battle

The lab should feel like a physical place built to contain an enormous organism, not a generic menu floating over a background.

## Progression

For the MVP:

- battles award XP and biomass
- kaiju level persists between deployments
- organs can have levels
- at least one organ can be replaced in the lab
- at least one organ can be upgraded
- at least one mutation visibly changes the kaiju
- the next deployment uses the changed build

Avoid building a huge research tree before this complete loop works.

---

# First Prototype Loop

```text
START IN LAB
      ↓
Inspect Kaiju
      ↓
Change / Upgrade Organ
      ↓
DEPLOY
      ↓
Kaiju enters left side of battle
      ↓
AUTOMATIC FORWARD MARCH
      ↓
Enemy waves attack
      ↓
Kaiju autonomously fights
      ↓
Advance again
      ↓
BOSS GATE
      ↓
Boss Fight
      ↓
Battle Result
      ↓
RETURN TO LAB
      ↓
Regenerate Damage
      ↓
Gain XP / Level Up
      ↓
Change Organs
      ↓
DEPLOY AGAIN
```

# Mutation Examples

## Offensive

### Acid Gland

Periodically fires acid.

Possible synergy:

```text
Acid Gland + Enhanced Stomach
→ faster acid generation
```

### Plasma Organ

Consumes energy to fire a powerful ranged attack.

### Bone Claws

Improves melee penetration.

### Electric Organ

Deals chain damage to nearby enemies.

---

## Defensive

### Bone Plating

Reduces incoming physical damage but increases mass.

### Regeneration Tumor

Slowly restores nearby components.

Consumes biomass.

### Second Heart

Improves circulation and survivability.

Can increase bleed vulnerability.

### Thick Hide

Reduces small-arms damage.

---

## Utility

### Additional Brain Node

Increases neural capacity.

Allows more complex instincts.

### Enhanced Eyes

Improves target detection.

### Adrenal Gland

Activates when health becomes low.

Increases attack and movement speed.

### Extra Legs

Improves stability and movement speed.

---

## Summoning

### Parasite Nest

Periodically generates small creatures.

### Egg Sac

Stores several parasites and releases them when enemies approach.

### Spore Gland

Creates temporary biological hazards.

---

# Enemy Factions

Enemy groups should create different adaptation pressures.

## Military

Units:

- infantry
- machine gunner
- tank
- artillery
- helicopter

Pressure:

- armor
- ranged damage
- air threats

---

## Machines

Units:

- shield drone
- laser robot
- repair drone
- EMP unit

Pressure:

- energy disruption
- shields
- precision damage

---

## Rival Kaiju

Units:

- predator
- tank
- flyer
- burrower
- regeneration monster

Pressure:

- specialized biological counters

---

## Alien Organisms

Units:

- parasite
- spitter
- hive creature
- spore carrier

Pressure:

- infection
- toxins
- swarms

---

# Combat Readability

The player should understand the battle while mostly watching rather than micromanaging.

Use:

- strong pixel-art silhouettes
- clear walk / attack / hurt animations
- readable projectiles
- organ damage indicators
- boss health bar
- level progress / boss-gate indicator
- enemy wave or threat indicators when useful
- visible regeneration and organ failure
- distinct audio cues
- screen shake sparingly for large attacks
- large boss telegraphs
- foreground/background separation

Avoid excessive UI covering the battle.

Because the player is not actively controlling attacks, the battle presentation itself must remain interesting for several minutes.

Important events should be obvious:

```text
HEART DESTROYED
PLASMA GLAND OFFLINE
LEFT ARM SEVERED
REGENERATION ACTIVE
BOSS APPROACHING
BOSS DEFEATED
```

# Lab Phase

The giant laboratory is the player's home base and the main preparation phase.

Every deployment should return to the lab after the battle result is resolved.

## Lab Fantasy

The kaiju should appear inside an enormous industrial-biotech regeneration chamber.

The scene may include:

- giant mechanical gantries
- articulated repair arms
- nutrient injectors
- regeneration fluid
- containment rings
- observation platforms
- scientists or tiny maintenance workers for scale
- giant tanks containing organs
- monitors showing tissue condition
- pipes, cables, pumps, warning lights, and bio-reactors
- visible scars and damaged organs being repaired

The kaiju should feel gigantic compared with the laboratory staff and machinery.

## Lab Functions

The player can:

- inspect the kaiju
- inspect battle damage
- regenerate damaged organs
- replace organs
- upgrade organ levels
- mutate organs
- attach new body parts
- compare organs
- inspect synergies
- inspect stats
- level up the specimen
- review battle results
- prepare the next deployment

The lab should visually show organ changes on the kaiju immediately.

## Regeneration

Post-battle damage should matter visually and mechanically.

At minimum, the lab should track:

```text
organ health
organ destroyed/damaged state
regeneration status
repair cost or regeneration requirement
```

For the MVP, regeneration may complete instantly when the player confirms recovery if real-time waiting would add no gameplay value.

Do **not** require the player to wait real-world hours for regeneration unless that mechanic is explicitly requested later.

## Leveling

The kaiju gains XP from battles.

Leveling may unlock:

- additional organ levels
- additional sockets
- mutation choices
- larger body stages
- new brain capacity
- new organ categories

Prefer unlocks and build choices over simple permanent stat inflation.

## Organ Management

Organ changes happen primarily in the lab, not during battle.

Changing an organ should:

1. validate socket compatibility
2. update gameplay data
3. update the corresponding pixel-art body-part sprite
4. update abilities / resources / synergies
5. update the lab preview
6. persist into the next deployment

The lab is as important as combat.

A strong game session should feel like alternating between:

> **spectacle and survival in battle**

and

> **experimentation and rebuilding in the lab**

# Meta Progression

Persistent progression should unlock options rather than simply grant permanent power.

Good unlocks:

- new organ families
- new brain archetypes
- new mutations
- new enemy factions
- new starting organisms
- new biological systems

Avoid:

```text
Permanent +20% damage
Permanent +30% health
```

Prefer:

```text
Unlock Electric Organ family

Unlock Hive Brain

Unlock Parasite mutations

Unlock Wing anatomy
```

---

# Run History

Long term, preserve memorable specimens.

Example:

```text
SPECIMEN K-27

Generation: 14
Survived: 31 minutes
Encounters defeated: 12
Enemies destroyed: 428

Notable mutations:
- Triple Heart
- Plasma Mouth
- Regeneration Tumor
- Armored Tail

Cause of death:
Artillery destroyed primary heart.
```

This feature is not required for the MVP.

---

# Coding Rules

## GDScript

Use Godot 4 typed GDScript.

Prefer:

```gdscript
var health: float = 100.0
var target: Node3D
var enemies: Array[Node3D] = []
```

Avoid unnecessarily untyped variables.

---

## Naming

Use:

```text
snake_case
```

for:

- variables
- functions
- filenames

Use:

```text
PascalCase
```

for:

- classes
- custom resources

Examples:

```text
kaiju_controller.gd
component_graph.gd
mutation_system.gd

class_name KaijuComponent
class_name ComponentData
```

---

## Signals

Use signals to decouple gameplay systems.

Examples:

```gdscript
signal component_destroyed(component)
signal health_changed(current_health, max_health)
signal target_changed(target)
signal mutation_added(mutation)
signal combat_finished(result)
```

Avoid directly traversing large scene trees to notify unrelated systems.

---

## Composition

Prefer composition.

Good:

```text
Kaiju
├── MovementController
├── BrainController
├── AnatomyController
└── ResourceController
```

Avoid putting movement, AI, anatomy, combat, mutations, audio, and UI logic into a single `kaiju.gd`.

---

## State Ownership

Every important piece of state should have one clear owner.

Examples:

```text
AnatomyController
→ owns biological component graph

BrainController
→ owns AI decisions

ResourceController
→ owns energy / biomass / oxygen

RunManager
→ owns current run progression
```

Avoid duplicate state.

---

# Performance

Battles may run for several minutes and contain many simultaneous enemies, projectiles, particles, and sprite animations.

Prefer:

- object pooling for common projectiles and effects
- cached node references
- event-driven encounter triggers
- simple lane/progression-axis AI
- staggered target scans
- disabling expensive logic for dead/off-screen entities
- sprite atlases / shared `SpriteFrames`
- reusing enemy scenes
- conservative particle counts
- despawning or pooling enemies far behind the active battle area
- separating background decoration from physics
- limiting navigation complexity because the game is primarily side-scrolling

Avoid treating the battle like an unrestricted 3D RTS.

Most ground combat should be solvable with:

```text
horizontal distance
limited depth/lane offset
engagement range
line of sight
target priority
```

Brain decisions do not need to run every frame.

Suggested starting frequencies:

```text
high-level brain evaluation: 4-8 Hz
target scanning: 2-5 Hz
encounter progression checks: event-driven where possible
```

# Development Priority

Always prioritize proving the complete gameplay rhythm.

Order:

1. Create one side-scrolling 2.5D test level.
2. Create fixed side-view camera and scroll behavior.
3. Place the kaiju on the left side of the screen.
4. Implement slow autonomous forward movement.
5. Make the world visually scroll left as progression advances.
6. Create modular retro-pixel kaiju body-part sprites.
7. Add one enemy that attacks automatically.
8. Make the kaiju automatically stop/engage/fight.
9. Add encounter trigger zones and wave spawning.
10. Add battle progress tracking.
11. Add final boss encounter.
12. Add explicit battle result states.
13. Return to giant laboratory after battle.
14. Show battle damage in the lab.
15. Add regeneration.
16. Add XP and level-up.
17. Add organ replacement/upgrading.
18. Redeploy with the modified kaiju.
19. Expand enemy variety and mutations.
20. Add polish, VFX, audio, additional levels, and meta progression.

Do not build complex procedural generation, large research trees, or many enemy factions before steps 1-18 work.

# Agent Behavior

When implementing a feature:

1. Inspect existing project structure first.
2. Reuse existing systems where appropriate.
3. Avoid rewriting unrelated code.
4. Keep changes focused.
5. Prefer small reusable components.
6. Use typed GDScript.
7. Keep gameplay content data-driven.
8. Add comments only where behavior is non-obvious.
9. Do not introduce dependencies unless necessary.
10. Preserve compatibility with Godot 4.
11. Preserve the 2.5D architecture: 3D world logic + modular pixel-art `Sprite3D` visuals.
12. Preserve the side-scrolling battle direction: kaiju starts on the left and the environment scrolls left as progress moves forward.
13. Do not replace the battle with a free-roaming 3D arena.
14. Do not replace the modular sprite pipeline with full 3D character rigs unless explicitly requested.
15. Do not introduce manual action-game controls unless explicitly requested.
16. Keep battles autonomous.
17. Keep the lab as a real gameplay phase, not just a pause menu.
18. After battle completion, return the persistent kaiju state to the lab rather than creating an unrelated new specimen.
19. Boss encounters belong at or near the end of standard battle maps.
20. Preserve the retro pixel-art visual direction.

# Feature Completion Criteria

A gameplay feature is complete when:

- it runs without errors
- it is integrated into the actual game loop
- it has reasonable defaults
- it is visible/testable in-game
- it does not require manual editor setup unless documented
- relevant signals and data resources are connected
- existing gameplay still works

Do not consider isolated scripts complete if they are never instantiated or exercised.

---

# Debugging

Prefer debug visualizations for complex systems.

Potential toggles:

```text
show_ai_target
show_component_health
show_anatomy_connections
show_navigation_target
show_resource_flow
show_damage_events
```

Debug tools should be easy to disable for release builds.

---

# Testing

When adding systems, test at minimum:

- battle starts with kaiju on the left side of the screen
- kaiju advances automatically
- camera/world scrolling creates the intended leftward scene motion
- kaiju stops or slows when engaging threats
- enemy waves trigger correctly
- enemies can attack the kaiju
- kaiju can autonomously acquire and attack targets
- component damage persists through battle result generation
- battle can end from kaiju death
- battle can end when required enemies are defeated
- boss encounter triggers at the end of the level
- battle can end from boss defeat
- battle result is passed to the lab
- damaged organs appear damaged in the lab
- regeneration restores organ state
- XP can level the kaiju
- organs can be replaced/upgraded
- changed organs appear visually
- changed build persists into the next deployment

For deterministic systems, prefer automated tests where practical.

# Art Direction

The target visual identity is:

- retro pixel-art 2.5D
- side-scrolling battle composition
- giant kaiju occupying the left side of the battlefield
- horizontally scrolling war zones
- modular 2D pixel-art kaiju body parts placed in 3D space
- layered parallax scenery
- ruined cities, industrial zones, military installations, alien biomes, and other large-scale environments
- grotesque biotechnology
- experimental laboratory organisms
- readable silhouettes
- visible mutation
- exaggerated biological weapons
- scientific instrumentation
- controlled body horror rather than pure gore
- dramatic size contrast between kaiju and soldiers/vehicles
- massive boss silhouettes at the end of maps

The laboratory should share the retro-pixel style but feel much more controlled and technological than battlefields.

The kaiju should visibly evolve across deployments.

A successful high-level specimen should be recognizable from its silhouette alone.

## Pixel-Art Asset Rules

All gameplay sprites should follow consistent production rules:

- transparent PNG or sprite atlas
- nearest-neighbor filtering
- no unintended smoothing
- consistent side-view camera angle
- consistent light direction
- consistent approximate pixel density
- intentional pivot point
- documented compatible socket type
- enough canvas around animated extremities to prevent clipping
- clear damaged / regenerating states where useful
- limited animation frame counts with strong poses

Do not simply shrink detailed painted illustrations and call them pixel art.

Prefer assets designed around pixel clusters and readable low-resolution shapes.

## Body-Part Asset Rules

Kaiju body parts should be authored to combine cleanly.

Each part should define:

```text
socket_type
pivot
layer_order
base_scale
animation_set
damage_variants
compatible_overlays
```

Prefer reusable sprite layers for:

- wounds
- armor
- tumors
- glowing energy
- poison
- electricity
- parasites
- regeneration tissue
- temporary status effects

The final assembled kaiju may intentionally become visually messy and mutated, but socket alignment must remain deterministic.

## Scale

The kaiju should feel huge.

Use visual scale cues such as:

- tiny soldiers
- tanks reaching only partway up the legs
- helicopters near the head
- buildings in background layers
- dust clouds at footsteps
- large projectile impacts
- lab workers and machinery surrounding the regeneration platform

Bosses should be large enough to visually signal the end of a battle.

# Design Rule

When considering a new feature, ask:

> Does this make designing the organism, watching it fight, or learning from its failure more interesting?

If not, it is probably not a priority.

---

# Current Goal

Build the smallest possible prototype where:

1. The game opens in a giant retro-pixel Kaiju Lab.
2. The player can inspect a modular kaiju and change at least one organ.
3. The player deploys the kaiju.
4. Battle begins with the kaiju on the left side of a 2.5D side-scrolling level.
5. The kaiju slowly advances automatically.
6. The scene/world scrolls left as level progress moves forward.
7. Enemies appear according to encounter triggers and attack automatically.
8. The kaiju autonomously stops, targets, and fights.
9. The battle lasts long enough to observe the build working.
10. The kaiju reaches a final boss.
11. The battle correctly resolves from kaiju death, required-enemy completion, or boss defeat.
12. The game returns to the lab.
13. Battle damage is visible on the kaiju.
14. The kaiju regenerates.
15. XP/rewards are applied.
16. The player can level up or replace/upgrade an organ.
17. The visual kaiju sprite assembly changes.
18. The modified specimen can be deployed again.

Everything else is secondary until this complete **LAB → BATTLE → BOSS → LAB** loop is fun.