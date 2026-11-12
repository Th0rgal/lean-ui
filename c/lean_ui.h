/* lean_ui.h — frozen C ABI between LeanUI (Lean 4) and its three C11 leaf shims.
 *
 * Rule: the shims hold no protocol, layout or rendering logic. They are call bridges.
 * Lean builds every request (Wayland argument arrays, Vulkan structs, shaping requests)
 * as bytes and decodes every reply from bytes. Each .c file stays <= 220 LOC and builds
 * with -std=gnu11 -O2 -Wall -Wextra -Werror.
 *
 * Conventions
 *  - All functions run in IO (trailing lean_obj_arg world, lean_io_result return).
 *  - `b_lean_obj_arg` = borrowed; the shim never retains a Lean object past the call.
 *  - Native pointers cross as size_t (Lean USize). 0 is null.
 *  - Byte layouts are little-endian, native alignment for x86_64 / aarch64 LP64.
 *  - Failures return an IO error; nothing is partially applied.
 */
#ifndef LEAN_UI_H
#define LEAN_UI_H
#include <lean/lean.h>

/* ---- lean_ui_wayland.c : libwayland-client + libxkbcommon ------------------------ */

/* Connect to $WAYLAND_DISPLAY. Returns wl_display* . */
lean_obj_res lean_ui_wl_connect(lean_obj_arg w);
/* Poll fd of the display (for the lean-sys reactor). Returns UInt32. */
lean_obj_res lean_ui_wl_fd(size_t display, lean_obj_arg w);
/* Address of a wl_interface exported by libwayland (e.g. "wl_compositor_interface"). */
lean_obj_res lean_ui_wl_core_interface(b_lean_obj_arg name, lean_obj_arg w);
/* Build a wl_interface for an extension protocol. `desc` is
 *   name\0 version:u32 nMethods:u32 nEvents:u32 then per message: name\0 signature\0
 * Types of object/new_id args are left NULL (untyped), which libwayland permits.
 * The result lives for the process lifetime. Returns wl_interface*. */
lean_obj_res lean_ui_wl_make_interface(b_lean_obj_arg desc, lean_obj_arg w);
/* wl_proxy_marshal_array_flags. `args` is nArgs * 8 bytes of wl_argument, in which a
 * string/array argument is given as an offset into `blob` (u32 offset, 0xffffffff = NULL;
 * arrays are u32 length-prefixed). Returns the new proxy (or 0 when iface == 0) and
 * installs the event recorder on it. flags bit0 = WL_MARSHAL_FLAG_DESTROY. */
lean_obj_res lean_ui_wl_marshal(size_t proxy, uint32_t opcode, size_t iface, uint32_t version,
                                uint32_t flags, b_lean_obj_arg args, b_lean_obj_arg blob,
                                lean_obj_arg w);
/* Install the event recorder on a proxy that was not created by lean_ui_wl_marshal
 * (the wl_display itself). */
lean_obj_res lean_ui_wl_listen(size_t proxy, lean_obj_arg w);
/* Flush requests, read and dispatch pending events without blocking, then return and clear
 * the recorded event bytes. One record:
 *   proxy:u64 opcode:u32 nArgs:u32 then per arg  type:u8 ('i','u','f','h','o','n','s','a')
 *   followed by 8 bytes (scalar / proxy pointer) or len:u32 + bytes (string / array).
 * fds ('h') are passed through as ints; Lean owns and closes them. */
lean_obj_res lean_ui_wl_pump(size_t display, lean_obj_arg w);
/* xkbcommon. Keymap arrives as (fd, size) from wl_keyboard.keymap; the fd is consumed. */
lean_obj_res lean_ui_xkb_keymap(uint32_t fd, uint32_t size, lean_obj_arg w); /* -> state* */
lean_obj_res lean_ui_xkb_modifiers(size_t state, uint32_t depressed, uint32_t latched,
                                   uint32_t locked, uint32_t group, lean_obj_arg w);
/* Key (evdev code, not +8). Returns keysym:u32, effective mods:u32, then UTF-8 text. */
lean_obj_res lean_ui_xkb_key(size_t state, uint32_t key, lean_obj_arg w);
/* Shared-memory file of `size` bytes (cursor/clipboard helpers). Returns fd. */
lean_obj_res lean_ui_memfd(uint32_t size, lean_obj_arg w);

/* ---- lean_ui_vulkan.c : libvulkan.so.1 through a generic call bridge -------------- */

/* dlopen + dlsym. Returns function address or 0. */
lean_obj_res lean_ui_dl_sym(b_lean_obj_arg lib, b_lean_obj_arg sym, lean_obj_arg w);
/* Call fn(a0..a5) with integer/pointer arguments (SysV / AAPCS64 integer class only).
 * `args` is 6 * u64. Returns u64 (VkResult is its low 32 bits). */
lean_obj_res lean_ui_call(size_t fn, b_lean_obj_arg args, lean_obj_arg w);
/* Native scratch memory for structs that must outlive one call. Zero-filled. */
lean_obj_res lean_ui_mem_alloc(size_t size, lean_obj_arg w);
lean_obj_res lean_ui_mem_free(size_t ptr, lean_obj_arg w);
/* Copy bytes into / out of native memory (also used on mapped VkDeviceMemory). */
lean_obj_res lean_ui_mem_write(size_t ptr, b_lean_obj_arg bytes, lean_obj_arg w);
lean_obj_res lean_ui_mem_read(size_t ptr, size_t size, lean_obj_arg w);

/* ---- lean_ui_text.c : Fontconfig + FreeType 2 + HarfBuzz -------------------------- */

/* Resolve a Fontconfig pattern ("Inter:weight=500") to a face. Returns face handle. */
lean_obj_res lean_ui_font_open(b_lean_obj_arg pattern, lean_obj_arg w);
/* Vertical metrics at `size64` (26.6 px): ascender:i32 descender:i32 lineHeight:i32. */
lean_obj_res lean_ui_font_metrics(size_t face, uint32_t size64, lean_obj_arg w);
/* Shape UTF-8 `text`. Returns nGlyphs records of
 *   glyph:u32 cluster:u32 xAdvance:i32 yAdvance:i32 xOffset:i32 yOffset:i32   (26.6 px)
 * A glyph id of 0 means the face lacks the character (Lean picks a fallback face). */
lean_obj_res lean_ui_shape(size_t face, uint32_t size64, b_lean_obj_arg text, lean_obj_arg w);
/* Rasterise one glyph at subpixel bin `subpx` (0..3 quarters of a pixel). Returns
 *   width:u32 height:u32 left:i32 top:i32 isColor:u8 then width*height bytes of coverage
 *   (or width*height*4 premultiplied BGRA when isColor). */
lean_obj_res lean_ui_rasterize(size_t face, uint32_t size64, uint32_t glyph, uint32_t subpx,
                               lean_obj_arg w);
#endif
