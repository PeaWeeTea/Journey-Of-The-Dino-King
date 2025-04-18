# 🦖 Journey of The Dino King

### 🎥 Video Demo: [Watch on YouTube](https://www.youtube.com/watch?v=_pOJ4kot4FE)  
### 🕹️ Play the Game: [Play on Itch.io](https://peatea16.itch.io/journey-of-the-dino-king)

---

## 📜 Description

**Journey of The Dino King** is a 2D top-down wave-based shooter built in **Godot 4.2.2** using **GDScript**. Players control a dinosaur warrior using `WASD` to move and the `Arrow Keys` to fire in different directions. Each level presents increasingly intense enemy waves. Survive them all and become the true Dino King.

---

## 🏗 Project Structure

### `Notes/`
Developer-only notes and reference files. Not required for gameplay, but useful during development for idea planning and implementation strategies.

### `assets/`
Contains all visual and audio resources:
- Sprites and animations
- Fonts
- Sound effects
- App icon for Windows builds

### `scenes/`
Houses all `.tscn` scene files used in the game. These are the structural blueprints of the game, combining art, sound, and logic.

### `scripts/`
Includes all GDScript files connected to their respective scenes. These are responsible for gameplay logic, input handling, enemy behavior, spawning, and UI updates.

---

## 💡 Developer Reflection

This project taught me a lot about scope and debugging. I learned firsthand how programming tasks can take **much longer than expected**—what I thought would take 30 minutes could easily take 2 hours… and introduce 3 new bugs along the way. Still, I’m proud of how it turned out, especially one script I spent a lot of time on:

---

# ⚔ Enemy Spawn System (GDScript Overview)

This script, attached to a `Node2D`, handles **enemy spawning** in a Godot game. It manages enemy waves, spawn timing, and difficulty scaling based on game progression.

---

## ⏮ Preloaded Scenes & Node References

```gdscript
var enemy_scene = preload("res://scenes/enemy.tscn")
@onready var spawn_timer = $SpawnTimer
@onready var player = get_node("../Player")
```

- `enemy_scene`: Preloaded enemy scene to instantiate during spawns.
- `spawn_timer`: Timer node used for scheduling spawn events.
- `player`: Reference to the player node (assumed to be a sibling of this node).

---

## ✨ Spawn Point Management

```gdscript
@onready var spawn_door_dict = {
    "up" : get_tree().get_nodes_in_group("up_enemy_spawn_points"),
    "right" : get_tree().get_nodes_in_group("right_enemy_spawn_points"),
    "down" : get_tree().get_nodes_in_group("down_enemy_spawn_points"),
    "left" : get_tree().get_nodes_in_group("left_enemy_spawn_points")
}

@onready var spawn_queue_dict = {
    "up" : 0,
    "right" : 0,
    "down" : 0,
    "left" : 0
}
```

- **`spawn_door_dict`**: Dictionary containing arrays of spawn points grouped by direction (`"up"`, `"right"`, `"down"`, `"left"`).
- **`spawn_queue_dict`**: Tracks queued enemy count per direction before they are actually spawned.

---

## 😖 Difficulty and Spawning Configuration

```gdscript
var difficulty_timer: float = 20.0
var difficulty_level = 0
@export var enemy_wave_spawn_time_range = [1.0, 2.0]
@export var MAX_NUM_SPAWN_PER_DOOR = 4
@export var num_enemy_spawn_per_wave_range = [1, 6]
```

- `difficulty_timer`: Time remaining until the next difficulty increase.
- `difficulty_level`: Current difficulty level; 0 disables spawning.
- `enemy_wave_spawn_time_range`: Range for randomizing spawn wave intervals.
- `MAX_NUM_SPAWN_PER_DOOR`: Maximum number of enemies that can spawn per door in a single wave.
- `num_enemy_spawn_per_wave_range`: Range of enemies to spawn per wave.

---

## 🔄 Main Game Loop: `_physics_process(delta)`

```gdscript
func _physics_process(delta):
    if difficulty_level == 0:
        if not spawn_timer.is_stopped():
            spawn_timer.stop()
        return

    if spawn_timer.is_stopped():
        spawn_timer.start()

    spawn_enemies_in_spawn_queue()

    difficulty_timer -= delta
    if difficulty_timer <= 0:
        increase_difficulty()
        difficulty_timer = 20.0
```

Handles the core runtime behavior:

1. Stops the timer if difficulty is 0.
2. Starts the timer if it's stopped and difficulty > 0.
3. Spawns any queued enemies (up to 3 per door).
4. Reduces `difficulty_timer` and increases difficulty when it hits zero.

---

## ⏲ Spawn Timer Callback: `_on_spawn_rate_timeout()`

