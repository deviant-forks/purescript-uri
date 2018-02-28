module Test.URI.AbsoluteURI where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.String.NonEmpty as NES
import Data.These (These(..))
import Data.Tuple (Tuple(..))
import Partial.Unsafe (unsafePartial)
import Test.Spec (Spec, describe)
import Test.Util (testIso)
import URI.AbsoluteURI (Authority(..), HierPath, HierarchicalPart(..), Host(..), Path(..), PathAbsolute(..), PathRootless(..), Port, Query, AbsoluteURI(..), AbsoluteURIOptions, UserInfo)
import URI.AbsoluteURI as AbsoluteURI
import URI.Host.RegName as RegName
import URI.HostPortPair (HostPortPair)
import URI.HostPortPair as HostPortPair
import URI.Path.Segment as PathSegment
import URI.Port as Port
import URI.Query as Query
import URI.Scheme as Scheme

spec ∷ ∀ eff. Spec eff Unit
spec =
  describe "AbsoluteURI parser/printer" do
    testIso
      (AbsoluteURI.parser options)
      (AbsoluteURI.print options)
      "couchbase://localhost/testBucket?password=&docTypeKey="
      (AbsoluteURI
        (Scheme.unsafeFromString "couchbase")
        (HierarchicalPartAuth
          (Authority
            Nothing
            (Just (This (NameAddress (RegName.unsafeFromString $ unsafePartial $ NES.unsafeFromString "localhost")))))
          (path ["testBucket"]))
        (Just (Query.unsafeFromString "password=&docTypeKey=")))
    testIso
      (AbsoluteURI.parser options)
      (AbsoluteURI.print options)
      "couchbase://localhost:9999/testBucket?password=pass&docTypeKey=type&queryTimeoutSeconds=20"
      (AbsoluteURI
        (Scheme.unsafeFromString "couchbase")
        (HierarchicalPartAuth
          (Authority
            Nothing
            (Just (Both (NameAddress (RegName.unsafeFromString $ unsafePartial $ NES.unsafeFromString "localhost")) (Port.unsafeFromInt 9999))))
          (path ["testBucket"]))
        (Just (Query.unsafeFromString "password=pass&docTypeKey=type&queryTimeoutSeconds=20")))
    testIso
      (AbsoluteURI.parser options)
      (AbsoluteURI.print options)
      "foo:/abc/def"
      (AbsoluteURI
        (Scheme.unsafeFromString "foo")
        (HierarchicalPartNoAuth
          (Just (Left (PathAbsolute (Just (Tuple (PathSegment.unsafeSegmentNZFromString $ unsafePartial $ NES.unsafeFromString "abc") [PathSegment.unsafeSegmentFromString "def"]))))))
        Nothing)
    testIso
      (AbsoluteURI.parser options)
      (AbsoluteURI.print options)
      "foo:abc/def"
      (AbsoluteURI
        (Scheme.unsafeFromString "foo")
        (HierarchicalPartNoAuth
          (Just (Right (PathRootless (Tuple (PathSegment.unsafeSegmentNZFromString $ unsafePartial $ NES.unsafeFromString "abc") [PathSegment.unsafeSegmentFromString "def"])))))
        Nothing)

path ∷ Array String → Maybe Path
path = Just <<< Path <<< map PathSegment.unsafeSegmentFromString

options ∷ Record (AbsoluteURIOptions UserInfo (HostPortPair Host Port) Path HierPath Query)
options =
  { parseUserInfo: pure
  , printUserInfo: id
  , parseHosts: HostPortPair.parser pure pure
  , printHosts: HostPortPair.print id id
  , parsePath: pure
  , printPath: id
  , parseHierPath: pure
  , printHierPath: id
  , parseQuery: pure
  , printQuery: id
  }
