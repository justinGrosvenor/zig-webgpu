const std = @import("std");
const gpu = @import("../gpu.zig");
const c = gpu.c;
const Input = @import("../input.zig").Input;
const Key = @import("../input.zig").Key;

const objc = @cImport({
    @cInclude("objc/runtime.h");
    @cInclude("objc/message.h");
});

const id = ?*anyopaque;
const SEL = objc.SEL;

fn sel(name: [*:0]const u8) SEL {
    return objc.sel_registerName(name);
}

fn class(name: [*:0]const u8) id {
    return @ptrCast(objc.objc_getClass(name));
}

fn msg(target: id, selector: SEL) id {
    const f: *const fn (id, SEL) callconv(.c) id = @ptrCast(&objc.objc_msgSend);
    return f(target, selector);
}

fn msgWithId(target: id, selector: SEL, arg: id) id {
    const f: *const fn (id, SEL, id) callconv(.c) id = @ptrCast(&objc.objc_msgSend);
    return f(target, selector, arg);
}

fn msgWithBool(target: id, selector: SEL, arg: bool) void {
    const f: *const fn (id, SEL, bool) callconv(.c) void = @ptrCast(&objc.objc_msgSend);
    f(target, selector, arg);
}

fn msgWithInt(target: id, selector: SEL, arg: c_ulong) id {
    const f: *const fn (id, SEL, c_ulong) callconv(.c) id = @ptrCast(&objc.objc_msgSend);
    return f(target, selector, arg);
}

fn getBool(target: id, selector: SEL) bool {
    const f: *const fn (id, SEL) callconv(.c) bool = @ptrCast(&objc.objc_msgSend);
    return f(target, selector);
}

fn getUShort(target: id, selector: SEL) u16 {
    const f: *const fn (id, SEL) callconv(.c) u16 = @ptrCast(&objc.objc_msgSend);
    return f(target, selector);
}

fn getULong(target: id, selector: SEL) c_ulong {
    const f: *const fn (id, SEL) callconv(.c) c_ulong = @ptrCast(&objc.objc_msgSend);
    return f(target, selector);
}

fn getLong(target: id, selector: SEL) c_long {
    const f: *const fn (id, SEL) callconv(.c) c_long = @ptrCast(&objc.objc_msgSend);
    return f(target, selector);
}

fn getF64(target: id, selector: SEL) f64 {
    const f: *const fn (id, SEL) callconv(.c) f64 = @ptrCast(&objc.objc_msgSend);
    return f(target, selector);
}

const NSPoint = extern struct { x: f64, y: f64 };
const NSRect = extern struct { x: f64, y: f64, width: f64, height: f64 };

