#include "common.h"
#include "core.cpp"
#include "ShaderProgram.h"
#include "util.h"

#define GLFW_DLL

#include <GLFW/glfw3.h>
#include <random>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <dirent.h>
#include "SOIL.h"

using namespace glm;

static const GLsizei WIDTH = 640, HEIGHT = 480; //размеры окна

GLuint load_texture(const char *filename) {
    int width, height;
    unsigned char *image = SOIL_load_image(filename, &width, &height, 0, SOIL_LOAD_RGB);
    if (image == nullptr) {
        std::cerr << "Cannot load image" << std::endl;
        return 0;
    }

    GLuint texture_id;
    glGenTextures(1, &texture_id);

    // "Bind" the newly created texture : all future texture functions will modify this texture
    glBindTexture(GL_TEXTURE_2D, texture_id);

    // Give the image to OpenGL
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, image);

    // OpenGL has now copied the data. Free our own version todo obfuscate copy paste
    SOIL_free_image_data(image);

    // Poor filtering, or ...
    //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

    // ... nice trilinear filtering ...
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    // ... which requires mipmaps. Generate them automatically.
    glGenerateMipmap(GL_TEXTURE_2D);

    // Return the ID of the texture we just created
    return texture_id;
}

int initGL() {
    int res = 0;
    //грузим функции opengl через glad
    if (!gladLoadGLLoader((GLADloadproc) glfwGetProcAddress)) {
        std::cout << "Failed to initialize OpenGL context" << std::endl;
        return -1;
    }

    std::cout << "Vendor: " << glGetString(GL_VENDOR) << std::endl;
    std::cout << "Renderer: " << glGetString(GL_RENDERER) << std::endl;
    std::cout << "Version: " << glGetString(GL_VERSION) << std::endl;
    std::cout << "GLSL: " << glGetString(GL_SHADING_LANGUAGE_VERSION) << std::endl;

    return 0;
}

void gen_cube_mesh(GLfloat *buffer) {
//    GLfloat local_buffer[] = {
//        1, 1, 1,
//        1, -1, 1,
//        -1, 1, 1,
//
//
//    };

//    for (int global_x = 0; global_x < 2; ++global_x) {
//        for (int global_y = 0; global_y < 2; ++global_y) {
//            for (int global_z = 0; global_z < 2; ++global_z) {
//
//            }
//        }
//    }
}

