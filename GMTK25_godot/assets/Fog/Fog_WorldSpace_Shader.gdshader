shader_type canvas_item;

uniform sampler2D fog_image : repeat_enable, filter_nearest; // texture expose
uniform float speed = 1.0;
uniform float scale = 0.0001;
uniform vec4 fog_color : source_color;
//uniform vec4 fog_color_g : source_color;
//uniform vec4 fog_color_b : source_color;

varying vec2 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    float t = fract(TIME * speed);

    vec2 base_uv = world_position * scale;

    vec2 offset_r = vec2( t, 0.0);
    vec2 offset_g = vec2(-t, 0.0);
    vec2 offset_b = vec2(0.0,  t);

    float fog_r = texture(fog_image, fract(base_uv + offset_r)).r;
    float fog_g = texture(fog_image, fract(base_uv + offset_g)).g;
    float fog_b = texture(fog_image, fract(base_uv + offset_b)).b;
	
	
	//float clinear = 0.2126 * fog_r + 

    //vec3 newcolor = vec3(fog_r, fog_g, fog_b);
	 vec3 newcolor_r = vec3(fog_r, fog_r, fog_r);
	 vec3 newcolor_g = vec3(fog_g, fog_g, fog_g);
	 vec3 newcolor_b = vec3(fog_b, fog_b, fog_b);
	vec3 finalcolor = newcolor_r * newcolor_g * newcolor_b;

    // alpha
    float base_alpha = texture(TEXTURE, UV).a;

	COLOR.rgb = fog_color.rgb * finalcolor.rgb;
	COLOR.a = fog_color.a * base_alpha;
	//COLOR.rgb = newcolor * fog_color.rgb;
	//COLOR = vec4((newcolor_r * fog_color_r.rgb).r, (newcolor_g * fog_color_g.rgb).g, (newcolor_b * fog_color_b.rgb).b, 1.0);
	//COLOR.a = clamp(base_alpha * 5.0 * texture(TEXTURE, UV).a, 0.0, 1.0);
   	// COLOR = vec4(newcolor, orig_alpha);
}