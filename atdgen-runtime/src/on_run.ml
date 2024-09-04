
let invalid_variant_tag x =
  Printf.ksprintf invalid_arg "Unsupported variant %S" x
