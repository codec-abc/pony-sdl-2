use "lib:SDL2"
use "lib:SDL2main"
use "debug"
use "time"
use "collections"
use "event"

// see 
// https://wiki.libsdl.org/SDL_Event#table and
// https://wiki.libsdl.org/SDL_Event#line-10 and
// https://github.com/spurious/SDL-mirror/blob/0a931e84e3739e636783dbaeaf9401e431d5cfaf/include/SDL_events.h and
// https://github.com/Rust-SDL2/rust-sdl2/blob/6e9a00a0d254c6b6e3cc0024494f84c1cc577534/sdl2-sys/src/event.rs

use @SDL_Init[I32](flags: U32)
use @SDL_CreateWindow[Pointer[_SDL2Window val] ref](title: Pointer[U8] tag, x: I32, y: I32, w: I32, h: I32, flags: U32)
use @SDL_CreateRenderer[Pointer[_SDL2Renderer val] ref](window: Pointer[_SDL2Window val] box, index: I32, flags: U32)
use @SDL_DestroyRenderer[None](renderer: Pointer[_SDL2Renderer val] box)
use @SDL_DestroyWindow[None](window: Pointer[_SDL2Window val] box)
use @SDL_RenderClear[I32](renderer: Pointer[_SDL2Renderer val] box)
use @SDL_RenderPresent[None](renderer: Pointer[_SDL2Renderer val] box)
use @SDL_SetRenderDrawColor[I32](renderer: Pointer[_SDL2Renderer val] box, r: U8, g: U8, b: U8, a: U8)
use @SDL_RenderFillRect[I32](renderer: Pointer[_SDL2Renderer val] box, rect: MaybePointer[_SDL2Rect ref] box)
use @SDL_PollEvent[I32](event : Pointer[U8] tag)

struct ref _SDL2Rect
    var x: I32 = 0
    var y: I32 = 0
    var w: I32 = 0
    var h: I32 = 0

    new create(x1: I32, y1: I32, w1: I32, h1: I32) =>
       x = x1
       y = y1
       w = w1
       h = h1

primitive SDL2Flag
    fun init_video(): U32 =>0x00000020
    fun window_shown(): U32 =>  0x00000004
    fun renderer_accelerated(): U32 => 0x00000002
    fun renderer_presentvsync(): U32 => 0x00000004

primitive _SDL2Window
primitive _SDL2Renderer
