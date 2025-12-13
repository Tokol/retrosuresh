// Set with custom image and fallback
window.flutterSetCursor = function(cursorUrl) {
  try {
    const img = new Image();
    img.src = cursorUrl;

    img.onload = function() {
      const xHotspot = Math.floor(img.width / 2);
      const yHotspot = Math.floor(img.height / 2);
      document.body.style.cursor = `url('${cursorUrl}') ${xHotspot} ${yHotspot}, auto`;
    };

    img.onerror = function() {
      console.warn('Cursor image failed to load, using fallback');
      document.body.style.cursor = 'pointer';
    };
  } catch (e) {
    console.error('Cursor error:', e);
    document.body.style.cursor = 'auto';
  }
};

// Reset to default
window.flutterResetCursor = function() {
  document.body.style.cursor = 'auto';
};