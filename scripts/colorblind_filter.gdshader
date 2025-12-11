shader_type canvas_item;

// This texture lets us grab the pixels from the screen behind the ColorRect
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

// 0 = Normal, 1 = Protanopia, 2 = Deuteranopia, 3 = Tritanopia
uniform int mode : hint_range(0, 3) = 0; 
uniform float intensity : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 screen_color = texture(screen_texture, SCREEN_UV);
    
    // Matrix data for simulating color blindness (LMS color space conversions)
    // These help us calculate what the user CANNOT see, so we can shift it.
    
    // Protanopia (Red-Blind)
    mat3 protan_matrix = mat3(
        vec3(0.567, 0.433, 0.0),
        vec3(0.558, 0.442, 0.0),
        vec3(0.0, 0.242, 0.758)
    );
    
    // Deuteranopia (Green-Blind)
    mat3 deutan_matrix = mat3(
        vec3(0.625, 0.375, 0.0),
        vec3(0.7, 0.3, 0.0),
        vec3(0.0, 0.3, 0.7)
    );
    
    // Tritanopia (Blue-Blind)
    mat3 tritan_matrix = mat3(
        vec3(0.95, 0.05, 0.0),
        vec3(0.0, 0.433, 0.567),
        vec3(0.0, 0.475, 0.525)
    );
    
    vec3 color = screen_color.rgb;
    vec3 original = color;
    
    // 1. Simulate what the color blind person sees
    vec3 simulated = color;
    if (mode == 1) { simulated = color * protan_matrix; }
    else if (mode == 2) { simulated = color * deutan_matrix; }
    else if (mode == 3) { simulated = color * tritan_matrix; }
    
    // 2. Calculate the error (Difference between true color and what they see)
    vec3 error = (original - simulated);
    
    // 3. Shift the error into visible channels (Daltonization)
    vec3 correction = vec3(0.0);
    
    // Setup shift vector: [0] moves error to Blue, [1] moves to Red, [2] moves to Green/Red
    // Adjust these numbers to taste if the effect is too strong/weak
    if (mode == 1) { 
        // Protanopia: Shift Red error into Blue/Green
        correction.b = error.r * 0.7; 
        correction.g = error.r * 0.7;
    } else if (mode == 2) { 
        // Deuteranopia: Shift Green error into Blue/Red
        correction.b = error.g * 0.7;
        correction.r = error.g * 0.7;
    } else if (mode == 3) { 
        // Tritanopia: Shift Blue error into Red/Green
        correction.r = error.b * 0.7;
        correction.g = error.b * 0.7;
    }
    
    // Apply correction
    color = simulated + correction;
    
    // Mix based on intensity (0.0 = original game, 1.0 = full correction)
    COLOR = vec4(mix(original, color, intensity), screen_color.a);
}