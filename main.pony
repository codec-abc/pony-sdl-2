use "time"
use "debug"
use "collections"

class val GameTime

    let second : I64
    let nano_second : I64

    new val create(s : I64, ns : I64) =>
        second = s
        nano_second = ns

    fun delta(s : I64, ns : I64) : GameTime val^ =>
        if (ns < nano_second) then
            let r = GameTime(s - 1 - second, (ns - nano_second) + 1_000_000_000)
            r
        else
            let r = GameTime(s - second, ns - nano_second)
            r
        end
    
    fun delta_prime(game_time : GameTime) : GameTime val^ =>
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
    var window: Pointer[_SDLWindow val] ref
    var renderer: Pointer[_SDLRenderer val] ref
    var is_done : Bool = false
    var start_time : GameTime
    var game_time : GameTime
    var frame_index : U64 = 0

    new create(env : Env) =>
        _env = env
        @SDL_Init(SDL2.init_video())
        window = @SDL_CreateWindow("Hello World!".cstring(), 100, 100, 640, 480, SDL2.window_shown())

        renderer = @SDL_CreateRenderer(window, -1, SDL2.renderer_accelerated() or SDL2.renderer_presentvsync())

        _event = SDLEvent
        (let s : I64, let ns : I64)= Time.now()
        start_time = GameTime(s, ns)
        game_time = start_time

        tick()

    be tick() =>
        (let s : I64, let ns : I64) = Time.now()
        let delta = game_time.delta(s, ns)
        if (delta.second > 1) or (delta.nano_second > 2_000_000) then
            game_time = GameTime(s, ns)
            let time_running = game_time.delta_prime(start_time)
            loop(delta, time_running)
            frame_index = frame_index + 1
        end

        if not is_done then
            tick()
        end

    fun ref loop(delta : GameTime, time_running : GameTime)  =>
        @SDL_RenderClear(renderer)

        @SDL_SetRenderDrawColor(renderer, 0, 0, 255, 255)
        @SDL_RenderFillRect(renderer, MaybePointer[_SDLRect].none())

        @SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255)
        let cosine = (((time_running.second.f64() * 1_000_000_000 ) + time_running.nano_second.f64()) / F64(1_000_000_000)).cos()
        let x : F64 = F64(100) + (F64(100) * cosine)
        let rect = _SDLRect(x.i32(), 100, 200, 200)
        @SDL_RenderFillRect(renderer, MaybePointer[_SDLRect](rect))

        @SDL_RenderPresent(renderer)
        var result : I32 = 1 

        while @SDL_PollEvent(_event.array.cpointer()) != 0 do
            var event_type = SDLEventTranslator.type_of_event(_event)
            if event_type == SdlQuitEvent() then
                quit()
            end
        end

    fun ref quit() : None =>
        @SDL_DestroyRenderer(renderer)
        @SDL_DestroyWindow(window)
        is_done = true
        _env.out.print("quitting")