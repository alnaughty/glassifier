#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;         // Screen size
uniform sampler2D uTexture; // Background image
uniform float uCount;         // Number of liquid elements
uniform vec4 uElements[20]; // x,y = position | z,w = width,height
uniform float uRadii[20];   // Radii for each element
uniform vec4 uColors[20];   // Colors for each element
uniform float uGooFactor;   // How "melty" the merge is (e.g., 30.0)

out vec4 fragColor;

// The "Gooey" Math: Smooth Minimum
float smin(float a, float b, float k) {
    float h = max(k - abs(a - b), 0.0) / k;
    return min(a, b) - h * h * k * (1.0 / 4.0);
}

// Rounded Box Distance Function
float sdBox(vec2 p, vec2 b, float r) {
    vec2 q = abs(p) - b + r;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void main() {
    vec2 p = FlutterFragCoord().xy;
    vec2 uv = p / uSize;
    
    // 1. Calculate the Unified Field and Gradient in a single pass
    float d = 1e10; 
    vec4 mixedColor = vec4(0.0);
    float totalWeight = 0.0;
    
    // Sampling offsets for gradient (central difference or forward difference)
    float delta = 1.0;
    float dx_f = 1e10;
    float dy_f = 1e10;

    int count = int(uCount);
    for(int i = 0; i < 20; i++) {
        if (i >= count) break;
        
        vec2 center = uElements[i].xy;
        vec2 halfSize = uElements[i].zw * 0.5;
        float r = uRadii[i];
        vec4 col = uColors[i];
        
        float d_i = sdBox(p - center, halfSize, r);
        float dx_i = sdBox(p + vec2(delta, 0.0) - center, halfSize, r);
        float dy_i = sdBox(p + vec2(0.0, delta) - center, halfSize, r);
        
        // Accumulate field
        d = smin(d, d_i, uGooFactor);
        dx_f = smin(dx_f, dx_i, uGooFactor);
        dy_f = smin(dy_f, dy_i, uGooFactor);

        // Accumulate color
        float w = smoothstep(uGooFactor * 2.0, -uGooFactor * 0.5, d_i);
        mixedColor += col * w;
        totalWeight += w;
    }

    if (totalWeight > 0.0) mixedColor /= totalWeight;

    // 2. Discard pixels outside the liquid
    if (d > 0.0) {
        fragColor = texture(uTexture, uv);
        return;
    }

    // 3. Smooth Normal Calculation (Dynamic Curvature)
    // To avoid the "roof" look, we need the surface to be a dome, not a pyramid.
    // 'd' is negative inside the shape. 
    vec2 grad = (vec2(dx_f, dy_f) - d) / delta;
    
    // We calculate a dynamic Z (height) based on the distance from the edge.
    // This makes the center of the blob flat and the edges curved.
    float bulge = 0.15 + 0.8 * smoothstep(0.0, -25.0, d);
    vec3 normal = normalize(vec3(grad, bulge));

    // 4. Premium Refraction
    // Dynamic refraction strength that increases at the curved edges
    float edgeMask = smoothstep(0.0, -15.0, d);
    float refractionStrength = 0.06 * (1.0 - edgeMask * 0.5);
    float abnm = 0.012 * (1.0 - edgeMask * 0.8);
    
    vec2 uvR = uv + normal.xy * (refractionStrength + abnm);
    vec2 uvG = uv + normal.xy * refractionStrength;
    vec2 uvB = uv + normal.xy * (refractionStrength - abnm);
    
    vec3 scene;
    scene.r = texture(uTexture, clamp(uvR, 0.0, 1.0)).r;
    scene.g = texture(uTexture, clamp(uvG, 0.0, 1.0)).g;
    scene.b = texture(uTexture, clamp(uvB, 0.0, 1.0)).b;
    
    // Tinting the glass
    scene = mix(scene, mixedColor.rgb, mixedColor.a * 0.4);

    // 5. Lighting (Premium Polish)
    vec3 lightDir = normalize(vec3(0.5, 0.5, 1.0));
    vec3 viewDir = vec3(0.0, 0.0, 1.0);
    
    // Specular
    vec3 halfV = normalize(lightDir + viewDir);
    float spec = pow(max(dot(normal, halfV), 0.0), 128.0);
    
    // Fresnel (Outer Rim Glow)
    float fresnel = pow(1.0 - max(dot(normal, viewDir), 0.0), 3.0);
    
    // Combine lighting
    scene += vec3(1.0) * spec * 0.8;          // Main glint
    scene += mixedColor.rgb * fresnel * 0.3; // Colored rim
    scene += vec3(1.0) * fresnel * 0.1;      // Bright rim

    // Subtle Inner Depth Shadows
    float innerShadow = smoothstep(0.0, -30.0, d);
    scene *= mix(0.9, 1.0, innerShadow);

    fragColor = vec4(scene, 1.0);
}


