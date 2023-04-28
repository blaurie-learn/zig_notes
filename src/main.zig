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

// if statements -------------------------------------------------------------
//
