Browsing the sources
============================

The table of content of the development is accessible [here](https://coqhott.github.io/logrel-coq/coqdoc/toc.html).

File description
==========

To complement it, here is a rough description of the content of every file.

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
[Induction] | Defines the induction principles over **LR**. Because of universe constraints, **LR** needs two induction principles, one for each type levels. |
[Escape] | Contains a proof of the escape lemma for **LR** |
[ShapeView] | Technique to avoid considering non-diagonal cases for two reducibly convertible types. |
[Reflexivity] | Reflexivity of the logical relation.
[Irrelevance] | Irrelevance of the logical relation: two reducibly convertible types decode to equivalent predicates. Symmetry is a direct corollary. |

Algorithmic typing and its properties
-----------------

| File | Description |
|---|----|
[AlgorithmicTyping] | Definition of the second notion of typing: algorithmic typing (and algorithmic conversion together with it).
[LogRelConsequences] | Consequences of the logical relation on declarative typing necessary to establish properties of algorithmic typing.
[BundledAlgorithmicTyping] | Algorithmic typing bundled with its pre-conditions, and a tailored induction principle showing invariant preservation in the "algorithm".
[AlgorithmicConvProperties] | Properties of algorithmic conversion, in order to derive the second instance of generic typing, consisting of declarative typing and algorithmic conversion. |
[AlgorithmicTypingProperties] |  Derive the third instance of generic typing, consisting entierly of algorithmic notions. |

Miscellaneous
-----------

| File | Description |
|---|----|
| [Positivity.v] and [Positivity.agda] | Showcase the difference between Coq and Agda's positivity checkers. |

[Utils]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.Utils.html
[BasicAst]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.BasicAst.html
[Context]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.Context.html
[AutoSubst/]: ./theories/AutoSubst/
[AutoSubst/Extra]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.AutoSubst.Extra.html
[Notations]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.Notations.html
[Automation]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.Automation.html
[NormalForms]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.NormalForms.html
[UntypedReduction]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.UntypedReduction.html
[GenericTyping]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.GenericTyping.html
[DeclarativeTyping]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.DeclarativeTyping.html
[Properties]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.Properties.html
[DeclarativeInstance]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.DeclarativeInstance.html
[LogicalRelation]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.LogicalRelation.html
[Induction]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.LogicalRelation.Induction.html
[Escape]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.LogicalRelation.Escape.html
[Reflexivity]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.LogicalRelation.Reflexivity.html
[Irrelevance]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.LogicalRelation.Irrelevance.html
[ShapeView]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.LogicalRelation.ShapeView.html
[Positivity.v]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.Positivity.html
[Weakening]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.Weakening.html
[AlgorithmicTyping]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.AlgorithmicTyping.html
[AlgorithmicConvProperties]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.AlgorithmicConvProperties.html
[AlgorithmicTypingProperties]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.AlgorithmicTypingProperties.html
[LogRelConsequences]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.LogRelConsequences.html
[BundledAlgorithmicTyping]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.BundledAlgorithmicTyping.html

[autosubst-ocaml]: https://github.com/uds-psl/autosubst-ocaml
[Positivity.agda]: https://coqhott.github.io/logrel-coq/coqdoc/LogRel.Posit.htmlity.agda