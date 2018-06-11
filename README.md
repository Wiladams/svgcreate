# svgcreate
Simple Lua tools for creating SVG graphics

Originally birthed from the remotesvg project: https://github.com/Wiladams/remotesvg

Whereas remotesvg was concerned with presenting a simple svg driven web server, the code here is only focused on generating SVG files, using Lua as the coding language.

The directory 'svgcreate' contains the guts of the thing.  You can copy this directory into your 
lua installation, and go from there.

There are plenty of examples in the 'testy' directory, so look there to see how to do things.

In general, the idea is to use familiar Lua syntax while generating .svg out the backend.  Here is a typical usage:

```lua
#!/usr/bin/env luajit 

package.path = "../?.lua;"..package.path;

require("svgcreate.svgelements")()

local doc = svg {
    ['xmlns:xlink']="http://www.w3.org/1999/xlink",
    width="120", 
    height="120", 
    viewBox="0 0 120 120",

    defs {
        radialGradient {id="MyGradient",
            stop {offset="10%", ['stop-color']="gold"},
            stop {offset="95%", ['stop-color']="green"},
        },
    },

    circle {fill="url(#MyGradient)",
            cx="60", cy="60", r="50"
    },
}

local FileStream = require("svgcreate.filestream")
local svgstream = require("svgcreate.svgstream")
local ImageStream = svgstream(FileStream.open("test_radialgradient.svg"))

doc:write(ImageStream);
```

This will generate a radial gradient image.  The part that reall matters is

```lua
require("svgcreate.svgelements")()
```

This will bring in the svg creation module, and put commands in the global namespace '()'.  If you don't want things in the global namespace, you can simply do it this way:

```lua
local svg = require("svgcreate.svgelements")
```

More interesting writeups of what can be done with this are here: https://williamaadams.wordpress.com/?s=svg


