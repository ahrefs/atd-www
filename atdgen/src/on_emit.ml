(*
  OCaml code generator for name serialization.
*)

open Atd.Import
open Indent

open Atd.Ast
open Mapping

let target : Ocaml.target = Name

type mapping = (Ocaml.Repr.t, Name.name_repr) Mapping.mapping
type field_mapping = (Ocaml.Repr.t, Name.name_repr) Mapping.field_mapping
type variant_mapping = (Ocaml.Repr.t, Name.name_repr) Mapping.variant_mapping

type field =
  { mapping : field_mapping
  ; ocaml_fname : string
  ; name_fname : string
  ; ocaml_default : string option
  ; optional : bool
  ; unwrapped : bool
  }

type param = {
  deref : mapping -> mapping;
  unknown_field_handler : string option;
  (* Optional handler that takes a field name as argument
     and does something with it such as displaying a warning message. *)

  force_defaults : bool;

  preprocess_input : string option;
  (* intended for UTF-8 validation *)

  ocaml_version: (int * int) option;

}

let make_ocaml_name_intf ~with_create buf deref defs =
  List.concat_map snd defs
  |> List.filter Ox_emit.include_intf
  |> List.iter (fun x ->
      let v = Option.value_exn x.def_value in
      match deref v with
      | Unit _
      | Bool _
      | Int _
      | Float _
      | String _
      | Tvar _
      | Record _
      | Tuple _
      | List _
      | Option _
      | Nullable _
      | External _ ->
        ()
      | Sum _ | Wrap _ | Name _ ->
        let s = x.def_name in
        let full_name = Ox_emit.get_full_type_name x in
        bprintf buf "\
val string_of_%s :
  %s -> string
  (** Serialize a value of type {!%s} into a name. *)

"
          s
          full_name
          s;
        bprintf buf "\
val %s_of_string :
  string -> %s
  (** Deserialize a name to a value of type {!%s}. *)

"
          s
          full_name
          s;
  )

(*
  ('a, 'b) t            -> write_t write__a write__b
  ('a, foo) t           -> write_t write__a write_foo
  ('a, (foo, 'b) bar) t -> write_t write__a (write_bar write_foo write__b)
*)
let get_left_to_string_name name =
  "string_of_" ^ name

let get_left_of_string_name name =
  name ^ "_of_string"

let rec make_writer ?type_constraint p (x : mapping) : Indent.t list =
  match x with
  | Sum (_, a, Sum o, Sum j) ->
      let tick = Ocaml.tick o in
      let open_enum = j.Name.name_open_enum in
      let standard_writer : Indent.t list =
        [
          Annot ("fun", Line "function");
          Block (
            Array.to_list (
              Array.map
                (fun x -> Inline (make_variant_writer p ~tick ~open_enum x))
                a
            )
          )
        ]
      in
      standard_writer

  | Wrap (_, x, Wrap o, Wrap) ->
      (match o with
         None -> make_writer p x
       | Some { Ocaml.ocaml_unwrap; _} ->
           [
             Annot ("fun", Line "fun x ->");
             Block [
               Line (sprintf "let x = ( %s ) x in (" ocaml_unwrap);
               Block (make_writer p ?type_constraint x);
               Line ") x";
             ]
           ]
      )

  | Name (_, x, _args, None, None) ->
      [
        Line (get_left_to_string_name x);
      ]

  | String _ ->
      [ Annot ("fun", Line "fun x -> x"); ]

  | External (_, _, _, External _, External)
  | Unit _
  | Bool _
  | Int _
  | Float _
  | Tvar _
  | Record (_, _, Record _, Record)
  | Tuple (_, _, Tuple, Tuple)
  | List (_, _, List _, List _)
  | Option (_, _, Option, Option)
  | Nullable (_, _, Nullable, Nullable) ->
      assert false

  | _ -> assert false


and make_variant_writer p ~tick ~open_enum x : Indent.t list =
  let o, j =
    match x.var_arepr, x.var_brepr with
      Variant o, Variant j -> o, j
    | _ -> assert false
  in
  let ocaml_cons = o.Ocaml.ocaml_cons in
  let name_cons = j.Name.name_cons in
  match x.var_arg with
  | None ->
    [ Line (sprintf "| %s%s -> %S" tick ocaml_cons name_cons); ]
  | Some v when open_enum ->
    [
      Line (sprintf "| %s%s x -> (" tick ocaml_cons);
      Block [
        Block (make_writer p v);
        Line ") x";
      ];
    ]
  | Some v ->
    [ Line (sprintf "| %s%s _ -> %S" tick ocaml_cons name_cons); ]

