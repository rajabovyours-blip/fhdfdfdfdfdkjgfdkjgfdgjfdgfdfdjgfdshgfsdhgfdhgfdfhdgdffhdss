{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    // Force the HTML renderer to avoid CanvasKit memory limits and black images on scroll
    renderer: "html",
  },
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    
    // Remove the splash screen (if it exists) immediately
    const splash = document.getElementById("splash");
    if (splash) {
        splash.remove();
    }
    
    await appRunner.runApp();
  }
});
