const std = @import("std");
const expect = std.testing.expect;

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
    // integer literals have no size limitation. If UB occurs, the compiler
    //   catches it.
    // once  an integer is no longer known at compile time, it must have a
    // predefined size, and it is subject to Undefined Behavior (such as divide
    //   by zero and integer overflow).
    // to avoid overflow, can use alternative operators:
    //      +% and -% perform wrapping arithmetic
    //      +| and -| perform saturating arithmetic
    const one_plus_one: i32 = 1 + 1;
    dbgprint("1 + 1 = {}\n", .{one_plus_one});

    //floats
    // f16 f32 f64 f128
    // float literals  have type comptime_float, guaranteed to have same
    //   precision and operations of the largest float type, which is 128.
    // float literals coerce to any floating type, or any integer type when
    //   there is no fractional component.
    // default float operations use strict mode, but you can switch to
    //   optimized mode on a per-block basis
    @setFloatMode(.Optimized);
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
    dbgprint("{}\n", .{@TypeOf(bytes)}); // *const [5:0]u8
    dbgprint("{d}\n", .{bytes.len}); // 5
    dbgprint("{c}\n", .{bytes[1]}); // 'e'
    dbgprint("{d}\n", .{bytes[5]}); // 0
    dbgprint("{}\n", .{'e' == '\x65'}); // true
    dbgprint("{d}\n", .{'\u{1f4a9}'}); // 128169
    dbgprint("{d}\n", .{'💯'}); // 128175
    dbgprint("{}\n", .{mem.eql(u8, "hello", "h\x65llo")}); // true
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

pub fn variables() anyerror!void {
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

    dbgprint("{d}, {d}, {d}\n", .{ y, x, z });

    // generally preferable to use const rather than var.

    // identifiers are never allowed to shadow identifiers from an outer scope
    // identifiers must start with an alphanumeric character or underscore
    // identifiers must not overlap with keywords.
    // use @"" notation to create identifiers that break zigs rules
    // const @"identifer with spaces" = 0xff;

    // container level variables have static lifetime and are order independant
    // initialization of container level vars is implicitly comptime.
    // if a container level var is const then its value is comtime known,
    // otherwise it is runtime known

    //containers are any encapsulation higher than function:
    //      structs, enums, unions, opaques, zig source files

    // you can have local variables with static lifetime by using containers
    // inside functions:
    const S = struct {
        var t: i32 = 1234;
    };
    S.t += 1;
    dbgprint("static var in func: {d}\n", .{S.t});

    //local vars occur in functions, comptime blocks and @cImport blocks.
    // if the variable is const, its value will not chage, meaning it is
    // comptime known. This also makes the variable comptime known.

    // a local variable may be qualified qith comptime, causing the variable to
    // be comptime known. All loads of this variable will then occur during
    // semantic analysis of the program, not runtime. All variables declared
    // in a comptime expression are implicitly comptime.
    comptime var ct: i32 = 1;

    ct += 1;

    try expect(ct == 2);

    if (ct != 2) {
        //this compile error never trigger because y is comptime.
        // so y != 2 is statically evaluated, and y is 2.
        @compileError("wrong y value");
    }
}

// a variable can be specified to be threadlocal using the threadlocal keyword