let rec make_reader p ?type_constraint (x : mapping) : Indent.t list =
  match x with
  | Sum (_, a, Sum o, Sum j) ->
      let tick = Ocaml.tick o in
      let open_enum = j.Name.name_open_enum in
      let l = Array.to_list a in
      let fallback_expr =
        [ Line "Atdgen_extra_runtime.On_run.invalid_variant_tag x" ]
      in
      let cases =
        make_cases_reader p type_constraint ~tick ~open_enum ~fallback_expr l
      in
      let standard_reader =
        [
          Annot ("fun", Line "function");
          Block cases;
        ]
      in
      standard_reader

  | Wrap (_, x, Wrap o, Wrap) ->
      (match o with
         None -> make_reader p ?type_constraint x
       | Some { Ocaml.ocaml_wrap; _ } ->
           [
             Annot ("fun", Line "fun x ->");
             Block [
               Line "let x = (";
               Block (make_reader p ?type_constraint x);
               Line ") x in";
               Line (sprintf "( %s ) x" ocaml_wrap);
             ]
           ]
      )

  | Name (_, x, _args, None, None) ->
      [ Line (get_left_of_string_name x) ]

  | String _ ->
      [ Annot ("fun", Line "fun x -> x"); ]

  | Unit _
  | Bool _
  | Int _
  | Float _
  | External _
  | Tvar _
  | Record (_, _, Record _, Record)
  | Tuple (_, _, Tuple, Tuple)
  | List (_, _, List _, List _)
  | Option (_, _, Option, Option)
  | Nullable (_, _, Nullable, Nullable) ->
      assert false

  | _ -> assert false

and make_case_reader p type_annot ~tick ~open_enum (x : variant_mapping) : (bool * Indent.t list) =
  let o, j =
    match x.var_arepr, x.var_brepr with
      Variant o, Variant j -> o, j
    | _ -> assert false
  in
  let ocaml_cons = o.Ocaml.ocaml_cons in
  let name_cons = j.Name.name_cons in
  let catch_all, expr =
    match x.var_arg with
    | None ->
      false, [ Line (sprintf "| %S -> %s%s" name_cons tick ocaml_cons); ]
    | Some _ when open_enum ->
      let expr = [ Line (Ox_emit.opt_annot type_annot (sprintf "%s%s x" tick ocaml_cons)); ] in
      true, expr
    | Some _ ->
      false, []
  in
  (catch_all, expr)

and make_cases_reader p type_annot ~tick ~open_enum ~fallback_expr l =
  let cases =
    List.map
      (make_case_reader p type_annot ~tick ~open_enum)
      l
  in
  let catch_alls, specific_cases =
    List.partition fst cases
  in
  let catch_all =
    match catch_alls with
    | [] -> [ Line "| x ->"; Block fallback_expr; ]
    | [(_, expr)] -> [ Line "| x ->"; Block expr; ]
    | _ -> assert false
  in
  let all_cases =
    List.map (function
      | false, expr -> Inline expr
      | true, _ -> assert false
    ) specific_cases
  in
  all_cases @ catch_all


let make_ocaml_name_writer p ~original_types is_rec let1 let2 def deref =
  let x = Option.value_exn def.def_value in
  match deref x with
  | Unit _
  | Bool _
  | Int _
  | Float _
  | String _
  | Tvar _
  | Record _
  | Tuple _
  | List _
  | Option _
  | Nullable _
  | External _ ->
    []
  | Sum _ | Wrap _ | Name _ ->
  let name = def.def_name in
  let type_constraint = Ox_emit.get_type_constraint ~original_types def in
  let _param = def.def_param in
  let to_string = get_left_to_string_name name in
  let type_constraint =
    match Ox_emit.needs_type_annot x with
    | true -> Some type_constraint
    | false -> None
  in
  let writer_expr = make_writer ?type_constraint p x in
  [
    Line (sprintf "%s %s =" let2 to_string);
    Block (List.map Indent.strip writer_expr);
    Line "";
  ]

