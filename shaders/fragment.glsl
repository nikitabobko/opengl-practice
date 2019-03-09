#version 330

#define float2 vec2
#define float3 vec3
#define float4 vec4
#define float4x4 mat4
#define float3x3 mat3

in float2 fragmentTexCoord;

layout(location = 0) out vec4 fragColor;

uniform int g_screenWidth;
uniform int g_screenHeight;

int SCENE_MAX = 10000;

uniform float3 g_bBoxMin   = float3(-1,-1,-1);
uniform float3 g_bBoxMax   = float3(+1,+1,+1);

uniform float4 backgroundColor = float4(0,0,0,1);

uniform vec3 cam_pos;

uniform vec3 cam_dir;

uniform vec3 cam_y;

uniform vec3 cam_x;

// Colors
vec4 WHITE = vec4(1, 1, 1, 0);
vec4 HALF_WHITE = vec4(0.5, 0.5, 0.5, 0);
vec4 QUAD_WHITE = vec4(0.25, 0.25, 0.25, 0);
vec4 BLACK = vec4(0, 0, 0, 0);
vec4 INDIGO = vec4(75.f/255,0,130.f/255,0);
vec4 GREY = vec4(0.2, 0.2, 0.2, 0);

// Ambient
vec4 NO_AMBIENT = BLACK;
vec4 GREEEN_RUBBER_AMBIENT = vec4(0.0, 0.05, 0.0, 0);

// Diffuse
vec4 GREEEN_RUBBER_DIFFUSE = vec4(0.4, 0.5, 0.4, 0.f);

// Specular
vec4 NO_SPECULAR = BLACK;
vec4 GREEEN_RUBBER_SPECULAR = vec4(0.04, 0.7, 0.04, 0.f);
vec4 EMERALD_SPECULAR = vec4(0.633, 0.727811, 0.633, 0);
float EMERALD_SPECULAR_SHINESS = 0.6;

// Specualr shiness
float NO_SPECULAR_SHINESS = 0.f;
float GREEEN_RUBBER_SPECULAR_SHINESS = 0.078125;

int NO_ID = 0;

float NO_REFLECTION = 0;

float MIN_DIST = 0.2;

struct Object {
    int id;
    float dist;
    vec4 ambient;
    vec4 diffuse;
    vec4 specular;
    float specular_shiness;
    float reflection;
};

float sphere_dist(vec3 p, vec3 center, float radius) {
    return length(p - center) - radius;
}

float box_dist(vec3 p, vec3 center, vec3 lengths) {
    return length(max(abs(p-center)-lengths,0.0));
}

float torus_dist(vec3 p, vec3 center, vec2 t) {
    p -= center;
    return length(vec2(length(p.xz)-t.x,p.y))-t.y;
}

float triangular_prism_dist(vec3 p, vec3 center, vec2 h) {
    p -= center;
    vec3 q = abs(p);
    return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}

float ellipsoid_dist(vec3 p, vec3 center, vec3 r) {
    p -= center;
    return (length( p/r ) - 1.0) * min(min(r.x,r.y),r.z);
}

//float dist_displace(float dist, vec3 p) {
//    return dist + displacement(p);
//}

Object y_chess_plane_object(vec3 p, float y, vec2 lengths, Object obj1, Object obj2) {
    float dist = box_dist(p, vec3(0, y, 0), vec3(lengths.x, 1, lengths.y));
    if ((int((p.x + SCENE_MAX) / 100) + int((p.z + SCENE_MAX) / 100)) % 2 == 0) {
        obj1.dist = dist;
        return obj1;
    } else {
        obj2.dist = dist;
        return obj2;
    }
}

Object emerald_object(int id, float dist) {
    return Object(id, dist, vec4(0.0215, 0.1745, 0.0215, 0), vec4(0.07568, 0.61424, 0.07568, 0), vec4(0.633, 0.727811, 0.633, 0), 0.6, NO_REFLECTION);
}

