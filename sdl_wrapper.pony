use "lib:SDL2"
use "lib:SDL2main"
use "debug"
use "time"
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