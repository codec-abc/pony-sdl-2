// look at this to  draw texture  https://gamedev.stackexchange.com/questions/72613/how-can-i-render-a-texture-to-the-screen-in-sdl2

use "time"
use "debug"
use "collections"
use "event"
use "keyboard"


class ref Vector2D
    var x : F64
    var y : F64

    new create(x' : F64, y': F64) =>
        x = x'
        y = y'

    fun ref add(other : Vector2D) : Vector2D =>
        let x' = x + other.x
        let y' = y + other.y
        Vector2D(x', y')

actor Main
    let _env : Env

    var _event : SDL2StructEvent

    var _window: Pointer[SDL2Window val] ref
    var _renderer: Pointer[SDL2Renderer val] ref
    var _is_done : Bool = false

    let _start_time : GameTime
    var _game_time : GameTime
    var _time_running : GameTime

    var _frame_index : U64 = 0

    var _square_position : Vector2D = Vector2D(50, 50)
    var _speed : Vector2D = Vector2D(0, 0)

    var _texture : Pointer[SDL2Texture val] ref

    new create(env : Env) =>
        _env = env
        @SDL_Init(SDL2Flag.init_video())

        _window = @SDL_CreateWindow(
            "Hello World!".cstring(), 
            100,
            100, 
            640, 
            480, 
            SDL2Flag.window_shown()
        )

        _renderer = @SDL_CreateRenderer(
            _window,
            -1, 
            SDL2Flag.renderer_accelerated() or SDL2Flag.renderer_presentvsync()
        )
        _event = SDL2StructEvent

        (let s : I64, let ns : I64) = Time.now()
        _start_time = GameTime(s, ns)
        _time_running = GameTime(0, 0)
        _game_time = _start_time

        let surface_pointer : Pointer[SDL2Surface val] ref = 
            @IMG_Load("./assets/mario.png".cstring())

        if not surface_pointer.is_null() then
            _texture = @SDL_CreateTextureFromSurface(_renderer, surface_pointer)
        else
            _texture = Pointer[SDL2Texture]
        end

        tick()

    be tick() =>
        (let s : I64, let ns : I64) = Time.now()
        let delta = _game_time.delta_s_and_ns(s, ns)
        if (delta.second > 1) or (delta.nano_second > 1_000_000) then
            _game_time = GameTime(s, ns)
            _time_running = _game_time.delta(_start_time)
            game_main_loop(delta)
            _frame_index = _frame_index + 1
        end

        if not _is_done then
            tick()
        end

    fun ref game_main_loop(delta : GameTime)  =>
        @SDL_RenderClear(_renderer)

        @SDL_SetRenderDrawColor(_renderer, 0, 0, 0, 255)
        @SDL_RenderFillRect(_renderer, MaybePointer[SDL2Rect].none())

        var result : I32 = 1 

        while @SDL_PollEvent(_event.array.cpointer()) != 0 do
            process_event()
        end

        let delta_time_ms : F64 = 
            (( _time_running.second.f64() * 1_000_000_000 ) + 
            _time_running.nano_second.f64()) / 1_000_000

        let scale_factor : F64 = 0.001
        _square_position = 
            _square_position + 
            Vector2D(where
                x' = _speed.x * delta_time_ms * scale_factor, 
                y' = _speed.y * delta_time_ms * scale_factor
            )

        @SDL_SetRenderDrawColor(_renderer, 255, 0, 0, 255)
        let rect = SDL2Rect(_square_position.x.i32(), _square_position.y.i32(), 30, 30)

        if _texture.is_null() then
            @SDL_RenderFillRect(_renderer, MaybePointer[SDL2Rect](rect))
        else
            @SDL_RenderCopy(_renderer, _texture, MaybePointer[SDL2Rect].none(), MaybePointer[SDL2Rect](rect))
        end

        @SDL_RenderPresent(_renderer)

    fun ref process_event() =>
        var event_type = SDL2EventTranslator.type_of_event(_event)
        match event_type
            | QuitEvent => quit()
            | let kb_event : KeyBoardEvent =>
                if not kb_event.repeated then
                    let delta_speed : F64 = 
                        match kb_event.key_state 
                            | KeyPressed => 1 
                            | KeyReleased => -1 
                        end
                    let key_code = kb_event.key_information.virtual_key_code
                    if (key_code == KeyCode.virtual_key_code_up()) then
                        _speed.y = _speed.y + delta_speed
                    elseif (key_code == KeyCode.virtual_key_code_down()) then
                        _speed.y = _speed.y - delta_speed
                    elseif (key_code == KeyCode.virtual_key_code_right()) then
                        _speed.x = _speed.x - delta_speed
                    elseif (key_code == KeyCode.virtual_key_code_left()) then
                        _speed.x = _speed.x + delta_speed
                    end
                end
            | None => None
        end

    fun ref quit() : None =>
        if not _is_done then
            @SDL_DestroyRenderer(_renderer)
            @SDL_DestroyWindow(_window)
            _is_done = true
        end