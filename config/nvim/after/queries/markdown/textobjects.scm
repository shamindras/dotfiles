; extends

; Section text object: heading + all content until the next same-level heading
; "around" = entire section including the heading line
; "inner" = section content after the heading line
(section
  (atx_heading) @_heading
  .
  (_) @section.inner)  @section.outer

(section
  (setext_heading) @_heading
  .
  (_) @section.inner) @section.outer
