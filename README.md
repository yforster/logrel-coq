Presentation
=======

This repo contains formalisation work on implementing a logical relation over MLTT with one universe.
This formalisation follows the [work done by Abel et al.]((https://github.com/mr-ohman/logrel-mltt/)) (described in [Decidability of conversion for Type Theory in Type Theory, 2018](https://dl.acm.org/doi/10.1145/3158111)), and [Loïc Pujet's work](https://github.com/loic-p/logrel-mltt) on removing induction-recursion from the previous formalization, making it feasible to translate it from Agda to Coq.

The definition of the logical relation (**LR**) ressembles Loïc's in many ways, but also had to be modified for a few reasons :
- Because of universe constraints and the fact that functors cannot be indexed by terms in Coq whereas it is possible in Agda, the relevant structures had to be parametrized by a type level and a recursor, and the module system had to be dropped out entirely.
- Since Coq and Agda's positivity checking for inductive types is different, it turns out that **LR**'s definition, even though it does not use any induction-induction or induction-recursion in Agda, is not accepted in Coq. As such, the predicate over Π-types for **LR** has been modified compared to Agda. You can find a MWE of the difference in positivity checking in the two systems in [Positivity.v] and [Positivity.agda].

In order to avoid some work on the syntax, this project uses the [AutoSubst](https://github.com/uds-psl/autosubst-ocaml) project to generate syntax-related boilerplate.

Building
===========

The project builds with Coq version `8.15.2`. It needs the opam package `coq-smpl`. Once these have been installed, you can simply issue `make` in the root folder.

The syntax has been generated using AutoSubst OCaml with the options `-s ucoq -v ge813 -allfv` (see the [AutoSubst OCaml documentation](https://github.com/uds-psl/autosubst-ocaml) for installation instructions for it). Currently, this implementation builds only with older version of Coq, so we cannot add a recipe to the MakeFile for re-generating the syntax.

Getting Started
=================

A few things to get accustomed to if you want to use the development.

Notations and refolding
-----------

In a style somewhat similar to the [Math Classes](https://math-classes.github.io/) project,
generic notations for typing, conversion, renaming, etc. are implemented using type-classes.
While some care has been taken to try and respect the abstractions on which the notations are
based, they might still be broken by carefree reduction performed by tactics. In this case,
the `refold` tactic can be used, as the name suggests, to refold all lost notations.

Induction principles
----------

The development relies on large, mutually-defined inductive relations. To make proofs by induction
more tractable, functions `XXXInductionConcl` are provided. These take the predicates
to be mutually proven, and construct the type of the conclusion of a proof by mutual induction.
Thus, a typical induction proof looks like the following:

``` coq-lang
Section Foo.

Let P := … .
…

Theorem Foo : XXXInductionConcl P … .
Proof.
  apply XXXInduction.

End Section.
```
The names of the arguments printed when querying `About XXXInductionConcl` should make it clear 
to which mutually-defined relation each predicate corresponds.

Detailed file description
==========

Utilities and AST
---------

| File | Description |
|---|----|
[Utils] | Basic generically useful definitions, notations, tactics…
[BasicAst] | Definitions preceding those of the AST of terms: sorts, binder annotations…
[AutoSubst/] | Abstract syntax tree, renamings, substitutions and many lemmas, generated using the [autosubst-ocaml] opam package.
[AutoSubst/Extra] | Extra instances, notations and tactics to better handle the boilerplate generated by AutoSubst.
[Notations] | Notations used throughout the development. It can be used as an index for notations!
[NormalForms] | Definition of normal and neutral forms, and properties. |

Common typing-related definitions
-------

| File | Description |
|---|----|
[Context] | Definition of contexts and operations on them.
[Weakening] | Definition of a well-formed weakening, and some properties.
[UntypedReduction] | Definiton and basic properties of untyped reduction, used to define algorithmic typing.
[GenericTyping] | A generic notion of typing, used to define the logical relation, to be instantiated three times: once with the fully declarative version, once with the mixed declarative and algorithmic one, and once with the fully algorithmic one.

Declarative typing and its properties
--------------

| File | Description |
|---|----|
[DeclarativeTyping] | Defines the theory's typing rules in a declarative fashion, the current definition has a single universe as well as product types and eta-conversion for functions. |
[DeclarativeInstance] | Proof that declarative typing is an instance of generic typing. |

Logical relation and its properties
-----------

| File | Description |
|---|----|
[LogicalRelation] | Contains the logical relation's (**LR**) definition. |
[LRInduction] | Defines the induction principles over **LR**. Because of universe constraints, **LR** needs two induction principles, one for each type levels. |
[Escape] | Contains a proof of the escape lemma for **LR** |
[Shapeview] | Technique to avoid considering non-diagonal cases for two reducibly convertible types. |
[Reflexivity] | Reflexivity of the logical relation.
[Irrelevance] | Irrelevance of the logical relation: two convertible types decode to equivalent predicates. Symmetry is a direct corollary. |

Algorithmic typing and its properties
-----------------

| File | Description |
|---|----|
[AlgorithmicTyping] | Definition of the second notion of typing : algorithmic typing (and algorithmic conversion together with it).
[LogRelConsequences] | Consequences of the logical relation on declarative typing necessary to establish properties of algorithmic typing.
[BundledAlgorithmicTyping] | Algorithmic typing bundled with its pre-conditions, and a tailored induction principle showing invariant preservation in the "algorithm".
[AlgorithmicConvProperties] | Properties of algorithmic conversion, in order to derive the second instance of generic typing, consisting of declarative typing and algorithmic conversion. |

Miscellaneous
-----------

| File | Description |
|---|----|
| [Positivity.v] and [Positivity.agda] | Showcase the difference between Coq and Agda's positivity checkers. |

[Utils]: ./theories/Utils.v
[BasicAst]: ./theories/BasicAst.v
[Context]: ./theories/Context.v
[AutoSubst/]: ./theories/AutoSubst/
[AutoSubst/Extra]: ./theories/AutoSubst/Extra.v
[Notations]: ./theories/Notations.v
[Automation]: ./theories/Automation.v
[NormalForms]: ./theories/NormalForms.v
[UntypedReduction]: ./theories/UntypedReduction.v
[GenericTyping]: ./theories/GenericTyping.v
[DeclarativeTyping]: ./theories/DeclarativeTyping.v
[Properties]: ./theories/Properties.v
[DeclarativeInstance]: ./theories/DeclarativeInstance.v
[LogicalRelation]: ./theories/LogicalRelation.v
[LRInduction]: ./theories/LRInduction.v
[Escape]: ./theories/Escape.v
[Reflexivity]: ./theories/Reflexivity.v
[Irrelevance]: ./theories/Irrelevance.v
[ShapeView]: ./theories/ShapeView.v
[Positivity.v]: ./theories/Positivity.v
[Weakening]: ./theories/Weakening.v
[Substitution]: ./theories/Substitution.v
[AlgorithmicTyping]: ./theories/AlgorithmicTyping.v
[AlgorithmicConvProperties]: ./theories/AlgorithmicConvProperties.v
[LogRelConsequences]: ./theories/LogRelConsequences.v
[BundledAlgorithmicTyping]: ./theories/BundledAlgorithmicTyping.v

[autosubst-ocaml]: https://github.com/uds-psl/autosubst-ocaml
[Positivity.agda]: ./theories/Positivity.agda
