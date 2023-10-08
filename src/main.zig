const std = @import("std");

const screen_width = 320;
const screen_height = 90;

var screen_buffer: [screen_width * screen_height]f32 = undefined;
var screen_depth_buffer: [screen_width * screen_height]f32 = undefined;
var noise_buffer: [screen_width * screen_height]f32 = undefined;

var ascii_sorted: []const u8 = "$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\\|()1{}[]?-_+~<>i!lI;:,\"^`'. ";
var ascii_sorted2: []const u8 = " `.-':_,^=;><+!rc*/z?sLTv)J7(|Fi{C}fI31tlu[neoZ5Yxjya]2ESwqkP6h9d4VpOGbUAKXHm8RD#$Bg0MNWQ%&@";

const vec2 = struct {
    x: f32,
    y: f32,
};

const vec3 = struct {
    x: f32,
    y: f32,
    z: f32,
};

var timer: std.time.Timer = undefined;

pub fn main() !void {
    var random = std.rand.DefaultPrng.init(0);
    var rng = random.random();

    for (0..screen_height) |uy| {
        for (0..screen_width) |ux| {
            var p = uy * screen_width + ux;
            noise_buffer[p] = rng.float(f32) * 0.03;
        }
    }

    timer = try std.time.Timer.start();

    var last_time = get_time();
    while (true) {
        if (get_time() - last_time > 1.0 / 60.0) {
            render();
            last_time = get_time();
        }
    }
}

fn get_time() f32 {
    return @as(f32, @floatFromInt(timer.read())) / std.time.ns_per_s;
}

fn render() void {
    for (0..screen_height) |uy| {
        for (0..screen_width) |ux| {
            var x: f32 = @floatFromInt(ux);
            var y: f32 = @floatFromInt(uy);
            x /= @as(f32, screen_width);
            y /= @as(f32, screen_height);

            var p = uy * screen_width + ux;

            screen_buffer[p] = 0;
            screen_depth_buffer[p] = std.math.floatMax(f32);
        }
    }

    var zz = get_time() + 1;

    rotateX = zz * 0.214;
    rotateY = zz;
    rotateZ = zz * 0.813;
    scaleXYZ = 1;
    translateXYZ = vec3{ .x = 0, .y = 0, .z = 3 };

    draw_cube();

    //var t = std.math.modf(get_time()).fpart;
    //std.debug.assert(false);

    std.debug.print("\x1b[3J\r", .{});
    render_screen();
}

fn draw_cube() void {
    draw_triangle_3d(
        .{ .x = 1, .y = 1, .z = 1 },
        .{ .x = 1, .y = -1, .z = 1 },
        .{ .x = -1, .y = -1, .z = 1 },
        0.95,
    );
    draw_triangle_3d(
        .{ .x = -1, .y = -1, .z = 1 },
        .{ .x = -1, .y = 1, .z = 1 },
        .{ .x = 1, .y = 1, .z = 1 },
        1,
    );

    draw_triangle_3d(
        .{ .x = -1, .y = -1, .z = -1 },
        .{ .x = 1, .y = -1, .z = -1 },
        .{ .x = 1, .y = 1, .z = -1 },
        0.95,
    );
    draw_triangle_3d(
        .{ .x = 1, .y = 1, .z = -1 },
        .{ .x = -1, .y = 1, .z = -1 },
        .{ .x = -1, .y = -1, .z = -1 },
        1,
    );

    draw_triangle_3d(
        .{ .x = 1, .y = -1, .z = 1 },
        .{ .x = 1, .y = -1, .z = -1 },
        .{ .x = -1, .y = -1, .z = -1 },
        0.01,
    );
    draw_triangle_3d(
        .{ .x = -1, .y = -1, .z = -1 },
        .{ .x = -1, .y = -1, .z = 1 },
        .{ .x = 1, .y = -1, .z = 1 },
        0.02,
    );

    draw_triangle_3d(
        .{ .x = -1, .y = 1, .z = -1 },
        .{ .x = 1, .y = 1, .z = -1 },
        .{ .x = 1, .y = 1, .z = 1 },
        0.01,
    );
    draw_triangle_3d(
        .{ .x = 1, .y = 1, .z = 1 },
        .{ .x = -1, .y = 1, .z = 1 },
        .{ .x = -1, .y = 1, .z = -1 },
        0.02,
    );

    draw_triangle_3d(
        .{ .x = -1, .y = 1, .z = 1 },
        .{ .x = -1, .y = -1, .z = -1 },
        .{ .x = -1, .y = 1, .z = -1 },
        0.12,
    );
    draw_triangle_3d(
        .{ .x = -1, .y = 1, .z = 1 },
        .{ .x = -1, .y = -1, .z = 1 },
        .{ .x = -1, .y = -1, .z = -1 },
        0.14,
    );

    draw_triangle_3d(
        .{ .x = 1, .y = 1, .z = 1 },
        .{ .x = 1, .y = 1, .z = -1 },
        .{ .x = 1, .y = -1, .z = -1 },
        0.12,
    );
    draw_triangle_3d(
        .{ .x = 1, .y = -1, .z = -1 },
        .{ .x = 1, .y = -1, .z = 1 },
        .{ .x = 1, .y = 1, .z = 1 },
        0.14,
    );
}

