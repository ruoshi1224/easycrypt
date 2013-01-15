(* -------------------------------------------------------------------- *)
open EcSymbols
open EcParsetree
open EcTypes
open EcDecl
open EcTypesmod

(* -------------------------------------------------------------------- *)
type tyerror =
  | UnknownVariable          of qsymbol
  | UnknownFunction          of qsymbol
  | UnknownTypeName          of qsymbol
  | UnknownOperatorForSig    of qsymbol * ty list
  | InvalidNumberOfTypeArgs  of qsymbol * int * int
  | ApplInvalidArity
  | UnboundTypeParameter     of symbol
  | OpNotOverloadedForSig    of qsymbol * ty list
  | UnexpectedType           of ty * ty * ty * ty
  | NonLinearPattern         of lpattern
  | DuplicatedLocals         of psymbol option
  | ProbaExpressionForbidden
  | PatternForbiden
  | ModApplToNonFunctor
  | ModApplInvalidArity
  | ModApplInvalidArgInterface
  | UnificationVariableNotAllowed
  | TypeVariableNotAllowed
  | RandomExprNotAllowed
  | UnNamedTypeVariable
  | UnusedTypeVariable

exception TyError of Location.t * tyerror

val tyerror : Location.t -> tyerror -> 'a
(* -------------------------------------------------------------------- *)

type typolicy
val tp_tydecl : typolicy
val tp_relax  : typolicy

(* -------------------------------------------------------------------- *)
val transty : typolicy -> EcEnv.env -> EcUnify.unienv -> pty -> ty 
val transtys :  
    typolicy -> EcEnv.env -> EcUnify.unienv -> pty list -> ty list


(* -------------------------------------------------------------------- *)
val select_op :
     bool
  -> EcEnv.env
  -> qsymbol
  -> EcUnify.unienv
  -> ty list
  -> (EcPath.path * operator * ty * EcUnify.unienv) list

(* -------------------------------------------------------------------- *)
type epolicy = {
  epl_prob : bool;
}

(* [transexp env policy ue pe] translates the *parsed* expression [pe]
 * to a *typed* expression, under environment [env], using policy
 * [policy], and unification map [ue].
*)
val transexp : EcEnv.env -> epolicy -> EcUnify.unienv -> pexpr -> tyexpr * ty
val transexpcast :
    EcEnv.env -> epolicy -> EcUnify.unienv -> ty -> pexpr -> tyexpr

(* -------------------------------------------------------------------- *)
module Fenv : sig 
  type fenv
  val mono_fenv : EcEnv.env -> fenv
  val bind_locals : fenv -> EcIdent.t list -> ty list -> fenv
  val fenv_hyps : EcEnv.env -> EcFol.hyps -> fenv
end
val transformula : Fenv.fenv -> EcUnify.unienv -> 
  pformula -> EcFol.form 

(* -------------------------------------------------------------------- *)
val transsig   : EcEnv.env -> psignature -> tysig
val transtymod : EcEnv.env -> pmodule_type -> tymod
val transmod   : EcEnv.env -> EcIdent.t -> pmodule_expr -> module_expr
