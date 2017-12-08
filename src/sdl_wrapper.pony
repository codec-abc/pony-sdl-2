use "lib:SDL2"
use "lib:SDL2main"
use "lib:SDL2_image"
use "debug"
use "time"
use "collections"
use "event"

use @SDL_Init[I32](flags: U32)
use @SDL_DestroyRenderer[None](renderer: Pointer[SDL2Renderer val] box)
use @SDL_DestroyWindow[None](window: Pointer[SDL2Window val] box)
use @SDL_RenderClear[I32](renderer: Pointer[SDL2Renderer val] box)
use @SDL_RenderPresent[None](renderer: Pointer[SDL2Renderer val] box)
use @SDL_PollEvent[I32](event : Pointer[U8] tag)
use @IMG_Load[Pointer[SDL2Surface val] ref](path : Pointer[U8 val] tag)
use @SDL_FreeSurface[None](surface: Pointer[SDL2Surface val] ref)

use @SDL_CreateWindow[Pointer[SDL2Window val] ref](
    title: Pointer[U8] tag, 
    x: I32,
    y: I32,
    w: I32, 
    h: I32, 
    flags: U32
)

use @SDL_CreateRenderer[Pointer[SDL2Renderer val] ref](
    window: Pointer[SDL2Window val] box, 
    index: I32, 
    flags: U32
)

use @SDL_SetRenderDrawColor[I32](
    renderer: Pointer[SDL2Renderer val] box, 
    r: U8, 
    g: U8, 
    b: U8, 
    a: U8
)

use @SDL_RenderFillRect[I32](
    renderer: Pointer[SDL2Renderer val] box, 
    rect: MaybePointer[SDL2Rect ref] box
)

use @SDL_CreateTextureFromSurface[Pointer[SDL2Texture val] ref](
    renderer : Pointer[SDL2Renderer val] ref, 
    surface : Pointer[SDL2Surface val] ref
)

use @SDL_RenderCopy[I32](
    renderer : Pointer[SDL2Renderer val] ref,
    texture : Pointer[SDL2Texture val] ref,
    source_rect: MaybePointer[SDL2Rect ref] box,
    destination_rect: MaybePointer[SDL2Rect ref] box
)

struct ref SDL2Rect
    var x: I32 = 0
    var y: I32 = 0
    var w: I32 = 0
    var h: I32 = 0

    new create(x1: I32, y1: I32, w1: I32, h1: I32) =>
       x = x1
       y = y1
       w = w1
       h = h1

primitive SDL2Window
primitive SDL2Renderer
primitive SDL2Surface
primitive SDL2Texture

primitive SDL2Flag
    fun init_video(): U32 =>0x00000020
    fun window_shown(): U32 =>  0x00000004
    fun renderer_accelerated(): U32 => 0x00000002
    fun renderer_presentvsync(): U32 => 0x00000004
