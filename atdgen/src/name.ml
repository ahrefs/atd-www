(*
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

let sections = [ "name"; "json"; ]

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
  | Wrap (* should we add support for Base64 encoding of binary data? *)

let name_float_of_string s : [ `Float | `Int ] option =
  match s with
      "float" -> Some `Float
    | "int" -> Some `Int
    | _ -> None

let name_precision_of_string s =
  try Some (int_of_string s)
  with _ -> None

let get_name_precision an =
  Atd.Annot.get_opt_field
    ~parse:name_precision_of_string
    ~sections
    ~field:"precision"
    an

let get_name_float an : name_float =
  match
    Atd.Annot.get_field
      ~parse:name_float_of_string
      ~default:`Float
      ~sections
      ~field:"repr"
      an
  with
      `Float -> Float (get_name_precision an)
    | `Int -> Int

let name_list_repr_of_string s : [ `Array | `Object ] option =
  match s with
  | "array" -> Some `Array
  | "object" -> Some `Object
  | _ -> (* error *) None

let get_name_open_enum an =
  Atd.Annot.get_flag ~sections ~field:"open_enum" an

let get_name_sum an = {
  name_open_enum = get_name_open_enum an;
}

let get_name_list an =
  let repr =
    Atd.Annot.get_field
      ~parse:name_list_repr_of_string
      ~default:`Array
      ~sections
      ~field:"repr"
      an
  in
  match repr with
  | `Object -> Object
  | `Array ->
  let start_index =
    Atd.Annot.get_field
      ~parse:(function "none" -> Some None | x -> Some (Some (int_of_string x)))
      ~default:None
      ~sections
      ~field:"start"
      an
  in
  let depth_first =
    Atd.Annot.get_field
      ~parse:(fun s -> Some (bool_of_string s))
      ~default:false
      ~sections
      ~field:"depth"
      an
  in
  Array { start_index; depth_first; }

let get_name_cons default an =
  Atd.Annot.get_field
    ~parse:(fun s -> Some s)
    ~default
    ~sections
    ~field:"name"
    an

let get_name_fname default an =
  Atd.Annot.get_field
    ~parse:(fun s -> Some s)
    ~default
    ~sections
    ~field:"name"
    an

let tests = [
]
