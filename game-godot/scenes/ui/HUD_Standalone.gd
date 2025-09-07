extends Node2D

func _ready() -> void:
    print("[HUD_Standalone] Script starting...")
    print("[HUD_Standalone] Node type: ", get_class())
    print("[HUD_Standalone] Parent: ", get_parent())

    # Create health section
    var health_label = Label.new()
    health_label.text = "HEALTH: "
    health_label.modulate = Color.RED
    health_label.position = Vector2(50, 50)
    add_child(health_label)
    
    # Add heart symbols
    for i in range(3):
        var heart = Label.new()
        heart.text = "❤️"
        heart.modulate = Color.RED
        heart.position = Vector2(120 + i * 30, 50)
        add_child(heart)
    
    # Create stamina section
    var stamina_label = Label.new()
    stamina_label.text = "STAMINA: "
    stamina_label.modulate = Color.GREEN
    stamina_label.position = Vector2(50, 80)
    add_child(stamina_label)
    
    # Add stamina blocks
    for i in range(5):
        var block = Label.new()
        block.text = "▮"
        block.modulate = Color.GREEN
        block.position = Vector2(120 + i * 20, 80)
        add_child(block)
    
    # Create ammo section
    var ammo_label = Label.new()
    ammo_label.text = "AMMO: "
    ammo_label.modulate = Color.YELLOW
    ammo_label.position = Vector2(50, 110)
    add_child(ammo_label)
    
    # Add ammo dots
    for i in range(3):
        var dot = Label.new()
        dot.text = "●"
        dot.modulate = Color.YELLOW
        dot.position = Vector2(120 + i * 20, 110)
        add_child(dot)
    
    # Add empty ammo dots
    for i in range(3):
        var empty_dot = Label.new()
        empty_dot.text = "○"
        empty_dot.modulate = Color.GRAY
        empty_dot.position = Vector2(200 + i * 20, 110)
        add_child(empty_dot)
    
    print("[HUD_Standalone] All elements created successfully!")
    
    # Add a big obvious test label
    var test_label = Label.new()
    test_label.text = "HUD_STANDALONE SCRIPT IS RUNNING!"
    test_label.modulate = Color(1, 1, 0) # bright yellow
    test_label.position = Vector2(50, 200)
    add_child(test_label)

