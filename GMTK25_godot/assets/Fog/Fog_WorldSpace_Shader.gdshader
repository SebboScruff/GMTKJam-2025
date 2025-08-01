shader_type canvas_item;

uniform sampler2D noise_img;

void fragment(){
		COLOR.r = texture( noise_img, UV);
		
}