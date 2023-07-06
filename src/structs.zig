//There are multiple ways to create a struct in zig

//In zig, all source files are a struct with the name of the file with the extension truncated
// Use this pattern when you have a single struct returning from a file
const structs = @This();    // Structs will now represent the type structs

pub fn init(self: structs) structs {
    
}



//Import these two below with:
//const structs = @import("structs.zig").structs;

//use this pattern when you have more than one struct returning, or just need a new struct,
//but arent handing off (ie constructor jumps) frequently:
pub const structs = struct {
    
};


//use this pattern when you'll be handing off a lot between different methods, or will have many different
//types defined in one file
pub fn structs() type {
    return struct {
        const Self = @This();
        
    }
}