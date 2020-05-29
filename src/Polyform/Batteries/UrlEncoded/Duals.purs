module Polyform.Batteries.UrlEncoded.Duals
  ( array
  , boolean
  , field
  , Field
  , int
  , number
  , optionalField
  , singleValue
  )
  where

import Prelude

import Data.Array (singleton) as Array
import Data.Map (singleton) as Map
import Data.Maybe (Maybe(..), fromMaybe)
import Polyform.Batteries (Dual) as Batteries
import Polyform.Batteries.Number (NumberExpected)
import Polyform.Batteries.Number (dual) as Batteries.Number
import Polyform.Batteries.UrlEncoded.Query (Decoded(..), Key, Value) as Query
import Polyform.Batteries.UrlEncoded.Types (Dual)
import Polyform.Batteries.UrlEncoded.Validators (IntExpected, SingleValueExpected, BooleanExpected)
import Polyform.Batteries.UrlEncoded.Validators (array, boolean, field, int, optionalField, singleValue) as Validators
import Polyform.Dual (dual)
import Polyform.Dual (parser, serializer) as Dual
import Type.Row (type (+))

type Field m e b = Batteries.Dual m e (Maybe Query.Value) b

field
  ∷ ∀ a e m
  . Monad m
  ⇒ Query.Key
  → Field m e a
  → Dual m e Query.Decoded a
field name d = dual
  (Validators.field name (Dual.parser d))
  ( map (Query.Decoded <<< Map.singleton name <<< fromMaybe [])
  <<< Dual.serializer d
  )

boolean ∷ ∀ e m. Monad m ⇒ Field m (BooleanExpected + e) Boolean
boolean = dual
  Validators.boolean
  (pure <<< if _ then Just ["on"] else Just ["off"])

singleValue ∷ ∀ e m. Monad m ⇒ Field m (SingleValueExpected + e) String
singleValue = dual Validators.singleValue (pure <<< Just <<< Array.singleton)

number ∷ ∀ e m. Monad m ⇒ Field m (SingleValueExpected + NumberExpected + e) Number
number = Batteries.Number.dual Nothing <<< singleValue

int ∷ ∀ e m. Monad m ⇒ Field m (SingleValueExpected + IntExpected + e) Int
int = dual
  Validators.int
  (pure <<< Just <<< Array.singleton <<< show)

array ∷ ∀ e m. Monad m ⇒ Field m e (Array String)
array = dual
  Validators.array
  (pure <<< Just)

optionalField ∷ ∀ a e m. Monad m ⇒ Field m e a → Field m e (Maybe a)
optionalField d = dual
  (Validators.optionalField (Dual.parser d))
  (case _ of
    Just a → Dual.serializer d a
    Nothing → pure Nothing)

