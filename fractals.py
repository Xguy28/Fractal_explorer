import glfw
from glfw import *
import pyglet
from pyglet.gl import *
import sys
sys.path += [sys.path[0] + '\\pyshaders']
from pyshaders import from_files_names, ShaderCompilationError
import imgui
from imgui.integrations.glfw import GlfwRenderer


global x_off
x_off = 0

global y_off
y_off = 0

global scalar
scalar = 4.5

global b
b = 1

global n_iter
n_iter = 100

def key_callback(window, key, scancode, action, mods):
    global y_off
    global x_off
    global scalar
    global b
    if(key == glfw.KEY_UP ):
        y_off += 0.1*scalar
    if(key == glfw.KEY_DOWN ):
        y_off -= 0.1*scalar
    if(key == glfw.KEY_RIGHT ):
        x_off += 0.1*scalar
    if(key == glfw.KEY_LEFT ):
        x_off -= 0.1*scalar
    if(key == glfw.KEY_Z):
        scalar *= 0.95
    if(key == glfw.KEY_X):
        scalar *= 1.05
    if(key == glfw.KEY_SPACE):
        b += 0.02

def window_size_callback(window, w, h):
    global width
    global height
    
    width = w
    height = h
    glViewport(0, 0, width, height)
    
    

def main():
    # Initialize the library
    if not glfw.init():
        return
    # Create a windowed mode window and its OpenGL context
    global width
    global height
    m = glfw.get_primary_monitor()
    mode = glfw.get_video_mode(m)
    width = mode.size.width//2
    height = mode.size.height//2

    window = glfw.create_window(width, height, "Fractals", None, None)
    glfw.make_context_current(window)
    if not window:
        glfw.terminate()
        return
    impl = GlfwRenderer(window)

    


    # Make the window's context current
    

    try:
        mandelbrot_shader = from_files_names("fractal_v.glsl", "mandelbrot_f.glsl")
        julia_shader = from_files_names("fractal_v.glsl", "julia_f.glsl")
        newton_shader = from_files_names("fractal_v.glsl", "newton_f.glsl")
    except ShaderCompilationError as e:
        print(e.logs) 
        exit()
    shader = mandelbrot_shader
    shader_i = 0
    shader.use()
    quad = pyglet.graphics.vertex_list(4,
        ('v2f', (-1.0, -1.0, -1.0, 1.0, 1.0, -1.0, 1.0, 1.0)))


    glfw.set_key_callback(window, key_callback)
    glfw.set_window_size_callback(window, window_size_callback)
    # Loop until the user closes the window
    while not glfw.window_should_close(window):
        global x_off
        global y_off
        global scalar
        global b
        global n_iter
        impl.process_inputs()
        imgui.new_frame()
        imgui.begin("Options", True)
        
       

        if imgui.button('Mandelbrot', False):
            shader = mandelbrot_shader
            shader_i = 0   
            shader.use()
        if imgui.button('Julia', False):
            shader = julia_shader
            shader.use()

            shader_i = 1
        if imgui.button('Newton', False):
            shader = newton_shader
            shader.use()

            shader_i = 2       

        b_changed, b_value = imgui.slider_float("b", b, 0, 10)
        b = b_value

        x_changed, x_value = imgui.slider_float("x offset", x_off, -10, 10)
        x_off = x_value
        
        y_changed, y_value = imgui.slider_float("y offset", y_off, -10, 10)
        y_off = y_value

        s_changed, s_value = imgui.slider_float("zoom", scalar, 0.000001, 10, display_format = '%.9f', power = 10)
        scalar = s_value

        i_changed, i_value = imgui.slider_float("iterations", n_iter, 1, 1000, power = 2)
        n_iter = int(i_value)


        if imgui.button('Reset', False):
            x_off = 0
            y_off = 0
            scalar = 4.5
            b = 1


        if imgui.button('Quit', False):
            exit(0)

        
        imgui.end()

        # Render here, e.g. using pyOpenGL
       
        if shader_i > 0:
            shader.uniforms.b = b
        
        
        shader.uniforms.scalar = scalar

        shader.uniforms.y_off = y_off
        shader.uniforms.x_off = x_off
        
        shader.uniforms.AR = width / height
        shader.uniforms.n_iter = n_iter
        # Swap front and back buffers
        glfw.swap_buffers(window)

        # Poll for and process events
        glfw.poll_events()
        quad.draw(GL_TRIANGLE_STRIP)
        imgui.render()
        impl.render(imgui.get_draw_data())

    impl.shutdown()
    glfw.terminate()

if __name__ == "__main__":
    main()