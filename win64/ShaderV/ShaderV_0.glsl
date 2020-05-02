vec4 qmul(vec4 a, vec4 b)
{
  vec4 r;
  r.w = a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z;
  r.x = a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y;
  r.y = a.w * b.y - a.x * b.z + a.y * b.w + a.z * b.x;
  r.z = a.w * b.z + a.x * b.y - a.y * b.x + a.z * b.w;
  return r;
}

void main()
{
  float time = gl_TexCoord[0].s * 0.001;

  vec2 st = -1.0 + 2.0 * (gl_FragCoord.xy / vec2(1280, 720));

  float y = cos(sin(4.0 * st.x + time)) - 0.5;

  gl_FragColor = vec4(st, y, 1.0);
}
