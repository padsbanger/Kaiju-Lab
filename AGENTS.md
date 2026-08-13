# AGENTS.md — Kaiju Lab

## Project Overview

**Kaiju Lab** is a single-player roguelite autobattler built in **Godot 4**.

The player does not directly control a combat character. Instead, the player grows and engineers a giant biological monster by attaching organs, limbs, mutations, weapons, nervous systems, defensive structures, and symbiotic organisms.

The player's main task is to design a kaiju that can survive combat autonomously.

The central design principle is:

> **Build the organism. Watch the organism fight. Learn from failure. Mutate again.**

The kaiju should feel like a living biological machine rather than a normal RPG character wearing equipment.

---

# Visual and Technical Direction

**Kaiju Lab is a 3D game with modular 2D character visuals.**

The battlefield, navigation, collisions, projectiles, targeting, effects, and encounter logic exist in real 3D space. The kaiju is visually assembled from multiple transparent 2D body-part sprites placed in that 3D world using Godot `Sprite3D` / `AnimatedSprite3D` nodes.

The intended presentation is a stylized **2.5D** game:

```text
3D arena / terrain / buildings
        +
3D navigation / hitboxes / projectiles
        +
2D Sprite3D kaiju body parts
        +
fixed or controlled isometric camera
```

This hybrid approach is a core project constraint, not a temporary placeholder.

## Rendering Rules

For the MVP:

- use a fixed or tightly controlled elevated/isometric camera
- use `Sprite3D` or `AnimatedSprite3D` for kaiju body parts
- keep body-part textures on transparent backgrounds
- keep all body-part art in the same viewing angle and lighting style
- use consistent sprite scale / pixels-per-world-unit
- define intentional pivots for every sprite
- attach parts through explicit sockets rather than hardcoded world positions
- keep gameplay collision separate from sprite dimensions
- use 3D particles, decals, lighting, shadows, and projectiles where useful

Do **not** introduce a freely rotating gameplay camera until the project supports directional sprites or another technique that prevents the kaiju from looking like a flat cardboard cutout.

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

Destroying or replacing a sprite must not destroy gameplay state unless the corresponding gameplay component is actually removed.

## Sprite Body-Part System

Kaiju visuals are assembled like a modular animated paper doll in 3D space.

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
│   └── AcidGlandComponent
│       └── AcidGlandSprite
└── TailSocket
    └── TailComponent
        └── TailSprite
```

Mutations should preferably produce visible changes by:

- replacing a sprite
- adding another sprite component
- changing animation frames
- adding overlays such as armor, tumors, wounds, eyes, glands, or parasites
- changing sprite scale or transform within safe limits
- spawning extra attachment sockets when a mutation permits additional anatomy

A late-run kaiju should look increasingly unusual and visually communicate the player's build.

## Sprite Animation

Prefer independent component animation over one monolithic character animation.

Useful animation states include:

```text
idle
move
attack
charge
hurt
damaged
destroyed
active
cooldown
```

Examples:

- heart sprites pulse independently
- glands swell before firing
- tentacles animate independently
- claws play attack frames when their ability activates
- eyes blink or track targets
- damaged components switch to injured frames
- destroyed limbs may detach, fall, fade, or leave a stump sprite

Do not require every body part to have every animation.

## Directional Sprites

The MVP may use a single camera-facing or fixed-angle sprite set because the camera is controlled.

If camera rotation is added later, prefer directional variants such as:

```text
front
front_right
right
back_right
back
back_left
left
front_left
```

Four directions are acceptable before eight directions.

Do not generate directional sprite complexity until camera rotation materially improves the game.

## Environment and Enemies

The environment should be true 3D so arenas have real depth, obstacles, elevation, destruction targets, and projectile trajectories.

For enemies:

- `Sprite3D` / `AnimatedSprite3D` enemies are preferred for the initial art style
- simple 3D enemy meshes are acceptable when they improve readability
- enemy gameplay logic must remain independent of rendering choice

Do not require full 3D character rigs for ordinary units unless a specific feature clearly benefits from them.

---

# Core Gameplay Loop

1. Start with a basic kaiju organism.
2. Enter an encounter.
3. The kaiju fights automatically.
4. Earn biomass, DNA, research material, or mutation rewards.
5. Choose new organs, limbs, mutations, or behavioral upgrades.
6. Modify the kaiju's body.
7. Enter a harder encounter.
8. Repeat until the kaiju dies or completes the run.
9. Unlock persistent research and new biological components.
10. Start a new experiment.

---

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
├── ResearchManager
├── SceneManager
└── AudioManager

CombatScene
├── Arena3D
├── NavigationRegion3D
├── Kaiju : CharacterBody3D
│   ├── AnatomyController
│   ├── BrainController
│   ├── MovementController
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
└── CombatUI
```