let make_ocaml_name_reader p ~original_types is_rec let1 let2 def deref =
  let x = Option.value_exn def.def_value in
  match deref x with
  | Unit _
  | Bool _
  | Int _
  | Float _
  | String _
  | Tvar _
  | Record _
  | Tuple _
  | List _
  | Option _
  | Nullable _
  | External _ ->
    []
  | Sum _ | Wrap _ | Name _ ->
  let name = def.def_name in
  let type_constraint = Ox_emit.get_type_constraint ~original_types def in
  let _param = def.def_param in
  let of_string = get_left_of_string_name name in
  let type_constraint =
    match Ox_emit.needs_type_annot x with
    | true -> Some type_constraint
    | false -> None
  in
  let reader_expr = make_reader p ?type_constraint x in
  [
    Line (sprintf "%s %s =" let2 of_string);
    Block (List.map Indent.strip reader_expr);
    Line "";
  ]

let make_ocaml_name_impl
    ~unknown_field_handler
    ~with_create ~preprocess_input ~original_types
    ~force_defaults ~ocaml_version
    buf deref defs =
  let p =
    { deref
    ; unknown_field_handler
    ; force_defaults
    ; preprocess_input
    ; ocaml_version
    } in
  defs
  |> List.concat_map (fun (is_rec, l) ->
    let l = List.filter (fun x -> x.def_value <> None) l in
    let writers =
      List.map_first (fun ~is_first def ->
        let let1, let2 = Ox_emit.get_let ~is_rec ~is_first in
        make_ocaml_name_writer p ~original_types is_rec let1 let2 def deref
      ) l
    in
    let readers =
      List.map_first (fun ~is_first def ->
        let let1, let2 = Ox_emit.get_let ~is_rec ~is_first in
        make_ocaml_name_reader p ~original_types is_rec let1 let2 def deref
      ) l
    in
    List.flatten (writers @ readers))
  |> Indent.to_buffer buf;
  Ox_emit.maybe_write_creator_impl ~with_create deref buf defs


(*
  Translation of the types into the ocaml/name mapping.
*)

let check_name_sum loc name_sum_param variants =
  if name_sum_param.Name.name_open_enum then (
    let variants_with_arg =
      List.filter (function {var_arg = Some _; _} -> true | _ -> false) variants
    in
    match variants_with_arg with
    | [] ->
        Error.error loc
          "Missing catch-all case of the form `| Other of string`, \
           required by <name open_enum>."
    | [x] -> (
        match x.var_arg with
        | None -> assert false
        | Some (String _) -> ()
        | Some mapping ->
            let loc = Mapping.loc_of_mapping mapping in
            Error.error loc
              "The argument of this variant must be of type string \
               as imposed by <name open_enum>."
      )
    | _ ->
        Error.error loc
          "Multiple variants have arguments, which doesn't make sense \
           when combined with <name open_enum>."
  )

