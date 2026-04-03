const fs = require('fs');
let p = fs.readFileSync('entry/src/main/ets/pages/Play.ets', 'utf8');

// Fix accidental ??mport
p = p.replace("??mport", "import");

// The Swiper issue
// Look at lines 510 downwards
// 514:      })
// 515:    } // Close Swiper
// 516:    .onChange((i: number) => { this.swiperIndex = i })
if (p.includes("} // Close Swiper\n    .onChange")) {
  p = p.replace("} // Close Swiper\n    .onChange", ".onChange");
  // we removed the }, we need to add it AFTER the attributes
  p = p.replace(
    /(\.expandSafeArea\(\[SafeAreaType\.SYSTEM\], \[SafeAreaEdge\.TOP, SafeAreaEdge\.BOTTOM\]\))\n  \} \/\/ Close NavDestination/,
    "$1\n    } // Close Swiper\n  } // Close NavDestination"
  );
}

fs.writeFileSync('entry/src/main/ets/pages/Play.ets', p, 'utf8');