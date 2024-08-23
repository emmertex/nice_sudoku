shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0, 10);

void fragment() {
    vec2 pixel_size = 1.0 / vec2(textureSize(SCREEN_TEXTURE, 0));
    vec4 color = vec4(0.0);
    float total_weight = 0.0;

    for (float x = -2.0; x <= 2.0; x += 1.0) {
        for (float y = -2.0; y <= 2.0; y += 1.0) {
            vec2 offset = vec2(x, y) * pixel_size * blur_amount;
            float weight = exp(-dot(offset, offset));
            color += textureLod(SCREEN_TEXTURE, SCREEN_UV + offset, 0.0) * weight;
            total_weight += weight;
        }
    }

    COLOR = color / total_weight;
}