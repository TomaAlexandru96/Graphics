#version 410 

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

uniform mat4 mvMatrix;
uniform mat4 pMatrix;
uniform mat3 normalMatrix; //mv matrix without translation

uniform vec4 lightPosition_camSpace; //light Position in camera space

uniform int time;

float rnd(vec2 x)
{
int n = int(x.x * 40.0 + x.y * 6400.0);
n = (n << 13) ^ n;
return 1.0 - float( (n * (n * n * 15731 + 789221)
+ 1376312589) & 0x7fffffff) / 1073741824.0;
}

in data
{
  vec4 position_camSpace;
  vec3 normal_camSpace;
  vec2 textureCoordinate;
  vec4 color;
}vertexIn[3];

out fragmentData
{
  vec4 position_camSpace;
  vec3 normal_camSpace;
  vec2 textureCoordinate;
  vec4 color;
} frag;

float lerp(float x, float y, float alpha) {
  return x + alpha * (y - x);
}

vec4 displace(vec4 position, vec3 normal)
{
	float t = time;
	// float random = rnd(vec2(rnd(normal.xy), t));
	float random = rnd(position.xy);
	vec4 displacement = vec4(
		lerp(position.x, normal.x, random),
		lerp(position.y, normal.y, random),
		lerp(position.z, normal.z, random),
		position.w + 50
	) - position;
	//return vec4(0, 0, 0, 0);
	return displacement;
}

void main() {
  for (int i = 0; i < 3; i++) { // You used triangles, so it's always 3
	vec4 displacement_difference = displace(vertexIn[i].position_camSpace, vertexIn[i].normal_camSpace);
    gl_Position = gl_in[i].gl_Position + displacement_difference;
    frag.position_camSpace = vertexIn[i].position_camSpace + displacement_difference;
    frag.normal_camSpace = vertexIn[i].normal_camSpace;
    frag.textureCoordinate = vertexIn[i].textureCoordinate;
    frag.color = vertexIn[i].color;
	EmitVertex();
  }
  EndPrimitive();
 }