var rotateX: f32 = 0;
var rotateY: f32 = 0;
var rotateZ: f32 = 0;
var translateXYZ: vec3 = vec3{ .x = 0, .y = 0, .z = 0 };
var scaleXYZ: f32 = 0;

fn rotateOnX(point: vec3, a: f32) vec3 {
    return vec3{
        .x = point.x,
        .y = point.y * @cos(a) + point.z * -@sin(a),
        .z = point.y * @sin(a) + point.z * @cos(a),
    };
}

fn rotateOnY(point: vec3, a: f32) vec3 {
    return vec3{
        .x = point.x * @cos(a) + point.z * -@sin(a),
        .y = point.y,
        .z = point.x * @sin(a) + point.z * @cos(a),
    };
}

fn rotateOnZ(point: vec3, a: f32) vec3 {
    return vec3{
        .x = point.x * @cos(a) + point.y * -@sin(a),
        .y = point.x * @sin(a) + point.y * @cos(a),
        .z = point.z,
    };
}

fn translate(point: vec3, translation: vec3) vec3 {
    return vec3{
        .x = point.x + translation.x,
        .y = point.y + translation.y,
        .z = point.z + translation.z,
    };
}

fn scale(point: vec3, s: f32) vec3 {
    return vec3{
        .x = point.x * s,
        .y = point.y * s,
        .z = point.z * s,
    };
}

fn perspective(point: vec3) vec2 {
    return vec2{ .x = point.x / point.z, .y = point.y / point.z };
}

fn lux_to_char(lux: f32) u8 {
    var l = @min(lux, 1);
    return ascii_sorted2[@as(usize, @intFromFloat(l * @as(f32, @floatFromInt(ascii_sorted2.len - 1))))];
}

fn unnormalize(point: vec2) vec2 {
    return vec2{
        .x = ((point.x + 1.0) * 0.5) * screen_height * 2 + ((screen_width - screen_height) * 0.5),
        .y = ((point.y + 1.0) * 0.5) * screen_height,
    };
}

fn transform_to_world(point: vec3) vec3 {
    var transformed = scale(point, scaleXYZ);
    transformed = rotateOnX(transformed, rotateX);
    transformed = rotateOnY(transformed, rotateY);
    transformed = rotateOnZ(transformed, rotateZ);
    return translate(transformed, translateXYZ);
}

fn transform_to_screenspace(point: vec3) vec2 {
    return unnormalize(perspective(point));
}

fn cross(a: vec3, b: vec3) vec3 {
    return vec3{
        .x = (a.y * b.z) - (a.z * b.y),
        .y = (a.z * b.x) - (a.x * b.z),
        .z = (a.x * b.y) - (a.y * b.x),
    };
}

fn normalize(a: vec3) vec3 {
    var magnitude: f32 = @sqrt(a.x * a.x + a.y * a.y + a.z * a.z);
    return vec3{
        .x = a.x / magnitude,
        .y = a.y / magnitude,
        .z = a.z / magnitude,
    };
}

