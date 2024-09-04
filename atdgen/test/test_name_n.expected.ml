(* Auto-generated from "test_name.atd" *)
              [@@@ocaml.warning "-27-32-33-35-39"]

type sum_classic = Test_name_t.sum_classic =  A1 | B1 | C1 

type sum_poly = Test_name_t.sum_poly

type sum_args_poly = Test_name_t.sum_args_poly

type sum_args_classic = Test_name_t.sum_args_classic

type sum_open_enum_poly = Test_name_t.sum_open_enum_poly

type sum_open_enum_classic = Test_name_t.sum_open_enum_classic = 
    A3
  | B3
  | C3
  | Z3 of string


let string_of_sum_classic =
  function
    | A1 -> "a"
    | B1 -> "bb"
    | C1 -> "Ccc"

let sum_classic_of_string =
  function
    | "a" -> A1
    | "bb" -> B1
    | "Ccc" -> C1
    | x ->
      Atdgen_extra_runtime.On_run.invalid_variant_tag x

let string_of_sum_poly =
  function
    | `A -> "a"
    | `B -> "bb"
    | `C -> "Ccc"

let sum_poly_of_string =
  function
    | "a" -> `A
    | "bb" -> `B
    | "Ccc" -> `C
    | x ->
      Atdgen_extra_runtime.On_run.invalid_variant_tag x

and string_of_sum_args_poly =
  function
    | `A _ -> "a"
    | `B _ -> "bb"
    | `C _ -> "Ccc"
    | `D _ -> "d!"
    | `E _ -> "E"
    | `F -> ""

and sum_args_poly_of_string =
  function
    | "" -> `F
    | x ->
      Atdgen_extra_runtime.On_run.invalid_variant_tag x

and string_of_sum_args_classic =
  function
    | `A2 _ -> "a"
    | `B2 _ -> "bb"
    | `C2 _ -> "Ccc"
    | `D2 _ -> "d!"
    | `E2 _ -> "E"
    | `F2 -> ""

and sum_args_classic_of_string =
  function
    | "" -> `F2
    | x ->
      Atdgen_extra_runtime.On_run.invalid_variant_tag x

let string_of_sum_open_enum_poly =
  function
    | `A -> "a"
    | `B -> "bb"
    | `C -> "Ccc"
    | `Z x -> (
        fun x -> x
      ) x

let sum_open_enum_poly_of_string =
  function
    | "a" -> `A
    | "bb" -> `B
    | "Ccc" -> `C
    | x ->
      `Z x

let string_of_sum_open_enum_classic =
  function
    | A3 -> "a"
    | B3 -> "bb"
    | C3 -> "Ccc"
    | Z3 x -> (
        fun x -> x
      ) x

let sum_open_enum_classic_of_string =
  function
    | "a" -> A3
    | "bb" -> B3
    | "Ccc" -> C3
    | x ->
      (Z3 x : sum_open_enum_classic)

