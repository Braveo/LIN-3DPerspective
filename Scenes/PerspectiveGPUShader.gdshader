shader_type spatial;


uniform vec3 globPos = vec3(0,0,0);
uniform vec3 globRot = vec3(0,0,0);
uniform vec3 surface = vec3(0,0,1);

mat3 GetEulerMatrix() {
	
	mat3 camX = mat3(
		vec3(1,0,0),
		vec3(0,cos(globRot.x),-sin(globRot.x)),
		vec3(0,sin(globRot.x),cos(globRot.x))
	);
	mat3 camY = mat3(
		vec3(cos(globRot.y),0,sin(globRot.y)),
		vec3(0,1,0),
		vec3(-sin(globRot.y),0,cos(globRot.y))
	);
	mat3 camZ = mat3(
		vec3(cos(globRot.z),sin(globRot.z),0),
		vec3(-sin(globRot.z),cos(globRot.z),0),
		vec3(0,0,1)
	);
	return camX*camY*camZ;
	
}

varying vec3 pos;

void vertex() {
	
	vec3 worldPos = (WORLD_MATRIX * vec4(vec3(0,0,0),1.0)).xyz;
	
	worldPos = worldPos + vec3(0,1.,0)*sin(TIME + worldPos.y) * 0.1 + vec3(1.,0,0)*sin(TIME + worldPos.y) * 0.1;
	
	pos = GetEulerMatrix()*(worldPos - globPos);
	float dRatio = surface.z/pos.z;
	vec2 proj = vec2(pos.x*dRatio+surface.x,pos.y*dRatio+surface.y);
	
	if (pos.z < 0.) dRatio = 0.;
	
	VERTEX = vec3(proj,0.) - worldPos + VERTEX * dRatio;
	NORMAL = vec3(0.,0.,-1.);
	
}