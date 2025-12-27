shader_type canvas_item;

uniform vec4 flash_color : source_color = vec4(1.0);
uniform float opacity : hint_range(0.0,1.0) = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 current_color = texture(TEXTURE,UV);
	if (current_color.a == 0.0){
		discard;
	}
	COLOR = mix(current_color, flash_color, opacity);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
