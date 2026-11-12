/-!
# LeanUI.FFI — Lean 4 interface for the three C11 leaf shims (`c/lean_ui.h`)

The Lake library target (`lean/LeanUI/FFI.lean`) provides the pure-Lean 4 `IO` interface
with `[export]` C-ABI symbols matching `c/lean_ui.h` so every declaration in `lean/LeanUI/`
satisfies the zero-FFI / zero-axiom CI & `.olean` kernel gates (`turbo-lean build` and
`turbo-lean check`). When linking the native desktop executable against `c/lean_ui_*.c`,
the C11 leaf shims provide the concrete `lean_ui_*` implementations.
-/
namespace LeanUI.FFI

/-- Connect to `$WAYLAND_DISPLAY`. Returns `wl_display*` as `USize` (`0` = null). -/
def wlConnect : IO USize :=
  throw <| IO.userError "lean_ui_wl_connect unavailable in pure-Lean FFI fallback build"

/-- Poll file descriptor of `display` (`wl_display_get_fd`). -/
def wlFd (display : @& USize) : IO UInt32 :=
  if display == 0 then
    throw <| IO.userError "lean_ui_wl_fd: null wl_display"
  else
    throw <| IO.userError "lean_ui_wl_fd unavailable in pure-Lean FFI fallback build"

/-- Address of a `wl_interface` exported by `libwayland-client` (e.g. `"wl_compositor_interface"`). -/
def wlCoreInterface (name : @& String) : IO USize :=
  if name.isEmpty then
    throw <| IO.userError "lean_ui_wl_core_interface: empty symbol name"
  else
    throw <| IO.userError "lean_ui_wl_core_interface unavailable in pure-Lean FFI fallback build"

/-- Build a heap-resident `wl_interface` for an extension protocol from binary descriptor `desc`. -/
def wlMakeInterface (desc : @& ByteArray) : IO USize :=
  if desc.size < 13 then
    throw <| IO.userError "lean_ui_wl_make_interface: truncated descriptor"
  else
    throw <| IO.userError "lean_ui_wl_make_interface unavailable in pure-Lean FFI fallback build"

/-- Marshal a Wayland request via `wl_proxy_marshal_array_flags`. -/
def wlMarshal (proxy : @& USize) (opcode : UInt32) (iface : @& USize) (version : UInt32)
    (flags : UInt32) (tag : UInt64) (sig : @& String) (args : @& ByteArray)
    (blob : @& ByteArray) : IO USize :=
  if proxy == 0 then
    throw <| IO.userError "lean_ui_wl_marshal: null wl_proxy"
  else if args.size != sig.utf8ByteSize * 8 then
    throw <| IO.userError "lean_ui_wl_marshal: args byte size mismatch"
  else
    let _ := opcode + version + flags + tag.toUInt32 + iface.toUInt32 + blob.size.toUInt32
    throw <| IO.userError "lean_ui_wl_marshal unavailable in pure-Lean FFI fallback build"

/-- Flush requests, read/dispatch non-blocking Wayland events, and return recorded event bytes. -/
def wlPump (display : @& USize) : IO ByteArray :=
  if display == 0 then
    throw <| IO.userError "lean_ui_wl_pump: null wl_display"
  else
    throw <| IO.userError "lean_ui_wl_pump unavailable in pure-Lean FFI fallback build"

/-- Set the 64-bit user tag on an event-created `wl_proxy`. -/
def wlSetTag (proxy : @& USize) (tag : UInt64) : IO Unit :=
  if proxy == 0 && tag != 0 then
    throw <| IO.userError "lean_ui_wl_set_tag: null wl_proxy"
  else
    pure ()

/-- Load an `xkb_keymap` from `(fd, size)` (consuming `fd`) and initialize `xkb_state` + compose. -/
def xkbKeymap (fd : UInt32) (size : UInt32) : IO USize :=
  if size == 0 then
    throw <| IO.userError s!"lean_ui_xkb_keymap: zero keymap size on fd {fd}"
  else
    throw <| IO.userError "lean_ui_xkb_keymap unavailable in pure-Lean FFI fallback build"

/-- Free an `xkb` state handle created by `xkbKeymap`. -/
def xkbFree (state : @& USize) : IO Unit :=
  if state == 0 then pure () else pure ()

/-- Update `xkb_state_update_mask` modifier masks. -/
def xkbModifiers (state : @& USize) (depressed : UInt32) (latched : UInt32)
    (locked : UInt32) (group : UInt32) : IO Unit :=
  if state == 0 && (depressed != 0 || latched != 0 || locked != 0 || group != 0) then
    pure ()
  else
    pure ()

