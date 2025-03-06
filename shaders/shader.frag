#version 300 es
precision highp float;

uniform vec2 uResolution;
uniform sampler2D uTexture;
uniform float uBulge;
uniform vec2 uOffset;

out vec4 fragColor;

void main() {
 
  vec2 uv = (gl_FragCoord.xy - uOffset) / uResolution;
  vec2 center = vec2(0.5, 0.5);
  float dist = length(uv - center);

 
  float scale = 1.0 / (1.0 + uBulge * dist * dist);

 

  vec2 newUv = center + (uv - center) * scale;
 
  if (newUv.x < 0.0 || newUv.x > 1.0 || newUv.y < 0.0 || newUv.y > 1.0) {
    fragColor = vec4(0.0, 0.0, 0.0, 0.0);
  } else {
    fragColor = texture(uTexture, newUv);
  }
}