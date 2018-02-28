module Test.URI.Fragment where

import Prelude

import Test.Spec (Spec, describe)
import Test.Util (testIso)
import URI.Fragment as Fragment

spec ∷ ∀ eff. Spec eff Unit
spec =
  describe "Fragment parser/printer" do
    testIso (Fragment.parser pure) Fragment.print "#" (Fragment.fromString "")
    testIso (Fragment.parser pure) Fragment.print "#foo" (Fragment.fromString "foo")
    testIso (Fragment.parser pure) Fragment.print "#foo%23bar" (Fragment.fromString "foo#bar")
    testIso (Fragment.parser pure) Fragment.print "#foo%23bar" (Fragment.unsafeFromString "foo%23bar")
