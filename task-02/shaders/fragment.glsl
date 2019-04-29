#version 330 core

out vec3 color;

in vec2 UV;

uniform sampler2D fragment_texture;
uniform int has_texture;

void main() {
    vec3 local_color;
    if (has_texture == 1) {
        local_color = texture(fragment_texture, UV).rgb;
    } else {
        local_color = vec3(1.0f, 0.0f, 0.0f);
    }
    color = local_color;
}
