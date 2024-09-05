(* Auto-generated from "test_name.atd" *)
              [@@@ocaml.warning "-27-32-33-35-39"]

type sum_classic = Test_name_t.sum_classic =  A | B | C 

type sum_poly = Test_name_t.sum_poly

type sum_args_poly = Test_name_t.sum_args_poly

type sum_args_classic = Test_name_t.sum_args_classic

type wrap_string = Test_name_t.wrap_string

type sum_open_enum_poly = Test_name_t.sum_open_enum_poly

type sum_open_enum_classic = Test_name_t.sum_open_enum_classic = 
    A
  | B
  | C
  | Z of string


type plain_string = Test_name_t.plain_string

let string_of_sum_classic : sum_classic -> _ = (
  function
    | A -> "a"
    | B -> "bb"
    | C -> "Ccc"
)

let sum_classic_of_string = (
  function
    | "a" ->
      (A : sum_classic)
    | "bb" ->
      (B : sum_classic)
    | "Ccc" ->
      (C : sum_classic)
    | x ->
      Atdgen_extra_runtime.On_run.invalid_variant_tag x
)

let string_of_sum_poly = (
  function
    | `A -> "a"
    | `B -> "bb"
    | `C -> "Ccc"
)

let sum_poly_of_string = (
  function
    | "a" ->
      `A
    | "bb" ->
      `B
    | "Ccc" ->
      `C
    | x ->
      Atdgen_extra_runtime.On_run.invalid_variant_tag x
)

and string_of_sum_args_poly = (
  function
    | `A _ -> "a"
    | `B _ -> "bb"
    | `C _ -> "Ccc"
    | `D _ -> "d!"
    | `E _ -> "E"
    | `F -> ""
)

and sum_args_poly_of_string = (
  function
    | "" ->
      `F
    | x ->
      Atdgen_extra_runtime.On_run.invalid_variant_tag x
)

and string_of_sum_args_classic = (
  function
    | `A _ -> "a"
    | `B _ -> "bb"
    | `C _ -> "Ccc"
    | `D _ -> "d!"
    | `E _ -> "E"
    | `F -> ""
)

and sum_args_classic_of_string = (
  function
    | "" ->
      `F
    | x ->
      Atdgen_extra_runtime.On_run.invalid_variant_tag x
)

let string_of__1 = (
  fun x ->
    let x = ( Fun.id ) x in (
      fun x -> x
    ) x
)

let _1_of_string = (
  fun x ->
    let x = (
      fun x -> x
    ) x in
    ( Fun.id ) x
)

let string_of_wrap_string = (
  string_of__1
)

let wrap_string_of_string = (
  _1_of_string
)

let string_of_sum_open_enum_poly = (
  function
    | `A -> "a"
    | `B -> "bb"
    | `C -> "Ccc"
    | `Z x -> (
        fun x -> x
      ) x
)

let sum_open_enum_poly_of_string = (
  function
    | "a" ->
      `A
    | "bb" ->
      `B
    | "Ccc" ->
      `C
    | x ->
      `Z x
)

let string_of_sum_open_enum_classic : sum_open_enum_classic -> _ = (
  function
    | A -> "a"
    | B -> "bb"
    | C -> "Ccc"
    | Z x -> (
        fun x -> x
      ) x
)

let sum_open_enum_classic_of_string = (
  function
    | "a" ->
      (A : sum_open_enum_classic)
    | "bb" ->
      (B : sum_open_enum_classic)
    | "Ccc" ->
      (C : sum_open_enum_classic)
    | x ->
      (Z x : sum_open_enum_classic)
)

let string_of_plain_string = (
  fun x -> x
)

let plain_string_of_string = (
  fun x -> x
)

