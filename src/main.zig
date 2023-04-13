const std = @import("std");

// Amalgamation notes from:
// https://ziglang.org/documentation/0.10.1
// https://ziglearn.org
// https://github.com/ratfactor/ziglings

// zig has a reasonably size standard library.

// Comments -----
// //	Comment
// ///	Documentation Comment
// //!	Top Level Documentation Comment
// only has single line comments, beginning with "//"
// as well as documentation comments, which begin with "///".
//	doc comments are only allowed in certain places.
// and top level documentation comments, which are documentation comments
// which do not belong to whatever immediately follows. Beginning with "//!"

// Values -------------------
// top level declarations are order independant
const dbgprint = std.debug.print;
const assert = std.debug.assert;
pub fn values() void {
    //integers
    // i8 i16 i32 i64 i128 isize
    // u8 u16 u32 u64 u128 usize
    // c_short c_int c_long c_longlong
    // c_ushort c_uint c_ulong c_ulonglong
    const one_plus_one: i32 = 1 + 1;
    dbgprint("1 + 1 = {}\n", .{one_plus_one});

    //floats
    // f16 f32 f64 f128
    const seven_div_three: f32 = 7.0 / 3.0;
    dbgprint("7.0 / 3.0 = {}\n", .{seven_div_three});

    //boolean
    // bool
    dbgprint("{}\n{}\n{}\n", .{
        true and false,
        true or false,
        !true,
    });

    //optional
    // begins with question mark "?"
    var optional_value: ?[]const u8 = null;
    assert(optional_value == null);

    //note that @TypeOf will run at compile time!
    dbgprint("\noptional 1\n type: {}\nvalue: {?s}\n", .{
        @TypeOf(optional_value),
        optional_value,
    });

    optional_value = "hi";
    assert(optional_value != null);

    dbgprint("\noptional 2\ntype: {}\nvalue: {?s}\n", .{
        @TypeOf(optional_value),
        optional_value,
    });

    //error union
    // bang "!" with lhs is error type, rhs is value type
    var number_or_error: anyerror!i32 = error.ArgNotFound;

    dbgprint("\nerror union 1\ntype: {}\nvalue: {!}\n", .{
        @TypeOf(number_or_error),
        number_or_error,
    });

    number_or_error = 1234;

    dbgprint("\nerror union 2\ntype: {}\nvalue: {!}\n", .{
        @TypeOf(number_or_error),
        number_or_error,
    });

    //a few more value types:
    // anyopaque  -- c equivalent is void

    //void - Always the value "void{}"
    //noreturn - the type of break, continue, return, unreachable, and while
    //type - the type of types
    //anyerror - an error code
    //comptime_int - Only allowed for comptime-known values. type of integer literals
    //comptime_float - Only allowed for comptime-known values. type of float literals

    // Additionally, arbitary bit width integers can be references by using
    // and "i" or "u" identifier followed by digits.
    // i7 is a 7-bit integer
    // maximum bit-width is 65535

    //primitive values:
    // true and false - are bool values
    // null - sets an optional to null
    // undefined - used to leave a value unspecified
}

const mem = @import("std").mem; 
pub fn strings() void {
    dbgprint("{s}", .{"\n\n----- Strings ------\n"});
    const bytes = "hello";
    dbgprint("{}\n", .{@TypeOf(bytes)});                    // *const [5:0]u8
    dbgprint("{d}\n", .{bytes.len});                        // 5
    dbgprint("{c}\n", .{bytes[1]});                         // 'e'
    dbgprint("{d}\n", .{bytes[5]});                         // 0
    dbgprint("{}\n", .{'e' == '\x65'});                     // true
    dbgprint("{d}\n", .{'\u{1f4a9}'});                      // 128169
    dbgprint("{d}\n", .{'💯'});                             // 128175
    dbgprint("{}\n", .{mem.eql(u8, "hello", "h\x65llo")});  // true
    dbgprint("0x{x}\n", .{"\xff"[0]}); // non-UTF-8 strings are possible with \xNN notation
    dbgprint("{u}\n", .{'⚡'});

    //multiline string literals use \\ token at the start of each line
    const hello_world_in_c = 
        \\#include <stdio.h>
        \\
        \\int main(int argc, char **argv) {
        \\  printf("hello world\n");
        \\  return 0;
        \\}\n
        ;
    dbgprint("{s}", .{hello_world_in_c});
    //you could additionally make use of @embedFile, which would read the 
    //contents of a file into a variable at compile time.

}



pub fn variables() void {
    // const - once assigned, cannot change
    const y = 5678;
    //y += 1;   // illegal. will not compile
    //const applies to all of the bytes that an identifier immediately addresses.
    //pointers have their own const-ness
    
    //mutable variables can be declared with var
    var x: i32 = 8765;
    x += 1;

    //variables must be initialized, or use undefined to initialize later
    //var z: i32;   // illegal. won't compile
    var z: i32 = undefined;
    z = 9876;

    // undefined can be coerced in to any type, and once a variable is set to
    // it, it is no longer possible to detect.
    // This means the value of the variable could be anything, even nonsense.
    // undefined is "not a meaningful value. Use without a later assignment 
    // would be a bug."

    // In debug builds, zig write 0xaa bytes to undefine memory. This is to
    // catch bugs. This is only an implementation feature, and not guaranteed
    // to be visible to code. do not rely on it.

    // should probably avoid heavy use of undefined.

    dbgprint("{d}, {d}, {d}", .{y, x, z});
}


// code written within one or more "test" declarations can be use to ensure
// behavior meets expectations

fn add_one(number: i32) i32 {
    return number + 1;
}


// test declarations contain the keyword "test" followed by an optional name,
// followed by a body that contains any zig code valid in a function.
// non-named tests, by convention, should only be used to call other tests
// https://ziglang.org/documentation/0.10.1/#Nested-Container-Tests

// test declarations are like functions. they have a reutrn type and a block of
// code. The implicit return tupe is anyerror!void, and it cannot be changed.

//tests can be written in the same file or in a separate file. Since tests
//are top level, they are order independant.

test "expect add_one add one to 41" {
    //standard library contains useful functions to help create tests
    //expect is a function that verifies its argument is true
    try std.testing.expect(add_one(41) == 42);

    //use "zig test" in the command line to run the test runner, which will
    //execute all tests and return a report.
}








pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!

    values();
    strings();
    variables();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