Do not create huge scripts that manage unrelated systems.

---

# Suggested Project Structure

```text
res://
├── autoload/
│   ├── game_state.gd
│   ├── run_manager.gd
│   ├── research_manager.gd
│   └── scene_manager.gd
│
├── kaiju/
│   ├── kaiju.tscn
│   ├── kaiju.gd
│   │
│   ├── anatomy/
│   │   ├── anatomy_controller.gd
│   │   ├── attachment_point.gd
│   │   └── component_graph.gd
│   │
│   ├── brain/
│   │   ├── brain_controller.gd
│   │   ├── instincts/
│   │   └── behaviors/
│   │
│   ├── components/
│   │   ├── base/
│   │   ├── organs/
│   │   ├── limbs/
│   │   ├── weapons/
│   │   ├── armor/
│   │   └── parasites/
│   │
│   ├── resources/
│   │   ├── component_data.gd
│   │   ├── mutation_data.gd
│   │   └── brain_data.gd
│   │
│   └── visuals/
│       ├── component_visual.gd
│       ├── sprite_orientation.gd
│       └── sprite_animation_controller.gd
│
├── enemies/
│   ├── base/
│   ├── military/
│   ├── robots/
│   ├── kaiju/
│   └── aliens/
│
├── combat/
│   ├── damage/
│   ├── targeting/
│   ├── projectiles/
│   ├── effects/
│   └── status_effects/
│
├── encounters/
│   ├── combat_scene.tscn
│   ├── encounter_manager.gd
│   └── encounter_data/
│
├── progression/
│   ├── mutation_system.gd
│   ├── reward_system.gd
│   └── research_tree.gd
│
├── ui/
│   ├── lab/
│   ├── combat/
│   ├── mutation_selection/
│   └── research/
│
├── data/
│   ├── components/
│   ├── enemies/
│   ├── encounters/
│   └── mutations/
│
├── audio/
├── art/
│   ├── sprites/
│   │   ├── kaiju/
│   │   │   ├── bodies/
│   │   │   ├── heads/
│   │   │   ├── limbs/
│   │   │   ├── tails/
│   │   │   ├── glands/
│   │   │   ├── armor/
│   │   │   ├── parasites/
│   │   │   └── damage_states/
│   │   └── enemies/
│   ├── environments_3d/
│   └── vfx/
└── tests/
```

---

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

The first playable prototype should be small.

## Kaiju

Implement:

- one `CharacterBody3D` kaiju root
- one torso `AnimatedSprite3D`
- one brain
- one heart
- one stomach
- two weapon limbs represented by separate body-part sprites
- explicit `Node3D` attachment sockets
- simple 3D hitboxes for damageable components
- one optional mutation slot
- fixed/elevated gameplay camera

## Enemies

Implement:

- melee soldier
- ranged soldier
- tank

## Abilities

Implement:

- melee claw attack
- projectile/spit attack
- regeneration

## Combat

Implement:

- autonomous targeting in 3D space
- autonomous 3D movement/navigation
- automatic attacks
- real 3D projectiles or melee hit volumes
- component damage through 3D hitboxes
- visible sprite damage states
- kaiju death
- enemy death

## Progression

After each battle:

- present 3 random mutation choices
- player chooses 1
- mutation modifies the kaiju
- whenever practical, the mutation also visibly adds/replaces/changes a body-part sprite
- next encounter begins

Do not build the meta-progression research tree before the core combat loop is fun.

---

# First Prototype Loop

```text
Start Run
   ↓
Create Basic Kaiju
   ↓
Encounter
   ↓
Autonomous Battle
   ↓
Win?
 ├─ No → Run Ends
 └─ Yes
      ↓
  Mutation Selection
      ↓
 Modify Kaiju
      ↓
 Next Encounter
```

---

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

The player should understand what is happening without needing to inspect logs constantly.

Use:

- clear attack animations
- readable projectiles
- status icons
- damaged organ indicators
- floating damage sparingly
- ability activation indicators
- distinct audio cues
- visible destroyed body parts when possible

