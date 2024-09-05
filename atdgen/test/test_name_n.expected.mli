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

val string_of_sum_classic :
  sum_classic -> string
  (** Serialize a value of type {!sum_classic} into a name. *)

val sum_classic_of_string :
  string -> sum_classic
  (** Deserialize a name to a value of type {!sum_classic}. *)

val string_of_sum_poly :
  sum_poly -> string
  (** Serialize a value of type {!sum_poly} into a name. *)

val sum_poly_of_string :
  string -> sum_poly
  (** Deserialize a name to a value of type {!sum_poly}. *)

val string_of_sum_args_poly :
  sum_args_poly -> string
  (** Serialize a value of type {!sum_args_poly} into a name. *)

val sum_args_poly_of_string :
  string -> sum_args_poly
  (** Deserialize a name to a value of type {!sum_args_poly}. *)

val string_of_sum_args_classic :
  sum_args_classic -> string
  (** Serialize a value of type {!sum_args_classic} into a name. *)

val sum_args_classic_of_string :
  string -> sum_args_classic
  (** Deserialize a name to a value of type {!sum_args_classic}. *)

val string_of_wrap_string :
  wrap_string -> string
  (** Serialize a value of type {!wrap_string} into a name. *)

val wrap_string_of_string :
  string -> wrap_string
  (** Deserialize a name to a value of type {!wrap_string}. *)

val string_of_sum_open_enum_poly :
  sum_open_enum_poly -> string
  (** Serialize a value of type {!sum_open_enum_poly} into a name. *)

val sum_open_enum_poly_of_string :
  string -> sum_open_enum_poly
  (** Deserialize a name to a value of type {!sum_open_enum_poly}. *)

val string_of_sum_open_enum_classic :
  sum_open_enum_classic -> string
  (** Serialize a value of type {!sum_open_enum_classic} into a name. *)

val sum_open_enum_classic_of_string :
  string -> sum_open_enum_classic
  (** Deserialize a name to a value of type {!sum_open_enum_classic}. *)

val string_of_plain_string :
  plain_string -> string
  (** Serialize a value of type {!plain_string} into a name. *)

val plain_string_of_string :
  string -> plain_string
  (** Deserialize a name to a value of type {!plain_string}. *)

