use "time"
use "debug"
use "collections"

class val GameTime

    let second : I64
    let nano_second : I64

    new val create(s : I64, ns : I64) =>
        second = s
        nano_second = ns

    fun delta_s_and_ns(s : I64 val, ns : I64 val) : GameTime val^ =>
        if (ns < nano_second) then
            let r = GameTime(s - 1 - second, (ns - nano_second) + 1_000_000_000)
            r
        else
            let r = GameTime(s - second, ns - nano_second)
            r
        end
    
    fun delta(game_time : GameTime) : GameTime val^ =>
        if (game_time.nano_second < nano_second) then
            let r = GameTime(game_time.second - 1 - second, (game_time.nano_second - nano_second) + 1_000_000_000)
            r
        else
            let r = GameTime(game_time.second - second, game_time.nano_second - nano_second)
            r
        end

actor Main

    let _env : Env

    var _event : SDLEvent

    var _window: Pointer[_SDLWindow val] ref
    var _renderer: Pointer[_SDLRenderer val] ref
    var _is_done : Bool = false

    let _start_time : GameTime
    var _game_time : GameTime
    var _time_running : GameTime

    var _frame_index : U64 = 0

    new create(env : Env) =>
        _env = env
        @SDL_Init(SDL2.init_video())

        _window = @SDL_CreateWindow("Hello World!".cstring(), 100, 100, 640, 480, SDL2.window_shown())
        _renderer = @SDL_CreateRenderer(_window, -1, SDL2.renderer_accelerated() or SDL2.renderer_presentvsync())
        _event = SDLEvent

        (let s : I64, let ns : I64) = Time.now()
        _start_time = GameTime(s, ns)
        _time_running = GameTime(0, 0)
        _game_time = _start_time

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
        @SDL_RenderFillRect(_renderer, MaybePointer[_SDLRect].none())

        @SDL_SetRenderDrawColor(_renderer, 255, 0, 0, 255)
        
        let cosine = 
            (
                (
                    ( _time_running.second.f64() * 1_000_000_000 ) + 
                    _time_running.nano_second.f64()
                ) / F64(1_000_000_000)
            ).cos()

        let x : F64 = F64(100) + (F64(100) * cosine)
        let rect = _SDLRect(x.i32(), 100, 200, 200)
        @SDL_RenderFillRect(_renderer, MaybePointer[_SDLRect](rect))

        @SDL_RenderPresent(_renderer)
        var result : I32 = 1 

        while @SDL_PollEvent(_event.array.cpointer()) != 0 do
            var event_type = SDLEventTranslator.type_of_event(_event)
            if event_type == SdlQuitEvent() then
                quit()
            end
        end

    fun ref quit() : None =>
        if not _is_done then
            @SDL_DestroyRenderer(_renderer)
            @SDL_DestroyWindow(_window)
            _is_done = true
        end