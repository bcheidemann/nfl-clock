// Emulate touch screen scrolling for Raspberry Pi Touch Display
// EXPLANATION: The default driver for the Raspberry Pi Touch Display
//              sends mouse inputs, so click and drag doesn't work
//              without this script.

import { isTauri } from "@tauri-apps/api/core";

if (isTauri()) {
  initializeTouchScreenEmulation();
}

function initializeTouchScreenEmulation() {
  console.log("Initialising touch screen emulation...");

  disableUserSelect();
  disableClickAndDragBehaviour();
  beginTouchInputScrollEmulation();
}

/**
 * Disables user select on all elements. This is necessary to prevent accidental
 * text selection when dragging.
 */
function disableUserSelect() {
  const styleTag = document.createElement("style");

  styleTag.innerHTML = `
    * {
      user-select: none;
      -webkit-user-select: none;
    }
  `;

  document.head.appendChild(styleTag);
}

/**
 * Disabled default click and drag behaviour on some elements. This is required
 * to prevent default drag behaviour of certain elements from interfering with
 * the emulated touch screen pan behaviour.
 */
function disableClickAndDragBehaviour() {
  document.querySelectorAll("a").forEach((a) => {
    a.addEventListener("dragstart", (e) => e.preventDefault());
  });

  document.querySelectorAll("img").forEach((a) => {
    a.addEventListener("dragstart", (e) => e.preventDefault());
  });
}

/**
 * Registers event listeners on the body to emulate normal touch and drag scroll
 * behaviour.
 */
function beginTouchInputScrollEmulation() {
  let isDown = false;
  let startY = 0;
  let initialScrollY = 0;

  document.body.addEventListener("pointerdown", (e) => {
    // Initialise scroll state
    isDown = true;
    startY = e.clientY;
    initialScrollY = window.scrollY;
  });

  document.body.addEventListener("pointermove", (e) => {
    // Ignore pointer move events when not dragging
    if (!isDown) return;

    // EXPLANATION: We can't do this on pointerdown because that would prevent
    //              clicking on elements.
    disableElementTouchEvents(e.pointerId);

    // Update scroll position
    const dy = e.clientY - startY;
    window.scroll(0, initialScrollY - dy);
  });

  document.body.addEventListener("pointerup", (e) => {
    // Stop
    isDown = false;
    enableElementTouchEvents(e.pointerId);
  });

  document.body.addEventListener("pointercancel", () => (isDown = false));
}

const disableTouchEventsTagId = "touch-screen-emulation--disable-touch-events";

/**
 * Disables touch events on all elements during scroll. This is necessary to
 * prevent accidentally clicking on elements on mouse up.
 */
function disableElementTouchEvents(pointerId: number) {
  // This is sufficient on most modern browsers
  document.body.setPointerCapture(pointerId);

  // The rest is required for webkitgtk, which incorrectly handles the pointer
  // capture API.

  // Avoid adding multiple tags while scrolling
  if (document.getElementById(disableTouchEventsTagId)) {
    return;
  }

  const styleTag = document.createElement("style");

  styleTag.id = disableTouchEventsTagId;

  styleTag.innerHTML = `
    * {
      pointer-events: none;
    }
  `;

  document.head.appendChild(styleTag);
}

/**
 * Re-enables touch events on all elements after scrolling is complete.
 */
function enableElementTouchEvents(pointerId: number) {
  document.body.releasePointerCapture(pointerId);
  document.getElementById(disableTouchEventsTagId)?.remove();
}
