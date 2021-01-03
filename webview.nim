import json

{.passC: "-DWEBVIEW_STATIC -DWEBVIEW_IMPLEMENTATION".}
{.passC: "-I" & currentSourcePath().substr(0, high(currentSourcePath()) - 4) .}

when defined(linux):
  {.passC:"`pkg-config --cflags --libs gtk+-3.0 webkit2gtk-4.0`".}
  {.passL:"`pkg-config --cflags --libs gtk+-3.0 webkit2gtk-4.0`".}
elif defined(windows):#NOT TESTED
  # {.passC:"-mwindows".}
  # {.passL:"-L./dll/x64 -lwebview -lWebView2Loader".}
  {.passC: "-DWEBVIEW_WINAPI=1".}
  {.passL: "-lole32 -lcomctl32 -loleaut32 -luuid -lgdi32".}
elif defined(macosx):
  {.passL: "-framework WebKit".}
type
  Webview* {.header:"webview.h", importc:"webview_t".} = pointer
  WebviewHint* = enum
    WEBVIEW_HINT_NONE,WEBVIEW_HINT_MIN,WEBVIEW_HINT_MAX,WEBVIEW_HINT_FIXED

proc set_size*(webview:Webview,width:cint,height:cint,hints:WebviewHint) {.importc:"webview_set_size", header:"webview.h".}
proc create*(debug:cint,window:pointer):Webview {.importc:"webview_create", header:"webview.h".}
proc set_title*(webview:Webview,title:cstring) {.importc:"webview_set_title", header:"webview.h".}
proc navigate*(webview:Webview,url:cstring) {.importc:"webview_navigate", header:"webview.h".}
proc destroy*(webview:Webview) {.importc:"webview_destroy", header:"webview.h".}
proc run*(webview:Webview) {.importc:"webview_run", header:"webview.h".}

proc listener_bind* (webview: Webview, name: cstring, fn: proc (id: cstring; data: cstring) {.cdecl.}, arg: cstring) {.importc:"webview_bind", header:"webview.h".}
proc listener_return* (webview : Webview, id:cstring, status: cint, result: cstring) {.importc:"webview_return", header:"webview.h".}

template bind_proc* (webview: Webview, name: cstring, actions: proc(payload: JsonNode) : JsonNode) =
  proc callback(id: cstring, raw: cstring){.cdecl, gensym.} =
    let payload = parseJson($(raw))
    let result = actions(payload)
    webview.listener_return(id,0,$(result))

  webview.listener_bind name, callback, ""