```gdscript
func _on_spawn_rate_timeout():
    if difficulty_level == 0:
        return

    randomize_wait_time(difficulty_level)

    var enemy_amount_to_spawn = get_random_amount_of_enemies()
    var enemies_to_spawn_dict = get_enemies_to_spawn(enemy_amount_to_spawn)

    for direction in enemies_to_spawn_dict.keys():
        spawn_queue_dict[direction] += enemies_to_spawn_dict[direction]
```

Executed every time the spawn timer runs out:

- Randomizes the next spawn time.
- Chooses a random number of enemies.
- Selects which doors to spawn enemies from.
- Populates `spawn_queue_dict` with pending spawns.

---

## 👿 Enemy Spawning Logic: `spawn_enemies_in_spawn_queue()`

```gdscript
func spawn_enemies_in_spawn_queue():
    for direction in spawn_queue_dict.keys():
        if spawn_queue_dict[direction] <= 0:
            continue
        if has_blocked_spawn_door(direction):
            continue

        for i in range(spawn_queue_dict[direction]):
            if i >= 3 or spawn_queue_dict[direction] <= 0:
                break
            var spawn_point = spawn_door_dict[direction][i].global_position
            if player != null:
                spawn_enemy(enemy_scene, spawn_point)
                spawn_queue_dict[direction] -= 1
```

- Iterates over directions in `spawn_queue_dict`.
- Checks if the door is unblocked.
- Spawns up to 3 enemies from that door’s queue.
- Reduces the count from the spawn queue accordingly.

---

## ❌ Spawn Blocking Check: `has_blocked_spawn_door(direction)`

```gdscript
func has_blocked_spawn_door(spawn_door_direction) -> bool:
    if spawn_door_direction == "up" and $UpSpawnDoorDetector.has_overlapping_bodies():
        return true
    elif spawn_door_direction == "right" and $RightSpawnDoorDetector2.has_overlapping_bodies():
        return true
    elif spawn_door_direction == "down" and $DownSpawnDoorDetector3.has_overlapping_bodies():
        return true
    elif spawn_door_direction == "left" and $LeftSpawnDoorDetector4.has_overlapping_bodies():
        return true
    else:
        return false
```

Checks whether a given door's detector overlaps with other bodies (e.g. player or enemies). Returns `true` if blocked.

---

## 🎲 Random Utility Functions

### `get_enemies_to_spawn(number_of_enemies_to_spawn)`

```gdscript
func get_enemies_to_spawn(number_of_enemies_to_spawn: int):
    var selected_enemies_to_spawn_dict = {}
    var num_doorways = 4
    var chosen_indices = []
    var doorways = spawn_door_dict.keys()

    while chosen_indices.size() < num_doorways:
        var index = randi_range(0, 3)
        if index not in chosen_indices:
            chosen_indices.append(index)
            selected_enemies_to_spawn_dict[doorways[index]] = 0

    var i = 0
    var selected_doorways = selected_enemies_to_spawn_dict.keys()
    while number_of_enemies_to_spawn > 0:
        if number_of_enemies_to_spawn < MAX_NUM_SPAWN_PER_DOOR:
            MAX_NUM_SPAWN_PER_DOOR = number_of_enemies_to_spawn
        var iterated_doorway = selected_doorways[i % selected_doorways.size()]
        var rand_num = randi_range(0, MAX_NUM_SPAWN_PER_DOOR)
        selected_enemies_to_spawn_dict[iterated_doorway] += rand_num
        number_of_enemies_to_spawn -= rand_num
        i += 1

    return selected_enemies_to_spawn_dict
```

Distributes a total number of enemies randomly among selected doorways and returns a dictionary like:

```gdscript
{ "up": 2, "right": 1, "left": 3 }
```

---

### `get_random_amount_of_enemies()`

```gdscript
func get_random_amount_of_enemies():
    return randi_range(num_enemy_spawn_per_wave_range[0], num_enemy_spawn_per_wave_range[1])
```

Returns a random number of enemies to spawn in the next wave.

---

### `randomize_wait_time(level_of_difficulty)`

```gdscript
func randomize_wait_time(level_of_difficulty):
    spawn_timer.stop()
    $SpawnTimer.wait_time = randf_range(enemy_wave_spawn_time_range[0], enemy_wave_spawn_time_range[1])
    spawn_timer.start()
```

Randomizes the spawn interval within the configured range and restarts the timer.

---

## 📈 Difficulty Scaling Stub

```gdscript
func increase_difficulty():
    pass
```

Placeholder for increasing difficulty over time.

---

## 🔚 Ending the Level

```gdscript
func _on_level_timer_timeout():
    difficulty_level = 0
```

Disables all spawning by resetting the difficulty level when the level ends.

---

## 🚀 Technologies Used

- **Game Engine**: Godot 4.2.2  
- **Language**: GDScript  

---

## 👾 Contact & Feedback

I've slowed down on updating this project but would  love hearing feedback. Feel free to [open an issue](https://github.com/PeaWeeTea/Journey-Of-The-Dino-King/issues) or drop a comment on the YouTube video.

---
