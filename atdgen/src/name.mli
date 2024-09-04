(**
  Mapping from ATD to names
*)

type name_float =
  | Float of int option (* max decimal places *)
  | Int

type name_list_array = {
  start_index : int option;
  depth_first : bool;
}

type name_list = Array of name_list_array | Object

type name_variant = { name_cons : string }

type name_field = {
  name_fname  : string;           (* <name name=...> *)
  name_unwrapped : bool;
}

type name_sum = {
  name_open_enum : bool;
}

(** The different kinds of ATD nodes with their name-specific options. *)
type name_repr =
  | Bool
  | Cell
  | Def
  | External
  | Field of name_field
  | Float of name_float
  | Int
  | List of name_list
  | Nullable
  | Option
  | Record
  | String
  | Sum of name_sum
  | Tuple
  | Unit
  | Variant of name_variant
  | Wrap

val get_name_list : Atd.Annot.t -> name_list

val get_name_float : Atd.Annot.t -> name_float

val get_name_cons : string -> Atd.Annot.t -> string

val get_name_fname : string -> Atd.Annot.t -> string

val get_name_sum : Atd.Annot.t -> name_sum

val tests : (string * (unit -> bool)) list

