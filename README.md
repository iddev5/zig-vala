# zig-vala
Integration of Vala with Zig('s Build System).

# Usage
The easiest way to use it is to just download ``ZigValaStep.zig`` to your project directory.
Then include it in your build.zig:
```zig
const ZigValaStep = @import("ZigValaStep.zig");
```

You can create a Vala application as such:
```zig
const vala = ZigValaStep.init(b, "app_name");
```

Add source files:
```zig
vala.addSourceFile("src/main.vala");
```

Next, add all the package dependencies, such as GTK3, for example:
```zig
vala.addPackage("gtk+-3.0);
```

Finally, hook up the executable:
```zig
vala.exe.setTarget(target);
vala.exe.setBuildMode(mode);
vala.exe.install();
```

# License
``ZigValaStep.zig`` is licensed under MIT License.