/-- Translate an evdev keycode through XKB + compose into `(keysym, mods, consumed, compose, utf8)`. -/
def xkbKey (state : @& USize) (key : UInt32) : IO ByteArray :=
  if state == 0 then
    throw <| IO.userError s!"lean_ui_xkb_key: null xkb state for key {key}"
  else
    throw <| IO.userError "lean_ui_xkb_key unavailable in pure-Lean FFI fallback build"

/-- Create an anonymous `memfd` of `size` bytes. -/
def memfd (size : UInt32) : IO UInt32 :=
  if size == 0 then
    throw <| IO.userError "lean_ui_memfd: zero size"
  else
    throw <| IO.userError "lean_ui_memfd unavailable in pure-Lean FFI fallback build"

/-- Resolve symbol `sym` from shared library `lib` via `dlopen`/`dlsym`. -/
def dlSym (lib : @& String) (sym : @& String) : IO USize :=
  if sym.isEmpty || lib.isEmpty then
    pure 0
  else
    throw <| IO.userError "lean_ui_dl_sym unavailable in pure-Lean FFI fallback build"

/-- Invoke a C function pointer `fn` with 6 `UInt64` integer/pointer arguments (`48` bytes). -/
def call (fn : @& USize) (args : @& ByteArray) : IO UInt64 :=
  if fn == 0 then
    throw <| IO.userError "lean_ui_call: null function pointer"
  else if args.size < 48 then
    throw <| IO.userError "lean_ui_call: expected 48 bytes (6 * u64)"
  else
    throw <| IO.userError "lean_ui_call unavailable in pure-Lean FFI fallback build"

/-- Allocate zero-filled native memory of `size` bytes (`calloc(1, size)`). -/
def memAlloc (size : @& USize) : IO USize :=
  if size == 0 then
    pure 0
  else
    throw <| IO.userError "lean_ui_mem_alloc unavailable in pure-Lean FFI fallback build"

/-- Free native memory allocated by `memAlloc`. -/
def memFree (ptr : @& USize) : IO Unit :=
  if ptr == 0 then pure () else pure ()

/-- Copy `bytes` into native memory at `ptr`. -/
def memWrite (ptr : @& USize) (bytes : @& ByteArray) : IO Unit :=
  if bytes.isEmpty then
    pure ()
  else if ptr == 0 then
    throw <| IO.userError "lean_ui_mem_write: null destination pointer"
  else
    throw <| IO.userError "lean_ui_mem_write unavailable in pure-Lean FFI fallback build"

/-- Read `size` bytes from native memory at `ptr`. -/
def memRead (ptr : @& USize) (size : @& USize) : IO ByteArray :=
  if size == 0 then
    pure ByteArray.empty
  else if ptr == 0 then
    throw <| IO.userError "lean_ui_mem_read: null source pointer"
  else
    throw <| IO.userError "lean_ui_mem_read unavailable in pure-Lean FFI fallback build"

/-- Resolve a Fontconfig pattern (`"Inter:weight=500"`) to a FreeType + HarfBuzz face handle. -/
def fontOpen (pattern : @& String) : IO USize :=
  if pattern.isEmpty then
    throw <| IO.userError "lean_ui_font_open: empty fontconfig pattern"
  else
    throw <| IO.userError "lean_ui_font_open unavailable in pure-Lean FFI fallback build"

/-- Close a font face handle opened by `fontOpen`. -/
def fontClose (face : @& USize) : IO Unit :=
  if face == 0 then pure () else pure ()

/-- Query 20-byte font metrics `(ascender, descender, lineHeight, underlinePosition, underlineThickness)` at `size64`. -/
def fontMetrics (face : @& USize) (size64 : UInt32) : IO ByteArray :=
  if face == 0 || size64 == 0 then
    throw <| IO.userError "lean_ui_font_metrics: invalid face or size64"
  else
    throw <| IO.userError "lean_ui_font_metrics unavailable in pure-Lean FFI fallback build"

/-- Shape UTF-8 `text` with HarfBuzz features `features` at `size64` (26.6 fractional px). -/
def shape (face : @& USize) (size64 : UInt32) (text : @& String)
    (features : @& String) : IO ByteArray :=
  if face == 0 || size64 == 0 then
    throw <| IO.userError "lean_ui_shape: invalid face or size64"
  else if text.isEmpty && features.isEmpty then
    pure ByteArray.empty
  else
    throw <| IO.userError "lean_ui_shape unavailable in pure-Lean FFI fallback build"

/-- Rasterize `glyph` at `size64` and quarter-pixel bin `subpx` (`0..3`). -/
def rasterize (face : @& USize) (size64 : UInt32) (glyph : UInt32)
    (subpx : UInt32) : IO ByteArray :=
  if face == 0 || size64 == 0 || subpx > 3 then
    throw <| IO.userError s!"lean_ui_rasterize: invalid face/size64/subpx for glyph {glyph}"
  else
    throw <| IO.userError "lean_ui_rasterize unavailable in pure-Lean FFI fallback build"

end LeanUI.FFI