Object green_ruber_object(int id, float dist) {
    return Object(id, dist, GREEEN_RUBBER_AMBIENT, GREEEN_RUBBER_DIFFUSE, GREEEN_RUBBER_SPECULAR, GREEEN_RUBBER_SPECULAR_SHINESS, NO_REFLECTION);
}

Object ruby_object(int id, float dist) {
    return Object(id, dist, vec4(0.1745, 0.01175, 0.01175, 0), vec4(0.61424, 0.04136, 0.04136, 0), vec4(0.727811, 0.626959, 0.626959, 0), 0.6, 0.5);
}

Object gold_object(int id, float dist) {
    return Object(id, dist, vec4(0.24725, 0.1995, 0.0745, 0.f), vec4(0.75164, 0.60648, 0.22648, 0.f), vec4(0.628281, 0.555802, 0.366065, 0.f), 0.4, NO_REFLECTION);
}

Object red_plastic(int id, float dist) {
    return Object(id, dist, vec4(0.0, 0.0, 0.0, 0), vec4(0.5, 0.0, 0.0, 0), vec4(0.7, 0.6, 0.6, 0), 0.25, 1);
}

Object white_plastic(int id, float dist) {
    return Object(id, dist, vec4(0.0, 0.0, 0.0, 0), vec4(0.55, 0.55, 0.55, 0), vec4(0.70, 0.70, 0.70, 0), .25, 1);
}
//
//Object black_plastic(float dist) {
//    return Object(dist, vec4(0.0, 0.0, 0.0, 0), vec4(0.01, 0.01, 0.01, 0), vec4(0.50, 0.50, 0.50, 0), .25);
//}
//
Object matt_green_object(int id, float dist) {
    return Object(id, dist, GREEEN_RUBBER_AMBIENT, GREEEN_RUBBER_DIFFUSE, NO_SPECULAR, NO_SPECULAR_SHINESS, NO_REFLECTION);
}

Object chrome_object(int id, float dist) {
    return Object(id, dist, vec4(0.25, 0.25, 0.25, 0), vec4(0.4, 0.4, 0.4, 0), vec4(0.774597, 0.774597, 0.774597, 0), 0.6, NO_REFLECTION);
}

//float displacement(vec3 p) {
//    return sin(20*p.x)*sin(20*p.y)*sin(20*p.z);
//}

Object scene0(vec3 p, int ignore_id) {
    Object[] scenes = Object[](
        ruby_object(1, sphere_dist(p, vec3(0, 200, 100), 100)),
        matt_green_object(2, sphere_dist(p, vec3(-500, -50, 0), 300)),
        red_plastic(3, box_dist(p, vec3(400, -400, -500), vec3(100, 200, 200))),
        gold_object(4, torus_dist(p, vec3(100, -400, 300), vec2(1000, 50))),
        y_chess_plane_object(p, -700, vec2(2000, 2000), white_plastic(5, 0), red_plastic(5, 0)),
        emerald_object(6, triangular_prism_dist(p, vec3(0, -500, 200), vec2(300, 100))),
        chrome_object(7, ellipsoid_dist(p, vec3(-500, 200, -600), vec3(100, 200, 100)))
    );
    Object cur = scenes[0];
    bool initialized = false;
    for (int i = 0; i < scenes.length(); ++i) {
        if (scenes[i].id != ignore_id && (!initialized || scenes[i].dist < cur.dist)) {
            cur = scenes[i];
            initialized = true;
        }
    }
    return cur;
}

Object cur_scene(vec3 point) {
    return scene0(point, NO_ID);
}

Object cur_scene_except(vec3 p, int ignore_id) {
    return scene0(p, ignore_id);
}

vec3 estimateNormal(float3 z) {
    float eps = 0.001;
    float3 z1 = z + float3(eps, 0, 0);
    float3 z2 = z - float3(eps, 0, 0);
    float3 z3 = z + float3(0, eps, 0);
    float3 z4 = z - float3(0, eps, 0);
    float3 z5 = z + float3(0, 0, eps);
    float3 z6 = z - float3(0, 0, eps);
    float dx = cur_scene(z1).dist - cur_scene(z2).dist;
    float dy = cur_scene(z3).dist - cur_scene(z4).dist;
    float dz = cur_scene(z5).dist - cur_scene(z6).dist;
    return normalize(float3(dx, dy, dz) / (2.0*eps));
}

