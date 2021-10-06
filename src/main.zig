const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const std = @import("std");

pub fn main() !void {
    const width = 800;
    const height = 600;

    if (c.SDL_Init(c.SDL_INIT_EVERYTHING) != 0) {
        std.log.crit("Unable to initialize SDL: {s}", .{c.SDL_GetError()});
        return error.SDLInitializationFailed;
    }
    defer {
        std.log.debug("defer DSL_Quit", .{});
        c.SDL_Quit();
    }

    const win = c.SDL_CreateWindow("My Game Window", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, width, height, c.SDL_WINDOW_OPENGL | c.SDL_WINDOW_SHOWN) orelse {
        std.log.crit("Unable to create window: {s}", .{c.SDL_GetError()});
        return error.SDLInitializationFailed;
    };
    defer {
        std.log.debug("defer SDL_DestroyWindow", .{});
        c.SDL_DestroyWindow(win);
    }

    const renderer = c.SDL_CreateRenderer(win, -1, c.SDL_RENDERER_ACCELERATED) orelse {
        std.log.crit("Unable to create renderer: {s}", .{c.SDL_GetError()});
        return error.SDLInitializationFailed;
    };
    defer {
        std.log.debug("defer SDL_DestroyRenderer", .{});
        c.SDL_DestroyRenderer(renderer);
    }

    const texture = c.SDL_CreateTexture(renderer, c.SDL_PIXELFORMAT_ARGB8888, c.SDL_TEXTUREACCESS_STREAMING, width, height) orelse {
        std.log.crit("Unable to create texture from renderer: {s}", .{c.SDL_GetError()});
        return error.SDLInitializationFailed;
    };
    defer {
        std.log.debug("defer SDL_DestroyTexture", .{});
        c.SDL_DestroyTexture(texture);
    }

    var quit = false;
    const Timer = std.time.Timer;
    var timer: Timer = try Timer.start();
    var fps: i32 = 0;
    std.log.debug("{}", .{timer});
    while (!quit) {
        if (timer.read() >= 1000000000) {
            var buf: [50]u8 = undefined;
            const fps_string = try std.fmt.bufPrintZ(&buf, "fps: {}", .{fps});
            c.SDL_SetWindowTitle(win, @ptrCast([*c]const u8, fps_string));
            timer.reset();
            fps = 0;
        }
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.@"type") {
                c.SDL_QUIT => {
                    quit = true;
                },
                else => {},
            }
        }

        _ = c.SDL_RenderClear(renderer);
        _ = c.SDL_RenderCopy(renderer, texture, null, null);
        _ = c.SDL_RenderPresent(renderer);

        //_ = c.SDL_Delay(17);

        fps += 1;
    }
}