fn dot(a: vec3, b: vec3) f32 {
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

fn sub(a: vec3, b: vec3) vec3 {
    return vec3{
        .x = a.x - b.x,
        .y = a.y - b.y,
        .z = a.z - b.z,
    };
}

fn add(a: vec3, b: vec3) vec3 {
    return vec3{
        .x = a.x + b.x,
        .y = a.y + b.y,
        .z = a.z + b.z,
    };
}

fn div(a: vec3, s: f32) vec3 {
    return vec3{
        .x = a.x / s,
        .y = a.y / s,
        .z = a.z / s,
    };
}

fn distance(a: vec3, b: vec3) f32 {
    return @sqrt(std.math.pow(f32, a.x - b.x, 2) + std.math.pow(f32, a.y - b.y, 2) + std.math.pow(f32, a.z - b.z, 2));
}

fn draw_triangle_3d(a: vec3, b: vec3, c: vec3, lux: f32) void {
    var wa = transform_to_world(a);
    var wb = transform_to_world(b);
    var wc = transform_to_world(c);

    var line1 = normalize(sub(wa, wb));
    var line2 = normalize(sub(wa, wc));

    var normal = normalize(cross(line1, line2));
    const light_source = normalize(.{ .x = 1, .y = 0, .z = 1 });
    var lux2 = lux * ((dot(normal, light_source) + 1) * 0.5);
    _ = lux2;

    // var average_depth = distance(
    //     vec3{ .x = 0, .y = 0, .z = 0 },
    //     div(add(wa, add(wb, wc)), 3),
    // );

    var average_depth = (wa.z + wb.z + wc.z) / 3;

    draw_triangle(
        transform_to_screenspace(wa),
        transform_to_screenspace(wb),
        transform_to_screenspace(wc),
        lux,
        average_depth,
    );
}

fn clamp(value: f32, min: f32, max: f32) f32 {
    return @max(min, @min(max, value));
}

fn draw_triangle(a: vec2, b: vec2, c: vec2, lux: f32, depth: f32) void {
    // std.debug.print("({d:.3}, {d:.3}), ({d:.3}, {d:.3}), ({d:.3}, {d:.3})\n", .{ a.x, a.y, b.x, b.y, c.x, c.y });

    var top: vec2 = undefined;
    var mid: vec2 = undefined;
    var bot: vec2 = undefined;

    if (a.y <= b.y and a.y <= c.y) {
        top = a;
        if (b.y < c.y) {
            mid = b;
            bot = c;
        } else {
            mid = c;
            bot = b;
        }
    } else if (b.y <= a.y and b.y <= c.y) {
        top = b;
        if (a.y < c.y) {
            mid = a;
            bot = c;
        } else {
            mid = c;
            bot = a;
        }
    } else {
        top = c;
        if (a.y < b.y) {
            mid = a;
            bot = b;
        } else {
            mid = b;
            bot = a;
        }
    }

    var y = @ceil(top.y);
    while (y < mid.y) {
        var line_topbot_x = top.x + (bot.x - top.x) * ((y - top.y) / (bot.y - top.y));
        var line_topmid_x = top.x + (mid.x - top.x) * ((y - top.y) / (mid.y - top.y));

        var start_x: usize = @intFromFloat(clamp(@min(line_topbot_x, line_topmid_x), 0, screen_width - 1));
        var end_x: usize = @intFromFloat(clamp(@max(line_topbot_x, line_topmid_x), 0, screen_width - 1));

        if (0 > y) {
            y = 0;
        }

        if (y >= screen_height) {
            break;
        }

        var uy: usize = @intFromFloat(y);
        for (start_x..end_x) |ux| {
            var p = uy * screen_width + ux;
            if (screen_depth_buffer[p] > depth) {
                var edge: f32 = 1;
                if (ux == start_x or ux == end_x) {
                    //edge = 0.5;
                }
                screen_buffer[p] = lux * edge;
                screen_depth_buffer[p] = depth;
            }
        }

        y += 1;
    }
    while (y < bot.y) {
        var line_topbot_x = top.x + (bot.x - top.x) * ((y - top.y) / (bot.y - top.y));
        var line_midbot_x = mid.x + (bot.x - mid.x) * ((y - mid.y) / (bot.y - mid.y));

        var start_x: usize = @intFromFloat(clamp(@min(line_topbot_x, line_midbot_x), 0, screen_width - 1));
        var end_x: usize = @intFromFloat(clamp(@max(line_topbot_x, line_midbot_x), 0, screen_width - 1));

        if (0 > y) {
            y = 0;
        }

        if (y >= screen_height) {
            break;
        }

        var uy: usize = @intFromFloat(y);
        for (start_x..end_x) |ux| {
            var p = uy * screen_width + ux;
            if (screen_depth_buffer[p] > depth) {
                var edge: f32 = 1;
                if (ux == start_x or ux == end_x - 1) {
                    //edge = 0.5;
                }
                screen_buffer[p] = lux * edge;
                screen_depth_buffer[p] = depth;
            }
        }

        y += 1;
    }
}

fn render_screen() void {
    const char_buffer_width = (screen_width / 2) + 1;
    const char_buffer_height = screen_height / 2;

    var screen_char_buffer: [char_buffer_width * char_buffer_height]u8 = undefined;
    for (0..char_buffer_height) |y| {
        for (0..char_buffer_width - 1) |x| {
            var x2 = x * 2;
            var y2 = y * 2;

            var lux: f32 = 0;
            lux += screen_buffer[y2 * screen_width + x2];
            lux += screen_buffer[y2 * screen_width + x2 + 1];
            lux += screen_buffer[(y2 + 1) * screen_width + x2];
            lux += screen_buffer[(y2 + 1) * screen_width + x2 + 1];
            lux /= 4;

            screen_char_buffer[y * (char_buffer_width) + x] = lux_to_char(lux + if (lux > 0) noise_buffer[y * (char_buffer_width) + x] else 0);
        }

        screen_char_buffer[((y + 1) * char_buffer_width) - 1] = '\n';
    }

    std.debug.print("{s}", .{screen_char_buffer});
}
