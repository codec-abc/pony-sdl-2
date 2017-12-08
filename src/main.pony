// look at this to  draw texture  https://gamedev.stackexchange.com/questions/72613/how-can-i-render-a-texture-to-the-screen-in-sdl2

use "time"
use "debug"
use "collections"
use "event"
use "keyboard"

class ref Vector2D
    var x : F64
    var y : F64

    new iso create(x' : F64, y': F64) =>
        x = x'
        y = y'

    fun box clone() : Vector2D iso^ =>
        Vector2D(x, y)

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

    var _sokoban : Sokoban

    new create(env : Env) =>
        _env = env
        @SDL_Init(SDL2Flag.init_video())

        _window = @SDL_CreateWindow(
            "Sokoban".cstring(), 
            100,
            100, 
            640, 
            640, 
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
            @IMG_Load("./assets/Spritesheet/sokoban_spritesheet@2.png".cstring())

        if not surface_pointer.is_null() then
            let texture = @SDL_CreateTextureFromSurface(_renderer, surface_pointer)
            @SDL_FreeSurface(surface_pointer)
            _sokoban = Sokoban(texture)
        else
            _sokoban = Sokoban.create_no_texture()
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

        _sokoban.tick_update(delta_time_ms)
        _sokoban.draw(_renderer)

        @SDL_RenderPresent(_renderer)

    fun ref process_event() =>
        var event_type = SDL2EventTranslator.type_of_event(_event)
        match event_type
            | QuitEvent => quit()
            | let kb_event : KeyBoardEvent =>
                _sokoban.handle_keyboard_event(kb_event)
            | None => None
        end

    fun ref quit() : None =>
        if not _is_done then
            @SDL_DestroyRenderer(_renderer)
            @SDL_DestroyWindow(_window)
            _is_done = true
        end