Avoid excessive visual noise.

Important events should be obvious:

```text
HEART DESTROYED

PLASMA GLAND OFFLINE

LEFT ARM SEVERED

REGENERATION ACTIVE
```

---

# Lab Phase

Between encounters, the player enters the lab interface.

The lab should eventually allow:

- viewing the assembled kaiju as a modular 2.5D specimen
- viewing anatomy
- attaching organs by socket
- replacing organs
- previewing sprite changes before committing
- inspecting connections
- viewing damage
- selecting mutations
- comparing components
- reviewing organism statistics

The lab is as important as combat.

The interface should make experimentation enjoyable.

---

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

Autobattlers can contain many enemies.

Keep common runtime systems lightweight.

Prefer:

- object pooling for projectiles when needed
- cached node references
- limited physics queries
- staggered AI updates
- event-based logic
- simple enemy navigation
- shared sprite atlases / `SpriteFrames` where practical
- disabling animation or reducing update frequency for distant/off-screen units
- keeping sprite presentation independent from expensive gameplay simulation

Avoid running expensive AI calculations every frame.

Example:

```gdscript
func _physics_process(delta: float) -> void:
    movement_controller.update_movement(delta)
```

But decision making can run less often:

```text
Brain evaluation:
5-10 times per second

Target scanning:
2-5 times per second
```

Adjust based on gameplay needs.

---

# Development Priority

Always prioritize a playable loop over infrastructure.

Order:

1. Create the 3D arena and fixed/elevated camera.
2. Create a kaiju root with modular `Sprite3D` / `AnimatedSprite3D` body parts.
3. Autonomous kaiju movement.
4. Autonomous targeting.
5. Basic attack.
6. Enemy combat.
7. Encounter completion.
8. Mutation reward.
9. Mutation visibly modifies the kaiju sprite assembly.
10. Multiple encounters.
11. Component hitboxes and damage states.
12. Component interactions.
13. Expanded organs.
14. Lab UI.
15. Meta progression.
16. Polish.

Do not build complex procedural generation before steps 1-8 work.

---

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
11. Preserve the 2.5D architecture: 3D gameplay + modular 2D body-part sprites.
12. Do not replace the modular sprite pipeline with full 3D character rigs unless explicitly requested.
13. Keep visual nodes separate from gameplay state and collision logic.

---

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

- kaiju can acquire a target
- kaiju can attack
- enemy can damage kaiju
- component can be destroyed
- destroyed component stops functioning
- encounter can end
- mutation can be selected
- mutation affects following battle

For deterministic systems, prefer automated unit-style tests where practical.

---

# Art Direction

The target visual identity is:

- stylized 2.5D presentation
- true 3D arenas and environmental depth
- modular 2D kaiju body-part sprites placed in 3D space
- grotesque biotechnology
- experimental laboratory organisms
- readable silhouettes
- modular anatomy
- visible mutation
- exaggerated biological weapons
- scientific instrumentation
- controlled body horror rather than pure gore
- strong sprite silhouettes that remain readable from the gameplay camera

The monster should visibly evolve during a run.

A successful late-run kaiju should look meaningfully different from the starting organism, ideally recognizable from its silhouette alone.

## Body-Part Asset Rules

All body-part sprites should follow consistent production rules:

- transparent PNG or sprite atlas input
- consistent camera/view angle
- consistent light direction
- consistent approximate pixel density
- intentional pivot point
- documented compatible socket type
- enough empty canvas around animated extremities to prevent clipping
- damage variants only when they add useful combat readability

Do not paint permanent effects into a base sprite if they can be represented as reusable overlays.

Prefer reusable sprite layers for:

- wounds
- armor plates
- tumors
- glowing energy
- poison
- electricity
- parasites
- temporary status effects

---

# Design Rule

When considering a new feature, ask:

> Does this make designing the organism, watching it fight, or learning from its failure more interesting?

If not, it is probably not a priority.

---

# Current Goal

Build the smallest possible prototype where:

1. A modular kaiju made from multiple 2D body-part sprites exists inside a 3D arena.
2. The kaiju autonomously moves and fights enemies using real 3D gameplay logic.
3. The player wins an encounter.
4. The player chooses one of three mutations.
5. The chosen mutation physically or behaviorally changes the kaiju and, whenever possible, visibly changes its sprite assembly.
6. The next encounter demonstrates the effect.

Everything else is secondary until this loop is fun.
