use "lib:SDL2"
use "lib:SDL2main"
use "time"
use "debug"
use "collections"

use @SDL_Init[I32](flags: U32)
use @SDL_CreateWindow[Pointer[_SDLWindow val] ref](title: Pointer[U8] tag, x: I32, y: I32, w: I32, h: I32, flags: U32)
use @SDL_CreateRenderer[Pointer[_SDLRenderer val] ref](window: Pointer[_SDLWindow val] box, index: I32, flags: U32)
use @SDL_DestroyRenderer[None](renderer: Pointer[_SDLRenderer val] box)
use @SDL_DestroyWindow[None](window: Pointer[_SDLWindow val] box)
use @SDL_RenderClear[I32](renderer: Pointer[_SDLRenderer val] box)
use @SDL_RenderPresent[None](renderer: Pointer[_SDLRenderer val] box)
use @SDL_SetRenderDrawColor[I32](renderer: Pointer[_SDLRenderer val] box, r: U8, g: U8, b: U8, a: U8)
use @SDL_RenderFillRect[I32](renderer: Pointer[_SDLRenderer val] box, rect: MaybePointer[_SDLRect ref] box)
use @SDL_PollEvent[I32](event : Pointer[U8] tag)

struct ref _SDLRect
    var x: I32 = 0
    var y: I32 = 0
    var w: I32 = 0
    var h: I32 = 0

    new create(x1: I32, y1: I32, w1: I32, h1: I32) =>
       x = x1
       y = y1
       w = w1
       h = h1

class SDLEvent
    var array : Array[U8]

    new create() =>
        array = Array[U8]()
        for i in Range(0, 56) do
            array.push(0)
        end
            

// see https://github.com/Rust-SDL2/rust-sdl2/blob/6e9a00a0d254c6b6e3cc0024494f84c1cc577534/sdl2-sys/src/event.rs
primitive SdlQuitEvent
    fun apply() : U32 => 256

primitive SDLEventTranslator

    fun type_of_event(event : SDLEvent) : U32 =>
        try
            var byte0 : U8 = event.array(0)?
            var byte1 : U8 = event.array(1)?
            var byte2 : U8 = event.array(2)?
            var byte3 : U8 = event.array(3)?
            
            // TODO use byte shiffting instead of that ugly multiplications
            let result = byte0.u32() + (byte1.u32() * 256) + (byte2.u32() * 256 * 256) + (byte3.u32() * 256 * 256 * 256)
            result
        else
            0
        end

primitive _SDLWindow
primitive _SDLRenderer

primitive SDL2
    fun init_video(): U32 =>
         0x00000020

    fun window_shown(): U32 => 
        0x00000004

    fun renderer_accelerated(): U32 =>
        0x00000002

    fun renderer_presentvsync(): U32 => 
        0x00000004


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