float hui_x;
float hui_y;

bool isVisible(vec3 from, vec3 to, int ignore_id) {
    vec3 direction = normalize(to - from);
    float step = min(cur_scene(from).dist, length(to - from));
    vec3 cur = from + direction*step;

    step = min(cur_scene(cur).dist, length(to - cur));
    while(step > MIN_DIST) {
        cur += direction*step;
        step = min(cur_scene_except(cur, ignore_id).dist, length(to - cur));
    }

    return length(to - cur) <= MIN_DIST;
}

struct Light {
    vec4 color;
    vec3 point;
};

vec4 light_point(vec3 point, Object obj, vec3 ray_dir, vec3 normal) {
    vec4 ambinet_color = WHITE;
    Light[] ligths = Light[](
        Light(WHITE, vec3(900, 600, -200)),
        Light(WHITE, vec3(-500, 300, -800)),
        Light(WHITE, vec3(0, -2000, 0))
    );
    vec4 color = BLACK;
    for (int i = 0; i < ligths.length(); ++i) {
        Light light = ligths[i];
        color += ambinet_color*obj.ambient;
        if (isVisible(light.point, point, obj.id)) {
//            vec3 normal = estimateNormal(point);
            vec3 to_light = normalize(light.point - point);
            float scalar = dot(to_light, normal);
            color += light.color*obj.diffuse*max(scalar, 0.f);
            vec3 reflected_light = 2*scalar*normal - to_light;
            if (obj.specular != NO_SPECULAR) {
                color += light.color*obj.specular*pow(max(dot(-ray_dir, reflected_light), 0.f), 128*obj.specular_shiness);
            }
//              float dist = length(light.point - point);
//              color += 100000/(dist*dist);
        }

    }
    return color;
}

//vec4 light_point(vec3 point, Object obj, vec3 ray_dir) {
//    return ligth_point_scene0(point, obj, ray_dir);
//}

vec3 EyeRayDir(float x, float y, float w) {
    float fov = 3.141592654f/(2.0f);
    float3 ray_dir;

    return normalize(cam_x*x + cam_y*y + cam_dir*(w)/tan(fov/2.0f));
}

bool isOutOfScene(vec3 point) {
    return abs(point.x) > SCENE_MAX || abs(point.y) > SCENE_MAX || abs(point.z) > SCENE_MAX;
}

vec4 RayTrace(vec3 ray_dir, float w, float h) {
    vec3 cur = cam_pos;
    vec4 color = backgroundColor;
//    while (!isOutOfScene(cur)) {
    int reflect_depth = 1;
    float cur_reflection = 1;
    int ignore_id = NO_ID;
    while (reflect_depth <= 3 && !isOutOfScene(cur)) {
        Object obj = cur_scene_except(cur, ignore_id);
        cur += obj.dist*ray_dir;
        if (obj.dist <= MIN_DIST) {
            vec3 normal = estimateNormal(cur);
            color += cur_reflection*light_point(cur, obj, ray_dir, normal)/reflect_depth/reflect_depth;
            if (obj.reflection == 0) {
                break;
            }
            cur_reflection = obj.reflection;
            ray_dir = 2*dot(normal, -ray_dir)*normal + ray_dir;
            ignore_id = obj.id;
            reflect_depth++;
        }
    }
    return color;
}

void main(void) {
    float w = float(g_screenWidth);
    float h = float(g_screenHeight);

    float x = fragmentTexCoord.x*w - w/2;
    float y = fragmentTexCoord.y*h - h/2;

    hui_x = x;
    hui_y = y;

    float3 ray_dir = EyeRayDir(x,y, w);

    fragColor = RayTrace(ray_dir, w, h);
}
