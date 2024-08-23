extends ColorRect

@export var blur_amount: float = 5.0

func _ready():
    # Create a new ShaderMaterial
    var shader_material = ShaderMaterial.new()
    
    # Load the shader
    shader_material.shader = load("res://blur_shader.gdshader")
    
    # Set the material for this ColorRect
    material = shader_material
    
    # Set the initial blur amount
    set_blur_amount(blur_amount)

func set_blur_amount(amount: float):
    blur_amount = amount
    if material:
        material.set_shader_parameter("blur_amount", blur_amount)