const c = @cImport({
    @cDefine("__vita__", "1");
    @cInclude("psp2/kernel/processmgr.h");
    @cInclude("psp2/kernel/clib.h");
    @cInclude("psp2/kernel/threadmgr.h");
    // @cInclude("stdio.h");
    @cInclude("debugScreen.h");
    @cInclude("psp2/display.h");
    @cDefine("printf", "psvDebugScreenPrintf");
});

const SCREEN_WIDTH = 960;
const SCREEN_HEIGHT = 544;

export fn __aeabi_read_tp() callconv(.c) *anyopaque {
    return @ptrFromInt(0x41414141);
}

fn memset2(ptr: ?*anyopaque, value: c_int, num: usize) callconv(.c) ?*anyopaque {
    return c.sceClibMemset(ptr, value, num);
}
comptime {
    @export(&memset2, .{ .name = "memset", .linkage = .weak });
}

pub export fn main() c_int {
    _ = c.psvDebugScreenInit();
    _ = c.psvDebugScreenPrintf("Hello, world!\n");

    _ = c.sceDisplayWaitVblankStart();
    _ = c.sceKernelDelayThread(10 * 1000000); // Wait for 3 seconds
    _ = c.psvDebugScreenPrintf("Hello, world zig!\n");
    _ = c.sceDisplayWaitVblankStart();
    _ = c.sceKernelDelayThread(50 * 1000000); // Wait for 3 seconds
    return 0;
}

// export fn _start() callconv(.naked) void {
//     asm volatile (
//         \\.thumb
//         \\pop     {r3, r4, r5, r6, r7}
//         \\pop     {r3}
//         \\mov     lr, r3
//         \\bx      lr
//     );
// }
// comptime {
//     std.mem.doNotOptimizeAway(WAAAAT);
// }

pub const std_options: std.Options = .{
    .log_level = .err,
    .logFn = myLogFn,
};

pub fn myLogFn(
    comptime level: std.log.Level,
    comptime scope: @Type(.enum_literal),
    comptime format: []const u8,
    args: anytype,
) void {
    _ = level;
    _ = scope;
    _ = format;
    _ = args;
    // // Ignore all non-error logging from sources other than
    // // .my_project, .nice_library and the default
    // const scope_prefix = "(" ++ switch (scope) {
    //     .my_project, .nice_library, std.log.default_log_scope => @tagName(scope),
    //     else => if (@intFromEnum(level) <= @intFromEnum(std.log.Level.err))
    //         @tagName(scope)
    //     else
    //         return,
    // } ++ "): ";
    // const prefix = "[" ++ comptime level.asText() ++ "] " ++ scope_prefix;
    // // Print the message to stderr, silently ignoring any errors
    // std.debug.lockStdErr();
    // defer std.debug.unlockStdErr();
    // const stderr = std.io.getStdErr().writer();
    // nosuspend stderr.print(prefix ++ format ++ "\n", args) catch return;
}

const std = @import("std");