pub const Window = struct {
    ns_window: id,
    metal_layer: id,
    should_close: bool,
    input: Input = .{},

    pub const Config = struct {
        title: [*:0]const u8 = "zig-webgpu",
        width: u32 = 800,
        height: u32 = 600,
    };

    pub fn init(config: Config) !Window {
        const app = msg(class("NSApplication"), sel("sharedApplication"));

        _ = msgWithInt(app, sel("setActivationPolicy:"), 0);

        const alloc = msg(class("NSWindow"), sel("alloc"));

        const style = (1 << 0) | (1 << 1) | (1 << 2) | (1 << 3);
        const rect = NSRect{ .x = 100, .y = 100, .width = @floatFromInt(config.width), .height = @floatFromInt(config.height) };
        const window = initWindow(alloc, rect, style);

        setTitle(window, config.title);
        _ = msgWithBool(window, sel("setAcceptsMouseMovedEvents:"), true);

        const content_view = msg(window, sel("contentView"));
        msgWithBool(content_view, sel("setWantsLayer:"), true);

        const metal_layer = msg(class("CAMetalLayer"), sel("layer"));
        _ = msgWithId(content_view, sel("setLayer:"), metal_layer);

        const scale = getBackingScaleFactor(window);
        setContentsScale(metal_layer, scale);

        _ = msgWithId(window, sel("makeKeyAndOrderFront:"), null);
        msgWithBool(app, sel("activateIgnoringOtherApps:"), true);

        return .{
            .ns_window = window,
            .metal_layer = metal_layer,
            .should_close = false,
        };
    }

    pub fn deinit(self: *Window) void {
        _ = msg(self.ns_window, sel("close"));
        self.* = undefined;
    }

    pub fn pollEvents(self: *Window) void {
        self.input.beginFrame();

        const app = msg(class("NSApplication"), sel("sharedApplication"));
        while (true) {
            const event = nextEvent(app);
            if (event == null) break;
            self.handleEvent(event);
            _ = msgWithId(app, sel("sendEvent:"), event);
        }
        _ = msg(app, sel("updateWindows"));

        if (!getBool(self.ns_window, sel("isVisible"))) {
            self.should_close = true;
        }
    }

    fn handleEvent(self: *Window, event: id) void {
        const event_type = getULong(event, sel("type"));
        switch (event_type) {
            10 => { // NSEventTypeKeyDown
                if (mapKeyCode(getUShort(event, sel("keyCode")))) |key|
                    self.input.handleKeyDown(key);
            },
            11 => { // NSEventTypeKeyUp
                if (mapKeyCode(getUShort(event, sel("keyCode")))) |key|
                    self.input.handleKeyUp(key);
            },
            1 => { // NSEventTypeLeftMouseDown
                self.input.mouse_left = true;
                self.input.mouse_left_pressed = true;
                self.updateCursorPos(event);
            },
            2 => { // NSEventTypeLeftMouseUp
                self.input.mouse_left = false;
                self.input.mouse_left_released = true;
                self.updateCursorPos(event);
            },
            3 => { // NSEventTypeRightMouseDown
                self.input.mouse_right = true;
                self.input.mouse_right_pressed = true;
                self.updateCursorPos(event);
            },
            4 => { // NSEventTypeRightMouseUp
                self.input.mouse_right = false;
                self.input.mouse_right_released = true;
                self.updateCursorPos(event);
            },
            5, 6, 7 => { // MouseMoved, LeftMouseDragged, RightMouseDragged
                self.input.mouse_dx += @floatCast(getF64(event, sel("deltaX")));
                self.input.mouse_dy += @floatCast(getF64(event, sel("deltaY")));
                self.updateCursorPos(event);
            },
            22 => { // NSEventTypeScrollWheel
                self.input.scroll_y += @floatCast(getF64(event, sel("scrollingDeltaY")));
            },
            25 => { // NSEventTypeOtherMouseDown — middle = buttonNumber 2
                if (getLong(event, sel("buttonNumber")) == 2) {
                    self.input.mouse_middle = true;
                    self.input.mouse_middle_pressed = true;
                    self.updateCursorPos(event);
                }
            },
            26 => { // NSEventTypeOtherMouseUp
                if (getLong(event, sel("buttonNumber")) == 2) {
                    self.input.mouse_middle = false;
                    self.input.mouse_middle_released = true;
                    self.updateCursorPos(event);
                }
            },
            27 => { // NSEventTypeOtherMouseDragged — fold into motion
                if (getLong(event, sel("buttonNumber")) == 2) {
                    self.input.mouse_dx += @floatCast(getF64(event, sel("deltaX")));
                    self.input.mouse_dy += @floatCast(getF64(event, sel("deltaY")));
                    self.updateCursorPos(event);
                }
            },
            else => {},
        }
    }

    pub fn createSurface(self: Window, instance: gpu.Instance) ?gpu.Surface {
        var source: c.WGPUSurfaceSourceMetalLayer = .{
            .chain = .{
                .next = null,
                .sType = c.WGPUSType_SurfaceSourceMetalLayer,
            },
            .layer = self.metal_layer,
        };
        const descriptor: c.WGPUSurfaceDescriptor = .{
            .nextInChain = @ptrCast(&source.chain),
            .label = gpu.stringView("macos surface"),
        };
        return instance.createSurface(&descriptor);
    }

    fn updateCursorPos(self: *Window, event: id) void {
        const loc = getLocationInWindow(event);
        const frame = getFrame(self.ns_window);
        const scale = getBackingScaleFactor(self.ns_window);
        self.input.mouse_x = @floatCast(loc.x * scale);
        self.input.mouse_y = @floatCast((frame.height - loc.y) * scale);
    }

    pub fn getSize(self: Window) [2]u32 {
        const frame = getFrame(self.ns_window);
        const scale = getBackingScaleFactor(self.ns_window);
        return .{
            @intFromFloat(frame.width * scale),
            @intFromFloat(frame.height * scale),
        };
    }
};

