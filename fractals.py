import glfw
from glfw import *
import pyglet
from pyglet.gl import *
import sys
sys.path += [sys.path[0] + '\\pyshaders']
from pyshaders import from_files_names, ShaderCompilationError
import imgui
from imgui.integrations.glfw import GlfwRenderer

def key_callback(window_dict, window, key, scancode, action, mods):

    if(key == glfw.KEY_UP ):
        window_dict.y_off += 0.1*window_dict.scalar
    if(key == glfw.KEY_DOWN ):
        window_dict.y_off -= 0.1*window_dict.scalar
    if(key == glfw.KEY_RIGHT ):
        window_dict.x_off += 0.1*window_dict.scalar
    if(key == glfw.KEY_LEFT ):
        window_dict.x_off -= 0.1*window_dict.scalar
    if(key == glfw.KEY_Z):
        window_dict.scalar *= 0.95
    if(key == glfw.KEY_X):
        window_dict.scalar *= 1.05
    if(key == glfw.KEY_SPACE):
        window_dict.b += 0.01

def window_size_callback(window_dict, window, width, height):
    window_dict.width = width
    window_dict.height = height
    glViewport(0, 0, width, height)
    
class struct:
    def __init__(self, d):
        for k in d:
            setattr(self, k, d[k])

def init():
    if not glfw.init():
        return
    # Create window
    m = glfw.get_primary_monitor()
    mode = glfw.get_video_mode(m)
    width = mode.size.width
    height = mode.size.height
    
    window = glfw.create_window(width, height, "Fractals", None, None)
    if not window:
        glfw.terminate()
        exit(0)
    glfw.make_context_current(window)
    impl = GlfwRenderer(window)
    #compile shaders
    try:
        mandelbrot_shader = from_files_names("fractal_v.glsl", "mandelbrot_f.glsl")
        julia_shader = from_files_names("fractal_v.glsl", "julia_f.glsl")
        newton_shader = from_files_names("fractal_v.glsl", "newton_f.glsl")
    except ShaderCompilationError as e:
        print(e.logs) 
        exit()
    #setup data used for window and shaders
    window_dict = {
        'width' : width,
        'height': height,
        'n_iter': 100,
        'b' : 1,
        'scalar': 4.5,
        'x_off': 0,
        'y_off': 0
    }
    window_dict = struct(window_dict)
    #setep callback so they can change local variables
    glfw.set_key_callback(window, lambda *args : key_callback(window_dict, *args))
    glfw.set_window_size_callback(window, lambda *args : window_size_callback(window_dict, *args))
    #quad we are drawing to
    quad = pyglet.graphics.vertex_list(4,
        ('v2f', (-1.0, -1.0, -1.0, 1.0, 1.0, -1.0, 1.0, 1.0)))
    return window, window_dict, impl, quad, mandelbrot_shader, julia_shader, newton_shader

def main():
    # Initialize the library
    window, window_dict, impl, quad, mandelbrot_shader, julia_shader, newton_shader = init()
    #set mandelbrot shader to default
    shader = mandelbrot_shader
    shader.use()
    while not glfw.window_should_close(window):
        #setup gui
        imgui.new_frame()
        imgui.begin("Options", True)
        if imgui.button('Mandelbrot', False):
            shader = mandelbrot_shader  
            shader.use()
        if imgui.button('Julia', False):
            shader = julia_shader
            shader.use()

        if imgui.button('Newton', False):
            shader = newton_shader
            shader.use()


        b_changed, b_value = imgui.slider_float("b", window_dict.b, 0, 10)
        window_dict.b = b_value

        x_changed, x_value = imgui.slider_float("x offset", window_dict.x_off, -10, 10)
        window_dict.x_off = x_value
        
        y_changed, y_value = imgui.slider_float("y offset", window_dict.y_off, -10, 10)
        window_dict.y_off = y_value

        s_changed, s_value = imgui.slider_float("zoom", window_dict.scalar, 0.000001, 10, display_format = '%.9f', power = 10)
        window_dict.scalar = s_value

        i_changed, i_value = imgui.slider_float("iterations", window_dict.n_iter, 1, 1000, power = 2)
        window_dict.n_iter = int(i_value)

        if imgui.button('Reset', False):
            window_dict.x_off = 0
            window_dict.y_off = 0
            window_dict.scalar = 4.5
            window_dict.b = 1

        if imgui.button('Quit', False):
            break        
        imgui.end()

        
        #set uniforms
        #mandelbrot shader does not have 'b' uniform
        if shader is not mandelbrot_shader:
            shader.uniforms.b = window_dict.b
        shader.uniforms.scalar = window_dict.scalar
        shader.uniforms.y_off = window_dict.y_off
        shader.uniforms.x_off = window_dict.x_off
        shader.uniforms.AR = window_dict.width / window_dict.height
        shader.uniforms.n_iter = window_dict.n_iter

        # Swap front and back buffers
        glfw.swap_buffers(window)

        # Poll for and process events
        glfw.poll_events()
        impl.process_inputs()
        #render
        quad.draw(GL_TRIANGLE_STRIP)
        imgui.render()
        impl.render(imgui.get_draw_data())
   

    

if __name__ == "__main__":
    main()