threadlocal var tlv: i32 = 1234;
test "thread local storage" {
    const thread1 = try std.Thread.spawn(.{}, testTls, .{});
    const thread2 = try std.Thread.spawn(.{}, testTls, .{});
    testTls();
    thread1.join();
    thread2.join();
}
fn testTls() void {
    assert(tlv == 1234);
    tlv += 1;
    assert(tlv == 1235);
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

//operators
// zig does not allow operator overloading
pub fn operators() void {
    // has all the standard operators and bitshift operators
    // can suffix operators with % for wrapping +% *% -%
    // can suffix operators with | for saturating +| *| -|

    // a >>= b bitshift right, but b must be comptime known.
    // ~a bitwise not

    // a orelse b - is a is null, returns b, otherwise the unwrapped a.
    // a.? - equivalent to a orelse unreachable
    // a catch b - if a is an error, return b, otherwise the unwrapped a.
    // a catch |err| b
    // a and b - short circuiting and
    // a or b  - short circuiting or
    // a ++ b  - Array concatenation (only when a and b are comptime known)
    // a ** b  - array multiplication (only when a and b are comptime known)
    // a.* - pointer dereference
    //      const x: u32 = 1234;
    //      const ptr = &x;
    //      ptr.* == 1234;          (true)
    //
    // a || b  - merging error sets
}

// ARRAYS ----------------------------------------------

//array literal
const message = [_]u8{ 'h', 'e', 'l', 'l', 'o' };

//get the message
comptime {
    assert(message.len == 5);
}

//a string literal is a single item pointer to an array literal
const same_message = "hello";

comptime {
    assert(mem.eql(u8, &message, same_message));
}

test "iterate over an array" {
    var sum: usize = 0;
    for (message) |byte| {
        sum += byte;
    }
    try expect(sum == 'h' + 'e' + 'l' + 'l' + 'o');
}

//modifieable array
var some_integers: [100]i32 = undefined;

test "modify an array" {
    for (some_integers) |*item, i| {
        item.* = @intCast(i32, i);
    }
    try expect(some_integers[10] == 10);
    try expect(some_integers[99] == 99);
}

//array concatenation if the values are known at compile time
const part_one = [_]i32{ 1, 2, 3, 4 };
const part_two = [_]i32{ 5, 6, 7, 8 };
const all_of_it = part_one ++ part_two;
comptime {
    assert(mem.eql(i32, &all_of_it, &[_]i32{ 1, 2, 3, 4, 5, 6, 7, 8 }));
}

//string literal comptime concatenation (they're arrays!)
const hello = "hello";
const world = "world";
const hello_world = hello ++ " " ++ world;
comptime {
    assert(mem.eql(u8, hello_world, "hello world"));
}

//** doesrepeating patters:
const pattern = "ab" ** 3;
comptime {
    assert(mem.eql(u8, pattern, "ababab"));
}

//initialize an array of 10 elements to 0
const all_zero = [_]u16{0} ** 10;
comptime {
    assert(all_zero.len == 10);
    assert(all_zero[5] == 0);
}

//use compile-time code to initialize an array
var fancy_array = init: {
    var initial_value: [10]Point = undefined;
    for (initial_value) |*pt, i| {
        pt.* = Point{
            .x = @intCast(i32, i),
            .y = @intCast(i32, i) * 2,
        };
    }
    break :init initial_value;
};
const Point = struct {
    x: i32,
    y: i32,
};

test "compile time array init" {
    try expect(fancy_array[4].x == 4);
    try expect(fancy_array[4].y == 8);
}

//call a function to initialize an array
var more_points = [_]Point{makePoint(3)} ** 10;
fn makePoint(x: i32) Point {
    return Point{
        .x = x,
        .y = x * 2,
    };
}
test "array init with function calls" {
    try expect(more_points[4].x == 3);
    try expect(more_points[4].y == 6);
    try expect(more_points.len == 10);
}

//if theres no type in the result location then an anonymous list literal
//turns into a struct with numbered field names

test "fully anonymous list literal" {
    try dump(.{ @as(u32, 1234), @as(f64, 12.34), true, "hi" });
}

fn dump(args: anytype) !void {
    try expect(args.@"0" == 1234);
    try expect(args.@"1" == 12.34);
    try expect(args.@"2");
    try expect(args.@"3"[0] == 'h');
    try expect(args.@"3"[1] == 'i');
}

//multi-dimensional arrays are created by nesting arrays
const mat4x4 = [4][4]f32{
    [_]f32{ 1.0, 0.0, 0.0, 0.0 },
    [_]f32{ 0.0, 1.0, 0.0, 0.0 },
    [_]f32{ 0.0, 0.0, 1.0, 0.0 },
    [_]f32{ 0.0, 0.0, 0.0, 1.0 },
};
test "multidimensional array" {
    // access the 2d array by indexing the outer array, then the inner array
    try expect(mat4x4[1][1] == 1.0);

    //iterate a 2d array
    for (mat4x4) |row, row_index| {
        for (row) |cell, column_index| {
            if (row_index == column_index) {
                try expect(cell == 1.0);
            }
        }
    }
}

//sentinel terminated arrays
//the syntax "[N:x]T" describes an array which has a sentinel element of value
//x at the index corresponding to "len"
//note that the sentinel value is not part of the length
test "null terminated array" {
    const array = [_:0]u8{ 1, 2, 3, 4 };

    try expect(@TypeOf(array) == [4:0]u8);
    try expect(array.len == 4);
    try expect(array[4] == 0);
}

//Vectors ---------------------------------------------------------------
//group of booleans, integers, floats, or pointers which are operated on in
//parallel using SIMD instructions if possible.
//vector types are created with the builtin function @Vector
//
//Vectors support the same builtin operators as their underlying base types.
//These operations areperformed element-wise, and return a vector of the same
//length of the input vectors
//      Arithmetic (+ - / * @divFloor @sqrt @ceil @log etc)
//      Bitwise Operators (>> << & | ~ etc)
//      Comparison Operators (> < == etc)
//
//Prohibited to use a math operator on a misture of scalars. Zig provides
//@splat builtin to easily convert from scalar to vectors, and supports
//@reduce and array indexing to convert vectors to scalars.
//Vectors also support  assignment to and from fixed-length arrays with
//comptime known length
//
//for rearranging elements within and between vectors, zig provides
// @shuffle and @select functions
//
//Operations on vectors shorter than the target machines native SIMD
//size and will typically compile to single SIMD instructions, and longer than
//the natice SIMD size will compile to multiple SIMD instructions.
//If SIMD is not suported for the operation / target arch, the compiler will
//default to operating on each vector element one at a time
//Zig suport any comptime known vector length up to 2^32-1, though small powers
//of 2 are most typical (2-64).
const expectEqual = std.testing.expectEqual;

test "basic vector usage" {
    //Vectors have a compile time known length and base type
    const a = @Vector(4, i32){ 1, 2, 3, 4 };
    const b = @Vector(4, i32){ 5, 6, 7, 8 };

    //math operations take place element wise
    const c = a + b;

    //Individual vector elements can be accessed using array indexing syntax
    try expectEqual(6, c[0]);
    try expectEqual(8, c[1]);
    try expectEqual(10, c[2]);
    try expectEqual(12, c[3]);
}

test "Conversion between vector, arrays, and slices" {
    //Vectors and fixed legth arrays can be automatically assigned back and forth
    var arr1: [4]f32 = [_]f32{ 1.1, 3.2, 4.5, 5.6 };
    var vec: @Vector(4, f32) = arr1;
    var arr2: [4]f32 = vec;
    try expectEqual(arr1, arr2);

    //you can also assign from a slice with compile time known length to a
    //vectors using ".*"
    const vec2: @Vector(2, f32) = arr1[1..3].*;

    var slice: []const f32 = &arr1;
    var offset: u32 = 1;
    //To extract a compile time known length from a runtime known offset, first
    //extract a new slice from the starting offset, then an array of compile
    //known length
    //taking 0..2 of the slice offset..end
    const vec3: @Vector(2, f32) = slice[offset..][0..2].*;
    try expectEqual(slice[offset], vec2[0]);
    try expectEqual(slice[offset + 1], vec2[1]);
    try expectEqual(vec2, vec3);
}

//Pointers --------------------------------------------------------------------
//Zig has two kinds of pointers, signle item and many item
//  *T - single item pointer.
//      supports deref syntax "ptr.*"
//  [*]T - many itme pointer to unknown number of items
//      supports index syntax "ptr[i]"
//      supports slice syntax "ptr[start..end]"
//      supports pointer arithmetic "ptr + x", "ptr - x"
//      T must have known size, which means it cannot be anyopaque or any other opaque type
//
//These tpyes are closely related to Arrays and Slices
//  *[N]T = Pointer to N items, same as single item pointer to array
//      Supports index syntax "array_ptr[i]"
//      Supports slice syntax "array_ptr[start..end]"
//      Supports len property "array_ptr.len"
//  []T - is a slice (a fat pointer, which contains a pointer of type [*]T and a length)
//      Supports index syntax "slice[i]"
//      Supports slice syntax "slize[start..end]"
//      Supports len property "slice.len"
//
// use &x to obtain a single-item pointer
test "address of syntax" {
    //Get the address of a variable:
    const x: i32 = 1234;
    const x_ptr = &x;

    //dereference it:
    try expect(x_ptr.* == 1234);

    //When you get the address of a const variable, you get a const single item pointer
    try expect(@TypeOf(x_ptr) == *const i32);

    //If you want to mutate the value you need a pointer to a mutable variable
    var y: i32 = 5678;
    const y_ptr = &y;
    try expect(@TypeOf(y_ptr) == *i32);
    y_ptr.* += 1;
    try expect(y_ptr.* == 5679);
}

test "pointer array access" {
    //taking address of an individual element gives a single-item pointer.
    //This doesn't support arithmetic
    var array = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const ptr = &array[2];
    try expect(@TypeOf(ptr) == *u8);

    try expect(array[2] == 3);
    ptr.* += 1;
    try expect(array[2] == 4);
}

test "pointer arithmetic with many-item pointer" {
    const array = [_]i32{ 1, 2, 3, 4 };
    var ptr: [*]const i32 = &array;

    try expect(ptr[0] == 1);
    ptr += 1;
    try expect(ptr[0] == 2);
}

test "Pointer arithmetic with slices" {
    var array = [_]i32{ 1, 2, 3, 4 };
    var length: usize = 0;
    var slice = array[length..array.len];

    try expect(slice[0] == 1);
    try expect(slice.len == 4);

    slice.ptr += 1;
    //now the slice is in a bat state since len has no tbeen updated

    try expect(slice[0] == 2);
    try expect(slice.len == 4);
}

//In zig, prefer to work with slices since they have bounds checking and avoid
//undefined behavior
test "pointer slicing" {
    var array = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    const slice = array[2..4];
    try expect(slice.len == 2);

    try expect(array[3] == 4);
    slice[1] += 1;
    try expect(array[3] == 5);
}

test "comptime pointers" {
    //pointers will work at comptime as long as the code does not depend
    //on undefined memory layout
    comptime {
        var x: i32 = 1;
        const ptr = &x;
        ptr.* += 1;
        x += 1;
        try expect(ptr.* == 3);
    }
}

test "@ptrToInt and @intToPtr" {
    // convert integer address to ptr using @intToPtr, and convert pointer to
    // integer using @ptrToInt
    const ptr = @intToPtr(*i32, 0xdeadbee0);
    const addr = @ptrToInt(ptr);
    try expect(@TypeOf(addr) == usize);
    try expect(addr == 0xdeadbee0);

    //zig could also preserve this pointer in comptime and long as it is never
    //dereferenced.
}

//volatile ---------------------------------------------------------------
//loads and stores are assumed to not have side-effects. If it would,
//such as Memory Mapped IO (MMIO), use volatile.
//const mmio_ptr = @intToPtr(*volatile u8, 0x12345678);

//Alignment -------------------------------------------------------------
//each type has an alignment -- When a value of the type is loaded from or
//stored to memory, the memory address must be divisible by this number.
//use @alignOf to find out this value for any type
//
//In zig, a pointer type has an alignment value. If the value is equal to the
//value of the underlying type, it can be omitted from the type

const builtin = @import("builtin");

test "variable alignment" {
    var x: i32 = 1234;
    const align_of_i32 = @alignOf(@TypeOf(x));
    try expect(@TypeOf(&x) == *i32);
    try expect(*i32 == *align(align_of_i32) i32);
    if (builtin.target.cpu.arch == .x86_64) {
        try expect(@typeInfo(*i32).Pointer.alignment == 4);
    }

    //you can specify alignment on variables and functions.
    // probably not going to dive in to this much
}

//Sentinel Terminated Pointers --------------------------------------------
//The syntax "[*:x]T" describes a pointer that has a length determined by a
//sentinel value. This provides protection against buffer overflow and overread

//Slices ---------------------------------------------------------------
test "basic slices" {
    var array = [_]i32{ 1, 2, 3, 4 };
    //a slice is a pointer and a length. The difference between and array and
    //a sliceis that the arrays length is a part of the type known at compile
    //time. A slices length is known at runtime.
    //Both lengths can be access with the "len" field.

    var known_at_runtime_zero: usize = 0;
    const slice = array[known_at_runtime_zero..array.len];
    try expect(@TypeOf(slice) == []i32);
    try expect(&slice[0] == &array[0]);
    try expect(slice.len == array.len);

    //if you slice with comptime known start andend positions, the result is
    //a pointer to an array rather than a slice
    const array_ptr = array[0..array.len];
    try expect(@TypeOf(array_ptr) == *[array.len]i32);

    //using the address-of operator on a slice gives a single-item pointer,
    //while using the 'ptr' field gives a many-item pointer
    try expect(@TypeOf(slice.ptr) == [*]i32);
    try expect(@TypeOf(&slice[0]) == *i32);
    try expect(@ptrToInt(slice.ptr) == @ptrToInt(&slice[0]));

    //slices have array bounds checking. if you access something out of bounds,
    //you get a safety check failure
    //slice[10] += 1;  // out of bounds access error

    //note that 'slice.ptr' does not invoke safety checking, while '&slice[0]'
    //asserts that the slice has the len >= 1;
}

const fmt = std.fmt;
test "using slices for strings" {
    //zig has no concept of strings. String literals are const pointers to
    //null terminated arrays of u8, and b convention parameters that are
    //strings are expected to be utf-8 encoded slices of u8.
    //here we coerce *const [5:0]u8 and *const [6:0]u8 to []const u8
    const hello1: []const u8 = "hello";
    const world1: []const u8 = "世界";

    var all_together: [100]u8 = undefined;
    //you can use slice syntax on an array to convert an array into a slice.
    const all_together_slice = all_together[0..];
    //string concat example
    const hello_world1 = try fmt.bufPrint(all_together_slice, "{s} {s}", .{ hello1, world1 });

    //generally, you can use UTF-8 and not worry about whether something is
    //a string. if you don't need to deal with individual characters, no
    //need to decode.
    try expect(mem.eql(u8, hello_world1, "hello 世界"));
}

test "slice pointer" {
    var a: []u8 = undefined;
    try expect(@TypeOf(a) == []u8);
    var array: [10]u8 = undefined;
    const ptr = &array;
    try expect(@TypeOf(ptr) == *[10]u8);

    //a pointer to an array can be sliced just like an array
    var start: usize = 0;
    var end: usize = 5;
    const slice = ptr[start..end];
    slice[2] = 3;
    try expect(slice[2] == 3);
    //the slice was mutable because we used a mutable pointer
    try expect(@TypeOf(slice) == []u8);

    //again slicing with constant indexes will produce another pointer to an array
    const ptr2 = slice[2..3];
    try expect(ptr2.len == 1);
    try expect(ptr2[0] == 3);
    try expect(@TypeOf(ptr2) == *[1]u8);
}

//Sentinel terminated slices
//The syntax [:x]T is a slice which has a runtime knownlength and also
//guarantees a sentinel value at the element indexed by length.
//Sentinel values are not guaranteed to not otherwise appear.

test "null terminated slice" {
    const slice: [:0]const u8 = "hello";

    try expect(slice.len == 5);
    try expect(slice[5] == 0);
}

//Sentimel terminated slices can also be created using the syntax
//"data[start..end:x]" where data is a many-item pointer, array or slice

test "null terminated slicing" {
    var array = [_]u8{ 3, 2, 1, 0, 3, 2, 1, 0 };
    var runtime_length: usize = 3;
    const slice = array[0..runtime_length :0];

    try expect(@TypeOf(slice) == [:0]u8);
    try expect(slice.len == 3);

    //sentinel terminated slices asserts that the element at the sentinel
    //position of the backing data is actually the sentinel value. If this is
    //not the case, safety-protected Undefined Behavior results.
}

//structs --------------------------------------------------------------------
//

//declaring. Zig gives no guarantee about the order or size of the struct after
//compiling, but the fields are guranteed to be ABI aligned
const Point2 = struct {
    x: f32,
    y: f32,
};

test "struct test" {
    //declare an instance
    const p = Point2{ .x = 0.12, .y = 0.34 };

    //if you need to leave a field not filled:
    const p2 = Point2{
        .x = 0.12,
        .y = undefined,
    };

    const val = p.x == p2.x;
    try expect(val);
}

//structs can have methods.
//struct methods are not special in any way. They just get namespaced
const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn init(x: f32, y: f32, z: f32) Vec3 {
        return Vec3{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn dot(self: Vec3, other: Vec3) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }
};

test "dot product" {
    const v1 = Vec3.init(1.0, 0.0, 0.0);
    const v2 = Vec3.init(0.0, 1.0, 0.0);

    //notice that the self parameter also fills with v1
    try expect(v1.dot(v2) == 0.0);

    //note that the above is sugar for the below syntax. The compiler
    //simply inserts the v1 as the first parameter for you
    try expect(Vec3.dot(v1, v2) == 0.0);
}

//structs can have declarations
//structs can have 0 fields
const Empty = struct {
    pub const PI = 3.14;
};
test "struct namespaced variable" {
    try expect(Empty.PI == 3.14);
    try expect(@sizeOf(Empty) == 0);

    //you cna still instantiate an empty struct
    const does_nothing = Empty{};

    _ = does_nothing;
}

//struct field order is determined by the compiler for optimal performance.
//however, you can still calculate a struct base pointer given a field pointer
fn setYBasedOnX(x: *f32, y: f32) void {
    const point = @fieldParentPtr(Point2, "x", x);
    point.y = y;
}
test "field parent pointer" {
    var point = Point2{
        .x = 0.1234,
        .y = 0.5678,
    };
    setYBasedOnX(&point.x, 0.9);
    try expect(point.y == 0.9);
}

//you can return a struct from a function. This is how generics is done!
fn LinkedList(comptime T: type) type {
    return struct {
        pub const Node = struct {
            prev: ?*Node,
            next: ?*Node,
            data: T,
        };

        first: ?*Node,
        last: ?*Node,
        len: usize,
    };
}
test "Linked List" {
    //functions called at compile time are memoized, so you can do this:
    try expect(LinkedList(i32) == LinkedList(i32));

    var list = LinkedList(i32){
        .first = null,
        .last = null,
        .len = 0,
    };
    try expect(list.len == 0);

    //Since types are first class values, you can instantiate the type by
    //assigning it to a variable
    const ListOfInts = LinkedList(i32);
    try expect(ListOfInts == LinkedList(i32));

    var node = ListOfInts.Node{
        .prev = null,
        .next = null,
        .data = 1234,
    };
    var list2 = LinkedList(i32){
        .first = &node,
        .last = &node,
        .len = 1,
    };

    //When using a pointer to a struct fields can be accessed directly
    //without explicitly dereferencing the pointer.
    try expect(list2.first.?.data == 1234);
    //instead of
    //try expect(list2.first.?.*.data == 1234);
}

//structs can have defautl fields values. These are executed at comptime
const Foo = struct {
    a: i32 = 1234,
    b: i32,
};
test "default struct initialization fields" {
    //note that because "a" has a default, it can be ignored at init time
    const x = Foo{
        .b = 5,
    };

    if (x.a + x.b != 1239) {
        @compileError("It's even comptime known");
    }
}

//If you need a struct that has an in memory layout matching the C ABI for the
//target, then use "extern struct".
//This should only ever be used for compatibility with the C ABI.

//Maybe it needs to pass to opengl, so we need to be particular about how the
//bytes are arranged
// packed structs have guaranteed memory layout
// fields remain in the order declared, least to most significant
// zig supports arbitrary width ints but:
//      ints fewer than 8 bits will still use one byte
//      ints greater than 8 will use exactly their bit width
// bool fiels use exactly 1 bit
// an enum field uses exactly the width of its integer type
// a packed union field uses exactly the bit with of the union field that's largest
// non-ABI aligned fields are packed in to the smallest possible ABI aligned
//  integers in accordance with the target endianess.
//
//This means that a packed struct can participate in a @bitCast or a @ptrCast
// to reinterpret memory. This even works at comptime.
const Point3 = packed struct {
    x: f32,
    y: f32,
};
const native_endian = @import("builtin").target.cpu.arch.endian();

const Full = packed struct {
    number: u16,
};
const Divided = packed struct {
    half1: u8,
    quarter3: u4,
    quarter4: u4,
};

test "@bitCast between packed structs" {
    try doTheTest();
    comptime try doTheTest();
}

fn doTheTest() !void {
    try expect(@sizeOf(Full) == 2);
    try expect(@sizeOf(Divided) == 2);
    var full = Full{ .number = 0x1234 };
    var divided = @bitCast(Divided, full);
    try expect(divided.half1 == 0x34);
    try expect(divided.quarter3 == 0x2);
    try expect(divided.quarter4 == 0x1);

    var ordered = @bitCast([2]u8, full);
    switch (native_endian) {
        .Big => {
            try expect(ordered[0] == 0x12);
            try expect(ordered[1] == 0x34);
        },
        .Little => {
            try expect(ordered[0] == 0x34);
            try expect(ordered[1] == 0x12);
        },
    }
}

//Note that you can take the address of a field in a packed struct
//that is not byte aligned with the ampersand "&".
//However, note that non-byte aligned fields have special properties,
//so they cannot be passed in placed a normal pointer is expected.
//Pointers to non-ABI aligned fields share the same address as the other field
//within their host integer.
//We can use @bitOffsetOf and @offsetOf to see where the non-aligned field is

//it is possible to set the alignment of struct fields
const AlignedStruct = struct {
    a: u32 align(2),
    a: u32 align(64),
};

//Struct Naming ------------------------------------

//Since all structs in zig are anonymous, zig infers the name based on
//a few rules
//  -If the struct is in the initialization expression of a variable, it gets
//   named after that variable
//  -if the struct is in a return expression, it gets named after the function
//   it is returning from, with the parameter values serialized
//  -Otherwise the struct gets a name such as (anonymous struct at file.zig:7:38)
//  -If the struct is declared inside another struct, it gets named after both
//   the parent struct and the name inferred by the previous rules, separated
//   by a dot.
fn NamedList(comptime T: type) type {
    return struct {
        x: T,
    };
}

//Anonymous Struct Literals -------------------------------------------------
//Zig allows omitting the struct type of a literal. When the result is coerced
//the struct literal will directly instantiate the result location with no
//copy
test "anonymous struct literal" {
    var pt: Point = .{
        .x = 13,
        .y = 67,
    };

    try expect(pt.x == 13);
    try expect(pt.y == 67);

    //the struct type can be inferred. Here the result location does not include
    //a type, so zig infers it
    try dump_anon(.{
        .int = @as(u32, 1234),
        .float = @as(f64, 12.34),
        .b = true,
        .s = "hi",
    });

    //anonymous structs can be created without specifying field names, and are
    //referred to as tuples.
    //The fields are implicitly named using numbers starting from 0. Because
    //their names are integers, the @"0" syntax must be used to access them.
    //Names inside @"" are always recognized as identifiers
    //Like arrays, tuples have e .len field, can be indexed and work with the
    //++ and ** operators. They can also be iterated over with inline for
    const tuple = .{
        @as(u32, 1234),
        @as(f64, 12.34),
        true,
        "hi",
    };
    inline for (tuple) |v, i| {
        if (i != 2) continue;
        try expect(v);
    }
    try expect(tuple.len == 4);
    try expect(tuple.@"3"[0] == 'h');
}

fn dump_anon(args: anytype) !void {
    try expect(args.int == 1234);
    try expect(args.float == 12.34);
    try expect(args.b);
    try expect(args.s[0] == 'h');
    try expect(args.s[1] == 'i');
}

//enum ------------------------------------------------------------------------
//declare an enum
const Type = enum {
    ok,
    not_ok,
};

//a specific instance of the enum
const cc = Type.ok;

//If you want access to the ordinal value of the enum, you can specify the tag type
const Value = enum(u2) {
    zero,
    one,
    two,
};

//now you can cast between u2 and Value
//the ordinal value starts from 0, counting up each member
test "enum" {
    try expect(@enumToInt(Value.zero) == 0);
    try expect(@enumToInt(Value.one) == 1);
    try expect(@enumToInt(Value.two) == 2);
}

//you can overwrite the ordinal values
const Value2 = enum(u32) {
    hundred = 100,
    thousand = 1000,
    million = 1000000,
};

//enums can have methods, the same as structs and unions.
//Enum methods are not special, they are only namespaced functions
const Suit = enum {
    clubs,
    spades,
    diamonds,
    hearts,

    pub fn isClubs(self: Suit) bool {
        return self == Suit.clubs;
    }
};

//An enum variant of different types can be switched upon
const FooEnum = enum {
    string,
    number,
    none,
};
test "enum variant switch" {
    const p = FooEnum.number;
    const what_is_it = switch (p) {
        FooEnum.string => "this is a string",
        FooEnum.number => "this is a number",
        FooEnum.none => "this is a none",
    };

    try expect(mem.eql(u8, what_is_it, "this is a number"));
}

test "more enum" {
    //@typeInfo can be used to access the integer tag type of an enum
    try expect(@typeInfo(Value2).Enum.tag_type == u32);

    //@typeInfo tells the field_count and fields names
    try expect(@typeInfo(Value2).Enum.fields.len == 3);
    try expect(mem.eql(u8, @typeInfo(Value2).Enum.fields[1].name, "thousand"));
}

//extern enum ----------------------------------------------------------------
//by default, enums are not guaranteed to be compatible with C ABI.
//for a c abi compatible enum, provide an explicit tag type to the enum
const c_compatible = enum(c_int) { a, b, c };
export fn c_entry(foo: c_compatible) void {
    _ = foo;
}

//Enum literals allow specifying the name of an enum field without specifying
//an enum type
const Color = enum { auto, off, on };

test "enum literals" {
    const color1: Color = .auto;
    const color2 = Color.auto;
    try expect(color1 == color2);
}

test "switch using enum literals" {
    const color = Color.on;
    const result = switch (color) {
        .auto => false,
        .on => true,
        .off => false,
    };

    try expect(result);
}

//Non-exhaustive enum --------------------------------------------------------
//non-exhaustive enum can be created by adding a trailing "_" field. It must
//specify a tag type, and cannot consume every enumeration value.

//@intToEnum on a non-exhaustive enum involves safety semantics of @intCast
//to the integer tag type, but beyond that always results in a well-defined
//enum value.

//a switch on a non-exhaistive enum can include a '_' prong as an alternative
//to an else prong with the difference being that it makes it a compiler error
//if all the known tag names are not handled by the switch.

const Number1 = enum(u8) {
    one,
    two,
    three,
    _,
};

test "switch on non-exhaustive enum" {
    const number = Number1.one;
    const result = switch (number) {
        .one => true,
        .two, .three => false,
        _ => false,
    };
    try expect(result);
    const is_one = switch (number) {
        .one => true,
        else => false,
    };
    try expect(is_one);
}

//Union -----------------------------------------------------------------------
//a bare union defines a set of possible types that a value can be as a list of
//fields. Only one field can be active at a time. The in-memory representation
//of bare unions is not guaranteed. Bare unions cannot be used to reinterpret
//memory, for that use @ptrCast, or use an "extern union" or a "packed union"
//which have guaranteed in-memory layout. Accessing the non-active field is
//safety checked Undefined Behavior

const Payload = union {
    int: i64,
    float: f64,
    boolean: bool,
};
test "simple union" {
    var payload = Payload{ .int = 1234 };
    //payload.float = 12.34; // causes a panic

    //you can activate another field by reassigning the entire union
    payload = Payload{ .float = 12.34 };
    try expect(payload.float == 12.34);
}

//Tagged Union ----------------------------------------------------------------

//unions can be declared with an enum tag type. This turns the union in to a
//tagged union, which makes it eligable to use with switch expressions.
//tagged unions coerce to their tag type

const ComplexTagType = enum {
    ok,
    not_ok,
};
const ComplexType = union(ComplexTagType) {
    ok: u8,
    not_ok: void,
};

test "switch on tagged union" {
    const c = ComplexType{ .ok = 42 };
    try expect(@as(ComplexTagType, c) == ComplexTagType.ok);

    switch (c) {
        ComplexTagType.ok => |value| try expect(value == 42),
        ComplexTagType.not_ok => unreachable,
    }
}

test "get tag type" {
    try expect(std.meta.Tag(ComplexType) == ComplexTagType);
}

test "coerce to enum" {
    const c1 = ComplexType{ .ok = 42 };
    const c2 = ComplexType.not_ok;

    try expect(c1 == .ok);
    try expect(c2 == .not_ok);
}

//in order to modify the payload of a tagged union in a switch expression,
//place an * before the variable name to make it a pointer

test "modify tagged union in a switch" {
    var c = ComplexType{ .ok = 42 };
    try expect(@as(ComplexTagType, c) == ComplexTagType.ok);

    switch (c) {
        ComplexTagType.ok => |*value| value.* += 1,
        ComplexTagType.not_ok => unreachable,
    }

    try expect(c.ok == 43);
}

//unions can be made to infer the enum tag type. Furthermore, unions can have
//methods just like structs and enums
const Variant = union(enum) {
    int: i32,
    boolean: bool,

    //void can be ommitted when inferring enum tag
    none,

    fn truthy(self: Variant) bool {
        return switch (self) {
            Variant.int => |x_int| x_int != 0,
            Variant.boolean => |x_bool| x_bool,
            Variant.none => false,
        };
    }
};

test "union method" {
    var v1 = Variant{ .int = 1 };
    var v2 = Variant{ .boolean = false };

    try expect(v1.truthy());
    try expect(!v2.truthy());
}

//@tagName can be used to return a comptime [:0]const u8 value representing a
//field name
test "@tagName" {
    try expect(std.mem.eql(u8, @tagName(Variant.int), "int"));
}

//"extern union" has a memory layout guaranteed to be compatible with the
//C ABI

//a "packed union" has a well defined in-memory layout and is it eligable
//to be in a packed struct.

//Anonymous Union Literals
// syntax can be used to initialize unions without specifying the type
test "anonymous union literal syntax" {
    var i: Payload = .{ .int = 42 };
    var f = makeNumber();
    try expect(i.int == 42);
    try expect(f.float == 12.34);
}
fn makeNumber() Payload {
    return .{ .float = 12.34 };
}

//Opaque
//Opaque declares a new type with an unknown (but non-zero) size and alignment.
//It can contain declarations the same as structs, unions, and enums.

//This is typically used for type safety when interacting with C code that
//does not expose struct details.

const Derp = opaque {};
const Wat = opaque {};

extern fn barderp(d: *Derp) void;
fn foowat(w: *Wat) callconv(.C) void {
    //barderp(w); //compiler error
    _ = w;
}

test "call foo" {
    foowat(undefined);
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
    try variables();
    try variables();

    //testing struct naming
    const Foo1 = struct {};
    std.debug.print("variable: {s}\n", .{@typeName(Foo1)});
    std.debug.print("anonymous: {s}\n", .{@typeName(struct {})});
    std.debug.print("function: {s}\n", .{@typeName(NamedList(i32))});

    //blocks are used to limit the scope of variable declarations
    {
        var limited: i32 = 1;
        _ = limited;
    }
    //limited += 1;     //identifier doesn't exist in this scope

    //blocks are expressions. When labeled, break can be used to return
    //a value from the block
    var outer: i32 = 123;
    const outerplus = blk: {
        outer += 1;
        break :blk outer;
    };
    try expect(outer == 124);
    try expect(outerplus == 124);

    //identifiers are never allowed to "hide" or "shadow" other identifiers
    //by using the same name in the same scope
    {
        //evenin a block
        //var outer: i32 = 1234;        //compiler error
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "empty blocks" {
    //an empty block is equivalent to void{}
    const a = {};
    const b = void{};
    try expect(@TypeOf(a) == void);
    try expect(@TypeOf(b) == void);
}

test "simple Switch" {
    const a: u64 = 10;
    const zz: u64 = 103;

    //all branches of a switch must be coerced to a common type
    //branches cannot fall though, if you need fallthough, combine the cases
    //and use an if

    const b = switch (a) {
        //multiple cases combined with a comma
        1, 2, 3 => 0,

        //ranges can be specified with the ... syntax. Inclusive both ends
        5...100 => 1,

        //branches can be arbitrarily complex
        101 => blk: {
            const c: u64 = 5;
            break :blk c * 2 + 1;
        },

        //switching on arbitrary expressions is allowed as long as the
        //expression is known at compile time
        zz => zz,
        blk: {
            const d: u32 = 5;
            const e: u32 = 100;
            break :blk d + e;
        } => 107,

        //The else branch catches everything not already captured
        //else is mandatory unless the entire range of values is handled
        else => 9,
    };

    try expect(b == 1);
}

//switch can be outside of a function
const os_msg = switch (builtin.target.os.tag) {
    .linux => "we found a linux user",
    else => "not a linux user",
};

//inside a function, switch statements are implcitly compile time evaluated
//if the target expression is compile time known
test "switch inside funcion" {
    switch (builtin.target.os.tag) {
        .fuchsia => {
            //On an OS other than fuchsia, block is not even analyzed,
            //so this compiler error is not triggered.
            //on fuchsia, this compile error would be triggered
            @compileError("fuchsia not supported");
        },
        else => {},
    }
}

test "switch tagged union" {
    const Pt = struct {
        x: u8,
        y: u8,
    };
    const Item = union(enum) {
        a: u32,
        c: Pt,
        d,
        e: u32,
    };

    var a = Item{ .c = Pt{ .x = 1, .y = 2 } };

    //switching on more complex enums is allowed
    const b = switch (a) {
        //A capture group is allowed on a match, and will return the enum
        //value matched. If the payload types of both cases are the same,
        //they can be put into the same switch prong
        Item.a, Item.e => |item| item,

        //A reference to the matched value can be obtained using the * syntax
        Item.c => |*item| blk: {
            item.*.x += 1;
            break :blk 6;
        },

        //No else is required ifthe types cases was exhaustively handled
        Item.d => 8,
    };

    try expect(b == 6);
    try expect(a.c.x == 2);
}

const Color1 = enum {
    auto,
    off,
    on,
};

test "enum literals with switch" {
    const color = Color1.off;
    const result = switch (color) {
        .auto => false,
        .on => false,
        .off => true,
    };
    try expect(result);
}

// Inline Switch -----------------------
// Switch prongs can be marked "inline" to generate the prongs body for
// each possible value it could have
fn isFieldOptional(comptime T: type, field_index: usize) !bool {
    const fields = @typeInfo(T).Struct.fields;
    return switch (field_index) {
        //This prong is analyzed 'fields.len - 1' times with 'idx' being an
        //unique comptime known value each time.
        inline 0...fields.len - 1 => |idx| @typeInfo(fields[idx].field_type) == .Optional,
        else => return error.IndexOutOfBounds,
    };
}

const Struct1 = struct {
    a: u32,
    b: ?u32,
};

const expectError = std.testing.expectError;

test "using @typeInfo with runtime values" {
    var index: usize = 0;
    try expect(!try isFieldOptional(Struct1, index));
    index += 1;
    try expect(try isFieldOptional(Struct1, index));
    index += 1;
    try expectError(error.IndexOutOfBounds, isFieldOptional(Struct1, index));
}

// Calls to `isFieldOptional` on `Struct1` get unrolled to an equivalent
// of this function:
fn isFieldOptionalUnrolled(field_index: usize) !bool {
    return switch (field_index) {
        0 => false,
        1 => true,
        else => return error.IndexOutOfBounds,
    };
}

//inline else prongs can be used as a typesafe alternative to inline for loops

const SliceTypeA = extern struct {
    len: usize,
    ptr: [*]u32,
};

const SliceTypeB = extern struct {
    ptr: [*]SliceTypeA,
    len: usize,
};

const AnySlice = union(enum) {
    a: SliceTypeA,
    b: SliceTypeB,
    c: []const u8,
    d: []AnySlice,
};

fn withFor(any: AnySlice) usize {
    const Tag = @typeInfo(AnySlice).Union.tag_type.?;
    inline for (@typeInfo(Tag).Enum.fields) |field| {
        //with 'inline for' the function gets generated as a series of 'if'
        //statements relying on the optimizer to convert it to a switch
        if (field.value == @enumToInt(any)) {
            return @field(any, field.name).len;
        }
    }
    //when using 'inline for' the compiler doesnt know that every possible case
    //has been handled requiring an explicit unreachable
    unreachable;
}

fn withSwitch(any: AnySlice) usize {
    return switch (any) {
        //with 'inline else' the function is explicitly generated as the
        //desired switch and the compiler can check that every possible case
        //is handled.
        inline else => |slice| slice.len,
    };
}

test "inline for and inline else similarity" {
    var any = AnySlice{ .c = "hello" };
    try expect(withFor(any) == 5);
    try expect(withSwitch(any) == 5);
}

//when using an inline prong  swtiching on an union, an additional capture
//can be used to obtain the unions enum tag value
const U = union(enum) {
    a: u32,
    b: f32,
};

fn getNum(u: U) u32 {
    switch (u) {
        //here 'num'  is a runtime known value that is either u.a or u.b and
        //tag is a u's comtime known tag value
        inline else => |num, tag| {
            if (tag == .b) {
                return @floatToInt(u32, num);
            }
            return num;
        },
    }
}

test "union inline switch prong tag capture" {
    var u = U{ .b = 42 };
    try expect(getNum(u) == 42);
}

// WHILE LOOP ----------------------------------------------------------------
test "while basic" {
    var i: usize = 0;
    while (i < 10) {
        i += 1;
    }
    try expect(i == 10);
}

test "while break" {
    var i: usize = 0;
    while (true) {
        if (i == 10) {
            break;
        }
        i += 1;
    }
    try expect(i == 10);
}

test "while continue" {
    var i: usize = 0;
    while (true) {
        i += 1;
        if (i < 10) {
            continue;
        }
        break;
    }
    try expect(i == 10);
}

//while loops also support a continue expression.
//the continue keyword respects the expression.
test "while loop continue expression" {
    var i: usize = 1;
    var j: usize = 1;
    while (i * j < 2000) : ({
        i *= 2;
        j *= 3;
    }) {
        const my_ij = i * j;
        try expect(my_ij < 2000);
    }
}

//while is an expression. 'break', like return accepts a parameter.
//if you 'break' a while loop, the 'else' is not evaluated
fn rangeHasNumber(begin: usize, end: usize, number: usize) bool {
    var i = begin;

    return while (i < end) : (i += 1) {
        if (i == number) {
            break true;
        }
    } else false;
}

//labeled while --------------

test "nexted break" {
    outer: while (true) {
        while (true) {
            break :outer;
        }
    }
}

test "nested Continue" {
    var i: usize = 0;
    outer: while (i < 10) : (i += 1) {
        while (true) {
            continue :outer;
        }
    }
}

//while with OPTIONALS --------------------------------------
//while can take an optional as the condition and capture the payload. When
//null is encountered, the loop exits.
//when |x| syntax is present on a while expression, the while condition must
//have an Optional Type.
//The else branch is allowed on optional iteration, in this case it will be
//executed on the first null value encountered
test "while null capture" {
    var sum1: u32 = 0;
    numbers_left = 3;
    while (eventuallyNullSequence()) |value| {
        sum1 += value;
    }
    try expect(sum1 == 3);

    var sum2: u32 = 0;
    numbers_left = 3;
    while (eventuallyNullSequence()) |value| {
        sum2 += value;
    } else {
        try expect(sum2 == 3);
    }
}
var numbers_left: u32 = undefined;
fn eventuallyNullSequence() ?u32 {
    return if (numbers_left == 0) null else blk: {
        numbers_left -= 1;
        break :blk numbers_left;
    };
}

//while with error unions
//while can take an error union as the condition and capture the payload or
//the error code. When the condition results in an error code, the else branch
//is evaluated and the loop is finished
//when 'else |x|' syntax is present on a while, the while condition must
//have an error union type
test "while error union capture" {
    var sum1: u32 = 0;
    numbers_left = 3;
    while (eventuallyErrorSequence()) |value| {
        sum1 += value;
    } else |err| {
        try expect(err == error.ReachedZero);
    }
}

fn eventuallyErrorSequence() anyerror!u32 {
    return if (numbers_left == 0) error.ReachedZero else blk: {
        numbers_left -= 1;
        break :blk numbers_left;
    };
}

//inline while
//inline while loop will be unrolled, which allows the code to so some things
//while only work at compile time, such as use types as first class values
test "inline while loop" {
    comptime var i = 0;
    var sum: usize = 0;
    inline while (i < 3) : (i += 1) {
        const T = switch (i) {
            0 => f32,
            1 => i8,
            2 => bool,
            else => unreachable,
        };
        sum += typeNameLength(T);
    }
    try expect(sum == 9);
}
fn typeNameLength(comptime T: type) usize {
    return @typeName(T).len;
}

//it is recommended that you use inline loops only when you need to execute
//the loop at compile time for semantics to work, for you have a benchmark
//to prove that forcibly unrolling the loop is measurably faster

// for loop -------------------------------------------------------------

test "for basics" {
    const items = [_]i32{ 4, 5, 3, 4, 0 };
    var sum: i32 = 0;

    //for loops iterate over slices and arrays
    for (items) |value| {
        //break and continue are supported
        if (value == 0) {
            continue;
        }
        sum += value;
    }
    try expect(sum == 16);

    //to iterate over a portion, slice
    for (items[0..1]) |value| {
        sum += value;
    }
    try expect(sum == 20);

    //to access the index of the iteration, specify a second capture value
    //this is zero-indexed
    var sum2: i32 = 0;
    for (items) |_, i| {
        try expect(@TypeOf(i) == usize);
        sum2 += @intCast(i32, i);
    }
    try expect(sum2 == 10);
}

test "for reference" {
    var items = [_]i32{ 3, 4, 2 };

    //iterate over the slice by reference by specifying that the capture
    //value is a pointer
    for (items) |*value| {
        value.* += 1;
    }

    try expect(items[0] == 4);
    try expect(items[1] == 5);
    try expect(items[2] == 3);
}

test "for else" {
    //for allows an else attached to it, the same as a while loop
    var items = [_]?i32{ 3, 4, null, 5 };

    //for loops can also be used as expressions
    //similar to while loops, when you break from a for loop, the else is not
    //evaluated
    var sum: i32 = 0;
    const result = for (items) |value| {
        if (value != null) {
            sum += value.?;
        }
    } else blk: {
        try expect(sum == 12);
        break :blk sum;
    };
    try expect(result == 12);
}

//labeled for -----------------------------------------------
//when a for loop is labeled, it can be references from a break or continue
//from within a nexted loop

test "nested break" {
    var count: usize = 0;
    outer: for ([_]i32{ 1, 2, 3, 4, 5 }) |_| {
        for ([_]i32{ 1, 2, 3, 4, 5 }) |_| {
            count += 1;
            break :outer;
        }
    }
    try expect(count == 1);
}

test "nexted continue" {
    var count: usize = 0;
    outer: for ([_]i32{ 1, 2, 3, 4, 5, 6, 7, 8 }) |_| {
        for ([_]i32{ 1, 2, 3, 4, 5 }) |_| {
            count += 1;
            continue :outer;
        }
    }
    try expect(count == 8);
}

//inline for -----------------------------------------------------------------
//for loops can be inlined. this causes the loop to be unrolled, which allows
//the code to do some things which only work at compile time, such as use
//first class values. The capture value and iterator value of inlined
//for loops are compile time known

test "inline for loop" {
    const nums = [_]i32{ 2, 4, 6 };
    var sum: usize = 0;

    inline for (nums) |i| {
        const T = switch (i) {
            2 => f32,
            4 => i8,
            6 => bool,
            else => unreachable,
        };
        sum += typeNameLength2(T);
    }
    try expect(sum == 9);
}

fn typeNameLength2(comptime T: type) usize {
    return @typeName(T).len;
}

//if ---------------------------------------------------------
//if expressions have 3 uses, corresponding to 3 types
//  bool
//  ?T
//  anyerror!T

test "if expression" {
    //if is used instead of ternary
    const a: u32 = 5;
    const b: u32 = 4;
    const result = if (a != b) 47 else 3089;
    try expect(result == 47);
}

test "if boolean" {
    //for a boolean test
    const a: u32 = 5;
    const b: u32 = 4;
    if (a != b) {
        try expect(true);
    } else if (a == 9) {
        unreachable;
    } else {
        unreachable;
    }
}

test "if optional" {
    //to test for null

    const a: ?u32 = 0;
    if (a) |value| {
        try expect(value == 0);
    } else {
        unreachable;
    }

    const b: ?u32 = null;
    if (b) |_| {
        unreachable;
    } else {
        try expect(true);
    }

    //else is not required
    if (a) |value| {
        try expect(value == 0);
    }

    //to test against null only, use the binary equality
    if (b == null) {
        try expect(true);
    }

    //access the value by reference using a pointer capture
    var c: ?u32 = 3;
    if (c) |*value| {
        value.* = 2;
    }

    if (c) |value| {
        try expect(value == 2);
    }
}

test "if error union" {
    const a: anyerror!u32 = 0;
    if (a) |value| {
        try expect(value == 0);
    } else |err| {
        _ = err;
        unreachable;
    }

    const b: anyerror!u32 = error.BadValue;
    if (b) |value| {
        _ = value;
        unreachable;
    } else |err| {
        try expect(err == error.BadValue);
    }

    //the else and error capture is required
    if (a) |value| {
        try expect(value == 0);
    } else |_| {}

    //to check only the error value, use an empty block expression
    if (b) |_| {} else |err| {
        try expect(err == error.BadValue);
    }

    //access the value by reference using a pointer capture
    var c: anyerror!u32 = 3;
    if (c) |*value| {
        value.* = 9;
    } else |_| {
        unreachable;
    }
}

test "if error union with optional" {
    //if expressions rest for error before unwrapping optionals.
    //the |optional_value| captures type is ?u32

    const a: anyerror!?u32 = 0;
    if (a) |optional_value| {
        try expect(optional_value.? == 0);
    } else |err| {
        _ = err;
        unreachable;
    }

    const b: anyerror!?u32 = null;
    if (b) |optional_value| {
        try expect(optional_value == null);
    } else |_| {
        unreachable;
    }

    const c: anyerror!?u32 = error.BadValue;
    if (c) |optional_value| {
        _ = optional_value;
        unreachable;
    } else |err| {
        try expect(err == error.BadValue);
    }

    var d: anyerror!?u32 = 3;
    if (d) |*optional_value| {
        if (optional_value.*) |*value| {
            value.* = 9;
        }
    } else |_| {
        unreachable;
    }

    if (d) |optional_value| {
        try expect(optional_value.? == 9);
    } else |_| {
        unreachable;
    }
}

//defer ----------------------------------------------------------------------
fn deferExample() !usize {
    var a: usize = 1;

    {
        defer a = 2;
        a = 1;
    }
    try expect(a == 2);

    a = 5;
    return a;
}

test "defer basics" {
    try expect((try deferExample()) == 5);
}

//if multiple defer statements are specified, they will be executed in reverse
//order that they were run
fn deferUnwindExample() void {
    dbgprint("\n", .{});

    defer {
        dbgprint("1 ", .{});
    }
    defer {
        dbgprint("2 ", .{});
    }
    if (false) {
        //defers are not run if they are never executed
        defer {
            dbgprint("3 ", .{});
        }
    }
}

test "defer unwinding" {
    deferUnwindExample();
}

//errdefer keyword is similar to defer, but will only execute if the scope
//returns with an error.
//
//This is expecially useful in allowing a function to clean up properly on
//error, and replaces goto error handling tactics seen in C
fn deferErrorExample(is_error: bool) !void {
    dbgprint("\nstart of function\n", .{});

    //this will always be executed on exit
    defer {
        dbgprint("end of the function\n", .{});
    }

    errdefer {
        dbgprint("encountered an error\n", .{});
    }

    //inside a defer method, the return statement is not allowed. The following
    //is not allowed
    //defer {
    //  return error.DeferError;
    //}

    if (is_error) {
        return error.DeferError;
    }
}

//the errdeferkeyword supports an alternative syntax to capture the error
//generated in case of one error.
//
//This is useful when during cleanup after an error, additional message needs
//to be printed.
fn deferErrorCaptureExample() !void {
    errdefer |err| {
        std.debug.print("the error is {s}\n", .{@errorName(err)});
    }

    return error.DeferError;
}

test "errdefer unwinding" {
    deferErrorExample(false) catch {};
    deferErrorExample(true) catch {};
    deferErrorCaptureExample() catch {};
}

//unreachable --------------------------------------------------
//in debug and ReleaseSafe mode, unreachable emits a call to panic with the
//message "reached unreachable code"
//
//In ReleaseSmall and ReleaseFast mode, the optimizer uses the assumption that
//unreachable code will never be hit to perform optimizations

test "basic math" {
    const x = 1;
    const y = 2;
    if (x + y != 3) {
        unreachable;
    }
}

//noreturn -------------------------------------------------------------------'
//noreturn is a type, and is the type of
//  break
//  continue
//  return
//  unreachable
//  while (true) {}
//
//When resolving types together, such as if clauses or switch prongs,
//the noreturn type is compatible with every other type
fn test_noreturn(condition: bool, b: u32) void {
    const a = if (condition) b else return;
    _ = a;
    @panic("do something with a");
}
test "noreturn" {
    test_noreturn(false, 1);
}

//another use case for noreturn is the 'exit' function

//const WINAPI: std.builtin.CallingConvention = if (builtin.cpu.arch == .i386) .Stdcall else .C;
//extern "kernel32" fn ExitProcess(exit_code: c_uint) callconv(WINAPI) noreturn;

//test "foo" {
//    const value = bar_noreturn() catch ExitProcess(1);
//    try expect(value == 1234);
//}

//fn bar_noreturn() anyerror!u32 {
//    return 1234;
//}

//functions ------------------------------------------------------------------
//
//functions are declared like this
fn add(a: i8, b: i8) i8 {
    if (a == 0) {
        return b;
    }

    return a + b;
}

//export makes a function externally visible in the generated object, and makes
//it follow the C ABI
export fn sub_export(a: i8, b: i8) i8 {
    return a - b;
}

//the extern specifier is used to declare a function that will be resoleved
//at link time, when linking statically, or at runtime when linking dynamically
//the callconv specifier changes the calling convention of the function
//const WINAPI: std.builtin.CallingConvention = if (native_arch == .i386) .Stdcall else .C;
//extern "kernel32" fn ExitProcess(exit_code: u32) callconv(WINAPI) noreturn;
//extern "c" fn atan2(a: f64, b: f64) f64;

//@setCold builtin tells the optimizer that the function is rarely called
fn abort() noreturn {
    @setCold(true);
    while (true) {}
}

//tnaked calling convention makes a function not have any prologue or epilogue.
//This can be useful when integrating with assembly
fn _start() callconv(.Naked) noreturn {
    abort();
}

//inline calling convention forces a function to be inlined at all call sites.
//If the function cannot be inlined, it is a compile time error
inline fn shiftLeftOne(a: u32) u32 {
    return a << 1;
}

//pub specifier allows the function to be visible when importing
//another file can use @import and call sub_pub
fn sub_pub(a: i8, b: i8) i8 {
    return a - b;
}

//function pointers are prefixed with '*const'
const call2_op = *const fn (a: i8, b: i8) i8;
fn do_op(fn_call: call2_op, op1: i8, op2: i8) i8 {
    return fn_call(op1, op2);
}

test "function" {
    try expect(do_op(add, 5, 6) == 11);
    try expect(do_op(sub_pub, 5, 6) == -1);
}

//function body are comptime only types
//function pointers may be runtime known

//pass by value semantics
//primitive types are always pass by value
//structs, unions, and arrays can sometimes be more efficiently passed by
//reference depending on the size. When they are passed as parameters, zig
//may choose whichever is faster between pass by reference or pass by value

//The function body can ignore he differenc ebetween reference or value and
//always treat a parameters as value. Incidentally, be careful when taking
//the address of a parameter. it should always be treated as if the address
//will become invalue when the function returns

//for extern functions, zig follows the C ABI for passing structs and unions
//by value.

//function parameter type inference ------------------------------------------
//declare parameters with anytype in the place of the type. In this case
//the parameter type will be inferred when the function is called.
//use @TypeOf and @typeInfo to get info about the inferred type
fn addFortyTwo(x: anytype) @TypeOf(x) {
    return x + 42;
}

test "type inference" {
    try expect(addFortyTwo(1) == 43);
    try expect(@TypeOf(addFortyTwo(1)) == comptime_int);
    var y: i64 = 2;
    try expect(addFortyTwo(y) == 44);
    try expect(@TypeOf(addFortyTwo(y)) == i64);
}

//functions can be reflected
test "function reflection" {
    try expect(@typeInfo(@TypeOf(expect)).Fn.args[0].arg_type.? == bool);
    try expect(@typeInfo(@TypeOf(expect)).Fn.is_var_args == false);
}

//Errors ---------------------------------------------------------------------
//An error set is like an enum. However, each error name accross the entire
//compilation gets assigned an unsigned integer greater than 0. You are allowed
//to declare the same error name more than once, and if you do, it gets
//assigned the same integer value

//You can have subsets and supersets, and coerce from a subset to a superset.
//But you cannot coerce from a superset to a subset.
//AllocationError is a subset because it comes second and declares and error
//with the same name as FileOpenError (OutOfMemory)
const FileOpenError = error{
    AccessDenied,
    OutOfMemory,
    FileNotFound,
};

const AllocationError = error{
    OutOfMemory,
};

fn force_alloc_error(err: AllocationError) FileOpenError {
    return err;
}

test "coerce subset to superset" {
    const err = force_alloc_error(AllocationError.OutOfMemory);
    try std.testing.expect(err == FileOpenError.OutOfMemory);
}

//there is a shortcut for declaring an error with only one value, and then
//getting that value
//const err = error.FileNotFound;
//
//is equivalent to
//const err = (error { FileNotFound }).FileNotFound

//the global error set -------------------------------------------------------
//"anyerror" refers to the global error set. This is the set that contains
//all the erros fr the entire compilation unit. It is a superset of all
//other error sets and a subset of none.
//Any error can coerce to the global set, and you can explicitly cast an error
//of the global error set to a non-global one (language level asserted)
//
//The global error set should be generally avoided because it prevents the
//compiler from knowing what errors are possible at compile time. Knowing the
//error at compile time is better for generated documentation and helpful
//error messages.

//Error Union Type -----------------------------------------------------------
//An error set type and normal type can be combined with the ! binary operator
//to form a union type.

const maxInt = std.math.maxInt;

//notice the return type is !u64. This means the function will return either
//u64, or an error. We left the errorset to the left of ! empty, so it is
//inferred.
pub fn parseU64(buf: []const u8, radix: u8) !u64 {
    var x: u64 = 0;

    for (buf) |c| {
        const digit = charToDigit(c);

        if (digit >= radix) {
            return error.InvalidChar;
        }

        if (@mulWithOverflow(u64, x, radix, &x)) {
            return error.Overflow;
        }

        if (@addWithOverflow(u64, x, digit, &x)) {
            return error.Overflow;
        }
    }

    return x;
}

fn charToDigit(c: u8) u8 {
    return switch (c) {
        '0'...'9' => c - '0',
        'A'...'Z' => c - 'A' + 10,
        'a'...'z' => c - 'a' + 10,
        else => maxInt(u8),
    };
}

test "parse u64" {
    const result = try parseU64("1234", 10);
    try std.testing.expect(result == 1234);
}

//You can use the "catch" binary operator to provide a default value
test "catch" {
    const number = parseU64("1234", 10) catch 13;
    _ = number;

    //the rhs of the catch operator must match the unwrapped type, or be
    //of the type noreturn.
}

//there is a shortcut for
//const number = parseU64(str, 10) catch |err| return err;
//known as the "try" expression
fn do_try(str: []u8) !void {
    const number = try parseU64(str, 10);
    _ = number; //try leaves number unwrapped!
}

//if we know for certain that an expression will never error
fn do_never_error(str: []u8) void {
    const number = parseU64(str, 10) catch unreachable;
    _ = number;
    //unreachable generates a panic in debug and ReleaseSafe modes. It is
    //Undefined Behavior in ReleaseFast mode.
}

//or say you would like to take a different action for each error. Combine
//the if and switch blocks
fn do_each_thing(str: []u8) void {
    if (parseU64(str, 10)) |number| {
        _ = number;
    } else |err| switch (err) {
        error.Overflow => {
            //handle overflow
        },
        error.InvalidChar => unreachable,
    }
}

//errdefer -------------------------------------------------------------------
//defer statements are the other component to error handling. zig provides
//defer adn errdefer, the later which evaluates the deferred expression
//on block exit path only if the function returned with an error
//from the block.

const FooErr = struct {
    data: u32,
};

//fn createFooErr(param: i32) FooErr {
//    const foo = try tryToAllocateFooErr();
//
//    //no foo is allocated, but we need to free it if the function fails
//    //or return it if the function succeeds
//    errdefer deallocateFooErr(foo);
//
//    const tmp_buf = allocateTmpBuffer() orelse return error.OutOfMemory;
//    //tmp_buf is trule a temporary resource, and we for sure want to clean it
//    //up before this block leaves scope
//    defer deallocateTmpBuffer(tmp_buf);
//
//    if (param > 1337) return error.InvalidParam;
//
//    //here, errdefer will not run since we're rturning success from the function
//    //but the defer will run.
//    return foo;
//}

const Allocator = std.mem.Allocator;

fn tryToAllocateFooErr(allocator: Allocator) !*FooErr {
    return allocator.create(FooErr);
}

fn deallocateFooErr(allocator: Allocator, foo: *FooErr) void {
    allocator.destroy(foo);
}

fn getFooErrData() !u32 {
    return 666;
}

fn createFooErr(allocator: Allocator, param: i32) !*FooErr {
    const foo = getFooErr: {
        var foo = try tryToAllocateFooErr(allocator);
        errdefer deallocateFooErr(allocator, foo);

        //calls deallocateFooErr on error
        foo.data = try getFooErrData();

        break :getFooErr foo;

        //the scope here will not have ended in an error, so the errdefer above
        //will not run here
    };

    //outside of the scope of the errdefer above, so deallocateFooErr will not be
    //called here.
    //we have to add one here as well
    errdefer deallocateFooErr(allocator, foo);
    if (param > 1337) return error.InvalidParam;

    return foo;
}

test "createFooErr" {
    try std.testing.expectError(error.InvalidParam, createFooErr(std.testing.allocator, 2468));
}

const FooPtrs = struct {
    data: *u32,
};

//That errdefer only lasts for the block is important for loops.
fn genFooPtrs(allocator: Allocator, num: usize) ![]FooPtrs {
    var foos = try allocator.alloc(FooPtrs, num);
    errdefer allocator.free(foos);

    for (foos) |*foo, i| {
        foo.data = try allocator.create(u32);
        //this errdefer does not last between iterations!!!
        errdefer allocator.destroy(foo.data);

        _ = i;
        //the data for the first 3 foos will be leaked!
        //if (i >= 3) return error.TooManyFoos;

        foo.data.* = try getFooErrData();
    }

    return foos;
}

test "genFoos" {
    //try std.testing.expectError(error.TooManyFoos, genFooPtrs(std.testing.allocator, 5));
}

fn genFooPtrsFixed(allocator: Allocator, num: usize) ![]FooPtrs {
    var foos = try allocator.alloc(FooPtrs, num);
    errdefer allocator.free(foos);

    // used to track how many foos have been initialized including their
    // data being deallocated
    var num_allocated: usize = 0;
    errdefer for (foos[0..num_allocated]) |foo| {
        allocator.destroy(foo.data);
    };
    for (foos) |*foo, i| {
        foo.data = try allocator.create(u32);
        num_allocated += 1;

        if (i >= 3) return error.TooManyFoos;

        foo.data.* = try getFooErrData();
    }

    return foos;
}

test "genFoosFixed" {
    try std.testing.expectError(error.TooManyFoos, genFooPtrsFixed(std.testing.allocator, 5));
}

//Compiler time reflection of the error union:
test "error union" {
    var foo: anyerror!i32 = undefined;

    // Coerce from child type of an error union:
    foo = 1234;

    // Coerce from an error set:
    foo = error.SomeError;

    // Use compile-time reflection to access the payload type of an error union:
    comptime try expect(@typeInfo(@TypeOf(foo)).ErrorUnion.payload == i32);

    // Use compile-time reflection to access the error set type of an error union:
    comptime try expect(@typeInfo(@TypeOf(foo)).ErrorUnion.error_set == anyerror);
}

//merging error sets
//use || operator to merge two error sets together
//If they both have doc comments, then the left side comments have precedent

const A = error{
    NotDir,

    /// A doc comment
    PathNotFound,
};
const B = error{
    OutOfMemory,

    /// B doc comment
    PathNotFound,
};

const C = A || B;

fn fooMerge() C!void {
    return error.NotDir;
}

test "merge error sets" {
    if (fooMerge()) {
        @panic("unexpected");
    } else |err| switch (err) {
        error.OutOfMemory => @panic("unexpected"),
        error.PathNotFound => @panic("unexpected"),
        error.NotDir => {},
    }
}

//This is especially useful for functions returning different error sets
//depending on comptime branches

//inferred error sets
//because many functions in zig return a pooible error, zig supports inferring
//the error set. To have an inferred set, simply use the ! operator without
//a left hadn side error type declaration
//when a functions has an inferred error set that function becomes generic
//and thus it becomes trickier to do certain things with is, such as obtain
//a function pointer, or have an error set that is consistent across different
//build targets. Inferred error sets are additionally incompatible with
//recursion.

// with an inferred error set
pub fn add_inferred(comptime T: type, a: T, b: T) !T {
    var answer: T = undefined;
    return if (@addWithOverflow(T, a, b, &answer)) error.Overflow else answer;
}

//with an explicit error set
pub fn add_explicit(comptime T: type, a: T, b: T) Error!T {
    var answer: T = undefined;
    return if (@addWithOverflow(T, a, b, &answer)) error.Overflow else answer;
}

const Error = error{
    Overflow,
};

test "inferred error set" {
    if (add_inferred(u8, 255, 1)) |_| unreachable else |err| switch (err) {
        error.Overflow => {},
    }
}

//Error return traces -------------------------------------------------
//Error return traces show all the points in the code that an error was returned
//to the calling function. This makes it practical to use "try" everywhere and
//then still now what happened in an error ends up bubbling all the way out
//of your applicaiton.
//This is not a stack trace
//Error return traces keep track of how an error started and how it ended up
//  for example, an error further up in the trace might start with a
//  FileNotFound, but get to your code as a PermissionError. With the ERT
//  you can know this
//
//ERT is enabled in Debug and ReleaseSafe, and disabled in ReleaseFast and
//ReleaseSmall
//
//  You can activate this feature by
//  -Return an error from main
//  -an error makes it to "catch unreachable" and you have not overridded
//   the default panic handler
//  -use errorReturnTrace to access the current trace. use
//   std.debug.dumpStackTrace to print it.

//Optionals ------------------------------------------------------------------
//The ? symbolizes and optional type

test "basic optional" {
    //normal integer
    const normal_int: i32 = 1234;
    _ = normal_int;

    //optional integer
    const optional_int: ?i32 = 5678;
    _ = optional_int;

    //now the variable "optinal_int" could be either an i32, or "null"
}

fn optional_ptr() ?*u8 {
    return null;
}

fn do_a_thing() ?*u8 {
    const unwrapped = optional_ptr() orelse return null;

    //here, you see that the orelse will cause the value to unwra, and if the
    //unwrap returns null, then we would return null;

    return unwrapped;
}

test "zig optional references" {
    //zig does not have null references like C. Although an optional pointer
    //compiles down to a regular pointer, and zig will use the value of 0 for
    //null, zig protects you from dereferencing null, or accidentally being
    //able to pass a null where the code says you must pass something

}

const OptionalFoo = struct {};
fn doSomethingWithFoo(foo: *OptionalFoo) void {
    _ = foo;
}

fn foAThingWithFoo(optional_foo: ?*OptionalFoo) void {
    //do some stuff

    //Here is another common pattern seen with optionals. doSomethingWithFoo
    //requires an OptionalFoo that is not null, meaning it assumes you are
    //passing a real value.
    if (optional_foo) |foo| {
        doSomethingWithFoo(foo);

        //notably, inside here, foo is guaranteed to be pointing at something
        //by the compiler.
    }

    //do some stuff
}

//one benefit to writing functions with pointers that cannot be null is that
//this actually opens up certain optimization paths in the compiler

test "optional compile time reflection" {
    //declare an optional and coerce from null
    var foo: ?i32 = null;

    //coerce from child type of an optional
    foo = 1234;

    //compile time reflection to access the child type of the optional
    comptime try expect(@typeInfo(@TypeOf(foo)).Optional.child == i32);
}

//null has its own type, and the only way to use null is to cast it to a
//different type

//Optional Pointers are guaranteed to be the same size as a pointer.
//The null of the optional is guaranteed to be address 0

//Casting ---------------------------------------------------------------------
//a type cast converts a value form one type to another
//zig has
// -Type Coercion for conversins that are known to be safe and unambiguous
// -Explicit casts for conversions that you wouldn't want to run by accident
// -Peer Type Resolution for when a result type is decided by multiple operand
// types

//type coercion occurs when one type expected, but another is provided.
//type coercions are only allowed when it is completely unambigiuous how to
//get one type from another and the transformation is guaranteed to be safe

//values which have the same representation at runtime can be cast to increase
//the strictness of the qualifiers
//  "const"     - non const to const is allowed
//  "volatile"  - non volatile to volatile is allowed
//  "align"     - bigger to smaller alignment is allowed
//  error sets to super sets is allowed
//
//the above casts are no-ops at runtime since the value representation
//does not change
//
//in addition, pointers coerce to const optional pointers
//
//integers coerce to wider integers
//floats coerce to wider floats

//Coercion of Slices, Arrays and Pointers ------------------------

//You can assign constant pointers to arrays to a slice with const modifier
//on the element type. Useful for String literals
test "*const [N]T to []const T" {
    var x1: []const u8 = "hello";
    var x2: []const u8 = &[5]u8{ 'h', 'e', 'l', 'l', 111 };
    try expect(std.mem.eql(u8, x1, x2));

    var y: []const f32 = &[2]f32{ 1.2, 3.4 };
    try expect(y[0] == 1.2);
}

//it works when the destination type is an error union
test "*const [N]T to E![]const T" {
    var x1: anyerror![]const u8 = "hello";
    var x2: anyerror![]const u8 = &[5]u8{ 'h', 'e', 'l', 'l', 111 };
    try expect(std.mem.eql(u8, try x1, try x2));

    var y: anyerror![]const f32 = &[2]f32{ 1.2, 3.4 };
    try expect((try y)[0] == 1.2);
}

//it works when the destination type is an optional
test "*const [N]T to E![]const T" {
    var x1: ?[]const u8 = "hello";
    var x2: ?[]const u8 = &[5]u8{ 'h', 'e', 'l', 'l', 111 };
    try expect(std.mem.eql(u8, x1.?, x2.?));

    var y: ?[]const f32 = &[2]f32{ 1.2, 3.4 };
    try expect(y.?[0] == 1.2);
}

//in this cast, the array length becomes the slice length
test "*[N]T to []T" {
    var buf: [5]u8 = "hello".*;
    const x: []u8 = &buf;
    try expect(std.mem.eql(u8, x, "hello"));

    const buf2 = [2]f32{ 1.2, 3.4 };
    const x2: []const f32 = &buf2;
    try expect(std.mem.eql(f32, x2, &[2]f32{ 1.2, 3.4 }));
}

//Single-item pointers to arrays can be coerced in to many-item pointers
test "*[N]T to [*]T" {
    var buf: [5]u8 = "hello".*;
    const x: [*]u8 = &buf;
    try expect(x[4] == 'o');
    //x[5] would be an uncaught out of bounds pointer dereference!
}

//this works when the destination is optional
test "*T to ?[*]T" {
    var buf: [5]u8 = "hello".*;
    const x: ?[*]u8 = &buf;
    try expect(x.?[4] == 'o');
}

//single-item pointers can be cast to the len-1 single-item arrays
test "*T to *[1]T" {
    var x: i32 = 1234;
    const y: *[1]i32 = &x;
    const z: [*]i32 = y;
    try expect(z[0] == 1234);
}

//Optional coercion
//The payload type as well as null coerce to the optional type
test "coerce to optional" {
    const x: ?i32 = 1234;
    const y: ?i32 = null;

    try expect(x.? == 1234);
    try expect(y == null);
}

//also works nexted in the error union type
test "coerce optionals wrappe din error union" {
    const x: anyerror!?i32 = 1234;
    const y: anyerror!?i32 = null;

    try expect((try x).? == 1234);
    try expect((try y) == null);
}

//the error union type as well as the error set type coerce to the error union
//type

test "coercion to error unions" {
    const x: anyerror!i32 = 1234;
    const y: anyerror!i32 = error.Failure;

    try expect((try x) == 1234);
    try std.testing.expectError(error.Failure, y);
}

//when a number is comptime know to be representable in the dest type, it
//may be coerced

//tagged unions can be coerced to enums, and enums can be coerced
//to tagged unions when they are comptime known to be a field of the union
//that only has one possible value

const E = enum { one, two, three };

const UN = union(E) { one: i32, two: f32, three };

test "coercion between unions and enums" {
    var u = UN{ .two = 12.34 };
    var e: E = u;
    try expect(e == E.two);

    const three = E.three;
    var another_u: UN = three;
    try expect(another_u == E.three);
}

//Explicit casts occur with builtins:
//    @bitCast - change type but maintain bit representation
//    @alignCast - make a pointer have more alignment
//    @boolToInt - convert true to 1 and false to 0
//    @enumToInt - obtain the integer tag value of an enum or tagged union
//    @errSetCast - convert to a smaller error set
//    @errorToInt - obtain the integer value of an error code
//    @floatCast - convert a larger float to a smaller float
//    @floatToInt - obtain the integer part of a float value
//    @intCast - convert between integer types
//    @intToEnum - obtain an enum value based on its integer tag value
//    @intToError - obtain an error code based on its integer value
//    @intToFloat - convert an integer to a float value
//    @intToPtr - convert an address to a pointer
//    @ptrCast - convert between pointer types
//    @ptrToInt - obtain the address of a pointer
//    @truncate - convert between integer types, chopping off bits

//Zero Bit Types---------------------
//For some types @sizeOf is 0
//  void
//  the Integers u0 an i0
//  Arrays and Vectors with a len 0, or an element type that is a zero bit type
//  an enum with only one tag
//  a struct with all fields being zero bit types
//  a union with only 1 field which is a zero bit type
//
//These types can only ever have one possible value, and thus require 0 bits
//to represent

//void --------------------------------

//void can be useful for instantiating generic types. For example, a
//Map(Key, Value) one can pass void for the value type to make it a Set

test "turn hashmap to set with void" {
    var map = std.AutoHashMap(i32, void).init(std.testing.allocator);
    defer map.deinit();

    try map.put(1, {});
    try map.put(2, {});

    try expect(map.contains(2));
    try expect(!map.contains(3));

    _ = map.remove(2);
    try expect(!map.contains(2));
}

//usingnamespace----------------------------------
//is a declaration that mixes the public declarations of the operand
//which must be a struct, union, enum or opaque into the namespace
test "using std namespace" {
    const S = struct {
        usingnamespace @import("std");
    };

    try S.testing.expect(true);
}

//comptime --------------------------------------------------------------------
//