fn mapKeyCode(code: u16) ?Key {
    return switch (code) {
        0x0D => .w,
        0x00 => .a,
        0x01 => .s,
        0x02 => .d,
        0x0C => .q,
        0x0E => .e,
        0x0F => .r,
        0x03 => .f,
        0x06 => .z,
        0x07 => .x,
        0x05 => .g,
        0x31 => .space,
        0x38 => .left_shift,
        0x3B => .left_ctrl,
        0x37 => .left_super,
        0x35 => .escape,
        0x30 => .tab,
        0x75 => .delete,
        0x33 => .backspace,
        0x7E => .up,
        0x7D => .down,
        0x7B => .left,
        0x7C => .right,
        else => null,
    };
}

fn getBackingScaleFactor(window: id) f64 {
    const screen = msg(window, sel("screen"));
    return getF64(screen, sel("backingScaleFactor"));
}

fn setContentsScale(layer: id, scale: f64) void {
    const f: *const fn (id, SEL, f64) callconv(.c) void = @ptrCast(&objc.objc_msgSend);
    f(layer, sel("setContentsScale:"), scale);
}

fn initWindow(alloc: id, rect: NSRect, style: c_ulong) id {
    const f: *const fn (id, SEL, NSRect, c_ulong, c_ulong, bool) callconv(.c) id = @ptrCast(&objc.objc_msgSend);
    return f(alloc, sel("initWithContentRect:styleMask:backing:defer:"), rect, style, 2, false);
}

fn setTitle(window: id, title: [*:0]const u8) void {
    const ns_string = msgWithInt(
        msgWithId(msg(class("NSString"), sel("alloc")), sel("initWithUTF8String:"), @ptrCast(@constCast(title))),
        sel("autorelease"),
        0,
    );
    _ = msgWithId(window, sel("setTitle:"), ns_string);
}

var default_run_loop_mode: id = null;

fn getDefaultRunLoopMode() id {
    if (default_run_loop_mode == null) {
        default_run_loop_mode = msgWithId(
            msg(class("NSString"), sel("alloc")),
            sel("initWithUTF8String:"),
            @ptrCast(@constCast("kCFRunLoopDefaultMode")),
        );
    }
    return default_run_loop_mode;
}

fn nextEvent(app: id) id {
    const f: *const fn (id, SEL, c_ulong, id, id, bool) callconv(.c) id = @ptrCast(&objc.objc_msgSend);
    return f(app, sel("nextEventMatchingMask:untilDate:inMode:dequeue:"), std.math.maxInt(c_ulong), null, getDefaultRunLoopMode(), true);
}

fn getFrame(window: id) NSRect {
    const content_view = msg(window, sel("contentView"));
    const f: *const fn (id, SEL) callconv(.c) NSRect = @ptrCast(&objc.objc_msgSend);
    return f(content_view, sel("frame"));
}

fn getLocationInWindow(event: id) NSPoint {
    const f: *const fn (id, SEL) callconv(.c) NSPoint = @ptrCast(&objc.objc_msgSend);
    return f(event, sel("locationInWindow"));
}
