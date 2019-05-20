
#version 330 core
out vec4 color;
in vec2 uv;
uniform sampler2D tex;
uniform float scalar;
uniform float x_off;
uniform float y_off;
uniform float b;

const float phi = (1 + sqrt(5))/2;
const float pi = 3.141593f;
uniform int n_iter;
uniform float AR;
#define EPSILON 0.00001f
vec2 c_mult(vec2 a, vec2 b)
{
	float re = a.x * b.x - a.y * b.y;
	float im = a.x * b.y + b.x * a.y;
	vec2 c = vec2(re, im);
	return c;
}
vec2 c_div(vec2 a, vec2 b)
{
	vec2 conjugate = vec2(b.x, -b.y);
	vec2 numer = c_mult(a, conjugate);
	float denom = b.x*b.x + b.y*b.y;
	return numer/denom;
}
float atan2(float x, float y)
{
	
	if(x > 0)
		return atan(y/x);
	else if(x < 0  && y >= -EPSILON)
		return atan(y/x) + pi;
	else if(x < 0 && y < 0)
		return atan(y/x) - pi;
	else if(abs(x) < EPSILON && y > EPSILON)
		return pi/2;
	else if(abs(x) < x && y < -EPSILON)
		return -pi/2;
	else return 0;

}
float c_arg(vec2 z)
{
	return atan2(z.x, z.y);
}
vec2 c_pow(vec2 a, vec2 b)
{
	return pow(a.x*a.x + a.y*a.y, b.x/2)*exp(-b.y*c_arg(a)) *
			vec2(cos(b.x * c_arg(a) + (0.5f)*b.y*log(a.x*a.x + a.y*a.y)), 
				 sin(b.x * c_arg(a) + (0.5f)*b.y*log(a.x*a.x + a.y*a.y)));
}

vec3 palette(float i)
{
	return(vec3((sin(1.0f*i) + 1)/2, 0.8*cos(0.5f*i + 1)/2, 0.8*cos(1.0f*i) +1 )/2);
}
vec3 get_colour(float len_sq, int i)
{
	vec3 c1 = palette(i);
	vec3 c2 = palette(i - 1);
	float t = log(log(len_sq)/2/log(2.0f))/log(2.0f);
	vec3 c =  mix(c1, c2,  t);
	return c;
}
vec3 mandelbrot(vec2 c)
{

	float q = (c.x - 0.25f)*(c.x - 0.25f) + c.y*c.y;
	if(q * (q + (c.x - 0.25f)) < 0.25f *c.y*c.y)
		return vec3(0,0,0.25);
	if((c.x + 1)*(c.x + 1) + c.y*c.y < 0.0625f)
		return vec3(0,0,0.25);
	
	vec2 z = c;
	int i;
	float len_sq;
	for(i = 0; i < n_iter; i++)
	{
		len_sq = z.x*z.x + z.y*z.y;
		if(len_sq >=4)
			break;
		z = c_mult(z, z) + c;
	//	z = c_pow(z, vec2(b, 0)) + c;
	}
	len_sq = z.x*z.x + z.y*z.y;
	if(len_sq <4)
		return vec3(0,0,0.25);
	else
		return get_colour(len_sq, i);

}

void main() {
	
	vec2 a = vec2(((uv.x- 0.5 ) * scalar * AR ) + x_off, ((uv.y - 0.5) * scalar) + y_off);
	color = vec4(mandelbrot(a), 1); 
}

