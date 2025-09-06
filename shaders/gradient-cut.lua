return [[

//extern vec2 screenSize;
extern float minX;
extern float distance;
extern float staffHeight;


vec4 effect(vec4 color, Image image, vec2 uv, vec2 screenCoords) {
   //vec2 screenUV = vec2(screenCoords.x / screenSize.x, screenCoords.y / screenSize.y);
   vec4 pixel = Texel(image, uv);
   
   float gradientAlpha = (screenCoords.x / staffHeight - minX) / distance;

   if (gradientAlpha > 1.0) {
      gradientAlpha = 1.0;
   }
   if (gradientAlpha < 0.0) {
      gradientAlpha = 0.0;
   }

   vec3 finalColor = pixel.xyz * color.xyz;
   float finalAlpha = pixel.a * color.a * gradientAlpha;

   return vec4(finalColor, finalAlpha);
   //return vec4(1, 1, 1, 1);
}

]]