let rec mapping_of_expr (x : type_expr) =
  match x with
  | Sum (loc, l, an) ->
      let ocaml_t = Ocaml.Repr.Sum (Ocaml.get_ocaml_sum Name an) in
      let name_sum_param = Name.get_name_sum an in
      let name_t = Name.Sum (Name.get_name_sum an) in
      let variants = List.map mapping_of_variant l in
      check_name_sum loc name_sum_param variants;
      Sum (loc, Array.of_list variants,
           ocaml_t, name_t)

  | Record (loc, l, an) ->
      let ocaml_t = Ocaml.Repr.Record (Ocaml.get_ocaml_record Name an) in
      let ocaml_field_prefix = Ocaml.get_ocaml_field_prefix Name an in
      let name_t = Name.Record in
      Record (loc,
              Array.of_list
                (List.map (mapping_of_field ocaml_field_prefix) l),
              ocaml_t, name_t)

  | Tuple (loc, l, _) ->
      let ocaml_t = Ocaml.Repr.Tuple in
      let name_t = Name.Tuple in
      Tuple (loc, Array.of_list (List.map mapping_of_cell l),
             ocaml_t, name_t)

  | List (loc, x, an) ->
      let ocaml_t = Ocaml.Repr.List (Ocaml.get_ocaml_list Name an) in
      let name_t = Name.List (Name.get_name_list an) in
      List (loc, mapping_of_expr x, ocaml_t, name_t)

  | Option (loc, x, _) ->
      let ocaml_t = Ocaml.Repr.Option in
      let name_t = Name.Option in
      Option (loc, mapping_of_expr x, ocaml_t, name_t)

  | Nullable (loc, x, _) ->
      let ocaml_t = Ocaml.Repr.Nullable in
      let name_t = Name.Nullable in
      Nullable (loc, mapping_of_expr x, ocaml_t, name_t)

  | Shared (loc, _, _) ->
      Error.error loc "Sharing is not supported by the Name interface"

  | Wrap (loc, x, an) ->
      let ocaml_t =
        Ocaml.Repr.Wrap (Ocaml.get_ocaml_wrap ~type_param:[] Name loc an) in
      let name_t = Name.Wrap in
      Wrap (loc, mapping_of_expr x, ocaml_t, name_t)

  | Name (loc, (x, s, l), an) ->
      (match s with
         "unit" ->
           Unit (loc, Unit, Unit)
       | "bool" ->
           Bool (loc, Bool, Bool)
       | "int" ->
           let o = Ocaml.get_ocaml_int Name an in
           Int (loc, Int o, Int)
       | "float" ->
           let j = Name.get_name_float an in
           Float (loc, Float, Float j)
       | "string" ->
           String (loc, String, String)
       | s ->
           Name (loc, s, List.map mapping_of_expr l, None, None)
      )
  | Tvar (loc, s) ->
      Tvar (loc, s)

and mapping_of_cell (cel_loc, x, an) =
  { cel_loc
  ; cel_value = mapping_of_expr x
  ; cel_arepr =
      Ocaml.Repr.Cell
        { Ocaml.ocaml_default = Ocaml.get_ocaml_default Name an
        ; ocaml_fname = ""
        ; ocaml_mutable = false
        ; ocaml_fdoc = Atd.Doc.get_doc cel_loc an
        }
  ; cel_brepr = Name.Cell
  }

and mapping_of_variant = function
  | Inherit _ -> assert false
  | Variant (var_loc, (var_cons, an), o) ->
      { var_loc
      ; var_cons
      ; var_arg = Option.map mapping_of_expr o
      ; var_arepr = Ocaml.Repr.Variant
            { Ocaml.ocaml_cons = Ocaml.get_ocaml_cons Name var_cons an
            ; ocaml_vdoc = Atd.Doc.get_doc var_loc an
            }
      ; var_brepr =
          Name.Variant
            { Name.name_cons = Name.get_name_cons var_cons an
            }
      }

and mapping_of_field ocaml_field_prefix = function
  | `Inherit _ -> assert false
  | `Field (f_loc, (f_name, f_kind, an), x) ->
      let { Ox_mapping.ocaml_default; unwrapped } =
        Ox_mapping.analyze_field Name f_loc f_kind an in
      { f_loc
      ; f_name
      ; f_kind
      ; f_value = mapping_of_expr x
      ; f_arepr = Ocaml.Repr.Field
            { Ocaml.ocaml_default
            ; ocaml_fname =
                Ocaml.get_ocaml_fname Name (ocaml_field_prefix ^ f_name) an
            ; ocaml_mutable = Ocaml.get_ocaml_mutable Name an
            ; ocaml_fdoc = Atd.Doc.get_doc f_loc an
            }
      ; f_brepr = Name.Field
            { Name.name_fname = Name.get_name_fname f_name an
            ; name_unwrapped = unwrapped
            }
      }

let defs_of_atd_modules l =
  List.map (fun (is_rec, l) ->
    ( is_rec
    , List.map (function Atd.Ast.Type atd ->
        Ox_emit.def_of_atd atd ~target ~external_:Name.External
          ~mapping_of_expr ~def:Name.Def
      ) l
    )
  ) l


(*
  Glue
*)
let make_ocaml_files ~unknown_field_handler ~preprocess_input =
  Ox_emit.make_ocaml_files
    ~defs_of_atd_modules
    ~make_ocaml_intf:make_ocaml_name_intf
    ~make_ocaml_impl:(make_ocaml_name_impl ~unknown_field_handler ~preprocess_input)
    ~target:Name