int main(int argc, char **argv) {
    if (!glfwInit())
        return -1;

    //запрашиваем контекст opengl версии 3.3
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_RESIZABLE, GL_FALSE);

    GLFWwindow *window = glfwCreateWindow(WIDTH, HEIGHT, "OpenGL basic sample", nullptr, nullptr);
    if (window == nullptr) {
        std::cout << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }

    glfwMakeContextCurrent(window);
    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_NORMAL);

    if (initGL() != 0)
        return -1;

    //Reset any OpenGL errors which could be present for some reason
    GLenum gl_error = glGetError();
    while (gl_error != GL_NO_ERROR)
        gl_error = glGetError();

    // Enable depth test
    glEnable(GL_DEPTH_TEST);
    // Accept fragment if it closer to the camera than the former one
    glDepthFunc(GL_LESS);

    std::unordered_map<GLenum, std::string> shaders;
    shaders[GL_VERTEX_SHADER] = "vertex.glsl";
    shaders[GL_FRAGMENT_SHADER] = "fragment.glsl";
    ShaderProgram program(shaders);
    GL_CHECK_ERRORS;

    glfwSwapInterval(1); // force 60 frames per second

    // magic
    GLuint vao;
    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);

    GLuint texture = load_texture(
            "/home/bobko/code/cmc-msu/mash_mash_graph/task-02/metalroof1.bmp"); // todo fix this absolute path

    GLfloat cube_mesh[] = {
            -1.0f, -1.0f, -1.0f,
            -1.0f, -1.0f, 1.0f,
            -1.0f, 1.0f, 1.0f,
            1.0f, 1.0f, -1.0f,
            -1.0f, -1.0f, -1.0f,
            -1.0f, 1.0f, -1.0f,
            1.0f, -1.0f, 1.0f,
            -1.0f, -1.0f, -1.0f,
            1.0f, -1.0f, -1.0f,
            1.0f, 1.0f, -1.0f,
            1.0f, -1.0f, -1.0f,
            -1.0f, -1.0f, -1.0f,
            -1.0f, -1.0f, -1.0f,
            -1.0f, 1.0f, 1.0f,
            -1.0f, 1.0f, -1.0f,
            1.0f, -1.0f, 1.0f,
            -1.0f, -1.0f, 1.0f,
            -1.0f, -1.0f, -1.0f,
            -1.0f, 1.0f, 1.0f,
            -1.0f, -1.0f, 1.0f,
            1.0f, -1.0f, 1.0f,
            1.0f, 1.0f, 1.0f,
            1.0f, -1.0f, -1.0f,
            1.0f, 1.0f, -1.0f,
            1.0f, -1.0f, -1.0f,
            1.0f, 1.0f, 1.0f,
            1.0f, -1.0f, 1.0f,
            1.0f, 1.0f, 1.0f,
            1.0f, 1.0f, -1.0f,
            -1.0f, 1.0f, -1.0f,
            1.0f, 1.0f, 1.0f,
            -1.0f, 1.0f, -1.0f,
            -1.0f, 1.0f, 1.0f,
            1.0f, 1.0f, 1.0f,
            -1.0f, 1.0f, 1.0f,
            1.0f, -1.0f, 1.0f
    };

    GLfloat uv[] = {
            0.0f, 0.0f,
            1.0f, 0.0f,
            1.1f, 1.1f,
            0.0f, 1.0f,
            1.0f, 1.0f,
            1.0f, 0.0f, //
            0.0f, 0.0f,
            1.0f, 0.0f,
            1.1f, 1.1f,
            0.0f, 1.0f,
            1.0f, 1.0f,
            1.0f, 0.0f,
            0.0f, 0.0f,
            1.0f, 0.0f,
            1.1f, 1.1f,
            0.0f, 1.0f,
            1.0f, 1.0f,
            1.0f, 0.0f,
            0.0f, 0.0f,
            1.0f, 0.0f,
            1.1f, 1.1f,
            0.0f, 1.0f,
            1.0f, 1.0f,
            1.0f, 0.0f,
            0.0f, 0.0f,
            1.0f, 0.0f,
            1.1f, 1.1f,
            0.0f, 1.0f,
            1.0f, 1.0f,
            1.0f, 0.0f,
            0.0f, 0.0f,
            1.0f, 0.0f,
            1.1f, 1.1f,
            0.0f, 1.0f,
            1.0f, 1.0f,
            1.0f, 0.0f,
    };

    GLfloat triangle_mesh[] = {
            -1.0f, -1.0f, 0.0f,
            1.0f, -1.0f, 0.0f,
            0.0f, 1.0f, 0.0f,
    };

    GLfloat triangle_color[] = {
            1.0f, 0.0f, 0.0f,
            0.0f, 1.0f, 0.0f,
            0.0f, 0.0f, 1.0f,
    };

    Object *objects[] = {
//            new SpinningObject(triangle_mesh, sizeof(cube_mesh), glm::vec3(2, 0, 0.5), true, texture, uv, sizeof(uv), 0.001f),
//            new SpinningObject(triangle_mesh, sizeof(triangle_mesh), glm::vec3(-1, 0, -1), 0.002f),
            (new SpinningObject(cube_mesh, sizeof(cube_mesh), vec3(3.0f, 0.0f, 0.0f), 0.001f))->set_texture(texture, uv,
                                                                                                            sizeof(uv)),
            (new SpinningObject(triangle_mesh, sizeof(triangle_mesh), vec3(-4, 0, 0), 0.001f))->set_color(
                    triangle_color, sizeof(triangle_color))

    };
    Scene scene(objects, sizeof(objects) / sizeof(*objects));

    // main loop
    while (!glfwWindowShouldClose(window)) {

        // Clear the screen
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        program.StartUseShader();

        scene.draw(program, get_cur_time_millis());

        // Swap buffers
        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    scene.delete_it();

    // Close OpenGL window and terminate GLFW
    glfwTerminate();
    glDeleteVertexArrays(1, &vao);

    return 0;
}

// todo check all comments. Read entire code once more
