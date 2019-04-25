
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
//const float as = 1;
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
	float epsilon = 0.00001f;
	if(x > 0)
		return atan(y/x);
	else if(x < 0  && y >= -epsilon)
		return atan(y/x) + pi;
	else if(x < 0 && y < 0)
		return atan(y/x) - pi;
	else if(abs(x) < epsilon && y > epsilon)
		return pi/2;
	else if(abs(x) < x && y < -epsilon)
		return -pi/2;
	else return 0;

}
float c_arg(vec2 z)
{
	return atan2(z.x, z.y);
}
vec2 c_pow(vec2 a, int n)
{
	int i;
	vec2 z = vec2(1,0);
	for(i = 0; i < n; i++)
		z = c_mult(z, a);
	return z;
}
vec2 c_pow(vec2 a, vec2 b)
{
	return pow(a.x*a.x + a.y*a.y, b.x/2)*exp(-b.y*c_arg(a)) *
			vec2(cos(b.x * c_arg(a) + (0.5f)*b.y*log(a.x*a.x + a.y*a.y)), 
				 sin(b.x * c_arg(a) + (0.5f)*b.y*log(a.x*a.x + a.y*a.y)));
}

vec2 c_exp(vec2 a)
{
	vec2 b = vec2(cos(a.y), sin(a.y));
	return b * exp(a.x);

}
vec2 sinh(vec2 a)
{
	return (c_exp(a) - c_exp(-a))/2;
}
vec2 cosh(vec2 a)
{
	return (c_exp(a) + c_exp(-a))/2;
}
vec2 f(vec2 a)
{
	//z^3 -1
	vec2 b = c_pow(a, 3);
	b.x -= 1.0f;
	return b;

}
vec2 f_p(vec2 a)
{
	vec2 b = 3*c_pow(a, 2);
	return b;
}

vec3 mandelbrot(vec2 c)
{
	vec2 z = vec2(0, 0);
	z = c;
	int num_iter = 1000;
	int i;
	float len_sq;
	for(i = 0; i < n_iter; i++)
	{
		len_sq = z.x*z.x + z.y*z.y;
		if(len_sq >=4)
			break;
		//z = c_mult(z, z) + c;
		z = c_pow(z, vec2(2,0)) + 0.7885*c_exp(vec2(0, b));
		//z =    c_div(c_pow(cosh(z), vec2(b, 0)) - vec2(1, 0) , sinh(z)) ;
		//z = c_pow(z, vec2(b, 0)) + c;
	
	}
	len_sq = z.x*z.x + z.y*z.y;
	if(len_sq <4)
		return vec3(0,0,0.25);
	else
		return vec3(1, 0.75, 0) * sin(phi*i) + vec3(0.25, 0.5, 0) * sin(pi*i) + vec3(0.5,0.1,0.5) + sin(7.0f*i);
}

vec3 newton(vec2 a)
{
	int i;
	float epsilon = 0.0001;
	vec2 r0 = vec2(1, 0);
	vec2 r1 = vec2(-0.5f, sqrt(3)/2);
	vec2 r2 = vec2(-0.5f, -sqrt(3)/2);
	//int num_iter = 40;
	vec2 prev;
	const int num_roots = 3;
	vec2 roots[num_roots];
	int j;
	//for(j = 0; j < num_roots; j++)
	//{//	roots[j] = vec2(0, 1.5708*(2*j -1));
		roots[0] = vec2(1, 0);
		roots[1] =vec2(-0.5f, sqrt(3)/2);
		roots[2] = vec2(-0.5f, -sqrt(3)/2);
	//}
	for(i = 0; i < n_iter; i ++)
	{
		prev = a;
		a -= (b)*c_div(f(a), f_p(a));
		//a -= c_div(cosh(a) - vec2(1, 0), sinh(a));
		//return vec3(1, 0, 0)*length(a);
		//if(dot((a - prev), (a - prev)) < epsilon)
		//	return vec3(1, 0, 0)*(num_iter - i)/num_iter;
		
		for(j = 0; j < num_roots; j++)
		{	
			if(dot((a - roots[j]), (a-roots[j])) < epsilon)
				return vec3(sin(float(j)), cos(float(j)), tan(float(j)))*(n_iter - i)/n_iter;
		}
		//if(length(a - prev) < epsilon)
		//	return vec3(a.x,a.y,atan(a.x/a.y))*(num_iter - i)/num_iter;
		/*
		if(dot((a - r0), (a-r0)) < epsilon)
			return vec3(1, 0, 0) * (num_iter - i)/num_iter;
		else if(dot((a - r1), (a-r1)) < epsilon) 
			return vec3(0, 1, 0)* (num_iter - i)/num_iter;
		else if(dot((a - r2), (a-r2)) < epsilon) 
			return vec3(0,0,1)* (num_iter - i)/num_iter;*/
	}

	vec3 c = vec3(a.y ,(a.x) ,15*atan(a.x/a.y) - abs(a.x)/30 - a.y)/2;
//	if(length(c) < 0.5)
//		c += vec3(0.25, 0, 0);
	return c;

}

void main() {
	
	vec2 a = vec2(((uv.x- 0.5 ) * scalar * AR ) + x_off, ((uv.y - 0.5) * scalar) + y_off);
	color = vec4(newton(a), 1);
	//color = vec4(mandelbrot(a), 1);
	

    
}

